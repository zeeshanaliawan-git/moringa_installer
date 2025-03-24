<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set,org.json.JSONObject,com.etn.asimina.util.FileUtil"%>
<%@ page import="org.apache.commons.fileupload.FileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%
    try {
        JSONObject rspObj=new JSONObject();
        FileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        List<FileItem> items = upload.parseRequest(request);
        for (FileItem item : items) {
            if (!item.isFormField() && item.getFieldName().equals("file") && item.getContentType().contains("html")) {
                String fileName = item.getName();
                String targetDirectory = GlobalParm.getParm("CUSTOM_ERROR_PAGE");
                File destDir = FileUtil.getFile(targetDirectory);//change
                FileUtil.mkDirs(destDir); //change
                String filePath = targetDirectory + (fileName.replaceAll("/", "").replaceAll("\\\\", ""));

                File file = FileUtil.getFile(filePath);//change
                item.write(file);
            }
        }
        rspObj.put("msg","File uploaded successfully!");
        rspObj.put("status",0);

        out.write(rspObj.toString());
    } catch (Exception e) {
        JSONObject rspObj=new JSONObject();
        e.printStackTrace();
        rspObj.put("msg","Error uploading file: " + e.getMessage());
        rspObj.put("status",1);
        out.write(rspObj.toString());
    }
%>