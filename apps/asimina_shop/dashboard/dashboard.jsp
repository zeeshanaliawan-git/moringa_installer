<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.time.*, java.time.format.DateTimeFormatter, java.io.*, com.etn.beans.app.GlobalParm, com.etn.asimina.util.UIHelper"%>
<%@ include file="/common2.jsp" %>
<%
    String username = "";
    String showDecimals = "";
    String roundTo = "";
    String langFormatter =  "";

    Set rsPerson = Etn.execute("select First_name from person where person_id="+escape.cote(Etn.getId()+""));
    if(rsPerson.next()) username = rsPerson.value(0);

    String catalogDb = GlobalParm.getParm("CATALOG_DB");
    String portalDb = GlobalParm.getParm("PORTAL_DB")+".";
    String site_id=parseNull(session.getAttribute("SELECTED_SITE_ID"));
    String lang="1";

    if(site_id.length()>0){
        Set rsLang = Etn.execute("select langue_id from "+GlobalParm.getParm("COMMONS_DB")+".sites_langs where site_id="+escape.cote(site_id)+
            " order by langue_id asc limit 1");
        rsLang.next();
        lang = rsLang.value("langue_id");
    }

    String prefix = "lang_" + lang + "_";
    
    Set rsSiteParams = Etn.execute("select  "+prefix+"price_formatter as price_formatter, "+prefix+"round_to_decimals as round_to_decimals, "
                                    +prefix+"show_decimals as show_decimals from "+catalogDb+".shop_parameters where site_id =  "+escape.cote(site_id));
    if(rsSiteParams.next())
    {
        langFormatter = parseNull(rsSiteParams.value("price_formatter"));
        roundTo = parseNull(rsSiteParams.value("round_to_decimals"));
        showDecimals = parseNull(rsSiteParams.value("show_decimals"));
    }

    Set rsFilters = Etn.execute("select id,filter_name from dashboard_filters where site_id="+escape.cote(site_id));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>Shop - Dashboard</title>
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
<link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/flatpickr.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/moringa-cui.css" rel="stylesheet">
    <style>

.chartjs-tooltip {
  position: absolute;
  z-index: 1021;
  display: -ms-flexbox;
  display: flex;
  -ms-flex-direction: column;
  flex-direction: column;
  padding: 0.25rem 0.5rem;
  color: #fff;
  pointer-events: none;
  background: rgba(0, 0, 0, 0.7);
  opacity: 0;
  transition: all 0.25s ease;
  -webkit-transform: translate(-50%, 0);
  transform: translate(-50%, 0);
  border-radius: 0.25rem;
}

.chartjs-tooltip .tooltip-header {
  margin-bottom: 0.5rem;
}

.chartjs-tooltip .tooltip-header-item {
  font-size: 0.765625rem;
  font-weight: 700;
}

.chartjs-tooltip .tooltip-body-item {
  display: -ms-flexbox;
  display: flex;
  -ms-flex-align: center;
  align-items: center;
  font-size: 0.765625rem;
  white-space: nowrap;
}

.chartjs-tooltip .tooltip-body-item-color {
  display: inline-block;
  width: 0.875rem;
  height: 0.875rem;
  margin-right: 0.875rem;
}

.chartjs-tooltip .tooltip-body-item-value {
  padding-left: 1rem;
  margin-left: auto;
  font-weight: 700;
}
         .loading2 {
             overflow: hidden;
             position: relative;
         }

         .loading2::after {
             content: "";
             overflow: hidden;
             display: block;
             position: absolute;
             z-index: 99999;
             top: 0;
             left: 0;
             height: 100%;
             width: 100%;
             background: rgba( 255, 255, 255, .8) url('/src/assets/images/loader.gif') 50% 45% no-repeat;
         }

         body.loading2::after {
             position: fixed;
         }

         .loading2>.loading2msg {
             position: absolute;
             top: 55%;
             width: 100%;
             text-align: center;
             z-index: 9999999;
         }

         body.loading2>.loading2msg {
             position: fixed;
         }

        .sidebar .nav-dropdown-items.active {max-height:inherit !important }
        .sidebar {height: calc(100vh - 55px);width:200px}
        .sidebar-minimized .sidebar {width:50px;}
        .feather-16{width: 16px;height: 16px;}
        .feather-20{width: 20px;height: 20px;}
        .feather-32{width: 32px;height: 32px;}

        .responsive-inline-frame-inner {width: 100%;position: relative;overflow: hidden;padding-top: 56.25%;height: 0;}
        .responsive-inline-frame-inner iframe {position: absolute;top: 0;left: 0;width: 100%;height: 100%;}

        .btn-outline-white {
            color: #23282c;
            background-color: #fff;
            background-image: none;
            border-color: #c8ced3;
        }

        .btn-outline-white:not(:disabled):not(.disabled):active, .btn-outline-white:not(:disabled):not(.disabled).active, .show > .btn-outline-white.dropdown-toggle {
            color: #23282c;
            background-color: #c8ced3;
            border-color: #c8ced3;
        }
        .btn-outline-white:hover {
            color: #23282c;
            background-color: #c8ced3;
            border-color: #c8ced3;
        }

        .canvas-funnel{

            width: 100% !important;

        }
    </style>
	
    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/feather.js"></script>
    <script src="<%=request.getContextPath()%>/js/moment.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/flatpickr.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/Chart.js"></script>
    <script src="<%=request.getContextPath()%>/js/custom-tooltips.js"></script>
    <script src="<%=request.getContextPath()%>/js/main-dashboard.js"></script>
    <script src="<%=request.getContextPath()%>/js/chart.funnel.bundled.js"></script>
    <script src="<%=request.getContextPath()%>/js/html2pdf.bundle.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/html2canvas.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/rangePlugin.js"></script>
    <script src="<%=request.getContextPath()%>/js/common.js"></script>
	
</head>
<body class="c-app" style="background-color:#efefef" >
<% if(session.getAttribute("LOGIN")!=null) {%>
    <%@ include file="/WEB-INF/include/sidebar.jsp" %>
<%}%>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">



            <!-- Page content -->
            <div id="main_div">
                <div id="ui-view">
                    <div>

                        <!-- ******************** -->


                        <div class="fade-in">


                            <div class="row mb-3">
                                <div id="asad" class="col-sm-4 mb-xl-0">
                                    <h3 style="margin-bottom:0">Welcome <b><%=UIHelper.escapeCoteValue(username)%></b>!
                                    </h3>
                                    <h6 class="font-weight-normal mb-0 text-muted d-none">Shop on line reached 57,6% of the monthly objectives</h6>
                                </div>
                                <div class="col-sm-8">
                                    <div class="d-flex align-items-center justify-content-md-end mt-1">
                                        <div class="mb-3 mb-xl-0 mr-3">

                                            <div class="dropdown">
                                                <%-- <button class="btn btn-secondary dropdown-toggle" type="button" data-toggle="dropdown"> --%>
                                                    <button id="reportrange" class="float-right reportrange" type="button" data-toggle="dropdown" style="background: #fff; cursor: pointer; padding: 6px 10px; border: 1px solid #ccc; ; display: inline-flex; vertical-align: middle;border-radius: .25rem;">
                                                        &nbsp;
                                                        <span></span>
                                                    </button>
                                                <%-- </button> --%>
                                                <div class="dropdown-menu">
                                                    <button class="dropdown-item" data-range="today" >Today</button>
                                                    <button class="dropdown-item" data-range="yesterday" >Yesterday</button>
                                                    <button class="dropdown-item" data-range="7days" >Last 7 Days</button>
                                                    <button class="dropdown-item" data-range="30days" >Last 30 Days</button>
                                                    <button class="dropdown-item" data-range="this-month" >This Month</button>
                                                    <button class="dropdown-item" data-range="last-month" >Last Month</button>
                                                    <button class="dropdown-item" data-range="this-year" >This Year</button>
                                                    <button class="dropdown-item" data-range="last-year" >Last Year</button>
                                                    <button class="dropdown-item" id="flatpickr" >Custom Range</button>
                                                </div>
                                            </div>

                                            
                                            
                                            <!-- <div class="btn-group btn-group-toggle float-right mr-3 d-none" data-toggle="buttons">
                                                <label class="btn btn-outline-white"><input id="option1" type="radio" name="options" autocomplete="off"> Day</label>
                                                <label class="btn btn-outline-white active"><input id="option2" type="radio" name="options" autocomplete="off" checked="checked"> Month</label>
                                                <label class="btn btn-outline-white"><input id="option3" type="radio" name="options" autocomplete="off"> Year</label>
                                            </div> -->
                                        </div>

                                        <div>
                                            <select id="selectCatalogType" class="form-control" style="display:inline-block;width:auto;" onchange="applyCatalogTypeFilter()">
                                                    <option value="all" selected>----- All -----</option>
                                                <%while(rsFilters.next()){%>
                                                    <option value="<%=UIHelper.escapeCoteValue(parseNull(rsFilters.value("id")))%>"><%=UIHelper.escapeCoteValue(parseNull(rsFilters.value("filter_name")))%></option>
                                                <%}%>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                            </div>


                            <div id="exportBar" class="border-top border-bottom mb-3">
                                <div class="btn-toolbar mb-2 mb-md-0" style="display: block;text-align:right;color: #000;">
                                    <button class="btn btn-link mr-2" onclick="exportData()" style="color:#23282c"><i  data-feather="download" style=""></i> Export data</button>
                                    <button class="btn btn-link mr-2" style="color:#23282c" onclick="downloadPdf()" ><i  data-feather="file-text" style=""></i> Download dashboard</button>
                                    <button class="btn btn-link" style="color:#23282c" data-toggle="modal" data-target="#emailModal"><i  data-feather="mail" style=""></i> Send as email</button>
                                </div>
                            </div>



                            <div class="row">

                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-primary">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>

                                            <div class="text-value"></div>
                                            <div class="text-label">Total revenue</div>
                                            
                                            <div class="btn-group float-right" id="spincard-chart1" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>
                                            
                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart1" height="70" style="display: block; width: 335px; height: 70px;" width="335"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-info">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>
                                            <div class="text-value"></div>
                                            <div class="text-label">Total orders</div>

                                            <div class="btn-group float-right" id="spincard-chart2" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>

                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart2" height="70" style="display: block; width: 335px; height: 70px;" width="335"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-warning">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>
                                            <div class="text-value"></div>
                                            <div class="text-label">Total products</div>
                                            
                                            <div class="btn-group float-right" id="spincard-chart3" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>

                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart3" height="70" style="display: block; width: 367px; height: 70px;" width="367"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-danger">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>
                                            <div class="text-value"></div>
                                            <div class="text-label">Transformation rate</div>

                                            <div class="btn-group float-right" id="spincard-chart4" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>

                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart4" height="70" style="display: block; width: 335px; height: 70px;" width="335"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-primary">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>
                                            <div class="text-value"></div>
                                            <div class="text-label">Abandoned Carts</div>

                                            <div class="btn-group float-right" id="spincard-chart5" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>

                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart5" height="70" style="display: block; width: 335px; height: 70px;" width="335"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-info">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>
                                            <div class="text-value"></div>
                                            <div class="text-label">Products per order</div>

                                            <div class="btn-group float-right" id="spincard-chart6" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>

                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart6" height="70" style="display: block; width: 335px; height: 70px;" width="335"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-warning">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>
                                            <div class="text-value"></div>
                                            <div class="text-label">Average order amount</div>

                                            <div class="btn-group float-right" id="spincard-chart7" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>

                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart7" height="70" style="display: block; width: 367px; height: 70px;" width="367"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-danger">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>
                                            <div class="text-value"></div>
                                            <div class="text-label">Number of visitors</div>

                                            <div class="btn-group float-right" id="spincard-chart8" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>

                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart8" height="70" style="display: block; width: 335px; height: 70px;" width="335"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-primary">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>
                                            <div class="text-value"></div>
                                            <div class="text-label">Average time for order treatment</div>

                                            <div class="btn-group float-right" id="spincard-chart9" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>

                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart9" height="70" style="display: block; width: 335px; height: 70px;" width="335"></canvas>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-info">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>
                                            <div class="text-value"></div>
                                            <div class="text-label">Average time for home delivery - standard</div>

                                            <div class="btn-group float-right" id="spincard-chart10" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>

                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart10" height="70" style="display: block; width: 335px; height: 70px;" width="335"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-sm-4 col-lg-3">
                                    <div class="card text-white bg-warning">
                                        <div class="card-body pb-0">
                                            <div class="btn-group float-right">
                                                <button class="btn btn-transparent p-0" type="button" data-toggle="modal" data-target="#editKpiDialog" onclick="editKPI(this)"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                            </div>
                                            <div class="text-value"></div>
                                            <div class="text-label">Average time for home delivery - express</div>

                                            <div class="btn-group float-right" id="spincard-chart11" style="display:none">
                                                <i class='fa fa-circle-o-notch fa-spin'></i>
                                            </div>

                                        </div>
                                        <div class="chart-wrapper mt-3 mx-3" style="height:70px;">
                                            <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                </div>
                                                <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                    <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                </div>
                                            </div>
                                            <canvas class="chart chartjs-render-monitor" id="card-chart11" height="70" style="display: block; width: 335px; height: 70px;" width="335"></canvas>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- <div class="html2pdf__page-break"></div> -->
                            <div class="row mb-3">
                                <div class="col-sm-12">
                                    <div class="card h-100" style="max-height:550px">
                                        <div class="card-header bg-dark text-white font-weight-bold">
                                            <div class="row">
                                                <div class="col-md-10">
                                                    Orders & Products<div class="small text-muted">unit(s)</div>
                                                </div>
                                                <div class="col-md-2">
                                                    <div class="btn-group float-right flex-column">
                                                        <button class="btn btn-transparent p-0" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                                        <i class='fa fa-circle-o-notch fa-spin' style="display:none;text-align: center" id="orderSpinner"></i>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="card-body">

                                            <div class="chart-wrapper" style="height:300px;margin-top:40px;">
                                                <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                    <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                        <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                    </div>
                                                    <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                        <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                    </div>
                                                </div>
                                                <canvas class="chart chartjs-render-monitor" id="main-chart" height="300" style="display: block;" width="1522"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="html2pdf__page-break"></div>
                            <div class="row mb-3">
                                <div class="col-12">
                                    <div class="card h-100" style="max-height:550px">
                                        <div class="card-header bg-dark text-white font-weight-bold">
                                            <div class="row">
                                                <div class="col-md-10">
                                                    Revenue<div class="small text-muted">in FCFA</div>
                                                </div>
                                                <div class="col-md-2">
                                                    <div class="btn-group float-right flex-column">
                                                        <button class="btn btn-transparent p-0" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                                        <i class='fa fa-circle-o-notch fa-spin' style="display:none;text-align: center" id="revenueSpinner"></i>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="card-body">

                                            <div class="chart-wrapper" style="height:300px;margin-top:40px;">
                                                <div style="position: absolute; inset: 0px; overflow: hidden; pointer-events: none; visibility: hidden; z-index: -1;" class="chartjs-size-monitor">
                                                    <div class="chartjs-size-monitor-expand" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                        <div style="position:absolute;width:1000000px;height:1000000px;left:0;top:0"></div>
                                                    </div>
                                                    <div class="chartjs-size-monitor-shrink" style="position:absolute;left:0;top:0;right:0;bottom:0;overflow:hidden;pointer-events:none;visibility:hidden;z-index:-1;">
                                                        <div style="position:absolute;width:200%;height:200%;left:0; top:0"></div>
                                                    </div>
                                                </div>
                                                <canvas class="chart chartjs-render-monitor" id="main-chart2" height="300" style="display: block;" width="1522"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- <div class="html2pdf__page-break"></div> -->
                            <div class="row mb-3">
                                <div class="col-sm-5">
                                    <div class="card h-100" >
                                        <div class="card-header bg-dark text-white font-weight-bold">
                                            <div class="row">
                                                <div class="col-md-10">
                                                    Top selling products<div class="small text-muted">unit(s)</div>
                                                </div>
                                                <div class="col-md-2">
                                                    <div class="btn-group float-right flex-column">
                                                        <button class="btn btn-transparent p-0" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                                        <i class='fa fa-circle-o-notch fa-spin' style="display:none;text-align: center" id="sellingSpinner"></i>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="topSellersChart" class="card-body" style="height:400px;overflow:auto;">

                                            </div>
                                        </div>
                                </div>
                                <div class="col-sm-4">
                                    <div class="card h-100" style="max-height:550px">
                                        <div class="card-header bg-dark text-white font-weight-bold">
                                            <div class="row">
                                                <div class="col-md-10">
                                                    Top Agents<div class="small text-muted">sale(s)</div>
                                                </div>
                                                <div class="col-md-2">
                                                    <div class="btn-group float-right flex-column">
                                                        <button class="btn btn-transparent p-0" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                                        <i class='fa fa-circle-o-notch fa-spin' style="display:none;text-align: center" id="agentSpinner"></i>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="topAgentsChart" class="card-body" style="height:400px;overflow:auto;">

                                            </div>
                                        </div>
                                </div>
                                <!-- <div class="html2pdf__page-break"></div> -->
                                <div class="col-sm-3">
                                    <div class="card h-100" style="max-height:550px">
                                        <div class="card-header bg-dark text-white font-weight-bold">
                                        <div class="row">
                                            <div class="col-md-10">
                                                Funnel<div class="small text-muted">visits</div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="btn-group float-right flex-column">
                                                    <button class="btn btn-transparent p-0" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                                    <i class='fa fa-circle-o-notch fa-spin' style="display:none;text-align: center" id="funnelSpinner"></i>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                        <div class="card-body">
                                            <div id="canvas-holder" style="">
                                                <canvas class="canvas-funnel" id="chart-area"  height="380"></canvas>
                                            </div>
                                        </div>
                                    </div>

                                </div>
                            </div>
                            <div class="html2pdf__page-break"></div>
                            <div class="row mb-3">
                                        <div class="col-sm-6 mb-3">
                                            <div class="card h-100" style="max-height:550px">
                                                <div class="card-header bg-dark text-white font-weight-bold">
                                                    <div class="row">
                                                        <div class="col-md-10">
                                                            Distribution of products per promotions<div class="small text-muted">product(s)</div>
                                                        </div>
                                                        <div class="col-md-2">
                                                            <div class="btn-group float-right">
                                                                <button class="btn btn-transparent p-0" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="card-body">
                                                    <div class="c-chart-wrapper"><div class="chartjs-size-monitor"><div class="chartjs-size-monitor-expand"><div class=""></div></div><div class="chartjs-size-monitor-shrink"><div class=""></div></div></div>
                                                    <canvas id="promotionDistributionCanvas" width="582" height="290" class="chartjs-render-monitor" style="display: block; width: 582px; height: 290px;"></canvas>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-sm-6 mb-3">
                                        <div class="card h-100" style="max-height:550px">
                                            <div class="card-header bg-dark text-white font-weight-bold">
                                                <div class="row">
                                                    <div class="col-md-10">
                                                        Distribution of sales per delivery method<div class="small text-muted">sale(s)</div>
                                                    </div>
                                                    <div class="col-md-2">
                                                        <div class="btn-group float-right">
                                                            <button class="btn btn-transparent p-0" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="card-body">
                                                <div class="c-chart-wrapper"><div class="chartjs-size-monitor"><div class="chartjs-size-monitor-expand"><div class=""></div></div><div class="chartjs-size-monitor-shrink"><div class=""></div></div></div>
                                                <canvas id="deliveryDistributionCanvas" width="582" height="290" class="chartjs-render-monitor" style="display: block; width: 582px; height: 290px;"></canvas>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-sm-6 mb-3">
                                    <div class="card h-100" style="max-height:550px">
                                        <div class="card-header bg-dark text-white font-weight-bold">
                                            <div class="row">
                                                <div class="col-md-10">
                                                    Distribution of sales per delivery stores<div class="small text-muted">sale(s)</div>
                                                </div>
                                                <div class="col-md-2">
                                                    <div class="btn-group float-right">
                                                        <button class="btn btn-transparent p-0" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <div class="c-chart-wrapper"><div class="chartjs-size-monitor"><div class="chartjs-size-monitor-expand"><div class=""></div></div><div class="chartjs-size-monitor-shrink"><div class=""></div></div></div>
                                            <canvas id="deliveryStoreDistributionCanvas" width="582" height="290" class="chartjs-render-monitor" style="display: block; width: 582px; height: 290px;"></canvas>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-6 mb-3">
                                    <div class="card h-100">
                                        <div class="card-header bg-dark text-white font-weight-bold">
                                            <div class="row">
                                                <div class="col-md-10">
                                                    Distribution of delivery methods per type<div class="small text-muted">delivery methods(s)</div>
                                                </div>
                                                <div class="col-md-2">
                                                    <div class="btn-group float-right">
                                                        <button class="btn btn-transparent p-0" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="card-body">
                                            <div class="c-chart-wrapper"><div class="chartjs-size-monitor"><div class="chartjs-size-monitor-expand"><div class=""></div></div><div class="chartjs-size-monitor-shrink"><div class=""></div></div></div>
                                            <canvas id="deliveryDistributionTypeCanvas" width="582" height="290" class="chartjs-render-monitor" style="display: block; width: 582px; height: 290px;"></canvas>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-sm-6 mb-3">
                                <div class="card h-100" style="max-height:550px">
                                    <div class="card-header bg-dark text-white font-weight-bold">
                                        <div class="row">
                                            <div class="col-md-10">
                                                Distribution of sales per delivery point<div class="small text-muted">sale(s)</div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="btn-group float-right">
                                                    <button class="btn btn-transparent p-0" type="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="nav-icon feather-16" data-feather="settings"></i></button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="c-chart-wrapper"><div class="chartjs-size-monitor"><div class="chartjs-size-monitor-expand"><div class=""></div></div><div class="chartjs-size-monitor-shrink"><div class=""></div></div></div>
                                        <canvas id="deliveryPointDistributionCanvas" width="582" height="290" class="chartjs-render-monitor" style="display: block; width: 582px; height: 290px;"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
            <!-- /Page content -->


        </main>
        <!-- /main container -->
    </div>
    <div>

        <div class="modal fade" id="editKpiDialog" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel3" aria-hidden="true">
            <div class="modal-dialog modal-dialog-slideout modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header bg-lg1">
                        <h5 class="modal-title font-weight-bold" id="exampleModalLabel">Edit KPI</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">×</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3 text-right">
                            <button type="button" class="btn btn-primary" onclick="saveKPI()">Save</button>
                        </div>
                        <form>
                            <div class="form-group row">
                                <label for="staticEmail" class="col-sm-3 col-form-label">KPI</label>
                                <div class="col-sm-9">
                                    <select class="custom-select" id="edit_kpi" aria-label="Example select with button addon">
                                        <option value="1" selected>Total revenue</option>
                                        <option value="2">Total orders</option>
                                        <option value="3">Total products</option>
                                        <option value="4" >Transformation rate</option>
                                        <option value="5" >Abandoned Carts</option>
                                        <option value="6" >Products per order</option>
                                        <option value="7" >Average order amount</option>
                                        <option value="8" >Number of visitors</option>
                                        <option value="9" >Average time for order treatment</option>
                                        <option value="10" >Average time for home delivery - standard</option>
                                        <option value="11" >Average time for home delivery - express</option>
                                    </select>
                                </div>
                            </div>

                            <div class="form-group row">
                                <label for="staticEmail" class="col-sm-3 col-form-label">Label</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" id="edit_label" value="CA online en FCFA">
                                </div>
                            </div>

                            <div class="form-group row">
                                <label for="staticEmail" class="col-sm-3 col-form-label">Rules </label>
                                <div class="col-sm-9">
                                    <div class="input-group">
                                        <div class="input-group-prepend">
                                            <div class="input-group-text">
                                                <input type="checkbox" aria-label="Checkbox for following text input" checked>
                                            </div>
                                        </div>
                                        <select class="custom-select" id="edit_graph_type" aria-label="">
                                            <option value="line">Line</option>
                                            <option value="bar">Bar</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group row">
                                <label for="staticEmail" class="col-sm-3 col-form-label">Color</label>
                                <div class="col-sm-9">
                                    <select class="custom-select" id="edit_graph_color" aria-label="Example select with button addon">
                                        <option value="bg-primary" selected>Blue 1</option>
                                        <option value="bg-info">Blue 2</option>
                                        <option value="bg-warning">Yellow</option>
                                        <option value="bg-danger">Red</option>
                                    </select>
                                </div>
                            </div>


                        </form>
                    </div>
                </div>
            </div>

        </div>

        <div class="modal fade" id="emailModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="exampleModalLabel">Email</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="container-fluid">
                            <form id="emailPdfForm" action="calls/mailDashboardPdf.jsp" method="post" >
                                <div class="col-12">
                                    <div class="form-row">
                                        <label for="email" class="col-sm-2 col-form-label">To:</label>
                                        <div class="col-sm-10 form-group ">
                                            <input type="text" class=" form-control" name="email" id="email">
                                            <span style="color:red;font-size: 11px" id="emailError"></span>
                                        </div>
                                    </div>
                                    <div class="form-row" >
                                        <label for="subject" class="col-sm-2 col-form-label">Subject:</label>
                                        <div class="col-sm-10 form-group ">
                                            <input type="text" class="form-control" id="subject" name="subject">
                                            <span style="color:red;font-size: 11px" id="subjectError" ></span>
                                        </div>
                                    </div>
                                    <div class="form-group" >
                                        <label for="message" class="col-form-label">Message:</label>
                                        <textarea class="form-control" rows="5" id="message" name="message"></textarea>
                                    </div>
                                </div>

                                <input  hidden type="text" id="pdf" value=""  name="pdf">
                            </form>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="mailDashboardPdf()" >Send</button>
                    </div>
                </div>
            </div>
        </div>

    </div>
    <%@ include file="/WEB-INF/include/footer.jsp" %>


    <script type="text/javascript">
        let catalogType="all"; 
        var startDate = "";
        var endDate = "";
        var mainChart = null;
        var periodicFunnelChart = null;
        var mainChart2 = null;
        var funnelChart = null;
        var cardChart1 = null;
        var cardChart2 = null;
        var cardChart3 = null;
        var cardChart4 = null;
        var cardChart5 = null;
        var cardChart6 = null;
        var cardChart7 = null;
        var cardChart8 = null;
        var cardChart9 = null;
        var cardChart10 = null;
        var cardChart11 = null;

        var tooltipConfig = {
            mode: 'label',
            label: 'mylabel',
            callbacks: {
                   label: function(tooltipItem, data){
                     return priceformatter('<%=UIHelper.escapeCoteValue(langFormatter)%>', '<%=UIHelper.escapeCoteValue(roundTo)%>' ,'<%=UIHelper.escapeCoteValue(showDecimals)%>',tooltipItem.yLabel)
                    }
           }
        }
        var promotionDistributionChart = null;
        var deliveryDistributionChart = null;
        var deliveryDistributionTypeChart = null;
        var deliveryStoreDistributionChart = null;
        var deliveryPointDistributionChart = null;
        Chart.defaults.global.pointHitDetectionRadius = 1;
        Chart.defaults.global.tooltips.enabled = false;
        Chart.defaults.global.tooltips.mode = 'index';
        Chart.defaults.global.tooltips.position = 'nearest';
        Chart.defaults.global.tooltips.custom = CustomTooltips;

        var selectedKpi = null;
        var kpiUrls={
            '1': 'calls/getRevenueChartSmallData.jsp',
            '2': 'calls/getOrdersChartSmallData.jsp',
            '3': 'calls/getQuantityChartSmallData.jsp',
            '4': 'calls/getTransformationRateChartSmallData.jsp',
            '5': 'calls/getAbandonedCartsChartSmallData.jsp',
            '6': 'calls/getProductsPerOrderChartSmallData.jsp',
            '7': 'calls/getAverageOrderChartSmallData.jsp',
            '8': 'calls/getVisitorsChartSmallData.jsp',
            '9': 'calls/getAverageTimeForOrderTreatmentChartSmallData.jsp',
            '10': 'calls/getAverageTimeForHomeDeliveryChartSmallData.jsp',
            '11': 'calls/getAverageTimeForHomeDeliveryChartSmallData.jsp'
        };

        var kpiSettings = {
            'card-chart1': {
                kpi: '1',
                label: 'Total revenue in <currency>',
                graphType: 'line',
                graphColor: 'bg-primary',
                chart: null,
                additionalInfo:""
            },
            'card-chart2': {
                kpi: '2',
                label: 'Total orders',
                graphType: 'bar',
                graphColor: 'bg-info',
                chart: null,
                additionalInfo:""
            },
            'card-chart3': {
                kpi: '3',
                label: 'Total products',
                graphType: 'bar',
                graphColor: 'bg-warning',
                chart: null,
                additionalInfo:""
            },
            'card-chart4': {
                kpi: '4',
                label: 'Transformation rate',
                graphType: 'bar',
                graphColor: 'bg-danger',
                chart: null,
                additionalInfo:""
            },
            'card-chart5': {
                kpi: '5',
                label: 'Abandoned Carts',
                graphType: 'bar',
                graphColor: 'bg-primary',
                chart: null,
                additionalInfo:""
            },
            'card-chart6': {
                kpi: '6',
                label: 'Products per order',
                graphType: 'bar',
                graphColor: 'bg-info',
                chart: null,
                additionalInfo:""
            },
            'card-chart7': {
                kpi: '7',
                label: 'Average order amount in <currency>',
                graphType: 'bar',
                graphColor: 'bg-warning',
                chart: null,
                additionalInfo:""
            },
            'card-chart8': {
                kpi: '8',
                label: 'Number of visitors',
                graphType: 'bar',
                graphColor: 'bg-danger',
                chart: null,
                additionalInfo:""
            },'card-chart9': {
                kpi: '9',
                label: 'Average time for order treatment',
                graphType: 'bar',
                graphColor: 'bg-primary',
                chart: null,
                additionalInfo:""
            },'card-chart10': {
                kpi: '10',
                label: 'Average time for home delivery - standard',
                graphType: 'bar',
                graphColor: 'bg-info',
                chart: null,
                additionalInfo: "Livraison classique - 24H"
            },'card-chart11': {
                kpi: '11',
                label: 'Average time for home delivery - express',
                graphType: 'bar',
                graphColor: 'bg-warning',
                chart: null,
                additionalInfo: "Livraison express - 2H"
            }
        };

        function initChartSmallGeneric(chartSetting, id){
            $("#spin"+id).show();
            $.ajax({
                url : kpiUrls[chartSetting.kpi],
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate,
                    label: chartSetting.label,
                    graphType: chartSetting.graphType,
                    catalogType:catalogType,
                    deliveryType:chartSetting.additionalInfo
                },
                dataType: 'json',
                success : function(json)
                {
                    if(id == 'card-chart1' || id == 'card-chart7' ){
                        json.options.tooltips = tooltipConfig;
                        json.total = priceformatter('<%=UIHelper.escapeCoteValue(langFormatter)%>', '<%=UIHelper.escapeCoteValue(roundTo)%>' ,'<%=UIHelper.escapeCoteValue(showDecimals)%>',json.total)
                    }
                    if(chartSetting.chart!=null) chartSetting.chart.destroy();
                    chartSetting.chart = new Chart($('#'+id), json);
                    $('#'+id).closest('.card').find('.text-value').html(json.total);
                    $('#'+id).closest('.card').find('.text-label').html(json.label);
                    $('#'+id).closest('.card').removeClass("bg-primary bg-info bg-warning bg-danger").addClass(chartSetting.graphColor);
                    $("#spin"+id).hide();
                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                    $("#spin"+id).hide();
                }
            });
            
        }

        function applyCatalogTypeFilter(){
            catalogType = document.getElementById("selectCatalogType").value;
            initCharts();
        }

        function cb(start, end) {
            $('.reportrange span').html(flatpickr.formatDate(start[0] || start._d,'M d, Y') + ' - ' + flatpickr.formatDate(start[1] || end._d,'M d, Y'));
        }

        function onDateChange(start, end){      
			cb(start, end);
			startDate = flatpickr.formatDate(start[0] || start._d,'Ymd');
			endDate = flatpickr.formatDate(start[1] || end._d,'Ymd');
            initCharts();
        }

        $(document).ready(function(){
            feather.replace();
            var start = moment().subtract(6, 'days');
            var end = moment();

            $(".dropdown-menu button").on("click", function(e){
                var parent = e.target.parentElement;
                var startDate;
                var endDate;
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

            flatpickr("#flatpickr", {
                mode: 'range',
                // defaultDate: [start, end],
                minDate: new Date(1000, 1, 01),
                maxDate: new Date(),
                dateFormat: 'd/m/Y',
                onClose: onDateChange,
                shorthandCurrentMonth: true,
                // plugins: [new rangePlugin({ input: ".reportrange", })],
            })

            onDateChange(start, end);

            $("#emailModal").on('hide.bs.modal', function(){
                $('#email').val("");
                $('#subject').val("");
                $('#message').val("");
            });

        });

        function initFunnelChart(){
            $('#funnelSpinner').show();
            $.ajax({
                url : 'calls/getFunnelChartData.jsp',
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate,
                    catalogType:catalogType
                },
                dataType: 'json',
                success : function(json)
                {
                    if(funnelChart!=null) funnelChart.destroy();
                    funnelChart = new FunnelChart($('#chart-area'), json);
                    $('#funnelSpinner').hide();
                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                    $('#funnelSpinner').hide();
                }
            });
        }
        function initOrdersAndProductsChart(){
            $('#orderSpinner').show();
            $.ajax({
                url : 'calls/getOrdersAndProductsChartData.jsp',
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate,
                    catalogType:catalogType
                },
                dataType: 'json',
                success : function(json)
                {
                    if(mainChart!=null) mainChart.destroy();
                    mainChart = new Chart($('#main-chart'), json);
                    $('#orderSpinner').hide();
                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                    $('#orderSpinner').show();
                }
            });
        }

        function initRevenueChart(){
            $('#revenueSpinner').show();
            $.ajax({
                url : 'calls/getRevenueChartData.jsp',
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate,
                    catalogType:catalogType
                },
                dataType: 'json',
                success : function(json)
                {
                    json.options.tooltips = tooltipConfig;
                    json.options.scales.yAxes = [{
                     ticks: {
                        callback: function(label, index, labels) { return priceformatter('<%=UIHelper.escapeCoteValue(langFormatter)%>', '<%=UIHelper.escapeCoteValue(roundTo)%>' ,'<%=UIHelper.escapeCoteValue(showDecimals)%>',label)},
                        },
                    }]

                    if(mainChart2!=null) mainChart2.destroy();
                    mainChart2 = new Chart($('#main-chart2'), json);
                    $('#main-chart2').closest('.card').find('.text-muted').html(json.subtext);
                    $('#revenueSpinner').hide();
                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                    $('#revenueSpinner').hide();
                }
            });
        }

        function initPromotionDistributionChart(pieOptions){
            $.ajax({
                url : 'calls/getPromotionDistributionChartData.jsp',
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate,
                    catalogType:catalogType
                },
                dataType: 'json',
                success : function(json)
                {

                    if(json.data.datasets[0].data.length==0){
                        $('#promotionDistributionCanvas').closest('.col-sm-6').hide();
                    }
                    else{
                        $('#promotionDistributionCanvas').closest('.col-sm-6').show();
                        json.options.events = pieOptions.events;
                        json.options.animation = pieOptions.animation;
                        if(promotionDistributionChart!=null) promotionDistributionChart.destroy();
                        promotionDistributionChart=new Chart($('#promotionDistributionCanvas'), json);
                    }
                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                }
            });
        }

        function initDeliveryDistributionChart(pieOptions){
            $.ajax({
                url : 'calls/getDeliveryDistributionChartData.jsp',
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate
                },
                dataType: 'json',
                success : function(json)
                {
                    if(json.data.datasets[0].data.length==0){
                        $('#deliveryDistributionCanvas').closest('.col-sm-6').hide();
                    }
                    else{
                        $('#deliveryDistributionCanvas').closest('.col-sm-6').show();
                        json.options.events = pieOptions.events;
                        json.options.animation = pieOptions.animation;
                        if(deliveryDistributionChart!=null) deliveryDistributionChart.destroy();
                        deliveryDistributionChart=new Chart($('#deliveryDistributionCanvas'), json);
                    }
                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                }
            });
        }

        function initDeliveryStoreDistributionChart(pieOptions){
            $.ajax({
                url : 'calls/getDeliveryStoreDistributionChartData.jsp',
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate,
                    catalogType:catalogType
                },
                dataType: 'json',
                success : function(json)
                {
                    if(json.data.datasets[0].data.length==0){
                        $('#deliveryStoreDistributionCanvas').closest('.col-sm-6').hide();
                    }
                    else{
                        $('#deliveryStoreDistributionCanvas').closest('.col-sm-6').show();
                        json.options.events = pieOptions.events;
                        json.options.animation = pieOptions.animation;
                        if(deliveryStoreDistributionChart!=null) deliveryStoreDistributionChart.destroy();
                        deliveryStoreDistributionChart=new Chart($('#deliveryStoreDistributionCanvas'), json);
                    }

                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                }
            });
        }

        function initDeliveryDistributionTypeChart(pieOptions){
            $.ajax({
                url : 'calls/getDeliveryDistributionTypeChartData.jsp',
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate,
                    catalogType:catalogType
                },
                dataType: 'json',
                success : function(json)
                {

                    if(json.data.datasets[0].data.length==0){
                        $('#deliveryDistributionTypeCanvas').closest('.col-sm-6').hide();
                    }
                    else{
                        $('#deliveryDistributionTypeCanvas').closest('.col-sm-6').show();
                        json.options.events = pieOptions.events;
                        json.options.animation = pieOptions.animation;
                        if(deliveryDistributionTypeChart!=null) deliveryDistributionTypeChart.destroy();
                        deliveryDistributionTypeChart=new Chart($('#deliveryDistributionTypeCanvas'), json);
                    }
                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                }
            });
        }

        function initDeliveryPointDistributionChart(pieOptions){
            $.ajax({
                url : 'calls/getDeliveryPointDistributionChartData.jsp',
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate,
                    catalogType:catalogType
                },
                dataType: 'json',
                success : function(json)
                {
                    if(json.data.datasets[0].data.length==0){
                        $('#deliveryPointDistributionCanvas').closest('.col-sm-6').hide();
                    }
                    else{
                        $('#deliveryPointDistributionCanvas').closest('.col-sm-6').show();
                        json.options.events = pieOptions.events;
                        json.options.animation = pieOptions.animation;
                        if(deliveryPointDistributionChart!=null) deliveryPointDistributionChart.destroy();
                        deliveryPointDistributionChart=new Chart($('#deliveryPointDistributionCanvas'), json);
                    }

                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                }
            });
        }


        function initTopSellersChart(){
            $('#sellingSpinner').show();
            $.ajax({
                url : 'calls/getTopSellersChartData.jsp',
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate,
                    catalogType:catalogType
                },
                dataType: 'json',
                success : function(json)
                {
                    var html = "";
                    for(var i=0; i<json.length; i++) html+= topSellersTemplate(json[i]);
                    $("#topSellersChart").html(html);
                    $('#sellingSpinner').hide();
                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                    $('#sellingSpinner').hide();
                }
            });
        }


        function initTopAgentsChart(){
            $('#agentSpinner').show();
            $.ajax({
                url : 'calls/getTopAgentsChartData.jsp',
                type: 'post',
                data: {
                    start: startDate,
                    end: endDate,
                    catalogType:catalogType
                },
                dataType: 'json',
                success : function(json)
                {
                    var html = "";
                    for(var i=0; i<json.length; i++) html+= topAgentsTemplate(json[i]);
                    $("#topAgentsChart").html(html);
                    $('#agentSpinner').hide();
                },
                error : function()
                {
                    console.log("Error while communicating with the server");
                    $('#agentSpinner').hide();
                }
            });
        }

        function initCharts(){

            initFunnelChart();

            for(property in kpiSettings){
                initChartSmallGeneric(kpiSettings[property], property);
            }

            initOrdersAndProductsChart();

            initRevenueChart();

            initTopSellersChart();

            initTopAgentsChart();

            var pieOptions = {
                events: false,
                animation: {
                    duration: 500,
                    easing: "easeOutQuart",
                    onComplete: function () {
                        var ctx = this.chart.ctx;
                        ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontFamily, 'normal', Chart.defaults.global.defaultFontFamily);
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';

                        this.data.datasets.forEach(function (dataset) {

                            for (var i = 0; i < dataset.data.length; i++) {
                                var model = dataset._meta[Object.keys(dataset._meta)[0]].data[i]._model,
                                total = dataset._meta[Object.keys(dataset._meta)[0]].total,
                                mid_radius = model.innerRadius + (model.outerRadius - model.innerRadius)/2,
                                start_angle = model.startAngle,
                                end_angle = model.endAngle,
                                mid_angle = start_angle + (end_angle - start_angle)/2;

                                var x = mid_radius * Math.cos(mid_angle);
                                var y = mid_radius * Math.sin(mid_angle);

                                ctx.fillStyle = '#fff';
                                // if (i == 3){ // Darker text color for lighter background
                                //     ctx.fillStyle = '#444';
                                // }
                                var percent = String(Math.round(dataset.data[i]/total*100)) + "%";
                                ctx.fillText(dataset.data[i], model.x + x, model.y + y);
                                // Display percent in another line, line break doesn't work for fillText
                                ctx.fillText(percent, model.x + x, model.y + y + 15);
                            }
                        });
                    }
                }
            };

            initPromotionDistributionChart(pieOptions);

            initDeliveryDistributionChart(pieOptions);
            
            initDeliveryDistributionTypeChart(pieOptions);

            initDeliveryStoreDistributionChart(pieOptions);

            initDeliveryPointDistributionChart(pieOptions);
        }

        function topSellersTemplate(topSeller) {
            return `<div class="progress-group">
                <div class="progress-group-header">
                    <i class="fa fa-shopping-cart progress-group-icon"></i>
                    <div>`+topSeller.name+`</div>
                    <div class="ml-auto font-weight-bold">`+topSeller.quantity+`</div>
                </div>
                <div class="progress-group-bars">
                    <div class="progress progress-xs">
                        <div class="progress-bar bg-success" role="progressbar" style="width: `+topSeller.width+`%" aria-valuenow="`+topSeller.width+`" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
            </div>
            `;
        }

        function topAgentsTemplate(topAgent) {
            return `<div class="progress-group">
                <div class="progress-group-header">
                    <i class="fa fa-shopping-cart progress-group-icon"></i>
                    <div>`+topAgent.name+`</div>
                    <div class="ml-auto font-weight-bold">`+topAgent.quantity+`</div>
                </div>
                <div class="progress-group-bars">
                    <div class="progress progress-xs">
                        <div class="progress-bar bg-warning" role="progressbar" style="width: `+topAgent.width+`%" aria-valuenow="`+topAgent.width+`" aria-valuemin="0" aria-valuemax="100"></div>
                    </div>
                </div>
            </div>
            `;
        }
        function ValidateEmail(mail)
        {
         if (/^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/.test(mail))
          {
            return (true);
          }
            return (false);
        }
        async function  mailDashboardPdf(){
            $('#emailError').text("");
            $('#subjectError').text("");
            var  emailError = false ;
            var isEmailValide = ValidateEmail($('#email').val().trim());
            if($('#subject').val().trim() === '' || $('#email').val().trim() === '' || isEmailValide  === false){
                if($('#email').val().trim() === '')
                {
                    $('#emailError').text("Email required");
                    $('#email').focus();
                    emailError =true;
                }
                else if(!isEmailValide)
                {
                    $('#emailError').text("Email is not valid");
                    $('#email').focus();
                    emailError =true;
                }
                if($('#subject').val().trim()===''){
                 $('#subjectError').text("Subject required");
                 if(!emailError){
                    $('#subject').focus();
                 }
                }
                return;
            }
            showLoader("");
            var opt = {
                margin:       [0.24, 0],
                filename:     'dashboard.pdf',
                 image:        { type: 'jpeg', quality: 1 },
               //  html2canvas:  { scale: 2 },
                jsPDF:        { unit: 'in', format: 'a3', orientation: 'landscape' }
                };
            var source = window.document.getElementById("main_div");
            $('#exportBar').hide();
            $('.btn-transparent').hide();
            var base64_pdf = await html2pdf().from(source).set(opt).toPdf().output('datauristring');
            $('#exportBar').show();
            $('.btn-transparent').show();
            $('#pdf').val(base64_pdf);
            var form = $('#emailPdfForm');
            var formData = new FormData(form.get(0));
            $.ajax({
            url : 'calls/mailDashboardPdf.jsp',
            type: 'post',
            data : formData,
            cache : false,
            contentType: false,
            processData: false,
            success : function(json)
            {
                console.log("success");
            },
            error : function()
            {
                alert("error");
            }
            });
            hideLoader();
            $('#emailError').text("");
            $('#subjectError').text("");
            $('#email').val("");
            $('#subject').val("");
            $('#message').val("");
            $('#emailModal').modal('toggle');

        }


        function exportData(){
            $.ajax({
                url : 'calls/generate_dashboard_excel.jsp',
                type: 'POST',
                data:  {
                        dateSpan:$('.reportrange span').html(),
                        start:startDate,
                        end: endDate,
                        catalogType:catalogType,
                      },
                success : function(filename)
                {
                    if(filename.trim().length>0)
                        window.location = 'calls/download_dashboard_excel.jsp?filename='+filename.trim();
                    else
                        alert("fail");
                },
                error : function()
                {
                    alert("fail");
                }
            });
        }

        async function downloadPdf(){
            showLoader();
            $('#exportBar').hide();
            $('.btn-transparent').hide();
            var opt = {
                margin:       [0.24, 0],
                filename:     'dashboard.pdf',
                 image:        { type: 'jpeg', quality: 1 },
               //  html2canvas:  { scale: 2 },
                jsPDF:        { unit: 'in', format: 'a3', orientation: 'landscape' }
                };
            var source = window.document.getElementById("main_div");
            var pdf = await html2pdf().from(source).set(opt).save();
            $('#exportBar').show();
            $('.btn-transparent').show();
            hideLoader();
        }

        function saveKPI(){
            kpiSettings[selectedKpi].kpi = $("#edit_kpi").val();
            kpiSettings[selectedKpi].label = $("#edit_label").val();
            kpiSettings[selectedKpi].graphType = $("#edit_graph_type").val();
            kpiSettings[selectedKpi].graphColor = $("#edit_graph_color").val();
            initChartSmallGeneric(kpiSettings[selectedKpi], selectedKpi);
            $('#editKpiDialog').modal('toggle');
        }

        function editKPI(element){
            selectedKpi = $(element).closest('.card').find('canvas').attr("id");
            var chartSetting = kpiSettings[selectedKpi];
            $("#edit_kpi").val(chartSetting.kpi);
            $("#edit_label").val(chartSetting.label);
            $("#edit_graph_type").val(chartSetting.graphType);
            $("#edit_graph_color").val(chartSetting.graphColor);

        }
       function showLoader(msg, ele){

        if(typeof ele === "undefined") ele = $('body');

        ele.addClass('loading2');

        $(ele).find('div.loading2msg').remove();
        var msgEle = $('<div>').addClass('loading2msg');
        $(ele).append(msgEle);

        if(typeof msg !== 'undefined'){
            msgEle.html(msg);
        }
        else{
            msgEle.html("");
        }

    }

    function hideLoader(){
        $('.loading2').removeClass('loading2');
    }
    </script>
</body>
</html>