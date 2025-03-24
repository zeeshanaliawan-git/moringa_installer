<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">

<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.asimina.util.UIHelper"%>
<%@ include file="common.jsp" %>
<%
	if(session.getAttribute("IS_LOGIN") == null)
	{
		session.setAttribute("GOTO_URL", request.getContextPath() + "/searchProcessGraphical.jsp");
		response.sendRedirect(request.getContextPath() + "/login.jsp?message=Login is required");
	}
%>
<%
	String isSearched = parseNull(request.getParameter("isSearched"));
	if(isSearched.equals("")) isSearched = "0";

	String mysqlDateFormat = "%Y%m%e"; //%Y gives four digits year, %m gives numeric month, %e gives numeric day start from 0-31	

	String startDate    = parseNull(request.getParameter("startDate"));
	String endDate      = parseNull(request.getParameter("endDate"));
	String orderNo      = parseNull(request.getParameter("orderNo"));

	String process 	    = parseNull(request.getParameter("process"));
	if(process.equals("")) process = "#";//means all

	String phase        = parseNull(request.getParameter("phase"));
	if(phase.equals("")) phase = "#"; //means all

	String status	    = parseNull(request.getParameter("status"));	
	if(status.equals("")) status = "#";//means all

	String[] selectedErrorCodes = request.getParameterValues("errCode");

	String[] selectedProducts = request.getParameterValues("product");
	Set rs = null;
	
	if(isSearched.equals("1"))
	{
		String innerQryWhereClause = "";
		String outerQryWhereClause = "";

		String innerQry = " select distinct client_key " +
				  "   from post_work pw";

		if(!startDate.equals(""))
		{
			innerQryWhereClause = innerQryWhereClause + " date_format(pw.start,'"+mysqlDateFormat+"') = " + escape.cote(startDate) + " and";
		}

		if(!endDate.equals(""))
		{
			innerQryWhereClause = innerQryWhereClause + " date_format(pw.end,'"+mysqlDateFormat+"') = " + escape.cote(endDate) + " and";
		}
		
		if(!orderNo.equals(""))
		{		
			outerQryWhereClause = outerQryWhereClause + " cl.orderId = " + escape.cote(orderNo) + " and";
		}

		if(selectedErrorCodes != null && selectedErrorCodes.length > 0)
		{
			String orClause = "";
			for(String currErrCode : selectedErrorCodes)
			{
				if(currErrCode != null && !currErrCode.equals(""))
				{
					if(orClause.equals("")) orClause = " pw.errCode = " + escape.cote(currErrCode);
					
					else orClause = orClause + " or pw.errCode = " + escape.cote(currErrCode);
				}
			}
			
			if(!orClause.equals(""))
			{
				innerQryWhereClause = innerQryWhereClause + " (" + orClause + ") and";
			}
		}

		if(!process.equals("#"))
		{
			innerQryWhereClause = innerQryWhereClause + " UPPER(pw.proces) = UPPER(" + escape.cote(process) + ") and";
		}

		if(!phase.equals("#"))
		{
			innerQryWhereClause = innerQryWhereClause + " UPPER(pw.phase) = UPPER(" + escape.cote(phase) + ") and";
		}

		if(selectedProducts != null && selectedProducts.length > 0)
		{
			String orClause = "";
			for(String currProduct : selectedProducts)
			{
				if(currProduct != null && !currProduct.equals(""))
				{
					if(orClause.equals("")) orClause = " UPPER(cl.terminal) like " + escape.cote("%"+currProduct+"%") + " ";
					
					else orClause = orClause + " or UPPER(cl.terminal) like " + escape.cote("%"+currProduct+"%")+ " ";
				}
			}
			
			if(!orClause.equals(""))
			{
				outerQryWhereClause = outerQryWhereClause + " (" + orClause + ") and";
			}
		}

		if(!status.equals("#"))
		{
			innerQryWhereClause = innerQryWhereClause + " pw.status = " + escape.cote(status) + " and"; 
		}

	/*	if(!salesChannel.equals(""))
		{
			outerQryWhereClause = outerQryWhereClause + " UPPER(cl.canalDeVente) like UPPER( " + escape.cote("%"+salesChannel+"%") + " ) and"; 
		}
	*/
		
		if(!innerQryWhereClause.equals(""))
		{
			innerQryWhereClause = innerQryWhereClause.substring(0, innerQryWhereClause.length() - 3);//removing last and
			innerQry = innerQry + " where " + innerQryWhereClause;
		}

		String query = " select cl.customerId " +
				   "   from customer cl " +
				   "  where cl.customerId in ( " + innerQry + ") ";

		if(!outerQryWhereClause.equals(""))
		{
			outerQryWhereClause = outerQryWhereClause.substring(0, outerQryWhereClause.length() - 3);//removing last and
			query = query + " and " + outerQryWhereClause;
		}

		rs = Etn.execute(query);	
	}
	

	Map<String, String> statuses = new LinkedHashMap<String, String>();
	statuses.put("#","ALL");
	statuses.put("0","Pending");
	statuses.put("1","In-process");
	statuses.put("2","Completed");
	statuses.put("3","Syn-Ack");
	statuses.put("4","Abandoned");

	Map<String, String> errCodes = new LinkedHashMap<String, String>();
	String queryErrs = "select id as errCode from errcode order by id";
	Set rsErrs = Etn.execute(queryErrs);
	while(rsErrs.next())
	{	
		errCodes.put(rsErrs.value("errCode"),rsErrs.value("errCode"));
	}	

	Map<String, String> processes = new LinkedHashMap<String, String>();
	processes.put("#","-- Select Process --");
	String processesQry = "select distinct start_proc as process " +
			      "  from rules " +
 			      " union " +
			      "select distinct next_proc as process " +
			      "  from rules " +
			      " order by process ";
	Set rsProcesses = Etn.execute(processesQry);
	while(rsProcesses.next())
	{
		processes.put(rsProcesses.value("process"),rsProcesses.value("process"));
	}

	Map<String, String> phases = new LinkedHashMap<String, String>();
	phases.put("#","ALL");
	String phasesQry = "select distinct start_phase as phase " +
			      "  from rules " +
 			      " union " +
			      "select distinct next_phase as phase " +
			      "  from rules " +
			      " order by phase ";
	Set rsPhases = Etn.execute(phasesQry);
	while(rsPhases.next())
	{
		phases.put(rsPhases.value("phase"),rsPhases.value("phase"));
	}

	Map<String, String> products = new LinkedHashMap<String, String>();
	String productsQry = "select distinct terminalIDEUP from mapterminal order by terminalIDEUP";
	Set rsProducts = Etn.execute(productsQry);
	while(rsProducts.next())
	{
		products.put(rsProducts.value("terminalIDEUP"), rsProducts.value("terminalIDEUP"));
	}
	// end of loading search fields

%>

<html>
<head>
<title>Gizmo template</title>

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


<script type="text/javascript">

function onSearch() 
{	
	if(document.forms[0].process.value == '#' && document.forms[0].orderNo.value == '')
	{
		alert('Either provide Order Id or select Process');
		return;
	}

	document.forms[0].action = 'searchProcessGraphical.jsp';
	document.forms[0].submit();

	/*var data = getFormParameters("filter");
	jQuery.ajax({
		url: "searchGraphical.jsp",
		data: data,
		type: 'post',
		success : function(resp)
		{
			alert(resp);
			document.getElementById("searchResults").innerHTML = resp;
		}
	});*/
}


function getFormParameters(formId) {
	queryString="";
	var frm = document.getElementById(formId);
	var numberElements = frm.elements.length;
	for(var i = 0; i < numberElements; i++) 
	{
		if(frm.elements[i].length === undefined)
		{
			queryString += frm.elements[i].name+"="+
			encodeURIComponent(frm.elements[i].value)+"&";
		}
		else
		{
			for(j=0; j<frm.elements[i].length; j++)
			{
				if(frm.elements[i][j].selected)
				{
					queryString += frm.elements[i].name+"="+
					encodeURIComponent(frm.elements[i][j].value)+"&";
				}
			}
		}
	}//for
	if(queryString.length > 0)
		queryString = queryString.substring(0,queryString.length-1);
	return queryString; 
}	


</script>

</head>
<body class="generic">

<div class="container">
<%@include file="/WEB-INF/include/menu_admin.jsp"%>
<center>
<table cellpadding="0" cellspacing="0" border="0" style="margin: 0;" >
<tr>
<td class="ficheh1" width="350">Search Orders</td>
<td width="400"></td>
<td align="left">
</td>
</tr>
</table>

<form id="filter" name="filter" method="POST">
<table id="searchGrid">
<tr>
	<th width="17%">Start Date <span style="font-size:11px">(yyyymmdd)</span></th>
	<th width="2%">:</th> 
	<td width="18%"><input type="text" name="startDate" id="startDate" size="10" maxlength="8" onkeypress="return numbersonly(event)"/></td>
	<th width="16%">End Date <span style="font-size:11px">(yyyymmdd)</span></th>
	<th width="2%">:</th> 
	<td width="18%"><input type="text" name="endDate" id="endDate" size="10" maxlength="8" onkeypress="return numbersonly(event)"/></td>
	<th width="8%">Ordre Id</th>
	<th width="2%">:</th> 
	<td width="17%"><input type="text" name="orderNo" id="orderNo" size="15" maxlength="13"/></td>
</tr>

<tr>
	<th>Process</th>
	<th>:</th> 
	<td ><%=addSelectControl("process","process",processes, false,0)%></td>
	<th>Phase(s)</th>
	<th>:</th> 
	<td ><%=addSelectControl("phase","phase",phases,false,0)%></td>
	<th>Status</th>
	<th>:</th> 
	<td ><%=addSelectControl("status","status", statuses, false, 0)%></td>
</tr>

<tr>
	<th>Error Code</th>
	<th>:</th> 
	<td ><%=addSelectControl("errCode","errCode",errCodes,true,8)%></td>
	<th>Product</th>
	<th>:</th> 
	<td colspan="4"><%=addSelectControl("product","product",products,true,8)%></td>
	<!-- <th>Le canal de vente</th>
	<th>:</th> 
	<td ><input type="text" name="salesChannel" id="salesChannel" size="10" maxlength="8"/></td> -->
</tr>
<tr class="buttonBar">
	<td colspan="9"><input type="button" onclick="onSearch();" value="Search"/></td>
</tr>
</table>

<input type="hidden" name="isSearched" value="1"/>

</form>

<div id="divGraph" style="position:absolute;left:0px;top:350px;width:3000px;height:3000px">
</div>

<div id="modalWindow" title=""></div>
</center>


</div>


<%
if(isSearched.equals("1")) { 
	if(rs.rs.Rows == 0) {
%>
	No records found
<%
	}
	else if (rs.rs.Rows == 1) {
		rs.next();
%>
<jsp:include page="orderFlow.jsp" >  
	<jsp:param name="customerId" value='<%=rs.value("customerId")%>' />  
	<jsp:param name="fromDialog" value="false" />  
</jsp:include> 
<%		
	}
	else {
		String ordersList = "";
		while(rs.next()){
			ordersList += rs.value("customerId") + ",";
		}
		ordersList = ordersList.substring(0, ordersList.length() - 1);
%>
<jsp:include page="loadGraphicalProcess.jsp" >  
	<jsp:param name="process" value="<%=UIHelper.escapeCoteValue(process)%>" />  
	<jsp:param name="screenMode" value="VIEW" />  
	<jsp:param name="customerIdsList" value="<%=ordersList%>" />  
	<jsp:param name="showLabels" value="true" />  
</jsp:include> 
<%
	}
%>
<% } %>

</body>
<script type="text/javascript">
	document.forms[0].startDate.value = '<%=UIHelper.escapeCoteValue(startDate)%>';
	document.forms[0].endDate.value = '<%=UIHelper.escapeCoteValue(endDate)%>';
	document.forms[0].orderNo.value = '<%=UIHelper.escapeCoteValue(orderNo)%>';
	document.forms[0].process.value = '<%=UIHelper.escapeCoteValue(process)%>';
	document.forms[0].phase.value = '<%=UIHelper.escapeCoteValue(phase)%>';
	document.forms[0].status.value = '<%=UIHelper.escapeCoteValue(status)%>';

	<%
	if(selectedErrorCodes != null && selectedErrorCodes.length > 0)
	{		
		for(String currErrCode : selectedErrorCodes)
		{
	%>			
			for(var i=0; i<document.forms[0].errCode.length;i++)
			{
				if(document.forms[0].errCode[i].value == '<%=UIHelper.escapeCoteValue(currErrCode)%>') 
				{
					document.forms[0].errCode[i].selected = true;
					break;
				}
			}
	<%
		}
	}
	%>

	<%
	if(selectedProducts != null && selectedProducts.length > 0)
	{		
		for(String currProduct : selectedProducts)
		{
	%>			
			for(var i=0; i<document.forms[0].product.length;i++)
			{
				if(document.forms[0].product[i].value == '<%=UIHelper.escapeCoteValue(currProduct)%>') 
				{
					document.forms[0].product[i].selected = true;
					break;
				}
			}
	<%
		}
	}
	%>

</script>
</html>
