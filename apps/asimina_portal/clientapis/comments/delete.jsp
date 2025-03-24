<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.JSONObject, java.util.*"%>


<%
    String message="";
    int status=0;
    JSONObject obj = new JSONObject();

    com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);

    if(client!=null){
        try{
            String postId = PortalHelper.parseNull(request.getParameter("post_id"));
            if(postId.length()>0){				
				String clientId=client.getProperty("client_uuid");
				Set rs = Etn.execute("select * from client_reviews where post_id = "+escape.cote(postId)+" and client_id = "+escape.cote(clientId));
				if(rs.rs.Rows > 0)//client is the owner of comment so can delete
				{
					Etn.executeCmd("UPDATE client_reviews SET is_deleted=1 WHERE post_id="+escape.cote(postId));
					message="Deleted successfully.";
				}
				else
				{
					message="You are not allowed to delete this comment";
					status = 20;
				}
            }else{
				message="Required fields are missing";
				status = 10;
            }
        }catch (Exception e){
            message="Some error occured while delete.";
            status=2;
        }
    }else{
        message="User not logged in.";
        status=100;
    }





    obj.put("msg",message);
    obj.put("status", status);

    out.write(obj.toString());
%>