package com.etn.pages;

import com.etn.Client.Impl.ClientDedieEtn;
import com.etn.beans.Etn;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.beans.app.GlobalParm;
import com.etn.util.ApiCaller;
import com.etn.util.Util;

import org.json.JSONArray;
import org.json.JSONObject;
import java.sql.SQLSyntaxErrorException;

import java.io.File;
import java.io.FileReader;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class PartooMigration {
    
    private Properties env;
	private Etn Etn;
    private ApiCaller apiCaller;
    private boolean debug;
    private String cacheBaseDir = "";	
	private String partooApiUrl = "";
	
	private boolean useProxy = true;//by default we assume we will use proxy if its configured

    public PartooMigration(String parm[])  throws Exception
    {
        env = new Properties();

        boolean envLoaded = false;
        if (parm.length > 0) {
            File confFile = new File(parm[0]);
            if (confFile.exists() && confFile.isFile()) {
                env.load(new FileReader(confFile));
                envLoaded = true;
            }
        }

        if (!envLoaded) {
            throw new Exception("Error: No .conf file provided!!");
        }

        Etn = new ClientDedieEtn("MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT"));
        Etn.setSeparateur(2, '\001', '\002');
        
        Set rs = Etn.execute("SELECT code,val FROM config");
        while (rs.next()) {
            env.setProperty(rs.value("code"), rs.value("val"));
        }
        String commonsDb = env.getProperty("COMMONS_DB");
        if (commonsDb.trim().length() > 0) {
            rs = Etn.execute("SELECT code,val FROM " + commonsDb + ".config");
            while (rs.next()) {
                if (!env.containsKey(rs.value("code"))) {
                    env.setProperty(rs.value("code"), rs.value("val"));
                }
            }
        }

        for (Map.Entry<Object, Object> curEntry : this.env.entrySet()) {
            GlobalParm.add(curEntry.getKey().toString(), curEntry.getValue());
        }

        partooApiUrl = env.getProperty("partoo_api_base_url");
		if(partooApiUrl.endsWith("/") == false) partooApiUrl += "/";

        apiCaller = new ApiCaller(Etn, env, false);
    }
    
    private JSONObject getGroupByNameV1(String apiKey, String orgId, String groupName, int pageNum)
	{
		try
		{
			System.out.println("In getGroupByNameV1 :: " + groupName);
			String _url = partooApiUrl + "groups?max_page=100&page="+pageNum;
			JSONObject apiResponse = callApi(_url, "GET", apiKey, "", "Partoo.getGroupByNameV1");
            
			if(apiResponse.getInt("http_code") == 200)
			{
				JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));							
				if(partooJsonResponse.has("groups") == false || partooJsonResponse.getJSONArray("groups").length() == 0) return null;
							
				for(int i=0;i<partooJsonResponse.getJSONArray("groups").length();i++)
				{
					JSONObject group = partooJsonResponse.getJSONArray("groups").getJSONObject(i);
					if(groupName.equalsIgnoreCase(Util.parseNull(group.getString("name"))))
					{
						return group;
					}

					for(int j=0;j<group.getJSONArray("subgroups").length();j++)
					{
						JSONObject subgroup = group.getJSONArray("subgroups").getJSONObject(j);
						if(groupName.equalsIgnoreCase(Util.parseNull(subgroup.getString("name"))))
						{
							return subgroup;
						}
					}
					
				}
				return getGroupByNameV1(apiKey, orgId, groupName, pageNum+1);
			}
			else
			{
				return null;
			}
		}
		catch(Exception e)
		{
			System.out.println("Error in getGroupByNameV1");
			e.printStackTrace();
		}
		return null;
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
			System.out.println("callApi::some exception occurred");
			e.printStackTrace();
			jResponse = new JSONObject();
			jResponse.put("status", 2000);
			apiCaller.addLogEntry(procedureName, e.getMessage());
		}
		return jResponse;		
	}

    private String getPortalConfig(String config)
	{
		Set rs = Etn.execute("select * from "+env.getProperty("PORTAL_DB")+".config where code = "+escape.cote(config));
		if(rs.next()) return Util.parseNull(rs.value("val"));
		return "";
	}   

    
    private int makeBackUp(String tableName) {
        return Etn.executeCmd("create table " + tableName + "_v48 AS select * from " + tableName);
    }
    
    private int modifyColumn(String tableName, String columnName, String[] values)
    {
        StringBuilder sb = new StringBuilder("ALTER TABLE " + tableName + " MODIFY COLUMN ");
        sb.append(columnName).append(" ENUM('").append(values[0]);
        for (int i = 1; i < values.length; i++) {
            sb.append("','").append(values[i]);
        }
        sb.append("'), ADD COLUMN group_id INT(11)");
        
        return Etn.executeCmd(sb.toString());
    }

    private JSONObject createGroupAddBusinessV2(JSONArray businesses, String groupName, String sectionId, String apiKey)
    {
        try
		{
			System.out.println("In createGroupAddBusinessV2 :: " + groupName);
			String _url = partooApiUrl + "sections/" + sectionId + "/groups";

            JSONObject apiRequest = new JSONObject();
            apiRequest.put("name", groupName);
            apiRequest.put("business__in",businesses);

			JSONObject apiResponse = callApi(_url, "POST", apiKey, apiRequest.toString(), "Partoo.createGroupAddBusinessV2");

			if(apiResponse.getInt("http_code") == 200)
			{
                JSONObject jObj = new JSONObject(apiResponse.getString("response"));
                return getGroupByIdV2(apiKey, sectionId, jObj.getInt("id")+"");
			}
			return null;
		}
		catch(Exception e)
		{
			System.out.println("Error in createGroupAddBusiness");
			e.printStackTrace();
		}
        return null;
    }

    private JSONObject updateGroupAddBusinessV2(JSONArray businesses, String groupId,String groupName, String sectionId, String apiKey)
    {
        try
		{
			System.out.println("In updateGroupAddBusinessV2 :: " + groupId);
			String _url = partooApiUrl + "sections/" + sectionId + "/groups/"+groupId;

            JSONObject apiRequest = new JSONObject();
            apiRequest.put("name", groupName);
            apiRequest.put("business__in",businesses);

			JSONObject apiResponse = callApi(_url, "POST", apiKey, apiRequest.toString(), "Partoo.updateGroupAddBusinessV2");

			if(apiResponse.getInt("http_code") == 200)
			{
                JSONObject jObj = new JSONObject(apiResponse.getString("response"));
                return getGroupByIdV2(apiKey, sectionId, jObj.getInt("id")+"");
			}
			return null;
		}
		catch(Exception e)
		{
			System.out.println("Error in updateGroupAddBusinessV2");
			e.printStackTrace();
		}
        return null;
    }

    private JSONObject getGroupByIdV2(String apiKey, String sectionId, String id)
    {
        try
		{
			System.out.println("In getGroupByIdV2 :: " + id);
			String _url = partooApiUrl + "sections/" + sectionId + "/groups/"+id;

			JSONObject apiResponse = callApi(_url, "GET", apiKey, "", "Partoo.getGroupByIdV2");

			if(apiResponse.getInt("http_code") == 200)
			{
                return new JSONObject(apiResponse.getString("response"));
			}
            return null;
			
		}
		catch(Exception e)
		{
			System.out.println("Error in getGroupByIdV2");
			e.printStackTrace();
		}
        return null;
    }

    private JSONObject getGroupByNameV2(String apiKey, String name, String sectionId)
    {
        try {
            System.out.println("In getGroupByNameV2 :: " + name);
            String _url = partooApiUrl + "sections/"+sectionId ;

            JSONObject apiResponse = callApi(_url, "GET", apiKey, "", "Partoo.getGroupByNameV2");
            if(apiResponse.getInt("http_code") == 200)
			{
                JSONObject jObj = new JSONObject(apiResponse.getString("response"));
                if(jObj.has("groups") == false || jObj.getJSONArray("groups").length() == 0) return null;
                for(int i=0; i<jObj.getJSONArray("groups").length(); i++)
                {
                    JSONObject group = jObj.getJSONArray("groups").getJSONObject(i);
                    if(name.equalsIgnoreCase(Util.parseNull(group.getString("name"))))
                    {
                        return group;
                    }
                }
			}
            return null;

        } catch (Exception e) {
            System.out.println("Error in getGroupByNameV2");
            e.printStackTrace();
        }
        return null;
    }

    private JSONObject getSectionById(String apiKey,String id, String orgId)
    {
        try {
            System.out.println("In getSectionById :: " + id);
            String _url = partooApiUrl + "sections/"+id;

            JSONObject apiResponse = callApi(_url, "GET", apiKey,"", "Partoo.getSectionById");
            if(apiResponse.getInt("http_code") == 200)
			{
                JSONObject jObj = new JSONObject(apiResponse.getString("response"));
                return jObj;                
			}
            return null;

        } catch (Exception e) {
            System.out.println("Error in getSectionById");
            e.printStackTrace();
        }
        return null;
    }

    private JSONObject getSectionByName(String apiKey,String name, String orgId,int pageNum)
    {
        if(pageNum > 100) return null;
        try {
            System.out.println("In getSectionByName :: " + name);
            String _url = partooApiUrl + "sections?page="+pageNum+"&org_id="+orgId;
            JSONObject apiResponse = callApi(_url, "GET", apiKey, "", "Partoo.getSectionByName");
            if(apiResponse.getInt("http_code") == 200)
			{
                JSONObject jObj = new JSONObject(apiResponse.getString("response"));
                if(jObj.has("sections") == false || jObj.getJSONArray("sections").length() == 0) return null;
                for(int i=0; i<jObj.getJSONArray("sections").length(); i++)
                {
                    JSONObject section = jObj.getJSONArray("sections").getJSONObject(i);
                    if(name.equalsIgnoreCase(Util.parseNull(section.getString("name"))))
                    {
                        return section;
                    }
                }
			}
            return getSectionByName(apiKey, name, orgId, pageNum+1);

        } catch (Exception e) {
            System.out.println("Error in getSectionByName");
            e.printStackTrace();
        }
        return null;
    }

    private JSONObject createSection(String apiKey, String name, String orgId)
    {
        try
		{
			System.out.println("In createSection :: " + name);
			String _url = partooApiUrl + "sections";
            
            JSONObject apiRequest = new JSONObject();
            apiRequest.put("name",name);
            apiRequest.put("org_id",orgId);

			JSONObject apiResponse = callApi(_url, "POST", apiKey, apiRequest.toString(), "Partoo.createSection");

			if(apiResponse.getInt("http_code") == 200)
			{
                JSONObject jObj = new JSONObject(apiResponse.getString("response"));
                return getSectionById(apiKey,jObj.getInt("id")+"",orgId);
			}
			return null;
		}
		catch(Exception e)
		{
			System.out.println("Error in createSection");
			e.printStackTrace();
		}
        return null;
    }
    
    private JSONObject getGroupBusinessesV1(String groupId, String groupName, String apiKey) 
    {
        try
		{
			System.out.println("In getGroupBusinesses :: " + groupName);
			String _url = partooApiUrl + "groups/" + groupId + "/businesses";
			JSONObject apiResponse = callApi(_url, "GET", apiKey, "", "Partoo.getGroupBusinesses");
			if(apiResponse.getInt("http_code") == 200)
			{
                return new JSONObject(apiResponse.getString("response"));
			}
            return null;
		}
		catch(Exception e)
		{
			System.out.println("Error in getGroupBusinesses");
			e.printStackTrace();
		}
        return null;
    }

    private JSONArray removingBusinesses(JSONArray businesses1, JSONArray businesses2)
    {
        for(int i=0;i<businesses1.length();i++)
        {
            for(int j=0;j<businesses2.length();j++)
            {
                if(businesses1.getString(i).equals(businesses2.getString(j))) {
                    businesses1.remove(i);
                    i--;
                    break;
                } 
            }
        }
        return businesses1;
    }

    private void updateGroupOfStore(JSONArray businessIds, String groupId)
    {
        for(int i=0;i<businessIds.length();i++){
            Etn.executeCmd("update partoo_contents set group_id=" + escape.cote(groupId) + " where ctype='store' and partoo_id="+escape.cote(businessIds.getString(i)));            
        }
    }



    private void run() throws Exception {
        String tableName = "partoo_contents";
        // first make backup of table 
        makeBackUp(tableName);
        System.out.println("Backup Done");
        
        // modify table column adding value to enum 
        // String[] values = {"store","folder","section"};
        // modifyColumn(tableName, "ctype", values);

        // fetch partoo info from site
        Set rsSite = Etn.execute("SELECT * FROM "+GlobalParm.getParm("PORTAL_DB")+".sites where partoo_activated = '1' AND partoo_country_code IS NOT NULL AND partoo_main_group IS NOT NULL");
        while(rsSite.next()){
            if(Util.parseNull(rsSite.value("partoo_country_code")).length() == 0 || Util.parseNull(rsSite.value("partoo_main_group")).length() == 0) continue;
             
            Map<String, String> partooInfo = new HashMap<>();
            partooInfo.put("name", Util.parseNull(rsSite.value("name")));
            partooInfo.put("domain", Util.parseNull(rsSite.value("domain")));
            partooInfo.put("activated", Util.parseNull(rsSite.value("partoo_activated")));
            partooInfo.put("api_key", Util.parseNull(rsSite.value("partoo_api_key")));
            partooInfo.put("country_code", Util.parseNull(rsSite.value("partoo_country_code")));
            partooInfo.put("main_group", Util.parseNull(rsSite.value("partoo_main_group")));
            partooInfo.put("org_id", Util.parseNull(rsSite.value("partoo_organization_id")));
            partooInfo.put("langue_id", Util.parseNull(rsSite.value("partoo_language_id")));
            partooInfo.put("langue_code", Util.parseNull(rsSite.value("partoo_language_code")));

            JSONObject sectionJson = getSectionByName(partooInfo.get("api_key"),partooInfo.get("country_code"), partooInfo.get("org_id"),1);

            if(sectionJson == null){
                sectionJson = createSection(partooInfo.get("api_key"), partooInfo.get("country_code"), partooInfo.get("org_id"));
            }
            
            Etn.executeCmd("insert into "+tableName+"(ctype,site_id,partoo_id,partoo_json)"
                    +" VALUES('section',"+escape.cote(rsSite.value("id"))+","+escape.cote(""+sectionJson.getInt("id"))+","+Util.escapeCote3(sectionJson.toString())+") "
                    +" ON DUPLICATE KEY UPDATE ctype=VALUES(ctype),site_id=VALUES(site_id),partoo_id=VALUES(partoo_id),partoo_json=VALUES(partoo_json)");            
            
            JSONObject jGroup = getGroupByNameV1(partooInfo.get("api_key"),partooInfo.get("org_id"),partooInfo.get("main_group"),1);
            if(jGroup != null){
                JSONObject pGroup = getGroupBusinessesV1(jGroup.getInt("id")+"",jGroup.getString("name"),partooInfo.get("api_key"));

                JSONArray subgroups = jGroup.getJSONArray("subgroups");
                for(int i = 0; i < subgroups.length(); i++)
                {
                    JSONObject jSubGroup = subgroups.getJSONObject(i);
                    JSONObject respJson = getGroupBusinessesV1(jSubGroup.getInt("id")+"",jSubGroup.getString("name"),partooInfo.get("api_key"));
                    
                    if(respJson == null || respJson.getJSONArray("ids").length() == 0) continue;
                    
                    pGroup.put("ids",removingBusinesses(pGroup.getJSONArray("ids"), respJson.getJSONArray("ids")));

                    JSONObject groupV2 = getGroupByNameV2(partooInfo.get("api_key"),jSubGroup.getString("name"), sectionJson.getInt("id")+"");
                    if(groupV2  == null) groupV2 = createGroupAddBusinessV2(respJson.getJSONArray("ids"), jSubGroup.getString("name"), sectionJson.getInt("id")+"", partooInfo.get("api_key"));
                    else groupV2 = updateGroupAddBusinessV2(respJson.getJSONArray("ids"), groupV2.getInt("id")+"", jSubGroup.getString("name"), sectionJson.getInt("id")+"", partooInfo.get("api_key"));                 

                    updateGroupOfStore(respJson.getJSONArray("ids"),groupV2.getInt("id")+"");

                    int updateRows = Etn.executeCmd("update "+ tableName + " set partoo_id="+escape.cote(groupV2.getInt("id")+"")+ ", rjson="+Util.escapeCote3(groupV2.toString())+" where ctype='folder' and partoo_id="+escape.cote(jSubGroup.getInt("id")+""));
                    System.out.println("Update rows: " + updateRows);

                }

                if(pGroup.getJSONArray("ids").length() == 0) continue;            
                JSONObject groupV2 = getGroupByNameV2(partooInfo.get("api_key"),jGroup.getString("name"), sectionJson.getInt("id")+"");
                if(groupV2  == null) groupV2 = createGroupAddBusinessV2(pGroup.getJSONArray("ids"), jGroup.getString("name"), sectionJson.getInt("id")+"", partooInfo.get("api_key"));
                else groupV2 = updateGroupAddBusinessV2(pGroup.getJSONArray("ids"), groupV2.getInt("id")+"", jGroup.getString("name"), sectionJson.getInt("id")+"", partooInfo.get("api_key"));

                updateGroupOfStore(pGroup.getJSONArray("ids"),groupV2.getInt("id")+"");
                int updateRows = Etn.executeCmd("update "+ tableName + " set partoo_id="+escape.cote(groupV2.getInt("id")+"")+ ", rjson="+Util.escapeCote3(groupV2.toString())+" where ctype='folder' and partoo_id="+escape.cote(jGroup.getInt("id")+""));
                System.out.println("Update rows: " + updateRows);
            }
            else
                System.out.println("jGroup == null");
        }

        System.out.println("--------------------------------------------------------------");
        System.out.println("--------------------------------------------------------------");
        System.out.println("Migration Done");
        System.out.println("--------------------------------------------------------------");
        System.out.println("Switching partoo api to v2");
		Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".config (code, val) value ('partoo_api_version','v2') on duplicate key update val = 'v2'");
		System.out.println("--------------------------------------------------------------");
		System.out.println("Before restarting partoo engine, check the partoo_api_version is set to v2 in commons db config");
		System.out.println("--------------------------------------------------------------");
		System.out.println("Restart partoo engine and check its logs to make sure its now using v2 api.");
    }

    public static void main(String[] args) throws Exception {
		System.out.println("To continue with Partoo migration, partoo engine must be stopped. To stop partoo engine use stopschedPartoo command and make sure it does not start again during migration. Comment it on crontab to be on safe side.");
		System.out.println("    ");
		System.out.println("Type continue or exit");
		BufferedReader reader = new BufferedReader(
            new InputStreamReader(System.in));

        // Reading data using readLine
        String c = reader.readLine();        
		if(c.equalsIgnoreCase("exit") == false)
		{
			new PartooMigration(args).run();
		}
    }
}

