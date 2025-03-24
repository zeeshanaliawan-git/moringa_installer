<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page import="java.io.*,com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%@ include file="../../common2.jsp" %>
<%
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");

	final String fileName = parseNull(request.getParameter("file_name"));
    final String fullPath = GlobalParm.getParm("LOGS_DIRECTORY");

    response.setContentType("text/x-log");
    response.setHeader("Content-Disposition", "attachment; filename=" + fileName.replaceAll("/", "").replaceAll("\\\\", ""));

    try{
        BufferedReader reader = new BufferedReader(new FileReader(fullPath + fileName.replaceAll("/", "").replaceAll("\\\\", "")));
        char[] buffer = new char[1000000];  // 1 MB 
        int bytesRead;
        while ((bytesRead = reader.read(buffer)) != -1) {
            out.write(buffer, 0, bytesRead);
        }
    } catch (IOException e) {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.write("An error occurred.");
        e.printStackTrace();
    }
%>