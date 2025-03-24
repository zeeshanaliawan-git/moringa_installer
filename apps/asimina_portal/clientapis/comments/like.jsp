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
                try{
					String clientId=client.getProperty("client_uuid");

					Set rs2 = Etn.execute("select * from client_review_reactions where post_id="+escape.cote(postId)+" and client_id="+escape.cote(clientId)+" and is_like= 1");
					
					if(rs2.rs.Rows>0){
						Etn.executeCmd("delete from client_review_reactions where post_id = "+escape.cote(postId)+" and client_id="+com.etn.sql.escape.cote(clientId)+" and is_like=1 ");
					}else{
						Etn.executeCmd("INSERT INTO client_review_reactions (post_id,client_id,is_like) VALUES ("+escape.cote(postId)+","+escape.cote(clientId)+",1) ON DUPLICATE KEY UPDATE is_like=1");
					}
					
                    JSONObject data = new JSONObject();

                    Set rs=Etn.execute("SELECT coalesce(sum(case is_like when 1 then 1 else 0 end),0) as likes ,coalesce(sum(case is_like when 0 then 1 else 0 end),0) as dislikes FROM client_review_reactions WHERE post_id="+escape.cote(postId));
                    rs.next();

                    Etn.executeCmd("UPDATE client_reviews SET nb_dislikes="+escape.cote(rs.value("dislikes"))+",nb_likes ="+escape.cote(rs.value("likes"))+" WHERE post_id="+escape.cote(postId));

                    message="Action performed successfully.";

                    data.put("post_id",postId);
                    data.put("total_likes",rs.value("likes"));
                    data.put("total_dislikes",rs.value("dislikes"));
                    obj.put("data", data);
                }catch (Exception e){
                    message="Error executing insert statement";
                    status=3;
                }
            }else{
                    message="Required fields are missing";
                    status = 10;
            }

        }catch (Exception e){
            message="Some error occured while inserting.";
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