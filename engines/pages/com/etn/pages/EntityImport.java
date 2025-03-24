package com.etn.pages;

import com.etn.Client.Impl.ClientSql;
import com.etn.asimina.util.UrlHelper;
import com.etn.beans.Etn;
import com.etn.beans.app.GlobalParm;
import com.etn.exception.SimpleException;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.util.Logger;
import freemarker.cache.FileTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateExceptionHandler;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

public class EntityImport {
    protected Etn Etn;
    protected String siteId;
    protected boolean importDatetime;
    protected String targetCatalogId;
    protected String themeId;
    protected Boolean isProcessingStructContent = false;
    protected int pid = 1;

    public EntityImport(Etn Etn, String siteId, int pid) {
        init(Etn, siteId, false, "", pid);
    }

    public EntityImport(Etn Etn, String siteId, boolean importDatetime, int pid) {
        init(Etn, siteId, importDatetime, "", pid);
    }

    public EntityImport(Etn Etn, String siteId, boolean importDatetime, String targetCatalogId, int pid) {
        init(Etn, siteId, importDatetime, targetCatalogId, pid);
    }

    protected void init(Etn Etn, String siteId, boolean importDatetime, String targetCatalogId, int pid) {
        this.Etn = Etn;
        this.siteId = siteId;
        this.importDatetime = importDatetime;
        this.targetCatalogId = targetCatalogId;
        this.pid = pid;
    }

    public String getSiteId() {
        return siteId;
    }

    public void setSiteId(String siteId) {
        this.siteId = siteId;
    }

    public boolean isImportDatetime() {
        return importDatetime;
    }

    public void setImportDatetime(boolean importDatetime) {
        this.importDatetime = importDatetime;
    }

    public String getTargetCatalogId() {
        return targetCatalogId;
    }

    public void setTargetCatalogId(String targetCatalogId) {
        this.targetCatalogId = targetCatalogId;
    }

    public int getPid() {
        return pid;
    }

    public void setPid(int pid) {
        this.pid = pid;
    }

    public void setThemeId(String themeId ) {
         this.themeId = themeId;
    }

    public final static String IMPORT_TYPE_KEEP = "keep";
    public final static String IMPORT_TYPE_REPLACE_ALL = "replace_all";
    public final static String IMPORT_TYPE_REPLACE_PARTIAL = "replace_partial";
    public final static String IMPORT_TYPE_DUPLICATE = "duplicate";

    private boolean isSectionEmpty = true;

    private void rollbackPage(String id, String type) {
        String tableName = "freemarker_pages";
        if (type.equals(Constant.PAGE_TYPE_STRUCTURED)) {
            tableName = "structured_contents";
        }
        if(id.length()>0){
            Etn.execute("DELETE FROM " + tableName + " WHERE id = " + escape.cote(id));
            // delete pages associated to this id
            Etn.execute("DELETE FROM pages WHERE parent_page_id = " + escape.cote(id)+" AND type = "+escape.cote(type));
            Etn.execute("DELETE FROM parent_pages_blocs WHERE page_id = " + escape.cote(id)+" AND type = "+escape.cote(type));
            Etn.execute("DELETE FROM parent_pages_forms WHERE page_id = " + escape.cote(id)+" AND type = "+escape.cote(type));
            if (type.equals(Constant.PAGE_TYPE_STRUCTURED)) {
                Etn.execute("DELETE FROM structured_contents_details WHERE content_id = "+escape.cote(id));
            }
        }
    }

    public String getTagId(JSONObject tagObj) {

        String tagId = PagesUtil.parseNull(tagObj.optString("id"));
        String tagLabel = PagesUtil.parseNull(tagObj.optString("label"));

        if (tagId.length() == 0) {
            return null;
        }

        String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");
        String q = "SELECT id FROM " + CATALOG_DB + ".tags "
                   + " WHERE site_id = " + escape.cote(siteId)
                   + " AND id = " + escape.cote(tagId);
        Set rs = Etn.execute(q);
        if (rs.next()) {
            return tagId;
        }
        else {
            //insert tag
            if (tagLabel.length() == 0) {
                return null;
            }

            q = "INSERT INTO " + CATALOG_DB + ".tags(id,site_id,label, created_by, created_on) VALUES ("
                + escape.cote(tagId) + ", "
                + escape.cote(siteId) + ", "
                + escape.cote(tagLabel) + ", "
                + escape.cote("" + pid) + ", NOW() )";
            Etn.executeCmd(q);

            return tagId;
        }

    }

    public JSONArray verifyImportItemsList(JSONArray itemsList) {

        JSONArray dataList = new JSONArray();
        for (int i = 0; i < itemsList.length(); i++) {

            String id = "" + (i + 1);
            String name = "";
            String itemType = "";
            String itemStatus = "";
            String errorMsg = "";

            JSONObject dataObj = new JSONObject();
            dataObj.put("id", "" + (i + 1));

            dataObj.put("name", "");
            dataObj.put("type", "");
            dataObj.put("status", "");
            dataObj.put("error", "");

            JSONObject curItemData = null;

            try {

                curItemData = itemsList.optJSONObject(i);

                if (curItemData == null) {
                    curItemData = new JSONObject();
                    throw new Exception("Error: item data is not a JSON object.");
                }
                errorMsg += verifyImportItem(curItemData, dataObj);
            }
            catch (Exception itemEx) {
                errorMsg += itemEx.getMessage() + ",";
            }

            if (errorMsg.length() > 0) {
                dataObj.put("status", "error");
            }

            dataObj.put("item_data", curItemData);
            dataObj.put("error", errorMsg);

            dataList.put(dataObj);
        }
        return dataList;
    }

    public String verifyImportItem(JSONObject itemObj, JSONObject retObj) {

        String retErrorMsg = "";
        try {
            String itemType = itemObj.optString("item_type", "");
            retObj.put("type", itemType);

            switch (itemType) {
                case "freemarker_page":
                case "page":
                    retErrorMsg += verifyImportItemFreemarkerPage(itemObj, retObj);
                    break;
                case "page_template":
                    retErrorMsg += verifyImportItemPageTemplate(itemObj, retObj);
                    break;

                case "bloc":
                    retErrorMsg += verifyImportItemBloc(itemObj, retObj);
                    break;

                case "bloc_template":
                    retErrorMsg += verifyImportItemBlocTemplate(itemObj, retObj);
                    break;

                case "library":
                    retErrorMsg += verifyImportItemLibrary(itemObj, retObj);
                    break;

                // case "structured_catalog":
                //     retErrorMsg += verifyImportItemStructuredCatalog(itemObj, retObj);
                //     break;

                case "structured_content":
                    retErrorMsg += verifyImportItemStructuredContent(itemObj, retObj);
                    break;

                case "structured_page":
                case "store":
                    retErrorMsg += verifyImportItemStructuredPage(itemObj, retObj);
                    break;

                case "catalog":
                    retErrorMsg += verifyImportItemCommercialCatalog(itemObj, retObj);
                    break;

                case "product":
                    retErrorMsg += verifyImportItemCommercialProduct(itemObj, retObj);
                    break;

                case "forms":
                    retErrorMsg += verifyImportItemForms(itemObj, retObj);
                    break;

                case "variable":
                    retErrorMsg += verifyImportItemVariables(itemObj, retObj);
                    break;

                default:
                    throw new Exception("Error: Invalid item type.");
            }

            if (importDatetime) {
                retErrorMsg += verifyImportDatetimeFormat(itemObj, retObj);
            }

        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }

        return retErrorMsg;
    }

    public String verifyImportDatetimeFormat(JSONObject itemObj, JSONObject retObj) {

        String retErrorMsg = "";
        try {

            JSONObject internalInfo = itemObj.optJSONObject("internal_info");

            if (internalInfo == null) {
                retErrorMsg += "Internal info not found,";
            }
            else {
                String createdTs = internalInfo.optString("created_ts");
                String updatedTs = internalInfo.optString("updated_ts");

                String srcFormat1 = "dd/MM/yyyy HH:mm:ss";
                String srcFormat2 = "yyyy-MM-dd HH:mm:ss";

                String createdDatetime = PagesUtil.convertDateTimeToStandardFormat(createdTs, srcFormat1);
                if (createdDatetime.length() == 0) {
                    //check with standard ISO format
                    createdDatetime = PagesUtil.convertDateTimeToStandardFormat(createdTs, srcFormat2);
                    if (createdDatetime.length() == 0) {
                        //failed both formats  mark error
                        retErrorMsg += "Creation datetime field (created_ts) format invalid,";
                    }
                }

                String updatedDatetime = PagesUtil.convertDateTimeToStandardFormat(updatedTs, srcFormat1);
                if (updatedDatetime.length() == 0) {
                    //check with standard ISO format
                    updatedDatetime = PagesUtil.convertDateTimeToStandardFormat(updatedTs, srcFormat2);
                    if (updatedDatetime.length() == 0) {
                        //failed both formats  mark error
                        retErrorMsg += "Last update datetime field (updated_ts) format invalid,";
                    }
                }
            }

            if (retErrorMsg.length() > 0) {
                retObj.put("status", "error");
            }

        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }

        return retErrorMsg;
    }

    public String verifyImportItemLibrary(JSONObject itemObj, JSONObject retObj) {

        String retErrorMsg = "";
        try {
            JSONObject sysInfo = itemObj.optJSONObject("system_info");
            JSONArray detailLangs = itemObj.optJSONArray("detail_langs");
            
            if(detailLangs == null)
            {
                detailLangs = new JSONArray();
                String query = "select sl.langue_id,l.langue_code from "+GlobalParm.getParm("COMMONS_DB")+
                    ".sites_langs sl left join language l on l.langue_id=sl.langue_id where sl.site_id="+escape.cote(siteId);
                Set rsLang = Etn.execute(query);
                
                while(rsLang.next()){
                    JSONObject detailsLangObj = PagesUtil.newJSONObject();
                    JSONArray bodyFilesList = itemObj.optJSONArray("body_files");
                    JSONArray headFilesList = itemObj.optJSONArray("head_files");
                    
                    if(bodyFilesList == null) throw new Exception("Error Body files list not found");
                    if(headFilesList == null) throw new Exception("Error head files list not found");

                    detailsLangObj.put("language_code", rsLang.value("langue_code"));
                    detailsLangObj.put("body_files", bodyFilesList);
                    detailsLangObj.put("head_files", headFilesList);
                    detailLangs.put(detailsLangObj);
                }
                itemObj.put("detail_langs",detailLangs);
            }

            if(detailLangs!=null && detailLangs.length()>0){
                int langCount = 0;
                for(int i =0; i < detailLangs.length(); i++){
                    JSONObject langObj = detailLangs.getJSONObject(i);
                    
                    String lang = langObj.optString("language_code");
                    if (lang==null) {
                        retErrorMsg += "Language code does not found,";
                    }else{
                        Set rsLang = Etn.execute("SELECT * FROM "+GlobalParm.getParm("COMMONS_DB")+".sites_langs sl JOIN language l ON sl.langue_id=l.langue_id "
                        +" WHERE l.langue_code="+escape.cote(lang)+" AND sl.site_id="+escape.cote(siteId));
                        if(rsLang.rs.Rows==0){
                            langCount++;
                            continue;
                        }
                    }

                    JSONArray headFiles = langObj.optJSONArray("head_files");
                    JSONArray bodyFiles = langObj.optJSONArray("body_files");
                    
                    if (headFiles == null) {
                        retErrorMsg += "Head files list not found,";
                    }
                    
                    if (bodyFiles == null) {
                        retErrorMsg += "Body files list not found,";
                    }
                }

                if(langCount>=detailLangs.length()){
                    retErrorMsg += "No valid language found.";
                }

            }else{
                retErrorMsg += "Language details not found,";
            }

            String name = "";
            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }
            if (sysInfo != null) {
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }
            }
            

            String itemStatus = "";
            if (retErrorMsg.length() > 0) {
                retObj.put("status", "error");
            }
            else {
                itemStatus = "new";
                String q = "SELECT id FROM libraries WHERE name = "+escape.cote(name)+" AND site_id = " + escape.cote(siteId);
                Set rs = Etn.execute(q);
                if (rs.next()) {
                    itemStatus = "existing";
                }
            }
            retObj.put("name", name);
            retObj.put("status", itemStatus);
        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }

        return retErrorMsg;
    }


    public String verifyImportItemBlocTemplate(JSONObject itemObj, JSONObject retObj) {

        String retErrorMsg = "";
        try {

            JSONObject sysInfo = itemObj.optJSONObject("system_info");
            JSONObject resources = itemObj.optJSONObject("resources");

            JSONArray sections = itemObj.optJSONArray("sections");

            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }


            String name = "";
            String type = "";
            String custom_id = "";

            if (sysInfo != null) {
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                type = PagesUtil.parseNull(sysInfo.optString("type"));
                custom_id = PagesUtil.parseNull(sysInfo.optString("custom_id"));

                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }

                if (type.length() == 0) {
                    retErrorMsg += "Type not found,";
                }
                else {
                    String[] validTemplateTypes = Constant.getTemplateTypes();
                    boolean isInvalid = true;
                    for (String validType : validTemplateTypes) {
                        if (validType.equals(type)) {
                            isInvalid = false;
                            break;
                        }
                    }

                    if (isInvalid) {
                        retErrorMsg += "Invalid type value:" + type + ",";
                    }
                }

                if (custom_id.length() == 0) {
                    retErrorMsg += "Custom_id not found,";
                }

            }


            if (resources != null) {
                // all containing properties are optional

            }

            if (sections != null) {
                retErrorMsg += verifyBlocTemplateSections(sections, "");
            }


            String itemStatus = "";

            if (retErrorMsg.length() > 0) {
                itemStatus = "error";
            }
            else {
                //no error
                itemStatus = "new";

                String q = "SELECT id FROM bloc_templates"
                           + " WHERE custom_id = " + escape.cote(custom_id)
                           + " AND site_id = " + escape.cote(siteId);

                Set rs = Etn.execute(q);
                if (rs.next()) {
                    itemStatus = "existing";
                }


            }

            retObj.put("name", name + " (" + custom_id + ")");
            retObj.put("status", itemStatus);
        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }

        return retErrorMsg;
    }

    public String pageTemplateId(String customId,String itemType) {
        String pgTemplateId = "0";

        if(!itemType.equalsIgnoreCase("product")){
            Set rsCustomId = Etn.execute("select id from page_templates where site_id="+escape.cote(siteId)+" and is_system='1'");
            if(rsCustomId.next()){
                pgTemplateId = escape.cote(rsCustomId.value(0));
            }
        }

        if(customId.length() > 0){
            Set rsCustomId = Etn.execute("select id from page_templates where site_id="+escape.cote(siteId)+" and custom_id="+escape.cote(customId));
            if(rsCustomId.next()){
                pgTemplateId = escape.cote(rsCustomId.value(0));
            }
        }
        return pgTemplateId;
    }

    public String verifyBlocTemplateSections(JSONArray sectionsList, String parentSectionName) {

        String retErrorMsg = "";

        for (int i = 0; i < sectionsList.length(); i++) {
            String curSectionError = "";
            JSONObject curSection = null;

            String secName = "";
            String secCustomId = "";
            try {

                curSection = sectionsList.getJSONObject(i);

                secName = PagesUtil.parseNull(curSection.optString("name"));
                secCustomId = PagesUtil.parseNull(curSection.optString("custom_id"));

                if (secName.length() == 0) {
                    throw new Exception("Name cannot be empty");
                }

                if (secCustomId.length() == 0) {
                    throw new Exception("Custom_id cannot be empty");
                }

            }
            catch (Exception secEx) {
                if (parentSectionName.length() > 0) {
                    curSectionError += parentSectionName + " > error in nested section # ";
                }
                else {
                    curSectionError += "Error in section # ";
                }

                curSectionError += (i + 1)
                                   + " : " + secEx.getMessage() + ",";
            }

            if (curSection != null && curSectionError.length() == 0) {
                JSONArray nestedSections = curSection.optJSONArray("sections");

                if (nestedSections != null && nestedSections.length() > 0) {
                    curSectionError += verifyBlocTemplateSections(nestedSections, secName);

                }
            }

            retErrorMsg += curSectionError;

        }

        return retErrorMsg;

    }

    public String verifyImportItemBloc(JSONObject itemObj, JSONObject retObj) {

        String retErrorMsg = "";
        try {

            JSONObject sysInfo = itemObj.optJSONObject("system_info");
            JSONObject parameters = itemObj.optJSONObject("parameters");

            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }

            String id = "";
            String name = "";
            String templateId = "";

            if (sysInfo != null) {
                id = PagesUtil.parseNull(sysInfo.optString("id"));
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                templateId = PagesUtil.parseNull(sysInfo.optString("template_id"));

                if (id.length() == 0) {
                    retErrorMsg += "ID not found,";
                }

                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }

                if (templateId.length() == 0) {
                    retErrorMsg += "Template id not found,";
                }
                else {
                    String q = "SELECT id FROM bloc_templates "
                               + " WHERE site_id = " + escape.cote(siteId)
                               + " AND custom_id = " + escape.cote(templateId);
                    Set rs = Etn.execute(q);
                    if (!rs.next()) {
                        retErrorMsg += "Invalid template id. Template does not exist,";
                    }
                }

            }
            List<Language> langList = PagesUtil.getLangs(Etn,siteId);
            JSONArray detailsLangList = itemObj.optJSONArray("details_lang");
            HashMap<String, String> langMap = new HashMap<>();

            for(Language language : langList){
                langMap.put(language.code, language.name);
            }

            if (detailsLangList != null) {
                boolean containAtleastOneSiteLang = false;
                // the incoming block must have atleast one site language otherwise it would be give error
                for(int i =0; i < detailsLangList.length(); i++){
                    JSONObject curObj = detailsLangList.optJSONObject(i);
                    if (curObj != null && langMap.containsKey(curObj.optString("langue_code"))) {
                        containAtleastOneSiteLang = true;
                        break;
                    }
                }
                if(!containAtleastOneSiteLang){
                    retErrorMsg += "No language code found familiar to this site in details_lang object,";
                }
            }

            String itemStatus = "";
            if (retErrorMsg.length() > 0) {
                itemStatus = "error";
            }
            else {
                //no error
                itemStatus = "new";

                String q = "SELECT id FROM blocs"
                           + " WHERE uuid = " + escape.cote(id)
                           + " AND site_id = " + escape.cote(siteId);

                Set rs = Etn.execute(q);
                if (rs.next()) {
                    itemStatus = "existing";
                }

            }

            retObj.put("name", name + " (" + templateId + ")");
            retObj.put("status", itemStatus);

        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }
        return retErrorMsg;
    }

    public String verifyImportItemPageSettings(JSONObject itemObj, JSONObject retObj) {
        return verifyImportItemPageSettings(itemObj, retObj,"","");
    }

    public String verifyImportItemPageSettings(JSONObject itemObj, JSONObject retObj,String pageType,String parentPageId) {

        String retErrorMsg = "";
        try {
            JSONObject sysInfo = itemObj.optJSONObject("system_info");
//          JSONObject metaInfo = itemObj.optJSONObject("meta_info");
//          JSONArray blocsList = itemObj.optJSONArray("blocs");

            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }

            String name = "";
            String path = "";
            String langue_code = "";
            String variant = "";
            String title = "";

            if (sysInfo != null) {
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                path = PagesUtil.parseNull(sysInfo.optString("path"));
                langue_code = PagesUtil.parseNull(sysInfo.optString("langue_code"));
                variant = PagesUtil.parseNull(sysInfo.optString("variant"));

                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }

                if (path.length() == 0) {
                    retErrorMsg += "Path not found,";
                }
                else if (!path.equals(PagesUtil.cleanPagePath(path))) {
                    retErrorMsg += "Invalid path. Only alphanumeric and slash(/) and hyphen(-) allowed,";
                }

                if (langue_code.length() == 0) {
                    retErrorMsg += "Langue_code not found,";
                }
                // From now we will not check the langue code, we will pass all langue codes
//                else {
//                    String q = "SELECT langue_code FROM language "
//                               + " WHERE langue_code = " + escape.cote(langue_code);
//                    Set rs = Etn.execute(q);
//                    if (!rs.next()) {
//                        retErrorMsg += "Invalid langue code. Not found in application language list,";
//                    }
//                }

                if (variant.length() == 0) {
                    retErrorMsg += "Variant not found,";
                }
                else if (!"|all|logged|anonymous|".contains("|" + variant + "|")) {
                    retErrorMsg += "Invalid variant value,";
                }
            }

            String itemStatus = "";
            if (retErrorMsg.length() > 0) {
                itemStatus = "error";
            }
            else {
                //no error
                itemStatus = "new";

                String folderPrefixPath = "";
                //append folder path
                JSONObject folderObj = sysInfo.optJSONObject("folder");
                if (folderObj != null && folderObj.optString("name").length() > 0) {
                    ArrayList<JSONObject> foldersList = getFoldersList(folderObj);

                    folderPrefixPath = getFolderPrefixPath(foldersList, langue_code, folderPrefixPath);
                }
                String fullPath = path;
                if (folderPrefixPath.length() > 0) {
                    fullPath = folderPrefixPath + "/" + fullPath;
                }

                //debug
                fullPath = PagesUtil.cleanPagePath(fullPath);
                //Logger.debug("### fullPath after clean=" + fullPath);

                JSONObject checkObj = checkIfPageExists(langue_code, variant, fullPath);
                String checkStatus = checkObj.getString("status");
                if ("error".equals(checkStatus)) {
                    retErrorMsg = checkObj.getString("message");
                }
                else if(checkStatus.equals("new")){
                    if(parentPageId.length()>0){
                        Set rsParentPage = Etn.execute("select * from pages where parent_page_id="+escape.cote(parentPageId)+" and langue_code="+escape.cote(langue_code)+
                        " and type="+escape.cote(pageType));
                        if(rsParentPage.rs.Rows>0){
                            retErrorMsg = "New path of "+langue_code+" for exsisting parent page.";
                        }
                    }
                }
                else {
                    itemStatus = checkStatus;
                    retObj.put("existingId", checkObj.optString("pageId"));
                    retObj.put("page_path", fullPath);
                }
            }

            retObj.put("name", name + " (" + path + ")");
            retObj.put("status", itemStatus);

        }
        catch (
            Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }

        return retErrorMsg;
    }

    public String verifyImportItemPageTemplate(JSONObject itemObj, JSONObject retObj) {

        String retErrorMsg = "";
        try {

            JSONObject sysInfo = itemObj.optJSONObject("system_info");
            JSONObject details = itemObj.optJSONObject("details");

            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }
            if (details == null) {
                retErrorMsg += "Details not found";
            }

            String name = "";
            String custom_id = "";

            if (sysInfo != null) {
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                custom_id = PagesUtil.parseNull(sysInfo.optString("custom_id"));

                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }

                if (custom_id.length() == 0) {
                    retErrorMsg += "Custom ID not found,";
                }

            }

            if (details != null) {
                // all data in details is optional and can be either filled with empty string or default values
            }

            String itemStatus = "";
            if (retErrorMsg.length() > 0) {
                itemStatus = "error";
            }
            else {
                //no error
                itemStatus = "new";

                String q = "SELECT id FROM page_templates"
                           + " WHERE custom_id = " + escape.cote(custom_id)
                           + " AND site_id = " + escape.cote(siteId);

                Set rs = Etn.execute(q);
                if (rs.next()) {
                    itemStatus = "existing";
                }
            }

            retObj.put("name", name + " (" + custom_id + ")");
            retObj.put("status", itemStatus);

        }
        catch (
            Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }

        return retErrorMsg;
    }

    protected JSONObject checkIfPageExists(String langue_code, String variant, String fullPath) {
        String status = "new";
        String message = "";
        String pageId = "";
        StringBuffer urlErrorMsg = new StringBuffer();
        String pageIdStr = "";
        boolean isUnique = PagesUtil.isPageUrlUnique(Etn, siteId,
                langue_code, variant, fullPath,
                pageIdStr, urlErrorMsg);
        String lastType = UrlHelper.lastType;
        String lastId = UrlHelper.lastId;
        String lastMsg = UrlHelper.lastMsg;
        if (!isUnique) {
            //complex condition
            String pageType = Constant.PAGE_TYPE_FREEMARKER;
            if ("page".equals(lastType)) {
                //get which type of page "block" or "structured"
                String q = "SELECT type FROM pages "
                        + " WHERE id =" + escape.cote(lastId)
                        + " AND site_id = " + escape.cote(siteId);
                Set rs = Etn.execute(q);
                if (rs.next()) {
                    pageType = rs.value("type");
                }
            }

            if ("page".equals(UrlHelper.lastType)
                    && (!pageType.equals(Constant.PAGE_TYPE_STRUCTURED) || this.isProcessingStructContent)) {
                status = "existing";
                pageId = lastId;
            }
            else {
                status = "error";
            }
            message = "Path already exist. " + urlErrorMsg;

        }

        return new JSONObject()
                .put("status", status)
                .put("message", message)
                .put("pageId", pageId);
    }

    protected String getFolderPrefixPath(ArrayList<JSONObject> foldersList, String langue_code, String
        prefixPath) {

        String folderPrefixPath = prefixPath;

        int lastParentId = 0;
        for (JSONObject curFolderObj : foldersList) {
            String folderName = curFolderObj.getString("name");
            String curPathPrefix = "";
            boolean folderExists = false;
            if (lastParentId >= 0) {
                String q = "SELECT id, name, fd.path_prefix "
                           + " FROM folders f"
                           + " JOIN folders_details fd ON fd.folder_id = f.id"
                           + " JOIN language l ON l.langue_id = fd.langue_id"
                           + " WHERE site_id = " + escape.cote(siteId)
                           + " AND parent_folder_id = " + escape.cote("" + lastParentId)
                           + " AND name = " + escape.cote(folderName)
                           + " AND l.langue_code = " + escape.cote(langue_code);

                if(!PagesUtil.parseNull(curFolderObj.optString("uuid")).isEmpty()){
                    q+= " AND f.type=(select type from folders where uuid="+escape.cote(curFolderObj.getString("uuid"))+")";
                }
                Set rs = Etn.execute(q);
                if (rs.next()) {
                    folderExists = true;
                    curPathPrefix = rs.value("path_prefix");
                    lastParentId = PagesUtil.parseInt(rs.value("id"));
                }
            }
            if (!folderExists) {
                lastParentId = -1;
                if (curFolderObj.optJSONArray("details") != null) {
                    JSONArray detailsList = curFolderObj.getJSONArray("details");
                    for (int i = 0; i < detailsList.length(); i++) {
                        JSONObject detailObj = detailsList.getJSONObject(i);
                        if (langue_code.equals(detailObj.optString("langue_code"))) {
                            curPathPrefix = detailObj.optString("path_prefix");
                            break;
                        }
                    }
                }
            }

            if (curPathPrefix.length() > 0) {
                if (folderPrefixPath.length() == 0) {
                    folderPrefixPath = curPathPrefix;
                }
                else {
                    folderPrefixPath += "/" + curPathPrefix;
                }
            }

        }
        return folderPrefixPath;
    }

    protected ArrayList<JSONObject> getFoldersList(JSONObject folderObj) {
        ArrayList<JSONObject> foldersList = new ArrayList<>();
        for (JSONObject curFolderObj = folderObj; curFolderObj != null; ) {
            foldersList.add(0, curFolderObj);
            curFolderObj = curFolderObj.optJSONObject("parent_folder");
        }
        return foldersList;
    }

    //Obsolete
    /*public String verifyImportItemStructuredCatalog(JSONObject itemObj, JSONObject retObj) {

        String retErrorMsg = "";

        String q = "";
        Set rs = null;
        try {

            JSONObject sysInfo = itemObj.optJSONObject("system_info");
            JSONArray detailsList = itemObj.optJSONArray("details");

            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }

            String name = "";
            String templateCustomId = "";
            String catalogType = "";

            String templateId = "";

            if (sysInfo != null) {
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }

                catalogType = PagesUtil.parseNull(sysInfo.optString("type"));
                templateCustomId = PagesUtil.parseNull(sysInfo.optString("template_id"));

                if (catalogType.length() == 0) {
                    retErrorMsg += "Type not found,";
                }

                if (templateCustomId.length() == 0) {
                    retErrorMsg += "Template id not found,";
                }

                if (retErrorMsg.length() == 0) {
                    //if required fields found, check id validity

                    if (!catalogType.equals("content") && !catalogType.equals("page")) {
                        retErrorMsg += "Invalid catalog type: " + catalogType + " ,";
                    }
                    else {

                        String templateType = "";
                        if (catalogType.equals("content")) {
                            templateType = Constant.TEMPLATE_STRUCTURED_CONTENT;
                        }
                        else {
                            templateType = Constant.TEMPLATE_STRUCTURED_PAGE;
                        }

                        q = "SELECT id FROM bloc_templates "
                            + " WHERE type = " + escape.cote(templateType)
                            + " AND custom_id = " + escape.cote(templateCustomId)
                            + " AND site_id = " + escape.cote(siteId);
                        rs = Etn.execute(q);
                        if (rs.next()) {
                            templateId = rs.value("id");
                        }
                        else {
                            retErrorMsg += "Invalid template_id : " + templateCustomId + ". Template not found of type : " + templateType + ".,";
                        }

                    }
                }
            }

            if ("page".equals(catalogType) && detailsList != null) {
                //only need to validate lang code if present
                ArrayList<Language> langList = PagesUtil.getLangs(Etn);
                for (int i = 0; i < detailsList.length(); i++) {

                    JSONObject detailObj = detailsList.optJSONObject(i);

                    if (detailObj != null) {
                        String langue_code = PagesUtil.parseNull(detailObj.optString("langue_code"));
                        String path_prefix = PagesUtil.parseNull(detailObj.optString("path_prefix"));

                        Language foundLanguage = null;
                        for (Language curLang : langList) {
                            if (curLang.code.equals(langue_code)) {
                                foundLanguage = curLang;
                                break;
                            }
                        }

                        if (foundLanguage == null) {
                            retErrorMsg += "Invalid langue_code : " + langue_code + " in detail item # " + (i + 1) + " .,";
                        }

                        if (path_prefix.length() > 0) {
                            String validPrefixPath = PagesUtil.cleanPagePath(path_prefix);

                            if (!validPrefixPath.equals(path_prefix)) {
                                retErrorMsg += "Invalid prefix_path : " + path_prefix + " in detail item # " + (i + 1) + ". Only alphanumeric and hyphen(-) allowed.,";
                            }
                        }

                    }
                }
            }

            String itemStatus = "";
            if (retErrorMsg.length() > 0) {
                retObj.put("status", "error");
            }
            else {

                itemStatus = "new";

                q = "SELECT id, name FROM structured_catalogs "
                    + " WHERE name = " + escape.cote(name)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if (rs.next()) {
                    itemStatus = "existing";
                }

            }

            retObj.put("name", name);
            retObj.put("status", itemStatus);

        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }

        return retErrorMsg;
    }*/

    public String verifyImportItemStructuredContent(JSONObject itemObj, JSONObject retObj) {
        return verifyImportItemStructuredContentGeneric(itemObj, retObj, Constant.STRUCTURE_TYPE_CONTENT);
    }

    public String verifyImportItemStructuredPage(JSONObject itemObj, JSONObject retObj) {
        return verifyImportItemStructuredContentGeneric(itemObj, retObj, Constant.STRUCTURE_TYPE_PAGE);
    }

    protected String verifyImportItemStructuredContentGeneric(JSONObject itemObj, JSONObject retObj, String contentType) {
        String retErrorMsg = "";
        try {
            this.isProcessingStructContent = true;
            ArrayList<String> existingPageIds = new ArrayList<>();
            ArrayList<String> existingPagePaths = new ArrayList<>();

            JSONObject sysInfo = itemObj.optJSONObject("system_info");
            String itemType = itemObj.optString("item_type", "");

            JSONArray detailsList = itemObj.optJSONArray("details");

            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }

            if (detailsList == null) {
                retErrorMsg += "Details list not found,";
            }

            String name = "";
            String templateId = "";
            String templateCustomId = "";
            String templateName = "";
            String templateType = "";
            String folderId = "0";

            if (sysInfo != null) {
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }

                String type = PagesUtil.parseNull(sysInfo.optString("type"));
                templateCustomId = PagesUtil.parseNull(sysInfo.optString("template_id"));

                if (type.length() == 0) {
                    retErrorMsg += "Type not found,";
                }
                else if (!type.equals(contentType)) {
                    retErrorMsg += "Type mismatch,";
                }

                if (templateCustomId.length() == 0) {
                    retErrorMsg += "Template id not found,";
                }

                if (retErrorMsg.length() == 0) {
                    //if required fields found, check template validity
                    String q = "SELECT id, name, type  FROM bloc_templates "
                               + " WHERE custom_id = " + escape.cote(templateCustomId)
                               + " AND site_id = " + escape.cote(siteId);
                    if (contentType.equals(Constant.STRUCTURE_TYPE_CONTENT)) {
                        q += " AND type = " + escape.cote(Constant.TEMPLATE_STRUCTURED_CONTENT);
                    }
                    else {
                        if(itemType.equals("structured_page")){
                            q += " AND type = " + escape.cote(Constant.TEMPLATE_STRUCTURED_PAGE);
                        } else if(itemType.equals("store")){
                            q += " AND type = " + escape.cote(Constant.TEMPLATE_STORE);
                        }
                    }

                    Set rs = Etn.execute(q);
                    if (rs.next()) {
                        templateId = rs.value("id");
                        templateName = rs.value("name");
                        templateType = rs.value("type");
                    }
                    else {
                        retErrorMsg += "Invalid template_id : " + templateCustomId + ". Template not found of type : " + templateType + ".,";
                    }

                }

                //set folderId
                JSONObject folderObj = sysInfo.optJSONObject("folder");
                if (retErrorMsg.length() == 0 && folderObj != null && folderObj.optString("name").length() > 0) {
                    ArrayList<JSONObject> foldersList = getFoldersList(folderObj);

                    //add missing folders
                    String folderType = Constant.FOLDER_TYPE_CONTENTS;
                    if (Constant.STRUCTURE_TYPE_PAGE.equals(contentType)) {
                        if (Constant.TEMPLATE_STORE.equals(templateType)) {
                            folderType = Constant.FOLDER_TYPE_STORE;
                        }
                        else {
                            folderType = Constant.FOLDER_TYPE_PAGES;
                        }
                    }
                    int lastParentId = 0;
                    for (JSONObject curFolderObj : foldersList) {
                        String folderName = curFolderObj.getString("name");

                        String q = "SELECT id FROM folders f"
                                   + " WHERE site_id = " + escape.cote(siteId)
                                   + " AND type = " + escape.cote(folderType)
                                   + " AND name = " + escape.cote(folderName)
                                   + " AND parent_folder_id = " + escape.cote("" + lastParentId);
                        Set rs = Etn.execute(q);
                        if (rs.next()) {
                            //folder already exist
                            folderId = rs.value("id");
                            lastParentId = PagesUtil.parseInt(folderId);
                        }
                        else {
                            //folder does not exist, on import folder will be created
                            folderId = "-1";
                            break;
                        }
                    }

                }

                if (detailsList != null) {
                    List<Language> langList = PagesUtil.getLangs(Etn,siteId);
                    boolean foundLangMatch = false;

                    for (int i = 0; i < detailsList.length(); i++) {
                        String detailLangCode = detailsList.optJSONObject(i).optString("langue_code");
                        for (Language lang : langList) {
                            if (lang.code.equals(detailLangCode)) {
                                foundLangMatch = true;
                                break; //match found
                            }
                        }
                        if(foundLangMatch) break;
                    }

                    if(!foundLangMatch && detailsList.length() > 0){
                        retErrorMsg += "No language code found familiar to this site in detail object";
                    }

                    //content_data can be empty,optional
                    if (Constant.STRUCTURE_TYPE_CONTENT.equals(contentType)) {
                        //no validation needed, if no valid detail found we put empty data for the system language(s)
                    }
                    else if (Constant.STRUCTURE_TYPE_PAGE.equals(contentType)) {

                        Set rsStruContId = Etn.execute("SELECT id FROM structured_contents WHERE name = " + escape.cote(name)
                            + " AND type = " + escape.cote(contentType)+" AND site_id ="+escape.cote(siteId)+" AND folder_id = " + escape.cote(folderId));
                        rsStruContId.next();
                        //for page type , we need atleast 1 detail
                        if (detailsList.length() == 0) {
                            retErrorMsg += " Atleast 1 detail entry is required.";
                        }

                        for (int i = 0; i < detailsList.length(); i++) {
                            String detailsErrorMsg = "";
                            try {
                                JSONObject detailObj = detailsList.optJSONObject(i);
                                if (detailObj == null) {
                                    continue;
                                }

                                Language detailLanguage = null;
                                String langue_code = PagesUtil.parseNull(detailObj.optString("langue_code"));
                                JSONObject pageSettings = detailObj.optJSONObject("page_settings");

                                if (pageSettings == null || pageSettings.isEmpty()) {
                                    //page is optional for store
                                    if (!Constant.TEMPLATE_STORE.equals(templateType)) {
                                        detailsErrorMsg += "Error: page_settings not found in detail item # " + (i + 1) + " .,";
                                    }
                                }
                                else {

                                    JSONObject pageObj2 = new JSONObject(pageSettings.toMap());
                                    // Logger.info(pageObj2.toString(2)

                                    pageObj2.put("item_type", "page");
                                    pageObj2.getJSONObject("system_info").put("langue_code", langue_code);
                                    pageObj2.getJSONObject("system_info").put("name", name);
                                    pageObj2.getJSONObject("system_info").put("folder_name", sysInfo.optString("folder_name"));
                                    pageObj2.getJSONObject("system_info").put("folder", sysInfo.optJSONObject("folder"));

                                    JSONObject pageRetObj = new JSONObject();
                                    String pageError = verifyImportItemPageSettings(pageObj2, pageRetObj,"structured",rsStruContId.value("id"));

                                    if (pageError.length() > 0) {
                                        System.out.println("==================Error Start==================");
                                        System.out.println("pageObj2=================="+pageObj2);
                                        System.out.println("==================Error End==================");
                                        detailsErrorMsg += "Invalid page_settings in detail item # " + (i + 1) + " .," + pageError;
                                    }
                                    else {
                                        if ("existing".equals(pageRetObj.optString("status"))) {
                                            if (pageRetObj.getString("existingId").length() > 0) {
                                                existingPageIds.add(pageRetObj.getString("existingId"));
                                                existingPagePaths.add(pageRetObj.optString("page_path"));
                                            }
                                        }
                                    }
                                }

                            }
                            catch (Exception detailEx) {
                                detailsErrorMsg += "Exception: " + detailEx.getMessage() + ",";
                                // detailEx.printStackTrace();
                            }
                            finally {
                                retErrorMsg += detailsErrorMsg;
                            }
                        }
                    }
                }//if(detailsList!=null)
            }


            String itemStatus = "";
            if (retErrorMsg.length() > 0) {
                itemStatus = "error";
            }
            else {
                //no error
                itemStatus = "new";

                String q = "SELECT sc.id "
                           + " FROM structured_contents sc "
                           + " WHERE sc.name = " + escape.cote(name)
                           + " AND sc.type = " + escape.cote(contentType)
                           + " AND sc.site_id = " + escape.cote(siteId)
                           + " AND sc.folder_id = " + escape.cote(folderId);

                Set rs = Etn.execute(q);
                String contentId = "";
                if (rs.next()) {
                    itemStatus = "existing";
                    contentId = rs.value("id");
                }
                
                //check existing pageIds
                if (Constant.STRUCTURE_TYPE_PAGE.equals(contentType) && existingPageIds.size() > 0) {
                    //check if dupliate paths are of outside pages
                    if ("new".equals(itemStatus)) {
                        
                        System.out.println("==================Duplicate Data Start==================");
                        System.out.println("name=================="+name);
                        System.out.println("contentType=================="+contentType);
                        System.out.println("siteId=================="+siteId);
                        System.out.println("folderId=================="+folderId);
                        System.out.println("==================Duplicate Data End==================");
                        retErrorMsg += "Error: following paths already exist: ";
                        for (String existingPath : existingPagePaths) {
                            retErrorMsg += existingPath + ",";
                        }
                    }
                    else {
                        //check existing pages are associated with same content
                        for (int i = 0; i < existingPageIds.size(); i++) {

                            String curPageId = existingPageIds.get(i);

                            q = "SELECT scd.page_id "
                                + " FROM structured_contents_details scd "
                                + " JOIN structured_contents sc ON sc.id = scd.content_id "
                                + " WHERE sc.id = " + escape.cote(contentId)
                                + " AND sc.site_id = " + escape.cote(siteId)
                                + " AND scd.page_id = " + escape.cote(curPageId);
                            rs = Etn.execute(q);
                            if (!rs.next()) {
                                retErrorMsg += "Following page already exist but not associated with this existing content : page ID = "
                                               + curPageId + "(path = " + existingPagePaths.get(i) + ")";
                            }

                        }

                    }
                }

                if (retErrorMsg.length() > 0) {
                    itemStatus = "error";
                }

            }

            retObj.put("name", name + " (" + templateName + ")");
            retObj.put("status", itemStatus);

        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }
        finally {
            this.isProcessingStructContent = false;
        }
        return retErrorMsg;
    }


    protected String verifyImportItemFreemarkerPage(JSONObject itemObj, JSONObject retObj) {
        String retErrorMsg = "";

        try {
            ArrayList<String> existingPageIds = new ArrayList<>();
            List<Language> langList = PagesUtil.getLangs(Etn,siteId);
            ArrayList<String> existingPagePaths = new ArrayList<>();

            JSONObject sysInfo = itemObj.optJSONObject("system_info");


            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }

            String name = "";
            String folderId = "0";

            if (sysInfo != null) {
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }

                //set folderId
                JSONObject folderObj = sysInfo.optJSONObject("folder");
                if (retErrorMsg.length() == 0 && folderObj != null && folderObj.optString("name").length() > 0) {
                    ArrayList<JSONObject> foldersList = getFoldersList(folderObj);

                    //add missing folders
                    String folderType = Constant.FOLDER_TYPE_PAGES;

                    int lastParentId = 0;
                    for (JSONObject curFolderObj : foldersList) {
                        String folderName = curFolderObj.getString("name");

                        String q = "SELECT id FROM folders f"
                                + " WHERE site_id = " + escape.cote(siteId)
                                + " AND type = " + escape.cote(folderType)
                                + " AND name = " + escape.cote(folderName)
                                + " AND parent_folder_id = " + escape.cote("" + lastParentId);
                        Set rs = Etn.execute(q);
                        if (rs.next()) {
                            //folder already exist
                            folderId = rs.value("id");
                            lastParentId = PagesUtil.parseInt(folderId);
                        }
                        else {
                            //folder does not exist, on import folder will be created
                            folderId = "-1";
                            break;
                        }
                    }
                }

                JSONArray detailsList = itemObj.optJSONArray("details");

                Set rsFreePages = Etn.execute("SELECT id FROM freemarker_pages WHERE name ="+escape.cote(name)+" AND site_id ="+escape.cote(siteId)+
                    " AND folder_id = " + escape.cote(folderId));
                rsFreePages.next();

                if (detailsList == null) {    //  -- older structure --
                    // single language page will be found. we need to add pages for other languages as well as the parent page
                    // and associate blocs, forms with parent freemarker page

                    String langue_code = itemObj.getJSONObject("system_info").optString("langue_code");
                    boolean foundLangMatch = false;
                    for (Language lang : langList) {
                        if (lang.code.equals(langue_code)) {
                            foundLangMatch = true;
                            break; //match found
                        }
                    }

                    if(!foundLangMatch){
                        retErrorMsg += "No language code found familiar to this site";
                    }

                    String detailsErrorMsg = "";
                    try {
                        JSONObject pageObj2 = itemObj;

                        pageObj2.put("item_type", "page");
                        pageObj2.getJSONObject("system_info").put("name", name);
//                        pageObj2.getJSONObject("system_info").put("folder_name", sysInfo.optString("folder_name"))
//                        pageObj2.getJSONObject("system_info").put("langue_code", langue_code);
//                        pageObj2.getJSONObject("system_info").put("folder", sysInfo.optJSONObject("folder"));

                        JSONObject pageRetObj = new JSONObject();
                        String pageError = verifyImportItemPageSettings(pageObj2, pageRetObj,"freemarker",rsFreePages.value("id"));

                        if (pageError.length() > 0) {
                            detailsErrorMsg += "Invalid page_settings," + pageError;
                        } else {
                            if ("existing".equals(pageRetObj.optString("status"))) {
                                if (pageRetObj.getString("existingId").length() > 0) {
                                    existingPageIds.add(pageRetObj.getString("existingId"));
                                    existingPagePaths.add(pageRetObj.optString("page_path"));
                                }
                            }
                        }
                    } catch (Exception detailEx) {
                        detailsErrorMsg += "Exception: " + detailEx.getMessage() + ",";
                        // detailEx.printStackTrace();
                    }
                    finally {
                        retErrorMsg += detailsErrorMsg;
                    }
                } else { // new structure
                    if (detailsList.length() == 0) {
                        retErrorMsg += " Atleast 1 detail entry is required.";
                    }

                    boolean foundLangMatch = false;
                    for (int i = 0; i < detailsList.length(); i++) {
                        String detailLangCode = detailsList.optJSONObject(i).optString("langue_code");
                        for (Language lang : langList) {
                            if (lang.code.equals(detailLangCode)) {
                                foundLangMatch = true;
                                break; //match found
                            }
                        }
                        if(foundLangMatch) break;
                    }

                    if(!foundLangMatch && detailsList.length() > 0){
                        retErrorMsg += "No language code found familiar to this site in detail object";
                    }


                    for (int i = 0; i < detailsList.length(); i++) {
                        String detailsErrorMsg = "";
                        try {
                            JSONObject detailObj = detailsList.optJSONObject(i);
                            if (detailObj == null) {
                                continue;
                            }

                            String langue_code = PagesUtil.parseNull(detailObj.optString("langue_code"));
                            JSONObject pageSettings = detailObj.optJSONObject("page_settings");

                            if (pageSettings == null || pageSettings.isEmpty()) {
                                detailsErrorMsg += "Error: page_settings not found in detail item # " + (i + 1) + " .,";
                            }
                            else {

                                JSONObject pageObj2 = new JSONObject(pageSettings.toMap());

                                pageObj2.put("item_type", "page");
                                pageObj2.getJSONObject("system_info").put("langue_code", langue_code);
                                pageObj2.getJSONObject("system_info").put("name", name);
                                pageObj2.getJSONObject("system_info").put("folder_name", sysInfo.optString("folder_name"));
                                pageObj2.getJSONObject("system_info").put("folder", sysInfo.optJSONObject("folder"));

                                JSONObject pageRetObj = new JSONObject();
                                String pageError = verifyImportItemPageSettings(pageObj2, pageRetObj,"freemarker",rsFreePages.value("id"));

                                if (pageError.length() > 0) {
                                    detailsErrorMsg += "Invalid page_settings in detail item # " + (i + 1) + " .," + pageError;
                                }
                                else {
                                    if ("existing".equals(pageRetObj.optString("status"))) {
                                        if (pageRetObj.getString("existingId").length() > 0) {
                                            existingPageIds.add(pageRetObj.getString("existingId"));
                                            existingPagePaths.add(pageRetObj.optString("page_path"));
                                        }
                                    }
                                }
                            }
                        }
                        catch (Exception detailEx) {
                            detailsErrorMsg += "Exception: " + detailEx.getMessage() + ",";
                            // detailEx.printStackTrace();
                        }
                        finally {
                            retErrorMsg += detailsErrorMsg;
                        }
                    }
                }
            }

            String itemStatus = "";
            if (retErrorMsg.length() > 0) {
                itemStatus = "error";
            }
            else {
                //no error
                itemStatus = "new";

                String q = "SELECT fp.id "
                        + " FROM freemarker_pages fp "
                        + " WHERE fp.name = " + escape.cote(name)
                        + " AND fp.site_id = " + escape.cote(siteId)
                        + " AND fp.folder_id = " + escape.cote(folderId)
                        + " AND fp.is_deleted = '0'";

                Set rs = Etn.execute(q);
                String pageId = "";
                if (rs.next()) {
                    itemStatus = "existing";
                    pageId = rs.value("id");
                }

                //check existing pageIds
                if (existingPageIds.size() > 0) {
                    //check if dupliate paths are of outside pages
                    if ("new".equals(itemStatus)) {
                        retErrorMsg += "Error: following paths already exist: ";
                        for (String existingPath : existingPagePaths) {
                            retErrorMsg += existingPath + ",";
                        }
                    }
                }

                if (retErrorMsg.length() > 0) {
                    itemStatus = "error";
                }
            }
//          retObj.put("name", name + " (" + path + ")");
            retObj.put("name", name);
            retObj.put("status", itemStatus);
        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }
        finally {
            this.isProcessingStructContent = false;
        }
        return retErrorMsg;
    }






    public String verifyImportItemCommercialCatalog(JSONObject itemObj, JSONObject retObj) {

        String retErrorMsg = "";

        String q = "";
        Set rs = null;
        try {

            JSONObject sysInfo = itemObj.optJSONObject("system_info");
            JSONArray detailsLangList = itemObj.optJSONArray("details_lang");
//            JSONArray descriptionsList = itemObj.optJSONArray("catalog_descriptions");
//            JSONArray essentialBlocksList = itemObj.optJSONArray("catalog_essential_blocks");

            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }

            String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");

            String name = "";
            String catalog_uuid = "";
            String catalog_type = "";

            if (sysInfo != null) {
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }

                catalog_uuid = PagesUtil.parseNull(sysInfo.optString("uuid"));
                if (catalog_uuid.length() == 0) {
                    retErrorMsg += "Catalog UUID not found,";
                }

                catalog_type = PagesUtil.parseNull(sysInfo.optString("type"));
                if (catalog_type.length() == 0) {
                    retErrorMsg += "Catalog type not found,";
                }
                else {
                    q = "SELECT 1 FROM " + CATALOG_DB + ".catalog_types "
                        + " WHERE value = " + escape.cote(catalog_type);
                    rs = Etn.execute(q);
                    if (!rs.next()) {
                        retErrorMsg += "Invalid catalog type : " + catalog_type + ",";
                    }
                }

            }


            List<Language> langList = PagesUtil.getLangs(Etn,siteId);

            ArrayList<JSONObject> catalogPathList = new ArrayList<>();
            if (detailsLangList != null) {
                for (int i = 0; i < detailsLangList.length(); i++) {
                    JSONObject detailObj = detailsLangList.optJSONObject(i);

                    //check language validity
                    String langue_code = PagesUtil.parseNull(detailObj.optString("langue_code"));
                    Language foundLanguage = null;
                    for (Language curLang : langList) {
                        if (curLang.code.equals(langue_code)) {
                            foundLanguage = curLang;
                            break;
                        }
                    }

                    if (foundLanguage == null) {
                        retErrorMsg += "Invalid langue_code : " + langue_code + " in detail lang item # " + (i + 1) + " .,";
                    }


                    if (detailObj == null || detailObj.optJSONObject("description") == null) {
                        continue;
                    }

                    JSONObject descObj = detailObj.optJSONObject("description");

                    String page_path = PagesUtil.parseNull(descObj.optString("page_path"));

                    if (page_path.length() > 0) {
                        String validPrefixPath = PagesUtil.cleanPagePath(page_path);

                        if (!validPrefixPath.equals(page_path)) {
                            retErrorMsg += "Invalid page_path : " + page_path + " in detail item # " + (i + 1) + ". Only alphanumeric and slash(/) and hyphen(-) allowed.,";
                        }
                        else {
                            JSONObject pathObj = new JSONObject();
                            pathObj.put("langue_code", langue_code);
                            pathObj.put("page_path", page_path);
                            catalogPathList.add(pathObj);
                        }

                    }

                }
            }

            String itemStatus = "";
            String catalogId = "";
            if (retErrorMsg.length() > 0) {
                retObj.put("status", "error");
            }
            else {

                itemStatus = "new";

                q = "SELECT id, name FROM " + CATALOG_DB + ".catalogs "
                    + " WHERE catalog_uuid = " + escape.cote(catalog_uuid)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if (rs.next()) {
                    itemStatus = "existing";
                    catalogId = rs.value("id");
                }

            }

            //check if name is not duplicate
            q = "SELECT id, name FROM " + CATALOG_DB + ".catalogs "
                + " WHERE name = " + escape.cote(name)
                + " AND site_id = " + escape.cote(siteId);
            if (catalogId.length() > 0) {
                q += " AND id != " + escape.cote(catalogId);
            }

            rs = Etn.execute(q);
            if (rs.next()) {
                retErrorMsg += "Duplicate name: Catalog of same name already exist. Please change the name.,";

                itemStatus = "error";
            }

            for (JSONObject descObj : catalogPathList) {
                String langue_code = descObj.getString("langue_code");
                String page_path = descObj.getString("page_path");

                page_path = PagesUtil.cleanPagePath(page_path);

                StringBuffer urlErrorMsg = new StringBuffer();
                boolean isUnique = UrlHelper.isUrlUnique(Etn, siteId, langue_code,
                                                         "catalog", catalogId, page_path, urlErrorMsg);

                if (!isUnique) {
                    retErrorMsg += "Duplicate page_path : " + page_path + " for lang : " + langue_code + ". " + urlErrorMsg + ",";

                    itemStatus = "error";
                }
            }


            retObj.put("name", name);
            retObj.put("status", itemStatus);

        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }

        return retErrorMsg;
    }

    public String verifyImportItemCommercialProduct(JSONObject itemObj, JSONObject retObj) {

        String retErrorMsg = "";

        String q = "";
        Set rs = null;
        try {

            JSONObject sysInfo = itemObj.optJSONObject("system_info");
            JSONArray detailsLangList = itemObj.optJSONArray("details_lang");

            JSONArray variantsList = itemObj.optJSONArray("variants");

            if (detailsLangList == null) detailsLangList = new JSONArray();

            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }

            String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");

            String catalogId = "";

            String product_uuid = "";
            String catalog_uuid = "";
            String name = "";

            if (sysInfo != null) {
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }

                product_uuid = PagesUtil.parseNull(sysInfo.optString("uuid"));
                if (product_uuid.length() == 0) {
                    retErrorMsg += "Product UUID not found,";
                }

                if (targetCatalogId.length() > 0) {
                    catalog_uuid = targetCatalogId;
                }
                else {
                    catalog_uuid = PagesUtil.parseNull(sysInfo.optString("catalog_uuid"));
                }

                if (catalog_uuid.length() == 0) {
                    retErrorMsg += "Catalog UUID not found,";
                }
                else {
                    q = "SELECT id FROM " + CATALOG_DB + ".catalogs "
                        + " WHERE catalog_uuid = " + escape.cote(catalog_uuid)
                        + " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);
                    if (rs.next()) {
                        catalogId = rs.value("id");
                    }
                    else {
                        retErrorMsg += "Invalid catalog UUID. Catalog not found,";
                    }
                }

            }

            String itemStatus = "";
            String productId = "";
            String existingFolderId = "";
            if (retErrorMsg.length() > 0) {
                retObj.put("status", "error");
            }
            else {

                itemStatus = "new";

                q = "SELECT p.id, p.lang_1_name AS name, p.catalog_id, p.folder_id FROM " + CATALOG_DB + ".products p"
                    + " JOIN " + CATALOG_DB + ".catalogs c ON c.id = p.catalog_id "
                    + " WHERE p.product_uuid = " + escape.cote(product_uuid)
                    + " AND c.site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if (rs.next()) {

                    if (catalogId.equals(rs.value("catalog_id"))) {
                        itemStatus = "existing";
                        productId = rs.value("id");
                        existingFolderId = rs.value("folder_id");
                    }
                    else {
                        itemStatus = "error";
                        retErrorMsg += "Product UUID exists in another catalog. Change product UUID.,";
                    }

                }

            }

            List<Language> langList = PagesUtil.getLangs(Etn,siteId);
            Language defaultLanguage = langList.get(0);
            HashMap<String, String> langPathPrefixHM = new HashMap<>(langList.size());

            Function<String, String> loadPrefixPaths = (fId) -> {
                String q2 = "SELECT l.langue_code, f.concat_path "
                            + " FROM  " + CATALOG_DB + ".products_folders_lang_path f "
                            + " JOIN language l ON l.langue_id = f.langue_id"
                            + " WHERE site_id = " + escape.cote(siteId)
                            + " AND folder_id = " + escape.cote(fId);
                Set rs2 = Etn.execute(q2);
                while (rs2.next()) {
                    langPathPrefixHM.put(rs2.value("langue_code"), rs2.value("concat_path"));
                }
                return fId;
            };

            //folders
            if ("existing".equals(itemStatus)) {
                // for existing consider existing folder, not the provided folders
                if (PagesUtil.parseInt(existingFolderId) > 0) {
                    loadPrefixPaths.apply(existingFolderId);
                }
            }
            else {
                //process paths for folder
                String folderId = "";
                JSONObject folderObj = sysInfo.optJSONObject("folder");
                if (folderObj != null && folderObj.optString("name").length() > 0) {
                    ArrayList<JSONObject> foldersList = getFoldersList(folderObj);

                    int lastParentId = 0;
                    for (JSONObject curFolderObj : foldersList) {
                        String folderName = curFolderObj.getString("name");

                        q = "SELECT id FROM " + CATALOG_DB + ".products_folders f"
                            + " WHERE site_id = " + escape.cote(siteId)
                            + " AND catalog_id = " + escape.cote(catalogId)
                            + " AND name = " + escape.cote(folderName)
                            + " AND parent_folder_id = " + escape.cote("" + lastParentId);
                        rs = Etn.execute(q);
                        if (rs.next()) {
                            //folder already exist
                            folderId = rs.value("id");
                            lastParentId = PagesUtil.parseInt(folderId);
                            loadPrefixPaths.apply(folderId);
                        }
                        else {
                            //folder does not exist, on import folder will be created
                            folderId = "-1";
                            lastParentId = -1;

                            JSONArray detailsList = folderObj.getJSONArray("details");
                            for (int i = 0; i < detailsList.length(); i++) {
                                JSONObject detailObj = detailsList.optJSONObject(i);
                                if (detailObj != null && detailObj.optString("path_prefix").length() > 0) {
                                    String langCode = detailObj.optString("langue_code");
                                    String pathPrefix = langPathPrefixHM.getOrDefault(langCode, "");
                                    if (pathPrefix.length() > 0) {
                                        pathPrefix += "/" + detailObj.optString("path_prefix");
                                    }
                                    else {
                                        pathPrefix = detailObj.optString("path_prefix");
                                    }
                                    langPathPrefixHM.put(langCode, pathPrefix);
                                }

                            }
                        }
                    }
                }
            }
            boolean langFound = false;
            for (int i = 0; i < detailsLangList.length(); i++) {
                JSONObject detailLangObj = detailsLangList.getJSONObject(i);
                if (detailLangObj != null) {
                    String langue_code = detailLangObj.optString("langue_code");
                    for (Language curLang : langList) {
                        if (curLang.code.equals(langue_code)) {
                            langFound = true;
                            break;
                        }
                    }
                }
                if(langFound) break;
            }
            if (!langFound) {
                retErrorMsg += "No language code found familiar to this site in details_lang object,";
                return retErrorMsg;
            }

            ArrayList<JSONObject> pathsList = new ArrayList<>();
            ArrayList<String> detailLanguagesCode = new ArrayList<>();

            for (Language curLang : langList) {

                JSONObject detailLangObj = null;
                for (int i = 0; i < detailsLangList.length(); i++) {
                    JSONObject curObj = detailsLangList.getJSONObject(i);

                    if (curObj != null && curLang.code.equals(curObj.optString("langue_code"))) {
                        detailLangObj = curObj;
                        break;
                    }
                }

                if (detailLangObj == null) { // some other lang detail
//                    retErrorMsg += "Detail_lang object for langue_code : " + curLang.code + " not found.,";
                    //lang not found, skip it
                    continue;
                }
                detailLanguagesCode.add(curLang.code);
                //description
                {
                    JSONObject descObj = detailLangObj.optJSONObject("description");

                    if (descObj == null) {
                        retErrorMsg += "Description object for langue_code : " + curLang.code + " not found.,";
                    }
                    else {
                        String page_path = PagesUtil.parseNull(descObj.optString("page_path"));

                        if (page_path.length() > 0) {
                            String validPrefixPath = PagesUtil.cleanPagePath(page_path);

                            if (!validPrefixPath.equals(page_path)) {
                                retErrorMsg += "Invalid page_path : " + page_path + " in description for lang : " + curLang.code + ". Only alphanumeric and slash(/) and hyphen(-) allowed.,";
                            }
                            else {
                                String fullPagePath = page_path;
                                String prefixPath = langPathPrefixHM.getOrDefault(curLang.code, "");
                                if (prefixPath.length() > 0) {
                                    fullPagePath = prefixPath + "/" + fullPagePath;
                                }

                                JSONObject pathObj = new JSONObject();
                                pathObj.put("langue_code", curLang.code);
                                pathObj.put("page_path", fullPagePath);
                                pathsList.add(pathObj);
                            }
                        }
                    }
                }

            }// for Languages


            for (JSONObject pathObj : pathsList) {
                String langue_code = PagesUtil.parseNull(pathObj.optString("langue_code"));
                String page_path = PagesUtil.parseNull(pathObj.optString("page_path"));

                page_path = PagesUtil.cleanPagePath(page_path);

                StringBuffer urlErrorMsg = new StringBuffer();
                boolean isUnique = UrlHelper.isUrlUnique(Etn, siteId, langue_code,
                                                         "product", productId, page_path, urlErrorMsg);

                if (!isUnique) {
                    retErrorMsg += "Duplicate page_path : " + page_path + " for lang : " + langue_code + ". " + urlErrorMsg + ",";
                }
            }

            //not checking specs attributes, considering them all optional

            if (variantsList == null || variantsList.length() == 0) {
                retErrorMsg += "Product must have atleast 1 variant.,";
            }
            else {

                HashSet<String> catAttribNames = new HashSet<>();
                HashSet<String> catAttribValues = new HashSet<>();

                q = "SELECT ca.name AS attribute_name, cav.attribute_value "
                    + " FROM " + CATALOG_DB + ".catalog_attributes ca  "
                    + " JOIN " + CATALOG_DB + ".catalog_attribute_values cav ON ca.cat_attrib_id = cav.cat_attrib_id "
                    + " WHERE ca.type = 'selection' AND  ca.catalog_id = " + escape.cote(catalogId);
                rs = Etn.execute(q);
                while (rs.next()) {
                    catAttribNames.add(rs.value("attribute_name"));
                    catAttribValues.add(rs.value("attribute_name") + "_" + rs.value("attribute_value"));
                }

                boolean validVariantFound = false;
                for (int i = 0; i < variantsList.length(); i++) {
                    try {
                        JSONObject variantObj = variantsList.getJSONObject(i);
                        JSONArray variant_attributes = variantObj.getJSONArray("variant_attributes");
                        JSONArray variant_details = variantObj.getJSONArray("variant_details");

                        String variantErrorMsg = "";

                        if (variant_attributes == null) {
                            retErrorMsg += "Invalid variant # " + (i + 1) + ": no attributes found.,";
                            continue;
                        }

                        if (variant_details == null || variant_details.length() == 0) {
                            retErrorMsg += "Invalid variant # " + (i + 1) + ": no details found.,";
                            continue;
                        }

                        String variantSKU = variantObj.optString("sku", "");
                        if (variantSKU.length() == 0) {
                            variantErrorMsg += "Variant # " + (i + 1) + ": SKU not found.,";
                        }
                        else {
                            q = "SELECT pv.id  "
                                + " FROM " + CATALOG_DB + ".product_variants pv "
                                + " JOIN " + CATALOG_DB + ".products p ON p.id = pv.product_id "
                                + " JOIN " + CATALOG_DB + ".catalogs c ON c.id = p.catalog_id  "
                                + " WHERE c.site_id = " + escape.cote(siteId)
                                + " AND pv.sku = " + escape.cote(variantSKU);
                            if (productId.length() > 0) {
                                q += " AND p.id != " + escape.cote(productId);
                            }

                            rs = Etn.execute(q);
                            if (rs.next()) {
                                variantErrorMsg += "Variant # " + (i + 1) + ": SKU already exists.,";
                            }
                        }

                        for (int j = 0; j < variant_attributes.length(); j++) {

                            JSONObject varAttribObj = variant_attributes.getJSONObject(j);
                            String attribName = varAttribObj.getString("attribute_name");
                            String attribValue = varAttribObj.getString("attribute_value");

                            if (!catAttribNames.contains(attribName)) {
                                variantErrorMsg += "Attribute name : " + attribName + " not found.,";
                            }
                            else {
                                if (!catAttribValues.contains(attribName + "_" + attribValue)) {
                                    variantErrorMsg += "Attribute value : " + attribValue + " not found for attribute name : " + attribName + " .,";
                                }
                            }

                        }

                        for (String curLangCode : detailLanguagesCode) {
                            JSONObject varinatDetailLangObj = null;
                            for (int j = 0; j < variant_details.length(); j++) {
                                JSONObject curObj = variant_details.getJSONObject(j);
                                if (curObj != null && curLangCode.equals(curObj.optString("langue_code"))) {
                                    varinatDetailLangObj = curObj;
                                    break;
                                }
                            }

                            if (varinatDetailLangObj == null) { // some other lang detail
                                variantErrorMsg += "Variant # " + (i + 1) + ": No details found for language "+curLangCode+".,";
                            } else {
                                String variantName = varinatDetailLangObj.optString("name", "");
                                if (variantName.length() == 0) {
                                    variantErrorMsg += "Variant # " + (i + 1) + ": Name not found for language "+curLangCode+".,";
                                }
                            }
                        }
                        if (variantErrorMsg.length() == 0) {
                            validVariantFound = true;
                        }
                        else {
                            retErrorMsg += variantErrorMsg;
                        }
                    }
                    catch (Exception varEx) {
                        retErrorMsg += "Exception in  variant item " + (i + 1) + ": " + varEx.toString() + ",";
                    }
                }
            }
            retObj.put("name", name);

            if (retErrorMsg.length() > 0) {
                retObj.put("status", "error");
            }
            else {
                retObj.put("status", itemStatus);
            }
        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }

        return retErrorMsg;
    }

    public String verifyImportItemForms(JSONObject itemObj, JSONObject retObj) {

        String retErrorMsg = "";

        String q = "";
        Set rs = null;
        try {

            JSONObject sysInfo = itemObj.optJSONObject("system_info");

            if (sysInfo == null) {
                retErrorMsg += "System info not found,";
            }

            String FORMS_DB = GlobalParm.getParm("FORMS_DB");

            String formId = "";
            String name = "";
            String tableName = "";

            if (sysInfo != null) {

                name = PagesUtil.parseNull(sysInfo.optString("name"));
                tableName = PagesUtil.parseNull(sysInfo.optString("table_name")) + "_" + siteId;

                if (name.length() == 0) {
                    retErrorMsg += "Name not found,";
                }

                formId = PagesUtil.parseNull(sysInfo.optString("id"));
                if (formId.length() == 0) {
                    retErrorMsg += "Form UUID not found,";
                }
            }

            String itemStatus = "";

            if (retErrorMsg.length() > 0) {
                retObj.put("status", "error");
            }
            else {

                itemStatus = "new";

                q = "SELECT form_id FROM " + FORMS_DB + ".process_forms_unpublished"
                    + " WHERE (table_name = " + escape.cote(tableName)
                    + " OR process_name = " + escape.cote(name)
                    + ") AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if (rs.next()) {

                    itemStatus = "existing";
                }
            }

            retObj.put("name", name);

            if (retErrorMsg.length() > 0) {
                retObj.put("status", "error");
            }
            else {
                retObj.put("status", itemStatus);
            }

        }
        catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }

        return retErrorMsg;
    }
    public String verifyImportItemVariables(JSONObject itemObj, JSONObject retObj) {
        String retErrorMsg = "";
        String q = "";
        Set rs = null;
        try {
            JSONObject sysInfo = itemObj.optJSONObject("system_info");
            if (sysInfo == null) retErrorMsg += "System info not found, ";

            String name = "";
            String value = "";
            String isEditable = "";

            if (sysInfo != null) {
                name = PagesUtil.parseNull(sysInfo.optString("name"));
                value = PagesUtil.parseNull(sysInfo.optString("value"));
                isEditable = PagesUtil.parseNull(sysInfo.optString("is_editable"));
                if (name.length() == 0) retErrorMsg += "Name not found, ";
            }

            String itemStatus = "";

            if (retErrorMsg.length() > 0) retObj.put("status", "error");
            else {
                itemStatus = "new";
                q = "SELECT id FROM variables WHERE name = " + escape.cote(name)+ " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if (rs.next()) itemStatus = "existing";
            }

            retObj.put("name", name);
            if (retErrorMsg.length() > 0) retObj.put("status", "error");
            else retObj.put("status", itemStatus);
        } catch (Exception ex) {
            retErrorMsg += ex.getMessage() + ",";
        }
        return retErrorMsg;
    }


    public String importItem(JSONObject itemObj, String importType) throws Exception {

        String action = "";

        String itemType = itemObj.getString("item_type");

        switch (itemType) {
            case "freemarker_page":
            case "page":
                action = importItemFreemarkerPage(itemObj, importType);
                break;

            case "page_template":
                action += importItemPageTemplate(itemObj, importType);
                break;

            case "bloc":
                action = importItemBloc(itemObj, importType);
                break;

            case "bloc_template":
                action = importItemBlocTemplate(itemObj, importType);
                break;

            case "library":
                action = importItemLibrary(itemObj, importType);
                break;

            // case "structured_catalog":
            //     action = importItemStructuredCatalog(itemObj, importType);
            //     break;

            case "structured_content":
                action = importItemStructuredContent(itemObj, importType);
                break;

            case "structured_page":
            case "store":
                action = importItemStructuredPage(itemObj, importType);
                break;

            case "catalog":
                action = importItemCommercialCatalog(itemObj, importType);
                break;

            case "product":
                action = importItemCommercialProduct(itemObj, importType);
                break;

            case "forms":
                action = importItemForms(itemObj, importType);
                break;
            
            case "variable":
                action = importItemVariables(itemObj, importType);
                break;

            default:
                throw new Exception("Error: Invalid item type.");
        }

        return action;

    }

    public String importItemLibrary(JSONObject itemObj, String importType) throws Exception {
        String action = ""; //insert, update, skip

        String q = "";
        Set rs = null;

        JSONObject sysInfo = itemObj.getJSONObject("system_info");
        JSONArray detailLangs = itemObj.optJSONArray("detail_langs");

        String name = sysInfo.getString("name").trim();

        boolean isExisting = false;
        String libId = "";

        q = "SELECT id FROM libraries "
            + " WHERE name = " + escape.cote(name)
            + " AND site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);
        if (rs.next()) {
            libId = rs.value("id");
            isExisting = true;
        }

        if (IMPORT_TYPE_KEEP.equals(importType)) {
            if (isExisting) {
                action = "skip";
                return action;
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
            if (isExisting) {
                // assign a new name not existing already
                int count = 2;
                String newName = "";
                do {
                    newName = name + " " + count;
                    q = "SELECT id FROM libraries "
                        + " WHERE name = " + escape.cote(newName)
                        + " AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);
                    count++;
                }
                while (rs.next());

                name = newName;

                action = "insert";

            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
            if (isExisting) {
                //delete all original data and "NOT" its associations

                q = "DELETE FROM libraries_files WHERE library_id = " + escape.cote(libId);
                Etn.executeCmd(q);

                action = "update";
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
            if (isExisting) {
                action = "update";
            }
            else {
                action = "insert";
            }
        }

        HashMap<String, String> colValueHM = new HashMap<>();

        colValueHM.put("name", escape.cote(name));
        colValueHM.put("updated_by", escape.cote("" + pid));
        colValueHM.put("updated_ts", "NOW()");
        if(themeId != null && themeId.length()>0){
            colValueHM.put("theme_id", escape.cote(themeId));
        }

        if ("insert".equals(action)) {
            colValueHM.put("created_ts", "NOW()");
            colValueHM.put("created_by", escape.cote("" + pid));
            colValueHM.put("site_id", escape.cote(siteId));

            q = PagesUtil.getInsertQuery("libraries", colValueHM);

            int newLibId = Etn.executeCmd(q);
            if (newLibId <= 0) {
                throw new Exception("Error in inserting library record");
            }
            else {
                libId = "" + newLibId;
            }
        }
        else if ("update".equals(action)) {
            q = PagesUtil.getUpdateQuery("libraries", colValueHM, " WHERE id = " + escape.cote(libId));
            int upCount = Etn.executeCmd(q);
            if (upCount <= 0) {
                throw new Exception("Error in updating library record");
            }
        }

        if(detailLangs == null)
        {
            detailLangs = new JSONArray();
            String query = "select sl.langue_id,l.langue_code from "+GlobalParm.getParm("COMMONS_DB")+
                ".sites_langs sl left join language l on l.langue_id=sl.langue_id where sl.site_id="+escape.cote(siteId);
            Set rsLang = Etn.execute(query);
            
            while(rsLang.next()){
                JSONObject detailsLangObj = PagesUtil.newJSONObject();
                JSONArray bodyFilesList = itemObj.optJSONArray("body_files");
                JSONArray headFilesList = itemObj.optJSONArray("head_files");
                
                if(bodyFilesList == null) throw new Exception("Error Body files list not found");
                if(headFilesList == null) throw new Exception("Error head files list not found");

                detailsLangObj.put("language_code", rsLang.value("langue_code"));
                detailsLangObj.put("body_files", bodyFilesList);
                detailsLangObj.put("head_files", headFilesList);
                detailLangs.put(detailsLangObj);
            }
            itemObj.put("detail_langs",detailLangs);
        }

        if(detailLangs.length()>0){
            int langCount = 0 ;
            for(int j =0; j < detailLangs.length(); j++){
                JSONObject langObj = detailLangs.optJSONObject(j);
                    
                String lang = langObj.optString("language_code");
                if (lang==null) {
                    continue;
                }else{
                    String langId="";
                    Set rsLang = Etn.execute("SELECT l.langue_id FROM "+GlobalParm.getParm("COMMONS_DB")+".sites_langs sl JOIN language l ON sl.langue_id=l.langue_id "
                    +" WHERE l.langue_code="+escape.cote(lang)+" AND sl.site_id="+escape.cote(siteId));
                    rsLang.next();
                    if(rsLang.rs.Rows>0){
                        langId=rsLang.value("langue_id");

                        JSONArray bodyFiles = langObj.getJSONArray("body_files");
                        JSONArray headFiles = langObj.getJSONArray("head_files");

                        //files
                        String qPrefix = "INSERT IGNORE INTO libraries_files(library_id, file_id, "
                                        + " page_position, sort_order,lang_id) "
                                        + " VALUES (" + escape.cote(libId);
                        int sort_order = 0;

                        //process body files
                        if ("update".equals(action) && IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                            //adjust sort order
                            q = "SELECT COUNT(0) as num FROM libraries_files "
                                + " WHERE library_id = " + escape.cote(libId)
                                + " AND page_position = 'body' AND lang_id="+escape.cote(langId);
                            rs = Etn.execute(q);
                            if (rs.next()) {
                                sort_order = PagesUtil.parseInt(rs.value("num"));
                            }
                        }

                        for (int i = 0; i < bodyFiles.length(); i++) {
                            String fileName = "";
                            JSONObject fileObj = bodyFiles.optJSONObject(i);
                            if (fileObj != null) {
                                fileName = PagesUtil.parseNull(fileObj.optString("name"));
                            }
                            
                            if (fileName.length() == 0) {
                                continue;
                            }

                            String fileId = "";
                            q = "SELECT id FROM files "
                                + " WHERE file_name = " + escape.cote(fileName)
                                + " AND type IN ('css','js')"
                                + " AND site_id = " + escape.cote(siteId);
                            rs = Etn.execute(q);
                            if (rs.next()) {
                                fileId = rs.value("id");
                            }

                            if (PagesUtil.parseInt(fileId) > 0) {
                                q = qPrefix + ", " + escape.cote(fileId)
                                    + " , 'body' , " + escape.cote("" + sort_order) + ","+escape.cote(langId)+")";
                                Etn.executeCmd(q);
                                sort_order++;
                            }
                        }

                        //process head files
                        if ("update".equals(action) && IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                            //adjust sort order
                            q = "SELECT COUNT(0) as num FROM libraries_files "
                                + " WHERE library_id = " + escape.cote(libId)
                                + " AND page_position = 'head' AND lang_id="+escape.cote(langId);
                            rs = Etn.execute(q);
                            if (rs.next()) {
                                sort_order = PagesUtil.parseInt(rs.value("num"));
                            }
                        }

                        for (int i = 0; i < headFiles.length(); i++) {

                            String fileName = "";
                            JSONObject fileObj = headFiles.optJSONObject(i);
                            if (fileObj != null) {
                                fileName = PagesUtil.parseNull(fileObj.optString("name"));
                            }

                            if (fileName.length() == 0) {
                                continue;
                            }

                            String fileId = "";
                            q = "SELECT id FROM files "
                                + " WHERE file_name = " + escape.cote(fileName)
                                + " AND type IN ('css','js')"
                                + " AND site_id = " + escape.cote(siteId);
                            rs = Etn.execute(q);
                            if (rs.next()) {
                                fileId = rs.value("id");
                            }

                            if (PagesUtil.parseInt(fileId) > 0) {
                                q = qPrefix + ", " + escape.cote(fileId)
                                    + " , 'head' , " + escape.cote("" + sort_order) + ","+escape.cote(langId)+")";
                                Etn.executeCmd(q);
                                sort_order++;
                            }
                        }

                        if (importDatetime && libId.length() > 0) {
                            updateCreatedUpdatedTs(itemObj, "libraries", " WHERE id = " + escape.cote(libId));
                        }
                    }
                }
            }
        }

        return action;

    }

    public String importItemPageSettings(JSONObject itemObj, String importType, String parentPageId) throws Exception {
		return importItemPageSettings(itemObj, importType, parentPageId, false);
	}
    public String importItemPageSettings(JSONObject itemObj, String importType, String parentPageId,boolean insertRequiredFieldsOnly) throws Exception {
		return importItemPageSettings(itemObj, importType, parentPageId, false,"");
	}
	
    public String importItemPageSettings(JSONObject itemObj, String importType, String parentPageId, boolean insertRequiredFieldsOnly,String pageType) throws Exception {
return importItemPageSettings(itemObj, importType, parentPageId, insertRequiredFieldsOnly,pageType,"");
    }

    public String importItemPageSettings(JSONObject itemObj, String importType, String parentPageId, boolean insertRequiredFieldsOnly,String pageType,String folderType) throws Exception {

        String action = ""; //insert, update, skip

        String q = "";
        Set rs = null;

        JSONObject sysInfo = itemObj.getJSONObject("system_info");
        JSONObject metaInfo = itemObj.optJSONObject("meta_info");
        JSONArray tagsList = itemObj.optJSONArray("tags");
        String name = sysInfo.getString("name").trim();   // manual
        String path = sysInfo.getString("path").trim();
        String variant = sysInfo.getString("variant").trim();
        String langue_code = sysInfo.getString("langue_code").trim();  // manual

        //variant default to all if not valid
        if (!"|all|logged|anonymous|".contains("|" + variant + "|")) {
            variant = "all";
        }

        //default langue_code to 1st , if not in language list
        q = "SELECT langue_code FROM language "
                + " WHERE langue_code = " + escape.cote(langue_code);
        rs = Etn.execute(q);
        if (!rs.next()) {
            q = "SELECT langue_code FROM language "
                    + " ORDER BY langue_id ASC LIMIT 1";

            rs = Etn.execute(q);
            if (rs.next()) {
                langue_code = rs.value("langue_code");
            }
            else {
                throw new Exception("No langue code found.");
            }
        }

        //add folders and get folderPrefixPath and parentFolderId
        String pageFolderId = "0"; //base folder
        String folderPrefixPath = "";

        JSONObject folderObj = sysInfo.optJSONObject("folder");  //manual
        if (folderObj != null && folderObj.optString("name").length() > 0) {
            ArrayList<JSONObject> foldersList = getFoldersList(folderObj);

            //add missing folders
            int lastParentId = 0;

            for (JSONObject curFolderObj : foldersList) {
                q = "SELECT id FROM folders"
                        + " WHERE site_id = " + escape.cote(siteId)
                        + " AND name = " + escape.cote(curFolderObj.getString("name"))
                        + " AND parent_folder_id = " + escape.cote("" + lastParentId)
                        + " AND type = " + escape.cote(folderType);
                rs = Etn.execute(q);
                if (rs.next()) {
                    //folder already exist
                    pageFolderId = rs.value("id");
                }
                else {
                    //folder does not exist, create it
                    pageFolderId = PagesUtil.addFolder(Etn, curFolderObj, "" + lastParentId, Constant.FOLDER_TYPE_PAGES, siteId, pid);
                }
                lastParentId = PagesUtil.parseInt(pageFolderId);
            }

            folderPrefixPath = getFolderPrefixPath(foldersList, langue_code, folderPrefixPath);
        }

        String fullPath = path;
        if (folderPrefixPath.length() > 0) {
            fullPath = folderPrefixPath + "/" + fullPath;
        }
        fullPath = PagesUtil.cleanPagePath(fullPath);
        // Logger.debug("### fullPath after clean=" + fullPath);


        boolean isExisting = false;
        String pageId = "";

        JSONObject checkObj = checkIfPageExists(langue_code, variant, fullPath);
        String checkStatus = checkObj.getString("status");
        if ("error".equals(checkStatus)) {
            throw new Exception(checkObj.getString("message"));
        }
        else if ("existing".equals(checkStatus)) {
            pageId = checkObj.getString("pageId");
            isExisting = true;
        }

        if(parentPageId.length()>0){
            Set rsParentPage = Etn.execute("select * from pages where parent_page_id="+escape.cote(parentPageId)+" and langue_code="+escape.cote(langue_code)+
            " and type="+escape.cote(pageType));
            if(rsParentPage.rs.Rows>0 && checkStatus.equals("new")){
                throw new Exception("New path of "+langue_code+" for exsisting parent page.");
            }
        }

        if (IMPORT_TYPE_KEEP.equals(importType)) {
            if (isExisting) {
                action = "skip";
                return action;
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
            if (isExisting) {
                // assign a new path not existing already
                int count = 2;
                String newPath = "";
                do {
                    newPath = path + "-" + count;
                    q = "SELECT id FROM pages "
                            + " WHERE path = " + escape.cote(newPath)
                            + " AND langue_code = " + escape.cote(langue_code)
                            + " AND variant = " + escape.cote(variant)
                            + " AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);
                    count++;
                }
                while (rs.next());

                path = newPath;

                action = "insert";

            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
            if (isExisting) {
                //delete all original data and "NOT" its associations
                q = "DELETE FROM pages_meta_tags WHERE page_id = " + escape.cote(pageId);
                Etn.executeCmd(q);

                q = "DELETE FROM pages_tags WHERE page_id = " + escape.cote(pageId);
                Etn.executeCmd(q);

                action = "update";
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
            if (isExisting) {
                action = "update";
            }
            else {
                action = "insert";
            }
        }

        HashMap<String, String> colValueHM = new HashMap<>();

        colValueHM.put("name", escape.cote(name));
        colValueHM.put("path", escape.cote(path));
        colValueHM.put("langue_code", escape.cote(langue_code));
        colValueHM.put("updated_by", escape.cote("" + pid));
        colValueHM.put("updated_ts", "NOW()");
        colValueHM.put("to_generate", escape.cote("1"));
        colValueHM.put("to_generate_by", escape.cote("" + pid));
        if(!insertRequiredFieldsOnly){
            colValueHM.put("variant", escape.cote(variant));
        } else{
            variant = "all";
            colValueHM.put("variant", escape.cote(variant)); //default variant
        }
        JSONObject internalInfo = itemObj.optJSONObject("internal_info");
        if (internalInfo != null && !insertRequiredFieldsOnly) { // wechecked the null so that in case of partial import it will not let the information to overwrite
            if(internalInfo.optString("dl_page_type", null) != null ){
                colValueHM.put("dl_page_type", escape.cote(internalInfo.optString("dl_page_type")));
            }
            if(internalInfo.optString("dl_sub_level_1", null) != null ){
                colValueHM.put("dl_sub_level_1", escape.cote(internalInfo.optString("dl_sub_level_1")));
            }
            if(internalInfo.optString("dl_sub_level_2", null) != null ){
                colValueHM.put("dl_sub_level_2", escape.cote(internalInfo.optString("dl_sub_level_2")));
            }
        }

        String title = null;
        String canonical_url = null;
        String meta_keywords = null;
        String meta_description = null;
        String template_id = null;

        if (metaInfo != null) {
            //here set default to null
            //otherwise it returns empty string is a valid value
            title = metaInfo.optString("title", null);
            if(!insertRequiredFieldsOnly){
                canonical_url = metaInfo.optString("canonical_url", null);
                meta_keywords = metaInfo.optString("meta_keywords", null);
                meta_description = metaInfo.optString("meta_description", null);
            }
            // template_id = metaInfo.optString("template_id", null);
        }

        String templateName = sysInfo.optString("template").trim();

        if (templateName.length() > 0) {
            q = "SELECT id FROM page_templates WHERE site_id = " + escape.cote(siteId)
                    + " AND name = " + escape.cote(templateName);
            rs = Etn.execute(q);
            if (rs.next()) {
                template_id = rs.value("id");
            }
        }
        if (PagesUtil.parseNull(template_id).length() == 0) {
            //if valid page template not found , set to default system template
            q = "SELECT id FROM page_templates WHERE site_id = " + escape.cote(siteId)
                    + " AND is_system = '1'";
            rs = Etn.execute(q);
            if (rs.next()) {
                template_id = rs.value("id");
            }
            else {
                throw new Exception("Error no default page template found. Create system page template.");
            }
        }


        if ("insert".equals(action)) {

            if (PagesUtil.parseNull(title).length() == 0) {
                title = name;
            }

            colValueHM.put("created_ts", "NOW()");
            colValueHM.put("created_by", escape.cote("" + pid));
            colValueHM.put("site_id", escape.cote(siteId));
            colValueHM.put("folder_id", escape.cote(pageFolderId));

            colValueHM.put("title", escape.cote(PagesUtil.parseNull(title)));
            colValueHM.put("canonical_url", escape.cote(PagesUtil.parseNull(canonical_url)));
            colValueHM.put("meta_keywords", escape.cote(PagesUtil.parseNull(meta_keywords)));
            colValueHM.put("meta_description", escape.cote(PagesUtil.parseNull(meta_description)));
            colValueHM.put("template_id", escape.cote(PagesUtil.parseNull(template_id)));
            colValueHM.put("parent_page_id", escape.cote(parentPageId));

            q = PagesUtil.getInsertQuery("pages", colValueHM);
            int newId = Etn.executeCmd(q);
            if (newId <= 0) {
                throw new Exception("Error in inserting page record");
            }
            else {
                pageId = "" + newId;
            }
        }
        else if ("update".equals(action)) {

            //optional
            if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                if (title != null) {
                    colValueHM.put("title", escape.cote(PagesUtil.parseNull(title)));
                }

                if (canonical_url != null) {
                    colValueHM.put("canonical_url", escape.cote(PagesUtil.parseNull(canonical_url)));
                }


                if (meta_keywords != null) {
                    colValueHM.put("meta_keywords", escape.cote(PagesUtil.parseNull(meta_keywords)));
                }

                if (meta_description != null) {
                    colValueHM.put("meta_description", escape.cote(PagesUtil.parseNull(meta_description)));
                }

                if (template_id != null) {
                    colValueHM.put("template_id", escape.cote("" + PagesUtil.parseInt(template_id)));
                }
            }
            else {
                colValueHM.put("title", escape.cote(PagesUtil.parseNull(title)));
                colValueHM.put("canonical_url", escape.cote(PagesUtil.parseNull(canonical_url)));
                colValueHM.put("meta_keywords", escape.cote(PagesUtil.parseNull(meta_keywords)));
                colValueHM.put("meta_description", escape.cote(PagesUtil.parseNull(meta_description)));
                colValueHM.put("template_id", escape.cote("" + PagesUtil.parseInt(template_id)));
            }


            q = PagesUtil.getUpdateQuery("pages", colValueHM, " WHERE id = " + escape.cote(pageId));
            int upCount = Etn.executeCmd(q);
            if (upCount <= 0) {
                throw new Exception("Error in updating page record");
            }
        }

        itemObj.put("id", pageId);

        if (metaInfo != null && !insertRequiredFieldsOnly) {

            JSONArray customMetaTagsList = metaInfo.optJSONArray("custom_meta_tags");
            if (customMetaTagsList != null && customMetaTagsList.length() > 0) {

                for (int i = 0; i < customMetaTagsList.length(); i++) {

                    JSONObject metaTag = customMetaTagsList.optJSONObject(i);

                    if (metaTag == null) {
                        continue;
                    }
                    String meta_name = metaTag.optString("meta_name", null);
                    String meta_content = metaTag.optString("meta_content", null);

                    if (meta_name == null || meta_content == null) {
                        continue;
                    }

                    q = "INSERT IGNORE INTO pages_meta_tags (page_id, meta_name, meta_content) "
                            + " VALUES (" + escape.cote(pageId)
                            + "," + escape.cote(meta_name)
                            + "," + escape.cote(meta_content)
                            + ")";
                    Etn.executeCmd(q);
                }
            }
        }

        if (tagsList != null && tagsList.length() > 0 && !insertRequiredFieldsOnly) {

            for (int i = 0; i < tagsList.length(); i++) {

                JSONObject curTagObj = tagsList.optJSONObject(i);
                if (curTagObj == null) {
                    continue;
                }

                String tagId = getTagId(curTagObj);
                q = "INSERT IGNORE INTO pages_tags (page_id, tag_id) "
                        + " VALUES (" + escape.cote(pageId)
                        + "," + escape.cote(tagId)
                        + ")";
                Etn.executeCmd(q);
            }
        }

        if (importDatetime && pageId.length() > 0) {
            //incase of import datetime we dont want engine to generate pages as it update the update_ts
            //we generate page here and set to_generate flag = 0
            PagesGenerator pagesGen = new PagesGenerator(Etn);
            pagesGen.generateAndSavePage(pageId);
            q = "UPDATE pages SET to_generate = '0' WHERE id = " + escape.cote(pageId);
            Etn.executeCmd(q);

            updateCreatedUpdatedTs(itemObj, "pages", " WHERE id = " + escape.cote(pageId));
        }

        return action;
    }

    public String importItemPageTemplate(JSONObject itemObj, String importType) throws Exception {

        String action = ""; //insert, update, skip

        String q = "";
        Set rs = null;

        JSONObject sysInfo = itemObj.getJSONObject("system_info");
        JSONObject details = itemObj.optJSONObject("details");
        if (details == null) {
            details = new JSONObject();
        }

        String name = sysInfo.getString("name").trim();
        String custom_id = sysInfo.getString("custom_id").trim();

        boolean isExisting = false;
        String templateId = "";

        q = "SELECT id FROM page_templates"
            + " WHERE custom_id = " + escape.cote(custom_id)
            + " AND site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);
        if (rs.next()) {
            templateId = rs.value("id");
            isExisting = true;
        }


        if (IMPORT_TYPE_KEEP.equals(importType)) {
            if (isExisting) {
                action = "skip";
                return action;
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
            if (isExisting) {
                // assign a new name not existing already
                int count = 2;
                String newName = "";
                String newCustomId = "";
                do {
                    newCustomId = custom_id + "_" + count;
                    newName = name + " " + count;

                    q = "SELECT id FROM page_templates "
                        + " WHERE custom_id = " + escape.cote(newCustomId)
                        + " AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);
                    count++;
                }
                while (rs.next());

                custom_id = newCustomId;
                name = newName;

                action = "insert";
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
            if (isExisting) {
                //delete original and all its associations
                q = "UPDATE page_templates SET description='', template_code='' WHERE id = " + escape.cote(templateId);
                Etn.executeCmd(q);

                q = "DELETE FROM page_templates_items_details WHERE item_id IN ("
                    + " SELECT id FROM page_templates_items WHERE page_template_id = " + escape.cote(templateId)
                    + ")";
                Etn.executeCmd(q);

                q = "DELETE FROM page_templates_items_blocs WHERE item_id IN ("
                    + " SELECT id FROM page_templates_items WHERE page_template_id = " + escape.cote(templateId)
                    + ")";
                Etn.executeCmd(q);

                q = " DELETE FROM page_templates_items "
                    + " WHERE page_template_id = " + escape.cote(templateId)
                    + " AND custom_id != 'content' "; //no need to delete 'content' fixed/permanent item
                Etn.executeCmd(q);

                action = "update";
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
            if (isExisting) {
                action = "update";
            }
            else {
                action = "insert";
            }
        }

        HashMap<String, String> colValueHM = new HashMap<>();

        colValueHM.put("name", escape.cote(name));
        colValueHM.put("custom_id", escape.cote(custom_id));

        //Note: is_system is only for default template generated by site
        //     do not use is_system from import json
        // colValueHM.put("is_system", is_system);

        colValueHM.put("updated_by", escape.cote("" + pid));
        colValueHM.put("updated_ts", "NOW()");
        if(themeId != null && themeId.length()>0){
            colValueHM.put("theme_id", themeId);
        }
        String description = sysInfo.optString("description", null);
        String template_code = details.optString("template_code", null);

        if ("insert".equals(action)) {
            colValueHM.put("created_ts", "NOW()");
            colValueHM.put("created_by", escape.cote("" + pid));
            colValueHM.put("site_id", escape.cote(siteId));

            colValueHM.put("description", escape.cote(PagesUtil.parseNull(description)));
            colValueHM.put("template_code", PagesUtil.escapeCote(PagesUtil.parseNull(template_code)));

            q = PagesUtil.getInsertQuery("page_templates", colValueHM);
            int newId = Etn.executeCmd(q);
            if (newId <= 0) {
                throw new Exception("Error in inserting page template record");
            }
            else {
                templateId = "" + newId;
            }
        }
        else if ("update".equals(action)) {
            //optional
            if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                if (description != null) {
                    colValueHM.put("description", escape.cote(PagesUtil.parseNull(description)));
                }

                if (template_code != null) {
                    colValueHM.put("template_code", PagesUtil.escapeCote(PagesUtil.parseNull(template_code)));
                }
            }
            else {
                colValueHM.put("description", escape.cote(PagesUtil.parseNull(description)));
                colValueHM.put("template_code", PagesUtil.escapeCote(PagesUtil.parseNull(template_code)));
            }

            q = PagesUtil.getUpdateQuery("page_templates", colValueHM, " WHERE id = " + escape.cote(templateId));
            int upCount = Etn.executeCmd(q);
            if (upCount <= 0) {
                throw new Exception("Error in updating page template record");
            }
        }


        JSONArray itemsList = details.optJSONArray("items");
        if (itemsList != null) {
            for (int i = 0; i < itemsList.length() && itemsList.optJSONObject(i) != null; i++) {
                try {
                    JSONObject item = itemsList.getJSONObject(i);

                    String itemId = "";
                    String itemName = item.optString("name").trim();
                    String itemCustomId = item.optString("custom_id").trim().toLowerCase();
                    String itemSortOrder = String.valueOf(item.optInt("sort_order", 0));

                    if (itemName.length() == 0 || itemCustomId.length() == 0) {
                        continue; //skip
                    }

                    if ("content".equals(itemCustomId)) {
                        //content is fixed non-editable item
                        //only sort_order could be updated if it already exist
                        q = "UPDATE page_templates_items SET sort_order = " + escape.cote(itemSortOrder)
                            + " WHERE page_template_id = " + escape.cote(templateId)
                            + " AND custom_id = 'content' ";
                        Etn.executeCmd(q);
                    }
                    else {
                        colValueHM.clear();
                        colValueHM.put("name", escape.cote(itemName));
                        colValueHM.put("sort_order", escape.cote(itemSortOrder));
                        colValueHM.put("updated_by", escape.cote("" + pid));
                        colValueHM.put("updated_ts", "NOW()");

                        q = "SELECT id FROM page_templates_items "
                            + " WHERE page_template_id = " + escape.cote(templateId)
                            + " AND custom_id = " + escape.cote(itemCustomId);
                        rs = Etn.execute(q);
                        if (rs.next()) {
                            itemId = rs.value("id");
                        }

                        if (itemId.length() == 0) {
                            //new item insert
                            colValueHM.put("page_template_id", escape.cote(templateId));
                            colValueHM.put("custom_id", escape.cote(itemCustomId));
                            colValueHM.put("created_by", escape.cote("" + pid));
                            colValueHM.put("created_ts", "NOW()");
                            q = PagesUtil.getInsertQuery("page_templates_items", colValueHM);
                            int newItemId = Etn.executeCmd(q);
                            if (newItemId <= 0) {
                                throw new Exception("Error while creating page template item record");
                            }
                            itemId = "" + newItemId;
                        }
                        else {
                            //existing item udpate
                            q = PagesUtil.getUpdateQuery("page_templates_items", colValueHM,
                                                         " WHERE id = " + escape.cote(itemId));
                            Etn.executeCmd(q);
                        }

                        if (itemId.length() == 0) continue;

                        JSONArray itemDetailsList = item.optJSONArray("item_details");
                        if (itemDetailsList == null) itemDetailsList = new JSONArray();

                        q = " INSERT IGNORE INTO page_templates_items_details( item_id, langue_id, css_classes, css_style ) "
                            + " SELECT " + escape.cote(itemId) + " AS item_id , l.langue_id, '' , '' "
                            + " FROM `language` l order by l.langue_id ";
                        Etn.executeCmd(q);

                        List<Language> langs = PagesUtil.getLangs(Etn,siteId);

                        for (Language curLang : langs) {
                            JSONObject itemDetail = null;

                            for (Object o : itemDetailsList) {
                                if (!(o instanceof JSONObject)) continue;
                                JSONObject curObj = (JSONObject) o;
                                if (curLang.code.equals(curObj.optString("langue_code"))) {
                                    //lang detail found
                                    itemDetail = curObj;
                                    break;
                                }
                            }

                            if (itemDetail == null) continue;

                            String curLangId = String.valueOf(curLang.id);

                            String css_classes = itemDetail.optString("css_classes", null);
                            String css_style = itemDetail.optString("css_style", null);
                            colValueHM.clear();
                            //optional
                            if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                                if (css_classes != null) {
                                    colValueHM.put("css_classes", escape.cote(PagesUtil.parseNull(css_classes)));
                                }

                                if (css_style != null) {
                                    colValueHM.put("css_style", PagesUtil.escapeCote(PagesUtil.parseNull(css_style)));
                                }
                            }
                            else {
                                colValueHM.put("css_classes", escape.cote(PagesUtil.parseNull(css_classes)));
                                colValueHM.put("css_style", PagesUtil.escapeCote(PagesUtil.parseNull(css_style)));
                            }
                            if (!colValueHM.isEmpty()) {
                                q = PagesUtil.getUpdateQuery("page_templates_items_details", colValueHM,
                                                             "WHERE item_id = " + escape.cote(itemId)
                                                             + " AND langue_id = " + escape.cote(curLangId));
                                Etn.executeCmd(q);
                            }

                            //process blocs
                            JSONArray blocsList = itemDetail.optJSONArray("blocs");
                            if (blocsList != null && blocsList.length() > 0) {
                                int blocIndex = 0;
                                for (Object curObj : blocsList) {
                                    if (!(curObj instanceof JSONObject)) continue;
                                    JSONObject bloc = (JSONObject) curObj;
                                    String blocUuid = bloc.optString("uuid");
                                    String blocType = bloc.optString("type");

                                    if (!"bloc".equals(blocType)) {
                                        continue;
                                    }
                                    q = " INSERT IGNORE INTO page_templates_items_blocs (item_id, langue_id, bloc_id, type, sort_order) "
                                        + " SELECT " + escape.cote(itemId)
                                        + " , " + escape.cote(curLangId)
                                        + ", id, " + escape.cote(blocType) + ", " + escape.cote("" + blocIndex)
                                        + " FROM blocs "
                                        + " WHERE site_id = " + escape.cote(siteId)
                                        + " AND uuid = " + escape.cote(blocUuid);
                                    Etn.executeCmd(q);
                                    blocIndex++;

                                }
                            }

                        }


                    }

                }
                catch (Exception itemEx) {
                    Logger.debug("Error in item # " + i + " | " + itemEx.getMessage());
                    itemEx.printStackTrace();
                }
            }

        }

        try {
            PagesUtil.createOrGetContentRegionId(templateId, Etn, pid);
        }
        catch (SimpleException e) {
            Logger.debug("Unexpected error in creating default content region for page template");
            e.printStackTrace();
        }

        if (importDatetime && templateId.length() > 0) {
            updateCreatedUpdatedTs(itemObj, "page_templates", " WHERE id = " + escape.cote(templateId));
        }

        return action;

    }

	private Map<String, Map<String, Map<String, String>>> getFieldsDefaultValues(String templateId)
	{
		Map<String, Map<String, Map<String, String>>> fieldsMap = new HashMap<String, Map<String, Map<String, String>>>();
		Set rs = Etn.execute("select sd.*, sf.custom_id as field_custom_id, ts.custom_id as section_custom_id from sections_fields_details sd join sections_fields sf on sf.id = sd.field_id join bloc_templates_sections ts on ts.id = sf.section_id WHERE ts.bloc_template_id = " + escape.cote(templateId));
		while(rs.next())
		{
			String s = PagesUtil.parseNull(rs.value("section_custom_id")) + "." + PagesUtil.parseNull(rs.value("field_custom_id"));
			if(fieldsMap.get(s) == null)
			{
				fieldsMap.put(s, new HashMap<String, Map<String, String>>());
			}

			Map<String, Map<String, String>> langueMap = fieldsMap.get(s);

			Map<String, String> detailsMap = new HashMap<String, String>();
			detailsMap.put("default_value", PagesUtil.parseNull(rs.value("default_value")));
			detailsMap.put("placeholder", PagesUtil.parseNull(rs.value("placeholder")));
			langueMap.put(rs.value("langue_id"), detailsMap);
		}
		return fieldsMap;
	}

    public String importItemBlocTemplate(JSONObject itemObj, String importType) throws Exception {

        String action = ""; //insert, update, skip

        String q = "";
        Set rs = null;

        JSONObject sysInfo = itemObj.getJSONObject("system_info");
        JSONObject resources = itemObj.optJSONObject("resources");

        JSONArray sections = itemObj.optJSONArray("sections");

        String name = sysInfo.getString("name").trim();
        String custom_id = sysInfo.getString("custom_id").trim();

        boolean isExisting = false;
        String templateId = "";

        q = "SELECT id FROM bloc_templates "
            + " WHERE custom_id = " + escape.cote(custom_id)
            + " AND site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);
        if (rs.next()) {
            templateId = rs.value("id");
            isExisting = true;
        }

		Map<String, Map<String, Map<String, String>>> fieldsDefaultValuesMap = null;

        if (IMPORT_TYPE_KEEP.equals(importType)) {
            if (isExisting) {
                action = "skip";
                return action;
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
            if (isExisting) {
                // assign a new name not existing already
                int count = 2;
                String newName = "";
                String newCustomId = "";
                do {
                    newCustomId = custom_id + "_" + count;
                    newName = name + " " + count;

                    q = "SELECT id FROM bloc_templates "
                        + " WHERE custom_id = " + escape.cote(newCustomId)
                        + " AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);
                    count++;
                }
                while (rs.next());

                custom_id = newCustomId;
                name = newName;

                action = "insert";

            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
            if (isExisting) {
				//preserve old default values
				fieldsDefaultValuesMap = getFieldsDefaultValues(templateId);

                //delete original and all its associations

                q = "DELETE FROM bloc_templates_libraries WHERE bloc_template_id = " + escape.cote(templateId);
                Etn.executeCmd(q);

				q = "delete from sections_fields_details where field_id in (select id FROM sections_fields WHERE section_id IN ( SELECT id FROM bloc_templates_sections WHERE bloc_template_id = " + escape.cote(templateId)+"))";
				Etn.executeCmd(q);

                q = "DELETE FROM sections_fields "
                    + " WHERE section_id IN ( SELECT id FROM bloc_templates_sections "
                    + " WHERE bloc_template_id = " + escape.cote(templateId) + " )";
                Etn.executeCmd(q);

                q = " DELETE FROM bloc_templates_sections "
                    + " WHERE bloc_template_id = " + escape.cote(templateId);
                Etn.executeCmd(q);

                action = "update";
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
            if (isExisting) {
				//preserve old default values
				fieldsDefaultValuesMap = getFieldsDefaultValues(templateId);
                action = "update";
            }
            else {
                action = "insert";
            }
        }

        HashMap<String, String> colValueHM = new HashMap<>();

        String type = sysInfo.getString("type");

        colValueHM.put("name", escape.cote(name));
        colValueHM.put("custom_id", escape.cote(custom_id));
        colValueHM.put("type", escape.cote(type));


        colValueHM.put("updated_by", escape.cote("" + pid));
        colValueHM.put("updated_ts", "NOW()");

        if(themeId != null && themeId.length()>0){
            colValueHM.put("theme_id", escape.cote(themeId));
        }


        String description = sysInfo.optString("description", null);
        String template_code = null;
        String css_code = null;
        String js_code = null;
        String jsonld_code = null;

        if (resources != null) {
            template_code = resources.optString("code", null);
            css_code = resources.optString("css", null);
            js_code = resources.optString("js", null);
            jsonld_code = resources.optString("jsonld", null);
        }

        if ("insert".equals(action)) {
            colValueHM.put("created_ts", "NOW()");
            colValueHM.put("created_by", escape.cote("" + pid));
            colValueHM.put("site_id", escape.cote(siteId));

            colValueHM.put("description", escape.cote(PagesUtil.parseNull(description)));
            colValueHM.put("template_code", PagesUtil.escapeCote(PagesUtil.parseNull(template_code)));
            colValueHM.put("css_code", PagesUtil.escapeCote(PagesUtil.parseNull(css_code)));
            colValueHM.put("js_code", PagesUtil.escapeCote(PagesUtil.parseNull(js_code)));
            colValueHM.put("jsonld_code", PagesUtil.escapeCote(PagesUtil.parseNull(jsonld_code)));

            q = PagesUtil.getInsertQuery("bloc_templates", colValueHM);
            int newId = Etn.executeCmd(q);
            if (newId <= 0) {
                throw new Exception("Error in inserting bloc template record");
            }
            else {
                templateId = "" + newId;
            }
        }
        else if ("update".equals(action)) {

            //optional
            if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                if (description != null) {
                    colValueHM.put("description", escape.cote(PagesUtil.parseNull(description)));
                }

                if (template_code != null) {
                    colValueHM.put("template_code", PagesUtil.escapeCote(PagesUtil.parseNull(template_code)));
                }

                if (css_code != null) {
                    colValueHM.put("css_code", PagesUtil.escapeCote(PagesUtil.parseNull(css_code)));
                }

                if (js_code != null) {
                    colValueHM.put("js_code", PagesUtil.escapeCote(PagesUtil.parseNull(js_code)));
                }

                if (jsonld_code != null) {
                    colValueHM.put("jsonld_code", PagesUtil.escapeCote(PagesUtil.parseNull(jsonld_code)));
                }
            }
            else {
                colValueHM.put("description", escape.cote(PagesUtil.parseNull(description)));
                colValueHM.put("template_code", PagesUtil.escapeCote(PagesUtil.parseNull(template_code)));
                colValueHM.put("css_code", PagesUtil.escapeCote(PagesUtil.parseNull(css_code)));
                colValueHM.put("js_code", PagesUtil.escapeCote(PagesUtil.parseNull(js_code)));
                colValueHM.put("jsonld_code", PagesUtil.escapeCote(PagesUtil.parseNull(jsonld_code)));
            }


            q = PagesUtil.getUpdateQuery("bloc_templates", colValueHM, " WHERE id = " + escape.cote(templateId));
            int upCount = Etn.executeCmd(q);
            if (upCount <= 0) {
                throw new Exception("Error in updating bloc template record");
            }
        }

        if (resources != null) {

            JSONArray librariesList = resources.optJSONArray("libraries");
            if (librariesList != null && librariesList.length() > 0) {

                for (int i = 0; i < librariesList.length(); i++) {

                    String libName = "";
                    libName = PagesUtil.parseNull(librariesList.optString(i));

                    if (libName.length() == 0) {
                        continue;
                    }

                    String libId = "";
                    q = "SELECT id FROM libraries "
                        + " WHERE name = " + escape.cote(libName)
                        + " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);
                    if (rs.next()) {
                        libId = rs.value("id");
                    }

                    if (PagesUtil.parseInt(libId) > 0) {
                        q = "INSERT IGNORE INTO bloc_templates_libraries (bloc_template_id,library_id) "
                            + " VALUES (" + escape.cote(templateId)
                            + "," + escape.cote(libId) + ") ";
                        Etn.executeCmd(q);
                    }
                }
            }
        }


        boolean processSections = true;
        if ("update".equals(action) && IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
            if (sections == null || sections.length() <= 0) {
                processSections = false;
            }
        }

        if (processSections) {
            try {
                PagesUtil.insertUpdateTemplateSections(Etn, sections, templateId, "0", false, pid);
            }
            catch (SimpleException e) {
                throw new Exception(e);
            }
        }

        if (importDatetime && templateId.length() > 0) {
            updateCreatedUpdatedTs(itemObj, "bloc_templates", " WHERE id = " + escape.cote(templateId));
        }

		//we must put back the original default values
		if(action.equals("update") && fieldsDefaultValuesMap != null)
		{
			for(String key : fieldsDefaultValuesMap.keySet())
			{
				String sectionCustomId = "";
				String fieldCustomId = "";
				if(key.indexOf(".") > -1)
				{
					sectionCustomId = key.substring(0, key.indexOf("."));
					fieldCustomId = key.substring(key.indexOf(".")+1);
				}
				if(fieldCustomId.length() > 0 && sectionCustomId.length() > 0)
				{
					Etn.executeCmd("delete from sections_fields_details where field_id in (select id FROM sections_fields WHERE custom_id = "+escape.cote(fieldCustomId)+" and section_id IN ( SELECT id FROM bloc_templates_sections WHERE custom_id = "+escape.cote(sectionCustomId)+" and bloc_template_id = " + escape.cote(templateId)+"))");
					Set rsF = Etn.execute("select id FROM sections_fields WHERE custom_id = "+escape.cote(fieldCustomId)+" and section_id IN ( SELECT id FROM bloc_templates_sections WHERE custom_id = "+escape.cote(sectionCustomId)+" and bloc_template_id = " + escape.cote(templateId)+")");
					if(rsF.next())
					{
						for(String langId : fieldsDefaultValuesMap.get(key).keySet())
						{
							Map<String, String> langueMap = fieldsDefaultValuesMap.get(key).get(langId);
							Etn.executeCmd("insert into sections_fields_details (field_id, langue_id, default_value, placeholder) values ("+escape.cote(rsF.value("id"))+", "+escape.cote(langId)+", "+escape.cote(PagesUtil.parseNull(langueMap.get("default_value")))+", "+escape.cote(PagesUtil.parseNull(langueMap.get("placeholder")))+")");
						}
					}
				}

			}

		}

        return action;
    }

    public String importItemBloc(JSONObject itemObj, String importType) throws Exception {

        String action = ""; //insert, update, skip

        String q = "";
        Set rs = null;

        JSONObject sysInfo = itemObj.getJSONObject("system_info");
        JSONObject paremeters = itemObj.optJSONObject("paremeters");
        JSONArray detailsLangList = itemObj.optJSONArray("details_lang");
        JSONArray tagsList = itemObj.optJSONArray("tags");

        String uuid = sysInfo.getString("id").trim();
        String name = sysInfo.getString("name").trim();
        String templateId = sysInfo.getString("template_id").trim();

        boolean isExisting = false;
        String blocId = "";
        String templateType = "";

        q = "SELECT id, type FROM bloc_templates "
	        + " WHERE custom_id = " + escape.cote(templateId)
	        + " AND site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);
        if (rs.next()) {
            templateId = rs.value("id");
            templateType = rs.value("type");
        }
        else {
            throw new Exception("Invalid template id.");
        }

        q = "SELECT id FROM blocs "
            + " WHERE uuid = " + escape.cote(uuid)
            + " AND site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);
        if (rs.next()) {
            blocId = rs.value("id");
            isExisting = true;
        }


        if (IMPORT_TYPE_KEEP.equals(importType)) {
            if (isExisting) {
                action = "skip";
                return action;
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
            if (isExisting) {
                // assign a new name not existing already
                int count = 2;
                String newName = "";
                String newUuid = "";
                do {
                    newName = name + " " + count;
                    newUuid = UUID.randomUUID().toString();

                    q = "SELECT id FROM blocs "
                        + " WHERE uuid = " + escape.cote(newUuid)
                        + " AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);
                    count++;
                }
                while (rs.next());

                name = newName;
                uuid = newUuid;

                action = "insert";

            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
            if (isExisting) {
                //delete original and all its associations

                q = "UPDATE blocs SET rss_feed_ids = '' AND rss_feed_sort = '' "
                    + " WHERE id = " + escape.cote(blocId);
                Etn.executeCmd(q);

                q = "DELETE FROM blocs_tags WHERE bloc_id = " + escape.cote(blocId);
                Etn.executeCmd(q);

                action = "update";
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
            if (isExisting) {
                action = "update";
            }
            else {
                action = "insert";
            }
        }

        HashMap<String, String> colValueHM = new HashMap<>();

        colValueHM.put("uuid", escape.cote(uuid));
        colValueHM.put("name", escape.cote(name));
        colValueHM.put("template_id", escape.cote(templateId));

        colValueHM.put("updated_by", escape.cote("" + pid));
        colValueHM.put("updated_ts", "NOW()");


        String description = sysInfo.optString("description", null);

        String margin_top = null;
        String margin_bottom = null;
        String start_date = null;
        String end_date = null;
        String refresh_interval = null;
        String visible_to = "";

        String rss_feed_ids = null;
        String rss_feed_sort = null;


        if (paremeters != null) {
            margin_top = paremeters.optString("margin_top", null);
            margin_bottom = paremeters.optString("margin_bottom", null);
            start_date = paremeters.optString("start_date", null);
            end_date = paremeters.optString("end_date", null);

            visible_to = PagesUtil.parseNull(paremeters.optString("visible_to"));
        }

        if (!"|all|logged|anonymous|".contains("|" + visible_to + "|")) {
            visible_to = "all";
        }

        //feed_view
        if ("feed_view".equals(templateType)) {
            rss_feed_sort = PagesUtil.parseNull(sysInfo.optString("rss_feed_sort"));
            if (!"|title_asc|title_desc|date_asc|date_desc|".contains("|" + rss_feed_sort + "|")) {
                rss_feed_sort = "date_desc";
            }

            rss_feed_ids = "";
            JSONArray rssFeedList = sysInfo.optJSONArray("rss_feeds");
            if (rssFeedList != null && rssFeedList.length() > 0) {

                for (int i = 0; i < rssFeedList.length(); i++) {

                    String feedName = PagesUtil.parseNull(rssFeedList.optString(i));

                    if (feedName.length() == 0) {
                        continue;
                    }

                    String feedId = "";
                    q = "SELECT id FROM rss_feeds "
                        + " WHERE name = " + escape.cote(feedName)
                        + " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);
                    if (rs.next()) {
                        feedId = rs.value("id");
                    }

                    if (feedId.length() > 0) {
                        if (rss_feed_ids.length() > 0) {
                            rss_feed_ids += ",";
                        }
                        rss_feed_ids += feedId;
                    }

                }
            }// if (rssFeedList)
        }


        if ("insert".equals(action)) {
            colValueHM.put("created_ts", "NOW()");
            colValueHM.put("created_by", escape.cote("" + pid));
            colValueHM.put("site_id", escape.cote(siteId));

            colValueHM.put("description", escape.cote(PagesUtil.parseNull(description)));
            colValueHM.put("margin_top", escape.cote(PagesUtil.parseNull(margin_top)));
            colValueHM.put("margin_bottom", escape.cote(PagesUtil.parseNull(margin_bottom)));
            colValueHM.put("start_date", escape.cote(PagesUtil.parseNull(start_date)));
            colValueHM.put("end_date", escape.cote(PagesUtil.parseNull(end_date)));
            colValueHM.put("visible_to", escape.cote(PagesUtil.parseNull(visible_to)));

            colValueHM.put("rss_feed_sort", escape.cote(PagesUtil.parseNull(rss_feed_sort)));
            colValueHM.put("rss_feed_ids", escape.cote(PagesUtil.parseNull(rss_feed_ids)));

            q = PagesUtil.getInsertQuery("blocs", colValueHM);
            int newId = Etn.executeCmd(q);
            if (newId <= 0) {
                throw new Exception("Error in inserting bloc record");
            }
            else {
                blocId = "" + newId;
            }
        }
        else if ("update".equals(action)) {

            //optional
            if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {

                if (description != null) {
                    colValueHM.put("description", escape.cote(PagesUtil.parseNull(description)));
                }

                if (margin_top != null) {
                    colValueHM.put("margin_top", escape.cote(PagesUtil.parseNull(margin_top)));
                }

                if (margin_bottom != null) {
                    colValueHM.put("margin_bottom", escape.cote(PagesUtil.parseNull(margin_bottom)));
                }

                if (start_date != null) {
                    colValueHM.put("start_date", escape.cote(PagesUtil.parseNull(start_date)));
                }

                if (end_date != null) {
                    colValueHM.put("end_date", escape.cote(PagesUtil.parseNull(end_date)));
                }

                if (visible_to != null) {
                    colValueHM.put("visible_to", escape.cote(PagesUtil.parseNull(visible_to)));
                }

                if (rss_feed_sort != null) {
                    colValueHM.put("rss_feed_sort", escape.cote(PagesUtil.parseNull(rss_feed_sort)));
                }

                if (rss_feed_ids != null) {
                    colValueHM.put("rss_feed_ids", escape.cote(PagesUtil.parseNull(rss_feed_ids)));
                }
            }
            else {
                colValueHM.put("description", escape.cote(PagesUtil.parseNull(description)));
                colValueHM.put("margin_top", escape.cote(PagesUtil.parseNull(margin_top)));
                colValueHM.put("margin_bottom", escape.cote(PagesUtil.parseNull(margin_bottom)));
                colValueHM.put("start_date", escape.cote(PagesUtil.parseNull(start_date)));
                colValueHM.put("end_date", escape.cote(PagesUtil.parseNull(end_date)));
                colValueHM.put("visible_to", escape.cote(PagesUtil.parseNull(visible_to)));

                colValueHM.put("rss_feed_sort", escape.cote(PagesUtil.parseNull(rss_feed_sort)));
                colValueHM.put("rss_feed_ids", escape.cote(PagesUtil.parseNull(rss_feed_ids)));


            }

            q = PagesUtil.getUpdateQuery("blocs", colValueHM, " WHERE id = " + escape.cote(blocId));
            int upCount = Etn.executeCmd(q);
            if (upCount <= 0) {
                throw new Exception("Error in updating bloc record");
            }

        }//else update

        List<Language> langList = PagesUtil.getLangs(Etn,siteId);
        //details_lang
        {
            //to handle older version JSON of non-multi-language blocs
            boolean isOldVersion = false;
            if (detailsLangList == null) {
                if (itemObj.optJSONObject("sections_data") != null) {
                    //older bloc export json
                    isOldVersion = true;
                }
                else {
                    detailsLangList = new JSONArray();
                }
            }


            for (Language curLang : langList) { // site langs
                String curLangId = "" + curLang.id;

                JSONObject sectionsData = null;
                //get sections_data json for current lang
                if (!isOldVersion) {
                    JSONObject curDetailLangObj = null;
                    for (int i = 0; i < detailsLangList.length(); i++) {
                        JSONObject curObj = detailsLangList.optJSONObject(i);

                        if (curObj != null && curLang.code.equals(curObj.optString("langue_code"))) {
                            curDetailLangObj = curObj;
                            break;
                        }
                    }
                    if (curDetailLangObj != null) {
                        sectionsData = curDetailLangObj.optJSONObject("sections_data");
                    }
                }
                else {
                    sectionsData = itemObj.getJSONObject("sections_data");
                }

                if ("insert".equals(action)) {
                    if (sectionsData == null) {
                        sectionsData = new JSONObject();
                    }
                    JSONObject dataObj = getBlocTemplateDataJson(templateId, sectionsData, curLangId);

                    String template_data = dataObj.toString();
                    q = "INSERT INTO blocs_details(bloc_id, langue_id, template_data) VALUES ("
                        + escape.cote(blocId) + "," + escape.cote(curLangId)
                        + "," + PagesUtil.escapeCote(template_data) + ")";
                    Etn.executeCmd(q);
                }
                else if ("update".equals(action)) {
                    if (sectionsData != null || !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                        if (sectionsData == null) continue;  // in import all case if the there is no section data then continue
                        JSONObject dataObj = getBlocTemplateDataJson(templateId, sectionsData, curLangId);

                        String template_data = dataObj.toString();

                        q = "UPDATE blocs_details SET template_data = " + PagesUtil.escapeCote(template_data)
                            + " WHERE bloc_id =" + escape.cote(blocId)
                            + " AND langue_id =" + escape.cote(curLangId);
                        Etn.executeCmd(q);
                    }

                }
            }
        }

        if (tagsList != null && tagsList.length() > 0) {

            for (int i = 0; i < tagsList.length(); i++) {

                JSONObject curTagObj = tagsList.optJSONObject(i);

                if (curTagObj == null) {
                    continue;
                }
                String tagId = getTagId(curTagObj);

                q = "INSERT IGNORE INTO blocs_tags (bloc_id, tag_id) "
                    + " VALUES (" + escape.cote(blocId)
                    + "," + escape.cote(tagId)
                    + ")";
                Etn.executeCmd(q);
            }
        }

        if (importDatetime && blocId.length() > 0) {
            updateCreatedUpdatedTs(itemObj, "blocs", " WHERE id = " + escape.cote(blocId));
        }

        return action;
    }

    //Obsolete
    /*public String importItemStructuredCatalog(JSONObject itemObj, String importType) throws Exception {
        String action = ""; //insert, update, skip

        String q = "";
        Set rs = null;

        JSONObject sysInfo = itemObj.getJSONObject("system_info");
        JSONArray detailsList = itemObj.optJSONArray("details");
        if (detailsList == null) {
            detailsList = new JSONArray();
        }

        String name = sysInfo.getString("name").trim();
        String templateCustomId = sysInfo.getString("template_id").trim();
        String catalogType = sysInfo.getString("type").trim();

        if (!"page".equals(catalogType)) {
            catalogType = "content";
        }

        String templateId = "";
        q = "SELECT id FROM bloc_templates"
            + " WHERE custom_id = " + escape.cote(templateCustomId)
            + " AND site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);
        if (rs.next()) {
            templateId = rs.value("id");
        }
        else {
            throw new Exception("Invalid template_id : " + templateCustomId);
        }

        boolean isExisting = false;
        String catalogId = "";

        q = "SELECT id FROM structured_catalogs "
            + " WHERE name = " + escape.cote(name)
            + " AND site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);
        if (rs.next()) {
            catalogId = rs.value("id");
            isExisting = true;
        }


        if (IMPORT_TYPE_KEEP.equals(importType)) {
            if (isExisting) {
                action = "skip";
                return action;
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
            if (isExisting) {
                // assign a new name not existing already
                int count = 2;
                String newName = "";
                do {
                    newName = name + " " + count;
                    q = "SELECT id FROM structured_catalogs "
                        + " WHERE name = " + escape.cote(newName)
                        + " AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);
                    count++;
                }
                while (rs.next());

                name = newName;

                action = "insert";

            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
            if (isExisting) {
                //delete all original data and "NOT" its associations

                action = "update";
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
            if (isExisting) {
                action = "update";
            }
            else {
                action = "insert";
            }
        }

        HashMap<String, String> colValueHM = new HashMap<>();
        int pid = pid;

        colValueHM.put("name", escape.cote(name));
        colValueHM.put("type", escape.cote(catalogType));
        colValueHM.put("template_id", escape.cote(templateId));

        colValueHM.put("updated_by", escape.cote("" + pid));
        colValueHM.put("updated_ts", "NOW()");
        if ("insert".equals(action)) {
            colValueHM.put("created_ts", "NOW()");
            colValueHM.put("created_by", escape.cote("" + pid));
            colValueHM.put("site_id", escape.cote(siteId));

            q = PagesUtil.getInsertQuery("structured_catalogs", colValueHM);

            int newCatalogId = Etn.executeCmd(q);
            if (newCatalogId <= 0) {
                throw new Exception("Error in inserting structured catalogs record");
            }
            else {
                catalogId = "" + newCatalogId;
            }
        }
        else if ("update".equals(action)) {
            q = PagesUtil.getUpdateQuery("structured_catalogs", colValueHM, " WHERE id = " + escape.cote(catalogId));
            int upCount = Etn.executeCmd(q);
            if (upCount <= 0) {
                throw new Exception("Error in updating structured catalogs record");
            }
        }

        if (importDatetime && catalogId.length() > 0) {
            updateCreatedUpdatedTs(itemObj, "structured_catalogs", " WHERE id = " + escape.cote(catalogId), Etn);
        }

        if ("page".equals(catalogType)) {
            //process content details
            ArrayList<Language> langList = PagesUtil.getLangs(Etn);
            for (Language lang : langList) {

                String langId = "" + lang.id;
                String langCode = lang.code;

                JSONObject detailObj = null;
                for (int i = 0; i < detailsList.length(); i++) {
                    JSONObject curDetailObj = detailsList.optJSONObject(i);
                    String detailLangCode = curDetailObj.optString("langue_code");
                    if (langCode.equals(detailLangCode)) {
                        detailObj = curDetailObj;
                        break; //match found
                    }
                }

                if (detailObj == null) {
                    detailObj = new JSONObject();
                }

                String detailId = "";
                q = "SELECT id FROM structured_catalogs_details "
                    + " WHERE catalog_id = " + escape.cote(catalogId)
                    + " AND langue_id = " + escape.cote(langId);
                rs = Etn.execute(q);
                if (rs.next()) {
                    detailId = rs.value("id");
                }

                colValueHM.clear();
                colValueHM.put("path_prefix", escape.cote(detailObj.optString("path_prefix", "")));
                if (detailId.length() == 0) {
                    //insert
                    colValueHM.put("catalog_id", escape.cote(catalogId));
                    colValueHM.put("langue_id", escape.cote(langId));

                    q = PagesUtil.getInsertQuery("structured_catalogs_details", colValueHM);
                    Etn.executeCmd(q);
                }
                else {
                    //update
                    if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType) && detailObj.optString("path_prefix") == null) {
                        //dont update if no value provided and import type is partial
                    }
                    else {
                        q = PagesUtil.getUpdateQuery("structured_catalogs_details", colValueHM, " WHERE id = " + escape.cote(detailId));
                        Etn.executeCmd(q);
                    }
                }

            }//for langList
        }

        return action;

    }*/

    public String importItemStructuredContent(JSONObject itemObj, String importType) throws Exception {
        return importItemStructuredContentGeneric(itemObj, importType, Constant.STRUCTURE_TYPE_CONTENT);
    }

    public String importItemStructuredPage(JSONObject itemObj, String importType) throws Exception {
        return importItemStructuredContentGeneric(itemObj, importType, Constant.STRUCTURE_TYPE_PAGE);
    }

    protected String importItemFreemarkerPage(JSONObject itemObj, String importType) throws Exception {
        String action = ""; //insert, update, skip
        String id = "";
        boolean isExisting = false;
        try {
            String q;
            Set rs;

            List<Language> langList = PagesUtil.getLangs(Etn,siteId);

            JSONObject sysInfo = itemObj.getJSONObject("system_info");
            JSONArray blocsList = itemObj.optJSONArray("blocs");

            String name = sysInfo.getString("name").trim();
            String folderId = "0";

            //set folderId
            JSONObject folderObj = sysInfo.optJSONObject("folder");
            if (folderObj != null && folderObj.optString("name").length() > 0) {
                ArrayList<JSONObject> foldersList = getFoldersList(folderObj);

                int lastParentId = 0;
                for (JSONObject curFolderObj : foldersList) {
                    String folderName = curFolderObj.getString("name");

                    q = "SELECT id FROM folders f"
                            + " WHERE site_id = " + escape.cote(siteId)
                            + " AND type = " + escape.cote(Constant.FOLDER_TYPE_PAGES)
                            + " AND name = " + escape.cote(folderName)
                            + " AND parent_folder_id = " + escape.cote("" + lastParentId);
                    rs = Etn.execute(q);
                    if (rs.next()) {
                        //folder already exist
                        folderId = rs.value("id");
                    }
                    else {
                        //folder does not exist, create it
                        folderId = PagesUtil.addFolder(Etn, curFolderObj, "" + lastParentId, Constant.FOLDER_TYPE_PAGES, siteId, pid);
                    }
                    lastParentId = PagesUtil.parseInt(folderId);
                }
            }

            q = "SELECT fp.id "
                    + " FROM freemarker_pages fp "
                    + " WHERE fp.name = " + escape.cote(name)
                    + " AND fp.site_id = " + escape.cote(siteId)
                    + " AND fp.folder_id = " + escape.cote(folderId)
                    + " AND fp.is_deleted = '0'";

            rs = Etn.execute(q);
            if (rs.next()) {
                id = rs.value("id");
                isExisting = true;
            }

            if (IMPORT_TYPE_KEEP.equals(importType)) {
                if (isExisting) {
                    action = "skip";
                    return action;
                }
                else {
                    action = "insert";
                }
            }
            else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
                if (isExisting) {
                    // assign a new name not existing already
                    int count = 2;
                    String newName = "";
                    do {
                        newName = name + " " + count;

                        q = "SELECT fp.id "
                                + " FROM freemarker_pages fp "
                                + " WHERE fp.name = " + escape.cote(newName)
                                + " AND fp.site_id = " + escape.cote(siteId)
                                + " AND fp.folder_id = " + escape.cote(folderId)
                                + " AND fp.is_deleted = '0'";

                        rs = Etn.execute(q);
                        count++;
                    }
                    while (rs.next());

                    name = newName;
                    action = "insert";
                }
                else {
                    action = "insert";
                }
            }
            else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
                if (isExisting) {
                    //clear original data
                    q = "DELETE FROM parent_pages_blocs WHERE page_id = " + escape.cote(id);
                    Etn.executeCmd(q);

                    q = "DELETE FROM parent_pages_forms WHERE page_id = " + escape.cote(id);
                    Etn.executeCmd(q);

                    action = "update";
                }
                else {
                    action = "insert";
                }
            }
            else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                if (isExisting) {
                    action = "update";
                }
                else {
                    action = "insert";
                }
            }

            HashMap<String, String> colValueHM = new HashMap<>();

            colValueHM.put("name", escape.cote(name));
            colValueHM.put("updated_by", escape.cote("" + pid));
            colValueHM.put("updated_ts", "NOW()");
            colValueHM.put("to_generate", "'1'");
            colValueHM.put("to_generate_by", escape.cote("" + pid));

            if ("insert".equals(action)) {
                colValueHM.put("site_id", escape.cote(siteId));
                colValueHM.put("folder_id", escape.cote(folderId));
                colValueHM.put("created_ts", "NOW()");
                colValueHM.put("created_by", escape.cote("" + pid));

                q = PagesUtil.getInsertQuery("freemarker_pages", colValueHM);
                int newId = Etn.executeCmd(q);
                if (newId <= 0) {
                    throw new Exception("Error in inserting freemarker pages record");
                }
                else {
                    id = "" + newId;
                }
            }
            else if ("update".equals(action)) {

                q = PagesUtil.getUpdateQuery("freemarker_pages", colValueHM, " WHERE id = " + escape.cote(id)+" AND site_id = "+escape.cote(siteId) +" AND is_deleted = '0'");
                int upCount = Etn.executeCmd(q);
                if (upCount <= 0) {
                    throw new Exception("Error in updating freemarker pages record");
                }

            }//else update

            itemObj.put("id", id);

            // adding blocs
            if (blocsList != null) {
                String FORMS_DB = GlobalParm.getParm("FORMS_DB");
                int sort_order = 0;
                //process head files
                if ("update".equals(action) && IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                    //adjust sort order
                    q = "SELECT MAX(max_num) AS max_num "
                            + " FROM ( "
                            + " SELECT MAX(sort_order) as max_num FROM parent_pages_blocs  "
                            + " where page_id = " + escape.cote(id)
                            + " UNION  "
                            + " SELECT MAX(sort_order) as max_num FROM parent_pages_forms  "
                            + " where page_id = " + escape.cote(id)
                            + " ) t1";
                    rs = Etn.execute(q);
                    if (rs.next()) {
                        sort_order = PagesUtil.parseInt(rs.value("max_num")) + 1;
                    }
                }

                String blocQPrefix = " INSERT INTO parent_pages_blocs(page_id, bloc_id, sort_order) "
                        + " VALUES ( " + escape.cote("" + id);
                String formQPrefix = " INSERT INTO parent_pages_forms(page_id, form_id, sort_order) "
                        + " VALUES ( " + escape.cote("" + id);
                for (int i = 0; i < blocsList.length(); i++) {

                    String blocUUID = PagesUtil.parseNull(blocsList.optString(i));
                    if (blocUUID.length() == 0) {
                        continue;
                    }

                    if (!blocUUID.startsWith("form_")) {
                        String blocId = "";
                        q = "SELECT id FROM blocs "
                                + " WHERE uuid = " + escape.cote(blocUUID)
                                + " AND site_id = " + escape.cote(siteId);
                        rs = Etn.execute(q);
                        if (rs.next()) {
                            blocId = rs.value("id");
                        }

                        if (PagesUtil.parseInt(blocId) > 0) {
                            q = blocQPrefix + ", " + escape.cote(blocId)
                                    + "," + escape.cote("" + sort_order) + ")";
                            Etn.executeCmd(q);
                            sort_order++;
                        }
                    }
                    else {
                        //form ID
                        String formId = blocUUID.substring(5);

                        q = " SELECT form_id FROM " + FORMS_DB + ".process_forms "
                                + " WHERE form_id = " + escape.cote(formId)
                                + " AND site_id = " + escape.cote(siteId);
                        rs = Etn.execute(q);
                        if (rs != null && rs.next()) {
                            q = formQPrefix + ", " + escape.cote(formId)
                                    + "," + escape.cote("" + sort_order) + ")";
                            Etn.executeCmd(q);
                            sort_order++;
                        }
                    }
                }
            }

            boolean isNewStructure = itemObj.has("details") ? true : false;

            JSONArray detailsList = new JSONArray();
            String _path = "";
            if(isNewStructure){
                detailsList = itemObj.optJSONArray("details");
                if (detailsList == null || detailsList.length() < 1) {
                    if(!isExisting){
                        rollbackPage(id, Constant.PAGE_TYPE_FREEMARKER);
                    }
                    throw new Exception("Error: Atleast 1 valid detail entry is required.");
                }
            } else{
                _path = itemObj.getJSONObject("system_info").getString("path").trim();
            }

            int firstDetailIndex = -1;

            if(isNewStructure){
                for (int i = 0; i < detailsList.length(); i++) {
                    String detailLangCode = detailsList.optJSONObject(i).optString("langue_code");
                    for (Language lang : langList) {
                        if (lang.code.equals(detailLangCode)) {
                            firstDetailIndex = i;
                            break; //match found
                        }
                    }
                    if(firstDetailIndex >= 0){
                        break;
                    }
                }

                if(firstDetailIndex < 0 ){
                    if(!isExisting){ // new
                        rollbackPage(id, Constant.PAGE_TYPE_FREEMARKER);
                    }
                    throw new Exception("Language codes of detail object are unfamiliar to this site");
                }
            }

            //process details pages
            for (Language lang : langList) {
                String langId = "" + lang.id;
                String langCode = lang.code;
                JSONObject pageObj2 = null;
                boolean insertRequiredFieldsOnly = false;

                if(isNewStructure){
                    JSONObject detailObj = null;

                    for (int i = 0; i < detailsList.length(); i++) {
                        JSONObject curDetailObj = detailsList.optJSONObject(i);
                        String detailLangCode = curDetailObj.optString("langue_code");
                        if (langCode.equals(detailLangCode)) {
                            detailObj = curDetailObj;
                            break; //match found
                        }
                    }

                    if (detailObj == null) {
                        // we will slp for this language
                        if(isExisting){
                            continue;
                        } else{
                            //if lang specific detail not found, use first detail lang obj
                            if(firstDetailIndex >= 0){
                                insertRequiredFieldsOnly = true;
                                detailObj = detailsList.getJSONObject(firstDetailIndex);
                            }
                        }
                    }

                    JSONObject pageSettings = detailObj.optJSONObject("page_settings");
                    if (pageSettings == null || pageSettings.isEmpty()) {
                        if(!isExisting){
                            rollbackPage(id, Constant.PAGE_TYPE_FREEMARKER);
                        }
                        throw new Exception("Error page settings not found for freemarker page detail. lang = " + langCode);
                    } else{
                        pageObj2 = new JSONObject(pageSettings.toMap());
                    }
                } else {
                    pageObj2 = itemObj;
                    String newPath = _path;
                    String pageLangcCode = pageObj2.getJSONObject("system_info").optString("langue_code");

                    q = "SELECT id FROM pages" +
                        " WHERE parent_page_id = "+escape.cote(id)+
                        " AND type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER) +
                        " AND langue_code = "+escape.cote(langCode);
                    rs = Etn.execute(q);

                    // if lang page exists in db but that lang page is not found in the josn then we will leave that page
                    if(!langCode.equals(pageLangcCode) && rs.next()){
                        continue;
                    }
                    // if lang page not exists in db and in json then we will create a new page against that lang
                    if(!langCode.equals(pageLangcCode) && !rs.next()){
                        int count = 1;
                        String variant = pageObj2.getJSONObject("system_info").getString("variant").trim();

                        do {
                            newPath =  _path + "-" + langCode + "-" + count;
                            q = "SELECT id FROM pages "
                                    + " WHERE path = " + escape.cote(newPath)
                                    + " AND langue_code = " + escape.cote(langCode)
                                    + " AND variant = " + escape.cote(variant)
                                    + " AND site_id = " + escape.cote(siteId);

                            rs = Etn.execute(q);
                            count++;
                        }
                        while (rs.next());
                    }
                    pageObj2.getJSONObject("system_info").put("path", newPath); // make path unique
                }

                pageObj2.put("item_type", "page");
                pageObj2.getJSONObject("system_info").put("langue_code", langCode);
                pageObj2.getJSONObject("system_info").put("name", name); //structured page name
                pageObj2.getJSONObject("system_info").put("folder_name", sysInfo.optString("folder_name"));
                pageObj2.getJSONObject("system_info").put("folder", sysInfo.optJSONObject("folder"));

                String pageAction = importItemPageSettings(pageObj2, importType, id, insertRequiredFieldsOnly,Constant.PAGE_TYPE_FREEMARKER,Constant.FOLDER_TYPE_PAGES);

                String pageId = pageObj2.getString("id");

                q = "SELECT id FROM pages "
                        + " WHERE id = " + escape.cote(pageId)
                        + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if (rs.next()) {
                    q = "UPDATE pages SET type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)+" WHERE id = " + escape.cote("" + PagesUtil.parseInt(rs.value("id")));
                    Etn.executeCmd(q);
                }
                else {
                    if(!isExisting){
                        rollbackPage(id, Constant.PAGE_TYPE_FREEMARKER);
                    }
                    throw new Exception("Error in page settings processing for Freemarker page detail. lang = " + langCode);
                }
            }//for langList
//            PagesGenerator pagesGen = new PagesGenerator(Etn);
//            String errorMsg = pagesGen.generateAndSaveBlocPage(id);
//            if (errorMsg.length() == 0) {
//                q = "UPDATE freemarker_pages SET to_generate = '0' WHERE id = " + escape.cote(id)
//                        + " AND is_deleted = '0'";
//
//                Etn.executeCmd(q);
//            }
            if (importDatetime && id.length() > 0) {
                //incase of import datetime
                //we generate page here and set to_generate flag = 0
                PagesGenerator pagesGen = new PagesGenerator(Etn);
                String errorMsg = pagesGen.generateAndSaveBlocPage(id);
                if (errorMsg.length() == 0) {
                    q = "UPDATE freemarker_pages SET to_generate = '0' WHERE id = " + escape.cote(id)
                    + " AND is_deleted = '0'";

                    Etn.executeCmd(q);
                }

                updateCreatedUpdatedTs(itemObj, "freemarker_pages", " WHERE id = " + escape.cote(id) +" AND is_deleted = '0'");
            }

        } catch (Exception ex){
            if(!isExisting){
                rollbackPage(id, Constant.PAGE_TYPE_FREEMARKER);
            }
            ex.printStackTrace();
        }
        return action;
    }

    protected String importItemStructuredContentGeneric(JSONObject itemObj, String importType,
                                                        String contentType) throws Exception {
        String contentId = "";
        boolean isExisting = false;
        try {
            this.isProcessingStructContent = true;
            String action = ""; //insert, update, skip
            String q;
            Set rs;

            List<Language> langList = PagesUtil.getLangs(Etn,siteId);
            boolean isPageContent = Constant.STRUCTURE_TYPE_PAGE.equals(contentType);

            JSONObject sysInfo = itemObj.getJSONObject("system_info");
            JSONArray detailsList = itemObj.optJSONArray("details");

            if (isPageContent) {
                if (detailsList == null || detailsList.length() < 1) {
                    throw new Exception("Error: Atleast 1 valid detail entry is required.");
                }
            }
            else {
                if (detailsList == null) {
                    detailsList = new JSONArray();
                }
            }

            String name = sysInfo.getString("name").trim();
            String templateCustomId = sysInfo.getString("template_id");

            
            String templateId = "";
            String templateType = "";
            String folderId = "0";

            q = "SELECT id, type FROM bloc_templates"
                + " WHERE custom_id = " + escape.cote(templateCustomId)
                + " AND site_id = " + escape.cote(siteId);
            rs = Etn.execute(q);
            if (rs.next()) {
                templateId = rs.value("id");
                templateType = rs.value("type");
            }
            else {
                throw new Exception("Invalid template_id : " + templateCustomId);
            }

            boolean isPageSettingOptional = Constant.TEMPLATE_STORE.equals(templateType);

            //set folderId
String folderType = "";
            JSONObject folderObj = sysInfo.optJSONObject("folder");
            if (folderObj != null && folderObj.optString("name").length() > 0) {
                ArrayList<JSONObject> foldersList = getFoldersList(folderObj);

                //add missing folders
                folderType = Constant.FOLDER_TYPE_CONTENTS;
                if (Constant.STRUCTURE_TYPE_PAGE.equals(contentType)) {
                    if (Constant.TEMPLATE_STORE.equals(templateType)) {
                        folderType = Constant.FOLDER_TYPE_STORE;
                    }
                    else {
                        folderType = Constant.FOLDER_TYPE_PAGES;
                    }
                }

                int lastParentId = 0;
                for (JSONObject curFolderObj : foldersList) {
                    String folderName = curFolderObj.getString("name");

                    q = "SELECT id FROM folders f"
                        + " WHERE site_id = " + escape.cote(siteId)
                        + " AND type = " + escape.cote(folderType)
                        + " AND name = " + escape.cote(folderName)
                        + " AND parent_folder_id = " + escape.cote("" + lastParentId);
                    rs = Etn.execute(q);
                    if (rs.next()) {
                        //folder already exist
                        folderId = rs.value("id");
                    }
                    else {
                        //folder does not exist, create it
                        folderId = PagesUtil.addFolder(Etn, curFolderObj, "" + lastParentId, folderType, siteId, pid);
                    }
                    lastParentId = PagesUtil.parseInt(folderId);
                }

            }

            q = "SELECT sc.id "
                + " FROM structured_contents sc "
                + " WHERE sc.name = " + escape.cote(name)
                + " AND sc.site_id = " + escape.cote(siteId)
                + " AND sc.folder_id = " + escape.cote(folderId);
            rs = Etn.execute(q);
            if (rs.next()) {
                contentId = rs.value("id");
                isExisting = true;
            }

            if (IMPORT_TYPE_KEEP.equals(importType)) {
                if (isExisting) {
                    action = "skip";
                    return action;
                }
                else {
                    action = "insert";
                }
            }
            else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
                if (isExisting) {
                    // assign a new name not existing already
                    int count = 2;
                    String newName = "";
                    do {
                        newName = name + " " + count;

                        q = "SELECT sc.id "
                            + " FROM structured_contents sc "
                            + " WHERE sc.name = " + escape.cote(newName)
                            + " AND sc.site_id = " + escape.cote(siteId)
                            + " AND sc.folder_id = " + escape.cote(folderId);

                        rs = Etn.execute(q);
                        count++;
                    }
                    while (rs.next());

                    name = newName;
                    action = "insert";
                }
                else {
                    action = "insert";
                }
            }
            else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
                if (isExisting) {
                    //clear original data

                    q = "UPDATE structured_contents_details scd "
                        + " SET content_data = '{}' "
                        + " WHERE content_id = " + escape.cote(contentId);
                    Etn.executeCmd(q);

                    action = "update";
                }
                else {
                    action = "insert";
                }
            }
            else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                if (isExisting) {
                    action = "update";
                }
                else {
                    action = "insert";
                }
            }

            HashMap<String, String> colValueHM = new HashMap<>();

            colValueHM.put("name", escape.cote(name));

            colValueHM.put("updated_by", escape.cote("" + pid));
            colValueHM.put("updated_ts", "NOW()");

            if (isPageContent) {
                colValueHM.put("to_generate", "'1'");
                colValueHM.put("to_generate_by", escape.cote("" + pid));
            }

            if ("insert".equals(action)) {
                colValueHM.put("site_id", escape.cote(siteId));
                colValueHM.put("type", escape.cote(contentType));
                colValueHM.put("template_id", escape.cote(templateId));
                colValueHM.put("folder_id", escape.cote(folderId));

                colValueHM.put("created_ts", "NOW()");
                colValueHM.put("created_by", escape.cote("" + pid));

                q = PagesUtil.getInsertQuery("structured_contents", colValueHM);
                int newId = Etn.executeCmd(q);
                if (newId <= 0) {
                    throw new Exception("Error in inserting structured content record");
                }
                else {
                    contentId = "" + newId;
                }
            }
            else if ("update".equals(action)) {

                q = PagesUtil.getUpdateQuery("structured_contents", colValueHM, " WHERE id = " + escape.cote(contentId));

                int upCount = Etn.executeCmd(q);
                if (upCount <= 0) {
                    throw new Exception("Error in updating structured content record");
                }

            }//else update

            itemObj.put("id", contentId);

            int firstDetailIndex = -1;
            for (int i = 0; i < detailsList.length(); i++) {
                String detailLangCode = detailsList.optJSONObject(i).optString("langue_code");
                for (Language lang : langList) {
                    if (lang.code.equals(detailLangCode)) {
                        firstDetailIndex = i;

                        break; //match found
                    }
                }
                if(firstDetailIndex >= 0){
                    break;
                }
            }

            if(firstDetailIndex < 0 ){
                if(isPageContent){ // structured page
                    if(!isExisting) // new
                        rollbackPage(contentId, Constant.PAGE_TYPE_STRUCTURED);
                    throw new Exception("Language codes of detail object are unfamiliar to this site");
                }
            }

            //process content details
            for (Language lang : langList) {

                String langId = "" + lang.id;
                String langCode = lang.code;
                boolean insertRequiredFieldsOnly = false;

                JSONObject detailObj = null;
                for (int i = 0; i < detailsList.length(); i++) {
                    JSONObject curDetailObj = detailsList.optJSONObject(i);
                    String detailLangCode = curDetailObj.optString("langue_code");
                    if (langCode.equals(detailLangCode)) {
                        detailObj = curDetailObj;
                        break; //match found
                    }
                }

                if (detailObj == null) {
                    if (isPageContent) {
                        if(isExisting){ // for the case of replace we will skip this item
                            continue;
                        } else{ // for new/ inserting case we will add this language item cloning the first matched lang detail item obj
                            insertRequiredFieldsOnly = true;
                            detailObj = detailsList.getJSONObject(firstDetailIndex);
                        }
                    }
                    else {
                        detailObj = new JSONObject();
                    }
                }

                String detailId = "";
                q = "SELECT id FROM structured_contents_details scd "
                    + " WHERE content_id = " + escape.cote(contentId)
                    + " AND langue_id = " + escape.cote(langId);
                rs = Etn.execute(q);
                if (rs.next()) {
                    detailId = rs.value("id");
                }

                int detailPageId = 0;
                JSONObject contentDataObj = detailObj.optJSONObject("template_data");

                if (isPageContent) {
                    JSONObject pageSettings = detailObj.optJSONObject("page_settings");
                    if (pageSettings == null || pageSettings.isEmpty()) {
                        //page is optional for store type
                        if (!isPageSettingOptional) {
                            if(!isExisting){
                                rollbackPage(contentId, Constant.PAGE_TYPE_STRUCTURED);
                            }
                            throw new Exception("Error page settings not found for structured page detail. lang = " + langCode);
                        }
                    }
                    else {
                        JSONObject pageObj2 = new JSONObject(pageSettings.toMap());
                        pageObj2.put("item_type", "page");
                        pageObj2.getJSONObject("system_info").put("langue_code", langCode);
                        pageObj2.getJSONObject("system_info").put("name", name); //structured page name
                        pageObj2.getJSONObject("system_info").put("folder_name", sysInfo.optString("folder_name"));
                        pageObj2.getJSONObject("system_info").put("folder", sysInfo.optJSONObject("folder"));

                        String pageAction = importItemPageSettings(pageObj2, importType, contentId, insertRequiredFieldsOnly,"structured",folderType);

                        String pageId = pageObj2.getString("id");

                        q = "SELECT id FROM pages "
                            + " WHERE id = " + escape.cote(pageId)
                            + " AND site_id = " + escape.cote(siteId);

                        rs = Etn.execute(q);
                        if (rs.next()) {
                            detailPageId = PagesUtil.parseInt(rs.value("id"));

                            q = "UPDATE pages SET type = 'structured' WHERE id = " + escape.cote("" + detailPageId);
                            Etn.executeCmd(q);
                        }
                        else {
                            if(!isExisting){
                                rollbackPage(contentId, Constant.PAGE_TYPE_STRUCTURED);
                            }
                            throw new Exception("Error in page settings processing for structured page detail. lang = " + langCode);
                        }
                    }
                }

                colValueHM.clear();
                colValueHM.put("page_id", escape.cote("" + detailPageId));

                if (detailId.length() == 0) {
                    //insert

                    if (contentDataObj == null || insertRequiredFieldsOnly) {
                        contentDataObj = new JSONObject();
                    }
                    JSONObject dataObj = getBlocTemplateDataJson(templateId, contentDataObj, langId);

                    String contentData = dataObj.toString();

                    colValueHM.put("content_id", escape.cote(contentId));
                    colValueHM.put("langue_id", escape.cote(langId));
                    colValueHM.put("content_data", escape.cote(PagesUtil.encodeJSONStringDB(contentData)));

                    q = PagesUtil.getInsertQuery("structured_contents_details", colValueHM);
                    int newId = Etn.executeCmd(q);
                    if (newId <= 0) {
                        if(!isExisting){
                            rollbackPage(contentId, Constant.PAGE_TYPE_STRUCTURED);
                        }
                        throw new Exception("Error in inserting content detail record. lang:" + langCode);
                    }
                }
                else {
                    //update
                    if (contentDataObj != null || !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                        //only update if content data was provided , or replace full
                        if (contentDataObj == null) {
                            contentDataObj = new JSONObject();
                        }
                        JSONObject dataObj = getBlocTemplateDataJson(templateId, contentDataObj, langId);
                        String contentData = dataObj.toString();
                        colValueHM.put("content_data", escape.cote(PagesUtil.encodeJSONStringDB(contentData)));
                    }

                    q = PagesUtil.getUpdateQuery("structured_contents_details", colValueHM, " WHERE id = " + escape.cote(detailId));

                    int upCount = Etn.executeCmd(q);
                    if (upCount <= 0) {
                        if(!isExisting){
                            rollbackPage(contentId, Constant.PAGE_TYPE_STRUCTURED);
                        }
                        throw new Exception("Error in updating content detail record. lang:" + langCode);
                    }
                }

            }//for langList
//            if (isPageContent) {
//                //incase of import datetime
//                //we generate page here and set to_generate flag = 0
//                PagesGenerator pagesGen = new PagesGenerator(Etn);
//                String errorMsg = pagesGen.generateAndSaveStructuredPage(contentId);
//                if (errorMsg.length() == 0) {
//                    q = "UPDATE structured_contents SET to_generate = '0' WHERE id = " + escape.cote(contentId);
//                    Etn.executeCmd(q);
//                }
//            }
            if (importDatetime && contentId.length() > 0) {
                if (isPageContent) {
                    //incase of import datetime
                    //we generate page here and set to_generate flag = 0
                    PagesGenerator pagesGen = new PagesGenerator(Etn);
                    String errorMsg = pagesGen.generateAndSaveStructuredPage(contentId);
                    if (errorMsg.length() == 0) {
                        q = "UPDATE structured_contents SET to_generate = '0' WHERE id = " + escape.cote(contentId);
                        Etn.executeCmd(q);
                    }
                }

                updateCreatedUpdatedTs(itemObj, "structured_contents", " WHERE id = " + escape.cote(contentId));
            }

            return action;
        }
        catch (Exception ex){
            if(!isExisting){
                System.out.println("Rolling back for store========="+contentId);
                rollbackPage(contentId, Constant.PAGE_TYPE_STRUCTURED);
            }
            ex.printStackTrace();
            throw new Exception(ex.getMessage());
        }
        finally {
            this.isProcessingStructContent = false;
        }
    }


    public String importItemCommercialCatalog(JSONObject itemObj, String importType) throws Exception {
        String action = ""; //insert, update, skip

        String q = "";
        Set rs = null;

        String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");

        JSONObject sysInfo = itemObj.getJSONObject("system_info");

        JSONObject detailsObj = itemObj.optJSONObject("details");
        JSONArray detailsLangList = itemObj.optJSONArray("details_lang");
        JSONArray attributesList = itemObj.optJSONArray("catalog_attributes");
        JSONArray foldersList = itemObj.optJSONArray("folders");


        //init optional (null) variables
        detailsObj = (detailsObj != null) ? detailsObj : (new JSONObject());
        detailsLangList = (detailsLangList != null) ? detailsLangList : (new JSONArray());
        attributesList = (attributesList != null) ? attributesList : (new JSONArray());
        foldersList = (foldersList != null) ? foldersList : (new JSONArray());

        String name = sysInfo.getString("name").trim();
        String catalog_uuid = sysInfo.getString("uuid").trim();
        String catalog_type = sysInfo.getString("type").trim();

        List<Language> langList = PagesUtil.getLangs(Etn,siteId);

        q = "SELECT 1 FROM " + CATALOG_DB + ".catalog_types "
            + " WHERE value = " + escape.cote(catalog_type);
        rs = Etn.execute(q);
        if (!rs.next()) {
            throw new Exception("Invalid catalog type : " + catalog_type);
        }

        boolean isExisting = false;
        String catalogId = "";

        q = "SELECT id FROM " + CATALOG_DB + ".catalogs "
            + " WHERE catalog_uuid = " + escape.cote(catalog_uuid)
            + " AND site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);
        if (rs.next()) {
            catalogId = rs.value("id");
            isExisting = true;
        }

        int productCount = 0;
        if (isExisting) {
            q = "SELECT COUNT(0) AS num FROM " + CATALOG_DB + ".products "
                + " WHERE catalog_id = " + escape.cote(catalogId);
            Set prodRs = Etn.execute(q);
            if (prodRs.next()) {
                productCount = PagesUtil.parseInt(prodRs.value("num"));
            }
        }


        if (IMPORT_TYPE_KEEP.equals(importType)) {
            if (isExisting) {
                action = "skip";
                return action;
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
            if (isExisting) {
                // assign a new name not existing already
                int count = 2;
                String newName = "";
                do {
                    newName = name + " " + count;
                    q = "SELECT id FROM " + CATALOG_DB + ".catalogs "
                        + " WHERE name = " + escape.cote(newName)
                        + " AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);
                    count++;
                }
                while (rs.next());

                name = newName;
                catalog_uuid = UUID.randomUUID().toString();

                action = "insert";

            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
            if (isExisting) {
                //delete all original data and "NOT" its associations

                q = "DELETE FROM " + CATALOG_DB + ".catalog_descriptions WHERE catalog_id = " + escape.cote(catalogId);
                Etn.executeCmd(q);

                q = "DELETE FROM " + CATALOG_DB + ".catalog_essential_blocks WHERE catalog_id = " + escape.cote(catalogId);
                Etn.executeCmd(q);

                if (productCount == 0) {
                    //delete catalog attributes only if no products
                    q = "DELETE cav FROM " + CATALOG_DB + ".catalog_attribute_values cav "
                        + " JOIN " + CATALOG_DB + ".catalog_attributes ca ON ca.cat_attrib_id = cav.cat_attrib_id "
                        + " WHERE ca.catalog_id  = " + escape.cote(catalogId);
                    Etn.executeCmd(q);

                    q = "DELETE FROM " + CATALOG_DB + ".catalog_attributes WHERE catalog_id = " + escape.cote(catalogId);
                    Etn.executeCmd(q);

                }

                action = "update";
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
            if (isExisting) {
                action = "update";
            }
            else {
                action = "insert";
            }
        }

        HashMap<String, String> colValueHM = new HashMap<>();

        colValueHM.clear();


        colValueHM.put("name", escape.cote(name));
        colValueHM.put("catalog_type", escape.cote(catalog_type));

        colValueHM.put("updated_by", escape.cote("" + pid));
        colValueHM.put("updated_on", "NOW()");

        java.util.Set<String> excludedCols = EntityExport.getCatalogExcludedColumns();
        for (String colName : detailsObj.keySet()) {
            if (!excludedCols.contains(colName)) {
                colValueHM.put(colName, escape.cote(detailsObj.getString(colName)));
            }
        }

        //get column names of table
        rs = Etn.execute("SELECT * FROM " + CATALOG_DB + ".catalogs WHERE 1 = 0");
        java.util.Set<String> catTableCols = Arrays.stream(rs.ColName).parallel()
            .map(String::toLowerCase).collect(Collectors.toSet());

        for (int i = 0; i < detailsLangList.length(); i++) {
            JSONObject curDetailsObj = detailsLangList.optJSONObject(i);
            String detailLangCode = curDetailsObj.optString("langue_code", "");
            String langId = null;
            for (Language curLang : langList) {
                if (curLang.code.equals(detailLangCode)) {
                    langId = "" + curLang.id;
                    break; //match found
                }
            }

            if (langId == null) {
                continue; //skip
            }

            for (String keyName : curDetailsObj.keySet()) {

                //skip objects , non string
                if ("langue_code".equals(keyName)
                    || curDetailsObj.get(keyName) instanceof JSONObject
                    || curDetailsObj.get(keyName) instanceof JSONArray) {

                    continue;//skip
                }

                String colName = "lang_" + langId + "_" + keyName;
                if ("essentials_alignment".equals(keyName)) {
                    colName = keyName + "_lang_" + langId;
                }

                if (catTableCols.contains(colName)) {
                    colValueHM.put(colName, escape.cote(curDetailsObj.getString(keyName)));
                }
            }

        }


        if ("insert".equals(action)) {

            colValueHM.put("catalog_uuid", escape.cote(catalog_uuid));
            colValueHM.put("created_on", "NOW()");
            colValueHM.put("created_by", escape.cote("" + pid));
            colValueHM.put("site_id", escape.cote(siteId));

            q = PagesUtil.getInsertQuery(CATALOG_DB + ".catalogs", colValueHM);

            int newCatalogId = Etn.executeCmd(q);
            if (newCatalogId <= 0) {
                throw new Exception("Error in inserting catalogs record");
            }
            else {
                catalogId = "" + newCatalogId;
            }
        }
        else if ("update".equals(action)) {
            q = PagesUtil.getUpdateQuery(CATALOG_DB + ".catalogs", colValueHM, " WHERE id = " + escape.cote(catalogId));
            int upCount = Etn.executeCmd(q);
            if (upCount <= 0) {
                throw new Exception("Error in updating catalogs record");
            }
        }

        if (importDatetime && catalogId.length() > 0) {
            updateCreatedUpdatedTs(itemObj, CATALOG_DB + ".catalogs", " WHERE id = " + escape.cote(catalogId), "on");
        }

        //catalog_descriptions
        for (Language lang : langList) {

            String langId = "" + lang.id;
            String langCode = lang.code;
            JSONObject detailLangObj = null;
            for (int i = 0; i < detailsLangList.length(); i++) {
                JSONObject curObj = detailsLangList.optJSONObject(i);
                if (curObj != null && langCode.equals(curObj.optString("langue_code"))) {
                    detailLangObj = curObj;
                    break;
                }
            }

            if (detailLangObj == null) {
                //lang not found => skip
                continue;
            }

            //description block
            {
                JSONObject descObj = detailLangObj.optJSONObject("description_tbl");
                if (descObj == null) {
                    descObj = new JSONObject();
                }

                q = "SELECT 1 FROM " + CATALOG_DB + ".catalog_descriptions "
                    + " WHERE catalog_id = " + escape.cote(catalogId)
                    + " AND langue_id = " + escape.cote(langId);
                rs = Etn.execute(q);

                if (rs.next()) {

                    colValueHM.clear();
                    if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                        //dont update if import type is partial and no value provided
                        if (descObj.optString("page_path") != null) {
                            colValueHM.put("page_path", escape.cote(descObj.optString("page_path")));
                        }

                        if (descObj.optString("canonical_url") != null) {
                            colValueHM.put("canonical_url", escape.cote(descObj.optString("canonical_url")));
                        }

                        if (descObj.optString("folder_name") != null) {
                            colValueHM.put("folder_name", escape.cote(descObj.optString("folder_name")));
                        }

                        if (descObj.optString("page_template_cstm_id") != null) {
                            colValueHM.put("page_template_id", pageTemplateId(descObj.optString("page_template_cstm_id"),"catalog"));
                        }
                    }
                    else {
                        colValueHM.put("page_path", escape.cote(descObj.optString("page_path", "")));
                        colValueHM.put("canonical_url", escape.cote(descObj.optString("canonical_url", "")));
                        colValueHM.put("folder_name", escape.cote(descObj.optString("folder_name", "")));
                        colValueHM.put("page_template_id", pageTemplateId(PagesUtil.parseNull(descObj.optString("page_template_cstm_id")),"catalog"));
                    }
                    //description exists update

                    if (!colValueHM.isEmpty()) {
                        q = PagesUtil.getUpdateQuery(CATALOG_DB + ".catalog_descriptions ", colValueHM,
                                                     " WHERE catalog_id = " + escape.cote(catalogId) + " AND langue_id = " + escape.cote(langId));
                    }

                }
                else {
                    //insert

                    colValueHM.clear();
                    colValueHM.put("page_path", escape.cote(descObj.optString("page_path", "")));
                    colValueHM.put("canonical_url", escape.cote(descObj.optString("canonical_url", "")));
                    colValueHM.put("folder_name", escape.cote(descObj.optString("folder_name", "")));
                    colValueHM.put("page_template_id", pageTemplateId(PagesUtil.parseNull(descObj.optString("page_template_cstm_id")),"catalog"));

                    colValueHM.put("catalog_id", escape.cote(catalogId));
                    colValueHM.put("langue_id", escape.cote(langId));


                    q = PagesUtil.getInsertQuery(CATALOG_DB + ".catalog_descriptions ", colValueHM);
                    Etn.executeCmd(q);
                }
            }

            //essential block
            {
                JSONArray essentialBlocksList = detailLangObj.optJSONArray("essential_blocks");
                if (essentialBlocksList != null) {
                    for (int i = 0; i < essentialBlocksList.length(); i++) {
                        JSONObject essentialObj = essentialBlocksList.optJSONObject(i);

                        //only update or insert if there is an object in json, as this is optional
                        if (essentialObj == null) {
                            continue;
                        }

                        String essentialBlockId = "";
                        q = "SELECT id FROM " + CATALOG_DB + ".catalog_essential_blocks "
                            + " WHERE catalog_id = " + escape.cote(catalogId)
                            + " AND langue_id = " + escape.cote(langId)
                            + " AND order_seq = " + escape.cote(essentialObj.optString("order_seq", ""))
                            + " AND file_name = " + escape.cote(essentialObj.optString("file_name", ""))
                            + " AND block_text = " + escape.cote(essentialObj.optString("block_text", ""));

                        rs = Etn.execute(q);
                        if (rs.next()) {
                            essentialBlockId = rs.value("id");
                        }

                        colValueHM.clear();
                        colValueHM.put("block_text", escape.cote(essentialObj.optString("block_text", "")));
                        colValueHM.put("order_seq", escape.cote(essentialObj.optString("order_seq", "")));
                        colValueHM.put("file_name", escape.cote(essentialObj.optString("file_name", "")));
                        colValueHM.put("actual_file_name", escape.cote(essentialObj.optString("actual_file_name", "")));
                        colValueHM.put("image_label", escape.cote(essentialObj.optString("image_label", "")));

                        if (essentialBlockId.length() == 0) {
                            //insert
                            colValueHM.put("catalog_id", escape.cote(catalogId));
                            colValueHM.put("langue_id", escape.cote(langId));

                            q = PagesUtil.getInsertQuery(CATALOG_DB + ".catalog_essential_blocks ", colValueHM);
                            Etn.executeCmd(q);

                        }
                        else {
                            if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                                //dont update if import type is partial and no value provided
                                colValueHM.clear();
                                if (essentialObj.optString("block_text") != null) {
                                    colValueHM.put("block_text", escape.cote(essentialObj.optString("block_text")));
                                }

                                if (essentialObj.optString("order_seq") != null) {
                                    colValueHM.put("order_seq", escape.cote(essentialObj.optString("order_seq")));
                                }

                                if (essentialObj.optString("file_name") != null) {
                                    colValueHM.put("file_name", escape.cote(essentialObj.optString("file_name")));
                                }

                                if (essentialObj.optString("actual_file_name") != null) {
                                    colValueHM.put("actual_file_name", escape.cote(essentialObj.optString("actual_file_name")));
                                }

                                if (essentialObj.optString("image_label") != null) {
                                    colValueHM.put("image_label", escape.cote(essentialObj.optString("image_label")));
                                }
                            }

                            if (!colValueHM.isEmpty()) {
                                q = PagesUtil.getUpdateQuery(CATALOG_DB + ".catalog_essential_blocks ", colValueHM,
                                                             " WHERE id = " + escape.cote(essentialBlockId));
                            }
                        }

                    }
                }

            }//essential block

        }//for langList


        for (int i = 0; i < attributesList.length(); i++) {
            try {
                JSONObject curAttribObj = attributesList.getJSONObject(i);
                String attribName = curAttribObj.getString("name");
                String attribType = curAttribObj.getString("type");

                String attribId = "";
                q = "SELECT cat_attrib_id FROM " + CATALOG_DB + ".catalog_attributes "
                    + " WHERE catalog_id = " + escape.cote(catalogId)
                    + " AND name = " + escape.cote(attribName)
                    + " AND type = " + escape.cote(attribType);
                rs = Etn.execute(q);
                if (rs.next()) {
                    attribId = rs.value("cat_attrib_id");
                }

                colValueHM.clear();
                colValueHM.put("visible_to", escape.cote(curAttribObj.optString("visible_to", "all")));
                colValueHM.put("sort_order", escape.cote(curAttribObj.optString("sort_order", "0")));
                colValueHM.put("migration_name", escape.cote(curAttribObj.optString("migration_name", "0")));
                colValueHM.put("is_searchable", escape.cote(curAttribObj.optString("is_searchable", "0")));
                colValueHM.put("value_type", escape.cote(curAttribObj.optString("value_type", "text")));
                colValueHM.put("is_fixed", escape.cote(curAttribObj.optString("is_fixed", "0")));

                if (attribId.length() == 0) {
                    //attrib insert
                    colValueHM.put("catalog_id", escape.cote(catalogId));
                    colValueHM.put("name", escape.cote(attribName));
                    colValueHM.put("type", escape.cote(attribType));

                    q = PagesUtil.getInsertQuery(CATALOG_DB + ".catalog_attributes ", colValueHM);
                    int newAttribId = Etn.executeCmd(q);

                    if (newAttribId > 0) {
                        attribId = "" + newAttribId;
                    }

                }
                else {
                    //attrib update

                    q = PagesUtil.getUpdateQuery(CATALOG_DB + ".catalog_attributes ", colValueHM,
                                                 " WHERE cat_attrib_id = " + escape.cote(attribId));
                    Etn.executeCmd(q);
                }

                if ("selection".equals(attribType) && attribId.length() > 0) {
                    JSONArray attribValueList = curAttribObj.optJSONArray("catalog_attribute_values");
                    if (attribValueList != null) {
                        for (int j = 0; j < attribValueList.length(); j++) {
                            JSONObject attribValueObj = attribValueList.getJSONObject(j);

                            colValueHM.clear();
                            colValueHM.put("cat_attrib_id", escape.cote(attribId));
                            colValueHM.put("attribute_value", escape.cote(attribValueObj.optString("attribute_value", "No Value")));
                            colValueHM.put("small_text", escape.cote(attribValueObj.optString("small_text", "")));
                            colValueHM.put("color", escape.cote(attribValueObj.optString("color", "")));
                            colValueHM.put("sort_order", escape.cote(attribValueObj.optString("sort_order", "0")));

                            q = PagesUtil.getInsertQuery(CATALOG_DB + ".catalog_attribute_values ", colValueHM);

                            q += " ON DUPLICATE KEY UPDATE small_text=VALUES(small_text), color=VALUES(color), sort_order=VALUES(sort_order) ";

                            Etn.executeCmd(q);

                        }

                    }
                }

            }
            catch (Exception attribEx) {
                attribEx.printStackTrace();
            }

        }

        //folders
        String folderTable = CATALOG_DB + ".products_folders";
        for (int i = 0; i < foldersList.length(); i++) {
            JSONObject folderObj = foldersList.optJSONObject(i);
            if (folderObj == null) continue;
            addCatalogFolder(folderTable, folderObj, catalogId, "0", 1);

        }

        return action;

    }

    protected int addCatalogFolder(String folderTable, JSONObject folderObj, String catalogId,
                                   String parentFolderId, int parentFolderLevel) {

        int folderId = -1;
        int folderLevel = parentFolderLevel + 1;
        if (folderLevel > 3) {
            //folder level > 3 is not allowed
            return folderId;
        }

        String folderName = folderObj.getString("name");
        String q = "SELECT id, folder_level FROM " + folderTable
                   + " WHERE site_id = " + escape.cote(siteId)
                   + " AND name = " + escape.cote(folderName)
                   + " AND catalog_id = " + escape.cote(catalogId)
                   + " AND parent_folder_id = " + escape.cote(parentFolderId);
        Set rs = Etn.execute(q);
        if (rs.next()) {
            folderId = PagesUtil.parseInt(rs.value("id"));
            folderLevel = PagesUtil.parseInt(rs.value("folder_level"));
        }
        else {
            try {

                LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();
                colValueHM.put("name", escape.cote(folderName));
                colValueHM.put("site_id", escape.cote(siteId));
                colValueHM.put("catalog_id", escape.cote(catalogId));
                colValueHM.put("parent_folder_id", escape.cote(parentFolderId));
                colValueHM.put("folder_level", escape.cote("" + folderLevel));
                colValueHM.put("created_by", escape.cote("" + pid));
                colValueHM.put("updated_by", escape.cote("" + pid));

                q = PagesUtil.getInsertQuery(folderTable, colValueHM);
                folderId = Etn.executeCmd(q);

                q = "INSERT INTO " + folderTable + "_details(folder_id, langue_id, path_prefix) "
                    + " SELECT " + escape.cote("" + folderId) + " ,l.langue_id, '' FROM language l";
                Etn.executeCmd(q);
                if (folderObj.optJSONArray("details") != null) {
                    JSONArray details = folderObj.getJSONArray("details");
                    for (int i = 0; i < details.length(); i++) {
                        JSONObject detailObj = details.optJSONObject(i);
                        if (detailObj != null && detailObj.has("langue_code")) {
                            q = "UPDATE " + folderTable + "_details fd "
                                + " JOIN language l ON l.langue_id = fd.langue_id"
                                + " SET fd.path_prefix = " + escape.cote(detailObj.optString("path_prefix"))
                                + " WHERE fd.folder_id = " + escape.cote("" + folderId)
                                + " AND l.langue_code = " + escape.cote(detailObj.optString("langue_code"));
                            Etn.executeCmd(q);
                        }
                    }
                }

            }
            catch (Exception ex) {
                Logger.debug("Error in creating folder " + folderName + ": " + Etn.getLastError());
            }
        }

        if (folderId >= 0 && folderLevel <= 2 && folderObj.optJSONArray("folders") != null) {
            //process child folders
            JSONArray childFolders = folderObj.optJSONArray("folders");
            for (int i = 0; i < childFolders.length(); i++) {
                JSONObject childFolderObj = childFolders.optJSONObject(i);
                addCatalogFolder(folderTable, childFolderObj, catalogId, "" + folderId, folderLevel);
            }
        }

        return folderId;
    }

    public String importItemCommercialProduct(JSONObject itemObj, String importType) throws Exception {
        String action = ""; //insert, update, skip

        String q = "";
        Set rs = null;

        String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");

        JSONObject sysInfo = itemObj.getJSONObject("system_info");

        JSONArray variantsList = itemObj.getJSONArray("variants"); //required

        JSONObject detailsObj = itemObj.optJSONObject("details");
        JSONArray detailsLangList = itemObj.optJSONArray("details_lang");
        JSONArray attributesList = itemObj.optJSONArray("attributes");
        JSONArray tagsList = itemObj.optJSONArray("tags");

        //init optional (null) variables
        detailsObj = (detailsObj != null) ? detailsObj : (new JSONObject());
        detailsLangList = (detailsLangList != null) ? detailsLangList : (new JSONArray());
        attributesList = (attributesList != null) ? attributesList : (new JSONArray());
        tagsList = (tagsList != null) ? tagsList : (new JSONArray());

        List<Language> langList = PagesUtil.getLangs(Etn,siteId);

        String name = sysInfo.getString("name").trim();
        String product_uuid = sysInfo.getString("uuid").trim();
        String catalog_uuid = sysInfo.getString("catalog_uuid").trim();
        String catalogId = "";

        if (targetCatalogId.length() > 0) {
            catalog_uuid = targetCatalogId;
        }

        q = "SELECT id FROM " + CATALOG_DB + ".catalogs "
            + " WHERE catalog_uuid = " + escape.cote(catalog_uuid)
            + " AND site_id = " + escape.cote(siteId);
        rs = Etn.execute(q);
        if (rs.next()) {
            catalogId = rs.value("id");
        }
        else {
            throw new Exception("Invalid catalog id");
        }

        boolean isExisting = false;
        String productId = "";

        q = "SELECT id FROM " + CATALOG_DB + ".products "
            + " WHERE product_uuid = " + escape.cote(product_uuid)
            + " AND catalog_id = " + escape.cote(catalogId);
        rs = Etn.execute(q);
        if (rs.next()) {
            productId = rs.value("id");
            isExisting = true;
        }

        if (IMPORT_TYPE_KEEP.equals(importType)) {
            if (isExisting) {
                action = "skip";
                return action;
            }
            else {
                action = "insert";
                product_uuid = UUID.randomUUID().toString();
            }
        }
        else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
            if (isExisting) {
                // assign a new name not existing already
                int count = 2;
                String newName = "";
                do {
                    newName = name + " " + count;
                    q = "SELECT id FROM " + CATALOG_DB + ".products "
                        + " WHERE lang_1_name = " + escape.cote(newName)
                        + " AND catalog_id = " + escape.cote(catalogId);

                    rs = Etn.execute(q);
                    count++;
                }
                while (rs.next());

                name = newName;
                product_uuid = UUID.randomUUID().toString();

                action = "insert";

            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
            if (isExisting) {
                //delete all original data and "NOT" its associations

                q = "DELETE FROM " + CATALOG_DB + ".product_descriptions WHERE product_id = " + escape.cote(productId);
                Etn.executeCmd(q);

                q = "DELETE FROM " + CATALOG_DB + ".product_essential_blocks WHERE product_id = " + escape.cote(productId);
                Etn.executeCmd(q);

                q = "DELETE FROM " + CATALOG_DB + ".product_attribute_values WHERE product_id = " + escape.cote(productId);
                Etn.executeCmd(q);

                q = "DELETE FROM " + CATALOG_DB + ".product_images WHERE product_id = " + escape.cote(productId);
                Etn.executeCmd(q);

                q = "DELETE FROM " + CATALOG_DB + ".product_tabs WHERE product_id = " + escape.cote(productId);
                Etn.executeCmd(q);

                q = "DELETE FROM " + CATALOG_DB + ".product_tags WHERE product_id = " + escape.cote(productId);
                Etn.executeCmd(q);

                q = "DELETE pvd FROM " + CATALOG_DB + ".product_variant_details pvd "
                    + " JOIN " + CATALOG_DB + ".product_variants pv ON pv.id = pvd.product_variant_id "
                    + " WHERE pv.product_id  = " + escape.cote(productId);
                Etn.executeCmd(q);

                q = "DELETE pvr FROM " + CATALOG_DB + ".product_variant_ref pvr "
                    + " JOIN " + CATALOG_DB + ".product_variants pv ON pv.id = pvr.product_variant_id "
                    + " WHERE pv.product_id  = " + escape.cote(productId);
                Etn.executeCmd(q);

                q = "DELETE pvr FROM " + CATALOG_DB + ".product_variant_resources pvr "
                    + " JOIN " + CATALOG_DB + ".product_variants pv ON pv.id = pvr.product_variant_id "
                    + " WHERE pv.product_id  = " + escape.cote(productId);
                Etn.executeCmd(q);

                action = "update";
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
            if (isExisting) {
                action = "update";
            }
            else {
                action = "insert";
            }
        }

        HashMap<String, String> colValueHM = new HashMap<>();

        //set folderId
        String folderId = "0";
        JSONObject folderObj = sysInfo.optJSONObject("folder");
        if (folderObj != null && folderObj.optString("name").length() > 0) {
            ArrayList<JSONObject> foldersList = getFoldersList(folderObj);

            int lastParentId = 0;
            int folderLevel = 1;
            for (JSONObject curFolderObj : foldersList) {
                String folderName = curFolderObj.getString("name");

                q = "SELECT id FROM " + CATALOG_DB + ".products_folders f"
                    + " WHERE site_id = " + escape.cote(siteId)
                    + " AND catalog_id = " + escape.cote(catalogId)
                    + " AND name = " + escape.cote(folderName)
                    + " AND parent_folder_id = " + escape.cote("" + lastParentId);
                rs = Etn.execute(q);
                if (rs.next()) {
                    //folder already exist
                    folderId = rs.value("id");
                }
                else {
                    //folder does not exist, create it
                    String folderTable = CATALOG_DB + ".products_folders";
                    int newFolderId = addCatalogFolder(folderTable, folderObj, catalogId, "" + lastParentId, folderLevel);
                    if (newFolderId <= 0) {
                        throw new Exception("Error in creating folder " + folderName);
                    }
                    folderId = String.valueOf(newFolderId);
                    folderLevel++;
                }
                lastParentId = PagesUtil.parseInt(folderId);
            }

        }

        //for insert/update products table record
        colValueHM.clear();
        java.util.Set<String> excludedCols = new HashSet<>(EntityExport.getCatalogExcludedColumns());
        excludedCols.add("product_uuid");
        excludedCols.add("catalog_id");
        excludedCols.add("folder_id");
        excludedCols.add("folder_name");
        excludedCols.add("folder_uuid");

        for (String colName : detailsObj.keySet()) {
            if (!excludedCols.contains(colName) && !"catalog_id".equals(colName)) {
                colValueHM.put(colName, escape.cote(detailsObj.getString(colName)));
            }
        }

        for (int i = 0; i < detailsLangList.length(); i++) {
            JSONObject curDetailsObj = detailsLangList.optJSONObject(i);
            String detailLangCode = curDetailsObj.optString("langue_code", "");
            String langId = null;
            for (Language curLang : langList) {
                if (curLang.code.equals(detailLangCode)) {
                    langId = "" + curLang.id;
                    break; //match found
                }
            }

            if (langId == null) {
                continue; //skip
            }

            for (String keyName : curDetailsObj.keySet()) {

                if ("langue_code".equals(keyName)
                    || curDetailsObj.get(keyName) instanceof JSONObject
                    || curDetailsObj.get(keyName) instanceof JSONArray) {
                    continue;//skip
                }

                String colName = "lang_" + langId + "_" + keyName;

                colValueHM.put(colName, escape.cote(curDetailsObj.getString(keyName)));
            }

        }

        colValueHM.put("lang_1_name", escape.cote(name));

        colValueHM.put("updated_by", escape.cote(pid+""));
        colValueHM.put("updated_on", "NOW()");
        colValueHM.put("catalog_id", escape.cote(catalogId));

        if ("insert".equals(action)) {

            colValueHM.put("folder_id", folderId);
            colValueHM.put("product_uuid", escape.cote(product_uuid));
            colValueHM.put("created_on", "NOW()");
            colValueHM.put("created_by", escape.cote(pid+""));
            colValueHM.remove("id");

            q = PagesUtil.getInsertQuery(CATALOG_DB + ".products", colValueHM);

            int newProductId = Etn.executeCmd(q);
            if (newProductId <= 0) {
                throw new Exception("Error in inserting product record");
            }
            else {
                productId = "" + newProductId;
            }
        }
        else if ("update".equals(action)) {
            q = PagesUtil.getUpdateQuery(CATALOG_DB + ".products", colValueHM, " WHERE id = " + escape.cote(productId));
            int upCount = Etn.executeCmd(q);
            if (upCount <= 0) {
                throw new Exception("Error in updating product record");
            }
        }

        if (importDatetime && productId.length() > 0) {
            updateCreatedUpdatedTs(itemObj, CATALOG_DB + ".products", " WHERE id = " + escape.cote(productId), "on");
        }

        HashMap<String, String> langCodeHM = new HashMap<>();
        for (Language lang : langList) {
            langCodeHM.put(lang.code, "" + lang.id);
        }

        HashMap<String, JSONObject> catAttribHM = new HashMap<>();
        ArrayList<String> selectionAttribsList = new ArrayList<>();
        q = "SELECT ca.cat_attrib_id AS attribute_id, ca.name AS attribute_name, ca.type AS attribute_type "
            + " , cav.attribute_value AS attribute_value,  cav.id AS attribute_value_id "
            + " FROM " + CATALOG_DB + ".catalog_attributes ca "
            + " LEFT JOIN " + CATALOG_DB + ".catalog_attribute_values cav ON ca.cat_attrib_id = cav.cat_attrib_id "
            + " WHERE ca.catalog_id = " + escape.cote(catalogId);
        rs = Etn.execute(q);
        while (rs.next()) {

            if ("selection".equals(rs.value("attribute_type"))) {
                selectionAttribsList.add(rs.value("attribute_name"));
            }

            String attribKey = rs.value("attribute_type") + "_" + rs.value("attribute_name");

            JSONObject attribObj = catAttribHM.get(attribKey);
            if (attribObj == null) {
                attribObj = new JSONObject();
                attribObj.put("id", rs.value("attribute_id"));
                // attribObj.put("type", rs.value("attribute_type"));
                catAttribHM.put(attribKey, attribObj);
            }

            if (PagesUtil.parseNull(rs.value("attribute_value_id")).length() > 0) {
                JSONObject valuesObj = attribObj.optJSONObject("values");
                if (valuesObj == null) {
                    valuesObj = new JSONObject();
                    attribObj.put("values", valuesObj);
                }

                valuesObj.put(rs.value("attribute_value"), rs.value("attribute_value_id"));
            }
        }

        //product_variants
        for (int i = 0; i < variantsList.length(); i++) {
            JSONObject curObj = variantsList.optJSONObject(i);
            String variantSKU = curObj.getString("sku");

            String variantId = "";

            q = "SELECT pv.id  FROM " + CATALOG_DB + ".product_variants pv "
                + " JOIN " + CATALOG_DB + ".products p ON p.id = pv.product_id "
                + " JOIN " + CATALOG_DB + ".catalogs c ON c.id = p.catalog_id  "
                + " WHERE pv.product_id = " + escape.cote(productId)
                + " AND sku = " + escape.cote(variantSKU);
            rs = Etn.execute(q);
            if (rs.next()) {
                variantId = rs.value("id");
            }

            colValueHM.clear();
            for (String colName : curObj.keySet()) {
                Object colValue = curObj.get(colName);
                if (colValue instanceof String) {
                    colValueHM.put(colName, escape.cote((String) colValue));
                }
            }

            colValueHM.put("updated_by", escape.cote(pid+""));
            colValueHM.put("updated_on", "NOW()");


            if (variantId.length() == 0) {

                colValueHM.remove("id");
                colValueHM.put("uuid", escape.cote(UUID.randomUUID().toString()));
                colValueHM.put("product_id", escape.cote(productId));
                colValueHM.put("sku", escape.cote(variantSKU));
                colValueHM.put("created_on", "NOW()");
                colValueHM.put("created_by", escape.cote(pid+""));

                q = PagesUtil.getInsertQuery(CATALOG_DB + ".product_variants", colValueHM);

                int newVariantId = Etn.executeCmd(q);
                if (newVariantId <= 0) {
                    throw new Exception("Error in inserting product varaint");
                }
                else {
                    variantId = "" + newVariantId;
                }

            }
            else {
                q = PagesUtil.getUpdateQuery(CATALOG_DB + ".product_variants", colValueHM, " WHERE id = " + escape.cote(variantId));
                int upCount = Etn.executeCmd(q);
                if (upCount <= 0) {
                    throw new Exception("Error in updating product variant record");
                }
            }

            q = "DELETE FROM " + CATALOG_DB + ".product_variant_ref WHERE product_variant_id =" + escape.cote(variantId);
            Etn.executeCmd(q);

            JSONArray variant_attributes = curObj.getJSONArray("variant_attributes");
            for (String curAttribName : selectionAttribsList) {
                String curAttribValue = "";

                for (int j = 0; j < variant_attributes.length(); j++) {
                    JSONObject curVarAttrib = variant_attributes.optJSONObject(j);
                    // String attribute_name = curVarAttrib.getString("attribute_name");
                    // String attribute_value = curVarAttrib.getString("attribute_value");

                    if (curAttribName.equals(curVarAttrib.getString("attribute_name"))) {
                        curAttribValue = curVarAttrib.getString("attribute_value");
                        break;
                    }
                }
                String attribKey = "selection_" + curAttribName;
                JSONObject attribObj = catAttribHM.get(attribKey);

                String attribId = attribObj.getString("id");

                JSONObject valuesObj = attribObj.optJSONObject("values");
                String attribValueId = "0";

                if(valuesObj != null){
                    attribValueId = valuesObj.optString(curAttribValue, "0");
                }

                q = "INSERT IGNORE INTO " + CATALOG_DB + ".product_variant_ref(product_variant_id, cat_attrib_id, catalog_attribute_value_id) VALUES ( "
                    + escape.cote(variantId) + "," + escape.cote(attribId) + "," + escape.cote(attribValueId) + ")";
                Etn.executeCmd(q);
            }
            JSONArray variant_details = curObj.getJSONArray("variant_details");

            for (int j = 0; j < variant_details.length(); j++) {
                JSONObject curDetail = variant_details.optJSONObject(j);

                String langId = langCodeHM.get(curDetail.getString("langue_code"));
                if (langId == null) { // lang code did not match with the site language
                    continue;
                }

                colValueHM.clear();

                String qPostfix = "";
                for (String colName : curDetail.keySet()) {
                    if (colName.equals("langue_code")
                        || curDetail.get(colName) instanceof JSONArray
                        || curDetail.get(colName) instanceof JSONObject) {
                        continue;
                    }

                    colValueHM.put(colName, escape.cote(curDetail.getString(colName)));
                    if (qPostfix.length() > 0) {
                        qPostfix += ",";
                    }
                    qPostfix += colName + "=VALUES(" + colName + ")";
                }
                colValueHM.put("product_variant_id", escape.cote(variantId));
                colValueHM.put("langue_id", escape.cote(langId));

                q = PagesUtil.getInsertQuery(CATALOG_DB + ".product_variant_details", colValueHM)
                    + " ON DUPLICATE KEY UPDATE " + qPostfix;
                Etn.executeCmd(q);

                JSONArray variant_resources = curDetail.getJSONArray("variant_resources");
                for (int k = 0; k < variant_resources.length(); k++) {
                    try {
                        JSONObject curResource = variant_resources.optJSONObject(k);

                        String resType = curResource.optString("type");
                        String resPath = curResource.optString("path");

                        q = "SELECT id FROM " + CATALOG_DB + ".product_variant_resources "
                            + " WHERE product_variant_id = " + escape.cote(variantId)
                            + " AND type = " + escape.cote(resType)
                            + " AND langue_id = " + escape.cote(langId)
                            + " AND path = " + escape.cote(resPath);
                        rs = Etn.execute(q);
                        if (rs.next()) {

                            q = "UPDATE " + CATALOG_DB + ".product_variant_resources " +
                                " SET label = " + escape.cote(curResource.optString("label", ""))
                                + " , sort_order = " + escape.cote(curResource.optString("sort_order", "1"))
                                + " WHERE id = " + escape.cote(rs.value("id"));
                            Etn.executeCmd(q);
                        }
                        else {
                            colValueHM.clear();
                            colValueHM.put("product_variant_id", escape.cote(variantId));
                            colValueHM.put("langue_id", escape.cote(langId));
                            colValueHM.put("type", escape.cote(resType));
                            colValueHM.put("path", escape.cote(resPath));
                            colValueHM.put("label", escape.cote(curResource.optString("label", "")));
                            colValueHM.put("sort_order", escape.cote(curResource.optString("sort_order", "1")));
                            q = PagesUtil.getInsertQuery(CATALOG_DB + ".product_variant_resources", colValueHM);
                            Etn.executeCmd(q);
                        }
                    }
                    catch (Exception varResEx) {
                        varResEx.printStackTrace();
                    }

                }
            }


        }//for variantsList


        //details_lang
        for (int i = 0; i < detailsLangList.length(); i++) {
            JSONObject curDetailLangObj = detailsLangList.optJSONObject(i);
            if (curDetailLangObj == null) {
                continue;
            }

            String langue_code = curDetailLangObj.getString("langue_code");
            String langId = langCodeHM.get(langue_code);
            if (langId == null) {
                continue;
            }
            HashSet<String> prevLangIds = new HashSet<>();

            //product_descriptions
            {
                try {
                    JSONObject descriptionObj = curDetailLangObj.getJSONObject("description");

                    colValueHM.clear();
                    for (String colName : descriptionObj.keySet()) {
                        if(colName.equals("page_template_cstm_id")){
                            colValueHM.put("page_template_id", pageTemplateId(PagesUtil.parseNull(descriptionObj.optString("page_template_cstm_id")),"product"));
                        }else if(colName.equals("page_template_id")){
                            continue;
                        }else{
                            colValueHM.put(colName, escape.cote(descriptionObj.getString(colName)));
                        }
                    }

                    if (colValueHM.size() > 0) {
                        q = "SELECT 1 FROM " + CATALOG_DB + ".product_descriptions "
                            + " WHERE product_id = " + escape.cote(productId)
                            + " AND langue_id = " + escape.cote(langId);
                        rs = Etn.execute(q);
                        if (rs.next()) {

                            q = PagesUtil.getUpdateQuery(CATALOG_DB + ".product_descriptions", colValueHM, " WHERE product_id = " + escape.cote(productId)
                                                                                                           + " AND langue_id = " + escape.cote(langId));
                            Etn.executeCmd(q);
                        }
                        else {
                            colValueHM.put("product_id", escape.cote(productId));
                            colValueHM.put("langue_id", escape.cote(langId));
                            q = PagesUtil.getInsertQuery(CATALOG_DB + ".product_descriptions", colValueHM);
                            Etn.executeCmd(q);
                        }
                    }
                }
                catch (Exception descEx) {
                    descEx.printStackTrace();
                }
            }

            //essential_blocks
            {
                JSONArray essentialBlocksList = curDetailLangObj.getJSONArray("essential_blocks");
                prevLangIds.clear();
                for (int j = 0; j < essentialBlocksList.length(); j++) {
                    try {
                        JSONObject curObj = essentialBlocksList.getJSONObject(j);

                        colValueHM.clear();
                        for (String colName : curObj.keySet()) {
                            colValueHM.put(colName, escape.cote(curObj.getString(colName)));
                        }
                        if (colValueHM.size() == 0) {
                            continue;
                        }

                        if (!prevLangIds.contains(langId)) {
                            //only on first langId occurance, delete all existing
                            //as there can be multiple essential blocks for same lang
                            prevLangIds.add(langId);
                            q = "DELETE FROM " + CATALOG_DB + ".product_essential_blocks "
                                + " WHERE product_id = " + escape.cote(productId)
                                + " AND langue_id = " + escape.cote(langId);
                            Etn.executeCmd(q);
                        }

                        colValueHM.put("product_id", escape.cote(productId));
                        colValueHM.put("langue_id", escape.cote(langId));
                        q = PagesUtil.getInsertQuery(CATALOG_DB + ".product_essential_blocks", colValueHM);
                        Etn.executeCmd(q);

                    }
                    catch (Exception pEssBlockEx) {
                        pEssBlockEx.printStackTrace();
                    }
                }
            }

            //product_tabs
            {
                JSONArray tabsList = curDetailLangObj.getJSONArray("tabs");
                prevLangIds.clear();
                for (int j = 0; j < tabsList.length(); j++) {
                    try {
                        JSONObject curObj = tabsList.getJSONObject(j);

                        colValueHM.clear();
                        for (String colName : curObj.keySet()) {
                            colValueHM.put(colName, escape.cote(curObj.getString(colName)));
                        }
                        if (colValueHM.size() == 0) {
                            continue;
                        }

                        if (!prevLangIds.contains(langId)) {
                            prevLangIds.add(langId);
                            q = "DELETE FROM " + CATALOG_DB + ".product_tabs "
                                + " WHERE product_id = " + escape.cote(productId)
                                + " AND langue_id = " + escape.cote(langId);
                            Etn.executeCmd(q);
                        }

                        colValueHM.put("product_id", escape.cote(productId));
                        colValueHM.put("langue_id", escape.cote(langId));
                        q = PagesUtil.getInsertQuery(CATALOG_DB + ".product_tabs", colValueHM);
                        Etn.executeCmd(q);

                    }
                    catch (Exception pTabEx) {
                        pTabEx.printStackTrace();
                    }
                }
            }

            //product_images
            {
                //images are optional , currenly only for offers
                JSONArray imagesList = curDetailLangObj.optJSONArray("images");
                if (imagesList != null) {

                    for (int j = 0; j < imagesList.length(); j++) {
                        try {
                            JSONObject curObj = imagesList.getJSONObject(j);

                            colValueHM.clear();
                            for (String colName : curObj.keySet()) {
                                colValueHM.put(colName, escape.cote(curObj.getString(colName)));
                            }
                            if (colValueHM.size() == 0) {
                                continue;
                            }

                            q = "SELECT id FROM " + CATALOG_DB + ".product_images "
                                + " WHERE product_id = " + escape.cote(productId)
                                + " AND langue_id = " + escape.cote(langId);
                            rs = Etn.execute(q);
                            if (rs.next()) {

                                q = PagesUtil.getUpdateQuery(CATALOG_DB + ".product_images", colValueHM, " WHERE id = " + escape.cote(rs.value("id")));
                                Etn.executeCmd(q);
                            }
                            else {
                                colValueHM.put("product_id", escape.cote(productId));
                                colValueHM.put("langue_id", escape.cote(langId));
                                q = PagesUtil.getInsertQuery(CATALOG_DB + ".product_images", colValueHM);
                                Etn.executeCmd(q);
                            }
                        }
                        catch (Exception pImgEx) {
                            pImgEx.printStackTrace();
                        }
                    }//for imagesList
                }
            }

        }//for detailsLangList

        //product_attributes
        String queryPrefix = "INSERT IGNORE INTO " + CATALOG_DB + ".product_attribute_values (product_id, cat_attrib_id, attribute_value) "
                             + " VALUES ( " + escape.cote(productId) + ",";
        for (int i = 0; i < attributesList.length(); i++) {

            JSONObject curAttribObj = attributesList.getJSONObject(i);

            String attribValue = curAttribObj.optString("attribute_value");

            String attribKey = curAttribObj.optString("attribute_type") + "_" + curAttribObj.optString("attribute_name");
            if (catAttribHM.containsKey(attribKey)) {
                String attribId = catAttribHM.get(attribKey).getString("id");
                q = queryPrefix + escape.cote(attribId) + "," + escape.cote(attribValue) + ")";
                Etn.executeCmd(q);
            }
        }

        //product_tags
        if (tagsList != null && tagsList.length() > 0) {
            for (int i = 0; i < tagsList.length(); i++) {

                JSONObject curTagObj = tagsList.optJSONObject(i);
                if (curTagObj == null) {
                    continue;
                }
                String tagId = getTagId(curTagObj);

                q = "INSERT IGNORE INTO " + CATALOG_DB + ".product_tags (product_id, tag_id, created_by, created_on) "
                    + " VALUES (" + escape.cote(productId)
                    + "," + escape.cote(tagId)
                    + "," + escape.cote("" + pid)
                    + " , NOW() )";
                Etn.executeCmd(q);
            }
        }

        return action;

    }

    protected void deleteDataFormTables(Etn Etn, String db, String siteId, String formId, String tableName) {

        Etn.execute("DELETE c FROM " + db + ".coordinates c INNER JOIN " + db + ".process_forms pf ON c.process = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE p FROM " + db + ".phases p INNER JOIN " + db + ".process_forms pf ON p.process = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE r FROM " + db + ".rules r INNER JOIN " + db + ".process_forms pf ON r.start_proc = pf.table_name AND r.next_proc = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE ha FROM " + db + ".has_action ha INNER JOIN " + db + ".process_forms pf ON ha.start_proc = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE m FROM " + db + ".mails_unpublished m INNER JOIN " + db + ".mail_config_unpublished mc ON m.id = mc.id INNER JOIN " + db + ".process_forms_unpublished pf ON mc.ordertype = pf.table_name WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE mc FROM " + db + ".mail_config_unpublished mc INNER JOIN " + db + ".process_forms_unpublished pf ON mc.ordertype = pf.table_name WHERE  site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE fr FROM " + db + ".freq_rules_unpublished fr INNER JOIN " + db + ".process_forms_unpublished pf ON fr.form_id = pf.form_id WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE fsf FROM " + db + ".form_search_fields_unpublished fsf INNER JOIN " + db + ".process_forms_unpublished pf ON fsf.form_id = pf.form_id WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE frf FROM " + db + ".form_result_fields_unpublished frf INNER JOIN " + db + ".process_forms_unpublished pf ON frf.form_id = pf.form_id WHERE site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE pffd FROM " + db + ".process_form_field_descriptions_unpublished pffd INNER JOIN " + db + ".process_form_fields_unpublished pff ON pffd.form_id = pff.form_id INNER JOIN " + db + ".process_forms pf ON pf.form_id = pff.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE pff FROM " + db + ".process_form_fields_unpublished pff INNER JOIN " + db + ".process_forms_unpublished pf ON pf.form_id = pff.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE pfl FROM " + db + ".process_form_lines_unpublished pfl INNER JOIN " + db + ".process_forms_unpublished pf ON pf.form_id = pfl.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE pfd FROM " + db + ".process_form_descriptions_unpublished pfd INNER JOIN " + db + ".process_forms_unpublished pf ON pf.form_id = pfd.form_id WHERE pf.site_id = " + escape.cote(siteId) + " AND pf.form_id = " + escape.cote(formId));

        Etn.execute("DELETE FROM " + db + ".process_forms_unpublished WHERE site_id = " + escape.cote(siteId) + " AND form_id = " + escape.cote(formId));
    }

    public String importItemForms(JSONObject itemObj, String importType) throws Exception {
        String action = ""; //insert, update, skip

        String q = "";
        Set rs = null;

        String FORMS_DB = GlobalParm.getParm("FORMS_DB");

        JSONObject sysInfo = itemObj.getJSONObject("system_info");

        JSONObject processFormObj = itemObj.optJSONObject("process_forms");
        JSONArray processFormDescriptionObj = itemObj.optJSONArray("form_descriptions");
        JSONArray processFormLinesObj = itemObj.optJSONArray("form_lines");
        JSONArray processFormFieldsObj = itemObj.optJSONArray("form_fields");
        JSONArray processFormFieldDescriptionObj = itemObj.optJSONArray("form_field_descriptions");
        JSONArray processRuleObj = itemObj.optJSONArray("form_rules");
        JSONArray processFormSearchFields = itemObj.optJSONArray("form_search_fields");
        JSONArray processFormResultFields = itemObj.optJSONArray("form_result_fields");
        JSONObject processFormMailsObj = itemObj.optJSONObject("mails");
        JSONObject processFormMailConfigObj = itemObj.optJSONObject("mail_config");
        JSONArray processCoordinateObj = itemObj.optJSONArray("process_coordinates");
        JSONArray processPhaseObj = itemObj.optJSONArray("process_phases");
        JSONArray processFormRulesObj = itemObj.optJSONArray("process_rules");
        JSONObject processFormHasActionObj = itemObj.optJSONObject("process_has_action");

        String name = sysInfo.getString("name").trim();
        String formId = sysInfo.getString("id").trim();
        String formType = sysInfo.getString("type").trim();
        String tableName = sysInfo.getString("table_name").trim();
        String now = "";
        String curDate = "";
        String cle = "";
        String filePath = GlobalParm.getParm("MAIL_UPLOAD_PATH") + "unpublished_mail";
        Map<String, String> formFieldFreemarkerValues = new HashMap<>();

        if (tableName.length() > 0) tableName = tableName + "_" + siteId;

        q = "SELECT now() as _datetime, curdate() as _date";

        rs = Etn.execute(q);

        if (rs.next()) {

            now = PagesUtil.parseNull(rs.value("_datetime"));
            curDate = PagesUtil.parseNull(rs.value("_date"));
        }

        boolean isExisting = false;

        q = "SELECT form_id,table_name FROM " + FORMS_DB + ".process_forms_unpublished "
            + " WHERE (table_name = " + escape.cote(tableName)
            + " OR process_name = " + escape.cote(name)
            + ") AND site_id = " + escape.cote(siteId);

        rs = Etn.execute(q);

        if (rs.next()) {
            formId = rs.value("form_id");
            tableName = rs.value("table_name");
            isExisting = true;
        }

        if (IMPORT_TYPE_KEEP.equals(importType)) {
            if (isExisting) {
                action = "skip";
                return action;
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_DUPLICATE.equals(importType)) {
            if (isExisting) {
                // assign a new name not existing already
                int count = 2;
                String newName = "";
                do {
                    newName = name + " " + count;
                    tableName = tableName + "_" + count;
                    q = "SELECT form_id FROM " + FORMS_DB + ".process_forms_unpublished "
                        + " WHERE process_name = " + escape.cote(newName)
                        + " AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);
                    count++;
                }
                while (rs.next());

                name = newName;
                action = "insert";

            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_ALL.equals(importType)) {
            if (isExisting) {
                //delete all original data and "NOT" its associations
                Etn.executeCmd("delete from "+FORMS_DB+".process_form_descriptions_unpublished where form_id="+escape.cote(formId));
                Etn.executeCmd("delete from "+FORMS_DB+".process_form_lines_unpublished where form_id="+escape.cote(formId));
                Etn.executeCmd("delete from "+FORMS_DB+".process_form_fields_unpublished where form_id="+escape.cote(formId));
                Etn.executeCmd("delete from "+FORMS_DB+".process_form_field_descriptions_unpublished where form_id="+escape.cote(formId));
                Etn.executeCmd("delete from "+FORMS_DB+".freq_rules_unpublished where form_id="+escape.cote(formId));
                Etn.executeCmd("delete from "+FORMS_DB+".form_search_fields_unpublished where form_id="+escape.cote(formId));
                Etn.executeCmd("delete from "+FORMS_DB+".form_result_fields_unpublished where form_id="+escape.cote(formId));
                Etn.executeCmd("delete from "+FORMS_DB+".mail_config_unpublished where ordertype="+escape.cote(tableName));

                action = "update";
            }
            else {
                action = "insert";
            }
        }
        else if (IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
            if (isExisting) {
                action = "update";
            }
            else {
                action = "insert";
            }
        }

        
        HashMap<String, String> colValueHM = new HashMap<>();
        String customerMailId = "";
        String backofficeMailId = "";
        
        if (action.equals("insert")) formId = UUID.randomUUID().toString();
        

        if (null != processFormObj) {
            
            colValueHM.clear();

            colValueHM = getHashMap(processFormObj);

            colValueHM.put("updated_by", escape.cote("" + pid));
            colValueHM.put("updated_on", "NOW()");
            colValueHM.put("to_publish", "0");
            colValueHM.put("to_unpublish", "0");
            colValueHM.put("to_publish_by", "0");
            colValueHM.put("to_unpublish_by", "0");
            colValueHM.put("created_on", "NOW()");
            colValueHM.put("created_by", escape.cote("" + pid)); 
            colValueHM.put("form_id", escape.cote(formId));
            colValueHM.put("table_name", escape.cote(tableName));
            colValueHM.put("process_name", escape.cote(name));
            colValueHM.put("site_id", escape.cote(siteId));
            
            if ("insert".equals(action)) {
                q = PagesUtil.getInsertQuery(FORMS_DB + ".process_forms_unpublished", colValueHM);
            }
            else if("update".equals(action)){
                q = PagesUtil.getUpdateQuery(FORMS_DB + ".process_forms_unpublished", colValueHM, " WHERE form_id = " + escape.cote(formId));
            }

            int rid = Etn.executeCmd(q);
            if (rid <= 0 && !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                throw new Exception("Error in inserting form record");
            }
            Etn.executeCmd("update freemarker_pages set updated_ts=now() where id in (select page_id from pages_forms where form_id="+escape.cote(formId)+" and type='freemarker')");
            Etn.executeCmd("update structured_contents set updated_ts=now() where id in (select page_id from pages_forms where form_id="+escape.cote(formId)+" and type='structured')");
        }

        if (null != processFormDescriptionObj) {

            for (int i = 0; i < processFormDescriptionObj.length(); i++) {

                colValueHM.clear();
                JSONObject jobj = (JSONObject) processFormDescriptionObj.get(i);

                colValueHM = getHashMap(jobj);

                colValueHM.put("form_id", escape.cote(formId));
                q = PagesUtil.getInsertQuery(FORMS_DB + ".process_form_descriptions_unpublished", colValueHM,true);
                
                int rid = Etn.executeCmd(q);
                if (rid <= 0 && !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                    deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                    throw new Exception("Error in inserting form description record");
                }
            }
        }

        if (null != processFormLinesObj) {

            for (int i = 0; i < processFormLinesObj.length(); i++) {

                colValueHM.clear();

                JSONObject jobj = (JSONObject) processFormLinesObj.get(i);

                colValueHM = getHashMap(jobj);

                colValueHM.put("form_id", escape.cote(formId));

                q = PagesUtil.getInsertQuery(FORMS_DB + ".process_form_lines_unpublished", colValueHM,true);

                int rid = Etn.executeCmd(q);
                if (rid <= 0 && !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                    deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                    throw new Exception("Error in inserting form lines record");
                }
            }
        }

        if (null != processFormFieldsObj) {

            for (int i = 0; i < processFormFieldsObj.length(); i++) {

                colValueHM.clear();

                JSONObject jobj = (JSONObject) processFormFieldsObj.get(i);

                colValueHM = getHashMap(jobj);

                colValueHM.put("form_id", escape.cote(formId));

                if (PagesUtil.parseNull(jobj.getString("type")).equals("textdate")) {
                    formFieldFreemarkerValues.put(PagesUtil.parseNull(jobj.getString("db_column_name")), curDate);
                }
                else if (PagesUtil.parseNull(jobj.getString("type")).equals("textdatetime")) {
                    formFieldFreemarkerValues.put(PagesUtil.parseNull(jobj.getString("db_column_name")), now);
                }
                else if (PagesUtil.parseNull(jobj.getString("type")).equals("number")) {
                    formFieldFreemarkerValues.put(PagesUtil.parseNull(jobj.getString("db_column_name")), "0");
                }
                else {
                    formFieldFreemarkerValues.put(PagesUtil.parseNull(jobj.getString("db_column_name")), "");
                }

                q = PagesUtil.getInsertQuery(FORMS_DB + ".process_form_fields_unpublished", colValueHM,true);

                int rid = Etn.executeCmd(q);
                if (rid <= 0 && !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                    deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                    throw new Exception("Error in inserting form fields record");
                }
            }
        }

        if (null != processFormFieldDescriptionObj) {

            for (int i = 0; i < processFormFieldDescriptionObj.length(); i++) {

                colValueHM.clear();

                JSONObject jobj = (JSONObject) processFormFieldDescriptionObj.get(i);

                colValueHM = getHashMap(jobj);

                colValueHM.put("form_id", escape.cote(formId));

                q = PagesUtil.getInsertQuery(FORMS_DB + ".process_form_field_descriptions_unpublished", colValueHM,true);

                int rid = Etn.executeCmd(q);
                if (rid <= 0 && !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                    deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                    throw new Exception("Error in inserting form field description record");
                }
            }
        }

        if (null != processRuleObj) {

            for (int i = 0; i < processRuleObj.length(); i++) {

                colValueHM.clear();

                JSONObject jobj = (JSONObject) processRuleObj.get(i);

                colValueHM = getHashMap(jobj);

                colValueHM.put("form_id", escape.cote(formId));

                q = PagesUtil.getInsertQuery(FORMS_DB + ".freq_rules_unpublished", colValueHM,true);

                int rid = Etn.executeCmd(q);
                if (rid <= 0 && !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                    deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                    throw new Exception("Error in inserting form rules record");
                }
            }
        }

        if (null != processFormSearchFields) {

            for (int i = 0; i < processFormSearchFields.length(); i++) {

                colValueHM.clear();

                JSONObject jobj = (JSONObject) processFormSearchFields.get(i);

                colValueHM = getHashMap(jobj);

                colValueHM.put("form_id", escape.cote(formId));

                q = PagesUtil.getInsertQuery(FORMS_DB + ".form_search_fields_unpublished", colValueHM,true);

                int rid = Etn.executeCmd(q);
                if (rid <= 0 && !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                    deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                    throw new Exception("Error in inserting form search fields record");
                }
            }
        }

        if (null != processFormResultFields) {

            for (int i = 0; i < processFormResultFields.length(); i++) {

                colValueHM.clear();

                JSONObject jobj = (JSONObject) processFormResultFields.get(i);

                colValueHM = getHashMap(jobj);

                colValueHM.put("form_id", escape.cote(formId));

                q = PagesUtil.getInsertQuery(FORMS_DB + ".form_result_fields_unpublished", colValueHM,true);

                int rid = Etn.executeCmd(q);
                if (rid <= 0 && !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                    deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                    throw new Exception("Error in inserting form result fields record");
                }
            }
        }

        if(action.equals("insert")){
            if (null != processFormMailsObj) {

                JSONArray mailConfg = (JSONArray) processFormMailsObj.get("configuration");

                if (null != mailConfg) {

                    for (int i = 0; i < mailConfg.length(); i++) {

                        colValueHM.clear();

                        JSONObject jobj = (JSONObject) mailConfg.get(i);

                        colValueHM = getHashMap(jobj);

                        q = PagesUtil.getInsertQuery(FORMS_DB + ".mails_unpublished", colValueHM);

                        int rid = Etn.executeCmd(q);

                        if (i == 0) customerMailId = rid + "";
                        if (i == 1) backofficeMailId = rid + "";

                        if (rid <= 0 ) {

                            deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                            throw new Exception("Error in inserting mails record");

                        }
                        else {

                            Set langRs = Etn.execute("select * from language");

                            while (langRs.next()) {

                                String langId = langRs.value("langue_id");
                                String langCode = langRs.value("langue_code");

                                if (!langId.equals("1")) {
                                    langCode = "_" + langCode;
                                }
                                else {
                                    langCode = "";
                                }

                                String tempData = "";
                                String tempDataFM = "";

                                if (i == 0) {

                                    tempData = processFormMailsObj.getString("customer_template" + langCode);
                                    tempDataFM = processFormMailsObj.getString("customer_template_freemarker" + langCode);
                                }

                                if (i == 1) {

                                    tempData = processFormMailsObj.getString("bkoffice_template" + langCode);
                                    tempDataFM = processFormMailsObj.getString("bkoffice_template_freemarker" + langCode);
                                }


                                writeDataInFile(filePath + rid + langCode, tempData, tableName);
                                writeDataFreemarkerTemplate(filePath + rid + langCode, tempDataFM, rid + "", langCode, tableName, formFieldFreemarkerValues);
                            }


                        }
                    }
                }

                colValueHM.clear();

                colValueHM.put("cust_eid", escape.cote(customerMailId));
                colValueHM.put("bk_ofc_eid", escape.cote(backofficeMailId));

                Etn.executeCmd(PagesUtil.getUpdateQuery(FORMS_DB + ".process_forms_unpublished", colValueHM, " WHERE form_id = " + escape.cote(formId)));
            }
        }

        if (null != processFormMailConfigObj) {

            colValueHM.clear();

            colValueHM = getHashMap(processFormMailConfigObj);

            colValueHM.put("id", escape.cote(backofficeMailId));
            colValueHM.put("ordertype", escape.cote(tableName));

            q = PagesUtil.getInsertQuery(FORMS_DB + ".mail_config_unpublished", colValueHM,true);

            int rid = Etn.executeCmd(q);
            if (rid <= 0 && !IMPORT_TYPE_REPLACE_PARTIAL.equals(importType)) {
                deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                throw new Exception("Error in inserting mail config record");
            }
        }

        /* -------------- (Ahsan) Data connected to phases obsolete as per discussion (12 June 2023)-------------------------
        if (null != processCoordinateObj) {

            for (int i = 0; i < processCoordinateObj.length(); i++) {

                colValueHM.clear();

                JSONObject jobj = (JSONObject) processCoordinateObj.get(i);

                colValueHM = getHashMap(jobj);

                colValueHM.put("process", escape.cote(tableName));

                q = PagesUtil.getInsertQuery(FORMS_DB + ".coordinates", colValueHM);

                int rid = Etn.executeCmd(q);
                if (rid <= 0) {
                    deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                    throw new Exception("Error in inserting process coordinates record");
                }
            }
        }

        if (null != processPhaseObj) {

            for (int i = 0; i < processPhaseObj.length(); i++) {

                colValueHM.clear();

                JSONObject jobj = (JSONObject) processPhaseObj.get(i);

                colValueHM = getHashMap(jobj);

                colValueHM.put("process", escape.cote(tableName));

                q = PagesUtil.getInsertQuery(FORMS_DB + ".phases", colValueHM);

                int rid = Etn.executeCmd(q);
                if (rid <= 0) {
                    deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                    throw new Exception("Error in inserting process phases record");
                }
            }
        }

        if (null != processFormRulesObj) {

            for (int i = 0; i < processFormRulesObj.length(); i++) {

                colValueHM.clear();

                JSONObject jobj = (JSONObject) processFormRulesObj.get(i);

                colValueHM = getHashMap(jobj);

                colValueHM.put("start_proc", escape.cote(tableName));
                colValueHM.put("next_proc", escape.cote(tableName));

                q = PagesUtil.getInsertQuery(FORMS_DB + ".rules", colValueHM);

                int rid = Etn.executeCmd(q);
                cle = rid + "";

                if (rid <= 0) {
                    deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                    throw new Exception("Error in inserting process rules record");
                }
            }
        }

        if (null != processFormHasActionObj) {

            colValueHM.clear();
            colValueHM = getHashMap(processFormHasActionObj);

            colValueHM.put("start_proc", escape.cote(tableName));
            colValueHM.put("cle", cle);

            q = PagesUtil.getInsertQuery(FORMS_DB + ".has_action", colValueHM);

            int rid = Etn.executeCmd(q);
            if (rid <= 0) {
                deleteDataFormTables(Etn, FORMS_DB, siteId, formId, tableName);
                throw new Exception("Error in inserting has action record");
            }
        }

        ---------------Till Here ------------------------*/ 

        if (importDatetime && formId.length() > 0) {
            updateCreatedUpdatedTs(itemObj, FORMS_DB + ".process_forms", " WHERE id = " + escape.cote(formId), "on");
        }

        return action;

    }
    
    public String importItemVariables(JSONObject itemObj, String importType) throws Exception {
        boolean isExisting = false;
        String action="skip";
        JSONObject sysInfo = itemObj.getJSONObject("system_info");

        String name = PagesUtil.parseNull(sysInfo.getString("name").trim());
        String value = PagesUtil.parseNull(sysInfo.getString("value").trim());
        String is_editable = PagesUtil.parseNull(sysInfo.getString("is_editable").trim());

        Set rs = Etn.execute("select * from variables where site_id="+escape.cote(PagesUtil.parseNull(siteId))+" and name="+escape.cote(name));
        if(rs.next()) isExisting = true;

        if(IMPORT_TYPE_REPLACE_PARTIAL.equals(importType) || IMPORT_TYPE_REPLACE_ALL.equals(importType)){
            if(!isExisting) action = "insert";
            else action = "update";
        }else if(IMPORT_TYPE_DUPLICATE.equals(importType) || IMPORT_TYPE_KEEP.equals(importType)){
            if(!isExisting) action = "insert";
        }

        if(action.equals("insert")){
            Etn.executeCmd("insert ignore into variables (name,value,site_id,created_ts,created_by,is_editable) values("+escape.cote(name)+","+
            escape.cote(value)+","+escape.cote(PagesUtil.parseNull(siteId))+",now(),"+escape.cote(PagesUtil.parseNull(pid))+","+
            escape.cote(is_editable)+")");
        }else if(action.equals("update")){
            Etn.executeCmd("Update variables set value="+escape.cote(value)+",is_editable="+escape.cote(is_editable)+" where name="+escape.cote(name)+" and site_id="+escape.cote(siteId));
        }

        return action;
    }

    protected HashMap<String, String> getHashMap(JSONObject jsonObject) {

        HashMap<String, String> colValueHM = new HashMap<>();

        for (String colName : jsonObject.keySet()) {

            colValueHM.put(colName, escape.cote(jsonObject.getString(colName)));
        }

        return colValueHM;
    }

    public JSONObject getBlocTemplateDataJson(String templateId, JSONObject dataJson, String langId) throws Exception {
        JSONObject dataObj = new JSONObject();
        JSONArray sectionsList = PagesUtil.getBlocTemplateSectionsData(Etn, templateId);
        generateSectionsDataObj(dataObj, sectionsList, dataJson, Etn,  langId);
        return dataObj;
    }

    public void generateSectionsDataObj(JSONObject parentObj, JSONArray sectionsList, JSONObject dataJson,
                                        Etn Etn, String langId) throws Exception {
        for (int i = 0; i < sectionsList.length(); i++) {

            JSONObject sectionCode = sectionsList.getJSONObject(i);
            String sectionId = sectionCode.getString("custom_id");
            int sectionNbItems = sectionCode.getInt("nb_items");

            JSONArray secDataArray = dataJson.optJSONArray(sectionId);
            if (secDataArray == null) {
                secDataArray = new JSONArray();
            }

            int maxSectionCount = secDataArray.length();
            if (sectionNbItems > 0 && sectionNbItems < maxSectionCount) {
                maxSectionCount = sectionNbItems;
            }

            if (maxSectionCount < 1) {
                maxSectionCount = 1;
            }

            JSONArray sectionDataObjList = new JSONArray();
            for (int j = 0; j < maxSectionCount; j++) {
                isSectionEmpty = true;
                JSONObject curSectionData = secDataArray.optJSONObject(j);
                if (curSectionData == null) {
                    curSectionData = new JSONObject(); //empty
                }
                JSONObject sectionDataMap = getSectionDataObj(sectionCode, curSectionData, langId);
                boolean allFieldsEmpty = sectionDataMap.getBoolean("allFieldsEmpty");
                boolean emptySection = allFieldsEmpty;
                
                if(allFieldsEmpty){ // all sections fields are empty now, check if the nested sections are empty
                    JSONArray nestedSectionsList = sectionCode.getJSONArray("sections"); // check all the nested sections are empty
                    boolean allNestedSectionsEmpty = true;
                    for (int k = 0; k < nestedSectionsList.length(); k++) {
                        JSONArray nestedSecDataArray = null;
                        JSONObject nestedSectionCode = nestedSectionsList.optJSONObject(k);
                        if(nestedSectionCode != null){
                            String nestedSectionId = nestedSectionCode.optString("custom_id");
                            nestedSecDataArray = curSectionData.optJSONArray(nestedSectionId);
                        }
                        if(nestedSecDataArray != null && nestedSecDataArray.length() > 0){
                            allNestedSectionsEmpty = false;
                            break;
                        }
                    }
                    if(!allNestedSectionsEmpty){
                        emptySection = false;
                    }
                }
                if(!emptySection){
                    sectionDataObjList.put(sectionDataMap);
                }
            }//for maxSectionCount

            parentObj.put(sectionId, sectionDataObjList);
        }//for sectionsList

    }

    public JSONObject getSectionDataObj(JSONObject sectionCode, JSONObject curSectionData, String langId) throws Exception {

        JSONObject sectionDataObj = new JSONObject();
        boolean allFieldsEmpty = true;
        JSONArray sectionFields = sectionCode.getJSONArray("fields");

        for (int i = 0; i < sectionFields.length(); i++) {

            JSONObject fieldObj = sectionFields.getJSONObject(i);
            //Logger.debug(fieldObj.toString());

            String fieldId = fieldObj.getString("custom_id");
            int fieldNbItems = fieldObj.getInt("nb_items");
            String fieldType = fieldObj.getString("type").toLowerCase();

            // get field default value
            String fieldDefaultValue = "";
            if(fieldObj.has("lang_data")){
                JSONArray fieldLangDataArray =  fieldObj.getJSONArray("lang_data");
                for(Object fieldLangObj : fieldLangDataArray){
                    JSONObject fieldLangData  = (JSONObject)fieldLangObj;
                    if(fieldLangData.getString("langue_id").equals(langId)){
                       fieldDefaultValue = fieldLangData.getString("default_value");
                    }
                }
            }

            JSONArray srcfieldDataArray = curSectionData.optJSONArray(fieldId);
            if (srcfieldDataArray == null) {
                srcfieldDataArray = new JSONArray();//empty
            }
            //Logger.debug(srcfieldDataArray.toString());

            int maxFieldCount = srcfieldDataArray.length();
            if (fieldNbItems > 0 && fieldNbItems < maxFieldCount) {
                maxFieldCount = fieldNbItems;
            }

            if (maxFieldCount < 1) {
                maxFieldCount = 1;
            }

            JSONArray fieldDataList = new JSONArray();

            for (int j = 0; j < maxFieldCount; j++) {
                try {
                    if ("image".equals(fieldType)) {

                        JSONObject curImgObj = new JSONObject();

                        String imgValue = "";
                        String imgAlt = "";

                        JSONObject srcImgObj = srcfieldDataArray.optJSONObject(j);

                        if (srcImgObj != null && srcImgObj.has("value") && srcImgObj.has("alt")) {
                            imgValue = PagesUtil.parseNull(srcImgObj.optString("value"));
                            imgAlt = PagesUtil.parseNull(srcImgObj.optString("alt"));
                            if(srcImgObj.optString("value").length() > 0){
                                allFieldsEmpty = false;
                            }
                        }
                        else {
                            // no value , set default
                            //JSONObject defaultValueObj = new JSONObject(fieldDefaultValue);
                            //imgValue = defaultValueObj.optString("value","");
                            //imgAlt = defaultValueObj.optString("alt","");
                            String[] defValueArr = fieldDefaultValue.split(",");
                            if (defValueArr.length >= 2) {
                                imgValue = defValueArr[0];
                                imgAlt = defValueArr[1];
                            }
                        }

                        curImgObj.put("value", imgValue);
                        curImgObj.put("alt", imgAlt);

                        fieldDataList.put(curImgObj);
                    }
                    else if ("url".equals(fieldType)) {
                        //field value is an json object { value:"", openType : ""}
                        // where as the defaultValue is a json Array ["<url>","<openType>"]
                        JSONObject curUrlObj = new JSONObject();

                        String urlValue = "";
                        String openTypeValue = "same_window";

                        JSONObject srcObj = srcfieldDataArray.optJSONObject(j);

                        if (srcObj != null) {
                            urlValue = srcObj.optString("value");
                            openTypeValue = srcObj.optString("openType", openTypeValue);
                            if(urlValue.length() > 0){
                                allFieldsEmpty = false;
                            }
                        }
                        else if (srcfieldDataArray.optString(j).length() > 0) {
                            urlValue = srcfieldDataArray.optString(j);
                            allFieldsEmpty = false;
                        }
                        else {
                            // no value , set default
                            JSONArray defaultValueArray = null;
                            try {
                                defaultValueArray = new JSONArray(fieldDefaultValue);
                            }
                            catch (Exception ignored) {
                            }

                            if (defaultValueArray != null && defaultValueArray.length() >= 2) {
                                urlValue = defaultValueArray.optString(0);
                                openTypeValue = defaultValueArray.optString(1);
                            }
                            else {
                                urlValue = fieldDefaultValue;
                            }

                        }

                        curUrlObj.put("value", urlValue);
                        curUrlObj.put("openType", openTypeValue);

                        fieldDataList.put(curUrlObj);
                    }
                    else if ("boolean".equals(fieldType)) {

                        String curFieldValue = srcfieldDataArray.optString(j, null);
                        if (curFieldValue == null) {
                            curFieldValue = fieldDefaultValue;
                        }
                        else {
                            //check value in options
                            //if not found set default value
                            boolean found = false;
                            JSONObject optionsObj = new JSONObject(fieldObj.getString("value"));
                            if (optionsObj.getString("on").equals(curFieldValue)
                                || optionsObj.getString("off").equals(curFieldValue)) {

                                found = true;
                            }

                            if (!found) {
                                curFieldValue = fieldDefaultValue;
                            } else{
                                allFieldsEmpty = false;
                            }
                        }

                        fieldDataList.put(curFieldValue);

                    }
                    else if ("select".equals(fieldType)) {
                        String curFieldValue = srcfieldDataArray.optString(j, null);
                        if (curFieldValue == null) {
                            curFieldValue = fieldDefaultValue;
                        }
                        else {
                            //check value in select options
                            //if not found set default value
                            boolean found = false;
                            JSONArray optionsList = new JSONArray(fieldObj.getString("value"));
                            for (int k = 0; k < optionsList.length(); k++) {
                                JSONArray curOption = optionsList.getJSONArray(k);
                                if (curOption.getString(0).equals(curFieldValue)) {
                                    found = true;
                                    break;
                                }
                            }

                            if (!found) {
                                curFieldValue = fieldDefaultValue;
                            } else{
                                allFieldsEmpty = false;
                            }
                        }

                        fieldDataList.put(curFieldValue);
                    }
                    else if ("tag".equals(fieldType)) {

                        JSONArray srcTagsList = srcfieldDataArray.optJSONArray(j);

                        if (srcTagsList == null) {
                            srcTagsList = new JSONArray();
                        }
                        else {

                            JSONArray validTagsList = new JSONArray();
                            for (int tagIndex = 0; tagIndex < srcTagsList.length(); tagIndex++) {
                                String curTag = srcTagsList.optString(tagIndex, "");
                                if (curTag.length() == 0) {
                                    continue;
                                }
                                allFieldsEmpty = false;
                                String curTagId = curTag.replaceAll(" ", "-");

                                String curTagLabel = curTag.substring(0, 1).toUpperCase()
                                                     + curTag.substring(1);

                                JSONObject tagObj = new JSONObject();
                                tagObj.put("id", curTagId);
                                tagObj.put("label", curTagLabel);

                                curTagId = getTagId(tagObj);

                                if (curTagId != null) {
                                    validTagsList.put(curTagId);
                                }

                            }//for

                            srcTagsList = validTagsList;

                        }
                        fieldDataList.put(srcTagsList);
                    }
                    else if ("date".equals(fieldType)) {

                        JSONArray srcDateList = srcfieldDataArray.optJSONArray(j);
                        if (srcDateList == null) {
                            try {
                                srcDateList = new JSONArray(fieldDefaultValue);
                            }
                            catch (Exception tEx) {
                                srcDateList = new JSONArray();
                                srcDateList.put("");
                                srcDateList.put("");
                            }
                        } else{
                            for(Object dFieldVal : srcDateList){
                                if(dFieldVal != null){
                                    if(dFieldVal.toString().length() > 0){
                                        allFieldsEmpty = false;
                                    }
                                }
                            }
                        }

                        fieldDataList.put(srcDateList);
                    }
                    else if (fieldType.startsWith(("view_"))) {
                        JSONObject curViewObj = new JSONObject("{catalogs:[], sortBy:[], filterBy:[]}");

                        JSONObject srcViewObj = srcfieldDataArray.optJSONObject(j);
                        if (srcViewObj != null) {
                            if (srcViewObj.optJSONArray("catalogs") != null) {
                                curViewObj.put("catalogs", srcViewObj.optJSONArray("catalogs"));

                                for(Object obj : srcViewObj.optJSONArray("catalogs")){
                                    String catVal = (String)obj;
                                    if(catVal.length() > 0){
                                        allFieldsEmpty = false;
                                        break;
                                    }
                                }
                            }
                            if (srcViewObj.optJSONArray("sortBy") != null) {
                                curViewObj.put("sortBy", srcViewObj.optJSONArray("sortBy"));

                                JSONArray sortByArray = srcViewObj.optJSONArray("sortBy");
                                if(sortByArray != null){
                                    for(Object object : sortByArray){
                                        JSONArray sortList = (JSONArray) object;
                                        if(sortList != null && sortList.length()>0){
                                            if(sortList.optString(0).length()>0){
                                                allFieldsEmpty = false;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                            if (srcViewObj.optJSONArray("filterBy") != null) {
                                allFieldsEmpty = false;
                                curViewObj.put("filterBy", srcViewObj.optJSONArray("filterBy"));

                                JSONArray filtersArray = srcViewObj.optJSONArray("filterBy");
                                for(Object object : filtersArray){
                                    JSONObject filterObj = (JSONObject)object;
                                    if(filterObj.optString("column").length()>0 || filterObj.optString("value").length()>0 || filterObj.optString("operator").length()>0){
                                        allFieldsEmpty = false;
                                        break;
                                    }
                                }
                            }
                        }

                        fieldDataList.put(curViewObj);
                     }
                    else {

                        String curFieldValue = srcfieldDataArray.optString(j, null);

                        if (curFieldValue == null) {
                            curFieldValue = fieldDefaultValue;
                        } else{
                            if(curFieldValue.length() > 0){
                                allFieldsEmpty = false;

                            }
                        }

                        fieldDataList.put(curFieldValue);
                    }

                }
                catch (Exception ex) {
                    ex.printStackTrace();
                    throw ex;
                }

            }

            sectionDataObj.put(fieldId, fieldDataList);
        }//for sectionFields

        sectionDataObj.put("allFieldsEmpty", allFieldsEmpty);
        JSONArray nestedSectionsList = sectionCode.getJSONArray("sections");
        generateSectionsDataObj(sectionDataObj, nestedSectionsList, curSectionData, Etn, langId);

        return sectionDataObj;
    }

    protected void updateCreatedUpdatedTs(JSONObject itemObj, String tableName, String whereClause) {
        updateCreatedUpdatedTs(itemObj, tableName, whereClause, "ts");
    }

    protected void updateCreatedUpdatedTs(JSONObject itemObj, String tableName, String whereClause,
                                          String colPostfix) {
        try {
            JSONObject internalInfo = itemObj.optJSONObject("internal_info");
            if (internalInfo != null) {

                String createdColName = "created_" + colPostfix;
                String updatedColName = "updated_" + colPostfix;

                String createdTs = internalInfo.getString("created_ts");
                String updatedTs = internalInfo.getString("updated_ts");

                String srcFormat1 = "dd/MM/yyyy HH:mm:ss";
                String srcFormat2 = "yyyy-MM-dd HH:mm:ss";

                String createdDatetime = PagesUtil.convertDateTimeToStandardFormat(createdTs, srcFormat1);
                if (createdDatetime.length() == 0) {
                    //check with standard ISO format
                    createdDatetime = PagesUtil.convertDateTimeToStandardFormat(createdTs, srcFormat2);
                    if (createdDatetime.length() == 0) {
                        //failed both formats  mark error
                        throw new Exception("Creation datetime field format invalid: " + createdTs);
                    }
                }

                String updatedDatetime = PagesUtil.convertDateTimeToStandardFormat(updatedTs, srcFormat1);
                if (updatedDatetime.length() == 0) {
                    //check with standard ISO format
                    updatedDatetime = PagesUtil.convertDateTimeToStandardFormat(updatedTs, srcFormat2);
                    if (updatedDatetime.length() == 0) {
                        //failed both formats  mark error
                        throw new Exception("Last update datetime field format invalid: " + updatedTs);
                    }
                }

                String q1 = "UPDATE " + tableName + " SET " + createdColName + " = " + escape.cote(createdDatetime)
                            + " , " + updatedColName + " = " + escape.cote(updatedDatetime)
                            + whereClause;
                Etn.executeCmd(q1);
            }

        }
        catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    void writeDataInFile(String path, String data, String tableName) {
        PrintWriter pw = null;
        try {
            String html = "Content-Type: multipart/alternative;\n boundary=\"------------010101080201020804090106\"\n\nThis is a multi-part message in MIME format.\n--------------010101080201020804090106\nContent-Type: text/html; charset=utf-8\nContent-Transfer-Encoding: 7bit\n\n\n";
            html += "<div id='" + tableName + "_template_div'>\n" + data + "\n</div>";
            html += "\n--------------010101080201020804090106--";

            pw = new PrintWriter(new File(path));
            pw.write(html);
            pw.flush();

        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            if (pw != null) pw.close();
        }
    }

    void writeDataInTempFile(String path, String content) {
        try (PrintWriter pw = new PrintWriter(new File(path))) {
            pw.write(content);
            pw.flush();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    JSONObject writeDataFreemarkerTemplate(String fileName, String templateContent, String fileId,
                                           String langCode, String tableName,
                                           Map<String, String> formFieldFreemarkerValues) throws Exception {

        writeDataInTempFile(fileName + "_tmp.ftl", templateContent);

        String templateName = GlobalParm.getParm("MAIL_UPLOAD_PATH") + "/unpublished_mail" + fileId;

        File ftemplate = new File(templateName + "_tmp.ftl");

        if (langCode.length() > 0) {
            templateName += "_" + langCode;
        }


        if (!ftemplate.exists() || ftemplate.length() == 0) {
            templateName = GlobalParm.getParm("MAIL_UPLOAD_PATH") + "/unpublished_mail" + fileId + langCode;
        }

        JSONObject json = validateFreemarkerTemplate("/unpublished_mail" + fileId + langCode, formFieldFreemarkerValues);

        if (json.get("status").equals("success")) {

            File tempTemplate = new File(GlobalParm.getParm("MAIL_UPLOAD_PATH") + "/unpublished_mail" + fileId + langCode + "_tmp.ftl");

            if (tempTemplate.exists() || tempTemplate.length() != 0) {
                tempTemplate.delete();
            }

            writeDataInFile(templateName + ".ftl", templateContent, tableName);
        }

        return json;
    }

    protected JSONObject validateFreemarkerTemplate(String templateName, Map<String, String> map) {

        JSONObject json = new JSONObject();

        try {

            Configuration cfg = PagesUtil.getFreemarkerConfig(GlobalParm.getParm("MAIL_UPLOAD_PATH"));

            Template template = cfg.getTemplate(templateName + "_tmp.ftl");

            StringWriter html = new StringWriter();

            template.process(map, html);

            json.put("status", "success");
            json.put("message", "");

        }
        catch (Exception ioe) {

            json.put("status", "error");
            json.put("message", ioe.getMessage());

        }

        return json;
    }
}
