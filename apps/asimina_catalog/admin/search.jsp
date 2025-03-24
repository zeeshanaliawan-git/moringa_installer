<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.Contexte, com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, org.json.JSONObject, org.json.JSONArray, com.etn.beans.app.GlobalParm, java.util.List, java.util.HashMap, com.etn.util.ItsDate"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="common.jsp"%>
<%!
   JSONArray getAllTags(Contexte Etn, String siteId){
        JSONArray tags = new JSONArray();
        Set rs = Etn.execute("select id,label,folder_id from tags where site_id = "+escape.cote(siteId)+ " order by label");
        if(rs != null){
            while(rs.next()){
                JSONObject tag = new JSONObject();
                tag.put("id",rs.value("id"));

                if(parseNull(rs.value("folder_id")).length() > 0){
                    Set tagFolder = Etn.execute("select * from tags_folders where id="+escape.cote(rs.value("folder_id")));
                    if(tagFolder.next()){
                        tag.put("label",parseNull(tagFolder.value("name")).replace("$","/")+"/"+parseNull(rs.value("label")));
                    }else{
                        tag.put("label",rs.value("label"));
                    }
                }else{
                    tag.put("label",rs.value("label"));
                }
                tags.put(tag);
            }
        }
        return tags;
    }
    String getRowColor(String publish_status){
        if( publish_status.equals("0")) return "danger";
        else if( publish_status.equals("1")) return "warning";
        else if( publish_status.equals("2")) return "success";
        else if( publish_status.equals("4") || publish_status.equals("")) return "white";
        else  return "danger";
    }
    String getMarketingQueries(String table, String process,  String viewType ,String status, String created_on ,String created_to, String published_on, String published_to, String searchText, String selectedsiteid, String[] tagIds ){
        String proddb =  com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
        String nameCol = "name";
        if(process.equals("additionalfee")) nameCol = "additional_fee";
        process = getProcess(process);

        String q = "select t."+nameCol+" as name, '"+viewType+"' as type, t.created_on, t.updated_on, t.id, '' as pid,'' as path,  case when coalesce(pt.id,0) = 0 then 0 when t.version = pt.version then 2 else 1 end  as publish_status, date_format(max(pw.insertion_date ), '%d/%m/%Y %H:%i:%s') as publish_date  , '"+process+"' as process , #ORDER_NUM# as order_id, '' as folder_id from "+table+" t left outer join post_work pw on pw.client_key = t.id and pw.phase = 'published' and  pw.proces = '"+process+"'  left outer join "+proddb+table+" pt  on pt.id = t.id where t."+nameCol+" like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);
        if(created_on.length()>0)  q += " and  t.created_on >= "+escape.cote(created_on);
        if(created_to.length()>0)  q += " and  t.created_on <= "+escape.cote(created_to);
        if(tagIds != null) q += " and  t.id  = null ";
        q += " GROUP BY t.id having 1=1";

        if(published_on.length()>0)  q += " and  publish_date >= "+escape.cote(published_on);
        if(published_to.length()>0)  q += " and  publish_date <= "+escape.cote(published_to);
        if(status.equals("Pub lished"))  q += " and  publish_status  = 2";
         if(status.equals("Changed"))  q += " and  publish_status  = 1";
        if(status.equals("Unpublished"))  q += " and  publish_status  = 0";
        return q;
    }
%>
<%

    //template types
    String TEMPLATE_STRUCTURED_CONTENT = "structured_content";
    String TEMPLATE_STRUCTURED_PAGE = "structured_page";
    String TEMPLATE_STORE = "store";


    //folders types
    String FOLDER_TYPE_PAGES = "pages";
    String FOLDER_TYPE_CONTENTS = "contents";
    String FOLDER_TYPE_STORE = "stores";


    String selectedsiteid = getSelectedSiteId(session);


    String searchText =  parseNull(request.getParameter("global_search"));
    String status =  parseNull(request.getParameter("status"));
    String type =  parseNull(request.getParameter("type"));
    String[]  tagIds =  request.getParameterValues("tagId");
    String[]  tagLabels = request.getParameterValues("tagLabel");

    String created_on =  parseNull(request.getParameter("created_on"));
    String created_to =  parseNull(request.getParameter("created_to"));
    String published_on =  parseNull(request.getParameter("published_on"));
    String published_to =  parseNull(request.getParameter("published_to"));


    String created_on_date = created_on;
    String created_to_date = created_to;
    String published_on_date = published_on;
    String published_to_date = published_to;

    if(created_on.length()>0) created_on =  ItsDate.stamp(ItsDate.getDate(created_on));
    if(created_to.length()>0) created_to = ItsDate.stamp(ItsDate.getDate(created_to)).substring(0,8) + "235959";

    if(published_on.length()>0) published_on = ItsDate.stamp(ItsDate.getDate(published_on));
    if(published_to.length()>0) published_to = ItsDate.stamp(ItsDate.getDate(published_to)).substring(0,8) + "235959";


    String PUBLISHED = "Published";
    String UNPUBLISHED = "Unpublished";
    String CHANGED = "Changed";

    ArrayList<String> types = new ArrayList<>();
    types.add("All");
    types.add("Catalogs");
    types.add("Products");
    types.add("Products Folders");
    types.add("Forms");
    types.add("Pages");
    types.add("Structured Pages");
    types.add("Stores");
    types.add("Structured Contents");
    types.add("Pages Folders");
    types.add("Stores Folders");
    types.add("Contents Folders");
    types.add("Dynamic Pages");
    types.add("Dynamic Components");
    types.add("Blocks");
    types.add("Block Templates");
    types.add("System Templates");
    types.add("Page Templates");
    types.add("RSS feeds");
    types.add("Tags");
    types.add("Come-withs");
    types.add("Subsidies");
    types.add("Promotions");
    types.add("Cart rules");
    types.add("Additional fees");
    types.add("Delivery fees");
    types.add("Delivery minimums");
    types.add("Quantity limits");

    String devdb = "";
    String tag_table = "";
    String process = "";
    String table ="";
    String viewType ="";
    String proddb = "";

//------------------------------------------------------------CATALOG------------------------------------------------------------------
    proddb =  com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
    process = getProcess("catalog");
    table = "catalogs";
    viewType = "Catalog";
    tag_table = "";
    String q_catalog = "select t.name, '"+viewType+"' as type, t.created_on, t.updated_on, t.id, '' as pid , '' as path, case when coalesce(pt.id,0) = 0 then 0 when t.version = pt.version then 2 else 1 end  as publish_status, date_format(max(pw.insertion_date ), '%d/%m/%Y %H:%i:%s') as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t left outer join post_work pw on pw.client_key = t.id and pw.phase = 'published' and  pw.proces = '"+process+"'  left outer join "+proddb+table+" pt  on pt.id = t.id where t.name like "+escape.cote("%"+searchText+"%")+" and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_catalog += " and  t.created_on >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_catalog += " and  t.created_on <= "+escape.cote(created_to);
    if(tagIds != null) q_catalog += " and  t.id  = null ";

    q_catalog += " GROUP BY t.id having 1=1";

    if(published_on.length()>0)  q_catalog += " and  publish_date >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_catalog += " and  publish_date <= "+escape.cote(published_to);
    if(status.equals(PUBLISHED))  q_catalog += " and  publish_status  = 2";
    if(status.equals(CHANGED))  q_catalog += " and  publish_status  = 1";
    if(status.equals(UNPUBLISHED))  q_catalog += " and  publish_status  = 0";
//------------------------------------------------------------PRODUCT------------------------------------------------------------------
    process = getProcess("product");
    table = "products";
    tag_table = "product_tags";
    viewType = "Products";
    String q_product = "select case  when (t.brand_name IS NULL || t.brand_name = '') then  coalesce(nullif(t.lang_1_name,''), nullif(t.lang_2_name,''), nullif(t.lang_3_name,'')) else concat(t.brand_name,' ',coalesce(nullif(t.lang_1_name,''), nullif(t.lang_2_name,''), nullif(t.lang_3_name,''))) end as name , concat('"+viewType+"',' - ',coalesce(t.product_type,''))  as type, t.created_on, t.updated_on, t.id, t.catalog_id as pid, '' as path, case when coalesce(pt.id,0) = 0 then 0 when t.version = pt.version then 2 else 1 end  as publish_status, date_format(max(pw.insertion_date ), '%d/%m/%Y %H:%i:%s') as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, pf.uuid as folder_id from "+table+" t left join products_folders pf on pf.id = t.folder_id left outer join post_work pw on pw.client_key = t.id and pw.phase = 'published' and  pw.proces = '"+process+"'  left outer join "+proddb+table+" pt  on pt.id = t.id left outer join "+tag_table+" tt on tt.product_id = t.id left outer join catalogs c on t.catalog_id = c.id  where  c.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_product += " and  t.created_on >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_product += " and  t.created_on <= "+escape.cote(created_to);
    if(tagIds != null){
        String taglist = "";
        for(int i =0; i <  tagIds.length; i++){
            if(i>0) taglist += ",";
            if(!tagIds[i].equals("")) taglist += escape.cote(tagIds[i]);
        }
        q_product += " and  tt.tag_id in ( "+taglist+" )";
    }
    q_product += " GROUP BY t.id having name like "+escape.cote("%"+searchText+"%");

    if(published_on.length()>0)  q_product += " and  publish_date >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_product += " and  publish_date <= "+escape.cote(published_to);
    if(status.equals(PUBLISHED))  q_product += " and  publish_status  = 2";
    if(status.equals(CHANGED))  q_product += " and  publish_status  = 1";
    if(status.equals(UNPUBLISHED))  q_product += " and  publish_status  = 0";

//------------------------------------------------------------PRODUCT FOLDER------------------------------------------------------------------
    process = "products_folders";
    table = "products_folders";
    viewType = "Product folder";
    String q_products_folders = "select  t.name , '"+viewType+"' as type, t.created_on, t.updated_on, t.id, t.catalog_id as pid, '' as path, case when coalesce(pt.id,0) = 0 then 0 when t.version = pt.version then 2 else 1 end  as publish_status, date_format(max(pw.insertion_date ), '%d/%m/%Y %H:%i:%s') as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, pf.uuid as folder_id from "+table+" t left join products_folders pf on pf.id = t.parent_folder_id left outer join post_work pw on pw.client_key = t.id and pw.phase = 'published' and  pw.proces = '"+getProcess("catalog")+"'  left outer join "+proddb+table+" pt  on pt.id = t.id left outer join "+tag_table+" tt on tt.product_id = t.id where t.name like "+escape.cote("%"+searchText+"%")+" and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_products_folders += " and  t.created_on >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_products_folders += " and  t.created_on <= "+escape.cote(created_to);
    if(tagIds != null) q_products_folders += " and  t.id  = null ";

    q_products_folders += " GROUP BY t.id having 1=1";

    if(published_on.length()>0)  q_products_folders += " and  publish_date >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_products_folders += " and  publish_date <= "+escape.cote(published_to);
    if(status.equals(PUBLISHED))  q_products_folders += " and  publish_status  = 2";
    if(status.equals(CHANGED))  q_products_folders += " and  publish_status  = 1";
    if(status.equals(UNPUBLISHED))  q_products_folders += " and  publish_status  = 0";



//------------------------------------------------------------Pages------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"freemarker_pages";
    process ="pages";
    tag_table = devdb+"pages_tags";
    viewType = "Page : blocks";
    String q_pages = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id,'' as pid, '' as path, case when t.publish_status != 'published' then 0 when (t.publish_status = 'published' and  t.updated_ts <= t.published_ts ) then 2 else 1  end as publish_status, date_format(t.published_ts, '%d/%m/%Y %H:%i:%s') as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t left outer join "+tag_table+" tt on tt.page_type = 'freemarker' and tt.page_id = t.id where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_pages += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_pages += " and  t.created_ts <= "+escape.cote(created_to);
    if(published_on.length()>0)  q_pages += " and  t.published_ts >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_pages += " and  t.published_ts <= "+escape.cote(published_to);
    if(tagIds != null){
        String taglist = "";
        for(int i =0; i <  tagIds.length; i++){
            if(!tagIds[i].equals("")) taglist += escape.cote(tagIds[i])+",";
        }
        if(taglist.length()>0) taglist = taglist.substring(0,taglist.length()-1);
        q_pages += " and  tt.tag_id in ( "+taglist+" )";
    }
    q_pages += " group by id having 1=1 ";
    if(status.equals(PUBLISHED))  q_pages += " and  publish_status  = '2'";
    if(status.equals(CHANGED))  q_pages += " and  publish_status  = '1'";
    if(status.equals(UNPUBLISHED))  q_pages += " and  publish_status  = '0'";
	
//------------------------------------------------------------Pages Folders------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"pages_folders";
    process ="pages_folders";
    viewType = "Page folder";
    String q_pages_folders = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id,'' as pid, '' as path, 2 as publish_status, '' as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, pf.uuid as folder_id from "+table+" t left outer join "+devdb+"pages_folders pf on pf.id = t.parent_folder_id where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_pages_folders += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_pages_folders += " and  t.created_ts <= "+escape.cote(created_to);
    if(published_on.length()>0)  q_pages_folders += " and  t.published_ts >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_pages_folders += " and  t.published_ts <= "+escape.cote(published_to);
    if(tagIds != null) q_catalog += " and  t.id  = null ";
    q_pages_folders += " group by id having 1=1 ";
    if(status.equals(PUBLISHED))  q_pages_folders += " and  publish_status  = '2'";
    if(status.equals(CHANGED))  q_pages_folders += " and  publish_status  = '1'";
    if(status.equals(UNPUBLISHED))  q_pages_folders += " and  publish_status  = '0'";
//------------------------------------------------------------stores Folders------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"stores_folders";
    process ="stores_folders";
    viewType = "Store folder";
    String q_stores_folders = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id,'' as pid, '' as path, 2 as publish_status, '' as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, pf.uuid as folder_id from "+table+" t left outer join "+devdb+"pages_folders pf on pf.id = t.parent_folder_id where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_stores_folders += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_stores_folders += " and  t.created_ts <= "+escape.cote(created_to);
    if(published_on.length()>0)  q_stores_folders += " and  t.published_ts >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_stores_folders += " and  t.published_ts <= "+escape.cote(published_to);
    if(tagIds != null) q_catalog += " and  t.id  = null ";
    q_stores_folders += " group by id having 1=1 ";
    if(status.equals(PUBLISHED))  q_stores_folders += " and  publish_status  = '2'";
    if(status.equals(CHANGED))  q_stores_folders += " and  publish_status  = '1'";
    if(status.equals(UNPUBLISHED))  q_stores_folders += " and  publish_status  = '0'";
//------------------------------------------------------------Contents Folders------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"structured_contents_folders";
    process ="contents_folders";
    viewType = "Contents folders";
    String q_contents_folders = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id,'' as pid, '' as path, 2 as publish_status, '' as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, pf.uuid as folder_id from "+table+" t left outer join "+devdb+"structured_contents_folders pf on pf.id = t.parent_folder_id where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_contents_folders += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_contents_folders += " and  t.created_ts <= "+escape.cote(created_to);
    if(published_on.length()>0)  q_contents_folders += " and  t.published_ts >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_contents_folders += " and  t.published_ts <= "+escape.cote(published_to);
    if(tagIds != null) q_catalog += " and  t.id  = null ";
    q_contents_folders += " group by id having 1=1 ";
    if(status.equals(PUBLISHED))  q_contents_folders += " and  publish_status  = '2'";
    if(status.equals(CHANGED))  q_contents_folders += " and  publish_status  = '1'";
    if(status.equals(UNPUBLISHED))  q_contents_folders += " and  publish_status  = '0'";

//------------------------------------------------------------Dynamic Pages------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"pages";
    process ="dynamic_pages";
    viewType = "Dynmaic Page";
    String q_dynamic_pages = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id,'' as pid, '' as path, case when t.publish_status != 'published' then 0 when (t.publish_status = 'published' and  t.updated_ts <= t.published_ts ) then 2 else 1  end as publish_status, date_format(t.published_ts, '%d/%m/%Y %H:%i:%s') as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t  where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid)+" and t.type = 'react'";
    if(created_on.length()>0)  q_dynamic_pages += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_dynamic_pages += " and  t.created_ts <= "+escape.cote(created_to);
    if(published_on.length()>0)  q_dynamic_pages += " and  t.published_ts >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_dynamic_pages += " and  t.published_ts <= "+escape.cote(published_to);
    if(tagIds != null) q_catalog += " and  t.id  = null ";

    q_dynamic_pages += " group by id having 1=1 ";
    if(status.equals(PUBLISHED))  q_dynamic_pages += " and  publish_status  = '2'";
    if(status.equals(CHANGED))  q_dynamic_pages += " and  publish_status  = '1'";
    if(status.equals(UNPUBLISHED))  q_dynamic_pages += " and  publish_status  = '0'";

//------------------------------------------------------------Dynamic Components------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"components";
    process ="dynamic_components";
    viewType = "Dynmaic Component";
    String q_dynamic_components = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id,'' as pid, '' as path, case when t.thumbnail_status = 'published' then 2 else 0 end as publish_status, '' as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t  where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_dynamic_components += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_dynamic_components += " and  t.created_ts <= "+escape.cote(created_to);
    if(tagIds != null) q_dynamic_components += " and  t.id  = null ";
    if(published_on.length()>0)  q_dynamic_components += " and  t.id = null";
    if(published_to.length()>0)  q_dynamic_components += " and  t.id = null";

    q_dynamic_components += " group by t.id  having 1=1";
    if(status.equals(PUBLISHED))  q_dynamic_components += " and  publish_status  = '2'";
    if(status.equals(UNPUBLISHED))  q_dynamic_components += " and  publish_status  = '0'";
    if(status.equals(CHANGED))  q_dynamic_components += " and  t.id  =  null";


//------------------------------------------------------------Block Template------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"bloc_templates";
    process ="block_templates";
    viewType = "Block Template";
    String q_block_template = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id,'' as pid, '' as path,'' as publish_status, '' as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t  where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid)+" and t.type != 'menu'";
    if(created_on.length()>0)  q_block_template += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_block_template += " and  t.created_ts <= "+escape.cote(created_to);
    if(!status.equals("All"))  q_block_template += " and  t.id = null";
    if(tagIds != null) q_block_template += " and  t.id  = null";
    if(published_on.length()>0)  q_block_template += " and  t.id = null";
    if(published_to.length()>0)  q_block_template += " and  t.id = null";


//------------------------------------------------------------System Template------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"bloc_templates";
    process ="block_templates";
    viewType = "Block Template";
    String q_system_template = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id, '' as pid, '' as path, '' as publish_status, '' as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t  where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid)+" and t.type = 'menu' and t.is_system = 1";
    if(created_on.length()>0)  q_system_template += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_system_template += " and  t.created_ts <= "+escape.cote(created_to);

    if(!status.equals("All"))  q_system_template += " and  t.id = null";
    if(tagIds != null) q_system_template += " and  t.id  = null";
    if(published_on.length()>0)  q_system_template += " and  t.id = null";
    if(published_to.length()>0)  q_system_template += " and  t.id = null";



//------------------------------------------------------------Page Template------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"page_templates";
    process ="page_templates";
    viewType = "Page Template";
    String q_page_template = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id,'' as pid,'' as path, '' as publish_status, '' as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t  where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);;
    if(created_on.length()>0)  q_page_template += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_page_template += " and  t.created_ts <= "+escape.cote(created_to);

    if(!status.equals("All"))  q_page_template += " and  t.id = null";
    if(tagIds != null) q_page_template += " and  t.id  = null";
    if(published_on.length()>0)  q_page_template += " and  t.id = null";
    if(published_to.length()>0)  q_page_template += " and  t.id = null";

//------------------------------------------------------------Blocs------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"blocs";
    tag_table = devdb+"blocs_tags";
    process = "blocks";
    viewType = "Block";
    String q_blocks = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id, '' as pid, '' as path,'' as publish_status, '' as publish_date , '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t left outer join "+tag_table+" tt on tt.bloc_id = t.id  where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_blocks += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_blocks += " and  t.created_ts <= "+escape.cote(created_to);
    if(tagIds != null){
        String taglist = "";
        for(int i =0; i <  tagIds.length; i++){
            if(!tagIds[i].equals("")) taglist += escape.cote(tagIds[i])+",";
        }
        if(taglist.length()>0) taglist = taglist.substring(0,taglist.length()-1);
        q_blocks += " and  tt.tag_id in ( "+taglist+" )";
    }
    if(!status.equals("All"))  q_blocks += " and  t.id = null";
    if(published_on.length()>0)  q_blocks += " and  t.id = null";
    if(published_to.length()>0)  q_blocks += " and  t.id = null";


//-------------------------------------------------------------------RSS -feeds-----------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"rss_feeds";
    viewType = "RSS feeds";
    process = "rss_feeds";
    String q_rssfeeds = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id, '' as pid, '' as path, case when is_active = 1 then 2 else 0 end as publish_status, '' as publish_date, '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t left outer join "+tag_table+" tt on tt.bloc_id = t.id  where t.name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_rssfeeds += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_rssfeeds += " and  t.created_ts <= "+escape.cote(created_to);
    if(tagIds != null) q_rssfeeds += " and  t.id  = null";
    if(published_on.length()>0)  q_rssfeeds += " and  t.id = null";
    if(published_to.length()>0)  q_rssfeeds += " and  t.id = null";

    q_rssfeeds += " group by t.id having 1 = 1 ";
    if(status.equals(PUBLISHED))  q_rssfeeds += " and publish_status = 2";
    if(status.equals(UNPUBLISHED))  q_rssfeeds += " and  publish_status = 0";
    if(status.equals(CHANGED))  q_rssfeeds += " and  t.id = null";

//------------------------------------------------------------Structured Content------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"structured_contents";
    viewType = "Structured Content";
    process = "structured_contents";
    String q_structure_content = "select t.name, '"+viewType+"' as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id, t.catalog_id as pid, '' as path, case when t.publish_status = 'unpublished' then 0 when (t.publish_status = 'published' and t.updated_ts <= t.published_ts) then 2 else 1  end  as publish_status, date_format(t.published_ts, '%d/%m/%Y %H:%i:%s') as publish_date , '"+process+"' as process, #ORDER_NUM# as order_id, pf.uuid as folder_id from "+table+" t left join "+devdb+"structured_contents_folders pf on pf.type = 'contents' and pf.id = t.folder_id where t.type = 'content' and t.name like "+escape.cote("%"+searchText+"%")+" and t.site_id =  "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_structure_content += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_structure_content += " and  t.created_ts <= "+escape.cote(created_to);
    if(published_on.length()>0)  q_structure_content += " and  t.published_ts >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_structure_content += " and  t.published_ts <= "+escape.cote(published_to);
    if(tagIds != null) q_structure_content += " and  t.id  = null";
    q_structure_content += " group by id having 1=1 ";
    if(status.equals(PUBLISHED))  q_structure_content += " and  publish_status  = '2'";
    if(status.equals(CHANGED))  q_structure_content += " and  publish_status  = '1'";
    if(status.equals(UNPUBLISHED))  q_structure_content += " and  publish_status  = '0'";

//------------------------------------------------------------Structured Page------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"structured_contents";
    viewType = "Page : News";
    process = "structured_pages";
    String q_structure_page = "select t.name, concat('Page : ', bt.name)  as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id, t.catalog_id as pid, '' as path, case when t.publish_status != 'published' then 0 when (t.publish_status = 'published' and t.updated_ts <= t.published_ts) then 2 else 1  end  as publish_status, date_format(t.published_ts, '%d/%m/%Y %H:%i:%s') as publish_date , '"+process+"' as process, #ORDER_NUM# as order_id, pf.uuid as folder_id from "+table+" t join "+devdb+"bloc_templates bt on bt.id = t.template_id left join "+devdb+"structured_contents_folders pf on pf.type = 'contents' and pf.id = t.folder_id where t.type = 'page' and t.name like "+escape.cote("%"+searchText+"%")+" and t.site_id =  "+escape.cote(selectedsiteid)+" and bt.type = "+escape.cote(TEMPLATE_STRUCTURED_PAGE);
    if(created_on.length()>0)  q_structure_page += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_structure_page += " and  t.created_ts <= "+escape.cote(created_to);
    if(published_on.length()>0)  q_structure_page += " and  t.published_ts >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_structure_page += " and  t.published_ts <= "+escape.cote(published_to);
    if(tagIds != null) q_structure_page += " and  t.id  = null";
    q_structure_page += " group by id having 1=1 ";
    if(status.equals(PUBLISHED))  q_structure_page += " and  publish_status  = '2'";
    if(status.equals(CHANGED))  q_structure_page += " and  publish_status  = '1'";
    if(status.equals(UNPUBLISHED))  q_structure_page += " and  publish_status  = '0'";

//------------------------------------------------------------Stores------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("PAGES_DB")+".";
    table =  devdb+"structured_contents";
    viewType = "Page : News";
    process = "stores";
    String q_store = "select t.name, concat('Store : ', bt.name)  as type, t.created_ts as created_on, t.updated_ts as updated_on, t.id, t.catalog_id as pid, '' as path, case when t.publish_status != 'published' then 0 when (t.publish_status = 'published' and t.updated_ts <= t.published_ts) then 2 else 1  end  as publish_status, date_format(t.published_ts, '%d/%m/%Y %H:%i:%s') as publish_date , '"+process+"' as process, #ORDER_NUM# as order_id, pf.uuid as folder_id from "+table+" t join "+devdb+"bloc_templates bt on bt.id = t.template_id left join "+devdb+"stores_folders pf on pf.type = 'stores' and pf.id = t.folder_id where t.type = 'page' and t.name like "+escape.cote("%"+searchText+"%")+" and t.site_id =  "+escape.cote(selectedsiteid)+" and bt.type = "+escape.cote(TEMPLATE_STORE);
    if(created_on.length()>0)  q_store += " and  t.created_ts >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_store += " and  t.created_ts <= "+escape.cote(created_to);
    if(published_on.length()>0)  q_store += " and  t.published_ts >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_store += " and  t.published_ts <= "+escape.cote(published_to);
    if(tagIds != null) q_store += " and  t.id  = null";
    q_store += " group by id having 1=1 ";
    if(status.equals(PUBLISHED))  q_store += " and  publish_status  = '2'";
    if(status.equals(CHANGED))  q_store += " and  publish_status  = '1'";
    if(status.equals(UNPUBLISHED))  q_store += " and  publish_status  = '0'";

//------------------------------------------------------------Marketing------------------------------------------------------------------

    String q_comwith  =  getMarketingQueries("comewiths", "comewith","Come-withs",status, created_on, created_to, published_on, published_to, searchText, selectedsiteid,tagIds);
    String q_cartrule  =  getMarketingQueries("cart_promotion", "cartrule","Cart rules",status, created_on, created_to, published_on, published_to, searchText, selectedsiteid,tagIds);
    String q_additionalfee  =  getMarketingQueries("additionalfees", "additionalfee","Additional fees",status, created_on, created_to, published_on, published_to, searchText, selectedsiteid,tagIds);
    String q_deliveryfee  =  getMarketingQueries("deliveryfees", "deliveryfee","Delivery fees",status, created_on, created_to, published_on, published_to, searchText, selectedsiteid,tagIds);
    String q_quantitylimit =  getMarketingQueries("quantitylimits", "quantitylimit","Quantity limits",status, created_on, created_to, published_on, published_to, searchText, selectedsiteid ,tagIds);
    String q_deliverymin =  getMarketingQueries("deliverymins", "deliverymin","Delivery minimums",status, created_on, created_to, published_on, published_to, searchText, selectedsiteid,tagIds);
    String q_promotions =  getMarketingQueries("promotions", "promotion","Promotions",status, created_on, created_to, published_on, published_to, searchText, selectedsiteid,tagIds);
    String q_subsidy =  getMarketingQueries("subsidies", "subsidy","Subsidy",status, created_on, created_to, published_on, published_to, searchText, selectedsiteid,tagIds);

//------------------------------------------------------------Forms------------------------------------------------------------------
    devdb =  com.etn.beans.app.GlobalParm.getParm("FORMS_DB")+".";
        table =  devdb+"process_forms_unpublished";
    viewType = "Form";
    process = "forms";
    String q_forms = "select t.process_name as name, '"+viewType+"' as type, t.created_on , t.updated_on, t.form_id as  id , '' as pid, '' as path, case  when coalesce(pf.form_id,0) = '0'  then 0 when t.version = pf.version then 2 else 1 end as publish_status, date_format(t.to_publish_ts, '%d/%m/%Y %H:%i:%s') as publish_date , '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t left outer join "+devdb+"process_forms pf on pf.form_id = t.form_id where t.process_name like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_forms += " and  t.created_on >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_forms += " and  t.created_on <= "+escape.cote(created_to);
    if(published_on.length()>0)  q_forms += " and  t.to_publish_ts >= "+escape.cote(published_on);
    if(published_to.length()>0)  q_forms += " and  t.to_publish_ts <= "+escape.cote(published_to);
    if(tagIds != null) q_forms += " and  t.form_id  = null";
    q_forms +=  " group by id having  1=1 ";
    if(status.equals(PUBLISHED))  q_forms += " and  publish_status  = '2'";
    if(status.equals(CHANGED))  q_forms += " and  publish_status  = '1'";
    if(status.equals(UNPUBLISHED))  q_forms += " and  publish_status  = '0'";


//------------------------------------------------------------TAGS------------------------------------------------------------------
    table =  "tags";
    viewType = "Tags";
    process = "tags";
    String q_tags = "select t.label as name, '"+viewType+"' as type, t.created_on ,'' as updated_on, t.id as  id, '' as pid, '' as path, '' as publish_status, '' as publish_date , '"+process+"' as process, #ORDER_NUM# as order_id, '' as folder_id from "+table+" t  where t.label like "+escape.cote("%"+searchText+"%")+"  and t.site_id  = "+escape.cote(selectedsiteid);
    if(created_on.length()>0)  q_tags += " and  t.created_on >= "+escape.cote(created_on);
    if(created_to.length()>0)  q_tags += " and  t.created_on <= "+escape.cote(created_to);

    if(!status.equals("All"))  q_tags += " and  t.id = null";
    if(tagIds != null) q_tags += " and  t.id  = null";
    if(published_on.length()>0)  q_tags += " and  t.id = null";
    if(published_to.length()>0)  q_tags += " and  t.id = null";

    String q = "";
    //23
    int orderNum = 0;
    String orderNumTem = "#ORDER_NUM#";
    if(type.equals("All") ||  type.equals("")){
        q = q_catalog.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_product.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_products_folders.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_forms.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_pages.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_structure_page.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_store.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_structure_content.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_pages_folders.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_stores_folders.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_contents_folders.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_dynamic_pages.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_dynamic_components.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_blocks.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_block_template.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_system_template.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_page_template.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_rssfeeds.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_tags.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_comwith.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_subsidy.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_promotions.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_cartrule.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_additionalfee.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_deliveryfee.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_deliverymin.replaceAll(orderNumTem, String.valueOf(orderNum++))
        +" union "+q_quantitylimit.replaceAll(orderNumTem, String.valueOf(orderNum++));

    }else if(type.equals("Catalogs")){
        q = q_catalog.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Products")){
        q = q_product.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Products Folders")){
        q = q_products_folders.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Pages")){
        q = q_pages.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Pages Folders")){
        q = q_pages_folders.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Stores Folders")){
        q = q_stores_folders.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }
    else if(type.equals("Blocks")){
        q = q_blocks.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Forms")){
        q = q_forms.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("RSS feeds")){
        q = q_rssfeeds.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Tags")){
        q = q_tags.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Structured Contents")){
        q = q_structure_content.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Contents Folders")){
        q = q_contents_folders.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Come-withs")){
        q = q_comwith.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Promotions")){
        q = q_promotions.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Cart rules")){
        q = q_cartrule.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Subsidies")){
        q = q_subsidy.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Delivery fees")){
        q = q_deliveryfee.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Delivery minimums")){
        q = q_deliverymin.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Quantity limits")){
        q = q_quantitylimit.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if(type.equals("Additional fees")){
        q = q_additionalfee.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if (type.equals("Structured Pages")){
        q  = q_structure_page.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if (type.equals("Stores")){
        q  = q_store.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if (type.equals("Dynamic Pages")){
        q  = q_dynamic_pages.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if (type.equals("Dynamic Components")){
        q  = q_dynamic_components.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if (type.equals("Block Templates")){
        q  = q_block_template.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if (type.equals("Page Templates")){
        q  = q_page_template.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }else if (type.equals("System Templates")){
        q  = q_system_template.replaceAll(orderNumTem, String.valueOf(orderNum++));
    }
    q += " order by order_id, name";
    Set rs = Etn.execute(q);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Search</title>

    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>
    <style>
        .modal-body {
            max-height: calc(100vh - 210px);
            overflow-y: auto;
        }
    </style>
</head>

<%
breadcrumbs.add(new String[]{"Search Results", ""});	
%>

<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
		<div style="padding:0px 30px">

			<!-- Title + buttons -->
			<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
				<h1 class="h2">Search results</h1>
				<div class="btn-toolbar mb-2 mb-md-0">
					<div class="btn-toolbar mb-2 mb-md-0 mt-2">
						<div class="btn-group mr-2">
							<button onclick="goBack()" class="btn btn-primary">Back</button>
						</div>
						<div class="btn-group ">
							<button class="btn btn-danger"  onclick="onbtnclickpublish('multi')" >Publish</button>
							<button class="btn btn-danger"   onclick="onbtnclickpublish('multidelete')" >Unpublish</button>
							<button class="btn btn-danger" onclick="deleteItems()">Delete</button>
						</div>
					</div>
				</div>
			</div>
			<!-- /Title + buttons -->

			<div class="col-xs-12 col-sm-12 col-md-12 col-lg-12" style="padding: 15px; background: #fff; border-radius: 6px; margin-bottom: 15px; margin-top:30px">
				<form id="frmSearch" class="form-horizontal" action="search.jsp" method="post">

					<div class="row">
						<div class="col-sm-12">
							<div class=" form-group">
								<label class="control-label">Search</label>
								<div>
									<input  class="form-control form-control-lg" type="text"  id="global_search" name="global_search" value="<%=searchText%>"  style="border:2px solid rgb(228, 231, 234)">
								</div>
							</div>
						</div>
						<div class="col-sm-6">

						</div>
					</div>
					<div class="row">
						<div class="col-sm-6">
							<div class=" form-group">
								<label class="control-label">Status</label>
								<div>
									<select value="<%=status%>" multiple class="form-control" id="status" name="status">
										<option value="All" <%if(status.equals("All") || status.equals("")){%>selected<%}%>  >All</option>
										<option value="Published"  <%if(status.equals(PUBLISHED)){%>selected<%}%>  >Published</option>
										<option value="Unpublished" <%if(status.equals(UNPUBLISHED)){%>selected<%}%>  >Unpublished</option>
										<option value="Changed"  <%if(status.equals(CHANGED)){%>selected<%}%>  >Changed</option>
									</select>
								</div>
							</div>
						</div>
						<div class="col-sm-6">
							<div class=" form-group">
								<label class="control-label">Type</label>
								<div>
									<select   multiple class="form-control" id="type" name="type">
										<%
										for(int i =0; i<types.size(); i++){
										%>
											<option value="<%=types.get(i)%>" <%if(type.equals(types.get(i)) || (type.equals("")&&i==0) ){%>selected<%}%> ><%=types.get(i)%></option>
										<%}%>

									</select>
								</div>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-sm-3">
							<div class=" form-group">
								<label class=" control-label">Created date</label>
								<div class="">
									<input  class="form-control" type="text" id="created_on" name="created_on" value="<%=created_on_date%>">
									<strong>To : </strong>
									<input  class="form-control ctextdatetime" id="created_to" type="text" name="created_to" value="<%=created_to_date%>">
								</div>
							</div>
						</div>
						<div class="col-sm-3">
							<div class=" form-group">
								<label class=" control-label">Published date</label>
								<div class="">
									<input  class="form-control ctextdatetime" id="published_on" type="text" name="published_on" value="<%=published_on_date%>">
									<strong>To : </strong>
									<input  class="form-control ctextdatetime" id="published_to"  type="text" name="published_to" value="<%=published_to_date%>">
								</div>
							</div>
						</div>
						<div class="col-sm-6">
							<div class=" form-group">
								<label class="col-sm-3 control-label">Tag</label>
								<div class="col-sm-9">
									<input class="form-control" type="text" id="tags" name="tags" value="" placeholder="search and add (by clicking return)">
								</div>
							</div>
							<div class="form-group ">
						<div class="col">
						</div>
						<div class="col-9" style="display: flex;flex-direction: row;" id="tagsDiv">
					</div>
						</div>

					</div>
					<div class="row" style="justify-content: center;flex: 1">
						<div class="col-sm-12 text-center">
							<div class="" role="group" aria-label="controls">
								<button onclick="onSearch()" type="button"  class="btn btn-success">Search</button>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							</div>
						</div>
					</div>
				</form>
			</div>
		</div>
			<form id="frm" class="form-horizontal" action="search.jsp" method="post" >
				<input id ="delete_id" type="hidden" name="delete_id">
				<input id ="delete_all" type="hidden" value='0'  name="delete_all">

				<table class="table table-hover" id="table-pages">
					<thead class="thead-dark">
						<tr>
							<th scope="col"><input type="checkbox" class="" id="sltall"></th>
							<th scope="col">Item name</th>
							<th scope="col">Type</th>
							<th scope="col">Created</th>
							<th scope="col">Last published</th>
							<th scope="col">Last changes</th>
							<th scope="col" style="width:90px">Actions</th>
						</tr>
					</thead>
					<tbody>
						<%
							while(rs.next()){
						%>

						<tr class='table-<%=getRowColor(parseNull(rs.value("publish_status")))%>'>
							<th scope="row">
								<input type="checkbox" class="slt_option"  value='<%=getValue(rs,"id","")%>' >
								<input type="hidden" class="process" value='<%=getValue(rs,"process","")%>' >
							</th>
							<td><%=getValue(rs,"name","")%></td>
							<td><%=getValue(rs,"type","")%></td>
							<td><%=getValue(rs,"created_on","")%></td>
							<td><%=getValue(rs,"publish_date","")%></td>
							<td><%=getValue(rs,"updated_on","")%></td>
							<td class="text-right">
								<button class="btn btn-sm btn-primary" type="button" onclick="editProcess('<%=getValue(rs,"id","")%>','<%=getValue(rs,"process","")%>','<%=getValue(rs,"pid","")%>','<%=getValue(rs,"folder_id","")%>')" ><i data-feather="edit"></i></button>
								<%
									if(parseNull(rs.value("publish_status")).equals("0") || parseNull(rs.value("publish_status")).equals("") || rs.value("process").contains("folder") ){
								%>
								<button class="btn btn-sm btn-danger" type="button" onclick="deleteItems('<%=getValue(rs,"id","")%>','<%=getValue(rs,"process","")%>')"><i data-feather="trash-2"></i></button>
								<%
									}else{
								%>
								<button class="btn btn-sm btn-danger" type="button" onclick="onbtnclickpublish('multidelete','<%=getValue(rs,"id","")%>','<%=getValue(rs,"process","")%>')"><i data-feather="x"></i></button>
								<%}%>
							</td>
						</tr>
						<%}%>

					</tbody>
				</table>
			</from>

		</div>
		<!-- /Page content -->
	<!-- /main container -->
    </div>
    </div>

    <!-- Modal -->
    <div w3-include-html="zzz-modal-add-site.html"></div>
    <div w3-include-html="zzz-modal-new-page.html"></div>
    <div w3-include-html="zzz-modal-edit-page.html"></div>
    <div w3-include-html="zzz-modal-edit-page-devices.html"></div>

    <div class="modal fade" id="publishModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="publishModalTitle"></h5>
            <button type="button" class="close" onclick="closeProcessModal(true)" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <table  class="table table-borderless">
              <thead>
                <tr>
                  <th scope="col">Process</th>
                  <th scope="col">Status</th>
                  <th scope="col">Message</th>
                </tr>
              </thead>
              <tbody id="processTableBody">

               </tbody>
                </table>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="closeProcessModal(true)">Close</button>
          </div>
        </div>
      </div>
    </div>

    <div style="display: none;">
        <iframe src='<%=GlobalParm.getParm("PAGES_APP_URL")%>admin/pagesAjax.jsp'></iframe>
    </div>
    <div style="display: none;">
        <iframe src='<%=GlobalParm.getParm("PAGES_APP_URL")%>admin/structuredContentsAjax.jsp'></iframe>
    </div>
    <div style="display: none;">
        <iframe src='<%=GlobalParm.getParm("PAGES_APP_URL")%>admin/structuredCatalogsAjax.jsp'></iframe>
    </div>
    <div style="display: none;">
        <iframe src='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>ajax/publishAjax.jsp'></iframe>
    </div>


<div class="modal fade" tabindex="-1" role="dialog" id='logindlg'>
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content">
            <form id="publishLoginForm" action="" class="loginForm" >
                <div class="modal-header">
                    <h5 class="modal-title">Connection for Publication</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div>
                        <div class="alert alert-danger invalid-feedback errorMsg" role="alert" style='display:none'></div>
                        <div class="form-group">
                            <input name="username" placeholder="username" class="form-control" type="text" id="lgusername" required="required" />
                        </div>
                        <div class="form-group">
                            <input name="password" placeholder="password" class="form-control" type="password" id="lgpassword" required="required" />
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-dismiss="modal">Close</button>
                    <button type="button" onclick="publishLogin()" class="btn btn-success" >Connect</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" tabindex="-1" role="dialog" id='publishdlg'>
    <div class="modal-dialog " role="document">
        <div class="modal-content">
            <div class="modal-body">
                <div class="container-fluid">

                <div class="form-group row">
                    <div class="col">
                        <div class="publishMessage">

                        </div>
                    </div>
                    <div class="col-1">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                </div>
                <div class="form-group row">
                    <label  class="col-sm-3 col-form-label">
                        <span  class="text-capitalize actionName"></span>
                    </label>
                    <div class="col-sm-9">
                        <button type="button" class="btn btn-primary publishNowBtn"
                             onclick="publishnow()" >Now</button>
                    </div>
                </div>
                <div class="form-group row">
                    <label  class="col-sm-3 col-form-label">
                        <span class="text-capitalize actionName"></span> on
                    </label>
                    <div class="col-sm-9">
                        <div class="input-group">
                            <input type="text" class="form-control" name="publishTime" value=""
                                 id='publishOnDatetimepicker'>
                            <div class="input-group-append">
                                <button class="btn btn-primary  rounded-right publishOnBtn" type="button"
                                    onclick="publishon()">OK</button>
                            </div>
                            <div class="invalid-feedback">Please specify date and time</div>
                        </div>
                    </div>
                </div>
                </div>
            </div>
        </div>
    </div>
</div>
    <script type="application/javascript">

    var allTags = <%=getAllTags(Etn, getSelectedSiteId(session))%>;

    function tagExists(tag){
        var doesTagExist = false;
        $("input[type='hidden'][name='tagId']").each(function(i,o){
            if($(o).val() === tag.id){
               doesTagExist = true;
            }
            return;
        });
        return doesTagExist;
    }

    function addTag(tag){
        if(!tagExists(tag)){
            $('#tagsDiv').append('<div style="margin-left: 20px; margin-top: 10px;"><button class="btn btn-pill btn-block btn-secondary" type="button"><strong onclick="delete_selected_on(this)" style="color:#f16e00; cursor: pointer;">X</strong> '+tag.label+'</button> <input type="hidden" name="tagId"   value="'+tag.id+'"><input type="hidden" name="tagLabel"   value="'+tag.label+'"> </div>');
        }
    }
    <% if(tagIds!=null){for( int i = 0; i<tagIds.length; i++){%>
        addTag({id:'<%=tagIds[i]%>', label:'<%=tagLabels[i]%>'});
    <%}}%>

    var processes = null;
    var pType = "";
    var processCount = -1;
    var publishOnField = $("#publishOnDatetimepicker");
    var publishId = null;
    var publishProcess = null;

    jQuery(document).ready(function(){

        feather.replace();

        flatpickr(document.querySelector("#publishOnDatetimepicker"), {
            enableTime: true,
            dateFormat: "d-m-Y H:i",
            time_24hr: true,
            allowInput: true
        });


        $('#table-pages').DataTable( {
            responsive: true,
            pageLength: 50,
            columnDefs: [
                {targets: [-1], searchable: false},
                {targets: [0,-1], orderable: false},
            ]
        });

        $("#created_to,#created_on,#published_to,#published_on").flatpickr({
            "dateFormat": "d/m/Y",
            "wrap": true,
            "clickOpens": false,
            "onChange": function(selectedDates, dateStr, instance) {
                instance.close();
            }
        });


        initTagAutocomplete($( "#tags" ),false,allTags,true);


        $("#sltall").click(function()
        {
            if($(this).is(":checked"))
            {
                $(".slt_option").each(function(){$(this).prop("checked",true)});
            }
            else
            {
                $(".slt_option").each(function(){$(this).prop("checked",false)});
            }
        });

     });

    publishLogin=function()
    {
        onprodloginok();
    }

    publishon=function()
    {
        if(publishOnField.val() == '')
        {
            publishOnField.addClass('is-invalid');
            publishOnField.focus();
            return false;
        }
        $("#publishdlg").modal('hide');
        _publish(publishOnField.val());
    };

    publishnow=function()
    {
        $("#publishdlg").modal('hide');
        _publish("now");
    };

    onbtnclickpublish=function(publishtype, id, process)
    {

        publishId = id;
        publishProcess = process;
        pType = publishtype;

        if ($(".slt_option:checked").length > 0 || id){
            $.ajax({
                url : '<%=request.getContextPath()%>/admin/isprodpushlogin.jsp',
                type: 'GET',
                dataType:'json',
                success : function(json)
                {
                    if(json.is_prod_login == 'true') {
                        showpublishdlg();
                    }
                    else{
                        var loginModal = $("#logindlg");
                        var loginForm = loginModal.find(".loginForm");
                        loginModal.find(".errorMsg").hide();
                        loginModal.modal("show");
                    }
                },
                error : function(){
                    bootNotifyError("Error while communicating with the server");
                }
            });
        }else{
            bootNotify("No items selected","success");
        }
    };

    onprodloginok=function()
    {
        var modal = $("#logindlg");
        var errorMsg = modal.find(".errorMsg");
        var username = modal.find('[name=username]');
        var password = modal.find('[name=password]');
        errorMsg.html("").hide();
        if(username.val().trim() == "" || password.val().trim() == "") {
            return false;
        }

        $.ajax({
            url : '<%=request.getContextPath()%>/admin/prodaccesslogin.jsp',
            type: 'POST',
            data: {username : username.val(), password : password.val()},
            dataType:'json',
            success : function(json)
            {
                if(json.resp == 'error')
                {
                    errorMsg.html(json.msg).show();
                }
                else
                {
                    modal.modal('hide');
                    showpublishdlg();
                }
            },
            error : function()
            {
                bootNotifyError("Error while communicating with the server");
            }
        });
    };

    showpublishdlg=function()
    {
        processes = {
        "forms":[],
        "comewiths":[],
        "promotions":[],
        "subsidies":[],
        "cartrules":[],
        "additionalfees":[],
        "deliveryfees":[],
        "deliverymins":[],
        "quantitylimits":[],
        "catalogs":[],
        "products":[],
        "pages":[],
        "dynamic_pages":[],
        "structured_pages":[],
        "stores":[],
        "structured_contents":[],
        "dynamic_components":[],
        };
        var flag = false;
        if(publishId){
            if(processes[publishProcess]){
                processes[publishProcess].push(publishId);
                flag =true;
            }
        }else{
            $(".slt_option").each(function(){
                if($(this).is(":checked") == true) {
                    if(processes[$(this).next(".process")[0].value] ){
                        processes[$(this).next(".process")[0].value].push($(this).val());
                        flag =true;
                    }
                }
            });
        }

        var t = pType == 'multi'?"publish":"unpublish";
        if(!flag){bootNotify("Cannot be "+t+"ed");return false;}

        var publishMessage = "Are you sure you want to "+t;
        $('#processTableBody').html("");
        for (var [key, value] of Object.entries(processes)){
            if(value.length>0){
                publishMessage += " "+capitalize(key)+"("+value.length+")";
                addProcessRow(key+"("+value.length+")");
            }
        }
        publishMessage += " ?";
        $('.publishMessage').html(publishMessage);
        $('.actionName').html(t);
        publishOnField.val("");
        $("#publishdlg").modal('show');
    };

      deleteItems=function(id, type){
        var action  = "delete";
        processes = {
        "forms":[],
        "comewiths":[],
        "promotions":[],
        "subsidies":[],
        "cartrules":[],
        "additionalfees":[],
        "deliveryfees":[],
        "deliverymins":[],
        "quantitylimits":[],
        "catalogs":[],
        "products":[],
        "products_folders":[],
        "pages":[],
        "pages_folders":[],
        "stores_folders":[],
        "contents_folders":[],
        "dynamic_pages":[],
        "dynamic_components":[],
        "structured_pages":[],
        "stores":[],
        "structured_contents":[],
        "blocks":[],
        "tags":[],
        "rss_feeds":[],
        "block_templates":[],
        "system_templates":[],
        "page_templates":[],
        };
        if(id){
           if(processes[type]){
                processes[type].push(id);
           }else {
                bootNotify("Cannot be "+action+"d");return false;
           }
        }else {
           if ($(".slt_option:checked").length > 0){
                $(".slt_option").each(function(){
                    if($(this).is(":checked") == true) {
                        if(processes[$(this).next(".process")[0].value] ){
                            processes[$(this).next(".process")[0].value].push($(this).val());
                        }
                    }
                });
            }else{
                bootNotify("No item selected ");return false;
            }
        }
        $('#processTableBody').html("");
        var confMsg = "Are you sure you want to delete";
        for (var [key, value] of Object.entries(processes)){
            if(value.length>0){
                confMsg += " "+capitalize(key)+"("+value.length+")";
                addProcessRow(key+"("+value.length+")");
            }
        }
        confMsg += " ?";

        if(confirm(confMsg))
        {
            $('#publishModal').modal("show");
            $('#publishModalTitle').text("Delete");
            var keys = Object.keys(processes);
            for (var i = 0; i<keys.length; i++){
                if(processes[keys[i]].length > 0){
                    processCount++;

                    if(keys[i] == "pages" || keys[i] == "structured_pages" ||
                         keys[i] == "pages_folders"){

                        var pages = [];
                        var type = "page";
                        var ids = processes[keys[i]];

                        if(keys[i] == "structured_pages"){
                            type = "structured";
                        }else if(keys[i] == "pages_folders"){
                            type = "folder";
                        }
                        ids.forEach(function (id, index) {
                            pages.push({id: id, type: type});
                        });
                        pagesCall(action+"Pages", "" , pages, processCount);
                    }
                    else if(keys[i] == "stores" || keys[i] == "stores_folders"){

                        var stores = [];
                        var type = "structured";
                        var ids = processes[keys[i]];

                        if(keys[i] == "stores_folders" ){
                            type = "folder";
                        }
                        ids.forEach(function (id, index) {
                            stores.push({id: id, type: type});
                        });
                        storesCall(action+"Pages", "" , stores, processCount);
                    }
                    else if(keys[i] == "dynamic_pages"){
                        dynamicPagesCall(action+"Pages", "" , processes[keys[i]].join(),processCount);
                    }
                    else if(keys[i] == "structured_contents"){
                        var ids = processes[keys[i]];
                        var contents = [];
                        ids.forEach(function (id, index) {
                            contents.push({id: id, type: "content"});
                        });
                        structuredContentCall(action+"Contents", "", contents, processCount, true);
                    }
                    else if(keys[i] == "contents_folders"){
                        contentFoldersCall(processes[keys[i]], processCount);
                    }
                    else if(keys[i] == "block_templates" ){
                        blockTemplatesCall(action+"Templates", processes[keys[i]].join(), processCount);
                    }
                    else if(keys[i] == "system_templates" ){
                        blockTemplatesCall(action+"Templates", processes[keys[i]].join(), processCount);
                    }
                    else if(keys[i] == "dynamic_components" ){
                        dynamicComponentsCall(action+"Component", processes[keys[i]].join(),processCount,"",true);
                    }
                    else if(keys[i] == "page_templates" ){
                        pageTemplatesCall(action+"Templates", processes[keys[i]].join(), processCount);
                    }
                    else if(keys[i] == "forms"){
                        formsCall(action+"Forms", "" , processes[keys[i]].join(),processCount,true);
                    }
                    else if(keys[i] == "blocks"){
                        blocksCall(action+"Blocs",processes[keys[i]].join(),processCount);
                    }
                    else if(keys[i] == "rss_feeds"){
                        rssFeedCall(action+"RssFeed",processes[keys[i]],processCount);
                    }
                    else if(keys[i] == "tags"){
                        tagsCall(action+"Tags",processes[keys[i]].join(),processCount);
                    }
                    else if(keys[i] == "products_folders"){
                        productsFoldersCall(processes[keys[i]], processCount);
                    }
                    else{
                        catalogsCall(pType, "", keys[i], processes[keys[i]].join(), processCount,true)
                    }
                }
            }
        }
     }

    onSearch=function(){
        $('#frmSearch').submit();
     }

    refreshscreen=function()
    {
        window.location = window.location
    };

    _publish=function(on)
    {
        var t = pType == 'multi'?"publish":"unpublish";

        $('#publishModal').modal("show");
        $('#publishModalTitle').text(capitalize(t)+"ing");
        var keys = Object.keys(processes);
        for (var i = 0; i<keys.length; i++){

            if(processes[keys[i]].length > 0){

                processCount++;

                if(keys[i] == "dynamic_pages"){
                    dynamicPagesCall(t+"Pages", on, processes[keys[i]].join(), processCount);
                }
                else if(keys[i] == "pages" || keys[i] == "structured_pages"){
                    var pages = [];
                    var type = "page";
                    var ids = processes[keys[i]];
                    if(keys[i] == "structured_pages"){
                        type = "structured";
                    }
                    ids.forEach(function (id, index) {
                        pages.push({id: id, type: type});
                    });
                    pagesCall(t+"Pages", on, pages, processCount);
                }
                else if(keys[i] == "stores"){
                    var stores = [];
                    var type = "structured";
                    var ids = processes[keys[i]];
                    ids.forEach(function (id, index) {
                        stores.push({id: id, type: type});
                    });
                    storesCall(t+"Pages", on, stores, processCount);
                }
                else if(keys[i] == "structured_contents" ){
                    structuredContentCall(t+"Contents", on,  processes[keys[i]].join(), processCount);
                }
                else if(keys[i] == "dynamic_components" ){
                    dynamicComponentsCall("generatePreview", processes[keys[i]].join(), processCount, t=="publish"?'1':'0');
                }
                else if(keys[i] == "forms"){
                    formsCall(t+"Forms", on , processes[keys[i]].join(),processCount);
                }
                else{
                    catalogsCall(pType, on == "now"?-1:on.replace(/-/g, '/'), keys[i], processes[keys[i]].join(), processCount)
                }
            }
        }
    };

    pageTemplatesCall=function(requestType, ids, i){
        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/pageTemplatesAjax.jsp',
            type: 'GET',
            data: {
                requestType : requestType,
                templateIds : ids,
            },
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });

    }

    blockTemplatesCall=function(requestType, ids, i){
        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/blocTemplatesAjax.jsp',
            type: 'GET',
            data: {
                requestType : requestType,
                templateIds : ids,
            },
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    catalogsCall=function(publishtype, publishTime, itemType, ids,i,isdelete)
    {
        var url = 'publish.jsp';
        if(isdelete)
            url = 'deleteall.jsp'
        $.ajax({
            url : url,
            type: 'POST',
            data: {
                type:itemType,
                publishtype : publishtype,
                id : ids,
                on : publishTime,
            },
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.response, json.msg,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    productsFoldersCall=function(ids,i)
    {
        var params = $.param({
            requestType : 'deleteFolders',
            ids : ids
        },true);

        $.ajax({
            url : "catalogs/foldersAjax.jsp",
            data: params,
            type: 'POST',
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    contentFoldersCall=function(ids,i)
    {
        var params = $.param({
            requestType : 'deleteFolders',
            ids : ids,
            folderType: 'contents'
        },true);

        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/foldersAjax.jsp',
            data: params,
            type: 'POST',
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    tagsCall=function(requestType, ids,i)
    {
        $.ajax({
            url : 'catalogs/tagsAjax.jsp',
            type: 'POST',
            data: {
                requestType : requestType,
                ids : ids
            },
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    rssFeedCall=function(requestType, ids,i)
    {
        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/rssFeedsAjax.jsp',
            type: 'GET',
            data: {
                requestType : requestType,
                id : ids
            },
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    blocksCall=function(requestType, ids,i)
    {
        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/blocsAjax.jsp',
            type: 'GET',
            data: {
                requestType : requestType,
                blocIds : ids,
            },
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }
    dynamicComponentsCall=function(requestType, ids,i,isGenerate, isdelete){
        var data = {};
        data['requestType'] = requestType;
        if(isdelete)
            data['id'] = ids;
        else
        {
            data['compIds'] = ids;
            data['isGenerate']  = isGenerate;
        }
        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/componentsAjax.jsp',
            type: 'GET',
            data: data,
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    pagesCall=function(requestType, publishTime, pages,i)
    {
        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/publishUnpublishPagesAjax.jsp',
            type: 'GET',
            data: {
                requestType : requestType,
                pages : JSON.stringify(pages),
                publishTime : publishTime,
                folderType : '<%=FOLDER_TYPE_PAGES%>'
            },
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    storesCall=function(requestType, publishTime, stores,i)
    {
        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/publishUnpublishPagesAjax.jsp',
            type: 'GET',
            data: {
                requestType : requestType,
                pages : JSON.stringify(stores),
                publishTime : publishTime,
                folderType : '<%=FOLDER_TYPE_STORE%>'
            },
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    dynamicPagesCall=function(requestType, publishTime, ids,i)
    {
        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/pagesAjax.jsp',
            type: 'GET',
            data: {
                requestType : requestType,
                pageIds : ids,
                publishTime : publishTime,
            },
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    formsCall=function(requestType, publishTime, ids,i,isdelete)
    {
        var url =  '<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>'+'ajax/publishAjax.jsp';
        var data = {};
        data['ids'] = ids;

        if(isdelete)
        {
            url = '<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>'+'ajax/backendAjaxCallHandler.jsp'
            data['action'] = 'deleteAllForms';
        }else{
            data['requestType'] = requestType;
            data['publishTime'] = publishTime;
        }

        $.ajax({
            url : url,
            type: 'GET',
            data: data,
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    structuredCatalogCall=function(requestType, publishTime, ids,i, isdelete)
    {
        var data = {};
        data['requestType'] = requestType;
        data[isdelete?'ids':'contentIds'] = ids;
        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/structuredCatalogsAjax.jsp',
            type: 'GET',
            data: data,
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    structuredContentCall=function(requestType, publishTime, contents, i, isdelete)
    {
        var data = {};
        data['requestType'] = requestType;

        if(isdelete){
          contents = JSON.stringify(contents);
        }
        data[isdelete?'contents':'contentIds'] = contents;
        $.ajax({
            url : '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/structuredContentsAjax.jsp',
            type: 'GET',
            data: data,
            dataType : 'json',
            success : function(json,xhr)
            {
                updateProcessStatus(json.status, json.message,i);
            },
            error : function(xhr,request, status, error)
            {
                updateProcessStatus(0,"Error while communicating with the server",i);
            }
        });
    }

    updateProcessStatus=function(status, message,i){
        var statusClass  = "text-success";
        var statusText = "SUCCESS";
        if(status != 1 && status != 'success'){
            statusClass = "text-danger";
            statusText = "FAILED";
        }
        $('td.process_status').eq(i).addClass(statusClass);
        $('td.process_status').eq(i).html(statusText);
        $('td.process_message').eq(i).html(message);
        processCount = processCount -1;
        if(processCount == -1) closeProcessModal();
    }

    capitalize=function(s){
      if (typeof s !== 'string') return ''
      return s.charAt(0).toUpperCase() + s.slice(1)
    }

    addProcessRow=function(process){

        process =  process.charAt(0).toUpperCase() + process.slice(1);
        var html = "<tr><td>"+process+"</td><td class='process_status' ><i class='fa fa-spinner fa-pulse fa-fw'></i></td><td width='50%' class='process_message'></td></tr>"
         $('#processTableBody').append(html);
    }

    function delete_selected_on(element){
        $(element).parent().parent().remove();
    }
    closeProcessModal=function(now){
        if(!now){
            setTimeout(() => {
                processCount = -1;
                $('#publishModal').modal("hide");
                $('#frmSearch').submit();
            }, 3000)
        }else{
            processCount = -1;
            $('#publishModal').modal("hide");
            $('#frmSearch').submit();
        }
    }


    goBack=function()
    {
        window.history.back();
    }
    editProcess=function(id ,process, pid, folderId){

        var url = ""
        if(process == "catalogs"){
            url = "catalogs/catalog.jsp?id="+id;
        }else if(process == 'products'){
             url = "catalogs/product.jsp?cid="+pid+"&id="+id+"&folderId="+folderId;
        }else if(process == 'products_folders'){
            url = "catalogs/products.jsp?cid="+pid;
            if(folderId.length>0){
                url += "&folderId="+folderId;
            }
            url += "&editId="+id;
        }else if(process == 'pages'){
            url ='<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/pageEditor.jsp?id='+id;
        }else if(process == 'pages_folders'){
            url ='<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/pages.jsp?';
            if(folderId.length>0){
                url += "&folderId="+folderId;
            }
            url += "&id="+id;
        }else if(process == 'stores_folders'){
            url ='<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/stores.jsp?';
            if(folderId.length>0){
                url += "&folderId="+folderId;
            }
            url += "&id="+id;
        }else if(process == 'contents_folders'){
            url ='<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/structuredContents.jsp?';
            if(folderId.length>0){
                url += "&folderId="+folderId;
            }
            url += "&id="+id;
        }else if(process == 'dynamic_pages'){
            url ='<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/dynamicPageEditor2.jsp?id='+id;
        }else if(process == 'structured_contents'){
            url ='<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/structuredContentEditor.jsp?folderId='+folderId+'&id='+id;
        }else if(process == 'structured_pages'){
            url ='<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/structuredPageEditor.jsp?id='+id;
        }else if(process == 'stores'){
            url ='<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/structuredPageEditor.jsp?id='+id+'&folderId='+folderId;
        }else if(process == 'forms'){
            url ='<%=GlobalParm.getParm("EXTERNAL_FORMS_LINK")%>'+'admin/editProcess.jsp?form_id='+id;
        }else if(process == 'rss_feeds'){
            url ='<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/rssFeeds.jsp?id='+id;
        }else if(process == 'blocks'){
            url ='<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/blocs.jsp?editBlocId='+id;
        }else if(process == 'tags'){
            url ='catalogs/tags.jsp?id='+id;
        }else if(process == 'dynamic_components'){
            url = '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/components.jsp?id='+id;
        }else if(process == 'block_templates'){
            url = '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/templateEditor.jsp?id='+id;
        }else if(process == 'system_templates'){
            url = '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/templateEditor.jsp?id='+id;
        }else if(process == 'page_templates'){
            url = '<%=GlobalParm.getParm("PAGES_APP_URL")%>'+'admin/pageTemplateEditor.jsp?id='+id;
        }
        else if(process == 'comewiths'){
            url = "catalogs/commercialoffers/comewith/comewiths.jsp?edit_id="+id;
        }else if(process == 'deliverymins' || process == 'deliveryfees' ){
            url = "catalogs/commercialoffers/delivery/"+process+".jsp?edit_id="+id;
        }else if(process == 'quantitylimits'){
            url = "catalogs/commercialoffers/quantitylimits/"+process+".jsp?edit_id="+id;
        }else if(process == 'subsidies'){
            url = "catalogs/commercialoffers/subsidies/"+process+".jsp?edit_id="+id;
        }else if(process == 'promotions'){
            url = "catalogs/commercialoffers/promotions/"+process+".jsp?edit_id="+id;
        }else if(process == 'cartrules'){
            url = "catalogs/commercialoffers/cartrules/promotions.jsp?edit_id="+id;
        }else if(process == 'additionalfees'){
            url = "catalogs/commercialoffers/additionalfees/additionalfees.jsp?edit_id="+id;
        }
        window.open(url);
    }
    </script>
  </body>
</html>
