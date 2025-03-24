package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.util.Properties;
import java.util.Random;
import java.util.List;
import java.util.ArrayList;

/** 
 * Must be extended.
*/
public class CheckAuto extends OtherAction 
{ 

	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		return execute(wkid, clid, param);
	}

	public int execute( int wkid , String clid, String param )
	{ 
		System.out.println("Sql wid:"+wkid+" cl:"+clid+" parm:"+param);
		if( param.equalsIgnoreCase("autoAccept") )
		{
			return isAutoAccept(wkid, clid);
		}
		else
		{
			System.out.println("Function not supported");
			return -1;
		}
	}
	
	private int isAutoAccept(int wkid, String clid)
	{
		int retVal = 0;
		try
		{
			System.out.println("in Auto Accept function...");

			String dbname = env.getProperty("PROD_PORTAL_DB");

			Set rsS = etn.execute("SELECT form_table_name FROM post_work WHERE id = " + escape.cote(wkid+""));
			if(rsS.next()){

				String tableName = Util.parseNull(rsS.value("form_table_name"));
				Set portalRs = etn.execute("SELECT ct.portalurl FROM " + tableName + " ct WHERE " + tableName + "_id = " + escape.cote(clid));
	
				if(portalRs.next()){

					String portalUrl = Util.parseNull(portalRs.value("portalurl"));
					if(portalUrl.toLowerCase().contains("_portal"))
						dbname = env.getProperty("PORTAL_DB");

					Set checkAutoAcceptRs = etn.execute("SELECT s.auto_accept_signup FROM " + tableName + " ct, process_forms pf, " + dbname + ".sites s WHERE ct.form_id = pf.form_id and " + tableName + "_id = " + escape.cote(clid) + " AND pf.site_id = s.id");

					if(checkAutoAcceptRs.next()){

						String checkAutoAcceptConfig = Util.parseNull(checkAutoAcceptRs.value("auto_accept_signup"));

						if(checkAutoAcceptConfig.equals("0")){

							etn.execute("UPDATE post_work SET errcode = " + escape.cote("10") + " WHERE id = " + escape.cote(wkid+""));
						}
					}
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		if(retVal == 0)
		{
			((Scheduler)env.get("sched")).endJob( wkid , clid );			
		}
		return retVal;
	}
	
}
