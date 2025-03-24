<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
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
    String folderId = parseNull(request.getParameter("folderId"));

	String on = "-1";
	String _goto = parseNull(request.getParameter("goto"));

	String process = getProcess(ty);

	String phase = "cancel";
	boolean dosemfree = movephase(Etn, id, process, phase, on);
	if(dosemfree) Etn.execute("select semfree('"+GlobalParm.getParm("SEMAPHORE")+"') ");

//	response.sendRedirect(_goto);
	response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);

    if(folderId.length()>0){
        _goto = _goto + "&folderId="+folderId;
    }
	response.setHeader("Location", _goto);

%>