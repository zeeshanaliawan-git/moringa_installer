package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;


import java.util.Properties;

public class Purger
{ 


	private Properties env;
	private ClientSql Etn;


	public Purger() throws Exception
	{   
		env = new Properties();
		env.load( getClass().getResourceAsStream("Scheduler.conf") );
    
		Etn = new ClientDedie(  "MySql", "com.mysql.jdbc.Driver", env.getProperty("CONNECT") );
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	private void purge(boolean isprod) 
	{
		String dbname = "";
		if(isprod) dbname = parseNull(env.getProperty("PROD_DB")) + ".";

		Set rs = Etn.execute("select * from "+dbname+"purge_pages ");
		while(rs.next())
		{
			System.out.println(env.getProperty("DELETE_FILE_SCRIPT") + " " + parseNull(rs.value("page_path")));
			try
			{
				Process proc = Runtime.getRuntime().exec(env.getProperty("DELETE_FILE_SCRIPT") + " " + parseNull(rs.value("page_path")));
				int r = proc.waitFor();					
				Etn.executeCmd("delete from "+dbname+"purge_pages where page_path = " + escape.cote(parseNull(rs.value("page_path"))));
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
		}
	}

	public static void main( String a[] ) throws Exception
	{
		Purger p = new Purger();

		p.purge(false);
		p.purge(true);
	}

}
