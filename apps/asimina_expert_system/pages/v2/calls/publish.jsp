<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*, org.json.*, java.text.*" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ include file="/pages/common.jsp" %>

<%!

	String getInsertQry(Set rs)
	{
		String iq = " insert into query_settings_published ";
		String iqcols = "";
		String iqvals = "";
		for(int i=0;i< rs.Cols; i++)
		{
			if(i > 0)
			{
				iqcols += ", ";
				iqvals += ", ";
			}
			
			iqcols += "`" + rs.ColName[i].toLowerCase() + "`";
			iqvals += escape.cote(parseNull(rs.value(i)));
		}
		iq += " ( " + iqcols + " ) values ("+iqvals+") ";
		return iq;
	}
	
%>
<% 
    String uuids = parseNull(request.getParameter("uuid"));
    String uuid[] = null;

    if(uuids.length() > 0)
    	uuid = uuids.split(",");

    for(String id : uuid)
	{
		Etn.execute("delete from query_settings_published where qs_uuid = " + escape.cote(id));
		
		Set rs = Etn.execute("select * from query_settings where qs_uuid = " + escape.cote(id));
		if(rs.next())
		{
			String q = getInsertQry(rs);
			Etn.executeCmd(q);
		}
	}
%>