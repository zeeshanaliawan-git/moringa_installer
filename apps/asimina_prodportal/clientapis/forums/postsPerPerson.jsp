<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.JSONObject,org.json.JSONArray, java.util.*"%>

<%
    String message="";
    int status=0;

    JSONObject obj = new JSONObject();

    String siteuuid = PortalHelper.parseNull(request.getParameter("suid"));
	
	if(siteuuid.length() == 0)
	{
		message="Site uuid is required";
		status = 10;						
		obj.put("msg",message);
		obj.put("status", status);

		out.write(obj.toString());
		return;		
	}
	Set rsSite = Etn.execute("Select * from sites where suid = "+escape.cote(siteuuid));
	if(rsSite.rs.Rows == 0)
	{
		message="Invalid site uuid provided";
		status = 10;						
		obj.put("msg",message);
		obj.put("status", status);

		out.write(obj.toString());
		return;
	}
	
	rsSite.next();
	String siteid = rsSite.value("id");


    com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
    

	try{ 
        String postid = PortalHelper.parseNull(request.getParameter("fid"));
        
        if(postid.length()>0){
		 
            if(client != null)
            {
                Set rs = Etn.execute("select count(*) as count from client_reviews where post_id="+escape.cote(postid)+" and client_id="+
                    escape.cote(client.getProperty("client_uuid"))+" and is_deleted=0 and source_type='forum' and type='comment' and site_id="+escape.cote(siteid));
                if(rs!=null && rs.next()){
                    obj.put("nb_comments",rs.value("count"));
                }

            }else{
                message="User not logged in.";
                status=2;
            }	
						
        }else{
            message="Post id is required.";
            status=2;
        }
						
		            
	}catch(Exception e){
		e.printStackTrace();
        message="Some  error occured while getting data.";
        status=2;
	}

	obj.put("msg",message);
    obj.put("status", status);

    out.write(obj.toString());
%>