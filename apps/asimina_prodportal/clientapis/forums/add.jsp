<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.*, java.util.*"%>

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

    if(client!=null)
    {
        String body = extractPostRequestBody(request);

        if(body!=null && body.length() > 0)
        {
			JSONObject req = new JSONObject(body);
            try{			
                String sourceType = "forum";
                String content = getData("content",req);
                String category = getData("category",req);
                String forumTopic = getData("topic",req).toLowerCase();
                String type = "forum";
                String siteuuid = getData("suid",req);
                JSONArray tagsArray = null;
				if(req.has("tags")) tagsArray = req.getJSONArray("tags");

				if(content.length() == 0)
                {
                    message="content is missing for type forum";
                    status = 10;
                }
                else if(forumTopic.length() == 0)
                {
                    message="forum topic is missing for type forum";
                    status = 10;
                }
                else if(siteuuid.length() == 0)
                {
                    message="site uuid is required";
                    status = 10;
                }
                else if(tagsArray == null || tagsArray.length() == 0)
                {
                    message="tags are required";
                    status = 10;
                }
                else{
					Set rsSite = Etn.execute("Select * from sites where suid = "+escape.cote(siteuuid));
					if(rsSite.rs.Rows == 0)
					{
						message="Invalid site uuid provided";
						status = 10;						
					}
					else
					{
						rsSite.next();
						String siteid = rsSite.value("id");
						String clientId=client.getProperty("client_uuid");						
						

						List<String> invalidTags = new ArrayList<>();
						List<String> tags = new ArrayList<>();
						for(int i=0;i<tagsArray.length();i++){
							String tagId = PortalHelper.parseNull(tagsArray.getString(i));
							if(tagId.length() > 0){
								Set rsTag=Etn.execute("SELECT tag_id FROM "+GlobalParm.getParm("COMMONS_DB")+".forum_tags WHERE site_id ="+escape.cote(siteid)+" and tag_id ="+escape.cote(tagId));
								if(rsTag.next()) tags.add(tagId);
								else invalidTags.add(tagId);
							}
						}

						if(invalidTags.size() > 0)
						{
							message="Invalid tags provide : " + invalidTags.toString().replace("[","").replace("]","");
							status = 10;
						}
						else
						{
							String postId = UUID.randomUUID().toString();

							String query="INSERT INTO client_reviews (post_id,site_id,source_type,type,content,client_id,forum_topic,is_verified,category) " +
							 "VALUES("+escape.cote(postId)+","+escape.cote(siteid)+","+escape.cote(sourceType)+","+escape.cote(type)+","+
							 escape.cote(content)+","+escape.cote(clientId)+","+escape.cote(forumTopic)+",'1',"+escape.cote(category)+")";

							int i = Etn.executeCmd(query);
							if(i > 0)
							{
								for(String tagId : tags)
								{
									Etn.executeCmd("insert into client_review_tags (post_id,tag_id) values("+escape.cote(postId)+","+escape.cote(tagId)+")");
								}								
								message="Inserted successfully";
								obj.put("forum_id", postId);
								
								Etn.executeCmd("insert into publish_content (cid,site_id,publication_type,ctype,priority,created_by,updated_by)"+
									" values ("+escape.cote(postId)+","+escape.cote(siteid)+","+escape.cote("publish")+","+escape.cote("forum")+
									",NOW(),"+escape.cote(clientId)+","+escape.cote(clientId)+")");

								Set rsNew=Etn.execute("select val from config where code='SEMAPHORE'");
								if(rsNew!=null && rsNew.rs.Rows>0 && rsNew.next()){
									Etn.execute("SELECT semfree("+escape.cote(rsNew.value("val"))+")");
								}
							}
							else
							{
								status = 40;
								message = "Some error occured while adding forum";
							}
							
						}
					}
                }


            }catch(Exception e){
                message="Some error occured while inserting.";
                status=2;
            }
        }
        else
        {
		    message="Body was empty.";
            status=1;
        }
    }
    else
    {
        message="User not logged in.";
        status=100;
    }

    obj.put("msg",message);
    obj.put("status", status);

    out.write(obj.toString());

%>