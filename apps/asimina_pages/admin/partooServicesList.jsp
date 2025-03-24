<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.*, com.etn.pages.*,org.json.JSONObject" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp"%>

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
                <h1 class="h2">Services</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <button type='button' class='btn btn-primary mr-2' onclick="window.location.href='<%=request.getContextPath()%>/admin/stores.jsp';">
                        Back
                    </button>
                    <button type='button' class='btn btn-success mr-2' onclick="window.location.href='<%=request.getContextPath()%>/admin/partooServices.jsp';">
                        Add Services
                    </button>
                </div>
            </div>
            <div class="row">
                <div class="col">
                    <table class="table table-hover table-vam" id="servicesTable" style="width:100%;">
                        <thead class="thead-dark">
                        <tr>
                            <th scope="col">Category</th>
                            <th scope="col">Service</th>
                            <th scope="col">Price</th>
                            <th scope="col">Description</th>
                            <th scope="col">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                            <%
                                String siteId=parseNull((String)session.getAttribute("SELECTED_SITE_ID"));
                                Set rs = Etn.execute("select * from partoo_services where to_delete=0 and site_id="+escape.cote(siteId));
                                while(rs.next()){
                            %>
                            <tr>
                                <td>
                                    <%=parseNull(rs.value("category"))%>
                                </td>
                                <td>
                                    <%=parseNull(rs.value("service_name"))%>
                                </td>
                                <td>
                                    <%=parseNull(rs.value("price"))%>
                                </td>
                                <td>
                                    <%=parseNull(rs.value("description"))%>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-danger btn-sm ml-2 mt-1" style="height:30px;" title="Delete Service" onclick='removeService("<%=parseNull(rs.value("id"))%>")'>
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

        </main>

    <%@ include file="/WEB-INF/include/footer.jsp" %>
</div>


<script type="text/javascript">

    $('#servicesTable').DataTable({
        responsive: true,
        filter: true,
        "searching": true,
        order : [[0,'asc']],
        lengthMenu: [100,250,375,500],
        pageLength : 100,
    });

    function removeService(id){

        $.ajax({
            url:"partooServicesAjax.jsp",
            type:"get",
            dataType:"json",
            data:{
                "id":id,
                "requestType":"removeService"
            },
        }).done(function (resp) {
            alert(resp.message);
            window.location.reload();
        });
        
    }

</script>
</body>
</html> 