<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.asimina.util.ActivityLog"%>

<%@ include file="common.jsp"%>
<%@ include file="menugenerator.jsp"%>

<%
	String menuid = parseNull(request.getParameter("menuid"));

	String header = generateHeader(Etn, menuid, "0", request.getContextPath());
	String footer = generateFooter(Etn, menuid, "0", request.getContextPath());

	System.out.println("Déjà client?");
	Etn.executeCmd("insert into site_menu_htmls (menu_id, header_html, footer_html) values ("+escape.cote(menuid)+","+escape.cote(header)+","+escape.cote(footer)+") on duplicate key update tmp_header_html = '', tmp_footer_html = '', header_html = "+escape.cote(header)+", footer_html = "+escape.cote(footer));

	Etn.executeCmd("update cached_pages set cached = 0, last_time_url_active = is_url_active, is_url_active = 0 where menu_id = "  + escape.cote(menuid));

	String _script = com.etn.beans.app.GlobalParm.getParm("CRAWLER_SCRIPT");
	String[] cmd = new String[2];
	cmd[0] = _script;
	cmd[1] = menuid;

	Process proc = Runtime.getRuntime().exec(cmd);
//	int r = proc.waitFor();

    Set rs =  Etn.execute("select name from site_menus where id = "+escape.cote(menuid)+" and site_id = "+escape.cote(parseNull(session.getAttribute("SELECTED_SITE_ID"))));
    rs.next();
    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),menuid,"PUBLISH TEST","Menu",parseNull(rs.value(0)),parseNull(session.getAttribute("SELECTED_SITE_ID")));
%>
{"response":"success"}