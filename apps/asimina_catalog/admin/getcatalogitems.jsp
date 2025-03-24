<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<%
	String isprod = parseNull(request.getParameter("isprod"));
	boolean bIsProd = "1".equals(isprod);
	String dbname = "";
	if(bIsProd) dbname = parseNull(GlobalParm.getParm("PROD_DB")) + ".";

	String id = parseNull(request.getParameter("id"));

	Set rs = Etn.execute("select id, (case when coalesce(lang_1_name,'') <> '' then lang_1_name when coalesce(lang_2_name,'') <> '' then lang_2_name when coalesce(lang_3_name,'') <> '' then lang_3_name when coalesce(lang_4_name,'') <> '' then lang_4_name when coalesce(lang_5_name,'') <> '' then lang_5_name else '' end) as name from "+dbname+"products where catalog_id = " + escape.cote(id) + " order by name ");

	if(rs != null && rs.rs.Rows > 0)
	{
		String products = "[";
		int i=0;
		while(rs.next())
		{
			if(i > 0) products += ",";
			products += "{\"id\":\""+rs.value("id")+"\",\"name\":\""+parseNull(rs.value("name")).replace("\"","\\\"")+"\"}";
			i++;
		}
		products += "]";
		out.write("{\"response\":\"success\", \"products\":"+products+"}");
	}
	else out.write("{\"response\":\"error\"}");
%>