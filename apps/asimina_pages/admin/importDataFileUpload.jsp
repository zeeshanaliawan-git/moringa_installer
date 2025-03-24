<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.util.XSSHandler, org.json.JSONObject, org.json.JSONArray, java.io.FileOutputStream, java.io.File, java.util.Date, java.text.SimpleDateFormat, com.etn.pages.*, java.nio.file.Files, com.etn.pages.excel.ExcelImportFile, com.etn.pages.excel.ExcelEntityImport,com.etn.asimina.util.FileUtil"%>
<%@ page import="java.util.UUID,com.etn.util.FormDataFilter,java.io.*"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/fileMethods.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%
    String IMPORT_DIR = GlobalParm.getParm("TEMP_DIRECTORY") + "data_import/";
    //For dev
    String directoryName = GlobalParm.getParm("BASE_DIR")+"uploads/queueImport/";
    //For local
    //String directoryName ="D:/work/asimina/svn/dev_pages/uploads/queueImport/";

    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";


    File importFile = null;

    FileOutputStream fileOutput = null;
    String[] fieldData = new String[3];
    String fileName = "";

    boolean importDatetime = false;
    
    JSONArray fileData = new JSONArray();
    JSONObject filed = new JSONObject();

    String siteId = getSiteId(session);
    
    String fileActualName = "";
    try{

         
        FormDataFilter formData = new FormDataFilter(request.getInputStream());

        boolean dataFound = false;

        String fileExtension = "";
        while((fieldData = formData.getField()) != null){
            if(formData.isStream())
            {
                fileActualName = XSSHandler.clean(getSafeFileName(parseNull(fieldData[1])));

                if(fileActualName.indexOf(".json") <= 0 && fileActualName.indexOf(".xlsx") <= 0){
                    continue;
                }

                int idx = fileActualName.lastIndexOf("/");
                if(idx >= 0) fileActualName=fileActualName.substring(idx + 1);
                int idy = fileActualName.lastIndexOf("\\");
                if(idy >= 0) fileActualName=fileActualName.substring(idy + 1);

                int lastIndex = fileActualName.lastIndexOf(".");
                if(lastIndex > 0){
                	fileName = fileActualName.substring(0,lastIndex);
                    
                    fileExtension = FileUtil.getFileExtension(fileActualName);//change
                }
                else{
                	fileName = fileActualName;
                }

                String fileNamePostFix = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());;

                fileName += fileNamePostFix + fileExtension;

                filed.put("batch",fileName);

                                
                importFile  = FileUtil.getFile(IMPORT_DIR + fileName);//change
                importFile.getParentFile().mkdirs();
                fileOutput = new FileOutputStream(importFile);

                File directory = FileUtil.getFile(directoryName);//change
                FileUtil.mkDir(directory);//change

                if(importFile != null && importFile.exists() && fileName.length() > 0 ){
                    FileOutputStream myFile = FileUtil.getFileOutputStream(directoryName + fileName);//change
                    formData.writeTo(myFile);
                    myFile.close();
                }else{
                    throw new Exception("file data not found.");
                }
            }
            else
            {
                if(fieldData[0].equals("importDatetime")) {
                    importDatetime = "1".equals(parseNull(fieldData[1]));
                }
            }

        }//while fieldData

        filed.put("name",fileActualName);
        
        filed.put("process","waiting");
        if(filed.getString("process").equalsIgnoreCase("loaded")){
            filed.put("action","<button class='btn btn-success'>Next</button>");
        }else{
            filed.put("action","None");
        }
        
        String query="insert into batch_imports (batch_id, name, status, site_id,created_by,info) values("+escape.cote(filed.getString("batch"))+
        ","+escape.cote(filed.getString("name"))+","+escape.cote(filed.getString("process"))+","+escape.cote(siteId)+","+
        escape.cote(""+Etn.getId())+","+escape.cote(""+importDatetime)+")";
        Etn.execute(query);

        fileData.put(filed);
        status=STATUS_SUCCESS;

        String q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("SEMAPHORE"))) + ");";
		Etn.execute(q);

    }//end try
    catch(Exception e)
    {
            e.printStackTrace();
            if(fileOutput != null) fileOutput.close();

            status = STATUS_ERROR;
            message = e.getMessage();
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",fileData);
    out.write(jsonResponse.toString());
%>