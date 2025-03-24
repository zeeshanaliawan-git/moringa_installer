<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, java.util.ArrayList, com.etn.asimina.util.ActivityLog"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>

<%!
    Boolean checkFolderBeforeDeletion(Contexte Etn,String id,String siteId){
        
        Set rs=Etn.execute("SELECT * FROM folders_tbl f1 JOIN folders_tbl f2 ON f1.name=f2.name and f1.site_id=f2.site_id and f1.parent_folder_id=f2.parent_folder_id and f2.is_deleted=1 WHERE f1.id="+escape.cote(id));
        if(rs.rs.Rows>0){
            return false;
        }

        rs=Etn.execute("select * from pages_tbl p1 join pages_tbl p2 on p1.name=p2.name and p1.site_id=p2.site_id and p1.folder_id=p2.folder_id and p2.is_deleted=1 where p1.folder_id="+escape.cote(id));
        if(rs.rs.Rows>0){
            return false;
        }

        rs=Etn.execute("select * from pages_tbl where (published_ts IS NOT NULL OR published_ts != '') and folder_id ="+escape.cote(id));
        if(rs.rs.Rows>0){
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
        Etn.executeCmd("update structured_contents_tbl set is_deleted='1',updated_by="+escape.cote(""+Etn.getId())+" WHERE folder_id = " + escape.cote(id));
        Etn.executeCmd("update freemarker_pages_tbl set is_deleted='1',updated_by="+escape.cote(""+Etn.getId())+" WHERE folder_id = " + escape.cote(id));
        Etn.executeCmd("update pages set is_deleted='1',updated_by="+escape.cote(""+Etn.getId())+" WHERE folder_id = " + escape.cote(id));

        Set rs = Etn.execute("select id from folders where parent_folder_id="+escape.cote(id));
        while(rs.next()){
            markFolderForDelete(Etn,parseNull(rs.value("id")),siteId);
        }
        Etn.executeCmd("update folders set is_deleted='1',updated_by="+escape.cote(""+Etn.getId())+" WHERE id = " + escape.cote(id));
        
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

    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();

    String q = "";
    Set rs = null;

    String siteId = getSiteId(session);

    try{

        String requestType = parseNull(request.getParameter("requestType"));
        String folderType = parseNull(request.getParameter("folderType"));

        final String folderTable = getFolderTableName(folderType);

        if("getPagePrefixPathsByFolderId".equalsIgnoreCase(requestType)){
            try{
                String folderId =  parseNull(request.getParameter("folderId"));

                data.put("pagePathPrefixList",getPagePrefixPathsByFolderId(Etn, folderId, siteId));
                status = STATUS_SUCCESS;
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting path prefixes.", ex);
            }
        } else if("getListForViews".equalsIgnoreCase(requestType)){
            try{
                q = "SELECT f.id AS id, f.name, f.folder_level  "
                    + " , CONCAT_WS('/', NULLIF(f3.name,''), NULLIF(f2.name,'')) as concat_path "
                    + " FROM " + folderTable + " f "
                    + " LEFT JOIN " + folderTable + " f2 ON f.parent_folder_id = f2.id "
                    + " LEFT JOIN " + folderTable + " f3 ON f2.parent_folder_id = f3.id "
                    + " WHERE f.folder_version='V1' and f.site_id = " + escape.cote(siteId)
                    + " ORDER BY concat_path, f.name, f.id";

                rs = Etn.execute(q);
                JSONArray foldersList = new JSONArray();
                while(rs.next()){
                    foldersList.put(getJSONObject(rs));
                }
                data.put("folders",foldersList);
                status = STATUS_SUCCESS;

            } catch(Exception ex){
                throw new SimpleException("Error in getting folders list for views.", ex);
            }
        } else if("getProductFoldersListForViews".equalsIgnoreCase(requestType)){
            try{
                String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");

                q = " SELECT * FROM ("
                    + " SELECT c.id, c.catalog_uuid AS uuid, c.name, c.catalog_type, '' AS concat_path "
	                + " FROM "+CATALOG_DB+".catalogs c"
                    + " WHERE c.site_id = " + escape.cote(siteId)
                    + " UNION ALL "
                    + " SELECT f.id, f.uuid, f.name, c.catalog_type, "
                    + " CONCAT_WS('/', NULLIF(c.name,''), NULLIF(f2.name,'')) as concat_path "
                    + " FROM "+CATALOG_DB+".products_folders f "
                    + " JOIN "+CATALOG_DB+".catalogs c ON c.id = f.catalog_id"
                    + " LEFT JOIN "+CATALOG_DB+".products_folders f2 ON f.parent_folder_id = f2.id "
                    + " WHERE f.site_id = " + escape.cote(siteId)
                    + " ) t "
                    + " ORDER BY catalog_type, concat_path, name, id ASC";

                rs = Etn.execute(q);
                JSONArray foldersList = new JSONArray();
                while(rs.next()){
                    foldersList.put(getJSONObject(rs));
                }
                data.put("folders",foldersList);
                status = STATUS_SUCCESS;

            } catch(Exception ex){
                throw new SimpleException("Error in getting folders list for views.", ex);
            }
        } else if("saveFolder".equalsIgnoreCase(requestType)){
            try{
                int id = parseInt(request.getParameter("id"), 0);
                String name = parseNull(request.getParameter("name"));

                String pageType = parseNull(request.getParameter("pageType"));
                String subLevel1 = parseNull(request.getParameter("subLevel1"));
                String subLevel2 = parseNull(request.getParameter("subLevel2"));
                String parentFolderUuid =  parseNull(request.getParameter("parentFolderUuid"));
                String parentFolderId = "0";

                String errorMsg = "";
                if(name.length() == 0) errorMsg = "Name cannot be empty";

                int parentFolderLevel = 0;
                // validate parent folder
                if(parentFolderUuid.length()>0){
                    q = "SELECT id, folder_level "
                        + " FROM " + folderTable
                        + " WHERE uuid = "+escape.cote(parentFolderUuid)+" AND site_id = "+escape.cote(siteId);
                    rs =  Etn.execute(q);
                    if(rs.next()){
                        parentFolderLevel = parseInt(rs.value("folder_level"));
                        parentFolderId = rs.value("id");
                    }else errorMsg = "Invalid parent folder";
                }
                if(parentFolderLevel > 3) errorMsg = "Folder Cannot be created at level 4";

                q = "SELECT id FROM " + folderTable
                    + " WHERE name = " + escape.cote(name)
                    + " AND site_id = " + escape.cote(siteId)
                    + " AND parent_folder_id = " + escape.cote(parentFolderId);
                if(id > 0) q += " AND id != " + escape.cote(""+id);

                rs = Etn.execute(q);
                if(rs.next()) errorMsg = "Name already exist. please specify different name.";

                if(errorMsg.length() > 0) message = errorMsg;
                else{
                    int pid = Etn.getId();

                    colValueHM.put("name", escape.cote(name));

                    colValueHM.put("dl_page_type", escape.cote(pageType));
                    colValueHM.put("dl_sub_level_1", escape.cote(subLevel1));
                    colValueHM.put("dl_sub_level_2", escape.cote(subLevel2));
                    
                    colValueHM.put("updated_ts", "NOW()");
                    colValueHM.put("updated_by", escape.cote(""+pid));

                    if(id <= 0){
                        //new
                        colValueHM.put("type", escape.cote(folderType));
                        colValueHM.put("site_id", escape.cote(siteId));
                        colValueHM.put("parent_folder_id", escape.cote(parentFolderId));
                        colValueHM.put("folder_level", escape.cote(""+( 1+parentFolderLevel )));
                        colValueHM.put("created_by", escape.cote(""+pid));
                        colValueHM.put("created_ts", "NOW()");

                        q = getInsertQuery(folderTable, colValueHM);
                        id = Etn.executeCmd(q);

                        if(id <= 0) message = "Error in creating folder. Please try again.";
                        else{
                            status = STATUS_SUCCESS;
                            message = "Folder created.";
                            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id+"","CREATED",folderType + " folder",name,siteId);
                            data.put("id", id);
							//we have to call partoo api for store folders
							if("stores".equals(folderType)) Etn.executeCmd("insert into partoo_publish (cid, ctype, site_id) values ("+escape.cote(""+id)+", 'folder', "+escape.cote(siteId)+")");
                        }
                    } else{
                        //existing update
                        q = getUpdateQuery(folderTable, colValueHM, " WHERE id = " + escape.cote(""+id) );
                        int count = Etn.executeCmd(q);

                        if(count <= 0) message = "Error in updating folder. Please try again.";
                        else{
                            markPagesToGenerate(""+id, folderType,Etn);

                            status = STATUS_SUCCESS;
                            message = "Folder updated.";
                            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id+"","UPDATED",folderType + " folder",name,siteId);
                            data.put("id", id);
							
							//we have to call partoo api for store folders
							if("stores".equals(folderType)) Etn.executeCmd("insert into partoo_publish (cid, ctype, site_id) values ("+escape.cote(""+id)+", 'folder', "+escape.cote(siteId)+")");
                        }
                    }

                    if(status == STATUS_SUCCESS && !folderType.equals(Constant.FOLDER_TYPE_CONTENTS) ){
                        // lang details are not for structured_contents
                        List<Language> langsList = getLangs(Etn,session);
                        colValueHM.clear();
                        colValueHM.put("folder_id", escape.cote(""+id));
                        for(Language curLang : langsList){
                            String curPathPrefix = parseNull(request.getParameter("path_prefix_"+curLang.getLanguageId()));

                            colValueHM.put("langue_id", escape.cote(curLang.getLanguageId()));
                            colValueHM.put("path_prefix", escape.cote(curPathPrefix));
                            q = getInsertQuery("folders_details",colValueHM);
                            q += " ON DUPLICATE KEY UPDATE path_prefix=VALUES(path_prefix)";
                            Etn.executeCmd(q);
                        }
                    }
                }
            } catch(Exception ex){
                throw new SimpleException("Error in saving folder. Please try again.",ex);
            }
        } else if("getFolderInfo".equalsIgnoreCase(requestType)){
            try{
                String id = parseNull(request.getParameter("id"));

                JSONObject retJson = new JSONObject();

                q = "SELECT * FROM " + folderTable
                    + " WHERE id = " + escape.cote(id)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if(rs.next()){
                    for(String colName : rs.ColName){
                        retJson.put(colName.toLowerCase(), rs.value(colName));
                    }

                    JSONObject pathPrefixJson = new JSONObject();

                    if( !folderType.equals(Constant.FOLDER_TYPE_CONTENTS) ){
                        q = "SELECT * FROM folders_details "
                            + " WHERE folder_id = " + escape.cote(id);
                        rs = Etn.execute(q);
                        while(rs.next()){
                            pathPrefixJson.put(rs.value("langue_id"), rs.value("path_prefix"));
                        }
                    }

                    retJson.put("path_prefix", pathPrefixJson);

                    data.put("folder",retJson);
                    status = STATUS_SUCCESS;
                } else message = "Error folder not found.";

            } catch(Exception ex){
                throw new SimpleException("Error in getting folder info.", ex);
            }
        } else if("copyFolder".equalsIgnoreCase(requestType)){
            try{
                String id =  parseNull(request.getParameter("id"));
                String name =  parseNull(request.getParameter("name"));
                if(id.length() == 0){
                    throw new SimpleException("Invalid folder id.");
                }

                rs = Etn.execute("SELECT folder_level, parent_folder_id "
                    + " FROM " + folderTable
                    + " WHERE id = " + escape.cote(id)
                    + " AND site_id = " + escape.cote(siteId));

                if(rs.next()){
                    q = "SELECT id FROM " + folderTable
                        + " WHERE name = " + escape.cote(name)
                        + " AND site_id = " + escape.cote(siteId)
                        + " AND parent_folder_id = " + escape.cote(rs.value("parent_folder_id"));

                    Set rsName = Etn.execute(q);
                    if(rsName.next()){
                        throw new SimpleException("Name already exist. please specify different name.");
                    }

                    colValueHM.put("name", escape.cote(name));
                    colValueHM.put("updated_ts", "NOW()");
                    colValueHM.put("updated_by", escape.cote(""+Etn.getId()));
                    colValueHM.put("type", escape.cote(folderType));
                    colValueHM.put("site_id", escape.cote(siteId));
                    colValueHM.put("parent_folder_id", escape.cote(rs.value("parent_folder_id")));
                    colValueHM.put("folder_level", escape.cote(rs.value("folder_level")));
                    colValueHM.put("created_by", escape.cote(""+Etn.getId()));
                    colValueHM.put("created_ts", "NOW()");

                    q = getInsertQuery(folderTable,colValueHM);
                    int newFolderId =  Etn.executeCmd(q);

                    if( newFolderId <= 0 ){
                        throw new SimpleException("Error in copying folder.");
                    } else {
                        if( !folderType.equals(Constant.FOLDER_TYPE_CONTENTS) ){

                            q = " INSERT IGNORE INTO folders_details(folder_id, langue_id, path_prefix) "
                                + " SELECT "+ escape.cote("" + newFolderId)+" AS folder_id , langue_id, path_prefix "
                                + " FROM  folders_details "
                                + " WHERE folder_id = " + escape.cote(id);
                            Etn.executeCmd(q);
                        }
                        status = STATUS_SUCCESS;
                        message = "Folder copied.";
                        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),newFolderId+"",
                            "COPIED", folderType + " folder ",name,siteId);
                        data.put("id", newFolderId);
                    }
                }else{
                    throw new SimpleException("Folder id is invalid.");
                }
            } catch(Exception ex){
                throw new SimpleException("Error in copying folders.",ex);
            }
        } else if("deleteFolders".equalsIgnoreCase(requestType)){
            try{
                String[] folderIds= request.getParameterValues("ids");

                int totalCount = folderIds.length;
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                int deleteCount = 0;
                String cids = "";
                String cnames = "";
                for(String curFolderId : folderIds){
                    String curName = "";
                    q = " SELECT name "
                        + " FROM " + folderTable
                        + " WHERE id = " + escape.cote(curFolderId)
                        + " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);

                    if(rs.next()) curName = rs.value("name");

                    boolean isFolderDeleted = deleteFolders(Etn, curFolderId, siteId);
                    if(isFolderDeleted){
                        cids += curFolderId + ",";
                        cnames += curName + ", ";
                        deleteCount += 1;
						
						//we have to call partoo api for store folders
						if("stores".equals(folderType)) Etn.executeCmd("insert into partoo_publish (cid, ctype, site_id) values ("+escape.cote(curFolderId)+", 'folder', "+escape.cote(siteId)+")");
                    }
                }

                if(totalCount == 1){
                    if(deleteCount != 1){
                        throw new SimpleException("Can not delete folder reasons could be: <br>1.It has published page.<br>2.Same folder is present in trash.");
                    } else{
                        status = STATUS_SUCCESS;
                        message = "Folder deleted";
                    }
                } else{
                    status = STATUS_SUCCESS;
                    message = deleteCount + " of " + totalCount + " folders deleted";
                    if(deleteCount < totalCount){
                        message += ". Non empty folders not deleted.";
                    }
                }
                if(status == STATUS_SUCCESS) ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),cids,"DELETED",folderType +" folder",cnames,siteId);

            } catch(Exception ex){
                throw new SimpleException("Error in deleting folders.",ex);
            }
        }

    } catch(SimpleException ex){
        message = ex.getMessage();
        ex.print();
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
    out.write(jsonResponse.toString());
%>
