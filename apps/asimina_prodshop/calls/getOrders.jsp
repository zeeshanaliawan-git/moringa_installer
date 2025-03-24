<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%
	request.setCharacterEncoding("utf-8");
	response.setCharacterEncoding("utf-8");
%>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap,org.json.*,java.util.Enumeration,javax.servlet.ServletException, com.etn.beans.app.GlobalParm,javax.servlet.http.*, org.apache.poi.ss.formula.functions.Column"%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate,com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.asimina.util.UIHelper"%>
<%@ page import="java.util.Date,java.text.SimpleDateFormat,java.text.ParseException,java.util.regex.Matcher,java.util.regex.Pattern,java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList,java.util.Arrays" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.io.DataInputStream"%>

<%@ include file="../common2.jsp" %>

<%!
    public int parseNullInt(String s)
	{
       	if (s == null) return 0;
	       if (s.equals("null")) return 0;
       	return Integer.parseInt(s);
	}
%>

<%

    String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));
    
    int start = parseNullInt(request.getParameter("start"));
    int record_size = parseNullInt(request.getParameter("length"));
    String GLOBAL_SEARCH_TERM = parseNull(request.getParameter("search[value]"));
    JSONObject result = new JSONObject();
    JSONArray array = new JSONArray();
    String startDate = parseNull(request.getParameter("startDate"));
    String endDate = parseNull(request.getParameter("endDate"));
    String orderBy = parseNull(request.getParameter("columns["+parseNullInt(request.getParameter("order[0][column]"))+"][data]"));
    String orderWay = parseNull(request.getParameter("order[0][dir]"));
	String user = (String)session.getAttribute("LOGIN");
	String userprofil = parseNull(session.getAttribute("PROFIL"));

    String sql = "SELECT distinct p.proces, p.phase, p.attempt, p.errMessage, p.insertion_date," +
		    "ph.displayName as phaseDisplayName, p.id as post_work_id, "+ 
            "c.*,rl.csr as csr, cp.First_name delivered_by_first_name, cp.last_name delivered_by_last_name "+
            "FROM phases ph, post_work p "+
            "left join dashboard_phases_config dpc ON dpc.process = p.proces AND dpc.ctype = 'delivery' "+
            "left join orders c on c.id = p.client_key "+
            "left join post_work cpw on cpw.proces = dpc.process and cpw.phase = dpc.phase and cpw.client_key = c.id "+
            "left join rlock rl on rl.id = c.id "+
            "left join post_work dpw on dpw.nextid = cpw.id "+
            "left join login pl on dpw.operador = pl.name left join person cp on cp.person_id = pl.pid "+
            "left join processes pr on pr.process_name = p.proces "+
            "WHERE pr.site_id="+escape.cote(siteId)+" and ph.phase = p.phase and p.client_key = c.id and ph.process = p.proces AND p.is_generic_form = 0 AND p.status in ('0','9')" ;
    
	if(!(parseNull(userprofil)).startsWith("SUPER_ADMIN") && !(parseNull(userprofil)).equals("ADMIN"))
	sql += " and ( ph.rulesVisibleTo = "+escape.cote(parseNull(userprofil))+" or ph.rulesVisibleTo like "+escape.cote(parseNull(userprofil)+"|%")+" or ph.rulesVisibleTo like "+escape.cote("%|"+parseNull(userprofil)+"|%")+" or ph.rulesVisibleTo like "+escape.cote("%|"+parseNull(userprofil))+" )";
	
    if(startDate.length()>0 && endDate.length()>0){
		sql += " AND (c.tm BETWEEN " + escape.cote(startDate + "000000") + " AND " + escape.cote(endDate + "235959") + ")";
    }
    if(GLOBAL_SEARCH_TERM.matches("-?\\d+(\\.\\d+)?")){
        sql += " AND (c.orderRef like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
			+ " or c.contactPhoneNumber1 like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.newPhoneNumber like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%") + ")";
    }else if (GLOBAL_SEARCH_TERM.length()>2) {
        sql += " AND (c.orderRef like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
			+ " or c.name like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.surnames like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.baline1 like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.baline2 like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.batowncity like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.bapostalCode like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.daline1 like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.daline2 like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.datowncity like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.dapostalCode like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.email like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.payment_txn_id like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.transaction_code like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.order_snapshot like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.tracking_number like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.courier_name like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.identityId like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.IdentityType like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or c.promo_code like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")
            + " or ph.displayName like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%") + ")";
    }
	
	//VERY IMPORTANT: as we are getting this from request parameter, sql injection can happen if we blindly
	//add orderWay to query. So we add this check to make sure orderWay can have value desc otherwise we make it empty string
	if(orderWay.toLowerCase().equals("desc")) orderWay = "desc";
	else orderWay = "";
	
	//VERY IMPORTANT: if order by column is coming from request, we must add ` around order by column so that no sql injection can happen
    if(orderBy.length()>0 && !orderBy.contains(".")){
        sql += " order by `"+orderBy+"` "+orderWay;
    }else{
        sql += " order by p.insertion_date desc";
    }
    session.setAttribute("IBO_EXPORT_QRY",sql);
        if (record_size > 0) {
            sql += " limit "+start +", "+record_size;
        }

    Set rs = Etn.executeWithCount(sql);
    int totalCount = Etn.UpdateCount; 

    while (rs.next()) {

        JSONObject ja = new JSONObject();
        for(String column: rs.ColName){
            if(column.toLowerCase().equals("customerid")){
				ja.put(column.toLowerCase(),parseNull(rs.value(column)));
				Set rsPw = Etn.execute("select * from post_work where client_key = "+escape.cote(parseNull(rs.value(column)))+ " order by id");
				JSONArray jPhases = new JSONArray();
				while(rsPw.next())
				{
					JSONObject jPhase = new JSONObject();
					jPhase.put("process", rsPw.value("proces"));
					jPhase.put("phase", rsPw.value("phase"));
					jPhase.put("status", rsPw.value("status"));
					jPhase.put("errCode", rsPw.value("errCode"));
					jPhase.put("errMessage", rsPw.value("errMessage"));
					jPhase.put("operador", rsPw.value("operador"));
					jPhases.put(jPhase);
				}
				ja.put("phases", jPhases);
			}
            else if(column.toLowerCase().equals("order_snapshot")){
                org.json.JSONObject orderSnapshot = new org.json.JSONObject(parseNull(rs.value("order_snapshot")));
                ja.put("order_snapshot",orderSnapshot);
            }else{
                ja.put(column.toLowerCase(),parseNull(rs.value(column)));
            }
        }
        array.put(ja); 
    }
    
    result.put("totalCount",totalCount);
    result.put("recordsFiltered",totalCount);
    result.put("recordsTotal",totalCount);
    result.put("data", array);
    out.write(result.toString());
%>
