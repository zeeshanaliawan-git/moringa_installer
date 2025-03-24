package com.etn.pages;

import com.etn.beans.Etn;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.util.ApiCaller;
import com.etn.util.Util;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.Normalizer;
import java.util.*;

public class PartooV2 implements PartooInterface
{ 
	private Properties env;
	private com.etn.beans.Etn Etn;
	private boolean debug;
	private String cacheBaseDir = "";	
	private String partooApiUrl = "";
	
	private ApiCaller apiCaller;
	
	private boolean useProxy = true;//by default we assume we will use proxy if its configured
	List<PartooGroup> countryFolders;

	public PartooV2(Etn Etn, Properties env, boolean debug) throws Exception
	{
		this.Etn = Etn;
		this.env = env;
		this.debug = debug;
		
		Etn.setSeparateur(2, '\001', '\002');
		
		cacheBaseDir = getPortalConfig("PROD_CACHE_FOLDER");
		if(cacheBaseDir.endsWith("/") == false) cacheBaseDir += "/";
		
		partooApiUrl = Util.parseNull(env.getProperty("partoo_api_base_url"));
		if(partooApiUrl.endsWith("/") == false) partooApiUrl += "/";
		
		if("false".equalsIgnoreCase(env.getProperty("partoo_api_use_proxy")) || "0".equals(env.getProperty("partoo_api_use_proxy"))) useProxy = false;
		
		apiCaller = new ApiCaller(Etn, env, true);
		countryFolders = new ArrayList<>();
	}

	private String getCachedResourcesUrl(Etn Etn, String siteid, String sitename)
	{
		Set rs = Etn.execute("select * from "+env.getProperty("PORTAL_DB")+".config where code = 'PROD_SEND_REDIRECT_LINK'");
		rs.next();
		String url = Util.parseNull(rs.value("val"));
		if(!url.endsWith("/")) url += "/";				
		
		url += Util.getSiteFolderName(sitename) + "/resources/";
		return url;
	}

	private String getPortalConfig(String config)
	{
		Set rs = Etn.execute("select * from "+env.getProperty("PORTAL_DB")+".config where code = "+escape.cote(config));
		if(rs.next()) return Util.parseNull(rs.value("val"));
		return "";
	}

	private void log(String m)
	{
		if(debug == false) return;
		logE(m);
	}

	private void logE(String m)
	{
		System.out.println("PartooV2::----------------- " + m);
	}
	
	private JSONObject callApi(String _url, String method, String apiKey, String params, String procedureName)
	{
		JSONObject jResponse = null;
		try 
		{
			Map<String, String> requestHeaders = new HashMap<>();
			requestHeaders.put("Accept","application/json");
			requestHeaders.put("x-APIKey", apiKey);
			if("post".equalsIgnoreCase(method) || "put".equalsIgnoreCase(method))
			{				
				requestHeaders.put("Content-Type","application/json");
			}
			
			jResponse = apiCaller.callApi(procedureName, _url, method, params, requestHeaders, useProxy);
			
		}
		catch(Exception e)
		{
			log("callApi::some exception occurred");
			e.printStackTrace();
			jResponse = new JSONObject();
			jResponse.put("status", 2000);
			apiCaller.addLogEntry(procedureName, e.getMessage());
		}
		return jResponse;		
	}

	private JSONArray getBusinesses(String apiKey, String sectionId, String groupId)
	{
		try
		{
			log("In getBusinesses :: ");
			String _url = partooApiUrl + "sections/"+sectionId+"/groups/"+groupId;
			log(_url);
			JSONObject apiResponse = callApi(_url, "GET", apiKey, "", "Partoo.getBusinesses");
			if(apiResponse.getInt("http_code") == 200)
			{
				JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));							
				if(partooJsonResponse.has("business_ids") == false || partooJsonResponse.getJSONArray("business_ids").length() == 0) return new JSONArray();
				return partooJsonResponse.getJSONArray("business_ids");
			}
		}
		catch(Exception e)
		{
			log("Error in getBusinesses");
			e.printStackTrace();
		}
		return new JSONArray();
	}

	private List<String> getSectionBusinesses(List<PartooGroup> groups)
	{
		List<String> businesses = new ArrayList<>();
		for (PartooGroup grp : groups) {
			businesses.addAll(grp.getBusinesses());
		}
		return businesses;
	}

	private void mergeBusinesses(PartooGroup pg,List<String> businesses)
	{
		log(" :: mergeBusinesses ::");
		HashSet<String> businessList = new HashSet<>();
		businessList.addAll(pg.getBusinesses());
		businessList.addAll(businesses);
		pg.setBusinesses(new JSONArray(businessList));
	}

	private int createMainGroup(List<PartooGroup> groups,String groupName, String siteid,Map<String, String> partooInfo)
	{
		return createMainGroup(groups, groupName, siteid, partooInfo.get("section_id"), partooInfo);
	}

	private int createMainGroup(List<PartooGroup> groups,String groupName, String siteid,String sectionId,Map<String, String> partooInfo)
	{
		log("In createMainGroup");
		int groupId = -1;
		try
		{
			PartooGroup group = getGroupByName(groups, groupName);
			if(group == null)
			{
				log("Main group not found ... creating group : "+ groupName);

				String u = partooApiUrl + "sections/"+sectionId+"/groups";
				JSONObject json = new JSONObject();					
				json.put("name", groupName);
				json.put("business__in", new JSONArray());
				log(json.toString());
				
				JSONObject apiResponse = callApi(u, "post", partooInfo.get("api_key"), json.toString(), "Partoo.createMainGroup");
				
				if(apiResponse.getInt("http_code") == 200)
				{
					JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
					groupId = partooJsonResponse.getInt("id");
					PartooGroup pg = new PartooGroup(groupId, groupName);
					groups.add(pg);
				}
				else
				{
					log("Error creating main group");
				}
			}
			else 
			{
				log("Main group already exists");
				groupId = group.getId();
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			groupId = -1;
		}
		return groupId;
	}

	private List<PartooGroup> populateGroups(List<PartooGroup> groups, String apiKey,String sectionId)
	{
		try
		{
			log("In populateGroups :: ");
			String _url = partooApiUrl + "sections/"+sectionId;
			log(_url);
			JSONObject apiResponse = callApi(_url, "GET", apiKey, "", "Partoo.populateGroups");
			if(apiResponse.getInt("http_code") == 200)
			{
				JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));														
				if(partooJsonResponse.has("groups") == false || partooJsonResponse.getJSONArray("groups").length() == 0) return groups;
				
				for(int idx=0; idx<partooJsonResponse.getJSONArray("groups").length(); idx++) {

					JSONObject group = partooJsonResponse.getJSONArray("groups").getJSONObject(idx);
					PartooGroup pg = new PartooGroup(group.getInt("id"), group.getString("name"));
					JSONArray businesses = getBusinesses(apiKey, sectionId, pg.getId()+"");
					pg.setBusinesses(businesses);
					groups.add(pg);
				}
			}
		}
		catch(Exception e)
		{
			log("Error in populateGroups");
			e.printStackTrace();
		}
		log("Groups size : " + groups.size());
		return groups;
	}	
		
	public void process()
	{
		//NOTE:: there can be case that someone publish the store/folder twice and engine did not run yet.
		//in this case we have more than 1 rows for same store/folder in the publish table so we should call api once rather making repeated
		//api calls ... so we will maintain a list of processed stores/folders and make sure we have called the api for it already then we ignore for next time
		
		List<String> processedStores = new ArrayList<>();
		List<String> processedFolders = new ArrayList<>();
		
		Map<String, Map<String, String>> sitesInfo = new HashMap<>();
		Map<String,Map<String, List<PartooGroup>>> sectionsInfo = new HashMap<>();
		Map<String,Map<String, HashSet<PartooGroup>>> sectionsGroupsUpdate = new HashMap<>();
		
		
		//order by is important as a folder can have sub-folders so parent folder must be created first in partoo
		String qry; 
		Set rs = Etn.execute(qry= "Select pp.id, pp.cid, pp.ctype, pp.status, pp.attempt,pp.site_id, s.name, s.domain, s.partoo_activated, s.partoo_api_key,s.partoo_country_code,s.partoo_organization_id,s.partoo_main_group,s.partoo_language_id"
			+",l.langue_code as partoo_language_code, l.langue_id from partoo_publish pp inner join "+env.getProperty("PORTAL_DB")+".sites s on pp.site_id = s.id "
			+" left join language l on l.langue_id = s.partoo_language_id"
			+" where pp.status = 0 and pp.attempt < 5 and s.partoo_activated='1' AND COALESCE(s.partoo_country_code, '') != '' AND COALESCE(s.partoo_main_group, '') != ''  order by pp.ctype desc,pp.id,pp.site_id");		

		log("query: " + qry);
		while(rs.next())
		{
			//some tasks take time in pages module so we must set the engine status at such points
			if (env != null) //this means its running from engine 
			{
				Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Partoo',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
			}
			
			Etn.executeCmd("update partoo_publish set attempt = attempt + 1, updated_ts = now() where id = "+escape.cote(rs.value("id")));

			String siteid = rs.value("site_id");			
			String cid = rs.value("cid");
			String ctype = rs.value("ctype");

			List<PartooGroup> groups = null;
			
			if("store".equalsIgnoreCase(ctype) && processedStores.contains(cid))
			{
				log("store is already processed. Lets not call api again and mark status to 2");
				Etn.executeCmd("update partoo_publish set status = 2 where id ="+escape.cote(rs.value("id")));
			}
			else if("folder".equalsIgnoreCase(ctype)&& processedFolders.contains(cid))
			{
				log("folder is already processed. Lets not call api again and mark status to 2");
				Etn.executeCmd("update partoo_publish set status = 2 where id ="+escape.cote(rs.value("id")));
			}
			else
			{
				log("process cid : " + cid + " ctype : " + ctype + " site_id : " + siteid);
				
				if(sitesInfo.get(siteid) == null)
				{
					Map<String, String> partooInfo = new HashMap<>();
					partooInfo.put("name", Util.parseNull(rs.value("name")));
					partooInfo.put("domain", Util.parseNull(rs.value("domain")));
					partooInfo.put("activated", Util.parseNull(rs.value("partoo_activated")));
					partooInfo.put("api_key", Util.parseNull(rs.value("partoo_api_key")));
					partooInfo.put("country_code", Util.parseNull(rs.value("partoo_country_code")));
					partooInfo.put("main_group", Util.parseNull(rs.value("partoo_main_group")));
					partooInfo.put("org_id", Util.parseNull(rs.value("partoo_organization_id")));
					partooInfo.put("langue_id", Util.parseNull(rs.value("partoo_language_id")));
					partooInfo.put("langue_code", Util.parseNull(rs.value("partoo_language_code")));
					groups = new ArrayList<>();

					String sectionName = partooInfo.get("main_group");
					int sectionId = -1;
					if(sectionName.length() > 0)
					{
						sectionId = createSection(sectionName, siteid, partooInfo);
						if(sectionId > 0)
						{
							partooInfo.put("section_id", ""+sectionId);
							int parentSectionId = createSection("Country", null, partooInfo);
							partooInfo.put("parent_section_id", ""+parentSectionId);
							populateGroups(countryFolders, partooInfo.get("api_key"), parentSectionId + "");
							if(getGroupByName(countryFolders, sectionName) == null) createMainGroup(countryFolders, sectionName, siteid, parentSectionId +"" ,partooInfo);

							populateGroups(groups, partooInfo.get("api_key"), sectionId+"");

							Map<String,List<PartooGroup>> sec = new HashMap<String,List<PartooGroup>>();
							sec.put(sectionName,groups);
							sectionsInfo.put(siteid,sec);
						}
						else
						{
							log("-----------------------");
							log("ERROR::Unable to find the section against section : " + sectionName);							
							log("-----------------------");
						}
					}
					sitesInfo.put(siteid, partooInfo);
				}
				//section ID and main group ID is mandatory
				if(Util.parseNullInt(sitesInfo.get(siteid).get("section_id")) <= 0)
				{
					log("-----------------------"+siteid);
					log("ERROR::Section ID OR main group ID is empty ... we cannot continue processing this row ... we will retry it next time");
					log("-----------------------");
				}
				else
				{
					Map<String, List<PartooGroup>> tmpGrp = sectionsInfo.get(siteid);
					groups = tmpGrp.get(sitesInfo.get(siteid).get("main_group"));

					boolean ret = false;
					if(sectionsGroupsUpdate.get(siteid) == null) sectionsGroupsUpdate.put(siteid,new HashMap<>());
					if("folder".equalsIgnoreCase(ctype))
					{
						ret = processFolder(groups, cid, siteid, sitesInfo.get(siteid));
						// ret=true;
					}
					else if("store".equalsIgnoreCase(ctype))
					{
						ret = processStore(groups, sectionsGroupsUpdate.get(siteid),cid, siteid, sitesInfo.get(siteid));
					}
					if(ret == true)
					{
						if("store".equalsIgnoreCase(ctype)) processedStores.add(cid);
						else if("folder".equalsIgnoreCase(ctype)) processedFolders.add(cid);
						
						Etn.executeCmd("update partoo_publish set status = 2 where id ="+escape.cote(rs.value("id")));
					}
				}
				// updating Country Section 
				PartooGroup pg = getGroupByName(countryFolders,sitesInfo.get(siteid).get("main_group"));
				if(pg != null) mergeBusinesses(pg, getSectionBusinesses(groups));
			}
		}


		// updating groups one by one 
		for (String key : sitesInfo.keySet()) {
			String siteid = key;
			String apiKey = sitesInfo.get(siteid).get("api_key");
			String sectionName = sitesInfo.get(siteid).get("main_group");
			String sectionId = sitesInfo.get(siteid).get("section_id");
			Map<String,HashSet<PartooGroup>> sectionsGrMap = sectionsGroupsUpdate.get(siteid);
			PartooGroup pg = getGroupByName(countryFolders,sitesInfo.get(siteid).get("main_group"));
			updateGroupPartoo(pg, sitesInfo.get(siteid).get("parent_section_id"), sitesInfo.get(siteid).get("api_key"),false);

			if(sectionsGrMap == null){ 
				log("sectionGrMap is null siteid ::"+siteid);
				continue;
			}
            HashSet<PartooGroup> grps = sectionsGrMap.get(sectionName);
			if(grps == null) {
				log("grps is null sectionName ::"+sectionName);
				continue;
			}

			for (PartooGroup grp : grps) {
				log("Group updating : " + grp.getId() + " :: " + grp.getName() );
				updateGroupPartoo(grp, sectionId, apiKey);
            }

        }
		
	}
	
	private void updateGroupId(List<String> businesses, String groupId)
	{
		for(String business: businesses)
		{
			Etn.execute("update partoo_contents set group_id="+escape.cote(groupId)+" where ctype='store' and partoo_id="+escape.cote(business));
		}
	}

	private boolean updateGroupPartoo(PartooGroup grp, String sectionId, String apiKey)
	{
		return updateGroupPartoo(grp,sectionId,apiKey,true);
	}

	private boolean updateGroupPartoo(PartooGroup grp, String sectionId, String apiKey,boolean updateDb)
	{
		try
		{
			log("In updateGroupPartoo :: " + sectionId);
			String _url = partooApiUrl + "sections/"+sectionId+"/groups/"+grp.getId();
			
			JSONObject rjson = new JSONObject();
			rjson.put("name", grp.getName());
			rjson.put("business__in", new JSONArray(grp.getBusinesses()));

			JSONObject apiResponse = callApi(_url, "POST", apiKey, rjson.toString() , "Partoo.updateGroupPartoo");
			if(apiResponse.getInt("http_code") == 200)
			{
				JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
				if(updateDb){
				updateGroupId(grp.getBusinesses(), partooJsonResponse.getInt("id")+"");
				int res = Etn.executeCmd("UPDATE partoo_contents set rjson="+Util.escapeCote3(rjson.toString())+", partoo_json="+Util.escapeCote3(grp.getJSON().toString())+" where partoo_id="+escape.cote(partooJsonResponse.getInt("id")+""));	
				if(res > 0) return true;
				}else return true;
			}
		}
		catch(Exception e)
		{
			log("Error in updateGroupPartoo");
			e.printStackTrace();
		}
		return false;
	}

	private JSONObject getSectionByName(String apiKey, String orgId, String sectionName, int pageNum)
	{
		try
		{
			log("In getSectionByName :: " + sectionName);
			String _url = partooApiUrl + "sections?org_id="+orgId+"&page="+pageNum;
			JSONObject apiResponse = callApi(_url, "GET", apiKey, "", "Partoo.getSectionByName");
			if(apiResponse.getInt("http_code") == 200)
			{
				JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));							
				if(partooJsonResponse.has("sections") == false || partooJsonResponse.getJSONArray("sections").length() == 0) return null;
							
				for(int i=0;i<partooJsonResponse.getJSONArray("sections").length();i++)
				{
					JSONObject sec = partooJsonResponse.getJSONArray("sections").getJSONObject(i);
					if(sectionName.equalsIgnoreCase(Util.parseNull(sec.getString("name"))))
					{
						return sec;
					}
					
				}
				return getSectionByName(apiKey, orgId, sectionName, pageNum+1);
			}
			else
			{
				return null;
			}
		}
		catch(Exception e)
		{
			log("Error in getSectionByName");
			e.printStackTrace();
		}
		return null;
	}

	private int getSectionBySiteId(String siteId)
	{
		Set rs = Etn.execute("SELECT * FROM partoo_contents where ctype='section' and site_id="+escape.cote(siteId));
		rs.next();
		return Util.parseNullInt(rs.value("partoo_id"),-1);
	}
	
	private int createSection(String sectionName, String siteid, Map<String, String> partooInfo)
	{
		log("In createSection");
		int sectionId = -1;
		try
		{
			if(siteid != null){
			sectionId = getSectionBySiteId(siteid);
			if(sectionId > 0) return sectionId;
			}

			JSONObject section = getSectionByName(partooInfo.get("api_key"),partooInfo.get("org_id"),sectionName,1);
			if(section == null)
			{
				log("Section not found ... creating section : "+ sectionName);

				String u = partooApiUrl + "sections";

				JSONObject json = new JSONObject();					
				json.put("name", sectionName);
                json.put("org_id", partooInfo.get("org_id"));
				log(json.toString());
				
				JSONObject apiResponse = callApi(u, "post", partooInfo.get("api_key"), json.toString(), "Partoo.createSection");
				
				if(apiResponse.getInt("http_code") == 200)
				{
					JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
					sectionId = partooJsonResponse.getInt("id");
					if(siteid != null){
					Etn.executeCmd("insert into partoo_contents(ctype,site_id,partoo_id,rjson,partoo_json)"
						+" VALUES('section',"+escape.cote(siteid)+","+escape.cote(sectionId+"")+","+Util.escapeCote3(json.toString())+","+Util.escapeCote3(partooJsonResponse.toString())+") "
						+" ON DUPLICATE KEY UPDATE ctype=VALUES(ctype),site_id=VALUES(site_id),partoo_id=VALUES(partoo_id),rjson=VALUES(rjson),partoo_json=VALUES(partoo_json)"); 
				}
				}
				else
				{
					log("Error creating Section");
				}
			}
			else 
			{
				log("Section already exists");
				sectionId = section.getInt("id");
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			sectionId = -1;
		}
		return sectionId;
	}
	
	private boolean processFolder(List<PartooGroup> groups,String folderId, String siteid, Map<String, String> siteInfo)
	{
		log("In processFolder");
		try
		{
			//it was decided that the second level of folder in asimina will never be created in partoo as that is not possible by partoo to handle
			//so if we have main group lets say Orange MEA ... and we create a folder in stores as Ivory Coast and inside that folder we create 
			//more folders corresponding to the states of ivory coast, then these states folder will never be created in partoo and we will simply ignore them
						
			boolean deleteFolder = false;
			Set rs = Etn.execute("select c.*, p.id as folder_id from partoo_contents c left join stores_folders p on p.id = c.cid where c.site_id = "+escape.cote(siteid)+" and c.ctype = 'folder' and c.cid = "+escape.cote(folderId));
			if(rs.rs.Rows > 0)
			{
				rs.next();
				if(Util.parseNull(rs.value("folder_id")).length() == 0) deleteFolder = true;
			}
			
			if(deleteFolder)
			{
				log("Delete folder");
				String partooId = Util.parseNull(rs.value("partoo_id"));
				if(partooId.length() > 0)
				{
					String u = partooApiUrl + "sections/" + siteInfo.get("section_id") + "/groups/" + partooId;
					JSONObject apiResponse = callApi(u, "get", siteInfo.get("api_key"), "", "Partoo.processFolder");
					if(apiResponse.getInt("http_code")==200)
					{
						JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
						if(partooJsonResponse.getJSONArray("business_ids") == null || partooJsonResponse.getJSONArray("business_ids").length() == 0) 
						{
							log("Business list for group id "+partooId+ " is empty. Try deleting from partoo");
							apiResponse = callApi(u, "delete", siteInfo.get("api_key"), "", "Partoo.processFolder");
							if(apiResponse.getInt("http_code")==200)
							{
								partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));			
								if(Util.parseNull(partooJsonResponse.optString("status")).equalsIgnoreCase("success"))
								{
									log("Folder deleted from partoo. Delete locally as well");
								}
								PartooGroup pg = getGroupById(groups,Util.parseNullInt(partooId));
								groups.remove(pg);
							}
						}
						Etn.executeCmd("delete from partoo_contents where site_id = "+escape.cote(siteid)+" and ctype = 'folder' and cid = "+escape.cote(folderId));
					}					
				}
				return true;				
			}
			else			
			{								
				rs = Etn.execute("Select * from stores_folders where id = "+escape.cote(folderId));
				if(rs.next())
				{
					log("Add/update folder");					
					//create/update group
					if(Util.parseNullInt(rs.value("parent_folder_id")) > 0)
					{
						log("Its a sub-folder so we will ignore this to be added to partoo");
						return true;
					}

					String partooId = "";					
					Set rsPs = Etn.execute("Select * from partoo_contents where site_id = "+escape.cote(siteid)+" and ctype = 'folder' and cid = "+escape.cote(folderId));
					if(rsPs.next())
					{
						partooId = Util.parseNull(rsPs.value("partoo_id"));
					}									
					String folderName = Util.parseNull(rs.value("name"));

					JSONObject json = new JSONObject();					
					json.put("name", folderName);
					json.put("business__in", new JSONArray());
										
					if(partooId.length() == 0)
					{
						PartooGroup group = getGroupByName(groups, folderName);
						if(group != null)//group already exists
						{
							log("New group already exists in partoo");
							json.put("business__in",new JSONArray(group.getBusinesses()));
							Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_id, rjson, partoo_json) values ("+escape.cote(siteid)+", 'folder', "+escape.cote(folderId)+", "+escape.cote(""+group.getId())+", "+Util.escapeCote3(json.toString())+", "+Util.escapeCote3(group.getJSON().toString())+") on duplicate key update partoo_id = "+escape.cote(""+group.getId())+", partoo_error = '', partoo_json = "+Util.escapeCote3(group.getJSON().toString())+", rjson = "+Util.escapeCote3(json.toString()));
							return true;
						}
					}

					String method = "post";
					String u = partooApiUrl+"sections/"+siteInfo.get("section_id");
					
					if(partooId.length() > 0) u += "/groups/" + partooId;
					else u += "/groups";

					log(json.toString());
					
					JSONObject apiResponse = callApi(u, method, siteInfo.get("api_key"), json.toString(), "Partoo.processFolder");
					if(apiResponse.getInt("status") == 2000)
					{
						Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_error, rjson) values ("+escape.cote(siteid)+", 'folder', "+escape.cote(folderId)+", 'some exception while calling api', "+Util.escapeCote3(json.toString())+") on duplicate key update partoo_error = 'some exception while calling api', rjson = "+Util.escapeCote3(json.toString()));
					}					
					else if(Util.parseNull(apiResponse.optString("response_content_type")).equalsIgnoreCase("application/json")==false)
					{
						Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_error, rjson) values ("+escape.cote(siteid)+", 'folder', "+escape.cote(folderId)+", 'invalid response from partoo', "+Util.escapeCote3(json.toString())+") on duplicate key update partoo_error = 'invalid response from partoo', rjson = "+Util.escapeCote3(json.toString()));
					}
					else if(apiResponse.getInt("http_code")==200)
					{
						JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
						PartooGroup pg = getGroupFromPartoo(siteInfo.get("api_key"),partooJsonResponse.getInt("id")+"",siteInfo.get("section_id"));
						groups.add(pg);
						Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_id, rjson, partoo_json) values ("+escape.cote(siteid)+", 'folder', "+escape.cote(folderId)+", "+escape.cote(Util.parseNull(partooJsonResponse.optString("id")))+", "+Util.escapeCote3(json.toString())+", "+Util.escapeCote3(pg.getJSON().toString())+") on duplicate key update partoo_id = "+escape.cote(Util.parseNull(partooJsonResponse.optString("id")))+", partoo_error = '', partoo_json = "+Util.escapeCote3(pg.getJSON().toString())+", rjson = "+Util.escapeCote3(json.toString()));
						return true;
					}
					else
					{
						Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_error, rjson) values ("+escape.cote(siteid)+", 'folder', "+escape.cote(folderId)+", "+Util.escapeCote3(Util.parseNull(apiResponse.optString("response")))+", "+Util.escapeCote3(json.toString())+") on duplicate key update partoo_error = "+Util.escapeCote3(Util.parseNull(apiResponse.optString("response")))+", rjson = "+Util.escapeCote3(json.toString()));
					}
				}
				else 
				{
					log("As folders are not added in partoo so means we have no entry in partoo_contents due to which we will reach here");
					return true;
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return false;
	}
	
	private boolean deleteStoreFromGroup(String businessId, int groupId, Map<String, String> siteInfo)
	{
		boolean ret = false;
		log("In deleteStoreFromGroup --- business id : " + businessId + " group id "+ groupId);
		try
		{
			String u = partooApiUrl + "sections/"+ siteInfo.get("section_id") +"/groups/"+groupId;
			JSONObject apiResponse = callApi(u, "get", siteInfo.get("api_key"), "", "Partoo.deleteStoreFromGroup");
			if(apiResponse.getInt("http_code")==200)
			{
				JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
				JSONArray newBusinessIds = new JSONArray();
				JSONArray businessIds = partooJsonResponse.getJSONArray("business_ids");
				for(int i=0;i<businessIds.length();i++)
				{
					if(Util.parseNull(businessIds.getString(i)).equals(businessId) == false)
					{
						newBusinessIds.put(businessIds.getString(i));
					}
				}
				
				log("New business Ids : "+newBusinessIds.toString());

				apiResponse = callApi(u, "POST", siteInfo.get("api_key"), ((new JSONObject()).put("name",partooJsonResponse.getString("name")).put("business__in", newBusinessIds)).toString(), "Partoo.deleteStoreFromGroup");
				if(apiResponse.getInt("http_code") == 200)
				{
					ret = true;
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return ret;
	}

	private PartooGroup getGroupByName(List<PartooGroup> groups, String name)
	{
		for(PartooGroup group : groups)
		{
			if(group.getName().equalsIgnoreCase(name)) return group;
		}
		return null;
	}

	private PartooGroup getGroupFromPartoo(String apiKey,String id, String sectionId)
	{
		try
		{
			log("In getGroupFromPartoo :: " + id);
			String _url = partooApiUrl + "sections/"+sectionId+"/groups/"+id;
			JSONObject apiResponse = callApi(_url, "GET", apiKey, "", "Partoo.getGroupFromPartoo");
			if(apiResponse.getInt("http_code") == 200)
			{
				JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
				return	new PartooGroup(partooJsonResponse.getInt("id"), partooJsonResponse.getString("name"));
			}
		}
		catch(Exception e)
		{
			log("Error in getGroupFromPartoo");
			e.printStackTrace();
		}
		return null;
	}

	private PartooGroup getGroupById(List<PartooGroup> groups, int id)
	{
		log("In getGroupById");
		for(PartooGroup group : groups)
		{
			if(group.getId() == id) return group;
		}
		return null;
	}

	private void addToUpdatingList(PartooGroup pg, Map<String, HashSet<PartooGroup>> sectionsGroupsUpdate ,String sectionName)
	{
		if(sectionsGroupsUpdate == null) sectionsGroupsUpdate = new HashMap<>();

		if(sectionsGroupsUpdate.containsKey(sectionName))
		{
			HashSet<PartooGroup> grp = sectionsGroupsUpdate.get(sectionName);
			grp.add(pg);
		} else {
			HashSet<PartooGroup> grp = new HashSet<PartooGroup>();
			grp.add(pg);
			sectionsGroupsUpdate.put(sectionName, grp);
		}
	}

	private List<PartooGroup> addStoreToGroup(List<PartooGroup> groups, Map<String, HashSet<PartooGroup>> sectionsGroupsUpdate, String businessId, int groupId, String sectionName)
	{
		log("In addStoreToGroup --- business id : " + businessId + " group id "+ groupId);
		PartooGroup pg = getGroupById(groups, groupId);
		if(pg == null) {
			log("addStoreToGroup group is null");
			return groups;
		}
		pg.addBusiness(businessId);
		Etn.executeCmd("update partoo_contents set group_id="+escape.cote(groupId+"")+" where ctype = 'store' and partoo_id="+escape.cote(businessId));
		addToUpdatingList(pg,sectionsGroupsUpdate,sectionName);
		return groups;
	}

	private List<PartooGroup> deleteStoreFromGroupById(List<PartooGroup> groups, Map<String, HashSet<PartooGroup>> sectionsGroupsUpdate, String businessId, int groupId, String sectionName) 
	{
		return deleteStoreFromGroupById(groups,sectionsGroupsUpdate,businessId,groupId,sectionName,true);
	}

	private List<PartooGroup> deleteStoreFromGroupById(List<PartooGroup> groups, Map<String, HashSet<PartooGroup>> sectionsGroupsUpdate, String businessId, int groupId, String sectionName, boolean toUpdate) 
	{
		log("In deleteStoreFromGroupById --- business id : " + businessId + " group id "+ groupId);
		PartooGroup pg = getGroupById(groups, groupId);
		if(pg == null) {
			log("deleteStoreFromGroupById group is null");
			return groups;
		}
		pg.removeBusiness(businessId);
		if(toUpdate){
			Etn.executeCmd("update partoo_contents set group_id=0 where ctype = 'store' and partoo_id="+escape.cote(businessId));
			addToUpdatingList(pg,sectionsGroupsUpdate,sectionName);
		}
		return groups;
	}

	private PartooGroup getGroupByBusiness(List<PartooGroup> groups, String businessId, int groupId)
	{
		log("In getGroupByBusiness :: ");
		if(groupId <= 0 ) return null;
		PartooGroup pg = getGroupById(groups, groupId);
		if(pg!=null && pg.hasBusiness(businessId)) return pg;
		return null;
	}

	private int getParentFolder(int id)
	{
		log("current_folder_id ::" +id);
		Set rsF = Etn.execute("Select * from stores_folders where id = "+escape.cote(id+""));
		if(rsF.next()){
			log("parent_folder_id ::" +Util.parseNullInt(rsF.value("parent_folder_id")));
			if(Util.parseNullInt(rsF.value("parent_folder_id")) > 0)
				return getParentFolder(Util.parseNullInt(rsF.value("parent_folder_id")));
			else
				return Util.parseNullInt(rsF.value("id"));
		} 
		return id;
	}

	private void updateStoreGroup(List<PartooGroup> groups,Map<String, HashSet<PartooGroup>> sectionsGroupsUpdate ,String folderId, String contentId, String siteId,Map<String, String> siteInfo)
	{
		log("In updateStoreGroup --- folder id : " + folderId + " content id "+ contentId);
		
		Set rs = Etn.execute("select * from partoo_contents where site_id = "+escape.cote(siteId)+" and ctype = 'store' and cid = "+escape.cote(contentId));
		rs.next();

		String partooStoreId = Util.parseNull(rs.value("partoo_id"));
		if(partooStoreId.length() == 0)
		{
			log("Store partoo id is empty");
			return;
		}
		
		int currentGroupId = Util.parseNullInt(rs.value("group_id"),0);
		PartooGroup grp = getGroupByBusiness(groups, partooStoreId, currentGroupId);
		if(grp != null) currentGroupId = grp.getId();
		
		log("currentGroupId : " + currentGroupId);

		int groupId = -1;
		if(Util.parseNull(folderId).length() > 0)
		{
			folderId = "" + getParentFolder(Util.parseNullInt(folderId));
			log("Folder ID applicable : "+folderId);
			Set rsF = Etn.execute("select * from partoo_contents where site_id = "+escape.cote(siteId)+" and ctype = 'folder' and cid = "+escape.cote(folderId));
			if(rsF.next())	groupId = Util.parseNullInt(rsF.value("partoo_id"));
		
		}
		
		log("Applicable Group ID : " + groupId);
		
		int applicableGroupId = groupId;

		log("contentId : " + contentId);
		log("currentGroupId : " + currentGroupId);
		log("Applicable Group ID : " + applicableGroupId);
		
		if(currentGroupId == applicableGroupId) return;
		 
		if(currentGroupId == 0 && applicableGroupId > 0)  
		{
			log("Add store to group");
			addStoreToGroup(groups,sectionsGroupsUpdate,partooStoreId, applicableGroupId,siteInfo.get("main_group"));
		}
		else if(currentGroupId > 0 && applicableGroupId <= 0)
		{
			log("Delete store from group");
			deleteStoreFromGroupById(groups,sectionsGroupsUpdate ,partooStoreId, currentGroupId, siteInfo.get("main_group"));
			deleteStoreFromGroupById(countryFolders,sectionsGroupsUpdate ,partooStoreId, getGroupByName(countryFolders, siteInfo.get("main_group")).getId(), siteInfo.get("main_group"),false);
		}
		else if(currentGroupId > 0 && applicableGroupId > 0)
		{
			log("Delete store from group :: "+currentGroupId);
			deleteStoreFromGroupById(groups,sectionsGroupsUpdate ,partooStoreId, currentGroupId, siteInfo.get("main_group"));
			log("Add store to group :: "+applicableGroupId);
			addStoreToGroup(groups, sectionsGroupsUpdate,partooStoreId, applicableGroupId, siteInfo.get("main_group"));
		}
	}
	
	private boolean processStore(List<PartooGroup> groups,Map<String, HashSet<PartooGroup>> sectionsGroupsUpdate,String contentId, String siteid, Map<String, String> siteInfo)
	{
		log("In processStore");
		try
		{	
			boolean deleteStore = false;
			String deleteStoreQry = "";
			Set rs = Etn.execute(deleteStoreQry="select c.*, p.id as content_id from partoo_contents c left join structured_contents_tbl p on p.id = c.cid join bloc_templates bt on bt.id=p.template_id and c.ctype = bt.type where c.site_id = "+escape.cote(siteid)+" and c.ctype = 'store' and p.publish_status='unpublished' and c.cid = "+escape.cote(contentId));
			log("deleteStore qry==============> "+deleteStoreQry);
			log("deletestore==============> "+rs.rs.Rows);
			if(rs.rs.Rows > 0)
			{
				deleteStore = true;
			}			

			log("deleting store ====> "+deleteStore);
			log("Add/Update store");

			String sitename = siteInfo.get("name");					
			String sitedomain = siteInfo.get("domain");
			
			String defaultLangCode = siteInfo.get("langue_code");
			String defaultLangId = siteInfo.get("langue_id");

			
			log("Publish in partoo for language : " + defaultLangCode);
			
			if(sitedomain.endsWith("/") == true) sitedomain = sitedomain.substring(0, sitedomain.length() - 1);

			String currentMenuPath = "";
			Set rsMenu = Etn.execute("select production_path From "+env.getProperty("PORTAL_DB")+".site_menus where is_active = 1 and lang = "+escape.cote(defaultLangCode)+" and site_id ="+escape.cote(siteid));
			if(rsMenu.next())
			{
				currentMenuPath = Util.parseNull(rsMenu.value("production_path"));
				if(currentMenuPath.startsWith("/") == false) currentMenuPath = "/" + currentMenuPath;
				if(currentMenuPath.endsWith("/") == false) currentMenuPath = currentMenuPath + "/";
			}

			String urlprefix = sitedomain + currentMenuPath;
			String resourcesUrlPrefix = sitedomain + getCachedResourcesUrl(Etn, siteid, sitename);
			
			//we check its store just to be on safe side
			String qry="";
			Set rsP = Etn.execute(qry="select c.id, d.content_data, u.page_path as url, c.folder_id "+
							" from  "+((!deleteStore)? "structured_contents_published c":"structured_contents c")+
							" inner join "+((!deleteStore)? "structured_contents_details_published d":"structured_contents_details d")+" on d.content_id = c.id and d.langue_id = "+escape.cote(defaultLangId)+
							" inner join bloc_templates b on b.id = c.template_id and b.type = 'store' "+
							" left outer join pages p on p.id = d.page_id "+
							" left outer join "+env.getProperty("COMMONS_DB")+".content_urls u on u.content_type = 'page' and u.content_id = p.id "+								
							" where c.id = "+escape.cote(contentId)+ " and c.structured_version='V1' ");
			log(qry);
			if(rsP.next())
			{
				JSONObject json = null;
				if(!deleteStore){
					json = getPartooJson(siteInfo.get("org_id"), siteInfo.get("country_code"), urlprefix, resourcesUrlPrefix, rsP.value("id"), Util.decodeJSONStringDB(rsP.value("content_data")), Util.parseNull(rsP.value("url")), siteid);
					if(json == null) json = new JSONObject();
				}else{
					log("status changing to closed");
					Set delRs = Etn.execute("SELECT rjson from partoo_contents where site_id = "+escape.cote(siteid)+" and ctype = 'store' and cid = "+escape.cote(contentId));
					if(delRs.next())
					{
						json = new JSONObject(Util.parseNull(delRs.value("rjson")));
						if(json.has("status"))	json.put("status","closed");
						log("marked closed");
						Etn.executeCmd("Update partoo_contents set rjson="+Util.escapeCote3(json.toString())+" where site_id = "+escape.cote(siteid)+" and ctype = 'store' and cid = "+escape.cote(contentId));
					}
				}
				
				String partooId = "";
				Set rsPs = Etn.execute("Select * from partoo_contents where site_id = "+escape.cote(siteid)+" and ctype = 'store' and cid = "+escape.cote(contentId));
				if(rsPs.next()) partooId = Util.parseNull(rsPs.value("partoo_id"));
				
				String u = partooApiUrl;
				if(partooId.length() > 0)
				{
					u += "business/" + partooId;
				}
				else
				{
					u += "business";
				}
				log(json.toString());
				JSONObject apiResponse = callApi(u, "post", siteInfo.get("api_key"), json.toString(), "Partoo.processStore");


				if(apiResponse.getInt("status") == 2000)
				{
					Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_error, rjson) values ("+escape.cote(siteid)+", 'store', "+escape.cote(contentId)+", 'some exception while calling api', "+Util.escapeCote3(json.toString())+") on duplicate key update partoo_error = 'some exception while calling api', rjson = "+Util.escapeCote3(json.toString()));
				}
				else if(Util.parseNull(apiResponse.optString("response_content_type")).equalsIgnoreCase("application/json") == false)
				{
					Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_error, rjson) values ("+escape.cote(siteid)+", 'store', "+escape.cote(contentId)+", 'invalid response from partoo', "+Util.escapeCote3(json.toString())+") on duplicate key update partoo_error = 'invalid response from partoo', rjson = "+Util.escapeCote3(json.toString()));
				}
				else if(apiResponse.getInt("http_code")==200)
				{
					JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
					Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_id, rjson, partoo_json) values ("+escape.cote(siteid)+", 'store', "+escape.cote(contentId)+", "+escape.cote(Util.parseNull(partooJsonResponse.optString("id")))+", "+Util.escapeCote3(json.toString())+", "+Util.escapeCote3(partooJsonResponse.toString())+") on duplicate key update partoo_id = "+escape.cote(Util.parseNull(partooJsonResponse.optString("id")))+", partoo_error = '', partoo_json = "+Util.escapeCote3(partooJsonResponse.toString())+", rjson = "+Util.escapeCote3(json.toString()));
					
					if(!deleteStore){
						if(json.optJSONArray("categories") != null)
						{
							boolean isUpdate = true;
							if(partooId.length()==0){
								isUpdate=false;
							}
							addPartooServices(siteid,json.getJSONArray("categories"),Util.parseNull(partooJsonResponse.optString("id")),isUpdate);
						}
						updateStoreGroup(groups,sectionsGroupsUpdate,Util.parseNull(rsP.value("folder_id")),contentId, siteid,siteInfo);
					}
					
					return true;
				}
				else
				{
					Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_error, rjson) values ("+escape.cote(siteid)+", 'store', "+escape.cote(contentId)+", "+Util.escapeCote3(Util.parseNull(apiResponse.optString("response")))+", "+Util.escapeCote3(json.toString())+") on duplicate key update partoo_error = "+Util.escapeCote3(Util.parseNull(apiResponse.optString("response")))+", rjson = "+Util.escapeCote3(json.toString()));							
					updateStoreGroup(groups,sectionsGroupsUpdate,Util.parseNull(rsP.value("folder_id")),contentId, siteid,siteInfo);
				}
			}
			else return true;//it was not store so mark status = 2
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return false;
	}	

	private void addPartooServices(String siteId,JSONArray categories,String businessId,boolean isUpdate) throws Exception{

		log("=============  Adding Services For Partoo");
		for(int i=0;i<categories.length();i++){
			log("=============  Category::"+categories.optString(i));
			Set rs = Etn.execute("select * from partoo_services where site_id="+escape.cote(siteId)+" and category="+escape.cote(categories.optString(i)));

			while(rs.next()){
				log("=============  Service Id::"+Util.parseNull(rs.value("id")));
				JSONObject serviceObj = new JSONObject();
				serviceObj.put("category_gmb_name",Util.parseNull(categories.optString(i)));
				serviceObj.put("name",Util.parseNull(rs.value("service_name")));
				serviceObj.put("price",Double.parseDouble(Util.parseNull(rs.value("price"))));
				serviceObj.put("description",Util.parseNull(rs.value("description")));
				
				boolean toAddService = true;
				if(isUpdate){
					toAddService = false;

					Set rsCheckService = Etn.execute("select * from partoo_services_details where partoo_id="+escape.cote(businessId)+
						" and category="+escape.cote(Util.parseNull(categories.optString(i)))+" and site_id="+escape.cote(siteId));
					if(rsCheckService.next()){
						while(rsCheckService.next()){
							Set rsCheckSerivceWork = Etn.execute("select ps.* from partoo_services ps join partoo_services_work psw on psw.services_id=ps.id where psw.id="+
								escape.cote(Util.parseNull(rsCheckService.value("partoo_work_id")))+" and ps.service_name="+escape.cote(Util.parseNull(rs.value("service_name"))));
							if(rsCheckSerivceWork.rs.Rows==0){
								toAddService=true;
							}
						}
					}else{
						toAddService=true;
					}
				}

				if(toAddService){
					log("adding for update===="+isUpdate);
					Etn.executeCmd("insert into partoo_services_work (services_id,partoo_id,method,request_json,site_id) values ("+escape.cote(Util.parseNull(rs.value("id")))+","
					+escape.cote(businessId)+",'post',"+Util.escapeCote3(serviceObj.toString())+","+escape.cote(siteId)+")");
				}
			}
		}
		PartooServices ps = new PartooServices(Etn, env);
		ps.processPartoo(siteId);
	}
	
	private JSONObject getPartooJson(String orgId, String countryCode, String urlprefix, String resourcesUrlPrefix, String storeId, String storeJson, String url, String siteid)
	{
		JSONObject json = null;
		try
		{
			JSONObject contentData = new JSONObject(storeJson);
			json = new JSONObject();
			
			json.put("org_id", orgId);
			json.put("country", countryCode.toUpperCase());
			if(url.length() > 0 ) 
			{
				String finalUrl =  urlprefix + url;
				if(finalUrl.indexOf("?") > -1) finalUrl += "&";
				else finalUrl += "?";
				finalUrl += "utm_source=gmb&utm_medium=siteweb";
				
				json.put("website_url", finalUrl);
			}
			
			log("In getPartooJson store id : " + storeId);
			
			if(contentData.has("global_information") && contentData.getJSONArray("global_information").length() > 0)
			{
				JSONObject globalInfo = contentData.getJSONArray("global_information").getJSONObject(0);
				if(globalInfo.has("map_section") && globalInfo.getJSONArray("map_section").length() > 0)
				{
					JSONObject mapSection = globalInfo.getJSONArray("map_section").getJSONObject(0);
					if(mapSection.has("informations") && mapSection.getJSONArray("informations").length() > 0)
					{
						String descriptionLong = "";
						for(int j=0; j<mapSection.getJSONArray("informations").length(); j++)
						{							
							JSONObject informations = mapSection.getJSONArray("informations").getJSONObject(j);
							if(informations.has("content") && informations.getJSONArray("content").length() > 0)
							{
								String content = Util.parseNull(informations.getJSONArray("content").optString(0));
								if(content.length() > 0 ) 
								{
									descriptionLong = descriptionLong + " " + content;									
								}
							}							
						}
						if(Util.parseNull(descriptionLong).length() > 0) json.put("description_long", Util.parseNull(descriptionLong));	
					}
				}
				
				
				if(globalInfo.has("store_section") && globalInfo.getJSONArray("store_section").length() > 0)
				{
					JSONObject storeSection = globalInfo.getJSONArray("store_section").getJSONObject(0);
					String _locationName = "";
					if(storeSection.has("presence_management_name_gmb") && Util.parseNull(storeSection.getJSONArray("presence_management_name_gmb").optString(0)).length() > 0) _locationName = Util.parseNull(storeSection.getJSONArray("presence_management_name_gmb").optString(0));
					else if(storeSection.has("location_name") && Util.parseNull(storeSection.getJSONArray("location_name").optString(0)).length() > 0) _locationName = Util.parseNull(storeSection.getJSONArray("location_name").optString(0));
					
					if(_locationName.length() > 0) json.put("name", _locationName);

					if(storeSection.has("city")) json.put("city", Util.parseNull(storeSection.getJSONArray("city").optString(0)));
					if(storeSection.has("postal_code")) json.put("zipcode", Util.parseNull(storeSection.getJSONArray("postal_code").optString(0)));
					if(storeSection.has("address")) json.put("address_full", Util.parseNull(storeSection.getJSONArray("address").optString(0)));
					if(storeSection.has("latitude")) 
					{
						try {
							double d = Double.parseDouble(Util.parseNull(storeSection.getJSONArray("latitude").optString(0)));
							json.put("lat", d);	
						} catch(Exception e) {}
						
					}
					if(storeSection.has("longitude")) 
					{
						try {
							double d = Double.parseDouble(Util.parseNull(storeSection.getJSONArray("longitude").optString(0)));
							json.put("long", d);	
						} catch(Exception e) {}
					}
					
					boolean isActive = false;
					if(storeSection.has("status") && Util.parseNull(storeSection.getJSONArray("status").optString(0)).equalsIgnoreCase("active")) isActive = true;
					
					if(isActive) json.put("status", "open");
					else json.put("status", "closed");
					
					if(storeSection.has("phone") && storeSection.getJSONArray("phone").length() > 0)
					{
						String storePhoneNumber = Util.parseNull(storeSection.getJSONArray("phone").optString(0));
						if(storePhoneNumber.length() > 0)
						{
							JSONArray contacts = new JSONArray();
							JSONObject contact = new JSONObject();
							JSONArray phoneNumbers = new JSONArray();
							phoneNumbers.put(storePhoneNumber);
							contact.put("phone_numbers", phoneNumbers);
							contacts.put(contact);
							json.put("contacts", contacts);
						}
					}
					
					if(storeSection.has("image") && storeSection.getJSONArray("image").length() > 0)
					{
						boolean primaryImageSet = false;
						JSONObject photos = new JSONObject();
						JSONArray secondarys = new JSONArray();
						boolean anyValidPhotos = false;
						for(int i=0;i<storeSection.getJSONArray("image").length();i++)
						{
							String _img = Util.parseNull(storeSection.getJSONArray("image").getJSONObject(i).optString("value"));

							if(_img.length() == 0) continue;
							
							_img = java.net.URLEncoder.encode(_img, "UTF-8");
							
							anyValidPhotos = true;
							
							if(primaryImageSet == false) 
							{
								if(_img.toLowerCase().startsWith("http:") || _img.toLowerCase().startsWith("https:") || _img.toLowerCase().startsWith("data:")) photos.put("primary", _img);
								else photos.put("primary", resourcesUrlPrefix + "img/" + _img);
								
								primaryImageSet = true;
							}
							else
							{
								if(_img.toLowerCase().startsWith("http:") || _img.toLowerCase().startsWith("https:") || _img.toLowerCase().startsWith("data:")) secondarys.put(_img);
								else secondarys.put(resourcesUrlPrefix + "img/" + _img);								
							}							
						}

						if(storeSection.has("alternative_images") && storeSection.getJSONArray("alternative_images").length() > 0)
						{
							for(int i=0;i<storeSection.getJSONArray("alternative_images").length();i++)
							{
								String altImg = Util.parseNull(storeSection.getJSONArray("alternative_images").getJSONObject(i).optString("value"));
								
								if(altImg.length() == 0) continue;
								altImg = java.net.URLEncoder.encode(altImg, "UTF-8");

								if(altImg.toLowerCase().startsWith("http:") || altImg.toLowerCase().startsWith("https:") || altImg.toLowerCase().startsWith("data:")) secondarys.put(altImg);
								else secondarys.put(resourcesUrlPrefix + "img/" + altImg);
							}
						}

						if(secondarys.length() > 0) photos.put("secondary", secondarys);
						if(anyValidPhotos) json.put("photos", photos);
					}	
					
					if(storeSection.has("categories") && storeSection.getJSONArray("categories").length() > 0)
					{
						JSONArray jCategories = storeSection.getJSONArray("categories").getJSONArray(0);
						JSONArray categories = new JSONArray();
						for(int i=0;i<jCategories.length();i++)
						{
							Set rsTag = Etn.execute("select * from "+env.getProperty("CATALOG_DB")+".tags where site_id = "+escape.cote(siteid)+" and id ="+escape.cote(Util.parseNull(jCategories.optString(i))));
							if(rsTag.next()) categories.put(rsTag.value("label"));
						}
						json.put("categories", categories);
					}
				}
			}
						
			if(contentData.has("timetable_section") && contentData.getJSONArray("timetable_section").length() > 0)
			{
				JSONObject timeTable = contentData.getJSONArray("timetable_section").getJSONObject(0);
				
				JSONObject openHours = new JSONObject();
				JSONArray jDay = getDaySchedule(timeTable, "monday");
				if(jDay != null) openHours.put("monday", jDay);

				jDay = getDaySchedule(timeTable, "tuesday");
				if(jDay != null) openHours.put("tuesday", jDay);

				jDay = getDaySchedule(timeTable, "wednesday");
				if(jDay != null) openHours.put("wednesday", jDay);

				jDay = getDaySchedule(timeTable, "thursday");
				if(jDay != null) openHours.put("thursday", jDay);

				jDay = getDaySchedule(timeTable, "friday");
				if(jDay != null) openHours.put("friday", jDay);

				jDay = getDaySchedule(timeTable, "saturday");
				if(jDay != null) openHours.put("saturday", jDay);

				jDay = getDaySchedule(timeTable, "sunday");
				if(jDay != null) openHours.put("sunday", jDay);
				
				json.put("open_hours", openHours);
			}	

			if(contentData.has("special_hours_section") && contentData.getJSONArray("special_hours_section").length() > 0)			
			{
				boolean isOpen = true;
				JSONArray jOpenDays = new JSONArray();
				JSONArray jCloseDays = new JSONArray();
				JSONObject spHours = contentData.getJSONArray("special_hours_section").getJSONObject(0);
				if(spHours.has("special_hours") && spHours.getJSONArray("special_hours").length() > 0)
				{
					for(int i=0;i<spHours.getJSONArray("special_hours").length();i++)
					{
						isOpen = true;
						JSONObject spHour = spHours.getJSONArray("special_hours").getJSONObject(i);						
						if(Util.parseNull(spHour.getJSONArray("start_date").getJSONArray(0).optString(0)).length() > 0 && Util.parseNull(spHour.getJSONArray("end_date").getJSONArray(0).optString(0)).length() > 0)
						{
							boolean isValid = true;
							String endsAt = Util.parseNull(spHour.getJSONArray("end_date").getJSONArray(0).optString(0));
							//we must check the end date is current or future otherwise partoo rejects it
							Set rsD = Etn.execute("select case when date(now()) > str_to_date("+escape.cote(endsAt)+",'%Y-%m-%d') then 0 else 1 end is_valid");
							if(rsD.next())
							{
								isValid = "1".equals(rsD.value("is_valid"));
							}
							if(isValid)
							{

								JSONObject jOpenDay = new JSONObject();
								jOpenDay.put("starts_at", Util.parseNull(spHour.getJSONArray("start_date").getJSONArray(0).optString(0)));
								jOpenDay.put("ends_at", endsAt);
							
								JSONArray jOpenHours = new JSONArray();
								for(int j=0;j<spHour.getJSONArray("opening_hours").length();j++)
								{
									String sTime = Util.parseNull(spHour.getJSONArray("opening_hours").getJSONObject(j).getJSONArray("start").getJSONArray(0).optString(0));
									String eTime = Util.parseNull(spHour.getJSONArray("opening_hours").getJSONObject(j).getJSONArray("end").getJSONArray(0).optString(0));
									if(sTime.length() > 0 || eTime.length() > 0) jOpenHours.put(sTime + "-" + eTime);

									if(sTime.equalsIgnoreCase("00:00") && eTime.equalsIgnoreCase("00:00")){
										isOpen=false;
									}
								}
								if(jOpenHours.length() > 0) jOpenDay.put("open_hours", jOpenHours);

								if(isOpen){
									jOpenDays.put(jOpenDay);
								}
								else{
									jOpenDay.remove("open_hours");
									jCloseDays.put(jOpenDay);
								}
							}
						}
					}
				}
				JSONObject specificHours = new JSONObject();
	
				if(jOpenDays.length() > 0) 
					specificHours.put("open", jOpenDays);
				
				if(jCloseDays.length() > 0)
					specificHours.put("close",jCloseDays);

				if(!specificHours.isEmpty()) json.put("specific_hours",specificHours);
			}			
		}
		catch(Exception e)
		{
			log("Error generating partoo json");
			e.printStackTrace();
		}
		return json;
	}
	
	private JSONArray getDaySchedule(JSONObject timeTable, String day) throws Exception
	{
		JSONArray jSchedule = new JSONArray();
		if(timeTable.has(day) && timeTable.getJSONArray(day).length() > 0)
		{
			JSONObject jDay = timeTable.getJSONArray(day).getJSONObject(0);
			if(jDay.has("schedules") && jDay.getJSONArray("schedules").length() > 0)
			{
				for(int i=0;i<jDay.getJSONArray("schedules").length();i++)
				{
					String sTime = Util.parseNull(jDay.getJSONArray("schedules").getJSONObject(i).getJSONArray("start").getJSONArray(0).optString(0));
					String eTime = Util.parseNull(jDay.getJSONArray("schedules").getJSONObject(i).getJSONArray("end").getJSONArray(0).optString(0));
					if(sTime.length() > 0 || eTime.length() > 0) jSchedule.put(sTime + "-" + eTime);
				}
			}
		}

		return jSchedule;
	}
}

