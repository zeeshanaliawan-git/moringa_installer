<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.util.ItsDate"%>
<%@ page import="java.util.*"%>
<%@include file="../common2.jsp"%>

<%
	String tablename = parseNull(request.getParameter("___noe_tbl"));
	String primarykey = parseNull(request.getParameter("___noe_prkey"));
	String[] selectedFilters = request.getParameterValues("selectedFilters[]");
	String formid = request.getParameter("___noe_formid");

	Set rsfields = Etn.execute("select * from process_form_fields where form_id = " + escape.cote(formid));
	Map<String, String> fields = new HashMap<String, String>();
	while(rsfields.next())
	{
		fields.put(rsfields.value("db_column_name"), rsfields.value("type"));
	}

	String resp = "success";
	String msg = "success";

	Enumeration<String> params = request.getParameterNames();

	String qry = "update " + tablename + " set ";

	int i=0;
	while (params.hasMoreElements()) 
	{
		String param = params.nextElement();
		if(param.startsWith("___noe_")) continue;
		if(i > 0) qry += ", ";

		String _typ = fields.get(param);
		if("textdate".equalsIgnoreCase(_typ))//its date
		{
			if(parseNull(request.getParameter(param)).length() > 0)
			{
				String z1 = ItsDate.stamp(ItsDate.getDate(parseNull(request.getParameter(param))));
				qry += param + " = " + escape.cote(z1.substring(0,8));
			}
			else qry += param + " = NULL ";
		}
		else if("textdatetime".equalsIgnoreCase(_typ))//its date
		{
			if(parseNull(request.getParameter(param)).length() > 0)
			{

				String z1 = parseNull(request.getParameter(param));
				if(z1.length() <= 16) z1 += ":00";

				z1 = ItsDate.stamp(ItsDate.getDate(z1));
				qry += param + " = " + escape.cote(z1);
			}
			else qry += param + " = NULL ";
		}
		else
		{
			qry += param + " = " + escape.cote(parseNull(request.getParameter(param)));
		}
		i++;
	}
	qry += " where " + primarykey + " = " + escape.cote(request.getParameter(primarykey));
//System.out.println(qry);
	if(i > 0)
	{
		int r = Etn.executeCmd(qry);
		if(r == 0) 
		{
			resp = "error";
			msg = "Some error occurred while updating the record";
		}		
	}
	out.write("{\"resp\":\""+resp+"\",\"msg\":\""+msg+"\"}");

%>
