<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>

<%
	request.setCharacterEncoding("utf-8");
	response.setCharacterEncoding("utf-8");
%>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap,org.json.*, com.etn.beans.app.GlobalParm, org.apache.poi.ss.formula.functions.Column"%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.asimina.util.UIHelper"%>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.io.DataInputStream"%>

<%@ include file="common2.jsp" %>

<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
		<title>Orders</title>

		<link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
		<link href="<%=request.getContextPath()%>/css/datatables.min.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/css/moringa-cui.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/css/flatpickr.min.css" rel="stylesheet">

        
        <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
        <script src="<%=request.getContextPath()%>/js2/common.js"></script>
        <script src="<%=request.getContextPath()%>/js/common.js"></script>
        <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/feather.js"></script>
        <script src="<%=request.getContextPath()%>/js/moment.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>
        <script src="<%=request.getContextPath()%>/js/datatables.min.js"></script>
        <script src="<%=request.getContextPath()%>/js/rangePlugin.js"></script>
        <script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>

        <style type="text/css">
            #orderTbl tr{
                cursor : pointer;
            }
        </style>


	</head>
	<body class="c-app" style="background-color:#efefef" >
		<%@ include file="/WEB-INF/include/sidebar.jsp" %>
		<div class="c-wrapper c-fixed-components">
			<%@ include file="/WEB-INF/include/header.jsp" %>
			<div class="c-body">
				<main class="c-main"  style="padding:0px 30px">
                    
                        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                            <div>
                                <h1 class="h2">Shop - Orders Management</h1>
                                <p class="lead"></p>
                                <button id="exportDiv" type="button" class="btn btn-primary" onclick="onExport()" >Export Excel</button>
                            </div>
                        </div>
                        <div id="customerEditParameters">
                            <div class="animated fadeIn">
                                <div id="customerEditTable">
                                    <div class="mb-3">
                                        <div class="d-flex align-items-center justify-content-md-end">

                                            <div class="mb-3 mb-xl-0">
                                                <div class="dropdown">
                                                    <button id="reportrange" class="float-right reportrange" type="button" data-toggle="dropdown" style="background: #fff; cursor: pointer; padding: 6px 10px; border: 1px solid #ccc; ; display: inline-flex; vertical-align: middle;border-radius: .25rem;">
                                                        &nbsp;
                                                        <span></span>
                                                    </button>
                                                    <div class="dropdown-menu">
                                                        <button class="dropdown-item" type="button" data-range="today" >Today</button>
                                                        <button class="dropdown-item" type="button" data-range="yesterday" >Yesterday</button>
                                                        <button class="dropdown-item" type="button" data-range="7days" >Last 7 Days</button>
                                                        <button class="dropdown-item" type="button" data-range="30days" >Last 30 Days</button>
                                                        <button class="dropdown-item" type="button" data-range="this-month" >This Month</button>
                                                        <button class="dropdown-item" type="button" data-range="last-month" >Last Month</button>
                                                        <button class="dropdown-item" type="button" data-range="this-year" >This Year</button>
                                                        <button class="dropdown-item" type="button" data-range="last-year" >Last Year</button>
                                                        <button class="dropdown-item" type="button" id="flatpickr" >Custom Range</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <table class="table table-hover table-vam m-t-20 display" id="orderTbl">
                                        <thead class="thead-dark">
                                            <tr>
                                                <th>Order Date</th>
                                                <th>Order Ref</th>
                                                <th>Name</th>
                                                <th>Delivery mode</th>
                                                <th>Status</th>
                                                <th>Status change date</th>
                                            </tr>
                                        </thead>
                                            
                                    </table>
                                </div>
                                    
                            </div>
                        </div>
                    
				</main>


			</div>
			<%@ include file="/WEB-INF/include/footer.jsp" %>
                        
		</div>

        <script type="text/javascript">
            var startDate = "";
            var endDate = "";

            if(!document.referrer.includes("<%=request.getContextPath()%>/ibo.jsp") && !document.referrer.includes("<%=request.getContextPath()%>/customerEdit.jsp")){
                sessionStorage.removeItem('defaultiboStartDate');
                sessionStorage.removeItem('defaultiboEndDate');
            }

            $(document).ready(function() {
                feather.replace();
                
                var start = (sessionStorage.getItem('defaultiboStartDate') !== null )? moment(sessionStorage.getItem('defaultiboStartDate'),"YYYYMMDD") : moment().subtract(6, 'days');
                var end = (sessionStorage.getItem('defaultiboEndDate') !== null )? moment(sessionStorage.getItem('defaultiboEndDate'),"YYYYMMDD") : moment();
                cb(start,end);
                
                startDate = flatpickr.formatDate(start[0] || start._d,'Ymd');
                endDate = flatpickr.formatDate(start[1] || end._d,'Ymd');
                
                if(sessionStorage.getItem('defaultiboPageLength')==null){
                    sessionStorage.setItem('defaultiboPageLength', 25);
                }

                $(".dropdown-menu button").on("click", function(e){
                    if(e.target.id == "flatpickr") return;

                    var parent = e.target.parentElement;
                    if(parent.querySelector(".active")!=null)
                    {
                        parent.querySelector(".active").classList.remove("active");
                    }

                    if(e.target.dataset.range.toLowerCase()=='today')
                    {
                        startDate = moment();
                        endDate = moment();

                    }else if(e.target.dataset.range.toLowerCase()=='yesterday')
                    {
                        startDate = moment().subtract(1,"days");
                        endDate = moment().subtract(1,"days");
                    }
                    else if(e.target.dataset.range.toLowerCase()=='7days')
                    {
                        startDate = moment().subtract(6, 'days');
                        endDate = moment();
                    }
                    else if(e.target.dataset.range.toLowerCase()=='30days')
                    {
                        startDate = moment().subtract(29, 'days');
                        endDate = moment();
                    }
                    else if(e.target.dataset.range.toLowerCase()=='this-month')
                    {
                        startDate = moment().startOf('month');
                        endDate = moment();
                    }
                    else if(e.target.dataset.range.toLowerCase()=='last-month')
                    {
                        startDate = moment().subtract(1,"month").startOf("month");
                        endDate = moment().subtract(1,"month").endOf("month");
                    }
                    else if(e.target.dataset.range.toLowerCase()=='this-year')
                    {
                        startDate = moment().startOf("year");
                        endDate = moment();
                    }
                    else if(e.target.dataset.range.toLowerCase()=='last-year')
                    {
                        startDate = moment().subtract(1,"year").startOf("year");
                        endDate = moment().subtract(1,"year").endOf("year");
                    }

                    onDateChange(startDate, endDate);
                });

                $('#orderTbl').DataTable({
                    responsive: true,
                    processing: true,
                    serverSide: true,
                    lengthMenu: [[25, 50, 100, -1], [25, 50, 100, 'All']],
                    TotalRecords:200,
                    order:[0,'desc'],
                    ajax: {
                        url: 'calls/getOrders.jsp',
                        type: 'POST',
                        data: function( d ) {
                            d.startDate= startDate;
                            d.endDate= endDate;
                        },
                        error : function(xhr,error,code){
                            if(xhr.status>=400)
                                location.reload();
                        }
                    },
                    columns: [
                        { data: "creationdate" },
                        { data: "orderref" },
                        { data: null,
                            render: function ( data, type, row ) {
                                return data.name[0] + '. ' + data.surnames;
                            } 
                        },
                        { data: null,
                            render: function ( data, type, row ) {
                                return data.order_snapshot.deliveryDisplayName || "";
                            } 
                        },
                        { data: "phasedisplayname" },
                        { data: "insertion_date" }
                    ],
                    createdRow: function( row, data, dataIndex){
                        if(data.csr.length>0 && data.csr!='<%=(String)session.getAttribute("LOGIN")%>'){
                            $(row).addClass('bg-danger');
                        }
                    }
                });
                
                var table = $('#orderTbl').DataTable();
                $('#orderTbl tbody').on('click', 'tr', function () {
                    var data = table.row( this ).data();
                    url1 ="customerEdit.jsp?parentUuid="+data.parent_uuid+"&post_work_id="+data.post_work_id;
                    window.location.href=url1;
                        
                } );
                adjustheight();
                
                flatpickr("#flatpickr", {
                    mode: 'range',
                    minDate: new Date(1000, 1, 01),
                    maxDate: new Date(),
                    dateFormat: 'd/m/Y',
                    onClose: onDateChange,
                    shorthandCurrentMonth: true,
                });

                $("#flatpickr").on("click",function(e){
                    e.preventDefault();
                })    
            });

            function onExport()
            {
                window.location.href='export.jsp';
            }

            function adjustheight(){
                $('#customerEditCard .card-body').height( window.outerHeight - $('.app-header').height() - $('.breadcrumb').height() - $('.app-footer').height()-48)
            }

            function refreshScreen(){
                $("#customerEditParameters").show();
                $("#customerEditTable").show();
                $('#exportDiv').show();
            }

            function cb(start, end) {
                $('.reportrange span').html(flatpickr.formatDate(start[0] || start._d,'M d, Y') + ' - ' + flatpickr.formatDate(start[1] || end._d,'M d, Y'));
            }

            function onDateChange(start, end){   
                
                cb(start, end);
                startDate = flatpickr.formatDate(start[0] || start._d,'Ymd');
                endDate = flatpickr.formatDate(start[1] || end._d,'Ymd');
                sessionStorage.setItem("defaultiboStartDate",startDate);
                sessionStorage.setItem("defaultiboEndDate",endDate);   
                $('#orderTbl').DataTable().ajax.reload();
            }

            $('#orderTbl').on( 'length.dt', function ( e, settings, len ) {
                sessionStorage.setItem('defaultiboPageLength', len);
            } );  
        </script>
	
    </body>
	
</html>
