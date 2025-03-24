 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.asimina.util.UIHelper,java.io.File,java.util.Date,java.util.Arrays,java.text.SimpleDateFormat"%>
<%@ page import="org.apache.commons.io.comparator.LastModifiedFileComparator,com.etn.beans.app.GlobalParm,org.apache.commons.codec.digest.DigestUtils,java.time.*,java.time.format.DateTimeFormatter,java.util.TimeZone"%>

<%@ include file="../common2.jsp" %>

<%!
    String convertDateToUTC(LocalDateTime datetime){
        LocalDateTime utcNow = datetime.atOffset(ZoneOffset.UTC).toLocalDateTime();
        DateTimeFormatter formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
        String formattedDate = utcNow.format(formatter);
        return formattedDate.split("T")[0];
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
<title>Logs Listing</title>
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/datatables.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">

    <!-- CoreUI and necessary plugins-->
    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>

    <!-- CoreUI and necessary plugins-->
    <script src="<%=request.getContextPath()%>/js/common.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/common.js"></script>
    <script src="<%=request.getContextPath()%>/js/datatables.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
      <main class="c-main"  style="padding:0px 30px">
        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
            <h1 class="h2">Logs Listing</h1>
        </div>
        <div class="animated fadeIn">
            <div class="form-group">
                <label for="order_ref">Order Ref:</label>
                <input type="text" class="form-control" id="order_ref" placeholder="Order Ref#">
            </div>
            <button type="button" class="btn btn-primary search-log">Search</button>
            <table id="logs-table" class="table table-hover m-t-20" style="width: 100%">
                <thead class="thead-dark">
                    <th>Date</th>
                    <th>Files</th>
                </thead>
                <tbody>
                </tbody>
                </tbody>
            </table>
  		</div>
	  </main>
      <%@ include file="../WEB-INF/include/footer.jsp" %>
	</div>
</div>
</body>
<script type="text/javascript">

        jQuery(document).ready(function() {

            var logsTable = $('#logs-table').DataTable({
                responsive: true,
                searching: false,
                columns: [
                    { data: 'date' },
                    {
                        data: 'file_name',
                        render: function(data, type, row) {
                            return '<a href="calls/downloadLogFile.jsp?file_name=' + encodeURIComponent(data) + '">' + data + '</a>';
                        }
                    }
                ],
                ajax: {
                    url: 'calls/getLogs.jsp',
                    type: 'GET',
                    data: {
                        action: 'getAll'
                    },
                    dataType:'json',
                    dataSrc: 'data.files'
                },
            });

            $('.search-log').on("click",function(){
                var orderRef = $("#order_ref").val();
                logsTable.ajax.url('calls/getLogs.jsp?action=findby&order-ref=' + encodeURIComponent(orderRef)).load();
            });

            $("#order_ref").on("keyup",function(){
                var searchTerm = this.value;
                if (searchTerm.length <= 2) {
                    logsTable.ajax.url('calls/getLogs.jsp?action=getAll').load();
                }
            });
            
        });

</script>        
</html>