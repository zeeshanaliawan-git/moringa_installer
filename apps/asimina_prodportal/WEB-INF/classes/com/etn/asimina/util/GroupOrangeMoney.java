package com.etn.asimina.util;

import java.util.Map;
import java.util.HashMap;
/**
* Purpose of this class is just to maintain the orange money token and expiry timestamp
* We had it in database before but orange made a recent change in which case the token can be max 3kb of length
* so we moved it out of database
* NOTE: We should not add any other logic in this class
*/
public class GroupOrangeMoney {
	private static Map<String, Map<String, String>> tokens = new HashMap<String, Map<String, String>>();
	
	public static void setToken(String siteid, String token, long expiry)
	{
		if(tokens.get(siteid) == null)
		{
			tokens.put(siteid, new HashMap<String, String>());
		}
		
		Map<String, String> siteMap = tokens.get(siteid);
		com.etn.util.Logger.info("GroupOrangeMoney","Site ID:"+siteid+" map size: "+siteMap.size());
		siteMap.put("token", token);
		siteMap.put("expiry", ""+expiry);
		com.etn.util.Logger.info("GroupOrangeMoney","Site ID:"+siteid+" map size: "+siteMap.size());
	}
	
	public static String getAccessToken(String siteid)
	{
		if(tokens.get(siteid) == null) return null;
		
		Map<String, String> siteMap = tokens.get(siteid);
		return siteMap.get("token");
	}

	public static long getExpiry(String siteid)
	{
		if(tokens.get(siteid) == null) return 0;
		
		Map<String, String> siteMap = tokens.get(siteid);
		if(siteMap.get("expiry") == null) return 0;
		long expiry = 0;
		try {
			expiry = Long.parseLong(siteMap.get("expiry"));
		} catch(Exception e) {}
		return expiry;
	}
}