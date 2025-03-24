<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.asimina.util.ActivityLog, com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.List, java.util.LinkedHashMap, java.util.Map, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*,org.json.*, java.util.ListIterator"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../../common.jsp"%>

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
        String query="";
        Set rsProd = Etn.execute(query="SELECT p1.*  "+
                "FROM products_tbl p1 "+
                "INNER JOIN ("+
                "    SELECT p.* "+
                "    FROM products_tbl p "+
                "    INNER JOIN catalogs_tbl c ON p.catalog_id = c.id "+
                "    WHERE p.id="+escape.cote(id)+" AND c.site_id ="+escape.cote(siteId)+
                ") p2 ON p1.catalog_id = p2.catalog_id AND ("+
                "    (LENGTH(COALESCE(p1.lang_1_name, '')) > 0 AND LENGTH(COALESCE(p2.lang_1_name, '')) > 0 AND p1.lang_1_name = p2.lang_1_name) OR"+
                "    (LENGTH(COALESCE(p1.lang_2_name, '')) > 0 AND LENGTH(COALESCE(p2.lang_2_name, '')) > 0 AND p1.lang_2_name = p2.lang_2_name) OR"+
                "    (LENGTH(COALESCE(p1.lang_3_name, '')) > 0 AND LENGTH(COALESCE(p2.lang_3_name, '')) > 0 AND p1.lang_3_name = p2.lang_3_name) OR"+
                "    (LENGTH(COALESCE(p1.lang_4_name, '')) > 0 AND LENGTH(COALESCE(p2.lang_4_name, '')) > 0 AND p1.lang_4_name = p2.lang_4_name) OR"+
                "    (LENGTH(COALESCE(p1.lang_5_name, '')) > 0 AND LENGTH(COALESCE(p2.lang_5_name, '')) > 0 AND p1.lang_5_name = p2.lang_5_name)"+
                ")"+
                "WHERE p1.is_deleted = 1");
        if(rsProd.rs.Rows>0)
            return false;
        return true;
    }

    Boolean canFolderBeDeleted(com.etn.beans.Contexte Etn , String id, String siteId, String logedInUserId){
        String query="";
        Set rsProd=Etn.execute(query="SELECT * FROM products_folders_tbl WHERE name = (SELECT name FROM products_folders_tbl WHERE id = "+escape.cote(id)+") AND site_id = "+escape.cote(siteId)+" AND is_deleted = 1");

        if(rsProd.rs.Rows>0)
            return false;
        return true;
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

%>
<%
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

    if(requestType.equals("getCommercialProducts")){
           
            if(delete_id.length() == 0) delete_id = "0";
            if(parseInt(delete_id) > 0)
            {
                Set rsp = Etn.execute("select * from "+GlobalParm.getParm("PROD_DB")+".catalogs where catalog_version='V1' and id = " + escape.cote(delete_id));
                if(rsp.rs.Rows > 0)
                {
                    errmsg = "Catalog already in production. Cannot proceed with delete. You must delete from production first";
                }
                else
                {
                    if(verifyCatalogFunction(Etn,delete_id)){
                        Boolean delStatus = canCatalogBeDeleted(Etn,delete_id,siteId);
                        if(delStatus == true){
                        Etn.executeCmd("UPDATE products_folders SET is_deleted='1',updated_on=now(),updated_by="+escape.cote(logedInUserId)+" WHERE catalog_id = "+escape.cote(delete_id));
                        Etn.executeCmd("UPDATE products SET is_deleted='1',updated_on=now(),updated_by="+escape.cote(logedInUserId)+" WHERE catalog_id = "+escape.cote(delete_id));
                        Etn.executeCmd("UPDATE catalogs SET is_deleted='1',updated_on= now(),updated_by="+escape.cote(logedInUserId)+" WHERE id = "+ escape.cote(delete_id));
                        ActivityLog.addLog(Etn,request,(String)request.getSession().getAttribute("LOGIN"),delete_id,"TRASHED","Catalog",rsp.value("name"),rsp.value("site_id"));
                        message="successfully deleted";
                        }else{
                            Set catalogRs = Etn.execute("Select name from catalogs where id =" +escape.cote(delete_id));
                            catalogRs.next();
                            status = STATUS_ERROR;
                            errmsg += "\"" + catalogRs.value("name") + "\" can not be deleted as the same catalog is present in Trash.";

                        }

                    }else{
                        errmsg = "Cannot delete catalog. Its products are published, publishing or deleting.";
                    }
                }
            }
            String process = getProcess("catalog");
			String rowColor = "";
            
            String q = "SELECT " +
                        "c.id, " +
                        "c.name, " +
                        "c.catalog_type as type, " +
                        "DATE_FORMAT(c.updated_on, '%m/%d/%Y %H:%i:%s') as updated_on, " +
                        "DATE_FORMAT(c.created_on, '%m/%d/%Y %H:%i:%s') as created_on, " +
                        "l1.name AS created_by, " +
                        "l2.name AS updated_by, " +
                        "COUNT(tbl.id) AS nb_items, " +
                        "COALESCE(tbl2._dt, '') AS tbl2_dt, " +
                        "tbl2.phase as phase, " +
                        "COALESCE(tbl2.user_name, '') AS tbl2_user_name, " +
                        "COALESCE(tbl3.dt, '') AS tbl3_dt, " +
                        "COALESCE(tbl3.user_name, '') AS tbl3_user_name ,c.id as catalog_id, '' as uuid " +
                    "FROM catalogs c " +
                    "LEFT JOIN login l1 ON c.created_by = l1.pid " +
                    "LEFT OUTER JOIN login l2 ON c.updated_by = l2.pid " +
                    "LEFT JOIN ( " +
                        "SELECT " +
                            "p.id, " +
                            "p.lang_1_name, " +
                            "p.updated_by, " +
                            "p.created_by, " +
                            "p.catalog_id " +
                        "FROM products p " +
                        "WHERE p.folder_id = 0 " +
                        "UNION " +
                        "SELECT " +
                            "pf.id, " +
                            "pf.name, " +
                            "pf.updated_by, " +
                            "pf.created_by, " +
                            "pf.catalog_id " +
                        "FROM products_folders pf " +
                        "WHERE pf.parent_folder_id = 0 " +
                    ") tbl ON c.id = tbl.catalog_id " +
                    "LEFT JOIN ( " +
                        "SELECT " +
                            "DATE_FORMAT(pw.priority, '%m/%d/%Y %H:%i:%s') AS _dt, " +
                            "pw.phase, " +
                            "IFNULL(l3.name, '') AS user_name, " +
                            "pw.client_key " +
                        "FROM post_work pw " +
                        "LEFT JOIN login l3 ON l3.pid = pw.operador " +
                        "WHERE pw.status = 0 " +
                        "AND pw.phase IN ('published', 'publish_ordering') " +
                        "AND pw.proces = "+escape.cote(process)+" " +
                    ") tbl2 ON c.id = tbl2.client_key " +
                    "LEFT JOIN ( " +
                        "SELECT " +
                            "DATE_FORMAT(pw1.priority, '%m/%d/%Y %H:%i:%s') AS dt, " +
                            "IFNULL(l4.name, '') AS user_name, " +
                            "pw1.client_key " +
                        "FROM post_work pw1 " +
                        "LEFT JOIN login l4 ON l4.pid = pw1.operador " +
                        "WHERE pw1.status = 0 " +
                        "AND pw1.phase = 'deleted' " +
                    ") tbl3 ON c.id = tbl3.client_key " +
                    "WHERE catalog_version='V1' and c.site_id = "+escape.cote(siteId)+" AND c.is_deleted='0' " + 
                    "GROUP BY c.id, c.name " +
                    "ORDER BY c.name";
        
            Set rs = Etn.execute(q);
            boolean taxParamsDifferent = false;
            String prevTaxIncluded = "";
            String prevPriceWithTax = "";


            while(rs!=null && rs.next())
            {
                String statusArr[] = getCatalogPublishStatus(Etn, rs.value("id"), rs.value("version"));
                JSONObject data = new JSONObject();
                data.put("publishStatus",statusArr);
                data.put("ICON","folder");
                data.put("isCatalog",true);
                for (String col : rs.ColName){
                    if(col.equalsIgnoreCase("phase")){
                        String pubStatus = "publish";
                        if(parseNull(rs.value(col)).equalsIgnoreCase("publish_ordering")) {
                            pubStatus = "publish ordering";
                        }
                        else if(parseNull(rs.value(col)).equalsIgnoreCase("delete")){
                            pubStatus = "unpublish";
                        }
                        data.put("__ty",pubStatus);
                    }
                    

                    data.put(col,parseNull(rs.value(col)));
                }
                rspArray.put(data);
            }
            status = STATUS_SUCCESS;
            result.put("totalCount",rs.rs.Rows);
            result.put("recordsFiltered",rs.rs.Rows);
            result.put("recordsTotal",rs.rs.Rows);
            result.put("taxParamsDifferent",true);
            
    }
    else if(requestType.equals("getProducts")){
        String searchText = parseNull(request.getParameter("searchText"));
        String folderUuid = parseNull(request.getParameter("folderId"));
        String folderId = "0";
        int folderLevel = 0;
        String parentFolderId = "";

       if (folderUuid.length() > 0) {
            String q = "SELECT f.id, f.uuid, f.folder_level, IFNULL(pf.uuid,'') AS parent_folder_id "
                + " FROM products_folders f "
                + " LEFT JOIN products_folders pf ON pf.id = f.parent_folder_id "
                + " WHERE f.uuid = " + escape.cote(folderUuid)
                + " AND f.site_id = " + escape.cote(siteId);
            Set rs = Etn.execute(q);
            if (rs.next()) {
                folderId = rs.value("id");
                folderLevel = parseInt(rs.value("folder_level"));
                parentFolderId = parseNull(rs.value("parent_folder_id"));
            }
        }
        // make changes here
        if (!delete_id.isEmpty()) {
            
            if (delete_id_type.equalsIgnoreCase("product")) {
                
                    Boolean delStatus = canProductBeDeleted(Etn,delete_id,siteId,logedInUserId);
                
                    if(delStatus == true){

                    Etn.execute("Update products set is_deleted='1', updated_on =now(), updated_by="+
				    escape.cote(logedInUserId)+" where id="+escape.cote(delete_id));
                    message="successfully deleted";
                    }else{
                        status = STATUS_ERROR;
                        errmsg = "Product \"" + delete_product_name + "\" can not be deleted as duplicate present in Trash.";
                    }
            }
                    
                 else if (delete_id_type.equalsIgnoreCase("folder")) {
                    Boolean del_Status = canFolderBeDeleted(Etn,delete_id,siteId,logedInUserId);
                    if(del_Status == true){
                        Etn.execute("UPDATE products_folders_tbl SET is_deleted='1',updated_on=now(),updated_by="+escape.cote(logedInUserId)+
			            " WHERE id = "+escape.cote(delete_id));
                    }else if(del_Status == false){
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
                +" where f.catalog_id = "+escape.cote(catalogId)+" AND f.is_deleted='0'"
                +" and f.parent_folder_id = "+escape.cote(folderId)
                +" and f.site_id = "+escape.cote(siteId)
                +" order by order_seq";

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
                    status=STATUS_SUCCESS;
        
    }
    else if(requestType.equals("searchCommercialProduct")){
            if(delete_id.length() == 0) delete_id = "0";
            if(parseInt(delete_id) > 0)
            {
                if(delete_id_type.equalsIgnoreCase("catalog")){
                    Set rsp = Etn.execute("select * from "+GlobalParm.getParm("PROD_DB")+".catalogs where id = " + escape.cote(delete_id));
                    if(rsp.rs.Rows > 0)
                    {
                        errmsg = "Catalog already in production. Cannot proceed with delete. You must delete from production first";
                    }
                    
                    
                    if(verifyCatalogFunction(Etn,delete_id)){
                            Boolean delStatus = canCatalogBeDeleted(Etn,delete_id,siteId);
                            if(delStatus == true){
                                Etn.executeCmd("UPDATE products_folders SET is_deleted='1',updated_on=now(),updated_by="+escape.cote(logedInUserId)+" WHERE catalog_id = "+escape.cote(delete_id));
                                Etn.executeCmd("UPDATE products SET is_deleted='1',updated_on=now(),updated_by="+escape.cote(logedInUserId)+" WHERE catalog_id = "+escape.cote(delete_id));
                                Etn.executeCmd("UPDATE catalogs SET is_deleted='1',updated_on= now(),updated_by="+escape.cote(logedInUserId)+" WHERE id = "+ escape.cote(delete_id));
                                ActivityLog.addLog(Etn,request,(String)request.getSession().getAttribute("LOGIN"),delete_id,"TRASHED","Catalog",rsp.value("name"),rsp.value("site_id"));
                                message="successfully deleted";
                            }else{
                                Set catalogRs = Etn.execute("Select name from catalogs where id =" +escape.cote(delete_id));
                                catalogRs.next();
                                status = STATUS_ERROR;
                                errmsg += "\"" + catalogRs.value("name") + "\" can not be deleted as the same catalog is present in Trash.";

                            }
                        
                    }
                    else
                    {
                            errmsg = "Cannot delete catalog. Its products are published, publishing or deleting.";
                    }
                }

                    else if(delete_id_type.equalsIgnoreCase("product")){
                        Boolean productDelStatus = canProductBeDeleted(Etn,delete_id,siteId,logedInUserId);
                            if(productDelStatus == true){
                                Etn.execute("Update products set is_deleted='1', updated_on =now(), updated_by="+
				                escape.cote(logedInUserId)+" where id="+escape.cote(delete_id));
                                message="successfully deleted";
                            }else{
                                status = STATUS_ERROR;
                                errmsg = "Product \"" + delete_product_name + "\" can not be deleted as duplicate present in Trash.";
                            }

                    }
                    
            }
            




        String searchText = parseNull(request.getParameter("searchText"));
            String process = getProcess("catalog");
			String rowColor = "";
            String q ="";
            int totalCount = 0;
            Set rs ;
            ArrayList<String> catalogIds = new ArrayList<String>();

            if(catalogId.length() == 0){
                q = "SELECT " +
                            "c.id, " +
                            "c.name, " +
                            "c.catalog_type as type, " +
                            "DATE_FORMAT(c.updated_on, '%m/%d/%Y %H:%i:%s') as updated_on, " +
                            "DATE_FORMAT(c.created_on, '%m/%d/%Y %H:%i:%s') as created_on, " +
                            "l1.name AS created_by, " +
                            "l2.name AS updated_by, " +
                            "COUNT(tbl.id) AS nb_items, " +
                            "COALESCE(tbl2._dt, '') AS tbl2_dt, " +
                            "tbl2.phase as phase, " +
                            "COALESCE(tbl2.user_name, '') AS tbl2_user_name, " +
                            "COALESCE(tbl3.dt, '') AS tbl3_dt, " +
                            "COALESCE(tbl3.user_name, '') AS tbl3_user_name " +
                        "FROM catalogs c " +
                        "LEFT JOIN login l1 ON c.created_by = l1.pid " +
                        "LEFT OUTER JOIN login l2 ON c.updated_by = l2.pid " +
                        "LEFT JOIN ( " +
                            "SELECT " +
                                "p.id, " +
                                "p.lang_1_name, " +
                                "p.updated_by, " +
                                "p.created_by, " +
                                "p.catalog_id " +
                            "FROM products p " +
                            "WHERE p.folder_id = 0 " +
                            "UNION " +
                            "SELECT " +
                                "pf.id, " +
                                "pf.name, " +
                                "pf.updated_by, " +
                                "pf.created_by, " +
                                "pf.catalog_id " +
                            "FROM products_folders pf " +
                            "WHERE pf.parent_folder_id = 0 " +
                        ") tbl ON c.id = tbl.catalog_id " +
                        "LEFT JOIN ( " +
                            "SELECT " +
                                "DATE_FORMAT(pw.priority, '%m/%d/%Y %H:%i:%s') AS _dt, " +
                                "pw.phase, " +
                                "IFNULL(l3.name, '') AS user_name, " +
                                "pw.client_key " +
                            "FROM post_work pw " +
                            "LEFT JOIN login l3 ON l3.pid = pw.operador " +
                            "WHERE pw.status = 0 " +
                            "AND pw.phase IN ('published', 'publish_ordering') " +
                            "AND pw.proces = "+escape.cote(process)+" " +
                        ") tbl2 ON c.id = tbl2.client_key " +
                        "LEFT JOIN ( " +
                            "SELECT " +
                                "DATE_FORMAT(pw1.priority, '%m/%d/%Y %H:%i:%s') AS dt, " +
                                "IFNULL(l4.name, '') AS user_name, " +
                                "pw1.client_key " +
                            "FROM post_work pw1 " +
                            "LEFT JOIN login l4 ON l4.pid = pw1.operador " +
                            "WHERE pw1.status = 0 " +
                            "AND pw1.phase = 'deleted' " +
                        ") tbl3 ON c.id = tbl3.client_key " +
                        "WHERE c.site_id = "+escape.cote(siteId)+" AND c.is_deleted='0' " + 
                        "AND c.name like "+escape.cote("%"+searchText+"%")+" " + 
                        "OR c.catalog_type like "+escape.cote("%"+searchText+"%")+" " + 
                        "OR updated_on like "+escape.cote("%"+searchText+"%")+" " +
                        "GROUP BY c.id , c.name " +
                        "ORDER BY c.name";
                System.out.println("query ==== "+q);
                rs = Etn.execute(q);
                boolean taxParamsDifferent = false;
                String prevTaxIncluded = "";
                String prevPriceWithTax = "";
                

                while(rs!=null && rs.next())
                {
                    String statusArr[] = getCatalogPublishStatus(Etn, rs.value("id"), rs.value("version"));
                    JSONObject data = new JSONObject();
                    data.put("publishStatus",statusArr);
                    data.put("ICON","folder");
                    data.put("isCatalog",true);
                    for (String col : rs.ColName){
                        if(col.equalsIgnoreCase("phase")){
                            String pubStatus = "publish";
                            if(parseNull(rs.value(col)).equalsIgnoreCase("publish_ordering")) {
                                pubStatus = "publish ordering";
                            }
                            else if(parseNull(rs.value(col)).equalsIgnoreCase("delete")){
                                pubStatus = "unpublish";
                            }
                            data.put("__ty",pubStatus);
                        }
                        

                        data.put(col,parseNull(rs.value(col)));
                    }
                    rspArray.put(data);
                }


                totalCount  += rs.rs.Rows;
            }

            q = "SELECT " +
                        "c.id " +
                    "FROM catalogs c " +
                    "WHERE c.site_id = "+escape.cote(siteId);
            if(catalogId.length()>0)
                q+=" AND c.id="+escape.cote(catalogId);
        
            rs = Etn.execute(q);

            while(rs!=null && rs.next())
            {
                catalogIds.add(rs.value("id"));
            }
            for(String cId:catalogIds){
                q = "select p.id, '' as uuid, 'product' as type, '-' as nb_items, coalesce(p.order_seq,999999) as order_seq, p.lang_1_name, p.lang_2_name, p.lang_3_name, p.lang_4_name, p.lang_5_name, p.version, case when prod_p.version is null then 'unpublished' when prod_p.version = p.version then 'published' else 'changed' end as publish_status, p.updated_on,p.created_on, f.name as familie_name, lg1.name as updated_by, lg.name as created_by, p.catalog_id, p.folder_id"
                    + " from products p "
                    + " left join "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".products prod_p on prod_p.id = p.id "
                    + " left outer join familie f on f.id = p.familie_id "
                    + " left outer join login lg on lg.pid = p.updated_by "
                    + " left join login lg1 on lg1.pid  = p.created_by  "
                    + " where p.catalog_id = " + escape.cote(cId)+" AND p.is_deleted='0' ";

                if(searchText.length() > 0){
                    q += " and (p.lang_1_name like " + escape.cote("%" + searchText + "%")
                        + " or p.lang_2_name like " + escape.cote("%" + searchText + "%")
                        + " or p.lang_3_name like " + escape.cote("%" + searchText + "%")
                        + " or p.lang_4_name like " + escape.cote("%" + searchText + "%")
                        + " or p.lang_5_name like " + escape.cote("%" + searchText + "%") 
                        + " or 'product' like " +escape.cote("%"+searchText+"%")
                        + ") ";
                }
                q += " union "
                    +" select f.id, f.uuid, 'folder' as type, IFNULL(tbcount.tcount,0) as nb_items, -1 as order_seq, f.name as lang_1_name, '' as lang_2_name, '' as lang_3_name, '' as lang_4_name, '' as lang_5_name,"
                    +" f.version as version, case when prod_f.version is null then 'unpublished' when prod_f.version = f.version then 'published' else 'changed' end as publish_status, f.updated_on, f.created_on, '' as familie_name, lg.name as last_updated_by, lg1.name as created_by, f.catalog_id,f.parent_folder_id as folder_id"
                    +" from products_folders f"
                    +" left join "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".products_folders prod_f on  prod_f.id = f.id"
                    +" left outer join login lg on lg.pid = f.updated_by "
                    +" left join login lg1 on lg1.pid = f.created_by "
                    +" LEFT JOIN ("
                    + "     SELECT folder_id, SUM(count)AS tcount"
                    + "     FROM ("
                    + "          SELECT folder_id, count(id) AS count"
                    + "          FROM products"
                    + "          GROUP BY folder_id"
                    + "          UNION ALL"
                    + "          SELECT parent_folder_id AS folder_id, count(id)"
                    + "          FROM products_folders pf"
                    + "          GROUP BY parent_folder_id"
                    + "          ) tcount"
                    + "     GROUP BY folder_id"
                    + "   ) tbcount ON tbcount.folder_id = f.id"
                    +" where f.catalog_id = "+escape.cote(cId)
                    +" and f.site_id = "+escape.cote(siteId)+" AND f.is_deleted='0'"
                    +" AND f.name like "+escape.cote("%" + searchText + "%")
                    +" OR 'folder' like "+escape.cote("%"+searchText+"%")
                    +" order by order_seq";

            
                    rs = Etn.execute(q);

        while(rs!=null && rs.next())
        {
            JSONObject data = new JSONObject();
            String statusArr[] = getProductPublishStatus(rs);
            data.put("publishStatus",statusArr);
            data.put("PHASE",rs.value("publish_status"));
            data.put("ICON",rs.value("type"));
            if(parseNull(rs.value("type")).equalsIgnoreCase("product")) data.put("isProduct",true);
            List<String> foldersName = new ArrayList<>();
            foldersName = generateSearchBreadcrumbs(foldersName,Etn,rs.value("folder_id"));
            String productPath = customBreadcrumb(foldersName,getCatalogName(Etn,rs.value("catalog_id")));
            data.put("NAME",getProductName(rs,getCatalogType(Etn,cId)));
            data.put("path",productPath);
            data.put("SRC",showProductImage(Etn,rs,getCatalogType(Etn,cId),siteId));
            data.put("isCatalog",false);
            for (String col : rs.ColName){
                data.put(col,parseNull(rs.value(col)));
            }
            status = STATUS_SUCCESS;
            rspArray.put(data);
        }
            totalCount+=rs.rs.Rows;
        }
        status=STATUS_SUCCESS;

    }

    result.put("status",status);
    if(errmsg.length() > 0){
    result.put("errmsg",errmsg);
    result.put("status",STATUS_ERROR);
    }
    result.put("message",message);
    result.put("data",rspArray);
    out.write(result.toString());
%>