<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set,java.time.LocalDateTime,java.time.format.DateTimeFormatter, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, java.util.ArrayList,java.util.List, com.etn.asimina.util.ActivityLog"%>
<%@ page import="com.etn.pages.PagesUtil, com.etn.pages.PagesGenerator"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/fileMethods.jsp"%>
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
    String getGridPagePath(String PAGES_PUBLISH_FOLDER, String siteId, String langCode, String variant,  String path ){
        return PAGES_PUBLISH_FOLDER + PagesUtil.getDynamicPagePath(siteId, langCode , variant , path);
    }

    String getGridPageUrl(String PAGES_PUBLISH_FOLDER, String siteId, String langCode, String variant,  String path ){
        return getGridPagePath(PAGES_PUBLISH_FOLDER, siteId, langCode, variant, path) + "index.html";
    }

    JSONObject movePage(Contexte Etn, String id, String type, String moveToFolderId, String siteId){
        boolean status = true;
        String message = "Error in moving page";
        String q = "";
        Set rs = null;
        String tableName = "freemarker_pages";
        ArrayList<String> pageIds = new ArrayList<>();

        if(type.equals(Constant.PAGE_TYPE_STRUCTURED)){
            tableName = "structured_contents";
        }
        // duplicate name check
        q = "SELECT id FROM "+tableName
              +" WHERE folder_id = "+escape.cote(moveToFolderId)
              +" AND site_id = "+escape.cote(siteId);
              if(tableName.equals("freemarker_pages")){
                  q += " AND  is_deleted = '0'";
              }
              q += " AND name = ( SELECT name  FROM "+tableName+" WHERE id = "+escape.cote(id)+" )";
        rs =  Etn.execute(q);
        if(rs.next()){
            status = false;
            message = "Page with this name already exists";
        } else{
            //path duplicate check
            if(type.equals(Constant.PAGE_TYPE_STRUCTURED)){ // structure
                q = "SELECT page_id FROM structured_contents_details WHERE content_id = "+escape.cote(id);
                rs = Etn.execute(q);
                while (rs.next()){
                    String pageId = rs.value("page_id");
                    if(parseInt(pageId)>0){
                        pageIds.add(pageId);
                    }
                }
            }else{ // bloc
                q = "SELECT id as page_id FROM pages WHERE parent_page_id = "+escape.cote(id) +" AND type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER);
                rs = Etn.execute(q);
                while (rs.next()){
                    String pageId = rs.value("page_id");
                    if(parseInt(pageId)>0){
                        pageIds.add(pageId);
                    }
                }
            }

            for(String pageId : pageIds){
                q = "SELECT * FROM pages WHERE id = "+escape.cote(pageId);
                rs =  Etn.execute(q);
                if(!rs.next()){
                    status = false;
                    message = "Invalid page Id";
                    break;
                }
                else{
                    q = "SELECT id, name FROM pages"
                          +" WHERE folder_id = "+escape.cote(moveToFolderId)
                          +" AND site_id = "+escape.cote(siteId)
                          +" AND path = "+escape.cote(rs.value("path"))
                          +" AND variant = "+escape.cote(rs.value("variant"))
                          +" AND langue_code = "+escape.cote(rs.value("langue_code"));
                    rs =  Etn.execute(q);

                    if(rs.next()){  //duplicate name or path
                        status = false;
                        message = "Path conflict with page "+rs.value("name");
                        break;
                    }
                }
            }

            if(status){
                q = "UPDATE "+tableName+" SET folder_id = "+escape.cote(moveToFolderId)
                      +", updated_by = "+escape.cote(""+Etn.getId())
                      +", updated_ts = NOW()"
                      +", to_generate = 1, to_generate_by = "+escape.cote("" + Etn.getId())
                      +" WHERE id = "+escape.cote(id)+" AND site_id = "+escape.cote(siteId);
                int res =  Etn.executeCmd(q);
                if(res == 0){
                    status = false;
                }

                for(String pageId : pageIds){
                    q = "UPDATE pages SET folder_id = "+escape.cote(moveToFolderId)
                        + " WHERE id = "+escape.cote(pageId);
                    Etn.executeCmd(q);
                }
            }
        }
        JSONObject retObject = new JSONObject();
        retObject.put("status", status);
        retObject.put("message", message);
        return retObject;
    }

    JSONObject moveFolder(Contexte Etn, String id, String moveToFolderId, int moveToFolderLevel, String folderType, String siteId){
         boolean status = false;
         String message = "Cannot move this folder";
         String q = "";
         String folderTable = getFolderTableName(folderType);
         // move folder
         if(!id.equals(moveToFolderId)){

             if(moveToFolderLevel < 4){
                 q = "SELECT id FROM "+folderTable+" WHERE parent_folder_id = "+escape.cote(id)+" AND site_id = "+escape.cote(siteId);
                 Set rs = Etn.execute(q);

                 if(!rs.next()){ // if folder has child folders then it will not be moved

                     // duplicate folder name check
                     q = "SELECT id FROM "+folderTable
                     +" WHERE parent_folder_id = "+escape.cote(moveToFolderId)
                     +" AND site_id = "+escape.cote(siteId)
                     +" AND name = ( SELECT name from "+folderTable+" WHERE id = "+escape.cote(id)+" )";

                     rs = Etn.execute(q);
                    if(rs.next()){
                        message = "Folder with this name already exsits";
                    } else {
                         q = "UPDATE "+folderTable
                         + " SET parent_folder_id = "+escape.cote(moveToFolderId)+", folder_level = "+escape.cote(moveToFolderLevel+1+"")
                         + " WHERE id = "+escape.cote(id)+" AND site_id = "+escape.cote(siteId);
                         int res =  Etn.executeCmd(q);
                         if(res > 0){
                            status = true;
                            markPagesToGenerate(id, folderType, Etn);
                        }
                    }
                 }
                 else {
                     message = "Folder has child folders, it cannot be moved";
                 }
             }
             else {
                 message = "Folders not allowed at this folder level";
             }
         }
         JSONObject retObject = new JSONObject();
         retObject.put("status", status);
         retObject.put("message", message);
         return retObject;
    }

    void insertChildBlocs(Etn Etn, String parentBlocId, String pageId, String langId) {
        if(parseNull(parentBlocId).length() == 0) return;

        LinkedHashMap<String, String> mapHM = new LinkedHashMap<String, String>();
        mapHM.put("lang_page_id", escape.cote(pageId));
        mapHM.put("bloc_id", escape.cote(parentBlocId));

        String q = getInsertQuery("structure_mappings",mapHM);
        System.out.println("--------------- STRUCTURED MAPPING ----------------");
        System.out.println(q);
        Etn.executeCmd(q);
        Set rs = Etn.execute("SELECT * FROM bloc_tree where langue_id=" + escape.cote(langId) + " and parent_bloc_id ="+ escape.cote(parentBlocId));
        while(rs.next()) {
            insertChildBlocs(Etn,rs.value("bloc_id"),pageId,langId);
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

	String siteId = getSiteId(session);

    try{

        String requestType = parseNull(request.getParameter("requestType"));
        if("getPagesList".equalsIgnoreCase(requestType)){
            try{

				//ADDED by umair : to show partoo status
				boolean partooEnabled = false;
				Set rsM = Etn.execute("select * from "+GlobalParm.getParm("PORTAL_DB")+".sites where id = "+escape.cote(siteId));
				if(rsM.next())
				{
					partooEnabled = "1".equals(rsM.value("partoo_activated"));
				}

                JSONArray pagesList = new JSONArray();
                JSONObject curPage = null;
                List<Language> langsList = getLangs(Etn,siteId);

                String folderUuid = parseNull(request.getParameter("folderId"));
                String folderType = parseNull(request.getParameter("folderType"));
                String folderTable =  getFolderTableName(folderType);
                String searchText = parseNull(request.getParameter("searchText"));
                if(searchText.length()>1) folderUuid ="";

                String folderId = "0";
                if(folderUuid.length()>0){
                    q = "SELECT id FROM "+folderTable+" WHERE uuid = " + escape.cote(folderUuid)
                        + " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);
                    if( rs.next() ){
                        folderId = rs.value("id");
                    }
                    else {
                        folderId = "-1";//invalid folder id provided
                    }
                }
                // block pages
                q = "";
                if(!folderType.equals(Constant.FOLDER_TYPE_STORE)){
                    q = " SELECT bp.id, bp.name, bp.uuid, '"+Constant.PAGE_TYPE_FREEMARKER+"' AS row_type, 'blocks' AS page_type, -1 AS nb_items, p.path, p.variant "
                    + " , p.langue_code, p.html_file_path, p.published_html_file_path "
                    + " , bp.updated_ts, l2.name AS updated_by "
                    + " , IF(ISNULL( bp.published_ts ),'',CONCAT(bp.published_ts, ' by ',l1.name)) AS published_ts "
                    + " , IF(bp.to_publish=1, CONCAT('Publish on ',DATE_ADD(bp.to_publish_ts , INTERVAL 5 MINUTE)), "
                    + "       IF(bp.to_unpublish=1,CONCAT('Un-publish on ',DATE_ADD(bp.to_unpublish_ts , INTERVAL 5 MINUTE)) ,'')) AS to_publish_ts "
                    + " , IF(ISNULL(bp.published_ts), 'unpublished' , IF(bp.updated_ts > bp.published_ts, 'changed' , 'published')) AS publish_status, '' as partoo_json, '' as partoo_error, '' as template_id  "
                    + " FROM freemarker_pages bp "
                    + " LEFT JOIN pages p ON p.parent_page_id = bp.id AND p.langue_code = "+escape.cote(langsList.get(0).getCode())
                    + " LEFT JOIN login l1 on l1.pid = bp.published_by "
                    + " LEFT JOIN login l2 on l2.pid = bp.updated_by "
                    + " LEFT JOIN login l3 on l3.pid = bp.to_publish_by "
                    + " LEFT JOIN login l4 on l4.pid = bp.to_unpublish_by "
                    + " WHERE bp.site_id = " + escape.cote(siteId)
                    + " AND  bp.is_deleted = '0'"
                    + " AND p.type = " + escape.cote(Constant.PAGE_TYPE_FREEMARKER);
                    
                    if(searchText.length()>1)
                        q+= " AND (bp.name like "+escape.cote("%"+searchText+"%")+" or 'blocks' like "+escape.cote("%"+searchText+"%")+" or p.variant like "+escape.cote("%"+searchText+"%")+" or bp.updated_ts like "+escape.cote("%"+searchText+"%")+")";
                    else
                        q+= " AND bp.folder_id = " + escape.cote(folderId);
                    q+= " UNION ALL ";

                }
                // structured pages
                q+=  " SELECT p.id, p.name, p.uuid, 'structured' AS row_type, bt.name AS page_type, -1 AS nb_items, scp.path, scp.variant AS variant "
                    + " , scp.langue_code, scp.html_file_path, scp.published_html_file_path "
                    + ", p.updated_ts, l1.name updated_by "
                    + ", IF(ISNULL( p.published_ts ),'',CONCAT(p.published_ts, ' by ',l2.name)) As published_ts "
                    + " , IF(p.to_publish=1, CONCAT('Publish on ',DATE_ADD(p.to_publish_ts , INTERVAL 5 MINUTE)), "
                    + "       IF(p.to_unpublish=1,CONCAT('Un-publish on ',DATE_ADD(p.to_unpublish_ts , INTERVAL 5 MINUTE)) ,'')) AS to_publish_ts "
                    + " , IF(ISNULL(p.published_ts), 'unpublished' , IF(p.updated_ts > p.published_ts, 'changed' , 'published')) as publish_status  ";

				if(folderType.equals(Constant.FOLDER_TYPE_STORE)){
					q += ", prc.partoo_json, prc.partoo_error ";
				}else{
					q += ", '' as partoo_json, '' as partoo_error ";
				}

				q += ", p.template_id ";
				q += " FROM structured_contents p "
                    + " JOIN bloc_templates bt ON bt.id = p.template_id "
                    + " LEFT JOIN structured_contents_details scd ON scd.content_id = p.id AND scd.langue_id = "+escape.cote(langsList.get(0).getLanguageId()+"")
                    + " LEFT JOIN pages scp ON scp.id = scd.page_id "
                    + " LEFT JOIN login l1 on l1.pid = p.updated_by "
                    + " LEFT JOIN login l2 on l2.pid = p.published_by "
                    + " LEFT JOIN login l3 on l3.pid = p.to_publish_by "
                    + " LEFT JOIN login l4 on l4.pid = p.to_unpublish_by ";

				if(folderType.equals(Constant.FOLDER_TYPE_STORE)){
					q += " left join partoo_contents prc on prc.site_id = p.site_id and prc.cid = p.id and prc.ctype = 'store' ";
				}

				q += " WHERE p.site_id = " + escape.cote(siteId)
                    + " AND  p.is_deleted = '0'"
                    + " AND p.type = 'page' ";
                if(searchText.length()>1)
                    q+= " AND (p.name like "+escape.cote("%"+searchText+"%")+" or bt.name like "+escape.cote("%"+searchText+"%")+" or scp.variant like "+escape.cote("%"+searchText+"%")+" or p.updated_ts like "+escape.cote("%"+searchText+"%")+")";
                else
                    q+= " AND p.folder_id = " + escape.cote(folderId);

				if(folderType.equals(Constant.FOLDER_TYPE_STORE)){
					q += " AND bt.type = "+escape.cote(Constant.TEMPLATE_STORE);
				}else{
					q += " AND bt.type = "+escape.cote(Constant.TEMPLATE_STRUCTURED_PAGE);
				}

                // folders
                q += " UNION ALL "
                    +" SELECT f.id, f.name, f.uuid, 'folder' AS row_type,'' AS page_type, IFNULL(tbcount.tcount,0) AS nb_items, '' AS path, '' AS variant"
                    + " , '' AS langue_code, '' AS html_file_path, '' AS published_html_file_path,  f.updated_ts,l.name updated_by,'' AS published_ts, '' AS  to_publish_ts"
                    +"  , 'published' AS publish_status";

				if(folderType.equals(Constant.FOLDER_TYPE_STORE)){
					q += ", prc.partoo_json, prc.partoo_error ";
				}else{
					q += ", '' as partoo_json, '' as partoo_error ";
				}
				
				q += ", '' as template_id ";

                q += " FROM "+folderTable+" f"
                    + " LEFT JOIN ("
                    + "     SELECT folder_id, SUM(count)AS tcount"
                    + "     FROM (";
                    if(folderType.equals(Constant.FOLDER_TYPE_PAGES)){
                      q+= "          SELECT folder_id, count(id) AS count"
                        + "          FROM freemarker_pages"
                        + "          WHERE folder_id > 0"
                        + "          AND  is_deleted = '0'"
                        + "          GROUP BY folder_id"
                        + "        UNION ALL";
                    }
                q  += "            SELECT folder_id, count(id)  AS count"
                    + "            FROM structured_contents "
                    + "            WHERE folder_id > 0 && type = 'page' "
                    + "            GROUP BY folder_id"
                    + "        UNION ALL"
                    + "            SELECT parent_folder_id AS folder_id, count(id)"
                    + "            FROM "+folderTable+" pf"
                    + "            WHERE parent_folder_id > 0"
                    + "            GROUP BY parent_folder_id"
                    + "          ) tcount"
                    + "     GROUP BY folder_id"
                    + "   ) tbcount ON tbcount.folder_id = id"
                    + " LEFT JOIN login l on l.pid = f.updated_by ";

				if(folderType.equals(Constant.FOLDER_TYPE_STORE)){
					q += " left join partoo_contents prc on prc.site_id = f.site_id and prc.cid = f.id and prc.ctype = 'folder' ";
				}

                q += " WHERE f.site_id = "+escape.cote(siteId)
                    + " AND  f.is_deleted = '0' AND f.folder_version='V1'";
                    
                if(searchText.length()>1)
                    q+= " AND (f.name like "+escape.cote("%"+searchText+"%")+" or 'folder' like "+escape.cote("%"+searchText+"%")+" or IFNULL(tbcount.tcount,0) like "+escape.cote("%"+searchText+"%")+" or f.updated_ts like "+escape.cote("%"+searchText+"%")+")";
                else
                    q+= " AND f.parent_folder_id = " + escape.cote(folderId);
                rs = Etn.execute(q);

                String PAGES_PUBLISH_FOLDER = GlobalParm.getParm("PAGES_PUBLISH_FOLDER");

                while(rs.next()){
                    curPage = new JSONObject();
                    for(String colName : rs.ColName){
                        curPage.put(colName.toLowerCase(), rs.value(colName));
                    }

                    String pubHtmlFilePath =  parseNull(rs.value("published_html_file_path"));

                    if(pubHtmlFilePath.length() > 0){
                        pubHtmlFilePath = PAGES_PUBLISH_FOLDER + pubHtmlFilePath;
                    }

                    curPage.put("html_url", pubHtmlFilePath);

                    pagesList.put(curPage);
                }

                data.put("pages",pagesList);

                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting pages list. Please try again.",ex);
            }
        }
        else if("getPagesListDynamic".equalsIgnoreCase(requestType)){
            try{

                JSONArray pagesList = new JSONArray();
                JSONObject curPage = null;

                q = " SELECT p.*, l.name updatedby ,l1.name publishedby "
                    + " FROM pages p"
                    + " LEFT JOIN login l on l.pid = p.updated_by "
                    + " LEFT JOIN login l1 on l1.pid = p.published_by "
                    + " WHERE site_id = " + escape.cote(siteId)
                    + " AND type = " + escape.cote(Constant.PAGE_TYPE_REACT);
                rs = Etn.execute(q);

                String PAGES_PUBLISH_FOLDER = GlobalParm.getParm("PAGES_PUBLISH_FOLDER");

                while(rs.next()){
                    curPage = new JSONObject();
                    for(String colName : rs.ColName){
                        curPage.put(colName.toLowerCase(), rs.value(colName));

                    }

                    String published_path = "";
                    if("published".equals(rs.value("publish_status"))){
                        published_path = getGridPageUrl(PAGES_PUBLISH_FOLDER, rs.value("site_id"),
                             rs.value("langue_code"), rs.value("variant"), rs.value("path"));
                    }
                    curPage.put("published_path",published_path);

                    pagesList.put(curPage);
                }

                data.put("pages",pagesList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting pages list. Please try again.",ex);
            }
        }
        else if("savePage".equalsIgnoreCase(requestType)){
            ArrayList<String> pageIds = new ArrayList<>();
            boolean isNew = false;
            int id = 0;
            try{
                id = parseInt(request.getParameter("id"), 0);

                String publishTime = parseNull(request.getParameter("publishTime"));
                String unpublishTime = parseNull(request.getParameter("unpublishTime"));
                String folderType = parseNull(request.getParameter("folderType"));
                String folderId = parseNull(request.getParameter("folderId"));
                String name = parseNull(request.getParameter("name"));
                String[] pageTags = parseNull(request.getParameter("pageTags")).split(",");
                String folderTable = getFolderTableName(folderType);
                // String templateId = parseNull(request.getParameter("templateId"));
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
                

                isNew  = id <= 0;

                if(name.length() == 0){
                    throw new SimpleException("Error: Name cannot be empty.");
                }
                // folder Id validation
                if(parseInt(folderId) > 0){
                    q = "SELECT id FROM  " + folderTable
                    + " WHERE id = " + escape.cote(folderId)
                    + " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);

                    if(!rs.next()){
                        throw new SimpleException("Error: Invalid folder parameters");
                    }
                }
                // parent_page id validation
                if(id > 0){
                    q = "SELECT id FROM freemarker_pages"
                        + " WHERE id = " + escape.cote(""+id)
                        + " AND site_id = " + escape.cote(siteId)
                        + " AND folder_id = " + escape.cote(folderId)
                        + " AND  is_deleted = '0'";
                    rs = Etn.execute(q);
                    if(!rs.next()){
                        throw new SimpleException("Error: Invalid parameters");
                    }
                }
                // name duplication validation
                q = "SELECT id FROM freemarker_pages WHERE name = " + escape.cote(name)
                    + "  AND folder_id = " + escape.cote(folderId)
                    + "  AND site_id = " + escape.cote(siteId)
                    + " AND  is_deleted = '0'";

                if(id > 0){
                    q += " AND id != " + escape.cote(""+id);
                }
                rs = Etn.execute(q);
                if(rs.next()){
                    throw new SimpleException("Error: Name already exists in folder. Please change name.");
                }

                // saving/updating freemarker_pages table
                int pid = Etn.getId();
                colValueHM.put("name", escape.cote(name));
                colValueHM.put("updated_ts", "NOW()");
                colValueHM.put("updated_by", escape.cote(""+pid));

                colValueHM.put("to_publish_ts", publishTime.length() > 0?escape.cote(publishTime):null);
                colValueHM.put("to_unpublish_ts", unpublishTime.length() > 0?escape.cote(unpublishTime):null);
                colValueHM.put("to_publish",publishTime.length() > 0?escape.cote("1"):escape.cote("0"));
                colValueHM.put("to_unpublish",unpublishTime.length() > 0?escape.cote("1"):escape.cote("0"));

                if(id <= 0){
                    //new
                    colValueHM.put("site_id", escape.cote(siteId));
                    colValueHM.put("folder_id", folderId);
                    colValueHM.put("publish_status", "'unpublished'");
                    colValueHM.put("publish_log", "'unpublished'");
					
					if("1".equals(parseNull(session.getAttribute("IS_WEBMASTER"))))
					{
						colValueHM.put("crt_by_webmaster", escapeCote2(getUserInfo(Etn).toString()));
					}
                    colValueHM.put("created_by", escape.cote(""+pid));
                    colValueHM.put("created_ts", "NOW()");

                    q = getInsertQuery("freemarker_pages",colValueHM);
                    System.out.println("query ==>"+q);
                    id = Etn.executeCmd(q);

                    if(id <= 0){
                        throw new SimpleException("Error in creating page. Please try again.");
                    }
                    else{
                        message = "Page created.";
                        data.put("id", id);
                    }
                }
                else{
                    //existing update
					colValueHM.put("to_generate", "1");
                    q = getUpdateQuery("freemarker_pages", colValueHM, " WHERE id = " + escape.cote(""+id) + " AND  is_deleted = '0'" );
                    int count = Etn.executeCmd(q);

                    if(count <= 0){
                        throw new SimpleException("Error in updating page. Please try again.");
                    }
                    else{
                        message = "Page updated.";
                        data.put("id", id);
						Etn.execute("select semfree(" + escape.cote(parseNull(GlobalParm.getParm("SEMAPHORE"))) + ")");
                    }
                }

                // saving all lang pages
                if(id > 0){
										
                    q = "DELETE FROM pages_tags WHERE page_id = " + escape.cote("" + id) + " and page_type ="+escape.cote("freemarker");
                    Etn.executeCmd(q);
					if(pageTags != null && pageTags.length > 0)
					{
						String tagQPrefix = "INSERT INTO pages_tags (page_id, page_type, tag_id) "
											+ " VALUES (" + escape.cote("" + id) + ", 'freemarker' , ";
						for (String tagId : pageTags) {
							if (tagId.trim().length() > 0) {
								q = tagQPrefix + escape.cote(tagId) + " )";
								System.out.println(q);
								Etn.executeCmd(q);
							}
						}
					}					
					
                    List<Language> langsList = getLangs(Etn,siteId);
                    for(Language curLang : langsList){
                        String curLangId = ""+curLang.getLanguageId();
                        JSONObject parameters =  getPageParametersJson(request, curLangId);
                        int pageId = parameters.optInt("pageId",0);
                        JSONObject res =  savePageCommon(Etn, request, parameters, siteId, session, id+"");
                        status = res.getInt("status");
                        String  msg = res.getString("message");

                        if(status == STATUS_SUCCESS){
                            pageId =  res.getJSONObject("data").getInt("pageId");
                        }
                        pageIds.add(pageId+"");

                        if(status == STATUS_ERROR){
                            // delete previous pages if new.
                            rollbackPageInsert(Etn, id+"", pageIds, isNew, siteId, Constant.PAGE_TYPE_FREEMARKER);
                            if(msg.length()>0){
                                throw new SimpleException(msg);
                            }
                            else{
                                throw new SimpleException("Error in saving page. Please try again.");
                            }
                        }
                    }
                    if(pageIds.size() != langsList.size()){
                        throw new SimpleException("Error in saving pages. Please try again.");
                    }
                }
                status = STATUS_SUCCESS;
                data.put("pageIds", pageIds);
            }catch (Exception ex){
                rollbackPageInsert(Etn, id+"", pageIds, isNew, siteId, Constant.PAGE_TYPE_FREEMARKER);
                throw new SimpleException("Error in saving pages. Please try again.",ex);
            }
        }
        else if("saveReactPage".equalsIgnoreCase(requestType)){
            try{
                JSONObject parameters = getPageParametersJson(request, "");
				
				String[] pageTags = parseNull(request.getParameter("pageTags")).split(",");
				
				int pageId = parseInt(parameters.optInt("pageId"));//for react page there is no parent page id so we use page id in pages_tags table
				
				q = "DELETE FROM pages_tags WHERE page_id = " + escape.cote("" + pageId) + " and page_type ="+escape.cote("react");
				Etn.executeCmd(q);
				if(pageTags != null && pageTags.length > 0)
				{
					String tagQPrefix = "INSERT INTO pages_tags (page_id, page_type, tag_id) "
										+ " VALUES (" + escape.cote("" + pageId) + ", 'react' , ";
					for (String tagId : pageTags) {
						if (tagId.trim().length() > 0) {
							q = tagQPrefix + escape.cote(tagId) + " )";
							Etn.executeCmd(q);
						}
					}					
				}
				
                JSONObject retObj =  savePageCommon(Etn, request, parameters, siteId, session, "0");
                message = retObj.getString("message");
                status = retObj.getInt("status");
                data = retObj.getJSONObject("data");
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving page. Please try again.",ex);
            }
        }
        else if("savePageBlocs".equalsIgnoreCase(requestType)){

            try{
                int pageId = parseInt(request.getParameter("pageId"), 0);
                q = " SELECT id, name FROM freemarker_pages "
                    + " WHERE id = " + escape.cote(""+pageId)
                    + " AND  is_deleted = '0'";
                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid params");
                }
                // -- deprecated --
                // if( !rs.value("type").equals(Constant.PAGE_TYPE_FREEMARKER) ){
                //     throw new SimpleException("Invalid page type");
                // }

                String pageName = rs.value("name");

                String blocIdsStr = parseNull(request.getParameter("blocIds"));

                ArrayList<String> blocIdsList = new ArrayList<>();

                if(blocIdsStr.length() > 0){
                    for(String str : blocIdsStr.split(",")){
                        if(str.startsWith("form_") || parseInt(str) > 0){
                            blocIdsList.add(str);
                        }
                    }
                }

                q = "DELETE FROM parent_pages_blocs WHERE page_id = " + escape.cote(""+pageId);
                Etn.executeCmd(q);
                q = "DELETE FROM parent_pages_forms WHERE page_id = " + escape.cote(""+pageId);
                Etn.executeCmd(q);

                String blocQPrefix = " INSERT INTO parent_pages_blocs(page_id, bloc_id, sort_order) VALUES ( " + escape.cote(""+pageId);
                String formQPrefix = " INSERT INTO parent_pages_forms(page_id, form_id, sort_order) VALUES ( " + escape.cote(""+pageId);
                
                 
                for(int i=0; i < blocIdsList.size(); i++){
                    String blocId = blocIdsList.get(i);

                    if(blocId.startsWith("form_")){
                    	String formId = blocId.substring(5);
                    	q =  formQPrefix + "," + escape.cote(formId) + "," + i + ")";
	                    Etn.executeCmd(q);
                    }
                    else{
	                    q =  blocQPrefix + "," + escape.cote(blocId) + "," + i + ")";
	                    Etn.executeCmd(q);
                    }
                }

				boolean isWebmasterProfil = "1".equals(parseNull(session.getAttribute("IS_WEBMASTER")));

                q = "UPDATE freemarker_pages SET updated_ts = NOW() "
                    + " , updated_by = " + escape.cote(""+Etn.getId());
				
				//we have a new case where we have to keep record of orange team webmasters user ID and time they actually
				//updated the content. Some times developers have to click save button just to update themes or some other thing related
				//to design so that gives us wrong info if the content was actually updated by webmaster
				if(isWebmasterProfil)
				{
					q += ", upd_by_webmaster = "+escapeCote2(getUserInfo(Etn).toString())+", upd_on_by_webmaster = now() ";
				}
				
				q += " WHERE id = " + escape.cote(""+pageId)
                    + " AND  is_deleted = '0'";


                Etn.executeCmd(q);

                PagesGenerator pagesGen = new PagesGenerator(Etn);
                pagesGen.generateAndSaveBlocPage(""+pageId);

                Set rsPage = Etn.execute("Select p.*,l.langue_id from pages p inner join language l on p.langue_code = l.langue_code where parent_page_id="+escape.cote(""+pageId));
                while(rsPage.next()) {                    
                    q = "DELETE FROM structure_mappings WHERE lang_page_id = " + escape.cote(parseNull(rsPage.value("id")));
                    Etn.executeCmd(q);
                    for(int i=0; i < blocIdsList.size(); i++){
                        String blocId = blocIdsList.get(i);
                        if(!blocId.startsWith("form_"))
                            insertChildBlocs(Etn,blocId,parseNull(rsPage.value("id")),parseNull(rsPage.value("langue_id")));
                    }
                }

                status = STATUS_SUCCESS;
                message = "Page blocs saved.";
                data.put("pageId", pageId);

                StringBuilder logMsg = new StringBuilder();
                logMsg.append("Page blocs update|pageId=")
                            .append(pageId).append("|")
                            .append(message).append("|")
                            .append(blocIdsList.toString()).append("|");

                logDebugInfo(request,Etn.getId(), logMsg.toString());
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),pageId+"","UPDATED","Page Blocks",pageName, siteId);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving page blocs. Please try again.",ex);

            }
        }
        else if("savePageLayout".equalsIgnoreCase(requestType)){
            try{

                String pageId = parseNull(request.getParameter("pageId"));

                q = " SELECT id, type, layout, name FROM pages "
                    + " WHERE id = " + escape.cote(pageId);
                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid params");
                }
                String pageName =  parseNull(rs.value("name"));

                if( !rs.value("type").equals(Constant.PAGE_TYPE_REACT) ){
                    throw new SimpleException("Invalid page type");
                }

                String pageLayout = rs.value("layout");

                StringBuilder logMsg = new StringBuilder();
                logMsg.append("Dynamic Page layout update|pageId=")
                            .append(pageId).append("|layout=")
                            .append(pageLayout).append("|");

                if(pageLayout.equals(Constant.PAGE_LAYOUT_CSS_GRID)){
                	String layoutData = parseNull(request.getParameter("layoutData"));
                	try{
                		JSONObject layoutDataJson = new JSONObject(layoutData);
                	}
                	catch(Exception ex){
                		throw new SimpleException("Invalid JSON for layout data",ex);
                	}

                	q = "UPDATE pages SET updated_ts = NOW(), layout_data = "
                		+ escape.cote(encodeJSONStringDB(layoutData))
                		+ " WHERE id = " + escape.cote(pageId);
                	Etn.executeCmd(q);

                }
                else if(pageLayout.equals(Constant.PAGE_LAYOUT_REACT)){
                	String itemsStr = parseNull(request.getParameter("items"));
                	JSONArray itemsList = new JSONArray(itemsStr);

                	q = " DELETE pv "
                	+ " FROM page_item_property_values pv "
                	+ " JOIN page_items pi ON pv.page_item_id = pi.id "
                	+ " WHERE pi.page_id = " + escape.cote(pageId);
                	Etn.executeCmd(q);

                	q = " DELETE pcu  "
                	+ " FROM page_component_urls pcu "
                	+ " JOIN page_items pi ON pcu.page_item_id = pi.id "
                	+ " WHERE pi.page_id = " + escape.cote(pageId);
                	Etn.executeCmd(q);

                	q = " DELETE FROM page_items "
                	+ " WHERE page_id = " + escape.cote(pageId);
                	Etn.executeCmd(q);

                	for (int i=0; i<itemsList.length(); i++ ) {
                		JSONObject curObj = itemsList.getJSONObject(i);

                		colValueHM.clear();
                		colValueHM.put("page_id",escape.cote(pageId));
                		colValueHM.put("component_id",escape.cote(curObj.getString("compId")));
                		colValueHM.put("index_key",escape.cote(""+i));
                		colValueHM.put("x_cord",escape.cote(curObj.get("x").toString()));
                		colValueHM.put("y_cord",escape.cote(curObj.get("y").toString()));
                		colValueHM.put("width",escape.cote(curObj.get("w").toString()));
                		colValueHM.put("height",escape.cote(curObj.get("h").toString()));
                		colValueHM.put("css_classes",escape.cote(curObj.getString("cssClasses")));
                		colValueHM.put("css_style",escape.cote(curObj.getString("cssStyle")));

                		logMsg.append(colValueHM.get("component_id")).append(",")
                		.append(colValueHM.get("index_key")).append(",")
                		.append(colValueHM.get("x_cord")).append(",")
                		.append(colValueHM.get("y_cord")).append("|");

                		q = getInsertQuery("page_items",colValueHM);

                		int pageItemId = Etn.executeCmd(q);

                		if(pageItemId > 0) {

                			JSONArray urlList = curObj.getJSONArray("urlList");
                			for (int j=0; j<urlList.length(); j++ ) {
                				String curUrl = urlList.getString(j);

                				colValueHM.clear();
                				colValueHM.put("page_item_id",escape.cote(""+pageItemId));
                				colValueHM.put("type","'item'");
                				colValueHM.put("component_id","'0'");
                				colValueHM.put("url",escape.cote(curUrl));

                				q = getInsertQuery("page_component_urls", colValueHM);
                				Etn.executeCmd(q);
                			}


                			if( curObj.getString("compId").length() > 0 ){

                				JSONObject propValues = curObj.getJSONObject("propValues");

                				for(String key : propValues.keySet()){
                					String value = propValues.getString(key);

                					colValueHM.clear();
                					colValueHM.put("page_item_id",escape.cote(""+pageItemId));
                					colValueHM.put("property_id",escape.cote(key));
                					colValueHM.put("value",escape.cote(value));

                					q = getInsertQuery("page_item_property_values", colValueHM);
                					Etn.executeCmd(q);

                				}
                			}
                		}
                	}//for
                }
                status = STATUS_SUCCESS;
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),pageId,"UPDATED","Page Layout",pageName,siteId);


                logDebugInfo(request,Etn.getId(), logMsg.toString());


            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving page layout. Please try again.",ex);
            }
        } 
        else if("getDynamicPageInfo".equalsIgnoreCase(requestType)){
            try{
                String pageId = parseNull(request.getParameter("pageId"));

                JSONObject retObj = new JSONObject();
                JSONObject curObj = null;

                q = "SELECT * FROM pages "
                    + " WHERE id = " + escape.cote(pageId)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);

                if(rs.rs.Rows <= 0){
                    throw new SimpleException("Error: page not found.");
                }

                if(rs.next()){
                    for(String colName : rs.ColName){
                        retObj.put(colName.toLowerCase(), rs.value(colName));
                    }
                }

                String pageType = rs.value("type");
                String pageLayout = rs.value("layout");

                JSONArray pageTags = new JSONArray();
                retObj.put("tags",pageTags);

                String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");
                q = "SELECT t.id, t.label FROM pages_tags pt "
                    + " JOIN "+CATALOG_DB+".tags t ON pt.tag_id = t.id "
                    + " WHERE t.site_id = " + escape.cote(siteId)
                    + " AND pt.page_id = " + escape.cote(rs.value("id"))//for react page there is no parent page id so we use ID for page tags
                    + " AND pt.page_type = " + escape.cote(rs.value("type"))
                    + " ORDER BY t.label";
                Set tagRs = Etn.execute(q);
                while(tagRs.next()){
                    JSONObject tagObj = new JSONObject();
                    tagObj.put("id",tagRs.value("id"));
                    tagObj.put("label",tagRs.value("label"));
                    pageTags.put(tagObj);
                }

                //get prefix paths list per language
                retObj.put("pagePathPrefixList", getPagePrefixPathsByFolderId(Etn, rs.value("folder_id"), siteId));

                if(Constant.PAGE_TYPE_FREEMARKER.equals(pageType)){

                    q = " SELECT meta_name, meta_content FROM pages_meta_tags "
                    + " WHERE page_id = " + escape.cote(pageId)
                    + " ORDER BY meta_name ";
                    Set mRs = Etn.execute(q);
                    JSONArray customMetaTags = new JSONArray();
                    while(mRs.next()){
                        JSONObject metaTag = new JSONObject();
                        metaTag.put("meta_name", mRs.value("meta_name"));
                        metaTag.put("meta_content", mRs.value("meta_content"));
                        customMetaTags.put(metaTag);
                    }

                    retObj.put("custom_meta_tags", customMetaTags);
                }
                else if(Constant.PAGE_TYPE_REACT.equals(pageType)){


                	q = " SELECT url, js_key FROM pages_urls "
                    + " WHERE page_id = " + escape.cote(pageId)
                    + " ORDER BY js_key ";
                    Set uRs = Etn.execute(q);
                    JSONArray pageUrls = new JSONArray();
                    while(uRs.next()){
                        JSONObject pageUrl = new JSONObject();
                        pageUrl.put("url", uRs.value("url"));
                        pageUrl.put("js_key", uRs.value("js_key"));
                        pageUrls.put(pageUrl);
                    }

                    retObj.put("page_urls", pageUrls);

                    JSONArray components = new JSONArray();
                    retObj.put("components",components);

                    q = " SELECT i.*, IFNULL(c.name,'') AS component_name "
                        + " FROM page_items i "
                        + " LEFT JOIN components c ON c.id = i.component_id "
                        + " WHERE i.page_id = " + escape.cote(pageId)
                        + " ORDER BY index_key , id" ;
                    rs = Etn.execute(q);
                    while(rs.next()){
                        curObj = new JSONObject();
                        for(String colName : rs.ColName){
                            curObj.put(colName.toLowerCase(), rs.value(colName));
                        }

                        JSONArray propertyValues = new JSONArray();
                        curObj.put("property_values", propertyValues );

                        JSONArray urls = new JSONArray();
                        curObj.put("urls", urls );

                        components.put(curObj);

                        q = "SELECT * "
                            + " FROM page_item_property_values pv "
                            + " WHERE page_item_id = " + escape.cote(rs.value("id"));
                        Set cRs = Etn.execute(q);
                        while(cRs.next()){
                            curObj = new JSONObject();
                            curObj.put("property_id", cRs.value("property_id"));
                            curObj.put("value", cRs.value("value"));
                            propertyValues.put(curObj);
                        }

                        q = "SELECT url  "
                            + " FROM page_component_urls  "
                            + " WHERE type = 'item' AND component_id = '0' "
                            + " AND page_item_id = " + escape.cote(rs.value("id"));
                        cRs = Etn.execute(q);
                        while(cRs.next()){
                            urls.put(cRs.value("url"));
                        }

                        if(parseInt(rs.value("component_id")) > 0){
                            q = "SELECT * "
                            + " FROM page_item_property_values pv "
                            + " WHERE page_item_id = " + escape.cote(rs.value("id"));
                            cRs = Etn.execute(q);
                            while(cRs.next()){
                                curObj = new JSONObject();
                                curObj.put("property_id", cRs.value("property_id"));
                                curObj.put("value", cRs.value("value"));
                                propertyValues.put(curObj);
                            }

                        }
                    }
                }

                data.put("page",retObj);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in page info.",ex);
            }
        } 
        else if("getPageInfo".equalsIgnoreCase(requestType)){

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

                q = "SELECT pp.id, pp.name, p.id page_id, l.langue_id,pp.to_publish_ts,pp.to_unpublish_ts "
                    + " FROM freemarker_pages pp"
                    + " JOIN pages p ON pp.id = p.parent_page_id"
                    + " JOIN " + GlobalParm.getParm("CATALOG_DB") + ".language l ON p.langue_code = l.langue_code "
                    + " WHERE pp.id = " + escape.cote(id)
                    + " AND pp.site_id = " + escape.cote(siteId)
                    + " AND  pp.is_deleted = '0'"
                    + " AND  p.type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER) ;

                rs = Etn.execute(q);
                // if(!rs.next()){
                //     throw new SimpleException("Invalid parameters");
                // }

                // String templateId = rs.value("template_id");
                // data.put("templateId", templateId);

                JSONObject pages = new JSONObject();
				JSONArray pageTags = new JSONArray();

				q = "SELECT t.id, t.label FROM pages_tags pt "
					+ " JOIN "+GlobalParm.getParm("CATALOG_DB")+".tags t ON pt.tag_id = t.id "
					+ " WHERE t.site_id = " + escape.cote(siteId)
					+ " AND pt.page_id = " + escape.cote(id)
					+ " AND pt.page_type = " + escape.cote(Constant.PAGE_TYPE_FREEMARKER)
					+ " ORDER BY t.label";
				Set tagRs = Etn.execute(q);
				while(tagRs.next()){
					JSONObject tagObj = new JSONObject();
					tagObj.put("id",tagRs.value("id"));
                    tagObj.put("label",tagRs.value("label"));

					pageTags.put(tagObj);
				}
				data.put("tags", pageTags);
                while(rs.next()){
                    String langId = rs.value("langue_id");
                    String pageId = rs.value("page_id");
                    if(parseInt(pageId)>0 && siteLangs.contains(langId)){
                        JSONObject pageObj = getPageInfo(Etn, pageId, siteId);

                        if(pageObj.getInt("status") == STATUS_SUCCESS){
                            pages.put("page_lang_"+langId, pageObj.getJSONObject("page"));
                        }
                        else{
                            throw new SimpleException("Error in getting info.");
                        }
                    }
                    data.put("name", rs.value("name"));
                    data.put("publishTime", rs.value("to_publish_ts"));
                    data.put("unpublishTime", rs.value("to_unpublish_ts"));
                }
                data.put("pages", pages);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting info.", ex);
            }
        }
        else if("getPagePreview".equalsIgnoreCase(requestType)){
            try{
                //this is for dynamic (react type) pages

                String pageId = parseNull(request.getParameter("pageId"));

                JSONArray pagesList = new JSONArray();
                JSONObject curPage = null;

                q = " SELECT id, type, site_id, variant,langue_code, path, publish_status "
                    + " FROM pages p"
                    + " WHERE site_id = " + escape.cote(siteId)
                    + " AND id = " + escape.cote(pageId);
                rs = Etn.execute(q);

                if(!rs.next()){
                    throw new SimpleException("Error: Invalid parameters.");
                }

                if( !rs.value("type").equals(Constant.PAGE_TYPE_REACT)){
                    throw new SimpleException("Error: Invalid page type.");
                }


                String publishStatus = rs.value("publish_status");
                String url = "";
                if("published".equals(publishStatus)){
                    status = STATUS_SUCCESS;

                    String PAGES_PUBLISH_FOLDER = GlobalParm.getParm("PAGES_PUBLISH_FOLDER");

                    url = getGridPageUrl(PAGES_PUBLISH_FOLDER, rs.value("site_id"),
                            rs.value("langue_code"), rs.value("variant"), rs.value("path"));
                }
                else if("processing".equals(publishStatus) || "queued".equals(publishStatus)){
                    status = STATUS_ERROR;
                    message = "Page is still " + publishStatus + ".";
                }
                else if("error".equals(publishStatus)){
                    status = STATUS_ERROR;
                    message = "There was a error in publishing. Please try again.";
                }
                else{
                    status = STATUS_ERROR;
                    message = "Page is not published yet. Please publish it first.";
                }

                data.put("publishStatus", publishStatus);
                data.put("url", url);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting page preview. Please try again.",ex);
            }
        }
        else if("movePages".equalsIgnoreCase(requestType)){
            // move folder, structuredPage , page
            try{
                String pagesData = parseNull(request.getParameter("pages"));
                String moveToFoldreId = parseNull(request.getParameter("moveToFolderId"));
                String folderType = parseNull(request.getParameter("folderType"));
                String folderTable = getFolderTableName(folderType);
                System.out.println("folderTable :: "+folderTable);
                JSONArray pages = new JSONArray(pagesData);
                int totalCount = pages.length();
                int moveToFolderLevel = 0;
                String movedToFolderName = "base";
                if(totalCount == 0){
                    throw new SimpleException("Error: No id found");
                }

                if(moveToFoldreId.equals("")){
                    throw new SimpleException("Cannot move to invalid folder");
                }
                else if(parseInt(moveToFoldreId) > 0){
                    q = "SELECT folder_level, name FROM "+folderTable+" WHERE id = "+escape.cote(moveToFoldreId);
                    rs = Etn.execute(q);
                    if(!rs.next()){
                        throw new SimpleException("Cannot move to invalid folder");
                    }
                    moveToFolderLevel  = parseInt(rs.value("folder_level"));
                    movedToFolderName = rs.value("name");
                }

                int movePageCount = 0;
                int moveFolderCount = 0;

                String movedPageIds = "";
                String movedPageNames = "";

                String movedStructurePageIds = "";
                String movedStructurePageNames = "";

                String movedFolderIds = "";
                String movedFolderNames = "";

                String type = "";
                ArrayList<String> unmovedItems = new ArrayList<>();
                ArrayList<String> unmovedItemsMessages = new ArrayList<>();

                for(Object obj : pages){
                    JSONObject pageObj  = (JSONObject)obj;
                    JSONObject moveResp = null;

                    String id = pageObj.optString("id","-1");
                    type = pageObj.optString("type");
                    String name = getPageName(Etn, id, type);

                    if(type.equals("folder")){
                        moveResp = moveFolder(Etn , id, moveToFoldreId, moveToFolderLevel, folderType, siteId);
                    } else {
                        moveResp = movePage(Etn , id, type, moveToFoldreId, siteId);
                    }
                    boolean isMoved = moveResp.optBoolean("status");

                    if(isMoved){
                        if(type.equals("folder")){
                            moveFolderCount += 1;
                            movedFolderIds += id+", ";
                            movedFolderNames += name+", ";
                        } else if(type.equals(Constant.PAGE_TYPE_FREEMARKER)){
                            movePageCount += 1;
                            movedPageIds += id+", ";
                            movedPageNames += name+", ";
                        } else if(type.equals(Constant.PAGE_TYPE_STRUCTURED)){
                            movePageCount += 1;
                            movedStructurePageIds += id+", ";
                            movedStructurePageNames += name+", ";
                        }
                    } else {
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
                    } else if(type.equals(Constant.PAGE_TYPE_FREEMARKER) || type.equals(Constant.PAGE_TYPE_STRUCTURED)){
                        if(movePageCount > 0){
                            status = STATUS_SUCCESS;
                            message = "Page moved";
                        } else {
                            if(unmovedItemsMessages.size()>0){
                                message = unmovedItemsMessages.get(0);
                            } else {
                                message = "Error in moving page";
                            }
                        }
                    }
                }
                else {
                    status = STATUS_SUCCESS;
                    if(movePageCount > 0){
                        message = movePageCount + " pages";
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
                    if((moveFolderCount + movePageCount) == 0){
                        message += "No page or folder moved";
                    }
                    if((moveFolderCount + movePageCount) < totalCount){
                        message += "<br>";
                        for(int i = 0; i < unmovedItems.size(); i++){
                            message += "<br>";
                            message += unmovedItems.get(i)+" : "+ unmovedItemsMessages.get(i);
                        }
                    }
                }
                //mark for publish by engine
                if((moveFolderCount + movePageCount) >0){
                    q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("SEMAPHORE"))) + ")";
                    Etn.execute(q);
                }
                //logs
                if (status == STATUS_SUCCESS) {
                    if(movedFolderIds.length()>0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), movedFolderIds, "MOVED",
                         "Pages Folder", movedFolderNames+" (moved to) => "+movedToFolderName+" folder", siteId);
                    }
                    if(movedStructurePageIds.length()>0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), movedStructurePageIds,
                        "MOVED", "Structured Pages", movedStructurePageNames+" (moved to) => "+movedToFolderName+" folder", siteId);
                    }
                    if(movedPageIds.length()>0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),
                         movedPageIds, "MOVED", "Pages", movedPageNames+" (moved to) => "+movedToFolderName+" folder", siteId);
                    }
                }
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in moving pages and folders. Please try again.",ex);
            }
        }
        else if("copyBlocPage".equalsIgnoreCase(requestType)){
            int parentPageId = 0;
            try{
                String copyPageId = parseNull(request.getParameter("pageId")); // copied from
                String duplicateBlocs = parseNull(request.getParameter("duplicateBlocs"));
                String name = parseNull(request.getParameter("name"));
                if(name.length() == 0){
                    throw new SimpleException("Error: name cannot be empty.");
                }
                // pageId validation check
                q = "SELECT * FROM freemarker_pages WHERE id = "+escape.cote(copyPageId)
                + " AND site_id = "+escape.cote(siteId);

                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid parameters.");
                }
                String folderId = rs.value("folder_id");

                // check duplicate page name
                q = "SELECT id FROM freemarker_pages"
                   + " WHERE name = " + escape.cote(name)
                   + " AND folder_id = " + escape.cote(folderId)
                   + " AND site_id  = " + escape.cote(siteId);

                Set rsName = Etn.execute(q);
                if(rsName.next()){
                    throw new SimpleException("Error: Name already exists. Please change name.");
                }

                colValueHM.clear();
                String pid = Etn.getId()+"";
                colValueHM.put("name",escape.cote(name));
                colValueHM.put("created_by",escape.cote(pid));
                colValueHM.put("updated_by",escape.cote(pid));
                colValueHM.put("created_ts","NOW()");
                colValueHM.put("updated_ts","NOW()");
                colValueHM.put("folder_id",escape.cote(folderId));
                colValueHM.put("site_id",escape.cote(siteId));

                q = getInsertQuery("freemarker_pages",colValueHM);
                parentPageId = Etn.executeCmd(q);

                if(parentPageId > 0){
					q = " INSERT INTO pages_tags(page_id, page_type, tag_id) "
						+ " SELECT "+escape.cote(""+parentPageId)+", page_type, tag_id "
						+ " FROM pages_tags "
						+ " WHERE page_id = " + escape.cote(copyPageId)
						+ " and page_type = " + escape.cote("freemarker");
					Etn.executeCmd(q);

                    q =  "SELECT * FROM pages WHERE parent_page_id = "+escape.cote(copyPageId)
                    + " AND site_id  = "+escape.cote(siteId) +" AND type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)+" and langue_code in (SELECT lang.langue_code FROM " + GlobalParm.getParm("CATALOG_DB")+ ".language lang JOIN " + GlobalParm.getParm("COMMONS_DB")
                    + ".sites_langs sl ON sl.langue_id=lang.langue_id WHERE sl.site_id=" + escape.cote(siteId)+" ORDER BY lang.langue_id)";
                    rs = Etn.execute(q);

                    while (rs.next()){
                        String pageId = rs.value("id");
                        String langue_code = rs.value("langue_code");
                        Set rsLang =  Etn.execute("SELECT langue_id FROM language WHERE langue_code = "+escape.cote(langue_code));

                        String langueId = "";
                        if(rsLang.next()){
                            langueId  = rsLang.value("langue_id");
                        }

                        // get request langue params
                        String path = parseNull(request.getParameter("path_lang_"+langueId));
                        String variant = parseNull(request.getParameter("variant_lang_"+langueId));

                        if(path.length() == 0){
                            rollbackPageInsert(Etn, parentPageId+"", siteId, Constant.PAGE_TYPE_FREEMARKER);
                            throw new SimpleException("Error: path cannot be empty for language "+langue_code+".");
                        }

                        //check duplicate url/path
                        StringBuffer urlErrorMsg = new StringBuffer();
                        String pageIdStr = ""; // no page id as we are creating new page

                        q = "SELECT fp.concat_path as folder_path FROM pages_folders_lang_path fp"
                            + " JOIN "+GlobalParm.getParm("CATALOG_DB") + ".language l on l.langue_id = fp.langue_id"
                            + " WHERE fp.site_id = "+escape.cote(siteId)
                            + " AND fp.folder_id = "+escape.cote(folderId)
                            + " AND l.langue_code = "+escape.cote(langue_code);

                        Set rsPathPrefix =  Etn.execute(q);
                        String fullPagePath  = path;
                        if(rsPathPrefix.next()){
                            String pathPrefix = rsPathPrefix.value("folder_path");
                            if(pathPrefix.length()>0){
                                fullPagePath = pathPrefix+"/"+path;
                            }
                        }

                        boolean isUnique = isPageUrlUnique(Etn, siteId,
                                                    langue_code, variant, fullPagePath,
                                                    pageIdStr, urlErrorMsg);
                        if(!isUnique){
                            rollbackPageInsert(Etn, parentPageId+"", siteId, Constant.PAGE_TYPE_FREEMARKER);
                            throw new SimpleException("Error: Path '"+path+"' entered for language '"+langue_code+"' is not unique across the site. " + urlErrorMsg);
                        }

                        // adding the langue pages
                        String pageType = rs.value("type");
                        colValueHM.clear();
                        for(String colName : rs.ColName){
                            if(colName.startsWith("to_")){
                                continue;//skip
                            }
                            colValueHM.put(colName.toLowerCase(), escape.cote(rs.value(colName)));
                        }

                        colValueHM.remove("id");
                        colValueHM.remove("published_ts");
                        colValueHM.remove("published_by");
                        colValueHM.remove("html_file_path"); //set by page generator afterwards
                        colValueHM.remove("published_html_file_path");
                        colValueHM.remove("publish_log");

                        colValueHM.put("name",escape.cote(name));
                        colValueHM.put("path",escape.cote(path));
                        colValueHM.put("variant",escape.cote(variant));
                        colValueHM.put("langue_code",escape.cote(langue_code));
                        colValueHM.put("publish_status","'unpublished'");
                        colValueHM.put("created_by",escape.cote(""+pid));
                        colValueHM.put("updated_by",escape.cote(""+pid));
                        colValueHM.put("created_ts","NOW()");
                        colValueHM.put("updated_ts","NOW()");
                        colValueHM.put("parent_page_id",escape.cote(""+parentPageId));

                        q = getInsertQuery("pages",colValueHM);

                        int newPageId = Etn.executeCmd(q);
                        if(newPageId <= 0){
                            rollbackPageInsert(Etn, ""+parentPageId, siteId, Constant.PAGE_TYPE_FREEMARKER);
                            throw new SimpleException("Error in copying page. Please try again.");
                        } else{
                            q = " INSERT INTO pages_meta_tags(page_id, meta_name, meta_content) "
                                + " SELECT "+escape.cote(""+newPageId)+", meta_name, meta_content "
                                + " FROM pages_meta_tags "
                                + " WHERE page_id = " + escape.cote(pageId);
                            Etn.executeCmd(q);
                        }
                    }

                    if(duplicateBlocs.equals("1")){
                        // create copy of blocks
                        q  = "SELECT pb.page_id, pb.sort_order, b.id, b.name  from parent_pages_blocs pb "
                            + " JOIN blocs b ON b.id = pb.bloc_id "
                            + " WHERE pb.page_id = "+escape.cote(copyPageId+"")
                            +"  ORDER BY sort_order";
                        Set rsPageBlocs = Etn.execute(q);
                        while(rsPageBlocs.next()){

                            boolean flag = true;
                            int counter = 0;
                            rsName = null;
                            String newBlocName = "";
                            while(flag){
                                counter++;
                                newBlocName = rsPageBlocs.value("name")+" "+counter;
                                rsName = Etn.execute("SELECT id from blocs where name = "+escape.cote(newBlocName));
                                if(rsName.rs.Rows == 0 ) flag  = false;
                            }

                            int newBlocId = copyBlock(Etn, rsPageBlocs.value("id"), newBlocName, siteId );
                            if(newBlocId>0){
                                q = " INSERT INTO parent_pages_blocs(page_id, bloc_id, type, sort_order) "
                                    + "VALUES("+escape.cote(parentPageId+"")
                                    +", "+escape.cote(""+newBlocId)
                                    +", "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)
                                    +", "+escape.cote(rsPageBlocs.value("sort_order"))+" ) ";
                                Etn.executeCmd(q);
                            }
                        }
                    }
                    else{
                        //copy existing blocs
                        q = " INSERT INTO parent_pages_blocs(page_id, bloc_id, type ,sort_order) "
                            + " SELECT "+escape.cote(""+parentPageId)+" as page_id, bloc_id, type, sort_order"
                            + " FROM parent_pages_blocs "
                            + " WHERE page_id = " + escape.cote(copyPageId+"");
                        Etn.executeCmd(q);
                    }

                    q = " INSERT INTO parent_pages_forms(page_id, form_id, type, sort_order) "
                        + " SELECT "+escape.cote(""+parentPageId)+" as page_id, form_id, type, sort_order "
                        + " FROM parent_pages_forms "
                        + " WHERE page_id = " + escape.cote(copyPageId);
                    Etn.executeCmd(q);

                    PagesGenerator pagesGen = new PagesGenerator(Etn);
                    pagesGen.generateAndSaveBlocPage(""+parentPageId);
                    status = STATUS_SUCCESS;
                    message = "Page copied successfully";
                }
            }//try
            catch(Exception ex){
                rollbackPageInsert(Etn, parentPageId+"", siteId, Constant.PAGE_TYPE_FREEMARKER);
                throw new SimpleException("Error in copying page. Please try again.",ex);
            }
        }
        else if("copyReactPage".equalsIgnoreCase(requestType)){

            try{
                String pageId = parseNull(request.getParameter("pageId"));
                String name = parseNull(request.getParameter("name"));
                String path = parseNull(request.getParameter("path"));
                String variant = parseNull(request.getParameter("variant"));
                String langue_code = parseNull(request.getParameter("langue_code"));
                if(name.length() == 0){
                    throw new SimpleException("Error: name cannot be empty.");
                }
                if(path.length() == 0){
                    throw new SimpleException("Error: path cannot be empty.");
                }

                q = " SELECT * FROM pages WHERE id = " + escape.cote(pageId);

                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid parameters.");
                }
                StringBuffer urlErrorMsg = new StringBuffer();
                String pageIdStr = ""; // no page id as we are creating new page

                q = "SELECT fp.concat_path as folder_path FROM pages_folders_lang_path fp"

                    + " JOIN "+GlobalParm.getParm("CATALOG_DB") + ".language l on l.langue_id = fp.langue_id"
                    + " WHERE fp.site_id = "+escape.cote(siteId)
                    + " AND fp.folder_id = "+escape.cote("0")
                    + " AND l.langue_code = "+escape.cote(langue_code);
                Set rsPathPrefix =  Etn.execute(q);
                String fullPagePath  = path;
                if(rsPathPrefix.next()){
                    String pathPrefix = rsPathPrefix.value("folder_path");
                    if(pathPrefix.length()>0){
                        fullPagePath = pathPrefix+"/"+path;
                    }
                }

                //check duplicate page name
                q = "SELECT id FROM pages WHERE name = " + escape.cote(name)
                    + " AND type = " + escape.cote(Constant.PAGE_TYPE_REACT)
                    + " AND folder_id = " + escape.cote("0");
                Set tempRs = Etn.execute(q);
                if(tempRs.next()){
                    throw new SimpleException("Error: Name already exists. Please change name.");
                }

                boolean isUnique = isPageUrlUnique(Etn, siteId,
                                            langue_code, variant, fullPagePath,
                                            pageIdStr, urlErrorMsg);
                if(!isUnique){
                    throw new SimpleException("Error: Path '"+path+"' entered for language '"+langue_code+"' is not unique across the site. " + urlErrorMsg);
                }

                String pageType = rs.value("type");
                colValueHM.clear();
                for(String colName : rs.ColName){
                    if(colName.startsWith("to_")){
                        continue;//skip
                    }
                    colValueHM.put(colName.toLowerCase(), escape.cote(rs.value(colName)));
                }

                int pid = Etn.getId();
                colValueHM.remove("id");
                colValueHM.remove("published_ts");
                colValueHM.remove("published_by");
                colValueHM.remove("html_file_path"); //set by page generator afterwards
                colValueHM.remove("published_html_file_path");
                colValueHM.remove("publish_log");

                colValueHM.put("name",escape.cote(name));
                colValueHM.put("path",escape.cote(path));
                colValueHM.put("variant",escape.cote(variant));
                colValueHM.put("langue_code",escape.cote(langue_code));
                colValueHM.put("publish_status","'unpublished'");
                colValueHM.put("created_by",escape.cote(""+pid));
                colValueHM.put("updated_by",escape.cote(""+pid));
                colValueHM.put("created_ts","NOW()");
                colValueHM.put("updated_ts","NOW()");

                q = getInsertQuery("pages",colValueHM);

                int newPageId = Etn.executeCmd(q);
                if(newPageId <= 0){
                    message = "Error in copying page. Please try again.";
                }
                else{
                    q = " INSERT INTO pages_urls(page_id, type, url, js_key) "
                        + " SELECT "+escape.cote(""+newPageId)+", type, url, js_key "
                        + " FROM pages_urls "
                        + " WHERE page_id = " + escape.cote(pageId);
                    Etn.executeCmd(q);

                    if(Constant.PAGE_TYPE_REACT.equals(pageType)){
                        q = " SELECT * FROM page_items "
                            + " WHERE page_id = " + escape.cote(pageId);
                        rs = Etn.execute(q);
                        while(rs.next()){
                            colValueHM.clear();
                            for(String colName : rs.ColName){
                                colValueHM.put(colName.toLowerCase(), escape.cote(rs.value(colName)));
                            }

                            colValueHM.remove("id");
                            colValueHM.put("page_id",escape.cote(""+newPageId));

                            q = getInsertQuery("page_items",colValueHM);
                            int newItemId = Etn.executeCmd(q);

                            if(newItemId > 0){
                                q = " INSERT INTO page_item_property_values(page_item_id, property_id, value) "
                                    + " SELECT "+escape.cote(""+newItemId)+", property_id, value "
                                    + " FROM page_item_property_values "
                                    + " WHERE page_item_id = " + escape.cote(rs.value("id"));
                                Etn.executeCmd(q);
                            }
                        }
                    }

                    status = STATUS_SUCCESS;
                    message = "Page copied.";
                    data.put("pageId",newPageId);
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in copying page. Please try again.",ex);
            }
        }
        else if("isPublishLogin".equalsIgnoreCase(requestType)){

            try{
                String COMMONS_DB = GlobalParm.getParm("COMMONS_DB");
            	q = " SELECT 1 FROM "+COMMONS_DB+".user_sessions "
            		+ " WHERE is_publish_prod_login = 1 AND pages_session_id = " + escape.cote(session.getId());
            	rs = Etn.execute(q);
            	if(rs.next()){
            		status = STATUS_SUCCESS;
            	}

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in checking publish login.",ex);
            }
        }
        else if("doPublishLogin".equalsIgnoreCase(requestType)){

            try{

                String username = parseNull(request.getParameter("username"));
                String password = parseNull(request.getParameter("password"));

                q = "SELECT l.pid FROM login l, profil pr, profilperson pp "
                    + " WHERE pr.profil not in ('PROD_CACHE_MGMT','PROD_SITE_ACCESS','TEST_SITE_ACCESS') "
                    + " AND l.pid = pp.person_id  "
                    + " AND pp.profil_id = pr.profil_id "
                    + " AND l.name = " + escape.cote(username)
                    + " AND l.pass = sha2(concat("+escape.cote(GlobalParm.getParm("ADMIN_PASS_SALT"))+",':',"+escape.cote(password)+",':',l.puid),256) ";

                rs = Etn.execute(q);
                if(rs.next()){
                    String COMMONS_DB = GlobalParm.getParm("COMMONS_DB");
                    q = "UPDATE "+COMMONS_DB+".user_sessions SET is_publish_prod_login = 1 "
                    	+  " WHERE pages_session_id = " + escape.cote(session.getId());
                    Etn.executeCmd(q);
                    status = STATUS_SUCCESS;
                }
                else{
                    message = "Invalid username or password";
                    status = STATUS_ERROR;
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in publish login.",ex);
            }
        }
        else if("getLog".equalsIgnoreCase(requestType) || "getHtmlLog".equalsIgnoreCase(requestType)){

            try{
                String columnName = "getLog".equalsIgnoreCase(requestType) ? "publish_log" : "get_html_log";

                String id = parseNull(request.getParameter("id"));

                q = "SELECT "+columnName+" FROM pages "
                    + " WHERE id = " + escape.cote(id)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if(rs.next()){
                    String log = parseNull(rs.value(0));
                    data.put("log", log);

                    status = STATUS_SUCCESS;
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in in getting log.",ex);
            }
        }
        else if("generateHtml".equalsIgnoreCase(requestType)){
            try{
                boolean isGenerate = "1".equals(parseNull(request.getParameter("isGenerate")));
                String[] ids= request.getParameterValues("ids");

                int totalCount = ids.length;
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                String publishStatus = isGenerate ? "queued":"unpublished";
                String retStatus = isGenerate ? "queued for generation":"deleted";

                q = "UPDATE pages SET get_html_status = " + escape.cote(publishStatus)
                        + " WHERE site_id = " + escape.cote(siteId)
                        + " AND id = ";
                for(String curId : ids){
                    Etn.executeCmd(q + escape.cote(curId));
                }

                if(isGenerate){
                    q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("SEMAPHORE"))) + ");";
                    Etn.execute(q);
                }

                status = STATUS_SUCCESS;
                message = "" + totalCount + " page HTML " + retStatus;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in generate/delete HTML. Please try again.",ex);
            }
        }
        else if("getDynamicHtml".equalsIgnoreCase(requestType)){

            try{
                String id = parseNull(request.getParameter("id"));

                q = "SELECT get_html_status, dynamic_html FROM pages "
                    + " WHERE id = " + escape.cote(id)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if(rs.next()){

                    if(rs.value("get_html_status").equals("published")){
                        data.put("html",rs.value("dynamic_html"));
                        status = STATUS_SUCCESS;
                    }

                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting dynamic HTML.",ex);
            }
        }
        else if("getLayoutData".equalsIgnoreCase(requestType)){

            try{
                String id = parseNull(request.getParameter("id"));

                q = "SELECT layout_data FROM pages "
                    + " WHERE id = " + escape.cote(id)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if(rs.next()){
                    data.put("layout_data",decodeJSONStringDB(rs.value("layout_data")));
                    status = STATUS_SUCCESS;
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting layout data.",ex);
            }
        }
        else if("checkPageLock".equalsIgnoreCase(requestType)){

            try{
                String pageType = parseNull(request.getParameter("pageType"));
                String pageId = parseNull(request.getParameter("pageId"));
                Set rsLockedPage = Etn.execute("select * from locked_items where item_type="+escape.cote(pageType)+" and item_id="+escape.cote(pageId)+
                    "and site_id="+escape.cote(siteId)+" and is_locked=1 and locked_by!="+escape.cote(""+Etn.getId()));
                data.put("rsp", rsLockedPage.rs.Rows);
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in checking lock on page.",ex);
            }
        }
        else if("manageLocks".equalsIgnoreCase(requestType)){
            try{
                String pageId = parseNull(request.getParameter("pageId"));
                String pageType = parseNull(request.getParameter("pageType"));
                
                Set rsLockedPage = Etn.execute("select * from locked_items where item_id="+escape.cote(pageId)+" and item_type="+escape.cote(pageType)+" and site_id="+escape.cote(siteId));
                if(rsLockedPage.rs.Rows>0){
                    int idTmp = Etn.executeCmd("update locked_items set updated_ts=now() where item_id="+escape.cote(pageId)+" and item_type="+escape.cote(pageType)+
                        " and site_id="+escape.cote(siteId)+" and is_locked=1 and locked_by="+escape.cote(""+Etn.getId()));

                    if(idTmp>0){
                        data.put("rsp", 2);
                    }else{
                        idTmp = Etn.executeCmd("update locked_items set  is_locked=1,locked_by="+escape.cote(""+Etn.getId())+" where item_id="+escape.cote(pageId)+
                            " and item_type="+escape.cote(pageType)+" and site_id="+escape.cote(siteId)+" and is_locked=1 and locked_by!="+escape.cote(""+Etn.getId())+
                            " and TIMESTAMPDIFF(SECOND, updated_ts, NOW()) >= 35");
                        
                        if(idTmp>0){
                            data.put("rsp", 0);
                        }else{
                            data.put("rsp", 1);
                        }
                    }
                }else{
                    Etn.executeCmd("insert into locked_items (item_id,item_type,site_id,is_locked,locked_by) values("+escape.cote(pageId)+","+escape.cote(pageType)+
                        ","+escape.cote(siteId)+",1,"+escape.cote(""+Etn.getId())+")");
                    data.put("rsp", 2);
                }
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in managing lock on page.",ex);
            }
        }
        else if("addToShortcut".equalsIgnoreCase(requestType)){
            try{
                String pagePath = parseNull(request.getParameter("pagePath"));
                String pageName = parseNull(request.getParameter("pageName"));
                
                Set rsAddShortCut = Etn.execute("select * from shortcuts where site_id="+escape.cote(siteId)+" and created_by="+escape.cote(""+ Etn.getId())+
                    "and name="+escape.cote(pageName));
                if(rsAddShortCut.rs.Rows>0){
                    int i = Etn.executeCmd("delete from shortcuts where site_id="+escape.cote(siteId)+" and created_by="+escape.cote(""+ Etn.getId())+
                    "and name="+escape.cote(pageName));
                    
                    if(i>0){
                        message ="deleted";
                        status = STATUS_SUCCESS;
                    }
                }else{
                    rsAddShortCut = Etn.execute("select * from shortcuts where site_id="+escape.cote(siteId)+" and created_by="+escape.cote(""+ Etn.getId()));
                    if(rsAddShortCut.rs.Rows>=10){
                        message ="Error: Your shortcuts limit reached for this site.";
                        status = STATUS_ERROR;
                    }else{
                        int i = Etn.executeCmd("insert into shortcuts (name,url,created_by,site_id) values ("+escape.cote(pageName)+","+escape.cote(pagePath)+
                            ","+escape.cote(""+ Etn.getId())+","+escape.cote(siteId)+")");
                        
                        if(i>0){
                            message ="added";
                            status = STATUS_SUCCESS;
                        }else{
                            status = STATUS_ERROR;
                        }
                    }
                }
            }//try
            catch(Exception ex){
                throw new SimpleException("Error adding in shortcuts.",ex);
            }
        }

    }//try
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
