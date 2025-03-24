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
    String sourceId;
    JSONObject obj = new JSONObject();

    com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);

    if(client!=null){
        String body = extractPostRequestBody(request);
		if(body != null){
			JSONObject req = new JSONObject(body);
			try{
			    String postId = getData("post_id",req);
			    if(postId.length()>0){
                    String category= getData("category",req);
                    String rating= getData("rating",req);
                    String content= getData("content",req);

					String clientId=client.getProperty("client_uuid");
					Set rs = Etn.execute("select * from client_reviews where post_id = "+escape.cote(postId)+" and client_id = "+escape.cote(clientId));
					if(rs.rs.Rows > 0)//client is the owner of comment so can delete
					{
						Etn.executeCmd("UPDATE client_reviews SET category="+escape.cote(category)+",rating="+escape.cote(rating)+",content="+escape.cote(content)+" WHERE post_id="+escape.cote(postId));
						message="Updated successfully.";
					}
					else
					{
						message="You are not allowed to update this comment";
						status = 20;
					}
                }else{
                    message="Required fields are missing";
                    status = 10;
                }

            }catch (Exception e){
                message="Some error occured while updating.";
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