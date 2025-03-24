package com.etn.asimina.beans;

import java.util.*;

public class Client
{
	private Map<String, String> properties;
	
	//these properties are all the columns in client table
	//etn always return column names in upper case
	//for safe side to make the case same we put them in lowercase and later check in lowercase
	public void addProperty(String key, String val)
	{
		if(this.properties == null) this.properties = new HashMap<String, String>();
		this.properties.put(key.toLowerCase(), val);
	}
	
	public String getProperty(String prop)
	{
		if(this.properties == null || this.properties.size() == 0) return null;
		for(String key : this.properties.keySet())
		{
			//we set in lowercase
			if(key.equals(prop.toLowerCase())) return this.properties.get(key);
		}
		return null;
	}
	
}