<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="java.lang.Math"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%@ include file="common.jsp" %>
<%	
        Map<String, String> processes = new LinkedHashMap<String, String>();
        String processesQry = "select distinct process from phases union select distinct start_proc as process from external_phases order by process ";
        Set rsProcesses = Etn.execute(processesQry);
        while(rsProcesses.next())
        {
                processes.put(rsProcesses.value("process"),rsProcesses.value("process"));
        }
	
        boolean partialUpdate = false;
        if(((String)session.getAttribute("PROFIL")).equalsIgnoreCase("ADMIN")) partialUpdate = true;
	
        String proc = parseNull(request.getParameter("process"));
	
        Set allProfs = Etn.execute("select * from profil where profil != 'SUPER_ADMIN' order by description");
        Set allPhases = Etn.execute("select * from phases where process = "+escape.cote(proc)+" order by displayName ");
	

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
    <head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
	<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/jquery-ui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
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
        </style>
<title>Processes</title>
    </head>
    <body class="light-blue position-relative">
        <%@include file="/WEB-INF/include/menu.jsp"%>
        <!-- toolbar starts -->
        <div class="container">
        <div id="toolbar" style="position:absolute;left:5px; display:none; width:100px; margin-top:1px; margin-left:10px; text-align:left; border:#07477A 1px solid; padding: 1px; ">
            <div style='text-align:center; '><a href="javascript:showHideToolbar('toolbar','innerToolbar', null,false)" style="color:#467ED6; text-decoration:none; font-weight:bold;">&nbsp;TOOLBAR&nbsp;</a></div>
            <div id="innerToolbar">
                <div class="my-button" style="cursor:pointer" onclick="javascript:showHideToolbar('innerToolbar','profToolbar','phaseToolbar',true)">Profiles</div>
                <div class="my-button" style="cursor:pointer" onclick="javascript:showHideToolbar('innerToolbar','phaseToolbar','profToolbar',true)">Phases</div>
            </div>
        </div>
        <div style="position:absolute; z-index:10000; display:none; text-align:left" id="profToolbar">
            <% while(allProfs.next()) { %>
            <div class="toolbarButton"><input type="checkbox" id="checkbox<%=allProfs.value("profil")%>" class="profChkbox" checked value="<%=allProfs.value("profil")%>" /><%=allProfs.value("description")%>&nbsp;&nbsp;&nbsp;</div>
            <% } %>
        </div>
        <div style="position:absolute; z-index:10000; display:none; text-align:left" id="phaseToolbar">
            <% while(allPhases.next()) { %>
            <div class="toolbarButton"><input type="checkbox" id="checkbox<%=allPhases.value("phase")%>" class="phaseChkbox" checked value="<%=allPhases.value("phase")%>" /><%=allPhases.value("displayName")%>&nbsp;&nbsp;&nbsp;</div>
            <% } %>
            </div>
        </div>
        <!-- toolbar ends -->
        <div class="container" style="margin-top:60px">
            <iframe id="ifmPrintContents" style="height: 0px; width: 0px; position: absolute; display:none;"></iframe>
                    <h2 class="register invoice-heading">Processes</h2>
            <div class='semi-transparent30 col-md-8 col-md-offset-2'>

                <form class="form-horizontal" id="filter" name="filter" method="POST" action="viewProcess.jsp">

                    <table id="searchGrid" cellpadding="0" cellspacing="0" style='border:none; '>
                        <tr>
                            <td align="center">
                                <table class="global" cellpadding="0" cellspacing="0" style='border:none' >
                                    <tr>
                                        <td width="100%" class="title1 control-label" style="text-align:left;">Search Process&nbsp;:&nbsp;
                                            <select name="process" id="process" onchange="onClickLoad()">
                                                <option value="#">-- Select Process --</option>
                                                <% for(String key : processes.keySet()) { %>
                                                <option value="<%=key%>"><%=processes.get(key)%></option>
                                                <% } %>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <table cellpadding="0" cellspacing="0" style='border:none' width="100%">
                                                <tr>
                                                    <td align="left">
                                                        <a class='my-button' style='text-decoration:none; ' href='javascript:onClickLoad()'>Reload</a>&nbsp;&nbsp;
                                                    </td>
                                                    <td align="center">
                                                        <div id="toolBar2" style="float:left;">
                                                            <a class='my-button' style='text-decoration:none; ' href='javascript:printDiv("divGraph")'>Print</a>&nbsp;&nbsp;
                                                            <input type='checkbox' id='showLabels'>Show Labels</input>
                                                            &nbsp;
                                                            <select id="opacity">
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
                                                    </td>
                                                    <td >
                                                        <div id="legend" style="padding:2px; float:right">
                                                            <span style="width:15px;height:15px;background-color:orange;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Start Phase
                                                            <span style="width:15px;height:15px;background-color:yellow;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;End Phase
                                                            <span style="width:15px;height:15px;background-color:gray;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Intra Process
                                                        </div>
                                                        <div style="clear:both"></div>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>

        </div>




        <div id="divGraph" class="w-100" style="border-top:1px solid gray;position:relative; height:80vh;overflow-x: auto;flex-grow: 1;background-color:white">
        </div>

        <div id="modalWindow" title=""></div>
    </body>
    <% if(!proc.equals("") && !proc.equals("#")) { %>
    <script>
        document.getElementById("toolbar").style.display="block";
    </script>
    <% } %>

    <jsp:include page="loadGraphicalProcess.jsp" >
        <jsp:param name="process" value='<%=parseNull(request.getParameter("process"))%>' />
        <jsp:param name="screenMode" value="VIEW" />
        <jsp:param name="partialUpdate" value="<%=partialUpdate%>" />
    </jsp:include>
</html>
