package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.beans.app.GlobalParm;
import com.etn.pages.*;
import com.etn.pages.excel.ExcelEntityExport;
import com.etn.pages.EntityExport;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import org.json.JSONObject;
import org.json.JSONArray;
import org.apache.poi.ss.usermodel.Workbook;

import java.io.OutputStream;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.FileOutputStream;
import java.io.File;
import java.util.Date;
import java.util.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

public class ExportData {
    private Properties env;
	private com.etn.beans.Etn Etn;
	private boolean debug;

    public ExportData(Etn Etn, Properties env, boolean debug) throws Exception {
		this.Etn = Etn;
		this.env = env;
		this.debug = debug;
		
	}

    void ExportFile(String siteId) throws Exception {
        try{
            Set rs= Etn.execute("select * from batch_export where process='waiting' and site_id="+escape.cote(siteId)+" order by created_ts asc");
            while(rs.next()){
                String fileName;
                String batchId=PagesUtil.parseNull(rs.value("batch_id"));
                String exportType=PagesUtil.parseNull(rs.value("export_type"));
                String langIds = PagesUtil.parseNull(rs.value("lang_ids"));
                String excelExport = PagesUtil.parseNull(rs.value("excel_export"));
                String ids = PagesUtil.parseNull(rs.value("target_ids"));
                String createdBy = PagesUtil.parseNull(rs.value("created_by"));

                if (!EntityExport.isValidExportImportType(exportType)) {
                    Etn.executeCmd("update batch_export set process='export_error', error_msg='Invalid Export Type' where batch_id="+escape.cote(batchId));
                } else {
                    System.out.println("==============Starting Export Batch=============");
                    Etn.executeCmd("update batch_export set process='processing' where batch_id="+escape.cote(batchId));
                    
                    if(excelExport.equals("1")) fileName = exportType + ".xlsx";
                    else fileName = exportType + ".json";
            
                    String q;
                    Set rs2;
                    JSONObject retObj = PagesUtil.newJSONObject();
            
                    JSONObject info = PagesUtil.newJSONObject();
                    info.put("comment", "this is optional (not required) export info");
                    info.put("export_by", createdBy);
                    info.put("date_time", new java.util.Date(System.currentTimeMillis()).toString());
                    info.put("export_type", exportType.replace("_", " "));
                    info.put("selection", "all".equals(ids) ? "all" : "select");
            
                    retObj.put("export_info", info);
            
                    JSONArray itemsList = new JSONArray();
                    JSONObject curObj;
                    
                    String tableName = escape.cote(exportType);
                    if(exportType.equals("pages")) tableName = "freemarker_pages";
                    else tableName = tableName.substring(1, tableName.length() - 1);
                    
                    EntityExport entityExport = new EntityExport(Etn, siteId);
                    HashSet<String> filterLangIds = new HashSet<>();
                    if(langIds.length() > 0){
                        Arrays.stream(langIds.split(",")).filter(curLangId -> PagesUtil.parseInt(curLangId) > 0).forEach(filterLangIds::add);
                        entityExport.setFilterLangIds(filterLangIds);
                    }
                    info.put("lang_ids", new JSONArray(filterLangIds));
                    if ("all".equals(ids)) {
                        q = " SELECT id FROM "+tableName+" WHERE site_id = " + escape.cote(siteId);
            
                        switch (exportType) {
                            case "structured_contents":
                            case "structured_pages":
                                String structType = Constant.STRUCTURE_TYPE_CONTENT;
                                if (exportType.equals("structured_pages")) structType = Constant.STRUCTURE_TYPE_PAGE;
            
                                q = " SELECT sc.id FROM  structured_contents sc JOIN bloc_templates bt ON bt.id = sc.template_id WHERE sc.site_id=" + escape.cote(siteId)
                                    +" AND sc.structured_version='V1' AND sc.type = " + escape.cote(structType)+" AND bt.type != " + escape.cote(Constant.TEMPLATE_STORE);
                                break;

                            case "stores":
                                exportType = "structured_pages";
                                q = " SELECT sc.id FROM  structured_contents sc JOIN bloc_templates bt ON bt.id = sc.template_id WHERE sc.site_id = " + escape.cote(siteId)
                                    +"  AND sc.structured_version='V1' AND sc.type = " + escape.cote(Constant.STRUCTURE_TYPE_PAGE)+" AND bt.type = " + escape.cote(Constant.TEMPLATE_STORE);
                                break;

                            case "catalogs":
                                q = " SELECT c.id FROM "+env.getProperty("CATALOG_DB")+".catalogs c WHERE c.catalog_version='V1' c.site_id = "+escape.cote(siteId);
                                break;

                            case "products":
                                q = " SELECT p.id FROM "+env.getProperty("CATALOG_DB")+".products p JOIN "+env.getProperty("CATALOG_DB")+".catalogs c ON c.id = p.catalog_id "
                                    + " WHERE p.product_version='V1' AND c.site_id = " + escape.cote(siteId);
                                break;

                            case "forms":
                                q = " SELECT form_id AS id FROM " + env.getProperty("FORMS_DB") + ".process_forms p WHERE site_id = " + escape.cote(siteId);
                                break;

                            case "variables":
                                q = " SELECT id FROM variables WHERE site_id = " + escape.cote(siteId);
                                break;
                        }
                        rs2 = Etn.execute(q);
                        while (rs2.next()) {
                            try {
                                curObj = entityExport.getExportJson(exportType, rs2.value("id"),true);
                                if (curObj != null) itemsList.put(curObj);
                            } catch (Exception ex) {
                                Etn.executeCmd("update batch_export set process='export_error', error_msg="+escape.cote(ex.getMessage())+" where batch_id="+escape.cote(batchId));
                            }
                        }
                    } else {
                        String[] idList = ids.split(",");
                        for (String curId : idList) {
                            try {
                                if (PagesUtil.parseInt(curId) <= 0 && !exportType.equals("forms")) continue;
                                if(exportType.equals("stores")) exportType = "structured_pages";
            
                                curObj = entityExport.getExportJson(exportType, curId,true);
                                if (curObj != null) itemsList.put(curObj);
                            } catch (Exception ex) {
                                Etn.executeCmd("update batch_export set process='export_error', error_msg="+escape.cote(ex.getMessage())+" where batch_id="+escape.cote(batchId));
                            }
                        }//for
                    }
                    String fileStorePath=env.getProperty("BASE_DIR")+"uploads/"+siteId+"/export/"+createdBy+"/";

                    File destDir = new File(fileStorePath);
                    if(!destDir.exists()) destDir.mkdirs();
                    if(excelExport.equals("1")){
                        System.out.println("==============Exporting Excel=============");
                        try{
                            File f = new File(fileStorePath+fileName);
                            if(f.exists()) f.delete();

                            OutputStream fileOut = new FileOutputStream(fileStorePath+fileName);
                            ExcelEntityExport excelExportEnitity = new ExcelEntityExport();
                            Workbook workbook = excelExportEnitity.getExportExcel(itemsList);
                            workbook.write(fileOut);
                            workbook.close();
                        } catch (Exception ex){
                            Etn.executeCmd("update batch_export set process='export_error', error_msg="+escape.cote(ex.getMessage())+" where batch_id="+escape.cote(batchId));
                        }
                    } else{
                        System.out.println("==============Exporting JSON=============");
                        try{
                            File f = new File(fileStorePath+fileName);
                            if(f.exists()) f.delete();

                            retObj.put("items", itemsList);
                            PrintWriter file = new PrintWriter(new FileWriter(fileStorePath+fileName));
                            file.write(retObj.toString());
                            file.close();
                        } catch(Exception ex){
                            Etn.executeCmd("update batch_export set process='export_error', error_msg="+escape.cote(ex.getMessage())+" where batch_id="+escape.cote(batchId));
                        }
                    }
                    Etn.executeCmd("update batch_export set process='exported' where batch_id="+escape.cote(batchId));
                    System.out.println("==============Ending Export Batch=============");
                }
            }
        }catch(Exception ex){
            ex.printStackTrace();
        }
    }


}