package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.beans.app.GlobalParm;
import com.etn.pages.EntityImport;
import com.etn.pages.*;
import com.etn.pages.excel.ExcelImportFile;
import com.etn.pages.excel.ExcelEntityImport;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import org.json.JSONObject;
import org.json.JSONArray;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.io.File;
import java.util.Date;
import java.util.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.text.Normalizer;

public class LoadImportFile 
{
    private Properties env;
	private com.etn.beans.Etn Etn;
	private boolean debug;

    public LoadImportFile(Etn Etn, Properties env, boolean debug) throws Exception
	{
		this.Etn = Etn;
		this.env = env;
		this.debug = debug;
		
	}

    void loadFile(String siteId) throws Exception{
        try{
            String engineQuery="select * from batch_imports where status in ('processing','loaded','importing','import error') and is_deleted='0' and site_id="+escape.cote(siteId);
            Set engineRs = Etn.execute(engineQuery);
            
            if(!engineRs.next()){
                engineQuery="select * from batch_imports where status='waiting' and site_id="+escape.cote(siteId)+" order by created_ts asc limit 0,1";
                engineRs = Etn.execute(engineQuery);
                if(engineRs.next()){

                    Etn.executeCmd("update batch_imports set status='processing' where status='waiting' and is_deleted='0' and id ="+escape.cote(engineRs.value("id")));
                    String fileExten="";
                    JSONArray dataList = null;
                    JSONArray itemsList = null;

                    //For dev
                    String directory = GlobalParm.getParm("BASE_DIR")+"uploads/queueImport/";
                    //For local
                    //String directory ="D:/work/asimina/svn/dev_pages/uploads/queueImport/";
                    File file = new File(directory+engineRs.value("batch_id"));
                    int extIndex = engineRs.value("batch_id").lastIndexOf(".");

                    if(extIndex > 0){
                        fileExten =  engineRs.value("batch_id").substring(extIndex);
                    }
                    if(".json".equalsIgnoreCase(fileExten)){
                        //json file processing
                        String fileContents = FilesUtil.readFile(file);
                        //check if its valid json
                        JSONObject fileJson = null;
                        try{
                            fileJson = new JSONObject(fileContents);
                        }
                        catch(Exception jsonEx){
                            Etn.executeCmd("update batch_imports set status='load error',info='',message='' where status='processing' and is_deleted='0' and id="+
                                escape.cote(engineRs.value("id")));
                            throw new Exception("Error: Invalid file contents." + jsonEx.toString());
                        }

                        itemsList = fileJson.optJSONArray("items");
                    }else if(".xlsx".equalsIgnoreCase(fileExten)){
                        ExcelEntityImport excelEntityImport = new ExcelEntityImport(file);

                        itemsList = excelEntityImport.getItemsList();
                    }else{
                        throw new Exception("File type not supported choose another file.");
                    }

                    boolean importDatetime="1".equals(engineRs.value("info"));

                    if(itemsList == null){
                        Etn.executeCmd("update batch_imports set status='load error',info='',message='' where status='processing' and is_deleted='0' and id="+escape.cote(engineRs.value("id")));
                        throw new Exception("Error: Invalid data. Items list not found.");
                    }
                    else if(itemsList.length() == 0){
                        Etn.executeCmd("update batch_imports set status='load error',info='',message='' where status='processing' and is_deleted='0' and id="+escape.cote(engineRs.value("id")));
                        throw new Exception("No import items found.");
                    }
                    else {
                        EntityImport entityImport = new EntityImport(Etn, engineRs.value("site_id"), importDatetime, Integer.parseInt(engineRs.value("created_by")));
                        dataList = entityImport.verifyImportItemsList(itemsList);
                    }
                    
                    if(dataList != null){
                        for(int i = 0; i < dataList.length(); i++){
                            JSONObject dataObject = dataList.getJSONObject(i);
                            String insertQuery="insert into batch_imports_items set batch_table_id="+escape.cote(engineRs.value("id"))+
                            ",name="+escape.cote(dataObject.getString("name"))+
                            ",item_id="+escape.cote(dataObject.getString("id"))+",type="+escape.cote(dataObject.getString("type"))+
                            ",error="+escape.cote(dataObject.getString("error"))+",status="+escape.cote(dataObject.getString("status"))+
                            ",item_data="+escape.cote(PagesUtil.encodeJSONStringDB(dataObject.getJSONObject("item_data").toString()))+
                            ",site_id="+escape.cote(engineRs.value("site_id"));

                            Etn.executeCmd(insertQuery);
                        }
                    }
                    Etn.executeCmd("update batch_imports set status='loaded',info='' where status='processing' and is_deleted='0' and id="+escape.cote(engineRs.value("id")));
                }
            }
        }catch(Exception ex){
            ex.printStackTrace();
            throw new Exception("Error in loading data. Please try again.",ex);
        }
    }

    void importFile(String site) throws Exception{
        try{
            Set rs =null;
            rs=Etn.execute("select * from batch_imports where status='importing' and is_deleted='0' and site_id="+escape.cote(site)+" order by created_ts asc limit 0,1");
            if(rs.next()){
                System.out.println("===========Starting import batch===========");
                JSONArray itemsList = new JSONArray();
                String msg="";
                JSONObject infoObj=new JSONObject(rs.value("info"));
                boolean importDatetime = "1".equals(infoObj.getString("importDatetime"));
                String targetCatalogId = infoObj.getString("targetCatalogId");
                String importType = infoObj.getString("importType");
                String importTypeReplace = infoObj.getString("importTypeReplace");
                String clientId = infoObj.getString("clientId");
                String isSuperAdmin = infoObj.getString("isSuperAdmin");
                String siteId = rs.value("site_id");
                String batchId = rs.value("id");
                String updatedItems="";
                String skipedItems="";
                String createdBy = rs.value("created_by");

                Set rs2=Etn.execute("select * from batch_imports_items where process='import' and is_deleted='0' and batch_table_id="+escape.cote(batchId)
                +" and site_id="+escape.cote(siteId));
                
                Etn.executeCmd("update batch_imports_items set process='importing' where process='import' and is_deleted='0' and batch_table_id="+escape.cote(batchId)
                +" and site_id="+escape.cote(siteId));
                try{
                    while(rs2.next()){
                        JSONObject tempDataObj=new JSONObject();
                        tempDataObj.put("item_data",new JSONObject(PagesUtil.decodeJSONStringDB(rs2.value("item_data"))));
                        tempDataObj.put("name",rs2.value("name"));
                        tempDataObj.put("type",rs2.value("type"));
                        tempDataObj.put("error",rs2.value("error"));
                        tempDataObj.put("item_id",rs2.value("id"));


                        itemsList.put(tempDataObj);
                    }
                }catch(Exception e){
                    Etn.executeCmd("update batch_imports set status='import error',info='',message='Invalid json. Use another file.' where id="+
                    escape.cote(batchId)+" and is_deleted='0'");
                    Etn.executeCmd("update batch_imports_items set process='import error' where batch_table_id="+escape.cote(batchId)+" and is_deleted='0'");
                    e.printStackTrace();
                    throw new Exception("Invalid json. Use another file.",e);
                }
                
                if("replace".equals(importType)){
                    importType += "_" + importTypeReplace;
                }

                if(importDatetime){
                    //import date time only allowed for super admin profile
                    importDatetime = Boolean.parseBoolean(isSuperAdmin);
                }

                int importCount = 0;
                String errorIds = "";

                HashMap<String, Integer> opHM = new HashMap<>();
                opHM.put("insert", 0);
                opHM.put("update", 0);
                opHM.put("skip", 0);
                String process="";
                String stats="";
                EntityImport entityImport = new EntityImport(Etn, siteId, importDatetime, targetCatalogId, Integer.parseInt(createdBy));
                for (int i=0; i<itemsList.length(); i++ ) {
                    String curItemId = "";
                    String itemErrorMsg="";
                    try{
                        JSONObject curItem = itemsList.getJSONObject(i);

                        curItemId = curItem.getString("item_id");
                        JSONObject curItemData = curItem.getJSONObject("item_data");
                        JSONObject dataObj = new JSONObject();
                        String curItemError = entityImport.verifyImportItem(curItemData, dataObj);
                        process="imported";
                        stats="existing";
                        if(curItemError.length() > 0){
                            System.out.println("curItemError=============="+curItemError);
                            process="import error";
                            stats="error";
                            itemErrorMsg="Invalid item.";
                        }
                        else{   
                            String operation = entityImport.importItem(curItemData, importType);
                            importCount++;

                            JSONObject sysInfo = curItemData.getJSONObject("system_info");
                            
                            if(operation.equalsIgnoreCase("skip")){
                                if(skipedItems.length()>0){
                                    skipedItems += "#"+curItemId+":"+sysInfo.getString("name").trim();
                                }else{
                                    skipedItems = curItemId+":"+sysInfo.getString("name").trim();
                                }
                            }else if(operation.equalsIgnoreCase("update")){
                                if(updatedItems.length()>0){
                                    updatedItems += "#"+curItemId+":"+sysInfo.getString("name").trim();
                                }else{
                                    updatedItems = curItemId+":"+sysInfo.getString("name").trim();
                                }
                            }

                            Integer opCount = opHM.get(operation);
                            if(opCount != null){
                                opHM.put(operation, opCount.intValue() + 1);
                            }
                        }
                        Etn.executeCmd("update batch_imports_items set process="+escape.cote(process)+",status="+escape.cote(stats)+
                            ",error="+escape.cote(itemErrorMsg)+" where process='importing' and is_deleted='0' and batch_table_id="+escape.cote(batchId)+" and site_id="+
                            escape.cote(siteId)+" and id="+escape.cote(curItemId));
                    }
                    catch(Exception itemEx){

                        System.out.println("===========Error occured for item===========");
                        Etn.executeCmd("update batch_imports_items set process='import error',status='error',error="+escape.cote(itemEx.getMessage())
                        +" where process='importing' and is_deleted='0' and batch_table_id="+escape.cote(batchId)+" and site_id="+
                        escape.cote(siteId)+" and id="+escape.cote(curItemId));
                        
                        itemEx.printStackTrace();
                        errorIds += curItemId+":" +itemEx.getMessage()+ ", ";
                    }
                }//for

                if(errorIds.length() > 0){
                    errorIds=errorIds.substring(0, errorIds.length() - 1);
                }

                // deleteInvalidStructuredPages(Etn);//cleanup after import
                String btn1="<button type='button' title=\"See updated items\" class='btn btn-primary' onclick='showItems(\"update\","+batchId+")'>Updated</button>";
                String btn2="<button type='button' title=\"See skipped items\" class='btn btn-warning' onclick='showItems(\"skipp\","+batchId+")'>Skipped</button>";
                msg = "" + importCount + " of " + itemsList.length()
                    + " items were imported. "
                    + opHM.get("insert") + " new, "
                    + opHM.get("update")+" "+btn1 + " and "
                    + opHM.get("skip") +" "+btn2;

                process="imported";
                
                if(errorIds.length() != 0){
                    errorIds=errorIds.replace(",","<br>");
                    btn2="<button type=\"button\" title=\"See Error\" class=\"btn btn-danger\" onclick='showErrors(\""+errorIds+"\")'>Error</button>";
                    msg += "<br> Error items : " +errorIds.split("<br>").length+" "+ btn2;
                    process="import error";		
                }
                if(importCount == 0){
                    msg = "<br> Error in importing all file/files.";
                    process="import error";	
                }
                Etn.executeCmd("update batch_imports set status="+escape.cote(process)+",info='',message="+escape.cote(msg)+
                ",updated_items="+escape.cote(updatedItems)+",skipped_items="+escape.cote(skipedItems)+" where id="+
                escape.cote(batchId)+" and is_deleted='0'");
                System.out.println("===========Ending import batch===========");
            }//if end
        }catch(Exception ex){
            ex.printStackTrace();
            throw new Exception("Error in importing data. Please try again.",ex);
        }
    }

}