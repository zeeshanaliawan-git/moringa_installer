<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%
    //response.sendRedirect(request.getContextPath()+"/admin/pages.jsp");

    String pageId = parseNull(request.getParameter("id"));

%>
<!doctype html>
<html lang="en">
    <head>
        <title>Grid Designer</title>
        <meta charset="utf8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"
            integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">

        <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"
            integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo"
            crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"
            integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1"
            crossorigin="anonymous"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"
            integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM"
            crossorigin="anonymous"></script>

    </head>
    <body>

        <div id="root"></div>

        <form name="hiddenform" action="" onsubmit="return false">
            <input type="hidden" id="pageId" name="pageId" value="<%=pageId%>" />
        </form>
    </body>
    <script type="text/javascript" src="dist/grid-designer.bundle.js?random=1%>"></script>
    <style>
        .grid-designer-title-row,.grid-designer-btn-row{
            display:none !important;
        }
    </style>
    <script type="text/javascript">

    </script>
</html>