<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>

<%@ include file="apicall.jsp"%>

<%
	String selectedsiteid = getSelectedSiteId(session);

	String brand = parseNull(request.getParameter("brand"));
	String model = parseNull(request.getParameter("model"));
	String dtype = parseNull(request.getParameter("dtype"));

	Set rs = Etn.execute("select id, migrated_id from products where coalesce(migrated_id,'') <> '' ");
	List<String> allMigratedDevices = new ArrayList<String>();
	while(rs.next())
	{
		allMigratedDevices.add(parseNull(rs.value("migrated_id")));
	}

	rs = Etn.execute("select p.id, p.migrated_id from products p, catalogs c where c.id = p.catalog_id and c.site_id = "+escape.cote(selectedsiteid)+" and coalesce(p.migrated_id,'') <> '' ");
	List<String> siteMigratedDevices = new ArrayList<String>();
	while(rs.next())
	{
		siteMigratedDevices.add(parseNull(rs.value("migrated_id")));
	} 

	String json = fetchDevices(brand, model, dtype, allMigratedDevices, siteMigratedDevices);
	out.write(json);
%>

