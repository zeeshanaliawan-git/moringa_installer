package com.etn.asimina.beans;

import com.etn.lang.ResultSet.Set;
import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;
import com.etn.util.Logger;
import com.etn.asimina.util.*;

import java.util.*;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

public class PaymentsRef
{
	private Map<String, String> properties;
		
	//these properties are all the columns in cart table
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