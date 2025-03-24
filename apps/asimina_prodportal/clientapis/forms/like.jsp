<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.*, java.util.*"%>

<%
    String message="";
    int status=0;
    JSONObject obj = new JSONObject();

    com.etn.asimina.beans.Client client = com.etn.asimina.session.ClientSession.getInstance().getLoggedInClient(Etn, request);
	

    try{
		String formId = PortalHelper.parseNull(request.getParameter("form_id"));
		String fieldId = PortalHelper.parseNull(request.getParameter("field_id"));
		
		String formsDb = GlobalParm.getParm("FORMS_DB");

        if(formId.length() == 0){
            message="Form id is required";
            status = 10;						
            obj.put("msg",message);
            obj.put("status", status);

            out.write(obj.toString());
            return;		
        }
        else if(fieldId.length() == 0){
            message="Field id is required";
            status = 10;						
            obj.put("msg",message);
            obj.put("status", status);

            out.write(obj.toString());
            return;		
        }else{
            if(client!=null){
                String clientId=PortalHelper.parseNull(client.getProperty("client_uuid"));

                Set rs=Etn.execute("select * from client_reactions where source_id="+escape.cote(formId)+" and source_type='form' and client_id="+
                escape.cote(clientId)+" and field_id="+escape.cote(fieldId));

                if(rs.rs.Rows>0){
                    Etn.executeCmd("delete from client_reactions where source_id="+escape.cote(formId)+" and source_type='form' and client_id="+
                        escape.cote(clientId)+" and field_id="+escape.cote(fieldId));
                }

                Etn.executeCmd("insert into client_reactions (source_id,source_type,client_id,is_like,field_id) values("+escape.cote(formId)+
                    ",'form',"+escape.cote(clientId)+",1,"+escape.cote(fieldId)+")");
            }else{
                String sessionId = PortalHelper.parseNull(request.getParameter("sessionId"));

                Set rs=Etn.execute("select * from client_reactions where source_id="+escape.cote(formId)+" and source_type='form' and session_id="+
                escape.cote(sessionId)+" and field_id="+escape.cote(fieldId));

                if(rs.rs.Rows>0){
                    Etn.executeCmd("delete from client_reactions where source_id="+escape.cote(formId)+" and source_type='form' and session_id="+
                        escape.cote(sessionId)+" and field_id="+escape.cote(fieldId));
                }

                Etn.executeCmd("insert into client_reactions (source_id,source_type,session_id,is_like,field_id) values("+escape.cote(formId)+
                    ",'form',"+escape.cote(sessionId)+",1,"+escape.cote(fieldId)+")");
            }
        }

            
    }catch (Exception e){
        message="Error to like field.";
        status=2;
    }

    obj.put("msg",message);
    obj.put("status", status);

    out.write(obj.toString());
%>