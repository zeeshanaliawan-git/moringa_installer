package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.*;
import java.util.stream.Collectors;

/**
 * @author Ali Adnan
 */
public class EntityExport extends BaseClass {

    protected boolean fromTemplateGenerator = false;
    protected String siteId;
    protected HashSet<String> filterLangIds = new HashSet<>();

    public static final HashSet<String> VALID_EXPORT_IMPORT_TYPES = new HashSet<>(Arrays.asList(
        "pages", "blocs", "bloc_templates", "page_templates",
        "libraries", "structured_contents", "structured_pages",
        "catalogs", "products", "forms", "stores","variables"));

    public static boolean isValidExportImportType(String type) {
        return VALID_EXPORT_IMPORT_TYPES.contains(type);
    }

    protected boolean isViewData = false; //for view data , set true
    protected static java.util.Set<String> catalogExcludedColumns = Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
        "name", "catalog_type", "catalog_uuid", "created_on", "created_by",
        "updated_on", "updated_by",
        "id", "site_id")));

    public EntityExport(Etn Etn, Properties env, boolean debug, String siteId) {
        super(Etn, env, debug);
        this.init(siteId);
    }

    public EntityExport(Etn Etn, Properties env, boolean debug, String siteId, boolean fromTemplateGenerator) {
        super(Etn, env, debug);
        this.init(siteId);
		this.fromTemplateGenerator = fromTemplateGenerator;
    }

    public EntityExport(Etn Etn, String siteId) {
        super(Etn);
        this.init(siteId);
    }

    protected void init(String siteId) {
        try {
            this.siteId = siteId;
        }
        catch (Exception ignored) {
        }
    }

    public boolean isViewData() {
        return isViewData;
    }

    public void setIsViewData(boolean isViewData) {
        this.isViewData = isViewData;
    }

    public void setFilterLangIds(HashSet<String> filterLangIds) {
        this.filterLangIds = filterLangIds;
    }

    public HashSet<String> getFilterLangIds() {
        return filterLangIds;
    }

    public String getFilterLangIdsCommaSeperatedEscaped() {
        return filterLangIds.stream().map(escape::cote).collect(Collectors.joining(","));
    }

    public static java.util.Set<String> getCatalogExcludedColumns() {
        return catalogExcludedColumns;
    }

    public static void setCatalogExcludedColumns(java.util.Set<String> catalogExcludedColumns) {
        EntityExport.catalogExcludedColumns = Collections.unmodifiableSet(catalogExcludedColumns);
    }

    protected JSONObject getJsonObject(Set rs) {

        JSONObject jsonObject = PagesUtil.newJSONObject();

        if (rs.next()) {

            for (int i = 0; i < rs.ColName.length; i++) {

                jsonObject.put(rs.ColName[i].toLowerCase(), rs.value(rs.ColName[i]));
            }
        }

        return jsonObject;
    }

    protected JSONArray getJsonArray(Set rs) {

        return getJsonArray(rs, "");
    }

    protected JSONArray getJsonArray(Set rs, String table) {

        JSONArray jsonArray = new JSONArray();

        while (rs.next()) {

            JSONObject jsonObject = PagesUtil.newJSONObject();

            for (int i = 0; i < rs.ColName.length; i++) {

                if (table.length() > 0
                    && (table.equals("process_form_fields") || table.equals("freq_rules") || table.equals("mails") || table.equals("rules"))
                    && (rs.ColName[i].toLowerCase().equals("id") || rs.ColName[i].toLowerCase().equals("cle"))) {

                    continue;
                }

                jsonObject.put(rs.ColName[i].toLowerCase(), rs.value(rs.ColName[i]));
            }

            jsonArray.put(jsonObject);
        }

        return jsonArray;
    }

    String readDataFromFile(String path, String tableName) throws Exception {
        StringBuilder outputFileData = new StringBuilder();
        String html = "";

        File f = new File(path);

        if (f.exists() && !f.isDirectory()) {


            BufferedReader in = new BufferedReader(new FileReader(path));
            String data = in.readLine();

            while (data != null) {

                outputFileData.append(data).append("\n");
                data = in.readLine();
            }

            html = outputFileData.toString();
            if (html.length() > 0) {

                html = subStringTemplateContent(html, tableName);
            }
        }

        if (html.length() > 0) return html;

        return "";
    }

    String subStringTemplateContent(String html, String tableName) {

        String startingBoundary = "Content-Type: multipart/alternative;\n boundary=\"------------010101080201020804090106\"\n\nThis is a multi-part message in MIME format.\n--------------010101080201020804090106\nContent-Type: text/html; charset=utf-8\nContent-Transfer-Encoding: 7bit\n\n\n<div id='" + tableName + "_template_div'>\n";

        int endIndex = html.indexOf("\n</div>\n--------------010101080201020804090106--");

        html = html.substring(startingBoundary.length(), endIndex);

        return html;
    }

    public JSONObject getFolderJSON(String folderId, String folderTable,boolean isFetchParent, boolean isDetails, boolean isRecursive) {
                                        
        JSONObject retObj = PagesUtil.newJSONObject();
        String q ="";
        
        if(folderTable.equalsIgnoreCase("folders")){
            q= "SELECT uuid, name, parent_folder_id,dl_page_type,dl_sub_level_1,dl_sub_level_2 FROM " + folderTable + " WHERE id = " + escape.cote(folderId);
        }else{
            q= "SELECT uuid, name, parent_folder_id FROM " + folderTable + " WHERE id = " + escape.cote(folderId);
        }

        Set rs = Etn.execute(q);
        if (!rs.next()) {
            return null;
        }
        retObj.put("uuid", rs.value("uuid"))
            .put("name", rs.value("name"));
        
        if(folderTable.equalsIgnoreCase("folders")){
            retObj.put("dl_page_type", PagesUtil.parseNull(rs.value("dl_page_type")));
            retObj.put("dl_sub_level_1", PagesUtil.parseNull(rs.value("dl_sub_level_1")));
            retObj.put("dl_sub_level_2", PagesUtil.parseNull(rs.value("dl_sub_level_2")));
        }

        if (isFetchParent && PagesUtil.parseInt(rs.value("parent_folder_id")) > 0) {
            JSONObject parentFolder = getFolderJSON(rs.value("parent_folder_id"), folderTable, isFetchParent, isDetails, isRecursive);
            retObj.put("parent_folder", parentFolder);
        }
        if (isDetails) {
            String detailsFolderName = "folders_details";
            if (folderTable.endsWith("products_folders")) {
                detailsFolderName = folderTable + "_details";
            }
            JSONArray details = new JSONArray();
            retObj.put("details", details);
            q = "SELECT l.langue_code, fd.path_prefix "
                + " FROM " + detailsFolderName + " fd"
                + " JOIN language l ON l.langue_id = fd.langue_id"
                + " WHERE fd.folder_id = " + escape.cote(folderId);
                
            rs = Etn.execute(q);
            while (rs.next()) {
                details.put(PagesUtil.newJSONObject()
                                .put("langue_code", rs.value("langue_code"))
                                .put("path_prefix", rs.value("path_prefix")));
            }
        }

        JSONArray childFolders = new JSONArray();
        if (isRecursive) {
            q = "SELECT id FROM " + folderTable
                + " WHERE parent_folder_id = " + escape.cote(folderId);
            rs = Etn.execute(q);
            while (rs.next()) {
                // in recursive do not get parent folder info it will be cyclic loop
                childFolders.put(getFolderJSON(rs.value("id"), folderTable, false, isDetails, isRecursive));
            }
        }

        return retObj;
    }

    public String getEntityUrl(String id, String type) {
        return getEntityUrl(id, type, 0);

    }

    public String getEntityUrl(String id, String type, int langId) {
        final String COMMONS_DB = getParm("COMMONS_DB");
        String q = "SELECT page_path AS url "
                   + " FROM " + COMMONS_DB + ".content_urls "
                   + " WHERE site_id = " + escape.cote(siteId)
                   + " AND content_type = " + escape.cote(type)
                   + " AND content_id = " + escape.cote(id);
        if (langId > 0) {
            q += " AND langue_id = " + escape.cote("" + langId);
        }
        Set rs = Etn.execute(q);
        if (rs.next()) {
            return PagesUtil.parseNull(rs.value("url"));
        }
        else {
            return "";
        }

    }

    public JSONObject getExportJson(String exportType, String id) throws Exception {
        return getExportJson(exportType,id,false,"");
    }

    public JSONObject getExportJson(String exportType, String id,String orderClause) throws Exception {
        return getExportJson(exportType,id,false,orderClause);
    }

    public JSONObject getExportJson(String exportType, String id,boolean isSort) throws Exception {
        return getExportJson(exportType,id,isSort,"");
    }

    public JSONObject getExportJson(String exportType, String id,boolean isSort,String orderClause) throws Exception {
        JSONObject retObj = null;

        switch (exportType) {
            case "bloc_templates":
                retObj = getBlocTemplateExportJson(id);
                break;
            case "blocs":
                retObj = getBlocExportJson(id);
                break;
            case "pages":
                retObj = getFreemarkerPage(id);
                break;
            case "page_templates":
                retObj = getPageTemplateExportJson(id);
                break;
            case "libraries":
                retObj = getLibraryExportJson(id);
                break;
            // else if ("structured_catalogs".equals(exportType)) {
            //     retObj = getStructuredCatalogExportJson(id);
            // }
            case "structured_contents":
                retObj = getStructuredContentExportJson(id,isSort);
                break;
            case "structured_pages":
                retObj = getStructuredPageExportJson(id,isSort);
                break;
            case "catalogs":
                retObj = getCommercialCatalogExportJson(id);
                break;
            case "products":
                retObj = getCommercialProductExportJson(id,orderClause);
                break;
            case "forms":
                retObj = getFormExportJson(id);
                break;
            case "variables":
                retObj = getVariableExportJson(id);
                break;
        }

        return retObj;
    }

    public JSONObject getBlocTemplateExportJson(String id) throws Exception {

        JSONObject retObj = null;

        String q = "";
        Set rs = null;

        q = " SELECT * "
            + " FROM  bloc_templates "
            + " WHERE id = " + escape.cote(id)
            + " AND site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);

        if (rs.next()) {
            retObj = PagesUtil.newJSONObject();

            retObj.put("item_type", "bloc_template");

            JSONObject sysInfo = PagesUtil.newJSONObject();

            sysInfo.put("name", rs.value("name"));
            sysInfo.put("custom_id", rs.value("custom_id"));
            sysInfo.put("type", rs.value("type"));
            sysInfo.put("description", rs.value("description"));

            JSONObject resources = PagesUtil.newJSONObject();

            resources.put("code", rs.value("template_code"));
            resources.put("js", rs.value("js_code"));
            resources.put("css", rs.value("css_code"));
            resources.put("jsonld", rs.value("jsonld_code"));

            JSONArray libraries = new JSONArray();

            q = " SELECT DISTINCT l.id, l.name "
                + " FROM libraries l"
                + " JOIN bloc_templates_libraries bl ON l.id = bl.library_id "
                + " WHERE bl.bloc_template_id = " + escape.cote(id)
                + " ORDER BY bl.id";
            Set libRs = Etn.execute(q);
            while (libRs.next()) {
                libraries.put(libRs.value("name"));
            }

            resources.put("libraries", libraries);

            JSONArray sectionsList = PagesUtil.getBlocTemplateSectionsData(Etn, id);

            clearSectionAndFieldIds(sectionsList);

            JSONObject internalInfo = PagesUtil.newJSONObject();

            internalInfo.put("id", rs.value("id"));
            internalInfo.put("site_id", rs.value("site_id"));
            internalInfo.put("created_ts", rs.value("created_ts"));
            internalInfo.put("created_by", rs.value("created_by"));
            internalInfo.put("updated_ts", rs.value("updated_ts"));
            internalInfo.put("updated_by", rs.value("updated_by"));

            retObj.put("system_info", sysInfo);
            retObj.put("resources", resources);
            retObj.put("internal_info", internalInfo);
            retObj.put("sections", sectionsList);

        }

        return retObj;
    }

    public JSONObject getBlocExportJson(String id) {

        JSONObject retObj = null;

        String q = "";
        Set rs = null;

        q = " SELECT b.*, bt.name AS template_name,bt.custom_id AS template_custom_id, bt.type AS template_type "
            + " FROM blocs b "
            + " JOIN bloc_templates bt ON bt.id = b.template_id "
            + " WHERE b.id = " + escape.cote(id)
            + " AND b.site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);

        if (rs.next()) {

            retObj = PagesUtil.newJSONObject();

            retObj.put("item_type", "bloc");

            JSONObject sysInfo = PagesUtil.newJSONObject();

            sysInfo.put("id", rs.value("uuid"));
            sysInfo.put("name", rs.value("name"));
            sysInfo.put("template_id", rs.value("template_custom_id"));
            sysInfo.put("description", rs.value("description"));

            if ("feed_view".equals(rs.value("template_type"))) {

                sysInfo.put("rss_feed_sort", rs.value("rss_feed_sort"));

                JSONArray rssFeeds = new JSONArray();

                if (PagesUtil.parseNull(rs.value("rss_feed_ids")).length() > 0) {
                    q = "SELECT name FROM rss_feeds "
                        + " WHERE site_id = " + escape.cote(siteId)
                        + " AND id IN ( " + rs.value("rss_feed_ids") + " )";
                    Set rssRs = Etn.execute(q);
                    while (rssRs.next()) {
                        rssFeeds.put(rssRs.value("name"));
                    }
                }

                sysInfo.put("rss_feeds", rssFeeds);
            }

            JSONObject parameters = PagesUtil.newJSONObject();

            parameters.put("refresh_interval", rs.value("refresh_interval"));
            parameters.put("start_date", rs.value("start_date"));
            parameters.put("end_date", rs.value("end_date"));
            parameters.put("margin_top", rs.value("margin_top"));
            parameters.put("margin_bottom", rs.value("margin_bottom"));

            JSONArray tags = new JSONArray();
            String CATALOG_DB = getParm("CATALOG_DB");
            q = "SELECT t.id, t.label FROM blocs_tags bt "
                + " JOIN " + CATALOG_DB + ".tags t ON bt.tag_id = t.id "
                + " WHERE t.site_id = " + escape.cote(siteId)
                + " AND bt.bloc_id = " + escape.cote(rs.value("id"))
                + " ORDER BY t.label";
            Set tagsRs = Etn.execute(q);
            while (tagsRs.next()) {
                JSONObject tagObj = PagesUtil.newJSONObject();
                tagObj.put("id", tagsRs.value("id"));
                tagObj.put("label", tagsRs.value("label"));
                tags.put(tagObj);
            }

            JSONObject internalInfo = PagesUtil.newJSONObject();

            internalInfo.put("id", rs.value("id"));
            internalInfo.put("site_id", rs.value("site_id"));
            internalInfo.put("created_ts", rs.value("created_ts"));
            internalInfo.put("created_by", rs.value("created_by"));
            internalInfo.put("updated_ts", rs.value("updated_ts"));
            internalInfo.put("updated_by", rs.value("updated_by"));

            // deprecated , template data is now multi language
            // String template_data = rs.value("template_data");
            // template_data = PagesUtil.decodeJSONStringDB(template_data);
            // blocData.put("template_data",template_data);

            JSONArray details_lang = new JSONArray();
            q = " SELECT l.langue_code, IFNULL(bd.template_data,'{}') AS template_data "
                + " FROM language l "
                + " LEFT JOIN blocs_details bd ON l.langue_id = bd.langue_id AND bd.bloc_id = " + escape.cote(id);
            if (!filterLangIds.isEmpty()) {
                q += " WHERE l.langue_id IN  (" + getFilterLangIdsCommaSeperatedEscaped() + ")";
            }
            Set detailsRs = Etn.execute(q);
            while (detailsRs.next()) {
                JSONObject curDetailObj = PagesUtil.newJSONObject();
                curDetailObj.put("langue_code", detailsRs.value("langue_code"));
                String template_data = detailsRs.value("template_data");
                template_data = PagesUtil.decodeJSONStringDB(template_data);
                curDetailObj.put("sections_data", PagesUtil.newJSONObject2(template_data));

                details_lang.put(curDetailObj);
            }

            retObj.put("system_info", sysInfo);
            retObj.put("parameters", parameters);
            retObj.put("internal_info", internalInfo);
            retObj.put("details_lang", details_lang);
            // retObj.put("sections_data", PagesUtil.newJSONObject(template_data));
            retObj.put("tags", tags);
        }

        return retObj;
    }

    public JSONObject getLibraryExportJson(String id) {

        JSONObject retObj = null;

        String q = "";
        Set rs = null;

        q = " SELECT * "
            + " FROM libraries "
            + " WHERE id = " + escape.cote(id)
            + " AND site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);

        if (rs.next()) {
            retObj = PagesUtil.newJSONObject();

            retObj.put("item_type", "library");

            JSONObject sysInfo = PagesUtil.newJSONObject();
            
            sysInfo.put("name", rs.value("name"));

            String query = "select sl.langue_id,l.langue_code from "+getParm("COMMONS_DB")+
                ".sites_langs sl left join language l on l.langue_id=sl.langue_id where sl.site_id="+escape.cote(siteId);
            
            if (!filterLangIds.isEmpty()) {
                query += " AND l.langue_id IN  (" + getFilterLangIdsCommaSeperatedEscaped() + ")";
            }
            Set rsLang = Etn.execute(query);

            JSONArray detailsLangAry = new JSONArray();
            while(rsLang.next()){

                JSONObject detailsLangObj = PagesUtil.newJSONObject();

                JSONArray bodyFilesList = new JSONArray();
                JSONArray headFilesList = new JSONArray();
                q = " SELECT f.file_name, f.type AS file_type, lf.page_position, lf.sort_order "
                    + " FROM libraries_files lf "
                    + " JOIN files f ON f.id = lf.file_id "
                    + " WHERE lf.library_id = " + escape.cote(id)
                    + " AND lf.lang_id = " + escape.cote(rsLang.value("langue_id"))
                    + " ORDER BY lf.sort_order ASC ";
                Set fRs = Etn.execute(q);
                JSONObject curFile;
                while (fRs.next()) {

                    curFile = PagesUtil.newJSONObject();
                    curFile.put("name", fRs.value("file_name"));
                    curFile.put("type", fRs.value("file_type"));

                    if ("head".equals(fRs.value("page_position"))) {
                        headFilesList.put(curFile);
                    }
                    else {
                        bodyFilesList.put(curFile);
                    }
                }
                detailsLangObj.put("language_code", rsLang.value("langue_code"));
                detailsLangObj.put("body_files", bodyFilesList);
                detailsLangObj.put("head_files", headFilesList);
                detailsLangAry.put(detailsLangObj);
            }

            JSONObject internalInfo = PagesUtil.newJSONObject();

            internalInfo.put("id", rs.value("id"));
            internalInfo.put("site_id", rs.value("site_id"));
            internalInfo.put("created_ts", rs.value("created_ts"));
            internalInfo.put("created_by", rs.value("created_by"));
            internalInfo.put("updated_ts", rs.value("updated_ts"));
            internalInfo.put("updated_by", rs.value("updated_by"));

            retObj.put("system_info", sysInfo);
            retObj.put("detail_langs", detailsLangAry);
            retObj.put("internal_info", internalInfo);

        }

        return retObj;
    }

    public JSONObject getPageSettingJson(String id) {
        JSONObject retObj = null;

        String q = "";
        Set rs = null;

        q = " SELECT p.*, IFNULL(pt.name, 'Default template') AS template_name,"
                + "     IFNULL(f.uuid,'') as folder_uuid, IFNULL(f.name,'') as folder_name "
                + " FROM pages p "
                + " LEFT JOIN page_templates pt ON pt.id = p.template_id "
                + " LEFT JOIN folders f ON f.id = p.folder_id"
                + " WHERE p.id = " + escape.cote(id)
                + " AND p.site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);
        if (rs.next()) {
			String _pageid = rs.value("id");
			String _parentPageId = rs.value("parent_page_id");
			String _pageType = rs.value("type");
			if("react".equalsIgnoreCase(_pageType)) _parentPageId = _pageid;//for react there is no parent page so page id is used as parent page id
            retObj = PagesUtil.newJSONObject();

            JSONObject sysInfo = PagesUtil.newJSONObject();

            sysInfo.put("path", rs.value("path"));
            sysInfo.put("variant", rs.value("variant"));
            sysInfo.put("template", rs.value("template_name"));
            sysInfo.put("folder_name", rs.value("folder_name"));

            if (isViewData) {
                sysInfo.put("url", getEntityUrl(id, "page"));
            }
//            -- deprecated folder is shifted to parent page --
//            String folderId = PagesUtil.parseNull(rs.value("folder_id"));
//            String folderTable = "folders";
//            JSONObject folderObj = getFolderJSON(folderId, folderTable, true, true, false);
//            sysInfo.put("folder", folderObj != null ? folderObj : PagesUtil.newJSONObject());

            String pageType = rs.value("type");
            String pagePath = PagesUtil.getPrefixedPagePath(Etn, id, rs.value("langue_code"), rs.value("path"), pageType, siteId);

			//when this function is called from TemplateDataGenerator at that time we are concerned with Page's cached path rather than its full path
            String fullPagePath = PagesUtil.getPageHtmlPath(pagePath, rs.value("variant"), rs.value("langue_code"), siteId);
			if(fromTemplateGenerator) {
				fullPagePath = PagesUtil.getCachedPath(Etn, siteId, rs.value("langue_code"), "page", id);
			}
            sysInfo.put("full_path", fullPagePath);

            JSONObject metaInfo = PagesUtil.newJSONObject();

            metaInfo.put("canonical_url", rs.value("canonical_url"));
            metaInfo.put("title", rs.value("title"));
            metaInfo.put("meta_keywords", rs.value("meta_keywords"));
            metaInfo.put("meta_description", rs.value("meta_description"));

            JSONArray customMetaTags = new JSONArray();
            q = " SELECT meta_name, meta_content FROM pages_meta_tags "
                    + " WHERE page_id = " + escape.cote(id)
                    + " ORDER BY meta_name ";
            Set mRs = Etn.execute(q);
            while (mRs.next()) {
                JSONObject metaTag = PagesUtil.newJSONObject();
                metaTag.put("meta_name", mRs.value("meta_name"));
                metaTag.put("meta_content", mRs.value("meta_content"));
                customMetaTags.put(metaTag);
            }

            metaInfo.put("custom_meta_tags", customMetaTags);

            JSONObject internalInfo = PagesUtil.newJSONObject();

            internalInfo.put("id", rs.value("id"));
            internalInfo.put("site_id", rs.value("site_id"));
            internalInfo.put("page_type", rs.value("type"));
            internalInfo.put("created_ts", rs.value("created_ts"));
            internalInfo.put("created_by", rs.value("created_by"));
            internalInfo.put("updated_ts", rs.value("updated_ts"));
            internalInfo.put("updated_by", rs.value("updated_by"));
            // data layer data
            internalInfo.put("dl_page_type", rs.value("dl_page_type"));
            internalInfo.put("dl_sub_level_1", rs.value("dl_sub_level_1"));
            internalInfo.put("dl_sub_level_2", rs.value("dl_sub_level_2"));

            retObj.put("system_info", sysInfo);
            retObj.put("meta_info", metaInfo);
            retObj.put("internal_info", internalInfo);
        }

        return retObj;
    }

    public JSONObject getPageTemplateExportJson(String id) {

        JSONObject retObj = null;

        String q = "";
        Set rs = null;

        q = " SELECT * "
            + " FROM page_templates "
            + " WHERE id = " + escape.cote(id)
            + " AND site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.next()) {
            retObj = PagesUtil.newJSONObject();

            retObj.put("item_type", "page_template");

            JSONObject sysInfo = PagesUtil.newJSONObject();
            retObj.put("system_info", sysInfo);

            sysInfo.put("name", rs.value("name"));
            sysInfo.put("custom_id", rs.value("custom_id"));
            sysInfo.put("description", rs.value("description"));
            sysInfo.put("is_system", rs.value("is_system"));

            JSONObject details = PagesUtil.newJSONObject();
            retObj.put("details", details);

            details.put("template_code", rs.value("template_code"));

            JSONArray itemsList = new JSONArray();
            details.put("items", itemsList);

            q = "SELECT * FROM page_templates_items "
                + " WHERE page_template_id = " + escape.cote(id)
                + " ORDER BY sort_order ";
            Set itemsRs = Etn.execute(q);

            while (itemsRs.next()) {
                String itemId = itemsRs.value("id");

                JSONObject item = PagesUtil.newJSONObject();
                itemsList.put(item);

                item.put("name", itemsRs.value("name"));
                item.put("custom_id", itemsRs.value("custom_id"));
                item.put("sort_order", itemsRs.value("sort_order"));

                JSONArray itemDetailsList = new JSONArray();
                item.put("item_details", itemDetailsList);

                q = "SELECT d.*, l.langue_code FROM page_templates_items_details d "
                    + " JOIN language l ON l.langue_id = d.langue_id "
                    + " WHERE item_id = " + escape.cote(itemId);
                if (filterLangIds.size() > 0) {
                    q += " AND d.langue_id IN (" + getFilterLangIdsCommaSeperatedEscaped() + ")";
                }
                Set itemDetailsRs = Etn.execute(q);
                while (itemDetailsRs.next()) {
                    JSONObject itemDetail = PagesUtil.newJSONObject();
                    itemDetailsList.put(itemDetail);

                    itemDetail.put("langue_code", itemDetailsRs.value("langue_code"));
                    itemDetail.put("css_classes", itemDetailsRs.value("css_classes"));
                    itemDetail.put("css_style", itemDetailsRs.value("css_style"));

                    String curLangId = itemDetailsRs.value("langue_id");

                    JSONArray blocs = new JSONArray();
                    itemDetail.put("blocs", blocs);
                    q = " SELECT * FROM ("
                        + " SELECT b.uuid, b.name, pb.type, pb.sort_order FROM page_templates_items_blocs pb "
                        + " JOIN blocs b ON b.id = pb.bloc_id AND pb.type = 'bloc' "
                        + " WHERE pb.item_id = " + escape.cote(itemId)
                        + " AND pb.langue_id = " + escape.cote(curLangId)
                        + " ) AS t "
                        + " ORDER BY sort_order ";
                    Set blocsRs = Etn.execute(q);
                    while (blocsRs.next()) {
                        blocs.put(PagesUtil.newJSONObject()
                                      .put("uuid", blocsRs.value("uuid"))
                                      .put("name", blocsRs.value("name"))
                                      .put("type", blocsRs.value("type")));
                    }

                }

            }

            JSONObject internalInfo = PagesUtil.newJSONObject();
            retObj.put("internal_info", internalInfo);

            internalInfo.put("id", rs.value("id"));
            internalInfo.put("uuid", rs.value("uuid"));
            internalInfo.put("site_id", rs.value("site_id"));
            internalInfo.put("created_ts", rs.value("created_ts"));
            internalInfo.put("created_by", rs.value("created_by"));
            internalInfo.put("updated_ts", rs.value("updated_ts"));
            internalInfo.put("updated_by", rs.value("updated_by"));

        }

        return retObj;
    }

    public JSONObject getStructuredContentExportJson(String id,boolean isSort) {

        return getStructuredContentExportJsonGeneric(id, Constant.STRUCTURE_TYPE_CONTENT,isSort);
    }

    public JSONObject getStructuredPageExportJson(String id,boolean isSort) {

        return getStructuredContentExportJsonGeneric(id, Constant.STRUCTURE_TYPE_PAGE,isSort);
    }

    public JSONObject getFreemarkerPage(String id) {
        JSONObject retObj = null;

        try {
            String q = "";
            Set rs = null;

            q = " SELECT fp.*, "
                    + " IFNULL(f.uuid,'') as folder_uuid, IFNULL(f.name,'') as folder_name "
                    + " FROM freemarker_pages fp "
                    + " LEFT JOIN folders f ON f.id = fp.folder_id "
                    + " WHERE fp.id = " + escape.cote(id)
                    + " AND fp.site_id = " + escape.cote(siteId)
                    + " AND fp.is_deleted = '0'";

            rs = Etn.execute(q);

            if (rs.next()) {
                retObj = PagesUtil.newJSONObject();
                retObj.put("item_type", "freemarker_page");

                JSONObject sysInfo = PagesUtil.newJSONObject();

                sysInfo.put("name", rs.value("name"));
                sysInfo.put("folder_name", rs.value("folder_name"));

                String folderId = PagesUtil.parseNull(rs.value("folder_id"));
                String folderTable = "folders";
                JSONObject folderObj = getFolderJSON(folderId, folderTable, true, true, false);
                sysInfo.put("folder", folderObj != null ? folderObj : PagesUtil.newJSONObject());

				JSONArray tags = new JSONArray();
				String CATALOG_DB = getParm("CATALOG_DB");
				q = "SELECT t.id, t.label FROM pages_tags pt "
						+ " JOIN " + CATALOG_DB + ".tags t ON pt.tag_id = t.id "
						+ " WHERE t.site_id = " + escape.cote(siteId)
						+ " AND pt.page_id = " + escape.cote(id)
						+ " AND pt.page_type = " + escape.cote("freemarker")
						+ " ORDER BY t.label";
				Set tagsRs = Etn.execute(q);
				while (tagsRs.next()) {
					JSONObject tagObj = PagesUtil.newJSONObject();
					tagObj.put("id", tagsRs.value("id"));
					tagObj.put("label", tagsRs.value("label"));
					tags.put(tagObj);
				}
				
                JSONArray details = new JSONArray();
                q = "SELECT p.* , l.langue_code as langue_code"
                        + " FROM pages p "
                        + " JOIN language l ON l.langue_code = p.langue_code"
                        + " WHERE p.parent_page_id = " + escape.cote(id)
                        + " AND p.type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER);

                if (!filterLangIds.isEmpty()) {
                    q += " AND l.langue_id IN (" + getFilterLangIdsCommaSeperatedEscaped() + ")";
                }

                Set detailsRs = Etn.execute(q);
                while (detailsRs.next()) {
                    JSONObject detailObj = PagesUtil.newJSONObject();
                    detailObj.put("langue_code", detailsRs.value("langue_code"));

                    String pageId = detailsRs.value("id");
                    JSONObject pageObj = PagesUtil.newJSONObject();
                    if (PagesUtil.parseInt(pageId) > 0) {
                        pageObj = getPageSettingJson(pageId);
                    }
                    detailObj.put("page_settings", pageObj);

                    details.put(detailObj);
                }

                JSONArray blocsList = new JSONArray();
                q = " SELECT * FROM ("
                    + "   SELECT b.uuid AS id, sort_order "
                    + "   FROM parent_pages_blocs pb"
                    + "   JOIN blocs b ON b.id = pb.bloc_id "
                    + "   WHERE page_id = " + escape.cote(id)
                    + "   UNION "
                    + "   SELECT CONCAT('form_',form_id) AS id, sort_order"
                    + "   FROM parent_pages_forms "
                    + "   WHERE page_id = " + escape.cote(id)
                    + " ) t1"
                    + " ORDER BY sort_order ASC";
                Set bRs = Etn.execute(q);
                while (bRs.next()) {
                    blocsList.put(bRs.value("id"));
                }

                JSONObject internalInfo = PagesUtil.newJSONObject();

                internalInfo.put("id", rs.value("id"));
                internalInfo.put("uuid", rs.value("uuid"));
                internalInfo.put("site_id", siteId);
                internalInfo.put("created_ts", rs.value("created_ts"));
                internalInfo.put("created_by", rs.value("created_by"));
                internalInfo.put("updated_ts", rs.value("updated_ts"));
                internalInfo.put("updated_by", rs.value("updated_by"));

                retObj.put("system_info", sysInfo);
                retObj.put("details", details);
                retObj.put("blocs", blocsList);
                retObj.put("internal_info", internalInfo);
                retObj.put("tags", tags);
            }
        } catch (Exception ex){
            ex.printStackTrace();
        }
        return retObj;
    }

    void insertRemainingElements(JSONObject respJson,JSONObject compareJson){
        for(String key : compareJson.keySet()){
            if(!respJson.has(key)){
                respJson.put(key,compareJson.get(key));
            }
        }
    }
    
    JSONObject getSectionsAndFieldsData(String parentSectionId,JSONObject compareJson){

        JSONObject respObj = PagesUtil.newJSONObject();

        Set rs2 = Etn.execute("select id,custom_id from sections_fields where section_id="+escape.cote(parentSectionId) + " ORDER BY sort_order ASC ");
                
        while(rs2.next()) {
            if(compareJson.has(rs2.value("custom_id"))){
                respObj.put(rs2.value("custom_id"),compareJson.get(rs2.value("custom_id")));
            }
        }

        rs2=Etn.execute("select id,custom_id from bloc_templates_sections where parent_section_id="+escape.cote(parentSectionId)+ " ORDER BY sort_order ASC ");
        while(rs2.next()){
            if(compareJson.has(rs2.value("custom_id"))){
                JSONArray tempArray = new JSONArray();
                for(int i=0;i<compareJson.getJSONArray(rs2.value("custom_id")).length();i++){
                    tempArray.put(getSectionsAndFieldsData(rs2.value("id"),compareJson.getJSONArray(rs2.value("custom_id")).getJSONObject(i)));
                }
                respObj.put(rs2.value("custom_id"),tempArray);
            }
        }
        insertRemainingElements(respObj,compareJson);
        return respObj;
    }

    JSONObject sortTempalteData(String templateId,JSONObject compareJson){

        JSONObject retObj = PagesUtil.newJSONObject();
        String q = "SELECT id,custom_id FROM bloc_templates_sections "
        + " WHERE bloc_template_id = " + escape.cote(templateId)
        + " ORDER BY sort_order ASC ";
        Set rs = Etn.execute(q);
        while(rs.next()) {
            if(compareJson.has(rs.value("custom_id"))){
                JSONArray tempArray = new JSONArray();
                for(int i=0;i<compareJson.getJSONArray(rs.value("custom_id")).length();i++){
                    tempArray.put(getSectionsAndFieldsData(rs.value("id"),compareJson.getJSONArray(rs.value("custom_id")).getJSONObject(i)));
                }
                retObj.put(rs.value("custom_id"),tempArray);
            }
        }
        return retObj;
    }

    public JSONObject getStructuredContentExportJsonGeneric(String id, String contentType) {
        return getStructuredContentExportJsonGeneric(id, contentType,false);
    }

    public JSONObject getStructuredContentExportJsonGeneric(String id, String contentType,boolean isSort) {

        JSONObject retObj = null;

        String q = "";
        Set rs = null;

        q = " SELECT sc.*, bt.custom_id AS template_custom_id, "
            + "   IFNULL(f.uuid,'') as folder_uuid, IFNULL(f.name,'') as folder_name "
            + "   , bt.type AS template_type "
            + " FROM structured_contents sc "
            + " JOIN bloc_templates bt ON bt.id = sc.template_id"
            + " LEFT JOIN folders f ON f.id = sc.folder_id "
            + " WHERE sc.id = " + escape.cote(id)
            + " AND sc.type = " + escape.cote(contentType)
            + " AND sc.site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);

        if (rs.next()) {

            retObj = PagesUtil.newJSONObject();

            retObj.put("item_type", "structured_" + contentType);
            if (Constant.TEMPLATE_STORE.equals(rs.value("template_type"))) {
                retObj.put("item_type", "store");
            }

            JSONObject sysInfo = PagesUtil.newJSONObject();

            sysInfo.put("name", rs.value("name"));
            sysInfo.put("type", rs.value("type"));
            sysInfo.put("template_id", rs.value("template_custom_id"));
            sysInfo.put("folder_name", rs.value("folder_name"));

			JSONArray tags = new JSONArray();
			String CATALOG_DB = getParm("CATALOG_DB");
			q = "SELECT t.id, t.label FROM pages_tags pt "
					+ " JOIN " + CATALOG_DB + ".tags t ON pt.tag_id = t.id "
					+ " WHERE t.site_id = " + escape.cote(siteId)
					+ " AND pt.page_id = " + escape.cote(id)
					+ " AND pt.page_type = " + escape.cote("structured")
					+ " ORDER BY t.label";
			Set tagsRs = Etn.execute(q);
			while (tagsRs.next()) {
				JSONObject tagObj = PagesUtil.newJSONObject();
				tagObj.put("id", tagsRs.value("id"));
				tagObj.put("label", tagsRs.value("label"));
				tags.put(tagObj);
			}

            String folderId = PagesUtil.parseNull(rs.value("folder_id"));
            String folderTable = "folders";
            JSONObject folderObj = getFolderJSON(folderId, folderTable, true, true, false);
            sysInfo.put("folder", folderObj != null ? folderObj : PagesUtil.newJSONObject());

            JSONArray details = new JSONArray();
            q = "SELECT scd.* , l.langue_code as langue_code,bt.id as temp_id"
                + " FROM structured_contents_details scd "
                + " JOIN structured_contents sc ON sc.id = scd.content_id "
                + " LEFT JOIN bloc_templates bt ON bt.id = sc.template_id"
                + " JOIN language l ON l.langue_id = scd.langue_id"
                + " WHERE sc.id = " + escape.cote(id);

            if (!filterLangIds.isEmpty()) {
                q += " AND l.langue_id IN (" + getFilterLangIdsCommaSeperatedEscaped() + ")";
            }

            Set detailsRs = Etn.execute(q);
            while (detailsRs.next()) {
                JSONObject detailObj = PagesUtil.newJSONObject();
                detailObj.put("langue_code", detailsRs.value("langue_code"));

                String content_data = detailsRs.value("content_data");
                content_data = PagesUtil.decodeJSONStringDB(content_data);
                
                if(isSort){
                    JSONObject tempData = sortTempalteData(detailsRs.value("temp_id"),PagesUtil.newJSONObject2(content_data));
                    detailObj.put("template_data", tempData);
                }else{
                    detailObj.put("template_data", new JSONObject(content_data));
                }

                if ("page".equals(contentType)) {
                    String pageId = detailsRs.value("page_id");
                    JSONObject pageObj = null;
                    if (PagesUtil.parseInt(pageId) > 0) {
                        try {
                            pageObj = getPageSettingJson(pageId);
                        } catch (Exception ex){
                            ex.printStackTrace();
                        }
                    }
                    else {
                        //optional page , in case of store
                        pageObj = PagesUtil.newJSONObject();
                    }
                    detailObj.put("page_settings", pageObj);
                }

                details.put(detailObj);
            }

            JSONObject internalInfo = PagesUtil.newJSONObject();

            internalInfo.put("id", rs.value("id"));
            internalInfo.put("uuid", rs.value("uuid"));
            internalInfo.put("site_id", siteId);
            internalInfo.put("created_ts", rs.value("created_ts"));
            internalInfo.put("created_by", rs.value("created_by"));
            internalInfo.put("updated_ts", rs.value("updated_ts"));
            internalInfo.put("updated_by", rs.value("updated_by"));

            retObj.put("system_info", sysInfo);
            retObj.put("details", details);
            retObj.put("internal_info", internalInfo);
			retObj.put("tags", tags);
        }

        return retObj;
    }

    public JSONObject getCommercialCatalogExportJson(String id) {

        JSONObject retObj = null;

        String q = "";
        Set rs = null;

        String CATALOG_DB = getParm("CATALOG_DB");
        //if lang filter set is not empty we need to filter languages
        boolean isFilterLangs = !filterLangIds.isEmpty();
        final String commaSepLangIds = getFilterLangIdsCommaSeperatedEscaped();

        q = " SELECT c.*"
            + " FROM " + CATALOG_DB + ".catalogs c"
            + " WHERE c.id = " + escape.cote(id)
            + " AND c.site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);

        if (!rs.next()) {
            return null;
        }

        retObj = PagesUtil.newJSONObject();

        retObj.put("item_type", "catalog");

        JSONObject sysInfo = PagesUtil.newJSONObject();
        retObj.put("system_info", sysInfo);

        sysInfo.put("name", rs.value("name"));
        sysInfo.put("uuid", rs.value("catalog_uuid"));
        sysInfo.put("type", rs.value("catalog_type"));

        JSONObject internalInfo = PagesUtil.newJSONObject();
        retObj.put("internal_info", internalInfo);

        internalInfo.put("id", rs.value("id"));
        internalInfo.put("site_id", rs.value("site_id"));
        internalInfo.put("created_ts", rs.value("created_on"));
        internalInfo.put("created_by", rs.value("created_by"));
        internalInfo.put("updated_ts", rs.value("updated_on"));
        internalInfo.put("updated_by", rs.value("updated_by"));

        JSONObject details = PagesUtil.newJSONObject();
        retObj.put("details", details);
        JSONArray details_lang = new JSONArray();
        retObj.put("details_lang", details_lang);

        List<Language> langList = PagesUtil.getLangs(Etn,siteId);
        if (isFilterLangs) {
            langList.removeIf(lang -> !filterLangIds.contains(String.valueOf(lang.id)));
        }

        HashMap<String, JSONObject> detailLangHM = new HashMap<>();
        for (Language curLang : langList) {
            JSONObject detailLangObj = PagesUtil.newJSONObject();
            detailLangObj.put("langue_code", curLang.code);
            if (isViewData) {
                detailLangObj.put("url", getEntityUrl(id, "catalog", curLang.id));
            }
            detailLangObj.put("essential_blocks", new JSONArray());
            detailLangObj.put("description_tbl", PagesUtil.newJSONObject());
            details_lang.put(detailLangObj);

            detailLangHM.put("" + curLang.id, detailLangObj);
        }

        java.util.Set<String> excludedCols = EntityExport.getCatalogExcludedColumns();
        for (int i = 0; i < rs.ColName.length; i++) {
            String colName = rs.ColName[i].toLowerCase();

            if (!isViewData && excludedCols.contains(colName)) {
                //skip excluded columns if not view data (i.e. export data)
            }
            else if (colName.startsWith("lang_")) {
                String[] colNameArr = colName.split("_");
                if (colNameArr.length >= 3 && detailLangHM.containsKey(colNameArr[1])) {
                    String langColName = colNameArr[2];
                    if (colNameArr.length > 3) {
                        langColName = String.join("_", Arrays.copyOfRange(colNameArr, 2, colNameArr.length));
                    }
                    detailLangHM.get(colNameArr[1]).put(langColName, rs.value(i));
                }
            }
            else if (colName.startsWith("essentials_alignment_")) {
                String[] colNameArr = colName.split("_");
                if (colNameArr.length == 4 && detailLangHM.containsKey(colNameArr[3])) {
                    detailLangHM.get(colNameArr[3]).put("essentials_alignment", rs.value(i));
                }
            }
            else {
                details.put(colName, rs.value(i));
            }
        }

        q = "SELECT cd.*,pt.custom_id as page_template_cstm_id FROM " + CATALOG_DB + ".catalog_descriptions cd "
            + " JOIN " + CATALOG_DB + ".language l ON l.langue_id = cd.langue_id "
            + " LEFT JOIN page_templates pt on cd.page_template_id=pt.id WHERE cd.catalog_id = " + escape.cote(id);
        if (isFilterLangs) {
            q += " AND l.langue_id IN (" + commaSepLangIds + ")";
        }

        Set catRs = Etn.execute(q);
        while (catRs.next()) {
            JSONObject curObj = PagesUtil.newJSONObject();
            for (int i = 0; i < catRs.ColName.length; i++) {
                String colName = catRs.ColName[i].toLowerCase();
                if (!"catalog_id".equals(colName) && !"langue_id".equals(colName)) {
                    curObj.put(colName, catRs.value(i));
                }
            }
            detailLangHM.get(catRs.value("langue_id")).put("description_tbl", curObj);
        }

        q = "SELECT ceb.* FROM " + CATALOG_DB + ".catalog_essential_blocks ceb "
            + " JOIN " + CATALOG_DB + ".language l ON l.langue_id = ceb.langue_id "
            + " WHERE ceb.catalog_id = " + escape.cote(id);
        if (isFilterLangs) {
            q += " AND l.langue_id IN (" + commaSepLangIds + ")";
        }

        catRs = Etn.execute(q);
        while (catRs.next()) {
            JSONObject curObj = PagesUtil.newJSONObject();
            for (int i = 0; i < catRs.ColName.length; i++) {
                String colName = catRs.ColName[i].toLowerCase();
                if (!"catalog_id".equals(colName) && !"id".equals(colName) && !"langue_id".equals(colName)) {
                    curObj.put(colName, catRs.value(i));
                }
            }

            detailLangHM.get(catRs.value("langue_id"))
                .getJSONArray("essential_blocks")
                .put(curObj);

        }

        JSONArray catalog_attributes = new JSONArray();
        retObj.put("catalog_attributes", catalog_attributes);

        q = "SELECT * FROM " + CATALOG_DB + ".catalog_attributes WHERE catalog_id = " + escape.cote(id);
        catRs = Etn.execute(q);
        Set attValRs = null;
        while (catRs.next()) {
            JSONObject curObj = PagesUtil.newJSONObject();
            for (int i = 0; i < catRs.ColName.length; i++) {
                String colName = catRs.ColName[i].toLowerCase();
                if (!"catalog_id".equals(colName) && !"cat_attrib_id".equals(colName)) {
                    curObj.put(colName, catRs.value(i));
                }
            }
            JSONArray catalog_attribute_values = new JSONArray();
            curObj.put("catalog_attribute_values", catalog_attribute_values);

            q = "SELECT * FROM " + CATALOG_DB + ".catalog_attribute_values WHERE cat_attrib_id = " + escape.cote(catRs.value("cat_attrib_id"));
            attValRs = Etn.execute(q);
            while (attValRs.next()) {
                JSONObject curObj2 = PagesUtil.newJSONObject();
                for (int i = 0; i < attValRs.ColName.length; i++) {
                    String colName = attValRs.ColName[i].toLowerCase();
                    if (!"catalog_id".equals(colName) && !"cat_attrib_id".equals(colName) && !"id".equals(colName)) {
                        curObj2.put(colName, attValRs.value(i));
                    }
                }
                catalog_attribute_values.put(curObj2);
            }

            catalog_attributes.put(curObj);
        }

        JSONArray folders = new JSONArray();
        retObj.put("folders", folders);
        String folderTable = CATALOG_DB + ".products_folders";
        q = "SELECT id FROM " + folderTable
            + " WHERE catalog_id = " + escape.cote(id)
            + " AND site_id = " + escape.cote(siteId)
            + "AND parent_folder_id = '0' ";
        Set foldersRs = Etn.execute(q);
        while (foldersRs.next()) {
            folders.put(getFolderJSON(foldersRs.value("id"), folderTable, false, true, true));
        }


        return retObj;
    }

    public JSONObject getCommercialProductExportJson(String id) {
        return getCommercialProductExportJson(id,"");
    }

    public JSONObject getCommercialProductExportJson(String id,String orderClause) {

        JSONObject retObj = null;

        String q = "";
        Set rs = null;

        String CATALOG_DB = getParm("CATALOG_DB");
        //if lang filter set is not empty we need to filter languages
        boolean isFilterLangs = !filterLangIds.isEmpty();
        final String commaSepLangIds = getFilterLangIdsCommaSeperatedEscaped();

        q = " SELECT p.*, c.catalog_uuid, c.catalog_type, "
            + " IFNULL(f.uuid,'') AS folder_uuid, IFNULL(f.name,'') AS folder_name "
            + " FROM " + CATALOG_DB + ".products p"
            + " JOIN " + CATALOG_DB + ".catalogs c ON c.id = p.catalog_id"
            + " LEFT JOIN " + CATALOG_DB + ".products_folders f ON f.id = p.folder_id"
            + " WHERE p.id = " + escape.cote(id)
            + " AND c.site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);

        if (rs.next()) {
            retObj = PagesUtil.newJSONObject();

            retObj.put("item_type", "product");

            JSONObject sysInfo = PagesUtil.newJSONObject();
            retObj.put("system_info", sysInfo);

            sysInfo.put("name", rs.value("lang_1_name"));
            sysInfo.put("uuid", rs.value("product_uuid"));
            sysInfo.put("catalog_uuid", rs.value("catalog_uuid"));
            sysInfo.put("folder_name", rs.value("folder_name"));

            String folderId = PagesUtil.parseNull(rs.value("folder_id"));
            String folderTable = CATALOG_DB + ".products_folders";
            JSONObject folderObj = getFolderJSON(folderId, folderTable, true, true, false);
            sysInfo.put("folder", folderObj != null ? folderObj : PagesUtil.newJSONObject());

            JSONObject internalInfo = PagesUtil.newJSONObject();
            retObj.put("internal_info", internalInfo);

            internalInfo.put("id", rs.value("id"));
            internalInfo.put("site_id", rs.value("site_id"));
            internalInfo.put("created_ts", rs.value("created_on"));
            internalInfo.put("created_by", rs.value("created_by"));
            internalInfo.put("updated_ts", rs.value("updated_on"));
            internalInfo.put("updated_by", rs.value("updated_by"));

            JSONObject details = PagesUtil.newJSONObject();
            retObj.put("details", details);
            JSONArray details_lang = new JSONArray();
            retObj.put("details_lang", details_lang);

            List<Language> langList = PagesUtil.getLangs(Etn,siteId);

            if (isFilterLangs) {
                langList.removeIf(lang -> !filterLangIds.contains(String.valueOf(lang.id)));
            }

            HashMap<String, JSONObject> detailLangHM = new HashMap<>();
            for (Language curLang : langList) {
                JSONObject detailLangObj = PagesUtil.newJSONObject();
                detailLangObj.put("langue_code", curLang.code);
                if (isViewData) {
                    detailLangObj.put("url", getEntityUrl(id, "product", curLang.id));
                }
                detailLangObj.put("description", PagesUtil.newJSONObject());
                detailLangObj.put("essential_blocks", new JSONArray());
                detailLangObj.put("tabs", new JSONArray());
                detailLangObj.put("images", new JSONArray());

                detailLangHM.put("" + curLang.id, detailLangObj);
                details_lang.put(detailLangObj);
            }

            java.util.Set<String> excludedCols = new HashSet<>(EntityExport.getCatalogExcludedColumns());
            excludedCols.add("product_uuid");
            excludedCols.add("catalog_id");
            excludedCols.add("folder_id");
            excludedCols.add("folder_name");
            excludedCols.add("folder_uuid");

            for (int i = 0; i < rs.ColName.length; i++) {
                String colName = rs.ColName[i].toLowerCase();
                if (!isViewData && excludedCols.contains(colName)) {
                    //skip excluded columns if not view data (i.e. export data)
                }
                else if (colName.startsWith("lang_")) {
                    String[] colNameArr = colName.split("_");
                    if (colNameArr.length == 3 && detailLangHM.containsKey(colNameArr[1])) {
                        detailLangHM.get(colNameArr[1]).put(colNameArr[2], rs.value(i));
                    }
                }
                else {
                    details.put(colName, rs.value(i));
                }
            }

            q = "SELECT pd.*,pt.custom_id as page_template_cstm_id  FROM " + CATALOG_DB + ".product_descriptions pd "
                + " JOIN " + CATALOG_DB + ".language l ON l.langue_id = pd.langue_id "
                + " LEFT JOIN page_templates pt on pd.page_template_id = pt.id WHERE pd.product_id = " + escape.cote(id);
            if (isFilterLangs) {
                q += " AND l.langue_id IN (" + commaSepLangIds + ")";
            }

            Set pRs = Etn.execute(q);
            while (pRs.next()) {
                JSONObject curObj = PagesUtil.newJSONObject();
                for (int i = 0; i < pRs.ColName.length; i++) {
                    String colName = pRs.ColName[i].toLowerCase();
                    if (!"product_id".equals(colName) && !"langue_id".equals(colName)) {
                        curObj.put(colName, pRs.value(i));
                    }
                }
                detailLangHM.get(pRs.value("langue_id")).put("description", curObj);
            }

            q = "SELECT peb.* FROM " + CATALOG_DB + ".product_essential_blocks peb "
                + " JOIN " + CATALOG_DB + ".language l ON l.langue_id = peb.langue_id "
                + " WHERE peb.product_id = " + escape.cote(id);
            if (isFilterLangs) {
                q += " AND l.langue_id IN (" + commaSepLangIds + ")";
            }

            pRs = Etn.execute(q);
            while (pRs.next()) {
                JSONObject curObj = PagesUtil.newJSONObject();
                for (int i = 0; i < pRs.ColName.length; i++) {
                    String colName = pRs.ColName[i].toLowerCase();
                    if (!"product_id".equals(colName) && !"id".equals(colName) && !"langue_id".equals(colName)) {
                        curObj.put(colName, pRs.value(i));
                    }
                }
                detailLangHM.get(pRs.value("langue_id"))
                    .getJSONArray("essential_blocks").put(curObj);
            }

            q = "SELECT pt.* FROM " + CATALOG_DB + ".product_tabs pt "
                + " JOIN " + CATALOG_DB + ".language l ON l.langue_id = pt.langue_id "
                + " WHERE pt.product_id = " + escape.cote(id);
            if (isFilterLangs) {
                q += " AND l.langue_id IN (" + commaSepLangIds + ")";
            }
			q += " order by case coalesce(pt.order_seq,'') when '' then 999999 else pt.order_seq end ";

            pRs = Etn.execute(q);
            while (pRs.next()) {
                JSONObject curObj = PagesUtil.newJSONObject();

                curObj.put("langue_code", pRs.value("langue_code"));
                curObj.put("name", pRs.value("name"));
                curObj.put("content", pRs.value("content"));
                curObj.put("order_seq", pRs.value("order_seq"));

                detailLangHM.get(pRs.value("langue_id"))
                    .getJSONArray("tabs").put(curObj);
            }

            q = "SELECT pimages.* FROM " + CATALOG_DB + ".product_images pimages "
                + " JOIN " + CATALOG_DB + ".language l ON l.langue_id = pimages.langue_id "
                + " WHERE pimages.product_id = " + escape.cote(id);
            if (isFilterLangs) {
                q += " AND l.langue_id IN (" + commaSepLangIds + ")";
            }
			q += " order by pimages.sort_order";

            pRs = Etn.execute(q);
            while (pRs.next()) {
                JSONObject curObj = PagesUtil.newJSONObject();
                for (int i = 0; i < pRs.ColName.length; i++) {
                    String colName = pRs.ColName[i].toLowerCase();
                    if (!"product_id".equals(colName) && !"id".equals(colName) && !"langue_id".equals(colName)) {
                        curObj.put(colName, pRs.value(i));
                    }
                }
                detailLangHM.get(pRs.value("langue_id"))
                    .getJSONArray("images").put(curObj);
            }

            JSONArray tags = new JSONArray();
            retObj.put("tags", tags);
            q = "SELECT t.id, t.label FROM " + CATALOG_DB + ".product_tags pt "
                + " JOIN " + CATALOG_DB + ".tags t ON pt.tag_id = t.id "
                + " AND pt.product_id = " + escape.cote(id)
                + " ORDER BY t.label";
            Set tagsRs = Etn.execute(q);
            ArrayList<String> tagIdsList = new ArrayList<>();
            while (tagsRs.next()) {
                JSONObject tagObj = PagesUtil.newJSONObject();
                tagObj.put("id", tagsRs.value("id"));
                tagObj.put("label", tagsRs.value("label"));
                tags.put(tagObj);
                tagIdsList.add(escape.cote(tagsRs.value("id")));
            }

            JSONArray attributes = new JSONArray();
            retObj.put("attributes", attributes);
            q = "SELECT ca.name AS attribute_name, ca.type AS attribute_type, pav.attribute_value "
                + " FROM " + CATALOG_DB + ".product_attribute_values pav  "
                + " JOIN " + CATALOG_DB + ".catalog_attributes ca ON pav.cat_attrib_id = ca.cat_attrib_id "
                + " WHERE ca.type = 'specs' AND  pav.product_id = " + escape.cote(id);
            Set attribRs = Etn.execute(q);
            while (attribRs.next()) {
                JSONObject attribObj = PagesUtil.newJSONObject();
                attribObj.put("attribute_name", attribRs.value("attribute_name"));
                attribObj.put("attribute_type", attribRs.value("attribute_type"));
                attribObj.put("attribute_value", attribRs.value("attribute_value"));

                attributes.put(attribObj);
            }

            JSONArray variants = new JSONArray();
            retObj.put("variants", variants);

            q = " SELECT distinct pv.* FROM " + CATALOG_DB + ".product_variants pv ";

            if(orderClause.length()>0 && orderClause.contains("pvd.")){
                q+= " left join "+CATALOG_DB+".product_variant_details pvd on pv.id=pvd.product_variant_id ";
            }
            q+=" WHERE product_id = " + escape.cote(id);
            
            if(orderClause.length()>0 && (orderClause.contains("pv.") || orderClause.contains("pvd."))){
                q+=" ORDER BY "+orderClause;
            }

            Set pvRs = Etn.execute(q);
            ArrayList<String> skuList = new ArrayList<>();
            while (pvRs.next()) {
                JSONObject variantObj = PagesUtil.newJSONObject();
                variants.put(variantObj);

                String curVariantId = pvRs.value("id");
                skuList.add(escape.cote(pvRs.value("sku")));

                for (int i = 0; i < pvRs.ColName.length; i++) {
                    String colName = pvRs.ColName[i].toLowerCase();

                    if ("id".equals(colName) || "product_id".equals(colName)
                        || colName.startsWith("created_") || colName.startsWith("updated_")) {
                        //skip
                    }
                    else {
                        variantObj.put(colName, pvRs.value(i));
                    }
                }

                JSONArray variant_details = new JSONArray();
                variantObj.put("variant_details", variant_details);
                HashMap<String, JSONObject> variantLangHM = new HashMap<>();

                q = " SELECT pvd.*, l.langue_code FROM " + CATALOG_DB + ".product_variant_details pvd "
                    + " JOIN " + CATALOG_DB + ".language l ON l.langue_id = pvd.langue_id "
                    + " WHERE pvd.product_variant_id = " + escape.cote(curVariantId);
                if (isFilterLangs) {
                    q += " AND l.langue_id IN (" + commaSepLangIds + ")";
                }

                Set pvdRs = Etn.execute(q);
                while (pvdRs.next()) {
                    JSONObject variantDetailObj = PagesUtil.newJSONObject();

                    variant_details.put(variantDetailObj);

                    for (int i = 0; i < pvdRs.ColName.length; i++) {
                        String colName = pvdRs.ColName[i].toLowerCase();

                        if ("product_variant_id".equals(colName) || "langue_id".equals(colName)) {
                            //skip
                        }
                        else {
                            variantDetailObj.put(colName, pvdRs.value(i));
                        }
                    }
                    variantDetailObj.put("variant_resources", new JSONArray());
                    variantLangHM.put(pvdRs.value("langue_id"), variantDetailObj);
                }//while  pvdRs

                JSONArray variant_attributes = new JSONArray();
                variantObj.put("variant_attributes", variant_attributes);

                q = "SELECT ca.name as attribute_name, cav.attribute_value, cav.small_text , cav.color "
                    + " FROM " + CATALOG_DB + ".product_variant_ref pvr "
                    + " JOIN " + CATALOG_DB + ".catalog_attributes ca ON ca.cat_attrib_id = pvr.cat_attrib_id "
                    + " JOIN " + CATALOG_DB + ".catalog_attribute_values cav ON cav.id = pvr.catalog_attribute_value_id "
                    + " WHERE pvr.product_variant_id = " + escape.cote(curVariantId);
                Set pvrefRs = Etn.execute(q);
                while (pvrefRs.next()) {
                    JSONObject variantRefObj = PagesUtil.newJSONObject();
                    variant_attributes.put(variantRefObj);

                    variantRefObj.put("attribute_name", pvrefRs.value("attribute_name"));
                    variantRefObj.put("attribute_value", pvrefRs.value("attribute_value"));
                    variantRefObj.put("color", pvrefRs.value("color"));
                    variantRefObj.put("small_text", pvrefRs.value("small_text"));

                }//while  pvrefRs

                q = " SELECT pvr.* FROM " + CATALOG_DB + ".product_variant_resources pvr "
                    + " JOIN " + CATALOG_DB + ".language l ON l.langue_id = pvr.langue_id "
                    + " WHERE pvr.product_variant_id = " + escape.cote(curVariantId);
                if (isFilterLangs) {
                    q += " AND l.langue_id IN (" + commaSepLangIds + ")";
                }
				q += " order by pvr.sort_order ";

                Set pvResourceRs = Etn.execute(q);
                while (pvResourceRs.next()) {
                    JSONObject variantResourceObj = PagesUtil.newJSONObject();
                    variantLangHM.get(pvResourceRs.value("langue_id"))
                        .getJSONArray("variant_resources").put(variantResourceObj);

                    for (int i = 0; i < pvResourceRs.ColName.length; i++) {
                        String colName = pvResourceRs.ColName[i].toLowerCase();

                        if ("id".equals(colName) || "product_variant_id".equals(colName) || "langue_id".equals(colName)) {
                            //skip
                        }
                        else {
                            variantResourceObj.put(colName, pvResourceRs.value(i));
                        }
                    }
                }//while  pvResourceRs

            }//while pvRs

            if (isViewData) {
                String tagIds = String.join(",", tagIdsList);
                String skus = String.join(",", skuList);
                //promotions and come withs
                JSONArray promotions = new JSONArray();
                retObj.put("promotions", promotions);
                q = "SELECT p.* FROM " + CATALOG_DB + ".promotions p "
                    + " JOIN " + CATALOG_DB + ".promotions_rules pr on p.id = pr.promotion_id "
                    + " WHERE p.site_id = " + escape.cote(siteId)
                    + " AND ( "
                    + "   (pr.applied_to_type='product' AND pr.applied_to_value=" + escape.cote(rs.value("id")) + ")"
                    + "   OR (pr.applied_to_type='catalog' AND pr.applied_to_value=" + escape.cote(rs.value("catalog_id")) + ")"
                    + "   OR (pr.applied_to_type='product_type' AND pr.applied_to_value=" + escape.cote(rs.value("catalog_type")) + ")"
                    + "   OR (pr.applied_to_type='manufacturer' AND pr.applied_to_value=" + escape.cote(rs.value("brand_name")) + ")"
                    + ((tagIds.length() > 0) ? "   OR (pr.applied_to_type='tag' AND pr.applied_to_value IN (" + tagIds + " ) )" : "")
                    + ((skus.length() > 0) ? "   OR (pr.applied_to_type='sku' AND pr.applied_to_value IN (" + skus + ") )" : "")
                    + " ) GROUP BY p.id "
                    + " ORDER BY p.order_seq ASC";
                pRs = Etn.execute(q);
                while (pRs.next()) {

                    JSONObject curObj = PagesUtil.newJSONObject();
                    promotions.put(curObj);
                    for (String colName : pRs.ColName) {
                        colName = colName.toLowerCase();
                        if (colName.startsWith("lang_")
                            || colName.startsWith("created_")
                            || colName.startsWith("updated_")
                            || colName.equals("site_id")
                            || colName.equals("version")) {
                            //skip column
                        }
                        else {
                            curObj.put(colName.toLowerCase(), pRs.value(colName));
                        }
                        JSONArray promoDetailLang = new JSONArray();
                        curObj.put("details_lang", promoDetailLang);
                        for (Language curLang : langList) {
                            JSONObject detailLangObj = PagesUtil.newJSONObject();
                            promoDetailLang.put(detailLangObj);
                            detailLangObj.put("langue_code", curLang.code);
                            detailLangObj.put("title", pRs.value("lang_" + curLang.id + "_title"));
                            detailLangObj.put("description", pRs.value("lang_" + curLang.id + "_description"));
                        }

                        JSONArray rulesList = new JSONArray();
                        curObj.put("rules", rulesList);
                        Set pRs2 = Etn.execute("SELECT * FROM " + CATALOG_DB + ".promotions_rules WHERE promotion_id= " + escape.cote(pRs.value("id")));
                        while (pRs2.next()) {
                            JSONObject curRule = PagesUtil.newJSONObject();
                            rulesList.put(curRule);
                            curRule.put("applied_to_type", pRs2.value("applied_to_type"));
                            curRule.put("applied_to_value", pRs2.value("applied_to_value"));
                        }
                    }
                }//promotions

                //promotions and come withs
                JSONArray comewiths = new JSONArray();
                retObj.put("comewiths", comewiths);
                q = "SELECT c.* FROM " + CATALOG_DB + ".comewiths c "
                    + " JOIN " + CATALOG_DB + ".comewiths_rules cr ON c.id = cr.comewith_id "
                    + " WHERE c.site_id = " + escape.cote(siteId)
                    + " AND ( "
                    + "   (cr.associated_to_type='product' AND cr.associated_to_value=" + escape.cote(rs.value("id")) + ")"
                    + "   OR (cr.associated_to_type='catalog' AND cr.associated_to_value=" + escape.cote(rs.value("catalog_id")) + ")"
                    + "   OR (cr.associated_to_type='product_type' AND cr.associated_to_value=" + escape.cote(rs.value("catalog_type")) + ")"
                    + "   OR (cr.associated_to_type='manufacturer' AND cr.associated_to_value=" + escape.cote(rs.value("brand_name")) + ")"
                    + ((tagIds.length() > 0) ? "   OR (cr.associated_to_type='tag' AND cr.associated_to_value IN (" + tagIds + " ) ) " : "")
                    + ((skus.length() > 0) ? "   OR (cr.associated_to_type='sku' AND cr.associated_to_value IN (" + skus + ") ) " : "")
                    + " ) GROUP BY c.id "
                    + " ORDER BY c.order_seq ASC";
                // log(q);
                pRs = Etn.execute(q);
                while (pRs.next()) {
                    JSONObject curObj = PagesUtil.newJSONObject();
                    comewiths.put(curObj);
                    for (String colName : pRs.ColName) {
                        colName = colName.toLowerCase();
                        if (colName.startsWith("lang_")
                            || colName.startsWith("created_")
                            || colName.startsWith("updated_")
                            || colName.startsWith("version")
                            || colName.equals("site_id")) {
                            //skip
                        }
                        else {
                            curObj.put(colName.toLowerCase(), pRs.value(colName));
                        }
                        JSONArray promoDetailLang = new JSONArray();
                        curObj.put("details_lang", promoDetailLang);
                        for (Language curLang : langList) {
                            JSONObject detailLangObj = PagesUtil.newJSONObject();
                            promoDetailLang.put(detailLangObj);
                            detailLangObj.put("langue_code", curLang.code);
                            detailLangObj.put("description", pRs.value("lang_" + curLang.id + "_description"));
                        }

                        JSONArray rulesList = new JSONArray();
                        curObj.put("rules", rulesList);
                        Set pRs2 = Etn.execute("SELECT * FROM " + CATALOG_DB + ".comewiths_rules WHERE comewith_id= " + escape.cote(pRs.value("id")));
                        while (pRs2.next()) {
                            JSONObject curRule = PagesUtil.newJSONObject();
                            rulesList.put(curRule);
                            curRule.put("associated_to_type", pRs2.value("associated_to_type"));
                            curRule.put("associated_to_value", pRs2.value("associated_to_value"));
                        }
                    }
                }

            }//if viewData

        }
        return retObj;
    }

    public JSONObject getFormExportJson(String id) throws Exception {

        JSONObject retObj = PagesUtil.newJSONObject();
        JSONObject systemInfoObj = PagesUtil.newJSONObject();
        JSONObject internalInfoObj = PagesUtil.newJSONObject();

        retObj.put("item_type", "forms");
        retObj.put("system_info", systemInfoObj);
        retObj.put("internal_info", internalInfoObj);

        String q = "";
        Set rs = null;
        String tableName = "";
        int customerMailId = 0;
        int backofficeMailId = 0;

        q = " SELECT * "
            + " FROM " + getParm("FORMS_DB") + ".process_forms pf "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("process_forms", getJsonObject(rs));
            rs.moveFirst();
            if (rs.next()) {

                tableName = PagesUtil.parseNull(rs.value("table_name"));
                customerMailId = PagesUtil.parseInt(rs.value("cust_eid"));
                backofficeMailId = PagesUtil.parseInt(rs.value("bk_ofc_eid"));

                systemInfoObj.put("name", PagesUtil.parseNull(rs.value("process_name")));
                systemInfoObj.put("table_name", PagesUtil.parseNull(rs.value("table_name")));
                systemInfoObj.put("id", PagesUtil.parseNull(rs.value("form_id")));
                systemInfoObj.put("type", PagesUtil.parseNull(rs.value("type")));


                internalInfoObj.put("id", rs.value("form_id"));
                internalInfoObj.put("site_id", rs.value("site_id"));
                internalInfoObj.put("created_ts", rs.value("created_on"));
                internalInfoObj.put("created_by", rs.value("created_by"));
                internalInfoObj.put("updated_ts", rs.value("updated_on"));
                internalInfoObj.put("updated_by", rs.value("updated_by"));
            }
        }

        q = " SELECT pfd.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".process_form_descriptions pfd "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.form_id = pfd.form_id"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("form_descriptions", getJsonArray(rs));
        }

        q = " SELECT pfl.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".process_form_lines pfl "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.form_id = pfl.form_id"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("form_lines", getJsonArray(rs));
        }

        q = " SELECT fr.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".freq_rules fr "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.form_id = fr.form_id"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("form_rules", getJsonArray(rs, "freq_rules"));
        }

        q = " SELECT m.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".mails m, "
            + getParm("FORMS_DB") + ".mail_config mc "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.table_name = mc.ordertype"
            + " AND pf.site_id = " + escape.cote(siteId)
            + " AND m.id in (" + escape.cote(customerMailId + "") + ", " + escape.cote(backofficeMailId + "") + ")";

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            String filePath = getParm("MAIL_UPLOAD_PATH") + "mail";

            JSONObject mailConfigurationObject = PagesUtil.newJSONObject();

            mailConfigurationObject.put("configuration", getJsonArray(rs, "mails"));

            Set langRs = Etn.execute("SELECT * FROM language");

            while (langRs.next()) {

                String langId = langRs.value("langue_id");
                String langCode = langRs.value("langue_code");

                if (!langId.equals("1")) {
                    langCode = "_" + langCode;
                }
                else {
                    langCode = "";
                }

                mailConfigurationObject.put("customer_template" + langCode, readDataFromFile(filePath + customerMailId + langCode, tableName));
                mailConfigurationObject.put("bkoffice_template" + langCode, readDataFromFile(filePath + backofficeMailId + langCode, tableName));
                mailConfigurationObject.put("customer_template_freemarker" + langCode, readDataFromFile(filePath + customerMailId + langCode + ".ftl", tableName));
                mailConfigurationObject.put("bkoffice_template_freemarker" + langCode, readDataFromFile(filePath + backofficeMailId + langCode + ".ftl", tableName));

            }

            retObj.put("mails", mailConfigurationObject);
        }

        q = " SELECT mc.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".mails m, "
            + getParm("FORMS_DB") + ".mail_config mc "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.table_name = mc.ordertype"
            + " AND m.id = mc.id"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("mail_config", getJsonObject(rs));
        }

        q = " SELECT pff.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".process_form_fields pff "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.form_id = pff.form_id"
            + " AND pf.site_id = " + escape.cote(siteId) + " ORDER BY pff.seq_order, pff.id";

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("form_fields", getJsonArray(rs, "process_form_fields"));
        }

        q = " SELECT pffd.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".process_form_fields pff, "
            + getParm("FORMS_DB") + ".process_form_field_descriptions pffd "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.form_id = pff.form_id"
            + " AND pf.form_id = pffd.form_id"
            + " AND pff.form_id = pffd.form_id"
            + " AND pff.field_id = pffd.field_id"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("form_field_descriptions", getJsonArray(rs));
        }

        q = " SELECT fsf.form_id, fsf.field_id, fsf.show_range, fsf.display_order FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".form_search_fields fsf "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.form_id = fsf.form_id"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("form_search_fields", getJsonArray(rs));
        }

        q = " SELECT frf.form_id, frf.field_id, frf.display_order FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".form_result_fields frf "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.form_id = frf.form_id"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("form_result_fields", getJsonArray(rs));
        }

        /* -------------- (Ahsan) Data connected to phases obsolete as per discussion (12 June 2023)-------------------------

        q = " SELECT c.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".coordinates c "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.table_name = c.process"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("process_coordinates", getJsonArray(rs, "coordinates"));
        }

        q = " SELECT r.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".rules r "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.table_name = r.start_proc"
            + " AND pf.table_name = r.next_proc"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("process_rules", getJsonArray(rs, "rules"));
        }

        q = " SELECT p.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".phases p "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.table_name = p.process"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("process_phases", getJsonArray(rs));
        }

        q = " SELECT ha.* FROM "
            + getParm("FORMS_DB") + ".process_forms pf, "
            + getParm("FORMS_DB") + ".has_action ha "
            + " WHERE pf.form_id = " + escape.cote(id)
            + " AND pf.table_name = ha.start_proc"
            + " AND pf.site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {

            retObj.put("process_has_action", getJsonObject(rs));
        }

        ---------------Till Here ------------------------*/ 

        return retObj;
    }
    public JSONObject getVariableExportJson(String id) throws Exception {

        JSONObject retObj = PagesUtil.newJSONObject();
        JSONObject systemInfoObj = PagesUtil.newJSONObject();

        retObj.put("item_type", "variable");
        retObj.put("system_info", systemInfoObj);

        String q = "";
        Set rs = null;

        q = " SELECT * FROM variables WHERE id = " + escape.cote(id);

        rs = Etn.execute(q);

        if (rs.rs.Rows > 0) {
            if (rs.next()) {
                systemInfoObj.put("name", PagesUtil.parseNull(rs.value("name")));
                systemInfoObj.put("value", PagesUtil.parseNull(rs.value("value")));
                systemInfoObj.put("id", PagesUtil.parseNull(rs.value("id")));
                systemInfoObj.put("is_editable", PagesUtil.parseNull(rs.value("is_editable")));
            }
        }

        return retObj;
    }

    public void clearSectionAndFieldIds(JSONArray sectionsList) {

        for (int i = 0; i < sectionsList.length(); i++) {
            JSONObject section = sectionsList.getJSONObject(i);

            section.remove("id");
            section.remove("parent_section_id");

            //fields processing
            JSONArray fieldsList = section.getJSONArray("fields");
            for (int j = 0; j < fieldsList.length(); j++) {
                JSONObject field = fieldsList.getJSONObject(j);
                field.remove("id");
            }

            //nested sections processing
            JSONArray nestedSectionsList = section.getJSONArray("sections");
            clearSectionAndFieldIds(nestedSectionsList);

        }//for sectionsList
    }
}
