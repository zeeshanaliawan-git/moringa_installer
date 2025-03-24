<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>

<%@ include file="common.jsp"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<% 
	String ty = parseNull(request.getParameter("type"));
	String id = parseNull(request.getParameter("id"));
	String on = parseNull(request.getParameter("on"));
	
	String _d = "";
	if(!"-1".equals(on))
	{
		if(on.length() != 16)
		{
			out.write("{\"response\":\"error\",\"msg\":\"Invalid date/time format. Format must be dd/mm/yyyy hh:mm\"}");
			return;
		}
		on = on + ":00";
		try {
			on =  ItsDate.stamp(ItsDate.getDate(on));
		} catch(Exception e) {
			out.write("{\"response\":\"error\",\"msg\":\"Invalid date/time format. Format must be dd/mm/yyyy hh:mm\"}");
			return;
		}
	}

	String process = getProcess(ty);

	String phase = "delete";
	String msg = "Sucess";
	String resp = "success";
	boolean dosemfree = movephase(Etn, id, process, phase, on);

	out.write("{\"response\":\""+resp+"\",\"msg\":\""+msg+"\"}");
	if(dosemfree) Etn.execute("select semfree('"+GlobalParm.getParm("SEMAPHORE")+"') ");
%>