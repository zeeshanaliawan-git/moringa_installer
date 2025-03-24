package com.etn.pages;

import com.etn.asimina.util.UrlHelper;
import com.etn.beans.Etn;
import com.etn.beans.app.GlobalParm;
import com.etn.exception.SimpleException;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import freemarker.cache.FileTemplateLoader;
import freemarker.cache.MultiTemplateLoader;
import freemarker.cache.TemplateLoader;
import freemarker.template.Configuration;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHost;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;
import org.apache.http.ssl.TrustStrategy;
import org.apache.http.util.EntityUtils;
import org.im4java.core.Info;
import org.json.*;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.lang.reflect.*;

/**
 * Utility class for static functions to be used
 * in engine and pages module web app
 *
 * @author Ali Adnan
 * @since 2019-04-01
 */
public class PagesUtil {

    public static final String[] FEED_CHANNEL_FIELDS = {"title", "link", "description",
        "language", "category", "copyright",
        "pubDate", "ttl",
        "image_url", "image_title"};
    public static final String[] FEED_ITEM_FIELDS = {"title", "link", "description", "guid",
        "enclosure_url", "enclosure_type", "enclosure_length",
        "pubDate", "category", "author", "comments",
        "source", "source_url"};

    private static final int HTTP_CONNECTION_TIMEOUT = 10000; //milliseconds
    public static int getHttpConnectionTimout(){
        int configTimeout = parseInt(GlobalParm.getParm("HTTP_CONNECTION_TIMEOUT"));
        if(configTimeout > 0){
            return configTimeout;
        }
        return HTTP_CONNECTION_TIMEOUT;
    }

    public static JSONObject newJSONObject(){
        JSONObject jsonObject = new JSONObject() {
        @Override
            public JSONObject put(String key, Object value) throws JSONException {
                try {
                    Field map = JSONObject.class.getDeclaredField("map");
                    map.setAccessible(true);
                    Object mapValue = map.get(this);
                    if (!(mapValue instanceof LinkedHashMap)) {
                        map.set(this, new LinkedHashMap<>());
                    }
                } catch (NoSuchFieldException | IllegalAccessException e) {
                    throw new RuntimeException(e);
                }
                return super.put(key, value);
            }
        };
        return jsonObject;

    }
    public static JSONObject newJSONObject2(String var){
        JSONObject jsonObject = new JSONObject(var) {
        @Override
            public JSONObject put(String key, Object value) throws JSONException {
                try {
                    Field map = JSONObject.class.getDeclaredField("map");
                    map.setAccessible(true);
                    Object mapValue = map.get(this);
                    if (!(mapValue instanceof LinkedHashMap)) {
                        map.set(this, new LinkedHashMap<>());
                    }
                } catch (NoSuchFieldException | IllegalAccessException e) {
                    throw new RuntimeException(e);
                }
                return super.put(key, value);
            }
        };
        return jsonObject;
    }

    public static final Map<String, String[]> ALLOWED_FILETYPES;

    static {
        ALLOWED_FILETYPES = new HashMap<>();
        ALLOWED_FILETYPES.put("js", new String[]{"js"});
        ALLOWED_FILETYPES.put("css", new String[]{"css"});
        ALLOWED_FILETYPES.put("jsx", new String[]{"jsx"});
        ALLOWED_FILETYPES.put("fonts", new String[]{"ttf", "eot", "otf", "svg", "woff", "woff2"});
        ALLOWED_FILETYPES.put("img",
                              new String[]{"jpeg", "jpg", "png", "gif", "jpe", "bmp", "tif", "tiff", "dib", "svg", "ico","webp"});
        ALLOWED_FILETYPES.put("video",
                              new String[]{"avi", "mov", "mp4", "webm", "flv", "wmv"});
        ALLOWED_FILETYPES.put("other",
                              new String[]{"pdf", "xls", "xlsx", "doc", "docx", "ppt", "pptx", "json", "csv", "ftl"});
    }

    public static String[] getAllowedFileTypes(String type) {
        return ALLOWED_FILETYPES.getOrDefault(type, new String[]{});
    }

    public static String cleanPagePath(String path) {
        if (path == null) {
            return path;
        }
        path = path.trim()
            .replaceAll("/\\s/ ", "-")
            .replaceAll("/[^a-zA-Z0-9/-]/", "")
            .replaceAll("/-", "/")
            .replaceAll("-/", "/")
            .replaceAll("--", "-");
        if (path.startsWith("-")) {
            path = path.substring(1);
        }
        return path;
    }

    public static String getPageHtmlPath(String path, String variant, String langue_code, String site_id) {
        return site_id + "/" + langue_code + "/" + variant + "/" + path + ".html";
    }

    public static String getCachedPath(Etn Etn, String siteId, String langCode, String type, String id ) {
        Set rs = Etn.execute("select * from "+GlobalParm.getParm("PROD_PORTAL_DB")+".cached_content_view where site_id = "+escape.cote(siteId)+" and lang = "+escape.cote(langCode)+" and content_type = "+escape.cote(type)+" and content_id ="+escape.cote(id));
		if(rs.next())
		{
			return parseNull(rs.value("published_url"));
		}
		return "";
    }

    public static String getDynamicPagePath(String site_id, String langue_code, String variant, String path) {
        return site_id + "/" + langue_code + "/" + variant + "/" + path + "/";
    }

    public static String getPrefixedPagePath(Etn Etn, String pageId, String langue_code, String path, String type, String siteId) {
        String q = "SELECT langue_id from language WHERE langue_code = " + escape.cote(langue_code);
        Set rs = Etn.execute(q);
        if (rs.next()) {
            String langId = rs.value("langue_id");
            String folderId = getPageFolderId(Etn, pageId, type);
            String pathPrefix = getPageFolderPath(Etn, folderId, siteId, langId);
            if (pathPrefix.length() > 0) {
                path = pathPrefix + path;
            }
        }
        return path;
    }

    public static HashMap<String, String> getAllPageFolderPaths(Etn Etn, String folderId, String siteId) {

        HashMap<String, String> retMap = new HashMap<>();

        String q = "SELECT f.langue_id, f.concat_path "
                   + " FROM pages_folders_lang_path f"
                   + " WHERE f.folder_id     = " + escape.cote(folderId)
                   + " AND f.site_id = " + escape.cote(siteId)
                   + " order by f.langue_id ";
        Set rs = Etn.execute(q);
        while (rs.next()) {
            String pathPrefix = parseNull(rs.value("concat_path"));
            if (pathPrefix.length() > 0) {
                pathPrefix += "/";
            }
            retMap.put(rs.value("langue_id"), pathPrefix);
        }

        return retMap;
    }

    public static String getPageFolderPath(Etn Etn, String folderId, String siteId, String langId) {
        String pathPrefix = "";

        String q = "SELECT f.concat_path "
                   + " FROM pages_folders_lang_path f"
                   + " WHERE f.folder_id = " + escape.cote(folderId)
                   + " AND f.site_id = " + escape.cote(siteId)
                   + " AND f.langue_id = " + escape.cote(langId);
        Set rs = Etn.execute(q);
        if (rs.next()) {
            pathPrefix = parseNull(rs.value("concat_path"));
            if (pathPrefix.length() > 0) {
                pathPrefix += "/";
            }
        }

        return pathPrefix;
    }

    public static String getPageFolderId(Etn Etn, String pageId, String type) {
        String folderId = "0";//default
        if (type.equals("structured")) {
            String q = " SELECT sc.folder_id, sc.site_id"
                       + " FROM structured_contents sc "
                       + " JOIN structured_contents_details scd ON scd.content_id = sc.id "
                       + " WHERE scd.page_id = " + escape.cote(pageId);
            Set rs = Etn.execute(q);
            if (rs.next()) {
                folderId = rs.value("folder_id");
            }
        }
        else {
            String q = " SELECT folder_id, site_id"
                       + " FROM pages "
                       + " WHERE id = " + escape.cote(pageId);
            Set rs = Etn.execute(q);
            if (rs.next()) {
                folderId = rs.value("folder_id");
            }
        }
        return folderId;
    }

    public static String getPrefixedPagePath(Etn Etn, String pageId) throws Exception {

        String q = "SELECT path, langue_code, site_id, type "
                   + " FROM pages "
                   + " WHERE type IN ( " + escape.cote(Scheduler.PAGE_TYPE_FREEMARKER)
                   + "," + escape.cote(Scheduler.PAGE_TYPE_STRUCTURED) + " ) "
                   + " AND id = " + escape.cote(pageId);
        Set rs = Etn.execute(q);
        if (!rs.next()) {
            throw new Exception("Invalid page id = " + pageId);
        }
        String type = rs.value("type");
        String siteId = rs.value("site_id");
        String path = rs.value("path");
        q = "SELECT langue_id from language WHERE langue_code = " + escape.cote(rs.value("langue_code"));
        rs = Etn.execute(q);
        rs.next();
        String langId = rs.value("langue_id");
        String folderId = getPageFolderId(Etn, pageId, type);
        String pathPrefix = getPageFolderPath(Etn, folderId, siteId, langId);

        if (pathPrefix.length() > 0) {
            path = pathPrefix + path;
        }
        return path;
    }

    public static String addFolder(Etn Etn, JSONObject folderObj, String parentId, String folderType, String siteId, int pid) throws Exception {
        String q;
        Set rs;
        String folderName = folderObj.getString("name");

        String dl_page_type =""; 
        if(folderObj.getString("dl_page_type")!=null && folderObj.getString("dl_page_type").length() > 0) {
            dl_page_type=folderObj.getString("dl_page_type");
        }

        String dl_sub_level_1 =""; 
        if(folderObj.getString("dl_sub_level_1")!=null && folderObj.getString("dl_sub_level_1").length() > 0) {
            dl_sub_level_1=folderObj.getString("dl_sub_level_1");
        }
        
        String dl_sub_level_2 =""; 
        if(folderObj.getString("dl_sub_level_2")!=null && folderObj.getString("dl_sub_level_2").length() > 0) {
            dl_sub_level_2=folderObj.getString("dl_sub_level_2");
        }

        int parentFolderLevel = 0;
        if (parseInt(parentId) > 0) {
            q = "SELECT folder_level FROM folders "
                + " WHERE site_id = " + escape.cote(siteId)
                + " AND id = " + escape.cote(parentId);
            rs = Etn.execute(q);
            if (rs.next()) {
                parentFolderLevel = parseInt(rs.value("folder_level"));
            }
            else {
                throw new Exception("Invalid parent id");
            }
        }

        if (parentFolderLevel >=4) {
            throw new Exception("Folder cannot be created at level 4");
        }

        q = "INSERT INTO folders(name, site_id, parent_folder_id, folder_level, type, created_ts, updated_ts, created_by, updated_by,dl_page_type,dl_sub_level_1,dl_sub_level_2) "
            + "VALUES (" + escape.cote(folderName) + ","
            + escape.cote(siteId) + ","
            + escape.cote(parentId) + ","
            + escape.cote("" + (parentFolderLevel + 1)) + ","
            + escape.cote(folderType) + ", NOW(), NOW(),"
            + escape.cote("" + pid) + ","
            + escape.cote("" + pid) + ","
            + escape.cote(dl_page_type) + ","
            + escape.cote(dl_sub_level_1) + ","
            + escape.cote(dl_sub_level_2) + ")";
        int folderId = Etn.executeCmd(q);
        if (folderId <= 0) {
            throw new Exception("Error in creating folder.");
        }
        else {
            JSONArray folderDetails = folderObj.optJSONArray("details");
            List<Language> langsList = getLangs(Etn,siteId);
            q = "";
            for (Language curLang : langsList) {
                String curPathPrefix = "";
                if (folderDetails != null) {
                    for (int i = 0; i < folderDetails.length(); i++) {
                        JSONObject detailObj = folderDetails.getJSONObject(i);
                        if (curLang.code.equals(detailObj.getString("langue_code"))) {
                            curPathPrefix = detailObj.optString("path_prefix");
                            break;
                        }
                    }
                }
                if (q.length() > 0) {
                    q += ",";
                }
                q += " (" + escape.cote("" + folderId) + ","
                     + escape.cote("" + curLang.id) + "," + escape.cote(curPathPrefix) + ")";
            }
            if (q.length() > 0) {
                q = "INSERT INTO folders_details(folder_id, langue_id, path_prefix) VALUES " + q;
                Etn.executeCmd(q);
            }
        }

        return "" + folderId;
    }

    public static boolean advanceParamExists(Etn Etn,String entity_id,String type)
    {
    	Set rs = Etn.execute("SELECT * FROM section_field_advance WHERE entity_id = "+escape.cote(entity_id)+" AND entity_type = "+escape.cote(type));
    	if(rs.rs.Rows>0) return true;
    	return false;
    }

    public static int insertAdvanceParams(Etn Etn,JSONObject jObj,boolean is_field)
    {
        String type = (is_field)? "field" : "section";
        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();
        colValueHM.put("entity_id",escape.cote(parseNull(jObj.getString("id"))));
        colValueHM.put("entity_type",escape.cote(type));
        colValueHM.put("display",escape.cote(jObj.optString("display","1")));
        colValueHM.put("css_code",escape.cote(jObj.optString("css_code","")));
        try{
            colValueHM.put("js_code",escape.cote(jObj.optString("js_code","")));
        }catch (JSONException e)
        {
            colValueHM.put("js_code",escape.cote(jObj.getJSONArray("js_code").toString()));
        }

        if(is_field) {
            colValueHM.put("unique_type",escape.cote(jObj.optString("unique_type","none")));
            colValueHM.put("modifiable",escape.cote(jObj.optString("modifiable","always")));
            colValueHM.put("reg_exp",escape.cote(jObj.optString("reg_exp","")));
        } 
        
        String q = advanceParamExists(Etn,jObj.getString("id"),type) ? 
            getUpdateQuery("section_field_advance",colValueHM," WHERE entity_id = "+escape.cote(jObj.getString("id"))+" AND entity_type = "+escape.cote(type)) 
            : 
            getInsertQuery("section_field_advance",colValueHM);
        
        return Etn.executeCmd(q);
    }

    public static void insertUpdateTemplateSections(Etn Etn,
                                                    JSONArray sectionsList,
                                                    String templateId,
                                                    String parentSectionId,
                                                    boolean isSystem,
                                                    int pid) throws SimpleException {

        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();
        ArrayList<String> sectionIdList = new ArrayList<>();
        String q = "";

        for (int i = 0; i < sectionsList.length(); i++) {
            JSONObject section = sectionsList.getJSONObject(i);

            colValueHM.clear();
            colValueHM.put("bloc_template_id", escape.cote(templateId));
            colValueHM.put("parent_section_id", escape.cote(parentSectionId));
            colValueHM.put("name", escape.cote(section.getString("name")));
            colValueHM.put("sort_order", escape.cote("" + i));
            colValueHM.put("nb_items", escape.cote(section.getString("nb_items")));
            colValueHM.put("description", escape.cote(section.optString("description","")));
            colValueHM.put("is_collapse", escape.cote(section.optString("is_collapse","0")));
            colValueHM.put("is_new_product_item", escape.cote(section.optString("is_new_product_item","0")));

            colValueHM.put("updated_ts", "NOW()");
            colValueHM.put("updated_by", escape.cote("" + pid));

            int sectionId = parseInt(section.optString("id"));

            if (isSystem) {
                colValueHM.put("is_system", "'1'");

                q = "SELECT id FROM bloc_templates_sections "
                    + " WHERE bloc_template_id = " + escape.cote(templateId)
                    + " AND parent_section_id = " + escape.cote(parentSectionId)
                    + " AND custom_id = " + escape.cote(section.getString("custom_id"));
                Set rs = Etn.execute(q);
                if (rs.next()) {
                    sectionId = parseInt(rs.value("id"));
                }
            }

            if (sectionId <= 0) {
                //new section
                colValueHM.put("custom_id", escape.cote(section.getString("custom_id")));

                colValueHM.put("created_ts", "NOW()");
                colValueHM.put("created_by", escape.cote("" + pid));
                q = getInsertQuery("bloc_templates_sections", colValueHM);

                sectionId = Etn.executeCmd(q);
                
                if (sectionId <= 0) {
                    throw new SimpleException("Error in creating new section. Please try again.");
                }
            }
            else {
                //existing section update
                q = getUpdateQuery("bloc_templates_sections", colValueHM, " WHERE id = " + escape.cote("" + sectionId));
                int count = Etn.executeCmd(q);
                if (count <= 0) {
                    throw new SimpleException("Error in updating existing section. Please try again.");
                }
            }

            sectionIdList.add(escape.cote("" + sectionId));
            try{
            	section.put("id","" + sectionId);
	            insertAdvanceParams(Etn,section,false);
            }catch(Exception e){ throw new SimpleException("Advance Parameter Error");}

            //fields processing
            JSONArray fieldsList = section.getJSONArray("fields");
            insertUpdateTemplateSectionFields(Etn, fieldsList, "" + sectionId, isSystem);

            //nested sections processing
            JSONArray nestedSectionsList = section.getJSONArray("sections");
            insertUpdateTemplateSections(Etn, nestedSectionsList, "0", "" + sectionId, isSystem, pid);

        }//for sectionsList

        if (!isSystem) {
            //deleted sections
            q = "DELETE FROM bloc_templates_sections WHERE bloc_template_id = " + escape.cote("" + templateId)
                + " AND parent_section_id = " + escape.cote(parentSectionId);
            if (sectionIdList.size() > 0) {
                q += " AND id NOT IN ( " + String.join(",", sectionIdList) + ")";
            }
            Etn.executeCmd(q);
        }

    }

    public static boolean checkProductTypeFromSection(Etn Etn, String sectionId){
        Set rs = Etn.execute("select bloc_template_id,parent_section_id from bloc_templates_sections where id="+escape.cote(sectionId));
        if(rs.next()){
            if(rs.value("bloc_template_id").equals("0")){
                return checkProductTypeFromSection(Etn,rs.value("parent_section_id"));
            }else{
                Set rsTemplateType = Etn.execute("select type from bloc_templates where id="+escape.cote(rs.value("bloc_template_id")));
                if(rsTemplateType.next()){
                    if(rsTemplateType.value("type").contains("product")){
                        return true;
                    }
                }
            }
        }
        return false;
    }

    public static void insertUpdateTemplateSectionFields(Etn Etn, JSONArray fieldsList,String sectionId, boolean isSystem) throws SimpleException {

        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();
        ArrayList<String> fieldIdList = new ArrayList<>();
        String q = "";

		Map<String, String> langCodes = new HashMap<>();
		Set rslangs = Etn.execute("select * from language ");
		while(rslangs.next())
		{
			langCodes.put(rslangs.value("langue_code").toLowerCase(), rslangs.value("langue_id"));
		}

        boolean isNewProductTemplate = checkProductTypeFromSection(Etn,sectionId);
        for (int j = 0; j < fieldsList.length(); j++) {
            JSONObject field = fieldsList.getJSONObject(j);
            colValueHM.clear();
            
            Set rsCustomId = Etn.execute("select * from template_reserved_ids where item_id="+escape.cote(field.getString("custom_id")));
            if(rsCustomId.rs.Rows>0){
                if(isNewProductTemplate){
                    colValueHM.put("is_new_product_item", escape.cote(parseNull(field.optString("is_new_product_item"))));
                }else{
                    throw new SimpleException(field.getString("custom_id")+" is reserved id. Please use some other id for field.");
                }
            }
            if(!isNewProductTemplate) colValueHM.put("is_new_product_item", "0");
            
            colValueHM.put("section_id", escape.cote(sectionId));
            colValueHM.put("name", escape.cote(field.getString("name")));
            colValueHM.put("sort_order", escape.cote("" + j));
            colValueHM.put("nb_items", escape.cote(field.getString("nb_items")));
            colValueHM.put("value", escape.cote(field.getString("value")));
            colValueHM.put("is_required", escape.cote(field.optString("is_required", "0")));
            colValueHM.put("is_indexed", escape.cote(field.optString("is_indexed", "0")));
            colValueHM.put("is_bulk_modify", escape.cote(field.optString("is_bulk_modify", "0")));
            colValueHM.put("is_meta_variable", escape.cote(field.optString("is_meta_variable", "0")));
            colValueHM.put("description", escape.cote(field.optString("description","")));
            colValueHM.put("select_type", escape.cote(field.optString("select_type","select")));
            colValueHM.put("is_query", escape.cote(field.optString("is_query","0")));
            colValueHM.put("query_type", escape.cote(field.optString("query_type","")));
            colValueHM.put("field_specific_data", escape.cote(field.optString("field_specific_data","{}")));

            int fieldId = parseInt(field.optString("id"));

            if (isSystem) {
                colValueHM.put("is_system", "'1'");

                q = "SELECT id FROM sections_fields "
                    + " WHERE section_id = " + escape.cote(sectionId)
                    + " AND custom_id = " + escape.cote(field.getString("custom_id"));
                Set rs = Etn.execute(q);
                if (rs.next()) {
                    fieldId = parseInt(rs.value("id"));
                    //the type in system template could be updated
                    colValueHM.put("type", escape.cote(field.getString("type")));
                }
            }

            if (fieldId <= 0) {
                //new field
                colValueHM.put("custom_id", escape.cote(field.getString("custom_id")));
                colValueHM.put("type", escape.cote(field.getString("type")));

                q = getInsertQuery("sections_fields", colValueHM);
                fieldId = Etn.executeCmd(q);

                if (fieldId <= 0) {
                    throw new SimpleException("Error in creating new field. Please try again.");
                }
            }
            else {
                //existing field update
                q = getUpdateQuery("sections_fields", colValueHM, " WHERE id = " + escape.cote("" + fieldId));

                Etn.executeCmd(q);
            }

            if(field.getString("type").equals("bloc")){
                Set rsSection = Etn.execute("select bloc_template_id from bloc_templates_sections where id="+escape.cote(sectionId));
                rsSection.next();
                JSONObject field_specific_data = new JSONObject(field.optString("field_specific_data","{}"));
                if(!field_specific_data.isEmpty()){
                    Etn.executeCmd("delete from bloc_field_selected_templates where field_id="+escape.cote(fieldId+""));

                    JSONArray selectedTemplates = field_specific_data.getJSONArray("templates_ids");
                    for(int counter=0;counter<selectedTemplates.length();counter++){
                        String templateId = parseNull(selectedTemplates.getString(counter));
                        if(!templateId.isEmpty()){
                            Etn.executeCmd("insert ignore into bloc_field_selected_templates (template_id,field_id,selected_template_id) values("+escape.cote(rsSection.value("bloc_template_id"))+
                            ","+escape.cote(fieldId+"")+","+escape.cote(selectedTemplates.getString(counter))+")");
                        }
                    }
                }
            }

            try{
            	field.put("id",""+fieldId);
                insertAdvanceParams(Etn,field,true);
            }catch( Exception e )
            {
                throw new SimpleException("Error in updating existing advance param. Please try again.");
            }

            fieldIdList.add(escape.cote("" + fieldId));
			
			//add/update field details
			if(field.has("lang_data"))
			{
				for(int i=0; i<field.getJSONArray("lang_data").length(); i++)
				{
					JSONObject langData = field.getJSONArray("lang_data").getJSONObject(i);
					System.out.println("langData " + langData.toString());
					
					String langCode = langData.optString("langue_code", "");
					if(langCodes.get(langCode.toLowerCase()) != null)
					{
						System.out.println("Lang code exists so we add/update sections_fields_details");
						//always pick langId from the hashmap ... this code is used by import functionality also in which case a lang code in another country might have a different lang id
						//which means in the exported json file the lang code FR might have different lang ID then this current country
						String langId = langCodes.get(langCode.toLowerCase());
						String defaultValue = parseNull(langData.optString("default_value",""));
						String placeholder = parseNull(langData.optString("placeholder",""));
						
						if(defaultValue.length() == 0 && placeholder.length() == 0)
						{
							Etn.executeCmd("delete from sections_fields_details where field_id = "+escape.cote(""+fieldId)+" and langue_id = "+escape.cote(langId));
						}
						else
						{
							Etn.executeCmd("insert into sections_fields_details (field_id, langue_id, default_value, placeholder) values ("+escape.cote(""+fieldId)+", "+escape.cote(langId)+", "+escape.cote(defaultValue)+", "+escape.cote(placeholder)+") on duplicate key update default_value = "+escape.cote(defaultValue)+", placeholder = "+escape.cote(placeholder));
						}						
					}
					else
					{
						System.out.println("Lang code "+langCode+" not supported by this instance of asimina");
					}
				}
			}
			else if(field.has("default_value") || field.has("placeholder"))
			{
				System.out.println("Fields old json structure found");
				String defaultValue = parseNull(field.optString("default_value",""));
				String placeholder = parseNull(field.optString("placeholder",""));
				
				for(String langCode : langCodes.keySet())
				{
					String langId = langCodes.get(langCode);
					if(defaultValue.length() == 0 && placeholder.length() == 0)
					{
						Etn.executeCmd("delete from sections_fields_details where field_id = "+escape.cote(""+fieldId)+" and langue_id = "+escape.cote(langId));
					}
					else
					{
						Etn.executeCmd("insert into sections_fields_details (field_id, langue_id, default_value, placeholder) values ("+escape.cote(""+fieldId)+", "+escape.cote(langId)+", "+escape.cote(defaultValue)+", "+escape.cote(placeholder)+") on duplicate key update default_value = "+escape.cote(defaultValue)+", placeholder = "+escape.cote(placeholder));
					}						
				}
			}
			else
			{
				Etn.executeCmd("delete from sections_fields_details where field_id = "+escape.cote(""+fieldId));
			}

        }//for fieldsList

        if (!isSystem) {
            //deleted fields
            String whereClause = " WHERE section_id = " + escape.cote(sectionId);
            if (fieldIdList.size() > 0) {
                whereClause += " AND id NOT IN ( " + String.join(",", fieldIdList) + ")";
            }
			//delete fields details before deleting the fields
			Etn.executeCmd("delete from sections_fields_details where field_id in (select id from sections_fields "+whereClause+")");
			
            Etn.executeCmd("DELETE FROM sections_fields " + whereClause);
        }

    }

    public static JSONArray getBlocTemplateSectionsData(Etn Etn, String templateId) throws Exception {
		return getBlocTemplateSectionsData(Etn, templateId, false);
	}
    public static JSONArray getBlocTemplateSectionsData(Etn Etn, String templateId, boolean loadForBulkModification) throws Exception {
        String q = "SELECT id from bloc_templates WHERE id = " + escape.cote(templateId);
        Set rs = Etn.execute(q);
        if (!rs.next()) {
            throw new Exception("Invalid parameters");
        }

        q = "SELECT bts.id,bts.name, bts.custom_id, bts.nb_items, bts.parent_section_id, bts.is_system "
            + ", bts.description, bts.is_collapse, sfa.display, sfa.unique_type, sfa.modifiable "
            + ", sfa.reg_exp, sfa.css_code, sfa.js_code,is_new_product_item "
            + " FROM bloc_templates_sections bts LEFT JOIN section_field_advance sfa"
            + " ON bts.id = sfa.entity_id "
            + " AND sfa.entity_type = 'section' " 
            + " WHERE bts.bloc_template_id = " + escape.cote(templateId)
            + " ORDER BY sort_order ASC ";

        rs = Etn.execute(q);

        JSONArray sectionsList = getSectionsList(Etn, rs, loadForBulkModification);

        return sectionsList;
    }

    public static JSONArray getSectionsList(Etn Etn, Set sectionsRs) throws Exception {
		return getSectionsList(Etn, sectionsRs, false);
	}
	
    public static JSONArray getSectionsList(Etn Etn, Set sectionsRs, boolean loadForBulkModification) throws Exception {

        JSONArray sectionsList = new JSONArray();
        while (sectionsRs.next()) {
            JSONObject section = newJSONObject();

            String sectionId = sectionsRs.value("id");

            section.put("id", sectionId);
            section.put("name", parseNull(sectionsRs.value("name")));
            section.put("custom_id", parseNull(sectionsRs.value("custom_id")));
            section.put("nb_items", parseNull(sectionsRs.value("nb_items")));
            section.put("is_system", parseNull(sectionsRs.value("is_system")));
            section.put("is_collapse", parseNull(sectionsRs.value("is_collapse")));
            section.put("description", parseNull(sectionsRs.value("description")));
            section.put("display", parseNull(sectionsRs.value("display")));
            section.put("unique_type", parseNull(sectionsRs.value("unique_type")));
            section.put("modifiable", parseNull(sectionsRs.value("modifiable")));
            section.put("reg_exp", parseNull(sectionsRs.value("reg_exp")));
            section.put("css_code", parseNull(sectionsRs.value("css_code")));
            section.put("js_code", parseNull(sectionsRs.value("js_code")));
            section.put("is_new_product_item", parseNull(sectionsRs.value("is_new_product_item")));

            String parentSectionId = sectionsRs.value("parent_section_id");
            if (parseInt(parentSectionId) <= 0) {
                parentSectionId = "";
            }
            section.put("parent_section_id", parentSectionId);

            JSONArray fieldsList = getSectionFieldList(Etn, sectionsRs.value("id"), loadForBulkModification);
            section.put("fields", fieldsList);

            //get nested sections
            String q = "SELECT bts.id,bts.name, bts.custom_id, bts.nb_items, bts.parent_section_id, bts.is_system "
                    + ", bts.description, bts.is_collapse, sfa.display, sfa.unique_type, sfa.modifiable "
                    + ", sfa.reg_exp, sfa.css_code, sfa.js_code,is_new_product_item "
                    + " FROM bloc_templates_sections bts LEFT JOIN section_field_advance sfa"
                    + " ON bts.id = sfa.entity_id "
                    + " AND sfa.entity_type = 'section' " 
                    + " WHERE bts.parent_section_id = " + escape.cote(sectionId)
                    + " ORDER BY sort_order ASC ";
            Set rs = Etn.execute(q);

            JSONArray nestedSections = getSectionsList(Etn, rs, loadForBulkModification);

            section.put("sections", nestedSections);

            sectionsList.put(section);

        }//while sections

        return sectionsList;
    }

    public static JSONArray getSectionFieldList(Etn Etn, String sectionId) throws Exception {
		return getSectionFieldList(Etn, sectionId, false);
	}
	
    public static JSONArray getSectionFieldList(Etn Etn, String sectionId, boolean loadForBulkModification) throws Exception {
        JSONArray fieldsList = new JSONArray();

        String q = "SELECT sf.*,sfd.display,sfd.unique_type,sfd.modifiable,sfd.reg_exp,sfd.css_code,sfd.js_code,is_new_product_item "
                   + " FROM sections_fields sf LEFT join section_field_advance sfd on sf.id=sfd.entity_id and sfd.entity_type='field' "
                   + " WHERE section_id = " + escape.cote(sectionId);
		if(loadForBulkModification) q += " and is_bulk_modify = 1 ";
        q += " ORDER BY sort_order ASC ";
        Set fRs = Etn.execute(q);
        while (fRs.next()) {
            JSONObject field = newJSONObject();

            for (String colName : fRs.ColName) {
                String colNameLower = colName.toLowerCase();
                if ("section_id".equals(colNameLower)) {
                    continue;
                }
                field.put(colNameLower, fRs.value(colName));
            }
			
			JSONArray langDatas = new JSONArray();
			field.put("lang_data", langDatas);
			Set rsDetails = Etn.execute("Select s.*, l.langue_code from sections_fields_details s, language l where l.langue_id = s.langue_id and s.field_id = "+escape.cote(fRs.value("id")));
			
			while(rsDetails.next())
			{
				JSONObject langData = newJSONObject();
				langData.put("langue_id", rsDetails.value("langue_id"));
				langData.put("langue_code", rsDetails.value("langue_code"));
				langData.put("default_value", rsDetails.value("default_value"));
				langData.put("placeholder", rsDetails.value("placeholder"));
				langDatas.put(langData);
			}
					
            fieldsList.put(field);
        }

        return fieldsList;
    }

    public static void fillPageAndMetaDataMap(Etn Etn, Map<String, Object> pageHM,
                                              Map<String, Object> metaHM, Set pageRs,
                                              String IMAGE_FOLDER_PATH, String IMAGE_URL_PREPEND, boolean debug) {

        String pageId = parseNull(pageRs.value("id"));
        String siteId = parseNull(pageRs.value("site_id"));
        String title = parseNull(pageRs.value("title"));
        String og_local = parseNull(pageRs.value("og_local"));
        String lang_dir = parseNull(pageRs.value("lang_dir"));
        String meta_description = parseNull(pageRs.value("meta_description")).replaceAll("\\s+", " ").trim();

        String pageType = parseNull(pageRs.value("type"));
        String pagePath = parseNull(pageRs.value("path"));
        String pageLangCode = parseNull(pageRs.value("langue_code"));
        String pageVariant = parseNull(pageRs.value("variant"));
        pagePath = getPrefixedPagePath(Etn, pageId, pageLangCode, pagePath, pageType, siteId);
        String fullPagePath = getPageHtmlPath(pagePath, pageVariant, pageLangCode, siteId);
        if (pagePath.length() > 0) pagePath += ".html";

        pageHM.put("title", title);
        pageHM.put("lang", parseNull(pageRs.value("langue_code")));
        pageHM.put("lang_dir", lang_dir);
        pageHM.put("canonical_url", parseNull(pageRs.value("canonical_url")));
        pageHM.put("path", pagePath);
        pageHM.put("full_path", fullPagePath);
        pageHM.put("uuid", parseNull(pageRs.value("uuid")));
		
		Map<String, String> pageDateHM = new HashMap<>();
		pageDateHM.put("created", parseNull(pageRs.value("created_ts_date")));
		pageDateHM.put("modified", parseNull(pageRs.value("updated_ts_date")));
		pageDateHM.put("published", parseNull(pageRs.value("published_ts_date")));
		
		pageHM.put("date", pageDateHM);
		
		Map<String, String> pageTimeHM = new HashMap<>();
		pageTimeHM.put("created", parseNull(pageRs.value("created_ts_time")));
		pageTimeHM.put("modified", parseNull(pageRs.value("updated_ts_time")));
		pageTimeHM.put("published", parseNull(pageRs.value("published_ts_time")));
		
		pageHM.put("time", pageTimeHM);

        String twitter_card = "summary";

        ArrayList<String> locale_alt = new ArrayList<>();
        //for og:locale:alternate
        if (parseNull(pageRs.value("id")).length() > 0) {
            String q = " SELECT DISTINCT l.og_local "
                       + " FROM pages p "
                       + " JOIN language l ON p.langue_code = l.langue_code "
                       + " WHERE p.site_id = " + escape.cote(parseNull(pageRs.value("site_id")))
                       + " AND p.path = " + escape.cote(parseNull(pageRs.value("path")))
                       + " AND p.id != " + escape.cote(parseNull(pageRs.value("id")))
                       + " AND p.langue_code != " + escape.cote(parseNull(pageRs.value("langue_code")));
            Set langRs = Etn.execute(q);
            while (langRs.next()) {
                locale_alt.add(langRs.value("og_local"));
            }
        }

        pageHM.put("meta", metaHM);
        //for backward compatabilty for existing templates,//deprecated
        pageHM.put("social", metaHM);

        metaHM.put("title", title);
        metaHM.put("type", parseNull(pageRs.value("social_type")));
        metaHM.put("locale", og_local);
        metaHM.put("keywords", parseNull(pageRs.value("meta_keywords")));
        metaHM.put("description", meta_description);
        metaHM.put("locale_alt", locale_alt);
        metaHM.put("twitter_card", twitter_card);

        metaHM.put("image", "");
        metaHM.put("image_width", "0");
        metaHM.put("image_height", "0");
        metaHM.put("image_type", "");
        String socialImageName = parseNull(pageRs.value("social_image"));
        if (socialImageName.length() > 0) {
            try {

                //first check in meta for resized image , fall back to original
                String socialImageFilePath = IMAGE_FOLDER_PATH + "og/" + socialImageName;
                File socialImageFile = new File(socialImageFilePath);
                String imageUrl = IMAGE_URL_PREPEND + "og/" + socialImageName;

                if (!socialImageFile.exists() || !socialImageFile.isFile()) {
                    socialImageFilePath = IMAGE_FOLDER_PATH + socialImageName;
                    socialImageFile = new File(socialImageFilePath);
                    imageUrl = IMAGE_URL_PREPEND + socialImageName;
                }

                if (socialImageFile.exists() && socialImageFile.isFile()) {
                    //using im4java library (wrapper for image magick)
                    Info imgInfo = new Info(socialImageFile.getAbsolutePath(), true);

                    imageUrl += "?_rnd=" + System.currentTimeMillis();
                    metaHM.put("image", imageUrl);
                    metaHM.put("image_width", "" + imgInfo.getImageWidth());
                    metaHM.put("image_height", "" + imgInfo.getImageHeight());
                    metaHM.put("image_type", "image/" + imgInfo.getImageFormat().toLowerCase());
                    metaHM.put("twitter_card", "summary_large_image");
                }
            }
            catch (Exception ex) {
                //do nothing
                if (debug) {
                    System.out.println("Error in getting page image info");
                    System.out.println(ex.getMessage());
                }
            }

        }
    }

    public static Map<String, Object> getSiteParamDataMap(Etn Etn, String siteId, String langId, String PROD_PORTAL_DB) {
        Map<String, Object> siteParamHM = new HashMap<>();
        Set rs = Etn.execute("SELECT * FROM " + PROD_PORTAL_DB + ".sites_details WHERE site_id = " + escape.cote(siteId)
                             + " AND langue_id = " + escape.cote(langId));
        rs.next();
        siteParamHM.put("homepage_url", parseNull(rs.value("homepage_url")));
        siteParamHM.put("page_404_url", parseNull(rs.value("page_404_url")));
        siteParamHM.put("production_path", parseNull(rs.value("production_path")));

        return siteParamHM;
    }

    static String getMetaValueFromFolders(Etn Etn,String folderId, String columnType)
    {
        Set rs = Etn.execute("select "+columnType+" as 'subLevel',parent_folder_id from folders where id="+escape.cote(folderId));
        if(rs.next() && parseNull(rs.value("subLevel")).length()>0)
        {
            return parseNull(rs.value("subLevel"));
        }
        else
        {
            if(parseNull(rs.value("parent_folder_id")).length()>0 && !parseNull(rs.value("parent_folder_id")).equals("0"))
            {
                return getMetaValueFromFolders(Etn,parseNull(rs.value("parent_folder_id")),columnType);
            }else{
                return "";
            }
        }
    }
	
	private static String getProperty(Etn Etn, String code)
	{
		Set rs = Etn.execute("Select * from config where code = "+escape.cote(code));
		if(rs.next())
		{
			return parseNull(rs.value("val"));
		}
		
		rs = Etn.execute("Select * from config where code = "+escape.cote("COMMONS_DB"));
		rs.next();
		String commonsDb = rs.value("val");
		
		rs = Etn.execute("Select * from "+commonsDb+".config where code = "+escape.cote(code));
		if(rs.next())
		{
			return parseNull(rs.value("val"));
		}
		
		return "";
	}
	
	private static boolean isImageStillValid(Etn Etn, String siteId, String img)
	{
		Set rsMedia = Etn.execute("select * from files where file_name="+escape.cote(img)+
			" and site_id="+escape.cote(siteId)+" and (COALESCE(removal_date,'') = '' or  removal_date>now())");
		System.out.println("select * from files where file_name="+escape.cote(img)+
			" and site_id="+escape.cote(siteId)+" and (COALESCE(removal_date,'') = '' or  removal_date>now())");
		if(rsMedia.next()) return true;
		return false;
	}
	
	private static String getTranslation(Etn Etn, String langCode, String w)
	{
		String m = "";
		Set rs = Etn.execute("select t.*, l.langue_id from langue_msg t join language l on l.langue_code = "+escape.cote(langCode)+" where t.LANGUE_REF = "+escape.cote(w));
		if(rs.next())
		{
			String langId = rs.value("langue_id");
			m = parseNull(rs.value("LANGUE_"+langId));
		}
		
		if(m.length() == 0) m = w;
		return m;
	}

    public static String getEtnMetaTags(Etn Etn, Set pageRs, String CATALOG_DB, String CONTEXT_PATH) {
        StringBuilder metaTags = new StringBuilder();

        String eletype = "", eleid = "", ctype = "", sccustomid = "", sctype = "", elename = "", eleurl = "", eletagid = "", eletaglabel = "";
        String scpageid="";
        String pageId = pageRs.value("id");
        String pageType = pageRs.value("type");
        String parentPageId = pageRs.value("parent_page_id");
		if("react".equalsIgnoreCase(pageType)) parentPageId = pageId;//for react we have no parent page so we consider parent page id same as page id

        String siteId = parseNull(pageRs.value("site_id"));
        String variant = parseNull(pageRs.value("variant"));
        String path = parseNull(pageRs.value("path"));
        String langCode = parseNull(pageRs.value("langue_code"));

		//-- for new products
		boolean isNewProduct = false;
		String brandName = "";
		String sContentId = "";
		String pname = "";
		String cname = "";
		String pprice = "";
		String pprice2 = "";
		String pprice3 = "";
		String pimage = "";
		String pcurrency = "";
		String ttype = "";
		String ncommitment = "";
		String pcommitment = "";
		String pcommitmentfrequency = "";
		//-- for new products
		
        path = getPrefixedPagePath(Etn, pageId, langCode, path, pageType, siteId);
        if (Scheduler.PAGE_TYPE_STRUCTURED.equals(pageType)) {

            String q = " SELECT sc.name as name, IFNULL(f.name,'') AS folder_name, sc.folder_id AS folder_id, "
                       + "   bt.name AS template_name, bt.custom_id AS template_custom_id, sc.id content_id"
                       + " FROM structured_contents_details scd "
                       + " JOIN structured_contents sc ON sc.id = scd.content_id "
                       + " LEFT JOIN pages_folders f ON f.id = sc.folder_id "
                       + " JOIN bloc_templates bt ON bt.id = sc.template_id "
                       + " WHERE scd.page_id =" + escape.cote(pageRs.value("id"));
            Set rs = Etn.execute(q);

            eletype = "structuredcatalog";
            if (rs.next()) {
                elename = rs.value("name");
                eleid = rs.value("folder_id");
                ctype = rs.value("folder_name");
                scpageid = pageRs.value("id");
                sctype = rs.value("template_name");
                sccustomid = rs.value("template_custom_id");
                sContentId = rs.value("content_id");
				
				Set rsM = Etn.execute("select * from products_map_pages where page_id = "+escape.cote(sContentId));
				if(rsM.next())
				{
					isNewProduct = true;
					Set rsD = Etn.execute("Select s.content_data from structured_contents_details s join language l on l.langue_id = s.langue_id and l.langue_code = "+escape.cote(langCode)+" where s.content_id = "+escape.cote(sContentId));
					if(rsD.next())
					{
						JSONObject jProduct = new JSONObject(decodeJSONStringDB(rsD.value("content_data")));
						if(jProduct.has("product_general_informations") && jProduct.getJSONArray("product_general_informations").length() > 0)
						{
							JSONObject jGenInfo = jProduct.getJSONArray("product_general_informations").getJSONObject(0);
							if(jGenInfo.has("product_general_informations_image") && jGenInfo.getJSONArray("product_general_informations_image").length() > 0)
							{								
								pimage = jGenInfo.getJSONArray("product_general_informations_image").getJSONObject(0).optString("value","");

								if(pimage.length() > 0 && isImageStillValid(Etn, siteId, pimage) == false)
								{
									pimage = "";
								}
							}
							if(jGenInfo.has("product_general_informations_manufacturer") && jGenInfo.getJSONArray("product_general_informations_manufacturer").length() > 0)
							{
								brandName = parseNull(jGenInfo.getJSONArray("product_general_informations_manufacturer").getString(0));
							}
						}
						//is configurable product
						if(jProduct.has("product_variants") && jProduct.getJSONArray("product_variants").length() > 0)
						{
							for(int v=0;v<jProduct.getJSONArray("product_variants").length();v++)
							{
								for(int j=0;j<jProduct.getJSONArray("product_variants").getJSONObject(v).getJSONArray("product_variants_variant_x").length();j++)
								{
									JSONObject jVariant = jProduct.getJSONArray("product_variants").getJSONObject(v).getJSONArray("product_variants_variant_x").getJSONObject(j);
									
									if(pimage.length() == 0)
									{
										if(jVariant.has("product_variants_variant_x_image") && jVariant.getJSONArray("product_variants_variant_x_image").length() > 0)
										{
											System.out.println("leng : " + jVariant.getJSONArray("product_variants_variant_x_image").length());
											for(int k=0;k<jVariant.getJSONArray("product_variants_variant_x_image").length();k++)
											{
												pimage = jVariant.getJSONArray("product_variants_variant_x_image").getJSONObject(k).optString("value","");

												if(pimage.length() > 0 && isImageStillValid(Etn, siteId, pimage) == false)
												{
													pimage = "";
												}
												
												if(pimage.length() > 0) break;
											}										
										}
									}
								}
							}
							
						}
					}
					
					Set rsPr = Etn.execute("select * from "+CATALOG_DB+".products where id = "+escape.cote(rsM.value("product_id")));
					if(rsPr.next())
					{
						ttype = rsPr.value("product_type");
						if("configurable_virtual_product".equalsIgnoreCase(rsPr.value("product_type")) || "simple_virtual_product".equalsIgnoreCase(rsPr.value("product_type")))
						{
							ctype = "offer";
						} 
						else
						{
							ctype = "product";
						}
						
						int v=0;
						Set rsPv = Etn.execute("Select * from "+CATALOG_DB+".product_variants where product_id = "+escape.cote(rsM.value("product_id")) + " order by is_default desc, id ");
						while(rsPv.next())
						{
							if(v==0)
							{
								pprice = parseNull(rsPv.value("price"));
								if(parseInt(rsPv.value("commitment")) > 0)
								{
									pcommitmentfrequency = parseNull(rsPv.value("frequency"));
									pcommitment = getTranslation(Etn, langCode, "Engagement") + " " + rsPv.value("commitment") + " " + getTranslation(Etn, langCode, pcommitmentfrequency);
								}
								else
								{
									pcommitment = getTranslation(Etn, langCode, "Sans engagement");
								}
								ncommitment = parseNull(rsPv.value("commitment"));
							}
							else if(pprice2.length() == 0) pprice2 = parseNull(rsPv.value("price"));
							else if(pprice3.length() == 0) pprice3 = parseNull(rsPv.value("price"));
							
							v++;							
						}						
					}
						
					Set rsSp = Etn.execute("Select lang_1_currency from "+CATALOG_DB+".shop_parameters where site_id = "+escape.cote(siteId));
					if(rsSp.next()) pcurrency = parseNull(rsSp.value("lang_1_currency"));
					
					if(pimage.length() > 0)
					{
						pimage = getProperty(Etn, "MEDIA_LIBRARY_UPLOADS_URL") + siteId + "/img/4x3/" + pimage;
					}
					
					eletype = "commercialcatalog";
					eleid = rsM.value("product_id");
					cname = sctype;
					pname = parseNull(brandName + " " + elename);
					
				}
            }
			
        }
        else {
            eletype = "page";
            eleid = pageRs.value("id");
            elename = pageRs.value("name");
        }

        eleurl = path + ".html";
        if ("logged".equals(variant)) {
            eleurl = variant + "/" + path + ".html";
        }

        String q = "SELECT t.id, t.label FROM pages_tags pt "
                   + " JOIN " + CATALOG_DB + ".tags t ON pt.tag_id = t.id "
                   + " WHERE t.site_id = " + escape.cote(siteId)
                   + " AND pt.page_id = " + escape.cote(parentPageId)
                   + " AND pt.page_type = " + escape.cote(pageType)
                   + " ORDER BY t.label ";
        Set rs = Etn.execute(q);
        boolean isFirst = true;
        while (rs.next()) {

            if (!isFirst) {
                eletagid += ",";
                eletaglabel += ",";
            }
            else {
                isFirst = false;
            }

            eletagid += rs.value("id");
            eletaglabel += rs.value("label");
        }

        metaTags.append(getMetaTag("etn:eleurl", eleurl));
        metaTags.append(getMetaTag("etn:eletaglabel", eletaglabel));
        metaTags.append(getMetaTag("etn:eletype", eletype));
        metaTags.append(getMetaTag("etn:eleid", eleid));
        metaTags.append(getMetaTag("etn:ctype", ctype));
        metaTags.append(getMetaTag("etn:sctype", sctype));
        metaTags.append(getMetaTag("etn:scpageid", scpageid));
        metaTags.append(getMetaTag("etn:sccustomid", sccustomid));
        metaTags.append(getMetaTag("etn:elename", elename));
        metaTags.append(getMetaTag("etn:eletagid", eletagid));
        metaTags.append(getMetaTag("etn:pagescontextpath", CONTEXT_PATH));
		
		//for new products
		if(isNewProduct)
		{
			if(parseNull(brandName).length() > 0) metaTags.append(getMetaTag("etn:elebrand", brandName));
			if(parseNull(pprice).length() > 0) metaTags.append(getMetaTag("etn:eleprice", pprice));
			if(ctype.equals("offer") && parseNull(pprice2).length() > 0) metaTags.append(getMetaTag("etn:eleprice2", pprice2));
			if(ctype.equals("offer") && parseNull(pprice3).length() > 0) metaTags.append(getMetaTag("etn:eleprice3", pprice3));
			if(parseNull(pimage).length() > 0) metaTags.append(getMetaTag("etn:eleimage", pimage));
			if(parseNull(cname).length() > 0) metaTags.append(getMetaTag("etn:cname", cname));
			if(parseNull(pname).length() > 0) metaTags.append(getMetaTag("etn:pname", pname));			
			if(parseNull(pcurrency).length() > 0) metaTags.append(getMetaTag("etn:elecurrency", pcurrency));			
			if(parseNull(ttype).length() > 0) metaTags.append(getMetaTag("etn:templatetype", ttype));			
			
			//for offers in products v1 we always had commitment info set so we do same here
			//else for products we only set commitment info in case commitment defined is greater than 0
			if("offer".equalsIgnoreCase(ctype) || parseInt(ncommitment) > 0)
			{
				if(parseNull(pcommitment).length() > 0) metaTags.append(getMetaTag("etn:elecommitment", pcommitment));			
				if(parseNull(pcommitmentfrequency).length() > 0) metaTags.append(getMetaTag("etn:commitmentfrequency", pcommitmentfrequency));			
				if(parseNull(ncommitment).length() > 0) metaTags.append(getMetaTag("etn:commitmentduration", ncommitment));
			}
		}
		
		

        
        //data layer meta tags
        String[] dlColList = {"dl_page_type", "dl_sub_level_1", "dl_sub_level_2"};

        for (String curDlCol : dlColList) {

            String curVal = parseNull(pageRs.value(curDlCol));
            if (curVal.length() > 0) {
                metaTags.append(getMetaTag("etn:" + curDlCol, curVal));
            }else{
                if(parseNull(pageRs.value("folder_id")).length() > 0 && !parseNull(pageRs.value("folder_id")).equals("0")) {
                    String metaValue = getMetaValueFromFolders(Etn,parseNull(pageRs.value("folder_id")),curDlCol);
                    if(metaValue.length()>0){
                        metaTags.append(getMetaTag("etn:" + curDlCol, metaValue));
                    }
                }
            }
        }
        //System.out.println(metaTags);
        return metaTags.toString();
    }

    public static HashMap<String, Object> getBlocExtraDataMap(Etn Etn, String blocId, String templateType, String PORTAL_DB) throws Exception {

        HashMap<String, Object> retDataMap = new HashMap<>();

        String q = "";
        Set rs = null;

        q = "SELECT b.name, b.uuid, b.rss_feed_ids, b.rss_feed_sort, b.site_id "
			+ ", date_format(b.created_ts, '%Y-%m-%d') as created_ts_date, DATE_FORMAT(b.created_ts,'%H:%i:%s') as created_ts_time "
			+ ", date_format(b.updated_ts, '%Y-%m-%d') as updated_ts_date, DATE_FORMAT(b.updated_ts,'%H:%i:%s') as updated_ts_time "
            + " FROM blocs b"
            + " JOIN bloc_templates bt ON bt.id = b.template_id"
            + " WHERE b.id = " + escape.cote(blocId)
            + " AND bt.type = " + escape.cote(templateType);


        rs = Etn.execute(q);
        if (!rs.next()) {
            throw new Exception("Invalid bloc ID : " + blocId + " for type : " + templateType);
        }
		
		Map<String, Object> blocHM = new HashMap<>();
		
		Map<String, String> dateHM = new HashMap<>();
		dateHM.put("created", rs.value("created_ts_date"));
		dateHM.put("modified", rs.value("updated_ts_date"));
		blocHM.put("date", dateHM);

		Map<String, String> timeHM = new HashMap<>();
		timeHM.put("created", rs.value("created_ts_time"));
		timeHM.put("modified", rs.value("updated_ts_time"));
		blocHM.put("time", timeHM);
		
		retDataMap.put("bloc", blocHM);

        if (Constant.TEMPLATE_FEED_VIEW.equals(templateType)) {

            String[] rssFeedIds = rs.value("rss_feed_ids").split(",");
            String rssFeedSort = rs.value("rss_feed_sort");

            String orderByClause = " ORDER BY id DESC";
            if ("title_asc".equalsIgnoreCase(rssFeedSort)) {
                orderByClause = " ORDER BY title ASC ";
            }
            else if ("title_desc".equalsIgnoreCase(rssFeedSort)) {
                orderByClause = " ORDER BY title DESC ";
            }
            else if ("date_asc".equalsIgnoreCase(rssFeedSort)) {
                orderByClause = " ORDER BY pubDate_std ASC, id ASC ";
            }
            else if ("date_desc".equalsIgnoreCase(rssFeedSort)) {
                orderByClause = " ORDER BY pubDate_std DESC, id DESC ";
            }

            ArrayList<HashMap<String, Object>> feedsDataList = new ArrayList<>();

            for (String feedId : rssFeedIds) {

                if (parseInt(feedId) <= 0) {
                    continue;
                }

                HashMap<String, Object> feedDataMap = getRssFeedDataMap(Etn, feedId, orderByClause);

                if (feedDataMap != null) {
                    feedsDataList.add(feedDataMap);
                }

            }//for

            retDataMap.put("rss_feed", feedsDataList);

        }//if templateType
        else if (Constant.SYSTEM_TEMPLATE_MENU.equals(templateType)) {
            HashMap<String, String> menuInfo = new HashMap<>();
            menuInfo.put("name", rs.value("name"));
            menuInfo.put("uuid", rs.value("uuid"));
            //dummy for backward compat old version
            menuInfo.put("langue", "");
            menuInfo.put("langue_code", "");

			Set _rsSite = Etn.execute("select * from "+PORTAL_DB+".sites where id = "+escape.cote(rs.value("site_id")));
			_rsSite.next();
			menuInfo.put("ecommerce_enabled", _rsSite.value("enable_ecommerce"));

            retDataMap.put("system_info", menuInfo);
        }
		else
		{			
			Set _rsSite = Etn.execute("select * from "+PORTAL_DB+".sites where id = "+escape.cote(rs.value("site_id")));
			_rsSite.next();
            HashMap<String, String> menuInfo = new HashMap<>();
			menuInfo.put("ecommerce_enabled", _rsSite.value("enable_ecommerce"));

            retDataMap.put("system_info", menuInfo);
			
		}

        return retDataMap;

    }

    public static HashMap<String, Object> getRssFeedDataMap(Etn Etn, String feedId, String orderByClause) throws Exception {

        HashMap<String, Object> retDataMap = new HashMap<>();

        String q = "";
        Set rs = null;

        q = "SELECT * FROM rss_feeds "
            + " WHERE id = " + escape.cote(feedId);
        rs = Etn.execute(q);

        if (!rs.next()) {
            throw new Exception("Invalid feed ID : " + feedId);
        }

        if (!"1".equals(rs.value("is_active"))) {
            return null;
        }

        retDataMap.put("name", rs.value("name"));

        HashMap<String, Object> channelMap = new HashMap<>();

        //fill channel info
        for (String fieldName : FEED_CHANNEL_FIELDS) {
            if (rs.value("ch_" + fieldName) != null) {
                channelMap.put(fieldName, rs.value("ch_" + fieldName));
            }
        }

        q = "SELECT * FROM rss_feeds_items "
            + " WHERE is_active = '1' "
            + " AND rss_feed_id = " + escape.cote(feedId)
            + " " + orderByClause;

        rs = Etn.execute(q);

        ArrayList<HashMap<String, Object>> itemsList = new ArrayList<>();
        while (rs.next()) {

            HashMap<String, Object> itemMap = new HashMap<>();
            //fill item info
            for (String fieldName : FEED_ITEM_FIELDS) {
                if (rs.value(fieldName) != null) {
                    itemMap.put(fieldName, rs.value(fieldName));
                }
            }

            itemsList.add(itemMap);
        }

        retDataMap.put("channel", channelMap);
        retDataMap.put("item", itemsList);

        return retDataMap;
    }

    public static LinkedHashMap<String, String> getAllTags(Etn Etn, String siteId, String CATALOG_DB) {
        LinkedHashMap<String, String> tagsHM = new LinkedHashMap<>();
        String q = "SELECT id, label FROM " + CATALOG_DB + ".tags "
                   + " WHERE site_id = " + escape.cote(siteId)
                   + " ORDER BY label";
        Set rs = Etn.execute(q);
        if (rs != null) {
            while (rs.next()) {
                tagsHM.put(rs.value("id"), rs.value("label"));
            }
        }
        return tagsHM;
    }

    /**
     * function is many times even in same request. or operation.
     * to save the cost of querying added a static variable and result is cached for 30 minutes
     */
    private static List<Language> langsList = null;
    private static long lastLangFetch = 0;

    public static List<Language> getLangs(Etn Etn) {
		if(langsList != null)
		{
			
			//System.out.println("*********************************** " + langsList.size() + " " + lastLangFetch);
		}
        if (langsList != null && langsList.size() > 0 && ((System.currentTimeMillis() - lastLangFetch) / (1000 * 60) < 30)) {
            return deepCopyLangArray(langsList);
        }
		System.out.println("------------------------------- reload languages");
        langsList = getAllLangs(Etn);
        lastLangFetch = System.currentTimeMillis();
        return deepCopyLangArray(langsList);
    }

    public static List<Language> getLangs(Etn Etn,String siteId) {
		if(langsList != null)
		{
			
			//System.out.println("*********************************** " + langsList.size() + " " + lastLangFetch);
		}
        if (langsList != null && langsList.size() > 0 && ((System.currentTimeMillis() - lastLangFetch) / (1000 * 60) < 30)) {
            return deepCopyLangArray(langsList);
        }
		System.out.println("------------------------------- reload languages");
        langsList = getSiteLangs(Etn,siteId);
        lastLangFetch = System.currentTimeMillis();
        return deepCopyLangArray(langsList);
    }

    public static List<Language> deepCopyLangArray(List<Language> array1){
        List<Language> array2 = new ArrayList<>();
        for(Language langObj1 :array1){
            Language l = new Language();
            l.id = langObj1.id;
            l.name = langObj1.name;
            l.code = langObj1.code;
            l.og_local = langObj1.og_local;
            l.direction = langObj1.direction;
            array2.add(l);
        }
        return array2;
    }

    public static void markFeedAssociatedPagesToGenerate(Etn Etn, String feedId) {

        String q = "";

        q = " UPDATE pages p "
            + " JOIN pages_blocs pb ON pb.page_id = p.id "
            + " JOIN blocs b ON b.id = pb.bloc_id "
            + " SET p.to_generate = 1, p.to_generate_by = 1 "
            + " WHERE CONCAT( ',' , b.rss_feed_ids , ',') LIKE " + escape.cote("%," + feedId + ",%");

        Etn.executeCmd(q);
    }
    public static Configuration getFreemarkerConfig(String TEMPLATES_DIR) throws Exception {
        return getFreemarkerConfig(null,TEMPLATES_DIR);
    }

    public static Configuration getFreemarkerConfig(TemplateLoader extraTL, String TEMPLATES_DIR) throws Exception {

        // Create your Configuration instance, and specify if up to what FreeMarker
        // version (here 2.3.27) do you want to apply the fixes that are not 100%
        // backward-compatible. See the Configuration JavaDoc for details.
        Configuration cfg = new Configuration(Configuration.VERSION_2_3_28);

        // Specify the source where the template files come from. Here I set a
        // plain directory for it, but non-file-system sources are possible too:
        //cfg.setDirectoryForTemplateLoading(new File(TEMPLATES_DIR));
        // Set the preferred charset template files are stored in. UTF-8 is
        // a good choice in most applications:
        cfg.setDefaultEncoding("UTF-8");

        // Sets how errors will appear.
        // During web page *development* TemplateExceptionHandler.HTML_DEBUG_HANDLER is better.
        cfg.setTemplateExceptionHandler(freemarker.template.TemplateExceptionHandler.HTML_DEBUG_HANDLER);

        // Don't log exceptions inside FreeMarker that it will thrown at you anyway:
        cfg.setLogTemplateExceptions(false);

        // Wrap unchecked exceptions thrown during template processing into TemplateException-s.
        cfg.setWrapUncheckedExceptions(true);

        cfg.setDateTimeFormat("yyyy-MM-dd HH:mm");
        cfg.setDateFormat("yyyy-MM-dd");
        cfg.setTimeFormat("HH:mm");

        FileTemplateLoader ftl = new FileTemplateLoader(new File(TEMPLATES_DIR));

        if(extraTL!=null){

            MultiTemplateLoader mtl = new MultiTemplateLoader(new TemplateLoader[]{ftl, extraTL});
            
            cfg.setTemplateLoader(mtl);
        }

        cfg.setSetting("new_builtin_class_resolver", "safer");

        return cfg;
    }

    public static String getScriptTag(String src) {
        return "\n<script type='text/javascript' src='" + src + "'></script>";
    }

    public static String getLinkTag(String src) {
        return "\n<link type='text/css' href='" + src + "' rel='stylesheet'>";
    }

    public static String getMetaTag(String name, String content) {
        return "\n<meta name='" + escapeCoteValue(name) + "' "
               + " content='" + escapeCoteValue(content) + "'>";
    }

    public static String generateHtmlTag(String tagName, String innerHtml,
                                         ArrayList<String> attrNames,
                                         ArrayList<String> attrValues) {
        StringBuilder tag = new StringBuilder("<");
        tag.append(tagName).append(" ");
        for (int i = 0; i < attrNames.size(); i++) {
            tag.append(attrNames.get(i))
                .append("='").append(escapeCoteValue(attrValues.get(i))).append("' ");
        }
        tag.append(">").append(innerHtml).append("</").append(tagName).append('>');
        return tag.toString();
    }

    public static String escapeCoteValue(String str) {

        if (str != null && str.length() > 0) {
            return str.replace("'", "&#39;").replace("\"", "&#34;").replace("<", "&lt;").replace(">", "&gt;");
        }
        else {
            return str;
        }
    }

    public static String encodeJSONStringDB(String str) {
        return str.replaceAll("\\\\", "#slash#");
    }

    public static String decodeJSONStringDB(String str) {
        return str.replaceAll("#slash#", "\\\\");
    }
    public static String getInsertQuery(String tableName, Map<String, String> colValueHM) {
        return getInsertQuery(tableName,colValueHM,false);
    }
    public static String getInsertQuery(String tableName, Map<String, String> colValueHM,boolean toIgnore) {

        String qPrefix;
        String qPostFix = " VALUES ( ";
        
        if(toIgnore){
            qPrefix = "INSERT IGNORE INTO " + tableName + " ( ";
        }else{
            qPrefix = "INSERT INTO " + tableName + " ( ";
        }

        boolean isFirst = true;
        for (Map.Entry<String, String> entry : colValueHM.entrySet()) {
            if (!isFirst) {
                qPrefix += ", ";
                qPostFix += ", ";
            }
            else {
                isFirst = false;
            }

            qPrefix += entry.getKey();
            qPostFix += entry.getValue();

        }

        return qPrefix + " ) \n" + qPostFix + " )";
    }

    public static String getUpdateQuery(String tableName, Map<String, String> colValueHM, String whereClause) {

        String query = "UPDATE " + tableName + " SET ";

        boolean isFirst = true;
        for (Map.Entry<String, String> entry : colValueHM.entrySet()) {
            if (!isFirst) {
                query += ", ";
            }
            else {
                isFirst = false;
            }
            query += entry.getKey() + "=" + entry.getValue();

        }

        return query + " " + whereClause;
    }

    public static String listToEscapedCommaSeperated(List<String> list) {
        String retString = "";
        for (int i = 0; i < list.size(); i++) {

            if (i > 0) {
                retString += ",";
            }
            retString += escape.cote(list.get(i));
        }

        return retString;
    }

    public static String getURLResponseAsString(String url, HashMap<String, String> httpHM) throws Exception {

        String responseStr;

        String proxyHost = parseNull(httpHM.get("HTTP_PROXY_HOST"));
        String proxyPort = parseNull(httpHM.get("HTTP_PROXY_PORT"));
        final String proxyUser = parseNull(httpHM.get("HTTP_PROXY_USER"));
        final String proxyPasswd = parseNull(httpHM.get("HTTP_PROXY_PASSWD"));

        CloseableHttpClient httpClient = null;
        //Builder for SSLContext instances
        SSLContextBuilder builder = new SSLContextBuilder();
        TrustStrategy strategy = new TrustStrategy() {
            @Override
            public boolean isTrusted(final X509Certificate[] chain, String authType)
            throws CertificateException {

                return true;
            }
        };
        builder.loadTrustMaterial(null, strategy);
        //create SSL connection Socket Factory object for trusting self-signed certificates
        SSLConnectionSocketFactory sslcsf = new SSLConnectionSocketFactory(builder.build());

        HttpClientBuilder clientBuilder = HttpClients.custom();
        clientBuilder.setSSLSocketFactory(sslcsf);
        if (proxyHost.length() > 0 && proxyPort.length() > 0) {
            HttpHost proxy = new HttpHost(proxyHost, Integer.parseInt(proxyPort));
            if (proxyUser.length() > 0 & proxyPasswd.length() > 0) {
                CredentialsProvider credentialsPovider = new BasicCredentialsProvider();
                credentialsPovider.setCredentials(new AuthScope(proxyHost, Integer.parseInt(proxyPort)), new UsernamePasswordCredentials(proxyUser, proxyPasswd));
                clientBuilder.setDefaultCredentialsProvider(credentialsPovider);
            }
            clientBuilder.setProxy(proxy);
        }

        httpClient = clientBuilder.build();

        HttpGet httpGet = new HttpGet(url);

        //setting timeout
        int connectionTimeout = getHttpConnectionTimout();
        RequestConfig requestConfig = RequestConfig.custom()
            .setConnectionRequestTimeout(connectionTimeout)
            .setConnectTimeout(connectionTimeout)
            .setSocketTimeout(connectionTimeout)
            .build();
        httpGet.setConfig(requestConfig);

        try (CloseableHttpResponse response = httpClient.execute(httpGet)) {
            response.getStatusLine();
            HttpEntity entity = response.getEntity();

            // do something useful with the response body
            // and ensure it is fully consumed
            responseStr = EntityUtils.toString(entity, StandardCharsets.UTF_8);

            EntityUtils.consume(entity);

        }

        return responseStr;
    }

    public static String parseNull(Object o) {
        if (o == null) {
            return ("");
        }
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        }
        else {
            return (s.trim());
        }
    }

    public static int parseInt(Object o) {
        return parseInt(o, 0);
    }

    public static int parseInt(Object o, int defaultValue) {
        String s = parseNull(o);
        if (s.length() > 0) {
            try {
                return Integer.parseInt(s);
            }
            catch (Exception e) {
                return defaultValue;
            }
        }
        else {
            return defaultValue;
        }
    }

    public static String convertDateToStandardFormat(String dateStr) {
        return convertDateToStandardFormat(dateStr, "dd/MM/yyyy");
    }

    public static String convertDateToStandardFormat(String dateStr, String srcFormat) {
        String retDate = dateStr;

        try {

            Date d = new SimpleDateFormat(srcFormat).parse(dateStr);

            retDate = new SimpleDateFormat("yyyy-MM-dd").format(d);
        }
        catch (Exception ex) {
            //return same date
        }

        return retDate;
    }

    public static String convertDateTimeToStandardFormat(String dateStr, String srcFormat) {
        String retDate = "";
        try {

            Date d = new SimpleDateFormat(srcFormat).parse(dateStr);

            retDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(d);
        }
        catch (Exception ex) {
            //return same date
        }

        return retDate;
    }

    public static String getFormattedDate(String date, String dateFormat) {
        Date d = getDate(date, "yyyy-MM-dd HH:mm");//date_time
        if (d != null) {
            return new SimpleDateFormat(getFormat(dateFormat)).format(d);
        }
        d = getDate(date, "yyyy-MM-dd");//date
        if (d != null) {
            return new SimpleDateFormat(getFormat(dateFormat)).format(d);
        }
        d = getDate(date, "HH:mm");//time
        if (d != null) {
            if (!dateFormat.equals("time")) {
                return "";
            }
            else {
                return new SimpleDateFormat(getFormat(dateFormat)).format(d);
            }
        }
        return "";
    }

    public static Date getDate(String date, String format) {
        try {
            SimpleDateFormat formatter = new SimpleDateFormat(format);
            formatter.setLenient(true);
            return formatter.parse(date);
        }
        catch (ParseException p) {
            return null;
        }
    }

    public static String getFormat(String dateFormat) {
        switch (dateFormat) {
            case "date_time":
                return "yyyy-MM-dd HH:mm";
            case "date":
                return "yyyy-MM-dd";
            case "time":
                return "HH:mm";
        }
        return "";
    }

    public static boolean isPageUrlUnique(Etn Etn, String siteId,
                                          String langue_code, String variant, String path,
                                          String pageId, StringBuffer errorMsg) {
        boolean isUnique = false;

        try {
            String type = "page";
            String url = path;
            if ("logged".equals(variant)) {
                url = variant + "/" + path;
            }
            isUnique = UrlHelper.isUrlUnique(Etn, siteId, langue_code, type, pageId, url, errorMsg);
        }
        catch (Exception ex) {
            System.out.println("Error in isPageUrlUnique()");
            ex.printStackTrace();
        }

        return isUnique;
    }

    protected static final int ESC_CHAR = '\\';
    protected static final String ESC_STR = "\\\\";
    protected static final String ESC_PLCHOLDR = "#SLS#";

    /***
     * a function to fix the issue of escape.cote()
     * where it removes \ characters from the string instead of properly escaping it
     * */
    public static String escapeCote(String str) {
        if (str == null || str.trim().length() == 0) {
            return escape.cote(str);
        }
        else if (str.indexOf(ESC_CHAR) >= 0) {
            //only do the extra replaces if needed, atleast one \ character is present
            String retStr = escape.cote(str.replaceAll(ESC_STR, ESC_PLCHOLDR));
            retStr = retStr.replaceAll(ESC_PLCHOLDR, ESC_STR + ESC_STR);
            return retStr;
        }
        else {
            return escape.cote(str);
        }
    }

    public static boolean copyContentPublish(Etn Etn, String contentId) throws Exception {
        String q = "SELECT sc.*"
                   + " FROM structured_contents sc "
                   + " WHERE sc.id = " + escape.cote(contentId);

        Set rs = Etn.execute(q);
        if (!rs.next()) {
            return false;
        }

        String allColumns = String.join(",", rs.ColName).toLowerCase(); //java8 function to join arrays

        //use "REPLACE" to remove existing row with same id if exists
        q = "REPLACE INTO structured_contents_published (" + allColumns + ") "
            + " SELECT " + allColumns + " FROM structured_contents "
            + " WHERE id = " + escape.cote(contentId);
        int count = Etn.executeCmd(q);

        if (count <= 0) {
            return false;
        }

        q = "SELECT * FROM structured_contents_details "
            + " WHERE content_id = " + escape.cote(contentId);
        rs = Etn.execute(q);
        rs.next();

        allColumns = String.join(",", rs.ColName).toLowerCase(); //java8 function to join arrays

        //use "REPLACE" to remove existing row with same id if exists
        q = "REPLACE INTO structured_contents_details_published (" + allColumns + ") "
            + " SELECT " + allColumns + " FROM structured_contents_details "
            + " WHERE content_id = " + escape.cote(contentId);
        count = Etn.executeCmd(q);

        if (count <= 0) {
            //cleanup
            q = "DELETE FROM structured_contents_published "
                + " WHERE id = " + escape.cote(contentId);
            Etn.executeCmd(q);
            return false;
        }
        Etn.executeCmd(q);
        return true;
    }

    public static boolean deleteContentPublish(Etn Etn, String contentId) throws Exception {
        String q = "SELECT name"
                   + " FROM structured_contents sc "
                   + " WHERE sc.id = " + escape.cote(contentId);

        Set rs = Etn.execute(q);
        if (!rs.next()) {
            return false;
        }
        //strucutreType = content

        q = "DELETE FROM structured_contents_details_published "
            + " WHERE content_id = " + escape.cote(contentId);
        Etn.executeCmd(q);

        q = "DELETE FROM structured_contents_published "
            + " WHERE id = " + escape.cote(contentId);
        Etn.executeCmd(q);

        return true;
    }

    public static String createOrGetContentRegionId(String templateId, Etn Etn, int pid) throws SimpleException{
		String regionId = null;

		String q = "SELECT id FROM page_templates_items "
				+ " WHERE custom_id = 'content' AND page_template_id = " + escape.cote(templateId);
		Set rs = Etn.execute(q);

		if(rs.next()){
			regionId = rs.value("id");
		}
		else{
			//create content region
			String _pid = escape.cote(""+pid);
			Map<String, String> colValueHM = new LinkedHashMap<>();
			colValueHM.put("page_template_id", escape.cote(templateId));
			colValueHM.put("name", "'Content'");
			colValueHM.put("custom_id", "'content'");
			colValueHM.put("sort_order", "'0'");
			colValueHM.put("created_by", _pid);
			colValueHM.put("updated_by", _pid);
			colValueHM.put("created_ts", "NOW()");
			colValueHM.put("updated_ts", "NOW()");

			q = getInsertQuery("page_templates_items", colValueHM);
			int newId = Etn.executeCmd(q);
			if(newId > 0){
				regionId = "" + newId;

				q = " INSERT INTO page_templates_items_details( item_id, langue_id, css_classes, css_style ) "
					+ " SELECT " + escape.cote(regionId) + " AS item_id , l.langue_id, '' , '' "
					+ " FROM `language` l order by l.langue_id ";
				Etn.executeCmd(q);
			}
			else{
				throw new SimpleException("Error in creating default 'content' region");
			}
		}

		return regionId;
	}

    public static boolean isValidDateRange(String startDateString, String endDateString) throws ParseException {

        DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        Date startDate, endDate, currentDate;

        currentDate = df.parse(df.format(new Date()));

        startDate = (startDateString.length() == 0 ? currentDate : df.parse(startDateString));
        endDate = (endDateString.length() == 0 ? currentDate : df.parse(endDateString));

        if(!(currentDate.before(startDate) || currentDate.after(endDate))) return true;

        return false;
    }
	
    public static List<Language> getSiteLangs(Etn Etn, String siteId) {
		String COMMONS_DB = GlobalParm.getParm("COMMONS_DB");
        Set rs = Etn.execute("SELECT lang.* FROM language lang JOIN " + COMMONS_DB
                + ".sites_langs sl ON sl.langue_id=lang.langue_id WHERE sl.site_id=" + escape.cote(siteId)+" ORDER BY lang.langue_id");
        List<Language> langList = new ArrayList<>();
        while (rs.next()) {
            Language lang = new Language();
            lang.id=Integer.parseInt(rs.value("langue_id"));
            lang.name=rs.value("langue");
            lang.code=rs.value("langue_code");
            lang.og_local=rs.value("og_local");
            lang.direction=rs.value("direction");
            langList.add(lang);
        }
        return langList;
    }

    public static List<Language> getAllLangs(Etn Etn) {
		String COMMONS_DB = GlobalParm.getParm("COMMONS_DB");
        Set rs =Etn.execute("select * from language order by langue_id");
        List<Language> langList = new ArrayList<>();
        while (rs.next()) {
            Language lang = new Language();
            lang.id=Integer.parseInt(rs.value("langue_id"));
            lang.name=rs.value("langue");
            lang.code=rs.value("langue_code");
            lang.og_local=rs.value("og_local");
            lang.direction=rs.value("direction");
            langList.add(lang);
        }
        return langList;
    }

	public static Map<String, String> loadVariables(Etn Etn, String siteId, String langId, boolean isGenerateForPublish)
	{
		Map<String, String> variables = new HashMap<>();
		
		String q = "SELECT * FROM variables WHERE site_id = "+escape.cote(siteId);
		Set rsVariables = Etn.execute(q);
		while (rsVariables.next()){
			variables.put(rsVariables.value("name"), rsVariables.value("value"));
		}

		String lnk = GlobalParm.getParm("EXTERNAL_LINK");
		if (!lnk.endsWith("/")) lnk += "/";
		String basePath = lnk + GlobalParm.getParm("UPLOADS_FOLDER") + siteId;

		variables.put("images_path", basePath + "/img/");
		variables.put("videos_path", basePath + "/video/");
		variables.put("js_path", basePath + "/js/");
		variables.put("css_path", basePath + "/css/");
		variables.put("fonts_path", basePath + "/fonts/");
		variables.put("other_files_path", basePath + "/other/");
		
		// algolia settings
		if(isGenerateForPublish)//load prod site settings
		{
			q = "SELECT * FROM "+GlobalParm.getParm("PROD_CATALOG_DB")+".algolia_settings WHERE site_id = "+escape.cote(siteId);
			rsVariables  = Etn.execute(q);
			if(rsVariables.next())
			{
				variables.put("algolia_application_id", rsVariables.value("application_id"));
				variables.put("algolia_search_api_key", rsVariables.value("search_api_key"));
				variables.put("algolia_write_api_key", rsVariables.value("write_api_key"));
			}
			
            // get default index of algolia
            q = "SELECT ai.index_name as default_index_value, CONCAT('algolia_default_index_', langue_code) as default_index_name" +
                    " FROM "+GlobalParm.getParm("PROD_CATALOG_DB")+".algolia_default_index ai " +
                    " LEFT JOIN "+GlobalParm.getParm("PROD_CATALOG_DB")+".language AS l ON l.langue_id = ai.langue_id " +
                    " WHERE ai.site_id = "+escape.cote(siteId);

            rsVariables = Etn.execute(q);
            if(rsVariables.next()){
                variables.put("default_index_name", rsVariables.value("default_index_value"));
            }
			
			q = "SELECT domain FROM "+GlobalParm.getParm("PROD_PORTAL_DB")+".sites WHERE id = "+escape.cote(siteId);
			rsVariables = Etn.execute(q);
			if(rsVariables.next()){
				variables.put("domain", rsVariables.value(0));
			}
			
            rsVariables = Etn.execute("SELECT * FROM "+GlobalParm.getParm("PROD_CATALOG_DB")+".shop_parameters WHERE site_id = "+escape.cote(siteId));
            if(rsVariables.next()){

                variables.put("currency_code", PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_currency")));
                variables.put("price_formatter", PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_price_formatter")));
                variables.put("round_to_decimals", PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_round_to_decimals")));
                variables.put("show_decimals", PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_show_decimals")));
                variables.put("currency_position", PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_currency_position")));

                Set rsVariables2 = Etn.execute("SELECT * FROM "+GlobalParm.getParm("PROD_CATALOG_DB")+".langue_msg WHERE LANGUE_REF="+escape.cote(PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_currency"))));
                if(rsVariables2.next()){
                    variables.put("currency_label", rsVariables2.value("LANGUE_"+langId));
                }
            }
			
		}
		else//load test site settings
		{
			q = "SELECT * FROM "+GlobalParm.getParm("CATALOG_DB")+".algolia_settings WHERE site_id = "+escape.cote(siteId);
			rsVariables  = Etn.execute(q);
			if(rsVariables.next())
			{
				variables.put("algolia_application_id", rsVariables.value("test_application_id"));
				variables.put("algolia_search_api_key", rsVariables.value("test_search_api_key"));
				variables.put("algolia_write_api_key", rsVariables.value("test_write_api_key"));
			}

            // get default index of algolia
            q = "SELECT ai.index_name as default_index_value, CONCAT('algolia_default_index_', langue_code) as default_index_name" +
                    " FROM "+GlobalParm.getParm("CATALOG_DB")+".algolia_default_index ai " +
                    " LEFT JOIN "+GlobalParm.getParm("CATALOG_DB")+".language AS l ON l.langue_id = ai.langue_id " +
                    " WHERE ai.site_id = "+escape.cote(siteId);

            rsVariables = Etn.execute(q);
            if(rsVariables.next()){
                variables.put("default_index_name", rsVariables.value("default_index_value"));
            }
			
			q = "SELECT domain FROM "+GlobalParm.getParm("PORTAL_DB")+".sites WHERE id = "+escape.cote(siteId);
			rsVariables = Etn.execute(q);
			if(rsVariables.next()){
				variables.put("domain", rsVariables.value(0));
			}
			
            rsVariables = Etn.execute("SELECT * FROM "+GlobalParm.getParm("CATALOG_DB")+".shop_parameters WHERE site_id = "+escape.cote(siteId));
            if(rsVariables.next()){

                variables.put("currency_code", PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_currency")));
                variables.put("price_formatter", PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_price_formatter")));
                variables.put("round_to_decimals", PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_round_to_decimals")));
                variables.put("show_decimals", PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_show_decimals")));
                variables.put("currency_position", PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_currency_position")));

                Set rsVariables2 = Etn.execute("SELECT * FROM "+GlobalParm.getParm("CATALOG_DB")+".langue_msg WHERE LANGUE_REF="+escape.cote(PagesUtil.parseNull(rsVariables.value("lang_"+langId+"_currency"))));
                if(rsVariables2.next()){
                    variables.put("currency_label", rsVariables2.value("LANGUE_"+langId));
                }
            }			
		}
		return variables;
		
	}
}

