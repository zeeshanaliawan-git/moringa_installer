<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, com.etn.asimina.util.ActivityLog, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>

<%@ include file="../../common.jsp"%>
<%
	String folderUuid = parseNull(request.getParameter("fuuid"));
	String ftype = parseNull(request.getParameter("ftype"));
	
	String ids = parseNull(request.getParameter("ids"));
	String[] idsList = ids.split(",");
	
	if(idsList.length > 0)
	{
		String inclause = "(";
		for(int i=0;i<idsList.length;i++)
		{
			if(parseNull(idsList[i]).length() == 0) continue;
			if(i>0) inclause += ",";
			inclause += escape.cote(parseNull(idsList[i]));
		}
		inclause += ")";
		
		String q = "update products set version = version + 1, updated_on = now() ";
		if(ftype.equals("catalog"))
		{
			q += ", folder_id = null";
		}
		else
		{
			Set rs = Etn.execute("select * from products_folders where uuid = "+escape.cote(folderUuid));
			if(rs.next())
			{
				q += ", folder_id = "+escape.cote(rs.value("id"));
			}
		}
		q += " where id in "+inclause;
		int i = Etn.executeCmd(q);
	}
%>
{"status":0}