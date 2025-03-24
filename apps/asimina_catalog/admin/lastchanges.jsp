<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.asimina.util.ActivityLog, java.util.Date, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm, java.text.*, java.util.*"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>

<%@ include file="/admin/common.jsp"%>
<%
    String siteId = getSelectedSiteId(session);

    String endDate = parseNull(request.getParameter("end"));
    String startDate =parseNull(request.getParameter("start"));
    if(endDate.trim().equals(""))
    {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Calendar cal = Calendar.getInstance();
        endDate = sdf.format(cal.getTime());
        //Number of Days to add
        cal.add(Calendar.DAY_OF_MONTH, -6);
        startDate = sdf.format(cal.getTime());
        System.out.println(startDate +" "+endDate);
    }

    String q = "select ua.*,s.name as sitename from "+GlobalParm.getParm("COMMONS_DB")+".user_actions ua left join "+GlobalParm.getParm("PORTAL_DB")+".sites s on s.id = ua.site_id where  ua.site_id = "+escape.cote(siteId);
        if(!startDate.equals("")) q += " and ua.activity_on >= "+escape.cote(startDate+" 00:00:00");
        if(!endDate.trim().equals("")) q += " and ua.activity_on <= "+escape.cote(endDate+ " 23:59:59")+" order by id desc";
    Set rs = Etn.execute(q);
%>
<!DOCTYPE html>

<html>
<head>
        <link href="<%=request.getContextPath()%>/css/daterangepicker.css" rel="stylesheet">

    <title>Track Changes</title>

    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>

	
<%	
breadcrumbs.add(new String[]{"Track Changes", ""});
%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
    <!-- title -->
    
        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
            <div>
                <h1 class="h2">Track Changes</h1>
                <p class="lead"></p>
            </div>

            <!-- buttons bar -->
            <div class="btn-toolbar mb-2 mb-md-0" >
                <div class="btn-group mr-2" role="group" aria-label="...">
                    <a href="<%=request.getContextPath()%>/admin/gestion.jsp" class="btn btn-primary" >Back</a>
                </div>
                <button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Track Changes');" title="Add to shortcuts">
                    <i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
                </button>

            <!-- /buttons bar -->
             </div><!-- /d-flex -->
        </div>
    <!-- /title -->

        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
            <div>

            </div>
           <div class="col-sm-8">
                <div class="d-flex align-items-center justify-content-md-end">

                    <div class="mb-3 mb-xl-0">
                        <div id="reportrange" class="float-right reportrange" style="background: #fff; cursor: pointer; padding: 6px 10px; border: 1px solid #ccc; ; display: inline-flex; vertical-align: middle;border-radius: .25rem;">
                            &nbsp;
                            <span></span>
                        </div>
                        <div class="btn-group btn-group-toggle float-right mr-3 d-none" data-toggle="buttons">
                            <label class="btn btn-outline-white"><input id="option1" type="radio" name="options" autocomplete="off"> Day</label>
                            <label class="btn btn-outline-white active"><input id="option2" type="radio" name="options" autocomplete="off" checked="checked"> Month</label>
                            <label class="btn btn-outline-white"><input id="option3" type="radio" name="options" autocomplete="off"> Year</label>
                        </div>
                    </div>
                </div>
            </div>
         </div>

    <!-- container -->
    <div class="animated fadeIn">
        <div>
            <form name='frm' id='frm' method='post' action='lastchanges.jsp' >
                <input type='hidden' value='<%=escapeCoteValue(startDate)%>' id="start" name='start' />
                <input type='hidden' value='<%=escapeCoteValue(endDate)%>' id="end" name='end' />
            <!-- legend -->

            <!-- /legend -->
                <table class="table table-hover table-vam m-t-20" id="resultsdata">
                    <thead class="thead-dark">
                        <th scope="col">Date</th>
                        <th scope="col">Type</th>
                        <th scope="col">Action</th>
                        <th scope="col">Description</th>
                        <th scope="col">User</th>
                        <th scope="col">IP</th>

                    </thead>
                    <tbody >
                        <%
                            while(rs.next()){
                        %>
                            <tr class="bg-white">
                                <td><%=parseNull(rs.value("activity_on"))%></td>
                                <td><%=parseNull(rs.value("type"))%></td>
                                <td ><%=parseNull(rs.value("action"))%></td>
                                <td  width="25%"><%=escapeCoteValue(parseNull(rs.value("description")))%></td>
                                <td><%=parseNull(rs.value("username"))%></td>
                                <td><%=parseNull(rs.value("ip"))%></td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </form>
        </div>
    <div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
    </div>
    <br>
</main>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<script src="<%=request.getContextPath()%>/js/moment.min.js"></script>
<script src="<%=request.getContextPath()%>/js/daterangepicker.min.js"></script>

<script>
    var startDate = "";
    var endDate = "";
    var newForm = true;

    function cb(start, end) {
        $('.reportrange span').html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
    }

    function onDateChange(start, end){
        cb(start, end);
        startDate = start.format('YYYY-MM-DD');
        endDate = end.format('YYYY-MM-DD');
        if(!newForm)
            searchLogs();
        newForm = false;
    }

    jQuery(document).ready(function()
    {
        var start = moment($('#start').val());
        var end = moment($('#end').val());
        console.log(start+"   "+end);
        $('.reportrange').daterangepicker({
            startDate: start,
            endDate: end,
            ranges: {
                'Today': [moment(), moment()],
                'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
                'Last 7 Days': [moment().subtract(6, 'days'), moment()],
                'Last 30 Days': [moment().subtract(29, 'days'), moment()],
                'This Month': [moment().startOf('month'), moment().endOf('month')],
                'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')],
                'This Year': [moment().startOf('year'), moment()],
                'Last Year': [moment().subtract(1, 'year').startOf('year'), moment().subtract(1, 'year').endOf('year')]
            }
        }, onDateChange);
        onDateChange(start, end);


        $('#resultsdata').DataTable({
            "responsive": true,
            "language": {
                "emptyTable": "No tracks found"
            },
            "pageLength": 50,
            "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, 'All']],
            "columnDefs": [
                { targets : [0, 5] , searchable : false},
                { targets : [0, 5] , orderable : false}
            ],
            "order": [[ 0, "desc" ]]
        });

        refreshscreen=function()
        {
            window.location = window.location
        };
    });
    function searchLogs(){
        $('#start').val(startDate);
        $('#end').val(endDate);
        document.frm.submit();
    }

</script>
</body>
</html>
