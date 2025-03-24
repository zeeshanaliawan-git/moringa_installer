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
    String engine = parseNull(request.getParameter("engine"));
%>
<!DOCTYPE html>
<html lang="en">
	<head>
		<title>Engine Logs</title>
        <%@ include file="/WEB-INF/include/headsidebar.jsp"%>
	</head>
	<body class="c-app" style="background-color:#efefef">
        <div class="container">
		    <div id="logContainer" style="border:1px solid #000; padding:10px; height:400px; overflow-y:scroll;"></div>
            <button type="button" class="btn btn-primary" id="sendButton">sendButton</button>
        </div>
        <script>     
            $(document).ready(function() {
                var socket = new WebSocket("ws://localhost:9806");
                
                socket.onopen = function() {
                    console.log("WebSocket connection established");
                };
                
                socket.onmessage = function(event) {
                    var message = event.data;
                    $("#messages").append("<p>Received: " + message + "</p>");
                };
                
                socket.onclose = function() {
                    console.log("WebSocket connection closed");
                };
                
                socket.onerror = function(error) {
                    console.error("WebSocket error:", error);
                };
                
                $("#sendButton").click(function() {
                    var message = "Hello, Server!";
                    socket.send(message);
                    $("#messages").append("<p>Sent: " + message + "</p>");
                });
            });
            // $(document).ready(function() {

            //     var getEngineLogs = function() {
            //         $.ajax({
            //             url: './ajax/getEngineLogs.jsp',
            //             type: 'GET',
            //             success: function(response) {
            //                 console.log(response);
            //             },
            //             error: function(error) {
            //                 console.error('Error:', error);
            //             }
            //         });
            //     }

            //     getEngineLogs();
            // });
        </script>
    </body>
	
</html>