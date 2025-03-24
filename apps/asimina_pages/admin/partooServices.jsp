<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.*, com.etn.pages.*,org.json.JSONObject" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp"%>

<%
    String siteId=parseNull((String)session.getAttribute("SELECTED_SITE_ID"));
    String catalogDb = parseNull(GlobalParm.getParm("CATALOG_DB"));

    String[] categories = request.getParameterValues("category");
    if(categories!=null) {
        for(int i=0;i<categories.length;i++){
            
            String category=parseNull(categories[i]);
            Set rsCat = Etn.execute("select * from "+catalogDb+".tags where label="+escape.cote(category)+" and label like '%gcid:%'");
            
            if(category.length()>0 && rsCat.next()){
                String[] services =request.getParameterValues("service"+(i+1));
                String[] prices =request.getParameterValues("price"+(i+1));
                String[] descriptions =request.getParameterValues("description"+(i+1));
                for(int j=0;j<services.length;j++){
                    String service = parseNull(services[j]);
                    if(service.length()>0){
                        String description = parseNull(descriptions[j]);
                        Double price = 0.0;
                        if(parseNull(prices[j]).length()>0){
                            price=Double.parseDouble(prices[j]);
                        }

                        int pid=Etn.executeCmd("insert into partoo_services (category,service_name,price,description, site_id, created_by, updated_by) values ("+
                            escape.cote(category)+","+escape.cote(service)+","+price+","+escape.cote(description)+
                            ", "+escape.cote(siteId)+","+escape.cote(""+Etn.getId())+","+escape.cote(""+Etn.getId())+
                            ") on duplicate key update price=values(price),description=values(description), updated_by=values(updated_by)");
                    

                        Set rs= Etn.execute("SELECT partoo_id FROM partoo_contents WHERE ctype='store' and rjson LIKE "+escape.cote('%'+category+'%')+" and site_id="+escape.cote(siteId));
                        while(rs.next()){
                            String partooId = parseNull(rs.value(0));
                            if(partooId.length()>0){
                                JSONObject obj = new JSONObject();

                                Set rsService = Etn.execute("select * from partoo_services_details where partoo_id="+escape.cote(partooId)+" and category="+
                                    escape.cote(category)+" and site_id="+escape.cote(siteId)+"and service_name="+escape.cote(service));

                                if(rsService.next() && rsService.rs.Rows>0){
                                    obj.put("service_id",parseNull(rsService.value("service_id")));
                                }
                                obj.put("category_gmb_name",category);
                                obj.put("name",parseNull(services[j]));
                                obj.put("price",price);
                                obj.put("description",parseNull(descriptions[j]));

                                Set rs2 = Etn.execute("select * from partoo_services_work where method='post' and status != 'success' and services_id="+escape.cote(""+pid));
                                System.out.println(obj.toString());
                                System.out.println(PagesUtil.escapeCote(obj.toString()));
                                
                                if(rs2.rs.Rows>0){
                                    Etn.executeCmd("update partoo_services_work set request_json="+PagesUtil.escapeCote(obj.toString())+"where method='post' and status != 'success' and services_id="+escape.cote(""+pid));
                                }else{
                                    Etn.executeCmd("insert into partoo_services_work (services_id,partoo_id,method,request_json,site_id) values ("+escape.cote(""+pid)+","
                                    +escape.cote(partooId)+",'post',"+PagesUtil.escapeCote(obj.toString())+","+escape.cote(siteId)+")");
                                }
                            }
                        }
                    }
                }
            }
        } 
        Etn.execute("SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("PARTOO_SEMAPHORE"))) + ")");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp" %>
    <title>Services</title>

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
                <h1 class="h2">Add services for categories</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type="button" class="btn btn-success mr-2"onclick="addNewRow();">Add category</button>
                    <button type='button' class='btn btn-primary mr-2' onclick="$('#serviceForm').submit()">Save</button>
                    <button type='button' class='btn btn-primary mr-2' onclick="window.location.href='<%=request.getContextPath()%>/admin/partooServicesList.jsp';">
                        Back
                    </button>
                </div>
            </div>

            <div class="row">
                <div class="col">
                    <form id='serviceForm' method='post' action='<%=request.getContextPath()%>/admin/partooServices.jsp'>
                        <table class="table table-hover table-vam" id="servicesTable" style="width:100%;">
                            <thead class="thead-dark">
                            <tr>
                                <th scope="col">Category</th>
                                <th scope="col">Services</th>
                                <th scope="col">Price</th>
                                <th scope="col">Description</th>
                                <th scope="col">Actions</th>
                            </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </form>
                </div>
            </div><!-- row-->

        </main>

    <%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<script type="text/javascript">

    $(function () {
        addNewRow();
    });

    function addNewRow(){
        
        let table = document.getElementById("servicesTable");
        
        let rowsInTable = table.rows.length;
        let row = table.insertRow(rowsInTable);
        
        addNewCol(rowsInTable,true);
    }
    function addNewCol(rowNum,check){
        let row = document.getElementById("servicesTable").rows[rowNum];


        for(let i=0; i<5;i++){
            
            let inputNum = $("tr:nth-child("+(rowNum+1)+") td:nth-child("+(i+1)+") input").length+1;
            
            let cellHtml = ["<div><input class='form-control' type='text' name ='category' list='datalist"+rowNum+"' onKeyUp='showResults(this.value,\"datalist"+rowNum+"\")' style ='width:200px'><datalist  id='datalist"+rowNum+"'></datalist ></div>",
            "<div><input id='input"+rowNum+"Col"+(i+1)+"Line"+inputNum+"' type='text' onblur='checkService(this)' class='form-control' name ='service"+rowNum+"' style ='width:200px;margin-top:2px;'></div>",
            "<input id='input"+rowNum+"Col"+(i+1)+"Line"+inputNum+"' type='text' class='form-control flex-grow-1' name ='price"+rowNum+"' style ='width:80px;margin-top:2px;'>",
            "<input type='text' class='form-control' maxlength='300' name ='description"+rowNum+"' style ='width:300px;margin-top:2px;'>",
            "<button type='button' class='btn btn-success mr-2' onclick='addNewCol("+rowNum+",false)'>Add service</button>"];

            let htmlString=cellHtml[i];

            if(i==3){
                let icon = '<button type="button" class="btn btn-danger btn-sm ml-2 mt-1" style="height:30px;" onclick="removeService('+rowNum+','+inputNum+')">'+
                '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-x">'+
                '<line x1="18" y1="6" x2="6" y2="18"></line>'+
                '<line x1="6" y1="6" x2="18" y2="18"></line>'+
                '</svg>'+
                '</button>';

                htmlString="<div id='input"+rowNum+"Col"+(i+1)+"Line"+inputNum+"' class='d-flex'>"+htmlString+icon+"</div>";
            }

            if((i>0 && i<4) && row.cells[i]){
                $("tr:nth-child("+(rowNum+1)+") td:nth-child("+(i+1)+")").append(htmlString);
            }else{
                if(check){
                    let cell = row.insertCell(i);
                    if(i==2){
                        cell.setAttribute("style","width:100px;border:1px solid #D9DDDC;");
                    }else if(i==0||i==1||i==4){
                        cell.setAttribute("style","width:220px;border:1px solid #D9DDDC;");
                    }else{
                        cell.setAttribute("style","width:320px;border:1px solid #D9DDDC;");
                    }
                    cell.innerHTML = htmlString;
                }
            }
        }
        
    }
    function removeService(rowNum,inputNum){
        for(let i=2;i<5;i++){
            let inputLength = $("tr:nth-child("+(rowNum+1)+") td:nth-child("+(i)+") input").length;
            if(inputLength>1){
                $("#input"+rowNum+"Col"+i+"Line"+inputNum).remove();
            }
            
        }
    }

    function checkService(e){
        let category = $($($($(e).parent()).parent().siblings()[0]).children()[0]).children()[0].value;
        let service = e.value;

        $.ajax({
            url:"partooServicesAjax.jsp",
            type:"GET",
            dataType:"json",
            data:{
                "category":category,
                "service":service,
                "requestType":"checkService"
            },
        }).done(function (resp) {
            if(resp.status=="true" && resp.services>0 && $(e).parent().children().length==1){
                $(e).parent().append("<div style='font-size: 11px;color:red;'>Service exist and willl be updated.<div>");
            }
        });
    }

    function showResults(value,id){
        
        if(value.length>3){
            
            $.ajax({
                url:"partooServicesAjax.jsp",
                type:"GET",
                dataType:"json",
                data:{
                    "value":value,
                    "requestType":"autocomplete"
                },
            }).done(function (resp) {
                if(resp.status=="true"){
                    res = document.getElementById(id);
                    res.innerHTML="";
                    let list='';
                    for(let i=0;i<resp.data.length;i++){
                        var option = document.createElement('option');
                        option.value = resp.data[i].label;
                        res.appendChild(option);
                    }
                }
            });
        }
    }

</script>
</body>
</html>