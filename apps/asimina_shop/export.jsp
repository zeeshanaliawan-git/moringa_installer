<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" /><%@page import="com.etn.lang.ResultSet.Set"%><%@page import="java.io.*"%><%!
String parseNull(Object o) {
  if( o == null )
    return("");
  String s = o.toString();
  if("null".equals(s.trim().toLowerCase()))
    return("");
  else
    return(s.trim());
}
%><%
	String exportJsp = "defaultexport.jsp";
	if(parseNull(com.etn.beans.app.GlobalParm.getParm("IBO_EXPORT_JSP")).length() > 0) exportJsp = parseNull(com.etn.beans.app.GlobalParm.getParm("IBO_EXPORT_JSP"));
	//String qry = parseNull(request.getParameter("qry"));
	request.getRequestDispatcher(exportJsp).forward(request,response);
%>