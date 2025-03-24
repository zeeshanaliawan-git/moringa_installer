<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="common.jsp" %>


<% 
	String customerId = parseNull(request.getParameter("customerId"));
	
	boolean isError = false;
	String message = "";
	if(customerId.equals("")) 
	{
		isError =true;
		message = "No Customer Id provided";
	}
	
	if(!isError)
	{
		String qry = "select orderId, creationDate, orderStatus, customerId from customer where customerId = "+escape.cote(customerId)+" ";
		Set rs = Etn.execute(qry);
		if(rs.rs.Rows == 0 )
		{
			isError = true;
			message = "No order found for the given customer Id";
		}
		else
		{
			rs.next();
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link rel="stylesheet" type="text/css" href="css/general.css" />
<link rel="stylesheet" type="text/css" href="css/jquery/jquery-ui-1.8.4.custom.css" />

<SCRIPT LANGUAGE="JavaScript" SRC="js/common.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="js/sorttable.js"></script>

<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery-1.4.2.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery-ui-1.8.4.custom.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery.bgiframe-2.1.1.js"></script>


	<SCRIPT src="js/draw2d/wz_jsgraphics.js"></SCRIPT>
	<SCRIPT src="js/draw2d/draw2d.js"></SCRIPT>
	
    <!-- undo/redo support (all times required too) -->
	<SCRIPT src="js/draw2d/mootools.js"></SCRIPT>
	<SCRIPT src="js/draw2d/moocanvas.js"></SCRIPT>
        <!--REGEXP_END_REMOVE-->

        <!-- example specific imports -->
	<SCRIPT src="js/draw2d/GizmoConnection.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoInputPort.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoOutputPort.js"></SCRIPT>	
	<SCRIPT src="js/draw2d/GizmoFigure.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoWorkflow.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoResizeHandle.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionRouter.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionDecorator.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionSourceDecorator.js"></SCRIPT>

	<link rel="stylesheet" type="text/css" href="css/colorpicker.css" />
	<script type="text/javascript" src="js/colorpicker.js"></script>

</head>
<body class="generic">

<div class="container">
<%@include file="/WEB-INF/include/menu_admin.jsp"%>

<center>
<div style="margin-top:15px">
<table style="text-align:left; font-weight:bold" cellspacing=0 cellpadding=0 border=0 width='60%'>
<tr>
	<td width='20%'>Order ID</td>
	<td width='2%'>:</td>
	<td width='30%'><%=rs.value("orderId")%></td>
	<td width='20%'>Customer ID</td>
	<td width='2%'>:</td>
	<td><%=rs.value("customerId")%></td>
</tr>
<tr>
	<td>Order Status</td>
	<td>:</td>
	<td><%=rs.value("orderStatus")%></td>
	<td>Order Date</td>
	<td>:</td>
	<td><%=rs.value("creationDate")%></td>
</tr>
</table>
</div>
</center>
</div>
<jsp:include page="orderFlow.jsp" >  
	<jsp:param name="customerId" value="<%=escapeHtml(customerId)%>" />  
	<jsp:param name="fromDialog" value="false" />  
</jsp:include> 

</body>
<% }
} %>

<% if(isError) { %>
<%=message%>
<% } %>
</html>
