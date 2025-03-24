<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.asimina.util.UIHelper, com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.time.*, java.time.format.DateTimeFormatter, java.io.*, com.etn.beans.app.GlobalParm"%>
<%@ include file="/common2.jsp" %>

<%
    String siteId = parseNull((String)session.getAttribute("SELECTED_SITE_ID"));
    String catalogDb = parseNull(GlobalParm.getParm("CATALOG_DB"))+".";
    String pagesDb = parseNull(GlobalParm.getParm("PAGES_DB"))+".";
    String commonDb = parseNull(GlobalParm.getParm("COMMONS_DB"))+".";

    int langId=0;
    String filterId = parseNull(request.getParameter("filterId"));
    String[] filterTypes=request.getParameterValues("filter1");
    String[] filtersOn=request.getParameterValues("filter_on1");

    if(filterId.length()>0) {
        for(int j=0;j<filterTypes.length;j++){
            if(parseNull(filterTypes[j]).length()>0 && parseNull(filtersOn[j]).length()>0){
                Etn.executeCmd("insert into dashboard_filters_items (filter_id,filter_type,filter_on,site_id,created_by) values("+escape.cote(filterId)+
                    ","+escape.cote(filterTypes[j])+","+escape.cote(filtersOn[j])+","+escape.cote(siteId)+","+escape.cote(""+Etn.getId())+")");
            }
        }   
    }
    
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">

    <title>Dashboard Filters</title>

    <link href="<%=request.getContextPath()%>/css/coreui-icons.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/font-awesome.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/simple-line-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/coreui.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/my.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/moringa-cui.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/jquery-ui.min.css" rel="stylesheet">

    <script src="<%=request.getContextPath()%>/js/jquery.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/jquery-ui.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/popper.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/bootstrap.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/coreui.min.js"></script>
        <!-- DataTables -->
    <link href="<%=request.getContextPath()%>/css/datatables.min.css" rel="stylesheet">
    <script src="<%=request.getContextPath()%>/js/jquery.dataTables.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/datatables.min.js"></script>
    <script src="<%=request.getContextPath()%>/js/feather.min.js?v=2.28.0"></script>


    <style type="text/css">
        .table-success .deleteBtn, .table-warning .deleteBtn {
            display: none !important;
        }

        .table-danger .unpublishBtn {
            display: none !important;
        }
        .dataTables_length select {
              min-width: 75px !important;
        }

    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Dashboard Filters</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type='button' class='btn btn-success mr-2' onclick="$('#modalAddFilter').modal('show');">
                        Add Filters
                    </button>
                </div>
            </div>
            <div class="row">
                <div class="col">
                    <table class="table table-hover table-vam" id="dashboardFiltersTable" style="width:100%;">
                        <thead class="thead-dark">
                        <tr>
                            <th scope="col">Filter Name</th>
                            <th scope="col">Filter Type</th>
                            <th scope="col">Filter on</th>
                            <th scope="col">Action</th>
                        </tr>
                        </thead>
                        <tbody>
                            <%
                                Set rsLang = Etn.execute("select langue_id from "+commonDb+"sites_langs where site_id="+escape.cote(siteId)+" order by langue_id limit 1");
                                if(rsLang.next()){
                                    langId=Integer.parseInt(parseNull(rsLang.value("langue_id")));
                                }

                                String query = "SELECT slfc.id, "+
                                    "CASE "+
                                        "WHEN slfc.filter_type = 'structuredcatalog' THEN 'Stores / Structured Pages' "+
                                        "WHEN slfc.filter_type = 'product' THEN 'Product' "+
                                        "WHEN slfc.filter_type = 'commercialcatalog' THEN 'Catalog' "+
                                        "WHEN slfc.filter_type = 'page' THEN 'Page' "+
                                        "ELSE NULL "+
                                    "END AS filter_type, "+
                                    "CASE "+
                                        "WHEN slfc.filter_type = 'structuredcatalog' THEN sc.name "+
                                        "WHEN slfc.filter_type = 'product' THEN lang_"+langId+"_name "+
                                        "WHEN slfc.filter_type = 'commercialcatalog' THEN c.name "+
                                        "WHEN slfc.filter_type = 'page' THEN fp.name "+
                                        "ELSE NULL "+
                                    "END AS filter_on_name "+
                                "FROM dashboard_filters_items AS slfc "+
                                "LEFT JOIN "+pagesDb+"structured_contents AS sc ON slfc.filter_type = 'structuredcatalog' AND slfc.filter_on = sc.id "+
                                "LEFT JOIN "+catalogDb+"products AS p ON slfc.filter_type = 'product' AND slfc.filter_on = p.id "+
                                "LEFT JOIN "+catalogDb+"catalogs AS c ON slfc.filter_type = 'commercialcatalog' AND slfc.filter_on = c.id "+
                                "LEFT JOIN "+pagesDb+"freemarker_pages AS fp ON slfc.filter_type = 'page' AND slfc.filter_on = fp.id ";

                                Set rs = Etn.execute("select * from dashboard_filters where site_id="+escape.cote(siteId));
                                while(rs.next()){
                            %>
                                    <tr>
                                        <td>
                                            <%=UIHelper.escapeCoteValue(parseNull(rs.value("filter_name")))%>
                                        </td>

                                        <%  
                                            Set rsFilters = Etn.execute(query+" where slfc.filter_id="+escape.cote(parseNull(rs.value("id"))));
                                        %>
                                        <td>
                                            <div class="list-group">    
                                            <%
                                                while(rsFilters.next()){
                                            %>
                                                <div class="border-0 d-flex justify-content-between list-group-item pt-0"><span><%=parseNull(rsFilters.value("filter_type"))%></span></div>
                                            <%}%>
                                            </div>
                                        </td>

                                        <td>
                                            <div class="list-group rounded-0">    
                                            <%
                                                rsFilters.moveFirst();
                                                while(rsFilters.next()){
                                            %>
                                                <div class="border-0 d-flex justify-content-between list-group-item pt-0">
                                                    <span><%=parseNull(rsFilters.value("filter_on_name"))%></span>
                                                    <button type="button" class="btn btn-link btn-sm py-0 text-danger" title="Remove Item" 
                                                        style="line-height:100%"
                                                        onclick='removeFilterItem("<%=parseNull(rsFilters.value("id"))%>","")'>
                                                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-x">
                                                            <line x1="18" y1="6" x2="6" y2="18"></line>
                                                            <line x1="6" y1="6" x2="18" y2="18"></line>
                                                        </svg>
                                                    </button>
                                                </div>
                                            <%}%>
                                            </div>
                                        </td>
                                        <td>
                                            <button type="button" class="btn btn-primary btn-sm ml-2 mt-1" style="height:30px;" title="Add Filter Items" 
                                                onclick='editFilter("<%=parseNull(rs.value("id"))%>","<%=parseNull(rs.value("filter_name"))%>")'>
                                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-edit">
                                                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                                </svg>
                                            </button>

                                            <button type="button" class="btn btn-danger btn-sm ml-2 mt-1" style="height:30px;" title="Remove Filter" 
                                                onclick='removeFilterItem("","<%=parseNull(rs.value("id"))%>")'>
                                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-x">
                                                    <line x1="18" y1="6" x2="6" y2="18"></line>
                                                    <line x1="6" y1="6" x2="18" y2="18"></line>
                                                </svg>
                                            </button>
                                        </td>
                                    </tr> 

                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div><!-- row-->

<%-- ------------------------Add Filter Modal----------------------------- --%>
            <div class="modal fade" id="modalAddFilter" tabindex="-1" role="dialog" data-backdrop="static">
                <div class="modal-dialog modal-dialog-slideout" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Add new Filter</h5>
                            <div class="text-right">
                            
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                        </div>
                        <div class="modal-body">
                            <div class="text-right mb-3">
                                <button type="button" class="btn btn-primary" onclick="saveFilter()">Save</button>
                            </div>
                            <div class="form-group row mt-4">
                                <label class="col-sm-3 col-form-label">Name</label>
                                <div class="col-sm-9">
                                    <input type="text" class="form-control" id="filterName" onBlur="document.getElementById('filterName2').value=document.getElementById('filterName').value;" value="" maxlength="100" required="required">
                                    <div class="invalid-feedback">Cannot be empty.</div>
                                </div>
                            </div>

                            <div class="form-group row mt-4">
                                <label class="col-sm-3 col-form-label">Filter</label>
                                <div class="col-sm-9">
                                    <input type="text" disabled class="form-control" id="filterName2" value="" maxlength="100">
                                </div>
                            </div>

                        </div>
                        
                    </div><!-- /.modal-content -->
                </div><!-- /.modal-dialog -->
            </div>


<%-- ------------------------Add Filter Items Modal----------------------------- --%>
            <div class="modal fade" id="modalAddFilterItems" tabindex="-1" role="dialog" data-backdrop="static">
                <div class="modal-dialog modal-dialog-slideout modal-xl" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title filterTitle"><%-- Dynamic Heading --%></h5>
                            <div class="text-right">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                    <span aria-hidden="true">&times;</span>
                                </button>
                            </div>
                        </div>
                        <div class="modal-body">
                            <div class="text-right mb-3">
                                <button type="button" class="btn btn-primary" onclick="$('#dashboardFiltersForm').submit()">Save</button>
                            </div>
                            <form id='dashboardFiltersForm' method='post' action='<%=request.getContextPath()%>/dashboard/dashboardFiltersList.jsp'>
                                <input hidden id='filterId' name='filterId'>
                                <table class="table table-hover table-vam" id="dashboardFiltersItemsTable" style="width:100%;">
                                    <thead class="thead-dark">
                                    <tr>
                                        <th scope="col">Filter type</th>
                                        <th scope="col">Search Items</th>
                                        <th scope="col">Action</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </form>

                        </div>
                        
                    </div><!-- /.modal-content -->
                </div><!-- /.modal-dialog -->
            </div>

        </main>

    <%@ include file="/WEB-INF/include/footer.jsp" %>
</div>


<script type="text/javascript">

    $('#dashboardFiltersTable').DataTable({
        responsive: true,
        filter: true,
        "searching": true,
        order : [[0,'asc']],
        lengthMenu: [100,250,375,500],
        pageLength : 100,
    });

    function openAddEditModal(id) {
        $('#modalAddFilter').modal('show');
        
    }

    function editFilter(id,name){
        $("#dashboardFiltersItemsTable tr:not(:first)").remove();
        $('#modalAddFilterItems').modal('show');
        $('.filterTitle').text('Apply filter on: '+name);
        $('#filterId').val(id);
        addNewRow();
    }

    function addNewRow(){
        
        let table = document.getElementById("dashboardFiltersItemsTable");
        
        let rowsInTable = table.rows.length;
        let row = table.insertRow(rowsInTable);
        
        addNewCol(rowsInTable,true);
    }

    function addNewCol(rowNum,check){
        let row = document.getElementById("dashboardFiltersItemsTable").rows[rowNum];

        let inputNum = 0;
        for(let i=0; i<3;i++){
            
            if(i==0){
                inputNum = $("#dashboardFiltersItemsTable tr:nth-child("+(rowNum+1)+") td:nth-child("+(i+1)+") select").length+1;
            }else{
                inputNum = $("#dashboardFiltersItemsTable tr:nth-child("+(rowNum+1)+") td:nth-child("+(i+1)+") input:not(:hidden)").length+1;
            }

            let cellHtml = ["<div><select id='select"+rowNum+"Line"+inputNum+"' name ='filter"+rowNum+"' class='form-control' style ='width:220px;margin-top:2px;'><option  value=''>-------- --------</option><option value='product'>Products</option><option value='page'>Pages</option><option value='structuredcatalog'>Stores / Structured Pages</option><option value='commercialcatalog'>Catalogs</option></select></div>",
            "<div><input hidden id='filter_on"+rowNum+"Line"+inputNum+"' name='filter_on"+rowNum+"'><input autocomplete='off' type='text' placeholder='Search' list='datalist"+rowNum+
            "Line"+inputNum+"' onKeyUp='showResults(this.value,\"select"+rowNum+"Line"+inputNum+"\",\"datalist"+rowNum+"Line"+inputNum+
            "\",\"filter_on"+rowNum+"Line"+inputNum+"\")' class='form-control' maxlength='100' id='filter_tmp"+rowNum+"Line"+inputNum+"' style ='width:220;margin-top:2px;'><select onchange='updateItem(\"filter_on"+
            rowNum+"Line"+inputNum+"\",\"filter_tmp"+rowNum+"Line"+inputNum+"\",\"datalist"+rowNum+"Line"+inputNum+"\")' class='form-control' hidden=true id='datalist"+rowNum+"Line"+inputNum+"'></select ></div>",
            "<button type='button' class='btn btn-success mr-2' onclick='addNewCol("+rowNum+",false)'>Add filter</button>"];

            let htmlString=cellHtml[i];

            if(i==1){
                let icon = '<button type="button" class="btn btn-danger btn-sm ml-2 mt-1" style="height:30px;" onclick="removefilter('+rowNum+','+inputNum+')">'+
                '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-x">'+
                '<line x1="18" y1="6" x2="6" y2="18"></line>'+
                '<line x1="6" y1="6" x2="18" y2="18"></line>'+
                '</svg>'+
                '</button>';

                htmlString="<div id='input"+rowNum+"Col"+(i+1)+"Line"+inputNum+"' class='d-flex'>"+htmlString+icon+"</div>";
            }

            if((i==0 || i==1) && row.cells[i]){
                $("#dashboardFiltersItemsTable tr:nth-child("+(rowNum+1)+") td:nth-child("+(i+1)+")").append(htmlString);
            }else{
                if(check){
                    let cell = row.insertCell(i);
                    if(i==0 || i==1){
                        cell.setAttribute("style","width:220;border:1px solid #D9DDDC;");
                    }else{
                        cell.setAttribute("style","width:180px;border:1px solid #D9DDDC;");
                    }
                    cell.innerHTML = htmlString;
                }
            }
        }
        
    }

    function removefilter(rowNum,inputNum){
        for(let i=1;i<3;i++){
            let inputLength = $("#dashboardFiltersItemsTable tr:nth-child("+(rowNum+1)+") td:nth-child("+(i)+") input:not(:hidden)").length;
            if(inputLength>1){
                $("#input"+rowNum+"Col"+i+"Line"+inputNum).remove();
            }else{
                inputLength = $("#dashboardFiltersItemsTable tr:nth-child("+(rowNum+1)+") td:nth-child("+(i)+") select").length;
                if(inputLength>1){
                    $("#select"+rowNum+"Line"+inputNum).remove();
                }
            }
            
            
        }
    }

    function removeFilterItem(itemId,filterId){
        $.ajax({
            url:"dashboardFiltersAjax.jsp",
            type:"get",
            dataType:"json",
            data:{
                "itemId":itemId,
                "filterId":filterId,
                "requestType":"removeFilter"
            },
        }).done(function (resp) {
            window.location.reload();
        });
    }

    function saveFilter(){
        let filterName = document.getElementById("filterName").value;
        $.ajax({
            url:"dashboardFiltersAjax.jsp",
            type:"get",
            dataType:"json",
            data:{
                "name":filterName,
                "requestType":"addFilter"
            },
        }).done(function (resp) {
            window.location.reload();
            // alert(resp.message);
            // document.getElementById("filterName").value = "";
            // document.getElementById("filterName2").value ="";
            // $('#dashboardFiltersTable').DataTable().ajax.reload();
        });
    }

    function showResults(value,filterTypeid,eleId,hiddenInput){
        document.getElementById(hiddenInput).value="";
        if(value.length>3){

            let filterType = document.getElementById(filterTypeid).value;
            if(filterType.length>0){
                $.ajax({
                    url:"dashboardFiltersAjax.jsp",
                    type:"GET",
                    dataType:"json",
                    data:{
                        "value":value,
                        "filterType": filterType,
                        "requestType":"autocomplete",
                    },
                }).done(function (resp) {
                    if(resp.status=="true"){
                        let res = document.getElementById(eleId);
                        res.hidden=false;
                        res.innerHTML="";
                        let list='';
                        
                        var option1 = document.createElement('option');
                        option1.value = "";
                        option1.textContent = "-------- --------";
                        res.appendChild(option1);

                        for(let i=0;i<resp.data.length;i++){
                            var option = document.createElement('option');
                            option.value = resp.data[i].id;
                            option.textContent = resp.data[i].name;
                            res.appendChild(option);
                        }
                    }
                });
            }
        }else{
            document.getElementById(eleId).hidden=true;
            document.getElementById(eleId).innerHTML="";
        }
    }

    function updateItem(inputId,InputName,selectId){
        var selectElement = document.getElementById(selectId);
        var selectedOption = selectElement.options[selectElement.selectedIndex];
        var selectedText = selectedOption.textContent;

        selectElement.hidden=true;

        document.getElementById(InputName).value=selectedOption.textContent;
        document.getElementById(inputId).value=selectedOption.value;
    }

</script>
</body>
</html> 