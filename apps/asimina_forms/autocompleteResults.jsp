<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.List, java.util.ArrayList"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>

<%@ include file="common2.jsp" %>

<%
	String objvalue = parseNull(request.getParameter("__objvalue"));
	String fieldname = parseNull(request.getParameter("__fieldname"));

	String formid = parseNull(request.getParameter("__form_id"));
	String fieldid = parseNull(request.getParameter("__field_id"));

	Set rs = Etn.execute("select * from process_form_fields where form_id = "+escape.cote(formid)+" and field_id = " +  escape.cote(fieldid));
	rs.next();
	out.write("[");
	String autoqry = parseNull(rs.value("element_autocomplete_query"));
	if(autoqry.length() > 0)
	{

		if(autoqry.indexOf("@@" + fieldname + "@@") > -1 ) autoqry = autoqry.replace("@@" + fieldname + "@@", escape.cote(objvalue + "%"));
		//System.out.println(autoqry);
		rs = Etn.execute(autoqry);
		int i=0;
		while(rs.next())
		{
			if (i > 0) out.write(",");
			out.write("{\"label\":\""+rs.value(0)+"\"}");
			i++;
		}
	}
	out.write("]");


%>  