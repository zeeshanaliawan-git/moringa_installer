 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.lang.Math"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ include file="common.jsp" %>
<%
	String __prof = (String)session.getAttribute("PROFIL");
	if(!__prof.equalsIgnoreCase("admin") && !__prof.equalsIgnoreCase("SUPER_ADMIN")) response.sendRedirect(request.getContextPath()+"/unauthorized.jsp");	
%>
<%
	Map<String, String> processes = new LinkedHashMap<String, String>();
	String processesQry = "select distinct process from phases union select distinct start_proc as process from external_phases order by process ";
	Set rsProcesses = Etn.execute(processesQry);
	while(rsProcesses.next())
	{
		processes.put(rsProcesses.value("process"),rsProcesses.value("process"));
	}
	
	String proc = parseNull(request.getParameter("process"));	
	
	Set allProfs = Etn.execute("select * from profil where profil != 'SUPER_ADMIN' order by description");
	Set allPhases = Etn.execute("select * from phases where process = "+escape.cote(proc)+" order by displayName ");
%>

<!DOCTYPE HTML>
<html>
<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
	<script src="<%=request.getContextPath()%>/js/jquery-ui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>

<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery-1.4.4.min.js"></script>
<script type="text/javascript">
window.oldjquery = $.noConflict(true);
</script> 
<link rel="stylesheet" type="text/css" href="css/jquery/jquery-ui-1.8.9.custom.css" />
	<SCRIPT LANGUAGE="JavaScript" SRC="js/common.js"></script>
	<SCRIPT LANGUAGE="JavaScript" SRC="<%=request.getContextPath()%>/js/Sortable.min.js"></script>

	<SCRIPT src="js/draw2d/wz_jsgraphics.js"></SCRIPT>
	<SCRIPT src="js/draw2d/draw2d.js"></SCRIPT>
	
    <!-- undo/redo support (all times required too) -->
	<SCRIPT src="js/draw2d/mootools.js"></SCRIPT>
	<SCRIPT src="js/draw2d/moocanvas.js"></SCRIPT>
        <!--REGEXP_END_REMOVE-->

        <!-- example specific imports -->
	<SCRIPT src="js/draw2d/GizmoConnection.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionGroup.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoInputPort.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoOutputPort.js"></SCRIPT>	
	<SCRIPT src="js/draw2d/GizmoFigure.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoFigureGroup.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoProfileFigure.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoWorkflow.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoResizeHandle.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionRouter.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionDecorator.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionSourceDecorator.js"></SCRIPT>
	<SCRIPT src="js/draw2d/GizmoConnectionAnchor.js"></SCRIPT>
		<script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
    <script type="text/javascript">
        $(function() {
            feather.replace();
        });
    </script>
	<link rel="stylesheet" type="text/css" href="css/colorpicker.css" />
	<script type="text/javascript" src="js/colorpicker.js"></script>
<style>
.ui-widget-header{
	background:#5bc0de;
	border:none;
}
div.toolbarButton {
	padding:5px;
	background-color:#5bc0de;
	color:white;
	/* font-size:14px; */
	}
	.ui-dialog { z-index: 99999 !important ;}
	.ui-icon-closethick{
		top: -2px;
		left: -2px;
	}
	#actors{
		width: 325px;
	}
</style>
<title>Processes</title>
</head>
<body class="c-app container" style="background-color:#efefef">
<div class="c-wrapper c-fixed-components">
    <div class="c-body ">
        <main class="c-main"  style="padding:0px 30px">
	
	<!-- toolbar starts -->
		<div id="toolbar" style="position: absolute;display:none; width:120px;right:520px;z-index: 99999;" class="pull-right">
		<div><a href="javascript:showHideToolbar('toolbar','innerToolbar', null,false)" style="text-decoration:none; font-weight:bold;padding:15px;">&nbsp;TOOLBAR&nbsp;</a></div>
	<div id="innerToolbar">
		<div class="toolbarButton" style="cursor:pointer" onclick="javascript:showHideToolbar('innerToolbar','profToolbar','phaseToolbar',true)">Profiles</div>
		<div class="toolbarButton" style="cursor:pointer" onclick="javascript:showHideToolbar('innerToolbar','phaseToolbar','profToolbar',true)">Phases</div>
	</div>
	</div>
		<div style="position:absolute; z-index:999999; display:none; text-align:left; right: 355px;width:165px;" id="profToolbar" class="pull-right">
		<% while(allProfs.next()) { %>
			<div class="toolbarButton"><input type="checkbox" id="checkbox<%=allProfs.value("profil")%>" class="profChkbox" checked value="<%=allProfs.value("profil")%>" /><%=allProfs.value("description")%>&nbsp;&nbsp;&nbsp;</div>
		<% } %>
	</div>
		<div style="position: absolute; z-index:999999; display:none; text-align:left;right:355px;width:165px;" id="phaseToolbar" class="pull-right">
		<% while(allPhases.next()) { %>
				<div class="toolbarButton"><input type="checkbox" id="checkbox<%=allPhases.value("phase")%>" class="phaseChkbox" checked value="<%=allPhases.value("phase")%>" /><%=allPhases.value("displayName")%>&nbsp;&nbsp;&nbsp;</div>
		<% } %>
	</div>
	<!-- toolbar ends -->
	<div class="" style="position:relative;display:flex;flex-direction: column;height: 100%;width: 100%;" >
	<iframe id="ifmPrintContents" style="height: 0px; width: 0px; position: absolute;display:none;"></iframe>
	<form id="filter" name="filter" method="POST" action="processStatus.jsp" style="flex-shrink: 0;">
		<div style="padding: 15px;">
			
			<div class="" style="margin-bottom:15px;">
				<div class="form-group" style="display:inline-block;">
					<button type="button" class="btn btn-info" onclick="onClickLoad()" title="Reload" style="display:inline-block">
						<svg xmlns="http://www.w3.org/2000/svg" style="vertical-align: initial;" width="14" height="14" viewBox="0 0 24 24"><path fill="#fff" d="M20.944 12.979c-.489 4.509-4.306 8.021-8.944 8.021-2.698 0-5.112-1.194-6.763-3.075l1.245-1.633c1.283 1.645 3.276 2.708 5.518 2.708 3.526 0 6.444-2.624 6.923-6.021h-2.923l4-5.25 4 5.25h-3.056zm-15.864-1.979c.487-3.387 3.4-6 6.92-6 2.237 0 4.228 1.059 5.51 2.698l1.244-1.632c-1.65-1.876-4.061-3.066-6.754-3.066-4.632 0-8.443 3.501-8.941 8h-3.059l4 5.25 4-5.25h-2.92z"/></svg>
					</button>
					<select name="process" id="process" onchange="onClickLoad()" class="form-control" style="display:inline-block;width:auto;">
			<option value="#">-- Select Process --</option>
			<% for(String key : processes.keySet()) { %>
				<option value="<%=key%>"><%=processes.get(key)%></option>
			<% } %>
		</select>
					<select id="opacity" class="form-control" style="display: inline-block;width:auto;">
					<option value="0.1">10%</option>
					<option value="0.2">20%</option>
					<option value="0.3">30%</option>
					<option value="0.4" selected>40%</option>
					<option value="0.5">50%</option>
					<option value="0.6">60%</option>
					<option value="0.7">70%</option>
					<option value="0.8">80%</option>
					<option value="0.9">90%</option>
					<option value="1">100%</option>
				</select>
			</div>
				
				<!-- <div style="width:50px; text-align:center; font-weight:bold; color:white; background-color:#FF6600; cursor:pointer" onclick="javascript:help()">Help</div> -->
				
						
				&nbsp;&nbsp;&nbsp;
				<a href='javascript:onNewProcess()'>New Process</a>	
				<div id="toolBar2" style="clear:both">
					<button type="button" class="btn btn-dark" onclick='printDiv("divGraph")'>Print</button>		
					<button type="button" class="btn btn-dark" id='deleteProcessBtn' >Delete Process</button>
					<button type="button" class="btn btn-dark" id='copyProcessBtn' >Copy</button>
					<input type='checkbox' id='showLabels' style="margin-left:15px;">Show Labels</input>
					
				</div>
				
				<div id="legend" style="margin-top: 20px;display: inline-block;">
				<span style="width:15px;height:15px;background-color:orange;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Start Phase
				<span style="width:15px;height:15px;background-color:yellow;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;End Phase
						<span style="width:15px;height:15px;background-color:gray;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Intra Process
			</div>
			<div style="clear:both"></div>

			</div>
		</div>
</form>



	<div id="divGraph" class="w-100" style="border-top:1px solid gray;position:relative; height:80vh;overflow-x: auto;flex-grow: 1;background-color:white">
</div>
</div>
                </main>
<div id="modalWindow" title=""></div>
</body>
<% if(!proc.equals("") && !proc.equals("#")) { %>
	<script>
		document.getElementById("toolbar").style.display="block";
	</script>
<% } %>

<jsp:include page="loadGraphicalProcess.jsp" >  
	<jsp:param name="process" value="<%=proc%>" />  
	<jsp:param name="screenMode" value="UPDATE" />  
</jsp:include> 


</html>
