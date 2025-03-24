package com.etn.util;

import java.util.Map;
import java.util.HashMap;
import com.etn.lang.ResultSet.Set;

public class Logger
{
	public static void debug(String cls, String s)
	{
		printMsg(cls, s, "D");
	}

	public static void debug(String s)
	{
		printMsg("", s, "D");
	}

	public static void info(String cls, String s)
	{
		printMsg(cls, s, "I");
	}

	public static void info(String s)
	{
		printMsg("", s, "I");
	}

	public static void error(String cls, String s)
	{
		printMsg(cls, s, "E");
	}

	public static void error(String s)
	{
		printMsg("", s, "E");
	}

	private static void printMsg(String cls, String s, String level)
	{
		String debugLevel = com.etn.beans.app.GlobalParm.getParm("LOGGER_LEVEL");
		if(debugLevel == null || debugLevel.trim().length() == 0) debugLevel = "info";

		if(cls != null && cls.length() > 0) s = cls.trim() + "::"+s.trim();

		String appName = com.etn.beans.app.GlobalParm.getParm("APP_NAME");
		if(appName == null || appName.trim().length() == 0) appName = "";
		else appName = appName.trim() + "::";
		
		if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV")) == true) appName = "PROD-ENV::" + appName;
		
		appName = com.etn.util.ItsDate.getWith(System.currentTimeMillis(),true) + "::" + appName;

		if("error".equalsIgnoreCase(debugLevel) && "E".equalsIgnoreCase(level)) System.out.println(appName + "ERROR::" + s);
		else if("info".equalsIgnoreCase(debugLevel)) 
		{
			if("E".equalsIgnoreCase(level)) System.out.println(appName + "ERROR::" + s);
			else if("I".equalsIgnoreCase(level)) System.out.println(appName + "INFO::" + s);
		}
		else if("debug".equalsIgnoreCase(debugLevel))
		{
			if("E".equalsIgnoreCase(level)) System.out.println(appName + "ERROR::" + s);
			else if("I".equalsIgnoreCase(level)) System.out.println(appName + "INFO::" + s);
			else if("D".equalsIgnoreCase(level)) System.out.println(appName + "DEBUG::" + s);
		}

	}
}