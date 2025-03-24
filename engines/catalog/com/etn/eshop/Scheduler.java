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


public class Scheduler { 


Properties env;
ClientSql Etn;
boolean stop = false;

final int wait_timeout;
final boolean debug;

final String semaphore;


class DynAction {
String tag;
OtherAction oth;
//String event;
}

DynAction dyn[];


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

public Scheduler( String parm[])
throws Exception
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

	semaphore = (String)env.get("SEMAPHORE");


	if( env.get("WAIT_TIMEOUT")==null ) wait_timeout = 300;
	else 
	{ 
		int k = Integer.parseInt(env.getProperty("WAIT_TIMEOUT"));
		wait_timeout = (k==0?300:k);
	}

	debug =  env.get("DEBUG")!=null || env.get("SCHED_DEBUG") != null;

	rs = Etn.execute( 
	"select name, className from actions "+
	" where coalesce(className,'') != '' " );
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

}

public static int atoi( String s) 
{
  if(s==null ||s.length() == 0 ) return(0);
  int u=0,c;
  for( int i = 0 ; i < s.length() ; i++ )
   { if(!Character.isDigit( c = s.charAt(i) ) )
       break;
     u *= 10;
     u += (c - '0') ;
   }

  return(u);
}

String  getTime()
{ return( ItsDate.getWith(System.currentTimeMillis(),true) ); }



protected void endJob( int wkid , String clid )
{ 
  Set rsRule = Etn.execute(
  "select r.cle , r.tipo from rules r inner join post_work p "+
  " on ( p.proces = r.start_proc and p.phase = r.start_phase and "+
  " p.errcode = r.errcode ) where p.id = "+wkid);

  int newid = 0 , rule = 0 ; String tipo = "'IN PROGRESS'" ;
  if( rsRule.next() ) 
    { try { rule = Integer.parseInt( rsRule.value(0) );
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
   newid = Etn.executeCmd(  
  "insert into post_work"+
  "(proces, phase , priority , insertion_date, client_key )"+
  " select r.next_proc, r.next_phase, now(),now(), p.client_key "+
  " from post_work p , rules r where "+
  " r.cle = "+rule+ " and p.id = "+wkid);
 
  

  System.out.println("EndJob clid:"+clid+" cloture wkid:"+wkid+
   (newid>0?" newid:"+newid:" fin proces") );

  if( newid > 0 ) 
  Etn.execute( new String[] {
  "update post_work set nextid ="+newid+" ,"+
  " status=2, start=ifnull(start,now()), end=now(),"+
  " attempt = attempt+1  where id ="+wkid ,
//  "update customer set lastid = "+wkid+" , "+
  //" orderStatus="+tipo+
//  " where customerid="+clid,
  "select semadm('"+semaphore+"',1,0,1)" });
  else if( newid == 0 ) 
    Etn.execute( new String[] {
  "update post_work set "+
  " status=9, start=ifnull(start,now()), end=now(),"+
  " attempt = attempt+1  where id ="+wkid ,
  "select semadm('"+semaphore+"',1,0,1)" });



}

protected void retry( int wkid , String clid, int errcode, String errmessage )
{
	retry(wkid , clid, errcode, errmessage, false);
}

protected void retry( int wkid , String clid, int errcode, String errmessage, boolean endJob )
{
	retry( wkid , clid, errcode, errmessage, endJob, "30" );
}

protected void retry( int wkid , String clid, int errcode, String errmessage, boolean endJob, String minutes )
{
   Set rs = Etn.execute(
    "select attempt  from post_work where id="+wkid );
   rs.next();
   if( Integer.parseInt( rs.value(0) )  < 16 )
   { 
     errcode += 1000;
     Etn.execute(
     "update post_work set status = 0 "+
     ",flag = 0 " +
//     ",attempt = attempt+1 "+
     ",priority = date_add(now(), interval +"+minutes+" minute) "+
     ",errcode = "+errcode+
     ",errmessage = "+escape.cote(errmessage)+
     " where id = "+wkid ) ;
     return;
   }
     
  Etn.execute(
     "update post_work set  "+
//" attempt = attempt+1, "+
     " errcode = "+errcode+
     ",errmessage = "+escape.cote(errmessage)+
     " where id = "+wkid ) ;

 
  if(endJob) endJob( wkid, clid); 

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
   { String todo[] = action.nextToken().split(":");
System.out.println("$$$$$ " + todo[0] + ":" + todo[1]);
     int r = -3 ;
     if( todo != null && todo.length == 2 )
     { 
        for( int i = 0; i < dyn.length ; i++ )
        {
 
	 if( dyn[i].tag.equalsIgnoreCase(todo[0]) )
             r = dyn[i].oth.execute( Etn, wkid, clid, todo[1]);
        }
          
     }
     if(debug) 
       System.out.println( "action:"+todo[0]+" wid:"+wkid+
         " clid:"+clid+" ret:"+r);
              
   }

 }

}


String parseNull(Object o)
{
	if( o == null ) return("");
	String s = o.toString();
	if("null".equals(s.trim().toLowerCase())) return("");
	else return(s.trim());
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

public void run(){
  Set rs;
  int wkid = 0; 

  File toStop = new File("_stop");
  toStop.delete();

  System.out.println("*****************\nDémarrage Scheduler ("+getTime()+")");
  System.out.println("Timeout:"+wait_timeout);
   
  try {
    while( !stop ) {
      if(toStop.exists()) break;

      Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Catalog',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");

      // Find Rows with action pending post_work.flag = 0
      while(true){
        wkid = 0 ;
        rs = Etn.execute( new String[] {
          "set @id := 0",
          "update post_work p "+
          " inner join ( select p2.id,r.cle from post_work p2"+
          " inner join has_action r on "+
          " (p2.proces = r.start_proc and p2.phase = r.start_phase "+
          " and p2.status = 0 "+
          " and p2.priority <= now() "+
          " and p2.flag = 0 ) "+
          "  order by p2.priority limit 1 ) ssid "+
          " on ssid.id = p.id "+
          " set p.status = 1, p.start = now(), "+
          " p.flag = ssid.cle , p.attempt = p.attempt+1,"+
          " p.id = @id := p.id , p.client_key = @clid := p.client_key",

          "select @id,@clid "} 
        );

        if( rs.next() && rs.next() && rs.next() )
        wkid = atoi(rs.value(0));

        System.out.println("wkid:"+wkid+":");
        if(wkid != 0) { 
          doAction( wkid , rs.value(1) ); // tolog: sql err
          Etn.execute("update post_work set status=0 where id="+wkid+" and status=1 ");
        } else break;
      }

      String prodDb = env.getProperty("PROD_DB")+".";
      String[] productParmTables = new String[] {"attributes_v2","attributes_values_v2","categories_v2","product_types_v2","product_v2_categories_and_attributes","product_v2_specifications"};
      
      System.out.println("Scheduler:: Moving Product parameters to prod=================");
      for(int i=0;i<productParmTables.length;i++){
        Etn.executeCmd("delete from "+prodDb+productParmTables[i]);
        Etn.executeCmd("insert into "+prodDb+productParmTables[i]+" select * from "+productParmTables[i]);
      }
	    Etn.executeCmd("update "+env.getProperty("COMMONS_DB")+".engines_status set end_date=NOW() where engine_name='Catalog'");

      // Wait CAT_MORINGA message on 300 secs timeout
      if(debug) System.out.println("Wait "+semaphore+"("+getTime()+")");

      while(true){ 
        rs = Etn.execute("select semwait('"+semaphore+"',"+wait_timeout+")");   
        if(rs==null) refreshTun();
        else break;
      }
    }

  } catch( Exception db ){ 
    db.printStackTrace(); 
  } finally {
    System.out.println("Arret Sms2 ("+getTime()+")" );
    // if(sendsms != null ) sendsms.stop();
    System.out.println("Arret Scheduler ("+getTime()+")" );
  }
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

public static void main( String a[] )
throws Exception
{
  new Scheduler(a).run();
}


}
