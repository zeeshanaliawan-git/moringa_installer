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

<%@ include file="../../common2.jsp" %>


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
        int record_size = parseNullInt(request.getParameter("length"));
        int start = parseNullInt(request.getParameter("start"));
        
        String GLOBAL_SEARCH_TERM = request.getParameter("search[value]");
        int totalCount = 0;

        String siteId = parseNull(request.getParameter("site_id"));
        String formPublishStatus = "";
        String rowColor= "";

        String sql = "SELECT uf.*, "
        +" l1.name as updated_by, "
        +" COALESCE(pf.to_publish_ts,'') as last_publish, l2.name as last_publish_by, "
        +" CASE WHEN uf.to_publish = 1 "
        +"      THEN Concat( 'Publish on', ' ', uf.to_publish_ts , ' by ', l3.name)  "
        +" WHEN uf.to_unpublish = 1 "
        +"      THEN Concat( 'Un-publish on', ' ', uf.to_unpublish_ts, ' by ', l4.name ) "
        +" ELSE '' END as next_publish, "
        +" case when coalesce(pf.id,'') = '' then 0 else 1 end as in_prod, "
        +" case when coalesce(pf.id, '') = '' then 'unpublished' when pf.version = uf.version then 'published' else 'needs_publish' end as publish_status "
        +" FROM games_unpublished uf "
        +" LEFT join games pf on pf.id = uf.id "
        +" LEFT JOIN login l1 on l1.pid = uf.updated_by "
        +" LEFT JOIN login l2 on l2.pid = pf.to_publish_by "
        +" LEFT JOIN login l3 on l3.pid = uf.to_publish_by "
        +" LEFT JOIN login l4 on l4.pid = uf.to_unpublish_by "
        +" WHERE uf.is_deleted != '1' AND uf.site_id = " + escape.cote(siteId);
        
        if (GLOBAL_SEARCH_TERM.length()>1) 
        sql += " AND (uf.name like " + escape.cote("%"+GLOBAL_SEARCH_TERM+"%")+") ";
        if (record_size > 0) {
            sql += " limit "+start +", "+record_size;
        }
        Set rs = Etn.executeWithCount(sql);


        totalCount = Etn.UpdateCount;

        Set formFilterRs = Etn.execute("SELECT form_id FROM "+GlobalParm.getParm("CATALOG_DB")+".person_forms pf inner join profilperson pp on pp.person_id = pf.person_id inner join profil p on p.profil_id = pp.profil_id where p.assign_site='1' and pf.person_id="+escape.cote(""+Etn.getId()));
        List<String> formIds = new ArrayList<String>();

        while(formFilterRs.next())
        {
            formIds.add(parseNull(formFilterRs.value("form_id")));
        }

        int count = 0;

        while (rs.next()) {

            JSONObject ja = new JSONObject();
            if(formIds.size() > 0 && !formIds.contains(rs.value("form_id"))){ 
                count++;
                continue;
            }
            
            for(String column: rs.ColName){

                ja.put(column.toLowerCase(), parseNull(rs.value(column)));        
            }

            ja.put("publish_status", rs.value("publish_status"));
            ja.put("in_prod", rs.value("in_prod"));

            String toolTipText = "";

            if(rs.value("updated_on").length() > 0 )
            {
                toolTipText = "Last change: ";
                if(rs.value("updated_by").length() >0){
                    toolTipText += " by "+ rs.value("updated_by");
                }
            }
            if(rs.value("last_publish").length() >0){
                toolTipText +="<br>Last publication: "+ rs.value("last_publish");
                if(rs.value("last_publish_by")
                .length() >0){
                    toolTipText += " by "+ rs.value("last_publish_by");
                }
            }
            if(rs.value("next_publish").length() >0){
                toolTipText += "<br>Next publication: "+ rs.value("next_publish");
            }
            
            String tooltipBtn = "&nbsp;<a href='javascript:void(0)' class='custom-tooltip' data-toggle='tooltip' title='' data-original-title="+ escape.cote(toolTipText) +"><svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='feather feather-info'><circle cx='12' cy='12' r='10'></circle><line x1='12' y1='16' x2='12' y2='12'></line><line x1='12' y1='8' x2='12' y2='8'></line></svg></a>";
			
			String delUnpublishAction = "delGame";
			if("1".equals(rs.value("in_prod"))) delUnpublishAction = "unpublishGame";
			
            
            String actionBtns = "<a id=" + escape.cote(rs.value("id")) + " class='btn btn-primary btn-sm edit_game mr-1' role='button' aria-pressed='true' style='color:white;' title='Edit game' onclick=\"getGame(\'"+rs.value("id")+"\')\" ><svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='feather feather-settings'><circle cx='12' cy='12' r='3'></circle><path d='M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z'></path></svg></a><a id='"+rs.value("form_id")+"' class='btn btn-primary btn-sm mr-1' role='button' aria-pressed='true' href='#' data-toggle='modal' data-placement='top' title='View fields' onclick=\'javascript:window.location=&quot;editProcess.jsp?form_id="+rs.value("form_id")+"&isGame=1&quot;;\'><svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='feather feather-edit'><path d='M20 14.66V20a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h5.34'></path><polygon points='18 2 22 6 12 16 8 16 8 12 18 2'></polygon></svg></a><a id='"+rs.value("form_id")+"' class='btn btn-primary btn-sm mr-1' role='button' aria-pressed='true' href='#' data-toggle='modal' data-placement='top' title='Mail Configuration' onclick='javascript:window.location=&quot;editProcess.jsp?form_id="+rs.value("form_id")+"&openTempModal=1&quot;;'><svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='feather feather-mail'><path d='M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z'></path><polyline points='22,6 12,13 2,6'></polyline></svg></a><a class='btn btn-primary btn-sm mr-1' role='button' aria-pressed='true' href='#' onclick=\'javascript:window.location=&quot;search.jsp?___fid="+rs.value("form_id")+"&isGame=1&quot;;\' data-toggle='tooltip' data-placement='top' title='Form replies'> <svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='feather feather-file-text'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'></path><polyline points='14 2 14 8 20 8'></polyline><line x1='16' y1='13' x2='8' y2='13'></line><line x1='16' y1='17' x2='8' y2='17'></line><polyline points='10 9 9 9 8 9'></polyline></svg></a><button type='button' class='btn btn-danger btn-sm mr-1' onclick=\""+delUnpublishAction+"(\'"+rs.value("id")+"\')\"  ><svg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round' class='feather feather-x'><line x1='18' y1='6' x2='6' y2='18'></line><line x1='6' y1='6' x2='18' y2='18'></line></svg></button>";
            ja.put("last_changes", parseNull(rs.value("updated_on")) + tooltipBtn );
            ja.put("actions", actionBtns);
            array.put(ja);
        }    
        
        result.put("recordsTotal",totalCount-count);
        result.put("recordsFiltered",totalCount-count);
        result.put("data", array);
        result.put("status", 0);
    }

    out.write(result.toString());

%>