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

public class Partoo implements PartooInterface
{ 
	private Properties env;
	private com.etn.beans.Etn Etn;
	private boolean debug;
	private String cacheBaseDir = "";	
	private String partooApiUrl = "";
	
	private ApiCaller apiCaller;
	
	private boolean useProxy = true;//by default we assume we will use proxy if its configured

	public Partoo(Etn Etn, Properties env, boolean debug) throws Exception
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
		System.out.println("Partoo::----------------- " + m);
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
		
	public void process()
	{
		//NOTE:: there can be case that someone publish the store/folder twice and engine did not run yet.
		//in this case we have more than 1 rows for same store/folder in the publish table so we should call api once rather making repeated
		//api calls ... so we will maintain a list of processed stores/folders and make sure we have called the api for it already then we ignore for next time
		
		List<String> processedStores = new ArrayList<>();
		List<String> processedFolders = new ArrayList<>();
		
		Map<String, Map<String, String>> sitesInfo = new HashMap<>();
		//order by is important as a folder can have sub-folders so parent folder must be created first in partoo
		Set rs = Etn.execute("Select * from partoo_publish where status = 0 and attempt < 5 order by id");		
		while(rs.next())
		{
			//some tasks take time in pages module so we must set the engine status at such points
			if (env != null) //this means its running from engine 
			{
				Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Partoo',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
			}
			
			Etn.executeCmd("update partoo_publish set attempt = attempt + 1, updated_ts = now() where id = "+escape.cote(rs.value("id")));
			String siteid = rs.value("site_id");
			
			Set rsSite = Etn.execute("Select s.*, l.langue_code as partoo_language_code from "+env.getProperty("PORTAL_DB")+".sites s left join language l on l.langue_id = s.partoo_language_id where s.id = "+escape.cote(siteid));
			rsSite.next();
			
			if("1".equals(Util.parseNull(rsSite.value("partoo_activated"))) == false)
			{
				log("Partoo is not activated for the site id : " + siteid+". Skip this row");
				Etn.executeCmd("update partoo_publish set status = 2 where id ="+escape.cote(rs.value("id")));
				continue;
			}
			
			String cid = rs.value("cid");
			String ctype = rs.value("ctype");
			
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
					partooInfo.put("name", Util.parseNull(rsSite.value("name")));
					partooInfo.put("domain", Util.parseNull(rsSite.value("domain")));
					partooInfo.put("activated", Util.parseNull(rsSite.value("partoo_activated")));
					partooInfo.put("api_key", Util.parseNull(rsSite.value("partoo_api_key")));
					partooInfo.put("country_code", Util.parseNull(rsSite.value("partoo_country_code")));
					partooInfo.put("org_id", Util.parseNull(rsSite.value("partoo_organization_id")));
					partooInfo.put("langue_id", Util.parseNull(rsSite.value("partoo_language_id")));
					partooInfo.put("langue_code", Util.parseNull(rsSite.value("partoo_language_code")));
					
					String groupName = Util.parseNull(rsSite.value("partoo_main_group"));
					if(groupName.length() > 0)
					{
						int groupId = createMainGroup(groupName, siteid, partooInfo);
						if(groupId > 0)
						{
							partooInfo.put("main_group_id", ""+groupId);
						}
						else
						{
							log("-----------------------");
							log("ERROR::Unable to find the group ID against main group : " + groupName);							
							log("-----------------------");
						}
					}

					sitesInfo.put(siteid, partooInfo);
				}
				//main_group_id is mandatory
				if(Util.parseNullInt(sitesInfo.get(siteid).get("main_group_id")) <= 0)
				{
					log("-----------------------");
					log("ERROR::Main group ID is empty ... we cannot continue processing this row ... we will retry it next time");
					log("-----------------------");
				}
				else
				{
					boolean ret = false;
					if("store".equalsIgnoreCase(ctype))
					{
						ret = processStore(cid, siteid, sitesInfo.get(siteid));
					}
					else if("folder".equalsIgnoreCase(ctype))
					{
						ret = processFolder(cid, siteid, sitesInfo.get(siteid));
					}
					if(ret == true)
					{
						if("store".equalsIgnoreCase(ctype)) processedStores.add(cid);
						else if("folder".equalsIgnoreCase(ctype)) processedFolders.add(cid);
						
						Etn.executeCmd("update partoo_publish set status = 2 where id ="+escape.cote(rs.value("id")));
					}
				}
			}
		}
	}
	
	private JSONObject getGroupByName(String apiKey, String orgId, String groupName, int pageNum)
	{
		try
		{
			log("In getGroupByName :: " + groupName);
			//we are fetching 100 records per page
			String _url = partooApiUrl + "groups?max_page=100&page="+pageNum;
			JSONObject apiResponse = callApi(_url, "GET", apiKey, "", "Partoo.getGroupByName");
			if(apiResponse.getInt("http_code") == 200)
			{
				JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));							
				if(partooJsonResponse.has("groups") == false || partooJsonResponse.getJSONArray("groups").length() == 0) return null;
							
				for(int i=0;i<partooJsonResponse.getJSONArray("groups").length();i++)
				{
					JSONObject group = partooJsonResponse.getJSONArray("groups").getJSONObject(i);
					if(groupName.equalsIgnoreCase(Util.parseNull(group.getString("name"))))
					{
						JSONObject grp = new JSONObject();
						grp.put("group_id", group.getInt("id"));
						return grp;
					}
					for(int j=0;j<group.getJSONArray("subgroups").length();j++)
					{
						JSONObject subgroup = group.getJSONArray("subgroups").getJSONObject(j);
						if(groupName.equalsIgnoreCase(Util.parseNull(subgroup.getString("name"))))
						{
							JSONObject grp = new JSONObject();
							grp.put("group_id", subgroup.getInt("id"));
							grp.put("parent_group_id", group.getInt("id"));
							return grp;
						}
					}
					
				}
				//if org_id does not match we should try next page num
				return getGroupByName(apiKey, orgId, groupName, pageNum+1);
			}
			else
			{
				return null;
			}
		}
		catch(Exception e)
		{
			log("Error in getGroupByName");
			e.printStackTrace();
		}
		return null;
	}
	
	private int createMainGroup(String groupName, String siteid, Map<String, String> partooInfo)
	{
		log("In createMainGroup");
		int groupId = -1;
		try
		{
			JSONObject group = getGroupByName(partooInfo.get("api_key"), partooInfo.get("org_id"), groupName, 1);
			if(group == null)
			{
				log("Main group not found ... creating group : "+ groupName);

				String u = partooApiUrl + "groups";
				JSONObject json = new JSONObject();					
				json.put("name", groupName);
				log(json.toString());
				
				JSONObject apiResponse = callApi(u, "post", partooInfo.get("api_key"), json.toString(), "Partoo.createMainGroup");
				
				if(apiResponse.getInt("http_code") == 200)
				{
					JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
					groupId = partooJsonResponse.getInt("id");
				}
				else
				{
					log("Error creating main group");
				}
			}
			else 
			{
				log("Main group already exists");
				groupId = group.getInt("group_id");
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			groupId = -1;
		}
		return groupId;
	}
	
	private boolean processFolder(String folderId, String siteid, Map<String, String> siteInfo)
	{
		log("In processFolder");
		try
		{
			//Group will always be created in main group ... in Partoo we can have only 2 levels of groups
			//whereas given main group in module parameters and we can create 2 levels of folders in asimina
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
				//we can only delete a group from partoo if all businesses from it are removed already
				String partooId = Util.parseNull(rs.value("partoo_id"));
				if(partooId.length() > 0)
				{
					//get Group info and check if there are any subgroups in it
					String u = partooApiUrl + "groups/" + partooId;
					JSONObject apiResponse = callApi(u, "get", siteInfo.get("api_key"), "", "Partoo.processFolder");
					if(apiResponse.getInt("http_code")==200)
					{
						JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
						//no subgroups in this group
						if(partooJsonResponse.getJSONArray("subgroups") == null || partooJsonResponse.getJSONArray("subgroups").length() == 0)
						{
							//now check if any businesses are there in this group
							//get list of business from partoo for this group .. if its empty then delete the group
							u = partooApiUrl + "groups/" + partooId +"/businesses";
							apiResponse = callApi(u, "get", siteInfo.get("api_key"), "", "Partoo.processFolder");
							
							if(apiResponse.getInt("http_code")==200)
							{						
								partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));							
								if(partooJsonResponse.getJSONArray("ids") == null || partooJsonResponse.getJSONArray("ids").length() == 0) 
								{
									log("Business list for group id "+partooId+ " is empty. Try deleting from partoo");
									u = partooApiUrl + "groups/" + partooId;
									apiResponse = callApi(u, "delete", siteInfo.get("api_key"), "", "Partoo.processFolder");
									
									if(apiResponse.getInt("http_code")==200)
									{
										partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));							
										if(Util.parseNull(partooJsonResponse.optString("status")).equalsIgnoreCase("success"))
										{
											log("Folder deleted from partoo. Delete locally as well");
										}
									}
								}
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
					if(Util.parseNullInt(rs.value("parent_folder_id")) > 0)
					{
						log("Its a sub-folder so we will ignore this to be added to partoo");
						return true;
					}
					
					//create/update group
					String partooId = "";					
					Set rsPs = Etn.execute("Select * from partoo_contents where site_id = "+escape.cote(siteid)+" and ctype = 'folder' and cid = "+escape.cote(folderId));
					if(rsPs.next())
					{
						partooId = Util.parseNull(rsPs.value("partoo_id"));
					}									
					String folderName = Util.parseNull(rs.value("name"));

					JSONObject json = new JSONObject();					
					json.put("name", folderName);
					if(Util.parseNullInt(siteInfo.get("main_group_id")) > 0) json.put("parent_id", Util.parseNullInt(siteInfo.get("main_group_id")));
										
					if(partooId.length() == 0)//new folder added ... we must check if partoo already has same name group as it can be added by some other country
					{
						JSONObject group = getGroupByName(siteInfo.get("api_key"), siteInfo.get("org_id"), folderName, 1);
						if(group != null)//group already exists
						{
							log("New group already exists in partoo");
							Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_id, rjson, partoo_json) values ("+escape.cote(siteid)+", 'folder', "+escape.cote(folderId)+", "+escape.cote(""+group.getInt("group_id"))+", "+Util.escapeCote3(json.toString())+", "+Util.escapeCote3(group.toString())+") on duplicate key update partoo_id = "+escape.cote(""+group.getInt("group_id"))+", partoo_error = '', partoo_json = "+Util.escapeCote3(group.toString())+", rjson = "+Util.escapeCote3(json.toString()));
							return true;
						}
					}

					String method = "post";
					String u = partooApiUrl;
					if(partooId.length() > 0)
					{
						method = "put";
						u += "groups/" + partooId;
					}
					else
					{
						u += "groups";
					}
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
						Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_id, rjson, partoo_json) values ("+escape.cote(siteid)+", 'folder', "+escape.cote(folderId)+", "+escape.cote(Util.parseNull(partooJsonResponse.optString("id")))+", "+Util.escapeCote3(json.toString())+", "+Util.escapeCote3(partooJsonResponse.toString())+") on duplicate key update partoo_id = "+escape.cote(Util.parseNull(partooJsonResponse.optString("id")))+", partoo_error = '', partoo_json = "+Util.escapeCote3(partooJsonResponse.toString())+", rjson = "+Util.escapeCote3(json.toString()));
						return true;
					}
					else
					{
						Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_error, rjson) values ("+escape.cote(siteid)+", 'folder', "+escape.cote(folderId)+", "+Util.escapeCote3(Util.parseNull(apiResponse.optString("response")))+", "+Util.escapeCote3(json.toString())+") on duplicate key update partoo_error = "+Util.escapeCote3(Util.parseNull(apiResponse.optString("response")))+", rjson = "+Util.escapeCote3(json.toString()));
					}
				}
				else 
				{
					log("It could be a sub-folder which was deleted. As sub-folders are not added in partoo so means we have no entry in partoo_contents due to which we will reach here");
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
			String u = partooApiUrl + "groups/"+groupId+"/businesses";
			JSONObject apiResponse = callApi(u, "get", siteInfo.get("api_key"), "", "Partoo.deleteStoreFromGroup");
			if(apiResponse.getInt("http_code")==200)
			{
				JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
				JSONArray newBusinessIds = new JSONArray();
				JSONArray businessIds = partooJsonResponse.getJSONArray("ids");
				for(int i=0;i<businessIds.length();i++)
				{
					if(Util.parseNull(businessIds.getString(i)).equals(businessId) == false)
					{
						newBusinessIds.put(businessIds.getString(i));
					}
				}
				
				log("New business Ids : "+newBusinessIds.toString());
				
				u = partooApiUrl + "groups/"+groupId+"/businesses";
				apiResponse = callApi(u, "put", siteInfo.get("api_key"), ((new JSONObject()).put("business__in", newBusinessIds)).toString(), "Partoo.deleteStoreFromGroup");
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
	
	private boolean addStoreToGroup(String businessId, int groupId, Map<String, String> siteInfo)
	{
		boolean ret = false;
		log("In addStoreToGroup --- business id : " + businessId + " group id "+ groupId);
		try
		{
			boolean storeAlreadyInGroup = false;
			String u = partooApiUrl + "groups/"+groupId+"/businesses";
			JSONObject apiResponse = callApi(u, "get", siteInfo.get("api_key"), "", "Partoo.addStoreToGroup");
			if(apiResponse.getInt("http_code") == 200)
			{
				JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
				JSONArray businessIds = partooJsonResponse.getJSONArray("ids");
				for(int i=0;i<businessIds.length();i++)
				{
					//just in case it was added last time so we confirm it
					if(Util.parseNull(businessIds.getString(i)).equals(businessId))
					{
						storeAlreadyInGroup = true;
						break;
					}					
				}				
				if(storeAlreadyInGroup)
				{
					ret = true;
				}
				else
				{
					businessIds.put(businessId);
					log("New business Ids : "+businessIds.toString());
					
					u = partooApiUrl + "groups/"+groupId+"/businesses";
					apiResponse = callApi(u, "put", siteInfo.get("api_key"), ((new JSONObject()).put("business__in", businessIds)).toString(), "Partoo.addStoreToGroup");
					if(apiResponse.getInt("http_code") == 200)
					{
						ret = true;
					}
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		return ret;
	}
	
	private void updateStoreGroup(String contentId, String siteid, Map<String, String> siteInfo, String folderId)
	{
		log("In updateStoreGroup store id : " + contentId + " site id : " + siteid);
		Set rs = Etn.execute("select * from partoo_contents where site_id = "+escape.cote(siteid)+" and ctype = 'store' and cid = "+escape.cote(contentId));
		rs.next();
		String partooStoreId = Util.parseNull(rs.value("partoo_id"));
		if(partooStoreId.length() == 0)
		{
			log("Store partoo id is empty");
			return;
		}
		
		int currentGroupId = -1;
		//we must get the group id for store every time as user can change the group from the website also
		String u = partooApiUrl + "business/" + partooStoreId;
		JSONObject apiResponse = callApi(u, "get", siteInfo.get("api_key"), "", "Partoo.updateStoreGroup");
		if(apiResponse.getInt("http_code") == 200)
		{
			JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
			if(partooJsonResponse.has("group_id") && partooJsonResponse.isNull("group_id") == false) currentGroupId = Util.parseNullInt(partooJsonResponse.getInt("group_id"));
		}
		
		log("currentGroupId : " + currentGroupId);
				
		int groupId = -1;
		if(Util.parseNull(folderId).length() > 0)
		{
			//any store in sub-folder will actually go into parent folder in partoo
			Set rsF = Etn.execute("Select * from stores_folders where id = "+escape.cote(folderId));
			if(rsF.next())
			{
				if(Util.parseNullInt(rsF.value("parent_folder_id")) > 0) folderId = ""+Util.parseNullInt(rsF.value("parent_folder_id"));
			}
			log("Folder ID applicable : "+folderId);
			
			rsF = Etn.execute("select * from partoo_contents where site_id = "+escape.cote(siteid)+" and ctype = 'folder' and cid = "+escape.cote(folderId));
			if(rsF.next())
			{
				groupId = Util.parseNullInt(rsF.value("partoo_id"));
			}
		}
		
		int mainGroupId = Util.parseNullInt(siteInfo.get("main_group_id"));
		
		int applicableGroupId = groupId;
		if(applicableGroupId <= 0) applicableGroupId = mainGroupId;
		log("Applicable Group ID : " + applicableGroupId);
		
		//currentGroupId can be empty the very first time we are adding a store to partoo
		//and for first time we must add the store to the parent group after which we can add to its sub-group
		if(currentGroupId <= 0 && applicableGroupId > 0)
		{
			log("Add store to group");
			log("Partoo has a problem. We cannot directly add the store to the sub-group. We have to first add to parent group which is the main group always");
			addStoreToGroup(partooStoreId, mainGroupId, siteInfo);
			if(applicableGroupId != mainGroupId)
			{
				addStoreToGroup(partooStoreId, applicableGroupId, siteInfo);
			}
		}
		else if(currentGroupId > 0 && applicableGroupId <= 0)
		{
			log("Delete store from group");
			deleteStoreFromGroup(partooStoreId, currentGroupId, siteInfo);
		}
		else if(currentGroupId != applicableGroupId)
		{
			log("Update store group");
			//store can be in main group only and now we might be moving to sub-group
			//in this case if we delete from main group then sub-group cannot see the store
			if(mainGroupId != currentGroupId) 
			{
				log("Delete store from group id "+ currentGroupId);
				deleteStoreFromGroup(partooStoreId, currentGroupId, siteInfo);
			}
			log("Add to new group");
			addStoreToGroup(partooStoreId, applicableGroupId, siteInfo);
		}
	}
	
	private boolean processStore(String contentId, String siteid, Map<String, String> siteInfo)
	{
		log("In processStore");
		try
		{	
			boolean deleteStore = false;
			
			Set rs = Etn.execute("select c.*, p.id as content_id from partoo_contents c left join structured_contents_published p on p.id = c.cid where c.site_id = "+escape.cote(siteid)+" and c.ctype = 'store' and p.structured_version='V1' and c.cid = "+escape.cote(contentId));
			if(rs.rs.Rows > 0)
			{
				rs.next();
				if(Util.parseNull(rs.value("content_id")).length() == 0) deleteStore = true;
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
							" where c.id = "+escape.cote(contentId)+ " and c.structured_version='V1'");
			log(qry);
			if(rsP.next())
			{
				JSONObject json = null;
				if(!deleteStore){
					json = getPartooJson(siteInfo.get("org_id"), siteInfo.get("country_code"), urlprefix, resourcesUrlPrefix, rsP.value("id"), Util.decodeJSONStringDB(rsP.value("content_data")), Util.parseNull(rsP.value("url")), siteid);
				
					if(json == null) json = new JSONObject();
				}else{
					// Etn.executeCmd("SELECT partoo_contents set rjson=replace(rjson,"+escape.cote(",\"status\":\"open\"")+","+escape.cote(",\"status\":\"closed\"")+") where site_id = "+escape.cote(siteid)+" and ctype = 'store' and cid = "+escape.cote(contentId));
					log("status changing  to closed");
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

						updateStoreGroup(contentId, siteid, siteInfo, Util.parseNull(rsP.value("folder_id")));
					}
					
					return true;
				}
				else
				{
					Etn.executeCmd("insert into partoo_contents (site_id, ctype, cid, partoo_error, rjson) values ("+escape.cote(siteid)+", 'store', "+escape.cote(contentId)+", "+Util.escapeCote3(Util.parseNull(apiResponse.optString("response")))+", "+Util.escapeCote3(json.toString())+") on duplicate key update partoo_error = "+Util.escapeCote3(Util.parseNull(apiResponse.optString("response")))+", rjson = "+Util.escapeCote3(json.toString()));							
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

		System.out.println("Partoo::=============  Adding Services For Partoo");
		for(int i=0;i<categories.length();i++){
			System.out.println("Partoo::=============  Category::"+categories.optString(i));
			Set rs = Etn.execute("select * from partoo_services where site_id="+escape.cote(siteId)+" and category="+escape.cote(categories.optString(i)));

			while(rs.next()){
				System.out.println("Partoo::=============  Service Id::"+Util.parseNull(rs.value("id")));
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
					System.out.println("adding for update===="+isUpdate);
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
					
					String _pnamegmb = "";
					if(storeSection.has("presence_management_name_gmb") && Util.parseNull(storeSection.getJSONArray("presence_management_name_gmb").optString(0)).length() > 0) _pnamegmb = Util.parseNull(storeSection.getJSONArray("presence_management_name_gmb").optString(0));
					log("_pnamegmb::"+_pnamegmb);
					
					String _locationName = "";
					if(storeSection.has("location_name") && Util.parseNull(storeSection.getJSONArray("location_name").optString(0)).length() > 0) _locationName = Util.parseNull(storeSection.getJSONArray("location_name").optString(0));
					log("_locationName::"+_locationName);
					
					if(_pnamegmb.length() > 0) _locationName = _pnamegmb;
					log("final locationName::"+_locationName);

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
						//System.out.println("--------------------------------------------------------");
						//System.out.println("######## jCategories "+ jCategories.toString());
						//System.out.println("--------------------------------------------------------");
						JSONArray categories = new JSONArray();

						for(int i=0;i<jCategories.length();i++)
						{
							Set rsTag = Etn.execute("select * from "+env.getProperty("CATALOG_DB")+".tags where site_id = "+escape.cote(siteid)+" and id ="+escape.cote(Util.parseNull(jCategories.optString(i))));
							if(rsTag.next()) categories.put(rsTag.value("label"));
						}
						json.put("categories", categories);
					}

					/*if(storeSection.has("categories") && storeSection.getJSONArray("categories").length() > 0)
					{
						JSONArray categories = new JSONArray();
						//System.out.println("Categories :: " +storeSection.getJSONArray("categories").toString());
						for(int i=0;i<storeSection.getJSONArray("categories").length();i++)
						{
							String[] cats = Util.parseNull(storeSection.getJSONArray("categories").optString(i)).split(",");
							for(int j=0;j<cats.length;j++)
							{
								String _cat = Util.parseNull(cats[j]).replace("\"","");								
								if(_cat.length() > 0) categories.put(_cat);
							}
						}
						json.put("categories", categories);
					}*/
					
				}								
				
				/*if(globalInfo.has("services_section") && globalInfo.getJSONArray("services_section").length() > 0)
				{
					JSONArray jServices = new JSONArray();
					for(int i=0;i<globalInfo.getJSONArray("services_section").getJSONObject(0).getJSONArray("services").length();i++)
					{
						String service = Util.parseNull(globalInfo.getJSONArray("services_section").getJSONObject(0).getJSONArray("services").getJSONObject(i).getJSONArray("title").getString(0));
						if(service.length() > 0) jServices.put(service);
					}
					if(jServices.length() > 0)
					{
						json.put("custom_fields", (new JSONObject()).put("Services", jServices));
					}
				}*/
				
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
