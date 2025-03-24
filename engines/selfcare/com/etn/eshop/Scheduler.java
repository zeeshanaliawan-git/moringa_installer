package com.etn.eshop;

import java.io.*;
import java.util.Properties;
import java.util.StringTokenizer;

import com.etn.util.ItsDate;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.eshop.Dictionary;

public class Scheduler
{
	Properties env;
	ClientSql Etn;
	boolean stop = false;

	final int wait_timeout;
	final boolean debug;
	final String semaphore;
	SendMail sendMail;
	Dictionary dictionary;

	public Scheduler( String parm[]) throws Exception
	{
		env = new Properties();
		env.load(new InputStreamReader( getClass().getResourceAsStream("Scheduler.conf") , "UTF-8" )) ;

		Etn = new ClientDedie(  "MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT") );

		//load config from db
		Set rs = Etn.execute("SELECT code,val FROM config");
		while (rs.next())
		{
			env.setProperty(rs.value("code"), rs.value("val"));
		}
		String commonsDb = env.getProperty("COMMONS_DB");
		if (commonsDb.trim().length() > 0)
		{
			//load from commons db but don't override local config
			rs = Etn.execute("SELECT code,val FROM " + commonsDb + ".config");
			while (rs.next())
			{
				if (!env.containsKey(rs.value("code")))
				{
					env.setProperty(rs.value("code"), rs.value("val"));
				}
			}
		}


		env.put( "sched", this);

		semaphore = (String)env.get("SELFCARE_SEMAPHORE");

		if( env.get("SELFCARE_WAIT_TIMEOUT")==null ) wait_timeout = 300;
		else
		{
			int k = Integer.parseInt(env.getProperty("SELFCARE_WAIT_TIMEOUT"));
			wait_timeout = (k==0?300:k);
		}

		debug =  env.get("SELFCARE_DEBUG")!=null || env.get("SCHED_DEBUG") != null;

		sendMail = new SendMail(Etn, env);
		dictionary = new Dictionary(Etn, env);
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
			rs=Etn.execute("select * from "+env.getProperty("COMMONS_DB")+".reload_translations where id='selfcare'");
			if(rs!=null && rs.next() && rs.rs.Rows>0){
				dictionary = new Dictionary(Etn , env);
				Etn.executeCmd("delete from "+env.getProperty("COMMONS_DB")+".reload_translations where id='selfcare'");
			}
			while( !stop )
			{
				if( toStop.exists() ) break;

				//emails of preprod
				sendUserVerificationEmail(false);

				sendUserVerificationEmail(true);

				sendForgotPasswordMailEmails(false);

				sendForgotPasswordMailEmails(true);

				sendAdminForgotPasswordMailEmails(parseNull(env.getProperty("CATALOG_DB"))+".", parseNull(env.getProperty("ADMIN_FORGOT_PASS_URL")));
				sendAdminForgotPasswordMailEmails(parseNull(env.getProperty("SHOP_DB"))+".", parseNull(env.getProperty("DANDELION_TEST_FORGOT_PASS_URL")));//test dendlion
				sendAdminForgotPasswordMailEmails(parseNull(env.getProperty("PROD_SHOP_DB"))+".", parseNull(env.getProperty("DANDELION_PROD_FORGOT_PASS_URL")));//prod dendlion
				
				sendAuthenticationCodeEmail(parseNull(env.getProperty("CATALOG_DB"))+".", parseNull(env.getProperty("APP_INSTANCE_NAME"))+" moringa");
				sendAuthenticationCodeEmail(parseNull(env.getProperty("SHOP_DB"))+".", parseNull(env.getProperty("APP_INSTANCE_NAME")) + " test dandelion");
				sendAuthenticationCodeEmail(parseNull(env.getProperty("PROD_SHOP_DB"))+".", parseNull(env.getProperty("APP_INSTANCE_NAME")) + " dandelion");

				sendStockThreshEmail(false);
				sendStockThreshEmail(true);


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


	private void sendAuthenticationCodeEmail(String dbName,String appName)
	{
		Set rsLang = Etn.execute("Select * from language order by langue_id limit 1");
		rsLang.next();
		String lang = rsLang.value("langue_code");
		
		Set rs = Etn.execute("select l.*,p.e_mail as 'email',p.first_name,p.last_name from "+dbName+"login l left join "+dbName+"person p on p.person_id=l.pid where l.send_email = 1");
		while(rs.next())
		{
			System.out.println("Sending email for QR code to user: " + rs.value("name"));
			int r = sendMail.qrCodeEmail(rs,appName,lang, dictionary);
			if(r == 1) Etn.execute("update "+dbName+"login set send_email = 0 where name = " + escape.cote(rs.value("name")));
		}
	}
	
	private void sendForgotPasswordMailEmails(boolean isprod)
	{
		String dbname = "";
		if(isprod)
		{
			dbname = env.getProperty("PROD_DB") + ".";
		}

		//emails of prod
		Set rs = Etn.execute("select * from "+dbname+"clients where forgot_password = 1 order by id ");
		while(rs.next())
		{
			System.out.println("ISPROD : " + isprod + " sending email for forgot password client id : " + rs.value("id"));
			int r = sendMail.forgotPassword(rs, isprod, dictionary );
			if(r == 1) Etn.execute("update "+dbname+"clients set forgot_password = 0 where id = " + escape.cote(rs.value("id")));
		}
	}

	private void sendAdminForgotPasswordMailEmails(String dbname, String forgotpassurl)
	{
		Set rs = Etn.execute("select * from "+dbname+"person where forgot_password = 1 order by person_id ");
		while(rs.next())
		{
			System.out.println("ADMIN : sending email for forgot password person id : " + rs.value("person_id"));
			int r = sendMail.forgotPasswordAdmin(rs, dictionary, dbname, forgotpassurl );
			if(r == 1) Etn.execute("update "+dbname+"person set forgot_password = 0 where person_id = " + escape.cote(rs.value("person_id")));
		}
	}

	private void sendStockThreshEmail(boolean isprod)
	{
		System.out.println("Send Stock Thresh Email");
		String emailCol = "email_test";
		String dbname = env.getProperty("PREPROD_CATALOG_DB")+".";
		if(isprod){
			emailCol = "email_prod";
			dbname = env.getProperty("PROD_CATALOG_DB")+".";
		} 
		
		Set inventoryRs = Etn.execute("SELECT * FROM "+env.getProperty("COMMONS_DB")+".inventory_mail WHERE DATE("+((isprod)? "prod_email_sent_ts":"test_email_sent_ts")+") <= CURDATE() AND TIME(NOW()) >= '00:00:00' AND TIME(NOW()) <= '03:00:00'");

		while(inventoryRs.next())
		{
			if(parseNull(inventoryRs.value(emailCol)).length() == 0) continue;
			
			Set rsLang =  Etn.execute("SELECT * FROM "+dbname+"language l INNER JOIN "+env.getProperty("COMMONS_DB")+".sites_langs sl on l.langue_id = sl.langue_id where site_id="+escape.cote(parseNull(inventoryRs.value("site_id"))));
			rsLang.next();

			Set siteRs = Etn.execute("SELECT * FROM sites where id="+escape.cote(parseNull(inventoryRs.value("site_id"))));
			siteRs.next();

			String qry = "select p.*, pv.*, c.name as catalog_name from "+dbname+"products p inner join "+dbname+"product_variants pv on  p.id = pv.product_id and pv.stock_thresh <> 0 and pv.stock_thresh >= pv.stock left join "+dbname+"catalogs c on p.catalog_id = c.id where c.site_id="+escape.cote(parseNull(inventoryRs.value("site_id")));
			Set productRs = Etn.execute(qry);
			
			int resp = sendMail.minimumStockEmail(productRs, dictionary, inventoryRs.value(emailCol),parseNull(rsLang.value("langue_code")),parseNull(rsLang.value("langue_id")),parseNull(inventoryRs.value("site_id")),parseNull(siteRs.value("name")));
			
			System.out.println(resp);
			
			if(resp == 1){
				Etn.executeCmd("Update "+env.getProperty("COMMONS_DB")+".inventory_mail set "+ ((isprod)? "prod_email_sent_ts=NOW()":"test_email_sent_ts=NOW()") +" where site_id="+escape.cote(parseNull(inventoryRs.value("site_id"))));			
				System.out.println("EMAIL SENT");
			} 
		}
	}

	private void sendUserVerificationEmail(boolean isprod)
	{
		String dbname = "";
		if(isprod)
		{
			dbname = env.getProperty("PROD_DB") + ".";
		}

		//emails of prod
		Set rs = Etn.execute("select * from "+dbname+"clients where send_verification_email = 1 order by id ");
		while(rs.next())
		{
			System.out.println("ISPROD : " + isprod + " sending email for verification to client id : " + rs.value("id"));
			int r = sendMail.userVerificationEmail(rs, isprod, dictionary );
			if(r == 1) Etn.execute("update "+dbname+"clients set send_verification_email = 0 where id = " + escape.cote(rs.value("id")));
		}
	}

	public static void main( String a[] ) throws Exception
	{
		new Scheduler(a).run();
	}

	public void refreshTun()
	{
		if(  env.getProperty("SELFCARE_TUNNEL") == null ) return;

		System.out.println("refreshTun");
		try
		{
			Process p = Runtime.getRuntime().exec( env.getProperty("SELFCARE_TUNNEL") );
			p.waitFor();
		}
		catch( Exception z )
		{ z.printStackTrace(); }

		try { Thread.currentThread().sleep( 60000 ); }
		catch( Exception inutile ) {}
	}


}
