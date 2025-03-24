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

public int execute( int wkid , String clid, String param )
{ 
  System.out.println("Sql wid:"+wkid+" cl:"+clid+" parm:"+param);
  if( param.equalsIgnoreCase("StockPlus") )
  {
    if( etn.executeCmd( "update customer set opstock=0 where "+
             " opstock=1 and customerid="+clid) < 1 )
       return(0);

   etn.execute( "update stock_other inner join materiels "+
   " on materiels.codesap = stock_other.codesap "+
   " set stock_virtuel = stock_virtuel +1 "+
   " where materiels.customerid = "+clid );

  return (
   etn.executeCmd("update stock inner join customer c "+
   " on c.terminalsap = stock.codesap "+
   " set stock_virtuel = stock_virtuel+1 "+
   " where c.customerid = "+clid+
   " and stock.tm < now()")==1?0:1);
  }

  if( param.equalsIgnoreCase("StockMoins") )
  {
   if( etn.executeCmd(
    "update customer set opstock=1 where "+
    " opstock=0 and customerid="+clid) < 1 ) 
       return(0);

   etn.execute( "update stock_other inner join materiels "+
   " on materiels.codesap = stock_other.codesap "+
   " set stock_virtuel = stock_virtuel -1 "+
   " where materiels.customerid = "+clid );

  return (
   etn.executeCmd("update stock inner join customer c "+
   " on c.terminalsap = stock.codesap "+
   " inner join post_work p on p.client_key = c.customerId and "+
   " p.nextid = "+wkid+
   " set  stock_virtuel = stock_virtuel - 1 "+
   " where c.customerid = "+clid+
   " and p.phase != 'EnReserva' "+
   " and stock.tm < now()" )==1?0:1);
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
    if( "120412".equals( lastCode ) || "nop".equals( lastCode ) || 
         lastCode.length() == 0 ) 
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
