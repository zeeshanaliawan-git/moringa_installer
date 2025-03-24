package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.github.wnameless.json.flattener.JsonFlattener;
import freemarker.cache.StringTemplateLoader;
import freemarker.template.Configuration;
import freemarker.template.Template;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.jsoup.Jsoup;
import org.jsoup.nodes.*;
import org.jsoup.parser.Parser;

import java.io.*;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Generate, publish, un-publish and updates pages that are marked for
 *
 * @author Ali Adnan
 * @since 2019-04-01
 */
public class PagesGenerator extends BaseClass {

    private boolean fromPageEditor = false;

    public PagesGenerator(Etn Etn, Properties env, boolean debug) {
        super(Etn, env, debug);
		Etn.setSeparateur(2, '\001', '\002');
    }

    public PagesGenerator(Etn Etn) {
        super(Etn);
		Etn.setSeparateur(2, '\001', '\002');
    }


    public boolean isFromPageEditor() {
        return fromPageEditor;
    }

    public void setFromPageEditor(boolean fromPageEditor) {
        this.fromPageEditor = fromPageEditor;
    }

    public TemplateDataGenerator getTemplateDataGenerator(String siteId) throws Exception {
        return getTemplateDataGenerator(siteId, false);
    }

    public TemplateDataGenerator getTemplateDataGenerator(String siteId, boolean isGenerateForPublish) throws Exception {
        TemplateDataGenerator tdg = null;
        if (env != null) {
            tdg = new TemplateDataGenerator(Etn, env, debug, siteId);
            tdg.setGenerateForPublish(isGenerateForPublish);
        }
        else {
            tdg = new TemplateDataGenerator(Etn, siteId);
            tdg.setGenerateForPublish(isGenerateForPublish);
        }
        return tdg;
    }

    public void algoliaIndexation(String type,String ids,String siteId,String publishStatus,String publishBy) throws Exception{
        
        if(ids.length()>0){
            String typePage="";
            String publish=publishStatus;


            if(type.equalsIgnoreCase("freemarker")){
                typePage="page";
            }
            else if(type.equalsIgnoreCase("structured")){
                
                String query="select case when coalesce(b.type,'') = 'store' then 'store' "+
                "when c.type = 'content' then 'structuredcontent' when b.type = 'structured_page' then 'structuredpage' else 'new_product' end type"+
                " from structured_contents c "+
                " left join bloc_templates b on b.id = c.template_id "+
                " where c.site_id = "+escape.cote(siteId)+" and c.id="+escape.cote(ids);
                Set rs = Etn.execute(query);
                if(rs.next() && rs.rs.Rows>0){
                    typePage=PagesUtil.parseNull(rs.value("type"));
                }
            }
            
            Etn.executeCmd("insert into "+env.getProperty("PROD_PORTAL_DB")+".publish_content (cid,site_id,publication_type,ctype,priority,created_by,updated_by)"+
            " values ("+escape.cote(ids)+","+escape.cote(siteId)+","+escape.cote(publish)+","+escape.cote(typePage)+
            ",NOW(),"+escape.cote(publishBy)+","+escape.cote(publishBy)+")");

            Etn.execute("select semfree("+escape.cote(getParm("PORTAL_ENG_SEMA"))+")");
        }
    }


    public void generateAllMarkedPages() throws Exception {
        getParm("BASE_DIR"); //testing env

        String q;
        Set rs;
        //first generate structured pages
        generateAllMarkedStructuredPages();
        generateAllMarkedBlocPages();
    }

    public void generateAllMarkedStructuredPages() throws Exception {

        String q;
        Set rs;

        try {
            q = "SELECT id as content_id, site_id FROM structured_contents"
                    + " WHERE to_generate = '1'";
            rs = Etn.execute(q);

            if (debug && rs.rs.Rows > 0) {
                log("****** Generating " + rs.rs.Rows + " structured pages");
            }
            while (rs.next()) {

				//some tasks take time in pages module so we must set the engine status at such points
				if (env != null) //this means its running from engine 
				{
					Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Pages',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
				}

                String contentId = rs.value("content_id");
                String siteId = rs.value("site_id");
                String errorMsg = "";
                try {
                    errorMsg = generateAndSaveStructuredPage(contentId);
                }
                catch (Exception ex) {
                    logE("Error in generating pages of content : " + contentId);
                    ex.printStackTrace();
                    errorMsg = ex.getMessage();
                }

                if (errorMsg.length() == 0) {
                    q = "UPDATE structured_contents "
                            + " SET to_generate = 0, updated_by = IFNULL(to_generate_by,1), updated_ts = NOW()  "
                            + " WHERE id = " + escape.cote(contentId);
                    Etn.executeCmd(q);						
                }
                else {
                    q = " UPDATE structured_contents "
                            + " SET publish_status = 'error',to_generate = 0, publish_log = " + escape.cote(errorMsg)
                            + " WHERE id = " + escape.cote(contentId);
                    Etn.executeCmd(q);
                }

            }
        }
        finally {

        }
    }

    public void generateAllMarkedBlocPages() throws Exception {
        String q;
        Set rs;

        try {
            q = "SELECT id as page_id, site_id FROM freemarker_pages"
                    + " WHERE to_generate = '1'"
                    + " AND  is_deleted = '0'";
            rs = Etn.execute(q);
            if (debug && rs.rs.Rows > 0) {
                log("****** Generating " + rs.rs.Rows + " bloc pages");
            }
            while (rs.next()) {

				//some tasks take time in pages module so we must set the engine status at such points
				if (env != null) //this means its running from engine 
				{
					Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Pages',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
				}

                String pageId = rs.value("page_id");
                String siteId = rs.value("site_id");
                String errorMsg = "";
                try {
                    errorMsg = generateAndSaveBlocPage(pageId);					
                }
                catch (Exception ex) {
                    logE("Error in generating page: " + pageId);
                    ex.printStackTrace();
                    errorMsg = ex.getMessage();
                }
                if (errorMsg.length() == 0) {
                    q = "UPDATE freemarker_pages "
                            + " SET to_generate = 0, updated_by = IFNULL(to_generate_by,1), updated_ts = NOW()  "
                            + " WHERE id = " + escape.cote(pageId)
                            + " AND  is_deleted = '0'";
                    Etn.executeCmd(q);										
                }
                else {
                    q = " UPDATE freemarker_pages "
                            + " SET publish_status = 'error',to_generate = 0, publish_log = " + escape.cote(errorMsg)
                            + " WHERE id = " + escape.cote(pageId)
                            + " AND  is_deleted = '0'";
                    Etn.executeCmd(q);
                }
            }
        }
        finally {

        }
    }

    public void publishAllMarkedBlocPages() throws Exception {

        String q;
        Set rs;
        try {

            q = " SELECT DISTINCT id, site_id "
                    + " FROM freemarker_pages "
                    + " WHERE to_publish = '1' AND to_publish_ts <= NOW()"
                    + " AND  is_deleted = '0'";
            rs = Etn.execute(q);

            if (debug && rs.rs.Rows > 0) {
                log("****** Publishing " + rs.rs.Rows + " marked bloc pages");
            }
            while (rs.next()) {
				//some tasks take time in pages module so we must set the engine status at such points
				if (env != null) //this means its running from engine 
				{
					Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Pages',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
				}

                String pageId = rs.value("id");
                String errorMsg = "";

                try {
                    publishBlocPage(pageId);		
					
					Etn.executeCmd("update "+getParm("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and site_id = "+escape.cote(rs.value("site_id"))+" and task in ('publish','unpublish') and content_type = 'freemarker' and content_id ="+escape.cote(pageId));
					int cacheTasks = Etn.executeCmd("insert into "+getParm("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
							" values("+escape.cote(rs.value("site_id"))+", 'freemarker', "+escape.cote(pageId)+", 'publish') ");
							
					if(cacheTasks > 0)
					{
						Etn.execute("select semfree("+escape.cote(getParm("PORTAL_ENG_SEMA"))+")");
					}					
                }
                catch (Exception ex) {
                    logE("Error in publishing bloc page : " + pageId);
                    ex.printStackTrace();
                }

            }
        }
        finally {

        }
    }


    public void publishAllMarkedStructuredPages() throws Exception {

        String q;
        Set rs;
        try {

            q = " SELECT DISTINCT id, site_id "
                    + " FROM structured_contents "
                    + " WHERE type = 'page' "
                    + " AND to_publish = '1' AND to_publish_ts <= NOW()";
            rs = Etn.execute(q);

            if (debug && rs.rs.Rows > 0) {
                log("****** Publishing " + rs.rs.Rows + " marked structured pages");
            }
            while (rs.next()) {
				
				//some tasks take time in pages module so we must set the engine status at such points
				if (env != null) //this means its running from engine 
				{
					Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Pages',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
				}
				
                String contentId = rs.value("id");
                String errorMsg = "";

                try {
                    publishStructuredPage(contentId);
					
					Etn.executeCmd("update "+getParm("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and site_id = "+escape.cote(rs.value("site_id"))+" and task in ('publish','unpublish') and content_type = 'structured' and content_id ="+escape.cote(contentId));
					int cacheTasks = Etn.executeCmd("insert into "+getParm("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
							" values("+escape.cote(rs.value("site_id"))+", 'structured', "+escape.cote(contentId)+", 'publish') ");
							
					if(cacheTasks > 0)
					{
						Etn.execute("select semfree("+escape.cote(getParm("PORTAL_ENG_SEMA"))+")");
					}
                }
                catch (Exception ex) {
                    logE("Error in publishing structured page : " + contentId);
                    ex.printStackTrace();
                }

            }
        }
        finally {

        }

    }

    public void unPublishAllMarkedPages() throws Exception {
        unPublishAllMarkedBlocPages();
        unPublishAllMarkedStructuredPages();
    }

    public void unPublishAllMarkedStructuredPages() throws Exception {

        String q;
        Set rs;
        try {

            q = " SELECT DISTINCT id, site_id "
                    + " FROM structured_contents "
                    + " WHERE type = 'page' "
                    + " AND to_unpublish = '1' AND to_unpublish_ts <= NOW()";
            rs = Etn.execute(q);

            if (debug && rs.rs.Rows > 0) {
                log("****** Publishing " + rs.rs.Rows + " marked structured pages");
            }
            while (rs.next()) {
				//some tasks take time in pages module so we must set the engine status at such points
				if (env != null) //this means its running from engine 
				{
					Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Pages',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
				}
				
                String contentId = rs.value("id");
                String errorMsg = "";

                try {
                    unPublishStructuredPage(contentId);
					
					Etn.executeCmd("update "+getParm("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and site_id = "+escape.cote(rs.value("site_id"))+" and task in ('publish','unpublish') and content_type = 'structured' and content_id ="+escape.cote(contentId));
					int cacheTasks = Etn.executeCmd("insert into "+getParm("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
							" values("+escape.cote(rs.value("site_id"))+", 'structured', "+escape.cote(contentId)+", 'unpublish') ");
					
					if(cacheTasks > 0)
					{
						Etn.execute("select semfree("+escape.cote(getParm("PORTAL_ENG_SEMA"))+")");
					}
                }
                catch (Exception ex) {
                    logE("Error in publishing structured page : " + contentId);
                    ex.printStackTrace();
                }

            }
        }
        finally {

        }

    }

    public void unPublishAllMarkedBlocPages() throws Exception {

        String q;
        Set rs;
        try {

            q = " SELECT DISTINCT id, site_id "
                    + " FROM freemarker_pages "
                    + " WHERE to_unpublish = '1' AND to_unpublish_ts <= NOW()"
                    + " AND  is_deleted = '0'";
            rs = Etn.execute(q);

            if (debug && rs.rs.Rows > 0) {
                log("****** Publishing " + rs.rs.Rows + " marked bloc pages");
            }
            while (rs.next()) {
				
				//some tasks take time in pages module so we must set the engine status at such points
				if (env != null) //this means its running from engine 
				{
					Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Pages',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
				}
				
                String id = rs.value("id");
                String errorMsg = "";

                try {
                    unPublishBlocPage(id);	
					
					Etn.executeCmd("update "+getParm("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and site_id = "+escape.cote(rs.value("site_id"))+" and task in ('publish','unpublish') and content_type = 'freemarker' and content_id ="+escape.cote(id));
					int cacheTasks = Etn.executeCmd("insert into "+getParm("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
						" values("+escape.cote(rs.value("site_id"))+", 'freemarker', "+escape.cote(id)+", 'unpublish') ");
						
					if(cacheTasks > 0)
					{
						Etn.execute("select semfree("+escape.cote(getParm("PORTAL_ENG_SEMA"))+")");
					}
                }
                catch (Exception ex) {
                    logE("Error in publishing bloc page : " + id);
                    ex.printStackTrace();
                }

            }
        }
        finally {

        }
    }

    
    public void publishStructuredPage(String contentId) throws Exception {

        String q = "SELECT p.id,p.site_id, scd.langue_id, p.langue_code FROM pages p"
                + " JOIN structured_contents_details scd ON p.id = scd.page_id "
                + " JOIN structured_contents sc ON sc.id = scd.content_id "
                + " WHERE  sc.id = " + escape.cote(contentId)
                + " AND p.type = " + escape.cote(Scheduler.PAGE_TYPE_STRUCTURED);

        Set pagesRs = Etn.execute(q);
        String errorMsg = "";
        String siteId="";
        String publishBy="";

        while (pagesRs.next()) {

            String pageId = pagesRs.value("id");
            String langId = pagesRs.value("langue_id");
            String langCode = pagesRs.value("langue_code");
            siteId = pagesRs.value("site_id");
            try {
                publishPage(pageId);				
            }
            catch (Exception ex) {
                ex.printStackTrace();
                errorMsg += "Error in publishing page: " + pageId
                        + ", lang id : " + langId
                        + "\n" + ex.getMessage() + "\n";
            }
        }
		
        boolean isCopied = PagesUtil.copyContentPublish(Etn, contentId);
        if (!isCopied) {
            errorMsg += " Error in copying data to publish table.\n";
        }

        if (errorMsg.length() == 0) {
            q = " UPDATE structured_contents "
                    + " SET published_ts = NOW() "
                    + " , published_by = to_publish_by "
                    + " , publish_status = 'published' "
                    + " , to_publish = 0 , to_publish_ts = NULL"
                    + " WHERE id = " + escape.cote(contentId);
            Etn.executeCmd(q);
			//we must set appropriate published_ts in published tables as well
            q = " UPDATE structured_contents_published "
                    + " SET published_ts = NOW() "
                    + " , published_by = to_publish_by "
                    + " , publish_status = 'published' "
                    + " , to_publish = 0 , to_publish_ts = NULL"
                    + " WHERE id = " + escape.cote(contentId);
            Etn.executeCmd(q);

            Set rsP = Etn.execute("select c.id, c.site_id " +
                    " from structured_contents c " +
                    " inner join bloc_templates b on b.id = c.template_id and b.type = 'store' " +
                    " where c.id = " + escape.cote(contentId));
            if (rsP.next())//its a store
            {
                Etn.executeCmd("insert into partoo_publish (cid, ctype, site_id) values(" + escape.cote(contentId) + ", 'store', " + escape.cote(rsP.value("site_id")) + ") ");
            }

            if(siteId.length()>0){

                Set rsNew = Etn.execute("select to_publish_by from structured_contents where id="+escape.cote(contentId));
                if(rsNew.next()){
                    publishBy=PagesUtil.parseNull(rsP.value("to_publish_by"));
                }
                try{
                    algoliaIndexation("structured",contentId,siteId,"publish",publishBy);
                }catch (Exception ex) {
                    ex.printStackTrace();
                    errorMsg += "Error in Algolia Publication";
                }
            }
            
        }
        else {
            q = " UPDATE structured_contents "
                    + " SET publish_status = 'error',to_publish = 0 ,to_publish_ts = NULL, publish_log = " + escape.cote(errorMsg)
                    + " WHERE id = " + escape.cote(contentId);
            Etn.executeCmd(q);
            
        }
    }


    public void publishBlocPage(String id) throws Exception {

        String CATALOG_DB = getParm("CATALOG_DB");

        String q = "SELECT p.id, l.langue_id, p.site_id, p.langue_code FROM freemarker_pages pp"
                + " JOIN pages p ON p.parent_page_id = pp.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)
                + " JOIN "+CATALOG_DB+".language l ON l.langue_code = p.langue_code "
                + " WHERE  pp.id = " + escape.cote(id)
                + " AND  pp.is_deleted = '0'";

        Set pagesRs = Etn.execute(q);
        String errorMsg = "";
        while (pagesRs.next()) {

            String pageId = pagesRs.value("id");
            String langId = pagesRs.value("langue_id");
            String langCode = pagesRs.value("langue_code");
            try {
                publishPage(pageId);				
            }
            catch (Exception ex) {
                ex.printStackTrace();
                errorMsg += "Error in publishing page: " + pageId
                        + ", lang id : " + langId
                        + "\n" + ex.getMessage() + "\n";
            }
        }

        if (errorMsg.length() == 0) {
            q = " UPDATE freemarker_pages "
                    + " SET published_ts = NOW() "
                    + " , published_by = to_publish_by "
                    + " , publish_status = 'published' "
                    + " , to_publish = 0 , to_publish_ts = NULL"
                    + " WHERE id = " + escape.cote(id)
                    + " AND  is_deleted = '0'";
            Etn.executeCmd(q);
        }
        else {
            q = " UPDATE freemarker_pages "
                    + " SET publish_status = 'error',to_publish = 0 ,to_publish_ts = NULL, publish_log = " + escape.cote(errorMsg)
                    + " WHERE id = " + escape.cote(id)
                    + " AND  is_deleted = '0'";
            Etn.executeCmd(q);
        }
    }

    private boolean regeneratePageForPublish(String id, String type)
    {
        //no other type supported yet
        if(type.equals(Scheduler.PAGE_TYPE_FREEMARKER) == false && type.equals(Scheduler.PAGE_TYPE_STRUCTURED) == false) return false;
        log("in regeneratePageForPublish id : " + id + " type : " + type);
        String errorMsg = "";
        try {
            generateAndSavePage(id, true);
        }
        catch (Exception ex) {
            logE("Error in regenerating page for publish : " + id);
            ex.printStackTrace();
            errorMsg = ex.getMessage();
        }
        if (errorMsg.length() > 0) {
            String q = "";
            if(type.equals(Scheduler.PAGE_TYPE_FREEMARKER))
            {
                q = " UPDATE freemarker_pages "
                        + " SET publish_status = 'error',to_publish = 0 ,to_publish_ts = NULL, publish_log = " + escape.cote(errorMsg)
                        + " WHERE id = " + escape.cote(id)
                        + " AND  is_deleted = '0'";
            }
            else if(type.equals(Scheduler.PAGE_TYPE_STRUCTURED))
            {
                q = " UPDATE structured_contents "
                        + " SET publish_status = 'error', to_publish = 0 ,to_publish_ts = NULL, publish_log = " + escape.cote(errorMsg)
                        + " WHERE id = " + escape.cote(id);
                Etn.executeCmd(q);
            }
            Etn.executeCmd(q);
            return false;
        }
        return true;
    }

    public void publishPage(String pageId) throws Exception {

        String q = " SELECT html_file_path, published_html_file_path, type "
                + " FROM pages "
                + " WHERE type IN ( " + escape.cote(Scheduler.PAGE_TYPE_FREEMARKER)
                + "," + escape.cote(Scheduler.PAGE_TYPE_STRUCTURED) + " ) "
                + " AND id = " + escape.cote(pageId);
        Set rs = Etn.execute(q);
        if (!rs.next()) {
            throw new Exception("Error: invalid page id");
        }
        if(regeneratePageForPublish(pageId, rs.value("type")) == false)
        {
            throw new Exception("Error: Unable to regenerate page for publish");
        }

        String pageHtmlPath = PagesUtil.parseNull(rs.value("html_file_path"));
        String oldPublishedHtmlPath = PagesUtil.parseNull(rs.value("published_html_file_path"));

        String BASE_DIR = getParm("BASE_DIR");
        String PAGES_PUBLISH_FOLDER = getParm("PAGES_PUBLISH_FOLDER");

        String srcFilePath = BASE_DIR + PAGES_PUBLISH_FOLDER + pageHtmlPath;
        String destFilePath = BASE_DIR + PAGES_PUBLISH_FOLDER + pageHtmlPath;

        log("*********** pageHtmlPath " + pageHtmlPath);
        log("*********** oldPublishedHtmlPath " + oldPublishedHtmlPath);
        //delete old file if different
        if (oldPublishedHtmlPath.length() > 0 && !oldPublishedHtmlPath.equals(pageHtmlPath)) {

            File oldPublishedFile = new File(BASE_DIR + PAGES_PUBLISH_FOLDER + oldPublishedHtmlPath);
            if (oldPublishedFile.exists() && oldPublishedFile.isFile()) {
                oldPublishedFile.delete();
            }
        }

        q = " UPDATE pages SET published_ts = NOW() "
                + ", published_by = to_publish_by ,attempt=attempt+1, publish_status = 'published' "
                + ", published_html_file_path = " + escape.cote(pageHtmlPath)
                + " , to_publish = 0 , to_publish_ts = NULL"
                + " WHERE id = " + escape.cote(pageId);
        Etn.executeCmd(q);
    }

    public void unPublishStructuredPage(String contentId) throws Exception {

        String q = "SELECT p.id,p.site_id, scd.langue_id,p.langue_code FROM pages p"
                + " JOIN structured_contents_details scd ON p.id = scd.page_id "
                + " JOIN structured_contents sc ON sc.id = scd.content_id "
                + " WHERE  sc.id = " + escape.cote(contentId)
                + " AND p.type = " + escape.cote(Scheduler.PAGE_TYPE_STRUCTURED);

        Set pagesRs = Etn.execute(q);
        String siteId="";
        String publishBy="";
        String errorMsg = "";

        while (pagesRs.next()) {
            String pageId = pagesRs.value("id");
            String langId = pagesRs.value("langue_id");
            String langCode = pagesRs.value("langue_code");
            siteId = pagesRs.value("site_id");
            try {
                unPublishPage(pageId);				
            }
            catch (Exception ex) {
                ex.printStackTrace();
                errorMsg += "Error in unpublishing page: " + pageId
                        + ", lang id : " + langId
                        + "\n" + ex.getMessage() + "\n";
            }

        }

        boolean isCopied = PagesUtil.deleteContentPublish(Etn, contentId);
        if (!isCopied) {
            errorMsg += " Error in deleting data from publish table.\n";
        }

        if (errorMsg.length() == 0) {
            q = " UPDATE structured_contents "
                    + " SET published_ts = NULL, published_by = NULL"
                    + " , to_unpublish = 0 "
                    + " , publish_status = 'unpublished' " //leave to_unpublish_by , and _ts for record
                    + " WHERE id = " + escape.cote(contentId);

            Etn.executeCmd(q);

            Set rsP = Etn.execute("select c.id, c.site_id,c.to_unpublish_by " +
                    " from structured_contents c " +
                    " inner join bloc_templates b on b.id = c.template_id and b.type = 'store' " +
                    " where c.id = " + escape.cote(contentId));
            if (rsP.next())//its a store
            {
                Etn.executeCmd("insert into partoo_publish (cid, ctype, site_id) values(" + escape.cote(contentId) + ", 'store', " + escape.cote(rsP.value("site_id")) + ") ");
            }
            if(siteId.length()>0){
                Set rsNew = Etn.execute("select to_unpublish_by from structured_contents where id="+escape.cote(contentId));
                if(rsNew.next()){
                    publishBy=PagesUtil.parseNull(rsP.value("to_unpublish_by"));
                }
                try{
                    algoliaIndexation("structured",contentId,siteId,"unpublish",publishBy);
                }catch (Exception ex) {
                    ex.printStackTrace();
                    errorMsg += "Error in Algolia Publication unpublish";
                }
            }
        }
        else {
            q = " UPDATE structured_contents "
                    + " SET publish_status = 'error', publish_log = " + escape.cote(errorMsg)
                    + " WHERE id = " + escape.cote(contentId);
            Etn.executeCmd(q);
        }
    }

    public void unPublishBlocPage(String id) throws Exception {

        String CATALOG_DB = getParm("CATALOG_DB");
        String q = "SELECT p.id, l.langue_id, p.site_id, p.langue_code FROM freemarker_pages pp"
                + " JOIN pages p ON p.parent_page_id = pp.id AND p.type = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)
                + " JOIN "+CATALOG_DB+".language l ON l.langue_code = p.langue_code "
                + " WHERE  pp.id = " + escape.cote(id)
                + " AND  pp.is_deleted = '0'";
        Set pagesRs = Etn.execute(q);
        String errorMsg = "";

        while (pagesRs.next()) {
            String pageId = pagesRs.value("id");
            String langId = pagesRs.value("langue_id");
            String langCode = pagesRs.value("langue_code");
            try {
                unPublishPage(pageId);				
            }
            catch (Exception ex) {
                ex.printStackTrace();
                errorMsg += "Error in unpublishing page: " + pageId
                        + ", lang id : " + langId
                        + "\n" + ex.getMessage() + "\n";
            }

        }

        if (errorMsg.length() == 0) {
            q = " UPDATE freemarker_pages "
                    + " SET published_ts = NULL, published_by = NULL"
                    + " , to_unpublish = 0 "
                    + " , publish_status = 'unpublished' " //leave to_unpublish_by , and _ts for record
                    + " WHERE id = " + escape.cote(id)
                    + " AND  is_deleted = '0'";

            Etn.executeCmd(q);
        } else {
            q = " UPDATE freemarker_pages  SET publish_status = 'error', publish_log = " + escape.cote(errorMsg)+ " WHERE id = " + escape.cote(id)+ " AND  is_deleted = '0'";
            Etn.executeCmd(q);
        }
    }

    public void unPublishPage(String pageId) throws Exception {

        String q = " SELECT id, type, site_id, variant, langue_code, path,  published_html_file_path "
                + " FROM pages "
                + " WHERE id = " + escape.cote(pageId);
        Set rs = Etn.execute(q);
        if (!rs.next()) {
            throw new Exception("Error: invalid page id");
        }

        String pageType = rs.value("type");
        String BASE_DIR = getParm("BASE_DIR");
        String PAGES_PUBLISH_FOLDER = getParm("PAGES_PUBLISH_FOLDER");

        if (Scheduler.PAGE_TYPE_FREEMARKER.equals(pageType)
                || Scheduler.PAGE_TYPE_STRUCTURED.equals(pageType)) {

            String publishedHtmlPath = PagesUtil.parseNull(rs.value("published_html_file_path"));

            if (publishedHtmlPath.length() > 0) {
                String publishedFilePath = BASE_DIR + PAGES_PUBLISH_FOLDER + publishedHtmlPath;

                File publishedFile = new File(publishedFilePath);

                if (publishedFile.exists() && publishedFile.isFile()) {
                    publishedFile.delete();
                }
            }
        }
        else if (Scheduler.PAGE_TYPE_REACT.equals(pageType)) {
            String siteId = PagesUtil.parseNull(rs.value("site_id"));
            String variant = PagesUtil.parseNull(rs.value("variant"));
            String langCode = PagesUtil.parseNull(rs.value("langue_code"));
            String path = PagesUtil.parseNull(rs.value("path"));

            String publishFolderPath = PagesUtil.getDynamicPagePath(siteId, langCode, variant, path);
            if (publishFolderPath.length() > 0) {
                publishFolderPath = BASE_DIR + PAGES_PUBLISH_FOLDER + publishFolderPath;
                File publishedFolder = new File(publishFolderPath);
                if (publishedFolder.exists() && publishedFolder.isDirectory()) {
                    FilesUtil.deleteDirectory(publishedFolder);
                }
            }

        }

        q = " UPDATE pages SET published_ts = NULL, published_by = NULL "
                + " , published_html_file_path = '' "
                + " , to_unpublish = 0 " //leave to_unpublish_by , and _ts for record
                + " , publish_status = 'unpublished' " //leave to_unpublish_by , and _ts for record
                + " WHERE id = " + escape.cote(pageId);
        Etn.executeCmd(q);

    }

    public String generateAndSaveStructuredPage(String contentId) throws Exception {
        return generateAndSaveStructuredPage(contentId, false);
    }

    public String generateAndSaveStructuredPage(String contentId, boolean isGenerateForPublish) throws Exception {
        String errorMsg = "";

        String q = "SELECT p.id, scd.langue_id, p.site_id, p.langue_code FROM pages p"
                + " JOIN structured_contents_details scd ON p.id = scd.page_id "
                + " JOIN structured_contents sc ON sc.id = scd.content_id "
                + " WHERE  sc.id = " + escape.cote(contentId)
                + " AND p.type = " + escape.cote(Scheduler.PAGE_TYPE_STRUCTURED);

        Set pagesRs = Etn.execute(q);

		String siteId = "";
        while (pagesRs.next()) {
			siteId = pagesRs.value("site_id");
            String pageId = pagesRs.value("id");
            String langId = pagesRs.value("langue_id");
            String langCode = pagesRs.value("langue_code");
            try {
                if (PagesUtil.parseInt(pageId) > 0) generateAndSavePage(pageId, isGenerateForPublish);					
            } catch (Exception ex) {
                ex.printStackTrace();
                errorMsg += "Error in generating page: " + pageId+", lang id : " + langId+ "\n" + ex.getMessage();
            }
        }

		//this function is called from webapp also so we enter the cache_task here
		//when isGenerateForPublish = true means the page is just being regenerated for publishing so we do not have to recache it in test site
		if(errorMsg.length() == 0 && isGenerateForPublish == false) {
			Etn.executeCmd("update "+getParm("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and site_id = "+escape.cote(siteId)+" and task = 'generate' and content_type = 'structured' and content_id ="+escape.cote(contentId));
			int cacheTasks = Etn.executeCmd("insert into "+getParm("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
						" values("+escape.cote(siteId)+", 'structured', "+escape.cote(contentId)+", 'generate') ");
						
			if(cacheTasks > 0) Etn.execute("select semfree("+escape.cote(getParm("PORTAL_ENG_SEMA"))+")");
		}
		
        return errorMsg;
    }

    public String generateAndSaveBlocPage(String id) throws Exception {
        return generateAndSaveBlocPage(id, false);
    }

    public String generateAndSaveBlocPage(String id, boolean isGenerateForPublish) throws Exception {
        log("Generating page "+id);
        String errorMsg = "";
        String CATALOG_DB = getParm("CATALOG_DB");

        String q = "SELECT p.id, l.langue_id, pp.site_id, p.langue_code FROM freemarker_pages pp"
                + " JOIN pages p ON p.parent_page_id = pp.id AND type  = "+escape.cote(Constant.PAGE_TYPE_FREEMARKER)
                + " JOIN "+CATALOG_DB+".language l ON l.langue_code = p.langue_code "
                + " WHERE  pp.id = " + escape.cote(id)
                + " AND  pp.is_deleted = '0'";
        Set pagesRs = Etn.execute(q);

		String siteId = "";
        while (pagesRs.next()) {
			siteId = pagesRs.value("site_id");
            String pageId = pagesRs.value("id");
            String langId = pagesRs.value("langue_id");
            String langCode = pagesRs.value("langue_code");
            try {
                if (PagesUtil.parseInt(pageId) > 0) generateAndSavePage(pageId, isGenerateForPublish);
            } catch (Exception ex) {
                ex.printStackTrace();
                errorMsg += "Error in generating page: " + pageId+ ", lang id : " + langId+ "\n" + ex.getMessage();
            }
        }
		
		//this function is called from webapp also so we enter the cache_task here
		//when isGenerateForPublish = true means the page is just being regenerated for publishing so we do not have to recache it in test site
		if(errorMsg.length() == 0 && isGenerateForPublish == false) {
			Etn.executeCmd("update "+getParm("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and site_id = "+escape.cote(siteId)+" and task = 'generate' and content_type = 'freemarker' and content_id ="+escape.cote(id));
			int cacheTasks = Etn.executeCmd("insert into "+getParm("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
						" values("+escape.cote(siteId)+", 'freemarker', "+escape.cote(id)+", 'generate') ");

			if(cacheTasks > 0) Etn.execute("select semfree("+escape.cote(getParm("PORTAL_ENG_SEMA"))+")");
		}							

        return errorMsg;
    }

    public String generateAndSavePage(String pageId) throws Exception {
        return generateAndSavePage(pageId, false);
    }

    public String generateAndSavePage(String pageId, boolean isGenerateForPublish) throws Exception {

        log("in generateAndSavePage pageId : "+pageId + " isGenerateForPublish " + isGenerateForPublish);

        String q = "SELECT path, variant, langue_code, site_id, html_file_path, type "
                + " FROM pages "
                + " WHERE type IN ( " + escape.cote(Scheduler.PAGE_TYPE_FREEMARKER)
                + "," + escape.cote(Scheduler.PAGE_TYPE_STRUCTURED) + " ) "
                + " AND id = " + escape.cote(pageId);
        Set rs = Etn.execute(q);

        if (!rs.next()) {
            throw new Exception("Invalid page id = " + pageId);
        }

        String pageHtmlStr = generatePageString(pageId, isGenerateForPublish);

        String siteId = rs.value("site_id");
        String pagePath = rs.value("path");
        String pageVariant = rs.value("variant");
        String pageLang = rs.value("langue_code");
        String oldPageHtmlPath = PagesUtil.parseNull(rs.value("html_file_path"));

        String BASE_DIR = getParm("BASE_DIR");
        String PAGES_SAVE_FOLDER = getParm("PAGES_SAVE_FOLDER");
        String PAGES_DIR = BASE_DIR + PAGES_SAVE_FOLDER;
        //if we are regenerating the page for Publish, we must generate it directly into the pulish folder
        if(isGenerateForPublish) PAGES_DIR = BASE_DIR + getParm("PAGES_PUBLISH_FOLDER");
        log("In generateAndSavePage PAGES_DIR : " + PAGES_DIR);

        pagePath = PagesUtil.getPrefixedPagePath(Etn, pageId, pageLang, pagePath, rs.value("type"), siteId);

        String pageHtmlPath = PagesUtil.getPageHtmlPath(pagePath, pageVariant, pageLang, siteId);
        //check and delete previous file, if path changed
        log("---------------------------- oldPageHtmlPath " + oldPageHtmlPath);
        log("---------------------------- pageHtmlPath " + pageHtmlPath);
        if (oldPageHtmlPath.length() > 0 && !pageHtmlPath.equals(oldPageHtmlPath)) {
            File oldFile = new File(PAGES_DIR + oldPageHtmlPath);
            if (oldFile.exists()) oldFile.delete();
        }

        File pageHtmlFile = new File(PAGES_DIR + pageHtmlPath);
        File folder = pageHtmlFile.getParentFile();
        if (!folder.exists()) folder.mkdirs();

        if (!pageHtmlFile.exists()) pageHtmlFile.createNewFile();

        if (debug) log("write to file : " + pageHtmlFile.getAbsolutePath());

        FilesUtil.writeFile(pageHtmlFile, pageHtmlStr);

        q = "UPDATE pages SET html_file_path = " + escape.cote(pageHtmlPath)+" WHERE id = " + escape.cote(pageId);
        Etn.executeCmd(q);

        if (debug) log("Page saved at : " + PAGES_DIR + pageHtmlPath);
        return pageHtmlStr;
    }

    public String generatePageString(String pageId) throws Exception {
        return generatePageString(pageId, null, false);
    }

    public String generatePageString(String pageId, boolean isGenerateForPublish) throws Exception {
        return generatePageString(pageId, null, isGenerateForPublish);
    }

    public String generatePageString(String pageId, ArrayList<String> blocIdsList) throws Exception {
        return generatePageString(pageId, blocIdsList, false);
    }

    // isGenerateForPublish added by umair to make separate pages for Test site and prod site
    // this was required for view where we have to fill up the URLs and we were always filling those from prod site
    // which was an issue testing things in Test site
    // also we will add some page info javascript object in all pages from now so that user can know the clientapis urls and
    // environment ( Test or Prod ) even in the preview
    public String generatePageString(String pageId, ArrayList<String> blocIdsList, boolean isGenerateForPublish) throws Exception {
        log("Generating page -------------------: " + pageId);
            
        boolean isBlocList = (blocIdsList != null);
        String blocIdQueryList = "";
        if (isBlocList) {
            blocIdQueryList = PagesUtil.listToEscapedCommaSeperated(blocIdsList);
            if (blocIdQueryList.length() == 0) blocIdQueryList = escape.cote("-1");
        }

        String q = null;
        Set rs = null;

        q = " SELECT p.*, l.og_local as og_local, l.direction as lang_dir, l.langue_id "
                + ", date_format(p.created_ts, '%Y-%m-%d') as created_ts_date, DATE_FORMAT(p.created_ts,'%H:%i:%s') as created_ts_time "
                + ", date_format(p.updated_ts, '%Y-%m-%d') as updated_ts_date, DATE_FORMAT(p.updated_ts,'%H:%i:%s') as updated_ts_time "
                + ", date_format(p.published_ts, '%Y-%m-%d') as published_ts_date, DATE_FORMAT(p.published_ts,'%H:%i:%s') as published_ts_time "
                + ", s.suid as site_uuid "
                + " FROM pages p "
                + " JOIN language l ON p.langue_code = l.langue_code "
                + " JOIN "+getParm("PORTAL_DB")+".sites s ON s.id = p.site_id "
                + " WHERE p.id = " + escape.cote(pageId);
        Set pageRs = Etn.execute(q);

        if (!pageRs.next()) { 
            throw new Exception("Error invalid parameters");
        }

        Map<String, Object> pageHM = new HashMap<>();
        Map<String, Object> metaHM = new HashMap<>();		
        
        String langId = pageRs.value("langue_id");
        String langCode = pageRs.value("langue_code");
        String siteId = pageRs.value("site_id");
        String siteSuid = pageRs.value("site_uuid");
        String pageType = pageRs.value("type");
        String pageLangId = pageRs.value("langue_id");

        int pageTemplateId = PagesUtil.parseInt(pageRs.value("template_id"), 0);
		pageHM.put("page_template_id", pageTemplateId);

        TemplateDataGenerator templateDataGen = getTemplateDataGenerator(siteId, isGenerateForPublish);

        String BASE_DIR = getParm("BASE_DIR");
        String TEMPLATES_DIR = BASE_DIR + "/WEB-INF/templates/";

        String CONTEXT_PATH = getParm("EXTERNAL_LINK");
        String UPLOADS_FOLDER = getParm("UPLOADS_FOLDER") + siteId + "/";
        String CATALOG_DB = getParm("CATALOG_DB");
        String PORTAL_DB = getParm("PORTAL_DB");
        String PROD_PORTAL_DB = getParm("PROD_PORTAL_DB");
        String IMAGE_FOLDER_PATH = BASE_DIR + UPLOADS_FOLDER + "/img/";
        String UPLOADS_URL_PREFIX = CONTEXT_PATH + UPLOADS_FOLDER;
        String IMAGE_URL_PREPEND = UPLOADS_URL_PREFIX + "img/";
        String CSS_URL_PREPEND = UPLOADS_URL_PREFIX + "css/";
        String JS_URL_PREPEND = UPLOADS_URL_PREFIX + "js/";

        LinkedHashMap<String, String> tagsHM = PagesUtil.getAllTags(Etn, siteId, CATALOG_DB);        
        Map<String, Object> siteParamHM = PagesUtil.getSiteParamDataMap(Etn, siteId, langId, PROD_PORTAL_DB);

        PagesUtil.fillPageAndMetaDataMap(Etn, pageHM, metaHM, pageRs,IMAGE_FOLDER_PATH, IMAGE_URL_PREPEND, debug);

        StringBuilder pageCustomMetaTags = new StringBuilder();
        StringBuilder pageBody = new StringBuilder();
        StringBuilder pageBodyCss = new StringBuilder();
        StringBuilder pageBodyJs = new StringBuilder();
        ArrayList<JSONObject> pageBodyJsonlds = new ArrayList<>();
        StringTemplateLoader stringTemplateLoader = new StringTemplateLoader();

        q = " SELECT pbt.* FROM (SELECT DISTINCT bt.id, bt.template_code, bt.js_code, bt.css_code, bt.jsonld_code FROM bloc_templates bt JOIN blocs b ON b.template_id = bt.id ";

        if (!isBlocList) q += " JOIN pages_blocs pb ON pb.bloc_id = b.id WHERE pb.page_id = "+escape.cote(pageId)+" ORDER BY pb.sort_order ) AS pbt";
        else q += " WHERE b.id IN (" + blocIdQueryList + ") ORDER BY FIELD(b.id, "+ blocIdQueryList +")  ) AS pbt";

        if (pageType.equals(Scheduler.PAGE_TYPE_STRUCTURED)) {
            q += " UNION "
                + " SELECT DISTINCT bt.id, bt.template_code, bt.js_code, bt.css_code, bt.jsonld_code "
                + " FROM structured_contents_details scd "
                + " JOIN structured_contents sc ON sc.id = scd.content_id "
                + " JOIN bloc_templates bt ON bt.id = sc.template_id "
                + " WHERE sc.type = 'page' AND scd.page_id = " + escape.cote(pageId);
        }
		
        rs = Etn.execute(q);

        ArrayList<String> templateIdsList = new ArrayList<>();
        while (rs.next()) {
            templateIdsList.add(escape.cote(rs.value("id")));
            stringTemplateLoader.putTemplate("template_" + rs.value("id"), rs.value("template_code"));
            stringTemplateLoader.putTemplate("template_js_" + rs.value("id"), rs.value("js_code"));
            stringTemplateLoader.putTemplate("template_css_" + rs.value("id"), rs.value("css_code"));
            stringTemplateLoader.putTemplate("template_jsonld_" + rs.value("id"), rs.value("jsonld_code"));
        }

        String templateIdQueryList = String.join(",", templateIdsList);
        if (templateIdQueryList.length() == 0) templateIdQueryList = escape.cote("-1");

        Set rsPageIncludedBlocs = Etn.execute("select b.template_id from structure_mappings sm join blocs b on sm.bloc_id=b.id where sm.lang_page_id="+escape.cote(pageId));
        while(rsPageIncludedBlocs.next()){
            if(!templateIdQueryList.isEmpty()) templateIdQueryList+=",";
            templateIdQueryList+= rsPageIncludedBlocs.value("template_id");
        }

        Configuration cfg=null;
        try{
            cfg = PagesUtil.getFreemarkerConfig(stringTemplateLoader, TEMPLATES_DIR);
            cfg.setSharedVariable("translateFunc", new TranslateLang(langId,Etn));
        }catch(Exception e) {
            logE("printing error -----------------------------------------");
        }

        if (pageType.equals(Scheduler.PAGE_TYPE_STRUCTURED)) {
            //generating structured page (one bloc page)
            processStructuredPageHTML(pageId, pageBody, pageHM, siteParamHM, tagsHM,pageBodyJs, pageBodyCss, pageBodyJsonlds, pageCustomMetaTags, cfg, templateDataGen, isGenerateForPublish);
        }


        //generating bloc html divs for all blocs
        //storing in HM and adding in pageBody later as per order
        //to save regenerating in case there are duplicates
        HashMap<String, String> blocResultHM = new HashMap<>();

        q = "SELECT b.id AS bloc_id,b.name AS bloc_name, b.template_id , bd.template_data "
                + " , b.rss_feed_ids, b.rss_feed_sort "
                + " , b.margin_top , b.margin_bottom "
                + " , b.refresh_interval , b.visible_to , b.start_date , b.end_date "
                + " , bt.custom_id AS template_custom_id, bt.js_code, bt.css_code, bt.jsonld_code "
                + " , bt.type AS template_type "
                + " FROM blocs b "
                + " JOIN blocs_details bd ON bd.bloc_id = b.id AND bd.langue_id = " + escape.cote(pageLangId)
                + " JOIN bloc_templates bt ON b.template_id = bt.id ";

        if (!isBlocList) q += " WHERE b.id IN (SELECT DISTINCT bloc_id FROM pages_blocs WHERE page_id = " + escape.cote(pageId)+")";
        else q += " WHERE b.id IN ( " + blocIdQueryList + " )";

        String blocsQuery = q;
        processPageBlocsHTML(blocsQuery, blocResultHM, pageHM, siteParamHM, tagsHM,pageBodyJs, pageBodyCss, pageBodyJsonlds, cfg, templateDataGen, langId, PORTAL_DB, siteId, pageId, isGenerateForPublish);
        
        String FORMS_DB = getParm("FORMS_DB");
        String formsQuery = "SELECT DISTINCT f.form_id AS form_id , f.process_name AS form_name FROM " + FORMS_DB + ".process_forms f  ";
        
        if (!isBlocList) formsQuery += " JOIN pages_forms pf  ON pf.form_id = f.form_id WHERE pf.page_id = " + escape.cote(pageId);
        else formsQuery += " WHERE CONCAT('form_',f.form_id) IN ( " + blocIdQueryList + " )";

        ArrayList<String> formsJsFiles = new ArrayList<>();
        ArrayList<String> formsCssFiles = new ArrayList<>();
        String pageLangCode = pageRs.value("langue_code");

        processPageFormsHTML(formsQuery, pageLangCode, blocResultHM, pageBodyJs, pageBodyCss, formsJsFiles, formsCssFiles);
        //Add bloc & forms html to page body in order
        if (!isBlocList) {
            q = " SELECT * FROM ("
                    + "	  SELECT DISTINCT pb.bloc_id AS id, bt.type AS template_type, pb.sort_order FROM pages_blocs pb"
                    + "	  JOIN blocs b ON b.id = pb.bloc_id JOIN bloc_templates bt ON bt.id = b.template_id "
                    + "	  WHERE page_id = " + escape.cote(pageId)
                    + "   UNION "
                    + "   SELECT form_id AS id, 'form' AS template_type, sort_order FROM pages_forms WHERE page_id = " + escape.cote(pageId)
                    + " ) t1 ORDER BY sort_order,template_type ASC";

            rs = Etn.execute(q);
            while (rs.next()) {
                String blocHMKey = rs.value("template_type") + "_" + rs.value("id");
                pageBody.append(blocResultHM.get(blocHMKey));
            }
        } else {
            for (String curBlocId : blocIdsList) {
                String blocHMKey = curBlocId;
                if (!curBlocId.startsWith("form_")) {
                    q = " SELECT bt.type AS template_type FROM blocs b JOIN bloc_templates bt ON bt.id = b.template_id WHERE b.id = " + escape.cote(curBlocId);
                    rs = Etn.execute(q);
                    if (rs.next()) blocHMKey = rs.value("template_type") + "_" + curBlocId;
                }

                if (blocResultHM.get(blocHMKey) != null) pageBody.append(blocResultHM.get(blocHMKey));
            }
        }
				
        //Add CSS and JS files tags
        setResourceFiles(pageId, templateIdQueryList, formsCssFiles, formsJsFiles, isGenerateForPublish);
		
        q = " SELECT meta_name, meta_content FROM pages_meta_tags WHERE page_id = " + escape.cote(pageId);

        Set metaTagsRs = Etn.execute(q);
        while (metaTagsRs.next()) {
            String metaName = metaTagsRs.value("meta_name");
            String metaContent = metaTagsRs.value("meta_content");
            pageCustomMetaTags.append(PagesUtil.getMetaTag(metaName, metaContent));
        }

        String etnMetaTags = PagesUtil.getEtnMetaTags(Etn, pageRs, CATALOG_DB, CONTEXT_PATH);
        pageCustomMetaTags.append(etnMetaTags);
		
		//before applying page template related css/js/html, save published content to disk to be later used by clear cache
		savePublishedContentToDisk(pageId, siteId, isGenerateForPublish, pageBody, pageBodyCss, pageBodyJs, pageBodyJsonlds, pageHM, metaHM, tagsHM, pageCustomMetaTags);
		
		return applyTemplate(pageId, langId, langCode, siteId, siteSuid, pageHM, metaHM, siteParamHM, tagsHM,
					pageBody, pageCustomMetaTags, pageBodyCss, pageBodyJs, pageBodyJsonlds,isGenerateForPublish);
    }	
	
	private void savePublishedContentToDisk(String pageId, String siteId, boolean isGenerateForPublish, StringBuilder pageBody, StringBuilder pageBodyCss, StringBuilder pageBodyJs, 	
							ArrayList<JSONObject> pageBodyJsonlds, Map<String, Object> pageHM, Map<String, Object> metaHM, 
							LinkedHashMap<String, String> tagsHM, StringBuilder pageCustomMetaTags) throws Exception {
		String BASE_DIR = getParm("BASE_DIR");
		String PAGES_FOLDER = getParm("PAGES_SAVE_FOLDER");
		if(isGenerateForPublish) PAGES_FOLDER = getParm("PAGES_PUBLISH_FOLDER");
		String contentDir = BASE_DIR + PAGES_FOLDER + "published_content/"+siteId+"/"+pageId+"/";
					
		File cFile = new File(contentDir + "page_content");
		writeContentsToFile(cFile, pageBody.toString());
		
		cFile = new File(contentDir + "body_css");
		writeContentsToFile(cFile, pageBodyCss.toString());
		
		cFile = new File(contentDir + "body_js");
		writeContentsToFile(cFile, pageBodyJs.toString());
		
		JSONArray jJsonLds = new JSONArray();
        for (JSONObject jsonld : pageBodyJsonlds) {
			jJsonLds.put(jsonld);
        }
		
		cFile = new File(contentDir + "jsonlds");
		writeContentsToFile(cFile, jJsonLds.toString());			

		cFile = new File(contentDir + "pageHM");
		writeObjectToFile(cFile, pageHM);

		cFile = new File(contentDir + "metaHM");
		writeObjectToFile(cFile, metaHM);

		cFile = new File(contentDir + "tagsHM");
		writeObjectToFile(cFile, tagsHM);

		cFile = new File(contentDir + "custom_meta_tags");
		writeContentsToFile(cFile, pageCustomMetaTags.toString());
	}

	private String applyTemplate(String pageId, String langId, String langCode, String siteId, String siteSuid, Map<String, Object> pageHM, Map<String, Object> metaHM, 
					Map<String, Object> siteParamHM, LinkedHashMap<String, String> tagsHM,StringBuilder pageBody, StringBuilder pageCustomMetaTags, 
					StringBuilder pageBodyCss, StringBuilder pageBodyJs, ArrayList<JSONObject> pageBodyJsonlds,boolean isGenerateForPublish) throws Exception{
		
		Set rs = Etn.execute("select * from pages where id = " + escape.cote(pageId));
		rs.next();
		String pageUuid = rs.value("uuid");
		
		int pageTemplateId = (int)pageHM.get("page_template_id");
		log("In applyTemplate :: pageId : "+pageId + " lang : "+langCode + " page template : "+pageTemplateId + " langId : "+langId);
		String BASE_DIR = getParm("BASE_DIR");
		String TEMPLATES_DIR = BASE_DIR + "/WEB-INF/templates/";
		String PORTAL_DB = getParm("PORTAL_DB");

		String CONTEXT_PATH = getParm("EXTERNAL_LINK");
		String UPLOADS_FOLDER = getParm("UPLOADS_FOLDER") + siteId + "/";
		String UPLOADS_URL_PREFIX = CONTEXT_PATH + UPLOADS_FOLDER;
        String CSS_URL_PREPEND = UPLOADS_URL_PREFIX + "css/";
        String JS_URL_PREPEND = UPLOADS_URL_PREFIX + "js/";

        StringBuilder pageHeadTags = new StringBuilder();
        StringBuilder pageBodyTags = new StringBuilder();
		processPageFiles(pageId, pageTemplateId, langId, pageHeadTags, pageBodyTags, CSS_URL_PREPEND, JS_URL_PREPEND, isGenerateForPublish);
						
		//we have to add this by default to all pages
        pageBodyTags.append(PagesUtil.getScriptTag(CONTEXT_PATH + "js/pages_default.js"));
		
        StringTemplateLoader stringTemplateLoader = new StringTemplateLoader();

        String q = " SELECT pt_bt.* FROM ( "
                    + " SELECT DISTINCT bt.id, bt.template_code, bt.js_code, bt.css_code, bt.jsonld_code FROM bloc_templates bt "
                    + " JOIN blocs b ON b.template_id = bt.id "
                    + " JOIN page_templates_items_blocs ptb ON ptb.bloc_id = b.id AND ptb.type = 'bloc' "
                    + " JOIN page_templates_items pti ON pti.id = ptb.item_id "
                    + " WHERE pti.page_template_id = " + escape.cote("" + pageTemplateId)
                    + " AND ptb.langue_id = "+escape.cote(langId)+" ORDER BY pti.sort_order, ptb.sort_order"
                + " ) AS pt_bt";
        rs = Etn.execute(q);

        while (rs.next()) {
            stringTemplateLoader.putTemplate("template_" + rs.value("id"), rs.value("template_code"));
            stringTemplateLoader.putTemplate("template_js_" + rs.value("id"), rs.value("js_code"));
            stringTemplateLoader.putTemplate("template_css_" + rs.value("id"), rs.value("css_code"));
            stringTemplateLoader.putTemplate("template_jsonld_" + rs.value("id"), rs.value("jsonld_code"));
        }

        String defaultPageTemplate = "<!DOCTYPE html><html><head></head><body>${content}</body></html>";
        stringTemplateLoader.putTemplate("pageTemplate_0", defaultPageTemplate);

        if (pageTemplateId > 0) {
            q = "SELECT template_code FROM page_templates WHERE id = " + escape.cote("" + pageTemplateId);
            rs = Etn.execute(q);
            if (rs.next()) stringTemplateLoader.putTemplate("pageTemplate_" + pageTemplateId, rs.value("template_code"));
            else {
                throw new Exception("Error invalid page template id.");
            }
        }

        Configuration cfg=null;
        try{
            cfg = PagesUtil.getFreemarkerConfig(stringTemplateLoader, TEMPLATES_DIR);
            cfg.setSharedVariable("translateFunc", new TranslateLang(langId,Etn));
        } catch(Exception e) {
            logE("printing error -----------------------------------------");
			throw e;
        }

        Template template = cfg.getTemplate("pageTemplate_" + pageTemplateId);
        if (fromPageEditor) template = cfg.getTemplate("pageTemplate_0");
		
		TemplateDataGenerator templateDataGen = getTemplateDataGenerator(siteId, isGenerateForPublish);
		
		Map<String, Object> templateHM = new HashMap<>();
		HashMap<String, String> blocResultHM = new HashMap<>();
		q = " SELECT b.id AS bloc_id, b.name AS bloc_name, b.template_id , bd.template_data,b.rss_feed_ids, b.rss_feed_sort, b.margin_top , b.margin_bottom "
                + " , b.refresh_interval , b.visible_to , b.start_date , b.end_date, bt.custom_id AS template_custom_id, bt.js_code, bt.css_code, bt.jsonld_code "
                + " , bt.type AS template_type FROM blocs b "
                + " JOIN blocs_details bd ON bd.bloc_id = b.id AND bd.langue_id = " + escape.cote(langId)
                + " JOIN bloc_templates bt ON b.template_id = bt.id "
                + " JOIN page_templates_items_blocs ptb ON ptb.bloc_id = b.id AND ptb.type = 'bloc' "
                + " JOIN page_templates_items pti ON pti.id = ptb.item_id "
                + " WHERE pti.page_template_id = "+escape.cote(""+ pageTemplateId)+" AND ptb.langue_id = " + escape.cote(langId);

        processPageBlocsHTML(q, blocResultHM, pageHM, siteParamHM, tagsHM,pageBodyJs, pageBodyCss, pageBodyJsonlds, cfg, templateDataGen, langId, PORTAL_DB, siteId, pageId, isGenerateForPublish);
		
        q = " SELECT pti.id, pti.name, pti.custom_id, ptd.* FROM page_templates_items pti LEFT JOIN page_templates_items_details ptd ON ptd.item_id = pti.id "
                +" AND ptd.langue_id = " + escape.cote(langId)+" WHERE page_template_id = "+escape.cote(""+pageTemplateId)+" AND pti.custom_id != 'content' ";

        rs = Etn.execute(q);
        while (rs.next()) {
            String regionCustomId = rs.value("custom_id");

            HashMap<String, Object> regionHM = new HashMap<>();
            String cssClasses = PagesUtil.parseNull(rs.value("css_classes"));
            String cssStyle = PagesUtil.parseNull(rs.value("css_style"));
            ArrayList<String> regionBlocsList = new ArrayList<>();

            q = " SELECT ptb.* , COALESCE(bt1.type,'') AS template_type FROM page_templates_items_blocs ptb LEFT JOIN blocs b ON b.id = ptb.bloc_id AND ptb.type = 'bloc' "
                    +" LEFT JOIN bloc_templates bt1 ON bt1.id = b.template_id WHERE ptb.item_id = " + escape.cote(rs.value("id"))
                    +" AND ptb.langue_id = "+escape.cote(langId)+" ORDER BY ptb.sort_order ";
            Set blocRs = Etn.execute(q);
            while (blocRs.next()) {
                String blocHMKey = blocRs.value("template_type") + "_" + blocRs.value("bloc_id");
                if (blocResultHM.get(blocHMKey) != null) regionBlocsList.add(blocResultHM.get(blocHMKey));
            }
            regionHM.put("css_classes", cssClasses);
            regionHM.put("css_style", cssStyle);
            regionHM.put("blocs", regionBlocsList);

            templateHM.put(regionCustomId, regionHM);
        }

        templateHM.put("page", pageHM);
        templateHM.put("site_param", siteParamHM);
        templateHM.put("content", pageBody);

        StringWriter stringWriter = new StringWriter();
        template.process(templateHM, stringWriter);
        Document document = Jsoup.parse(stringWriter.toString(), "", Parser.htmlParser());
        document.outputSettings().prettyPrint(false);
        
        Element htmlTag = document.getElementsByTag("html").first();
        htmlTag.attr("lang", PagesUtil.parseNull(pageHM.get("lang")));
        String pageLangDir = PagesUtil.parseNull(pageHM.get("lang_dir"));

        if (pageLangDir.length() > 0) htmlTag.attr("dir", pageLangDir);

        Element head = document.head();
        Element body = document.body();
        //check title
        if (head.getElementsByTag("title").isEmpty()) head.prependElement("title").appendText(PagesUtil.parseNull(pageHM.get("title")));
        
        addMetaTags(head, pageHM, metaHM, pageCustomMetaTags.toString());

        String canonical_url = getString(pageHM, "canonical_url");
        if (canonical_url.length() > 0) head.appendElement("link").attr("rel", "canonical").attr("href", canonical_url);

        head.appendChild(new Comment(" page.headTags "));
        head.append(pageHeadTags.toString());

        String portalConfigQuery = "select * from ";
        String pageEnvironment = "T";
        if(isGenerateForPublish == false) portalConfigQuery += getParm("PREPROD_PORTAL_DB");
        else {
            pageEnvironment = "P";//prod site
            portalConfigQuery += getParm("PROD_PORTAL_DB");
        }

        portalConfigQuery += ".config where code = 'EXTERNAL_LINK'";
        Set portalConfigRs = Etn.execute(portalConfigQuery);
        portalConfigRs.next();
        String apiExternalLink = portalConfigRs.value("val");
        if(apiExternalLink.endsWith("/") == false) apiExternalLink += "/";

        String asmPageInfoObj = "<script type=\"text/javascript\">\n";
        asmPageInfoObj += "\tvar asmPageInfo = asmPageInfo || {};\n";
        asmPageInfoObj += "\tasmPageInfo.apiBaseUrl = \""+apiExternalLink+"\";\n";
        asmPageInfoObj += "\tasmPageInfo.clientApisUrl = \""+apiExternalLink+"clientapis/\";\n";
		asmPageInfoObj += "\tasmPageInfo.expSysUrl = \""+getParm("EXP_SYS_EXTERNAL_URL")+"\";\n";
        asmPageInfoObj += "\tasmPageInfo.environment = \""+pageEnvironment+"\";\n";
        asmPageInfoObj += "\tasmPageInfo.suid = \""+siteSuid+"\";\n";
        asmPageInfoObj += "\tasmPageInfo.lang = \""+langCode+"\";\n";
        asmPageInfoObj += "\tasmPageInfo.pageId = \""+pageUuid+"\";\n";
        asmPageInfoObj += "</script>\n";

        head.append(asmPageInfoObj);

        body.prependChild(new Comment(" page.body "));

        body.appendChild(new Comment(" page.bodyTags "));
        body.append(pageBodyTags.toString());

        if (pageBodyCss.toString().trim().length() > 0) {
            body.appendChild(new Comment(" page.bodyCss "));
            body.appendChild(new Element("style").attr("type", "text/css").appendChild(new DataNode("\n" + pageBodyCss.toString() + "\n")));
        }

        if (pageBodyJs.toString().trim().length() > 0) {
            body.appendChild(new Comment(" page.bodyJs "));
            body.appendChild(new Element("script").attr("type", "text/javascript").appendChild(new DataNode("\n" + pageBodyJs.toString() + "\n")));
        }
		
        body.appendChild(new Comment(" page.bodyJsonld "));
        for (JSONObject jsonld : pageBodyJsonlds) {
            body.appendChild(new Element("script").attr("type", "application/ld+json").appendChild(new DataNode("\n" + jsonld.toString() + "\n")));
        }

        return document.toString();
	}
	
	private void writeContentsToFile(File cFile, String contents) throws Exception
	{
		File folder = cFile.getParentFile();
		if (!folder.exists()) {
			folder.mkdirs();
		}

		if (!cFile.exists()) {
			cFile.createNewFile();
		}

		if (debug) {
			log("write content to file : " + cFile.getAbsolutePath());
		}

		FilesUtil.writeFile(cFile, contents);		
	}
	
	private void writeObjectToFile(File cFile, Object obj) throws Exception
	{
		File folder = cFile.getParentFile();
		if (!folder.exists()) {
			folder.mkdirs();
		}

		if (!cFile.exists()) {
			cFile.createNewFile();
		}

		if (debug) {
			log("write content to file : " + cFile.getAbsolutePath());
		}

		java.io.ObjectOutputStream oos = null;
		try
		{
			oos = new java.io.ObjectOutputStream(new java.io.FileOutputStream(cFile));
			oos.writeObject(obj);
		}
		finally
		{
			if(oos != null) oos.close();
		}
		
	}
	
    private void addMetaTags(Element head, Map<String, Object> pageHM, Map<String, Object> metaHM, String pageCustomMetaTags) {

        ArrayList<Node> metaTagsList = new ArrayList<>();

        metaTagsList.add(new Element("meta").attr("charset", "UTF-8"));
        metaTagsList.add(getMetaTag("viewport", getString(pageHM, "viewport", "width=device-width, initial-scale=1.0")));
        metaTagsList.add(getMetaTag("author", getString(pageHM, "author")));

        metaTagsList.add(getMetaTag("language", getString(metaHM, "locale", "en_EN")));
        metaTagsList.add(getMetaTag("keywords", getString(metaHM, "keywords")));
        metaTagsList.add(getMetaTag("description", getString(metaHM, "description")));

        metaTagsList.add(getMetaTag("og:url", ""));
        metaTagsList.add(getMetaTag("og:site_name", getString(pageHM, "site_name")));
        metaTagsList.add(getMetaTag("fb:app_id", getString(pageHM, "fb_app_id")));

        metaTagsList.add(getMetaTag("og:locale", getString(metaHM, "locale", "en_EN")));
        metaTagsList.add(getMetaTag("og:title", getString(metaHM, "title")));
        metaTagsList.add(getMetaTag("og:description", getString(metaHM, "description")));
        metaTagsList.add(getMetaTag("og:type", getString(metaHM, "type", "website")));

        ArrayList<String> localAlt = (ArrayList<String>) metaHM.get("locale_alt");
        for (String curLocaleAlt : localAlt) {
            metaTagsList.add(getMetaTag("og:locale:alternate", curLocaleAlt));
        }

        if (getString(metaHM, "image").length() > 0) {
            metaTagsList.add(getMetaTag("og:image", getString(metaHM, "image")));
            metaTagsList.add(getMetaTag("og:image:width", getString(metaHM, "image_width")));
            metaTagsList.add(getMetaTag("og:image:height", getString(metaHM, "image_height")));
            metaTagsList.add(getMetaTag("og:image:type", getString(metaHM, "image_type")));
            metaTagsList.add(getMetaTag("og:image:alt", getString(metaHM, "title")));
        }

        metaTagsList.add(getMetaTag("twitter:site", getString(metaHM, "twitter_site")));
        metaTagsList.add(getMetaTag("twitter:title", getString(metaHM, "title")));
        metaTagsList.add(getMetaTag("twitter:card", getString(metaHM, "twitter_card")));

        int insertIndex = 0;
        if (head.children().size() > 0 && head.child(0).tagName().equalsIgnoreCase("title")) {
            insertIndex = 1;
        }

        head.insertChildren(insertIndex, metaTagsList);

        Node lastMetaTag = metaTagsList.get(metaTagsList.size() - 1);
        lastMetaTag.after(pageCustomMetaTags);
        lastMetaTag.after(new Comment(" page.customMetaTags "));
    }

    private Element getMetaTag(String name, String content) {
        String nameAttr = "name";
        if (name.startsWith("og:") || name.startsWith("fb:")) {
            nameAttr = "property";
        }
        return new Element("meta").attr(nameAttr, name).attr("content", content);
    }

    private String getString(Map<String, Object> map, String key) {
        return PagesUtil.parseNull(map.get(key));
    }

    private String getString(Map<String, Object> map, String key, String defaultValue) {
        String retVal = getString(map, key);
        if (retVal == null || retVal.length() == 0) retVal = defaultValue;
        return retVal;
    }

    private void processPageBlocsHTML(String blocsQuery, HashMap<String, String> blocResultHM,
                                      Map<String, Object> pageHM, Map<String, Object> siteParamHM, HashMap<String, String> tagsHM,
                                      StringBuilder pageBodyJs, StringBuilder pageBodyCss, List<JSONObject> pageBodyJsonlds,
                                      Configuration cfg, TemplateDataGenerator templateDataGen, String langId, String PORTAL_DB, String siteId, String pageId, boolean isGenerateForPublish) throws Exception {

        Set rs = Etn.execute(blocsQuery);
        while (rs.next()) {
            String blocId = rs.value("bloc_id");
            String templateId = rs.value("template_id");
            String templateType = rs.value("template_type");
            String templateData = rs.value("template_data");
            String templateCustomId = rs.value("template_custom_id");

            String refreshInterval = rs.value("refresh_interval");
            String visibleTo = rs.value("visible_to");
            String startDate = rs.value("start_date");
            String endDate = rs.value("end_date");

            String marginTop = rs.value("margin_top");
            String marginBottom = rs.value("margin_bottom");

            templateData = PagesUtil.decodeJSONStringDB(templateData);

            String templateJsCode = rs.value("js_code");
            String templateCssCode = rs.value("css_code");
            String templateJsonldCode = rs.value("jsonld_code");

            Template curBlocTemplate = cfg.getTemplate("template_" + templateId);

            JSONObject templateDataJson = new JSONObject(templateData);
            HashMap<String, Object> curBlocDataHM = templateDataGen.getBlocTemplateDataMap(templateId, templateDataJson, tagsHM, langId,isGenerateForPublish);
			saveProductViewData(siteId, pageId, blocId, langId, templateDataGen.jProductViewArr);
			
            HashMap<String, Object> extraDataHM = PagesUtil.getBlocExtraDataMap(Etn, blocId, templateType, PORTAL_DB);

            curBlocDataHM.putAll(extraDataHM);
            curBlocDataHM.put("page", pageHM);
            curBlocDataHM.put("site_param", siteParamHM);

            JSONObject dataJson = new JSONObject();
            try {
                dataJson = new JSONObject(curBlocDataHM);
            }
            catch (Exception ex) {
                ex.printStackTrace();
            }
            curBlocDataHM.put("data_json", dataJson.toString());


            // collecting the global vaiables
            String CATALOG_DB = getParm("CATALOG_DB");

            curBlocDataHM.putAll(PagesUtil.loadVariables(Etn, siteId, langId, isGenerateForPublish));

            StringWriter blocHtml = new StringWriter();
            curBlocTemplate.process(curBlocDataHM, blocHtml);

            if (templateJsCode.trim().length() > 0) {
                StringWriter jsCodeWriter = new StringWriter();
                Template curBlocJsTemplate = cfg.getTemplate("template_js_" + templateId);
                curBlocJsTemplate.process(curBlocDataHM, jsCodeWriter);
                pageBodyJs.append(jsCodeWriter.toString()).append("\n");
            }
            if (templateCssCode.trim().length() > 0) {
                StringWriter cssCodeWriter = new StringWriter();
                Template curBlocCssTemplate = cfg.getTemplate("template_css_" + templateId);
                curBlocCssTemplate.process(curBlocDataHM, cssCodeWriter);
                pageBodyCss.append(cssCodeWriter.toString()).append("\n");
            }
            if (templateJsonldCode.trim().length() > 0) {

                StringWriter jsonldCodeWriter = new StringWriter();
                Template curBlocJsonldTemplate = cfg.getTemplate("template_jsonld_" + templateId);
                curBlocJsonldTemplate.process(curBlocDataHM, jsonldCodeWriter);
                JSONObject jsonObject;
                try {
                    jsonObject = new JSONObject(jsonldCodeWriter.toString());
                    if (jsonObject.keySet().isEmpty()) {
                        throw new JSONException("");
                    }
                }
                catch (JSONException e) {
                    jsonObject = new JSONObject();
                    jsonObject.put("error", "Invalid Json-ld from Block " + rs.value("bloc_name"));
                }
                pageBodyJsonlds.add(jsonObject);
            }


            //generate valid xhtml
            Document validHtmlDoc = Jsoup.parse(blocHtml.toString(), "", Parser.htmlParser());
            validHtmlDoc.outputSettings().prettyPrint(false);

            List<Map.Entry<String, String>> indexedList = templateDataGen.getIndexedList();
            if (indexedList.size() > 0) {
                Element indexedDiv = new Element("div");
                indexedDiv.attr("style", "display:none;");
                for (Map.Entry<String, String> pair : indexedList) {
                    Element childDiv = new Element("div");
                    childDiv.attr("data-name", pair.getKey());
                    childDiv.attr("data-value", pair.getValue());
                    childDiv.addClass("algExtraParamsDiv");
                    indexedDiv.appendChild(childDiv);
                }
                validHtmlDoc.body().appendChild(indexedDiv);
            }
            //html parser adds <html>,<head>, <body> tags to make it valid html
            //remove all those
            String validHtml = validHtmlDoc.body().html();

            ArrayList<String> attrList = new ArrayList<>();
            ArrayList<String> valList = new ArrayList<>();

            String classVal = "bloc_div";
            classVal += " visible_to_" + visibleTo;
            classVal += " template_custom_id_" + templateCustomId;

            attrList.add("class");
            valList.add(classVal);

            String styleVal = "";
            if (marginTop.length() > 0) {
                styleVal += "margin-top: " + marginTop + "px;";
            }
            if (marginBottom.length() > 0) {
                styleVal += " margin-bottom: " + marginBottom + "px;";
            }
            
            attrList.add("style");
            valList.add(styleVal);


            attrList.add("data-bloc-id");
            valList.add(blocId);

            attrList.add("data-bloc-name");
            valList.add(rs.value("bloc_name"));

            attrList.add("template-custom-id");
            valList.add(templateCustomId);

            attrList.add("visible-to");
            valList.add(visibleTo);

            attrList.add("refresh-interval");
            valList.add(refreshInterval);

            attrList.add("start-date");
            valList.add(startDate);

            attrList.add("end-date");
            valList.add(endDate);

            String blocDiv = PagesUtil.generateHtmlTag("div", validHtml, attrList, valList);

            String blocHMKey = templateType + "_" + blocId;

            blocResultHM.put(blocHMKey, blocDiv);
        }
    }

    private void replaceMetaVariables(Map<String, Object> pageHM, HashMap<String, Object> curBlocDataHM) {
        HashMap<String, Object> socialMap = (HashMap<String, Object>) pageHM.get("social");

        // currentky we are doing it for only tow fields (title, description)
        HashMap<String, String> fieldsHM = new HashMap<>();
        fieldsHM.put("title", (String) socialMap.get("title"));
        fieldsHM.put("description", (String) socialMap.get("description"));

        Map<String, Object> metaVariablesHM = JsonFlattener.flattenAsMap(new JSONObject(curBlocDataHM).toString());
        Pattern pattern = Pattern.compile("<[^>]*>");
        for (Map.Entry<String, String> entry : fieldsHM.entrySet()) {
            String variableString = entry.getValue();
            Matcher matcher = pattern.matcher(variableString);

            // Find all matches
            while (matcher.find()) {
                String match = matcher.group();
                String matchKey = match.replace("<", "");
                matchKey = matchKey.replace(">", "");
                if (metaVariablesHM.containsKey(matchKey)) {
                    String replaceVal = (String) metaVariablesHM.get(matchKey);
                    variableString = variableString.replace(match, replaceVal);
                } else variableString = variableString.replace(match, "");
            }
            socialMap.put(entry.getKey(), variableString);
        }
        pageHM.put("title", (String) socialMap.get("title"));
    }

    private void processStructuredPageHTML(String pageId, StringBuilder pageBody,Map<String, Object> pageHM, Map<String, Object> siteParamHM, HashMap<String, String> tagsHM,
                    StringBuilder pageBodyJs, StringBuilder pageBodyCss, List<JSONObject> pageBodyJsonlds,StringBuilder pageCustomMetaTags,Configuration cfg, 
                    TemplateDataGenerator templateDataGen, boolean isGenerateForPublish) throws Exception {

        String q = "SELECT scd.id as content_detail_id, scd.langue_id, scd.content_data as template_data"
                + " , sc.template_id as template_id,sc.site_id as site_id, sc.id as content_id,sc.uuid as alg_obj_id, sc.name as content_name "
                + " , bt.custom_id AS template_custom_id, bt.js_code, bt.css_code, bt.jsonld_code "
                + " , bt.type AS template_type "
                + " FROM structured_contents_details scd "
                + " JOIN structured_contents sc ON sc.id = scd.content_id "
                + " JOIN bloc_templates bt ON bt.id = sc.template_id "
                + " WHERE sc.type = 'page' AND scd.page_id = " + escape.cote(pageId);

        Set rs = Etn.execute(q);
        if (rs.next()) {
            String langId = rs.value("langue_id");
            String templateId = rs.value("template_id");
            String templateData = rs.value("template_data");
            String templateCustomId = rs.value("template_custom_id");
            String contentId = rs.value("content_id");
            String contentName = rs.value("content_name");
            String contentDetailId = rs.value("content_detail_id");
            String templateType = rs.value("template_type");
            String siteId = rs.value("site_id");
            String algObjId = rs.value("alg_obj_id");
            String CATALOG_DB = getParm("CATALOG_DB");
            String PORTAL_DB = getParm("PORTAL_DB");
            
            templateData = PagesUtil.decodeJSONStringDB(templateData);

            String templateJsCode = rs.value("js_code");
            String templateCssCode = rs.value("css_code");
            String templateJsonldCode = rs.value("jsonld_code");

            Template curBlocTemplate = cfg.getTemplate("template_" + templateId);

            JSONObject templateDataJson = new JSONObject(templateData);

            HashMap<String, Object> curBlocDataHM = templateDataGen.getBlocTemplateDataMap(templateId, templateDataJson, tagsHM, langId,isGenerateForPublish);

            templateDataGen.setMetaVariableDataOnly(true);
            HashMap<String, Object> metaVariablesHM = templateDataGen.getBlocTemplateDataMap(templateId, templateDataJson, tagsHM, langId,isGenerateForPublish);
            replaceMetaVariables(pageHM, metaVariablesHM);
            templateDataGen.setMetaVariableDataOnly(false);
            curBlocDataHM.put("page", pageHM);

            curBlocDataHM.put("site_param", siteParamHM);

            JSONObject dataJson = new JSONObject();
            try {
                dataJson = new JSONObject(curBlocDataHM);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            curBlocDataHM.put("data_json", dataJson.toString());

            curBlocDataHM.putAll(PagesUtil.loadVariables(Etn, siteId, langId, isGenerateForPublish));
			
            StringWriter structuredHtml = new StringWriter();
            curBlocTemplate.process(curBlocDataHM, structuredHtml);

            if (templateJsCode.trim().length() > 0) {
                StringWriter jsCodeWriter = new StringWriter();
                Template curBlocJsTemplate = cfg.getTemplate("template_js_" + templateId);
                curBlocJsTemplate.process(curBlocDataHM, jsCodeWriter);
                pageBodyJs.append(jsCodeWriter.toString()).append("\n");
            }

            if (templateCssCode.trim().length() > 0) {
                StringWriter cssCodeWriter = new StringWriter();
                Template curBlocCssTemplate = cfg.getTemplate("template_css_" + templateId);
                curBlocCssTemplate.process(curBlocDataHM, cssCodeWriter);
                pageBodyCss.append(cssCodeWriter.toString()).append("\n");
            }

            if (templateJsonldCode.trim().length() > 0) {

                StringWriter jsonldCodeWriter = new StringWriter();
                Template curBlocJsonldTemplate = cfg.getTemplate("template_jsonld_" + templateId);
                curBlocJsonldTemplate.process(curBlocDataHM, jsonldCodeWriter);
                JSONObject jsonObject = null;
                try {
                    jsonObject = new JSONObject(jsonldCodeWriter.toString());
                    if (jsonObject.keySet().isEmpty()) {
                        throw new JSONException("");
                    }
                } catch (JSONException e) {
                    jsonObject = new JSONObject();
                    jsonObject.put("error", "Invalid Json-ld from Block " + rs.value("bloc_name"));
                }
                pageBodyJsonlds.add(jsonObject);
            }

            if (Constant.TEMPLATE_STORE.equals(templateType)) {
                try {
                    String storeStatus = templateDataJson.query("/global_information/0/store_section/0/status/0").toString();
                    if ("inactive".equalsIgnoreCase(storeStatus.trim())) pageCustomMetaTags.append(PagesUtil.getMetaTag("robots", "noindex, nofollow"));
                } catch (Exception ignore) {
                }
            }
            pageCustomMetaTags.append(PagesUtil.getMetaTag("alg:objectid", algObjId));
            
            //generate valid xhtml
            Document validHtmlDoc = Jsoup.parse(structuredHtml.toString(), "", Parser.htmlParser());
            validHtmlDoc.outputSettings().prettyPrint(false);
            //html parser adds <html>,<head>, <body> tags to make it valid html
            //remove all those
            String validHtml = validHtmlDoc.toString();
            validHtml = validHtml.replaceAll("<html>", "").replaceAll("</html>", "").replaceAll("<head>", "").replaceAll("</head>", "").replaceAll("<body>", "").replaceAll("</body>", "");

            ArrayList<String> attrList = new ArrayList<>();
            ArrayList<String> valList = new ArrayList<>();

            String classVal = "bloc_div structured_page_div";
            classVal += " template_custom_id_" + templateCustomId;

            attrList.add("class");
            valList.add(classVal);

            String styleVal = "";
            attrList.add("style");
            valList.add(styleVal);

            attrList.add("data-content-id");
            valList.add(contentId);

            attrList.add("data-content-detail-id");
            valList.add(contentDetailId);

            attrList.add("data-content-name");
            valList.add(contentName);

            attrList.add("template-custom-id");
            valList.add(templateCustomId);

            pageBody.append(PagesUtil.generateHtmlTag("div", validHtml, attrList, valList));
        }
    }

    private void processPageFormsHTML(String formsQuery, String pageLangCode,HashMap<String, String> blocResultHM,StringBuilder pageBodyJs, StringBuilder pageBodyCss,ArrayList<String> formsJsFiles, ArrayList<String> formsCssFiles) throws Exception {

        Set rs = Etn.execute(formsQuery);
        final String FORM_PREFIX = "form_";

        final String FORM_HTML_API_URL = getParm("FORM_HTML_API_URL");
        HashMap<String, String> httpHM = new HashMap<>();
        // these config proxy settings should not be used for internal URLs/APIs
        // httpHM.put("HTTP_PROXY_HOST", getParm("HTTP_PROXY_HOST"));
        // httpHM.put("HTTP_PROXY_PORT", getParm("HTTP_PROXY_PORT"));
        // httpHM.put("HTTP_PROXY_USER", getParm("HTTP_PROXY_USER"));
        // httpHM.put("HTTP_PROXY_PASSWD", getParm("HTTP_PROXY_PASSWD"));

        while (rs.next()) {
            String formId = rs.value("form_id");
            String formName = rs.value("form_name");

            String url = FORM_HTML_API_URL+ "?lang=" + pageLangCode+ "&form_id=" + formId;

            String response = PagesUtil.getURLResponseAsString(url, httpHM);
            JSONObject respJson = new JSONObject(response);

            String blocHtml = "";
            if ("1".equals(respJson.get("status").toString())) {
                JSONObject dataJson = respJson.getJSONObject("data");
                blocHtml = dataJson.getString("formHtml");

                String formBodyJs = dataJson.optString("bodyJs");
                if (formBodyJs.length() > 0) pageBodyJs.append("\n //form JS \n").append(formBodyJs);

                String formBodyCss = dataJson.optString("bodyCss");
                if (formBodyCss.length() > 0) pageBodyCss.append("\n /* form CSS */ \n").append(formBodyCss);

                JSONArray jsFilesList = dataJson.getJSONArray("jsFiles");
                JSONArray cssFilesList = dataJson.getJSONArray("cssFiles");

                for (int i = 0; i < jsFilesList.length(); i++) {
                    String jsFile = jsFilesList.getString(i);
                    if (!formsJsFiles.contains(jsFile)) formsJsFiles.add(jsFile);
                }

                for (int i = 0; i < cssFilesList.length(); i++) {
                    String cssFile = cssFilesList.getString(i);
                    if (!formsCssFiles.contains(cssFile)) formsCssFiles.add(cssFile);
                }

            } else {
                String formErrMsg = "Error in getting form id = " + formId + " :\n"+ respJson.getString("message");
                log(formErrMsg);
                blocHtml = "<span class='formErrorMsg' style='display:none'>Error in fetching form output<br>"+ respJson.getString("message") + "</span>";
            }
            //generate valid xhtml
            Document validHtmlDoc = Jsoup.parse(blocHtml, "", Parser.htmlParser());
            validHtmlDoc.outputSettings().prettyPrint(false);
            //html parser adds <html>,<head>, <body> tags to make it valid html
            //remove all those
            String validHtml = validHtmlDoc.toString();
            validHtml = validHtml.replaceAll("<html>", "").replaceAll("</html>", "").replaceAll("<head>", "").replaceAll("</head>", "").replaceAll("<body>", "").replaceAll("</body>", "");

            ArrayList<String> attrList = new ArrayList<>();
            ArrayList<String> valList = new ArrayList<>();

            String classVal = "bloc_div asm_form_div col-sm-12";

            // attrList.add("data-size");
            // valList.add("col-sm-12");

            attrList.add("class");
            valList.add(classVal);

            attrList.add("data-bloc-id");
            valList.add(FORM_PREFIX + formId);

            attrList.add("data-bloc-name");
            valList.add("Form " + formName);

            String blocDiv = PagesUtil.generateHtmlTag("div", validHtml, attrList, valList);
            blocResultHM.put(FORM_PREFIX + formId, blocDiv);
        }
    }
	
	private String getResourceFilesOrderBy(String templateIdQueryList) {
		//NOTE:If you change order by there then search for RESOURCES_ORDER_BY in file and change order by at all places
		//RESOURCES_ORDER_BY
		return " ORDER BY FIELD(bt.id, "+ templateIdQueryList + "),  btl.id, lf.sort_order ";		
	}

    private void processPageFiles(String pageId, int pageTemplateId, String pageLangId, StringBuilder pageHeadTags, StringBuilder pageBodyTags, String CSS_URL_PREPEND, String JS_URL_PREPEND, boolean isGenerateForPublish) {
		String tbl = "unpublished_pages_applied_files";
		if(isGenerateForPublish) tbl = "published_pages_applied_files";

		//First we will get the list of bloc templates used in the page template only
		String q = " SELECT pt_bt.* FROM ( "
                + " SELECT DISTINCT bt.id, bt.template_code, bt.js_code, bt.css_code, bt.jsonld_code FROM bloc_templates bt JOIN blocs b ON b.template_id = bt.id "
                + " JOIN page_templates_items_blocs ptb ON ptb.bloc_id = b.id AND ptb.type = 'bloc' JOIN page_templates_items pti ON pti.id = ptb.item_id "
                + " WHERE pti.page_template_id = " + escape.cote("" + pageTemplateId)+" AND ptb.langue_id = "+escape.cote(pageLangId)+" ORDER BY pti.sort_order, ptb.sort_order"
                + " ) AS pt_bt";

		Set rs = Etn.execute(q);
        ArrayList<String> templateIdsList = new ArrayList<>();
        while (rs.next()) {
            templateIdsList.add(escape.cote(rs.value("id")));
		}

        String templateIdQueryList = String.join(",", templateIdsList);
        if (templateIdQueryList.length() == 0) templateIdQueryList = escape.cote("-1");
		
		//get the list of files set by setResourceFiles which are required by all the bloc templates used directly in the page
		String pQry = "select file_id, file_name, file_type, library_name, page_position, sort_order, file_update_ts as updated_ts,bloc_template_id, bloc_templates_lib_id, library_id"
				+" from "+tbl+" where file_type not in ('forms_css', 'forms_js') and page_id = "+escape.cote(pageId);				

		//union the list of files required used directly in the page template or blocs used in page template
		String tQry = " SELECT f.id as file_id, f.file_name, f.type as file_type, l.name as library_name, lf.page_position, lf.sort_order "
                + " , UNIX_TIMESTAMP(f.updated_ts) AS updated_ts, bt.id as bloc_template_id, btl.id as bloc_templates_lib_id, l.id as library_id "
                + " FROM files f JOIN libraries_files lf ON lf.file_id = f.id JOIN libraries l ON l.id = lf.library_id "
                + " JOIN bloc_templates_libraries btl ON btl.library_id = l.id JOIN bloc_templates bt ON bt.id = btl.bloc_template_id "
                + " WHERE bt.id IN (" + templateIdQueryList + ") and lf.lang_id="+escape.cote(pageLangId)
                +" and (COALESCE(f.removal_date,'') = '' or  f.removal_date>now()) ";
	
		String allTemplateIdQueryList = "";
		//as we inserted the bloc_template_id as per the applied sorting, we will get the list in same order as it was in the function setResourceFiles
		rs = Etn.execute("select distinct bloc_template_id from "+tbl+" where page_id = "+escape.cote(pageId)+" order by applicable_sort_order");
		while(rs.next()) {
			if(allTemplateIdQueryList.length() > 0) allTemplateIdQueryList += ",";
			allTemplateIdQueryList += escape.cote(PagesUtil.parseNull(rs.value("bloc_template_id")));
		}

		//append the page template's template IDs to do this list to apply proper order by
		//before this list was generated by generatePageString function where page's template IDs were always before the page template bloc template IDs
		//so we append those at the end
		if(allTemplateIdQueryList.length() > 0) allTemplateIdQueryList += ",";
		allTemplateIdQueryList += templateIdQueryList;

		//resource files applied by blocs used directly in page has more priority than those from page template so we order by idx
		rs = Etn.execute("select t.* from ("+pQry+" union "+tQry+") t ORDER BY FIELD(bloc_template_id, "+ allTemplateIdQueryList + "), bloc_templates_lib_id,sort_order");
		
		HashSet<String> filesIdSet = new HashSet<>();
		HashSet<String> fileNamesSet = new HashSet<>();
		boolean isJquery = false;
		boolean isBootstrap = false;
        while (rs.next()) {
            String fileId = rs.value("file_id");

            if (filesIdSet.contains(fileId)) continue;
            else filesIdSet.add(fileId);

            String fileName = rs.value("file_name").trim();
            String fileType = rs.value("file_type");
            String pagePosition = rs.value("page_position");
            String updatedTs = rs.value("updated_ts");

            String lcFileName = fileName.toLowerCase();
            fileNamesSet.add(lcFileName);

            if (lcFileName.contains("jquery")) isJquery = true;
            else if (lcFileName.contains("bootstrap")) isBootstrap = true;

            String urlFileName = fileName + "?rand=" + updatedTs;
            if ("css".equals(fileType)) {
                if ("head".equals(pagePosition)) pageHeadTags.append(PagesUtil.getLinkTag(CSS_URL_PREPEND + urlFileName));
                else pageBodyTags.append(PagesUtil.getLinkTag(CSS_URL_PREPEND + urlFileName));
            } else if ("js".equals(fileType)) {
                if ("head".equals(pagePosition)) pageHeadTags.append(PagesUtil.getScriptTag(JS_URL_PREPEND + urlFileName));
                else pageBodyTags.append(PagesUtil.getScriptTag(JS_URL_PREPEND + urlFileName));
            }
		}
		
		List<String> formsCssFiles = new ArrayList<>();
		rs = Etn.execute("select * from "+tbl+" where page_id = "+escape.cote(pageId)+" and file_type = 'forms_css' order by applicable_sort_order");
		while(rs.next()) {
			formsCssFiles.add(rs.value("file_name"));
		}

		List<String> formsJsFiles = new ArrayList<>();
		rs = Etn.execute("select * from "+tbl+" where page_id = "+escape.cote(pageId)+" and file_type = 'forms_js' order by applicable_sort_order");
		while(rs.next()) {
			formsJsFiles.add(rs.value("file_name"));
		}
		
        for (String formFileUrl : formsCssFiles) {
            String curFileName = formFileUrl.substring(formFileUrl.lastIndexOf("/") + 1).toLowerCase();
            if (!(isJquery && curFileName.contains("jquery-")) && !(isBootstrap && curFileName.contains("bootstrap")) && !fileNamesSet.contains(curFileName)) {
                pageBodyTags.append(PagesUtil.getLinkTag(formFileUrl));
                fileNamesSet.add(curFileName);
            }
        }

        for (String formFileUrl : formsJsFiles) {
            String curFileName = formFileUrl.substring(formFileUrl.lastIndexOf("/") + 1).toLowerCase();
            if (!(isJquery && curFileName.contains("jquery-")) && !(isBootstrap && curFileName.contains("bootstrap")) && !fileNamesSet.contains(curFileName)) {
                pageBodyTags.append(PagesUtil.getScriptTag(formFileUrl));
                fileNamesSet.add(curFileName);
            }
        }
	}
	
    private void setResourceFiles(String pageId, String templateIdQueryList, ArrayList<String> formsCssFiles, ArrayList<String> formsJsFiles, boolean isGenerateForPublish) {
		String tbl = "unpublished_pages_applied_files";
		if(isGenerateForPublish) tbl = "published_pages_applied_files";

        String pageLangId = "1";
        Set rsPageLang = Etn.execute("select l.langue_id from language l join pages p on l.langue_code = p.langue_code where p.id="+escape.cote(pageId));
        if(rsPageLang.next()) pageLangId = PagesUtil.parseNull(rsPageLang.value("langue_id"));

		String q = " SELECT f.id as file_id, f.file_name, f.type as file_type, "
				+ " l.name as library_name, l.id as library_id, bt.id as bloc_template_id, btl.id as bloc_templates_library_id, lf.page_position, lf.sort_order "
                + " , UNIX_TIMESTAMP(f.updated_ts) AS updated_ts "
                + " FROM files f "
                + " JOIN libraries_files lf ON lf.file_id = f.id "
                + " JOIN libraries l ON l.id = lf.library_id "
                + " JOIN bloc_templates_libraries btl ON btl.library_id = l.id "
                + " JOIN bloc_templates bt ON bt.id = btl.bloc_template_id "
                + " WHERE bt.id IN (" + templateIdQueryList + ") and lf.lang_id="+escape.cote(pageLangId)
                +" and (COALESCE(f.removal_date,'') = '' or  f.removal_date>now()) ";
				
		q += getResourceFilesOrderBy(templateIdQueryList);

        Set filesRs = Etn.execute(q);			
		
		//clear old list and add all files actually applied in this table for clear cache process
		Etn.executeCmd("delete from "+tbl+" where page_id = "+escape.cote(pageId));
		
		//applicable_sort_order is very important here as using this sort order, we will recompile the templateIdQueryList later
		//we have to add the resource files as per the order by in function getResourceFilesOrderBy which is dependent on the order of template IDs sent to it 
		//so we keep applicable_sort_order in this table and will use this later to get exact list of template IDs as we have in this function in templateIdQueryList
		int sorder = 0;				
        while (filesRs.next()) {
            String fileId = filesRs.value("id");

			Etn.executeCmd("insert into "+tbl+" (page_id, bloc_template_id, bloc_templates_lib_id, library_id, file_id, file_type, file_name, file_update_ts, "+
							" library_name, page_position, sort_order, applicable_sort_order) "+
				" value ("+escape.cote(pageId)+", "+escape.cote(filesRs.value("bloc_template_id"))+", "+escape.cote(filesRs.value("bloc_templates_library_id"))+
				", "+escape.cote(filesRs.value("library_id"))+", "+escape.cote(filesRs.value("file_id"))+
				", "+escape.cote(filesRs.value("file_type"))+", "+escape.cote(filesRs.value("file_name"))+", "+escape.cote(filesRs.value("updated_ts"))+
				", "+escape.cote(filesRs.value("library_name"))+", "+escape.cote(filesRs.value("page_position"))+", "+escape.cote(filesRs.value("sort_order"))+", "+escape.cote(""+sorder)+") ");
			
			sorder++;
        }
		
        for (String formFileUrl : formsCssFiles) {
			Etn.executeCmd("insert into "+tbl+" (page_id, file_type, file_name, applicable_sort_order) "+
				" value ("+escape.cote(pageId)+", 'forms_css', "+escape.cote(formFileUrl)+", "+escape.cote(""+sorder)+") ");
			sorder++;
        }
		
        for (String formFileUrl : formsJsFiles) {
			Etn.executeCmd("insert into "+tbl+" (page_id, file_type, file_name, applicable_sort_order) "+
				" value ("+escape.cote(pageId)+", 'forms_js', "+escape.cote(formFileUrl)+", "+escape.cote(""+sorder)+") ");
			sorder++;
        }
    }

    private void processPageTemplateFiles(StringBuilder pageHeadTags, StringBuilder pageBodyTags,String templateIdQueryList, String CSS_URL_PREPEND, String JS_URL_PREPEND) {
        processPageTemplateFiles(pageHeadTags, pageBodyTags,templateIdQueryList, CSS_URL_PREPEND, JS_URL_PREPEND,"1");
    }

    private void processPageTemplateFiles(StringBuilder pageHeadTags, StringBuilder pageBodyTags,String templateIdQueryList, String CSS_URL_PREPEND, String JS_URL_PREPEND,String langId) {

        HashSet<String> filesIdSet = new HashSet<>();

		String q = " SELECT f.id, f.file_name, f.type , l.name, lf.page_position, lf.sort_order "
                + " , UNIX_TIMESTAMP(f.updated_ts) AS updated_ts "
                + " FROM files f "
                + " JOIN libraries_files lf ON lf.file_id = f.id "
                + " JOIN libraries l ON l.id = lf.library_id "
                + " JOIN bloc_templates_libraries btl ON btl.library_id = l.id "
                + " JOIN bloc_templates bt ON bt.id = btl.bloc_template_id "
                + " WHERE bt.id IN (" + templateIdQueryList + ") and lf.lang_id="+escape.cote(langId)
                +" and (COALESCE(f.removal_date,'') = '' or f.removal_date>now()) ";
		q += getResourceFilesOrderBy(templateIdQueryList);

        Set filesRs = Etn.execute(q);
		
        while (filesRs.next()) {
            String fileId = filesRs.value("id");

            if (filesIdSet.contains(fileId)) continue;
            else  filesIdSet.add(fileId);
			
            String fileName = filesRs.value("file_name").trim();
            String fileType = filesRs.value("type");
            String pagePosition = filesRs.value("page_position");
            String updatedTs = filesRs.value("updated_ts");

            String urlFileName = fileName + "?rand=" + updatedTs;
            if ("css".equals(fileType)) {
                if ("head".equals(pagePosition)) pageHeadTags.append(PagesUtil.getLinkTag(CSS_URL_PREPEND + urlFileName));
                else pageBodyTags.append(PagesUtil.getLinkTag(CSS_URL_PREPEND + urlFileName));
            } else if ("js".equals(fileType)) {
                if ("head".equals(pagePosition)) pageHeadTags.append(PagesUtil.getScriptTag(JS_URL_PREPEND + urlFileName));
                else pageBodyTags.append(PagesUtil.getScriptTag(JS_URL_PREPEND + urlFileName));
            }
        }
    }

    public JSONObject getBlocHtmlByPage(String blocId, String pageId, boolean isGenerateForPublish) throws Exception {
        return getBlocMenuHtml(blocId, pageId, "", isGenerateForPublish);
    }

    public JSONObject getBlocHtmlByLang(String blocId, String langId, boolean isGenerateForPublish) throws Exception {
        return getBlocMenuHtml(blocId, "", langId, isGenerateForPublish);
    }
	
	/**
	* This function will save the commercial products view data in db so that if any catalog or its products are changed,
	* we can track what pages have those data in them and we can mark them for regeneration
	*
	*/ 
	private void saveProductViewData(String siteId, String pageId, String blocId, String langId, JSONArray jProductViewArr) {
		log("In saveProductViewData");
		if(PagesUtil.parseNull(pageId).length() == 0) return;
		if(PagesUtil.parseNull(blocId).length() == 0) return;
		if(jProductViewArr == null || jProductViewArr.length() == 0) return;
		log("pageID:"+pageId+" blocID:" + blocId+" langID:"+langId+" jProductViewArr.length:"+jProductViewArr.length());
		
		Set rsL = Etn.execute("select * from language where langue_id = " + escape.cote(langId));
		rsL.next();
		String langCode = rsL.value("langue_code");
		
		for(int i=0;i<jProductViewArr.length();i++) {
			JSONObject jProductViewObj = jProductViewArr.getJSONObject(i);
			
			String forProd = "0";
			if(jProductViewObj.getBoolean("for_prod_site") == true) forProd = "1";
			
			Set rs = Etn.execute("select id from products_view_bloc_data where langue_code = "+escape.cote(langCode)+
						" and for_prod_site = "+escape.cote(forProd)+" and page_id = "+escape.cote(pageId)+
						" and bloc_id = "+escape.cote(blocId)+" and site_id = "+escape.cote(siteId));
						
			String dataId = "";
			if(rs.next()) {
				dataId = rs.value("id");
				Etn.executeCmd("delete from products_view_bloc_criteria where data_id = "+escape.cote(dataId));
				Etn.executeCmd("delete from products_view_bloc_results where data_id = "+escape.cote(dataId));
			}
			
			if(dataId.length() > 0) {
				Etn.executeCmd("update products_view_bloc_data set updated_ts = now(), view_query = "+escape.cote(PagesUtil.parseNull(jProductViewObj.optString("query")))+
						" where id = "+escape.cote(dataId));
			} else {
				dataId = "" + Etn.executeCmd("insert into products_view_bloc_data (site_id, page_id, bloc_id, langue_code, for_prod_site, view_query) "+
						" value ("+escape.cote(siteId)+","+escape.cote(pageId)+", "+escape.cote(blocId)+", "+escape.cote(langCode)+", "+escape.cote(forProd)+", "+escape.cote(PagesUtil.parseNull(jProductViewObj.optString("query")))+") ");
			}
			
			if(dataId.length() > 0) {
				if(jProductViewObj.getJSONArray("criteria") != null && jProductViewObj.getJSONArray("criteria").length() > 0) {
					for(int j=0;j<jProductViewObj.getJSONArray("criteria").length();j++) {
						String criteria = PagesUtil.parseNull(jProductViewObj.getJSONArray("criteria").optString(j));
						if(criteria.length() > 0) Etn.executeCmd("insert into products_view_bloc_criteria (data_id, cid) value ("+escape.cote(dataId)+","+escape.cote(criteria)+")");
					}
				}

				if(jProductViewObj.getJSONArray("results") != null && jProductViewObj.getJSONArray("results").length() > 0){
					for(int j=0;j<jProductViewObj.getJSONArray("results").length();j++){
						String productId = PagesUtil.parseNull(jProductViewObj.getJSONArray("results").optString(j));
						if(productId.length() > 0) Etn.executeCmd("insert into products_view_bloc_results (data_id, product_id) value ("+escape.cote(dataId)+","+escape.cote(productId)+")");
					}
				}
			}
		}
	}

    protected JSONObject getBlocMenuHtml(String id, String pageId, String pLangId, boolean isGenerateForPublish) throws Exception {
        JSONObject retObj = new JSONObject();

        String q = null;
        Set rs = null;
        Set pageRs;
        String langId;

        if (pageId.length() > 0) {
            q = " SELECT p.*, l.og_local as og_local, l.direction as lang_dir, l.langue_id "
                    + ", date_format(p.created_ts, '%Y-%m-%d') as created_ts_date, DATE_FORMAT(p.created_ts,'%H:%i:%s') as created_ts_time "
                    + ", date_format(p.updated_ts, '%Y-%m-%d') as updated_ts_date, DATE_FORMAT(p.updated_ts,'%H:%i:%s') as updated_ts_time "
                    + ", date_format(p.published_ts, '%Y-%m-%d') as published_ts_date, DATE_FORMAT(p.published_ts,'%H:%i:%s') as published_ts_time "
                    + " FROM pages p "
                    + " JOIN language l ON p.langue_code = l.langue_code "
                    + " WHERE id = " + escape.cote(pageId);
            pageRs = Etn.execute(q);

            if (!pageRs.next()) {
                throw new Exception("Error: Invalid page parameters");
            }

        }
        else if (pLangId.length() > 0) {
            q = " SELECT l.og_local as og_local, l.direction as lang_dir, l.langue_id "
                    + " FROM language l"
                    + " WHERE l.langue_id = " + escape.cote(pLangId);
            pageRs = Etn.execute(q);

            if (!pageRs.next()) {
                throw new Exception("Error: Invalid language parameters");
            }
        }
        else {
            throw new Exception("Invalid page and lang parameters");
        }


        q = "SELECT DISTINCT bt.id, bt.template_code, bt.js_code, bt.css_code, bt.jsonld_code, b.site_id AS site_id "
                + " FROM bloc_templates bt "
                + " JOIN blocs b ON b.template_id = bt.id "
                + " WHERE b.id = " + escape.cote(id);
        rs = Etn.execute(q);

        if (!rs.next()) {
            throw new Exception("Error: Invalid id parameter");
        }

        langId = pageRs.value("langue_id");

        String siteId = rs.value("site_id");

        String BASE_DIR = getParm("BASE_DIR");
        String TEMPLATES_DIR = BASE_DIR + "/WEB-INF/templates/";
        String CONTEXT_PATH = getParm("EXTERNAL_LINK");
        String UPLOADS_FOLDER = getParm("UPLOADS_FOLDER") + siteId + "/";
        String CATALOG_DB = getParm("CATALOG_DB");
        String PORTAL_DB = getParm("PORTAL_DB");
        String PROD_PORTAL_DB = getParm("PROD_PORTAL_DB");
        String IMAGE_FOLDER_PATH = BASE_DIR + UPLOADS_FOLDER + "/img/";
        String UPLOADS_URL_PREFIX = CONTEXT_PATH + UPLOADS_FOLDER;
        String IMAGE_URL_PREPEND = UPLOADS_URL_PREFIX + "img/";
        String CSS_URL_PREPEND = UPLOADS_URL_PREFIX + "css/";
        String JS_URL_PREPEND = UPLOADS_URL_PREFIX + "js/";

        StringTemplateLoader stringTemplateLoader = new StringTemplateLoader();
        stringTemplateLoader.putTemplate("template_" + rs.value("id"), rs.value("template_code"));
        stringTemplateLoader.putTemplate("template_js_" + rs.value("id"), rs.value("js_code"));
        stringTemplateLoader.putTemplate("template_css_" + rs.value("id"), rs.value("css_code"));
        stringTemplateLoader.putTemplate("template_jsonld_" + rs.value("id"), rs.value("jsonld_code"));

        Configuration cfg=null;
        try{
            cfg = PagesUtil.getFreemarkerConfig(stringTemplateLoader, TEMPLATES_DIR);
            cfg.setSharedVariable("translateFunc", new TranslateLang(langId,Etn));
        }catch(Exception e) {
            logE("printing error -----------------------------------------");
        }

        HashMap<String, String> tagsHM = PagesUtil.getAllTags(Etn, siteId, CATALOG_DB);
        Map<String, Object> templateHM = new HashMap<>();

        Map<String, Object> pageHM = new HashMap<>();
        Map<String, Object> socialHM = new HashMap<>();
        Map<String, Object> siteParamHM = PagesUtil.getSiteParamDataMap(Etn, siteId, langId, PROD_PORTAL_DB);

        PagesUtil.fillPageAndMetaDataMap(Etn, pageHM, socialHM, pageRs,
                IMAGE_FOLDER_PATH, IMAGE_URL_PREPEND, debug);

        JSONArray headJsFiles = new JSONArray();
        JSONArray bodyJsFiles = new JSONArray();
        JSONArray headCssFiles = new JSONArray();
        JSONArray bodyCssFiles = new JSONArray();

        StringBuilder bodyCss = new StringBuilder();
        StringBuilder bodyJs = new StringBuilder();

        q = "SELECT b.id AS bloc_id, b.name AS bloc_name, b.template_id , bd.template_data "
                + " , b.rss_feed_ids, b.rss_feed_sort "
                + " , b.margin_top , b.margin_bottom "
                + " , b.refresh_interval , b.visible_to , b.start_date , b.end_date "
                + " , bt.custom_id AS template_custom_id, bt.template_code, bt.js_code, bt.css_code, bt.jsonld_code "
                + " , bt.type AS template_type "
                + " FROM blocs b "
                + " JOIN blocs_details bd ON bd.bloc_id = b.id AND bd.langue_id = " + escape.cote(langId)
                + " JOIN bloc_templates bt ON b.template_id = bt.id "
                + " WHERE b.id = " + escape.cote(id);

        rs = Etn.execute(q);

        if (!rs.next()) {
            throw new Exception("Error: something very wrong.");
        }
        String templateId = rs.value("template_id");
        String templateType = rs.value("template_type");
        String templateData = rs.value("template_data");
        String templateCustomId = rs.value("template_custom_id");

        String refreshInterval = rs.value("refresh_interval");
        String visibleTo = rs.value("visible_to");

        String marginTop = rs.value("margin_top");
        String marginBottom = rs.value("margin_bottom");

        templateData = PagesUtil.decodeJSONStringDB(templateData);

        String templateJsCode = rs.value("js_code");
        String templateCssCode = rs.value("css_code");
        String templateJsonldCode = rs.value("jsonld_code");

        Template curBlocTemplate = cfg.getTemplate("template_" + templateId);

        JSONObject templateDataJson = new JSONObject(templateData);
        TemplateDataGenerator templateDataGen = getTemplateDataGenerator(siteId);
        HashMap<String, Object> curBlocDataHM = templateDataGen.getBlocTemplateDataMap(templateId, templateDataJson, tagsHM, langId,isGenerateForPublish);
		
		saveProductViewData(siteId, pageId, id, langId, templateDataGen.jProductViewArr);

        HashMap<String, Object> extraDataHM = PagesUtil.getBlocExtraDataMap(Etn, id, templateType, PORTAL_DB);

        curBlocDataHM.putAll(extraDataHM);

        curBlocDataHM.put("page", pageHM);
        curBlocDataHM.put("site_param", siteParamHM);

        JSONObject dataJson = new JSONObject();
        try {
            dataJson = new JSONObject(curBlocDataHM);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        curBlocDataHM.put("data_json", dataJson.toString());

        StringWriter blocHtml = new StringWriter();

        curBlocDataHM.putAll(PagesUtil.loadVariables(Etn, siteId, langId, isGenerateForPublish));
		
        curBlocTemplate.process(curBlocDataHM, blocHtml);

        if (templateJsCode.trim().length() > 0) {
            StringWriter jsCodeWriter = new StringWriter();
            Template curBlocJsTemplate = cfg.getTemplate("template_js_" + templateId);
            curBlocJsTemplate.process(curBlocDataHM, jsCodeWriter);
            bodyJs.append(jsCodeWriter.toString()).append("\n");
        }
        if (templateCssCode.trim().length() > 0) {
            StringWriter cssCodeWriter = new StringWriter();
            Template curBlocCssTemplate = cfg.getTemplate("template_css_" + templateId);
            curBlocCssTemplate.process(curBlocDataHM, cssCodeWriter);
            bodyCss.append(cssCodeWriter.toString()).append("\n");
        }
        String jsonldHtml = "";
        if (templateJsonldCode.trim().length() > 0) {
            StringWriter jsonldCodeWriter = new StringWriter();
            Template curBlocJsonldTemplate = cfg.getTemplate("template_jsonld_" + templateId);
            curBlocJsonldTemplate.process(curBlocDataHM, jsonldCodeWriter);
            JSONObject jsonObject;
            try {
                jsonObject = new JSONObject(jsonldCodeWriter.toString());
                if (jsonObject.keySet().isEmpty()) {
                    throw new JSONException("");
                }
            } catch (JSONException e) {
                jsonObject = new JSONObject();
                jsonObject.put("error", "Invalid Json-ld from Block " + rs.value("bloc_name"));
            }
            jsonldHtml = jsonObject.toString();
        }

        //generate valid xhtml
        Document validHtmlDoc = Jsoup.parse(blocHtml.toString(), "", Parser.htmlParser());
        validHtmlDoc.outputSettings().prettyPrint(false);
        if (jsonldHtml.trim().length() > 0) {
            validHtmlDoc.body().appendChild(new Element("script").attr("type", "application/ld+json").appendChild(new DataNode("\n" + jsonldHtml + "\n")));
        }

        //html parser adds <html>,<head>, <body> tags to make it valid html
        //just keep body innerHtml
        String validHtml = validHtmlDoc.body().html();

        ArrayList<String> attrList = new ArrayList<>();
        ArrayList<String> valList = new ArrayList<>();

        String classVal = "bloc_div";
        classVal += " visible_to_" + visibleTo;
        classVal += " template_custom_id_" + templateCustomId;

        attrList.add("class");
        valList.add(classVal);

        String styleVal = "margin-top: " + marginTop + "px;"
                + " margin-bottom: " + marginBottom + "px;";
        attrList.add("style");
        valList.add(styleVal);

        attrList.add("data-bloc-id");
        valList.add(id);

        attrList.add("data-bloc-name");
        valList.add(rs.value("bloc_name"));

        attrList.add("template-custom-id");
        valList.add(templateCustomId);

        attrList.add("visible-to");
        valList.add(visibleTo);

        attrList.add("refresh-interval");
        valList.add(refreshInterval);

        String blocDiv = PagesUtil.generateHtmlTag("div", validHtml, attrList, valList);

        HashSet<String> filesIdSet = new HashSet<>();

        q = " SELECT DISTINCT f.id, f.file_name, f.type, UNIX_TIMESTAMP(f.updated_ts) AS updated_ts "
                + " , l.name, lf.page_position, lf.sort_order "
                + " FROM files f "
                + " JOIN libraries_files lf ON lf.file_id = f.id "
                + " JOIN libraries l ON l.id = lf.library_id "
                + " JOIN bloc_templates_libraries btl ON btl.library_id = l.id "
                + " JOIN bloc_templates bt ON bt.id = btl.bloc_template_id "
                + " WHERE bt.id = " + escape.cote(templateId)+" and lf.lang_id="+escape.cote(pLangId)
                +" and (COALESCE(f.removal_date,'') = '' or  f.removal_date>now()) "
                + " ORDER BY"
                + " btl.id,"
                + " lf.sort_order ";

        Set filesRs = Etn.execute(q);
        while (filesRs.next()) {
            String fileId = filesRs.value("id");

            if (filesIdSet.contains(fileId)) continue;
            else filesIdSet.add(fileId);

            String fileName = filesRs.value("file_name").trim();
            String fileType = filesRs.value("type");
            String pagePosition = filesRs.value("page_position");
            String updatedTs = filesRs.value("updated_ts");

            String urlFileName = fileName + "?rand=" + updatedTs;
            if ("css".equals(fileType)) {
                if ("head".equals(pagePosition)) headCssFiles.put(CSS_URL_PREPEND + urlFileName);
                else bodyCssFiles.put(CSS_URL_PREPEND + urlFileName);
            }
            else if ("js".equals(fileType)) {
                if ("head".equals(pagePosition)) headJsFiles.put(JS_URL_PREPEND + urlFileName);
                else bodyJsFiles.put(JS_URL_PREPEND + urlFileName);
            }
        }

        retObj.put("blocHtml", blocDiv);
        retObj.put("bodyCss", bodyCss.toString());
        retObj.put("bodyJs", bodyJs.toString());
        retObj.put("headJsFiles", headJsFiles);
        retObj.put("bodyJsFiles", bodyJsFiles);
        retObj.put("headCssFiles", headCssFiles);
        retObj.put("bodyCssFiles", bodyCssFiles);

        return retObj;
    }

    protected String getBlocHtmlForBlocField(String id, String pageId, String pLangId, boolean isGenerateForPublish) throws Exception {
        JSONObject retObj = new JSONObject();

        String q = null;
        Set rs = null;
        Set pageRs;
        String langId;

        if (pageId.length() > 0) {
            q = " SELECT p.*, l.og_local as og_local, l.direction as lang_dir, l.langue_id "
                    + ", date_format(p.created_ts, '%Y-%m-%d') as created_ts_date, DATE_FORMAT(p.created_ts,'%H:%i:%s') as created_ts_time "
                    + ", date_format(p.updated_ts, '%Y-%m-%d') as updated_ts_date, DATE_FORMAT(p.updated_ts,'%H:%i:%s') as updated_ts_time "
                    + ", date_format(p.published_ts, '%Y-%m-%d') as published_ts_date, DATE_FORMAT(p.published_ts,'%H:%i:%s') as published_ts_time FROM pages p "
                    + " JOIN language l ON p.langue_code = l.langue_code WHERE id = " + escape.cote(pageId);
            pageRs = Etn.execute(q);
            if (!pageRs.next()) {
                throw new Exception("Error: Invalid page parameters");
            }
        } else if (pLangId.length() > 0) {
            pageRs = Etn.execute("SELECT l.og_local as og_local, l.direction as lang_dir, l.langue_id FROM language l WHERE l.langue_id = " + escape.cote(pLangId));
            if (!pageRs.next()) {
                throw new Exception("Error: Invalid language parameters");
            }
        } else {
            throw new Exception("Invalid page and lang parameters");
        }

        q = "SELECT DISTINCT bt.id, bt.template_code, bt.js_code, bt.css_code, bt.jsonld_code, b.site_id AS site_id FROM bloc_templates bt JOIN blocs b ON b.template_id = bt.id WHERE b.id = " + escape.cote(id);
        rs = Etn.execute(q);
        if (!rs.next()) {
            throw new Exception("Error: Invalid id parameter");
        }
        langId = pageRs.value("langue_id");

        String siteId = rs.value("site_id");
        String BASE_DIR = getParm("BASE_DIR");
        String TEMPLATES_DIR = BASE_DIR + "/WEB-INF/templates/";
        String CONTEXT_PATH = getParm("EXTERNAL_LINK");
        String UPLOADS_FOLDER = getParm("UPLOADS_FOLDER") + siteId + "/";
        String CATALOG_DB = getParm("CATALOG_DB");
        String PORTAL_DB = getParm("PORTAL_DB");
        String PROD_PORTAL_DB = getParm("PROD_PORTAL_DB");
        String IMAGE_FOLDER_PATH = BASE_DIR + UPLOADS_FOLDER + "/img/";
        String UPLOADS_URL_PREFIX = CONTEXT_PATH + UPLOADS_FOLDER;
        String IMAGE_URL_PREPEND = UPLOADS_URL_PREFIX + "img/";
        String CSS_URL_PREPEND = UPLOADS_URL_PREFIX + "css/";
        String JS_URL_PREPEND = UPLOADS_URL_PREFIX + "js/";

        StringTemplateLoader stringTemplateLoader = new StringTemplateLoader();
        stringTemplateLoader.putTemplate("template_" + rs.value("id"), rs.value("template_code"));
        stringTemplateLoader.putTemplate("template_js_" + rs.value("id"), rs.value("js_code"));
        stringTemplateLoader.putTemplate("template_css_" + rs.value("id"), rs.value("css_code"));
        stringTemplateLoader.putTemplate("template_jsonld_" + rs.value("id"), rs.value("jsonld_code"));

        Configuration cfg=null;
        try{
            cfg = PagesUtil.getFreemarkerConfig(stringTemplateLoader, TEMPLATES_DIR);
            cfg.setSharedVariable("translateFunc", new TranslateLang(langId,Etn));
        }catch(Exception e) {
            logE("printing error -----------------------------------------");
        }

        HashMap<String, String> tagsHM = PagesUtil.getAllTags(Etn, siteId, CATALOG_DB);
        Map<String, Object> templateHM = new HashMap<>();

        Map<String, Object> pageHM = new HashMap<>();
        Map<String, Object> socialHM = new HashMap<>();
        Map<String, Object> siteParamHM = PagesUtil.getSiteParamDataMap(Etn, siteId, langId, PROD_PORTAL_DB);

        PagesUtil.fillPageAndMetaDataMap(Etn, pageHM, socialHM, pageRs,
                IMAGE_FOLDER_PATH, IMAGE_URL_PREPEND, debug);

        JSONArray headJsFiles = new JSONArray();
        JSONArray bodyJsFiles = new JSONArray();
        JSONArray headCssFiles = new JSONArray();
        JSONArray bodyCssFiles = new JSONArray();

        StringBuilder bodyCss = new StringBuilder();
        StringBuilder bodyJs = new StringBuilder();

        q = "SELECT b.id AS bloc_id, b.name AS bloc_name, b.template_id , bd.template_data , b.rss_feed_ids, b.rss_feed_sort, b.margin_top , b.margin_bottom "
                + " , b.refresh_interval , b.visible_to , b.start_date , b.end_date, bt.custom_id AS template_custom_id, bt.template_code, bt.js_code, bt.css_code, bt.jsonld_code "
                + " , bt.type AS template_type FROM blocs b JOIN blocs_details bd ON bd.bloc_id = b.id AND bd.langue_id = " + escape.cote(langId)
                + " JOIN bloc_templates bt ON b.template_id = bt.id WHERE b.id = " + escape.cote(id);
        rs = Etn.execute(q);

        if (!rs.next()) {
            throw new Exception("Error: something very wrong.");
        }
        String templateId = rs.value("template_id");
        String templateType = rs.value("template_type");
        String templateData = rs.value("template_data");
        String templateCustomId = rs.value("template_custom_id");
        String refreshInterval = rs.value("refresh_interval");
        String visibleTo = rs.value("visible_to");
        String marginTop = rs.value("margin_top");
        String marginBottom = rs.value("margin_bottom");

        templateData = PagesUtil.decodeJSONStringDB(templateData);

        String templateJsCode = rs.value("js_code");
        String templateCssCode = rs.value("css_code");
        String templateJsonldCode = rs.value("jsonld_code");

        Template curBlocTemplate = cfg.getTemplate("template_" + templateId);

        JSONObject templateDataJson = new JSONObject(templateData);
        TemplateDataGenerator templateDataGen = getTemplateDataGenerator(siteId);
        HashMap<String, Object> curBlocDataHM = templateDataGen.getBlocTemplateDataMap(templateId, templateDataJson, tagsHM, langId,isGenerateForPublish);
		
		saveProductViewData(siteId, pageId, id, langId, templateDataGen.jProductViewArr);

        HashMap<String, Object> extraDataHM = PagesUtil.getBlocExtraDataMap(Etn, id, templateType, PORTAL_DB);

        curBlocDataHM.putAll(extraDataHM);

        curBlocDataHM.put("page", pageHM);
        curBlocDataHM.put("site_param", siteParamHM);

        JSONObject dataJson = new JSONObject();
        try {
            dataJson = new JSONObject(curBlocDataHM);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        curBlocDataHM.put("data_json", dataJson.toString());

        StringWriter blocHtml = new StringWriter();

        curBlocDataHM.putAll(PagesUtil.loadVariables(Etn, siteId, langId, isGenerateForPublish));
		
        curBlocTemplate.process(curBlocDataHM, blocHtml);

        if (templateJsCode.trim().length() > 0) {
            StringWriter jsCodeWriter = new StringWriter();
            Template curBlocJsTemplate = cfg.getTemplate("template_js_" + templateId);
            curBlocJsTemplate.process(curBlocDataHM, jsCodeWriter);
            bodyJs.append(jsCodeWriter.toString()).append("\n");
        }
        if (templateCssCode.trim().length() > 0) {
            StringWriter cssCodeWriter = new StringWriter();
            Template curBlocCssTemplate = cfg.getTemplate("template_css_" + templateId);
            curBlocCssTemplate.process(curBlocDataHM, cssCodeWriter);
            bodyCss.append(cssCodeWriter.toString()).append("\n");
        }
        String jsonldHtml = "";
        if (templateJsonldCode.trim().length() > 0) {
            StringWriter jsonldCodeWriter = new StringWriter();
            Template curBlocJsonldTemplate = cfg.getTemplate("template_jsonld_" + templateId);
            curBlocJsonldTemplate.process(curBlocDataHM, jsonldCodeWriter);
            JSONObject jsonObject;
            try {
                jsonObject = new JSONObject(jsonldCodeWriter.toString());
                if (jsonObject.keySet().isEmpty()) {
                    throw new JSONException("");
                }
            } catch (JSONException e) {
                jsonObject = new JSONObject();
                jsonObject.put("error", "Invalid Json-ld from Block " + rs.value("bloc_name"));
            }
            jsonldHtml = jsonObject.toString();
        }

        //generate valid xhtml
        Document validHtmlDoc = Jsoup.parse(blocHtml.toString(), "", Parser.htmlParser());
        validHtmlDoc.outputSettings().prettyPrint(false);
        if (jsonldHtml.trim().length() > 0) {
            validHtmlDoc.body().appendChild(new Element("script").attr("type", "application/ld+json").appendChild(new DataNode("\n" + jsonldHtml + "\n")));
        }

        //html parser adds <html>,<head>, <body> tags to make it valid html
        //just keep body innerHtml
        String validHtml = validHtmlDoc.body().html();
        ArrayList<String> attrList = new ArrayList<>();
        ArrayList<String> valList = new ArrayList<>();

        // String classVal = "child_bloc_div";
        // classVal += " visible_to_" + visibleTo;
        // classVal += " template_custom_id_" + templateCustomId;

        attrList.add("class");
        valList.add("child_bloc_div");

        // String styleVal = "margin-top: " + marginTop + "px;"
        //         + " margin-bottom: " + marginBottom + "px;";
        // attrList.add("style");
        // valList.add(styleVal);

        attrList.add("data-bloc-id");
        valList.add(id);

        attrList.add("data-bloc-name");
        valList.add(rs.value("bloc_name"));

        attrList.add("template-custom-id");
        valList.add(templateCustomId);

        attrList.add("visible-to");
        valList.add(visibleTo);

        attrList.add("refresh-interval");
        valList.add(refreshInterval);

        String blocDiv = PagesUtil.generateHtmlTag("div", validHtml, attrList, valList);

        return "<style type='text/css'>"+bodyCss.toString()+"</style>"+blocDiv+"<script type='text/javascript'>"+bodyJs.toString()+"</script>";
    }

    public String getPageTemplateHtml(String pageTemplateId, String langId, String siteId, String contentUUID) throws Exception {
        log("Generating page template : " + pageTemplateId);
        String retHtml = "";

        String q = null;
        Set rs = null;
        String blocIdQueryList = "";

        q = " SELECT pt.* "
                + " FROM page_templates pt "
                + " WHERE pt.id =" + escape.cote(pageTemplateId)
                + " AND pt.site_id =" + escape.cote(siteId);
        Set ptRs = Etn.execute(q);
        if (!ptRs.next()) {
            throw new Exception("Error: page template not found.");
        }

        StringTemplateLoader stringTemplateLoader = new StringTemplateLoader();

        String defaultPageTemplate = "<!DOCTYPE html><html><head></head><body>${content}</body></html>";
        stringTemplateLoader.putTemplate("pageTemplate_0", defaultPageTemplate);
        stringTemplateLoader.putTemplate("pageTemplate_" + pageTemplateId, ptRs.value("template_code"));

        TemplateDataGenerator templateDataGen = getTemplateDataGenerator(siteId);

        String BASE_DIR = getParm("BASE_DIR");
        String TEMPLATES_DIR = BASE_DIR + "/WEB-INF/templates/";

        String CONTEXT_PATH = getParm("EXTERNAL_LINK");
        String UPLOADS_FOLDER = getParm("UPLOADS_FOLDER") + siteId + "/";
        String CATALOG_DB = getParm("CATALOG_DB");
        String PORTAL_DB = getParm("PORTAL_DB");
        String PROD_PORTAL_DB = getParm("PROD_PORTAL_DB");
        String IMAGE_FOLDER_PATH = BASE_DIR + UPLOADS_FOLDER + "/img/";
        String UPLOADS_URL_PREFIX = CONTEXT_PATH + UPLOADS_FOLDER;
        String IMAGE_URL_PREPEND = UPLOADS_URL_PREFIX + "img/";
        String CSS_URL_PREPEND = UPLOADS_URL_PREFIX + "css/";
        String JS_URL_PREPEND = UPLOADS_URL_PREFIX + "js/";

        HashMap<String, String> tagsHM = PagesUtil.getAllTags(Etn, siteId, CATALOG_DB);
        Map<String, Object> templateHM = new HashMap<>();

        Map<String, Object> pageHM = new HashMap<>();
        Map<String, Object> metaHM = new HashMap<>();
        Map<String, Object> siteParamHM = PagesUtil.getSiteParamDataMap(Etn, siteId, langId, PROD_PORTAL_DB);

        Set dummyPageRs = Etn.execute("SELECT 1;");
        PagesUtil.fillPageAndMetaDataMap(Etn, pageHM, metaHM, dummyPageRs,
                IMAGE_FOLDER_PATH, IMAGE_URL_PREPEND, debug);
        StringBuilder pageHeadTags = new StringBuilder();

        String content = "<div id='content_" + contentUUID + "'></div>";

        StringBuilder pageBodyTags = new StringBuilder();
        StringBuilder pageBodyCss = new StringBuilder();
        StringBuilder pageBodyJs = new StringBuilder();
        List<JSONObject> pageBodyJsonlds = new ArrayList<>();

        q = " SELECT DISTINCT bt.id, bt.template_code, bt.js_code, bt.css_code, bt.jsonld_code "
                + " FROM bloc_templates bt "
                + " JOIN blocs b ON b.template_id = bt.id "
                + " JOIN page_templates_items_blocs ptb ON ptb.bloc_id = b.id AND ptb.type = 'bloc' "
                + " JOIN page_templates_items pti ON pti.id = ptb.item_id "
                + " WHERE pti.page_template_id = " + escape.cote(pageTemplateId)
                + " AND ptb.langue_id = " + escape.cote(langId)
                + " ORDER BY pti.sort_order, pti.sort_order";

        rs = Etn.execute(q);

        ArrayList<String> templateIdsList = new ArrayList<>();
        while (rs.next()) {
            templateIdsList.add(escape.cote(rs.value("id")));
            stringTemplateLoader.putTemplate("template_" + rs.value("id"), rs.value("template_code"));
            stringTemplateLoader.putTemplate("template_js_" + rs.value("id"), rs.value("js_code"));
            stringTemplateLoader.putTemplate("template_css_" + rs.value("id"), rs.value("css_code"));
            stringTemplateLoader.putTemplate("template_jsonld_" + rs.value("id"), rs.value("jsonld_code"));
        }
        String templateIdQueryList = escape.cote("-1");
        if (templateIdsList.size() > 0) {
            templateIdQueryList = String.join(",", templateIdsList);
        }
        
        Configuration cfg=null;
        try{
            cfg = PagesUtil.getFreemarkerConfig(stringTemplateLoader, TEMPLATES_DIR);
            cfg.setSharedVariable("translateFunc", new TranslateLang(langId,Etn));
        }catch(Exception e)
        {
            logE("printing error -----------------------------------------");
        }

        //generating bloc html divs for all blocs
        //storing in HM to save regenerating in case there are duplicates
        HashMap<String, String> blocResultHM = new HashMap<>();

        q = " SELECT b.id AS bloc_id, b.name AS bloc_name, b.template_id , bd.template_data "
                + " , b.rss_feed_ids, b.rss_feed_sort "
                + " , b.margin_top , b.margin_bottom "
                + " , b.refresh_interval , b.visible_to , b.start_date , b.end_date "
                + " , bt.custom_id AS template_custom_id, bt.js_code, bt.css_code, bt.jsonld_code "
                + " , bt.type AS template_type "
                + " FROM blocs b "
                + " JOIN blocs_details bd ON bd.bloc_id = b.id AND bd.langue_id = " + escape.cote(langId)
                + " JOIN bloc_templates bt ON b.template_id = bt.id "
                + " JOIN page_templates_items_blocs ptb ON ptb.bloc_id = b.id AND ptb.type = 'bloc' "
                + " JOIN page_templates_items pti ON pti.id = ptb.item_id "
                + " WHERE pti.page_template_id = " + escape.cote(pageTemplateId)
                + " AND ptb.langue_id = " + escape.cote(langId);

        String blocsQuery = q;
        processPageBlocsHTML(blocsQuery, blocResultHM, pageHM, siteParamHM, tagsHM,
                pageBodyJs, pageBodyCss, pageBodyJsonlds, cfg, templateDataGen, langId, PORTAL_DB, siteId, null, false);

        //Add CSS and JS files tags
        ArrayList<String> emptyDummyList = new ArrayList<>();
        processPageTemplateFiles(pageHeadTags, pageBodyTags, templateIdQueryList, CSS_URL_PREPEND, JS_URL_PREPEND,langId);
        pageBodyTags.append(PagesUtil.getScriptTag(CONTEXT_PATH + "js/pages_default.js"));

        Template template = cfg.getTemplate("pageTemplate_" + pageTemplateId);

        q = " SELECT pti.id, pti.name, pti.custom_id, ptd.* "
                + " FROM page_templates_items pti "
                + " LEFT JOIN page_templates_items_details ptd ON ptd.item_id = pti.id "
                + "     AND ptd.langue_id = " + escape.cote(langId)
                + " WHERE page_template_id = " + escape.cote(pageTemplateId)
                + " AND pti.custom_id != 'content' ";
        rs = Etn.execute(q);

        while (rs.next()) {
            String regionCustomId = rs.value("custom_id");

            HashMap<String, Object> regionHM = new HashMap<>();
            String cssClasses = PagesUtil.parseNull(rs.value("css_classes"));
            String cssStyle = PagesUtil.parseNull(rs.value("css_style"));
            ArrayList<String> regionBlocsList = new ArrayList<>();

            q = " SELECT ptb.* , COALESCE(bt1.type,'') AS template_type "
                    + " FROM page_templates_items_blocs ptb "
                    + " LEFT JOIN blocs b ON b.id = ptb.bloc_id AND ptb.type = 'bloc' "
                    + " LEFT JOIN bloc_templates bt1 ON bt1.id = b.template_id"
                    + " WHERE ptb.item_id = " + escape.cote(rs.value("id"))
                    + " AND ptb.langue_id = " + escape.cote(langId)
                    + " ORDER BY ptb.sort_order ";
            Set blocRs = Etn.execute(q);
            while (blocRs.next()) {
                String blocHMKey = blocRs.value("template_type") + "_" + blocRs.value("bloc_id");
                if (blocResultHM.get(blocHMKey) != null) {
                    regionBlocsList.add(blocResultHM.get(blocHMKey));
                }
            }

            regionHM.put("css_classes", cssClasses);
            regionHM.put("css_style", cssStyle);
            regionHM.put("blocs", regionBlocsList);

            templateHM.put(regionCustomId, regionHM);

        }

        templateHM.put("page", pageHM);
        templateHM.put("site_param", siteParamHM);
        templateHM.put("content", content);

        StringWriter stringWriter = new StringWriter();

        template.process(templateHM, stringWriter);

        Document document = Jsoup.parse(stringWriter.toString(), "", Parser.htmlParser());
        document.outputSettings().prettyPrint(false);
        Element htmlTag = document.getElementsByTag("html").first();
        Element head = document.head();
        Element body = document.body();

        head.appendChild(new Comment(" page.headTags "));
        head.append(pageHeadTags.toString());

        body.prependChild(new Comment(" page.body "));

        body.appendChild(new Comment(" page.bodyTags "));
        body.append(pageBodyTags.toString());

        if (pageBodyCss.toString().trim().length() > 0) {
            body.appendChild(new Comment(" page.bodyCss "));
            body.appendChild(new Element("style").attr("type", "text/css")
                    .appendChild(new DataNode("\n" + pageBodyCss.toString() + "\n")));
        }

        if (pageBodyJs.toString().trim().length() > 0) {
            body.appendChild(new Comment(" page.bodyJs "));
            body.appendChild(new Element("script").attr("type", "text/javascript")
                    .appendChild(new DataNode("\n" + pageBodyJs.toString() + "\n")));
        }
        body.appendChild(new Comment(" page.bodyJsonld "));
        for (JSONObject jsonld : pageBodyJsonlds) {
            body.appendChild(new Element("script").attr("type", "application/ld+json")
                    .appendChild(new DataNode("\n" + jsonld.toString() + "\n")));
        }
        //        document.outputSettings().prettyPrint(false);

        retHtml = document.toString();
        return retHtml;
    }
	
	/*
	* This function will use the content saved on disk in published_content/ folder and apply template to it
	* If the content is missing on disk we just return false in which case the html file previously created will be used
	*/
	public boolean regenerateForCache(String pageId, boolean isGenerateForPublish) throws Exception
	{
		Set rs = Etn.execute("select p.*, l.langue_id, s.suid as site_uuid from pages p join language l on l.langue_code = p.langue_code "+
							" join "+getParm("PORTAL_DB")+".sites s on s.id = p.site_id where p.id = "+escape.cote(pageId));
		if(!rs.next())
		{
			logE("No row found for Page ID : " +pageId);
			return false;
		}
		
		String siteId = rs.value("site_id");
		String langId = rs.value("langue_id");
		String langCode = rs.value("langue_code");
		String siteUuid = rs.value("site_uuid");
		String pageHtmlPath = rs.value("html_file_path");
		if(isGenerateForPublish) pageHtmlPath = rs.value("published_html_file_path");
		
		String PROD_PORTAL_DB = getParm("PROD_PORTAL_DB");
		String BASE_DIR = getParm("BASE_DIR");
		String PAGES_SAVE_FOLDER = getParm("PAGES_SAVE_FOLDER");
		if(isGenerateForPublish) PAGES_SAVE_FOLDER = getParm("PAGES_PUBLISH_FOLDER");
		String contentDir = BASE_DIR + PAGES_SAVE_FOLDER + "published_content/"+siteId+"/"+pageId+"/";
		
		File cDir = new File(contentDir);
		boolean contentFilesFound = false;
		if(cDir.exists())
		{
			File contentFile = new File(contentDir + "page_content");
			File pageHMFile = new File(contentDir + "pageHM");
			File metaHMFile = new File(contentDir + "metaHM");
			if(contentFile.exists() == false || pageHMFile.exists() == false || metaHMFile.exists() == false)
			{
				logE("Required content file(s) missing for Page ID : " +pageId);
			}
			else
			{							
				StringBuilder pageBody = readFileContents(contentFile);				
				StringBuilder pageBodyCss = readFileContents(new File(contentDir + "body_css"));
				StringBuilder pageBodyJs = readFileContents(new File(contentDir + "body_js"));
				StringBuilder pageCustomMetaTags = readFileContents(new File(contentDir + "custom_meta_tags"));
				
				String jsonLds = PagesUtil.parseNull((readFileContents(new File(contentDir + "jsonlds"))).toString());
				if(jsonLds.length() == 0) jsonLds = "[]";
				JSONArray jJsonLds = new JSONArray(jsonLds);
				ArrayList<JSONObject> pageBodyJsonlds = new ArrayList<>();
				for(int i=0;i<jJsonLds.length();i++)
				{
					pageBodyJsonlds.add(jJsonLds.getJSONObject(i));
				}
				
				Map<String, Object> pageHM = readMapFromFile(new File(contentDir + "pageHM"));				
				Map<String, Object> metaHM = readMapFromFile(new File(contentDir + "metaHM"));
				Map<String, Object> oTagsHM = readMapFromFile(new File(contentDir + "tagsHM"));
				LinkedHashMap<String, String> tagsHM = tagsHM = new LinkedHashMap<>();
				if(oTagsHM != null)
				{
					for(Map.Entry<String, Object> mEntry : oTagsHM.entrySet())
					{
						tagsHM.put(mEntry.getKey(), PagesUtil.parseNull(mEntry.getValue()));
					}
				}
				
				Map<String, Object> siteParamHM = PagesUtil.getSiteParamDataMap(Etn, siteId, langId, PROD_PORTAL_DB);
				
				String pageHtmlStr = applyTemplate(pageId, langId, langCode, siteId, siteUuid, pageHM, metaHM, siteParamHM, tagsHM,
					pageBody, pageCustomMetaTags, pageBodyCss, pageBodyJs, pageBodyJsonlds, isGenerateForPublish);
					
					
				if(PagesUtil.parseNull(pageHtmlStr).length() > 0)
				{					
					String PAGES_DIR = BASE_DIR + PAGES_SAVE_FOLDER;
					log("In regenerateForCache PAGES_DIR : " + PAGES_DIR);
					log("---------------------------- pageHtmlPath " + pageHtmlPath);

					File pageHtmlFile = new File(PAGES_DIR + pageHtmlPath);
					File folder = pageHtmlFile.getParentFile();
					if (!folder.exists()) {
						folder.mkdirs();
					}

					if (!pageHtmlFile.exists()) {
						pageHtmlFile.createNewFile();
					}

					if (debug) {
						log("write to file : " + pageHtmlFile.getAbsolutePath());
					}

					FilesUtil.writeFile(pageHtmlFile, pageHtmlStr);										
										
				}	
				return true;				
			}
		}
		else
		{
			logE(contentDir + " does not exists. We cannot re-apply template on content.");
		}
		return false;
	}
	
	private StringBuilder readFileContents(File file) throws Exception
	{
		BufferedReader br = null;
		StringBuilder contents = new StringBuilder();
		try
		{
			if(file.exists()){
				br = new BufferedReader(new InputStreamReader(new FileInputStream(file), "UTF-8"));					
				String str;
				while ((str = br.readLine()) != null) 
				{
					contents.append(str+System.getProperty("line.separator"));
				}
			}
		}
		finally
		{
			if(br != null) br.close();
		}
		return contents;
	}
	
	private Map<String, Object> readMapFromFile(File file) throws Exception
	{
		ObjectInputStream ois = null;
		Map<String, Object> map = null;
		try
		{
			FileInputStream fis = new FileInputStream(file);
			ois = new ObjectInputStream(fis);
			map = (Map<String,Object>) ois.readObject();
		}
		finally
		{
			if(ois != null) ois.close();
		}
		
		if(map == null) map = new HashMap<>();
		return map;
	}

	private void logE(String m)
	{
		System.out.println("PagesGenerator.java::ERROR::"+m);
	}
}
