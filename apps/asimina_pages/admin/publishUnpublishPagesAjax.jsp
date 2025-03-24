<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, java.util.ArrayList, com.etn.asimina.util.ActivityLog,com.etn.asimina.util.FileUtil"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/fileMethods.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%!
    JSONObject publishUnpublishPages(Contexte Etn, HttpServletRequest request, String pagesData, String siteId,
                                        String publishTimeStr, boolean isPublish, String folderType) throws SimpleException{
        int STATUS_SUCCESS = 1, STATUS_ERROR = 0;
        
        int status = STATUS_ERROR;
        String message = "";
        String itemType = "page";
        
        if(folderType.equals(Constant.FOLDER_TYPE_STORE)) itemType = "store";
        try{
            JSONArray pages = new JSONArray(pagesData);
            String date = "";
            String publishTime = ""; //default
            boolean isPublishNow = false;

            String publishType = "unpublish";
            if(isPublish) publishType = "publish";

            if(publishTimeStr.equalsIgnoreCase("now")){
                publishTime = "NOW()";
                isPublishNow = true;
                date = "";
            } else {
                //parse publish date time to standard format
                publishTime = convertDateTimeToStandardFormat(publishTimeStr, "yyyy-MM-dd HH:mm");

                if(publishTime.length() == 0) throw new Exception("Error: Invalid "+publishType+" on time");
                date = " for "+publishTime;
                publishTime = escape.cote(publishTime);
            }

            ArrayList<String> blocPageIds = new ArrayList<>();
            ArrayList<String> reactPageIds = new ArrayList<>();
            ArrayList<String> structuredPageIds = new ArrayList<>();

            String logNames = "";
            String logIds = "";
            int totalCount = pages.length();
            String lastPageType = "";
            String publishRsp = "";

            for(Object object : pages){
                JSONObject page = (JSONObject)object;
                String type = page.optString("type");
                String table = "freemarker_pages";
                int id = parseInt(page.optString("id","0"));

                if(type.equals(Constant.PAGE_TYPE_STRUCTURED)) table = "structured_contents";
                else if(type.equals(Constant.PAGE_TYPE_REACT)) table = "pages";

                if(id > 0){
                    String q = " SELECT id, name";
                    if(table.equals("structured_contents")) q+=", structured_version ";
                    q+= " FROM "+table+" WHERE id = " + escape.cote(""+id)+" AND site_id = " + escape.cote(siteId);

                    if(table.equals("freemarker_pages")) q += " AND  is_deleted = '0'";

                    Set rs = Etn.execute(q);
                    if(rs.next()){
                        if(type.equals(Constant.PAGE_TYPE_STRUCTURED)){
                            if(rs.value("structured_version").equalsIgnoreCase("v2")) {
                                publishRsp = publishUnpublishCatalogAndProduct(Etn, id+"",isPublish?"publish":"delete","-1");
                                itemType="product";
                            } else structuredPageIds.add(""+id);

                        } else if(type.equals(Constant.PAGE_TYPE_REACT)) reactPageIds.add(""+id);
                        else blocPageIds.add(""+id);

                        logIds += id+", ";
                        logNames += parseNull(rs.value("name")) + ", ";
                    }
                }
                lastPageType = type;
            }

            int pid = Etn.getId();
            if(itemType=="product"){
                if(publishRsp.length()>0) message = "Something went wrong while publishing";
                else {
                    status = STATUS_SUCCESS;
                    message = "Product marked for published";
                }
            }else{
                if(reactPageIds.size() + blocPageIds.size() + structuredPageIds.size() == 0) message = "Error: No valid "+itemType+" ids found";
                else {
                    if(structuredPageIds.size()>0) publishUnpublishValidPages(Etn, Constant.PAGE_TYPE_STRUCTURED, structuredPageIds, publishTime, isPublish, itemType);
                    if(blocPageIds.size()>0) publishUnpublishValidPages(Etn, Constant.PAGE_TYPE_FREEMARKER, blocPageIds, publishTime, isPublish, itemType);
                    if(reactPageIds.size()>0) publishUnpublishValidPages(Etn, Constant.PAGE_TYPE_REACT, reactPageIds, publishTime, isPublish, itemType);

                    message = reactPageIds.size() + blocPageIds.size() + structuredPageIds.size() + " " +itemType+"(s) marked for "+publishType+"ing .";
                    status = STATUS_SUCCESS;
                }
            }
            String q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("SEMAPHORE"))) + ")";
            Etn.execute(q);

            String logAction = "UNPUBLISHED";
            if(isPublish){
                logAction = "PUBLISHED";
            }
            if(status == STATUS_SUCCESS){
                ActivityLog.addLog(Etn, request, parseNull(request.getSession().getAttribute("LOGIN")),
                 logIds, logAction, capitalizeFirstLetter(itemType)+"s "+date, logNames, siteId);
            }
        }//try
        catch(Exception ex){
            throw new SimpleException("Error in publishing "+itemType+"(s). Please try again.",ex);
        }
        JSONObject resObject = new JSONObject();
        resObject.put("status", status);
        resObject.put("message", message);
        return resObject;
    }


    boolean publishUnpublishValidPages(Contexte Etn,String type, List<String> ids, String publishTime,
                                        Boolean toPublish, String itemType) throws SimpleException{
        String tableName = "freemarker_pages";
        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();

        String whereClause = " WHERE  id IN (" + convertArrayToCommaSeperated(ids.toArray(), escape::cote) + " ) ";
        if(type.equals(Constant.PAGE_TYPE_STRUCTURED)){
            tableName = "structured_contents";
        } else if(type.equals(Constant.PAGE_TYPE_REACT)){
            tableName = "pages";
        } else {
            whereClause += "AND is_deleted = '0'";
        }

        try{
            if(toPublish){
                colValueHM.put("to_publish",escape.cote("1"));
                colValueHM.put("to_publish_by",escape.cote(""+Etn.getId()));
                colValueHM.put("to_publish_ts", publishTime);
            }else{
                colValueHM.put("to_unpublish",escape.cote("1"));
                colValueHM.put("to_unpublish_by",escape.cote(""+Etn.getId()));
                colValueHM.put("to_unpublish_ts", publishTime);
            }
            colValueHM.put("publish_status",escape.cote("queued"));
            colValueHM.put("publish_log",escape.cote("queued"));

            String q = getUpdateQuery(tableName, colValueHM, whereClause );
            Etn.executeCmd(q);

            return true;

        }
        catch(Exception ex){
            ex.printStackTrace();
            if(toPublish){
                throw new SimpleException("Error publishing "+itemType+"s.");
            } else {
                throw new SimpleException("Error unpublishing "+itemType+"s.");
            }
        }
    }

    public void moveToDelete(String htmlFilePathSource,String htmlFilePathDestination){
        try {

            File sourceFile = FileUtil.getFile(htmlFilePathSource);//change
            File destinationFolder = FileUtil.getFile(htmlFilePathDestination);//change

            if (!sourceFile.exists()) {
                System.out.println("Source file does not exist");
            } else {
                if (!destinationFolder.exists()) {
					//we are safe to use this as FileUtil.getFile is already fixing the path
					destinationFolder.mkdirs();
                }
                
                File destinationFile = FileUtil.getFile(htmlFilePathDestination + sourceFile.getName());
                
                sourceFile.renameTo(destinationFile);

                File htmlFile = FileUtil.getFile(htmlFilePathSource);//change
                if (htmlFile.exists()) {
                    htmlFile.delete();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public void movePageToDeleteFolder(Contexte Etn,String pageId) {

        String q = " SELECT html_file_path, published_html_file_path"
                   + " FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tbl "
                   + " WHERE id = " + escape.cote(pageId);
        Set rs = Etn.execute(q);
        if (!rs.next()) {
            return;
        }
        String pageHtmlPath = parseNull(rs.value("html_file_path"));
        String publishedHtmlPath = parseNull(rs.value("published_html_file_path"));

        String BASE_DIR = GlobalParm.getParm("BASE_DIR");
        String PAGES_SAVE_FOLDER = GlobalParm.getParm("PAGES_SAVE_FOLDER");
        String PAGES_PUBLISH_FOLDER = GlobalParm.getParm("PAGES_PUBLISH_FOLDER");

        if (pageHtmlPath.length() > 0) {
            String htmlFilePathSource = BASE_DIR + PAGES_SAVE_FOLDER + pageHtmlPath;
            String htmlFilePathDestination = BASE_DIR + "delete/" + PAGES_SAVE_FOLDER + pageHtmlPath.substring(0, pageHtmlPath.lastIndexOf("/")+1);
            moveToDelete(htmlFilePathSource,htmlFilePathDestination);
        }

        if (publishedHtmlPath.length() > 0) {
            String htmlFilePathSource = BASE_DIR + PAGES_PUBLISH_FOLDER + publishedHtmlPath;
            String htmlFilePathDestination = BASE_DIR + "delete/" + PAGES_PUBLISH_FOLDER + publishedHtmlPath.substring(0, publishedHtmlPath.lastIndexOf("/")+1);

            File sourceFile = FileUtil.getFile(htmlFilePathSource);//change
            File destinationFolder = FileUtil.getFile(htmlFilePathDestination);//change

            moveToDelete(htmlFilePathSource,htmlFilePathDestination);
        }

    }

    boolean deleteBlocPage(Contexte Etn, String id, String siteId, String itemType){

        Set rs=Etn.execute("select id from freemarker_pages_tbl where name = (select name from freemarker_pages_tbl where id="+escape.cote(id)+
        ") and folder_id = (select folder_id from freemarker_pages_tbl where id="+escape.cote(id)+") and id !="+escape.cote(id)
            +"  AND site_id = "+escape.cote(siteId));
        
        if(rs.rs.Rows>0){
            return false;
        }else{
            rs = Etn.execute("select * from freemarker_pages where COALESCE(published_ts,'')='' and id="+escape.cote(id));
            if(rs.next()){
                rs=Etn.execute("select id from pages where type='freemarker' and parent_page_id="+escape.cote(id));
                while(rs.next()){
                    movePageToDeleteFolder(Etn,rs.value("id"));
                }

                Etn.executeCmd("update pages set updated_ts = now(), updated_by= "+escape.cote(""+Etn.getId())+", deleted_by = "+escape.cote(""+Etn.getId())+", is_deleted='1' where type='freemarker' and parent_page_id="+escape.cote(id));
                Etn.executeCmd("update freemarker_pages_tbl set updated_ts = now(), updated_by= "+escape.cote(""+Etn.getId())+", deleted_by = "+escape.cote(""+Etn.getId())+", is_deleted='1' WHERE id = " + escape.cote(id)+" AND site_id = "+escape.cote(siteId) );
                return true;
            }else{
                return false;
            }
        }

    }

    boolean deleteReactPage(Contexte Etn, String id, String siteId, String itemType){

        Set rs=Etn.execute("select id from pages_tbl where name = (select name from pages_tbl where id="+escape.cote(id)+
        ") and folder_id=(select folder_id from pages_tbl where id="+escape.cote(id)+") and id !="+escape.cote(id)+" AND site_id = "+escape.cote(siteId));
        
        if(rs.rs.Rows>0){
            return false;
        }else{

            rs = Etn.execute("select * from pages where COALESCE(published_ts,'')='' and id="+escape.cote(id));
            if(rs.next()){
                rs=Etn.execute("select id from pages where type='freemarker' and parent_page_id="+escape.cote(id));
                while(rs.next()){
                    movePageToDeleteFolder(Etn,rs.value("id"));
                }

                Etn.executeCmd("update pages set updated_ts = now(), updated_by= "+escape.cote(""+Etn.getId())+", deleted_by = "+escape.cote(""+Etn.getId())+", is_deleted='1' where id="+escape.cote(id));

                return true;
            }else{
                return false;
            }
        }
    }


    boolean deleteStructuredPage(Contexte Etn, String id, String siteId, String itemType){

        Set rs=Etn.execute("select id from structured_contents_tbl where name = (select name from structured_contents_tbl where id="+escape.cote(id)+") and id !="+escape.cote(id)
            +" AND folder_id=(select folder_id from structured_contents_tbl where id="+escape.cote(id)+") and type = (select type from structured_contents_tbl where id="+escape.cote(id)+") and site_id = "+escape.cote(siteId));
        
        if(rs.rs.Rows>0){
            return false;
        }else{
            rs = Etn.execute("select * from structured_contents where COALESCE(published_ts,'')='' and id="+escape.cote(id));
            if(rs.next()){
                rs=Etn.execute("select id from pages where type='structured' and parent_page_id="+escape.cote(id));
                while(rs.next()){
                    movePageToDeleteFolder(Etn,rs.value("id"));
                }

                Etn.executeCmd("update pages set updated_ts = now(), updated_by= "+escape.cote(""+Etn.getId())+", deleted_by = "+escape.cote(""+Etn.getId())+", is_deleted='1' where type='structured' and parent_page_id="+escape.cote(id));
                Etn.executeCmd("update structured_contents_tbl set updated_ts = now(), updated_by= "+escape.cote(""+Etn.getId())+", deleted_by = "+escape.cote(""+Etn.getId())+", is_deleted='1' WHERE id = " + escape.cote(id));

                return true;
            }else{
                return false;
            }
        }

    }


    Boolean checkFolderBeforeDeletion(Contexte Etn,String id,String siteId){

        Set rs=Etn.execute("SELECT * FROM folders_tbl f1 JOIN folders_tbl f2 ON f1.name=f2.name and f1.site_id=f2.site_id and f1.parent_folder_id=f2.parent_folder_id and f2.is_deleted=1 WHERE f1.id="+escape.cote(id));
        if(rs.rs.Rows>0){
            System.out.println("first condition");
            return false;
        }


        /*rs=Etn.execute("Select * from pages_folders where parent_folder_id ="+escape.cote(id)+" and site_id ="+escape.cote(siteId));
        if(rs.rs.Rows>0){
            return false;
        }*/


        rs=Etn.execute("select * from pages_tbl p1 join pages_tbl p2 on p1.name=p2.name and p1.site_id=p2.site_id and p1.folder_id=p2.folder_id and p2.is_deleted=1 where p1.is_deleted=0 and p1.folder_id="+escape.cote(id));
        if(rs.rs.Rows>0){
            System.out.println("second condition");
            return false;
        }

        /*rs=Etn.execute("select * from pages_tbl where (published_ts IS NOT NULL OR published_ts != '') and folder_id ="+escape.cote(id));
        if(rs.rs.Rows>0){
            return false;
        }*/

        rs=Etn.execute("select * from pages where (published_ts IS NOT NULL OR published_ts != '') and folder_id ="+escape.cote(id));
        if(rs.rs.Rows>0){
            System.out.println("third condition");
            return false;
        }


        rs=Etn.execute("select * from pages where (publish_status ='published') and folder_id ="+escape.cote(id));
        if(rs.rs.Rows>0){
            System.out.println("forth condition");
            return false;
        }


        rs = Etn.execute("select id from folders where parent_folder_id="+escape.cote(id));
        while(rs.next()){
            Boolean resp = checkFolderBeforeDeletion(Etn,parseNull(rs.value("id")),siteId);
            if(resp !=null && !resp){
                return false;
            }
        }
        return null;
        
    }

    void markFolderForDelete(Contexte Etn,String id,String siteId){

        Set rs =Etn.execute("select id from structured_contents WHERE folder_id = " + escape.cote(id));
        while(rs.next()){
            deleteStructuredPage(Etn,rs.value("id"),siteId,"");
        }
        
        rs =Etn.execute("select id from freemarker_pages WHERE folder_id = " + escape.cote(id));
        while(rs.next()){
            deleteBlocPage(Etn,rs.value("id"),siteId,"");
        }
        
        rs =Etn.execute("select id from pages WHERE folder_id = " + escape.cote(id));
        while(rs.next()){
            deleteReactPage(Etn,rs.value("id"),siteId,"");
        }

        rs = Etn.execute("select id from folders where parent_folder_id="+escape.cote(id));
        while(rs.next()){
            markFolderForDelete(Etn,parseNull(rs.value("id")),siteId);
        }
        Etn.executeCmd("update folders set is_deleted='1', updated_ts=now(), updated_by= "+escape.cote(""+Etn.getId())+", deleted_by="+escape.cote(""+Etn.getId())+" WHERE id = " + escape.cote(id));
        
    }

    boolean deleteFolders(Contexte Etn, String id, String siteId) throws SimpleException{

        Boolean isValidFolder = checkFolderBeforeDeletion(Etn,id,siteId);
        if(isValidFolder==null){
            markFolderForDelete(Etn,id,siteId);
            return true;
        }else{
            return false;
        }
    }

%>
<%
    int STATUS_SUCCESS = 1;
    int STATUS_ERROR = 0;
    int status = STATUS_ERROR;
    String message = "";
    String PAGE = "page";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();

    String q = "";
    Set rs = null;

    String siteId = getSiteId(session);
    // item type is just display message on front end according to type of item
    String itemType = "page";
    String folderType = parseNull(request.getParameter("folderType"));
    if(folderType.equals(Constant.FOLDER_TYPE_STORE)){
        itemType = "store";
    }

    try{
        String requestType = parseNull(request.getParameter("requestType"));
        if("deletePages".equalsIgnoreCase(requestType)){
            // delete folder, structuredPage , page
            try{
                String pagesData = parseNull(request.getParameter("pages"));

                JSONArray pages = new JSONArray(pagesData);

                int totalCount = pages.length();

                if(totalCount == 0){
                    throw new SimpleException("Error: No id found");
                }

                int deletePageCount = 0;
                int deleteFolderCount = 0;

                String deletedPageIds = "";
                String deletedPageNames = "";

                String deletedStructurePageIds = "";
                String deletedStructurePageNames = "";

                String deletedFolderIds = "";
                String deletedFolderNames = "";

                String type = "";

                for(Object obj : pages){
                    JSONObject pageObj  = (JSONObject)obj;
                    String id = pageObj.optString("id","-1");
                    type = pageObj.optString("type");
                    boolean isDeleted = false;
                    String name = getPageName(Etn, id, type);

                    if(type.equals("folder")){
                        isDeleted = deleteFolders(Etn ,id, siteId);
                        
                    } else if(type.equals(Constant.PAGE_TYPE_STRUCTURED)){
                        isDeleted = deleteStructuredPage(Etn , id, siteId, itemType);
                    } else if(type.equals(Constant.PAGE_TYPE_FREEMARKER)){
                        isDeleted = deleteBlocPage(Etn, id, siteId, itemType);
                    } else if(type.equals(Constant.PAGE_TYPE_REACT)){
                        isDeleted = deleteReactPage(Etn, id, siteId, itemType);
                    }

                    if(isDeleted){
                        if(type.equals("folder")){
                            deleteFolderCount += 1;
                            deletedFolderIds += id+", ";
                            deletedFolderNames += name+", ";
                        } else if(type.equals(Constant.PAGE_TYPE_FREEMARKER) || type.equals(Constant.PAGE_TYPE_REACT)){
                            deletePageCount += 1;
                            deletedPageIds += id+", ";
                            deletedPageNames += name+", ";
                        } else if(type.equals(Constant.PAGE_TYPE_STRUCTURED)){
                            deletePageCount += 1;
                            deletedStructurePageIds += id+", ";
                            deletedStructurePageNames += name+", ";
                        }
                    }
                }

                if(totalCount == 1){
                    if(type.equals("folder")){
                        System.out.println("delete folder count ====> "+deleteFolderCount);
                        if(deleteFolderCount != 1){
                            throw new SimpleException("Cannot delete this folder.");
                        } else {
                            status = STATUS_SUCCESS;
                            message = "Folder deleted";
                        }
                    } else if(type.equals(Constant.PAGE_TYPE_FREEMARKER) || type.equals(Constant.PAGE_TYPE_STRUCTURED) || type.equals(Constant.PAGE_TYPE_REACT)){
                        if(deletePageCount != 1){
                            throw new SimpleException("Cannot delete "+itemType+". Duplicate entry in trash.");
                        } else {
                            status = STATUS_SUCCESS;
                            message = capitalizeFirstLetter(itemType)+" deleted";
                        }
                    }
                }
                else {
                    status = STATUS_SUCCESS;
                    if(deletePageCount > 0){
                        message = deletePageCount + " "+itemType+"s";
                    }
                    if(deleteFolderCount > 0){
                        if(message.length()>0){
                            message += " and ";
                        }
                        message += deleteFolderCount + " folders";
                    }
                    if(message.length()>0){
                        message += " deleted";
                    }
                    if(deletePageCount + deleteFolderCount < totalCount){
                        message += ". Published "+itemType+"s and non emtpy folders not deleted.";
                    }
                }
                //logs
                if (status == STATUS_SUCCESS) {
                    if(deletedFolderIds.length()>0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),
                         deletedFolderIds, "DELETED", capitalizeFirstLetter(itemType)+" Folder", deletedFolderNames, siteId);
                    }
                    if(deletedStructurePageIds.length()>0){
                        String loggedItem = "Structured Pages";
                        if(folderType.equals(Constant.FOLDER_TYPE_STORE)){
                            loggedItem = "Stores";
                        }
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),
                         deletedStructurePageIds, "DELETED", loggedItem , deletedStructurePageNames, siteId);
                    }
                    if(deletedPageIds.length()>0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),
                         deletedPageIds, "DELETED", "Pages", deletedPageNames, siteId);
                    }
                }
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting "+itemType+"s and folders. Please try again.",ex);
            }
        }
        else if("publishPages".equalsIgnoreCase(requestType)){
            String pagesData = parseNull(request.getParameter("pages"));
            String publishTimeStr = parseNull(request.getParameter("publishTime"));

            JSONObject responseObj =  publishUnpublishPages(Etn, request, pagesData, siteId, publishTimeStr, true, folderType);
            status = responseObj.getInt("status");
            message = responseObj.getString("message");
        }
        else if("unpublishPages".equalsIgnoreCase(requestType)){
            String pagesData = parseNull(request.getParameter("pages"));
            String publishTimeStr = parseNull(request.getParameter("publishTime"));

            JSONObject responseObj = publishUnpublishPages(Etn, request, pagesData, siteId, publishTimeStr, false, folderType);
            status = responseObj.getInt("status");
            message = responseObj.getString("message");
        }
        else if("deleteFolders".equalsIgnoreCase(requestType)){
            String folders = parseNull(request.getParameter("folders"));
            System.out.println("folders ============>"+folders);
            boolean isDeleted = deleteFolders(Etn ,folders, siteId);
            if(isDeleted==false){
                status=STATUS_ERROR;
                message="Can not delete folder reasons could be: <br>1.It has published page.<br>2.Same folder is present in trash.";
            }else{

                status=STATUS_SUCCESS;
                message = "Folder deleted successfully.";
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
