package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import java.util.Properties;
import com.etn.sql.escape;
import java.lang.Process;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static java.nio.file.StandardCopyOption.COPY_ATTRIBUTES;
import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;


public class PublishOrdering extends OtherAction 
{
	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		if("product".equalsIgnoreCase(param)) return publishProduct(etn, wkid, clid);
		else if("familie".equalsIgnoreCase(param)) return publishFamilie(etn, wkid, clid);
		return -1;
	}

	private String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	private int publishFamilie(ClientSql etn, int wkid, String clid)
	{
		try 
		{
			System.out.println("Publish ordering for familie id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from familie where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				rs.next();

				int i = etn.executeCmd("update "+proddb+".familie set order_seq = "+escape.cote(parseNull(rs.value("order_seq")))+", updated_on = now() where id = " + escape.cote(rs.value("id")));

				((Scheduler)env.get("sched")).endJob( wkid , clid );		
				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishProduct(ClientSql etn, int wkid, String clid)
	{
		try 
		{
			System.out.println("Publish ordering for product id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from products where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				rs.next();
				String cid = rs.value("catalog_id");
				int i = etn.executeCmd("update "+proddb+".products set order_seq = "+escape.cote(parseNull(rs.value("order_seq")))+", updated_on = now() where id = " + escape.cote(rs.value("id")));

				((Scheduler)env.get("sched")).endJob( wkid , clid );		
				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}
}