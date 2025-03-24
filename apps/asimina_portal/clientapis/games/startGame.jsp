<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>


<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm,com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.*, java.util.*,java.sql.Timestamp"%>
<%@ include file="common.jsp"%>

<%

	String formsDb=GlobalParm.getParm("FORMS_DB");
	String gameId = PortalHelper.parseNull(request.getParameter("id"));
	String queryParm = PortalHelper.parseNull(request.getParameter("q"));

	try{
	
		if(gameId.length() == 0)
		{
			out.write(errorResponse("game_id_missing","critical","Game id is required","","","","",0));
			return;		
		}
		Set rs = Etn.execute("select g.id, case when COALESCE(g.launch_date,'') = '' then '' else "+
		"date_format(COALESCE(g.launch_date,'0000-00-00 00:00:00'),'%Y/%m/%dT%H:%i:%s') end as 'launch_date'"+
		",case when COALESCE(g.end_date,'') = '' then '' else "+
		"date_format(COALESCE(g.end_date,'9999-00-00 00:00:00'), '%Y/%m/%dT%H:%i:%s') end as 'end_date'"+
		",g.name,g.play_game_column,g.can_lose,g.attempts_per_user,g.win_type,g.site_id,pf.table_name,g.form_id from "+formsDb+".games g left join "
		+formsDb+".process_forms pf on pf.form_id=g.form_id where g.id="+escape.cote(gameId));

		if(rs!=null && rs.rs.Rows>0 && rs.next()){
			if(queryParm.length() == 0)
			{
				out.write(errorResponse("search_value_missing","critical","Search value is required",PortalHelper.parseNull(rs.value("win_type")),PortalHelper.parseNull(rs.value("launch_date")),PortalHelper.parseNull(rs.value("end_date")),PortalHelper.parseNull(rs.value("attempts_per_user")),0));
				return;
			}
			else
			{
				String tableName = PortalHelper.parseNull(rs.value("table_name"));
				String identityType = PortalHelper.parseNull(rs.value("play_game_column"));
				String identity=identityType;
				String identityTypeValue=queryParm;

				Set rsFieldLabel = Etn.execute("select pffd.label from "+formsDb+".process_form_fields pff left join "+formsDb+".process_form_field_descriptions pffd on "+
					" pff.field_id=pffd.field_id where pff.form_id="+escape.cote(PortalHelper.parseNull(rs.value("form_id")))+
					" and pff.db_column_name="+escape.cote(identityType));
				if(rsFieldLabel.next()){
					identity = PortalHelper.parseNull(rsFieldLabel.value("label"));
				}

				Set rsTimeCheck =Etn.execute("select * from "+formsDb+".games where (COALESCE(launch_date,'0000-00-00 00:00:00')<=now() or launch_date='0000-00-00 00:00:00')"+
					"and (COALESCE(end_date,'9999-00-00 00:00:00') >now() or end_date='0000-00-00 00:00:00') and id="+escape.cote(gameId));

				if(rsTimeCheck!=null && rsTimeCheck.rs.Rows>0 && rsTimeCheck.next())
				{
					Set rs2=Etn.execute("select _etn_game_status as 'status',"+tableName+"_id as 'id' from "+formsDb+"."+tableName+
						" where "+identityType+"="+escape.cote(identityTypeValue)+" order by id desc Limit 1");
					
					if(rs2!=null &&rs2.rs.Rows>0 && rs2.next()){

						Etn.executeCmd("delete from "+formsDb+"."+tableName+" where "+identityType+"="+escape.cote(identityTypeValue)+" and "+tableName+"_id !="+
						escape.cote(rs2.value("id"))+" and COALESCE(_etn_game_status,'') != 'end'");

						Set rs3=Etn.execute("select * from "+formsDb+"."+tableName+" where "+identityType+"="+escape.cote(identityTypeValue));

						if(rs3!=null && rs3.rs.Rows<=Integer.parseInt(rs.value("attempts_per_user"))){
							String gameStatus=PortalHelper.parseNull(rs2.value("status"));

							if(gameStatus.length()==0){
								Etn.executeCmd("update "+formsDb+"."+tableName+" set _etn_game_status='start',updated_on=NOW() where "+
									tableName+"_id="+escape.cote(rs2.value("id")));
								out.write(successResponseStartGame(gameId,PortalHelper.parseNull(rs.value("can_lose")),Etn,"readyToPlay",tableName));
								changeGamePhase(Etn, gameId, rs2.value("id"), tableName);
								return;

							}else if(gameStatus.equalsIgnoreCase("start")){
								out.write(successResponseStartGame(gameId,PortalHelper.parseNull(rs.value("can_lose")),Etn,"readyToPlay",tableName));
								return;
							}else{
								if(rs3.rs.Rows==Integer.parseInt(rs.value("attempts_per_user"))){
									out.write(successResponseStartGame(gameId,PortalHelper.parseNull(rs.value("can_lose")),Etn,"maxGamePerUserReach",tableName));
									return;	
								}else{
									out.write(successResponseStartGame(gameId,PortalHelper.parseNull(rs.value("can_lose")),Etn,"closed",tableName));
									return;
								}
							}
						}else{
							out.write(successResponseStartGame(gameId,PortalHelper.parseNull(rs.value("can_lose")),Etn,"maxGamePerUserReach",tableName));
							return;		
						}
					}else{
						out.write(errorResponse("invalid_"+identity.toLowerCase().replace(" ","_"),"critical",identity+" is invalid.",PortalHelper.parseNull(rs.value("win_type")),PortalHelper.parseNull(rs.value("launch_date")),PortalHelper.parseNull(rs.value("end_date")),PortalHelper.parseNull(rs.value("attempts_per_user")),0));
						return;
					}
				}
				else
				{
					int count=0;
					Set rsCount = Etn.execute("select * from "+formsDb+"."+tableName+" where "+identityType+"="+escape.cote(identityTypeValue)+
					" and _etn_game_status = 'end'");
					if(rsCount!=null && rsCount.rs.Rows>0 && rsCount.next()){
						count=rsCount.rs.Rows;
					}
					out.write(errorResponse("game_date_error","critical","Game is either expired or not launched","","","","",count));
					return;
				}
			}
		}else{
			out.write(errorResponse("invalid_game_id","critical","Game id is invalid","","","","",0));
			return;		
		}

	}catch(Exception e){
		out.write(errorResponse("exception","critical","An axception occured while processing.","","","","",0));
		return;
	}
%>