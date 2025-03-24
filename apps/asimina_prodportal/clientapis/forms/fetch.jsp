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
	String sessionId = PortalHelper.parseNull(request.getParameter("sessionId"));

    try{
		String formId = PortalHelper.parseNull(request.getParameter("form_id"));
		String pno = PortalHelper.parseNull(request.getParameter("pno"));
		String pagesize = PortalHelper.parseNull(request.getParameter("psize"));
		if(pagesize.length() == 0 || pagesize.equals(null)) pagesize = "25";
		int pageno = 1;
		try	{
			pageno = PortalHelper.parseNullInt(pno);
		} catch (Exception e) { pageno = 1; }

		//user will start pageno from 1 but for us it should be 0
		pageno = pageno - 1;
		if(pageno < 0) pageno = 0;
		
		String limitApply=" Limit "+(pageno*Integer.parseInt(pagesize))+", "+pagesize;
		boolean loadAll = "1".equals(PortalHelper.parseNull(request.getParameter("loadAll")));
		String formsDb = GlobalParm.getParm("FORMS_DB");

        if(formId.length() > 0){
            JSONObject data = new JSONObject();
			JSONArray respArray = new JSONArray();
			Set rs= Etn.execute("select table_name from "+formsDb+".process_forms_unpublished where form_id="+escape.cote(formId));
			if(rs!=null && rs.next()){

				String tableName = formsDb+"."+PortalHelper.parseNull(rs.value("table_name"));
				System.out.println("tableName==========="+tableName);
				Set rs2;
				String query = "select * from "+tableName;
				if(loadAll){
					rs2= Etn.execute(query+" order by created_on desc");
				}else{
					rs2= Etn.execute(query+" order by created_on desc"+limitApply);
				}
				if(rs2!=null){
					while(rs2.next()){
						JSONObject respObj = new JSONObject();
						for(String colName: rs2.ColName){
							if(colName.equalsIgnoreCase(rs.value("table_name")+"_id")){
								String idColm = rs.value("table_name")+"_id";
								
								Set rs3 = Etn.execute("select coalesce(sum(case is_like when 1 then 1 else 0 end),0) as likes , coalesce(sum(case is_like when 0 then 1 else 0 end),0)"+
								" as dislikes from client_reactions where source_id="+escape.cote(formId)+
								" and field_id="+escape.cote(rs2.value(idColm))+" and source_type='form'");

								if(rs3!=null && rs3.next()){
									respObj.put("nb_likes",rs3.value("likes"));
									respObj.put("nb_dislikes",rs3.value("dislikes"));
								}

								String query2="select is_like from client_reactions where source_id="+escape.cote(formId)+
								" and field_id="+escape.cote(rs2.value(idColm))+" and source_type='form'";

								if(client!=null){
									query2+=" and client_id="+escape.cote(client.getProperty("client_uuid"));
								}else{
									query2+=" and session_id="+escape.cote(sessionId);
								}
								rs3=Etn.execute(query2);
								
								if(rs3!=null && rs3.next()){
									boolean isLike = false;
									if(rs3.value("is_like").equalsIgnoreCase("1")){
										isLike=true;
									}
									respObj.put("client_reaction",isLike);
								}
							}
							respObj.put(colName,rs2.value(colName));
						}
						respArray.put(respObj);
					}
				}
			}
			
			if(respArray.length()>0){
				obj.put("data",respArray);
				message="Data fetched successfully.";
			}else{
				message = "No category found.";
			}
			
            
        }else{
            message="Required fields are missing";
            status = 10;
        }
    }catch (Exception e){
        message="Error fetching data.";
        status=2;
    }

    obj.put("msg",message);
    obj.put("status", status);

    out.write(obj.toString());
%>