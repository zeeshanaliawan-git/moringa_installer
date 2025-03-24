<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.JSONObject, java.util.*"%>


<%!
	String extractPostRequestBody(HttpServletRequest request) throws java.io.IOException {
	    if ("POST".equalsIgnoreCase(request.getMethod())) {
	        java.util.Scanner s = new java.util.Scanner(request.getInputStream(), "UTF-8").useDelimiter("\\A");
	        return s.hasNext() ? s.next() : "";
	    }
	    return null;
	}
	String getData(String param,JSONObject req){
	    try{
	        return com.etn.util.XSSHandler.clean(PortalHelper.parseNull(req.get(param)));
        }catch (Exception e){
	        return "";
        }

	}
%>

<%
    String message="";
    int status=0;
    JSONObject obj = new JSONObject();

    com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);

    if(client!=null){
        String body = extractPostRequestBody(request);
		if(body != null){
			JSONObject req = new JSONObject(body);
            try{
                String sourceId= getData("source_id",req);
                String sourceType= getData("source_type",req).toLowerCase();
                String postParentId= getData("post_id",req);
                String type = getData("type",req);
                String category= getData("category",req);
                String rating= getData("rating",req);
                String content= getData("content",req);

				if(sourceId.length() == 0)
				{
                    message="source_id is required";
                    status = 10;										
				}
				else if(sourceType.length() == 0)
				{
                    message="source_type is required";
                    status = 10;										
				}
				else if(sourceType.equals("page") == false && sourceType.equals("product") == false && sourceType.equals("forum") == false)
				{
                    message="invalid source type provided";
                    status = 10;										
				}
				else if(type.length() == 0)
				{
                    message="type is required";
                    status = 10;										
				}
				else if(type.equals("comment") == false && type.equals("review") == false)
				{
                    message="invalid type provided";
                    status = 10;										
				}
				else if(content.length() == 0 && type.equals("comment")) 
				{
                    message="content is missing for type comment";
                    status = 10;					
				}
				else if(type.equals("review") && (content.length() == 0 || rating.length() == 0) ) 
				{
                    message="Either content or rating must be provided for type review";
                    status = 10;					
				}
				else
				{
                    String clientId=client.getProperty("client_uuid");
                    String postId = UUID.randomUUID().toString();

					String catalogDb = GlobalParm.getParm("CATALOG_DB") + ".";

					String siteId = "0";
					if(sourceType.equals("page"))
					{
						Set rsP = Etn.execute("select * from "+GlobalParm.getParm("PAGES_DB")+".pages where uuid = "+escape.cote(sourceId));
						if(rsP.next()) siteId = rsP.value("site_id");
					}
					else if(sourceType.equals("product"))
					{
						Set rsP = Etn.execute("select c.site_id from "+catalogDb+"products p inner join "+catalogDb+"catalogs c on c.id = p.catalog_id where p.product_uuid ="+escape.cote(sourceId));
						if(rsP.next()) siteId = rsP.value("site_id");
					}
					else if(sourceType.equals("forum"))
					{
						Set rsP = Etn.execute("select site_id from client_reviews where source_type = 'forum' and post_id = "+escape.cote(sourceId));
						if(rsP.next()) siteId = rsP.value("site_id");
					}


                    String query="INSERT INTO client_reviews (post_id,site_id,source_id,source_type,post_parent_id,type,category,rating,content,client_id) " +
                     "VALUES("+escape.cote(postId)+","+escape.cote(siteId)+","+escape.cote(sourceId)+","+escape.cote(sourceType)+","+escape.cote(postParentId)+","+
                     escape.cote(type)+","+escape.cote(category)+","+escape.cote(rating)+","+escape.cote(content)+","+escape.cote(clientId)+")";

                    int i = Etn.executeCmd(query);
					if(i > 0)
					{
						message="Inserted successfully";
						obj.put("post_id",postId);
					}
					else
					{
						message="Some error occured";
						status = 40;
					}
                }
            }catch (Exception e){
                message="Some error occured while inserting.";
                status=2;
            }
        }else{
		    message="Body was empty.";
            status=1;
        }
    }else{
        message="User not logged in.";
        status=100;
    }

    obj.put("msg",message);
    obj.put("status", status);

    out.write(obj.toString());
%>