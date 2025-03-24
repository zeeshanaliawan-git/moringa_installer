<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="java.sql.SQLException,com.etn.beans.app.GlobalParm,java.util.UUID, com.etn.sql.escape, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, com.etn.asimina.util.ActivityLog, java.util.LinkedHashMap"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%!
    String deleteFolders(Contexte Etn,String ids){
        String returnFolders="";
        String[] idArray = ids.split(",");
        for(int i=0;i<idArray.length;i++){
            Set rs=Etn.execute("select id from tags where folder_id ="+escape.cote(idArray[i])+" union select id from tags_folders where parent_folder_id="+escape.cote(idArray[i]));
            if(rs.rs.Rows>0){
                rs= Etn.execute("select * from tags_folders where id="+escape.cote(idArray[i]));
                if(rs.next()){

                    if(returnFolders.length()>0){
                        returnFolders+=","+rs.value("name");
                    }else{
                        returnFolders=rs.value("name");
                    }
                }
            }else{
                Etn.executeCmd("Delete from tags_folders where id="+escape.cote(idArray[i]));
            }
        }
        return returnFolders;

    }

    void updateTagData(Contexte Etn, Set details, String type,String oldId, String newId,String pagesDb,String siteId) {
        String tableName = type.equals("structure") ? ".structured_contents_details" : ".blocs_details";
        String dataColumn = type.equals("structure") ? "content_data" : "template_data";
        String idColumn = type.equals("structure") ? "content_id" : "bloc_id";

        String updateQuery = "update "+pagesDb+tableName+" SET "+dataColumn+" = REPLACE("+dataColumn+","+
            escape.cote("\""+oldId+"\"")+","+escape.cote("\""+newId+"\"")+") where "+dataColumn + 
            " LIKE '%[[%\"" + oldId + "\"%]]%'";
        
        Etn.execute(updateQuery);
        while (details.next()) {
            String contentId = details.value(idColumn);
            String oldContentData = details.value(dataColumn);
            String langueId = details.value("langue_id");

            Set newContentData = Etn.execute("SELECT " + dataColumn + " FROM " + pagesDb + tableName + " WHERE " + 
                idColumn + " = " + escape.cote(contentId) +" AND langue_id = " + escape.cote(langueId)+ " ");
            String newData = newContentData.next() ? newContentData.value(dataColumn) : "";

            Etn.executeCmd("INSERT INTO " + pagesDb + ".tags_history (lang_id, item_id, item_type, old_data, new_data, updated_by, created_ts) VALUES (" + escape.cote("" + langueId) + 
                "," + escape.cote(contentId) + "," + escape.cote(type) + "," + escape.cote(oldContentData) + "," + escape.cote(newData) + "," + escape.cote("" + Etn.getId()) + 
                ", NOW())");

            if (type.equals("bloc")) {
                Set pageIds = Etn.execute("SELECT distinct parent_page_id FROM " + pagesDb + 
                    ".pages where id IN (SELECT page_id FROM " + pagesDb + ".pages_blocs WHERE type = 'freemarker' and bloc_id = " +
                     escape.cote(contentId) +" )");

                while (pageIds.next()){
                    Etn.executeCmd("UPDATE "+pagesDb+".freemarker_pages SET to_generate=1, updated_by="+
                        escape.cote(""+Etn.getId())+", to_generate_by="+escape.cote(""+Etn.getId())+
                        ", updated_ts=NOW() WHERE id=" + escape.cote(pageIds.value("parent_page_id")));
                } 
            } else {
                Etn.executeCmd("UPDATE "+pagesDb+".structured_contents SET to_generate=1, updated_by=" + 
                    escape.cote(""+Etn.getId())+", to_generate_by="+escape.cote(""+Etn.getId())+", updated_ts=NOW() WHERE id=" +
                    escape.cote(contentId));
            }
        }
    }
   

    JSONArray getFoldersData(Contexte Etn,String siteId,String parentFolderId){
        JSONArray folderArray = new JSONArray();
        Set rs = Etn.execute("select * from tags_folders where site_id="+escape.cote(siteId)+" and parent_folder_id="+escape.cote(parentFolderId)+" and is_deleted=0");
        while(rs.next()){
            JSONObject folderObj = new JSONObject();

            for(String colName:rs.ColName){
                if(colName.equalsIgnoreCase("id")){
                    folderObj.put("childFolder",getFoldersData(Etn,siteId,rs.value("id")));
                }
                folderObj.put(colName.toLowerCase(),rs.value(colName));
            }
            folderArray.put(folderObj);
        }
        return folderArray;
    }

    void moveTagsToParent(Contexte Etn,String siteId,String moveToFolderId,String tagFolders) throws SQLException {
        String folderToTiverse = tagFolders;
        if(folderToTiverse.length() == 0) folderToTiverse = moveToFolderId;
        
        Set rsChildFolders = Etn.execute("select id from tags_folders where parent_folder_id="+escape.cote(folderToTiverse));
        while(rsChildFolders.next()){
            moveTagsToParent(Etn,siteId,moveToFolderId,parseNull(rsChildFolders.value("id")));
        }

        if(tagFolders.length()>0){
            Set rsTags = Etn.execute("select id from tags where folder_id="+escape.cote(tagFolders));
            String tagIds = "";
            while(rsTags.next()){
                if(tagIds.length()>0) tagIds+=",";
                tagIds+=parseNull(rsTags.value("id"));
            }
            if(moveTagToFolder(Etn,siteId,tagIds,moveToFolderId,true).length()==0) Etn.executeCmd("delete from tags_folders where id="+escape.cote(tagFolders));
        }
    }

    String moveTagToFolder(Contexte Etn,String siteId,String tagIds,String folderId) throws SQLException{
        return moveTagToFolder(Etn,siteId,tagIds,folderId,false);
    }

    String moveTagToFolder(Contexte Etn,String siteId,String tagIds,String folderId,boolean moveToParent) throws SQLException{
        
        String PAGES_DB = GlobalParm.getParm("PAGES_DB");
        String[] tagsArray=tagIds.split(",");
        String folderLabelId = "";
        String respString="";

        Set rs = Etn.execute("select * from tags_folders where id="+escape.cote(folderId));
        if(rs.next()){
            folderLabelId="$"+rs.value("folder_id");
        }

        if(folderId.equalsIgnoreCase("0")){
            folderId="";
        }
        
        for(int i=0;i<tagsArray.length;i++){
            rs=Etn.execute("select * from tags where id="+escape.cote(tagsArray[i])+" and site_id="+escape.cote(siteId));
            if(rs.next()){
                String oldTagId = tagsArray[i];
                String newTagId = tagsArray[i];

                if(oldTagId.indexOf('$')>=0) newTagId=oldTagId.replace(oldTagId.substring(oldTagId.indexOf('$')),folderLabelId);
                else newTagId+=folderLabelId;

                rs=Etn.execute("select * from tags where id="+escape.cote(newTagId)+" and site_id="+escape.cote(siteId));
                if(rs.rs.Rows>0){
                    if(moveToParent){
                        Etn.executeCmd("update catalog_tags ct JOIN catalogs c ON c.id = ct.catalog_id set ct.tag_id="+escape.cote(newTagId)+
                            " WHERE  c.site_id = " + escape.cote(siteId)+ " AND ct.tag_id = " + escape.cote(oldTagId));

                        Etn.executeCmd("update product_tags pt JOIN products p ON p.id = pt.product_id JOIN catalogs c ON c.id = p.catalog_id  "
                            + " set pt.tag_id = " + escape.cote(newTagId)+" WHERE  c.site_id = " + escape.cote(siteId)+ " AND pt.tag_id = " + escape.cote(oldTagId));

                        Etn.executeCmd(" update "+PAGES_DB+".blocs b JOIN "+PAGES_DB+".blocs_tags bt ON b.id = bt.bloc_id set bt.tag_id = "+escape.cote(newTagId)
                            +" WHERE b.site_id = " + escape.cote(siteId)+" AND bt.tag_id = " +  escape.cote(oldTagId));

                        Etn.executeCmd(" update "+PAGES_DB+".pages_tags pt JOIN "+PAGES_DB+".pages p ON case when p.type='react' then p.id else p.parent_page_id end = pt.page_id and p.type = pt.page_type "
                            + " set pt.tag_id = " + escape.cote(newTagId)+" WHERE  p.site_id = " + escape.cote(siteId)+ " AND pt.tag_id = " + escape.cote(oldTagId));
                        
                        Etn.executeCmd(" update "+PAGES_DB+".media_tags pt JOIN "+PAGES_DB+".files p ON p.id = pt.file_id "
                            + " set pt.tag = " + escape.cote(newTagId)+" WHERE  p.site_id = " + escape.cote(siteId)+ " AND pt.tag = " + escape.cote(oldTagId));
                        
                        Etn.executeCmd("delete from tags where id="+escape.cote(oldTagId)+" and site_id="+escape.cote(siteId));
                        respString="";
                    }else{
                        if(respString.length()>0) respString+=",";
                        respString+=tagsArray[i];
                    }
                }else{
                    Etn.executeCmd("update tags set id="+escape.cote(newTagId)+",folder_id="+escape.cote(folderId)+" where site_id="+
                        escape.cote(siteId)+" and id="+escape.cote(oldTagId));

                    Etn.executeCmd("update catalog_tags ct JOIN catalogs c ON c.id = ct.catalog_id set ct.tag_id="+escape.cote(newTagId)+
                        " WHERE  c.site_id = " + escape.cote(siteId)+ " AND ct.tag_id = " + escape.cote(oldTagId));

                    Etn.executeCmd("update product_tags pt JOIN products p ON p.id = pt.product_id JOIN catalogs c ON c.id = p.catalog_id  "
                        + " set pt.tag_id = " + escape.cote(newTagId)+" WHERE  c.site_id = " + escape.cote(siteId)+ " AND pt.tag_id = " + escape.cote(oldTagId));

                    Etn.executeCmd(" update "+PAGES_DB+".blocs b JOIN "+PAGES_DB+".blocs_tags bt ON b.id = bt.bloc_id set bt.tag_id = "+escape.cote(newTagId)
                        +" WHERE b.site_id = " + escape.cote(siteId)+" AND bt.tag_id = " +  escape.cote(oldTagId));

                    Etn.executeCmd(" update "+PAGES_DB+".pages_tags pt JOIN "+PAGES_DB+".pages p ON case when p.type='react' then p.id else p.parent_page_id end = pt.page_id and p.type = pt.page_type "
                        + " set pt.tag_id = " + escape.cote(newTagId)+" WHERE  p.site_id = " + escape.cote(siteId)+ " AND pt.tag_id = " + escape.cote(oldTagId));
                    
                    Etn.executeCmd(" update "+PAGES_DB+".media_tags pt JOIN "+PAGES_DB+".files p ON p.id = pt.file_id "
                        + " set pt.tag = " + escape.cote(newTagId)+" WHERE  p.site_id = " + escape.cote(siteId)+ " AND pt.tag = " + escape.cote(oldTagId));
                        
                    Etn.executeCmd("UPDATE payment_n_delivery_method_excluded_items SET item_id = " + escape.cote(newTagId) + 
                        " WHERE item_type = 'tag' AND site_id =" + escape.cote(siteId)+ " AND item_id = " + escape.cote(oldTagId));

                    Etn.executeCmd("UPDATE variant_tags vt JOIN product_variants pv ON vt.variant_id = pv.id"+
                        " JOIN products p ON pv.product_id = p.id JOIN catalogs c ON p.catalog_id = c.id"+
                        " SET vt.tag_id = "+escape.cote(newTagId)+
                        " WHERE vt.tag_id = " + escape.cote(oldTagId)+" AND c.site_id = " + escape.cote(siteId));
                    // ---------------Added by Awais---------------------//
                    Set structuredContentDetail=Etn.execute("select content_id,content_data,langue_id from "+PAGES_DB+
                        ".structured_contents_details where content_data LIKE '%[[%\""+oldTagId+"\"%]]%'");
                    if (structuredContentDetail.rs.Rows>0 ) updateTagData(Etn, structuredContentDetail, "structure",oldTagId,newTagId,PAGES_DB,siteId);
                    
                    Set blocDetail = Etn.execute("select bloc_id, langue_id, template_data from " + PAGES_DB + 
                        ".blocs_details where template_data LIKE '%[[%\""+oldTagId+"\"%]]%'");
                    if (blocDetail.rs.Rows>0 )  updateTagData(Etn, blocDetail, "bloc",oldTagId,newTagId,PAGES_DB,siteId);
                    
                    //--------------------------------------------------//
                }
            }else{
                if(respString.length()>0) respString+=","+tagsArray[i];
                else respString=tagsArray[i];
            }
        }
        return respString;
    }
%>
<%
    JSONObject jsonResponse = new JSONObject();

    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";

    String requestType = parseNull(request.getParameter("requestType"));

    String siteId = getSelectedSiteId(session);

    try{
        if("saveFolder".equalsIgnoreCase(requestType)){
            try{

                int maxFolderLevel = Integer.parseInt(GlobalParm.getParm("MAX_TAG_FOLDER_LEVEL"));
                String parentFolderId = parseNull(request.getParameter("parentFolderId"));
                String label = parseNull(request.getParameter("label")).replaceAll(",","");
                String folderId = parseNull(request.getParameter("label")).toLowerCase().replace(" ", "-").replaceAll(",","");

                if(label.length() == 0 ){
                    throw new SimpleException("Error: label cannot be empty");
                }

                int folder_level=0;
                String parentFolder="";

                String q = " SELECT * FROM tags_folders "
                    + " WHERE folder_id = " + escape.cote(folderId)
                    + " AND is_deleted=0 and site_id = " + escape.cote(siteId);
                
                if(parentFolderId.length() > 0){

                    Set rsFolder = Etn.execute("select id,folder_level+1 as fl,folder_id from tags_folders where uuid="+escape.cote(parentFolderId));
                    if(rsFolder.next()){
                        folder_level=Integer.parseInt(parseNull(rsFolder.value("fl")));
                        parentFolder="$"+parseNull(rsFolder.value("folder_id"));
                        parentFolderId=parseNull(rsFolder.value("id"));
                    }

                    q+=" and parent_folder_id="+escape.cote(parentFolderId);
                }

                Set rs = Etn.execute(q);
                if(rs.next()){
                    throw new SimpleException("Error: Folder already exists.");
                }

                if(folder_level>maxFolderLevel){
                    throw new SimpleException("Error: Folder at level "+folder_level+" can not be created.");
                }

                String uuid = UUID.randomUUID().toString();

                //add new
                q = "INSERT INTO tags_folders(folder_id,uuid,name,";
                if(parentFolderId.length() > 0) {
                    q+="parent_folder_id,";
                    folderId=folderId+parentFolder;
                }
                
                q+="folder_level,site_id, updated_by, created_by) VALUES ("+ escape.cote(folderId) + ", "+ escape.cote(uuid) + ", "+ escape.cote(label) + ", ";

                if(parentFolderId.length() > 0) q+= escape.cote(parentFolderId) + ", ";

                q+= escape.cote(""+folder_level) + ", "+ escape.cote(siteId) + ", "+ escape.cote(""+Etn.getId()) + ", "+ escape.cote(""+Etn.getId()) + ") ";
                
                int count = Etn.executeCmd(q);
                if(count < 1){
                    throw new SimpleException("Error in adding new folder.");
                }else{
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),folderId,"CREATED","Folder",label,siteId);
                }

                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                message = "Error in saving folder. Please try again.";
                throw new SimpleException(message, ex);
            }

        }else if("deleteFolders".equalsIgnoreCase(requestType)){
            String ids = parseNull(request.getParameter("ids"));
            String rspFolders=deleteFolders(Etn,ids);

            if(rspFolders.length() > 0){
                message = "Non empty folders "+rspFolders+" can not be deleted.";
                status=STATUS_ERROR;
            }else{
                message = "Folder(s) deleted successfully.";
                status=STATUS_SUCCESS;
            }
        }else if("getListForViews".equalsIgnoreCase(requestType)){
            jsonResponse.put("data",getFoldersData(Etn,siteId,"0"));
            status=STATUS_SUCCESS;

        }else if("moveTags".equalsIgnoreCase(requestType)){
            String tagIds = parseNull(request.getParameter("tagIds"));
            String moveToFolderId = parseNull(request.getParameter("moveToFolderId"));
            String rsp=moveTagToFolder(Etn,siteId,tagIds,moveToFolderId);

            if(rsp.length() > 0){
                message = "Duplicate tag(s): "+rsp;
                status=STATUS_ERROR;
            }else{
                message = "Tag(s) moved successfully.";
                status=STATUS_SUCCESS;
            }
        }else if("moveTagsToParent".equalsIgnoreCase(requestType)){
            Set rsTagsFolders = Etn.execute("select id,name from tags_folders where COALESCE(parent_folder_id,'0')='0' and site_id="+escape.cote(siteId));
            while(rsTagsFolders.next()){
                moveTagsToParent(Etn,siteId,parseNull(rsTagsFolders.value("id")),"");
            }
        }
    }
    catch(SimpleException ex){
        message = ex.getMessage();
        ex.print();
    }

    
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    out.write(jsonResponse.toString());
%>
