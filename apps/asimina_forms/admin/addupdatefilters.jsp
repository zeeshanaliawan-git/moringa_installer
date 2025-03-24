<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.*"%>
<%@include file="../common2.jsp"%>

<%
	String action = parseNull(request.getParameter("action"));
	String[] selectedFilters = request.getParameterValues("selectedFilters[]");

	if("deletesearchfilter".equals(action))
	{
		String id = parseNull(request.getParameter("id"));
		Etn.executeCmd("delete from form_search_fields where id = " + escape.cote(id));
	}
	else if("deleteresultfilter".equals(action))
	{
		String id = parseNull(request.getParameter("id"));
		Etn.executeCmd("delete from form_result_fields where id = " + escape.cote(id));
	}
	else if("updaterangeflag".equals(action))
	{
		String id = parseNull(request.getParameter("id"));
		String flag = parseNull(request.getParameter("flag"));

		Etn.executeCmd("update form_search_fields set show_range = "+escape.cote(flag)+" where id = " + escape.cote(id));
	}
	else if(selectedFilters != null && selectedFilters.length > 0)
	{
		String formid = parseNull(request.getParameter("fid"));

		if("addsearchfilter".equals(action))
		{

			Set rs = Etn.execute("SELECT coalesce(display_order,0) as display_order FROM form_search_fields WHERE form_id = " + escape.cote(formid) + " order by coalesce(display_order,0) desc limit 1");

			int maxOrder = 0;
			if(rs.next()) maxOrder = Integer.parseInt(rs.value("display_order"));
			
			for(String sf : selectedFilters)
			{
				maxOrder++;
				Etn.executeCmd("insert into form_search_fields(form_id, field_id, display_order) values ("+escape.cote(formid)+","+escape.cote(sf)+","+escape.cote(""+maxOrder)+") " );
			}
		}

		else if("addresultfilter".equals(action))
		{

			Set rs = Etn.execute("SELECT coalesce(display_order,0) as display_order FROM form_result_fields WHERE form_id = " + escape.cote(formid) + " order by coalesce(display_order,0) desc limit 1");
			int maxOrder = 0;
			if(rs.next()) maxOrder = Integer.parseInt(rs.value("display_order"));
			
			for(String sf : selectedFilters)
			{
				maxOrder++;
				Etn.executeCmd("insert into form_result_fields(form_id, field_id, display_order) values ("+escape.cote(formid)+","+escape.cote(sf)+","+escape.cote(""+maxOrder)+") " );
			}
		}

	}

%>
