<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.ArrayList"%>

<%@ include file="common.jsp"%>


<%
	String proddb = com.etn.beans.app.GlobalParm.getParm("PROD_DB");
	String mid = parseNull(request.getParameter("menuid"));

	Set rs = Etn.execute("select * from "+proddb+".crawler_errors where menu_id = " + escape.cote(mid) + " order by created_on ");
	String h = "<table cellpadding='2' cellspacing='0' border='0' width='95%' class='table table-hover table-vam m-t-20 no-footer'>";
	while(rs.next())
	{
		h += "<tr><td>"+escapeCoteValue(rs.value("err"))+"</td></tr>";
	}
	h += "</table>";
	out.write(h);
%>

