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

public class PartooServices 
{
    private Properties env;
	private com.etn.beans.Etn Etn;
	private String partooApiUrl = "";

	private ApiCaller apiCaller;
	
	private boolean useProxy = true;//by default we assume we will use proxy if its configured

    public PartooServices(Etn Etn, Properties env) throws Exception
	{
		this.Etn = Etn;
		this.env = env;

        partooApiUrl = Util.parseNull(env.getProperty("partoo_api_base_url"));
		if(partooApiUrl.endsWith("/") == false) partooApiUrl += "/";
        partooApiUrl += "business/";
		
		if("false".equalsIgnoreCase(env.getProperty("partoo_api_use_proxy")) || "0".equals(env.getProperty("partoo_api_use_proxy"))) useProxy = false;
		
		apiCaller = new ApiCaller(Etn, env, true);
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

    private boolean executePartooApis(String categoryId,String category,String siteId,String apiKey) throws Exception
	{
        int totalDelete = 0;
        int actualDelete = 0;
        Set rs2 = Etn.execute("select * from partoo_services_work where attempt<5 and status != 'success' and services_id="+escape.cote(categoryId)+" order by created_on asc");
        while(rs2.next())
		{
            String workId = Util.parseNull(rs2.value("id"));
            String partooId = Util.parseNull(rs2.value("partoo_id"));
            String method = Util.parseNull(rs2.value("method"));
            JSONObject requestJson = new JSONObject(Util.parseNull(rs2.value("request_json")));
            String url = partooApiUrl+partooId+"/";

            if(method.equalsIgnoreCase("post"))
			{
                url+="free_form_services";
                JSONObject apiResponse = callApi(url, "post", apiKey, requestJson.toString(), "PartooServices.executePartooApis");
                System.out.println("Api Rsponse in executePartooApis for post==============="+apiResponse.toString());
                if(apiResponse.getInt("http_code")==200)
                {
                    JSONObject partooJsonResponse = new JSONObject(Util.parseNull(apiResponse.optString("response")));
                    JSONArray serviceArray = partooJsonResponse.getJSONArray("services");
                    for(int i=0;i<serviceArray.length();i++){
                        Etn.executeCmd("insert into partoo_services_details (partoo_work_id,partoo_id,category,service_id,service_name,service,site_id)"+
                        " VALUES ("+escape.cote(workId)+","+escape.cote(partooId)+","+escape.cote(category)+","+serviceArray.getJSONObject(i).getInt("service_id")+
                        ","+escape.cote(serviceArray.getJSONObject(i).getString("name"))+","+Util.escapeCote3(serviceArray.getJSONObject(i).toString())+","+escape.cote(siteId)+")"+
                        "on duplicate key update service=values(service)");
                    }
                    Etn.executeCmd("update partoo_services_work set attempt=attempt+1, status='success' where id="+escape.cote(workId));
                }
                else if(apiResponse.has("http_code"))//if not has http_code means there was some exception in code
				{
                    String respType = "error";
                    JSONObject objTmp = new JSONObject(Util.parseNull(apiResponse.optString("response")));

                    if(objTmp.has("errors") && objTmp.getJSONObject("errors").has("json") && objTmp.getJSONObject("errors").getString("json").equalsIgnoreCase("A service with the same name already exist")){
                        respType="success";
                    }

                    Etn.executeCmd("update partoo_services_work set attempt=attempt+1, status="+escape.cote(respType)+",error_msg="+
                        Util.escapeCote3(Util.parseNull(apiResponse.optString("response")))+" where id="+escape.cote(workId));
                }
            }
			else
			{
                totalDelete=totalDelete+1;
                url+="services";
                JSONObject apiResponse = callApi(url, "delete", apiKey, requestJson.toString(), "PartooServices.executePartooApis");
                System.out.println("Api Rsponse in executePartooApis for delete==============="+apiResponse.toString());
                if(apiResponse.getInt("http_code")==200)
                {
                    Etn.executeCmd("insert into partoo_services_details_deleted (partoo_work_id,partoo_id,category,service_name,service_id,service,site_id) values "+
                        " select partoo_work_id,partoo_id,category,service_name,service_id,service,site_id from partoo_services_details  where partoo_id="+escape.cote(partooId));
                    Etn.executeCmd("delete from partoo_services_details where partoo_id="+escape.cote(partooId));
                    Etn.executeCmd("update partoo_services_work set attempt=attempt+1, status='success' where id="+escape.cote(workId));
                    actualDelete=actualDelete+1;
                }else{
                    Etn.executeCmd("update partoo_services_work set attempt=attempt+1, status='error',error_msg="+Util.escapeCote3(Util.parseNull(apiResponse.optString("response")))+" where id="+escape.cote(workId));
                }
            }

        }
        if(totalDelete==actualDelete){
            return true;
        }else{
            return false;
        }
    }


    public void processPartoo(String siteId) throws Exception{
        try{            
            Set rsSite = Etn.execute("Select partoo_api_key from "+env.getProperty("PORTAL_DB")+".sites where id = "+escape.cote(siteId));
            rsSite.next();
            String apiKey=Util.parseNull(rsSite.value("partoo_api_key"));
            
            Set rs = Etn.execute("select * from partoo_services where site_id="+escape.cote(siteId));
			if(rs.rs.Rows > 0)
			{
				System.out.println("============In Partoo Services=============== "+siteId);
			}
            while(rs.next()){
				
                String categoryId = Util.parseNull(rs.value("id"));
                String category = Util.parseNull(rs.value("category"));

                executePartooApis(categoryId,category,siteId,apiKey);
                
                if(rs.value("to_delete").equals("1")){
                    Set rsService= Etn.execute("SELECT partoo_id FROM partoo_contents WHERE ctype='store' and rjson LIKE "+escape.cote('%'+category+'%')+" and site_id="+escape.cote(siteId));
                    
                    while(rsService.next()){
                        String partooId = Util.parseNull(rs.value(0));
                        Set rs2 = Etn.execute("select * from partoo_services_details where partoo_id="+escape.cote(partooId)+" and site_id="+escape.cote(siteId)+" and category="+escape.cote(category));
                        while(rs2.next()){
                            JSONObject serviceObj = new JSONObject();
                            serviceObj.put("service_id",Integer.parseInt(Util.parseNull(rs2.value("service_id"))));
                            Etn.executeCmd("insert into partoo_services_work (services_id,partoo_id,method,request_json,site_id) values ("+escape.cote(categoryId)+","
                                +escape.cote(partooId)+",'delete',"+escape.cote(serviceObj.toString())+","+escape.cote(siteId)+")");
                        }
                    }
                    boolean status = executePartooApis(categoryId,category,siteId,apiKey);
                    if(status == true){
                        Etn.executeCmd("insert into partoo_services_deleted (category,service_name,price,description,site_id,created_by,updated_by) values "+
                            "select category,service_name,price,description,site_id,created_by,updated_by from partoo_services where id="+escape.cote(categoryId));
                        Etn.executeCmd("delete from partoo_services where id="+escape.cote(categoryId));
                    }
                }
            }
        }catch(Exception ex){
            ex.printStackTrace();
            throw new Exception("Error in processing partoo services.",ex);
        }
    }

	private void log(String m)
	{
		logE(m);
	}

	private void logE(String m)
	{
		System.out.println("PartooServices::----------------- " + m);
	}

}