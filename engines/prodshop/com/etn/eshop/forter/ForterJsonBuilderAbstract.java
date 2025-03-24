package com.etn.eshop.forter;

import com.etn.Client.Impl.ClientSql;
import java.util.Properties;
import org.json.JSONArray;
import org.json.JSONObject;


/*
* Countries can sometimes have difference in the personal details/address/payment options so they can implement this class 
* to create json as per their requirements
*
*/
public abstract class ForterJsonBuilderAbstract 
{ 
	public ClientSql etn;
	public Properties env;
	public int wkid;
	public String clid;

	public int init( ClientSql etn , Properties conf, int wkid, String clid )
	{ 
		this.etn = etn;
		this.env = conf;
		this.wkid = wkid;
		this.clid = clid;
		return(0); // OK
	}
		
	public JSONArray getPayments(  ) throws Exception
	{ 
		return null;
	}

	public JSONObject getPrimaryRecipient(  ) throws Exception
	{ 
		return null;
	}

	public JSONObject getPrimaryDeliveryDetails(  ) throws Exception
	{ 
		return null;
	}

}
