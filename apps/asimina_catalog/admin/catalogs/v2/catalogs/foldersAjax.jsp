<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, java.util.ArrayList, java.util.List, com.etn.asimina.util.ActivityLog"%>
<%@ page import="com.etn.asimina.data.LanguageFactory"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../../../common.jsp"%>
<%!

    int parseNullInt(Object o)
    {
        if (o == null) return 0;
        String s = o.toString();
        if (s.equals("null")) return 0;
        if (s.equals("")) return 0;
        return Integer.parseInt(s);
    }

    int insertCatalogAttribute(Contexte Etn, String oldCatalogId, String newCatalogId)
    {
        String insertionQry = " insert into catalog_attribute_values(cat_attrib_id,attribute_value,small_text,color,sort_order) "
        +"select abcd.cat_attrib_id, abcd.attribute_value, abcd.small_text, abcd.color, abcd.sort_order "
        +"from(SELECT abc.cat_attrib_id, abc.attribute_value, abc.small_text, abc.color, abc.sort_order, abc.name "
        +"FROM (SELECT b.cat_attrib_id,b.name, a.attribute_value, a.small_text, a.color, a.sort_order  "
        +"FROM (SELECT cav.*,ca.name  "
        +"FROM catalog_attribute_values cav  "
        +"JOIN catalog_attributes ca ON cav.cat_attrib_id = ca.cat_attrib_id  "
        +"WHERE ca.catalog_id = "+escape.cote(oldCatalogId)+") a  "
        +"JOIN (SELECT cav1.*, ca1.name  "
        +"FROM catalog_attribute_values cav1  "
        +"JOIN catalog_attributes ca1 ON cav1.cat_attrib_id = ca1.cat_attrib_id  "
        +"WHERE ca1.catalog_id = "+escape.cote(newCatalogId)+") b "
        +"ON a.name = b.name) abc "
        +"JOIN catalog_attributes ca3 "
        +"ON abc.name = ca3.name "
        +"WHERE abc.attribute_value NOT IN ( "
        +"SELECT cav4.attribute_value "
        +"FROM catalog_attribute_values cav4  "
        +"JOIN catalog_attributes ca4 ON cav4.cat_attrib_id = ca4.cat_attrib_id  "
        +"WHERE ca4.catalog_id = "+escape.cote(newCatalogId)+")) abcd ";
        return Etn.executeCmd(insertionQry);
    }

    int insertNewProductAttributeValue(Contexte Etn,String product_id, String newCatalogId) {
        String deleteQry = "DELETE FROM product_variant_ref where product_variant_id in (select id from product_variants where product_id="+escape.cote(product_id)+")";
        Etn.execute(deleteQry);
        String insertQry = "Insert into product_variant_ref(cat_attrib_id,product_variant_id,catalog_attribute_value_id) "
                           + "Select cat_attrib_id,(select id from product_variants where product_id="+escape.cote(product_id)+"),'0' from catalog_attributes where catalog_id="+escape.cote(newCatalogId);
        return Etn.executeCmd(insertQry);
    }

    JSONObject moveProduct(Contexte Etn, List<Language> langsList,String id, String moveToFolderId, String moveToCatalogId, String siteId,String pagesDb){
        boolean status = true;
        String message = "Error in moving product";
        String q = "";
        Set rs = null;
        String folderId = "0";
        String catalogId = "0";
        boolean isSameCatalog = false;

        q = "SELECT catalog_id, folder_id FROM products WHERE id = "+escape.cote(id);
        rs = Etn.execute(q);

        if(rs.next()){
            folderId = rs.value("folder_id");
            catalogId  = rs.value("catalog_id");
        }

        if(catalogId.equalsIgnoreCase(moveToCatalogId)) isSameCatalog = true;

        for(Language curLang : langsList){
            String langId = ""+curLang.getLanguageId();
            // duplicate name check
            q = "SELECT id "
                +" FROM products"
                +" WHERE folder_id = "+escape.cote(moveToFolderId)
                +" AND catalog_id = "+escape.cote(moveToCatalogId)
                +" AND lang_"+langId+"_name != '' "
                +" AND lang_"+langId+"_name = ( SELECT lang_"+langId+"_name FROM products WHERE id = "+escape.cote(id)+" )";

            rs = Etn.execute(q);
            if(rs.next()){
                status = false;
                message = "Product with this name already exists for langue "+curLang.getCode();
                break;
            }

            // check path uniquness
            q = "SELECT p.id, p.lang_"+langId+"_name as name FROM products p"
                +" JOIN product_descriptions pd ON pd.product_id = p.id"
                +" WHERE p.folder_id = "+escape.cote(moveToFolderId)
                +" AND p.catalog_id = "+escape.cote(moveToCatalogId)
                +" AND pd.page_path != '' "
                +" AND pd.page_path = "
                +"   ("
                +"      SELECT page_path FROM product_descriptions"
                +"      WHERE product_id = "+escape.cote(id)
                +"      AND langue_id = "+escape.cote(langId)
                +"   )";
            
            rs = Etn.execute(q);
            if(rs.next()){
                status = false;
                message = "Path conflict with product "+rs.value("name");
                break;
            }
        }

        if(status){
            String newPath = getFolderNewPrefixPath(Etn,moveToFolderId,id,"product");
            boolean isDuplicateUrl = isProductPagePathUnique(Etn,id,newPath,siteId,pagesDb,"product");
            if(!isDuplicateUrl){
                q = "UPDATE products SET folder_id = "+escape.cote(moveToFolderId) +", catalog_id = "+escape.cote(moveToCatalogId)
                    +", updated_by = "+escape.cote(""+Etn.getId())
                    +", version = version + 1"
                    +", updated_on = NOW()"
                    +"  WHERE id = "+escape.cote(id);
                if(Etn.executeCmd(q) == 0) status = false;
                else{
                    Set prV2Id = Etn.execute("select product_definition_id from products where id="+escape.cote(id));
                    prV2Id.next();
                    Etn.executeCmd("update products_definition set folder_id="+escape.cote(moveToFolderId)+" where id="+escape.cote(prV2Id.value("product_definition_id")));
                    updateProductPagePath(Etn,prV2Id.value("product_definition_id"),newPath,siteId,pagesDb,"product");
                }
            }else{
                status=false;
                message="Product can't be moved as there will be duplicated url.";
            }
        }
        JSONObject retObject = new JSONObject();
        retObject.put("status", status);
        retObject.put("message", message);
        return retObject;
    }

    String getFolderNewPrefixPath(Contexte Etn, String moveToFolderId,String id,String type){
        String path="";
        Set rsParenFolder = Etn.execute("select pf.parent_folder_id,pfd.path_prefix from products_folders pf left join products_folders_details pfd on pfd.folder_id=pf.id where pf.id="+
            escape.cote(moveToFolderId)+" limit 1");
        if(rsParenFolder.next() && !rsParenFolder.value("parent_folder_id").equals("0")) path = getFolderNewPrefixPath(Etn,rsParenFolder.value("parent_folder_id"),"",type);
        
        if(!path.isEmpty() && !path.endsWith("/")) path+="/";
        if(!parseNull(rsParenFolder.value("path_prefix")).isEmpty()) path+=rsParenFolder.value("path_prefix");

        if(!id.isEmpty() && type.equals("folder")){
            Set rsCurrentFolderPath = Etn.execute("select path_prefix from products_folders_details where folder_id="+escape.cote(id)+" limit 1");
            if(rsCurrentFolderPath.next()){
                if(!path.isEmpty() && !path.endsWith("/")) path+="/";
                path+=rsCurrentFolderPath.value("path_prefix");
            }
        }
        return path;
    }

    void updateProductPagePath(Contexte Etn, String id,String newPath,String siteId,String pagesDb,String type){
        if(type.equals("folder")){
            Set rsPv2 = Etn.execute("select * from products_definition where folder_id="+escape.cote(id));
            while(rsPv2.next()){
                String pagePath="";
                if(!newPath.isEmpty()) pagePath = newPath;
                if(!pagePath.endsWith("/")) pagePath+="/";
                pagePath += rsPv2.value("url");

                if(pagePath.startsWith("/")) pagePath = pagePath.substring(1);
                if(pagePath.endsWith("/")) pagePath = pagePath.substring(0, pagePath.length() - 1);
                
                Set rsProductPage = Etn.execute("select page_id from "+pagesDb+".products_map_pages where product_id=(select id from products where product_definition_id="+
                    escape.cote(rsPv2.value("id"))+")");
                rsProductPage.next();
                Etn.executeCmd("update "+pagesDb+".pages_tbl set path="+escape.cote(pagePath)+" where site_id="+escape.cote(siteId)+
                    " and type='structured' and parent_page_id="+escape.cote(rsProductPage.value("page_id")));
                Etn.executeCmd("update "+pagesDb+".structured_contents_tbl set to_generate=1,to_generate_by="+escape.cote(""+Etn.getId())+
                    ",updated_ts=now(),updated_by="+escape.cote(""+Etn.getId())+" where id="+escape.cote(rsProductPage.value("page_id")));
            }
        }else{
            Set rsPv2 = Etn.execute("select * from products_definition where id="+escape.cote(id));
            if(rsPv2.next()){
                String pagePath="";
                if(!newPath.isEmpty()) pagePath = newPath;
                if(!pagePath.endsWith("/")) pagePath+="/";
                pagePath += rsPv2.value("url");

                if(pagePath.startsWith("/")) pagePath = pagePath.substring(1);
                if(pagePath.endsWith("/")) pagePath = pagePath.substring(0, pagePath.length() - 1);
                
                Set rsProductPage = Etn.execute("select page_id from "+pagesDb+".products_map_pages where product_id=(select id from products where product_definition_id="+escape.cote(id)+")");
                rsProductPage.next();
                Etn.executeCmd("update "+pagesDb+".pages_tbl set path="+escape.cote(pagePath)+" where site_id="+escape.cote(siteId)+
                    " and type='structured' and parent_page_id="+escape.cote(rsProductPage.value("page_id")));
                Etn.executeCmd("update "+pagesDb+".structured_contents_tbl set to_generate=1,to_generate_by="+escape.cote(""+Etn.getId())+
                    ",updated_ts=now(),updated_by="+escape.cote(""+Etn.getId())+" where id="+escape.cote(rsProductPage.value("page_id")));
            }
        }
    }

    boolean isProductPagePathUnique(Contexte Etn, String id,String newPath,String siteId,String pagesDb,String type){
        if(type.equals("folder")){
            Set rsPv2 = Etn.execute("select * from products_definition where folder_id="+escape.cote(id));
            while(rsPv2.next()){
                String pagePath="";
                if(!newPath.isEmpty()) pagePath = newPath;
                if(!pagePath.endsWith("/")) pagePath+="/";
                pagePath += rsPv2.value("url")+".html";

                Set rsPages = Etn.execute("select * from "+GlobalParm.getParm("COMMONS_DB")+".content_urls where site_id="+escape.cote(siteId)+" and page_path="+escape.cote(pagePath));
                while(rsPages.next()){
                    if(!rsPages.value("content_type").equals("page")) return true;
                    else{
                        Set rsLanPage = Etn.execute("select * from "+pagesDb+".pages where id="+escape.cote(rsPages.value("content_id")));
                        if(rsLanPage.next()) {
                            if(!rsLanPage.value("type").equals("structured")) return true;
                            else{
                                Set rsCheck = Etn.execute("select * from "+pagesDb+".products_map_pages where page_id="+escape.cote(rsLanPage.value("parent_page_id")));
                                rsCheck.next();
                                if(rsCheck.rs.Rows==0) return true;
                                else {
                                    if(!rsCheck.value("product_id").equals(id)) return true;
                                }
                            }
                        }
                    }
                }
            }
        }else{
            Set rsPv2 = Etn.execute("select * from products_definition where id=(select product_definition_id from products where id="+escape.cote(id)+")");
            if(rsPv2.next()){
                String pagePath="";
                if(!newPath.isEmpty()) pagePath = newPath;
                if(!pagePath.endsWith("/")) pagePath+="/";
                pagePath += rsPv2.value("url")+".html";
                
                Set rsPages = Etn.execute("select * from "+GlobalParm.getParm("COMMONS_DB")+".content_urls where site_id="+escape.cote(siteId)+" and page_path="+escape.cote(pagePath));
                while(rsPages.next()){
                    if(!rsPages.value("content_type").equals("page")) return true;
                    else{
                        Set rsLanPage = Etn.execute("select * from "+pagesDb+".pages where id="+escape.cote(rsPages.value("content_id")));
                        if(rsLanPage.next()) {
                            if(!rsLanPage.value("type").equals("structured")) return true;
                            else{
                                Set rsCheck = Etn.execute("select * from "+pagesDb+".products_map_pages where page_id="+escape.cote(rsLanPage.value("parent_page_id")));
                                rsCheck.next();
                                if(rsCheck.rs.Rows==0) return true;
                                else {
                                    if(!rsCheck.value("product_id").equals(id)) return true;
                                }
                            }
                        }
                    }
                }
            }
        }
        return false;
    }

    void updatePagesOnFolderupdate(Contexte Etn, String folderId,String catalogId,String siteId,String pagesDb){
        String newPath = getFolderNewPrefixPath(Etn,folderId,"","product");
        Set rs = Etn.execute("select id,product_definition_id from products where folder_id="+escape.cote(folderId)+" and catalog_id="+escape.cote(catalogId));
        while(rs.next()){
            if(!isProductPagePathUnique(Etn,rs.value("id"),newPath,siteId,pagesDb,"product")) updateProductPagePath(Etn,rs.value("product_definition_id"),newPath,siteId,pagesDb,"product");
        }
        Set rsFolders = Etn.execute("select id from products_folders where parent_folder_id="+escape.cote(folderId)+" and catalog_id="+escape.cote(catalogId));
        while(rsFolders.next()){
            updatePagesOnFolderupdate(Etn,rsFolders.value("id"), catalogId, siteId, pagesDb);
        }
    }

    JSONObject moveFolder(Contexte Etn, String id, String moveToFolderId, String oldCatalogId ,String moveToCatalogId ,int moveToFolderLevel, String siteId,String pagesDb){
        boolean status = false;
        String q = "";
        String message = "Cannot move this folder";
        boolean isSameCatalog = false;
        // duplicate folder name check
        q = "SELECT id FROM products_folders"
        +" WHERE parent_folder_id = "+escape.cote(moveToFolderId)
        +" AND site_id = "+escape.cote(siteId)
        +" AND catalog_id = "+escape.cote(moveToCatalogId)
        +" AND name = ( SELECT name from products_folders WHERE id = "+escape.cote(id)+" )";
        Set rs = Etn.execute(q);

        if(rs.next()) message = "Folder with this name already exsits";
        else {
            
            String newPath = getFolderNewPrefixPath(Etn,moveToFolderId,id,"folder");

            boolean isDuplicateUrl = isProductPagePathUnique(Etn,id,newPath,siteId,pagesDb,"folder");
            if(!id.equals(moveToFolderId)){
                if(moveToFolderLevel <= 3){
                    q = "SELECT id FROM products_folders WHERE parent_folder_id = "+escape.cote(id)+" AND site_id = "+escape.cote(siteId)+" AND catalog_id = "+escape.cote(moveToCatalogId);
                    rs = Etn.execute(q);

                    if(!rs.next()){ // if folder has child folders then it will not be moved

                        if(!isDuplicateUrl){
                            q = "UPDATE products_folders SET parent_folder_id = "+escape.cote(moveToFolderId)+", folder_level = "+escape.cote(moveToFolderLevel+1+"")+
                                ", catalog_id="+escape.cote(moveToCatalogId)+ " WHERE id = "+escape.cote(id)+" AND site_id = "+escape.cote(siteId);
                            if(Etn.executeCmd(q) > 0){
                                updateProductPagePath(Etn,id,newPath,siteId,pagesDb,"folder");
                                status = true;
                            } 
                        }else message = "Can't move folder, it will create duplicate URLs.";
                    } else message = "Folder has child folders, it cannot be moved";
                } else message = "Folders not allowed at this folder level";
            }
        }

        JSONObject retObject = new JSONObject();
        retObject.put("status", status);
        retObject.put("message", message);
        return retObject;
    }

    String getCatalogByProduct(Contexte Etn, String id,String type){
        String q = "";
        Set rs = null;

        if(type.equals("folder")){
            q = "SELECT catalog_id FROM products_folders WHERE id ="+escape.cote(id);
            rs = Etn.execute(q);
        }else{
            q = "SELECT catalog_id FROM products WHERE id ="+escape.cote(id);
            rs = Etn.execute(q);
        }
        if(rs.next()){
                return parseNull(rs.value("catalog_id")) ;
        } else {
                return "";
        }
    }

    String getProductName(Contexte Etn ,String id, String type, String langId){
        String q = "";
        Set rs = null;

        if(type.equals("folder")) rs = Etn.execute("SELECT name FROM products_folders WHERE id ="+escape.cote(id));
        else rs = Etn.execute("SELECT lang_"+langId+"_name as name FROM products WHERE id ="+escape.cote(id));
        
        if(rs.next()) return parseNull(rs.value("name")) ;
        else return "";
    }

    
    boolean verifyFolderFunction(com.etn.beans.Contexte Etn,String id){
		
		Set rsProd=Etn.execute("select id,lang_1_name from products where folder_id="+escape.cote(id));
        while(rsProd.next()){
            Set rsPost=Etn.execute("select phase from post_work where proces='products' and client_key ="+escape.cote(rsProd.value("id"))+" order by id desc limit 1");
            if(rsPost!=null && rsPost.next()){
                if(!rsPost.value("phase").equalsIgnoreCase("deleted")){
                    return false;
                }
            }
        }
        
        Set rsCilFolders = Etn.execute("select id from products_folders where parent_folder_id="+escape.cote(id));
        while(rsCilFolders.next()){
            boolean tmp = verifyFolderFunction(Etn,parseNull(rsCilFolders.value("id")));
            if(!tmp){
                return false;
            }
        }
		return true;
	}

    Boolean canFolderBeDeleted(com.etn.beans.Contexte Etn , String folId, String siteId){
        Set rsProd=Etn.execute("SELECT * FROM products_folders_tbl WHERE name = (SELECT name FROM products_folders_tbl WHERE id = "+escape.cote(folId)+") AND site_id = "+escape.cote(siteId)+" AND is_deleted = 1");
        if(rsProd.rs.Rows>0)
            return false;
        return true;
    }

    JSONArray getFoldersData(Contexte Etn,String siteId,String catalog_id, String parent_folder_id){
        JSONArray folderArray = new JSONArray();
        String query = "select * from products_folders where site_id="+ escape.cote(siteId) +" and catalog_id="+ escape.cote(catalog_id)+" and is_deleted=0 and parent_folder_id="+ escape.cote(parent_folder_id);
        Set rs = Etn.execute(query);
        while(rs.next()){
            JSONObject folderObj = new JSONObject();
            for(String colName:rs.ColName){
                if(colName.equalsIgnoreCase("id")){
                    folderObj.put("childFolder",getFoldersData(Etn,siteId,catalog_id,rs.value("id")));
                }
                folderObj.put(colName.toLowerCase(),rs.value(colName));
            }
            folderArray.put(folderObj);
        }
        return folderArray;
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

    String siteId = getSelectedSiteId(session);
    List<Language> langsList = getLangs(Etn,siteId);
    int pid = Etn.getId();

    int maxFolderLevel = parseNullInt(GlobalParm.getParm("max_catalogs_folder_level"));
    String pagesDb = GlobalParm.getParm("PAGES_DB");

    try{
        String requestType = parseNull(request.getParameter("requestType"));
        if("saveFolder".equalsIgnoreCase(requestType)){
            try{
                int id = parseInt(request.getParameter("id"), 0);
                String name = parseNull(request.getParameter("name"));
                String parentFolderUuid =  parseNull(request.getParameter("parentFolderUuid"));
                String catalogId =  parseNull(request.getParameter("catalogId"));
                String parentFolderId = "0";
                boolean isUpdate = false;

                String errorMsg = "";
                if(name.length() == 0){
                    errorMsg = "Name cannot be empty";
                }

                int parentFolderLevel = 1;
                // validate parent folder
                if(parentFolderUuid.length()>0){
                    rs =  Etn.execute("SELECT id, folder_level FROM products_folders WHERE uuid = "+escape.cote(parentFolderUuid)+" AND site_id = "+escape.cote(siteId));
                    if(rs.next()){
                        parentFolderLevel = parseNullInt(rs.value("folder_level"));
                        parentFolderId = rs.value("id");
                    }else{
                        errorMsg = "Invalid parent folder";
                    }
                }
                if(parentFolderLevel >= maxFolderLevel){
                    errorMsg = "Folder Cannot be created at this level";
                }

                q = "SELECT id FROM products_folders "
                    + " WHERE name = " + escape.cote(name)
                    + " AND site_id = " + escape.cote(siteId)
                    + " AND parent_folder_id = " + escape.cote(parentFolderId)
                    + " AND catalog_id = " + escape.cote(catalogId);
                if(id > 0){
                    q += " AND id != " + escape.cote(""+id);
                }

                rs = Etn.execute(q);
                if(rs.next()){
                    errorMsg = "Name already exist. please specify different name.";
                }

                if(errorMsg.length() > 0){
                    message = errorMsg;
                }
                else{
                    colValueHM.put("name", escape.cote(name));
                    colValueHM.put("updated_on", "NOW()");
                    colValueHM.put("updated_by", escape.cote(""+pid));
                    if(id <= 0){
                        //new
                        colValueHM.put("site_id", escape.cote(siteId));
                        colValueHM.put("catalog_id", escape.cote(catalogId));
                        colValueHM.put("parent_folder_id", escape.cote(parentFolderId));
                        colValueHM.put("folder_level", escape.cote(""+( 1+parentFolderLevel)));
                        colValueHM.put("version", "1");
                        colValueHM.put("created_by", escape.cote(""+pid));
                        colValueHM.put("created_on", "NOW()");

                        q = getInsertQuery("products_folders",colValueHM);
                        id = Etn.executeCmd(q);

                        if(id <= 0){
                            message = "Error in creating folder. Please try again.";
                        }
                        else{
                            status = STATUS_SUCCESS;
                            message = "Folder created.";
                            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id+"","CREATED","Products Folder",name,siteId);
                            data.put("id", id);
                        }
                    }
                    else{
                        isUpdate=true;
                        //existing update
                        colValueHM.put("version", "version + 1");
                        q = getUpdateQuery("products_folders", colValueHM, " WHERE id = " + escape.cote(""+id) );

                        int count = Etn.executeCmd(q);

                        if(count <= 0){
                            message = "Error in updating folder. Please try again.";
                        }
                        else{
                            status = STATUS_SUCCESS;
                            message = "Folder updated.";
                            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id+"","UPDATED","Product Folder",name,siteId);
                            data.put("id", id);
                        }
                    }

                    if(status == STATUS_SUCCESS){
                        colValueHM.clear();
                        colValueHM.put("folder_id", escape.cote(""+id));

                        String curPathPrefix = parseNull(request.getParameter("path_prefix"));
                        for(Language lang : langsList){
                            colValueHM.put("langue_id", escape.cote(lang.getLanguageId()));
                            colValueHM.put("path_prefix", escape.cote(curPathPrefix));
                            q = getInsertQuery("products_folders_details",colValueHM);
                            q += " ON DUPLICATE KEY UPDATE path_prefix=VALUES(path_prefix)";
                            Etn.executeCmd(q);
                        }

                        //update the date of all products inside folder

                        colValueHM.clear();
                        colValueHM.put("version", "version +1");
                        colValueHM.put("updated_on", "NOW()");
                        colValueHM.put("updated_by", escape.cote(""+pid));
                        q = getUpdateQuery("products", colValueHM, " WHERE catalog_id = "+ escape.cote(catalogId) +" AND folder_id = "+escape.cote(""+id));
                        Etn.execute(q);
                        //update the date of all folders inside this folder(last level folder)

                        colValueHM.clear();
                        colValueHM.put("version", "version +1");
                        colValueHM.put("updated_on", "NOW()");
                        colValueHM.put("updated_by", escape.cote(""+pid));
                        q = getUpdateQuery("products_folders", colValueHM, " WHERE parent_folder_id = "+ escape.cote(id+""));
                        rs =  Etn.execute(q);

                        q = "SELECT id FROM products_folders WHERE parent_folder_id = "+ escape.cote(id+"");
                        rs = Etn.execute(q);

                        while(rs.next()){
                            String _id = rs.value("id");
                            // update the date of all products in this folder 
                            colValueHM.clear();
                            colValueHM.put("version", "version +1");
                            colValueHM.put("updated_on", "NOW()");
                            colValueHM.put("updated_by", escape.cote(""+pid));
                            q = getUpdateQuery("products", colValueHM, " WHERE catalog_id = "+ escape.cote(catalogId) +" AND folder_id = "+escape.cote(_id));
                            Etn.execute(q);
                        }

                        // update catalog verstion
                        colValueHM.clear();
                        colValueHM.put("version", "version +1");
                        colValueHM.put("updated_on", "NOW()");
                        colValueHM.put("updated_by", escape.cote(""+pid));
                        q = getUpdateQuery("catalogs", colValueHM, " WHERE id = " + escape.cote(catalogId) + " AND site_id = "+escape.cote(siteId));
                        Etn.execute(q);
                        // update parentFolder
                        if(!parentFolderId.equals("0")){
                            colValueHM.clear();
                            colValueHM.put("version", "version +1");
                            colValueHM.put("updated_on", "NOW()");
                            colValueHM.put("updated_by", escape.cote(""+pid));
                            q = getUpdateQuery("products_folders", colValueHM, " WHERE id = " + escape.cote(parentFolderId) + " AND site_id = "+escape.cote(siteId));
                            Etn.execute(q);
                        }

                        if(isUpdate) updatePagesOnFolderupdate(Etn,id+"", catalogId, siteId, pagesDb);
                    }
                }
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving folder. Please try again.",ex);
            }
        }
        else if("moveProducts".equalsIgnoreCase(requestType)){
            // move folder, products
            try{
                String productsData = parseNull(request.getParameter("products"));
                String  moveToFoldreId = parseNull(request.getParameter("moveToFolderId"));
                String  moveToCatalogId = parseNull(request.getParameter("moveToCatalogId"));
                JSONArray products = new JSONArray(productsData);
                int totalCount = products.length();
                int moveToFolderLevel = 0;
                String movedToFolderName = "base";

                if(totalCount == 0){
                    throw new SimpleException("Error: No id found");
                }
                if(moveToFoldreId.length()>0){
                    if(moveToFoldreId.equals("-1")){
                       moveToFoldreId = "0"; //catalog folder
                    } else{
                        q = "SELECT id, folder_level, name FROM products_folders WHERE uuid = "+escape.cote(moveToFoldreId)+" and catalog_id="+escape.cote(moveToCatalogId);
                        rs = Etn.execute(q);
                        if(!rs.next()){
                            throw new SimpleException("Cannot move to invalid folder");
                        }
                        moveToFoldreId = rs.value("id");
                        moveToFolderLevel  = parseInt(rs.value("folder_level"));
                        movedToFolderName = rs.value("name");
                    }
                }
                else{
                    throw new SimpleException("Cannot move to invalid folder");
                }

                int moveProductCount = 0;
                int moveFolderCount = 0;

                String movedProductIds = "";
                String movedProductNames = "";

                String movedFolderIds = "";
                String movedFolderNames = "";

                String type = "";

                ArrayList<String> unmovedItems = new ArrayList<>();
                ArrayList<String> unmovedItemsMessages = new ArrayList<>();

                for(Object obj : products){

                    JSONObject productObj  = (JSONObject)obj;
                    String id = productObj.optString("id","-1");
                    type = productObj.optString("type");
                    String name = getProductName(Etn, id, type,langsList.get(0).getLanguageId());
                    JSONObject moveResp = null;

                    if(type.equals("folder")) moveResp = moveFolder(Etn , id, moveToFoldreId, getCatalogByProduct(Etn,id,type),moveToCatalogId , moveToFolderLevel, siteId,pagesDb);
                    else moveResp = moveProduct(Etn, langsList, id, moveToFoldreId, moveToCatalogId, siteId,pagesDb);

                    boolean isMoved = moveResp.optBoolean("status");

                    if(isMoved){
                        if(type.equals("folder")){
                            moveFolderCount += 1;
                            movedFolderIds += id+", ";
                            movedFolderNames += name+", ";
                        } else {
                            moveProductCount += 1;
                            movedProductIds += id+", ";
                            movedProductNames += name+", ";
                        }
                    }
                    else {
                        unmovedItems.add(name);
                        unmovedItemsMessages.add(moveResp.getString("message"));
                    }
                }
                if(totalCount == 1){
                    if(type.equals("folder")){
                        if(moveFolderCount > 0){
                            status = STATUS_SUCCESS;
                            message = "Folder moved to "+movedToFolderName+" folder";
                        } else {
                            if(unmovedItemsMessages.size()>0) message = unmovedItemsMessages.get(0);
                            else message = "Error in moving folder";
                        }
                    } else {
                        if(moveProductCount > 0){
                            status = STATUS_SUCCESS;
                            message = "Product moved to "+movedToFolderName+" folder";;
                        } else {
                            if(unmovedItemsMessages.size()>0) message = unmovedItemsMessages.get(0);
                            else message = "Error in moving product";
                        }
                    }
                }
                else {
                    status = STATUS_SUCCESS;
                    if(moveProductCount > 0) message = moveProductCount + " products";
                    
                    if(moveFolderCount > 0){
                        if(message.length()>0) message += " and ";
                        message += moveFolderCount + " folders";
                    }
                    if(message.length()>0) message += " moved to "+movedToFolderName+" folder";
                    if((moveFolderCount + moveProductCount) == 0) message += "No product or folder moved";

                    if((moveFolderCount + moveProductCount) < totalCount){
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
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), movedFolderIds, "MOVED", "Products Folder", movedFolderNames+" (moved to) => "+movedToFolderName+" folder", siteId);
                    }
                    if(movedProductIds.length()>0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), movedProductIds, "MOVED", "Products", movedProductNames+" (moved to) => "+movedToFolderName+" folder", siteId);
                    }
                }
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in moving products and folders. Please try again.",ex);
            }
        }
        else if("getProductFoldersList".equalsIgnoreCase(requestType)){
            try{
                String catalogId = parseNull(request.getParameter("catalogId"));
                JSONArray foldersList = new JSONArray();
                q= "Select * from ( SELECT '' as p_folder_id,'-1' AS uuid,c.name,c.catalog_type,'' AS concat_path, c.id as catalog_id  "
                    + " FROM  "
                    + " ( SELECT * FROM catalogs WHERE site_id= "+escape.cote(siteId)+" AND id="+escape.cote(catalogId)+ " ) c "
                    + " UNION ALL "
                    +" SELECT f.id as p_folder_id, f.uuid, f.name, c.catalog_type, CONCAT_WS('/', NULLIF(f2.name,'')) as concat_path, f.catalog_id  "
                    + " FROM products_folders f JOIN catalogs c ON c.id = f.catalog_id  "
                    + " LEFT JOIN products_folders f2 ON f.parent_folder_id = f2.id WHERE f.site_id = "+escape.cote(siteId)+" and f.catalog_id="+escape.cote(catalogId)
                    + ") t ORDER BY catalog_type, concat_path, name, p_folder_id ASC";

                rs = Etn.executeWithCount(q);

                if(Etn.UpdateCount == 0 ){
                    q=  " SELECT f.id as p_folder_id, f.uuid, f.name, c.catalog_type, CONCAT_WS('/', NULLIF(f2.name,'')) as concat_path, f.catalog_id  "
                        +" FROM products_folders f JOIN catalogs c ON c.id = f.catalog_id  "
                        +" LEFT JOIN products_folders f2 ON f.parent_folder_id = f2.id WHERE f.site_id = "+escape.cote(siteId)+" and f.catalog_id="+escape.cote(catalogId)
                        +" ORDER BY catalog_type, concat_path, name, p_folder_id ASC";
                    rs = Etn.execute(q);
                }
                while(rs.next()){
                    foldersList.put(getJSONObject(rs));
                }
                data.put("folders",foldersList);
                status = STATUS_SUCCESS;
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting folders list for views.", ex);
            }
        }
        else if("getFolderInfo".equalsIgnoreCase(requestType)){

            try{
                String id = parseNull(request.getParameter("id"));

                JSONObject retJson = new JSONObject();

                q = "SELECT * FROM products_folders "
                    + " WHERE id = " + escape.cote(id)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if(rs.next()){
                    for(String colName : rs.ColName){
                        retJson.put(colName.toLowerCase(), rs.value(colName));
                    }

                    JSONObject pathPrefixJson = new JSONObject();

                    q = "SELECT * FROM products_folders_details "
                        + " WHERE folder_id = " + escape.cote(id)+" limit 1";
                    rs = Etn.execute(q);
                    while(rs.next()){
                        pathPrefixJson.put(rs.value("langue_id"), rs.value("path_prefix"));
                    }

                    retJson.put("path_prefix", pathPrefixJson);

                    data.put("folder",retJson);
                    status = STATUS_SUCCESS;
                }
                else{
                    message = "Error folder not found.";
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting folder info.", ex);
            }
        }
        else if("copyFolder".equalsIgnoreCase(requestType)){

            try{
                String id =  parseNull(request.getParameter("id"));
                String name =  parseNull(request.getParameter("name"));
                String catalogId = "";
                int parentFolderId = 0;

                if(id.length() == 0){
                    throw new SimpleException("Invalid folder id.");
                }

                rs = Etn.execute("SELECT folder_level, parent_folder_id, catalog_id FROM products_folders "
                    + " WHERE id = " + escape.cote(id)
                    + " AND site_id = " + escape.cote(siteId));

                if(rs.next()){

                    q = "SELECT id FROM products_folders "
                        + " WHERE name = " + escape.cote(name)
                        + " AND site_id = " + escape.cote(siteId)
                        + " AND parent_folder_id = " + escape.cote(rs.value("parent_folder_id"));

                    Set rsName = Etn.execute(q);
                    if(rsName.next()){
                        throw new SimpleException("Name already exist. please specify different name.");
                    }
                    catalogId = rs.value("catalog_id");
                    parentFolderId = parseInt(rs.value("parent_folder_id"));

                    colValueHM.put("name", escape.cote(name));
                    colValueHM.put("updated_on", "NOW()");
                    colValueHM.put("updated_by", escape.cote(""+Etn.getId()));
                    colValueHM.put("site_id", escape.cote(siteId));
                    colValueHM.put("parent_folder_id", escape.cote(rs.value("parent_folder_id")));
                    colValueHM.put("catalog_id", escape.cote(catalogId));
                    colValueHM.put("folder_level", escape.cote(rs.value("folder_level")));
                    colValueHM.put("created_by", escape.cote(""+Etn.getId()));
                    colValueHM.put("created_on", "NOW()");

                    q = getInsertQuery("products_folders",colValueHM);
                    int _id =  Etn.executeCmd(q);

                    if(_id<=0){
                        throw new SimpleException("Error in copying folder.");
                    }else{
                        rs = Etn.execute("SELECT langue_id, path_prefix FROM products_folders_details WHERE folder_id = "+escape.cote(id));
                        while(rs.next()){
                            colValueHM.clear();
                            colValueHM.put("folder_id", escape.cote(""+_id));
                            colValueHM.put("langue_id", escape.cote(rs.value("langue_id")));
                            colValueHM.put("path_prefix", escape.cote(rs.value("path_prefix")));

                            q = getInsertQuery("products_folders_details",colValueHM);
                            Etn.executeCmd(q);
                        }
                        // updating catalog version
                        colValueHM.clear();
                        colValueHM.put("version", "version +1");
                        colValueHM.put("updated_on", "NOW()");
                        colValueHM.put("updated_by", escape.cote(""+pid));
                        q = getUpdateQuery("catalogs", colValueHM, " WHERE id = " + escape.cote(catalogId) + " AND site_id = "+escape.cote(siteId));
                        Etn.execute(q);

                        // update parentFolder
                        if(parentFolderId>0){
                            colValueHM.clear();
                            colValueHM.put("version", "version +1");
                            colValueHM.put("updated_on", "NOW()");
                            colValueHM.put("updated_by", escape.cote(""+pid));
                            q = getUpdateQuery("products_folders", colValueHM, " WHERE id = " + escape.cote(""+parentFolderId) + " AND site_id = "+escape.cote(siteId));
                            Etn.execute(q);
                        }

                        status = STATUS_SUCCESS;
                        message = "Folder copied.";
                        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),_id+"","COPIED","Products Folder ",name,siteId);
                        data.put("id", _id);
                    }
                }else{
                    throw new SimpleException("Folder id is invalid.");
                }
            }
            catch(Exception ex){
                throw new SimpleException("Error in copying folders.",ex);
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
        else if("deleteFolders".equalsIgnoreCase(requestType)){
            try{
                String folderIds[]= request.getParameterValues("ids");
                Boolean del_Status= true;
                int totalCount = folderIds.length;
                String catalogId  = "";
                int parentFolderId = 0;

                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                int deleteCount = 0;
                String cids = "";
                String cnames = "";
                for(String folId : folderIds){
                    if(verifyFolderFunction(Etn,folId)){

                        del_Status = canFolderBeDeleted(Etn,folId,siteId);
                        if(!del_Status){    
                            status = STATUS_SUCCESS;
                            Set rsFolNme = Etn.execute("select name from products_folders_tbl where id="+escape.cote(folId));
                            rsFolNme.next();
                            message += "\"" + rsFolNme.value("name") + "\"";

            
                        }
                        else{
                            q = " SELECT id, name, catalog_id, parent_folder_id"
                                + " FROM products_folders "
                                + " WHERE id = " + escape.cote(folId);
                            Set rsFolder = Etn.execute(q);
                            if(!rsFolder.next()){
                                continue;
                            }
                            String curName = rsFolder.value("name");

                            trashFolder(Etn,folId);

                            catalogId = rsFolder.value("catalog_id");
                            parentFolderId = parseInt(rsFolder.value("parent_folder_id"));

                            cids += folId + ",";
                            cnames += curName + ", ";

                            deleteCount += 1;

                        }
                    }else{
                        if(message.length()>0){
                            message+=",";
                        }
                        Set rsFolNme = Etn.execute("select name from products_folders_tbl where id="+escape.cote(folId));
                        rsFolNme.next();
                        message += "\"" + rsFolNme.value("name") + "\"";
                    }
                }

                if(totalCount != deleteCount){

                    if(del_Status == false){
                        status = STATUS_SUCCESS;
                        message+=" Folder can not be deleted as duplicate present in Trash.";
                    }
                    else{

                    status = STATUS_SUCCESS;
                    message = deleteCount + " of " + totalCount + " folders deleted. Folders with published products cannot be deleted. "+message+" has products either published or publishing.";
                    }

                    
                }else{
                    message = "Folder";
                    if(deleteCount>1){
                        message+="s";
                    }
                    message+=" deleted successfully";

                    status = STATUS_SUCCESS;
                }

                if(status == STATUS_SUCCESS){
                    // updating catalog version
                    colValueHM.clear();
                    colValueHM.put("version", "version +1");
                    colValueHM.put("updated_on", "NOW()");
                    colValueHM.put("updated_by", escape.cote(""+pid));
                    q = getUpdateQuery("catalogs", colValueHM, " WHERE id = " + escape.cote(catalogId) + " AND site_id = "+escape.cote(siteId));
                    Etn.execute(q);

                    // update parentFolder
                    if(parentFolderId>0){
                        colValueHM.clear();
                        colValueHM.put("version", "version +1");
                        colValueHM.put("updated_on", "NOW()");
                        colValueHM.put("updated_by", escape.cote(""+pid));
                        q = getUpdateQuery("products_folders", colValueHM, " WHERE id = " + escape.cote(""+parentFolderId) + " AND site_id = "+escape.cote(siteId));
                        Etn.execute(q);
                    }

                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),cids,"TRASHED","Products Folder",cnames,siteId);
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting folders.",ex);
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
               