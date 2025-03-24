package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.util.Properties;

/** 
 * Must be extended.
*/
public class Sql extends OtherAction { 


public int execute( ClientSql etn, int wkid , String clid, String param )
{
	return execute(wkid, clid, param);
}

private int checkGameStatus(int wkid, String clid)
{
	System.out.println("in checkGameStatus");
	Set rsP = etn.execute("select * from post_work where id = "+escape.cote(""+wkid));
	if(rsP.next())
	{
		String tablename = rsP.value("proces");
		Set rsG = etn.execute("select * from "+tablename+" where "+tablename+"_id = "+escape.cote(clid));
		System.out.println("select * from "+tablename+" where "+tablename+"_id = "+escape.cote(clid));
		if(rsG.next())
		{
			if("win".equalsIgnoreCase(rsG.value("_etn_win_status"))) return 0;
			else return 19;
		}
		else return -1;
	}
	return -1;
}

public int execute( int wkid , String clid, String param )
{ 
  System.out.println("Sql wid:"+wkid+" cl:"+clid+" parm:"+param);
	if( param.equalsIgnoreCase("checkGameStatus") )//this action must move to next
	{
		int err = checkGameStatus(wkid, clid);
		etn.executeCmd("update post_work set errcode = "+escape.cote(""+err) + " where id = "+escape.cote(""+wkid));		
		((Scheduler)env.get("sched")).endJob( wkid , clid );
	}

  Set rs = etn.execute(
         "select nextOnerr,throwErr,sqltext  from osql "+
         " where id="+ escape.cote(param) );
  if(!rs.next() ) return(1);

  boolean next= rs.value(0).length() > 0;
  boolean signal= rs.value(1).length() > 0;
  String sql = rs.value(2).replace("$clid",clid);
  sql = sql.replace("$wkid",""+wkid);
  System.out.println(sql);
  String tsql[] = sql.split(";");
  rs = etn.execute( tsql );
  if( rs == null ) return(-1);
  if(  !rs.next() && ( signal || next ) ) 
    return(2);
  if( signal || next  ) 
  {
    String lastCode = rs.value(0) , lastmsg = rs.value(1) ;
    while( rs.next() )
      { lastCode = rs.value(0) ; lastmsg = rs.value(1) ; }

     
    System.out.println("Sql:errcode ->"+lastCode ); 
    //special code where we have to wait in phase due to previous action called. 
    //Like mail reminders where we have to wait in phase till reminder mail/sms is sent 
    //120000 is returned so that engine does not try moving to next phase
    //by default next attempt will be made after 30mins but if we want next attempt to be made like after 15mins then we return 120015 similarly for 30mins 120030
    int nlastcode = -1;
    try
    {
	nlastcode = Integer.parseInt(lastCode);
    }
    catch(Exception e) {}
    if(nlastcode >= 120000) 
    {
	//default interval for this action to execute again is 30mins
	int intervalmins = nlastcode - 120000;
	if(intervalmins <= 0) intervalmins = 30;

//	etn.executeCmd("update post_work set attempt = attempt-1, start = null, priority = date_add(now(), interval "+intervalmins+" minute), flag = 0 where id="+wkid );
	etn.executeCmd("update post_work set start = null, priority = date_add(now(), interval "+intervalmins+" minute), flag = 0 where id="+wkid );

	return (0);
    }

    if( "nop".equals( lastCode ) || lastCode.length() == 0 ) 
    {  etn.executeCmd("update post_work set errmessage='nop' "+
        " where id="+wkid );
      return(0);
    }

    etn.executeCmd("update post_work set errcode="+lastCode+
    ",errmessage="+escape.cote(lastmsg)+
    " where id="+wkid );
  
   if( next ) 
     ((Scheduler)env.get("sched")).endJob( wkid , clid );
  }
        
 
   
 return(0);

}

}
