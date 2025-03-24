<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.asimina.util.ActivityLog, com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%!
	void updateBlocTags(Etn Etn, String blocId, String[] tagIds) {

		String q = "DELETE FROM blocs_tags WHERE bloc_id = " + escape.cote(blocId);
        Etn.executeCmd(q);

        String qPrefix = "INSERT INTO blocs_tags (bloc_id, tag_id) "
                    + " VALUES (" + escape.cote(blocId) + " , ";
        for(String tagId : tagIds) {
            if(tagId.trim().length() > 0 ) {
                q = qPrefix + escape.cote(tagId) + " )";
                Etn.executeCmd(q);
            }
        }
	}

    void processChildBlocsJson(Etn Etn,String childBlocs, String blocId) {
        JSONArray childBlocsJson = null;
        try{
            childBlocsJson = new JSONArray(childBlocs);
            String q = "DELETE FROM bloc_tree WHERE parent_bloc_id = " + escape.cote(blocId);
            Etn.executeCmd(q);
            for(int i=0; i < childBlocsJson.length() ; i++) {
                JSONObject childbloc = childBlocsJson.getJSONObject(i);
                insertChildBlocs(Etn,blocId,childbloc.getString("langue_id"),childbloc.getString("bloc_id"));
            }
        } catch (JSONException e) {
            System.out.println("--------- INVALID JSON ---------");
            System.out.println("--------- "+childBlocs+" ---------");
        }
    }

    int insertChildBlocs(Etn Etn, String blocId, String langueId ,String childBlocId) {
        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();
        colValueHM.put("parent_bloc_id", blocId);
        colValueHM.put("bloc_id", childBlocId);
        colValueHM.put("langue_id", langueId);
        
        String q = getInsertQuery("bloc_tree",colValueHM);
        return Etn.executeCmd(q);
    }
%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();

    String q  ;
    Set rs  ;
    int count = 0;

    String requestType = parseNull(request.getParameter("requestType"));

	try{
		String siteId = getSiteId(session);
	    if("getBlocsList".equalsIgnoreCase(requestType)){
	    	try{

                String screenType = parseNull(request.getParameter("screenType"));
				boolean isMenus = Constant.SCREEN_TYPE_MENUS.equals(screenType);

				JSONArray blocsList = new JSONArray();
				JSONObject curBloc;

				q = " SELECT b.id, b.name, b.updated_ts, bt.name as template, IFNULL(uses.nb_use,0) as nb_use, l.name updated_by "
	                + " FROM blocs b"
                    + " LEFT JOIN login l on l.pid = b.updated_by "
	                + " JOIN bloc_templates bt ON bt.id = b.template_id"
	                + " LEFT JOIN ("
	                + "   SELECT b_uses.bloc_id, COUNT(b_uses.rel_id) AS nb_use  "
	                + "   FROM ( "
                    + "     SELECT DISTINCT pb.bloc_id,  pb.page_id as rel_id, 'pages' as type"
                    + "     FROM parent_pages_blocs pb "
                    + "     JOIN freemarker_pages p ON p.id = pb.page_id "
                    + "     WHERE p.site_id = " + escape.cote(siteId)
                    + "     AND  p.is_deleted = '0'"

                    + "     UNION "
                    + "     SELECT DISTINCT ptb.bloc_id,  pti.page_template_id as rel_id, 'page_templates' as type "
                    + "     FROM page_templates_items_blocs ptb "
                    + "     JOIN page_templates_items pti ON pti.id = ptb.item_id"
                    + "     JOIN page_templates pt ON pt.id = pti.page_template_id"
                    + "     WHERE pt.site_id = " + escape.cote(siteId) + " AND ptb.type = 'bloc' "
                    + "     UNION "
                    + "     SELECT DISTINCT mjd.header_bloc_id as bloc_id,  mj.id as rel_id, 'menu_js' as type "
                    + "     FROM menu_js_details mjd "
                    + "     JOIN menu_js mj ON mj.id = mjd.menu_js_id"
                    + "     WHERE mj.site_id = " + escape.cote(siteId) + " AND mjd.header_bloc_type = 'bloc' "
                    + "     UNION "
                    + "     SELECT DISTINCT mjd.footer_bloc_id as bloc_id,  mj.id as rel_id, 'menu_js' as type "
                    + "     FROM menu_js_details mjd "
                    + "     JOIN menu_js mj ON mj.id = mjd.menu_js_id"
                    + "     WHERE mj.site_id = " + escape.cote(siteId) + " AND mjd.footer_bloc_type = 'bloc' "
                    + "   ) b_uses "
                    + "   GROUP BY b_uses.bloc_id "
	                + " ) uses ON uses.bloc_id = b.id "
                    + " WHERE b.site_id = " + escape.cote(siteId)
                    + " AND bt.type " +(isMenus?"=":"!=") + escape.cote(Constant.SYSTEM_TEMPLATE_MENU);

                rs = Etn.execute(q);
				while(rs.next()){
					curBloc = new JSONObject();
					for(String colName : rs.ColName){
						curBloc.put(colName.toLowerCase(), rs.value(colName));
					}

					blocsList.put(curBloc);
				}

				data.put("blocs",blocsList);
				status = STATUS_SUCCESS;

	    	}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in getting blocs list. Please try again.",ex);
	    	}
	    }
	    else if("searchBlocsList".equalsIgnoreCase(requestType)){
	        try{

	            String search = parseNull(request.getParameter("search"));
		   	 	String blocType = parseNull(request.getParameter("type"));

	            JSONArray resultList = new JSONArray();
	            JSONObject curItem;
                q = "";
                if( blocType.length() == 0 || blocType.equals("bloc")){
    	            q += " SELECT b.id, b.name, bt.name as template, 'bloc' as type"
    	                + " FROM blocs b"
    	                + " JOIN bloc_templates bt ON bt.id = b.template_id "
                        + " WHERE b.site_id = " + escape.cote(siteId)
                        + " AND bt.type != " + escape.cote(Constant.SYSTEM_TEMPLATE_MENU);

    	            q += " AND b.name LIKE " + escape.cote("%"+search+"%");

                }

                if( blocType.length() == 0 || blocType.equals("system")){

                    if(q.length() > 0){
                        q += " UNION ALL ";
                    }

                    q += " SELECT b.id, CONCAT(b.name,' (',bt.type,')') AS name, bt.name as template, bt.type as type "
                        + " FROM blocs b"
    	                + " JOIN bloc_templates bt ON bt.id = b.template_id "
                        + " WHERE b.site_id = " + escape.cote(siteId)
                        + " AND bt.type = " + escape.cote(Constant.SYSTEM_TEMPLATE_MENU);

                    q += " AND b.name LIKE " + escape.cote("%"+search+"%");
                }

                q = "SELECT * FROM ( " + q + " ) AS t ORDER BY name";

                rs = Etn.execute(q);
	            while(rs.next()){
	                curItem = new JSONObject();
	                for(String colName : rs.ColName){
	                    curItem.put(colName.toLowerCase(), rs.value(colName));
	                }

	                resultList.put(curItem);
	            }

	            data.put("blocs",resultList);
                data.put("search",search);
                data.put("blocType",blocType);
	            status = STATUS_SUCCESS;

	        }//try
	        catch(Exception ex){
	        	throw new SimpleException("Error in searching blocs. Please try again.",ex);
	        }
	    }
        else if("getBlocsAndFormsList".equalsIgnoreCase(requestType)){
            try{

                String search = parseNull(request.getParameter("search"));
                String blocType = parseNull(request.getParameter("blocType"));
                String screenType = parseNull(request.getParameter("screenType"));

                boolean isMenus = Constant.SCREEN_TYPE_MENUS.equals(screenType);

                JSONArray resultList = new JSONArray();
                JSONObject curItem = null;

                String FORMS_DB = GlobalParm.getParm("FORMS_DB");

                q = " SELECT * FROM (";

                q += " SELECT b.id, b.name, bt.name as template"
                    + " FROM blocs b"
                    + " JOIN bloc_templates bt ON bt.id = b.template_id "
                    + " WHERE b.site_id = " + escape.cote(siteId)
                    + " AND bt.type " +(isMenus?"=":"!=") + escape.cote(Constant.SYSTEM_TEMPLATE_MENU);

                String whereClause = "";
                if(search.length() > 0){
                    whereClause += " AND b.name LIKE " + escape.cote("%"+search+"%");
                }
                if(blocType.length() > 0 ){
                    whereClause += " AND bt.custom_id = " +escape.cote(blocType);
                }
                q +=  whereClause;

                q += " UNION ALL "
                	+ " SELECT CONCAT('form_',form_id) AS id, process_name AS name, 'form' AS template "
                    + " FROM "+FORMS_DB+".process_forms "
                    + " WHERE site_id = " + escape.cote(siteId);

                whereClause = "";
                if(search.length() > 0){
                    whereClause += " AND process_name LIKE " + escape.cote("%"+search+"%");
                }
                if(blocType.length() > 0 ){
                    whereClause += " AND 'form' = " +escape.cote(blocType);
                }
                q +=  whereClause;

                q += " ) as t1 ORDER BY name";

                rs = Etn.execute(q);
                while(rs.next()){
                    curItem = new JSONObject();
                    for(String colName : rs.ColName){
                        curItem.put(colName.toLowerCase(), rs.value(colName));
                    }

                    resultList.put(curItem);
                }

                data.put("blocs",resultList);
                data.put("search",search);
                data.put("blocType",blocType);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in searching blocs. Please try again.",ex);
            }
        }
	    else if("getBlocUses".equalsIgnoreCase(requestType)){
	        try{
	            String blocId = parseNull(request.getParameter("blocId"));

	            JSONArray  resultList = new JSONArray();
	            JSONObject curEntry = null;

	            //nb_use as updated in list + delete condition + here

                //uses as blocs in pages
	            q = " SELECT DISTINCT p.id, p.parent_page_id, p.name, p.path , p.variant, p.langue_code, p.site_id, published_ts"
	                + " FROM pages p "
	                + " JOIN pages_blocs pb ON pb.page_id = p.id "
	                + " JOIN language l ON l.langue_code = p.langue_code "
	                + " WHERE pb.bloc_id = " + escape.cote(blocId)
	                + " AND p.site_id = " + escape.cote(siteId)
	                + " AND l.langue_id = '1'";

	            rs = Etn.execute(q);
	            while(rs.next()){
	                curEntry = new JSONObject();

                    String path = rs.value("path");
                    String variant = rs.value("variant");
                    String parent_page_id = rs.value("parent_page_id");
                    String langue_code = rs.value("langue_code");
                    String pageHtmlPath =  "/" + langue_code + "/" + variant + "/" + path;

                    curEntry.put("type","page")
                    .put("id", rs.value("id"))
                    .put("name", rs.value("name"))
                    .put("path", pageHtmlPath)
                    .put("parent_page_id", parent_page_id)
                    .put("is_published", rs.value("published_ts").length() > 0 ? "1":"0");

	                resultList.put(curEntry);
	            }

	            //uses as blocs in page_templates
	            q = " SELECT DISTINCT pt.id, pt.name"
	                + " FROM page_templates pt "
                    + " JOIN page_templates_items pti ON pt.id = pti.page_template_id"
	                + " JOIN page_templates_items_blocs ptb ON pti.id = ptb.item_id"
	                + " WHERE ptb.bloc_id = " + escape.cote(blocId)
	                + " AND pt.site_id = " + escape.cote(siteId)
	                + " AND ptb.type = 'bloc' ";

	            rs = Etn.execute(q);
	            while(rs.next()){
	                curEntry = new JSONObject();

                    curEntry.put("type","page_template")
                    .put("id", rs.value("id"))
                    .put("name", rs.value("name"));
	                resultList.put(curEntry);
	            }

	            //uses in menu_js
	            q = " SELECT DISTINCT mj.id, mj.name"
                    + " FROM menu_js mj "
                    + " JOIN menu_js_details mjd ON mj.id = mjd.menu_js_id"
	                + " WHERE mj.site_id = " + escape.cote(siteId)
	                + " AND (( mjd.header_bloc_type = 'bloc' AND mjd.header_bloc_id = " + escape.cote(blocId) +  " ) "
	                + " OR ( mjd.footer_bloc_type = 'bloc' AND mjd.footer_bloc_id = " + escape.cote(blocId) +  " ) ) ";
                rs = Etn.execute(q);
	            while(rs.next()){
	                curEntry = new JSONObject();

                    curEntry.put("type","menu_js")
                    .put("id", rs.value("id"))
                    .put("name", rs.value("name"));
	                resultList.put(curEntry);
	            }

	            data.put("uses", resultList);
	            status = STATUS_SUCCESS;

	        }//try
	        catch(Exception ex){
	            throw new SimpleException("Error in getting blocs list. Please try again.",ex);
	        }
	    }
	    else if("getBlocData".equalsIgnoreCase(requestType)){
	        try{
	            String blocId = parseNull(request.getParameter("blocId"));

	            JSONObject blocData = new JSONObject();

	            q = "SELECT b.*, bt.name AS template_name , bt.type AS template_type "
                    + " FROM blocs b "
                    + " JOIN bloc_templates bt ON b.template_id = bt.id "
	                + " WHERE b.id = " + escape.cote(blocId)
                    + " AND b.site_id = " + escape.cote(siteId);

	            rs = Etn.execute(q);
	            if(!rs.next()){
	                throw new SimpleException("Invalid parameters");
	            }

	            for(String colName : rs.ColName){
	                    blocData.put(colName.toLowerCase(), rs.value(colName));
	            }

                JSONObject templateCode = new JSONObject();
	            String templateId = rs.value("template_id");

                JSONArray sections = PagesUtil.getBlocTemplateSectionsData(Etn, templateId);
	            templateCode.put("sections",sections);

	            //blocs_details
	            JSONObject detailsObj = new JSONObject();
                blocData.put("details",detailsObj);
	            q = "SELECT l.langue_id, IFNULL(bd.template_data,'{}') AS template_data "
                    + " FROM language l "
                    + " LEFT JOIN blocs_details bd ON bd.langue_id = l.langue_id "
	                + " WHERE bd.bloc_id = " + escape.cote(blocId);
	            rs = Etn.execute(q);
	            while(rs.next()){
                    String langId = rs.value("langue_id");
	                String curTemplateData = rs.value("template_data");
                    curTemplateData = decodeJSONStringDB(curTemplateData);

                    JSONObject langDetail = new JSONObject();
                    langDetail.put("langue_id", langId)
                        .put("template_data",curTemplateData);

                    detailsObj.put(langId, langDetail);
	            }

	            JSONArray blocTags = new JSONArray();
	            blocData.put("tags",blocTags);

	            String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");
	            q = "SELECT t.id, t.label FROM blocs_tags bt "
	            	+ " JOIN "+CATALOG_DB+".tags t ON bt.tag_id = t.id "
	            	+ " WHERE t.site_id = " + escape.cote(siteId)
	            	+ " AND bt.bloc_id = " + escape.cote(blocId)
	            	+ " ORDER BY t.label";
	            rs = Etn.execute(q);
	            while(rs.next()){
	            	JSONObject tagObj = new JSONObject();
	            	tagObj.put("id",rs.value("id"));
	            	tagObj.put("label",rs.value("label"));
	            	blocTags.put(tagObj);
	            }

	            data.put("bloc_data", blocData);
	            data.put("template_code", templateCode);
	            status = STATUS_SUCCESS;

	        }//try
	        catch(Exception ex){
	            throw new SimpleException("Error in getting bloc data. Please try again.",ex);
	        }
	    }
	    else if("copyBloc".equalsIgnoreCase(requestType)){
            try{
                String blocId = parseNull(request.getParameter("blocId"));
                String name = parseNull(request.getParameter("name"));

                int newblocId = copyBlock(Etn, blocId, name, siteId);

                if (newblocId > 0) {
                    message = "Bloc copied.";
                    status = STATUS_SUCCESS;
                }
            }
            catch(Exception ex){
				throw new SimpleException("Error in copying bloc.",ex);
	    	}
	    }
        else if("deleteBlocs".equalsIgnoreCase(requestType)){
            try{
                String[] blocIds= request.getParameterValues("blocIds");
                String screenType = parseNull(request.getParameter("screenType"));

                int totalCount = blocIds.length;
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                String deletedBlocks = "";
                String deletedBlockIds = "";
                int deleteCount = 0;
                for(String blocId : blocIds){

                    q = " SELECT COUNT(0) AS nb_use "
                        + "   FROM ( "
                        + "     SELECT DISTINCT pb.bloc_id,  pb.page_id as rel_id, 'pages' as type"
                        + "     FROM parent_pages_blocs pb "
                        + "     JOIN freemarker_pages p ON p.id = pb.page_id "
                        + "     WHERE p.site_id = " + escape.cote(siteId)
                        + "     AND  p.is_deleted = '0'"
                        + "     AND pb.bloc_id = " + escape.cote(blocId)
                        + "     UNION "
                        + "     SELECT DISTINCT ptb.bloc_id,  pti.page_template_id as rel_id, 'page_template' as type "
                        + "     FROM page_templates_items_blocs ptb "
                        + "     JOIN page_templates_items pti ON pti.id = ptb.item_id"
                        + "     JOIN page_templates pt ON pt.id = pti.page_template_id"
                        + "     WHERE pt.site_id = " + escape.cote(siteId) + " AND ptb.type = 'bloc' "
                        + "     AND ptb.bloc_id = " + escape.cote(blocId)
                        + "     UNION "
                        + "     SELECT DISTINCT mjd.header_bloc_id as bloc_id,  mj.id as rel_id, 'menu_js' as type "
                        + "     FROM menu_js_details mjd "
                        + "     JOIN menu_js mj ON mj.id = mjd.menu_js_id"
                        + "     WHERE mj.site_id = " + escape.cote(siteId) + " AND mjd.header_bloc_type = 'bloc' "
                        + "     AND mjd.header_bloc_id = " + escape.cote(blocId)
                        + "     UNION "
                        + "     SELECT DISTINCT mjd.footer_bloc_id as bloc_id,  mj.id as rel_id, 'menu_js' as type "
                        + "     FROM menu_js_details mjd "
                        + "     JOIN menu_js mj ON mj.id = mjd.menu_js_id"
                        + "     WHERE mj.site_id = " + escape.cote(siteId) + " AND mjd.footer_bloc_type = 'bloc' "
                        + "     AND mjd.footer_bloc_id = " + escape.cote(blocId)
                        + "   ) b_uses "
                        + "   WHERE bloc_id = " + escape.cote(blocId);

                    rs = Etn.execute(q);
                    if(!rs.next() || parseInt(rs.value("nb_use"),-1) != 0){
                        //skip if in use
                        continue;
                    }

                    q = "SELECT name FROM blocs WHERE id = " + escape.cote(blocId)+" AND site_id = "+escape.cote(siteId);
                    Set rsName = Etn.execute(q);
                    rsName.next();
                    String curName = parseNull(rsName.value(0));

                    q = "DELETE FROM blocs_tags WHERE bloc_id = " + escape.cote(blocId);
                    Etn.executeCmd(q);

                    q = "DELETE FROM blocs_details WHERE bloc_id = " + escape.cote(blocId);
                    Etn.executeCmd(q);

                    q = "DELETE FROM blocs WHERE id = " + escape.cote(blocId);
                    Etn.executeCmd(q);

                    deleteCount += 1;
                    deletedBlocks += curName + ", ";
                    deletedBlockIds += blocId + ", ";
                }

                if(totalCount == 1){
                    if(deleteCount != 1){
                        throw new SimpleException("Cannot delete, "+ screenType +" is used.");
                    }
                    else{
                        status = STATUS_SUCCESS;
                        message = screenType+ " deleted";
                    }
                }
                else{
                    status = STATUS_SUCCESS;
                    message = deleteCount + " of " + totalCount + " " + screenType + "s deleted";
                    if(deleteCount < totalCount){
                        message += ". "+screenType+"s in use not deleted.";
                    }
                }
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"DELETED",deletedBlockIds,screenType+"s",deletedBlocks,siteId);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting blocs.",ex);
            }
        }
	    else if("saveBloc".equalsIgnoreCase(requestType)){
	    	try{

		   	 	String blocId = parseNull(request.getParameter("blocId"));

                String name = parseNull(request.getParameter("name"));
		   	 	String template_id = parseNull(request.getParameter("template_id"));
		   	 	String refresh_interval = parseNull(request.getParameter("refresh_interval"));
		   	 	String start_date = parseNull(request.getParameter("start_date"));
		   	 	String end_date = parseNull(request.getParameter("end_date"));
		   	 	String visible_to = parseNull(request.getParameter("visible_to"));
		   	 	String margin_top = parseNull(request.getParameter("margin_top"));
		   	 	String margin_bottom = parseNull(request.getParameter("margin_bottom"));
		   	 	String description = parseNull(request.getParameter("description"));
		   	 	String detailsJson = parseNull(request.getParameter("detailsJson"));
                String rss_feed_ids = parseNull(request.getParameter("rss_feed_ids"));
                String rss_feed_sort = parseNull(request.getParameter("rss_feed_sort"));
                String uniqueIds = parseNull(request.getParameter("uniqueIds"));
                String triggerEvents = parseNull(request.getParameter("triggerEvents"));

                String childBlocs = parseNull(request.getParameter("childBlocs"));
                String[] blocTags = parseNull(request.getParameter("blocTags")).split(",");
                JSONObject detailsObj = new JSONObject(detailsJson);

                //check duplicate name
                q = "SELECT id FROM blocs WHERE name = " + escape.cote(name)
                    + " AND site_id = " + escape.cote(siteId);
                if(blocId.length() > 0){
                    q += " AND id != " + escape.cote(""+blocId);
                }

                rs = Etn.execute(q);
                if(rs.next()){
                    throw new SimpleException("Error: Bloc name already exists. Please change name.");
                }

		   	 	int pid = Etn.getId();

                colValueHM.put("name", escape.cote(name));
				colValueHM.put("template_id", escape.cote(template_id));
				colValueHM.put("refresh_interval", escape.cote(refresh_interval));
				colValueHM.put("start_date", escape.cote(start_date));
				colValueHM.put("end_date", escape.cote(end_date));
				colValueHM.put("visible_to", escape.cote(visible_to));
				colValueHM.put("margin_top", escape.cote(margin_top));
				colValueHM.put("margin_bottom", escape.cote(margin_bottom));
				colValueHM.put("description", escape.cote(description));
                colValueHM.put("rss_feed_ids", escape.cote(rss_feed_ids));
                colValueHM.put("rss_feed_sort", escape.cote(rss_feed_sort));
                colValueHM.put("triggers", escape.cote(triggerEvents));

                if(uniqueIds.length()>0){
                    colValueHM.put("unique_id", escape.cote(uniqueIds));
                }

				colValueHM.put("updated_ts", "NOW()");
		   	 	colValueHM.put("updated_by", escape.cote(""+pid));

		   	 	boolean isUpdate = false;
		   	 	if(blocId.length() == 0){
		   	 		//new bloc
					colValueHM.put("created_ts", "NOW()");
					colValueHM.put("created_by", escape.cote(""+pid));
                    colValueHM.put("site_id", escape.cote(siteId));
                    colValueHM.put("uuid",escape.cote( getUUID() ));

					q = getInsertQuery("blocs",colValueHM);

					int newBlocId = Etn.executeCmd(q);

					if(newBlocId <= 0){
						message = "Error in creating bloc. Please try again.";
					}
					else{
                        blocId = ""+newBlocId;

						status = STATUS_SUCCESS;
						message = "Bloc created.";
						data.put("blocId", newBlocId);
                        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),""+newBlocId,"CREATED","Block",name,siteId);
					}
		   	 	}
		   	 	else{
		   	 		//existing bloc update
		   	 		isUpdate = true;
					q = getUpdateQuery("blocs", colValueHM, " WHERE id = " + escape.cote(""+blocId) );
					count = Etn.executeCmd(q);

					if(count <= 0){
						message = "Error in updating bloc. Please try again.";
					}
					else{
						status = STATUS_SUCCESS;
						message = "Bloc updated.";
						data.put("blocId", blocId);
                        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),""+blocId,"UPDATED","Block",name,siteId);
					}
		   	 	}

		   	 	if(status == STATUS_SUCCESS){
		   	 	    //set bloc details (language based)
		   	 	    updateBlocTags(Etn, blocId, blocTags);
                    processChildBlocsJson(Etn, childBlocs, blocId);                    
		   	 	    //save multi language template data
                    List<Language> languages = getLangs(Etn,session);
                    for(Language curLang : languages){
                        JSONObject langDetailObj = Optional.of(detailsObj.optJSONObject(curLang.getLanguageId())).orElseGet(JSONObject::new);
                        System.out.println("language :: "+curLang.getLanguageId());
                        JSONObject langTemplateData = Optional.of(langDetailObj.optJSONObject("template_data")).orElseGet(JSONObject::new);
                        q = "INSERT INTO blocs_details(bloc_id, langue_id, template_data) VALUES ("
                            + escape.cote(blocId) + "," + escape.cote(curLang.getLanguageId())  + ","
                            + escapeCote(langTemplateData.toString()) + ") ON DUPLICATE KEY UPDATE template_data=VALUES(template_data)";
                        Etn.executeCmd(q);
                    }

		   	 	    if(isUpdate){
		   	 	        markPagesToGenerate(blocId, "blocs",Etn);
                        Set rsBloc = Etn.execute("select * from bloc_tree where bloc_id="+escape.cote(""+blocId));
                        while(rsBloc.next()) {
                            if(! (parseNull(rsBloc.value("parent_bloc_id")).equals("0") || parseNull(rsBloc.value("parent_bloc_id")).length() == 0)){
                                System.out.println("updating parent_bloc_id :: "+parseNull(rsBloc.value("parent_bloc_id")));
                                Etn.executeCmd("update blocs set updated_ts=now(), updated_by="+escape.cote(""+pid)+" where id="+escape.cote(""+parseNull(rsBloc.value("parent_bloc_id"))));
                                markPagesToGenerate(parseNull(rsBloc.value("parent_bloc_id")), "blocs",Etn);
                            }
                        }
		   	 	    }
		   	 	}

			}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in deleting bloc.",ex);
	    	}
	    }
        else if("viewsFilterSeach".equalsIgnoreCase(requestType)){
	    	try{
                String filterCol = parseNull(request.getParameter("filterCol"));
                String viewType = parseNull(request.getParameter("viewType")).replace("view_" , "");
                String searchQuery = parseNull(request.getParameter("searchQuery"));
                String templateVal = parseNull(request.getParameter("templateVal"));

                q = "";
                JSONArray  searchResults  = new JSONArray();
	            String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");

                if(viewType.length()>0){
                    if(filterCol.equals("f.name")){
                        String tableName =  "";
                        switch(viewType){
                            case "structured_pages":
                                tableName = "pages_folders";
                            break;
                            case "structured_contents":
                                tableName = "structured_contents_folders";
                                break;
                            case "commercial_products":
                                tableName = CATALOG_DB+".products_folders";
                                break;
                            case "commercial_catalogs": // as catalog is iteself is a folder
                                q = "SELECT c.name FROM "+CATALOG_DB+".catalogs c"
                                + " WHERE  c.name LIKE "+escape.cote('%'+searchQuery+"%")
                                + " AND c.site_id = "+escape.cote(siteId)
                                + " ORDER BY c.name ASC";
                                break;
                        }
                        if(tableName.length()>0){    // else it will be catalog query
                            q = "SELECT name from "+tableName+" WHERE site_id = "+escape.cote(siteId)+" ORDER BY name ASC";
                        }
                    } else if(filterCol.equals("p.name") || filterCol.equals("p.lang_1_name")){
                        switch(viewType){
                            case "structured_pages":
                            case "structured_contents":
                                q = "SELECT p.name FROM structured_contents p";
                                if(templateVal.length() > 0){
                                    q += " JOIN bloc_templates bt ON bt.id = p.template_id"
                                    + " AND bt.custom_id = "+escape.cote(templateVal);
                                }
                                q += " WHERE  p.name LIKE "+escape.cote('%'+searchQuery+"%")
                                  + " AND p.site_id = "+escape.cote(siteId)+" ORDER BY p.name ASC";
                                break;
                            case "commercial_products":
                                q = "SELECT pr.lang_1_name as name FROM  "+CATALOG_DB+".products pr"
                                + " JOIN "+CATALOG_DB+".catalogs c ON c.id = pr.catalog_id "
                                + " WHERE  pr.lang_1_name LIKE "+escape.cote('%'+searchQuery+"%")
                                + " AND c.site_id = "+escape.cote(siteId)+" ORDER BY pr.lang_1_name ASC";
                                break;
                        }
                    }
                }

                if(q.length() > 0){
                    rs = Etn.execute(q);
                    while(rs.next()){
                        searchResults.put(rs.value("name"));
                    }
                }

                data.put("searchResults", searchResults);
                status = STATUS_SUCCESS;

			}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in filtering views.",ex);
	    	}
	    }
	    else if("getSelectData".equalsIgnoreCase(requestType)){
	    	try{
                String params = parseNull(request.getParameter("params"));
                String site_id = parseNull(request.getParameter("site_id"));
                JSONObject jObj = new JSONObject(params);
                
                if(params.length()>0){
                    ArrayList<String> list  = new ArrayList<String>(jObj.keySet());
                    String key = list.get(0);
                    if(key.length()>0){
                        String qry = "";
                        if(key.equalsIgnoreCase("Free"))
                            qry = jObj.getString(key);
                        else{
                            if(key.equalsIgnoreCase("catalogs")) qry = "SELECT "+jObj.getString(key)+" FROM "+GlobalParm.getParm("CATALOG_DB")+"."+key+" WHERE site_id="+escape.cote(site_id);
                            else qry = "SELECT "+jObj.getString(key)+" FROM "+key+" WHERE site_id="+escape.cote(site_id);
                        }
                        
                        Set rsData = Etn.execute(qry);
                        if(rsData.rs.Rows>0){
                            JSONArray rspAry = new JSONArray();
                            while(rsData.next()){
                                JSONArray dataAry = new JSONArray();
                                dataAry.put(rsData.value(0));
                                dataAry.put(rsData.value(1));
                                rspAry.put(dataAry);
                            }
                            data.put("resp", rspAry);
                            status = STATUS_SUCCESS;
                        }else{
                            status = STATUS_ERROR;
                            message ="No data";
                        }
                    }else{
                        status = STATUS_ERROR;
                        message ="Query type is invalid";
                    }
                }else{
                    status = STATUS_ERROR;
                    message ="No query";
                }
			}//try
	    	catch(JSONException ex){
				throw new SimpleException("Invalid query ",ex);
	    	}
            catch(Exception ex){
				throw new SimpleException("Something went wrong ",ex);
	    	}
	    }
	    else if("fetchPageLogs".equals(requestType)){
	    	try{
                String pageId = parseNull(request.getParameter("id"));
                String pageType = parseNull(request.getParameter("pageType"));

                if(pageId.length()>0){
                    if(pageType.equals("structured") || pageType.equals("freemarker")){
                        String tblName = "freemarker_pages";
                        if(pageType.equals("structured")) tblName = "structured_contents";

                        Set rsLogs= Etn.execute("select publish_log from "+tblName+" where id="+escape.cote(pageId));
                        if(rsLogs.next()) {
                            message = parseNull(rsLogs.value("publish_log"));
                            if(message.isEmpty()) message = "No Error logs found.";
                            status=STATUS_SUCCESS;
                        }
                    }else{
                        status = STATUS_ERROR;
                        message ="Invalid page type";
                    }
                }else{
                    status = STATUS_ERROR;
                    message ="No id received";
                }
			}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in testing.",ex);
	    	}
	    } else if("checkUniqueId".equalsIgnoreCase(requestType)){
	    	try{
                String uniqueId = parseNull(request.getParameter("id"));
                String templateId = parseNull(request.getParameter("templateId"));
                String blocId = parseNull(request.getParameter("blocId"));
                String pageType = parseNull(request.getParameter("pageType"));

                String tblName = "blocs";
                if(pageType.equalsIgnoreCase("struct")){
                    tblName = "structured_contents";
                }

                if(uniqueId.length()>0){
                    String query = "select * from "+tblName+" where unique_id = "+escape.cote(uniqueId)+" and site_id="+escape.cote(siteId)+
                        " and template_id="+escape.cote(templateId);
                    
                    if(blocId.length() > 0){
                        query += " and id !="+escape.cote(blocId);
                    }

                    Set rsData = Etn.execute(query);
                    if(rsData.rs.Rows>0){
                        status = STATUS_ERROR;
                        message ="Not unique";
                    }else{
                        status = STATUS_SUCCESS;
                    }
                }else{
                    status = STATUS_ERROR;
                    message ="No id received";
                }
			}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in testing.",ex);
	    	}
	    }
	    else if("test".equalsIgnoreCase(requestType)){
	    	try{

			}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in testing.",ex);
	    	}
	    }
        else{
            message = "Invalid params";
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
