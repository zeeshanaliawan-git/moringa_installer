<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.asimina.util.ActivityLog,com.etn.asimina.util.UrlHelper, com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.List, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*,org.json.*, java.util.ListIterator,com.etn.asimina.util.FileUtil,java.io.File"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../../../common.jsp"%>

<%!
    boolean verifyCatalogFunction(com.etn.beans.Contexte Etn,String id) 
    {
		
		Set rsProd=Etn.execute("select id from products where catalog_id="+escape.cote(id));
		if(rsProd!=null){
			while(rsProd.next()){
				Set rsPost=Etn.execute("select phase from post_work where proces='products' and client_key ="+escape.cote(rsProd.value("id"))+" order by id desc limit 1");
				if(rsPost!=null && rsPost.next()){
					if(!rsPost.value("phase").equalsIgnoreCase("deleted")){
						return false;
					}
				}
			}
		}else{
			return false;
		}
		return true;
	}

    String getCatalogType(Contexte Etn, String id)
    {
        Set rs = Etn.execute("SELECT catalog_type from catalogs where id="+escape.cote(id));
        rs.next();
        return parseNull(rs.value("catalog_type"));
    }

    String getCatalogName(Contexte Etn, String id)
    {
        Set rs = Etn.execute("SELECT name from catalogs where id="+escape.cote(id));
        rs.next();
        return parseNull(rs.value("name"));
    }

    String getProductName(com.etn.lang.ResultSet.Set rs, String catalogType)
    {
        if(parseNull(rs.value("lang_1_name")).length() > 0) return "device".equals(catalogType) ? parseNull(rs.value("brand_name")) + " " + parseNull(rs.value("lang_1_name")) : parseNull(rs.value("lang_1_name"));
        if(parseNull(rs.value("lang_2_name")).length() > 0) return "device".equals(catalogType) ? parseNull(rs.value("brand_name")) + " " + parseNull(rs.value("lang_2_name")) : parseNull(rs.value("lang_2_name"));
        if(parseNull(rs.value("lang_3_name")).length() > 0) return "device".equals(catalogType) ? parseNull(rs.value("brand_name")) + " " + parseNull(rs.value("lang_3_name")) : parseNull(rs.value("lang_3_name"));
        if(parseNull(rs.value("lang_4_name")).length() > 0) return "device".equals(catalogType) ? parseNull(rs.value("brand_name")) + " " + parseNull(rs.value("lang_4_name")) : parseNull(rs.value("lang_4_name"));
        if(parseNull(rs.value("lang_5_name")).length() > 0) return "device".equals(catalogType) ? parseNull(rs.value("brand_name")) + " " + parseNull(rs.value("lang_5_name")) : parseNull(rs.value("lang_5_name"));
        return "";
    }

    String showProductImage(com.etn.beans.Contexte Etn, Set rs, String catalogType, String siteId)
    {
        
        String imageUrlPrefix = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/thumb/";
        
        if("offer".equals(catalogType))
        {
            Set rs2 = Etn.execute("select image_file_name from product_images where product_id = " + escape.cote(rs.value("id")) );
            if(rs2.next())
            {
                String imageName = rs2.value("image_file_name");
                return imageUrlPrefix + imageName ;
            }
        }
        
        Set rsv = Etn.execute("select pvr.path from product_variants pv, product_variant_resources pvr where pvr.type = 'image' and pvr.product_variant_id = pv.id and pv.product_id = " + escape.cote(rs.value("id")) + " order by pv.id, pvr.langue_id, pvr.sort_order ");
        
        if(rsv.next()) {
            String imageName = rsv.value("path");
            return imageUrlPrefix + imageName ;
        }
        return "";
    }

    String [] getProductPublishStatus(Set rs)
    {
        return new String[] {parseNull(rs.value("publish_status")),parseNull(rs.value("updated_on")),parseNull(rs.value("updated_by"))};
    }
    List<String> generateSearchBreadcrumbs(List<String> searchBreadcrumbs, com.etn.beans.Contexte Etn, String folderid) {
    
        Set rs = Etn.execute("Select parent_folder_id, name from products_folders where id =" + escape.cote(folderid));

        if (rs.rs.Rows == 0) {
            return searchBreadcrumbs;
        } else {
            rs.next();        
            searchBreadcrumbs.add(rs.value("name"));
            if (Integer.parseInt(rs.value("parent_folder_id")) == 0)
                return searchBreadcrumbs; 
        }
        return generateSearchBreadcrumbs( searchBreadcrumbs ,Etn, rs.value("parent_folder_id"));
    }

    Boolean canCatalogBeDeleted(com.etn.beans.Contexte Etn , String id, String siteId){
        String query="";
        Set rsCatalog = Etn.execute(query="SELECT * "
                +" FROM catalogs_tbl "
                +" where name = "
                +" ( SELECT name FROM catalogs_tbl where id="+escape.cote(id)+" ) AND site_id="+escape.cote(siteId)+" AND is_deleted=1");
        if(rsCatalog.rs.Rows>0)
            return false;
        return true;
    }

    Boolean canProductBeDeleted(com.etn.beans.Contexte Etn , String id, String siteId, String logedInUserId){
        Set rs = Etn.execute("select * from products where id="+escape.cote(id)+" and is_deleted=0 and product_version='V2'");
        if(rs.next()){
            rs = Etn.execute("select p2.* from products_tbl p1 join products_tbl p2 on p1.lang_1_name=p2.lang_1_name "+
            " and p1.catalog_id=p2.catalog_id and p1.folder_id=p2.folder_id and p1.id != p2.id where p1.id="+escape.cote(id));
            if(!rs.next()){
                return true;
            }
        }
        return false;
    }

    Boolean canFolderBeDeleted(com.etn.beans.Contexte Etn , String id, String siteId, String logedInUserId){
        String query="";
        Set rsProd=Etn.execute(query="SELECT * FROM products_folders_tbl WHERE name = (SELECT name FROM products_folders_tbl WHERE id = "+escape.cote(id)+") AND site_id = "+escape.cote(siteId)+" AND is_deleted = 1");

        if(rsProd.rs.Rows>0)
            return false;
        return true;
    }

    void moveToDelete(String htmlFilePathSource,String htmlFilePathDestination){
        try {
            File sourceFile = FileUtil.getFile(htmlFilePathSource);
            File destinationFolder = FileUtil.getFile(htmlFilePathDestination);

            if (!sourceFile.exists()) System.out.println("Source file does not exist");
            else {
                FileUtil.mkDirs(destinationFolder);
                
                File destinationFile = FileUtil.getFile(htmlFilePathDestination + sourceFile.getName());
                sourceFile.renameTo(destinationFile);

                File htmlFile = FileUtil.getFile(htmlFilePathSource);
                if (htmlFile.exists()) htmlFile.delete();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    void movePageToDeleteFolder(Contexte Etn,String pageId) {

        String q = " SELECT html_file_path, published_html_file_path"
            + " FROM "+GlobalParm.getParm("PAGES_DB")+".pages_tbl "
            + " WHERE id = " + escape.cote(pageId);
        Set rs = Etn.execute(q);
        if (!rs.next()) return;

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

            File sourceFile = FileUtil.getFile(htmlFilePathSource);
            File destinationFolder = FileUtil.getFile(htmlFilePathDestination);

            moveToDelete(htmlFilePathSource,htmlFilePathDestination);
        }
    }

    

    String customBreadcrumb(List<String> searchBreadcrumbs,String catalogName) 
    {
        StringBuilder breadcrumb = new StringBuilder();
        ListIterator<String> list_iterator = searchBreadcrumbs.listIterator(searchBreadcrumbs.size());
        while (list_iterator.hasPrevious()) {
            breadcrumb.append(list_iterator.previous()).append("/");
        }
        
        return catalogName + "/" + breadcrumb.toString();
    }

    boolean verifyUrlUniquness(com.etn.beans.Contexte Etn,String siteId,String langCode,boolean isUpdate,String productV1Id, String pagesDb,String url){
        String pageId="";
        boolean rsp = false;
        if(!productV1Id.isEmpty()){
            Set rs = Etn.execute("select id from "+pagesDb+"pages where type='structured' and langue_code="+escape.cote(langCode)+" and parent_page_id=(select page_id from "+
            pagesDb+"products_map_pages where product_id="+escape.cote(productV1Id)+")");
            if(rs.next()) pageId = rs.value("id");
        }

        if(pageId.isEmpty()) rsp =  UrlHelper.isUrlUnique(Etn,siteId,langCode,"","",url);
        else rsp = UrlHelper.isUrlUnique(Etn,siteId,langCode,"page",pageId,url);

        return rsp;
    }

%>
<%
    String commonsDb = GlobalParm.getParm("COMMONS_DB") + ".";
    String pagesDb = GlobalParm.getParm("PAGES_DB") + ".";

    String requestType = parseNull(request.getParameter("requestType"));
    String siteId = getSelectedSiteId(session);
    String prodId = parseNull(request.getParameter("prodId"));
    
    int STATUS_SUCCESS = 1;
    int STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    String errmsg = "";

    String logedInUserId = parseNull(Etn.getId());

    JSONArray rspArray = new JSONArray();
    JSONObject result = new JSONObject();

    String catalogId = parseNull(request.getParameter("catalogId"));
    String delete_id = parseNull(request.getParameter("delete_id"));
    String delete_id_type = parseNull(request.getParameter("delete_id_type"));
    String delete_product_name = parseNull(request.getParameter("delete_product_name"));
    Set rsLang = Etn.execute("SELECT lang.* FROM language lang LEFT JOIN "+commonsDb+ "sites_langs sl ON lang.langue_id = sl.langue_id WHERE sl.site_id=" + escape.cote(siteId));
    
    try{
        if(requestType.equals("getProducts")){
            String searchText = parseNull(request.getParameter("searchText"));
            String folderUuid = parseNull(request.getParameter("folderId"));
            String folderId = "0";

            if (folderUuid.length() > 0) {
                String q = "SELECT f.id, f.uuid, f.folder_level, IFNULL(pf.uuid,'') AS parent_folder_id "
                    + " FROM products_folders f "
                    + " LEFT JOIN products_folders pf ON pf.id = f.parent_folder_id "
                    + " WHERE f.uuid = " + escape.cote(folderUuid)
                    + " AND f.site_id = " + escape.cote(siteId);
                Set rs = Etn.execute(q);
                if (rs.next()) {
                    folderId = rs.value("id");
                }
            }
            // make changes here
            if (!delete_id.isEmpty()) {
                if (delete_id_type.equalsIgnoreCase("product")) {
                    if(canProductBeDeleted(Etn,delete_id,siteId,logedInUserId)){

                        Set rsPages=Etn.execute("select id from "+pagesDb+"pages where type='structured' and parent_page_id=(select page_id from "+pagesDb+
                            "products_map_pages where product_id="+escape.cote(delete_id)+")");
                        while(rsPages.next()){
                            movePageToDeleteFolder(Etn,rsPages.value("id"));
                        }
                        Etn.executeCmd("update "+pagesDb+"pages set updated_ts = now(), updated_by= "+escape.cote(""+Etn.getId())+", deleted_by = "+escape.cote(""+Etn.getId())+
                            ", is_deleted='1' where type='structured' and parent_page_id=(select page_id from "+pagesDb+"products_map_pages where product_id="+escape.cote(delete_id)+")");

                        Etn.executeCmd("update "+pagesDb+"structured_contents set updated_ts = now(), updated_by= "+escape.cote(""+Etn.getId())+", deleted_by = "+escape.cote(""+Etn.getId())+
                            ", is_deleted='1' WHERE id = (select page_id from "+pagesDb+"products_map_pages where product_id="+escape.cote(delete_id)+")");
                        
                        
                        Etn.executeCmd("Update products_definition set is_deleted='1', updated_ts =now(), updated_by="+escape.cote(logedInUserId)+
                            " where id=(select product_definition_id from products where id="+escape.cote(delete_id)+")");
                        Etn.executeCmd("Update products set is_deleted='1', updated_on =now(), updated_by="+escape.cote(logedInUserId)+" where id="+escape.cote(delete_id));

                        message="Product deleted successfully";
                    }else{
                        status = STATUS_ERROR;
                        errmsg = "Product \"" + delete_product_name + "\" can not be deleted. Either duplicate present in Trash or invalid id passed.";
                    }
                }else if (delete_id_type.equalsIgnoreCase("folder")) {
                    if(canFolderBeDeleted(Etn,delete_id,siteId,logedInUserId)){
                        Etn.executeCmd("UPDATE products_folders_tbl SET is_deleted='1',updated_on=now(),updated_by="+escape.cote(logedInUserId)+" WHERE id = "+escape.cote(delete_id));
                        message="Folder deleted successfully";
                    }else{
                        status = STATUS_ERROR;
                        errmsg = "Folder can not be deleted as duplicate present in Trash.";
                    }
                }
            }

            String q = "select p.id, '' as uuid, 'product' as type, '-' as nb_items, coalesce(p.order_seq,999999) as order_seq, p.lang_1_name, p.lang_2_name, p.lang_3_name, p.lang_4_name, p.lang_5_name, p.version, case when prod_p.version is null then 'unpublished' when prod_p.version = p.version then 'published' else 'changed' end as publish_status, p.updated_on,p.created_on as created_on, lg1.name as created_by ,f.name as familie_name, lg.name as updated_by ,c.id as catalog_id "
                + " from products p "
                + " left join catalogs c on c.id = p.catalog_id "
                + " left join "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".products prod_p on prod_p.id = p.id "
                + " left outer join familie f on f.id = p.familie_id "
                + " left outer join login lg on lg.pid = p.updated_by "
                + " left join login lg1 on lg1.pid = p.created_by "
                + " where p.catalog_id = " + escape.cote(catalogId)+" AND p.is_deleted='0'" 
                +" and c.site_id = "+escape.cote(siteId);
                
            if(folderId.length()>0){
                q+= " and p.folder_id = "+escape.cote(folderId);

            }
            if(searchText.length() > 0){
                q += " and (p.lang_1_name like " + escape.cote("%" + searchText + "%")
                    + " or p.lang_2_name like " + escape.cote("%" + searchText + "%")
                    + " or p.lang_3_name like " + escape.cote("%" + searchText + "%")
                    + " or p.lang_4_name like " + escape.cote("%" + searchText + "%")
                    + " or p.lang_5_name like " + escape.cote("%" + searchText + "%") + ") ";
            }
            q += " union "
            +" select f.id, f.uuid, 'folder' as type, IFNULL(tbcount.tcount,0) as nb_items, -1 as order_seq, f.name as lang_1_name, '' as lang_2_name, '' as lang_3_name, '' as lang_4_name, '' as lang_5_name,"
            +" f.version as version, case when prod_f.version is null then 'unpublished' when prod_f.version = f.version then 'published' else 'changed' end as publish_status, f.updated_on, f.created_on as created_on, lg1.name as created_by ,'' as familie_name, lg.name as last_updated_by, f.catalog_id "
            +" from products_folders f"
            +" left join "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".products_folders prod_f on  prod_f.id = f.id"
            +" left outer join login lg on lg.pid = f.updated_by "
            +" left outer join login lg1 on lg1.pid = f.created_by "
            +" LEFT JOIN ("
            + "     SELECT folder_id, SUM(count)AS tcount"
            + "     FROM ("
            + "          SELECT folder_id, count(id) AS count"
            + "          FROM products"
            + "          WHERE folder_id > 0"
            + "          GROUP BY folder_id"
            + "          UNION ALL"
            + "          SELECT parent_folder_id AS folder_id, count(id)"
            + "          FROM products_folders pf"
            + "          WHERE parent_folder_id > 0"
            + "          GROUP BY parent_folder_id"
            + "          ) tcount"
            + "     GROUP BY folder_id"
            + "   ) tbcount ON tbcount.folder_id = f.id"
            +" where f.catalog_id = "+escape.cote(catalogId)+" AND f.is_deleted='0'";
            if(searchText.isEmpty()) {
                q += " and f.parent_folder_id = "+escape.cote(folderId);
            }
            q+=" and f.site_id = "+escape.cote(siteId);

            if(!searchText.isEmpty()){
                q += " AND ( f.name like "+escape.cote("%" + searchText + "%")
                    +" OR 'folder' like "+escape.cote("%"+searchText+"%")
                    + ") ";
            }
            q += " order by id";

            Set rs = Etn.execute(q);

            while(rs!=null && rs.next())
            {
                JSONObject data = new JSONObject();
                String statusArr[] = getProductPublishStatus(rs);
                data.put("publishStatus",statusArr);
                data.put("PHASE",rs.value("publish_status"));
                data.put("ICON",rs.value("type"));
                data.put("NAME",getProductName(rs,getCatalogType(Etn,catalogId)));
                data.put("SRC",showProductImage(Etn,rs,getCatalogType(Etn,catalogId),siteId));
                data.put("isCatalog",false);
                for (String col : rs.ColName){
                    data.put(col,parseNull(rs.value(col)));
                }
                status = STATUS_SUCCESS;
                rspArray.put(data);
            }
            result.put("data",rspArray);
            status=STATUS_SUCCESS;
            
        }else if(requestType.equals("saveProduct")){

            String folderId = parseNull(request.getParameter("folderId"));

            JSONObject productJson = new JSONObject(parseNull(request.getParameter("productJson")));
            String productUrl = productJson.getString("url");
            String folderUrl = parseNull(productJson.optString("folderUrl"));

            String completeUrl = productUrl;
            if(!folderUrl.isEmpty()) completeUrl = folderUrl.replace('~', '/')+completeUrl;

            String productV2Id = parseNull(productJson.optString("productV2Id"));
            String productV1Id = parseNull(productJson.optString("productV1Id"));

            boolean isUpdate = false;
            if(productJson.has("productV1Id") && productJson.has("productV2Id") 
                && !productJson.getString("productV1Id").isEmpty() && !productJson.getString("productV2Id").isEmpty()) isUpdate = true;

            StringBuilder query = new StringBuilder().append("select * from products_definition where site_id=").append(escape.cote(siteId))
                .append(" and catalog_id=").append(escape.cote(catalogId))
                .append(" and folder_id=").append(escape.cote(folderId))
                .append(" and name=").append(escape.cote(productJson.getString("productName")));

            if(isUpdate) query.append(" and id != ").append(escape.cote(productV2Id));
            
            Set rsCheckProduct = Etn.execute(query.toString());
            if(rsCheckProduct.rs.Rows<=0){

                if(!completeUrl.isEmpty()){
                    String langCode = "";
                    rsLang.moveFirst();
                    while(rsLang.next()){
                        langCode = rsLang.value("langue_code");
                        if(!langCode.isEmpty()) break;
                    }

                    if(verifyUrlUniquness(Etn,siteId,langCode,isUpdate,productV1Id,pagesDb,completeUrl)){

                        String langName = "";
                        String langNameVal = "";
                        String langMetaDiscription = "";
                        String langMetaDiscriptionVal = "";

                        String productTypeId = parseNull(productJson.getString("productType"));

                        StringBuilder dmlQuery = new StringBuilder();
                        if(!isUpdate){
                            dmlQuery.append("INSERT INTO products_definition (save_type, name, url, title, meta_description, product_type, site_id, catalog_id, folder_id, created_by, updated_by) VALUES (")
                                    .append(escape.cote(productJson.getString("saveType"))).append(", ")
                                    .append(escape.cote(productJson.getString("productName"))).append(", ")
                                    .append(escape.cote(productUrl)).append(", ")
                                    .append(escape.cote(productJson.getString("title"))).append(", ")
                                    .append(escape.cote(productJson.getString("description"))).append(", ")
                                    .append(escape.cote(productTypeId)).append(", ")
                                    .append(escape.cote(siteId)).append(", ")
                                    .append(escape.cote(catalogId)).append(", ")
                                    .append(escape.cote(folderId)).append(", ")
                                    .append(escape.cote(logedInUserId)).append(", ")
                                    .append(escape.cote(logedInUserId))
                                    .append(")");
                        }else{
                            dmlQuery.append("update products_definition set save_type=").append(escape.cote(productJson.getString("saveType")))
                                    .append(", name=").append(escape.cote(productJson.getString("productName")))
                                    .append(", url=").append(escape.cote(productUrl))
                                    .append(", title=").append(escape.cote(productJson.getString("title")))
                                    .append(", meta_description=").append(escape.cote(productJson.getString("description")))
                                    .append(", updated_by=").append(escape.cote(logedInUserId))
                                    .append(" where id=").append(escape.cote(productV2Id));
                        }

                        int productV2 = Etn.executeCmd(dmlQuery.toString());
                        rsLang.moveFirst();
                        while(rsLang.next()){
                            if(!isUpdate){
                                langMetaDiscriptionVal += escape.cote(parseNull(productJson.getString("description"))) + ",";
                                langMetaDiscription += "lang_"+rsLang.value("langue_id")+"_meta_description" +",";

                                langNameVal += escape.cote(parseNull(productJson.getString("productName"))) + ",";
                                langName += "lang_"+rsLang.value("langue_id")+"_name" +",";
                            }else{
                                langNameVal += "lang_"+rsLang.value("langue_id")+"_name = "+escape.cote(parseNull(productJson.getString("productName")))+", ";
                                langMetaDiscriptionVal += "lang_"+rsLang.value("langue_id")+"_meta_description = "+escape.cote(parseNull(productJson.getString("description")))+", ";
                            }

                        }

                        String templateType = "";
                        String templateId = "";
                        
                        Set rsTemplate = Etn.execute("select b.type,b.id from "+pagesDb+"bloc_templates b join product_types_v2 pt on b.id=pt.template_id where pt.id="+escape.cote(productTypeId));
                        if(rsTemplate.rs.Rows>0 && rsTemplate.next()){
                            templateId = parseNull(rsTemplate.value("id"));
                            templateType = parseNull(rsTemplate.value("type"));
                        }

                        String queryDml="";
                        if(!isUpdate){
                            queryDml="insert into products (product_uuid,"+langName+langMetaDiscription+
                                "catalog_id,folder_id,html_variant,product_type,created_by,updated_by,updated_on,product_version,product_definition_id,show_basket) values (uuid(),"+
                                langNameVal+langMetaDiscriptionVal+escape.cote(catalogId)+","+escape.cote(folderId)+",'all',"+escape.cote(templateType)+","+escape.cote(logedInUserId)+","+
                                escape.cote(logedInUserId)+",now(),'V2',"+escape.cote(productV2+"")+",'1')";

                        }else queryDml = "update products set "+langNameVal+langMetaDiscriptionVal+"updated_on=now(),updated_by="+escape.cote(logedInUserId)+",version=version+1 where id="+escape.cote(productV1Id);

                        int productV1 = Etn.executeCmd(queryDml);
                        
                        if(!isUpdate && productV2 >0 && productV1>0) message += "Product saved successfully";
                        else {
                            productV1= Integer.parseInt(productV1Id);
                            
                            Set rsPageofProduct = Etn.execute("select page_id from "+pagesDb+"products_map_pages where product_id="+escape.cote(productV1Id));
                            rsPageofProduct.next();
                            result.put("pageId",rsPageofProduct.value("page_id"));
                            message += "Product updated successfully";
                        }

                        status=STATUS_SUCCESS;
                        result.put("productId",productV1);
                        result.put("templateId",templateId);
                    }else{
                        errmsg += "Product url is not unique.";
                        status=STATUS_ERROR;
                    }
                }else{
                    errmsg += "Product url is required.";
                    status=STATUS_ERROR;
                }
            }else{
                errmsg += "Product name not unique.";
                status=STATUS_ERROR;
            }
        }else if(requestType.equals("getPageForProduct")){
            String productId = parseNull(request.getParameter("productId"));
            Set rs = Etn.execute("select page_id from "+pagesDb+"products_map_pages where product_id = "+escape.cote(parseNull(request.getParameter("productId"))));
            if(rs.next()){
                result.put("pageId",rs.value("page_id"));
                status = STATUS_SUCCESS;
            }
        }else if(requestType.equals("getProductV2ById")){
            Set rs = Etn.execute("select * from products_definition where id=(select product_definition_id from products where id="+escape.cote(parseNull(request.getParameter("productId")))+")");
            JSONObject rspObj = new JSONObject();
            if(rs.next()){
                for (String col : rs.ColName) {
                    rspObj.put(col.toLowerCase(),rs.value(col));
                }
                result.put("data",rspObj);
                status=STATUS_SUCCESS;
            }
        }else if(requestType.equals("deleteProductPermanently")){
            String productV1Id = parseNull(request.getParameter("productId"));
            
            Set rsProduct = Etn.execute("select * from products where id="+escape.cote(productV1Id));
            if(rsProduct.next() && rsProduct.value("product_version").equalsIgnoreCase("v2")){
            
                Etn.executeCmd("delete from products_definition where id="+escape.cote(rsProduct.value("product_definition_id")));

                Set rsPages = Etn.execute("select * from "+pagesDb+"products_map_pages where product_id="+escape.cote(productV1Id));
                while(rsPages.next()){
                    Etn.executeCmd("delete from "+pagesDb+"pages where parent_page_id="+escape.cote("page_id"));
                    Etn.executeCmd("delete from "+pagesDb+"structured_contents_details where content_id="+escape.cote("page_id"));
                    Etn.executeCmd("delete from "+pagesDb+"structured_contents where id="+escape.cote("page_id"));
                }

                Etn.executeCmd("delete from products where id="+escape.cote(productV1Id));
                status=STATUS_SUCCESS;
            }else{
                errmsg += "Invalid product id.";
                status=STATUS_ERROR;
            }
        }
    }catch(Exception e){
        e.printStackTrace();
        errmsg=e.getMessage();
        status=STATUS_ERROR;
    }

    result.put("status",status);
    if(errmsg.length() > 0){
        result.put("errmsg",errmsg);
        result.put("status",STATUS_ERROR);
    }
    result.put("message",message);
    out.write(result.toString());
%>