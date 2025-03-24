package com.etn.util;

import java.util.Map;
import java.util.HashMap;
import com.etn.lang.ResultSet.Set;

public class AppConfig
{
	private static Map<String, String> configs;

	public static String getConfig(String conf)
	{
		if(configs == null || configs.size() == 0)
		{
			AppConfig.refreshConfig();
		}

		if(configs != null && configs.size() > 0)
		{
			return configs.get(conf);
		}
		else return null;
	}

	public static void refreshConfig(){
		configs = new HashMap<String, String>();
		com.etn.beans.Contexte Etn = new com.etn.beans.Contexte();
		Set rs = Etn.execute("select * from config");
		while(rs != null && rs.next())
		{
			configs.put(rs.value("code"), rs.value("val"));
		}
	}
}