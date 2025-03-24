<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.util.XSSHandler, org.json.JSONObject, org.json.JSONArray, java.io.FileOutputStream, java.io.File, java.util.Date, java.text.SimpleDateFormat, com.etn.pages.*, java.nio.file.Files, com.etn.pages.excel.ExcelImportFile, com.etn.pages.excel.ExcelEntityImport"%>
<%@ page import="java.util.UUID,com.etn.util.FormDataFilter,java.io.*"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/fileMethods.jsp"%>
<%@ include file="pagesUtil.jsp"%>

<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_SUCCESS;

    String message="";
    JSONArray result = new JSONArray();
    String requestType=parseNull(request.getParameter("request_type"));
    String siteId = getSiteId(session);
    String query="";
    Set rs=null;

    Etn.execute("SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("IMPORT_SEMAPHORE"))) + ");");

    if(requestType!=null && requestType.length()>0) {
        if(requestType.equalsIgnoreCase("load")){
            query="select * from batch_imports where site_id=" + escape.cote(siteId) +" and is_deleted='0' order by created_ts asc";
            
            try{
                rs=Etn.execute(query);
                while(rs.next()){
                    JSONObject obj = new JSONObject();
                    String batchId=escape.cote(rs.value("ID"));
                    for(String colName: rs.ColName){
                        if(colName.equalsIgnoreCase("status")){
                            String next="<button class='btn btn-sm btn-success ml-1' title='Next' onclick=redirectToImport("+batchId+")><i class='fa fa-edit'></i></button>";
                            String delete="<button class='btn btn-sm btn-danger ml-1' title='Delete' onclick=doAction("+batchId+",'delete')><i class='fa fa-trash'></i></button>";
                            String verify="<button class='btn btn-sm btn-primary ml-1' title='Verify' onclick=doAction("+batchId+",'verify')><i class='fa fa-check'></i></button>";
                            String ignore="<button class='btn btn-sm btn-warning ml-1' title='Ignore' onclick=doAction("+batchId+",'ignore')><i class='fa fa-exclamation'></i></button>";
                            String btn = "<div class='d-flex justify-content-end'>";
                            String hiddenDiv="<div style='display: none'>";
                            if(rs.value(colName).equalsIgnoreCase("loaded")){
                                
                                 btn +=hiddenDiv+"1"+"</div>"+next+ignore+delete+"</div>";
                                obj.put("action",btn);
                                
                            }else if(rs.value(colName).equalsIgnoreCase("ignored")){

                                btn +=hiddenDiv+"6"+"</div>"+delete+"</div>";
                                obj.put("action",btn);

                            }else if(rs.value(colName).equalsIgnoreCase("import error")){

                                btn +=hiddenDiv+"3"+"</div>"+next+ignore+verify+delete+"</div>";
                                obj.put("action",btn);

                            }else if(rs.value(colName).equalsIgnoreCase("load error")){

                                btn +=hiddenDiv+"4"+"</div>"+ignore+delete+"</div>";
                                obj.put("action",btn);

                            }else if(rs.value(colName).equalsIgnoreCase("imported")){

                                btn +=hiddenDiv+"5"+"</div>"+next+delete+"</div>";
                                obj.put("action",btn);
                            
                            }else if(rs.value(colName).equalsIgnoreCase("waiting")||rs.value(colName).equalsIgnoreCase("processing")|| rs.value(colName).equalsIgnoreCase("importing")){
                                obj.put("action",btn+hiddenDiv+"2"+"</div>"+ignore+"</div>");
                            }
                        }
                        obj.put(colName.toLowerCase(),rs.value(colName));
                    }
                    result.put(obj);
                }
            }catch(Exception e){
                status=STATUS_ERROR;
                message=e.getMessage();
            }
        }else if(requestType.equalsIgnoreCase("import")){
            try{

                String batchId=parseNull(request.getParameter("batch_id"));
                if(batchId != null && batchId.length()>0){
                    query="select * from batch_imports_items where batch_table_id="+escape.cote(batchId) + " and is_deleted='0' and site_id="+escape.cote(siteId);
                    rs=Etn.execute(query);
                    while(rs.next()) {
                        JSONObject obj = new JSONObject();
                        for(String colName : rs.ColName){
                            obj.put(colName.toLowerCase(),rs.value(colName));
                        }
                        result.put(obj);
                    }
                }else{
                    status=STATUS_ERROR;
                    message="Batch id is missing.";
                }
            }catch(Exception e){
                status=0;
                message=e.getMessage();
            }
        }else if(requestType.equalsIgnoreCase("verify")){
            try{

                String batchId=parseNull(request.getParameter("batch_id"));
                if(batchId != null && batchId.length()>0){
                    query="select status from batch_imports where id="+escape.cote(batchId)+" and is_deleted='0' and site_id="+escape.cote(siteId);
                    Set rsVerify=Etn.execute(query);
                    rsVerify.next();
                    if(!(rsVerify.value("status").equalsIgnoreCase("processing") ||rsVerify.value("status").equalsIgnoreCase("importing"))){

                        query="delete from batch_imports_items where batch_table_id="+escape.cote(batchId) + " and site_id="+escape.cote(siteId)+
                        " and process not in ('importing','processing')";
                        Etn.executeCmd(query);
                        query="update batch_imports set status='waiting',message='' where id="+escape.cote(batchId)+" and status not in ('importing','processing')";
                        Etn.executeCmd(query);
                        message="Batch is being verified. It will take some time.";
                    }else{
                        status=STATUS_ERROR;
                        message="Can not verify batch. It is either in loading or importing process.";
                    }
                    
                }else{
                    status=STATUS_ERROR;
                    message="Batch id is missing.";
                }
                String q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("IMPORT_SEMAPHORE"))) + ");";
                Etn.execute(q);
            }catch(Exception e){
                status=0;
                message=e.getMessage();
            }
        }
        else if(requestType.equalsIgnoreCase("ignore")){
            try{

                String batchId=parseNull(request.getParameter("batch_id"));
                if(batchId != null && batchId.length()>0){
                    query="update batch_imports_items set process='ignored' where batch_table_id="+escape.cote(batchId) + " and site_id="+escape.cote(siteId);
                    Etn.executeCmd(query);
                    query="update batch_imports set status='ignored',message='' where id="+escape.cote(batchId);
                    Etn.executeCmd(query);
                    message="Batch is ignored.";
                    
                }else{
                    status=STATUS_ERROR;
                    message="Batch id is missing.";
                }
                String q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("IMPORT_SEMAPHORE"))) + ");";
                Etn.execute(q);
            }catch(Exception e){
                status=0;
                message=e.getMessage();
            }
        }
        else if(requestType.equalsIgnoreCase("delete")){
            try{

                String batchId=parseNull(request.getParameter("batch_id"));
                if(batchId != null && batchId.length()>0){
                    query="update batch_imports_items set is_deleted='1' where batch_table_id="+escape.cote(batchId) + " and site_id="+escape.cote(siteId);
                    Etn.executeCmd(query);
                    query="update batch_imports set is_deleted='1',deleted_by="+escape.cote(""+Etn.getId())+" where id="+escape.cote(batchId);
                    Etn.executeCmd(query);
                    message="Batch is ignored.";
                    
                }else{
                    status=STATUS_ERROR;
                    message="Batch id is missing.";
                }

                String q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("IMPORT_SEMAPHORE"))) + ");";
                Etn.execute(q);
            }catch(Exception e){
                status=0;
                message=e.getMessage();
            }
        }
        else if(requestType.equalsIgnoreCase("refresh")){
            try{
                String q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("IMPORT_SEMAPHORE"))) + ");";
                Etn.execute(q);
                
            }catch(Exception e){
                status=0;
                message=e.getMessage();
            }
        }else{
            status=STATUS_ERROR;
            message="Request type is invalid.";
        }
    }else{
        status=STATUS_ERROR;
        message="Request type is missing.";
    }
    JSONObject returnObj = new JSONObject();
    returnObj.put("status",status);
    returnObj.put("message",message);
    returnObj.put("data",result);
    out.write(returnObj.toString());
%>