package com.etn.eshop;

import java.io.*;
import java.util.Properties;

import com.etn.util.ItsDate;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.lang.Process;


public class Scheduler 
{ 
	Properties env;
	ClientSql Etn;
	boolean stop = false;

	final int wait_timeout;
	final boolean debug;
	final String semaphore;

	private void log(String m)
	{
		if(!debug) return;		
		m = "Cache Sync::" + m;
		System.out.println(m);
	}

	public Scheduler( String parm[]) throws Exception
	{   
		env = new Properties();
		env.load( getClass().getResourceAsStream("Scheduler.conf") );
    
		Etn = new ClientDedie(  "MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT") );

		env.put( "sched", this);

		semaphore = (String)env.get("SEMAPHORE");
  
		if( env.get("WAIT_TIMEOUT")==null ) wait_timeout = 300;
		else 
		{ 
			int k = Integer.parseInt(env.getProperty("WAIT_TIMEOUT"));
			wait_timeout = (k==0?300:k);
		}

		debug =  env.get("DEBUG")!=null || env.get("SCHED_DEBUG") != null;

	}

	public static int atoi( String s) 
	{
		if(s==null ||s.length() == 0 ) return(0);
		int u=0,c;
		for( int i = 0 ; i < s.length() ; i++ )
		{ 
			if(!Character.isDigit( c = s.charAt(i) ) )
			break;
			u *= 10;
			u += (c - '0') ;
		}
		return(u);
	}

	String  getTime()
	{ 
		return( ItsDate.getWith(System.currentTimeMillis(),true) ); 
	}

	String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	public void run()
	{
		Set rs;
		int wkid = 0; 

		File toStop = new File("_stop");
		toStop.delete();

		System.out.println("*****************\nDémarrage Scheduler ("+getTime()+")");
		System.out.println("Timeout:"+wait_timeout);
   
		try 
		{
			while( !stop )
			{
				if( toStop.exists() ) break;

				Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Cachesync',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
				// Find Rows with action pending post_work.flag = 0
				while( true )
				{      
					wkid = 0 ;
					rs = Etn.execute( new String[] {
					"set @id := 0",
					"update cache_sync p "+
					" inner join ( select p2.id from cache_sync p2 "+
					" where p2.priority <= now() "+
					" and p2.status = 0  "+
					" order by p2.priority limit 1 ) ssid "+
					" on ssid.id = p.id "+
					" set p.status = 1, p.start = now(), "+
					" p.id = @id := p.id ",
					"select @id "} );
      
					if( rs.next() && rs.next() && rs.next() )
						wkid = atoi(rs.value(0));

					if( wkid != 0 )
					{ 
						syncCache(wkid);
						Etn.execute("update cache_sync set status=0 where id="+wkid+" and status=1 ");
					}
					else break;
				}

				Etn.executeCmd("update "+env.getProperty("COMMONS_DB")+".engines_status set end_date=NOW() where engine_name='Cachesync'");

				// Wait PORTAL message on 300 secs timeout
				if( debug ) System.out.println("Wait "+semaphore+"("+getTime()+")");

				while( true)
				{ 
					rs = Etn.execute("select semwait('"+semaphore+"',"+wait_timeout+")");   
					if( rs == null ) refreshTun();
					else break;
				}

				//if( debug ) System.out.println("New Fin Wait("+getTime()+")");
			}

		}
		catch( Exception db )
		{ 
			db.printStackTrace(); 
		}
		finally 
		{
			System.out.println("Arret Scheduler ("+getTime()+")" );
		}
	}

	private void syncCache(int wkid) 
	{
		String isforcedsync = "";
		try
		{
			System.out.println("Starting cache sync process ");
			Set rs = Etn.execute("select * from cache_sync where id = " + wkid);
			rs.next();
			
			//forced sync is when cache on primary server is updated and it will force secondary server to sync cache
			isforcedsync = parseNull(rs.value("is_forced_sync"));

			System.out.println("Is forced sync : " + isforcedsync);
			
			String cmd = env.getProperty("SCRIPT");
			Process proc = Runtime.getRuntime().exec(cmd);
			int r = proc.waitFor();					
			System.out.println("result :" + r + " for " + cmd);			
			
			System.out.println("End cache sync process ");
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			Etn.execute("update cache_sync set status=2, end = now() where id="+wkid);

			//not a forced sync so we sync cache every 4hrs
			if(!"1".equals(isforcedsync)) 
			{
				Etn.execute("insert into cache_sync (priority, status, insertion_date, is_forced_sync) values (date_add(now(), interval 4 hour), 0, now(), 0) ");
			}
		}
	}

	public static void main( String a[] ) throws Exception
	{
		new Scheduler(a).run();
	}

	public void refreshTun()
	{
		if(  env.getProperty("TUNNEL") == null ) return;

		System.out.println("refreshTun");
		try 
		{	
			Process p = Runtime.getRuntime().exec( env.getProperty("TUNNEL") );
			p.waitFor();
		}
		catch( Exception z )
		{ z.printStackTrace(); }

		try { Thread.currentThread().sleep( 60000 ); }
		catch( Exception inutile ) {}
	}


}
