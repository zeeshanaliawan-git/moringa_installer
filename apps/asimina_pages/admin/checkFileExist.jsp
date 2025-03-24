<%@ page trimDirectiveWhitespaces="true" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.pages.EntityExport, com.etn.sql.escape, java.util.*,
 com.etn.pages.excel.ExcelEntityExport, org.apache.poi.ss.usermodel.Workbook" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp" %>
<%
    String fileName = parseNull(request.getParameter("file_name"));
    String path = parseNull(request.getParameter("path"));
    
    if(path.length() == 0){
        path=GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("UPLOADS_FOLDER")+getSiteId(session)+"/"+fileName;
    }else{
        path=path+fileName;
    }

    File myObj = new File(path);
    if(myObj.exists()){
        System.out.println("==========File Exists==========");
        out.write("{\"status\":\"true\"}");
    }else{
        System.out.println("==========File No Exists==========");
        out.write("{\"status\":\"false\"}");
    }

%>