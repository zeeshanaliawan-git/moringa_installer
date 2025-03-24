package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import java.util.Properties;
import com.etn.sql.escape;
import java.lang.Process;
import com.etn.util.Base64;


public class Remove extends OtherAction 
{
	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		if("menu".equalsIgnoreCase(param)) return deleteMenu(etn, wkid, clid);
		return -1;
	}

	private String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	private int deleteMenu(ClientSql etn, int wkid, String clid)
	{
		try 
		{
			String proddb = env.getProperty("PROD_DB");
			Set rs = etn.execute("Select * from site_menus where id = " + clid);
			if(rs.rs.Rows == 0) return -1;


			etn.executeCmd("delete from "+proddb+".additional_menu_items where menu_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".menu_apply_to where menu_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".menu_items where menu_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".site_menus where id = " + escape.cote(clid));
			//dont delete from cached_pages as they sometimes make mistake of removing menu and then we loose all .html urls and they will be generated new
			//so we keep data in cached_pages

			//NOTE::Once all the sites go in v2.2 after that we can make improvement to actually delete rows from cached_pages and cached_pages_path 
			//when a menu is deleted because in v2.2 we are using webmaster urls so in case they publish the same site again to production the URLs wont change
			//So this can be done down the road once all pages are generated as per webmaster url
			//maybe some pages were on auto refresh so we just set that timer to 0 as menu is deleted from production
			etn.executeCmd("update "+proddb+".cached_pages set refresh_minutes = 0 where menu_id = " + escape.cote(clid));

		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}
}