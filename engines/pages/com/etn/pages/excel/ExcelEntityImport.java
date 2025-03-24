package com.etn.pages.excel;

import com.etn.pages.excel.ExcelImportFile.ExcelRow;
import com.github.wnameless.json.unflattener.JsonUnflattener;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class ExcelEntityImport {

    protected ExcelImportFile excelFile;

    public ExcelEntityImport(File excelFile) throws IOException, InvalidFormatException {
        init(excelFile);
    }

    protected void init(File file) throws IOException, InvalidFormatException {
        if (!file.exists() && !file.isFile()) {
            throw new FileNotFoundException("Invalid excel file");
        }
        else {
            this.excelFile = new ExcelImportFile(file);
        }

        //check mandatory column
        if (!excelFile.getColumnIndexMap().containsKey("item_type")) {
            throw new InvalidFormatException("Mandatory column item_type not found");
        }

    }

    public ExcelImportFile getExcelFile() {
        return excelFile;
    }

    public void setExcelFile(ExcelImportFile excelFile) {
        this.excelFile = excelFile;
    }

    public JSONArray getItemsList() {
        JSONArray items = new JSONArray();

        for (int i = 0; i < excelFile.getRowCount(); i++) {
            ExcelRow row = excelFile.getRow(i);
            JSONObject itemObj;
            String itemType = row.getColumnValue("item_type").orElse("Not Found");
            try {
                itemObj = getItemJson(row, itemType);
                itemObj.put("item_type",itemType);
            }
            catch (Exception ex) {
                ex.printStackTrace();
                itemObj = new JSONObject();
                itemObj.put("item_type", itemType);
                itemObj.put("system_info", new JSONObject()
                    .put("name", row.getColumnValue("name").orElse("")));
            }
            items.put(itemObj);
        }
        return items;
    }

    protected JSONObject getItemJson(ExcelImportFile.ExcelRow row, String itemType) throws Exception {
        JSONObject retObj = null;

        switch (itemType) {
            case "bloc_template":
                retObj = getBlocTemplateJson(row);
                break;
            case "bloc":
                retObj = getBlocExportJson(row);
                break;
            case "freemarker_page":
            case "page":
                retObj = getFreemarkerPageExportJson(row);
                break;
            case "page_template":
                retObj = getPageTemplateExportJson(row);
                break;
            case "library":
                retObj = getLibraryExportJson(row);
                break;
            case "structured_content":
                retObj = getStructuredData(row);
                break;
            case "store":
                retObj = getStoreExportJson(row);
                break;
            case "structured_page":
                retObj = getStructuredPageExportJson(row);
                break;
            case "variable":
                retObj = getVariableExportJson(row);
                break;
            // case "catalogs":
            //     retObj = getCommercialCatalogExportJson(id);
            //     break;
            // case "products":
            //     retObj = getCommercialProductExportJson(id);
            //     break;
            // case "forms":
            //     retObj = getFormExportJson(id);
            //     break;
            default:
                throw new Exception("Invalid or Unsupported item type: " + itemType);
        }

        return retObj;

    }

    // this will remove null form json array
    protected JSONArray getCleanJsonArray(JSONObject jsonObject, String key){
        JSONArray retJsonArray = new JSONArray();
        if(jsonObject.optJSONArray(key) != null){
            for(Object obj : jsonObject.getJSONArray(key)){
                if(obj != null){
                    retJsonArray.put(obj);
                }
            }
        }
        return  retJsonArray;
    }

    protected JSONArray getSimpleJsonArrayFromRow(ExcelImportFile.ExcelRow row, String prefix, String[] attributes){
        try{
            int index = 0;
            JSONArray retArray = new JSONArray();
            Optional<String> value;
            if(attributes != null && attributes.length > 1){
                value = row.getColumnValue(prefix + "[" + index + "]." + attributes[0]);
            } else{
                value = row.getColumnValue(prefix+"[" + index + "]");
            }
            while (value.isPresent() && value.get().length() > 0) {
                JSONObject attObject = new JSONObject();
                if(attributes != null){
                    for (String attr : attributes) {
                        if(attr.equals("head_files") || attr.equals("body_files")){
                            attObject.put(attr,getSimpleJsonArrayFromRow(row, prefix + "[" + index + "]." + attr, new String[]{"name", "type"}));
                        }else{
                            attObject.put(attr, row.getColumnValue(prefix + "[" + index + "]." + attr).orElse(""));
                        }
                    }
                    retArray.put(attObject);
                } else{
                    retArray.put(value.get());
                }

                index++;
                if(attributes != null && attributes.length > 1){
                    value = row.getColumnValue(prefix + "[" + index + "]." + attributes[0]);
                } else{
                    value = row.getColumnValue(prefix+"[" + index + "]");
                }
            }
            return retArray;
        } catch (Exception ex){
            return new JSONArray();
        }
    }

    protected JSONObject getFolderJson(ExcelImportFile.ExcelRow row, String keyPrefix) {
        JSONObject folder = new JSONObject();
        keyPrefix += ".";

        String name = row.getColumnValue(keyPrefix+"name").orElse("");

        if(name.length() > 0){
            folder.put("name", name);
            folder.put("uuid", row.getColumnValue(keyPrefix+"uuid").orElse(""));
            
            folder.put("dl_page_type", row.getColumnValue(keyPrefix+"dl_page_type").orElse(""));
            folder.put("dl_sub_level_1", row.getColumnValue(keyPrefix+"dl_sub_level_1").orElse(""));
            folder.put("dl_sub_level_2", row.getColumnValue(keyPrefix+"dl_sub_level_2").orElse(""));

            JSONArray details = getSimpleJsonArrayFromRow(row, keyPrefix+"details", new String[]{"langue_code", "path_prefix"});
            folder.put("details", details);
            // get parent folder
            String parentFolederName = row.getColumnValue(keyPrefix+"parent.name").orElse("");
            if(parentFolederName.length() > 0){
                JSONObject parentFolder = getFolderJson(row, keyPrefix+"parent");
                folder.put("parent_folder", parentFolder);
            }
        }
        return folder;
    }

    protected JSONObject getCommonInternalInfo(ExcelImportFile.ExcelRow row, String keyPrefix) {
        keyPrefix += ".";

        JSONObject internalInfo = new JSONObject();
        internalInfo.put("created_ts", row.getColumnValue("created_ts").orElse(""));
        internalInfo.put("updated_ts", row.getColumnValue("updated_ts").orElse(""));
        internalInfo.put("id", row.getColumnValue(keyPrefix+"id").orElse(""));
        internalInfo.put("site_id", row.getColumnValue(keyPrefix+"site_id").orElse(""));
        internalInfo.put("created_by", row.getColumnValue(keyPrefix+"created_by").orElse(""));
        internalInfo.put("updated_by", row.getColumnValue(keyPrefix+"updated_by").orElse(""));
        return internalInfo;
    }

    protected JSONObject getPageSettings(ExcelImportFile.ExcelRow row, String colPrefix){
        try{
            JSONObject pageSetting = new JSONObject();
            if(colPrefix.length()>0) colPrefix += ".";
            String template =  row.getColumnValue(colPrefix+"template").orElse("");
            String variant = row.getColumnValue(colPrefix+"variant").orElse("");
            String path = row.getColumnValue(colPrefix+"path").orElse("");
            if(template.length() > 0 && variant.length()>0 && path.length()>0){
                // system_info
                JSONObject sysInfo = new JSONObject();
                sysInfo.put("template", template);
                sysInfo.put("path", path);
                sysInfo.put("variant", variant);
                sysInfo.put("folder_name", row.getColumnValue(colPrefix+"folder_name").orElse(""));
                sysInfo.put("full_path", row.getColumnValue(colPrefix+"full_path").orElse(""));

                 // meta tags
                JSONObject metaInfo = new JSONObject();
                metaInfo.put("meta_description", row.getColumnValue(colPrefix+"meta_description").orElse(""));
                metaInfo.put("canonical_url", row.getColumnValue(colPrefix+"canonical_url").orElse(""));
                metaInfo.put("title", row.getColumnValue(colPrefix+"meta_title").orElse(""));
                metaInfo.put("meta_keywords", row.getColumnValue(colPrefix+"meta_keywords").orElse(""));
                metaInfo.put("custom_meta_tags", getSimpleJsonArrayFromRow(row, colPrefix+"custom_meta_tags", new String[]{"meta_name", "meta_content"}));

                // internal info
                JSONObject internalInfo = getCommonInternalInfo(row, colPrefix+"internal_info");
                internalInfo.put("page_type", row.getColumnValue(colPrefix+"internal_info.page_type").orElse(""));
                internalInfo.put("page_type", row.getColumnValue(colPrefix+"internal_info.page_type").orElse(""));
                // data layer data
                internalInfo.put("dl_page_type", row.getColumnValue(colPrefix+"internal_info.dl_page_type").orElse(""));
                internalInfo.put("dl_sub_level_1", row.getColumnValue(colPrefix+"internal_info.dl_sub_level_1").orElse(""));
                internalInfo.put("dl_sub_level_2", row.getColumnValue(colPrefix+"internal_info.dl_sub_level_2").orElse(""));

                JSONArray tags = getSimpleJsonArrayFromRow(row, colPrefix+"tags", new String[]{"id", "label"});

                pageSetting.put("tags", tags);
                pageSetting.put("system_info", sysInfo);
                pageSetting.put("meta_info", metaInfo);
                pageSetting.put("internal_info", internalInfo);
            }
            return pageSetting;
        } catch (Exception ex){
            return  new JSONObject();
        }
    }

    protected JSONObject getStructuredExportJson(ExcelImportFile.ExcelRow row, String type) {
        JSONObject retObj = new JSONObject();

        JSONObject sysInfo = new JSONObject();
        sysInfo.put("folder", getFolderJson(row, "folder"));
        sysInfo.put("name", row.getColumnValue("name").orElse(""));
        sysInfo.put("template_id", row.getColumnValue("template_id").orElse(""));
        sysInfo.put("folder_name", row.getColumnValue("folder_name").orElse(""));
        sysInfo.put("type", row.getColumnValue("type").orElse(""));

        JSONObject internalInfo = getCommonInternalInfo(row,"internal_info");
        internalInfo.put("uuid", row.getColumnValue("internal_info.uuid").orElse(""));

        JSONArray details = new JSONArray();
        int coutner = 0;
        String lang = row.getColumnValue("details["+coutner+"].langue_code").orElse("");

        while(lang.length() > 0){
            JSONObject detailObj = new JSONObject();
            detailObj.put("langue_code", lang);
            JSONObject templateObj  =  getJsonFromRow("details["+coutner+"].template_data.", row, "details["+coutner+"]");
            JSONObject templateData = templateObj.optJSONObject("template_data");
            if(templateData == null){
                templateData = new JSONObject();
            }
            detailObj.put("template_data", templateData);
            if(!type.equals("content")){
                JSONObject pageSettings = getPageSettings(row,"details["+coutner+"].page_settings");
                detailObj.put("page_settings", pageSettings);
            }
            details.put(detailObj);
            coutner++;
            lang = row.getColumnValue("details["+coutner+"].langue_code").orElse("");
        }

        retObj.put("system_info", sysInfo);
        retObj.put("details", details);
        retObj.put("internal_info", internalInfo);
        return retObj;
    }
    protected JSONObject getVariableExportJson(ExcelImportFile.ExcelRow row) {
        JSONObject retObj = new JSONObject();
        JSONObject sysObj = new JSONObject();
        sysObj.put("name", row.getColumnValue("name").orElse(""));
        sysObj.put("value", row.getColumnValue("value").orElse(""));
        sysObj.put("is_editable", row.getColumnValue("is_editable").orElse(""));
        sysObj.put("id", row.getColumnValue("id").orElse(""));

        retObj.put("system_info", sysObj);
        return retObj;
    }

    protected JSONObject getStructuredPageExportJson(ExcelImportFile.ExcelRow row) {
        JSONObject retObj = getStructuredExportJson(row, "page");
        retObj.put("item_type", "structured_page");
        return retObj;
    }

    protected JSONObject getStoreExportJson(ExcelImportFile.ExcelRow row) {
        JSONObject retObj = getStructuredExportJson(row, "store");
        retObj.put("item_type", "store");
        return retObj;
    }

    protected JSONObject getStructuredData(ExcelImportFile.ExcelRow row) {
        JSONObject retObj = getStructuredExportJson(row,"content");
        retObj.put("item_type", "structured_content");
        return retObj;
    }

    protected JSONObject getBlocExportJson(ExcelImportFile.ExcelRow row){
        JSONObject retObj = new JSONObject();
        retObj.put("item_type", "bloc");

        JSONObject sysInfo = new JSONObject();
        sysInfo.put("name", row.getColumnValue("name").orElse(""));
        sysInfo.put("id", row.getColumnValue("id").orElse(""));
        sysInfo.put("template_id", row.getColumnValue("template_id").orElse(""));
        sysInfo.put("description", row.getColumnValue("description").orElse(""));
        String rssFeedsSort = row.getColumnValue("rss_feed_sort").orElse("");
        if(rssFeedsSort.length()>0){
            sysInfo.put("rss_feed_sort", rssFeedsSort);
            sysInfo.put("rss_feeds",getSimpleJsonArrayFromRow(row, "rss_feeds", null));
        }


        JSONArray detailsLang = new JSONArray();
        int index = 0;
        String langCode = row.getColumnValue("details_lang["+index+"].langue_code").orElse("");
        while(langCode.length() > 0){
            JSONObject detailData = new JSONObject();
            detailData.put("langue_code", langCode);
            // get section data
            String colPrefix = "details_lang["+index+"].sections_data.";
            JSONObject sectionsDataJson =  getJsonFromRow(colPrefix,  row, "details_lang["+index+"]");
            JSONObject sectionsData = sectionsDataJson.optJSONObject("sections_data");
            if(sectionsData == null){
                sectionsData = new JSONObject();
            }
            detailData.put("sections_data", sectionsData);
            detailsLang.put(detailData);
            index++;
            langCode = row.getColumnValue("details_lang["+index+"].langue_code").orElse("");
        }
        JSONArray tags = getSimpleJsonArrayFromRow(row, "tags", new String[]{"id", "label"});

        JSONObject internalInfo = getCommonInternalInfo(row, "internal_info");

        JSONObject parameters = new JSONObject();
        parameters.put("end_date", row.getColumnValue("parameters.end_date").orElse(""));
        parameters.put("margin_bottom", row.getColumnValue("parameters.margin_bottom").orElse(""));
        parameters.put("refresh_interval", row.getColumnValue("parameters.refresh_interval").orElse(""));
        parameters.put("margin_top", row.getColumnValue("parameters.margin_top").orElse(""));
        parameters.put("start_date",row.getColumnValue("parameters.start_date").orElse(""));

        retObj.put("tags", tags);
        retObj.put("parameters", parameters);
        retObj.put("system_info", sysInfo);
        retObj.put("details_lang", detailsLang);
        retObj.put("internal_info", internalInfo);

        return retObj;
    }

    protected JSONObject getPageTemplateExportJson(ExcelImportFile.ExcelRow row) {
        JSONObject retObj = new JSONObject();
        retObj.put("item_type", "page_template");

        JSONObject sysInfo = new JSONObject();
        sysInfo.put("is_system", row.getColumnValue("is_system").orElse("0"));
        sysInfo.put("name", row.getColumnValue("name").orElse(""));
        sysInfo.put("custom_id", row.getColumnValue("custom_id").orElse(""));
        sysInfo.put("description", row.getColumnValue("description").orElse(""));
        // detail
        JSONObject details = new JSONObject();

        int counter = 0;
        JSONArray items = new JSONArray();
        String name = row.getColumnValue("items["+counter+"].name").orElse("");
        String custom_id = row.getColumnValue("items["+counter+"].custom_id").orElse("");
        while (name.length()> 0 &&  custom_id.length()>0){
            JSONObject item = new JSONObject();
            String sort_order  = row.getColumnValue("items["+counter+"].sort_order").orElse("");
            item.put("name",name);
            item.put("custom_id",custom_id);
            item.put("sort_order", sort_order);

            String colPrefix = "items["+counter+"].item_details[";
            JSONObject itemsDetailsJson =  getJsonFromRow(colPrefix,  row, "items["+counter+"]");
            JSONArray itemsDetails = getCleanJsonArray(itemsDetailsJson , "item_details");

            item.put("item_details", itemsDetails);
            items.put(item);
            counter++;
            name = row.getColumnValue("items["+counter+"].name").orElse("");
            custom_id = row.getColumnValue("items["+counter+"].custom_id").orElse("");
        }

        details.put("items", items);
        details.put("template_code", row.getColumnValue("template_code").orElse(""));

        JSONObject internalInfo = getCommonInternalInfo(row, "internal_info");
        internalInfo.put("uuid", row.getColumnValue("internal_info.uuid").orElse(""));

        retObj.put("system_info", sysInfo);
        retObj.put("details", details);
        retObj.put("internal_info", internalInfo);

        return retObj;
    }

    protected JSONObject getLibraryExportJson(ExcelImportFile.ExcelRow row) {
        JSONObject retObj = new JSONObject();
        retObj.put("item_type", "library");

        JSONObject sysInfo = new JSONObject();
        sysInfo.put("name", row.getColumnValue("name").orElse(""));

        JSONObject internalInfo = new JSONObject();

        JSONArray detailsLang = getSimpleJsonArrayFromRow(row, "detail_langs", new String[]{"language_code", "body_files","head_files"});

        retObj.put("system_info", sysInfo);
        retObj.put("detail_langs", detailsLang);
        retObj.put("internal_info", internalInfo);

        return retObj;
    }

    protected JSONArray getBlocSectionFields(ExcelImportFile.ExcelRow row, String prefix){
         if(prefix.length()>0){
             prefix += ".";
         }
         JSONArray fields =  new JSONArray();
         int index = 0;
         String customId =  row.getColumnValue(prefix+"fields["+index+"].custom_id").orElse("");
         String name =  row.getColumnValue(prefix+"fields["+index+"].name").orElse("");

         while(customId.length() > 0 && name.length() > 0){
             JSONObject field = new JSONObject();
             field.put("custom_id",customId);
             field.put("name", name);
             field.put("is_system",row.getColumnValue(prefix+"fields["+index+"].is_system").orElse(""));
             field.put("nb_items",row.getColumnValue(prefix+"fields["+index+"].nb_items").orElse(""));
             field.put("type",row.getColumnValue(prefix+"fields["+index+"].type").orElse(""));
             field.put("sort_order",row.getColumnValue(prefix+"fields["+index+"].sort_order").orElse(""));
             field.put("value",row.getColumnValue(prefix+"fields["+index+"].value").orElse(""));
             field.put("is_indexed",row.getColumnValue(prefix+"fields["+index+"].is_indexed").orElse(""));
             field.put("is_required",row.getColumnValue(prefix+"fields["+index+"].is_required").orElse(""));
             field.put("is_meta_variable", row.getColumnValue(prefix+"fields["+index+"].is_meta_variable").orElse(""));

             JSONArray langData = new JSONArray();
             int i  = 0;
             String langCode = row.getColumnValue(prefix+"fields["+index+"].lang_data["+i+"].langue_code").orElse("");
             while(langCode.length() > 0){
                 JSONObject data = new JSONObject();
                 data.put("langue_code", row.getColumnValue(prefix+"fields["+index+"].lang_data["+i+"].langue_code").orElse(""));
                 data.put("default_value", row.getColumnValue(prefix+"fields["+index+"].lang_data["+i+"].default_value").orElse(""));
                 data.put("placeholder", row.getColumnValue(prefix+"fields["+index+"].lang_data["+i+"].placeholder").orElse(""));
                 data.put("langue_id", row.getColumnValue(prefix+"fields["+index+"].lang_data["+i+"].langue_id").orElse(""));
                 langData.put(data);
                 i++;
                 langCode = row.getColumnValue(prefix+"fields["+index+"].lang_data["+i+"].langue_code").orElse("");
             }

             field.put("lang_data", langData);
             fields.put(field);
             index++;
             customId =  row.getColumnValue(prefix+"fields["+index+"].custom_id").orElse("");
             name =  row.getColumnValue(prefix+"fields["+index+"].name").orElse("");
         }
         return fields;
    }

    protected JSONArray getBlocSections(ExcelImportFile.ExcelRow row, String prefix){
        if(prefix.length() > 0){
            prefix += ".";
        }
        JSONArray sectionsList = new JSONArray();
        int counter = 0;
        String secName =  row.getColumnValue(prefix+"sections["+counter+"].name").orElse("");
        String secCustomId = row.getColumnValue(prefix+"sections["+counter+"].custom_id").orElse("");

        while (secName.length() > 0 && secCustomId.length() > 0) {
            JSONObject section = new JSONObject();
            String is_system = row.getColumnValue(prefix+"sections["+counter+"].is_system").orElse("");
            String nb_items = row.getColumnValue(prefix+"sections["+counter+"].nb_items").orElse("");
            JSONArray fields = getBlocSectionFields(row, prefix+"sections["+counter+"]");
            JSONArray nestedSections = getBlocSections(row, prefix+"sections["+counter+"]");

            section.put("fields", fields);
            section.put("name", secName);
            section.put("custom_id", secCustomId);
            section.put("is_system", is_system);
            section.put("nb_items", nb_items);
            section.put("sections", nestedSections);
            sectionsList.put(section);
            counter++;
            secName = row.getColumnValue(prefix+"sections["+counter+"].name").orElse("");
            secCustomId = row.getColumnValue(prefix+"sections["+counter+"].custom_id").orElse("");
        }
        return sectionsList;
    }


    protected JSONObject getFreemarkerPageExportJson(ExcelImportFile.ExcelRow row) {
        JSONObject retObj = new JSONObject();
        int coutner = 0;
        String lang = row.getColumnValue("details["+coutner+"].langue_code").orElse("");
        if(lang.length() == 0){ // old single line structure
            retObj = getPageSettings(row, "");
            retObj.getJSONObject("system_info").put("name", row.getColumnValue("name").orElse(""));
            retObj.getJSONObject("system_info").put("langue_code", row.getColumnValue("langue_code").orElse(""));
            retObj.getJSONObject("system_info").put("name", row.getColumnValue("name").orElse(""));
            retObj.getJSONObject("system_info").put("folder", getFolderJson(row, "folder"));
        } else{ // new structure with multi languages
            JSONObject sysInfo = new JSONObject();

            sysInfo.put("folder", getFolderJson(row, "folder"));
            sysInfo.put("name", row.getColumnValue("name").orElse(""));
            sysInfo.put("folder_name", row.getColumnValue("folder_name").orElse(""));

            JSONObject internalInfo = getCommonInternalInfo(row,"internal_info");
            internalInfo.put("uuid", row.getColumnValue("internal_info.uuid").orElse(""));
            JSONArray details = new JSONArray();

            // in case of old structure then there will be no detail object
            while(lang.length() > 0){
                JSONObject detailObj = new JSONObject();
                JSONObject pageSettings = getPageSettings(row,"details["+coutner+"].page_settings");
                detailObj.put("langue_code", lang);
                detailObj.put("page_settings", pageSettings);
                details.put(detailObj);
                coutner++;
                lang = row.getColumnValue("details["+coutner+"].langue_code").orElse("");
            }

            if(details.length() > 0){
                retObj.put("details", details);
            }
            retObj.put("system_info", sysInfo);
            retObj.put("internal_info", internalInfo);
        }
        JSONArray blocs = getSimpleJsonArrayFromRow(row, "blocs", null);
        retObj.put("blocs", blocs);
        retObj.put("item_type", "freemarker_page");

        return retObj;
    }

    protected JSONObject getBlocTemplateJson(ExcelImportFile.ExcelRow row) {
        JSONObject retObj = new JSONObject();
        retObj.put("item_type", "bloc_template");

        JSONObject sysInfo = new JSONObject();
        sysInfo.put("name", row.getColumnValue("name").orElse(""));
        sysInfo.put("custom_id", row.getColumnValue("custom_id").orElse(""));
        sysInfo.put("type", row.getColumnValue("type").orElse(""));
        sysInfo.put("description", row.getColumnValue("description").orElse(""));


        JSONObject resources = new JSONObject();

        resources.put("code", row.getColumnValue("resources.code").orElse(""));
        resources.put("js", row.getColumnValue("resources.js").orElse(""));
        resources.put("css", row.getColumnValue("resources.css").orElse(""));
        resources.put("jsonld", row.getColumnValue("resources.jsonld").orElse(""));

        JSONArray libraries = getSimpleJsonArrayFromRow(row,"resources.libraries", null);
        resources.put("libraries", libraries);

        JSONObject internalInfo = getCommonInternalInfo(row, "internal_info");

        retObj.put("system_info", sysInfo);
        retObj.put("resources", resources);
        retObj.put("internal_info", internalInfo);
        retObj.put("sections", getBlocSections(row, ""));

        return retObj;
    }

    protected JSONObject getJsonFromRow(String colPrefix, ExcelRow row) {
        return getJsonFromRow(colPrefix, row, "");
    }

    protected JSONObject getJsonFromRow(String colPrefix,
                                        ExcelRow row,
                                        String filterHeader) {
        try {
            // filterHeader.replaceFirst("[", "")
            Map<String, String> map = row.getColumnValueMap(colPrefix);
            Map<String, Object> objMap = map.entrySet().parallelStream()
                .collect(Collectors.toMap( e-> {
                    if(e.getKey().startsWith(filterHeader+".")){
                        return e.getKey().replaceFirst(Pattern.quote(filterHeader+ ".") , "");
                    }
                    return  e.getKey();
                } , e -> {
                    String value = e.getValue();
                    Object retVal = value;

                    if ("[]".equals(value)) {
                        retVal = new ArrayList<>();
                    }
                    else if ("{}".equals(value)) {
                        retVal = new HashMap<String, Object>();
                    }
                    return retVal;
                }));
            return new JSONObject(JsonUnflattener.unflatten(objMap));
        }
        catch (Exception ex) {
            return new JSONObject();
        }
    }

}
