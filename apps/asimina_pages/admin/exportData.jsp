<%@ page trimDirectiveWhitespaces="true" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape,com.etn.pages.EntityExport,com.etn.pages.excel.ExcelEntityExport,org.apache.poi.ss.usermodel.Workbook,java.util.*,com.etn.asimina.util.FileUtil" %>
<%@ include file="../WEB-INF/include/commonMethod.jsp" %>
<%@ include file="pagesUtil.jsp" %>

<%!
    String getSelectedSiteId(javax.servlet.http.HttpSession session) {
        if(session.getAttribute("SELECTED_SITE_ID") == null) return "";
        return (String)session.getAttribute("SELECTED_SITE_ID");
    }

    boolean isDwnldOnBrowser(String siteId,String ids,String exportType, com.etn.beans.Contexte Etn,String exportLimit,String excelExport){
        int limit= Integer.parseInt(parseNull(exportLimit));

        if(excelExport.equals("1")){
            return false;
        }else {
            if(ids.equalsIgnoreCase("all")){
                String query="";

                switch (exportType.toLowerCase()) {
                    case "bloc_templates":
                        query = "SELECT COUNT(0) as nb_count FROM bloc_templates WHERE site_id = " + escape.cote(siteId);
                        break;
                    case "blocs":
                        query = "SELECT COUNT(0) as nb_count FROM blocs WHERE site_id = " + escape.cote(siteId);
                        break;
                    case "forms":
                        query = "SELECT COUNT(0) AS nb_count FROM " + GlobalParm.getParm("FORMS_DB") + ".process_forms WHERE site_id = " + escape.cote(siteId);
                        break;
                    case "libraries":
                        query = "SELECT COUNT(0) as nb_count FROM libraries WHERE site_id = " + escape.cote(siteId);
                        break;

                    case "page_templates":
                        query = "SELECT COUNT(0) as nb_count FROM page_templates WHERE site_id = " + escape.cote(siteId);
                        break;

                    case "pages":
                        query = "SELECT COUNT(0) as nb_count FROM freemarker_pages WHERE site_id = " + escape.cote(siteId) + " AND is_deleted = '0'";
                        break;

                    case "structured_pages":
                        query = "SELECT COUNT(0) as nb_count FROM structured_contents sc JOIN bloc_templates bt ON bt.id = sc.template_id "
                                + "WHERE sc.type = 'page' AND sc.structured_version='V1' AND bt.type != " + escape.cote(Constant.TEMPLATE_STORE) + " AND sc.site_id = " + escape.cote(siteId);
                        break;

                    case "products":
                        query = "SELECT COUNT(0) as nb_count FROM " + GlobalParm.getParm("CATALOG_DB") + ".products p "
                                + "JOIN " + GlobalParm.getParm("CATALOG_DB") + ".catalogs c ON c.id = p.catalog_id WHERE p.product_version='V1' AND c.site_id = " + escape.cote(siteId);
                        break;

                    case "stores":
                        query = "SELECT COUNT(0) as nb_count FROM structured_contents sc JOIN bloc_templates bt ON bt.id = sc.template_id "
                                + "WHERE sc.type = 'page' AND sc.structured_version='V1' AND bt.type = " + escape.cote(Constant.TEMPLATE_STORE) + " AND sc.site_id = " + escape.cote(siteId);
                        break;

                    case "structured_contents":
                        query = "SELECT COUNT(0) as nb_count FROM structured_contents sc WHERE sc.type = 'content' AND sc.structured_version='V1' AND sc.site_id = " + escape.cote(siteId);
                        break;

                    case "variables":
                        query = "SELECT COUNT(0) as nb_count FROM variables WHERE site_id = " + escape.cote(siteId);
                        break;
                    
                    default:
                        if(exportType.contains("catalogs")) query="SELECT COUNT(0) as nb_count FROM "+GlobalParm.getParm("CATALOG_DB")+".catalogs WHERE catalog_version='V1' AND site_id ="+escape.cote(siteId);
                        break;
                }

                Set rs=Etn.execute(query);
                if(rs.next()){
                    if(Integer.parseInt(parseNull(rs.value("nb_count")))>=limit && !exportType.equalsIgnoreCase("variables")) return false;
                    else return true;
                }else return false;
            
            }else if(ids.split(",").length>=limit && !exportType.equalsIgnoreCase("variables")) return false;
            else return true;
        }
    }
%>

<%
    String baseDir = GlobalParm.getParm("BASE_DIR");
    String exportLimit = GlobalParm.getParm("EXPORT_LIMIT");
    String selectedsiteid = getSelectedSiteId(session);
    String pathTemp="uploads/"+selectedsiteid+"/export/"+Etn.getId()+"/";

    String exportType = parseNull(request.getParameter("exportType"));
    String langIds = parseNull(request.getParameter("langIds"));
    String excelExport = parseNull(request.getParameter("excelExport"));
    String ids = parseNull(request.getParameter("ids"));
    String action = parseNull(request.getParameter("action"));
    String filePath = parseNull(request.getParameter("filePath"));

    String semaphores = parseNull(GlobalParm.getParm("IMPORT_SEMAPHORE"));
    JSONObject resp = new JSONObject();
    try{
        if(action.length() > 0){
            
            if(action.equalsIgnoreCase("insert")){
                Etn.executeCmd("insert into batch_export (target_ids,lang_ids,site_id,export_type,excel_export,process,created_by) values ("+escape.cote(ids)+","+
                escape.cote(langIds)+","+escape.cote(selectedsiteid)+","+escape.cote(exportType)+","+escape.cote(excelExport)+",'waiting',"+escape.cote(Etn.getId()+"")+")");
                Etn.execute("select semfree("+escape.cote(semaphores)+")");
                
                resp.put("status","true");
                resp.put("message","Data is being exported");

            }else if(action.equalsIgnoreCase("check")){
                Set rs = Etn.execute("select * from batch_export where export_type="+escape.cote(exportType)+" and lang_ids="+escape.cote(langIds)+" and excel_export="+
                escape.cote(excelExport)+" and target_ids="+escape.cote(ids)+" order by created_ts desc limit 1");
                if(rs!=null && rs.next()){
                    String fileName = exportType.replaceAll("/", "").replaceAll("\\\\", "");
                    if(excelExport.equals("0")) fileName+=".json";
                    else fileName+=".xlsx";

                    resp.put("status",parseNull(rs.value("process")));
                    resp.put("url",pathTemp+fileName);
                    resp.put("message",parseNull(rs.value("error_msg")));
                }else{
                    resp.put("status","false");
                    resp.put("message","Error in downloading file");
                }
            }else if(action.equalsIgnoreCase("deleteFile")){
                // File file = new File(baseDir+pathTemp+(filePath.replaceAll("\\\\", "").split("/")[filePath.split("/").length-1]));
                File file = FileUtil.getFile(baseDir+pathTemp+(filePath.replaceAll("\\\\", "").split("/")[filePath.split("/").length-1]));
                if(file.exists()) file.delete();
                resp.put("status","true");
                resp.put("message","File Deleted");

            }else if(action.equalsIgnoreCase("checkFileExist")){

                String fileNames="";
                // File[] files = new File(baseDir+pathTemp).listFiles();
                File directory = FileUtil.getFile(baseDir+pathTemp);  // code change for fileUtil.java
                File[] files = directory.listFiles();
                for (File file : files) {
                    if (file.isFile()) {
                        if(fileNames.length() > 0) fileNames+="$"+file.getName();
                        else fileNames=file.getName();
                    }
                }

                if(fileNames.length() > 0 && !fileNames.contains("lock")){
                    resp.put("status","true");
                    resp.put("files",fileNames);
                    resp.put("url",pathTemp);
                }else{
                    Set rs2=Etn.execute("select * from batch_export where process in ('waiting','processing') and site_id="+escape.cote(selectedsiteid)+
                        " and created_by="+escape.cote(Etn.getId()+"")+" order by created_ts desc limit 1");

                    if(rs2!=null && rs2.next()){ 
                        resp.put("status",rs2.value("process"));
                        resp.put("message",rs2.value("process"));
                    }else{
                        resp.put("status","false");
                        resp.put("message","No file present");
                    }
                }
            }else if(action.equalsIgnoreCase("isDwnldOnBrowser")){
                if(isDwnldOnBrowser(selectedsiteid,ids,exportType,Etn,exportLimit,excelExport)){
                    resp.put("status","true");
                    resp.put("message","Downlaod on browser");
                }else{
                    resp.put("status","false");
                    resp.put("message","Downlaod on engine");
                }
            }
            out.write(resp.toString());

        } else {
            String fileName;
            if (!EntityExport.isValidExportImportType(exportType)) out.write("");
            else {
                if(excelExport.equals("1")) fileName = exportType + ".xlsx";
                else fileName = exportType + ".json";

                response.setContentType("application/octet-stream; charset=utf-8");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

                String q;
                Set rs;
                JSONObject retObj = new JSONObject();

                JSONObject info = new JSONObject();
                info.put("comment", "this is optional (not required) export info");
                info.put("export_by", "" + Etn.getId());
                info.put("date_time", new java.util.Date(System.currentTimeMillis()).toString());
                info.put("export_type", exportType.replace("_", " "));
                info.put("selection", "all".equals(ids) ? "all" : "select");

                retObj.put("export_info", info);

                JSONArray itemsList = new JSONArray();
                JSONObject curObj;

                String tableName = escape.cote(exportType);
                if(exportType.equals("pages")) tableName = "freemarker_pages";
                else tableName = tableName.substring(1, tableName.length() - 1);
                
                String siteId = getSiteId(session);
                EntityExport entityExport = new EntityExport(Etn, siteId);
                HashSet<String> filterLangIds = new HashSet<>();
                if(langIds.length() > 0){
                    Arrays.stream(langIds.split(",")).filter(curLangId -> parseInt(curLangId) > 0).forEach(filterLangIds::add);
                    entityExport.setFilterLangIds(filterLangIds);
                }
                info.put("lang_ids", new JSONArray(filterLangIds));

                if ("all".equals(ids)) {
                    q = " SELECT id FROM  "+tableName+" WHERE site_id = " + escape.cote(siteId);
                    switch (exportType) {
                        case "structured_contents":
                        case "structured_pages":
                            String structType = Constant.STRUCTURE_TYPE_CONTENT;
                            if (exportType.equals("structured_pages")) structType = Constant.STRUCTURE_TYPE_PAGE;
                            q = " SELECT sc.id FROM  structured_contents sc JOIN bloc_templates bt ON bt.id = sc.template_id WHERE sc.site_id = " + escape.cote(siteId)
                                + " AND sc.structured_version='V1' AND sc.type = " + escape.cote(structType)+ " AND bt.type != " + escape.cote(Constant.TEMPLATE_STORE);
                            break;

                        case "stores":
                            exportType = "structured_pages";
                            q = " SELECT sc.id FROM  structured_contents sc JOIN bloc_templates bt ON bt.id = sc.template_id WHERE sc.site_id = "+escape.cote(siteId)
                                + " AND sc.structured_version='V1' AND sc.type = "+escape.cote(Constant.STRUCTURE_TYPE_PAGE)+" AND bt.type = "+escape.cote(Constant.TEMPLATE_STORE);
                            break;

                        case "catalogs":
                            q = " SELECT c.id FROM  "+GlobalParm.getParm("CATALOG_DB")+".catalogs c WHERE c.catalog_version='V1' AND c.site_id = " + escape.cote(siteId);
                            break;

                        case "products":
                            q = " SELECT p.id FROM "+GlobalParm.getParm("CATALOG_DB")+".products p JOIN "+GlobalParm.getParm("CATALOG_DB")+
                                ".catalogs c ON c.id = p.catalog_id WHERE p.product_version='V1' AND c.site_id = " + escape.cote(siteId);
                            break;

                        case "forms":
                            q = " SELECT form_id AS id FROM " + GlobalParm.getParm("FORMS_DB") + ".process_forms p WHERE site_id = " + escape.cote(siteId);
                            break;

                        case "variables":
                            q = " SELECT id FROM variables WHERE site_id = " + escape.cote(siteId);
                            break;
                    }
                    rs = Etn.execute(q);
                    while (rs.next()) {
                        try {
                            curObj = entityExport.getExportJson(exportType, rs.value("id"));
                            if (curObj != null) itemsList.put(curObj);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }
                } else {
                    String[] idList = ids.split(",");
                    for (String curId : idList) {
                        try {
                            if (parseInt(curId) <= 0 && !exportType.equals("forms")) continue;
                            if(exportType.equals("stores")) exportType = "structured_pages";

                            curObj = entityExport.getExportJson(exportType, curId);
                            if (curObj != null) itemsList.put(curObj);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }//for
                }

                if(excelExport.equals("1")){
                    try{
                        ExcelEntityExport excelExportEnitity = new ExcelEntityExport();
                        Workbook workbook = excelExportEnitity.getExportExcel(itemsList);
                        workbook.write(response.getOutputStream());
                        workbook.close();
                    } catch (Exception ex){
                        ex.printStackTrace();
                    }
                } else{
                    retObj.put("items", itemsList);
                    out.write(retObj.toString(2));
                }
            }
        }
    } catch(Exception e){
        e.printStackTrace();
        resp.put("status","false");
        resp.put("message",e.getMessage());
        out.write(resp.toString());
    }
%>