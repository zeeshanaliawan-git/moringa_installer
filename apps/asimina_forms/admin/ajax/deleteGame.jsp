<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%
	request.setCharacterEncoding("utf-8");
	response.setCharacterEncoding("utf-8");
%>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.util.Logger, java.lang.Exception"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap,org.json.*,java.util.Enumeration,javax.servlet.ServletException, com.etn.beans.app.GlobalParm,javax.servlet.http.*, org.apache.poi.ss.formula.functions.Column"%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate,com.etn.beans.app.GlobalParm, com.etn.asimina.util.UIHelper"%>
<%@ page import="java.util.ArrayList,java.util.Arrays" %>
<%@ include file="../../common2.jsp" %>

<%!
    Boolean gameExists(com.etn.beans.Contexte etn,String gameId)
    {   
        Set rs = etn.execute("SELECT * FROM games_unpublished WHERE id = "+escape.cote(gameId));
        if(rs != null && rs.rs.Rows > 0)
            return true;
        return false;
    }
%>

<%
    JSONObject result = new JSONObject();
    if(! "POST".equalsIgnoreCase(request.getMethod()) )
    {
        result.put("err_code","invalid_request_method");
        result.put("err_description","Invalid Method Called");
        result.put("status", 10);
    }
    else{
        String gameId = parseNull(request.getParameter("game_id"));
        String siteId = getSelectedSiteId(session);
        String logedInUserId = parseNull(""+Etn.getId());
        
        String err_code="";
        String err_description="";
        
        String msg="";
        int status = 0;

        if(gameExists(Etn,gameId)){
            Logger.debug("deleteGame.jsp","Deleting Game with id="+gameId);
            try{
                Etn.execute("UPDATE games_unpublished SET is_deleted = 1, updated_on=now(), updated_by="+escape.cote(logedInUserId)+" WHERE site_id=" + escape.cote(siteId) + " AND id=" + escape.cote(gameId));
                Etn.execute("UPDATE games SET is_deleted = 1, updated_on=now(), updated_by="+escape.cote(logedInUserId)+" WHERE site_id=" + escape.cote(siteId) + " AND id=" + escape.cote(gameId));
                Etn.execute("UPDATE process_forms_unpublished pfu SET pfu.is_deleted = 1 WHERE pfu.site_id=" + escape.cote(siteId) + " AND pfu.form_id=( SELECT gu.form_id FROM games_unpublished gu WHERE gu.id="+ escape.cote(gameId) +" )");
                Logger.debug("deleteGame.jsp","Game Deleted");
                msg="Successfully Deleted!";
            }catch(Exception e){
                status = 10;
                err_code="unable_to_delete";
                err_description="Unable to delete Game";
            }
        }
        else{
            status = 10;
            err_code="Game_doesnt_Exists";
            err_description="Game doesnt Exists";
        }

        if(status == 0)
        {
            result.put("msg",msg);
            result.put("status",status);
        }
        else{
            result.put("err_code",err_code);
            result.put("err_description",err_description);
            result.put("status",status);
        }
    }

    out.write(result.toString());
%>