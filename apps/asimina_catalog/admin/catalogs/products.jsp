<%
    String cid = com.etn.asimina.util.UIHelper.parseNull(request.getParameter("cid"));
    String folderUuid = com.etn.asimina.util.UIHelper.parseNull(request.getParameter("folderId"));

	response.sendRedirect("catalogs.jsp?cid="+cid+"&folderId="+folderUuid);
%>