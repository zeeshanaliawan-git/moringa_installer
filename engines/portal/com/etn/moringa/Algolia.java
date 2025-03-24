package com.etn.moringa;

import java.util.*;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.math.BigDecimal;


import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.util.ApiCaller;

import org.jsoup.*;
import org.json.JSONObject;
import org.json.JSONArray;

import java.net.URL;
import java.net.URLEncoder;
import java.net.HttpURLConnection;
import java.io.OutputStreamWriter;
import java.io.OutputStream;
import java.io.InputStream;
import java.io.File;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class Algolia 
{ 
	private Properties env;
	private ClientSql Etn;
	private boolean isprod;
	private boolean debug;
	private String portaldb = "";
	private String catalogdb = "";
	private String preprodcatalogdb = "";
	private String pagesdb = "";
	private String commonsdb = "";
	private boolean activated = false;
	private boolean excludeNoIndex = false;
	private String algDefaultIndex = "";
	private String urlprefix = "";
	private String sitedomain = "";
	private String menuid = "";
	private String siteid = "";
	private String appId = "";
	private String apiKey = "";
	private String langId = "";
	private String langCode = "";

	private final int ESC_CHAR = (int) '\\';
    private final String ESC_STR = "\\\\";
    private final String ESC_PLCHOLDR = "#SLS#";
	
	private String cacheBaseDir = "";
	
	private ApiCaller apiCaller;
	
	private boolean useProxy = true;//by default we assume we will use proxy if its configured

    private String escapeCote3(String str) 
	{
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
	
	private void init(ClientSql Etn, Properties env, boolean isprod, boolean debug) throws Exception
	{
		this.Etn = Etn;
		this.env = env;
		this.isprod = isprod;
		this.debug = debug;	
		
		commonsdb = env.getProperty("COMMONS_DB")+".";
		pagesdb = env.getProperty("PAGES_DB")+".";
		preprodcatalogdb = env.getProperty("CATALOG_DB")+".";//always test site catalog db
		catalogdb = env.getProperty("CATALOG_DB")+".";
		if(isprod) 
		{
			portaldb = env.getProperty("PROD_DB") + ".";
			catalogdb = env.getProperty("PROD_CATALOG_DB") + ".";
		}		

		Etn.setSeparateur(2, '\001', '\002');
		
		cacheBaseDir = parseNull(env.getProperty("CACHE_FOLDER")) ;
		
		if(isprod) cacheBaseDir = parseNull(env.getProperty("PROD_CACHE_FOLDER")) ;
		
		if(cacheBaseDir.endsWith("/") == false) cacheBaseDir += "/";
		
		if("false".equalsIgnoreCase(env.getProperty("aloglia_api_use_proxy")) || "0".equals(env.getProperty("aloglia_api_use_proxy"))) useProxy = false;
		
		apiCaller = new ApiCaller(Etn, env, isprod);
	}

	public Algolia(String menuid, ClientSql Etn, Properties env, boolean isprod, boolean debug, String currentMenuPath, String sitedomain) throws Exception
	{
		this.menuid = menuid;
		init(Etn, env, isprod, debug);
		
		Set rsm = Etn.execute("select * from "+portaldb+"site_menus where id ="+escape.cote(menuid));
		rsm.next();
		this.siteid = rsm.value("site_id");
		this.langCode = parseNull(rsm.value("lang")); 

		Set rs = Etn.execute("select * from "+catalogdb+"algolia_settings where site_id = "+escape.cote(this.siteid));
		if(rs.next())
		{
			activated = "1".equals(rs.value("activated"));
			excludeNoIndex = "1".equals(rs.value("exclude_noindex"));			
			if(isprod)
			{
				appId = parseNull(rs.value("application_id")); 
				apiKey = parseNull(rs.value("write_api_key")); 
			}
			else
			{
				appId = parseNull(rs.value("test_application_id")); 
				apiKey = parseNull(rs.value("test_write_api_key")); 
			}
			
			if(activated && (appId.length() == 0 || apiKey.length() == 0))
			{
				logE("Algolia is activated but Application ID or api key is not provided");
				activated = false;
			}
		}
		
		Set rsLang = Etn.execute("select * from language where langue_code = "+escape.cote(langCode));
		rsLang.next();
		langId = rsLang.value("langue_id");
		
		Set rsDefaultIndex = Etn.execute("select * from "+catalogdb+"algolia_default_index where langue_id = "+escape.cote(langId)+" and site_id = "+escape.cote(this.siteid));
		if(rsDefaultIndex.next())
		{
			String defaultIndex = parseNull(rsDefaultIndex.value("index_name"));

			Set rsD = Etn.execute("select * from "+catalogdb+"algolia_indexes where site_id = "+escape.cote(this.siteid) + " and langue_id = "+escape.cote(langId)+" and index_name = "+escape.cote(defaultIndex));
			/*-----------------Added By Awais------------------*/
			if(rsD.next())
			{
				algDefaultIndex = isprod ? rsD.value("algolia_index") : rsD.value("test_algolia_index");
			}
			/*-----------------End------------------*/
		}
		
		if(activated)
		{
			log("--------- Algolia is activated");
			log("--------- ISPROD : "+isprod+" using app id : "+ appId);
		}
		
		if(sitedomain.endsWith("/") == true) sitedomain = sitedomain.substring(0, sitedomain.length() - 1);
		if(currentMenuPath.startsWith("/") == false) currentMenuPath = "/" + currentMenuPath;
		if(currentMenuPath.endsWith("/") == false) currentMenuPath = currentMenuPath + "/";
		this.sitedomain = sitedomain;
		urlprefix = sitedomain + currentMenuPath;
		
		log("Mark all pages for indexation as in-active" );
		//mark all pages as in-active and every page which is crawlable will be marked active again
		if(activated) 
		{
			Etn.executeCmd("delete from "+portaldb+"crawler_indexation where menu_id = "+escape.cote(menuid));			
		}
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	private void log(String m)
	{
		if(!debug) return;		
		logE(m);
	}

	private void logE(String m)
	{
		if(isprod) m = "Prod Algolia::----------------- " + m;
		else m = "Preprod Algolia::----------------- " + m;
		System.out.println(m);
	}
	
	public void setPageInfo(String pageid, org.jsoup.nodes.Document doc)
	{
		try
		{	
			if(activated == false) return;
			if(doIndex(doc))
			{				
				log("setPageInfo::pageid : " + pageid);
				String pageType = getPageType(doc);
				//while crawling we will just add normal page and commercial catalog info into indexation table
				//structured content/page and stores data will be fetched from database and used for indexation
				if(pageType.equals("page") || pageType.equals("product") || pageType.equals("offer") )
				{
					List<String> applicableAlgIdx = getApplicableIndexForCachedPage(pageid, doc);
					if(applicableAlgIdx.size() > 0)
					{
						for(String _aIndex : applicableAlgIdx)
						{			
							if(parseNull(_aIndex).length() == 0) 
							{
								logE("applicable index returned is empty for pageid : " + pageid);
								continue;
							}
							Etn.executeCmd("insert into "+portaldb+"crawler_indexation (ctype, cid, menu_id, applicable_algolia_index) values ("+escape.cote(pageType)+","+escape.cote(pageid)+","+escape.cote(menuid)+", "+escape.cote(_aIndex)+")");
						}
					}					
				}
			}		
		}
		catch(Exception e)
		{
			Etn.executeCmd("insert into "+portaldb+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+","+escape.cote("Algolia::Error setting info for pageid:"+pageid)+") ");
			log("Error while setting page info");
			e.printStackTrace();
		}
	}
	
	private boolean addIndex(String algoliaid, String idx, JSONObject json)
	{
		boolean ret = true;
		try 
		{
			//some tasks take more time so we must keep updating engine status
			Etn.executeCmd("insert into "+commonsdb+"engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
			
			Map<String, String> requestHeaders = new HashMap<>();
			requestHeaders.put("X-Algolia-Application-Id", this.appId);
			requestHeaders.put("X-Algolia-API-Key", this.apiKey);
			
			String algoliaurl = "https://"+this.appId+".algolia.net/1/indexes/"+idx+"/"+algoliaid;
			
			log("Calling callapi");
			JSONObject jResponse = apiCaller.callApi("Algolia.addIndex", algoliaurl, "PUT", json.toString(), requestHeaders, useProxy);
						
			if(jResponse.getInt("http_code") != 200) 
			{
				log("ERROR::addIndex");
				ret = false;			
			}
		} 
		catch(Exception e)
		{
			log("addIndex::error::algoliaid:"+algoliaid+" idx :"+idx);
			e.printStackTrace();
			ret = false;
		}
		finally
		{
		}				
		return ret;
	}
	
	public boolean deleteIndex(String algoliaid, String idx) {
		boolean ret = true;
		try {
			//some tasks take more time so we must keep updating engine status
			Etn.executeCmd("insert into "+commonsdb+"engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
			
			Map<String, String> requestHeaders = new HashMap<>();
			requestHeaders.put("X-Algolia-Application-Id", this.appId);
			requestHeaders.put("X-Algolia-API-Key", this.apiKey);
			
			String algoliaurl = "https://"+this.appId+".algolia.net/1/indexes/"+idx+"/"+algoliaid;
			
			JSONObject jResponse = apiCaller.callApi("Algolia.deleteIndex", algoliaurl, "DELETE", "", requestHeaders, useProxy);
			
			if(jResponse.getInt("http_code") != 200) ret = false;
		} catch(Exception e) {
			log("deleteIndex::error::algoliaid:"+algoliaid+" idx :"+idx);
			e.printStackTrace();
			ret = false;
		}	
		return ret;
	}

	public void startIndexation() { startIndexation(""); }
	
	public void startIndexation(String cid) { startIndexation(cid,""); }

	public void startIndexation(List<String> cids) {
		if(activated == false) {
			log("Algolia not activated. Returning from startIndexation");
			return;
		}
		
		if(cids == null || cids.size() == 0) return;

		try { for(String cid : cids) addIndexes(cid); }
		catch(Exception e) { e.printStackTrace(); }
	}
	
	public void startIndexation(String cid, String ruleType) {
		if(activated == false) {
			log("Algolia not activated. Returning from startIndexation");
			return;
		}

		int auditid = 0;
		try {
			String additionalConditions="";
			if(parseNull(cid).length() == 0 && parseNull(ruleType).length() == 0) {
				auditid = Etn.executeCmd("insert into "+portaldb+"crawler_audit (menu_id, start_time, status, action) values ("+
					escape.cote(menuid)+",now(),1, 'Updating Algolia') ");
			}
			String pageQuery ="";

			if(parseNull(ruleType).equalsIgnoreCase("forum")) {
				pageQuery = "select post_id as uuid,type as _type,category as url,content as tags,forum_topic as name,'' as template_id, '' as catalog_type from "+
					this.portaldb+"client_reviews where type='forum' and site_id = "+escape.cote(this.siteid)+" and post_id="+escape.cote(cid);

			} else if(parseNull(ruleType).equalsIgnoreCase("marketing_rules")) {
				pageQuery = "select p.lang_"+langId+"_name as name,'' as url,'commercialcatalog'as _type,p.id as uuid,'' as tags,'' as template_id,c.catalog_type from "+
				this.catalogdb+"products p left join "+this.catalogdb+"catalogs c on p.catalog_id=c.id where c.site_id="+escape.cote(this.siteid)+" and p.id="+escape.cote(cid);
				//marketing rules published so we have to find the applicable index on product id passed in cid
			} else if(parseNull(ruleType).equalsIgnoreCase("new_product")) {
				pageQuery = "select sc.name,'' as url, 'new_product' as _type, sc.uuid,'' as tags,'' as template_id,ptv.id as catalog_type from "+pagesdb+
				"structured_contents sc left join "+pagesdb+"products_map_pages pmp on pmp.page_id=sc.id left join "+this.catalogdb+
				"products p on p.id=pmp.product_id left join "+this.catalogdb+"products_definition pd on pd.id=p.product_definition_id left join "+this.catalogdb+
				"product_types_v2 ptv on ptv.id=pd.product_type where sc.uuid="+escape.cote(cid);
			} else {				
				//we do not want this to be run every time an individual item is cached in which case ruleType is always passed
				if(cid.length()>0) additionalConditions = " and c.uuid="+escape.cote(cid);

				pageQuery = "select c.uuid, c.name, u.page_path as url, c.template_id, case when coalesce(b.type,'') = 'store' then 'store' "+
				"when c.type = 'content' then 'structuredcontent' else 'structuredpage' end _type, group_concat(ct.label) as tags "+
				", '' as catalog_type from "+pagesdb+"structured_contents_published c "+
				" inner join "+pagesdb+"structured_contents_details_published d on d.content_id = c.id and d.langue_id = "+escape.cote(langId)+
				" inner join "+pagesdb+"bloc_templates b on b.id = c.template_id "+
				" left outer join "+pagesdb+"pages p on p.id = d.page_id "+
				" left outer join "+pagesdb+"pages_tags pt on pt.page_type = p.type and pt.page_id = case when p.type = 'react' then p.id else p.parent_page_id end "+
				" left outer join "+this.catalogdb+"tags ct on pt.tag_id = ct.id and ct.site_id = "+escape.cote(this.siteid)+
				" left outer join "+commonsdb+"content_urls u on u.content_type = 'page' and u.content_id = p.id "+
				" where c.site_id = "+escape.cote(this.siteid)+additionalConditions+" group by c.uuid ";
			}

			if(parseNull(pageQuery).length() > 0) {
				//first get all the structured content/pages/stores and add to crawler_indexation table as these are dynamic data which is not available at time of crawling
				Set rsP = Etn.execute(pageQuery);
				while(rsP.next()) {
					String pname = parseNull(rsP.value("name"));
					String purl = parseNull(rsP.value("url"));
					String ptype = parseNull(rsP.value("_type"));
					String pid = parseNull(rsP.value("uuid"));
					String ptags = parseNull(rsP.value("tags"));
					String templateId = parseNull(rsP.value("template_id"));
					String catalogType = parseNull(rsP.value("catalog_type"));
					List<String> applicableIdx = getApplicableIndex(ptype, ptags, purl, pname, catalogType, templateId);
					if(applicableIdx.size() > 0) {
						if(parseNull(ruleType).equals("marketing_rules")) {
							//marketing rule is applicable on product and offer only
							if(catalogType.equalsIgnoreCase("offer")) ptype = catalogType;
							else ptype = "product";

							Set rsCachePage = Etn.execute("select cached_page_id from "+portaldb+"cached_content_view where content_id="+escape.cote(cid)+
								" and site_id="+escape.cote(this.siteid)+" and menu_id="+escape.cote(this.menuid)+" and content_type="+escape.cote(ptype));
							if(rsCachePage.next()) {
								pid=parseNull(rsCachePage.value("cached_page_id"));
								cid=pid;
							}
						}

						for(String _aIndex : applicableIdx) {
							Etn.executeCmd("insert into "+portaldb+"crawler_indexation (menu_id, ctype, cid, applicable_algolia_index) values ("+escape.cote(this.menuid)+", "+escape.cote(ptype)+", "+escape.cote(pid)+", "+escape.cote(_aIndex)+")");
						}
					}
				}
			}
			addIndexes(cid);
			//now delete the in active indexes from algolia
			Set rs = Etn.execute("select * from "+portaldb+"algolia_indexation where is_active = 0 and menu_id = "+escape.cote(menuid));
			while(rs.next()) {
				//make call to algolia to delete this index
				//on success delete from db
				boolean deleted = false;
				if(parseNull(rs.value("variant_id")).length()>0) {
					log("delete index::ctype:"+rs.value("ctype")+ " variant_id:"+rs.value("variant_id")+" idx:"+rs.value("algolia_index"));
					deleted = deleteIndex(rs.value("variant_id"), rs.value("algolia_index"));
				} else {
					log("delete index::ctype:"+rs.value("ctype")+ " cid:"+rs.value("cid")+" idx:"+rs.value("algolia_index"));
					deleted = deleteIndex(rs.value("cid"), rs.value("algolia_index"));
				}

				if(deleted) {
					Etn.executeCmd("insert into "+portaldb+"algolia_indexation_history (menu_id, ctype, cid, algolia_index, algolia_json, is_active, variant_id) " +
								" select menu_id, ctype, cid, algolia_index, algolia_json, is_active, variant_id from "+portaldb+"algolia_indexation where id = "+rs.value("id"));
					Etn.executeCmd("delete from "+portaldb+"algolia_indexation where id = "+rs.value("id"));
				}
			}
			log("Indexation completed");
		} catch(Exception e) {
			Etn.executeCmd("insert into "+portaldb+"crawler_errors (menu_id, err) values("+escape.cote(menuid)+",'Algolia::Error updating indexes') ");
			e.printStackTrace();
		} finally {
            try {                
				Etn.executeCmd("update "+portaldb+"crawler_audit set end_time = now(), status = 2 where id = " + auditid); 
            } catch(Exception e) {}			
		}
	}
	
	public void deleteIndividualIndex(String cachedPageId) {
		try {
			log("In deleteIndividualIndex cachedPageId : "+cachedPageId);
			Set rs = Etn.execute("select * from "+portaldb+"algolia_indexation where cid = "+escape.cote(cachedPageId));
			while(rs.next()) {
				//lets mark it as in_active just in case due to any reason aloglia call failed, then in next site crawling this index will be removed as its marked in-active
				Etn.executeCmd("update "+portaldb+"algolia_indexation set is_active = 0 where id = "+rs.value("id"));
				//make call to algolia to delete this index
				//on success delete from db
				boolean deleted = false;
				if(parseNull(rs.value("variant_id")).length()>0) {
					log("delete index::ctype:"+rs.value("ctype")+ " variant_id:"+rs.value("variant_id")+" idx:"+rs.value("algolia_index"));
					deleted = deleteIndex(rs.value("variant_id"), rs.value("algolia_index"));
				} else {
					log("delete index::ctype:"+rs.value("ctype")+ " cid:"+rs.value("cid")+" idx:"+rs.value("algolia_index"));
					deleted = deleteIndex(rs.value("cid"), rs.value("algolia_index"));
				}
				if(deleted) Etn.executeCmd("delete from "+portaldb+"algolia_indexation where id = "+rs.value("id"));
			}			
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	private void addIndexes(String cid) throws Exception {
		log("In addIndexes menu id : "+menuid);
		//update all previous indexes as inactive
		//for structured pages/content/stores we have uuid in this cid 
		//else its the ID of cached page in algolia_indexation table
		String additionalConditions = "";
		if(parseNull(cid).length() > 0) {
			log("cid : " + parseNull(cid));
			additionalConditions = " and cid = "+escape.cote(cid);
		}

		log("update "+portaldb+"algolia_indexation set is_active = 0 where menu_id = "+escape.cote(menuid)+additionalConditions);
		Etn.executeCmd("update "+portaldb+"algolia_indexation set is_active = 0 where menu_id = "+escape.cote(menuid)+additionalConditions);
		log("Add/Update/delete indexation");
		List<String> successIds = new ArrayList<String>();
		
		log("select * from "+portaldb+"crawler_indexation where menu_id = "+escape.cote(menuid)+additionalConditions+ " order by ctype, cid ");	
		Set rs = Etn.execute("select * from "+portaldb+"crawler_indexation where menu_id = "+escape.cote(menuid)+additionalConditions+ " order by ctype, cid ");	
		while(rs.next()) {
			log("add index::ctype:"+rs.value("ctype")+ " cid:"+rs.value("cid")+" idx:"+rs.value("applicable_algolia_index"));				
			//call api				
			org.jsoup.nodes.Document doc = null;
			if(!rs.value("ctype").equals("structuredpage") && !rs.value("ctype").equals("structuredcontent") && !rs.value("ctype").equals("store") 
			&& !rs.value("ctype").equals("forum") && !rs.value("ctype").equals("new_product") ) {
				doc = getCachedPageDocument(rs.value("cid")); //cached document is only possible for products/offers/pages/forms
			}

			Object response = getJson(rs.value("ctype"), rs.value("cid"), rs.value("applicable_algolia_index"), doc);
			if (response instanceof JSONObject) verifyJsonAddIndex((JSONObject) response,rs);
			else if (response instanceof JSONArray) {
				JSONArray jsonArray = (JSONArray) response;
				for (int i =0 ;i<jsonArray.length();i++) {
					verifyJsonAddIndex((JSONObject) jsonArray.getJSONObject(i),rs);
				}
			} else log("Unexpected response type");
		}
	}

	private void verifyJsonAddIndex(JSONObject json, Set rs) throws Exception{
		if(json == null) json = new JSONObject();	//not possible case but we must handle
		log("in verifyJsonAddIndex");
		boolean isJsonSame = false;
		//lets compare if there is no change in the json then dont send to algolia again and save time
		Set _rsT = Etn.execute("select algolia_json from "+portaldb+"algolia_indexation where menu_id = "+escape.cote(rs.value("menu_id"))+" and ctype = "+escape.cote(rs.value("ctype"))+" and cid = "+escape.cote(rs.value("cid"))+" and algolia_index = "+escape.cote(rs.value("applicable_algolia_index")));
		if(_rsT.next() && json.toString().equals(_rsT.value("algolia_json"))) isJsonSame = true;

		if(isJsonSame) {
			log("index json is same .. not sending to algolia again");  //mark it as active
			Etn.executeCmd("update "+portaldb+"algolia_indexation set is_active = 1 where menu_id = "+escape.cote(rs.value("menu_id"))+" and ctype = "+escape.cote(rs.value("ctype"))+" and cid = "+escape.cote(rs.value("cid"))+" and algolia_index = "+escape.cote(rs.value("applicable_algolia_index"))+"");
		} else {
			boolean added=false;
			if(json.has("objectID")) added = addIndex(json.getString("objectID"), rs.value("applicable_algolia_index"), json);
			else added = addIndex(rs.value("cid"), rs.value("applicable_algolia_index"), json);
			if(added) {
				//weird case where unique key is not working in OMG for this table.
				//we are going to check uniqueness in the code
				String qry = "select id from "+portaldb+"algolia_indexation "+
							" where menu_id = "+escape.cote(rs.value("menu_id"))+" and ctype = "+escape.cote(rs.value("ctype"))+
							" and cid = "+escape.cote(rs.value("cid"))+" and algolia_index = "+escape.cote(rs.value("applicable_algolia_index"));
				
				if(json.has("objectID")) qry+=" and variant_id = "+escape.cote(parseNull(json.getString("objectID")));
				log("Check record already exists : "+qry);
				
				Set _rs = Etn.execute(qry);
				log("rec found : " +_rs.rs.Rows);
				if(_rs.next()) {
					log("update "+portaldb+"algolia_indexation set is_active = 1, algolia_json = "+escapeCote3(json.toString())+" where id = "+escape.cote(_rs.value("id")));
					int klm = Etn.executeCmd("update "+portaldb+"algolia_indexation set is_active = 1,is_failed=0, algolia_json = "+escapeCote3(json.toString())+" where id = "+
						escape.cote(_rs.value("id")));
					log("row id changed : "+klm);
				} else {					
					String insertQuery ="insert into "+portaldb+"algolia_indexation (menu_id,ctype,cid,algolia_index,algolia_json";
					if(json.has("objectID")) insertQuery+=",variant_id";

					insertQuery+=") values ("+escape.cote(rs.value("menu_id"))+","+escape.cote(rs.value("ctype"))+","+escape.cote(rs.value("cid"))+","+
						escape.cote(rs.value("applicable_algolia_index"))+","+escapeCote3(json.toString());

					if(json.has("objectID")) insertQuery+=","+escape.cote(parseNull(json.getString("objectID")));
					insertQuery+=") ";

					log(insertQuery);
					int klm = Etn.executeCmd(insertQuery);
					log("rows inserted : "+klm);
					Set _rs21 = Etn.execute(qry);
				}
			} else {
				//in case its not added we still check and mark is_active to 1 because this index could be an old one added due to any previous 
				//crawling. If we dont mark it as active, it will be deleted and that could be an issue .. so to be on safe side
				//if there is any issue in calling api we will still mark the previously added indexation rows to active so that they can be retreated same way 
				//in next crawling ... in ideal situation there should not be an issue in the api call
				//here as the api call is failed we will not update the algolia_json column
				int klm = Etn.executeCmd("update "+portaldb+"algolia_indexation set is_active = 1, is_failed=1 where menu_id = "+escape.cote(rs.value("menu_id"))+" and ctype = "+escape.cote(rs.value("ctype"))+" and cid = "+escape.cote(rs.value("cid"))+" and algolia_index = "+escape.cote(rs.value("applicable_algolia_index"))+"");
				log("rows changed : "+klm);
			}
			addFailedIndexes();
		}
	}

	public void addFailedIndexes() {
		Set rsAlgolia = Etn.execute("select * from "+portaldb+"algolia_indexation where is_failed=1");
		log("Failed index found================="+rsAlgolia.rs.Rows);
		while(rsAlgolia.next()){
			if(parseNull(rsAlgolia.value("algolia_json")).length() > 0){
				try{
					boolean added = false;
					JSONObject json = new JSONObject(parseNull(rsAlgolia.value("algolia_json")));
					if(json.has("objectID")){
						added = addIndex(json.getString("objectID"), rsAlgolia.value("algolia_index"), json);
					}else{
						added = addIndex(rsAlgolia.value("cid"), rsAlgolia.value("algolia_index"), json);
					}

					if(added){
						Etn.executeCmd("update "+portaldb+"algolia_indexation set is_failed=0 where menu_id = "+escape.cote(rsAlgolia.value("menu_id"))+
							" and ctype = "+escape.cote(rsAlgolia.value("ctype"))+" and cid = "+escape.cote(rsAlgolia.value("cid"))+" and algolia_index = "+
							escape.cote(rsAlgolia.value("algolia_index")));
					}
				}catch(Exception e){
					e.printStackTrace();
				}
			}else{
				String ruleType = "";
				if(rsAlgolia.value("ctype").equals("commercialcatalog")){
					ruleType = "marketing_rules";
				}else if(rsAlgolia.value("ctype").equals("forum") ||rsAlgolia.value("ctype").equals("offer") || rsAlgolia.value("ctype").equals("product") || rsAlgolia.value("ctype").equals("productv2")){
					ruleType = rsAlgolia.value("ctype");
				}
				startIndexation(rsAlgolia.value("cid"), ruleType);
			}
		}
	}
	
	private boolean doIndex(org.jsoup.nodes.Document doc)
	{
		org.jsoup.select.Elements eles = doc.select("meta[name=etn:eletype]");
		if(eles == null || eles.size() == 0) return false;
		
		if(this.excludeNoIndex)
		{
			eles = doc.select("meta[name=robots]");
			if(eles != null && eles.size() > 0)
			{
				String val = parseNull(eles.first().attr("content"));
				if(val.toLowerCase().contains("noindex")) return false;
			}		
		}
		return true;
	}
	
	private String getPageType(org.jsoup.nodes.Document doc)
	{
		org.jsoup.select.Elements eles = doc.select("meta[name=etn:eletype]");		
		String eletype = parseNull(eles.first().attr("content"));				
		
		if("commercialcatalog".equals(eletype)) 
		{
			String catalogtype = "";
			eles = doc.select("meta[name=etn:ctype]");
			if(eles != null && eles.size() > 0) catalogtype = parseNull(eles.first().attr("content"));
			
			if("offer".equals(catalogtype)) return "offer";
			else return "product";
		}
		
		return eletype;
		
	}
	private List<String> getApplicableIndexForCachedPage(String pageid, org.jsoup.nodes.Document doc)
	{
		log("getApplicableIndexForCachedPage::Page id : "+pageid);
		org.jsoup.select.Elements eles = doc.select("meta[name=etn:eletype]");
		
		String eletype = parseNull(eles.first().attr("content"));
		
		String eletags = "";
		eles = doc.select("meta[name=etn:eletaglabel]");
		if(eles != null && eles.size() > 0) eletags = parseNull(eles.first().attr("content"));

		String eleurl = "";
		eles = doc.select("meta[name=etn:eleurl]");
		if(eles != null && eles.size() > 0) eleurl = parseNull(eles.first().attr("content"));

		String elename = "";
		if("commercialcatalog".equals(eletype)) eles = doc.select("meta[name=etn:pname]");
		else eles = doc.select("meta[name=etn:elename]");
		if(eles != null && eles.size() > 0) elename = parseNull(eles.first().attr("content"));
		
		String catalogtype = "";
		if("commercialcatalog".equals(eletype)) 
		{
			eles = doc.select("meta[name=etn:ctype]");
			if(eles != null && eles.size() > 0) catalogtype = parseNull(eles.first().attr("content"));
		}
		return getApplicableIndex(eletype, eletags, eleurl, elename, catalogtype, "");
	}
	
	private List<String> getApplicableIndex(String eletype, String eletags, String eleurl, String elename, String catalogtype, String blocTemplateId) {
		List<String> indexes = new ArrayList<String>();
		/*-----------------Changed By Awais------------------*/
		String algoliaIndexField = isprod ? "i.algolia_index" : "i.test_algolia_index as algolia_index";
		String query = "SELECT r.*, " + algoliaIndexField + " FROM " + catalogdb + "algolia_rules r, " + catalogdb + "algolia_indexes i WHERE r.langue_id = i.langue_id AND r.langue_id = " + escape.cote(langId) + " AND r.rule_type = " + escape.cote(eletype) + " AND i.site_id = " + escape.cote(this.siteid) + " AND i.site_id = r.site_id AND r.index_name = i.index_name ORDER BY r.order_seq";
		Set rs = Etn.execute(query);
		/*-----------------End------------------*/
		
		while(rs.next()) {
			String criteria = parseNull(rs.value("rule_criteria"));

			if("name_contains".equals(criteria) && elename.toLowerCase().contains(parseNull(rs.value("rule_value")).toLowerCase())) {
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			} else if("name_is".equals(criteria) && elename.toLowerCase().equals(parseNull(rs.value("rule_value")).toLowerCase())) {
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			} else if("topic_contains".equals(criteria) && elename.toLowerCase().contains(parseNull(rs.value("rule_value")).toLowerCase())) {
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			} else if("topic_is".equals(criteria) && elename.toLowerCase().equals(parseNull(rs.value("rule_value")).toLowerCase())) {
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			} else if("category_contains".equals(criteria) && eleurl.toLowerCase().contains(parseNull(rs.value("rule_value")).toLowerCase())) {
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			} else if("category_is".equals(criteria) && eleurl.toLowerCase().equals(parseNull(rs.value("rule_value")).toLowerCase())) {
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			} else if("tag".equals(criteria) && eletags.toLowerCase().contains(parseNull(rs.value("rule_value")).toLowerCase())) {
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			} else if("url".equals(criteria) && eleurl.toLowerCase().contains(parseNull(rs.value("rule_value")).toLowerCase())) {
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			} else if("commercialcatalog".equals(eletype) && "type".equals(criteria) && catalogtype.toLowerCase().equals(parseNull(rs.value("rule_value")).toLowerCase())) {
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			}else if("new_product".equals(eletype) && "type".equals(criteria) && catalogtype.toLowerCase().equals(parseNull(rs.value("rule_value")).toLowerCase())) {
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			} else if(("store".equals(eletype) || "structuredcontent".equals(eletype) || "structuredpage".equals(eletype)) 
				&& "type".equals(criteria) && blocTemplateId.equals(parseNull(rs.value("rule_value"))))
			{
				if(indexes.contains(parseNull(rs.value("algolia_index"))) == false) indexes.add(parseNull(rs.value("algolia_index")));
				
				if("1".equals(parseNull(rs.value("exclude_from_default"))) == false) {
					if(indexes.contains(this.algDefaultIndex) == false) indexes.add(this.algDefaultIndex);
				}
			}
		}
		//just to make sure we dont get empty index value from rules then we return default index
		if(indexes.isEmpty()) indexes.add(this.algDefaultIndex);
		log("getApplicableIndex::eletype:"+eletype+" elename:"+elename+" catalogtype:"+catalogtype + " index:"+String.join(", ", indexes));
		return indexes;
	}
	
	private Object getJson(String ctype, String cid, String idx, org.jsoup.nodes.Document doc) {
		Object json = null;
		try {
			log("getJson::langid : "+this.langId+" ctype : "+ ctype + " cid : " + cid + " idx : " + idx);
			String indexType = "basic";
           /*-----------------Changed By Awais------------------*/
			String algoIndex = isprod ? "algolia_index" : "test_algolia_index";
			Set rsI = Etn.execute("select * from "+catalogdb+"algolia_indexes where langue_id = "+escape.cote(this.langId)+" and site_id = "+escape.cote(this.siteid)+
				" and "+algoIndex+" = "+escape.cote(idx));
           /*-----------------End------------------*/
			if(rsI.next()) indexType = parseNull(rsI.value("index_type"));
			log("getJson::index type:"+indexType);
			
			if(indexType.equals("products")) json = getProductTypeJson(ctype, cid, doc);
			else if(indexType.equals("offers")) json = getOfferTypeJson(ctype, cid, doc);
			else if(indexType.equals("stores")) json = getStoreJson(ctype, cid, doc);
			else if(indexType.equals("customized")) json = getCustomizedJson(ctype, cid, doc);
			else if(indexType.equals("forums")) json = getForumJson(ctype, cid, doc);
			else if(indexType.equals("productv2")) json = getProductVariants(ctype, cid,doc);
			else if(indexType.equals("productv3")) json = getNewProductJson(ctype, cid,doc);
			else json = getBasicTypeJson(ctype, cid, doc); //basic
		} catch(Exception e) {
			e.printStackTrace();
		}
		return json;
	}
	
	private String getDynamicElements(String ctype, String cid) { return ""; }
	
	private org.jsoup.nodes.Document getCachedPageDocument(String cid) throws Exception {
		org.jsoup.nodes.Document doc = null;
		Set rs = Etn.execute("select concat(coalesce(cp.file_path,''), coalesce(c.filename,'')) as file_path from "+portaldb+"cached_pages_path cp, "+
			portaldb+"cached_pages c where c.id = cp.id and cp.id = "+escape.cote(cid));
		if(rs.next()) {
			String path = cacheBaseDir + rs.value("file_path");
			log("getCachedPageDocument::cid:"+cid+" path:"+path);
			doc = Jsoup.parse(new File(path), "UTF-8", sitedomain);
		} else log("ERROR::Unable to find cached page path for cached id : "+cid);
		return doc;
	}
	
	private JSONObject getStoreJson(String ctype, String cid, org.jsoup.nodes.Document doc) throws Exception {
		JSONObject json = null;
		if(ctype.equals("store") ) {
			Map<String, String> map = getDynamicContentMetaInfo(ctype, cid);
			JSONObject dynamicDataToIndex = callInternalPagesApi(cid);
			json = new JSONObject();
			json.put("obj_type", ctype);
			String url = "";
			if(parseNull(map.get("eleurl")).length() > 0) url = urlprefix + parseNull(map.get("eleurl"));
			
			json.put("URL", url);
			
			if(dynamicDataToIndex.has("extra_informations")){
				JSONObject extraInformations = dynamicDataToIndex.getJSONObject("extra_informations");
				if(extraInformations!=null && extraInformations.has("eshopenvtype")) json.put("eshopEnvType", parseNull(extraInformations.getString("eshopenvtype")));
			}

			if(!json.has("eshopEnvType")) json.put("eshopEnvType", "");

			JSONObject globalInfo = dynamicDataToIndex.getJSONObject("global_information");
			JSONObject storeSection = globalInfo.getJSONObject("store_section");

			json.put("Location name", parseNull(storeSection.optString("location_name")));
			json.put("Address 1", parseNull(storeSection.optString("address")));
			json.put("City", parseNull(storeSection.optString("city")));
			json.put("Phone", parseNull(storeSection.optString("phone")));
			json.put("contact", parseNull(storeSection.optString("contact")));
			json.put("appointment", parseNull(storeSection.optString("appointment")));
			json.put("take_a_ticket", parseNull(storeSection.optString("take_a_ticket")));
			json.put("Status", parseNull(storeSection.optString("status")));
			json.put("Postal Code", parseNull(storeSection.optString("postal_code")));

			JSONArray customButtons = storeSection.optJSONArray("custom_buttons");
			if(customButtons!=null){
				for (int i = 0; i < customButtons.length(); i++) {
					JSONObject jsonObject = customButtons.getJSONObject(i);
					jsonObject.remove("button_icon_alt");
				}
				json.put("custom_buttons", customButtons);
			}

			if(storeSection.has("further_information") && storeSection.getJSONArray("further_information").length() > 0){
				JSONArray returnAry = new JSONArray();
				JSONArray furtherInfoStoreAry = storeSection.getJSONArray("further_information");
				for(int i=0;i<furtherInfoStoreAry.length();i++) {
					JSONObject infoObj = furtherInfoStoreAry.getJSONObject(i);
					infoObj.remove("icon_alt");
				}
				json.put("further_information",furtherInfoStoreAry);
			}
			
			JSONObject geoLoc = new JSONObject();
			String lat = parseNull(storeSection.optString("latitude"));
			String lng = parseNull(storeSection.optString("longitude"));
			if(lat.length() > 0 && lng.length() > 0) {
				double dLat = 0;
				double dLng = 0;
				try{
					dLat = Double.parseDouble(lat);
				} catch(Exception e) {}

				try{
					dLng = Double.parseDouble(lng);
				} catch(Exception e) {}
				geoLoc.put("lat", dLat);
				geoLoc.put("lng", dLng);				
				json.put("_geoloc", geoLoc);
			}
			
			List<String> days = new ArrayList<String>();
			days.add("sunday");
			days.add("monday");
			days.add("tuesday");
			days.add("wednesday");
			days.add("thursday");
			days.add("friday");
			days.add("saturday");
			
			JSONObject jDays = new JSONObject();
			json.put("horaires", jDays);
			
			if(dynamicDataToIndex.has("timetable_section") == true) {
				JSONObject timetableSection = dynamicDataToIndex.getJSONObject("timetable_section");
				json.put("timezone", parseNull(timetableSection.optString("timezone")));
				for(String day : days) {	
					JSONArray jDay = new JSONArray();
					jDays.put(day, jDay);

					if(timetableSection.has(day) == false) continue;
					
					JSONObject currDay = timetableSection.getJSONObject(day);		
					if(currDay.has("schedules") == false) continue;
					
					JSONArray schedules = currDay.getJSONArray("schedules");
					for(int i=0; i<schedules.length(); i++) {					
						String startTime = parseNull(schedules.getJSONObject(i).optString("start"));
						String endTime = parseNull(schedules.getJSONObject(i).optString("end"));
						
						if(startTime.length() > 0 || endTime.length() > 0) {
							JSONArray jTime = new JSONArray();
							jTime.put(startTime);
							jTime.put(endTime);
							
							jDay.put(jTime);
						}
					}
				}
			}
			
			JSONArray jServices = new JSONArray();
			json.put("Services", jServices);
			if(globalInfo.has("services_section") == true && globalInfo.getJSONObject("services_section").has("services") == true)
			{
				JSONArray services = globalInfo.getJSONObject("services_section").getJSONArray("services");			
				for(int i=0; i < services.length(); i++)
				{
					String service = parseNull(services.getJSONObject(i).optString("title"));
					if(service.length() > 0) jServices.put(service);
				}
			}
			
			JSONObject jSpecialHours = new JSONObject();
			json.put("special_hours", jSpecialHours);			
			if(dynamicDataToIndex.has("special_hours_section") == true && dynamicDataToIndex.getJSONObject("special_hours_section").has("special_hours") == true)				
			{
				JSONArray specialHours = dynamicDataToIndex.getJSONObject("special_hours_section").getJSONArray("special_hours");
				for(int i=0; i < specialHours.length(); i++)
				{
					String startDate = parseNull(specialHours.getJSONObject(i).optString("start_date"));
					String endDate = parseNull(specialHours.getJSONObject(i).optString("end_date"));
					if(startDate.length() > 0 || endDate.length() > 0)
					{
						String message = parseNull(specialHours.getJSONObject(i).optString("message"));
						
						JSONObject jSpecialHour = new JSONObject();
						jSpecialHour.put("start_date", startDate);
						jSpecialHour.put("end_date", endDate);
						jSpecialHour.put("message", message);
						
						JSONArray jOpeningHours = new JSONArray();
						jSpecialHour.put("opening_hours", jOpeningHours);
						
						if(specialHours.getJSONObject(i).has("opening_hours") == true)
						{
							JSONArray openHours = specialHours.getJSONObject(i).getJSONArray("opening_hours");
							for(int j=0; j<openHours.length(); j++)
							{
								JSONObject openHour = openHours.getJSONObject(j);
								String startTime = parseNull(openHour.optString("start"));
								String endTime = parseNull(openHour.optString("end"));
								if(startTime.length() > 0 || endTime.length() > 0)
								{
									JSONArray jOpenTime = new JSONArray();
									jOpenTime.put(startTime);
									jOpenTime.put(endTime);
									jOpeningHours.put(jOpenTime);
								}
							}
						}
						
						jSpecialHours.put(""+i, jSpecialHour);						
					}
				}
			}
			
			//---------- customized fields ---------------
			//remove the default sections for store bloc
			//if any section is left means it has some new indexed field which is not part of fixed store json for algolia and will be treated as customized field
			dynamicDataToIndex.remove("special_hours_section");
			dynamicDataToIndex.remove("reviews_section");
			dynamicDataToIndex.remove("timetable_section");
			dynamicDataToIndex.remove("global_information");

			//for any extra fields to be indexed and added outside the pre-defined sections of store
			//in-coming data from pages api is in structural form and we need in linear form
			dynamicDataToIndex = getFieldsLinearJSON(dynamicDataToIndex);
			Iterator<String> keys = dynamicDataToIndex.keys();
			while(keys.hasNext())
			{
				String key = keys.next();
				json.put(key, dynamicDataToIndex.get(key));
			}
			//---------- customized fields ---------------
			
			Set rsTags = Etn.execute("select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+pagesdb+"pages_tags where page_id= (select id from "+pagesdb+"structured_contents_published where uuid="+
				escape.cote(cid)+") and page_type='structured') and site_id="+escape.cote(this.siteid));
			while(rsTags.next()){
				json.put(parseNull(rsTags.value("label")),true);
			}

			JSONObject folderInfo =  getFoldersHerarchy(cid,"store");
			if(folderInfo.length() > 0){
				for(String key : JSONObject.getNames(folderInfo))
				{
					json.put(key, folderInfo.get(key));
				}
			}
		}
		else if(ctype.equals("structuredpage") || ctype.equals("structuredcontent") )
		{
			Map<String, String> map = getDynamicContentMetaInfo(ctype, cid);
			
			String url = "";
			if(parseNull(map.get("eleurl")).length() > 0)
			{
				url = urlprefix + parseNull(map.get("eleurl"));
			}
			
			json = getEmptyStoreJson(ctype, url);
		}
		else
		{
			if(doc != null) 
			{				
				Map<String, String> map = getMetaInfo(doc);

				String otype = "page";
				if("commercialcatalog".equals(map.get("eletype")) && "offer".equals(map.get("catalogtype"))) otype = "offer";
				else if("commercialcatalog".equals(map.get("eletype"))) otype = "product";
				
				json = getEmptyStoreJson(otype, urlprefix + map.get("eleurl"));				
			}
		}
		return json;
	}
	
	private JSONObject getEmptyStoreJson(String otype, String url) throws Exception
	{
		JSONObject json = new JSONObject();
		json.put("obj_type", otype);
		json.put("URL", url);
		json.put("Location name", "");
		json.put("Address 1", "");
		json.put("City", "");
		json.put("Phone", "");
		json.put("contact", "");
		json.put("appointment", "");
		json.put("take_a_ticket", "");
		json.put("Status", "");
		json.put("Postal Code", "");
		
		JSONObject geoLoc = new JSONObject();
		geoLoc.put("lat", 0);
		geoLoc.put("lng", 0);				
		json.put("_geoloc", geoLoc);
		
		List<String> days = new ArrayList<String>();
		days.add("sunday");
		days.add("monday");
		days.add("tuesday");
		days.add("wednesday");
		days.add("thursday");
		days.add("friday");
		days.add("saturday");
		
		JSONObject jDays = new JSONObject();
		json.put("horaires", jDays);
		
		for(String day : days)
		{	
			JSONArray jDay = new JSONArray();
			jDays.put(day, jDay);
		}
		
		JSONArray jServices = new JSONArray();
		json.put("Services", jServices);
		
		JSONObject jSpecialHours = new JSONObject();
		json.put("special_hours", jSpecialHours);			

		return json;
	}
	private JSONObject getForumJson(String ctype, String cid, org.jsoup.nodes.Document doc) throws Exception
	{
		JSONObject json = new JSONObject();
		if(ctype.contains("forum")){

			Set rs =Etn.execute("select cr.post_id as fid,cr.content,cr.category,cr.created_dt,cr.forum_topic,c.name as author_name,'' as avatar from "+portaldb+"client_reviews cr left join "+portaldb+"clients c on cr.client_id = c.client_uuid where cr.post_id="+escape.cote(cid));
			if(rs.next()) {
				for(String colName:rs.ColName){
					json.put(colName.toLowerCase(),parseNull(rs.value(colName)));
				}
				json.put("metadescription", parseNull(rs.value("content")));
			}
			
			rs =Etn.execute("select * from "+portaldb+"client_reviews where source_id="+escape.cote(cid));
			json.put("nb_answers",rs.rs.Rows);
			
			rs =Etn.execute("select * from "+portaldb+"client_reviews where client_id=(select client_id from "+portaldb+"client_reviews post_id="+
				escape.cote(cid)+") and type='comment' and is_deleted=0");
			json.put("total_nb_comments",rs.rs.Rows);
			
			Set rsTags = Etn.execute("select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+env.getProperty("PORTAL_DB")+
				".client_review_tags where post_id="+escape.cote(cid)+") and site_id="+escape.cote(this.siteid));
			while(rsTags.next()){
				json.put(parseNull(rsTags.value("label")),true);
			}
		}else{
			json.put("fid","");
			json.put("content","");
            json.put("metadescription", "");
			json.put("category","");
			json.put("created_dt","");
			json.put("forum_topic","");
			json.put("author_name","");
			json.put("avatar","");
			json.put("nb_answers",0);
			json.put("total_nb_comments",0);
		}
			
		return json;
	}
	
	private JSONObject getCustomizedJson(String ctype, String cid, org.jsoup.nodes.Document doc) throws Exception
	{
		JSONObject json = null;
		String query="";
		if(ctype.equals("structuredpage") || ctype.equals("structuredcontent"))
		{
			Map<String, String> map = getDynamicContentMetaInfo(ctype, cid);
			JSONObject dynamicDataToIndex = callInternalPagesApi(cid);
			
			json = new JSONObject();
			json.put("obj_type", ctype);
			json.put("title", parseNull(map.get("elename")));
			json.put("content", parseNull(map.get("descr")));
			String url = "";
			if(parseNull(map.get("eleurl")).length() > 0)
			{
				url = urlprefix + parseNull(map.get("eleurl"));
			}
			
			json.put("URL", url);
			json.put("uuid", getItemUUID(ctype, cid, map));
			
			String _pageUuid = parseNull(getAssociatedPageUUID(ctype, cid));
			if(_pageUuid.length() > 0) json.put("page_uuid", _pageUuid);
			
			if(dynamicDataToIndex != null)
			{
				//in-coming data from pages api is in structural form and we need in linear form
				dynamicDataToIndex = getFieldsLinearJSON(dynamicDataToIndex);
				Iterator<String> keys = dynamicDataToIndex.keys();
				while(keys.hasNext())
				{
					String key = keys.next();
					json.put(key, dynamicDataToIndex.get(key));
				}
			}

			query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+pagesdb+"pages_tags where page_type='structured' and page_id=(select id from "+pagesdb+"structured_contents_published where uuid="+
				escape.cote(cid)+")) and site_id="+escape.cote(this.siteid);

			JSONObject folderInfo = getFoldersHerarchy(cid,"store");
			if(folderInfo.length() > 0){
				for(String key : JSONObject.getNames(folderInfo))
				{
					json.put(key, folderInfo.get(key));
				}
			}
		}
		else if(ctype.equals("store"))
		{
			Map<String, String> map = getDynamicContentMetaInfo(ctype, cid);
			
			json = new JSONObject();
			json.put("obj_type", ctype);
			json.put("title", parseNull(map.get("elename")));
			json.put("content", parseNull(map.get("descr")));
			String url = "";
			if(parseNull(map.get("eleurl")).length() > 0)
			{
				url = urlprefix + parseNull(map.get("eleurl"));
			}
			
			json.put("URL", url);
			json.put("uuid", getItemUUID(ctype, cid, map));
			
			String _pageUuid = parseNull(getAssociatedPageUUID(ctype, cid));
			if(_pageUuid.length() > 0) json.put("page_uuid", _pageUuid);		
			
			query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+pagesdb+"pages_tags where page_type='structured' and page_id=(select id from "+pagesdb+"structured_contents_published where uuid="+
				escape.cote(cid)+")) and site_id="+escape.cote(this.siteid);
			
			JSONObject folderInfo = getFoldersHerarchy(cid,"store");
			if(folderInfo.length() > 0){
				for(String key : JSONObject.getNames(folderInfo))
				{
					json.put(key, folderInfo.get(key));
				}
			}
		}
		else
		{
			if(doc != null) 
			{				
				Map<String, String> map = getMetaInfo(doc);
				
				json = new JSONObject();
				
				if("commercialcatalog".equals(map.get("eletype")) && "offer".equals(map.get("catalogtype"))) json.put("obj_type", "offer");
				else if("commercialcatalog".equals(map.get("eletype"))) json.put("obj_type", "product");
				else if("page".equals(map.get("eletype"))) json.put("obj_type", "page");
				
				json.put("title", map.get("elename"));
				json.put("content", map.get("descr"));		
				if(map.containsKey("descr")){
					json.put("metadescription", map.get("descr"));
				}
				json.put("URL", urlprefix + map.get("eleurl"));

				org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleid]");
				if(eles != null && eles.size() > 0) cid = parseNull(eles.first().attr("content"));
				
				if(!"page".equals(map.get("eletype"))) 
				{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+catalogdb+"product_tags where product_id="+escape.cote(cid)+")";
				}else{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+pagesdb+"pages_tags where page_id=(select parent_page_id from "+pagesdb+"pages where id="+escape.cote(cid)+
						") and page_type='freemarker') and site_id="+escape.cote(this.siteid);
				}

				
				String itemType = "product";
				if("page".equals(map.get("eletype"))){
					itemType="page";
				}
				JSONObject folderInfo = getFoldersHerarchy(cid,itemType);
				if(folderInfo.length() > 0){
					for(String key : JSONObject.getNames(folderInfo))
					{
						json.put(key, folderInfo.get(key));
					}
				}

			}else{
				Set rsTmp = Etn.execute("select content_id from "+portaldb+"cached_content_view where cached_page_id = "+escape.cote(cid)+" and site_id="+
					escape.cote(this.siteid)+" and menu_id="+escape.cote(this.menuid)+" and content_type="+escape.cote(ctype));
				if(rsTmp.next()) {
					cid= parseNull(rsTmp.value("content_id"));
				}

				if(ctype.toLowerCase().contains("product")) 
				{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+catalogdb+"product_tags where product_id="+escape.cote(cid)+")";
				}else{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+pagesdb+"pages_tags where page_id=(select parent_page_id from "+pagesdb+"pages where id="+escape.cote(cid)+
						") and page_type='freemarker') and site_id="+escape.cote(this.siteid);
				}
			}
		}

		if(query.length()>0){
			Set rsTags = Etn.execute(query);
			while(rsTags.next()){
				json.put(parseNull(rsTags.value("label")),true);
			}
		}
		return json;
	}
	
	private String getItemUUID(String ctype, String cid, Map<String, String> metaMap)
	{
		if(ctype.equals("structuredpage") || ctype.equals("structuredcontent") || ctype.equals("store") ) 
		{
			//check if this has an associated page then we return that page's id
			return cid;//in this case cid we have is always the uuid
		}
		
		String qry = "";
		if("commercialcatalog".equals(metaMap.get("eletype"))) 
		{
			qry = "select product_uuid as uuid from "+env.getProperty("PROD_CATALOG_DB")+".products where id = "+escape.cote(metaMap.get("eleid"));
		}
		else if("page".equals(metaMap.get("eletype"))) 
		{
			qry = "select uuid from "+pagesdb+"pages where id = "+escape.cote(metaMap.get("eleid"));
		}
		
		String uuid = "";
		if(qry.length() > 0)
		{
			Set _rsT = Etn.execute(qry);
			if(_rsT.next())
			{
				uuid =  _rsT.value("uud");
			}
		}
		return uuid;
	}
	
	private String getAssociatedPageUUID(String ctype, String cid)
	{
		if(ctype.equals("structuredpage") || ctype.equals("structuredcontent") || ctype.equals("store") ) 
		{
			//check if this has an associated page then we return that page's id
			Set rs = Etn.execute("select p.uuid from "+pagesdb+"structured_contents_published s "+
							" inner join "+pagesdb+"pages p on p.langue_code = "+escape.cote(langCode)+" and p.parent_page_id = s.id and p.type = 'structured' where s.uuid = "+escape.cote(cid));
			if(rs.next()) 
			{
				return rs.value("uuid");
			}
		}
		return "";//if no page is associated we always return empty
	}
	
	private JSONObject getBasicTypeJson(String ctype, String cid, org.jsoup.nodes.Document doc) throws Exception
	{
		JSONObject json = null;
		String query="";

		if(ctype.equals("structuredpage") || ctype.equals("structuredcontent") || ctype.equals("store") )
		{
			Map<String, String> map = getDynamicContentMetaInfo(ctype, cid);
			json = new JSONObject();
			json.put("obj_type", ctype);
			json.put("title", parseNull(map.get("elename")));
			json.put("content", parseNull(map.get("descr")));
			json.put("uuid", getItemUUID(ctype, cid, map));
			
			String _pageUuid = parseNull(getAssociatedPageUUID(ctype, cid));
			if(_pageUuid.length() > 0) json.put("page_uuid", _pageUuid);
			
			String url = "";
			if(parseNull(map.get("eleurl")).length() > 0)
			{
				url = urlprefix + parseNull(map.get("eleurl"));
			}
			
			json.put("URL", url);
			
			query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+pagesdb+"pages_tags where page_type='structured' and page_id=(select id from "+pagesdb+"structured_contents_published where uuid="+
				escape.cote(cid)+")) and site_id="+escape.cote(this.siteid);
			
			JSONObject folderInfo = getFoldersHerarchy(cid,"store");
			if(folderInfo.length() > 0){
				for(String key : JSONObject.getNames(folderInfo))
				{
					json.put(key, folderInfo.get(key));
				}
			}
		}
		else
		{
			if(doc != null) 
			{				
				Map<String, String> map = getMetaInfo(doc);
				
				json = new JSONObject();
				
				if("commercialcatalog".equals(map.get("eletype")) && "offer".equals(map.get("catalogtype"))) 
				{
					json.put("obj_type", "offer");
				}
				else if("commercialcatalog".equals(map.get("eletype"))) 
				{
					json.put("obj_type", "product");
				}
				else if("page".equals(map.get("eletype"))) 
				{
					json.put("obj_type", "page");
				}
				
				json.put("title", map.get("elename"));
				json.put("content", map.get("descr"));									
				json.put("URL", urlprefix + map.get("eleurl"));
				if(map.containsKey("descr")){
					json.put("metadescription", map.get("descr"));
				}
				
				org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleid]");
				if(eles != null && eles.size() > 0) cid = parseNull(eles.first().attr("content"));
				
				if(!"page".equals(map.get("eletype"))) 
				{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+catalogdb+"product_tags where product_id="+escape.cote(cid)+")";
				}else{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+pagesdb+"pages_tags where page_id=(select parent_page_id from "+pagesdb+"pages where id="+escape.cote(cid)+
						") and page_type='freemarker') and site_id="+escape.cote(this.siteid);
				}

				String itemType = "product";
				if("page".equals(map.get("eletype"))){
					itemType="page";
				}
				JSONObject folderInfo = getFoldersHerarchy(cid,itemType);
				if(folderInfo.length() > 0){
					for(String key : JSONObject.getNames(folderInfo))
					{
						json.put(key, folderInfo.get(key));
					}
				}

			}else{
				Set rsTmp = Etn.execute("select content_id from "+portaldb+"cached_content_view where cached_page_id = "+escape.cote(cid)+" and site_id="+
					escape.cote(this.siteid)+" and menu_id="+escape.cote(this.menuid)+" and content_type="+escape.cote(ctype));
				if(rsTmp.next()) {
					cid= parseNull(rsTmp.value("content_id"));
				}

				if(ctype.toLowerCase().contains("product")) 
				{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+catalogdb+"product_tags where product_id="+escape.cote(cid)+")";
				}else{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+pagesdb+"pages_tags where page_id=(select parent_page_id from "+pagesdb+"pages where id="+escape.cote(cid)+
						") and page_type='freemarker') and site_id="+escape.cote(this.siteid);
				}
			}
		}
		if(query.length() > 0){
			Set rsTags = Etn.execute(query);
			while(rsTags.next()){
				json.put(parseNull(rsTags.value("label")),true);
			}
		}
		return json;
	}
	
	private Map<String, String> getDynamicContentMetaInfo(String ctype, String cid)
	{
		Map<String, String> map = new HashMap<String, String>();

		Set rsP = Etn.execute("select c.uuid, c.name, u.page_path as url, group_concat(ct.label) as tags, p.meta_description "+
							" from "+pagesdb+"structured_contents_published c "+
							" inner join "+pagesdb+"structured_contents_details_published d on d.content_id = c.id and d.langue_id = "+escape.cote(langId)+
							" left outer join "+pagesdb+"pages p on p.id = d.page_id "+
							" left outer join "+pagesdb+"pages_tags pt on pt.page_type = p.type and pt.page_id = case when p.type = 'react' then p.id else p.parent_page_id end "+
							" left outer join "+preprodcatalogdb+"tags ct on pt.tag_id = ct.id and ct.site_id = "+escape.cote(this.siteid)+
							" left outer join "+commonsdb+"content_urls u on u.content_type = 'page' and u.content_id = p.id "+
							" left outer join "+pagesdb+"bloc_templates b on b.id = c.template_id "+
							" where c.site_id = "+escape.cote(this.siteid)+" and c.uuid = "+escape.cote(cid));
							
		if(rsP.next())
		{
			map.put("elename", parseNull(rsP.value("name")));
			map.put("descr", parseNull(rsP.value("meta_description")));
			map.put("eletags", parseNull(rsP.value("tags")));
			map.put("eleurl", Util.removeAccents(parseNull(rsP.value("url"))).toLowerCase());
		}
		return map;
	}
	
	//String commitmentduration, String commitmentfrequency are added for products v2
	private JSONObject fillOfferTypeJson(String objType, String elename, String description, String price, String price2, String price3, String picUrl, String completeurl, String commitment, String monthly, String currency, String commitmentduration, String commitmentfrequency) throws Exception
	{
		JSONObject json = new JSONObject();
		json.put("obj_type", objType);
		
		json.put("name", elename);
		json.put("content", description);
		if(!(objType.equals("structuredpage") || objType.equals("structuredcontent") || objType.equals("store") ))
		{
			json.put("metadescription", description);
		}
				
		json.put("price1", price);
		if(price2.length() > 0) json.put("price2", price2);					
		else json.put("price2", "false");
		
		if(price3.length() > 0) json.put("price3", price3);
		else json.put("price3", "false");

		if(picUrl.length() > 0) json.put("image", picUrl);

		json.put("URL", completeurl);

		json.put("commitment", commitment);	

		json.put("monthly", monthly);
		
		//for products v2
		json.put("commitment_frequency", commitmentfrequency);
		json.put("commitment_duration", commitmentduration);

		json.put("ISO_4217", currency);						
			
		return json;
	}
	
	private JSONObject fillProductTypeJson(String objType, String elename, String description, String price, String catalog, String picUrl, String brand, String completeurl, String lpid, String isnew, String currency, String commitment, String commitmentduration, String commitmentfrequency) throws Exception
	{		
		JSONObject json = new JSONObject();		
		json.put("obj_type", objType);
		
		json.put("title", elename);
		json.put("description", description);
		if(!(objType.equals("structuredpage") || objType.equals("structuredcontent") || objType.equals("store") ))
		{
			json.put("metadescription", description);
		}		
		json.put("prix", price);

		json.put("category", catalog);

		if(picUrl.length() > 0) json.put("pictureURL", picUrl);

		if(brand.length() > 0) json.put("brand", brand);

		json.put("detail", completeurl);
		json.put("URL", completeurl);

		json.put("idProduct", lpid);

		json.put("isnew", isnew);

		json.put("ISO_4217", currency);	
		
		//for products v2
		if(Util.parseNullInt(commitmentduration) > 0)
		{
			json.put("commitment", commitment);	
			json.put("commitment_frequency", commitmentfrequency);
			json.put("commitment_duration", commitmentduration);
		}
		
		
		return json;
	}
		
	private JSONObject getOfferTypeJson(String ctype, String cid, org.jsoup.nodes.Document doc) throws Exception
	{
		JSONObject json = null;		
		String query="";
		String uuid = "";
		if(ctype.equals("structuredpage") || ctype.equals("structuredcontent") || ctype.equals("store") )
		{
			Map<String, String> map = getDynamicContentMetaInfo(ctype, cid);
			String url = "";
			if(parseNull(map.get("eleurl")).length() > 0)
			{
				url = urlprefix + parseNull(map.get("eleurl"));
			}
			json = fillOfferTypeJson(ctype, parseNull(map.get("elename")), parseNull(map.get("descr")), "", "", "", "", url, "", "", "", "", "");
		}
		else
		{
			String productdId="";
			if(doc != null) 
			{
				Map<String, String> map = getMetaInfo(doc);

				if("commercialcatalog".equals(map.get("eletype")) && "offer".equals(map.get("catalogtype"))) 
				{
					String price = "0";
					org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleprice]");
					if(eles != null && eles.size() > 0) price = parseNull(eles.first().attr("content"));

					String price2 = "";
					eles = doc.select("meta[name=etn:eleprice2]");
					if(eles != null && eles.size() > 0) price2 = parseNull(eles.first().attr("content"));
					
					String price3 = "";
					eles = doc.select("meta[name=etn:eleprice3]");
					if(eles != null && eles.size() > 0) price3 = parseNull(eles.first().attr("content"));
					
					String picUrl = "";
					eles = doc.select("meta[name=etn:eleimage]");
					if(eles != null && eles.size() > 0) picUrl = parseNull(eles.first().attr("content"));

					String commitment = "";
					eles = doc.select("meta[name=etn:elecommitment]");
					if(eles != null && eles.size() > 0) commitment = parseNull(eles.first().attr("content"));

					String monthly = "";
					eles = doc.select("meta[name=etn:elemonthly]");
					if(eles != null && eles.size() > 0) monthly = parseNull(eles.first().attr("content"));

					String currency = "";
					eles = doc.select("meta[name=etn:elecurrency]");
					if(eles != null && eles.size() > 0) currency = parseNull(eles.first().attr("content"));

					String commitmentduration = "";
					eles = doc.select("meta[name=etn:commitmentduration]");
					if(eles != null && eles.size() > 0) commitmentduration = parseNull(eles.first().attr("content"));

					String commitmentfrequency = "";
					eles = doc.select("meta[name=etn:commitmentfrequency]");
					if(eles != null && eles.size() > 0) commitmentfrequency = parseNull(eles.first().attr("content"));

					json = fillOfferTypeJson("offer", map.get("elename"), map.get("descr"), price, price2, price3, picUrl, urlprefix + map.get("eleurl"), commitment, monthly, currency, commitmentduration, commitmentfrequency);					
					
					JSONObject folderInfo = getFoldersHerarchy(map.get("eleid"),"product");
					if(folderInfo.length() > 0){
						for(String key : JSONObject.getNames(folderInfo))
						{
							json.put(key, folderInfo.get(key));
						}
					}
				}
				else if("commercialcatalog".equals(map.get("eletype")))
				{
					String price = "0";
					org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleprice]");
					if(eles != null && eles.size() > 0) price = parseNull(eles.first().attr("content"));

					String picUrl = "";
					eles = doc.select("meta[name=etn:eleimage]");
					if(eles != null && eles.size() > 0) picUrl = parseNull(eles.first().attr("content"));

					String currency = "0";
					eles = doc.select("meta[name=etn:elecurrency]");
					if(eles != null && eles.size() > 0) currency = parseNull(eles.first().attr("content"));		

					json = fillOfferTypeJson("product", map.get("elename"), map.get("descr"), price, "", "", picUrl, urlprefix + map.get("eleurl"), "", "", currency, "", "");
					
					JSONObject folderInfo = getFoldersHerarchy(map.get("eleid"),"product");
					if(folderInfo.length() > 0){
						for(String key : JSONObject.getNames(folderInfo))
						{
							json.put(key, folderInfo.get(key));
						}
					}
				}
				else if("page".equals(map.get("eletype"))) 
				{
					json = fillOfferTypeJson("page", map.get("elename"), map.get("descr"), "", "", "", "", urlprefix + map.get("eleurl"), "", "", "", "", "");
				}
				
				org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleid]");
				if(eles != null && eles.size() > 0) cid = parseNull(eles.first().attr("content"));
				
				if(!"page".equals(map.get("eletype"))) 
				{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+catalogdb+"product_tags where product_id="+escape.cote(cid)+")";
				}else{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+pagesdb+"pages_tags where page_id=(select parent_page_id from "+pagesdb+"pages where id="+escape.cote(cid)+
						") and page_type='freemarker') and site_id="+escape.cote(this.siteid);
				}
			}else{
				Set rsTmp = Etn.execute("select content_id from "+portaldb+"cached_content_view where cached_page_id = "+escape.cote(cid)+" and site_id="+
					escape.cote(this.siteid)+" and menu_id="+escape.cote(this.menuid)+" and content_type="+escape.cote(ctype));
				if(rsTmp.next()) {
					cid= parseNull(rsTmp.value("content_id"));
				}

				if(ctype.toLowerCase().contains("product")) 
				{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+catalogdb+"product_tags where product_id="+escape.cote(cid)+")";
				}else{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+pagesdb+"pages_tags where page_id=(select parent_page_id from "+pagesdb+"pages where id="+escape.cote(cid)+
						") and page_type='freemarker') and site_id="+escape.cote(this.siteid);
				}
			}
		}

		if(query.length()>0){
			Set rsTags = Etn.execute(query);
			while(rsTags.next()){
				json.put(parseNull(rsTags.value("label")),true);
			}
		}

		if(json == null)//not possible but lets check and return empty json
		{
			json = new JSONObject();
		}

		
		return json;
	}

	private static boolean isValidDateRange(String startDateString, String endDateString) throws Exception {

        DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        Date startDate, endDate, currentDate;

        currentDate = df.parse(df.format(new Date()));

        startDate = (startDateString.length() == 0 ? currentDate : df.parse(startDateString));
        endDate = (endDateString.length() == 0 ? currentDate : df.parse(endDateString));

        if(!(currentDate.before(startDate) || currentDate.after(endDate))) return true;

        return false;
    }

	private boolean isNumeric(String str) {
		return parseNull(str).length() > 0 && str.matches("-?\\d+(\\.\\d+)?");
	}
	
	private JSONObject addMarketingRules(String cid,String price,String sku) throws Exception {

		BigDecimal  actualPrice;
		if (isNumeric(price)) actualPrice = new BigDecimal(price);
		else actualPrice = new BigDecimal(0);

		JSONObject respObj = new JSONObject();
		JSONArray marketingRules = new JSONArray();
		String priceDiscountOneTime = price;
		String priceSubsidy = null;

		//----------------------------------------------For Subsidy----------------------------------------------
		
		String marketingQuery = "select s.* FROM " + this.catalogdb + "subsidies s INNER JOIN " + this.catalogdb + "subsidies_rules sr on s.id = sr.subsidy_id WHERE s.site_id = "+
			escape.cote(this.siteid)+" AND (( sr.associated_to_type = 'product' AND sr.associated_to_value = "+escape.cote(cid)+
			") or ( sr.associated_to_type = 'sku' AND sr.associated_to_value = "+escape.cote(sku)+")) GROUP BY s.id ORDER BY s.order_seq";

		BigDecimal  priceOfProduct;
		if (isNumeric(price)) priceOfProduct = new BigDecimal(price);
		else priceOfProduct = new BigDecimal(0);

		Set rsMarketing=Etn.execute(marketingQuery);
		while(rsMarketing.next()) {
			if(isValidDateRange(rsMarketing.value("start_date"), rsMarketing.value("end_date"))) {

				JSONObject marketingObj = new JSONObject();
				marketingObj.put("type","subsidy");
				marketingObj.put("start_date",rsMarketing.value("start_date"));
				marketingObj.put("end_date",rsMarketing.value("end_date"));
				marketingObj.put("title",rsMarketing.value("name"));
				marketingObj.put("frequency", "");
				marketingObj.put("flash_sale_type", "");
				marketingObj.put("duration", "");
				marketingObj.put("quantity_flash_sale", "");
				marketingObj.put("discount_value",rsMarketing.value("discount_value"));

				BigDecimal  discountValue;
				if (isNumeric(parseNull(rsMarketing.value("discount_value")))) discountValue = new BigDecimal(parseNull(rsMarketing.value("discount_value")));
				else discountValue = new BigDecimal(0);

				if(rsMarketing.value("discount_type").equalsIgnoreCase("fixed")) {
					marketingObj.put("discount_type","fixed_amount");
					if(priceOfProduct.compareTo(discountValue)>0) priceOfProduct = priceOfProduct.subtract(discountValue);
					else priceOfProduct=priceOfProduct.subtract(priceOfProduct);

				}else {
					marketingObj.put("discount_type",rsMarketing.value("discount_type"));
					BigDecimal percentage = actualPrice.multiply(discountValue.divide(new BigDecimal("100")));
					if(priceOfProduct.compareTo(percentage)>0) priceOfProduct = priceOfProduct.subtract(percentage);
					else priceOfProduct=priceOfProduct.subtract(priceOfProduct);
				}
				marketingRules.put(marketingObj);
			}
		}

		if(actualPrice.compareTo(priceOfProduct)>0) priceSubsidy=priceOfProduct.toString();
		//----------------------------------------------For Promotions----------------------------------------------

		marketingQuery="select p.* from "+this.catalogdb+"promotions p inner join "+this.catalogdb+"promotions_rules pr on p.id=pr.promotion_id where p.site_id = "+
			escape.cote(this.siteid)+" and discount_value!=0 and ((pr.applied_to_type='product' and pr.applied_to_value="+escape.cote(cid)+
			") or ( pr.applied_to_type = 'sku' AND pr.applied_to_value = "+escape.cote(sku)+")) group by pr.promotion_id order by p.order_seq";

		rsMarketing=Etn.execute(marketingQuery);
		
		if (isNumeric(price)) priceOfProduct = new BigDecimal(price);
		else priceOfProduct = new BigDecimal(0);

		while(rsMarketing.next()) {
			if(isValidDateRange(rsMarketing.value("start_date"), rsMarketing.value("end_date"))) {
				JSONObject marketingObj = new JSONObject();
				marketingObj.put("type","promotion");
				marketingObj.put("start_date",rsMarketing.value("start_date"));
				marketingObj.put("end_date",rsMarketing.value("end_date"));
				marketingObj.put("title",rsMarketing.value("lang_"+this.langId+"_title"));
				marketingObj.put("frequency",rsMarketing.value("frequency"));
				marketingObj.put("flash_sale_type",rsMarketing.value("flash_sale"));
				marketingObj.put("duration",rsMarketing.value("duration"));
				marketingObj.put("quantity_flash_sale",rsMarketing.value("flash_sale_quantity"));
				marketingObj.put("discount_value",rsMarketing.value("discount_value"));

				BigDecimal  discountValue;
				if (isNumeric(parseNull(rsMarketing.value("discount_value")))) discountValue = new BigDecimal(parseNull(rsMarketing.value("discount_value")));
				else discountValue = new BigDecimal(0);

				if(rsMarketing.value("discount_type").equalsIgnoreCase("fixed")){
					marketingObj.put("discount_type","fixed_amount");
					if(priceOfProduct.compareTo(discountValue)>0) priceOfProduct = priceOfProduct.subtract(discountValue);
					else priceOfProduct=priceOfProduct.subtract(priceOfProduct);
				}else{
					marketingObj.put("discount_type",rsMarketing.value("discount_type"));
					BigDecimal percentage = actualPrice.multiply(discountValue.divide(new BigDecimal("100")));
					if(priceOfProduct.compareTo(percentage)>0) priceOfProduct = priceOfProduct.subtract(percentage);
					else priceOfProduct=priceOfProduct.subtract(priceOfProduct);
				}
				marketingRules.put(marketingObj);
			}
		}

		if(actualPrice.compareTo(priceOfProduct)>0) priceDiscountOneTime=priceOfProduct.toString();
		//----------------------------------------------For ComeWith----------------------------------------------

		marketingQuery="select * from "+this.catalogdb+"comewiths c inner join "+this.catalogdb+"comewiths_rules cr on c.id = cr.comewith_id where c.site_id = "+
			escape.cote(this.siteid)+" and ((cr.associated_to_type='product' and cr.associated_to_value="+escape.cote(cid)+
			") or ( cr.associated_to_type = 'sku' AND cr.associated_to_value = "+escape.cote(sku)+")) group by cr.comewith_id order by c.order_seq";
		
		rsMarketing=Etn.execute(marketingQuery);
		while(rsMarketing.next()){
			if(isValidDateRange(rsMarketing.value("start_date"), rsMarketing.value("end_date"))){
				JSONObject marketingObj = new JSONObject();
				marketingObj.put("type","come-with");
				marketingObj.put("comeWithTitle",rsMarketing.value("title"));
				marketingObj.put("comeWithStartDate",rsMarketing.value("start_date"));
				marketingObj.put("comeWithEndDate",rsMarketing.value("end_date"));
				marketingObj.put("frequency",rsMarketing.value("frequency"));
				marketingObj.put("flash_sale_type", "");
				marketingObj.put("duration", "");
				marketingObj.put("quantity_flash_sale", "");
				marketingObj.put("discount_type", "");
				marketingObj.put("discount_value", "");
				
				marketingRules.put(marketingObj);
			}
		}
		respObj.put("marketing_rules",marketingRules);

		if (isNumeric(priceSubsidy)) respObj.put("priceSubsidy",new BigDecimal(priceSubsidy));
		else respObj.put("priceSubsidy",0);

		if (isNumeric(priceDiscountOneTime)) respObj.put("priceDiscountOneTime",new BigDecimal(priceDiscountOneTime));
		else respObj.put("priceDiscountOneTime",0);

		return respObj;
	}

	private JSONObject getProductTypeJson(String ctype, String cid, org.jsoup.nodes.Document doc) throws Exception {
		JSONObject json = null;		
		String query="";
		String productId="";
		if(ctype.equals("structuredpage") || ctype.equals("structuredcontent") || ctype.equals("store") )
		{
			Map<String, String> map = getDynamicContentMetaInfo(ctype, cid);
			String url = "";
			if(parseNull(map.get("eleurl")).length() > 0)
			{
				url = urlprefix + parseNull(map.get("eleurl"));
			}
			json = fillProductTypeJson(ctype, parseNull(map.get("elename")), parseNull(map.get("descr")), "0", "", "", "", url, "", "", "", "", "", "");
		}
		else
		{
			if(doc != null) 
			{				
				Map<String, String> map = getMetaInfo(doc);

				if("commercialcatalog".equals(map.get("eletype")) && "offer".equals(map.get("catalogtype"))) 
				{
					String price = "0";
					org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleprice]");
					if(eles != null && eles.size() > 0) price = parseNull(eles.first().attr("content"));

					String catalog = "";
					eles = doc.select("meta[name=etn:cname]");
					if(eles != null && eles.size() > 0) catalog = parseNull(eles.first().attr("content"));

					String picUrl = "";
					eles = doc.select("meta[name=etn:eleimage]");
					if(eles != null && eles.size() > 0) picUrl = parseNull(eles.first().attr("content"));

					String brand = "";
					eles = doc.select("meta[name=etn:elebrand]");
					if(eles != null && eles.size() > 0) brand = parseNull(eles.first().attr("content"));

					String lpid = "";
					eles = doc.select("meta[name=etn:eleid]");
					if(eles != null && eles.size() > 0) lpid = parseNull(eles.first().attr("content"));

					String isnew = "0";
					eles = doc.select("meta[name=etn:eleisnew]");
					if(eles != null && eles.size() > 0) isnew = parseNull(eles.first().attr("content"));

					String currency = "0";
					eles = doc.select("meta[name=etn:elecurrency]");
					if(eles != null && eles.size() > 0) currency = parseNull(eles.first().attr("content"));

					//for products v2
					String commitment = "";
					eles = doc.select("meta[name=etn:elecommitment]");
					if(eles != null && eles.size() > 0) commitment = parseNull(eles.first().attr("content"));

					String commitmentduration = "";
					eles = doc.select("meta[name=etn:commitmentduration]");
					if(eles != null && eles.size() > 0) commitmentduration = parseNull(eles.first().attr("content"));

					String commitmentfrequency = "";
					eles = doc.select("meta[name=etn:commitmentfrequency]");
					if(eles != null && eles.size() > 0) commitmentfrequency = parseNull(eles.first().attr("content"));
					//end changes for products v2
					
					json = fillProductTypeJson("offer", map.get("elename"), map.get("descr"), price, catalog, picUrl, brand, urlprefix + map.get("eleurl"), lpid, isnew, currency, commitment, commitmentduration, commitmentfrequency);
					
					JSONObject folderInfo = getFoldersHerarchy(lpid,"product");
					if(folderInfo.length() > 0){
						for(String key : JSONObject.getNames(folderInfo))
						{
							json.put(key, folderInfo.get(key));
						}
					}
					
					productId=lpid;
				}				
				else if("commercialcatalog".equals(map.get("eletype")))
				{
					String price = "0";
					org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleprice]");
					if(eles != null && eles.size() > 0) price = parseNull(eles.first().attr("content"));

					String catalog = "";
					eles = doc.select("meta[name=etn:cname]");
					if(eles != null && eles.size() > 0) catalog = parseNull(eles.first().attr("content"));

					String picUrl = "";
					eles = doc.select("meta[name=etn:eleimage]");
					if(eles != null && eles.size() > 0) picUrl = parseNull(eles.first().attr("content"));

					String brand = "";
					eles = doc.select("meta[name=etn:elebrand]");
					if(eles != null && eles.size() > 0) brand = parseNull(eles.first().attr("content"));

					String lpid = "";
					eles = doc.select("meta[name=etn:eleid]");
					if(eles != null && eles.size() > 0) lpid = parseNull(eles.first().attr("content"));

					String isnew = "0";
					eles = doc.select("meta[name=etn:eleisnew]");
					if(eles != null && eles.size() > 0) isnew = parseNull(eles.first().attr("content"));

					String currency = "0";
					eles = doc.select("meta[name=etn:elecurrency]");
					if(eles != null && eles.size() > 0) currency = parseNull(eles.first().attr("content"));

					//for products v2
					String commitment = "";
					eles = doc.select("meta[name=etn:elecommitment]");
					if(eles != null && eles.size() > 0) commitment = parseNull(eles.first().attr("content"));

					String commitmentduration = "";
					eles = doc.select("meta[name=etn:commitmentduration]");
					if(eles != null && eles.size() > 0) commitmentduration = parseNull(eles.first().attr("content"));

					String commitmentfrequency = "";
					eles = doc.select("meta[name=etn:commitmentfrequency]");
					if(eles != null && eles.size() > 0) commitmentfrequency = parseNull(eles.first().attr("content"));
					//end changes for products v2

					json = fillProductTypeJson("product", map.get("elename"), map.get("descr"), price, catalog, picUrl, brand, urlprefix + map.get("eleurl"), lpid, isnew, currency, commitment, commitmentduration, commitmentfrequency);
					
					JSONObject folderInfo = getFoldersHerarchy(lpid,"product");
					if(folderInfo.length() > 0){
						for(String key : JSONObject.getNames(folderInfo))
						{
							json.put(key, folderInfo.get(key));
						}
					}
					
					productId=lpid;
				}
				else if("page".equals(map.get("eletype"))) 
				{
					json = fillProductTypeJson("page", map.get("elename"), map.get("descr"), "0", "", "", "", urlprefix + map.get("eleurl"), "", "", "", "", "", "");
				}				
				
				if(!"page".equals(map.get("eletype"))) 
				{
					query="select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+catalogdb+"product_tags where product_id="+escape.cote(productId)+") and site_id="+escape.cote(this.siteid);
				}
			}
		}
		if(query.length()>0){
			Set rsTags = Etn.execute(query);
			while(rsTags.next()){
				json.put(parseNull(rsTags.value("label")),true);
			}
		}

		if(json == null)//not possible but lets check and return empty json
		{
			json = new JSONObject();
		}

		return json;
	}	

	private String addParam(String name, String value,String queryParam) {
		if(queryParam.length()>0) queryParam+="&";
		try { queryParam += URLEncoder.encode(name, "UTF-8")+"="+URLEncoder.encode(value, "UTF-8"); } 
		catch (Exception e) { e.printStackTrace(); }

		return queryParam;
	}


	private JSONArray getNewProductJson(String ctype, String cid, org.jsoup.nodes.Document doc) throws Exception {	
		System.out.println("================================Start getNewProductJson=================================");
		
		boolean enableEcommerce =false;
		Set rsEcommerce = Etn.execute("select enable_ecommerce from "+portaldb+"sites where id="+escape.cote(this.siteid));
		rsEcommerce.next();
		if(parseNull(rsEcommerce.value("enable_ecommerce")).equals("1")) enableEcommerce=true;
		
		if(doc!=null)  {
			org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleid]");
			if(eles != null && eles.size() > 0) cid = parseNull(eles.first().attr("content"));
		} else {
			Set rsTmp = Etn.execute("select content_id from "+portaldb+"cached_content_view where cached_page_id = "+escape.cote(cid)+" and site_id="+
				escape.cote(this.siteid)+" and menu_id="+escape.cote(this.menuid)+" and content_type="+escape.cote(ctype));
			if(rsTmp.next()) {
				cid= parseNull(rsTmp.value("content_id"));
			}
		}

		JSONArray jsonArray = new JSONArray();
		if(ctype.equals("structuredpage") || ctype.equals("structuredcontent") || ctype.equals("store")|| ctype.equals("page") ) {
			JSONObject json = new JSONObject();
			json.put("category",""); json.put("brand",""); json.put("priceOneTime",0);
			json.put("priceDiscountOneTime",0); json.put("priceSubsidy",0); 
			if(enableEcommerce){
				json.put("quantityInStock",0);
			}else{
				json.put("quantityInStock",99);
			}
			json.put("description",""); json.put("parentObjectID",""); json.put("marketing_rules",new JSONArray());
			json.put("href",""); json.put("image","");
			
			jsonArray.put(json);	
		} else if(ctype.equals("product") || ctype.equals("offer")) {
			Set rsProduct = Etn.execute("select p.id as prod_id,p.show_basket,pv.uuid as variant_id,pv.id as var_id, c.name as 'catalog_name',p.brand_name,pv.price,pv.stock,p.lang_"+this.langId+
				"_name as name,p.lang_"+this.langId+"_summary as 'desc',pv.sku,pv.sticker from "+catalogdb+"product_variants pv left join "+catalogdb+
				"products p on p.id=pv.product_id left join "+catalogdb+"catalogs c on p.catalog_id=c.id where p.id="+escape.cote(cid));

			while(rsProduct.next()){
				JSONObject json = new JSONObject();

				JSONObject temp=addMarketingRules(cid,rsProduct.value("price"),rsProduct.value("sku"));

                json.put("metadescription", parseNull(rsProduct.value("desc")));
				json.put("objectID",parseNull(rsProduct.value("variant_id")));
				json.put("category",parseNull(rsProduct.value("catalog_name")));
				json.put("brand",parseNull(rsProduct.value("brand_name")));
				json.put("priceOneTime",Double.parseDouble(parseNull(rsProduct.value("price"))));

				Object value = temp.opt("priceDiscountOneTime");
				if (value instanceof Number) json.put("priceDiscountOneTime",new BigDecimal(value.toString()));
				else json.put("priceDiscountOneTime",0);

				if(temp.has("priceSubsidy")){
					value = temp.opt("priceSubsidy");
					if (value instanceof Number) json.put("priceSubsidy",new BigDecimal(value.toString()));
					else json.put("priceSubsidy",0);
				}

				if(!enableEcommerce) json.put("quantityInStock",99);
				else{
					if(parseNull(rsProduct.value("show_basket")).equals("1")) json.put("quantityInStock",Integer.parseInt(parseNull(rsProduct.value("stock"))));
					else json.put("quantityInStock",99);
				}
				
				json.put("description",parseNull(rsProduct.value("desc")));
				json.put("parentObjectID",parseNull(rsProduct.value("name")));
				json.put("marketing_rules",temp.getJSONArray("marketing_rules"));

				Set rsSticker = Etn.execute("select sname,color from "+catalogdb+"stickers where sname="+escape.cote(parseNull(rsProduct.value("sticker")))+
					" and site_id="+escape.cote(this.siteid));
				if(rsSticker.next()){
					json.put("stickersLabel",parseNull(rsSticker.value("sname")));
					json.put("stickersColor",parseNull(rsSticker.value("color")));
				}else{
					json.put("stickersLabel","");
					json.put("stickersColor","");
				}
				
				String queryParam="";
				Set rsAtr = Etn.execute("SELECT ca.name,cav.attribute_value,cav.color FROM "+catalogdb+"product_variant_ref pvr "
					+"LEFT JOIN "+catalogdb+"catalog_attributes ca ON ca.cat_attrib_id=pvr.cat_attrib_id "
					+"LEFT JOIN "+catalogdb+"catalog_attribute_values cav ON cav.id=pvr.catalog_attribute_value_id "
					+"WHERE ca.type='selection' AND pvr.product_variant_id="+escape.cote(parseNull(rsProduct.value("var_id")))
					+" AND COALESCE(cav.attribute_value,'')!=''");
				while(rsAtr.next()){
					if(parseNull(rsAtr.value("name")).equalsIgnoreCase("color")){
						if(parseNull(rsAtr.value("color")).length()==0){
							json.put("colorCode","#000000");
							json.put("color","black");
							
							queryParam = addParam("color","black",queryParam);
							queryParam = addParam("colorCode","#000000",queryParam);
						}else{
							json.put("colorCode",parseNull(rsAtr.value("color")));
							json.put("color",parseNull(rsAtr.value("attribute_value")));

							queryParam = addParam("colorCode",parseNull(rsAtr.value("color")),queryParam);
							queryParam = addParam("color",parseNull(rsAtr.value("attribute_value")),queryParam);
						}
					}else if(parseNull(rsAtr.value("name")).equalsIgnoreCase("storage")){
						if(parseNull(rsAtr.value("attribute_value")).replaceAll("[^0-9]", "").length()==0){
							json.put("storage",0);
							queryParam = addParam("storage","0GB",queryParam);
						}else{
							json.put("storage",Integer.parseInt(parseNull(rsAtr.value("attribute_value")).replaceAll("[^0-9]", "")));
							queryParam = addParam("storage",parseNull(rsAtr.value("attribute_value")),queryParam);
						}
					}else{
						json.put(parseNull(rsAtr.value("name")).toLowerCase(),parseNull(rsAtr.value("attribute_value")));
						queryParam = addParam(parseNull(rsAtr.value("name")).toLowerCase(),parseNull(rsAtr.value("attribute_value")),queryParam);
					}
				}

				if(!json.has("color")){
					json.put("colorCode","#000000");
					json.put("color","black");
				}
				if(!json.has("storage")) json.put("storage",0);

				if(doc!=null) {
					Map<String, String> map = getMetaInfo(doc);
					json.put("href",urlprefix + map.get("eleurl")+"?"+queryParam);
					String picUrl = "";
					org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleimage]");
					if(eles != null && eles.size() > 0) picUrl = parseNull(eles.first().attr("content"));
					
					json.put("image",picUrl);
				}
				Set rsTag=Etn.execute("select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+catalogdb+"product_tags where product_id="+escape.cote(cid)+")");
				while(rsTag.next()) {
					json.put(parseNull(rsTag.value("label")),true);
				}

				JSONObject folderInfo = getFoldersHerarchy(cid,"product");
				if(folderInfo.length() > 0){
					for(String key : JSONObject.getNames(folderInfo)) {
						json.put(key, folderInfo.get(key));
					}
				}
				jsonArray.put(json);
			}

			JSONArray tempArray = new JSONArray(jsonArray.toString());
			for (int i = 0; i < jsonArray.length(); i++) {
				JSONObject jsonObject = jsonArray.getJSONObject(i);
				jsonObject.put("modelVariants", tempArray);
			}
		} else if(ctype.equals("new_product")) {
			
			Set rsProductContent = Etn.execute("select scd.content_data,scd.content_id,pmp.product_id from "+pagesdb+"structured_contents sc left join "+pagesdb+
				"structured_contents_details scd on scd.content_id=sc.id and scd.langue_id="+this.langId+" join "+pagesdb+"products_map_pages pmp on pmp.page_id=sc.id"+
				" where sc.uuid="+escape.cote(cid));
			rsProductContent.next();
			String contentString = parseNull(rsProductContent.value("content_data")).isEmpty()?"{}":parseNull(rsProductContent.value("content_data"));

			String productId = rsProductContent.value("product_id");
			String contentId = rsProductContent.value("content_id");
			JSONObject contentdata = new JSONObject(contentString);

			Set rsProductDefinition = Etn.execute("select p.show_basket,pd.*,ptv.type_name,ptv.template_id,ptv.uuid as product_type_uuid from "+this.catalogdb+"products p join "+this.catalogdb+
				"products_definition pd on p.product_definition_id=pd.id join "+this.catalogdb+"product_types_v2 ptv on pd.product_type=ptv.id "+
				" where p.id="+escape.cote(productId));
			rsProductDefinition.next();

			JSONArray categories = new JSONArray();
			Set rsProductTypeAttriAndCat = Etn.execute("select * from "+this.catalogdb+"product_v2_categories_and_attributes where reference_type='category' and product_type_uuid="+escape.cote(rsProductDefinition.value("product_type_uuid")));
			while(rsProductTypeAttriAndCat.next()){
				Set rsTmp = Etn.execute("select * from "+this.catalogdb+"categories_v2 where uuid="+escape.cote(rsProductTypeAttriAndCat.value("reference_uuid")));
				rsTmp.next();
				categories.put(rsTmp.value("name"));
			}
			// ----------- Filling JSON --------------
			JSONObject productMainInfo = contentdata.getJSONArray("main_information").getJSONObject(0);
			JSONObject productGeneralInfo = contentdata.getJSONArray("product_general_informations").getJSONObject(0);
			JSONArray productVariants = contentdata.getJSONArray("product_variants").getJSONObject(0).getJSONArray("product_variants_variant_x");

			for (int ind = 0; ind < productVariants.length(); ind++) {
				JSONObject varObj = productVariants.getJSONObject(ind);

				JSONObject json = new JSONObject();

				String variantId = varObj.getJSONArray("product_variants_variant_x_id").getString(0);
				String variantUuid = varObj.getJSONArray("product_variants_variant_x_uuid").getString(0);
				
				String priceOneTime = "";
				try{
					priceOneTime = varObj.getJSONArray("product_variants_variant_x_price_price").getString(0);
				}catch(Exception e) { priceOneTime = ""; }

				JSONObject temp=addMarketingRules(productId,priceOneTime,varObj.getJSONArray("product_variants_variant_x_sku").getString(0));
				
				Set rsVarStock = Etn.execute("select stock from "+this.catalogdb+"product_variants where id="+escape.cote(variantId));
				rsVarStock.next();
				if(!enableEcommerce) json.put("quantityInStock",99);
				else{
					if(parseNull(rsProductDefinition.value("show_basket")).equals("1")) json.put("quantityInStock",Integer.parseInt(parseNull(rsVarStock.value("stock"))));
					else json.put("quantityInStock",99);
				}

				Object value = temp.opt("priceDiscountOneTime");
				if (value instanceof Number) json.put("priceDiscountOneTime",new BigDecimal(value.toString()));
				else json.put("priceDiscountOneTime",0);

				if(temp.has("priceSubsidy")){
					value = temp.opt("priceSubsidy");
					if (value instanceof Number) json.put("priceSubsidy",new BigDecimal(value.toString()));
					else json.put("priceSubsidy",0);
				}
				json.put("marketing_rules",temp.optJSONArray("marketing_rules"));
				json.put("metadescription",rsProductDefinition.value("meta_description"));

				try {
					json.put("priceOneTime",Double.parseDouble(parseNull(priceOneTime)));
				} catch(Exception e) { json.put("priceOneTime",0); }

				json.put("parentObjectID",parseNull(rsProductDefinition.value("name")));
				
				try {
				json.put("brand",parseNull(productGeneralInfo.getJSONArray("product_general_informations_manufacturer").getString(0)));
				} catch(Exception e) { json.put("brand",""); }

				json.put("objectID",parseNull(variantUuid));
				json.put("system_product_type",parseNull(rsProductDefinition.value("type_name")));
				try {
				json.put("long_description",parseNull(varObj.getJSONArray("product_variants_variant_x_long_description").getString(0)));
				} catch(Exception e) { json.put("long_description",""); }

				try {
				json.put("short_description",parseNull(varObj.getJSONArray("product_variants_variant_x_short_description").getString(0)));
				} catch(Exception e) { json.put("short_description",""); }
				
				try{
				JSONArray tagsAry = varObj.getJSONArray("product_variants_variant_x_tags").getJSONArray(0);
				for(int i = 0; i < tagsAry.length(); i++){ 
					Set rsTag=Etn.execute("select label from "+preprodcatalogdb+"tags where id="+escape.cote(tagsAry.getString(i)));
					if(rsTag.next()) json.put(parseNull(rsTag.value("label")),true);
				}
				}catch(Exception tmpExp3){}

				try{
					JSONArray tagsAry = productGeneralInfo.getJSONArray("product_general_informations_tags").getJSONArray(0);
				for(int i = 0; i < tagsAry.length(); i++){ 
					Set rsTag=Etn.execute("select label from "+preprodcatalogdb+"tags where id="+escape.cote(tagsAry.getString(i)));
					if(rsTag.next()) json.put(parseNull(rsTag.value("label")),true);
				}
				}catch(Exception tmpExp2){}

				Set rsContentTags = Etn.execute("select * from "+pagesdb+"pages_tags where page_type='structured' and page_id="+escape.cote(contentId));
				while(rsContentTags.next()){
					Set rsTag=Etn.execute("select label from "+preprodcatalogdb+"tags where id="+escape.cote(rsContentTags.value("tag_id")));
					if(rsTag.next()) json.put(parseNull(rsTag.value("label")),true);
				}

				try {
				JSONArray specsAry = varObj.getJSONArray("product_variants_variant_x_specifications").getJSONObject(0).getJSONArray("product_variants_variant_x_specifications_x_spec");
				for(int i=0;i<specsAry.length();i++) {
					JSONObject specObj = specsAry.getJSONObject(i);
					if(specObj.optString("is_indexed","1").equals("1"))
						json.put(specObj.getString("label")+"."+specObj.getString("value"),specObj.getString("spec_value"));
				}
				}catch(Exception tmpExp1){}

				String queryParam="";
				JSONArray atrAry = varObj.optJSONArray("product_variants_variant_x_attributes");
				if(atrAry!=null) {
				for(int i=0;i<atrAry.length();i++) {
					JSONObject atrObj = atrAry.getJSONObject(i);
					
					String atrName = atrObj.getString("name").toLowerCase();
					String atrValue = atrObj.getString("value");
					String atrLabel = atrObj.getString("label");
					String atrUnit = atrObj.getString("unit");
					if(atrName.equals("color")) {
						json.put(atrName,atrLabel);
						json.put("colorCode",atrValue);

						queryParam = addParam(atrName,atrLabel,queryParam);
						queryParam = addParam("colorCode",atrValue,queryParam);
					}  else if(atrName.equals("storage")) {
						int storage = 0;
						try { storage = Integer.parseInt(atrValue.replaceAll("[^0-9]", "")); } 
						catch(Exception e) { storage = 0; }

						json.put(atrName,storage);
						queryParam = addParam(atrName,storage+atrUnit,queryParam);
					} else {
						json.put(atrName,atrLabel);
						queryParam = addParam(atrName,atrLabel+atrUnit,queryParam);
					}
				}
				}

				if(!json.has("color")){
					json.put("colorCode","#000000");
					json.put("color","black");

					queryParam = addParam("color","black",queryParam);
					queryParam = addParam("colorCode","#000000",queryParam);
				}
				if(!json.has("storage")) {
					json.put("storage","0");
					queryParam = addParam("storage","0",queryParam);
				}

				JSONObject folderInfo = getFoldersHerarchy(productId,"product");
				if(folderInfo.length() > 0){
					for(String key : JSONObject.getNames(folderInfo)) { json.put(key, folderInfo.get(key)); }
				}

				json.put("system_category",categories);
				
				Set rsPagePath = Etn.execute("Select m.production_path, s.domain,s.name from site_menus m, sites s where s.id = m.site_id and m.id = " + escape.cote(this.menuid));
				rsPagePath.next();

				String domainName = rsPagePath.value("domain");
				String siteName = rsPagePath.value("name");
				String pagePath = domainName;

				if(!pagePath.endsWith("/")) pagePath+="/";
				pagePath+=rsPagePath.value("production_path");
				
				rsPagePath = Etn.execute("select path from "+pagesdb+"pages where langue_code="+escape.cote(this.langCode)+" and parent_page_id="+escape.cote(contentId));
				rsPagePath.next();

				if(!pagePath.endsWith("/")) pagePath+="/";
				pagePath+=rsPagePath.value("path")+".html";
				pagePath+="?"+queryParam;
				
				try{
				String resourcePath = domainName;
				if(!resourcePath.endsWith("/")) resourcePath+="/";
				String imageName = varObj.getJSONArray("product_variants_variant_x_image").getJSONObject(0).optString("value","");
				if(!imageName.isEmpty()){
					resourcePath+=Util.removeAccents(siteName).toLowerCase()+"/resources/"+imageName;
					json.put("image",resourcePath);
				}
				}catch(Exception tmpExp5){}
				
				json.put("href",pagePath);

				JSONObject dynamicDataToIndex = callInternalPagesApi(cid);
				if(dynamicDataToIndex != null) {

					dynamicDataToIndex = getFieldsLinearJSON(dynamicDataToIndex);
					Iterator<String> keys = dynamicDataToIndex.keys();
					while(keys.hasNext()) {
						String key = keys.next();
						Set rsReservedIds = Etn.execute("select * from "+pagesdb+"template_reserved_ids where item_id="+escape.cote(key));
						if(rsReservedIds.rs.Rows==0) json.put(key, dynamicDataToIndex.get(key));
					}
				}

				jsonArray.put(json);
			}

			JSONArray tempArray = new JSONArray(jsonArray.toString());
			for (int i = 0; i < jsonArray.length(); i++) {
				JSONObject jsonObject = jsonArray.getJSONObject(i);
				jsonObject.put("modelVariants", tempArray);
			}
		}
		System.out.println("================================End getNewProductJson=================================");
		return jsonArray;
	}	

	private JSONArray getProductVariants(String ctype, String cid, org.jsoup.nodes.Document doc) throws Exception {	
		System.out.println("================================Start getProductVariants=================================");
		
		boolean enableEcommerce =false;
		Set rsEcommerce = Etn.execute("select enable_ecommerce from "+portaldb+"sites where id="+escape.cote(this.siteid));
		rsEcommerce.next();
		if(parseNull(rsEcommerce.value("enable_ecommerce")).equals("1")){
			enableEcommerce=true;
		}
		
		if(doc!=null) 
		{
			org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleid]");
			if(eles != null && eles.size() > 0) cid = parseNull(eles.first().attr("content"));
		}else{
			Set rsTmp = Etn.execute("select content_id from "+portaldb+"cached_content_view where cached_page_id = "+escape.cote(cid)+" and site_id="+
				escape.cote(this.siteid)+" and menu_id="+escape.cote(this.menuid)+" and content_type="+escape.cote(ctype));
			if(rsTmp.next()) {
				cid= parseNull(rsTmp.value("content_id"));
			}
		}

		JSONArray jsonArray = new JSONArray();

		if(ctype.equals("structuredpage") || ctype.equals("structuredcontent") || ctype.equals("store")|| ctype.equals("page") )
		{
			JSONObject json = new JSONObject();
			json.put("category",""); json.put("brand",""); json.put("priceOneTime",0);
			json.put("priceDiscountOneTime",0); json.put("priceSubsidy",0); 
			if(enableEcommerce){
				json.put("quantityInStock",0);
			}else{
				json.put("quantityInStock",99);
			}
			json.put("description",""); json.put("parentObjectID",""); json.put("marketing_rules",new JSONArray());
			json.put("href",""); json.put("image","");
			
			jsonArray.put(json);	
		}
		else if(ctype.equals("product") || ctype.equals("offer"))
		{
			Set rsProduct = Etn.execute("select p.id as prod_id,p.show_basket,pv.uuid as variant_id,pv.id as var_id, c.name as 'catalog_name',p.brand_name,pv.price,pv.stock,p.lang_"+this.langId+
				"_name as name,p.lang_"+this.langId+"_summary as 'desc',pv.sku,pv.sticker from "+catalogdb+"product_variants pv left join "+catalogdb+
				"products p on p.id=pv.product_id left join "+catalogdb+"catalogs c on p.catalog_id=c.id where p.id="+escape.cote(cid));

			while(rsProduct.next()){
				JSONObject json = new JSONObject();

				JSONObject temp=addMarketingRules(cid,rsProduct.value("price"),rsProduct.value("sku"));

                json.put("metadescription", parseNull(rsProduct.value("desc")));
				json.put("objectID",parseNull(rsProduct.value("variant_id")));
				json.put("category",parseNull(rsProduct.value("catalog_name")));
				json.put("brand",parseNull(rsProduct.value("brand_name")));
				json.put("priceOneTime",Double.parseDouble(parseNull(rsProduct.value("price"))));

				Object value = temp.opt("priceDiscountOneTime");
				if (value instanceof Number) {
					json.put("priceDiscountOneTime",new BigDecimal(value.toString()));
				}else{
					json.put("priceDiscountOneTime",0);
				}

				if(temp.has("priceSubsidy")){
					value = temp.opt("priceSubsidy");
					if (value instanceof Number) {
						json.put("priceSubsidy",new BigDecimal(value.toString()));
					}else{
						json.put("priceSubsidy",0);
					}
				}

				if(!enableEcommerce){
					json.put("quantityInStock",99);
				}else{
					if(parseNull(rsProduct.value("show_basket")).equals("1")){
						json.put("quantityInStock",Integer.parseInt(parseNull(rsProduct.value("stock"))));
					}else{
						json.put("quantityInStock",99);
					}
				}
				
				json.put("description",parseNull(rsProduct.value("desc")));
				json.put("parentObjectID",parseNull(rsProduct.value("name")));
				json.put("marketing_rules",temp.getJSONArray("marketing_rules"));

				Set rsSticker = Etn.execute("select sname,color from "+catalogdb+"stickers where sname="+escape.cote(parseNull(rsProduct.value("sticker")))+
					" and site_id="+escape.cote(this.siteid));
				if(rsSticker.next()){
					json.put("stickersLabel",parseNull(rsSticker.value("sname")));
					json.put("stickersColor",parseNull(rsSticker.value("color")));
				}else{
					json.put("stickersLabel","");
					json.put("stickersColor","");
				}
				
				String queryParam="";
				Set rsAtr = Etn.execute("SELECT ca.name,cav.attribute_value,cav.color FROM "+catalogdb+"product_variant_ref pvr "
					+"LEFT JOIN "+catalogdb+"catalog_attributes ca ON ca.cat_attrib_id=pvr.cat_attrib_id "
					+"LEFT JOIN "+catalogdb+"catalog_attribute_values cav ON cav.id=pvr.catalog_attribute_value_id "
					+"WHERE ca.type='selection' AND pvr.product_variant_id="+escape.cote(parseNull(rsProduct.value("var_id")))
					+" AND COALESCE(cav.attribute_value,'')!=''");
				while(rsAtr.next()){
					if(parseNull(rsAtr.value("name")).equalsIgnoreCase("color")){
						if(parseNull(rsAtr.value("color")).length()==0){
							json.put("colorCode","#000000");
							json.put("color","black");
							
							queryParam = addParam("color","black",queryParam);
							queryParam = addParam("colorCode","#000000",queryParam);
						}else{
							json.put("colorCode",parseNull(rsAtr.value("color")));
							json.put("color",parseNull(rsAtr.value("attribute_value")));

							queryParam = addParam("colorCode",parseNull(rsAtr.value("color")),queryParam);
							queryParam = addParam("color",parseNull(rsAtr.value("attribute_value")),queryParam);
						}
					}else if(parseNull(rsAtr.value("name")).equalsIgnoreCase("storage")){
						if(parseNull(rsAtr.value("attribute_value")).replaceAll("[^0-9]", "").length()==0){
							json.put("storage",0);
							queryParam = addParam("storage","0GB",queryParam);
						}else{
							json.put("storage",Integer.parseInt(parseNull(rsAtr.value("attribute_value")).replaceAll("[^0-9]", "")));
							queryParam = addParam("storage",parseNull(rsAtr.value("attribute_value")),queryParam);
						}
					}else{
						json.put(parseNull(rsAtr.value("name")).toLowerCase(),parseNull(rsAtr.value("attribute_value")));
						queryParam = addParam(parseNull(rsAtr.value("name")).toLowerCase(),parseNull(rsAtr.value("attribute_value")),queryParam);
					}
				}

				if(!json.has("color")){
					json.put("colorCode","#000000");
					json.put("color","black");
				}
				if(!json.has("storage")){
					json.put("storage",0);
				}

				if(doc!=null) 
				{
					Map<String, String> map = getMetaInfo(doc);
					json.put("href",urlprefix + map.get("eleurl")+"?"+queryParam);
					String picUrl = "";
					org.jsoup.select.Elements eles = doc.select("meta[name=etn:eleimage]");
					if(eles != null && eles.size() > 0) picUrl = parseNull(eles.first().attr("content"));
					
					json.put("image",picUrl);

				}
				Set rsTag=Etn.execute("select label from "+preprodcatalogdb+"tags where id in (select tag_id from "+catalogdb+"product_tags where product_id="+escape.cote(cid)+")");
				while(rsTag.next()){
					json.put(parseNull(rsTag.value("label")),true);
				}

				JSONObject folderInfo = getFoldersHerarchy(cid,"product");
				if(folderInfo.length() > 0){
					for(String key : JSONObject.getNames(folderInfo))
					{
						json.put(key, folderInfo.get(key));
					}
				}
				
				jsonArray.put(json);
			}

			JSONArray tempArray = new JSONArray(jsonArray.toString());
			
			for (int i = 0; i < jsonArray.length(); i++) {
				JSONObject jsonObject = jsonArray.getJSONObject(i);
				jsonObject.put("modelVariants", tempArray);
			}
		}
		System.out.println("================================End getProductVariants=================================");
		return jsonArray;
	}

	private JSONObject getFoldersInfo(String folderId,String catalogId,String db,String type) {
		JSONObject tmpObj = new JSONObject();
		try {
			if(type.equals("product")) {
				if(folderId.equals("0")) {
					Set rs = Etn.execute("select name from "+db+"catalogs where id="+escape.cote(catalogId));
					if(rs.next()) tmpObj.put("systemFolder",rs.value("name"));
				} else {
					Set rs = Etn.execute("select id,name,parent_folder_id from "+db+"products_folders where id="+escape.cote(folderId));
					if(rs.next()) {
						tmpObj = getFoldersInfo(rs.value("parent_folder_id"),catalogId,db,type);
						
						String subFolder="system";
						for(int i=0;i<tmpObj.length();i++) { subFolder+="Sub"; }
						subFolder+="Folder";
						
						tmpObj.put(subFolder,rs.value("name"));
					}
				}
			} else {
				Set rs = Etn.execute("select id,name,parent_folder_id from "+db+"folders where id="+escape.cote(folderId));
				if(rs.next()) {
					if(!rs.value("parent_folder_id").equals("0")) {
						
						tmpObj = getFoldersInfo(rs.value("parent_folder_id"),catalogId,db,type);
						
						String subFolder="system";
						for(int i=0;i<tmpObj.length();i++) { subFolder+="Sub"; }
						subFolder+="Folder";

						tmpObj.put(subFolder,rs.value("name"));
					} 
					else tmpObj.put("systemFolder",rs.value("name"));
				}
			}
		} catch(Exception e) { e.printStackTrace(); }
		return tmpObj;
	}

	private JSONObject getFoldersHerarchy(String id, String type) {
		JSONObject obj = new JSONObject();
		if(type.equals("store")) {
			Set rs = Etn.execute("select folder_id from "+pagesdb+"structured_contents_published where uuid="+escape.cote(id));
			if(rs.next() && !rs.value("folder_id").equals("0")) obj = getFoldersInfo(rs.value("folder_id"),"",pagesdb,type);
			
		} else if(type.equals("page")) {
			Set rs = Etn.execute("select folder_id from "+pagesdb+"pages where id="+escape.cote(id));
			if(rs.next() && !rs.value("folder_id").equals("0")) obj = getFoldersInfo(rs.value("folder_id"),"",pagesdb,type);
			
		} else if(type.equals("product")) {
			Set rs = Etn.execute("select folder_id,catalog_id from "+catalogdb+"products where id="+escape.cote(id));
			if(rs.next()) obj = getFoldersInfo(rs.value("folder_id"),rs.value("catalog_id"),catalogdb,type);
		}
		return obj;
	}

	private Map<String, String> getMetaInfo(org.jsoup.nodes.Document doc) {
		Map<String, String> map = new HashMap<String, String>();
		org.jsoup.select.Elements eles = doc.select("meta[name=etn:eletype]");
		String eletype = parseNull(eles.first().attr("content"));
		map.put("eletype", eletype);
		
		String eletags = "";
		eles = doc.select("meta[name=etn:eletaglabel]");
		if(eles != null && eles.size() > 0) eletags = parseNull(eles.first().attr("content"));
		map.put("eletags", eletags);

		String descr = "";
		eles = doc.select("meta[name=description]");
		if(eles != null && eles.size() > 0) descr = parseNull(eles.first().attr("content"));
		map.put("descr", descr);

		String eleurl = "";
		eles = doc.select("meta[name=etn:eleurl]");
		if(eles != null && eles.size() > 0) eleurl = parseNull(eles.first().attr("content"));
		map.put("eleurl", eleurl.toLowerCase());

		String eleid = "";
		eles = doc.select("meta[name=etn:eleid]");
		if(eles != null && eles.size() > 0) eleid = parseNull(eles.first().attr("content"));
		map.put("eleid", eleid);

		String elename = "";
		if("commercialcatalog".equals(eletype)) eles = doc.select("meta[name=etn:pname]");
		else eles = doc.select("meta[name=etn:elename]");
		if(eles != null && eles.size() > 0) elename = parseNull(eles.first().attr("content"));				
		map.put("elename", elename);

		String catalogtype = "";
		if("commercialcatalog".equals(eletype)) 
		{
			eles = doc.select("meta[name=etn:ctype]");
			if(eles != null && eles.size() > 0) catalogtype = parseNull(eles.first().attr("content"));
		}
		map.put("catalogtype", catalogtype);
	
		return map;
	}	

	private JSONObject callInternalPagesApi(String cid)
	{
		try
		{
			log("callInternalPagesApi::cid="+cid);
			String url = env.getProperty("PAGES_INDEXED_DATA_API");
			url += "?siteId="+this.siteid+"&lang="+this.langCode+"&contentId="+cid+"&tm="+System.currentTimeMillis();

			String _jsonStr = Jsoup.connect(url).ignoreContentType(true).execute().body();
			JSONObject json = new JSONObject(_jsonStr);

			if(json.getInt("status") == 1)
			{
				return json.getJSONObject("data").getJSONObject("content_data");
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();			
		}
		return null;		
	}
	
    private JSONObject getFieldsLinearJSON(JSONObject obj) throws Exception
	{
		JSONObject retObj = new JSONObject();

		Iterator<String> keys = obj.keys();
		while(keys.hasNext())
		{
			String key = keys.next();
			Object curVal = obj.get(key);
			boolean isSection = false;

			if(curVal instanceof JSONObject)
			{
				//its a section
				JSONObject sectionFields = getFieldsLinearJSON((JSONObject) curVal);
				Iterator<String> secKeys = sectionFields.keys();
				while(secKeys.hasNext())
				{
					String secKey = secKeys.next();
					putValueInLinearJSON(retObj, secKey, sectionFields.get(secKey));
				}
			}
			else if(curVal instanceof JSONArray)
			{
				for(int i=0; i < ((JSONArray)curVal).length(); i++)
				{
					Object arrayItem = ((JSONArray)curVal).get(i);
					if(arrayItem instanceof JSONObject)
					{
						//its a section
						JSONObject sectionFields = getFieldsLinearJSON((JSONObject) arrayItem);
						Iterator<String> secKeys = sectionFields.keys();						
						while(secKeys.hasNext())
						{
							String secKey = secKeys.next();
							putValueInLinearJSON(retObj, secKey, sectionFields.get(secKey));
						}
					}
					else
					{
						putValueInLinearJSON(retObj, key, arrayItem);
					}
				}
			}
			else 
			{
				putValueInLinearJSON(retObj, key, curVal);
			}
		}

		return retObj;
	}

	private void putValueInLinearJSON(JSONObject obj, String key, Object val) throws Exception
	{
		Object targetVal = obj.opt(key);
		if(targetVal == null)
		{
			obj.put(key,val);
		}
		else if(targetVal instanceof JSONArray)
		{
			//target is array, append value to it
			((JSONArray)targetVal).put(val);
		}
		else
		{
			// key already exist
			//convert value to array , append old value then new value
			JSONArray valList = new JSONArray();
			valList.put(targetVal).put(val);
			obj.put(key, valList);
		}
	}	
	
	/*private HttpURLConnection openUrlConnection(URL url) throws Exception
	{
		String proxyhost = parseNull(env.getProperty("HTTP_PROXY_HOST"));
		String proxyport = parseNull(env.getProperty("HTTP_PROXY_PORT"));
		final String proxyuser = parseNull(env.getProperty("HTTP_PROXY_USER"));
		final String proxypasswd = parseNull(env.getProperty("HTTP_PROXY_PASSWD"));

		HttpURLConnection htp = null;
	
		if(proxyhost.length() > 0 )
		{
			java.net.Proxy proxy = new java.net.Proxy(java.net.Proxy.Type.HTTP, new java.net.InetSocketAddress (proxyhost, Integer.parseInt(proxyport)));			

			if(proxyuser.length() > 0)
			{
				java.net.Authenticator authenticator = new java.net.Authenticator() {
					public java.net.PasswordAuthentication getPasswordAuthentication() {
						return (new java.net.PasswordAuthentication(proxyuser, proxypasswd.toCharArray()));
					}
				};
				java.net.Authenticator.setDefault(authenticator);
			}

			htp = (HttpURLConnection) url.openConnection(proxy);
		}
		else htp = (HttpURLConnection) url.openConnection();
		
		return htp;
	}*/
}