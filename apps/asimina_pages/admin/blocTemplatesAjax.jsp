<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.pages.PagesUtil, org.json.JSONObject, org.json.JSONArray, com.etn.pages.FilesUtil, java.util.Map, com.etn.asimina.util.ActivityLog, java.sql.SQLException"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%!

    public int parseNullInt(String s)
	{
       	if (s == null) return 0;
	       if (s.equals("null")) return 0;
       	return Integer.parseInt(s);
	}

    void addingBlocTemplateDescription(Contexte Etn,int templateId, List<Map<String, Object>> descriptionArray) throws SQLException
    {
        Etn.execute("DELETE FROM bloc_template_description where bloc_template_id="+escape.cote(templateId+""));   
        for ( Map<String, Object> descrip : descriptionArray) {
            
            String description = parseNull(descrip.get("description"));
            String imageInfo = parseNull(descrip.get("image_info"));
            String altImage = parseNull(descrip.get("alt_image"));
            int langId = Integer.parseInt((String) descrip.get("lang_id"));
            Etn.executeCmd("INSERT INTO bloc_template_description(bloc_template_id, lang_id ,description,image_info) values("+escape.cote(templateId+"")+","+escape.cote(langId+"")+","+escape.cote(parseNull(description))+","+escape.cote(parseNull(imageInfo)+"##;##"+parseNull(altImage))+")");
        }
    }

    JSONArray getTemplateDescription(Contexte Etn,String templateId)
    {
        
        Set templateDescription = Etn.execute("SELECT description,lang_id,image_info FROM bloc_template_description WHERE bloc_template_id="+escape.cote(templateId)+" ORDER BY id");
        JSONArray jsonTmpArray = new JSONArray();
        while(templateDescription.next())
        {
            JSONObject tmpDesc = new JSONObject();
            tmpDesc.put("description",parseNull(templateDescription.value("description")));
            tmpDesc.put("lang_id",parseNull(templateDescription.value("lang_id")));
            try{
                tmpDesc.put("image_src",parseNull(templateDescription.value("image_info")).split("##;##")[0]);
            }catch(ArrayIndexOutOfBoundsException e)
            {
                tmpDesc.put("image_src","");
            }
            try{
                tmpDesc.put("image_label",parseNull(templateDescription.value("image_info")).split("##;##")[1]);
            }catch(ArrayIndexOutOfBoundsException e)
            {
                tmpDesc.put("image_label","");
            }
            jsonTmpArray.put(tmpDesc);
        }

        return jsonTmpArray;
    }

    JSONArray getExtraTemplateFieldsByType(String templateType){

        JSONArray retList = new JSONArray();

        if(Constant.TEMPLATE_FEED_VIEW.equals(templateType)){

            JSONObject rssFeedObj = new JSONObject();

            rssFeedObj.put("name","RSS Feeds");
            rssFeedObj.put("custom_id","rss_feed");
            rssFeedObj.put("nb_items","0");

            JSONArray rssFields = new JSONArray();

            JSONObject feedNameObj = new JSONObject();
            feedNameObj.put("name","Name");
            feedNameObj.put("custom_id","name");
            feedNameObj.put("nb_items","1");
            feedNameObj.put("type","text");
            rssFields.put(feedNameObj);

            rssFeedObj.put("fields",rssFields);

            JSONArray rssSections = new JSONArray();
            rssFeedObj.put("sections",rssSections);

            retList.put(rssFeedObj);

            JSONObject channelObj = new JSONObject();

            channelObj.put("name","Channel");
            channelObj.put("custom_id","channel");
            channelObj.put("nb_items","1");

            JSONArray channelFields = new JSONArray();
            for(String field : PagesUtil.FEED_CHANNEL_FIELDS){

                String fieldName = field.replaceAll("_"," ");
                fieldName = fieldName.substring(0,1).toUpperCase()
                                    + fieldName.substring(1);

                JSONObject curField = new JSONObject();
                curField.put("name", fieldName);
                curField.put("custom_id",field);
                curField.put("nb_items","1");
                curField.put("type","text");
                channelFields.put(curField);
            }

            channelObj.put("fields",channelFields);

            rssSections.put(channelObj);

            JSONObject feedItemsObj = new JSONObject();

            feedItemsObj.put("name","Items");
            feedItemsObj.put("custom_id","item");
            feedItemsObj.put("nb_items","0");

            JSONArray feedItemFields = new JSONArray();
            for(String field : PagesUtil.FEED_ITEM_FIELDS){

                String fieldName = field.replaceAll("_"," ");
                fieldName = fieldName.substring(0,1).toUpperCase()
                                    + fieldName.substring(1);

                JSONObject curField = new JSONObject();
                curField.put("name", fieldName);
                curField.put("custom_id",field);
                curField.put("nb_items","1");
                curField.put("type","text");
                feedItemFields.put(curField);
            }

            feedItemsObj.put("fields",feedItemFields);


            rssSections.put(feedItemsObj);
        }
        else if(Constant.SYSTEM_TEMPLATE_MENU.equals(templateType)){
        	JSONObject systemInfo = new JSONObject();

            systemInfo.put("name","System info");
            systemInfo.put("custom_id","system_info");
            systemInfo.put("nb_items","1");

            String[] fieldsNamesList = {
            	"uuid", "name"
            };

            JSONArray fields = new JSONArray();
            systemInfo.put("fields", fields);
            for(String fieldName : fieldsNamesList){
            	JSONObject feedNameObj = new JSONObject();
	            feedNameObj.put("name",fieldName.replaceAll("_"," "));
	            feedNameObj.put("custom_id",fieldName);
	            feedNameObj.put("nb_items","1");
	            feedNameObj.put("type","text");
	            fields.put(feedNameObj);
            }

			JSONObject field = new JSONObject();
			field.put("name", "ecommerce enabled");
			field.put("custom_id","ecommerce_enabled");
			field.put("nb_items","1");
			field.put("type","text");
			fields.put(field);

            retList.put(systemInfo);
        }
		else
		{			
			JSONObject systemInfo = new JSONObject();
            systemInfo.put("name","System info");
            systemInfo.put("custom_id","system_info");
            systemInfo.put("nb_items","1");
            JSONArray fields = new JSONArray();
			JSONObject field = new JSONObject();
			field.put("name", "ecommerce enabled");
			field.put("custom_id","ecommerce_enabled");
			field.put("nb_items","1");
			field.put("type","text");
			fields.put(field);
            systemInfo.put("fields", fields);
			
			retList.put(systemInfo);
		}

        return retList;
    }

%>
<%
    final int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    Map<String, String> colValueHM = new LinkedHashMap<>();

    String q = "";
    Set rs = null;
    int count = 0;

    String siteId = getSiteId(session);

    String requestType = parseNull(request.getParameter("requestType"));

    String logedInUserId = parseNull(Etn.getId());

    try{

        if("getList".equalsIgnoreCase(requestType)){
            try{

                String templateType = parseNull(request.getParameter("templateType"));
                boolean isSystem = "system".equals(templateType);

                String systemTemplateTypes = convertArrayToCommaSeperated(Constant.getSystemTemplateTypes(), escape::cote);

                JSONArray resultList = new JSONArray();
                JSONObject curObj = null;

                q = " SELECT bt.id, bt.name, bt.type, bt.custom_id, bt.updated_ts ,l.name updated_by"
                	+ " , IFNULL(b.nb_use,0) + IFNULL(c.nb_use,0) + IFNULL(d.nb_use,0) as nb_use "
                    + " , th.name as theme_name, th.version as theme_version, th.status as theme_status, bt.theme_id "
                    + " FROM bloc_templates bt "
                    + " LEFT JOIN themes th ON th.id = bt.theme_id"
                    + " LEFT JOIN login l on l.pid = bt.updated_by "
                    + " LEFT JOIN ("
                    + "     SELECT template_id, COUNT(id) as nb_use "
                    + "     FROM blocs GROUP BY template_id"
                    + "     ) b ON b.template_id = bt.id "
                    + " LEFT JOIN ("
                    + "     SELECT sc.template_id, COUNT(sc.id) as nb_use "
                    + "     FROM structured_contents sc "
                    + "     GROUP BY sc.template_id"
                    + "     ) c ON c.template_id = bt.id "
                    + " LEFT JOIN ("
                    + "     SELECT ptv.template_id, COUNT(ptv.id) as nb_use "
                    + "     FROM "+GlobalParm.getParm("CATALOG_DB")+".product_types_v2 ptv "
                    + "     GROUP BY ptv.template_id"
                    + "     ) d ON d.template_id = bt.id "
                    + " WHERE bt.site_id = " + escape.cote(siteId);

                if(isSystem) q += " AND bt.type IN (" + systemTemplateTypes + ")";
                else q += " AND bt.type NOT IN (" + systemTemplateTypes+ ")";
                
                rs = Etn.execute(q);
                while(rs.next()){
                    curObj = new JSONObject();
                    for(String colName : rs.ColName){
                        curObj.put(colName.toLowerCase(), rs.value(colName));
                    }

                    resultList.put(curObj);
                }

                data.put("templates",resultList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting template list. Please try again.", ex);
            }
        }
        else if("getTemplateDescription".equalsIgnoreCase(requestType))
        {
            try{
                data.put("template",getTemplateDescription(Etn,parseNull(request.getParameter("templateId"))));
                status = STATUS_SUCCESS;
            }catch(Exception exception)
            {
                throw new SimpleException("Error in fetching template. Please try again.",exception);
            }
        }
        else if("saveTemplate".equalsIgnoreCase(requestType)){
            try{
                int templateId = parseInt(request.getParameter("templateId"), 0);

                String name = parseNull(request.getParameter("name"));
                String custom_id = parseNull(request.getParameter("custom_id"));
                String type = parseNull(request.getParameter("type"));
                List<Language> langList = getLangs(Etn,siteId);
                List<Map<String, Object>> descriptionArray = new ArrayList<>();
                
                for(Language curLang : langList){
                    String langId = curLang.getLanguageId();
                    String[] description = request.getParameterValues("description_" + langId);
                    String[] imagesValue = request.getParameterValues("image_value_" + langId);
                    String[] imagesAlt = request.getParameterValues("image_alt_" + langId);
                    for (int i = 0; i < description.length; i++) {
                        Map<String, Object> descriptionObject = new HashMap<>();
                        descriptionObject.put("lang_id", langId);
                        descriptionObject.put("description", description[i]);
                        if (imagesValue != null && i < imagesValue.length) {
                            descriptionObject.put("image_info", imagesValue[i]);
                        }
                        if (imagesAlt != null && i < imagesAlt.length) {
                            descriptionObject.put("alt_image", imagesAlt[i]);
                        }

                        descriptionArray.add(descriptionObject);
                    }
                }
                String templateType = parseNull(request.getParameter("templateType"));
                   
                int themeVersion = 0;
                int themeId = 0;

                if(templateId > 0){
                    q = "SELECT bt.theme_id, bt.theme_version, th.status as theme_status FROM bloc_templates_tbl bt "
                        + " LEFT JOIN themes th ON th.id = bt.theme_id"
                        + " WHERE bt.id = " + escape.cote(templateId+"")
                        + " AND is_deleted='0' AND bt.site_id = " + escape.cote(siteId);

                    rs =  Etn.execute(q);
                    if(rs.next()){
                        if(!isSuperAdmin(Etn) && rs.value("theme_status").equals(Constant.THEME_LOCKED)){
                             throw new SimpleException("You are not authorized.");
                        }
                        themeId = parseInt(rs.value("theme_id"));
                        themeVersion = parseInt(rs.value("theme_version"));
                    } else{
                         throw new SimpleException("Invalid template Id.");
                    }
                }
                String errorMsg = "";
                if(name.length() == 0){
                    errorMsg = "Name cannot be empty";
                }
                if(custom_id.length() == 0){
                    errorMsg = "Template ID cannot be empty";
                }
                if(errorMsg.length() == 0){
                    //check duplicate path+variant
                    q = "SELECT id FROM bloc_templates_tbl "
                        + " WHERE custom_id = " + escape.cote(custom_id)
                        + " AND is_deleted='0' AND site_id = " + escape.cote(siteId);
                    if(templateId > 0){
                        q += " AND id != " + escape.cote(""+templateId);
                    }

                    rs = Etn.execute(q);
                    if(rs.next()){
                        errorMsg = "Template ID already exist. please specify different ID.";
                    }
                }

                if(errorMsg.length() > 0){
                    message = errorMsg;
                }
                else{

                    int pid = Etn.getId();

                    colValueHM.put("name", escape.cote(name));
                    colValueHM.put("custom_id", escape.cote(custom_id));
                    colValueHM.put("updated_ts", "NOW()");
                    colValueHM.put("updated_by", escape.cote(""+pid));

                    if(templateId <= 0){
                        //new template

                        colValueHM.put("created_ts", "NOW()");
                        colValueHM.put("created_by", escape.cote(""+pid));
                        colValueHM.put("site_id", escape.cote(siteId));
                        colValueHM.put("type", escape.cote(type));

                        q = getInsertQuery("bloc_templates_tbl",colValueHM);
                        templateId = Etn.executeCmd(q);

                        if(templateId <= 0){
                            message = "Error in creating template. Please try again.";
                        }
                        else{
                            if(type.contains("product")){
                                JSONArray sectionsList = getNewProductTemplateJson(type);
                                insertUpdateTemplateSections(Etn,sectionsList,Integer.toString(templateId),"0",true);
                            }

                            try{
                                addingBlocTemplateDescription(Etn,templateId,descriptionArray);
                                status = STATUS_SUCCESS;
                                message = "Template created.";
                                data.put("templateId", templateId);
                            }catch(SQLException exception){
                                throw new SimpleException("Template Description INSERTION Error Occurred");
                            }

                            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),templateId+"","CREATED","Block Template",name,siteId);
                        }
                    }
                    else{
                        if(themeId > 0){
                            themeVersion = themeVersion + 1;
                            colValueHM.put("theme_version", escape.cote(themeVersion+""));
                        }
                        //existing template update
                        q = getUpdateQuery("bloc_templates_tbl", colValueHM, " WHERE is_deleted='0' and id = " + escape.cote(""+templateId));
                        count = Etn.executeCmd(q);

                        if(count <= 0) message = "Error in updating template. Please try again.";
                        else{
                            try{
                                addingBlocTemplateDescription(Etn,templateId,descriptionArray);
                                markPagesToGenerate(""+templateId, "bloc_templates",Etn);

                                status = STATUS_SUCCESS;
                                message = "Template updated.";
                                data.put("templateId", templateId);
                            } catch(SQLException exception) {
                                throw new SimpleException("Bloc Template Description UPDATING Error Occurred");
                            }
                            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),templateId+"","UPDATED","Block Template",name,siteId);
                        }
                    }
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving template. Please try again.",ex);
            }
        }
        else if("getTemplateInfo".equalsIgnoreCase(requestType)){

            try{
                String templateId = parseNull(request.getParameter("templateId"));
                JSONObject templateJson = new JSONObject();

                q = "SELECT id, name, custom_id, type FROM bloc_templates "
                    + " WHERE id = " + escape.cote(templateId)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if(rs.next()){
                    for(String colName : rs.ColName){
                        templateJson.put(colName.toLowerCase(), rs.value(colName));
                    }
                    templateJson.put("description-template",getTemplateDescription(Etn,parseNull(templateId)));
                    data.put("template",templateJson);
                    status = STATUS_SUCCESS;
                }
                else{
                    message = "Error template not found.";
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting template info.", ex);
            }
        }
        else if("deleteTemplates".equalsIgnoreCase(requestType)){
            try{
                String templateIds[]= request.getParameterValues("templateIds");

                int totalCount = templateIds.length;
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                int deleteCount = 0;

                String deletedTemplateIds = "";
                String deletedTemplateNames = "";
                Set rs_name = null;
                for(String templateId : templateIds){

                    q = "SELECT SUM(nb_use) as  nb_use "
                        + " FROM ( "
                        + "     SELECT COUNT(0) as nb_use FROM blocs  "
                        + "     WHERE template_id = " + escape.cote(templateId)
                        + "  UNION ALL "
                        + "     SELECT COUNT(sc.id) as nb_use  "
                        + "     FROM structured_contents sc  "
                        + "     WHERE template_id =  " + escape.cote(templateId)
                        + " ) t";

                    rs = Etn.execute(q);
                    if(!rs.next()){
                        continue;
                    }

                    int usesCount = parseInt(rs.value("nb_use"),-1);

                    if(usesCount != 0){
                        continue;
                    }
                    // if template is a part of theme then it cannot be deleted
                    q = "SELECT bt.theme_id FROM bloc_templates_tbl bt "
                        + " LEFT JOIN themes th ON th.id = bt.theme_id"
                        + " WHERE bt.id = " + escape.cote(templateId)
                        + " AND is_deleted='0' AND bt.site_id = " + escape.cote(siteId);

                    rs =  Etn.execute(q);
                    if(rs.next() && parseInt(rs.value("theme_id"))>0){ //it is part of theme
                        continue;
                    }

                    Set rsProductType = Etn.execute("select * from "+GlobalParm.getParm("CATALOG_DB")+".product_types_v2 where template_id ="+escape.cote(templateId));
                    if(rsProductType.rs.Rows>0){
                        continue;
                    }

                    rs_name =  Etn.execute("SELECT name from bloc_templates_tbl WHERE id = "+escape.cote(templateId)+" and is_deleted='0' AND site_id = "
                        +escape.cote(siteId));
                    rs_name.next();
                    String curName = parseNull(rs_name.value(0));

                    //check duplicate in trash
                    Set rsCheckTrash= Etn.execute("SELECT bt1.* FROM bloc_templates_tbl bt1 JOIN bloc_templates_tbl bt2 ON bt1.site_id=bt2.site_id"+
                        " AND bt1.custom_id=bt2.custom_id AND bt1.id!=bt2.id where bt1.id="+escape.cote(templateId));
                    if(rsCheckTrash.rs.Rows==0){
                        Etn.executeCmd("UPDATE bloc_templates SET is_deleted='1',updated_ts=NOW(),updated_by="+escape.cote(logedInUserId)+
                            " WHERE id = "+escape.cote(templateId));

                        deletedTemplateIds += templateId +",";
                        deletedTemplateNames += curName+", ";
                        deleteCount += 1;
                    }
                }
                if(totalCount == 1){
                    if(deleteCount != 1){
                        throw new SimpleException("Error: Cannot delete. Templates who have identical in trash, in use or part of theme can not be deleted.");
                    }
                    else{
                        status = STATUS_SUCCESS;
                        message = "template deleted";
                    }
                }
                else{
                    status = STATUS_SUCCESS;
                    message = deleteCount + " of " + totalCount + " templates deleted";
                    if(deleteCount < totalCount){
                        message += ". Templates who have identical in trash, in use and part of theme are not deleted.";
                    }
                }
                if(status == STATUS_SUCCESS)
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),deletedTemplateIds,"DELETED","Block Templates",deletedTemplateNames,siteId);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting templates.",ex);
            }
        }
        else if("getTemplateSectionsData".equalsIgnoreCase(requestType)){
            try{
                String templateId = parseNull(request.getParameter("template_id"));
                String withExtra = parseNull(request.getParameter("with_extra"));


                q = "SELECT id, type from bloc_templates WHERE id = "+ escape.cote(templateId)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid parameters");
                }

                JSONArray sectionsList = PagesUtil.getBlocTemplateSectionsData(Etn, templateId);
                data.put("sections",sectionsList);

                if("1".equals(withExtra)){
                    //get extra special variables for template type
                    JSONArray extraList = getExtraTemplateFieldsByType(rs.value("type"));
                    data.put("extra",extraList);
                }

                // collecting the global vaiables
                JSONArray variables = new JSONArray();
                String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");

                q = "SELECT name FROM variables WHERE site_id = "+escape.cote(siteId);
                rs = Etn.execute(q);
                while (rs.next()){
                    variables.put(rs.value("name"));
                }

                variables.put("images_path");
                variables.put("videos_path");
                variables.put("js_path");
                variables.put("css_path");
                variables.put("fonts_path");
                variables.put("other_files_path");

                // algolia settings
                variables.put("algolia_application_id");
                variables.put("algolia_search_api_key");
                variables.put("algolia_write_api_key");
                variables.put("translateFunc()");

                // get default index of algolia
                q = "SELECT CONCAT('algolia_default_index_', langue_code) as default_index_name" +
                        " FROM "+CATALOG_DB+".algolia_default_index ai " +
                        " LEFT JOIN "+CATALOG_DB+".language AS l ON l.langue_id = ai.langue_id " +
                        " WHERE ai.site_id = "+escape.cote(siteId);

                rs = Etn.execute(q);
                while(rs.next()){
                    variables.put(rs.value("default_index_name"));
                }

                variables.put("domain");
                variables.put("currency_code");
                variables.put("currency_position");
                
                variables.put("currency_label");
                
                variables.put("price_formatter");
                variables.put("round_to_decimals");
                variables.put("show_decimals");

                data.put("globalVariables", variables);

                status = STATUS_SUCCESS;
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting sections data. Please try again.", ex);
            }

        }
        else if("saveTemplateSections".equalsIgnoreCase(requestType)){

            try{
                String templateId = parseNull(request.getParameter("template_id"));

                String jsonStr = parseNull(request.getParameter("data"));
                
                q = "SELECT bt.id, bt.name, bt.type, th.status, bt.theme_id, bt.theme_version "
                + " FROM  bloc_templates_tbl as bt "
                + " LEFT JOIN themes th ON th.id = bt.theme_id "
                + " WHERE bt.id = "+ escape.cote(templateId)
                + " AND bt.is_deleted='0' AND bt.site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid parameters");
                }
                if(rs.value("status").equals(Constant.THEME_LOCKED) && !isSuperAdmin(Etn)){
                    throw new SimpleException("You are not authorized.");
                }
                String name = rs.value("name");

                JSONObject sectionsData = new JSONObject(jsonStr);
                
                JSONArray sectionsList = sectionsData.getJSONArray("sections");
                int pid = Etn.getId();
                insertUpdateTemplateSections(Etn, sectionsList, templateId, "0", false);

                // update the theme version
                if(parseInt(rs.value("theme_id"))>0){
                    int themeVersion  = parseInt(rs.value("theme_version")) + 1;
                    q = "UPDATE bloc_templates_tbl SET theme_version = "+escape.cote(themeVersion+"")+
                        " WHERE id = "+escape.cote(templateId)+" AND is_deleted='0' AND site_id = "+escape.cote(siteId);
                    Etn.execute(q);

                }

                markPagesToGenerate(""+templateId, "bloc_templates",Etn);

                status = STATUS_SUCCESS;
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),templateId+"","UPDATED","Block Template Sections",name, siteId);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving sections data. Please try again.", ex);
            }
        }
        else if("getTemplateResourcesData".equalsIgnoreCase(requestType)){
            try{
                String templateId = parseNull(request.getParameter("template_id"));

                q = "SELECT id, template_code, css_code, js_code, jsonld_code from bloc_templates "
                    + " WHERE id = "+ escape.cote(templateId)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid parameters");
                }

                data.put("template_code",rs.value("template_code"));
                data.put("css_code",rs.value("css_code"));
                data.put("js_code",rs.value("js_code"));
                data.put("jsonld_code",rs.value("jsonld_code"));

                JSONArray libraries = new JSONArray();
                q = "SELECT l.id , l.name FROM libraries l "
                    + " JOIN bloc_templates_libraries bl ON bl.library_id = l.id "
                    + " WHERE bl.bloc_template_id = "+ escape.cote(templateId)
                    + " ORDER BY bl.id";
                rs = Etn.execute(q);

                JSONObject curEntry = null;
                while(rs.next()){
                    curEntry = new JSONObject();
                    for(String colName : rs.ColName){
                        curEntry.put(colName.toLowerCase(), rs.value(colName));
                    }

                    libraries.put(curEntry);
                }
                data.put("libraries",libraries);

                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting resources data. Please try again.",ex);
            }

        }
        else if("saveTemplateResources".equalsIgnoreCase(requestType)){

            try{
                String templateId = parseNull(request.getParameter("template_id"));

                q = "SELECT bt.id, bt.name, th.status, bt.theme_id, bt.theme_version from bloc_templates_tbl as bt "
                + " LEFT JOIN themes th ON th.id = bt.theme_id "
                + " WHERE bt.id = "+ escape.cote(templateId)
                + " AND bt.is_deleted='0' AND bt.site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid parameters");
                }
                if(rs.value("status").equals(Constant.THEME_LOCKED) && !isSuperAdmin(Etn)){
                    throw new SimpleException("You are not authorized.");
                }

                String name = rs.value("name");

                String template_code = parseNull(request.getParameter("template_code"));
                String css_code = parseNull(request.getParameter("css_code"));
                String js_code = parseNull(request.getParameter("js_code"));
                String jsonld_code = parseNull(request.getParameter("jsonld_code"));

                String libraries[] = parseNull(request.getParameter("libraries")).split(",");

                colValueHM.clear();
                if(parseInt(rs.value("theme_id"))>0){
                    int themeVersion  = parseInt(rs.value("theme_version")) + 1;
                    colValueHM.put("theme_version", escapeCote(themeVersion+""));
                }
                colValueHM.put("template_code", escapeCote(template_code));
                colValueHM.put("css_code", escapeCote(css_code));
                colValueHM.put("js_code", escapeCote(js_code));
                colValueHM.put("jsonld_code", escapeCote(jsonld_code));

                colValueHM.put("updated_ts", "NOW()");
                colValueHM.put("updated_by", escape.cote(""+Etn.getId()));

                q = getUpdateQuery("bloc_templates", colValueHM, " WHERE id = " + escape.cote(templateId) );

                count = Etn.executeCmd(q);

                if(count <= 0){
                    throw new SimpleException("Error in updating template resources. Please try again.");
                }

                q = "DELETE FROM bloc_templates_libraries WHERE bloc_template_id = " + escape.cote(templateId);
                Etn.executeCmd(q);

                count = 0;
                String qPrefix = "INSERT INTO bloc_templates_libraries (bloc_template_id, library_id) "
                            + " VALUES (" + escape.cote(templateId) + " , ";
                for(String libId : libraries){
                    if(parseInt(libId) > 0 ){
                        q = qPrefix + escape.cote(libId) + " )";
                        Etn.executeCmd(q);
                        count++;
                    }
                }

                markPagesToGenerate(""+templateId, "bloc_templates",Etn);

                status = STATUS_SUCCESS;
                message = "Resources updated.";

                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),templateId+"","UPDATED","Block Template Resources",name,siteId);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving resources data. Please try again.",ex);
            }
        } else if("getExistingFields".equalsIgnoreCase(requestType)){
            try{
                String whereCondition="";
                String searchValue = parseNull(request.getParameter("search"));
                if(!searchValue.isEmpty()) whereCondition = " where sf.name like "+escape.cote("%"+searchValue+"%")+" or sf.custom_id like "+escape.cote("%"+searchValue+"%")+" or sf.type like "+escape.cote("%"+searchValue+"%");

                String offset = parseNull(request.getParameter("offset"));
                String limit = "";
                if(!offset.isEmpty()) limit = "limit "+parseNullInt(offset)+","+parseNullInt(request.getParameter("limit"));

                JSONArray fields = new JSONArray();
                JSONObject curObj = new JSONObject();

                q = "SELECT sf.name,sf.field_specific_data, sf.custom_id, sf.type, sf.nb_items, sf.value, sf.is_required, sf.is_bulk_modify, sf.is_indexed, sf.is_meta_variable "
                    + " FROM sections_fields  sf "
                    + " JOIN ( "
                    + "     SELECT bts.id AS final_id FROM bloc_templates_sections bts LEFT JOIN bloc_templates bt ON bt.id = bts.bloc_template_id  "
                    + "     LEFT JOIN bloc_templates_sections bts2 ON bts2.id  = bts.parent_section_id LEFT JOIN bloc_templates bt2 ON bt2.id = bts2.bloc_template_id "
                    + "     WHERE IFNULL(bt.site_id,bt2.site_id) = "+ escape.cote(siteId)
                    + " )  bts_final ON bts_final.final_id = sf.section_id "+whereCondition+" GROUP BY sf.name, sf.custom_id, sf.type ORDER BY sf.name "+limit;
                
                rs = Etn.execute(q);
                while(rs.next()){
                    curObj = new JSONObject();
                    for(String colName : rs.ColName){
                        curObj.put(colName.toLowerCase(), rs.value(colName));
                    }
					//we can have multiple fields with same name and custom_id and type ... for lang data we will load the very old fields data as we assume
					//once a field was created first it has highest probability of being used again
					Set rs1 = Etn.execute("select id from sections_fields where name = "+escape.cote(rs.value("name"))+" and custom_id = "+escape.cote(rs.value("custom_id"))+" and type = "+escape.cote(rs.value("type")) + " order by id ");
					if(rs1.next()) {
						JSONArray langDatas = new JSONArray();
						curObj.put("lang_data", langDatas);
						Set rsDetails = Etn.execute("Select s.*, l.langue_code from sections_fields_details s, language l where l.langue_id = s.langue_id and s.field_id = "+escape.cote(rs1.value("id")));
						while(rsDetails.next()) {
							JSONObject langData = new JSONObject();
							langData.put("langue_id", rsDetails.value("langue_id"));
							langData.put("langue_code", rsDetails.value("langue_code"));
							langData.put("default_value", rsDetails.value("default_value"));
							langData.put("placeholder", rsDetails.value("placeholder"));
							langDatas.put(langData);
						}
					}
                    fields.put(curObj);
                }
                data.put("fields",fields);
                status = STATUS_SUCCESS;
            } catch(Exception ex){
                throw new SimpleException("Error in saving resources data. Please try again.",ex);
            }
        } else if("getTemplatesBlocs".equalsIgnoreCase(requestType)) {
            try{
                String [] templateIds = request.getParameterValues("templateIds[]");
                boolean isValid = true;

                JSONArray blocs = new JSONArray();
                q = "SELECT b.id, b.name as label, bt.id as template_id, bt.name template from blocs b left join bloc_templates bt on b.template_id = bt.id "
                    + " WHERE b.site_id = " + escape.cote(siteId);
                
                if(templateIds.length > 0){   
                    String temp = " AND b.template_id in (";
                    for(String tempId : templateIds) {
                        if(tempId.equalsIgnoreCase("") || tempId.equalsIgnoreCase("all")) isValid = false;
                        temp+= escape.cote(tempId) +",";
                    }
                    if(isValid)
                        q = q + temp.substring(0, temp.length() - 1) + ")";
                }
                
                rs = Etn.execute(q);
                while(rs.next()){
                    blocs.put(getJSONObject(rs));
                }
                
                data.put("blocs",blocs);
                status = STATUS_SUCCESS;
            } catch(Exception ex) {
                throw new SimpleException("Error in getting Blocs. Please try again.",ex);
            }
        }
        else if("getTemplatesByType".equalsIgnoreCase(requestType)){
            try{
                String type = parseNull(request.getParameter("type"));

                JSONArray templates = new JSONArray();

                q = "SELECT id, name, custom_id  FROM bloc_templates "
                    + " WHERE site_id = " + escape.cote(siteId)
                    + " AND type = " + escape.cote(type)
                    + " ORDER BY name , id ";
                rs = Etn.execute(q);
                while(rs.next()){
                    templates.put(getJSONObject(rs));
                }

                data.put("templates", templates);

                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting sample JSON. Please try again.",ex);
            }
        }
        else if("getViewSampleJSON".equalsIgnoreCase(requestType)){
            try{
                String viewType = parseNull(request.getParameter("viewType"));
                String viewTemplateId = parseNull(request.getParameter("viewTemplateId"));

                //here view template id is custom_id of template

                String BASE_DIR = GlobalParm.getParm("BASE_DIR");
                String TEMPLATES_DIR = BASE_DIR + "/WEB-INF/templates/";

                String fileName = viewType + ".json";

                File jsonFile = new File(TEMPLATES_DIR + fileName);


                if(jsonFile.exists() && jsonFile.isFile()){
                    JSONObject sampleJson;
                    try{
                        sampleJson = new JSONObject(FilesUtil.readFile(jsonFile));
                    }
                    catch(Exception ex){
                        throw new SimpleException("Invalid JSON in sample file", ex);
                    }

                    JSONArray sectionsList = new JSONArray();
                    q = "SELECT id FROM bloc_templates "
                        + " WHERE site_id = " + escape.cote(siteId)
                        + " AND custom_id = " + escape.cote(viewTemplateId);
                    rs = Etn.execute(q);
                    if(rs.next()){
                        sectionsList = PagesUtil.getBlocTemplateSectionsData(Etn, rs.value("id"));
                    }

                    JSONObject templateCode = new JSONObject();
                    templateCode.put("sections",sectionsList);

                    data.put("view_code", sampleJson);
                    data.put("template_code", templateCode);
                    status = STATUS_SUCCESS;
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting sample JSON. Please try again.",ex);
            }
        }
        else if("getAllTagsJson".equalsIgnoreCase(requestType)){
            try{
                String folderIds = parseNull(request.getParameter("folderIds"));
                JSONArray tagsArray = getAllTagsJSON(Etn,siteId,GlobalParm.getParm("CATALOG_DB"),folderIds);
                data.put("tags", tagsArray);
                status = STATUS_SUCCESS;
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting sample JSON. Please try again.",ex);
            }
        }
    }
    catch(SimpleException ex){
        message = ex.getMessage();
        ex.print();
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
    out.write(jsonResponse.toString());
%>