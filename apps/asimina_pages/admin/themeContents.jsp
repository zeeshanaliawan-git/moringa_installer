<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>

<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp"%>
<%
     String themeUuid = parseNull(request.getParameter("id"));
     String title = "";
     String q = "SELECT * FROM themes WHERE site_id = "+escape.cote(getSiteId(session))+" AND uuid = "+escape.cote(themeUuid);
     Set rs =  Etn.execute(q);
     String themeId = "";
     if(rs.next()){
          title = "Content of theme : "+rs.value("name")+" V"+rs.value("version");
          themeId = rs.value("id");
     } else{
         response.sendRedirect("themes.jsp");
     }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="../WEB-INF/include/head2.jsp" %>
    <title>Theme Content</title>
    <style type="text/css">
        .bg-published .deleteBtn, .bg-changed .deleteBtn {
            display: none !important;
        }

        .bg-unpublished .unpublishBtn {
            display: none !important;
        }
    </style>
</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%
        breadcrumbs.add(new String[]{"Themes","themes.jsp"});
        breadcrumbs.add(new String[]{rs.value("name")+" V"+rs.value("version"),""});
    %>
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
        <!-- beginning of container -->
             <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Theme Contents</h1>
                 <div class="btn-toolbar mb-2 mb-md-0">
                    <div class="col-12">
                        <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-2 border-bottom">
                            <div class="btn-toolbar mb-2 mb-md-0">
                                <a type="button" href="themes.jsp" class="btn btn-primary mr-2"
                                        >Back
                                </a>
                            </div>
                        </div>
                    </div>
                </div><!-- row -->
            </div>
            <div class="row">
                <div class="col">
                    <table class="table table-hover table-vam" id="themesTable" style="width:100%;">
                        <thead class="thead-dark">
                        <tr>
                            <th scope="col">Type of Content</th>
                            <th scope="col">Nb Items</th>
                            <th scope="col">Last Changes</th>
                            <th scope="col">Actions</th>
                        </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                    <div id="actionsCellTemplateThemeContent" class="d-none">
                        <button class="btn btn-sm btn-success sycBtn" title="Sync"
                                onclick="syncThemeContent('#THEME_CONTENT#')">
                            <i data-feather="refresh-cw"></i>
                        </button>
                        <a class="btn btn-sm btn-primary"
                           title="list"
                           href="themeContentData.jsp?themeId=<%=escapeCoteValue(themeUuid)%>&content=#THEME_CONTENT#">
                            <i data-feather="list"></i>
                        </a>
                    </div>

                </div>
            </div><!-- row-->

        </div>
        <!-- container -->
        <!-- /end of container -->
    </main>
    <%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<script type="text/javascript">
    // ready function
    $(function () {
        $ch.themeId = '<%=themeId%>';
        initThemeTable();

    });
    function initThemeTable() {

        window.themesTable = $('#themesTable')
        .DataTable({
            responsive: true,
            pageLength: 100,
            ajax: function (data, callback, settings) {
                getThemeContents(data, callback, settings);
            },
            order: [[0, 'asc']],
            columns: [
                {"data": "name", className: "name", className: "text-capitalize"},
                {"data": "nb_items"},
                {"data": "last_modified"},
                {"data": "actions", className: "dt-body-right text-nowrap"},
        ],
            columnDefs: [
                {targets: [-1], searchable: false},
                {targets: [-1], orderable: false},
                {
                    targets: [-2],
                    render: function (data, type, row) {
                        if (type == 'sort' && data.trim().length > 0) {
                            return getMoment(data).unix();
                        }else{
                           return data;
                        }
                    }
                },
            ],
            select: {
                style: 'multi',
                className: '',
                selector: 'td.noselector' //dummyselector
            },
        })
    }

    function getThemeContents(data, callback, settings) {

        showLoader();
        $.ajax({
            url: 'themesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                id: $ch.themeId,
                requestType: 'getThemeContents',
            },
        })
        .done(function (resp) {
            var data = [];
            if (resp.status == 1) {
                data = resp.data.themeContents;
                var actionsCellEle =  $('#actionsCellTemplateThemeContent');
                $.each(data, function (index, val) {
                    if(val.syncRequired){
                        actionsCellEle.find(".sycBtn").show();
                    } else {
                        actionsCellEle.find(".sycBtn").hide();
                    }
                    val.actions = strReplaceAll(actionsCellEle.html(), "#THEME_CONTENT#", val.name);
                });
            }
            callback({"data": data});
        })
        .fail(function () {
            callback({"data": []});
        })
        .always(function () {
            hideLoader();
        });

    }

    function syncThemeContent(themeContent) {
        showLoader();
        $.ajax({
            url: 'themesAjax.jsp', type: 'POST', dataType: 'json',
            data: {
                requestType : 'syncThemeContent',
                themeId: $ch.themeId,
                themeContent : themeContent,
            },
        })
        .done(function(resp) {
            if(resp.status === 1){
                bootNotify(resp.message);
                refreshDataTable();
            }
            else{
                bootNotifyError(resp.message);
            }
        })
        .fail(function() {
            bootNotifyError("Error in contacting server. please try again.");
        })
        .always(function() {
            hideLoader();
        });
    }

    function refreshDataTable() {
        window.themesTable.ajax.reload(function () {
            $('#checkAll').triggerHandler('change');
        }, false);
    }

</script>
</body>
</html>