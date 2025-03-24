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
public class CheckAdmin extends OtherAction 
{ 

	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		return execute(wkid, clid, param);
	}

	public int execute( int wkid , String clid, String param )
	{ 
		System.out.println("Sql wid:"+wkid+" cl:"+clid+" parm:"+param);
		if( param.equalsIgnoreCase("adminRequest") )
		{
			return isAdminRequest(wkid, clid);
		}
		else
		{
			System.out.println("Function not supported");
			return -1;
		}
	}
	
	private int isAdminRequest(int wkid, String clid)
	{
		int retVal = 0;
		try
		{
			System.out.println("in isAdminRequest function");
			Set rsS = etn.execute("SELECT form_table_name FROM post_work WHERE id = " + escape.cote(wkid+""));

			if(rsS.next())
			{
				String tableName = Util.parseNull(rsS.value("form_table_name"));
				Set tableRs = etn.execute("SELECT *, pf.site_id FROM " + tableName + " ct, process_forms pf WHERE ct.form_id = pf.form_id and " + tableName + "_id = " + escape.cote(clid));

				if(tableRs.next()){

					String siteId = Util.parseNull(tableRs.value("site_id"));
					boolean isProd = false;
					String portalUrl = Util.parseNull(tableRs.value("portalurl"));
					String dbname = env.getProperty("PROD_PORTAL_DB");
					String isAdmin = Util.parseNull(tableRs.value("is_admin"));

					if(isAdmin.equals("0")){
						etn.execute("UPDATE post_work SET errcode = " + escape.cote("10") + " WHERE id = " + escape.cote(wkid+""));
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
