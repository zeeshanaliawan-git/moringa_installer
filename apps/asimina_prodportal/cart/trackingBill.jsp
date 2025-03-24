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
	String _jsp = "/cart/defaultTrackingBill.jsp";
	if(parseNull(com.etn.beans.app.GlobalParm.getParm("BILL_TRACKING_JSP")).length() > 0) _jsp = parseNull(com.etn.beans.app.GlobalParm.getParm("BILL_TRACKING_JSP"));

	request.getRequestDispatcher(_jsp).forward(request,response);
%>