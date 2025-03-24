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
<%@ page import="java.util.ArrayList,java.util.Arrays,java.text.DateFormat,java.text.SimpleDateFormat,java.util.Date" %>
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
    JSONArray array = new JSONArray();

    if(! "GET".equalsIgnoreCase(request.getMethod()) )
    {
        result.put("err_code","invalid_request_method");
        result.put("err_description","Invalid Method Called");
        result.put("status", 10);
    }
    else
    {
        
        String gameId = parseNull(request.getParameter("game_id"));
        String siteId = getSelectedSiteId(session);
        
        String err_code="";
        String err_description="";
        String msg="";

        int status = 0;

        JSONObject ja = new JSONObject();

        if(gameExists(Etn,gameId)){
            Logger.debug("getGame.jsp","Get Game with id="+gameId);
            Set rs = Etn.execute("Select * FROM games_unpublished WHERE is_deleted != 1 AND id="+escape.cote(gameId));
            if(rs!=null && rs.rs.Rows > 0 && rs.next())
            {
                for(String column: rs.ColName){
                    ja.put(column.toLowerCase(), parseNull(rs.value(column)));        
                }
                Set prizeRs = Etn.execute("SELECT * FROM game_prize_unpublished WHERE game_uuid="+escape.cote(gameId)+" ORDER BY CREATED_ON ASC");
                
                JSONArray prizes = new JSONArray();
                while(prizeRs!=null && prizeRs.rs.Rows > 0 && prizeRs.next())
                {
                    JSONObject prize = new JSONObject();
                    
                    for(String column: prizeRs.ColName){
                        if(column.contains("_date")){
                            DateFormat format = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
                            Date date = format.parse(parseNull(prizeRs.value(column)));
                            prize.put(column.toLowerCase(),date);
                        }
                        else
                        prize.put(column.toLowerCase(), parseNull(prizeRs.value(column)));        
                    }
                    prizes.put(prize);
                }
                ja.put("prizes",prizes);
				
				Set rsL = Etn.execute("Select * from "+GlobalParm.getParm("COMMONS_DB")+".sites_langs where site_id = "+escape.cote(siteId)+" order by langue_id ");
				String langId = "0";
				if(rsL.next()) langId = rsL.value("langue_id");
				
				JSONArray jColumns = new JSONArray();

				Set rsFormColumns = Etn.execute("select f.db_column_name, fd.label from process_form_fields_unpublished f "+
						" join process_form_field_descriptions_unpublished fd on fd.form_id = f.form_id and fd.field_id = f.field_id and fd.langue_id = "+escape.cote(langId)+
						" where f.type not in ('texthidden','hr_line','label','imgupload','hyperlink','button','emptyblock','textrecaptcha') and f.form_id = "+escape.cote(rs.value("form_id")));
				while(rsFormColumns.next())
				{
					JSONObject jColumn = new JSONObject();
					jColumn.put("col", rsFormColumns.value("db_column_name"));
					jColumn.put("name", rsFormColumns.value("label"));
					jColumns.put(jColumn);
				}
				ja.put("columns", jColumns);
            }
            else{
                status = 10;
                err_code="Game_doesnt_Exists";
                err_description="Game doesnt Exists";    
            }
            
        }
        else{
            status = 10;
            err_code="Game_doesnt_Exists";
            err_description="Game doesnt Exists";
        }

        if(status == 0)
        {
            result.put("data",ja);
            System.out.println(result.toString());
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