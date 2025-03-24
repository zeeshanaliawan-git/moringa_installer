package com.etn.eshop;

import java.io.*;
import java.net.URL;

import java.security.*;
import java.security.cert.*;

import javax.net.ssl.*;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Properties;
import java.util.StringTokenizer;

import com.etn.util.ItsDate;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import java.util.*;

import java.lang.reflect.Type;
import com.etn.eshop.Dictionary;

public class Scheduler
{
    Properties env;
    ClientSql Etn;
    boolean stop = false;
    SendSms sendsms;
    SendMail sendmail;
    SendStockMail sendstockmail;
    CreateInvoice createInvoice;
    Sso sso;
	GenericMail genericMail ;
	DashboardMail dashboardMail;
	private Dictionary dictionary;
	String engineName;

    final int wait_timeout;
    final boolean debug;

    class DynAction
    {
        String tag;
        OtherAction oth;
        //String event;
    }

    DynAction dyn[];
    String semaphore;


    /**
    * active.
    * return true sur une propriété commençant par un préfixe positif
    * soit 1, Oo( Oui), Tt (True), Ss (Si), Yy (Yes)...autres langues ?.
    * false sur valeur nulle ou vide
    */
    boolean active( String val)
    {
        boolean ok ;
        if( val == null || val.length() == 0 ) ok = false;
        else ok = ( "1OoTtSsYy".indexOf(val.charAt(0)) != -1 );

        //System.out.println("active:"+val+" -> "+ok);

        return( ok );
    }

	int parseNullInt(Object o)
	{
		if (o == null) return 0;
		String s = o.toString();
		if (s.equals("null")) return 0;
		if (s.equals("")) return 0;
		return Integer.parseInt(s);
	}

    public Scheduler( String parm[]) throws Exception
    {
        env = new Properties();
		env.load(new InputStreamReader( getClass().getResourceAsStream("Scheduler.conf") , "UTF-8" )) ;

		Etn = new ClientDedie(  "MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT") );
		Etn.setSeparateur(2, '\001', '\002');	

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

        if( env.get("WAIT_TIMEOUT")==null )
        wait_timeout = 300;
        else
        {
            int k = Integer.parseInt(env.getProperty("WAIT_TIMEOUT"));
            wait_timeout = (k==0?300:k);
        }

        debug =  env.get("DEBUG")!=null || env.get("SCHED_DEBUG") != null;
        semaphore =  env.getProperty("SEMAPHORE");



        sendsms = (active( env.getProperty("WITH_SMS"))? new SendSms( Etn , env ): null);
        sendmail = (active( env.getProperty("WITH_MAIL"))? new SendMail( Etn , env): null);
        sendstockmail = new SendStockMail( Etn , env);

		genericMail = new GenericMail(Etn, env);
		dashboardMail = new DashboardMail(Etn, env);

        createInvoice = new CreateInvoice(Etn,env);
		sso = new Sso(Etn, env);

        rs = Etn.execute("select name, className from actions where coalesce(className,'') != '' " );
        dyn = new DynAction[rs.rs.Rows];
        if( dyn.length > 0 )
        {
            int j = 0;
            while( rs.next() )
            {
                DynAction dy = new DynAction();
                dy.tag = rs.value("name");
                //dy.event = rs.value("eventSql");

                Class z =  Class.forName( "com.etn.eshop."+rs.value("className") );
                dy.oth = (OtherAction) z.newInstance();
                dy.oth.init( Etn, env);
                dyn[j++] = dy;
            }
        }

		dictionary = new Dictionary(Etn , env);
		
		engineName = env.getProperty("ENGINE_NAME");
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

    public void endJob( int wkid , String clid )
    {
        Set rsRule = Etn.execute("select r.cle , r.tipo, p.is_generic_form from rules r inner join post_work p "+
                        " on ( p.proces = r.start_proc and p.phase = r.start_phase and "+
                        " p.errcode = r.errcode ) where p.id = "+wkid);

        int newid = 0 , rule = 0 ; String tipo = "'IN PROGRESS'" ;
	String isgenericform = "0";
        if( rsRule.next() )
        {
	    isgenericform = rsRule.value("is_generic_form");
            try
            {
                rule = Integer.parseInt( rsRule.value(0) );
                switch( Integer.parseInt( rsRule.value(1) ) )
                {
                    case 1 : tipo = "'CLOSED'" ; break;
                    case 2 : tipo = "'CANCELLED'" ; break;
                    case 4 : tipo = "'HISTORY'" ; break;
                }
            }
            catch( Exception ee) {}
        }

        if( rule != 0 )
        {
            newid = Etn.executeCmd(
                        "insert into post_work"+
                        "(proces, phase , priority , insertion_date, client_key, is_generic_form )"+
                        " select r.next_proc, r.next_phase, now(),now(), p.client_key, is_generic_form "+
                        " from post_work p , rules r where "+
                        " r.cle = "+rule+ " and p.id = "+wkid);
        }


        System.out.println("EndJob clid:"+clid+" cloture wkid:"+wkid+(newid>0?" newid:"+newid:" fin proces") );

        if( newid > 0 )
        {
            String qrys[] = new String[3];
            qrys[0] = "update post_work set nextid ="+newid+" , status=2, start=ifnull(start,now()), end=now(), attempt = attempt+1  where id ="+wkid;
	    if("1".equals(isgenericform))
	    {
                qrys[1] = "update generic_forms set lastid = "+wkid+" where id="+clid ;
  	    }
            else
            {
                qrys[1] = "update "+Util.getTargetTable(env)+" set lastid = "+wkid+" where id="+clid ;
            }
            qrys[2] = "select semadm('"+semaphore+"',1,0,1)";

            Etn.execute(qrys);
        }
        else if( newid == 0 )
        {
            Etn.execute( new String[] {
                "update post_work set "+
                " status=9, start=ifnull(start,now()), end=now(),"+
                " attempt = attempt+1  where id ="+wkid ,
                "select semadm('"+semaphore+"',1,0,1)" });
        }
    }

    public void retry( int wkid , String clid, int errcode, String errmessage )
    {
        retry(wkid , clid, errcode, errmessage, false);
    }

    public void retry( int wkid , String clid, int errcode, String errmessage, boolean endJob )
    {
        retry( wkid , clid, errcode, errmessage, endJob, "30" );
    }

    public void retry( int wkid , String clid, int errcode, String errmessage, boolean endJob, int noOfTries )
    {
        retry( wkid , clid, errcode, errmessage, endJob, "30", noOfTries );
    }

    public void retry( int wkid , String clid, int errcode, String errmessage, boolean endJob, String minutes )
    {
		//default 15 tries
		retry( wkid , clid, errcode, errmessage, endJob, minutes, 15 );
	}
	
    public void retry( int wkid , String clid, int errcode, String errmessage, boolean endJob, String minutes, int noOfTries )
	{
		System.out.println("Scheduler.java::RETRY::noOfTries:"+noOfTries);
        Set rs = Etn.execute("select attempt  from post_work where id="+wkid );
        rs.next();
        if( Integer.parseInt( rs.value(0) )  < (noOfTries+1) )
        {
            errcode += 1000;
            Etn.execute("update post_work set status = 0 "+
                        ",flag = 0 " +
                        //     ",attempt = attempt+1 "+
                        ",priority = date_add(now(), interval +"+minutes+" minute) "+
                        ",errcode = "+errcode+
                        ",errmessage = "+escape.cote(errmessage)+
                        " where id = "+wkid ) ;
            return;
        }

        Etn.execute("update post_work set  "+
                    //" attempt = attempt+1, "+
                    " errcode = "+errcode+
                    ",errmessage = "+escape.cote(errmessage)+
                    " where id = "+wkid ) ;

        if(endJob) endJob( wkid, clid);
    }


    int doSms( int wkid ,  String idsms )
    {
        if( atoi(idsms)==0  )
        {
            if(debug) System.out.println("Sms Id null ??? wid:"+wkid);
            return(0);
        }

        try
        {
            int r = sendsms.send( wkid , idsms );
            System.out.println("doSms wid:"+wkid+" retour:"+r);
            return(r);
        }
        catch( Exception e)
        {
            e.printStackTrace();
            return(-1);
        }
    }

    int doMail( int wkid ,  String idsms )
    {
        if( atoi(idsms)==0  )
        {
            if(debug) System.out.println("Mail Id null ??? wid:"+wkid);
            return(0);
        }

        try
        {
            return (sendmail.send( wkid , idsms  ));
        }
        catch( Exception e)
        {
            e.printStackTrace();
            return(-1);
        }
    }

    int doInvoice( int wkid ,  String invoiceType )
    {

        try
        {
            if("sale".equalsIgnoreCase(invoiceType)){

                return (createInvoice.generateSaleInvoice(wkid)) ? 1 : -1;
            }
            else if("reverse".equalsIgnoreCase(invoiceType)){

                return (createInvoice.generatePurchaseInvoice(wkid)) ? 1 : -1;
            }
            else{
                throw new Exception("Error: invalid parameter for invoice action");
            }

        }
        catch( Exception e)
        {
            e.printStackTrace();
            return(-1);
        }
    }

    int doSso( int wkid ,  String clid, String actType )
    {
        try
        {
	     if("signup".equalsIgnoreCase(actType)) return (sso.signup(wkid, clid));
            else throw new Exception("Error: invalid parameter for sso action");
        }
        catch( Exception e)
        {
            e.printStackTrace();
            return(-1);
        }
    }


    void doAction( int wkid , String clid )
    {
        /**
        * post_work flag = rules.cle
        */
        Set rs = Etn.execute(
                        "select r.action from post_work p "+
                        "inner join rules r on " +
                        " r.cle = p.flag  "+
                        " where p.id = "+wkid );

        if( rs.next() && rs.value(0).length() > 0 )
        {
            StringTokenizer action = new StringTokenizer(rs.value(0), ",");
            while( action.hasMoreTokens() )
            {
                String todo[] = action.nextToken().split(":");
                System.out.println("$$$$$ " + todo[0]);
                int r = -3 ;
                if( todo != null && todo.length == 2 )
                {
                    if( "sms".equalsIgnoreCase(todo[0]) && sendsms != null  ) r = doSms( wkid, todo[1] );
                    else if( "smsw".equalsIgnoreCase(todo[0]) && sendsms != null  ) r = doSms( wkid, todo[1] );
                    else if( "mail".equalsIgnoreCase(todo[0]) && sendmail != null ) r = doMail( wkid, todo[1] );
                    else if( "mailw".equalsIgnoreCase(todo[0]) && sendmail != null ) r = doMail( wkid, todo[1] );
                    else if( "invoice".equalsIgnoreCase(todo[0]) && createInvoice != null ) r = doInvoice( wkid, todo[1] );
                    else if( "sso".equalsIgnoreCase(todo[0]) && sso != null ) r = doSso( wkid, clid, todo[1] );
                    else
                    {
                        for( int i = 0; i < dyn.length ; i++ )
                        {
                            if( dyn[i].tag.equalsIgnoreCase(todo[0]) )
                            r = dyn[i].oth.execute( Etn, wkid, clid, todo[1]);
                        }
                    }

                    if(debug) System.out.println( "action:"+todo[0]+" wid:"+wkid+" clid:"+clid+" ret:"+r);
                }

            }
        }
    }



    void refreshTun()
    {
        if(  env.getProperty("TUNNEL") == null ) return;

        System.out.println("refreshTun");
        try
        {
            Process p = Runtime.getRuntime().exec( env.getProperty("TUNNEL") );
            p.waitFor();
        }
        catch( Exception z )
        {
            z.printStackTrace();
        }

        try { Thread.currentThread().sleep( 60000 ); }
        catch( Exception inutile ) {}
    }

    String parseNull(Object o)
    {
        if( o == null ) return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase())) return("");
        else return(s.trim());
    }

    void doCheck( int wkid , String clid )
    {
        if( debug ) System.out.println("CHECK("+getTime()+")....wid:"+wkid+" clid:"+clid);
        //we will move the order to RelanceCommande/RelanceSO/RelanceCmmdeHT phase
        Set rs = Etn.execute("select r.* from rules r, post_work p where p.id = "+wkid+" and p.proces = r.start_proc and p.phase = r.start_phase and r.start_proc = r.next_proc and r.next_phase in ('RelanceSO','RelanceCommande','RelanceCmmdeHT') ");
        if(rs.next())
        {
            Etn.executeCmd("update post_work set errcode = "+rs.value("errCode")+"  where  id =" + wkid );
            endJob( wkid , clid );
        }
        Etn.executeCmd("update post_work set status = 0 , attempt = attempt+1 , priority = date_add(now(), interval + 30 minute) where id="+wkid+" and status=1 ");
    }

    void closeIfEndingPhase( int wkid , String clid )
    {
        //if its in last phase we need to mark it as status 9
        Set rs = Etn.execute("select r.* from rules r, post_work p where p.id = "+wkid+" and p.proces = r.start_proc and p.phase = r.start_phase ");
        if(rs.rs.Rows == 0)//no rules found for the process/phase means its the last phase
        {
            if(debug) System.out.println("$$$$$$$$$$$$$$ closeIfEndingPhase : Its the last phase wkid = " + wkid);
            int rows = Etn.executeCmd(" update post_work set status = 1 where status = 0 and id = " + wkid );//lock the record first
            if(rows > 0) Etn.executeCmd(" update post_work set status=9, start=ifnull(start,now()), end=now(), attempt = attempt+1  where id = "+wkid);
        }
    }


    public void run()
    {
        Set rs;
        int wkid = 0;

        File toStop = new File("_stop");
        toStop.delete();

        System.out.println("*****************\nStart Scheduler ("+getTime()+")");
        System.out.println("Timeout:"+wait_timeout);
        System.out.println("Fonctions:\nsms:"+(sendsms!=null)+
        "\nmail:"+(sendmail!=null)+
        "\ntunnel:"+( env.getProperty("TUNNEL")!=null)+
        "\n*****************" );

        try
        {
            rs=Etn.execute("select * from "+env.getProperty("COMMONS_DB")+".reload_translations where id="+escape.cote(engineName.toLowerCase()));
            if(rs!=null && rs.next() && rs.rs.Rows>0){
                dictionary = new Dictionary(Etn , env);
                Etn.executeCmd("delete from "+env.getProperty("COMMONS_DB")+".reload_translations where id="+escape.cote(engineName.toLowerCase()));
            }
            while( !stop )
            {
                if( toStop.exists() )
                break;

                Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES("+escape.cote(engineName)+",NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
                // Find Rows with action pending post_work.flag = 0
                while( true )
                {
                    wkid = 0 ;
                    rs = Etn.execute( new String[] {
                    "set @id := 0",
                    "update post_work p "+
                    " inner join ( select p2.id,r.cle from post_work p2"+
                    " inner join has_action r on "+
                    " (p2.proces = r.start_proc and p2.phase = r.start_phase "+
                    " and p2.status = 0 "+
                    " and coalesce(p2.proces,'') <> '' "+
                    " and coalesce(p2.phase,'') <> '' "+
                    " and p2.priority between date_add(now(), interval -1 day) and now() "+
                    " and (case when coalesce(r.action,'') like 'smsw:%' or coalesce(r.action,'') like 'mailw:%' then date_format(now(), '%H%i') else 1 end) >=  (case when coalesce(r.action,'') like 'smsw:%' or coalesce(r.action,'') like 'mailw:%' then '0800' else 1 end) "+
                    " and (case when coalesce(r.action,'') like 'smsw:%' or coalesce(r.action,'') like 'mailw:%' then date_format(now(), '%H%i') else 1 end) <=  (case when coalesce(r.action,'') like 'smsw:%' or coalesce(r.action,'') like 'mailw:%' then '2200' else 1 end) "+
                    " and p2.flag = 0 ) "+
                    " order by p2.priority limit 1 ) ssid "+
                    " on ssid.id = p.id "+
                    " set p.status = 1, p.start = now(), "+
                    " p.flag = ssid.cle , p.attempt = p.attempt+1,"+
                    " p.id = @id := p.id , p.client_key = @clid := p.client_key",

                    "select @id,@clid "} );
					try {
						if( rs.next() && rs.next() && rs.next() )
						wkid = atoi(rs.value(0));
					} catch(Exception _ex) {
						_ex.printStackTrace();
						wkid = 0;
					}

                    if( wkid != 0 )
                    {
                        Set rs2 = Etn.execute("SELECT orderRef from orders where id="+rs.value(1));
                        rs2.next();
                        System.out.println("<wkid="+wkid+"::clid="+rs.value(1)+"::orderRef="+rs2.value("orderRef")+">");
                        doAction( wkid , rs.value(1) ); // tolog: sql err
                        System.out.println("</wkid:"+wkid+"::clid:"+rs.value(1)+"::orderRef="+rs2.value("orderRef")+">");
                        Etn.execute("update post_work set status=0 where id="+wkid+" and status=1 ");
                    }
                    else break;
                }
				
				try {
					// When order is in last phase we need to mark it as status 9
					rs = Etn.execute("select * from post_work where status = 0 and priority <= now() order by priority");
					while(rs.next())
					{
						closeIfEndingPhase(atoi(rs.value("id")), rs.value("client_key"));
					}
				} catch(Exception _ex) {
					_ex.printStackTrace();
				}

				try {
					Set rsQuestions = Etn.execute("select pq.question, pq.question_uuid, pq.menu_uuid, pq.product_id, s.domain, l.langue_id from "+env.getProperty("CATALOG_DB")+".product_questions pq inner join "+env.getProperty("PORTAL_DB")+".site_menus sm on pq.menu_uuid = sm.menu_uuid inner join "+env.getProperty("PORTAL_DB")+".sites s on sm.site_id = s.id inner join "+env.getProperty("CATALOG_DB")+".language l on sm.lang = l.langue_code where email_sent=0");
					//System.out.println("select pq.question, pq.question_uuid, pq.menu_uuid, pq.product_id, s.domain, l.langue_id from "+env.getProperty("CATALOG_DB")+".product_questions pq inner join "+env.getProperty("PORTAL_DB")+".site_menus sm on pq.menu_uuid = sm.menu_uuid inner join "+env.getProperty("PORTAL_DB")+".sites s on sm.site_id = s.id inner join "+env.getProperty("CATALOG_DB")+".language l on sm.lang = l.langue_code where email_sent=0");
					while(rsQuestions.next()){
						Set rsMail = Etn.execute("select o.email, o.client_id from orders o inner join order_items oi on o.parent_uuid = oi.parent_id inner join "+env.getProperty("CATALOG_DB")+".products p on oi.product_ref = p.product_uuid where p.id="+rsQuestions.value("product_id")+" group by o.client_id order by o.tm desc");
						//System.out.println("select o.email, o.client_id from orders o inner join order_items oi on o.parent_uuid = oi.parent_id inner join "+env.getProperty("CATALOG_DB")+".products p on oi.product_ref = p.product_uuid where p.id="+rsQuestions.value("product_id")+" group by o.client_id order by o.tm desc");
						//System.out.println("select 'asad.usman@seecs.edu.pk' as email, "+escape.cote(rsQuestions.value("question"))+" as question, "+escape.cote(rsQuestions.value("question_uuid"))+" as question_uuid from orders o inner join order_items oi on o.parent_uuid = oi.parent_id inner join "+env.getProperty("CATALOG_DB")+".products p on oi.product_ref = p.product_uuid where p.id="+rsQuestions.value("product_id")+" order by o.tm desc limit 1");
						String[] attachs = null;
						while(rsMail.next()){
							try
							{
								QuestionMail sm = new QuestionMail(Etn, env, rsQuestions.value("langue_id"));
								//System.out.println(rsMail.value(0));
								int _s = sm.send(rsMail, rsQuestions);
								System.out.println("send mail : " + _s);
							}
							catch(Exception ee)
							{
								System.out.println(ee.toString());
									ee.printStackTrace();
							}
						}
					}
					Etn.executeCmd("update "+env.getProperty("CATALOG_DB")+".product_questions set email_sent=1;");
				} catch(Exception _ex) {
					_ex.printStackTrace();
				}

				try {
					Set rsDashboardMail = Etn.execute("select * from dashboard_emails   where email_sent= 0");
					while(rsDashboardMail.next()){
						String[] attachs = null;// not null this
						try
						{                        
							int _s = dashboardMail.send(rsDashboardMail);
							System.out.println("send mail : " + _s);
						}
						catch(Exception ee)
						{
							System.out.println(ee.toString());
								ee.printStackTrace();
						}
					}
					Etn.executeCmd("update dashboard_emails set email_sent=1;");
				} catch(Exception _ex) {
					_ex.printStackTrace();
				}

				try {
					Set rsStockAlert = Etn.execute("select * from "+env.getProperty("CATALOG_DB")+".product_variants where id in (select variant_id from stock_mail where is_stock_alert=1) ;");
					//System.out.println("select * from "+env.getProperty("CATALOG_DB")+".product_variants where id in (select variant_id from stock_mail where is_stock_alert=1);");

					String templateIdColName = "stock_alert_email_id_test";
					if("1".equals(env.getProperty("IS_PROD_SHOP"))) templateIdColName = "stock_alert_email_id_prod";
						
					while(rsStockAlert.next()){
						
						//we will always pick the email template ID from preprod db shop_parameters for both Shop and Prod Shop as we dont want to republish the site just in case user changes template on shop parameters screen
						Set rsStockMail = Etn.execute("select s.*, l.langue_id, l.langue_code, si.domain, sm.id as menu_id, sp."+templateIdColName+" as emailTemplateId from stock_mail s inner join "+env.getProperty("PORTAL_DB")+".site_menus sm on s.menu_uuid = sm.menu_uuid inner join "+env.getProperty("PORTAL_DB")+".sites si on si.id = sm.site_id inner join "+env.getProperty("CATALOG_DB")+".language l on sm.lang = l.langue_code inner join "+env.getProperty("PREPROD_CATALOG_DB")+".shop_parameters sp on sp.site_id = si.id where s.is_stock_alert=1 and s.variant_id="+rsStockAlert.value("id"));
						//System.out.println("select 'asad.usman@seecs.edu.pk' as email, "+escape.cote(rsQuestions.value("question"))+" as question, "+escape.cote(rsQuestions.value("question_uuid"))+" as question_uuid from orders o inner join order_items oi on o.parent_uuid = oi.parent_id inner join "+env.getProperty("CATALOG_DB")+".products p on oi.product_ref = p.product_uuid where p.id="+rsQuestions.value("product_id")+" order by o.tm desc limit 1");
						while(rsStockMail.next()){
                            try
							{
								int _mailid = parseNullInt(rsStockMail.value("emailTemplateId"));
                                if(_mailid > 0)
								{
                                    int _s = sendstockmail.send(rsStockMail);
                                    System.out.println("send stock mail : " + _s);
								    if(_s == 0) Etn.executeCmd("delete from stock_mail where product_id="+rsStockMail.value("product_id")+" and variant_id = "+escape.cote(rsStockMail.value("variant_id"))+" and email = "+escape.cote(rsStockMail.value("email")));
                                }
								else
								{
                                    //System.out.println("Email template id does not exist for email "+rsStockMail.value("email")+".");
									//improvement .. we must somehow notify admin that this email tempalte is missing
                                }
                            }
							catch(Exception ee)
							{
								ee.printStackTrace();
							}
						}

						//Etn.executeCmd("update "+env.getProperty("CATALOG_DB")+".products set is_stock_alert=0 where id = "+rsStockAlert.value("id"));
					}
				} catch(Exception _ex) {
					_ex.printStackTrace();
				}
				try {
                    String templateIdColName = "incomplete_cart_email_id_test";
					if("1".equals(env.getProperty("IS_PROD_SHOP"))) templateIdColName = "incomplete_cart_email_id_prod";

                    String query="SELECT crt.*,s."+templateIdColName+" as 'emailTemplateId' FROM "+ 
                        env.getProperty("PORTAL_DB") + ".cart crt left join "+env.getProperty("CATALOG_DB") +".shop_parameters s on s.site_id=crt.site_id"+
                        " where crt.session_access_time < DATE_SUB(NOW(), INTERVAL 24 HOUR) AND crt.incomplete_cart_mail_sent ='0'";
						
                    //we will always pick the email template ID from preprod db shop_parameters for both Shop and Prod Shop as we dont want to republish the site just in case user changes template on shop parameters screen
                    Set rsIncompleteCartMail = Etn.execute(query);

                    while(rsIncompleteCartMail.next()){
                        try
                        {   
							int _mailid = parseNullInt(rsIncompleteCartMail.value("emailTemplateId"));
							if(_mailid > 0)
							{
                                int _s = genericMail.send(rsIncompleteCartMail);
                                System.out.println("send stock mail : " + _s);
                            }
							else
							{
                                //System.out.println("Email template id does not exist for email "+rsIncompleteCartMail.value("email")+".");
								//improvement .. we must somehow notify admin that this email tempalte is missing
                            }
                        }
                        catch(Exception ee)
                        {
                            ee.printStackTrace();
                        }
                    }
				} catch(Exception _ex) {
					_ex.printStackTrace();
				}
					
				try {
					Set rsEligibility = Etn.execute("select * from "+env.getProperty("CATALOG_DB")+".eligibility_requests where email_sent=0");
					while(rsEligibility.next()){
						Set rsMail = Etn.execute("select email from "+env.getProperty("CATALOG_DB")+".eligibility_emails;");
						//System.out.println("select 'asad.usman@seecs.edu.pk' as email, "+escape.cote(rsQuestions.value("question"))+" as question, "+escape.cote(rsQuestions.value("question_uuid"))+" as question_uuid from orders o inner join order_items oi on o.parent_uuid = oi.parent_id inner join "+env.getProperty("CATALOG_DB")+".products p on oi.product_ref = p.product_uuid where p.id="+rsQuestions.value("product_id")+" order by o.tm desc limit 1");

						while(rsMail.next()){
							try
							{
								String emailText = "<p>Dear Customer,</p>";
								emailText += "<p>An eligibility request has been submitted for the number "+rsEligibility.value("number")+" and unfortunately it was not eligible.</p>";
								emailText += "<p>Kindly check if an upgrade Adsl offer can be proposed to that prospect or if fiber is being developed in his area then alert him.</p>";
								emailText += "<p>Regards,<br>";
								emailText += parseNull(env.getProperty("MAIL_FROM_DISPLAY_NAME"))+"</p>";
								//System.out.println(rsMail.value(0));
								int _s = genericMail.send(rsMail.value("email"), "Eligibility", emailText);
								System.out.println("send mail : " + _s);
							}
							catch(Exception ee)
							{
								ee.printStackTrace();
							}
						}
					}
					Etn.executeCmd("update "+env.getProperty("CATALOG_DB")+".eligibility_requests set email_sent=1;");
				} catch(Exception _ex) {
					_ex.printStackTrace();
				}					

				try {
					sendKeepEmails();
				} catch(Exception _ex) {
					_ex.printStackTrace();
				}					


                Etn.executeCmd("update "+env.getProperty("COMMONS_DB")+".engines_status set end_date=NOW() where engine_name="+escape.cote(engineName));

                // Wait "+semaphore+" message on 300 secs timeout
                if( debug ) System.out.println("Wait "+semaphore+"("+getTime()+")");
				System.out.println("*****************\nWait Scheduler ("+getTime()+")");
                while( true)
                {
                    rs = Etn.execute("select semwait('"+semaphore+"',"+wait_timeout+")");
                    if( rs == null ) refreshTun();
                    else break;
                }

            }
        }
        catch( Exception db )
        {
            db.printStackTrace();
        }

        finally
        {
            System.out.println("Arret Sms2 ("+getTime()+")" );
            // if(sendsms != null ) sendsms.stop();
            System.out.println("Arret Scheduler ("+getTime()+")" );
        }
    }

	private void sendKeepEmails()
	{
		String templateIdColName = "save_cart_email_id_test";
		if("1".equals(env.getProperty("IS_PROD_SHOP"))) templateIdColName = "save_cart_email_id_prod";

		String carturl = env.getProperty("CART_URL");
		if(carturl.endsWith("/") == false) carturl +=  "/";
		carturl += "cart.jsp";
		
		//emails of prod
		Set rs = Etn.execute("select * from "+env.getProperty("PORTAL_DB")+".cart where sendKeepEmail = 1 order by id ");
		while(rs.next())
		{
			if(parseNull(rs.value("keepEmail")).length() == 0)
			{
				System.out.println("sendKeepEmails::Error::keepEmail is empty");
			}
			else
			{
				String siteid = parseNull(rs.value("site_id"));
				//we will always pick the template ID from preprod catalog db as we dont want this change to be dependent on site publishing 
				//issue was they select the template in shop parameter screen and unless the site is published that new select template ID was not visible to prod shop engine
				Set rsS = Etn.execute("select p.*, s.domain from "+env.getProperty("PORTAL_DB")+".sites s, "+env.getProperty("PREPROD_CATALOG_DB")+".shop_parameters p where s.id = p.site_id and s.id = "+escape.cote(siteid));
				if(rsS.next())
				{
					String mailTemplateId = parseNull(rsS.value(templateIdColName));
                    if(mailTemplateId.length() > 0)
					{                       
                        String siteDomain = parseNull(rsS.value("domain"));
                        if(siteDomain.endsWith("/")) siteDomain = siteDomain.substring(0, siteDomain.length() - 1);
                        carturl = siteDomain + carturl;
                        
                        boolean emailSent = false;
                        if(mailTemplateId.length() == 0 || parseNullInt(mailTemplateId) == 0)
                        {
                            System.out.println("----------------------------------------------------------------------------------------");
                            System.out.println("WARNING :: save cart mail template id is not provided for site id : "+ siteid);
                            System.out.println("Sending default email");				
                            System.out.println("----------------------------------------------------------------------------------------");

                            Set rsM = Etn.execute("select c.*, s.lang, concat("+escape.cote(carturl)+",'?sid=', session_id, '&muid=', keepEmailMuid) as cart_url " +
                                    " from "+env.getProperty("PORTAL_DB")+".cart c, "+env.getProperty("PORTAL_DB")+".site_menus s" +
                                    " where s.menu_uuid = c.keepEmailMuid and c.id = "+escape.cote(rs.value("id")));
                            rsM.next();

                            String emailText = "<div>";
                            emailText += dictionary.getTranslation(rsM.value("lang"), "Dear customer") + "<br><br>";
                            emailText += dictionary.getTranslation(rsM.value("lang"), "Kindly click the following link in order to resume your cart")  + "<br><br>";
                            emailText += "<a href='"+rsM.value("cart_url")+"'>"+rsM.value("cart_url")+"</a><br>";
                            emailText += "</div>";
                            //System.out.println(rsMail.value(0));
                            int r = genericMail.send(rsM.value("keepEmail"), dictionary.getTranslation(rsM.value("lang"), "Complete your order"), emailText);
                            if ( r == 1) emailSent = true;
                        }
                        else
                        {	
                            Set rsM = Etn.execute("select c.name, c.surnames, c.site_id, c.keepEmail as email, s.lang, concat("+escape.cote(carturl)+",'?sid=', session_id, '&muid=', keepEmailMuid) as cart_url, " +
                                    " m.sujet, m.sujet_lang_2, m.sujet_lang_3, m.sujet_lang_4, m.sujet_lang_5 " +
                                    " from "+env.getProperty("PORTAL_DB")+".cart c, "+env.getProperty("PORTAL_DB")+".site_menus s, mails m " +
                                    " where m.id = "+escape.cote(mailTemplateId)+" and s.menu_uuid = c.keepEmailMuid and c.id = "+escape.cote(rs.value("id")));
                            rsM.next();
                            System.out.println("send save cart email to : " + rsM.value("email") + " template id : " + mailTemplateId);

                            int r = sendmail.send(rsM, rsM.value("lang"), mailTemplateId );
                            if ( r == 0 ) emailSent = true;
                        }
						
                        System.out.println("sendKeepEmails sent : " + emailSent);
                        if(emailSent) 
						{
                            Etn.execute("update "+env.getProperty("PORTAL_DB")+".cart set sendKeepEmail = 0 where id = " + escape.cote(rs.value("id")));
                        }
                    }
					else
					{
                        //System.out.println("Mail template id does not exist for save cart.");
						//improvement .. we must somehow notify admin that this email tempalte is missing
                    }
				}
				else
				{
					System.out.println("ERROR::impossible not to find shop parameters for site id " + siteid);
				}
			}
		}
	}

    public static void main( String a[] ) throws Exception
    {
        new Scheduler(a).run();
    }
}
