package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import org.json.JSONArray;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * @author Ali Adnan
 */
public class TemplateDataGenerator extends BaseClass {

    protected String siteId = "1";
    protected String UPLOADS_URL_PREFIX = "";
    protected List<Map.Entry<String, String>> indexedList = new ArrayList<>();
    protected boolean isIndexedDataOnly = false;
    protected boolean isMetaVariableDataOnly = false;
    protected boolean generateForPublish = false;

    protected JSONArray jProductViewArr = null;

    protected HashMap<String, String> filterByOperatorMap = new HashMap<String, String>() {
        {
            put("is", "=");
            put("not_is", "!=");
            put("greater_than", ">");
            put("greater_than_or_equal", ">=");
            put("less_than", "<");
            put("less_than_or_equal", "<=");
            put("like", "LIKE");
            put("not_like", "NOT LIKE");
            put("starts_with", "LIKE");
            put("not_starts_with", "NOT LIKE");
            put("ends_with", "LIKE");
            put("not_ends_with", "NOT LIKE");
        }

    };

    public TemplateDataGenerator(Etn Etn, Properties env, boolean debug, String siteId) {
        super(Etn, env, debug);
        this.init(siteId);
    }

    public TemplateDataGenerator(Etn Etn, String siteId) {
        super(Etn);
        this.init(siteId);
    }

    protected void init(String siteId) {
        try {
            this.siteId = siteId;

            String CONTEXT_PATH = getParm("EXTERNAL_LINK");
            String UPLOADS_FOLDER = getParm("UPLOADS_FOLDER") + siteId + "/";
            this.UPLOADS_URL_PREFIX = CONTEXT_PATH + UPLOADS_FOLDER;
        }
        catch (Exception ignored) {
        }
    }

    public boolean isGenerateForPublish() {
        return generateForPublish;
    }

    public void setGenerateForPublish(boolean generateForPublish) {
        this.generateForPublish = generateForPublish;
    }

    public boolean isMetaVariableDataOnly() {
        return isMetaVariableDataOnly;
    }

    public void setMetaVariableDataOnly(boolean metaVariableDataOnly) {
        isMetaVariableDataOnly = metaVariableDataOnly;
    }

    public String getSiteId() {
        return siteId;
    }

    public void setSiteId(String siteId) {
        this.siteId = siteId;
    }

    public List<Map.Entry<String, String>> getIndexedList() {
        return indexedList;
    }

    public void setIndexedDataOnly(boolean indexedDataOnly) {
        isIndexedDataOnly = indexedDataOnly;
    }

    public boolean isIndexedDataOnly() {
        return isIndexedDataOnly;
    }

    public String getFilterByOperator(String key) {
        return filterByOperatorMap.getOrDefault(key, "");
    }

    public HashMap<String, Object> getBlocTemplateDataMap(String templateId,JSONObject dataJson,HashMap<String, String> tagsHM, String langId) throws Exception {
        return getBlocTemplateDataMap(templateId,dataJson,tagsHM,langId,false);
    }

    public HashMap<String, Object> getBlocTemplateDataMap(String templateId,JSONObject dataJson,HashMap<String, String> tagsHM, String langId,boolean isGenerateForPublish) throws Exception {
        indexedList.clear();
        HashMap<String, Object> dataHM = new HashMap<>();
        //we always reset this as this function is called for each bloc and not every bloc can have a view_commercial_products field(s) in it
        jProductViewArr = null;

        JSONArray sectionsList = PagesUtil.getBlocTemplateSectionsData(Etn, templateId);
        generateSectionsDataMap(dataHM, sectionsList, dataJson, tagsHM, langId,isGenerateForPublish);
        return dataHM;
    }

    public void generateSectionsDataMap(HashMap<String, Object> parentHM, JSONArray sectionsList,JSONObject dataJson, HashMap<String, String> tagsHM, String langId) {
        generateSectionsDataMap(parentHM,sectionsList,dataJson,tagsHM,langId,false);
    }

    public void generateSectionsDataMap(HashMap<String, Object> parentHM, JSONArray sectionsList,JSONObject dataJson, HashMap<String, String> tagsHM, String langId,boolean isGenerateForPublish) {

        for (int i = 0; i < sectionsList.length(); i++) {
            JSONObject sectionCode = sectionsList.getJSONObject(i);
            String sectionId = sectionCode.getString("custom_id");
            int sectionNbItems = sectionCode.getInt("nb_items");
            JSONArray secDataArray = dataJson.optJSONArray(sectionId);

            if (secDataArray == null) secDataArray = new JSONArray();

            int maxSectionCount = secDataArray.isEmpty() ? 1 : secDataArray.length();
            if (sectionNbItems > 0 && sectionNbItems < maxSectionCount) maxSectionCount = sectionNbItems;

            ArrayList<HashMap<String, Object>> sectionDataMapsList = new ArrayList<>(maxSectionCount);
            for (int j = 0; j < maxSectionCount; j++) {
                JSONObject curSectionData = secDataArray.optJSONObject(j);
                if (curSectionData == null) curSectionData = new JSONObject(); //empty

                HashMap<String, Object> sectionDataMap = getSectionDataMap(sectionCode, curSectionData, tagsHM, langId,isGenerateForPublish);
                sectionDataMapsList.add(sectionDataMap);
            }//for maxSectionCount

            if (sectionNbItems == 1 && !sectionDataMapsList.isEmpty()) parentHM.put(sectionId, sectionDataMapsList.get(0));
            else parentHM.put(sectionId, sectionDataMapsList);
        }
    }

    public HashMap<String, Object> getSectionDataMap(JSONObject sectionCode,JSONObject curSectionData,HashMap<String, String> tagsHM,String langId) {
        return getSectionDataMap(sectionCode,curSectionData,tagsHM,langId,false);
    }

    public HashMap<String, Object> getSectionDataMap(JSONObject sectionCode,JSONObject curSectionData,HashMap<String, String> tagsHM,String langId,boolean isGenerateForPublish) {
        HashMap<String, Object> sectionDataHM = new HashMap<>();

        JSONArray sectionFields = sectionCode.getJSONArray("fields");

        for (int i = 0; i < sectionFields.length(); i++) {

            JSONObject fieldObj = sectionFields.getJSONObject(i);

            String fieldId = fieldObj.getString("custom_id");
            int fieldNbItems = fieldObj.getInt("nb_items");
            String fieldType = fieldObj.getString("type").toLowerCase();
            boolean fieldIsIndexed = "1".equals(fieldObj.getString("is_indexed"));
            boolean fieldIsMetaVariable = "1".equals(fieldObj.getString("is_meta_variable"));

            if (isIndexedDataOnly && !fieldIsIndexed) continue;//skip this un-indexed field
            if (isMetaVariableDataOnly && !fieldIsMetaVariable) continue;//skip this non meta_variable field

            JSONArray fieldDataArray = curSectionData.optJSONArray(fieldId);
            if (fieldDataArray == null) fieldDataArray = new JSONArray();//empty

            int maxFieldCount = fieldDataArray.isEmpty() ? 1 : fieldDataArray.length();
            if (fieldNbItems > 0 && fieldNbItems < maxFieldCount) maxFieldCount = fieldNbItems;

            ArrayList<Object> fieldDataList = new ArrayList<>();
            //for secondary additional field data if present e.g. image, url, date,etc
            ArrayList<Object> fieldDataList2 = new ArrayList<>();
            //for secondary additional field data if present e.g. url 
            ArrayList<Object> fieldDataList3 = new ArrayList<>();

            String defaultValue = "";
            if(fieldObj.has("lang_data")) {
                for(int k=0;k<fieldObj.getJSONArray("lang_data").length();k++) {
                    JSONObject langData = fieldObj.getJSONArray("lang_data").getJSONObject(k);
                    if(langId.equals(langData.getString("langue_id"))) {
                        defaultValue = langData.optString("default_value", "");
                        break;
                    }
                }
            }

            for (int j = 0; j < maxFieldCount; j++) {
                Object curFieldValue = "";
                boolean useDefaultValue = fieldDataArray.isNull(j);

                if ("image".equalsIgnoreCase(fieldType)) {
                    String imgValue = "";
                    String imgAlt = "";
                    if (!useDefaultValue) {
                        JSONObject imgObj = fieldDataArray.optJSONObject(j);
                        if (imgObj != null && imgObj.has("value") && imgObj.has("alt")) {
                            imgValue = imgObj.getString("value");
                            imgAlt = imgObj.getString("alt");
                        }
                    } else {
                        String[] defValue = defaultValue.split(",");
                        if (defValue.length >= 2) {
                            imgValue = defValue[0].trim();
                            imgAlt = defValue[1].trim();
                        }
                    }

                    if (!imgValue.isEmpty()) {
                        String fQuery = "SELECT * from files WHERE file_name = " + escape.cote(imgValue)+" and type='img' and site_id="+escape.cote(siteId)+
                                " and (COALESCE(removal_date,'') = '' or  removal_date > now())";
                        Set fileRs = Etn.execute(fQuery);
                        if (fileRs.next()) {
                            String directory = "/";
                            if(!fieldObj.getString("value").isEmpty() && !fieldObj.getString("value").equalsIgnoreCase("free")){
                                directory = "/cropped/"+fieldObj.getString("value") +"/";
                            }
                            curFieldValue = UPLOADS_URL_PREFIX + "img" +  directory + imgValue;
                        }
                    }

                    fieldDataList2.add(imgAlt);
                } else if ("tag".equalsIgnoreCase(fieldType)) {

                    JSONArray tagsArray = fieldDataArray.optJSONArray(j);
                    if (useDefaultValue) {
                        tagsArray = null;
                        try {
                            tagsArray = new JSONArray(defaultValue);
                        } catch (Exception ignored) {}
                    }
                    ArrayList<String> tagsDataList = new ArrayList<>();
                    ArrayList<String> curTagsIdList = new ArrayList<>();

                    if (tagsArray != null) {
                        for (int k = 0; k < tagsArray.length(); k++) {
                            String curTagId = tagsArray.getString(k).trim();
                            String curTag = tagsHM.getOrDefault(curTagId, "");
                            if (!curTag.isEmpty()) {
                                tagsDataList.add(curTag);
                                curTagsIdList.add(curTagId);
                            }
                        }
                    }

                    curFieldValue = tagsDataList;
                    fieldDataList2.add(curTagsIdList);
                } else if ("date".equalsIgnoreCase(fieldType)) {
                    JSONArray dateValArray = fieldDataArray.optJSONArray(j);
                    if (useDefaultValue) {
                        dateValArray = null;
                        try {
                            dateValArray = new JSONArray(defaultValue);
                        }
                        catch (Exception ignored) {}
                    }

                    String dateStart = "";
                    String dateEnd = "";
                    if (dateValArray != null) {
                        dateStart = dateValArray.optString(0, "");
                        dateEnd = dateValArray.optString(1, "");
                    }

                    String dateFormat = new JSONObject(fieldObj.getString("value")).getString("date_format");
                    if (!dateStart.isEmpty()) curFieldValue = PagesUtil.getFormattedDate(dateStart, dateFormat);
                    else curFieldValue = dateStart;

                    if (!dateEnd.isEmpty()) fieldDataList2.add(PagesUtil.getFormattedDate(dateEnd, dateFormat));
                    else fieldDataList2.add(dateEnd);

                } else if ("url".equalsIgnoreCase(fieldType)) {
                    if (!useDefaultValue) {
                        JSONObject urlValObj = fieldDataArray.optJSONObject(j);

                        if (urlValObj != null) {
                            curFieldValue = urlValObj.optString("value", "");
                            fieldDataList2.add(urlValObj.optString("openType", ""));
                            fieldDataList3.add(urlValObj.optString("label", ""));
                        } else {
                            curFieldValue = fieldDataArray.optString(j, "");
                            fieldDataList2.add("same_window");
                            fieldDataList3.add("");
                        }
                    } else {
                        JSONArray defValArray = null;
                        try {
                            defValArray = new JSONArray(defaultValue);
                        } catch (Exception ignored) {}

                        if (defValArray != null) {
                            curFieldValue = defValArray.optString(0, "");
                            fieldDataList2.add(defValArray.optString(1, "same_window"));
                        } else {
                            curFieldValue = defaultValue;
                            fieldDataList2.add("same_window");
                        }
                    }
                } 
                else if ("bloc".equalsIgnoreCase(fieldType)) {
                    PagesGenerator pg = new PagesGenerator(Etn, env, false);
                    String blocTmpId="";
                    if (!useDefaultValue) {
                        JSONObject blocValObj = fieldDataArray.optJSONObject(j);
                        if (blocValObj != null) blocTmpId = blocValObj.optString("bloc_id", "0");
                    } else {
                        JSONObject defObj = null;
                        try {
                            defObj = new JSONObject(defaultValue);
                        } catch (Exception ignored) {}
                        if (defObj != null) blocTmpId = defObj.optString("bloc_id", "0");
                    }

                    if(!blocTmpId.isEmpty()){
                        try{
                            curFieldValue = pg.getBlocHtmlForBlocField(blocTmpId,"",langId,isGenerateForPublish);
                        } catch (Exception e){
                            System.out.println("TemplateDataGenerator Exception in getBlocMenuHtml===================== ");
                        }
                    }
                } 
                else if ("file".equalsIgnoreCase(fieldType)) {
                    String fileLabel = "";
                    String fileName = fieldDataArray.optString(j, "");
                    if (useDefaultValue) fileName = defaultValue;

                    if (!fileName.isEmpty()) {
                        String fileQ = "SELECT type, label FROM files WHERE file_name = " + escape.cote(fileName)+" and site_id="+escape.cote(siteId)+
                                " and (COALESCE(removal_date,'') = '' or  removal_date>now())";
                        Set fileRs = Etn.execute(fileQ);
                        if (fileRs.next()) {
                            String fileType = fileRs.value("type");
                            fileName = UPLOADS_URL_PREFIX + fileType + "/" + fileName;
                            fileLabel = fileRs.value("label");
                        }else fileName="";
                    }

                    curFieldValue = fileName;
                    fieldDataList2.add(fileLabel);
                } else if (fieldType.startsWith("view_")) {
                    JSONObject viewObj = fieldDataArray.optJSONObject(j);

                    JSONObject viewData = new JSONObject();
                    try {
                        viewData = getViewDataMap(fieldType, viewObj, fieldObj, tagsHM, langId);
                    } catch (Exception ex) {
                        System.out.println("Exception in getting view data of field:" + fieldId);
                    }
                    curFieldValue = viewData.toMap();

                }else if (fieldType.startsWith("product_attribute")) {
                    JSONObject viewObj = fieldDataArray.optJSONObject(j);
                    if(viewObj != null) {
                        String atrImg = viewObj.getString("icon");
                        if (!atrImg.isEmpty()) {
                            String fQuery = "SELECT * from files WHERE file_name = " + escape.cote(atrImg)+" and type='img' and site_id="+escape.cote(siteId)+
                                    " and (COALESCE(removal_date,'') = '' or  removal_date > now())";
                            Set fileRs = Etn.execute(fQuery);
                            if (fileRs.next()) atrImg = UPLOADS_URL_PREFIX + "img/" + atrImg;
                        }
                        viewObj.put("icon",atrImg);

                        curFieldValue = viewObj.toMap();
                    }
                    else curFieldValue = new HashMap<String,Object>();
                } else if (fieldType.startsWith("product_specification")) {
                    JSONObject viewObj = fieldDataArray.optJSONObject(j);
                    if(viewObj != null) curFieldValue = viewObj.toMap();
                    else curFieldValue = new HashMap<String,Object>();
                } else {
                    if (useDefaultValue) curFieldValue = defaultValue;
                    else curFieldValue = fieldDataArray.optString(j, "");
                }

                fieldDataList.add(curFieldValue);
            }

            if (fieldNbItems == 1 && !fieldDataList.isEmpty()) {
                sectionDataHM.put(fieldId, fieldDataList.get(0));
                if (fieldIsIndexed) addIndexedKeyValPair(fieldId, fieldDataList.get(0));
                
                if ("image".equalsIgnoreCase(fieldType)) {
                    sectionDataHM.put(fieldId + "_alt", fieldDataList2.get(0));
                    if (fieldIsIndexed) addIndexedKeyValPair(fieldId + "_alt", fieldDataList2.get(0));
                    
                } else if ("file".equalsIgnoreCase(fieldType)) {
                    sectionDataHM.put(fieldId + "_label", fieldDataList2.get(0));
                    if (fieldIsIndexed) addIndexedKeyValPair(fieldId + "_label", fieldDataList2.get(0));
                    
                } else if ("date".equalsIgnoreCase(fieldType)) {
                    String dateType = new JSONObject(fieldObj.getString("value")).getString("date_type");

                    if("period".equalsIgnoreCase(dateType)) {
                        //if period type , remove the simple entries and add _start and _end entries
                        sectionDataHM.remove(fieldId);
                        sectionDataHM.put(fieldId + "_start", fieldDataList.get(0));
                        sectionDataHM.put(fieldId + "_end", fieldDataList2.get(0));
                        if (fieldIsIndexed) {
                            removeIndexedKeyValPair(fieldId, fieldDataList.get(0));
                            addIndexedKeyValPair(fieldId + "_start", fieldDataList.get(0));
                            addIndexedKeyValPair(fieldId + "_end", fieldDataList2.get(0));
                        }
                    }
                } else if ("tag".equalsIgnoreCase(fieldType)) {
                    sectionDataHM.put(fieldId + "_id", fieldDataList2.get(0));
                    if (fieldIsIndexed) addIndexedKeyValPair(fieldId + "_id", fieldDataList2.get(0));

                } else if ("url".equalsIgnoreCase(fieldType)) {
                    sectionDataHM.put(fieldId + "_openType", fieldDataList2.get(0));
                    if(fieldDataList3.size() > 0)
                    sectionDataHM.put(fieldId + "_label", fieldDataList3.get(0));
                    else
                        sectionDataHM.put(fieldId + "_label", "");
                    if (fieldIsIndexed){ 
                        addIndexedKeyValPair(fieldId + "_openType", fieldDataList2.get(0));
                        if(fieldDataList3.size() > 0)
                        addIndexedKeyValPair(fieldId + "_label", fieldDataList3.get(0));
                    }
                }
            }
            else {
                sectionDataHM.put(fieldId, fieldDataList);
                if (fieldIsIndexed) addIndexedKeyValPair(fieldId, fieldDataList);

                if ("image".equalsIgnoreCase(fieldType)) {
                    sectionDataHM.put(fieldId + "_alt", fieldDataList2);
                    if (fieldIsIndexed) addIndexedKeyValPair(fieldId + "_alt", fieldDataList2);

                } else if ("file".equalsIgnoreCase(fieldType)) {
                    sectionDataHM.put(fieldId + "_label", fieldDataList2);
                    if (fieldIsIndexed) addIndexedKeyValPair(fieldId + "_label", fieldDataList2);

                } else if ("date".equalsIgnoreCase(fieldType)) {
                    String dateType = new JSONObject(fieldObj.getString("value")).getString("date_type");

                    if("period".equalsIgnoreCase(dateType)) {
                        //if period type , remove the simple entries and add _start and _end entries
                        sectionDataHM.remove(fieldId);
                        sectionDataHM.put(fieldId + "_start", fieldDataList);
                        sectionDataHM.put(fieldId + "_end", fieldDataList2);
                        if (fieldIsIndexed) {
                            removeIndexedKeyValPair(fieldId, fieldDataList) ;
                            addIndexedKeyValPair(fieldId + "_start", fieldDataList);
                            addIndexedKeyValPair(fieldId + "_end", fieldDataList2);
                        }
                    }
                } else if ("tag".equalsIgnoreCase(fieldType)) {
                    sectionDataHM.put(fieldId + "_id", fieldDataList2);
                    if (fieldIsIndexed) addIndexedKeyValPair(fieldId + "_id", fieldDataList2);
                } else if ("url".equalsIgnoreCase(fieldType)) {
                    sectionDataHM.put(fieldId + "_openType", fieldDataList2);
                    sectionDataHM.put(fieldId + "_label", fieldDataList3);
                    if (fieldIsIndexed){
                        addIndexedKeyValPair(fieldId + "_openType", fieldDataList2);
                        addIndexedKeyValPair(fieldId + "_label", fieldDataList3);
                    }
                }
            }
        }//for sectionFields
        
        JSONArray nestedSectionsList = sectionCode.getJSONArray("sections");
        generateSectionsDataMap(sectionDataHM, nestedSectionsList, curSectionData, tagsHM, langId);

        return sectionDataHM;
    }

    public JSONObject getViewDataMap(String fieldType, JSONObject viewObj, JSONObject fieldObj, HashMap<String, String> tagsHM, String langId) throws Exception {

        String comparison="";
        JSONObject retDataObj = new JSONObject();
        JSONArray dataList = new JSONArray();
        retDataObj.put("data", dataList);

        JSONArray catalogsList = viewObj.optJSONArray("catalogs");
        JSONArray filterByList = viewObj.optJSONArray("filterBy");
        JSONArray sortByList = viewObj.optJSONArray("sortBy");
        String promotionFilter = viewObj.optString("promotionFilter");
        String subFolder = viewObj.optString("subFolder");

        JSONObject jProductViewObj = null;

        String q = "", exportType = "";
        String CATALOG_DB = getParm("CATALOG_DB");
        if(this.generateForPublish) CATALOG_DB = getParm("PROD_CATALOG_DB");
        switch (fieldType) {
            case "view_commercial_catalogs": {
                exportType = "catalogs";
                final String PROD_CATALOG_DB = getParm("PROD_CATALOG_DB");

                q = "SELECT DISTINCT f.id, 0 as template_id "
                        + " FROM " + CATALOG_DB + ".catalogs f "
                        + " JOIN ( "
                        + "   SELECT c.id, IF(c2.id IS NULL, 'unpublished','published') AS publish_status "
                        + "   FROM " + CATALOG_DB + ".catalogs c "
                        + "   LEFT JOIN " + PROD_CATALOG_DB + ".catalogs c2 ON c.id = c2.id "
                        + "   WHERE c.site_id = " + escape.cote(siteId)
                        + " ) f2 ON f.id = f2.id"
                        + " LEFT JOIN " + CATALOG_DB + ".catalog_descriptions fd ON f.id = fd.catalog_id "
                        + " WHERE f.site_id = " + escape.cote(siteId);

                ArrayList<String> whereClause = new ArrayList<>();

                String catalogWhere = getCatalogWhere(catalogsList);
                if (!catalogWhere.isEmpty()) whereClause.add("f.catalog_uuid IN (" + catalogWhere + ")");
                whereClause.addAll(getFilterByWhereList(filterByList));

                String orderByClause = getOrderByClause(sortByList);

                if (!whereClause.isEmpty()) {
                    q += " AND " + String.join(" AND ", whereClause);
                }
                if (!orderByClause.isEmpty()) {
                    q += " ORDER BY " + orderByClause;
                }
                break;
            }
            case "view_commercial_products": {
                exportType = "products";
                final String PROD_CATALOG_DB = getParm("PROD_CATALOG_DB");

                JSONArray jProductViewCriteriaArr = new JSONArray();
                if (catalogsList != null) {
                    for (int i = 0; i < catalogsList.length(); i++) {
                        jProductViewCriteriaArr.put(catalogsList.optString(i));
                    }
                }

                StringBuilder uuidsOfChildFolders = new StringBuilder();

                if (subFolder.equals("1")) {
                    if (catalogsList != null && !catalogsList.isEmpty()) {
                        for (int i = 0; i < catalogsList.length(); i++) {
                            String curCatalogId = catalogsList.optString(i);
                            if (!curCatalogId.isEmpty()) {
                                Set rsWhere = Etn.execute("select p.uuid from " + CATALOG_DB + ".catalogs c left join " + CATALOG_DB +
                                        ".products_folders p on p.catalog_id=c.id where p.uuid is not null and c.site_id=" + escape.cote(siteId) +
                                        " and c.catalog_uuid=" + escape.cote(curCatalogId));
                                if (rsWhere != null && rsWhere.rs.Rows > 0) {
                                    while (rsWhere.next()) {
                                        if (uuidsOfChildFolders.length() > 0) uuidsOfChildFolders.append(",");
                                        uuidsOfChildFolders.append(escape.cote(rsWhere.value("uuid")));
                                        jProductViewCriteriaArr.put(rsWhere.value("uuid"));
                                    }

                                } else {
                                    rsWhere = Etn.execute("select p.uuid from " + CATALOG_DB + ".products_folders c left join " + CATALOG_DB +
                                            ".products_folders p on p.parent_folder_id=c.id where p.uuid is not null and c.site_id=" +
                                            escape.cote(siteId) + " and c.uuid=" + escape.cote(curCatalogId));
                                    if (rsWhere != null && rsWhere.rs.Rows > 0) {
                                        while (rsWhere.next()) {
                                            if (uuidsOfChildFolders.length() > 0) uuidsOfChildFolders.append(",");
                                            uuidsOfChildFolders.append(escape.cote(rsWhere.value("uuid")));
                                            jProductViewCriteriaArr.put(rsWhere.value("uuid"));
                                        }

                                    }
                                }
                            }
                        }
                    }
                }

                String orderByClause = getOrderByClause(sortByList);
                String orderCol = "";

                if (!orderByClause.isEmpty() && (orderByClause.contains("pv.") || orderByClause.contains("pvd."))) {
                    comparison = orderByClause;
                    if (orderByClause.charAt(0) == ' ') orderCol = "," + orderByClause.split(" ")[1];
                    else orderCol = "," + orderByClause.split(" ")[0];
                }

                //VERY IMPORTANT::In this query always add db name with the table even if we are using dev_pages db,
                //still we must add the db name as this query is saved in the db and will be executed in catalog webapp/engine
                //and never change the select columns sequence in this query as we are using rs.value(int) mostly
                if (!orderCol.isEmpty()) q = "select distinct t.id, t.template_id from (";
                else q = "";

                q += "SELECT DISTINCT p.id, 0 AS template_id" + orderCol + " FROM " + CATALOG_DB + ".products p "
                        // + " JOIN " + CATALOG_DB + ".catalogs c ON c.id = p.catalog_id "
                        + " JOIN ( "
                        + "   SELECT c.site_id, c.id AS catalog_id, 0 AS folder_id, c.catalog_uuid AS uuid, c.name, "
                        + "       c.catalog_type AS type, c.lang_1_heading AS title,  c.created_on, c.updated_on"
                        + "   FROM " + CATALOG_DB + ".catalogs c "
                        + "   WHERE c.site_id = " + escape.cote(siteId)
                        + "   UNION ALL "
                        + "   SELECT f.site_id, c.id AS catalog_id, f.id AS folder_id, f.uuid, f.name, c.catalog_type AS type,"
                        + "       '' AS title,  f.created_on, f.updated_on"
                        + "   FROM " + CATALOG_DB + ".products_folders f "
                        + "   JOIN " + CATALOG_DB + ".catalogs c ON c.id = f.catalog_id "
                        + "   WHERE f.site_id = " + escape.cote(siteId)
                        + " ) AS f ON p.catalog_id = f.catalog_id AND p.folder_id = f.folder_id "
                        + " JOIN ( "
                        + "   SELECT p.id, IF(p2.id IS NULL, 'unpublished','published') AS publish_status "
                        + "   FROM " + CATALOG_DB + ".products p "
                        + "   LEFT JOIN " + PROD_CATALOG_DB + ".products p2 ON p.id = p2.id "
                        + " ) p2 ON p.id = p2.id"
                        + " LEFT JOIN " + CATALOG_DB + ".product_descriptions pd ON p.id = pd.product_id "
                        + " LEFT JOIN " + CATALOG_DB + ".product_essential_blocks peb ON p.id = peb.product_id "
                        + " LEFT JOIN " + CATALOG_DB + ".product_tabs pt ON p.id = pt.product_id "
                        + " LEFT JOIN " + CATALOG_DB + ".product_tags ptags1 ON p.id = ptags1.product_id "
                        + " LEFT JOIN " + CATALOG_DB + ".tags AS ptags ON ptags.id = ptags1.tag_id "
                        + " LEFT JOIN " + CATALOG_DB + ".product_variants pv ON p.id = pv.product_id "
                        + " LEFT JOIN " + CATALOG_DB + ".product_variant_details pvd ON pv.id = pvd.product_variant_id "
                        + " LEFT JOIN " + CATALOG_DB + ".product_variant_ref pvr ON pv.id = pvr.product_variant_id "
                        + " LEFT JOIN (  "
                        + "     SELECT ca.catalog_id, ca.name, cav.attribute_value AS value "
                        + "             , ca.cat_attrib_id AS attrib_id, cav.id AS attrib_value_id "
                        + "     FROM " + CATALOG_DB + ".catalog_attributes ca "
                        + "     LEFT JOIN " + CATALOG_DB + ".catalog_attribute_values cav ON ca.cat_attrib_id = cav.cat_attrib_id "
                        + "     WHERE ca.name = 'color' "
                        + "   UNION "
                        + "     SELECT ca.catalog_id, ca.name, '' AS value "
                        + "             , ca.cat_attrib_id AS attrib_id, 0 AS attrib_value_id "
                        + "     FROM " + CATALOG_DB + ".catalog_attributes ca "
                        + "     WHERE ca.name = 'color' "
                        + " ) AS attrib_color ON p.catalog_id = attrib_color.catalog_id AND pvr.cat_attrib_id = attrib_color.attrib_id AND pvr.catalog_attribute_value_id = attrib_color.attrib_value_id "
                        + " LEFT JOIN (  "
                        + "     SELECT ca.catalog_id, ca.name, cav.attribute_value AS value "
                        + "             , ca.cat_attrib_id AS attrib_id, cav.id AS attrib_value_id "
                        + "     FROM " + CATALOG_DB + ".catalog_attributes ca     "
                        + "     LEFT JOIN " + CATALOG_DB + ".catalog_attribute_values cav ON ca.cat_attrib_id = cav.cat_attrib_id "
                        + "     WHERE ca.name = 'storage' "
                        + "   UNION "
                        + "     SELECT ca.catalog_id, ca.name, '' AS value "
                        + "             , ca.cat_attrib_id AS attrib_id, 0 AS attrib_value_id "
                        + "     FROM " + CATALOG_DB + ".catalog_attributes ca "
                        + "     WHERE ca.name = 'storage' "
                        + " ) AS attrib_storage ON p.catalog_id = attrib_storage.catalog_id AND pvr.cat_attrib_id = attrib_storage.attrib_id AND pvr.catalog_attribute_value_id = attrib_storage.attrib_value_id "
                        + " WHERE f.site_id = " + escape.cote(siteId);
                ArrayList<String> whereClause = new ArrayList<>();

                String catalogWhere = getCatalogWhere(catalogsList);
                if (!catalogWhere.isEmpty()) {
                    if (uuidsOfChildFolders.length() > 0) catalogWhere += "," + uuidsOfChildFolders;
                    whereClause.add("f.uuid IN (" + catalogWhere + ")");
                }

                whereClause.addAll(getFilterByWhereList(filterByList));

                if (!whereClause.isEmpty()) q += " AND " + String.join(" AND ", whereClause);
                if (!orderByClause.isEmpty()) {
                    if (orderByClause.contains("pv.order_seq")) q += " ORDER BY p.lang_" + langId + "_name";
                    else q += " ORDER BY " + orderByClause;
                }

                if (!orderCol.isEmpty()) q += " ) as t";

                jProductViewObj = new JSONObject();
                jProductViewObj.put("query", q);
                jProductViewObj.put("for_prod_site", this.generateForPublish);
                jProductViewObj.put("criteria", jProductViewCriteriaArr);
                jProductViewObj.put("results", new JSONArray());

                if (jProductViewArr == null) jProductViewArr = new JSONArray();
                jProductViewArr.put(jProductViewObj);
                break;
            }
            case "view_structured_contents":
            case "view_structured_pages": {
                String templateCustomId = fieldObj.getString("value");

                String contentType = Constant.STRUCTURE_TYPE_CONTENT;
                exportType = "structured_contents";
                if (fieldType.equals("view_structured_pages")) {
                    contentType = Constant.STRUCTURE_TYPE_PAGE;
                    exportType = "structured_pages";
                }

                String scTbl = "structured_contents";
                String scdTbl = "structured_contents_details";
                if (this.generateForPublish) {
                    scTbl += "_published";
                    scdTbl += "_published";
                }

                StringBuilder uuidsOfChildFolders = new StringBuilder();

                if (subFolder.equals("1")) {
                    if (catalogsList != null && !catalogsList.isEmpty()) {
                        for (int i = 0; i < catalogsList.length(); i++) {
                            String curCatalogId = catalogsList.optString(i);
                            if (!curCatalogId.isEmpty()) {
                                Set rsWhere = Etn.execute("select id from folders where parent_folder_id=" + escape.cote(curCatalogId) + " and site_id=" + escape.cote(siteId));
                                if (rsWhere != null && rsWhere.rs.Rows > 0) {
                                    while (rsWhere.next()) {
                                        if (uuidsOfChildFolders.length() > 0) uuidsOfChildFolders.append(",");
                                        uuidsOfChildFolders.append(escape.cote(rsWhere.value("id")));
                                    }

                                }
                            }
                        }
                    }
                }

                q = "SELECT DISTINCT p.id, p.template_id FROM " + scTbl + " p JOIN bloc_templates bt ON bt.id = p.template_id AND bt.custom_id = " + escape.cote(templateCustomId);
                if (Constant.STRUCTURE_TYPE_CONTENT.equals(contentType)) q += " LEFT JOIN structured_contents_folders f ON f.id = p.folder_id ";
                else q += " JOIN " + scdTbl + " scd ON p.id = scd.content_id JOIN pages sp ON sp.id = scd.page_id LEFT JOIN pages_folders f ON f.id = p.folder_id ";
                
                q += " WHERE p.site_id = " + escape.cote(siteId)+ " AND p.type = " + escape.cote(contentType);

                ArrayList<String> whereClause = new ArrayList<>();

                String catalogWhere = getCatalogWhere(catalogsList, fieldType);
                if (!catalogWhere.isEmpty()) {
                    if (uuidsOfChildFolders.length() > 0) catalogWhere += "," + uuidsOfChildFolders;
                    whereClause.add(" IFNULL(f.id,0) IN (" + catalogWhere + ")");
                }
                whereClause.addAll(getFilterByWhereList(filterByList));

                String orderByClause = getOrderByClause(sortByList);

                if (!whereClause.isEmpty()) q += " AND " + String.join(" AND ", whereClause);
                if (!orderByClause.isEmpty()) q += " ORDER BY " + orderByClause;
                break;
            }
        }

        EntityExport entityExport = new EntityExport(Etn, env, debug, siteId, true);
        entityExport.setIsViewData(true);
        HashSet<String> langsSet = new HashSet<>();
        langsSet.add(langId);
        entityExport.setFilterLangIds(langsSet);

        if (!q.isEmpty()) {
            Set rs = Etn.execute(q);
            // apply active promotion filter on product view
            if (fieldType.equals("view_commercial_products") && promotionFilter.equals("1")) {
                JSONObject curDataObj;
                while (rs.next()) {
                    try {
                        curDataObj = entityExport.getExportJson(exportType, rs.value(0),comparison);
                        if (curDataObj != null) {
                            JSONArray promotions = curDataObj.getJSONArray("promotions");
                            boolean activePromotion = false;
                            for (int i = 0; i < promotions.length(); i++) {
                                JSONObject promotion = (JSONObject) promotions.get(i);
                                String startDateString = promotion.getString("start_date");
                                String endDateString = promotion.getString("end_date");
                                if (!PagesUtil.isValidDateRange(startDateString, endDateString)) continue;
                                else if (!startDateString.isEmpty()) { // because frequency is only applicable when start date is set
                                    Calendar today = Calendar.getInstance();
                                    DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
                                    Date startDate = formatter.parse(startDateString);
                                    Calendar start = Calendar.getInstance();
                                    start.setTime(startDate);
                                    if (promotion.getString("frequency").equals("weekly")) {
                                        if (start.get(Calendar.DAY_OF_WEEK) != today.get(Calendar.DAY_OF_WEEK)) continue;
                                    } else if (promotion.getString("frequency").equals("monthly")) {
                                        if (start.get(Calendar.DAY_OF_MONTH) != today.get(Calendar.DAY_OF_MONTH)) continue;
                                    }
                                }
                                activePromotion = true;
                                break;
                            }

                            if (activePromotion) {
                                String templateId = PagesUtil.parseNull(rs.value(1));
                                postProcessViewDataMap(fieldType, curDataObj, templateId, tagsHM, langId);
                                dataList.put(curDataObj);
                                jProductViewObj.getJSONArray("results").put(rs.value(0));
                            }
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            } else {
                while (rs.next()) {
                    JSONObject curDataObj;
                    try {
                        curDataObj = entityExport.getExportJson(exportType, rs.value(0),comparison);
                        if (curDataObj != null) {
                            String templateId = PagesUtil.parseNull(rs.value(1));
                            postProcessViewDataMap(fieldType, curDataObj, templateId, tagsHM, langId);
                            dataList.put(curDataObj);
                            if(fieldType.equals("view_commercial_products")) jProductViewObj.getJSONArray("results").put(rs.value(0));
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }
        }
        if (dataList.isEmpty()) log("Empty view result : query : " + q);
        return retDataObj;
    }

    protected void postProcessViewDataMap(String fieldType, JSONObject viewDataObj, String templateId,HashMap<String, String> tagsHM, String langId) throws Exception {
        if (!fieldType.equals("view_structured_contents") && !fieldType.equals("view_structured_pages")) return;
        
        JSONArray details = viewDataObj.optJSONArray("details");
        if (details != null) {
            for (int i = 0; i < details.length(); i++) {
                JSONObject curDetailObj = details.optJSONObject(i);
                if (curDetailObj == null) continue;
                
                JSONObject templateData = curDetailObj.optJSONObject("template_data");
                if (templateData == null) continue;

                HashMap<String, Object> dataObj = getBlocTemplateDataMap(templateId, templateData, tagsHM, langId);
                JSONObject newTemplateData = new JSONObject(dataObj);
                curDetailObj.put("template_data", newTemplateData);
            }
        }
    }

    protected String getCatalogWhere(JSONArray catalogsList) {
        return getCatalogWhere(catalogsList,"");
    }

    protected String getCatalogWhere(JSONArray catalogsList,String type) {
        StringBuilder catalogWhere = new StringBuilder();
        if (catalogsList != null && !catalogsList.isEmpty()) {
            for (int i = 0; i < catalogsList.length(); i++) {
                String curCatalogId = catalogsList.optString(i);
                if (!curCatalogId.isEmpty()) {
                    if (catalogWhere.length() > 0) catalogWhere.append(",");
                    catalogWhere.append(escape.cote(curCatalogId));
                }
            }
        } else {
            if(!type.isEmpty() && (type.equals("view_structured_pages") || type.equals("view_structured_contents"))) catalogWhere = new StringBuilder("'-1'");
            else catalogWhere = new StringBuilder("'0'");
        }
        return catalogWhere.toString();
    }

    protected ArrayList<String> getFilterByWhereList(JSONArray filterByList) {
        //CHANGED by Umair
        //if the column name is same in filter by, then we consider an OR between those
        //else its an AND condition
        ArrayList<String> whereList = new ArrayList<>();
        if (filterByList != null && !filterByList.isEmpty()) {
            Map<String, List<String>> filterBys = new HashMap<>();

            for (int i = 0; i < filterByList.length(); i++) {
                JSONObject filterByObj = filterByList.optJSONObject(i);
                if (filterByObj == null) continue;

                String column = filterByObj.getString("column");
                String operator = filterByObj.getString("operator");
                String value = filterByObj.getString("value");

                value = escape.cote(value); //escape value

                if (operator.contains("like")) value = "'%" + value.substring(1, value.length() - 1) + "%'";
                else if (operator.contains("starts_with")) value = value.substring(0, value.length() - 1) + "%'";
                else if (operator.contains("ends_with")) value = "'%" + value.substring(1);

                operator = getFilterByOperator(operator);
                filterBys.computeIfAbsent(column, k -> new ArrayList<>());
                filterBys.get(column).add(" " + column + " " + operator + " " + value);
            }

            for(String column : filterBys.keySet()) {
                int i=0;
                StringBuilder orClause = new StringBuilder("(");
                for(String q : filterBys.get(column)) {
                    if(i > 0) orClause.append(" OR ");
                    orClause.append(q);
                    i++;
                }
                orClause.append(" )");
                whereList.add(orClause.toString());
            }
        }
        return whereList;
    }

    protected String getOrderByClause(JSONArray sortByList) {
        StringBuilder orderByClause = new StringBuilder();
        if (sortByList != null && !sortByList.isEmpty()) {
            for (int i = 0; i < sortByList.length(); i++) {
                JSONArray sortByObj = sortByList.optJSONArray(i);
                
                if (sortByObj == null || sortByObj.length() < 2) continue;
                if (orderByClause.length() > 0) orderByClause.append(",");
                orderByClause.append(" ").append(sortByObj.getString(0)).append(" ").append(sortByObj.getString(1));
            }
        }
        return orderByClause.toString();
    }

    protected void addIndexedKeyValPair(String key, Object value) {
        if (value instanceof String) indexedList.add(new AbstractMap.SimpleEntry<>(key, (String) value));
        else if (value instanceof List) {
            for (Object listval : (List) value) {
                addIndexedKeyValPair(key, listval);
            }
        }
    }

    protected void removeIndexedKeyValPair(String key, Object value) {
        if (value instanceof String) indexedList.remove(new AbstractMap.SimpleEntry<>(key, (String) value));
        else if (value instanceof List) {
            for (Object listval : (List) value) {
                removeIndexedKeyValPair(key, listval);
            }
        }
    }
}
