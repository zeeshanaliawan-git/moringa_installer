<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ include file="../common2.jsp" %>

	<SCRIPT src="../js/draw2dv1/wz_jsgraphics.js"></SCRIPT>
	<SCRIPT src="../js/draw2dv1/draw2d.js"></SCRIPT>
	
    <!-- undo/redo support (all times required too) -->
	<SCRIPT src="../js/draw2dv1/mootools.js"></SCRIPT>
	<SCRIPT src="../js/draw2dv1/moocanvas.js"></SCRIPT>
        <!--REGEXP_END_REMOVE-->

        <!-- example specific imports -->
	<SCRIPT src="../js/draw2dv1/GizmoConnection.js"></SCRIPT>
	<SCRIPT src="../js/draw2dv1/GizmoInputPort.js"></SCRIPT>
	<SCRIPT src="../js/draw2dv1/GizmoOutputPort.js"></SCRIPT>	
	<SCRIPT src="../js/draw2dv1/GizmoFigure.js"></SCRIPT>
	<SCRIPT src="../js/draw2dv1/GizmoWorkflow.js"></SCRIPT>
	<SCRIPT src="../js/draw2dv1/GizmoResizeHandle.js"></SCRIPT>
	<SCRIPT src="../js/draw2dv1/GizmoConnectionRouter.js"></SCRIPT>
	<SCRIPT src="../js/draw2dv1/GizmoConnectionDecorator.js"></SCRIPT>
	<SCRIPT src="../js/draw2dv1/GizmoConnectionSourceDecorator.js"></SCRIPT>

<%
	String clientKey = parseNull(request.getParameter("client_key"));	
	boolean fromDialog = Boolean.parseBoolean(parseNull(request.getParameter("fromDialog")));
	String tableName = parseNull(request.getParameter("table_name"));
	int index = 0;
	
	int topLeftX = 100;
	int topLeftY = 120;
	if(fromDialog) topLeftY = 20;
%>


<div class="container">

<center>
<div id="divFlowGraph" style="height: 100%;margin-left:auto;margin-right:auto;position: relative; text-align:left">
</div>

</center>
</div>



<script id="graphScript" type="text/javascript">	
	orderWorkflow  = new draw2d.Workflow("divFlowGraph");
	//g = new Graph(document.getElementById('divFlowGraph'),200,100);
	var currNode ;
	var prevNode ;	
	<% if(clientKey != null && !clientKey.equals("")) { 	

		String qry = " select date_format(pw.start,'%m/%d/%Y %H:%i:%S') as start_date, date_format(pw.end,'%m/%d/%Y %H:%i:%S') as end_date, pw.attempt, pw.id, pw.status, pw.errCode, pw.phase, pw.proces, ph.topLeftX, ph.displayName, ph.actors phase_actors, ph.priority phase_priority, ph.execute phase_execute, ph.visc, " +
					" ph.topLeftY from post_work pw, phases ph where pw.client_key = " + escape.cote(clientKey) +
					" and ph.process = pw.proces and ph.phase = pw.phase and pw.form_table_name = " + escape.cote(tableName) + " order by pw.id ";
					System.out.println(qry);
		Set rs = Etn.execute(qry);		
		String prevPhase = null;
		while(rs.next())
		{
			int errCode = Integer.parseInt(rs.value("errCode"));
			int statut = Integer.parseInt(rs.value("status"));
	%>
			currNode= new draw2d.GizmoFigure(150,80, '<%=rs.value("phase")%>', '<%=rs.value("phase_actors")%>', '<%=rs.value("phase_priority")%>', '<%=rs.value("phase_execute")%>', '<%=rs.value("visc")%>','<%=rs.value("displayName")%>','<%=rs.value("proces")%>','<%=rs.value("proces")%>');
			currNode.setTitle('<%=rs.value("displayName")%>');
			currNode.footer.style.backgroundColor="white";
			currNode.setAllowDoubleClick(false);
			currNode.setCanDrag(false);
	<%
			if(errCode >= 5000)
			{	%>  		
			currNode.setContent('<div style="background-color:#FF0000; width:100%; height: 100%"><div>Start:&nbsp;<%=rs.value("start_date")%></div><div>End:&nbsp;<%=rs.value("end_date")%></div><div>ErrCode:&nbsp;<%=rs.value("errCode")%></div></div>');
	<%		}
			else if(errCode >= 1001)
			{	%>
			currNode.setContent('<div style="background-color:#FFEE00; width:100%; height: 100%"><div>Start:&nbsp;<%=rs.value("start_date")%></div><div>End:&nbsp;<%=rs.value("end_date")%></div><div>ErrCode:&nbsp;<%=rs.value("errCode")%></div>');
	<%		}	
			else if(statut != 0 && statut != 1)
			{	%>
			currNode.setContent('<div style="background-color:#00aaFF; width:100%; height: 100%"><div>Start:&nbsp;<%=rs.value("start_date")%></div><div>End:&nbsp;<%=rs.value("end_date")%></div><div>ErrCode:&nbsp;<%=rs.value("errCode")%></div>');
	<% 
			}
			else
			{ 	%>
			currNode.setContent('<div style="background-color:white; width:100%; height: 100%"><div>Start:&nbsp;<%=rs.value("start_date")%></div><div>End:&nbsp;<%=rs.value("end_date")%></div><div>ErrCode:&nbsp;<%=rs.value("errCode")%></div>');
	<%		}
	%>
			orderWorkflow.addFigure(currNode, <%=topLeftX%>,<%=topLeftY%>);
	<%
			topLeftX += 250;			
			if((index +1) % 4 == 0) 
			{
				topLeftX = 100;
				topLeftY += 150;
			}
		if(index > 0) 
		{ %>
			c = new draw2d.GizmoConnection();
			c.setSource(prevNode.getPort("output"));
			c.setTarget(currNode.getPort("input"));
			orderWorkflow.addFigure(c);							
	<%	}	%>
	prevNode = currNode;	
	<% index ++;
		}//while %>						
	<% } %>
</script>

<% if(index == 0) { %>
<div style='margin-top: 20px; text-align:center; color:red; font-size:8pt'>
No phases found for the given order
</div>
<% } %>