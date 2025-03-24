<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,java.time.LocalDateTime,java.time.format.DateTimeFormatter,  com.etn.asimina.util.ActivityLog, com.etn.pages.*, com.github.wnameless.json.flattener.JsonFlattener"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%!

    LocalDateTime parseAndFormat(String timer){
        
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

        LocalDateTime timeFormatter=null;
        try {
            timeFormatter = LocalDateTime.parse(timer, formatter);
        } catch (Exception e) {
            LocalDateTime dateTime = LocalDateTime.parse(timer, inputFormatter);
            String formated = dateTime.format(formatter);
            timeFormatter = LocalDateTime.parse(formated, formatter);
        }
        return timeFormatter;
    }
    boolean deleteFolderFunc(Contexte Etn, String id, String siteId, String folderType) throws SimpleException {
        final String folderTable = getFolderTableName(folderType);
        try {
            String q = " SELECT id, name "
                       + " FROM " + folderTable
                       + " WHERE id = " + escape.cote(id)
                       + " AND site_id = " + escape.cote(siteId);
            Set rs = Etn.execute(q);
            if (!rs.next()) {
                return false;
            }

            String curName = rs.value("name");

            q = "SELECT id from ("
                + "  SELECT id FROM " + folderTable
                + "  WHERE parent_folder_id = " + escape.cote(id)
                + "  AND site_id = " + escape.cote(siteId);

            if (folderType.equals(Constant.FOLDER_TYPE_CONTENTS)) {
                q += " UNION ALL"
                     + "  SELECT id FROM structured_contents "
                     + "  WHERE folder_id= " + escape.cote(id)
                     + "  AND site_id = " + escape.cote(siteId)
                     + "  AND type = 'content' ";
            }
            else {
                // bloc
                q += " UNION ALL"
                     + "  SELECT id FROM freemarker_pages "
                     + "  WHERE folder_id= " + escape.cote(id)
                     + "  AND site_id = " + escape.cote(siteId)
                     + " AND  is_deleted = '0'";
                // structured
                q += " UNION ALL"
                     + "  SELECT id FROM structured_contents "
                     + "  WHERE folder_id= " + escape.cote(id)
                     + "  AND site_id = " + escape.cote(siteId)
                     + "  AND type = 'page' ";
            }
            q += ") count_table";

            rs = Etn.execute(q);
            if (rs.rs.Rows > 0) {
                return false;
            }
            Etn.executeCmd("update "+folderTable+" set deleted_by = "+escape.cote(""+Etn.getId())+", updated_by="+escape.cote(""+Etn.getId())+", updated_ts = now(), is_deleted='1' WHERE id = " + escape.cote(id)+" AND site_id = " + escape.cote(siteId));

            return true;
        }//try
        catch (Exception ex) {
            throw new SimpleException("Error in deleting folders.", ex);
        }
    }
	void getSectionsForBulkModif(com.etn.beans.Contexte Etn, List<String> sections, String sectionId, String customIdPath)
	{
		Set rs = Etn.execute("select * from bloc_templates_sections where parent_section_id = "+escape.cote(sectionId));
		while(rs.next())
		{
			//if a section can be added more than one time means the complete section will be overwritten in the final jsons
			//because if the source store has that section once and the buld modif has it say twice so we dont know how to merge them
			//so assumption is if section can be added more than once we just overwrite that complete section in store json
			if("1".equals(rs.value("nb_items")))
			{
				sections.add(customIdPath + "." + rs.value("custom_id"));
				getSectionsForBulkModif(Etn, sections, rs.value("id"), customIdPath + "." + rs.value("custom_id"));
			}
		}
	}

    Boolean verifyKeyForAppend(String key,JSONArray bulkMapCheck){
        for(Object obj : bulkMapCheck){
            JSONObject json = (JSONObject)obj;
            if(json.has(key)){
                Object valueAtIndex = json.getJSONArray(key).get(json.getJSONArray(key).length()-1);
                if (valueAtIndex instanceof String) return Boolean.valueOf(valueAtIndex.toString());
            }
        }
        return null;
    }

    int getNbItemsFromTemplate(JSONArray templateData, String keyPath, String itemType){
        String[] keys = keyPath.split("\\.",2);
        for(Object obj : templateData){
            JSONObject curObject = (JSONObject) obj;
            if(curObject.getString("custom_id").equals(keys[0])){
                if(keys.length==1) return Integer.parseInt(curObject.getString("nb_items"));
                else{
                    if(itemType.equals("section")) return getNbItemsFromTemplate(curObject.getJSONArray("sections"),keys[1],itemType);
                    else{
                        if(keys[1].split("\\.",2).length>1) return getNbItemsFromTemplate(curObject.getJSONArray("sections"),keys[1],itemType);
                        else return getNbItemsFromTemplate(curObject.getJSONArray("fields"),keys[1],itemType);
                    }
                }
            }
        }
        return 1;
    }

    void fillErrMsg(JSONObject errMsg,String type,String track){
        String errItem ="";
        if(errMsg.has(type)) errItem = errMsg.getString(type);
        if(errItem.length() > 0) errItem+=", ";

        errItem+=track;
        errMsg.put(type, errItem);
    }

    void getNewStoreJson(JSONObject newStoreData,JSONObject oldStoreData,JSONArray bulkMapCheck,JSONArray templateData,String track,String generalTrack,JSONObject errMsg,String oldDataTrack){
        for (String key : newStoreData.keySet()) {
            if(track.length() > 0)  {
                track+="."; generalTrack+="."; oldDataTrack+=".";
            }
            track+=key; generalTrack+=key; oldDataTrack+=key;

            if(oldStoreData.has(key)){
                JSONArray jsonArray = newStoreData.getJSONArray(key);
                if(jsonArray.get(0) instanceof String || jsonArray.get(0) instanceof JSONArray){
                    Boolean appendCheck = verifyKeyForAppend(track,bulkMapCheck);
                    if(appendCheck == null || !appendCheck) oldStoreData.getJSONArray(key).clear();

                    int nbItems = getNbItemsFromTemplate(templateData,generalTrack,"field");
                    if(oldStoreData.getJSONArray(key).length()<nbItems || nbItems == 0)
                        for(Object obj : jsonArray){
                            if(obj instanceof JSONArray){
                                if((appendCheck != null && appendCheck) && oldStoreData.getJSONArray(key).length()>0){
                                    JSONArray tmpArray = (JSONArray)obj;
                                    for(Object objTmp : tmpArray) oldStoreData.getJSONArray(key).getJSONArray(0).put(objTmp.toString());
                                }else oldStoreData.getJSONArray(key).put((JSONArray)obj);
                            }else oldStoreData.getJSONArray(key).put(obj.toString());
                        }
                    else fillErrMsg(errMsg,"fields",oldDataTrack);
                }else{
                    int count =1;
                    for(Object obj : jsonArray){
                        Boolean appendCheck = verifyKeyForAppend(track+"_"+count,bulkMapCheck);
                        if(appendCheck != null && appendCheck){
                            int nbItems = getNbItemsFromTemplate(templateData,generalTrack,"section");
                            if(oldStoreData.getJSONArray(key).length()<nbItems || nbItems == 0) oldStoreData.getJSONArray(key).put((JSONObject)obj);
                            else fillErrMsg(errMsg,"sections",oldDataTrack);
                        }else{
                            int count2=1;
                            for(Object obj2 : oldStoreData.getJSONArray(key)){
                                getNewStoreJson((JSONObject)obj,(JSONObject)obj2,bulkMapCheck,templateData,track+"_"+count,generalTrack,errMsg,oldDataTrack+"_"+count2);
                                count2++;
                            }
                        }
                        count++;
                    }
                }
                if (track.lastIndexOf('.') != -1) track = track.substring(0, track.lastIndexOf('.'));
                else track="";
                
                if (generalTrack.lastIndexOf('.') != -1) generalTrack = generalTrack.substring(0, generalTrack.lastIndexOf('.'));
                else track="";
            }else oldStoreData.put(key,newStoreData.getJSONArray(key));
        }
    }

    void bulkModifyStore(com.etn.beans.Contexte Etn,JSONObject newStoreData,JSONArray templateData,String storeIds,JSONArray bulkMapCheck,String langId,JSONArray errArray){

        for(int i=0;i<storeIds.split(",").length;i++){
            String storeId = storeIds.split(",")[i];
            Set rs = Etn.execute("select scd.content_data,sc.name from structured_contents_details scd left join structured_contents sc on scd.content_id = sc.id "+
                "where scd.langue_id ="+escape.cote(langId) + " and scd.content_id ="+escape.cote(storeId));
			if(rs.next())
			{
				JSONObject oldStoreData = new JSONObject(PagesUtil.decodeJSONStringDB(rs.value("content_data")));
                
                JSONObject errMsgObj = new JSONObject();
                getNewStoreJson(newStoreData,oldStoreData,bulkMapCheck,templateData,"","",errMsgObj,"");
                if(!errMsgObj.isEmpty()){
                    errMsgObj.put("store",parseNull(rs.value("name")));
                    errArray.put(errMsgObj);
                }
                
                Etn.executeCmd("update structured_contents_details set content_data = "+escape.cote(PagesUtil.encodeJSONStringDB(oldStoreData.toString()))+
                    " where langue_id ="+escape.cote(langId) + " and content_id ="+escape.cote(storeId));
				
				String updQry = "update structured_contents set updated_ts = now(), updated_by = "+escape.cote(""+Etn.getId());
				Set _rsP = Etn.execute("select * from pages where type='structured' and parent_page_id = "+escape.cote(storeId));
				if(_rsP.rs.Rows > 0)
				{
					System.out.println("Store has pages associated so we must mark for regenerate. Store Id : "+storeId);
					updQry += ", to_generate = 1, to_generate_by = "+escape.cote(""+Etn.getId());
				}
				updQry += " where id ="+escape.cote(storeId);
				Etn.executeCmd(updQry);
            }
        }
    }
	
    boolean sectionHasFieldsToModify(JSONObject section)
	{
		JSONArray bulkModifySections = new JSONArray();
		if(section.has("sections") && section.getJSONArray("sections").length() > 0)
		{
			JSONArray innertSections = section.getJSONArray("sections");
			for(int i=0; i<innertSections.length();i++)
			{
				if(sectionHasFieldsToModify(innertSections.getJSONObject(i))) bulkModifySections.put(innertSections.get(i));
			}
		}
		if((section.has("fields") && section.getJSONArray("fields").length() > 0) || bulkModifySections.length() > 0)
		{
			section.remove("sections");
			section.put("sections", bulkModifySections);
			return true;
		}
		return false;
	}

    ArrayList<String> getValidContentIds(com.etn.beans.Contexte Etn, String contentIds, String siteId){
		ArrayList<String> contentIdList = new ArrayList<>();

		for(String contentIdStr : contentIds.split(",")){
		    int contentId = parseInt(contentIdStr,0);
		    if(contentId > 0){
		        String q = " SELECT id FROM structured_contents"
		            + " WHERE id = " + escape.cote(""+contentId)
		            + " AND site_id = " + escape.cote(siteId);
		        Set rs = Etn.execute(q);
		        if(rs.next()){
		           contentIdList.add(""+contentId);
		        }
		    }
		}

		return contentIdList;
	}

    JSONObject moveContent(Contexte Etn, String id, String moveToFolderId, String siteId){
        boolean status = false;
        String message  =  "";

        String q = "SELECT id FROM structured_contents"
              +" WHERE folder_id = "+escape.cote(moveToFolderId)
              +" AND name = ( SELECT name FROM structured_contents WHERE id = "+escape.cote(id)+" )";
        Set rs =  Etn.execute(q);
        if(rs.next()){
            message = "Structured data with this name already exists";
        }else{
            q = "UPDATE structured_contents SET folder_id = "+escape.cote(moveToFolderId)
                  +", updated_by = "+escape.cote(""+Etn.getId())
                  +", updated_ts = NOW()"
                  +" WHERE id = "+escape.cote(id)+" AND site_id = "+escape.cote(siteId);
            int res = Etn.executeCmd(q);
            if(res > 0){
                status = true;
            }
        }
         JSONObject retObject = new JSONObject();
         retObject.put("status", status);
         retObject.put("message", message);
        return retObject;
    }

    JSONObject moveFolder(Contexte Etn, String id, String moveToFolderId, int moveToFolderLevel, String siteId){
         boolean status = false;
         String q = "";
         String message = "Cannot move this folder";
         // duplicate folder name check
         q = "SELECT id FROM structured_contents_folders"
             +" WHERE parent_folder_id = "+escape.cote(moveToFolderId)
             +" AND site_id = "+escape.cote(siteId)
             +" AND name = ( SELECT name from structured_contents_folders WHERE id = "+escape.cote(id)+" )";

         Set rs = Etn.execute(q);
        if(rs.next()){
            message = "Folder with this name already exsits";
        }else{
             if(!id.equals(moveToFolderId)){
                 if(moveToFolderLevel < 2){
                     q = "SELECT id FROM structured_contents_folders WHERE parent_folder_id = "+escape.cote(id)+" AND site_id = "+escape.cote(siteId);
                     rs = Etn.execute(q);
                     if(!rs.next()){ // if folder has child folders then it will not be moved
                         q = "UPDATE structured_contents_folders "
                         + " SET parent_folder_id = "+escape.cote(moveToFolderId)+", folder_level = "+escape.cote(moveToFolderLevel+1+"")
                         + " WHERE id = "+escape.cote(id)+" AND site_id = "+escape.cote(siteId);
                         int res = Etn.executeCmd(q);
                         if(res > 0){
                             status = true;
                         }
                     }else{
                          message = "Folder has child folders, it cannot be moved";
                     }
                 }else{
                     message = "Folders not allowed at this folder level";
                 }
             }
        }
         JSONObject retObject = new JSONObject();
         retObject.put("status", status);
         retObject.put("message", message);
         return retObject;
    }

    String getContentName(Contexte Etn ,String id, String type){
        String tableName = "structured_contents";
        if(type.equals("folder")){
            tableName = "structured_contents_folders";
        }
        if(id.length()>0){
            String q = "SELECT name FROM "+tableName+" WHERE id ="+escape.cote(id);
            Set rs = Etn.execute(q);
            if(rs.next()){
                return parseNull(rs.value("name")) ;
            } else {
                return "";
            }
        } else {
            return "";
        }
    }

    ArrayList<String> saveStructuredLangPages(Contexte Etn, HttpServletRequest request, boolean isNew,
        String siteId, List<Language> langsList, HttpSession session, String parentId ) throws SimpleException{

	    ArrayList<String> pageIds = new ArrayList<>();
	    try{
            String folderType = parseNull(request.getParameter("folderType"));
            boolean status = true;
            String message = "";

            for(Language curLang : langsList){
                status = true;
                JSONObject parameters =  getPageParametersJson(request, curLang.getLanguageId());
                int pageId = parameters.optInt("pageId",0);

                if(folderType.equals(Constant.FOLDER_TYPE_STORE) &&
                    parseNull(parameters.getString("path")).length() == 0 ) { // delete the page if its path is empty in case of update

                    if(pageId > 0){
                        // check page is published or not
                        String q = " SELECT IF( ISNULL(published_ts), 0, 1) AS is_published  "
                            + " FROM pages "
                            + " WHERE id = " + escape.cote(pageId+"")
                            + " AND site_id = " + escape.cote(siteId);
                        Set rs = Etn.execute(q);
                        if(!rs.next()){
                            status = false;
                            message = "Invalid page id";
                        }
                        if( "1".equals(rs.value("is_published")) ){
                            status = false;
                            message = "Published Page path cannot be empty";
                        }else{
                            deletePageCommon(pageId+"", Etn);
                            pageId = 0;
                        }
                    }
                } else{
                    JSONObject res =  savePageCommon(Etn, request, parameters, siteId, session, parentId);
                    JSONObject data = res.getJSONObject("data");
                    status = res.getInt("status")>0;
                    message = res.getString("message");
                    if(status){
                        pageId =  res.getJSONObject("data").getInt("pageId");
                    }
                }
                pageIds.add(pageId+"");

                if(!status){
                    // delete previous pages if new.
                    rollbackPageInsert(Etn, parentId, pageIds, isNew, siteId, Constant.PAGE_TYPE_STRUCTURED);
                    if(message.length()>0){
                        throw new SimpleException(message);
                    }
                    else{
                        throw new SimpleException("Error in saving page. Please try again.");
                    }
                }
            }
            if(pageIds.size() != langsList.size()){
                throw new SimpleException("Error in saving pages. Please try again.");
            }
	    }catch (Exception ex){
            throw new SimpleException("Error in saving pages. Please try again.",ex);
	    }
	    return  pageIds;
    }

    JSONArray convertStringToJSONArray(String input) {
        JSONArray jsonArray = new JSONArray();
        String[] lines = input.split("\\r?\\n");
        for (String line : lines) {
            if (!line.trim().isEmpty()) {
                String[] pairs = line.split(";");
                
                for (String pair : pairs) {
                    if (!pair.trim().isEmpty()) {
                        String[] keyValue = pair.split(":");
                        if(keyValue.length!=2) keyValue = pair.split(",");
                        
                        if (keyValue.length == 3) {
                            JSONObject jsonObject = new JSONObject();
                            jsonObject.put("specLabel", keyValue[0].trim());
                            jsonObject.put("specValue", keyValue[1].trim());
                            jsonObject.put("is_indexed", keyValue[2].trim());

                            jsonArray.put(jsonObject);
                        }
                    }
                }
            }
        }
        return jsonArray;
    }

    void insertChildBlocs(Etn Etn, String parentBlocId, String pageId, String langId) {
        if(parseNull(parentBlocId).length() == 0) return;

        LinkedHashMap<String, String> mapHM = new LinkedHashMap<String, String>();
        mapHM.put("lang_page_id", pageId);
        mapHM.put("bloc_id", parentBlocId);

        String q = getInsertQuery("structure_mappings",mapHM);
        Etn.executeCmd(q);
        Set rs = Etn.execute("SELECT * FROM bloc_tree where langue_id=" + escape.cote(langId) + " and parent_bloc_id ="+ escape.cote(parentBlocId));
        while(rs.next()) {
            insertChildBlocs(Etn,rs.value("bloc_id"),pageId,langId);
        }
    }

    boolean updateProductV2(Contexte Etn, String siteId,JSONObject productObj, String catalogDb) {
        try{
            String variantIds="";
            String productId = productObj.getString("product_id");
            
            Etn.executeCmd("update "+catalogDb+"products set brand_name="+escape.cote(productObj.getString("manufacturer"))+",updated_on=now(),updated_by="+
                escape.cote(Etn.getId()+"")+", version=version+1 where id="+escape.cote(productId));

            Etn.executeCmd("delete from "+catalogDb+"product_tags where product_id="+escape.cote(productId));
            JSONArray tagAry = productObj.getJSONArray("tag");
            for(int i=0 ; i<tagAry.length();i++){
                String tag = parseNull(tagAry.getString(i));
                if(!tag.isEmpty()){
                    Etn.executeCmd("insert into "+catalogDb+"product_tags (product_id,tag_id,created_by,created_on) values ("+escape.cote(productId)+
                        ","+escape.cote(tag)+","+escape.cote(Etn.getId()+"")+",now())");
                }
            }
            
            JSONArray variants = productObj.getJSONArray("variants");
			//System.out.println("----------- variants:"+variants.length());
            for(int i=0 ; i<variants.length();i++){
                JSONObject varObj = variants.getJSONObject(i);
                String varId = varObj.getString("id");
                if(!varId.isEmpty()){
                    varId = escape.cote(varId);
                    if(variantIds.isEmpty()) variantIds+=varId;
                    else variantIds+=","+varId;
                }
            }

            if(variantIds.isEmpty()) variantIds="0";
            Etn.executeCmd("delete from "+catalogDb+"product_variant_details where product_variant_id in (select id from "+catalogDb+"product_variants where id not in ("+
                variantIds+") and product_id="+escape.cote(productId)+")");
            Etn.executeCmd("delete from "+catalogDb+"product_variants where id not in ("+variantIds+") and product_id="+escape.cote(productId));

            for(int i=0 ; i<variants.length();i++){
                JSONObject varObj = variants.getJSONObject(i);

                String variantId = varObj.getString("id");
                if(variantId.isEmpty()){
                    String uuid = UUID.randomUUID().toString();

                    int varId = Etn.executeCmd("insert into "+catalogDb+"product_variants (product_id,uuid,sku,ean,frequency,price,created_by,created_on,updated_by,updated_on,commitment) values ("+
                        escape.cote(productId)+","+escape.cote(uuid)+","+escape.cote(varObj.getString("sku"))+","+escape.cote(varObj.getString("ean"))+","+
                        escape.cote(varObj.getString("frequency"))+","+escape.cote(varObj.getString("price"))+","+escape.cote(""+Etn.getId())+",now(),"+
                        escape.cote(""+Etn.getId())+",now(),"+escape.cote(varObj.getString("commitment"))+")");
						
					System.out.println("---------------- insert into "+catalogDb+"product_variants (product_id,uuid,sku,ean,frequency,price,created_by,created_on,updated_by,updated_on,commitment) values ("+
                        escape.cote(productId)+","+escape.cote(uuid)+","+escape.cote(varObj.getString("sku"))+","+escape.cote(varObj.getString("ean"))+","+
                        escape.cote(varObj.getString("frequency"))+","+escape.cote(varObj.getString("price"))+","+escape.cote(""+Etn.getId())+",now(),"+
                        escape.cote(""+Etn.getId())+",now(),"+escape.cote(varObj.getString("commitment"))+")");

                    if(varId>0){
                        variantId=varId+"";
                        JSONArray langdata = varObj.getJSONArray("lang_data");
                        for(int j=0 ; j<langdata.length();j++){
                            JSONObject langdataObj = langdata.getJSONObject(j);
                            Etn.executeCmd("insert into "+catalogDb+"product_variant_details (product_variant_id,langue_id,name) values ("+escape.cote(""+varId)+
                                ","+escape.cote(langdataObj.getString("lang_id"))+","+escape.cote(langdataObj.getString("name"))+")");
                        }
                        varObj.put("id",varId+"");
                        varObj.put("uuid",uuid);
                    }
                }else{
                    int updatedRows = Etn.executeCmd("update "+catalogDb+"product_variants set sku="+escape.cote(varObj.getString("sku"))+", ean="+escape.cote(varObj.getString("ean"))+
                    ", frequency="+escape.cote(varObj.getString("frequency"))+", price="+escape.cote(varObj.getString("price"))+
                    ", updated_by="+escape.cote(""+Etn.getId())+", updated_on=now(),commitment="+escape.cote(varObj.getString("commitment"))+" where id="+escape.cote(variantId));
					
					System.out.println("------------ update "+catalogDb+"product_variants set sku="+escape.cote(varObj.getString("sku"))+", ean="+escape.cote(varObj.getString("ean"))+
                    ", frequency="+escape.cote(varObj.getString("frequency"))+", price="+escape.cote(varObj.getString("price"))+
                    ", updated_by="+escape.cote(""+Etn.getId())+", updated_on=now(),commitment="+escape.cote(varObj.getString("commitment"))+" where id="+escape.cote(variantId));

                    if(updatedRows>0){
                        JSONArray langdata = varObj.getJSONArray("lang_data");
                        for(int j=0 ; j<langdata.length();j++){
                            JSONObject langdataObj = langdata.getJSONObject(j);
                            Etn.executeCmd("update "+catalogDb+"product_variant_details set name="+escape.cote(langdataObj.getString("name"))+" where langue_id="+
                                escape.cote(langdataObj.getString("lang_id"))+" and product_variant_id="+escape.cote(variantId));
                        }
                    }
                }

                Etn.executeCmd("delete from "+catalogDb+"variant_tags where variant_id="+escape.cote(variantId));
                if(varObj.has("tag")){
                    JSONArray variantTags = varObj.getJSONArray("tag");
                    for(int j=0 ; j<variantTags.length();j++){
                        Etn.executeCmd("insert ignore into "+catalogDb+"variant_tags (variant_id,tag_id,created_on,created_by) values ("+escape.cote(variantId)+","+
                            escape.cote(variantTags.getString(j))+",now(),"+escape.cote(Etn.getId()+"")+")");
                    }
                }
            }
            return true;
        }catch(Exception e){
            e.printStackTrace();
            return false;
        }
    }

%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;
    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();

    String q = "";
    Set rs = null;
    int count = 0;
    String requestType = parseNull(request.getParameter("requestType"));
    String siteId = getSiteId(session);
    boolean isDeleteInvalidPages = false;

    String catalogDb = GlobalParm.getParm("CATALOG_DB")+".";

    try{

        if("getList".equalsIgnoreCase(requestType)){
            // only to get "content" type list not "page" type
            try{

            	String folderUuid = parseNull(request.getParameter("folderId"));
                String folderId = "0";
                if(folderUuid.length()>0){
                    q = "SELECT id FROM structured_contents_folders WHERE uuid =" + escape.cote(folderUuid)
                        + " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);
                    if( rs.next() ){
                        folderId = rs.value("id");
                    }
                    else {
                        folderId = "-1";//invalid folder id provided
                    }
                }

                JSONArray resultList = new JSONArray();
                JSONObject curObj = null;

                q = " SELECT sc.id, sc.name, sc.uuid, 'content' AS row_type, bt.name AS item_type, -1 AS nb_items, sc.publish_status"
                    + " , sc.updated_ts, l1.name AS updated_by "
                    + " , IF(ISNULL( sc.published_ts ),'',CONCAT(sc.published_ts, ' by ',l2.name)) As published_ts "
                	+ " , IF(sc.to_publish=1, CONCAT('Publish on ',DATE_ADD(sc.to_publish_ts , INTERVAL 5 MINUTE)), "
                	+ "       IF(sc.to_unpublish=1,CONCAT('Un-publish on ',DATE_ADD(sc.to_unpublish_ts , INTERVAL 5 MINUTE)) ,'')) AS to_publish_ts "
                	+ " , IF(ISNULL(sc.published_ts), 'unpublished' , IF(sc.updated_ts > sc.published_ts, 'changed' , 'published')) as ui_status  "
                    + " FROM structured_contents sc"
                    + " JOIN bloc_templates bt ON bt.id = sc.template_id "
                    + " LEFT JOIN login l1 on l1.pid = sc.updated_by "
                    + " LEFT JOIN login l2 on l2.pid = sc.published_by "
                    + " LEFT JOIN login l3 on l3.pid = sc.to_publish_by "
                    + " LEFT JOIN login l4 on l4.pid = sc.to_unpublish_by "
                    + " WHERE sc.type = 'content' "
                    + " AND sc.site_id = " + escape.cote(siteId)
                    + " AND sc.folder_id = " + escape.cote(folderId);

                // folders
                q += " UNION ALL "
                    + " SELECT f.id, f.name, f.uuid, 'folder' AS row_type, '' AS item_type, IFNULL(tbcount.tcount,0) AS nb_items, "
                    + " 'published' AS publish_status, f.updated_ts, l1.name AS updated_by "
                    + " , '' AS published_ts, '' AS to_publish_ts, 'published' AS ui_status"
                    + " FROM structured_contents_folders f"
                    + " LEFT JOIN login l1 on l1.pid = f.updated_by "
                    + " LEFT JOIN ("
                    + "     SELECT folder_id, SUM(count)AS tcount"
                    + "     FROM ("
                    + "          SELECT folder_id, count(id) AS count"
                    + "          FROM structured_contents"
                    + "          WHERE folder_id > 0 AND type = 'content'"
                    + "          GROUP BY folder_id"
                    + "        UNION ALL"
                    + "          SELECT parent_folder_id AS folder_id, count(id)"
                    + "          FROM structured_contents_folders pf"
                    + "          WHERE parent_folder_id > 0"
                    + "          GROUP BY parent_folder_id"
                    + "          ) tcount"
                    + "     GROUP BY folder_id"
                    + "   ) tbcount ON tbcount.folder_id = id"
                    + " WHERE site_id = "+escape.cote(siteId)
                    + " AND f.parent_folder_id = " + escape.cote(folderId);

                // Logger.debug(q);
                rs = Etn.execute(q);
                while(rs.next()){
                    curObj = new JSONObject();
                    for(String colName : rs.ColName){
                        curObj.put(colName.toLowerCase(), rs.value(colName));
                    }

                    resultList.put(curObj);
                }

                data.put("contents",resultList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting contents list. Please try again.", ex);
            }
        }else if("buildConnection".equalsIgnoreCase(requestType)){
            status = STATUS_SUCCESS;
        }else if("saveContentSettings".equalsIgnoreCase(requestType)){
            ArrayList<String> pageIds = new ArrayList<>();
            String itemType = "structured page";
            int id = 0;
            boolean isNew = true;
            try{
                if(siteId.isEmpty()) siteId = parseNull(request.getParameter("siteId"));
                isDeleteInvalidPages = true;
                String structureType = Constant.STRUCTURE_TYPE_PAGE;
                List<Language> langsList = getLangs(Etn,siteId);

                id = parseInt(request.getParameter("id"), 0);
                String publishTime = parseNull(request.getParameter("publishTime"));
                String unpublishTime = parseNull(request.getParameter("unpublishTime"));
                String folderType = parseNull(request.getParameter("folderType"));
                String templateId = parseNull(request.getParameter("templateId"));
                String uniqueIds = parseNull(request.getParameter("uniqueIds"));
                String folderId = parseNull(request.getParameter("folderId"));
                String folderUrl = parseNull(request.getParameter("folderUrl")).replace('~', '/');
                String[] pageTags = parseNull(request.getParameter("pageTags")).split(",");
                String name = parseNull(request.getParameter("name"));
                String version = parseNull(request.getParameter("version")).isEmpty()?"V1": parseNull(request.getParameter("version"));
                boolean generateOnCreate = true;
                
                isNew = id <= 0;
                if(Constant.FOLDER_TYPE_STORE.equals(folderType)) itemType = "store";
                if(version.equals("V2")) itemType = "product";

                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-mm-dd HH:mm");
                LocalDateTime currentDateTime = LocalDateTime.now();

                if(publishTime.length() > 0){
                    int comparPublish = parseAndFormat(publishTime).compareTo(currentDateTime);
                    if(comparPublish<0){
                        throw new SimpleException("Publish time can not be less than "+currentDateTime.toString().replace("T"," "));
                    }
                }
                if(unpublishTime.length() > 0){
                    int comparPublish = parseAndFormat(unpublishTime).compareTo(currentDateTime);
                    if(comparPublish<0){
                        throw new SimpleException("Un publish time can not be less than "+currentDateTime.toString().replace("T"," "));
                    }
                }

                // content id validation
                if(id > 0){
                    q = "SELECT id,structured_version FROM structured_contents "
                        + " WHERE id = " + escape.cote(""+id)
                        + " AND site_id = " + escape.cote(siteId)
                        + " AND type = " + escape.cote(structureType)
                        + " AND folder_id = " + escape.cote(folderId);
                    rs = Etn.execute(q);
                    if(!rs.next()){
                        throw new SimpleException("Error: Invalid parameters");
                    }else {
                        version = parseNull(rs.value("structured_version"));
                        if(version.equals("V2")) itemType = "product";
                    }
                }

                // folder validation
                String folderTable = getFolderTableName(folderType);
                if(parseInt(folderId) > 0){
                    rs = Etn.execute("SELECT id FROM  "+folderTable+" WHERE id = "+escape.cote(folderId)+" AND site_id ="+escape.cote(siteId));
                    if(!rs.next()){
                        throw new SimpleException("Error: Invalid folder parameters");
                    }
                }

                // page name validaity
                if(name.length() == 0){
                    throw new SimpleException("Error: Name cannot be empty.");
                }else{
                    //check duplicate name
                    q = "SELECT sc.id FROM structured_contents sc JOIN bloc_templates bt ON bt.id = sc.template_id WHERE sc.name = " + escape.cote(name)
                        +"  AND sc.type ="+escape.cote(structureType)+"  AND sc.folder_id ="+escape.cote(folderId)+" AND sc.site_id ="+ escape.cote(siteId);

                    if(folderType.equals(Constant.FOLDER_TYPE_STORE)) q += " AND bt.type = " + escape.cote(Constant.TEMPLATE_STORE);
                    else q += " AND bt.type != " + escape.cote(Constant.TEMPLATE_STORE);

                    if(id > 0) q += " AND sc.id != " + escape.cote(""+id);
                    
                    rs = Etn.execute(q);
                    if(rs.next()){
                        throw new SimpleException("Error: Name already exists in folder. Please change name.");
                    }
                }

                //  update/isnert content
                int pid = Etn.getId();
                colValueHM.put("name", escape.cote(name));

                if(!uniqueIds.isEmpty()) colValueHM.put("unique_id", escape.cote(uniqueIds));

                colValueHM.put("updated_ts", "NOW()");
                colValueHM.put("updated_by", escape.cote(""+pid));
                colValueHM.put("to_publish_ts", !publishTime.isEmpty()?escape.cote(publishTime):null);
                colValueHM.put("to_unpublish_ts", !unpublishTime.isEmpty()?escape.cote(unpublishTime):null);
                colValueHM.put("to_publish",!publishTime.isEmpty()?escape.cote("1"):escape.cote("0"));
                colValueHM.put("to_unpublish",!unpublishTime.isEmpty()?escape.cote("1"):escape.cote("0"));

                if(id <= 0){
                    //new
                    colValueHM.put("site_id", escape.cote(siteId));
                    colValueHM.put("type", escape.cote(structureType));
                    colValueHM.put("folder_id", escape.cote(folderId));
                    colValueHM.put("template_id", escape.cote(templateId) );
                    colValueHM.put("publish_status", "'unpublished'");
                    colValueHM.put("created_by", escape.cote(""+pid));
                    colValueHM.put("created_ts", "NOW()");
                    if(version.equalsIgnoreCase("V2")) colValueHM.put("structured_version", escape.cote(version));

					if("1".equals(parseNull(session.getAttribute("IS_WEBMASTER")))) {
						JSONObject jUser = getUserInfo(Etn);
						colValueHM.put("crt_by_webmaster", escapeCote2(jUser.toString()));
					}

                    q = getInsertQuery("structured_contents",colValueHM);
                    id = Etn.executeCmd(q);
                    if(id <= 0) message = "Error in creating "+itemType+". Please try again.";
                    else{
                        if(version.equalsIgnoreCase("V2")){
                            generateOnCreate=false;
                            Etn.executeCmd("insert into products_map_pages (product_id,page_id) values ("+escape.cote(parseNull(request.getParameter("productId")))+","+escape.cote(""+id)+")");
                        }
                        status = STATUS_SUCCESS;
                        message = capitalizeFirstLetter(itemType)+" created.";
                        data.put("id", id);
                    }
                } else{
                    //existing update
                    q = getUpdateQuery("structured_contents", colValueHM, " WHERE id = " + escape.cote(""+id) );
                    count = Etn.executeCmd(q);

                    if(count <= 0) message = "Error in updating "+itemType+". Please try again.";
                    else{
                        if(version.equals("V2")){
                            Etn.executeCmd("update "+catalogDb+"products set updated_on=now(),version=version+1,updated_by="+escape.cote(Etn.getId()+"")
                                +" where id = (select product_id from products_map_pages where page_id="+escape.cote(id+"")+")");
                        }
                        status = STATUS_SUCCESS;
                        message = capitalizeFirstLetter(itemType)+" updated.";
                        data.put("id", id);
                    }
                }
				
				if(id > 0) {
					q = "DELETE FROM pages_tags WHERE page_id = " + escape.cote("" + id) + " and page_type ="+escape.cote("structured");
					Etn.executeCmd(q);
					if(pageTags != null && pageTags.length > 0)
					{
						String tagQPrefix = "INSERT INTO pages_tags (page_id, page_type, tag_id) VALUES (" + escape.cote("" + id) + ", 'structured' , ";
						for (String tagId : pageTags) {
							if (tagId.trim().length() > 0) {
								q = tagQPrefix + escape.cote(tagId) + " )";
								Etn.executeCmd(q);
							}
						}
					}					
				}					

                if(version.equals("V2")){
                    if(!publishTime.isEmpty()) publishUnpublishCatalogAndProduct(Etn, id+"","publish",publishTime);
                    if(!unpublishTime.isEmpty()) publishUnpublishCatalogAndProduct(Etn, id+"","delete",unpublishTime);
                }

                // insert language pages
                if(parseNull(request.getParameter("isFromProduct")).equals("1")){
                    for(Language curLang : langsList){
                        JSONObject parameters = new JSONObject();
                        parameters.put("pageType","structured");
                        parameters.put("folderId",folderId);
                        
                        Set rsPageTemplates = Etn.execute("select id from page_templates where site_id="+escape.cote(siteId)+" order by id limit 1");
                        if(rsPageTemplates.next()) parameters.put("template_id",rsPageTemplates.value("id"));
                        else parameters.put("template_id",0);
                        
                        parameters.put("title",parseNull(request.getParameter("title")));
                        parameters.put("langue_code",curLang.getCode());
                        parameters.put("path",folderUrl+parseNull(request.getParameter("url")));
                        parameters.put("name",name);
                        parameters.put("meta_description",parseNull(request.getParameter("meta_description")));
                        parameters.put("page_version",version);

                        if(!isNew){
                            Set rsLangPageId= Etn.execute("select id,template_id from pages where parent_page_id="+escape.cote(""+id)+" and langue_code="+escape.cote(curLang.getCode()));
                            if(rsLangPageId.next()) {
                                parameters.put("pageId",rsLangPageId.value("id"));
                                parameters.put("template_id",rsLangPageId.value("template_id"));
                            }
                        }
                        JSONObject res =  savePageCommonProducts(Etn, request, parameters, siteId, session, id+"");
                        if(res.getInt("status")>0) pageIds.add(res.getJSONObject("data").getInt("pageId")+"");
                    }
                }else pageIds = saveStructuredLangPages(Etn, request, isNew, siteId, langsList, session, id+"");

                if(status == STATUS_SUCCESS){
                    //save content details/ lang based data
                    int i=0;
                    for(Language curLang : langsList){

                        String detailPageId  =  pageIds.get(i++);
                        int contentDetailId = 0;
                        q = " SELECT id FROM structured_contents_details "
                            + " WHERE content_id = " + escape.cote(""+id)
                            + " AND langue_id = " + escape.cote(curLang.getLanguageId());
                        rs = Etn.execute(q);

                        if(rs.next()){
                            contentDetailId = parseInt(rs.value("id"));
                        }

                        colValueHM.clear();
                        colValueHM.put("page_id", escape.cote(detailPageId));

                        if(contentDetailId <= 0){
                            //add new
                            colValueHM.put("content_id",escape.cote(""+id));
                            colValueHM.put("langue_id",escape.cote(curLang.getLanguageId()));
                            colValueHM.put("content_data", escape.cote("{}"));

                            q = getInsertQuery("structured_contents_details",colValueHM);
                            Etn.executeCmd(q);
                        }
                        else{
                            //existing update
                            q = getUpdateQuery("structured_contents_details", colValueHM, " WHERE id = " + escape.cote(""+contentDetailId) );
                            Etn.executeCmd(q);
                        }
                    }

                    if(generateOnCreate){
                        //generate page
                        PagesGenerator pagesGen = new PagesGenerator(Etn);
                        String errorMsg = pagesGen.generateAndSaveStructuredPage(""+id);
                        if(errorMsg.length() > 0){
                            Logger.debug(errorMsg);
                            q= "UPDATE structured_contents SET to_generate=1 , to_generate_by= " + escape.cote(""+Etn.getId())
                                + " WHERE id = "+ escape.cote(""+id);
                            Etn.executeCmd(q);
                        }
                    }

                    data.put("pageIds", pageIds);
                }

            }catch(Exception ex){
                status=STATUS_ERROR;
                rollbackPageInsert(Etn, id+"", pageIds,isNew, siteId, Constant.PAGE_TYPE_STRUCTURED);
                throw new SimpleException("Error in saving "+itemType+". Please try again.",ex);
            }
        }else if("saveContent".equalsIgnoreCase(requestType)){

            String itemType = "structured page";
            int id = 0;

            try{
                isDeleteInvalidPages = true;
                List<Language> langsList = getLangs(Etn,siteId);
                id = parseInt(request.getParameter("id"), 0);
                String publishTime = parseNull(request.getParameter("publishTime"));
                String unpublishTime = parseNull(request.getParameter("unpublishTime"));
                String folderType = parseNull(request.getParameter("folderType"));
                String templateId = parseNull(request.getParameter("templateId"));
                String folderId = parseNull(request.getParameter("folderId"));
                String structureType = parseNull(request.getParameter("structureType"));
                String name = parseNull(request.getParameter("name"));
                String uniqueIds = parseNull(request.getParameter("uniqueIds"));
                Map<String, ArrayList<String>> contentBlocs = new HashMap<String, ArrayList<String>>();

                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-mm-dd HH:mm");
                LocalDateTime currentDateTime = LocalDateTime.now();

                if(publishTime.length() > 0){
                    int comparPublish = parseAndFormat(publishTime).compareTo(currentDateTime);
                    if(comparPublish<0){
                        throw new SimpleException("Publish time can not be less than "+currentDateTime.toString().replace("T"," "));
                    }
                }
                if(unpublishTime.length() > 0){
                    int comparPublish = parseAndFormat(unpublishTime).compareTo(currentDateTime);
                    if(comparPublish<0){
                        throw new SimpleException("Un publish time can not be less than "+currentDateTime.toString().replace("T"," "));
                    }
                }

                String templateType = "";
                Set rsV2Template = Etn.execute("select * from bloc_templates where id="+escape.cote(templateId));
                if(rsV2Template.next()) templateType = rsV2Template.value("type");

                if(Constant.FOLDER_TYPE_STORE.equals(folderType)){
                    itemType = "store";
                }else if(Constant.FOLDER_TYPE_CONTENTS.equals(folderType)){
                    itemType = "structured data";
                }

                String folderTable = getFolderTableName(folderType);
                if(folderId.length() >0 && parseInt(folderId) > 0){
                    q = "SELECT id FROM  " + folderTable
                    + " WHERE id = " + escape.cote(folderId)
                    + " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);

                    if(!rs.next()){
                        throw new SimpleException("Error: Invalid folder parameters");
                    }
                }

                if(id > 0){
                    q = "SELECT id FROM structured_contents "
                        + " WHERE id = " + escape.cote(""+id)
                        + " AND site_id = " + escape.cote(siteId)
                        + " AND type = " + escape.cote(structureType)
                        + " AND folder_id = " + escape.cote(folderId);
                    rs = Etn.execute(q);
                    if(!rs.next()){
                        throw new SimpleException("Error: Invalid parameters");
                    }

                }

                String errorMsg = "";
                if(name.length() == 0) errorMsg += "Error: Name cannot be empty.";
                else{
                    //check duplicate name
                    q = "SELECT sc.id FROM structured_contents sc JOIN bloc_templates bt ON bt.id = sc.template_id WHERE sc.name = " + escape.cote(name)
                        + "  AND sc.type = "+escape.cote(structureType)
                        + "  AND sc.folder_id = " + escape.cote(folderId)
                        + "  AND sc.site_id = "+escape.cote(siteId);

                    if(folderType.equals(Constant.FOLDER_TYPE_STORE)) q += " AND bt.type = " + escape.cote(Constant.TEMPLATE_STORE);
                    else q += " AND bt.type != " + escape.cote(Constant.TEMPLATE_STORE);

                    if(id > 0) q += " AND sc.  id != " + escape.cote(""+id);
                    
                    rs = Etn.execute(q);
                    if(rs.next()) errorMsg += "Error: Name already exists in folder. Please change name.";
                }

                if(errorMsg.length() > 0) message = errorMsg;
                else{

                    int pid = Etn.getId();

                    colValueHM.put("name", escape.cote(name));

                    if(uniqueIds.length() > 0) colValueHM.put("unique_id", escape.cote(uniqueIds));

                    if(publishTime.length() > 0){
                        colValueHM.put("to_publish_ts", escape.cote(publishTime));
                        colValueHM.put("to_publish",escape.cote("1"));
                    }

                    if(unpublishTime.length() > 0){
                        colValueHM.put("to_unpublish_ts", escape.cote(unpublishTime));
                        colValueHM.put("to_unpublish",escape.cote("1"));
                    }
                    colValueHM.put("updated_ts", "NOW()");
                    colValueHM.put("updated_by", escape.cote(""+pid));
					
					boolean isWebmasterProfil = "1".equals(parseNull(session.getAttribute("IS_WEBMASTER")));
					JSONObject jUser = getUserInfo(Etn);
                    
					if(isWebmasterProfil){
						colValueHM.put("upd_on_by_webmaster", "NOW()");
						colValueHM.put("upd_by_webmaster", escapeCote2(jUser.toString()));
					}

                    if(id <= 0 && folderType.equals(Constant.FOLDER_TYPE_CONTENTS)){ // only content will be saved as new
                        colValueHM.put("site_id", escape.cote(siteId));
                        colValueHM.put("type", escape.cote(structureType));
                        colValueHM.put("folder_id", folderId);
                        colValueHM.put("template_id", escape.cote(templateId) );
                        colValueHM.put("publish_status", "'unpublished'");
                        colValueHM.put("created_by", escape.cote(""+pid));
                        colValueHM.put("created_ts", "NOW()");

						if(isWebmasterProfil) colValueHM.put("crt_by_webmaster", escapeCote2(jUser.toString()));

                        q = getInsertQuery("structured_contents",colValueHM);
                        id = Etn.executeCmd(q);

                        if(id <= 0) message = "Error in creating "+itemType+". Please try again.";
                        else{
                            status = STATUS_SUCCESS;
                            message = capitalizeFirstLetter(itemType)+" created.";
                            data.put("id", id);
                        }
                    }
                    else{
                        //existing update
                        q = getUpdateQuery("structured_contents", colValueHM, " WHERE id = " + escape.cote(""+id) );
                        count = Etn.executeCmd(q);

                        if(count <= 0) message = "Error in updating "+itemType+". Please try again.";
                        else{
                            status = STATUS_SUCCESS;
                            message = capitalizeFirstLetter(itemType)+" updated.";
                            data.put("id", id);
                        }
                    }

                    if(status == STATUS_SUCCESS){
                        //save content details/ lang based data
                        JSONObject productObj = new JSONObject();
                        
                        if(!templateType.isEmpty() && templateType.contains("product")){
                            JSONObject contentDetailsJSONForProduct = new JSONObject();
                            JSONArray productVariantsAry = new JSONArray();
                            try{
                                for(Language curLang: langsList){
                                    try{
                                        contentDetailsJSONForProduct = new JSONObject(parseNull(request.getParameter("contentDetailData_"+curLang.getLanguageId())));
                                    }catch(Exception ex){
                                        ex.printStackTrace();
										//why to initialize again when its already initialized?
                                        //contentDetailsJSONForProduct = new JSONObject();
                                    }
                                    break;
                                }

                                if(contentDetailsJSONForProduct.length() > 0){
                                    productObj.put("product_id",contentDetailsJSONForProduct.getJSONArray("product_general_informations").getJSONObject(0).getJSONArray("product_general_informations_product_id").getString(0));
                                    productObj.put("product_uuid",contentDetailsJSONForProduct.getJSONArray("product_general_informations").getJSONObject(0).getJSONArray("product_general_informations_product_uuid").getString(0));
                                    productObj.put("manufacturer",contentDetailsJSONForProduct.getJSONArray("product_general_informations").getJSONObject(0).getJSONArray("product_general_informations_manufacturer").getString(0));
                                    productObj.put("tag",contentDetailsJSONForProduct.getJSONArray("product_general_informations").getJSONObject(0).getJSONArray("product_general_informations_tags").getJSONArray(0));
                                    
                                    if(templateType.toLowerCase().contains("configurable")){

                                        JSONArray prodVarTmpAry = contentDetailsJSONForProduct.getJSONArray("product_variants").getJSONObject(0).getJSONArray("product_variants_variant_x");
                                        for (int i = 0; i < prodVarTmpAry.length(); i++) {
                                            JSONObject prodVarTmp = prodVarTmpAry.getJSONObject(i);
                                            JSONObject prodVarObj = new JSONObject();
                                            
                                            prodVarObj.put("id", prodVarTmp.getJSONArray("product_variants_variant_x_id").getString(0));
                                            String variantUuid = prodVarTmp.getJSONArray("product_variants_variant_x_uuid").getString(0);
                                            prodVarObj.put("uuid", variantUuid);
                                            prodVarObj.put("ean", prodVarTmp.getJSONArray("product_variants_variant_x_ean").getString(0));

                                            String sku = contentDetailsJSONForProduct.getJSONArray("main_information").getJSONObject(0).getJSONArray("system_product_name").getString(0)+"_"+UUID.randomUUID().toString();
                                            sku=sku.replace(" ","_");
                                            if(prodVarTmp.getJSONArray("product_variants_variant_x_sku").length()>0 && prodVarTmp.getJSONArray("product_variants_variant_x_sku").getString(0).length()>0){
                                                sku = parseNull(prodVarTmp.getJSONArray("product_variants_variant_x_sku").getString(0));
                                            }
                                            prodVarObj.put("sku",sku);

                                            prodVarObj.put("price", prodVarTmp.getJSONArray("product_variants_variant_x_price_price").getString(0));
                                            prodVarObj.put("frequency", "");
                                            if(prodVarTmp.has("product_variants_variant_x_price_frequency") && prodVarTmp.getJSONArray("product_variants_variant_x_price_frequency")!=null 
                                            && !prodVarTmp.getJSONArray("product_variants_variant_x_price_frequency").isEmpty() 
                                            && !prodVarTmp.getJSONArray("product_variants_variant_x_price_frequency").isNull(0)){
                                                String frequency = parseNull(prodVarTmp.getJSONArray("product_variants_variant_x_price_frequency").getString(0));
                                                if(frequency.equals("one_shot")) frequency="";
                                                prodVarObj.put("frequency", frequency);
                                            }
                                            prodVarObj.put("tag", prodVarTmp.getJSONArray("product_variants_variant_x_tags").getJSONArray(0));

                                            String commitment = "0";
                                            JSONArray atrAry = prodVarTmp.optJSONArray("product_variants_variant_x_attributes");
                                            if(atrAry!=null){
                                                for(Object obj : atrAry){
                                                    JSONObject atr = (JSONObject) obj;
                                                    if(atr.getString("name").equalsIgnoreCase("commitment")){
                                                        try{
                                                            commitment= String.valueOf(Integer.parseInt(atr.getString("value")));
                                                        }catch(Exception ignored){}
                                                    }
                                                }
                                            }
                                            prodVarObj.put("commitment", commitment);

                                            JSONArray variantLangDataAry = new JSONArray();
                                            for(Language curLang: langsList){
                                                String tmpContentString = parseNull(request.getParameter("contentDetailData_"+curLang.getLanguageId()));
                                                JSONObject tmpContentJSON = new JSONObject(tmpContentString);
                                                JSONObject curVarLangData = tmpContentJSON.getJSONArray("product_variants").getJSONObject(0).getJSONArray("product_variants_variant_x").getJSONObject(i);

                                                JSONObject variantLangData = new JSONObject();
                                                variantLangData.put("lang_id",curLang.getLanguageId());
                                                variantLangData.put("name",curVarLangData.getJSONArray("product_variants_variant_x_name").getString(0));
                                                
                                                variantLangDataAry.put(variantLangData);
                                            }

                                            prodVarObj.put("lang_data",variantLangDataAry);

                                            productVariantsAry.put(prodVarObj);
                                        }

                                    }else if(templateType.toLowerCase().contains("simple")){
                                        String productName = contentDetailsJSONForProduct.getJSONArray("main_information").getJSONObject(0).getJSONArray("system_product_name").getString(0);

                                        JSONObject variantObj = new JSONObject();
                                        JSONObject generalInfoV2 = contentDetailsJSONForProduct.getJSONArray("product_general_informations").getJSONObject(0);

                                        variantObj.put("id",generalInfoV2.getJSONArray("product_general_informations_variant_id").getString(0));
                                        
                                        String variantUuid = generalInfoV2.getJSONArray("product_general_informations_variant_uuid").getString(0);
                                        variantObj.put("uuid",variantUuid);
                                        variantObj.put("ean",generalInfoV2.getJSONArray("product_general_informations_ean").getString(0));
                                        
                                        String sku = productName+"_"+UUID.randomUUID().toString();
                                        sku=sku.replace(" ","_");
                                        if(generalInfoV2.getJSONArray("product_general_informations_sku").length()>0 && generalInfoV2.getJSONArray("product_general_informations_sku").getString(0).length()>0){
                                            sku = parseNull(generalInfoV2.getJSONArray("product_general_informations_sku").getString(0));
                                        }
                                        variantObj.put("sku",sku);

                                        variantObj.put("price",generalInfoV2.getJSONArray("product_general_informations_price_price").getString(0));
                                        variantObj.put("frequency",generalInfoV2.getJSONArray("product_general_informations_price_frequency").getString(0));
                                        
                                        variantObj.put("frequency", "");
                                        if(generalInfoV2.has("product_general_informations_price_frequency") && generalInfoV2.getJSONArray("product_general_informations_price_frequency")!=null 
                                        && !generalInfoV2.getJSONArray("product_general_informations_price_frequency").isEmpty() 
                                        && !generalInfoV2.getJSONArray("product_general_informations_price_frequency").isNull(0)){
                                            String frequency = parseNull(generalInfoV2.getJSONArray("product_general_informations_price_frequency").getString(0));
                                            if(frequency.equals("one_shot")) frequency="";
                                            variantObj.put("frequency", frequency);
                                        }

                                        String commitment = "0";
                                        JSONArray atrAry = generalInfoV2.optJSONArray("product_attributes");
                                        if(atrAry!=null){
                                            for(Object obj : atrAry){
                                                JSONObject atr = (JSONObject) obj;
                                                if(atr.getString("name").equalsIgnoreCase("commitment")) {
                                                    try{
                                                        commitment= String.valueOf(Integer.parseInt(atr.getString("value")));
                                                    }catch(Exception ignored){}
                                                }
                                            }
                                        }
                                        variantObj.put("commitment", commitment);
                                        
                                        JSONArray variantLangDataAry = new JSONArray();
                                        for(Language curLang: langsList){
                                            JSONObject variantLangData = new JSONObject();

                                            variantLangData.put("lang_id",curLang.getLanguageId());
                                            variantLangData.put("name",productName);
                                            
                                            variantLangDataAry.put(variantLangData);
                                        }

                                        variantObj.put("lang_data",variantLangDataAry);
                                        
                                        productVariantsAry.put(variantObj);
                                    }
                                    productObj.put("variants",productVariantsAry);
                                }
                                
                            }catch(Exception ex){
                                ex.printStackTrace();
                            }

                            if(productObj.length() > 0) updateProductV2(Etn,siteId,productObj,catalogDb);
                        }

                        for(Language curLang: langsList){

                            int contentDetailId = 0;
                            q = " SELECT id FROM structured_contents_details "
                                + " WHERE content_id = " + escape.cote(""+id)
                                + " AND langue_id = " + escape.cote(curLang.getLanguageId());
                            rs = Etn.execute(q);

                            if(rs.next()) contentDetailId = parseInt(rs.value("id"));

                            String contentDetailDataStr = parseNull(request.getParameter("contentDetailData_"+curLang.getLanguageId()));

                            JSONObject contentDetailJson;
                            try{
                                contentDetailJson = new JSONObject(contentDetailDataStr);
                            }catch(Exception ex){
                                contentDetailJson = new JSONObject();
                            }

                            if(contentDetailJson.length() > 0 && !templateType.isEmpty() && templateType.contains("product")){
                                if(templateType.contains("configurable")){
                                    JSONArray prodVarTmpAry = contentDetailJson.getJSONArray("product_variants").getJSONObject(0).getJSONArray("product_variants_variant_x");
                                    JSONArray updatedProductVarinats = productObj.getJSONArray("variants");
                                    if(prodVarTmpAry.length() == updatedProductVarinats.length()){
                                        for (int i = 0; i < prodVarTmpAry.length(); i++) {
                                            JSONObject prodVarTmp = prodVarTmpAry.getJSONObject(i);
                                            JSONObject updatedVariant = updatedProductVarinats.getJSONObject(i);

                                            String updatedVarId = updatedVariant.getString("id");
                                            String updatedVarUuid = updatedVariant.getString("uuid");
                                            String variantSku = updatedVariant.getString("sku");

                                            if(!updatedVarId.isEmpty()) prodVarTmp.getJSONArray("product_variants_variant_x_id").put(0,updatedVarId);
                                            
                                            if(!updatedVarUuid.isEmpty()) prodVarTmp.getJSONArray("product_variants_variant_x_uuid").put(0,updatedVarUuid);

                                            if(prodVarTmp.getJSONArray("product_variants_variant_x_sku").length()==0 
                                                || prodVarTmp.getJSONArray("product_variants_variant_x_sku").getString(0).length()==0){
                                                    prodVarTmp.getJSONArray("product_variants_variant_x_sku").put(0,variantSku);
                                            }
                                        }
                                    }
                                }else if(templateType.contains("simple")){
                                    String updatedVarId = productObj.getJSONArray("variants").getJSONObject(0).getString("id");
                                    String updatedVarUuid = productObj.getJSONArray("variants").getJSONObject(0).getString("uuid");
                                    String variantSku = productObj.getJSONArray("variants").getJSONObject(0).getString("sku");

                                    if(!updatedVarId.isEmpty())
                                        contentDetailJson.getJSONArray("product_general_informations").getJSONObject(0)
                                            .getJSONArray("product_general_informations_variant_id").put(0,updatedVarId);
                                    if(!updatedVarUuid.isEmpty())
                                        contentDetailJson.getJSONArray("product_general_informations").getJSONObject(0)
                                            .getJSONArray("product_general_informations_variant_uuid").put(0,updatedVarUuid);

                                    if(contentDetailJson.getJSONArray("product_general_informations").getJSONObject(0).getJSONArray("product_general_informations_sku").length()==0 
                                        || contentDetailJson.getJSONArray("product_general_informations").getJSONObject(0).getJSONArray("product_general_informations_sku").getString(0).length()==0){
                                        contentDetailJson.getJSONArray("product_general_informations").getJSONObject(0).getJSONArray("product_general_informations_sku").put(0,variantSku);
                                    }
                                }
                            }

                            String contentDetailData = encodeJSONStringDB(contentDetailJson.toString());

                            colValueHM.clear();
                            colValueHM.put("content_data", escape.cote(contentDetailData));

                            if(contentDetailId <= 0){
                                //add new
                                colValueHM.put("content_id",escape.cote(""+id));
                                colValueHM.put("langue_id",escape.cote(curLang.getLanguageId()));
                                colValueHM.put("page_id", escape.cote("0"));

                                q = getInsertQuery("structured_contents_details",colValueHM);
                                Etn.executeCmd(q);
                            }
                            else{
                                //existing update
                                q = getUpdateQuery("structured_contents_details", colValueHM, " WHERE id = " + escape.cote(""+contentDetailId) );
                                Etn.executeCmd(q);
                            }

                            ArrayList<String> langContentBlocs = new ArrayList<String>();
                            if(contentBlocs.containsKey(""+curLang.getLanguageId()))
                                langContentBlocs = contentBlocs.get(""+curLang.getLanguageId()); 
                            
                            System.out.println("blocIds_"+curLang.getLanguageId());
                            String blocIds = parseNull(request.getParameter("blocIds_"+curLang.getLanguageId()));
                            System.out.println("blocIds: " + blocIds);
                            if(blocIds.length() > 0) 
                                for(String bId : blocIds.split(",")) 
                                    langContentBlocs.add(bId);

                            contentBlocs.put(""+curLang.getLanguageId(), langContentBlocs);
                        }

                        if( structureType.equals(Constant.STRUCTURE_TYPE_PAGE) ){
                            PagesGenerator pagesGen = new PagesGenerator(Etn);
                            errorMsg = pagesGen.generateAndSaveStructuredPage(""+id);
                            if(errorMsg.length() > 0){
                                Logger.debug(errorMsg);
                                q= "UPDATE structured_contents SET to_generate=1 , to_generate_by= " + escape.cote(""+Etn.getId())
                                    + " WHERE id = "+ escape.cote(""+id);
                                Etn.executeCmd(q);
                            }
                        }

                        Set pagesRs = Etn.execute("SELECT p.*,l.langue_id FROM pages p left join language l on p.langue_code = l.langue_code where p.parent_page_id="+escape.cote(""+id)+" and p.type="+escape.cote("structured"));
                        while(pagesRs.next())
                        {    
                            q = "DELETE FROM structure_mappings WHERE lang_page_id = " + escape.cote(parseNull(pagesRs.value("id")));
                            Etn.executeCmd(q);
                            
                            for(String blocId : contentBlocs.get(parseNull(pagesRs.value("langue_id"))))
                            {
                                q = "select * from bloc_tree where langue_id="+escape.cote(parseNull(pagesRs.value("langue_id")))+" and parent_bloc_id="+escape.cote(blocId);
                                Set blocRs = Etn.execute(q);
                                while(blocRs.next()){
                                    insertChildBlocs(Etn,blocRs.value("bloc_id"), parseNull(pagesRs.value("id")), parseNull(pagesRs.value("langue_id")));
                                }
                            }
                        }                        
                    }
                }

            }catch(Exception ex){
                throw new SimpleException("Error in saving "+itemType+". Please try again.",ex);
            }
        }else if("saveBulkModifications".equalsIgnoreCase(requestType)){

			String templateId = parseNull(request.getParameter("templateId"));
			String storeIds = parseNull(request.getParameter("sids"));
			// boolean appendSection = parseNull(request.getParameter("appendSection")).equals("1");
			String[] arrStoreIds = storeIds.split(",");
			if(arrStoreIds == null || arrStoreIds.length == 0 || templateId.length() == 0)
			{
				status = STATUS_ERROR;
				message = "Required data is missing";
			}			
			else
			{
				List<String> sections = new ArrayList<>();
				rs = Etn.execute("select * from bloc_templates_sections where bloc_template_id = "+escape.cote(templateId) + " and coalesce(parent_section_id,0) = 0");
				while(rs.next())
				{
					sections.add(rs.value("custom_id"));
					getSectionsForBulkModif(Etn, sections, rs.value("id"), rs.value("custom_id"));
				}
				
                JSONObject errorMsg = new JSONObject();
				Set rsLang = Etn.execute("select * from language");
				while(rsLang.next())
				{
                    JSONArray errArray = new JSONArray();
					Map<String, Object> bulkData = new HashMap<>();
					String contentData = parseNull(request.getParameter("contentDetailData_"+rsLang.value("langue_id")));

                    JSONArray sections2 = PagesUtil.getBlocTemplateSectionsData(Etn, templateId, true);
                    JSONArray bulkModifySections = new JSONArray();
                    for(int i=0;i<sections2.length();i++)
                    {
                        if(sectionHasFieldsToModify(sections2.getJSONObject(i))) bulkModifySections.put(sections2.get(i));
                    }

                    JSONArray bulkModifyCheckData = new JSONArray(parseNull(request.getParameter("bulkModifyCheckData_"+rsLang.value("langue_id"))));
                    if(contentData.length() > 0) bulkModifyStore(Etn,new JSONObject(contentData),bulkModifySections,storeIds,bulkModifyCheckData,rsLang.value("langue_id"),errArray);
                    
                    if(errArray.length()>0){
                        errorMsg.put(rsLang.value("langue"),errArray);
                    }
					// if(contentData.length() > 0) processBulkModificationData(Etn, sections, bulkData, rsLang.value("langue_id"), templateId, arrStoreIds, new JSONObject(contentData),appendSection);
				}
                data = errorMsg;
				message = arrStoreIds.length + " store(s) updated";
				status = STATUS_SUCCESS;
			}
        }else if("getStructuredPageInfo".equalsIgnoreCase(requestType)){
            try{
                String siteLangs="";
                Set rsSiteLangs = Etn.execute("select langue_id from "+GlobalParm.getParm("COMMONS_DB")+".sites_langs where site_id="+escape.cote(siteId));
                while(rsSiteLangs.next()){
                    if(siteLangs.length()>0){
                        siteLangs+=",";
                    }
                    siteLangs+=parseNull(rsSiteLangs.value("langue_id"));
                }

                String id = parseNull(request.getParameter("id"));

                q = "SELECT name, template_id,to_publish_ts,to_unpublish_ts "
                    + " FROM structured_contents "
                    + " WHERE id = " + escape.cote(id)
                    + " AND type ="+escape.cote(Constant.STRUCTURE_TYPE_PAGE)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);

                if(!rs.next()){
                    throw new SimpleException("Invalid parameters");
                }
                String templateId = rs.value("template_id");
                data.put("name", rs.value("name"));
                data.put("publishTime", rs.value("to_publish_ts"));
                data.put("unpublishTime", rs.value("to_unpublish_ts"));
                data.put("templateId", templateId);

                q = "SELECT langue_id, page_id, content_data"
                    + " FROM structured_contents_details "
                    + " WHERE content_id = " + escape.cote(id);
                rs = Etn.execute(q);

				JSONArray pageTags = new JSONArray();

				q = "SELECT t.id, t.label FROM pages_tags pt "
					+ " JOIN "+GlobalParm.getParm("CATALOG_DB")+".tags t ON pt.tag_id = t.id "
					+ " WHERE t.site_id = " + escape.cote(siteId)
					+ " AND pt.page_id = " + escape.cote(id)
					+ " AND pt.page_type = 'structured'"
					+ " ORDER BY t.label";
					
				Set tagRs = Etn.execute(q);
				while(tagRs.next()){
					JSONObject tagObj = new JSONObject();
					tagObj.put("id",tagRs.value("id"));
					tagObj.put("label",tagRs.value("label"));
					pageTags.put(tagObj);
				}
				data.put("tags", pageTags);

                String templateData = "";
                JSONObject pages = new JSONObject();
                while(rs.next()){
                    String langId = rs.value("langue_id");
                    String pageId = rs.value("page_id");
                    templateData = rs.value("content_data");

                    if(parseInt(pageId)>0 && siteLangs.contains(langId)){
                        JSONObject pageObj = getPageInfo(Etn, pageId, siteId);

                        if(pageObj.getInt("status") == STATUS_SUCCESS){
                            pages.put("page_lang_"+langId, pageObj.getJSONObject("page"));
                        }
                        else{
                            throw new SimpleException("Error in getting info.");
                        }
                    }
                }
                templateData =  rs.value("content_data");
                templateData = PagesUtil.decodeJSONStringDB(templateData);
                JSONObject templateDataJson = new JSONObject(templateData);
                TemplateDataGenerator templateDataGenerator = new TemplateDataGenerator(Etn, siteId);
                templateDataGenerator.setMetaVariableDataOnly(true);
                HashMap<String, Object> templateDataHM = templateDataGenerator.getBlocTemplateDataMap(templateId, templateDataJson, new HashMap<>(), "1" );
                Map<String, Object> metaVariablesHM = JsonFlattener.flattenAsMap(new JSONObject(templateDataHM).toString());
                Map<String, Object> cleanMetaVariablesHM = new HashMap<>();
                // remove emtry fields sections
                for (Map.Entry<String,Object> entry : metaVariablesHM.entrySet()){
                     try{
                         if(!entry.getValue().toString().equals("{}")){
                             cleanMetaVariablesHM.put(entry.getKey(), entry.getValue());
                         }
                     } catch (Exception ignored){
                         cleanMetaVariablesHM.put(entry.getKey(), entry.getValue());
                    }
                }
                data.put("pages", pages);
                data.put("metaVariables", cleanMetaVariablesHM);

                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting info.", ex);
            }
        }else if("getContentDetail".equalsIgnoreCase(requestType)){

            try{
                String contentId = parseNull(request.getParameter("contentId"));

                q = "SELECT id, name, template_id, folder_id, publish_status "
                    + " , IF(ISNULL(published_ts), 'unpublished' , IF(updated_ts > published_ts, 'changed' , 'published')) as ui_status,structured_version  "
                    + " FROM structured_contents "
                    + " WHERE id = " + escape.cote(contentId)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);

                if(!rs.next()){
                    throw new SimpleException("Invalid parameters");
                }

                JSONObject retJson = getJSONObject(rs);

                JSONObject templateCode = new JSONObject();
                retJson.put("template_code",templateCode);

                String templateId = rs.value("template_id");
                JSONArray sections = PagesUtil.getBlocTemplateSectionsData(Etn, templateId);
                templateCode.put("sections",sections);

                JSONArray templateData = new JSONArray();
                retJson.put("template_data",templateData);

                q = "SELECT id, langue_id, content_data, page_id "
                    + " FROM structured_contents_details "
                    + " WHERE content_id = " + escape.cote(contentId);
                rs = Etn.execute(q);

                JSONObject contentDetail;
                while(rs.next()){
                    contentDetail = new JSONObject();
                    contentDetail.put("id",rs.value("id"));
                    contentDetail.put("langue_id",rs.value("langue_id"));
                    contentDetail.put("page_id",rs.value("page_id"));

                    String contentData = decodeJSONStringDB(rs.value("content_data"));
                    contentDetail.put("content_data",contentData);

                    templateData.put(contentDetail);
                }

                if(retJson.getString("structured_version").equals("V2")){

                    JSONArray atrAry = new JSONArray();

                    String atrQuery = "select a1.id,a1.name,a1.type,a1.icon,a1.unit from "+catalogDb+"attributes_v2 a1 "+
                        "join "+catalogDb+"product_v2_categories_and_attributes pvca on pvca.reference_uuid = a1.uuid and pvca.reference_type='attribute' "+
                        "join "+catalogDb+"product_types_v2 pt2 on pt2.uuid=pvca.product_type_uuid "+
                        "join "+catalogDb+"products_definition pd on pd.product_type = pt2.id "+
                        "join "+catalogDb+"products p on p.product_definition_id = pd.id "+
                        "join products_map_pages pmp on pmp.product_id=p.id "+
                        "where pmp.page_id="+escape.cote(contentId)+" order by pvca.id";

                    Set rsAttr = Etn.execute(atrQuery);

                    while(rsAttr.next()){
                        JSONObject atrObj = new JSONObject();
                        for(String colName : rsAttr.ColName){
                            atrObj.put(colName.toLowerCase(),rsAttr.value(colName));

                            if(colName.equalsIgnoreCase("id")){
                                JSONArray atrValAry = new JSONArray();
                                Set rsAttrVal = Etn.execute("select label,value from "+catalogDb+"attributes_values_v2 where attr_id="+escape.cote(rsAttr.value(colName))+" order by id");
                                while(rsAttrVal.next()){
                                    JSONObject tmpObj = new JSONObject();
                                    tmpObj.put("label",rsAttrVal.value("label"));
                                    tmpObj.put("value",rsAttrVal.value("value"));
                                    atrValAry.put(tmpObj);
                                }
                                atrObj.put("values",atrValAry);
                            }
                        }
                        atrAry.put(atrObj);
                    }
                    retJson.put("attributes",atrAry);

                    Set rsSpec = Etn.execute("SELECT pvs.id,pvs.data_entry_type,pvs.data_type,pvs.specification FROM structured_contents sc "
                        +" JOIN "+catalogDb+"product_types_v2 pt2 ON pt2.template_id = sc.template_id "
                        +" JOIN "+catalogDb+"product_v2_specifications pvs ON pvs.product_type_uuid=pt2.uuid "
                        +" WHERE sc.id="+escape.cote(contentId));
                    
                    JSONObject specObj = new JSONObject();
                    if(rsSpec.next()){
                        specObj.put("id",rsSpec.value("id"));
                        specObj.put("data_entry_type",rsSpec.value("data_entry_type"));
                        specObj.put("data_type",rsSpec.value("data_type"));
                        try{
                            specObj.put("specs",new JSONArray(rsSpec.value("specification")));
                        }catch(Exception e){
                            specObj.put("specs",convertStringToJSONArray(rsSpec.value("specification")));
                        }
                    }
                    retJson.put("specification",specObj);
                }


                data.put("content",retJson);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting info.", ex);
            }
        }else if("getTemplateFieldsForBulkModification".equalsIgnoreCase(requestType)){

            try{
                String templateId = parseNull(request.getParameter("templateId"));

                JSONArray sections = PagesUtil.getBlocTemplateSectionsData(Etn, templateId, true);

				JSONArray bulkModifySections = new JSONArray();
				for(int i=0;i<sections.length();i++)
				{
					if(sectionHasFieldsToModify(sections.getJSONObject(i))) bulkModifySections.put(sections.get(i));
				}

                data.put("sections",bulkModifySections);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting info.", ex);
            }
        }else if("deleteContents".equalsIgnoreCase(requestType)){
            try{
            	isDeleteInvalidPages = true;
                String contentData = request.getParameter("contents");
                JSONArray contents = new JSONArray(contentData);

                int totalCount = contents.length();
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }
                String type = "";
                int deletedFoldersCount = 0;
                int deletedContentCount = 0;
                String deletedFolderNames = "";
                String deletedFolderIds = "";
                String deletedContentIds = "";
                String deletedContentNames = "";

                for(Object obj : contents){
                    JSONObject content =  (JSONObject)obj;
                    String id = content.getString("id");
                    type = content.getString("type");
                    if(type.equals("folder")){
                        q = "SELECT name from structured_contents_folders WHERE id = "+escape.cote(id);
                        rs = Etn.execute(q);
                        String name = "";
                        if(rs.next()){
                            name = rs.value("name");
                        };

                        boolean isDeleted = deleteFolderFunc(Etn, id, siteId, Constant.FOLDER_TYPE_CONTENTS);
                        if(isDeleted){
                            deletedFoldersCount += 1;
                            deletedFolderNames += name+", ";
                            deletedFolderIds += id+", ";
                        }
                    }
                    else{
                        q = " SELECT sc.id, sc.name, sc.publish_status"
                        + " FROM structured_contents sc "
                        + " WHERE sc.id = " + escape.cote(id)
                        + " AND sc.type = " + escape.cote(Constant.STRUCTURE_TYPE_CONTENT)
                        + " AND sc.site_id = " + escape.cote(siteId);
                        rs = Etn.execute(q);
                        if(!rs.next()){
                            continue;
                        }

                        if( "published".equals(rs.value("publish_status")) ){
                            continue;
                        }

                        // TODO  , uses ??
                        // q = "SELECT COUNT(0) as count FROM uses_table "
                        //     + " WHERE catalog_id = " + escape.cote(id);

                        /*q = "DELETE FROM structured_contents_details WHERE content_id = " + escape.cote(id);
                        Etn.executeCmd(q);

                        q = "DELETE FROM structured_contents WHERE id = " + escape.cote(id);
                        */

                        q = "UPDATE structured_contents set updated_ts = now(), updated_by = "+escape.cote(""+Etn.getId())+", deleted_by = "+escape.cote(""+Etn.getId())+", is_deleted='1' WHERE id = " + escape.cote(id);
                        Etn.executeCmd(q);
                        deletedContentCount += 1;
                        deletedContentIds += id+", ";
                        deletedContentNames += rs.value("name")+", ";
                    }
                }

                if(totalCount == 1){
                    if(type.equals("content")){
                        if(deletedContentCount != 1){
                            throw new SimpleException("Error: Cannot delete. Content status is 'published'.");
                        }
                        else{
                            status = STATUS_SUCCESS;
                            message = "Content deleted";
                        }
                    }else{
                        if(deletedFoldersCount != 1){
                            throw new SimpleException("Error: Cannot delete folder.");
                        }
                        else{
                            status = STATUS_SUCCESS;
                            message = "Folder deleted";
                        }
                    }
                }
                else{
                    if(deletedContentCount>0){
                        message = deletedContentCount + " contents";
                    }
                    if(deletedFoldersCount>0){
                        if(message.length()>0){
                            message += " and ";
                        }
                        message += deletedFoldersCount+" folders ";
                    }
                    if(message.length()>0){
                        message += " deleted";
                    }
                    status = STATUS_SUCCESS;
                    if(deletedContentCount + deletedFoldersCount <totalCount){
                        message += ". Published contents and non empty folders are not deleted.";
                    }
                }
              //logs
                if (status == STATUS_SUCCESS) {
                    if(deletedFoldersCount>0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), deletedFolderIds, "DELETED", "Content Folder", deletedFolderNames, siteId);
                    }
                    if(deletedContentCount>0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), deletedContentIds, "DELETED", "Structured Data ", deletedContentNames, siteId);
                    }
                }



            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting contents.",ex);
            }
        }else if("moveContents".equalsIgnoreCase(requestType)){
            // move folder, cotnents
            try{
                String  moveToFoldreId = request.getParameter("moveToFolderId");
                String contentData = request.getParameter("contents");
                JSONArray contents = new JSONArray(contentData);
                String movedToFolderName = "base";

                int totalCount = contents.length();
                int moveToFolderLevel = 0;

                if(totalCount == 0){
                    throw new SimpleException("Error: No id found");
                }

                if(parseInt(moveToFoldreId) > 0){
                    q = "SELECT folder_level, name FROM structured_contents_folders WHERE id = "+escape.cote(moveToFoldreId);
                    rs = Etn.execute(q);
                    if(!rs.next()){
                        throw new SimpleException("Cannot move to invalid folder");
                    }
                    moveToFolderLevel  = parseInt(rs.value("folder_level"));
                    movedToFolderName = rs.value("name");
                }

                int moveContentCount = 0;
                int moveFolderCount = 0;

                String movedContentIds = "";
                String movedContentNames = "";

                String movedFolderIds = "";
                String movedFolderNames = "";

                String type = "";

                ArrayList<String> unmovedItems = new ArrayList<>();
                ArrayList<String> unmovedItemsMessages = new ArrayList<>();

                for(Object obj : contents){
                    JSONObject contentObj  = (JSONObject)obj;
                    String id = contentObj.optString("id","-1");
                    type = contentObj.optString("type");
                    String name = getContentName(Etn, id, type);
                    JSONObject moveResp = null;

                    if(type.equals("folder")){
                        moveResp = moveFolder(Etn , id, moveToFoldreId, moveToFolderLevel, siteId);
                    } else {
                        moveResp = moveContent(Etn , id, moveToFoldreId, siteId);
                    }

                    boolean isMoved = moveResp.optBoolean("status");
                    if(isMoved){
                        if(type.equals("folder")){
                            moveFolderCount += 1;
                            movedFolderIds += id+", ";
                            movedFolderNames += name+", ";
                        } else if(type.equals(Constant.STRUCTURE_TYPE_CONTENT)){
                            moveContentCount += 1;
                            movedContentIds += id+", ";
                            movedContentNames += name+", ";
                        }
                    }else{
                        unmovedItems.add(name);
                        unmovedItemsMessages.add(moveResp.getString("message"));
                    }
                }
                if(totalCount == 1){
                    if(type.equals("folder")){
                        if(moveFolderCount > 0){
                            status = STATUS_SUCCESS;
                            message = "Folder moved";
                        } else {
                            if(unmovedItemsMessages.size()>0){
                                message = unmovedItemsMessages.get(0);
                            } else{
                                message = "Error in moving folder";
                            }
                        }
                    } else if(type.equals(Constant.STRUCTURE_TYPE_CONTENT)){
                        if(moveContentCount > 0){
                            status = STATUS_SUCCESS;
                            message = "Content moved";
                        } else {
                            if(unmovedItemsMessages.size()>0){
                                message = unmovedItemsMessages.get(0);
                            } else {
                                message = "Error in moving structured data";
                            }
                        }
                    }
                }
                else {
                    status = STATUS_SUCCESS;
                    if(moveContentCount > 0){
                        message = moveContentCount + " contents";
                    }
                    if(moveFolderCount > 0){
                        if(message.length()>0){
                            message += " and ";
                        }
                        message += moveFolderCount + " folders";
                    }
                    if(message.length()>0){
                        message += " moved to "+movedToFolderName+" folder";
                    }
                    if((moveFolderCount + moveContentCount) == 0){
                        message += "No structured data or folder moved";
                    }
                    if((moveFolderCount + moveContentCount) < totalCount){
                        message += "<br>";
                        for(int i = 0; i < unmovedItems.size(); i++){
                            message += "<br>";
                            message += unmovedItems.get(i)+" : "+ unmovedItemsMessages.get(i);
                        }
                    }
                }
                //logs
                if (status == STATUS_SUCCESS) {
                    if(movedFolderIds.length()>0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), movedFolderIds, "MOVED", "Content Folder", movedFolderNames+" (moved to) => "+movedToFolderName+" folder", siteId);
                    }
                    if(movedContentIds.length()>0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), movedContentIds, "MOVED", "Contents", movedContentNames+" (moved to) => "+movedToFolderName+" folder", siteId);
                    }
                }
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in moving Contents and folders. Please try again.",ex);
            }
        }else if("copyContent".equalsIgnoreCase(requestType)){
            int newContentId = 0;
            boolean isPageStructure = false;
            try{
                isDeleteInvalidPages = true;
                String contentId   = parseNull(request.getParameter("contentId"));
                String name   = parseNull(request.getParameter("name"));
                String folderType   = parseNull(request.getParameter("folderType"));
                String path   = parseNull(request.getParameter("path"));
                String structuredType   = parseNull(request.getParameter("structuredType"));

                HashMap<String, String> langPageHM = null;
                String structureType = "";
                // validdation copied page id
                q = "SELECT id, type, folder_id, template_id"
                    + " FROM structured_contents "
                    + " WHERE id = " + escape.cote(contentId)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid parameters.");
                }
                structureType = rs.value("type");
                String folderId = rs.value("folder_id");
                String templateId = rs.value("template_id");
                isPageStructure = structureType.equals(Constant.STRUCTURE_TYPE_PAGE);

                if(name.length() == 0){
                    throw new SimpleException("Error: Name cannot be empty");
                }
                else{
                    //check duplicate name
                    q = "SELECT sc.id FROM structured_contents sc JOIN bloc_templates bt ON bt.id = sc.template_id WHERE sc.name = " + escape.cote(name)
                        + " AND sc.type = " + escape.cote(structuredType)
                        + " AND sc.folder_id = " + escape.cote(folderId);

                    if(folderType.equals(Constant.FOLDER_TYPE_STORE)){
                        q += " AND bt.type = " + escape.cote(Constant.TEMPLATE_STORE);
                    }else{
                        q += " AND bt.type != " + escape.cote(Constant.TEMPLATE_STORE);
                    }

                    Set tempRs = Etn.execute(q);
                    if(tempRs.next()){
                        throw new SimpleException("Error: Name already exists. Please change name.");
                    }
                }
                if(isPageStructure){
                    if(path.length() == 0){
                	     if(folderType.equals(Constant.FOLDER_TYPE_PAGES)){
                	        throw new SimpleException("Error: path cannot be empty");
                	     }
                	}
                	else{

                		//check duplicate path+variant for all languanges
                        List<Language> langsList =  getLangs(Etn,siteId);
                        String pageIdStr = ""; // no page id as we are creating new page
                        String curSiteId = getSiteId(session);
                        String variant = "all";

                        for(Language curLang : langsList){
                            StringBuffer urlErrorMsg = new StringBuffer();
                            q = "SELECT fp.concat_path as folder_path FROM pages_folders_lang_path fp"
                                + " JOIN "+GlobalParm.getParm("CATALOG_DB") + ".language l on l.langue_id = fp.langue_id"
                                + " WHERE fp.site_id = "+escape.cote(siteId)
                                + " AND fp.folder_id = "+escape.cote(folderId)
                                + " AND l.langue_code = "+escape.cote(curLang.getCode());
                            rs =  Etn.execute(q);
                            String fullPagePath  = path;
                            if(rs.next()){
                                String pathPrefix = rs.value("folder_path");
                                if(pathPrefix.length()>0){
                                    fullPagePath = pathPrefix+"/"+path;
                                }
                            }
                            boolean isUnique = isPageUrlUnique(Etn, curSiteId,
                                                        curLang.getCode(), variant, fullPagePath,
                                                        pageIdStr, urlErrorMsg);
                            if(!isUnique){
                		    	throw new SimpleException("Error: Path '"+path+"' entered for language '"+curLang.getCode()+"' is not unique across the site. " + urlErrorMsg);
                            }
                        }

                		// //check duplicate path+variant
                		// //not adding lang check, as we need it for all langs
                		// q = "SELECT id FROM pages WHERE path = " + escape.cote(path)
                		//     + " AND variant = 'all' "
                		//     + " AND site_id = " + escape.cote(getSiteId(session));

                		// rs = Etn.execute(q);
                		// if(rs.next()){
                		//     throw new SimpleException("Error: Page having same path already exists.");
                		// }
                	}

                	langPageHM = new HashMap<>();
                }
                // inserting in structured contents
                int pid = Etn.getId();

                colValueHM.clear();
                colValueHM.put("name",escape.cote(name));
                colValueHM.put("created_by",escape.cote(""+pid));
                colValueHM.put("folder_id",escape.cote(folderId));
                colValueHM.put("template_id",escape.cote(templateId));
                colValueHM.put("site_id",escape.cote(siteId));
                colValueHM.put("type",escape.cote(structureType));
                colValueHM.put("updated_by",escape.cote(""+pid));
                colValueHM.put("created_ts","NOW()");
                colValueHM.put("updated_ts","NOW()");

                q = getInsertQuery("structured_contents",colValueHM);
                newContentId = Etn.executeCmd(q);
                if(newContentId <= 0){
                    throw new SimpleException("Error in copying structured "+structureType+". Please try again.");
                }

                // inserting pages of structured cotnents
                if(isPageStructure && path.length()>0){
                	//create copies of lang pages
                	q = " SELECT  langue_id, page_id "
                        + " FROM structured_contents_details "
                        + " WHERE content_id = " + escape.cote(contentId);
                    rs = Etn.execute(q);

                    EntityExport entityExport = new EntityExport(Etn, siteId);
                    EntityImport entityImport = new EntityImport(Etn,siteId, false, Etn.getId());

                    while(rs.next()){
                    	String curPageId = rs.value("page_id");
                    	if(parseInt(curPageId) > 0){

                            String langId = rs.value("langue_id");
 				    String langueCode = "";
                            Set rsLang = Etn.execute("SELECT langue_code FROM language WHERE langue_id = "+escape.cote(langId));
                            if(rsLang.next()){
                                langueCode = rsLang.value("langue_code");
                            }

                            JSONObject pageObj = entityExport.getPageSettingJson(curPageId);
				    JSONObject folderObj = entityExport.getFolderJSON(folderId, "folders", true, true, false);
				    pageObj.getJSONObject("system_info").put("langue_code", langueCode);
                            pageObj.getJSONObject("system_info").put("name", name);
                            pageObj.getJSONObject("system_info").put("path", path);
                            pageObj.getJSONObject("system_info").put("variant", "all");
				    pageObj.getJSONObject("system_info").put("folder", folderObj);
                            entityImport.importItemPageSettings(pageObj, "keep",newContentId+"",false,"",folderType);

                            String newPageId = pageObj.optString("id");
                            if(newPageId == null){
                                String langue_code = pageObj.getJSONObject("system_info").getString("langue_code");
                                rollbackPageInsert(Etn, newContentId+"", siteId, Constant.PAGE_TYPE_STRUCTURED);
                                throw new SimpleException("Error in copying page settings for lang :" + langue_code);
                            }
                            else{
                                q = "UPDATE pages SET type = " + escape.cote(Constant.PAGE_TYPE_STRUCTURED) +", parent_page_id = "+escape.cote(newContentId+"")
                                    + " WHERE id = " + escape.cote(newPageId);
                                Etn.executeCmd(q);
                                langPageHM.put(langId, newPageId);
                            }
                    	}
                    }
                }
                // adding content details
                q = " SELECT * "
                    + " FROM structured_contents_details "
                    + " WHERE content_id = " + escape.cote(contentId);
                rs = Etn.execute(q);

                while(rs.next()){

                    String newPageId = "0";
                    if(isPageStructure && path.length()>0){
                        newPageId = ""+parseInt(langPageHM.get(rs.value("langue_id")),0);
                    }

                    colValueHM.clear();
                    for(String colName : rs.ColName){
                            colValueHM.put(colName.toLowerCase(), escape.cote(rs.value(colName)));
                    }
                    colValueHM.remove("id");
                    colValueHM.put("content_id",escape.cote(""+newContentId));
                    colValueHM.put("page_id",escape.cote(newPageId));
                    q = getInsertQuery("structured_contents_details",colValueHM);

                    int newDetailId = Etn.executeCmd(q);
                    if(newDetailId <= 0){
                        message = "Error in copying detail record. Please try again.";
                    }

                }

                status = STATUS_SUCCESS;
                message = structureType + " copied.";

            }//try
            catch(Exception ex){
                if(isPageStructure){
                    rollbackPageInsert(Etn, newContentId+"", siteId, Constant.PAGE_TYPE_STRUCTURED);
                }
                throw new SimpleException("Error in copying.",ex);
            }
        }else if("publishContents".equalsIgnoreCase(requestType)){

            try{
                String contentIds = parseNull(request.getParameter("contentIds"));
                ArrayList<String> contentIdList = getValidContentIds(Etn, contentIds, siteId);

                int pid = Etn.getId();
                if(contentIdList.size() == 0){
                    message = "Error: No valid content ids found";
                }
                else{
                	//publish
                	int totalCount = contentIdList.size();
                    int publishCount = 0;

                    for(String curContentId : contentIdList){
                        try{
                            boolean isPublished =  PagesUtil.copyContentPublish(Etn, curContentId);
                            if(isPublished){
                                q = "UPDATE structured_contents_published "
                                    + " SET publish_status = 'published', published_ts = NOW() "
                                    + " , published_by = " +escape.cote(""+pid)
                                    + " WHERE id = " + escape.cote(curContentId);
                                Etn.executeCmd(q);

                                q = "UPDATE structured_contents sc "
                                    + " JOIN structured_contents_published scp ON sc.id = scp.id "
                                    + " SET sc.publish_status = scp.publish_status "
                                    + " , sc.published_ts = scp.published_ts , sc.published_by = scp.published_by "
                                    + " WHERE sc.id = " + escape.cote(curContentId);
                                Etn.executeCmd(q);
                                publishCount++;
                            }
                        }
                        catch(Exception ex){
                            ex.printStackTrace();
                        }
                    }//for
                    if(publishCount == totalCount){
                        status = STATUS_SUCCESS;
                        message =  "Content published.";
                    }
                    else{
                        //publishCount < totalCount
                        if(totalCount == 1){
                            status = STATUS_ERROR;
                            message = "Error in publishing content";
                        }
                        else if(publishCount == 0){
                            status = STATUS_ERROR;
                            message = "Error in publishing all content(s)";
                        }
                        else{
                            status = STATUS_SUCCESS;
                            message = publishCount + " of " + totalCount + " published";
                        }
                    }
                }//else if(size == 0)

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in publishing content(s). Please try again.",ex);
            }
        }else if("unpublishContents".equalsIgnoreCase(requestType)){
        	 try{

                String contentIds = parseNull(request.getParameter("contentIds"));

                ArrayList<String> contentIdList = getValidContentIds(Etn, contentIds, siteId);

                int pid = Etn.getId();
                if(contentIdList.size() == 0){
                    message = "Error: No valid content ids found";
                }
                else{
                	//unpublish
                	int totalCount = contentIdList.size();
                    int unpublishCount = 0;

                    for(String curContentId : contentIdList){
                        try{
                            boolean isUnpublished =  PagesUtil.deleteContentPublish(Etn, curContentId);
                            if(isUnpublished){
                                q = "UPDATE structured_contents sc "
                                    + " SET publish_status = 'unpublished' "
                                    + " , published_ts = null, published_by =  "+escape.cote(Etn.getId()+"")
                                    + " WHERE id = " + escape.cote(curContentId);
                                Etn.executeCmd(q);
                                unpublishCount++;
                            }
                        }
                        catch(Exception ex){
                            ex.printStackTrace();
                        }
                    }
                    //content (not page)
                    if(unpublishCount == totalCount){
                        status = STATUS_SUCCESS;
                        message = "Content unpublished.";
                    }
                    else{
                        //unpublishCount < totalCount
                        if(totalCount == 1){
                            status = STATUS_ERROR;
                            message = "Error in unpublishing content";
                        }
                        else if(unpublishCount == 0){
                            status = STATUS_ERROR;
                            message = "Error in unpublishing all contents";
                        }
                        else{
                            status = STATUS_SUCCESS;
                            message = unpublishCount + " of " + totalCount + " unpublished";
                        }
                    }
                }//else if(size == 0)
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in unpublishing content(s). Please try again.",ex);
            }
        }
    }
    catch(SimpleException ex){
        message = ex.getMessage();
        ex.print();
    }
    finally{
    	if(isDeleteInvalidPages){
    		deleteInvalidStructuredPages(Etn);
    	}
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
    out.write(jsonResponse.toString());
%>