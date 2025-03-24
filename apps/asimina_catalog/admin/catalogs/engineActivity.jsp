 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.List, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../common.jsp"%>

<%
    String[] enginesList=GlobalParm.getParm("OBSERVER_ENGINES").split(",");
%>
<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Engines Activity</title>
        <%@ include file="/WEB-INF/include/headsidebar.jsp"%>
        <style>
            .publish-status-circle {
                border-radius: 50%;
                height: 25px;
                width: 25px;
                border-radius: 50%;
                border: 1px solid rgb(221, 221, 221);
                display: inline-block;
                vertical-align: middle;
                margin-left: 15px;
            }
        </style>
	</head>
	<body class="c-app" style="background-color:#efefef">
		<%@ include file="/WEB-INF/include/sidebar.jsp" %>
		<div class="c-wrapper c-fixed-components">
			<%@ include file="/WEB-INF/include/header.jsp" %>
			<div class="c-body">
				<main class="c-main"  style="padding:0px 30px">
                    <form name="fsi" id="fsi" method="post" class="form-horizontal" role="form">
                        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                            <div>
                                <h1 class="h2">Engines Activity</h1>
                            </div>
                            <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Engines Activity');" title="Add to shortcuts">
                                <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                            </button>
                        </div>
                        <div id="customerEditParameters">
                            <div class="animated fadeIn">
                                <div id="enginesActivityTable">
                                        <table class="table table-hover table-vam m-t-20 display" id="orderTbl">
                                            <thead class="thead-dark">
                                                <tr>
                                                    <th>Engine Name</th>
                                                    <th>Engine Start Date</th>
                                                    <th>Engine End Date</th>
                                                    <th>Engine Status</th>
                                                    <%-- <th>Show Logs</th> --%>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <%for(String name: enginesList){%>
                                                    <tr>
                                                        <td>
                                                           <%=name%>
                                                        </td>
                                                        <%
                                                        String color="success";
                                                        Set rs =Etn.execute("select e.engine_name,e.start_date,e.end_date,TIMESTAMPDIFF(MINUTE,e.start_date,NOW()) >"+
                                                        "10 as 'st',TIMESTAMPDIFF(MINUTE,e.end_date,NOW()) >10 as 'et' from "+GlobalParm.getParm("COMMONS_DB")+
                                                        ".engines_status e where e.engine_name="+escape.cote(name));
                                                        if(!rs.next()){
                                                            color="danger";
                                                        }
                                                        else{
                                                            if(rs.value("end_date").length()<=0 && rs.value("st").equalsIgnoreCase("1")){
                                                                color="danger";
                                                            }else if(rs.value("end_date").length()>0 && rs.value("et").equalsIgnoreCase("1")){
                                                                color="danger";
                                                            }
                                                        }
                                                        %>
                                                        <td>
                                                            <%=rs.value("start_date")%>
                                                        </td>
                                                        <td>
                                                            <%=rs.value("end_date")%>
                                                        </td>
                                                        <td>
                                                            <div class="bg-<%=color%> publish-status-circle" style="width:16px;height:16px;"></div>
                                                        </td>
                                                        <%-- <td class="text-center">
                                                            <button class="btn-sm btn-primary" onclick="window.open('DisplayLogs.jsp?popup=1&engine=<%=parseNull(rs.value("engine_name"))%>')" type="button" title="<%=parseNull(rs.value("engine_name"))%> Engine Logs"><i class="fa fa-history" aria-hidden="true"></i></button>
                                                        </td> --%>
                                                    </tr>
                                                <%}%>
                                            </tbody>
                                                
                                        </table>
                                </div>
                                    
                            </div>
                        </div>
                    </form>
				</main>
			</div>
			<%@ include file="/WEB-INF/include/footer.jsp" %>          
		</div>	
        <script>
            
        </script>
    </body>
	
</html>