package com.etn.eshop;

import java.io.*;
import java.net.URL;
import java.util.StringTokenizer;

import java.security.*;
import java.security.cert.*;

import java.net.HttpURLConnection;
import javax.net.ssl.*;
import java.util.HashMap;
import java.util.Properties;
import com.etn.util.ItsDate;
import com.etn.sql.escape;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.lang.SimplSem;


public class SendSms2 {

public final int NO_MAILID = 1;
public final int NO_ROW = 2;
public final int NO_CONTACT = 3;
public final int NO_CONNECTION = -1;

 

String queue;
int tempo = 0;

class Sender extends SimplSem implements Runnable {

boolean nonStop = true;
File sent,qs;
String url, errdir;

public Sender( Properties conf )
{
  url = env.getProperty("SMS_URL");
  qs = new File( env.getProperty( "SMS_QUEUE" ) );
  sent = new File( env.getProperty( "SMS_SENT" ) );
  errdir = env.getProperty( "SMS_ERROR" );
}

int sendFile( File f )
{
 HttpURLConnection con = null;

 try {

  //System.err.println("About to send:"+f.toString());
  FileInputStream infile = new FileInputStream(f);
  byte b[] = new byte[ infile.available() ];
  infile.read(b);
  infile.close();

  URL ur = new URL(url);
  //System.err.println("connect to:"+ur);
  con = (HttpURLConnection)ur.openConnection();

  con.setRequestMethod("POST");
  con.setDoOutput( true);
  con.setDoInput( true);
  con.setRequestProperty("Content-Type", "text/xml; charset=UTF-8");
  con.setRequestProperty("SOAPAction", "\"\"");

 con.setRequestProperty("Content-Length", ""+b.length );
 con.connect();

 OutputStream os = con.getOutputStream();
 os.write( b);
 os.close();
 System.out.println("Status:"+ con.getResponseCode() );

 InputStream in = con.getInputStream();
     // .. etc...
 b = new byte[4096];

 ByteArrayOutputStream bo = new ByteArrayOutputStream();
 int i;
 while( ( i = in.read(b) ) != -1 )
    bo.write(b,0,i);

 in.close();
 con.disconnect();

 if( bo.toString().indexOf("<errorCode>0</errorCode><isSuccessful>true") != -1 )
    return(0);

 FileOutputStream p = new FileOutputStream( errdir+"/"+f.getName());
 bo.writeTo( p );
 p.close();
 return( 1 );

}
catch( Exception e )
{ 
  try {
  PrintWriter p = new PrintWriter( errdir+"/"+f.getName());
  e.printStackTrace(p);
  p.close();
  if( con != null ) con.disconnect();
  } catch( Exception ye) {} 

  return(NO_CONNECTION);
}

}



boolean doSms()
{

  String files[] ;
  boolean trouve = false;

  files = qs.list();
  //System.out.println(" files..."+files.length);
  for( int i = 0 ; i < files.length ; i++ )
  {
    if( files[i].matches("^[0-9_]*.*sms" ) )
     { File mv = new File(sent,files[i]);
       new File(qs , files[i]).renameTo(mv);
       sendFile( mv );
       trouve = true;
       System.out.println(" SMS job..."+mv);
     }
  }

 return(trouve);

}

public void stop()
{  
  nonStop = false;
}

public void run()
{

  while( nonStop  )
  {
    if( ! doSms() )
    { System.out.println( "Sms2 ("+
       ItsDate.getWith(System.currentTimeMillis(),true)+
       ") Waiting.... for tempo:"+tempo+" ms");
      if( tempo == 0 ) Wait();
       else Wait(tempo);
    }

  }

}

}





Properties env;
Sender sender;

public SendSms2( ClientSql etn , Properties conf )
{ 
  this.env = conf;
  
  queue = env.getProperty( "SMS_QUEUE" );
  if( env.getProperty( "SMS_TEMPO" ) != null)
  {  
     tempo = 1000 * Integer.parseInt( env.getProperty( "SMS_TEMPO" ) );
     if( tempo < 0 ) tempo = 0;
  }

  sender = new Sender(env);
  System.out.println(
  "Sms2 démarré queue="+queue+" tempo = "+tempo+"ms");

  new Thread(sender).start();

}


int indexOfEndName( String smstext , int pos)
{
  int len = smstext.length();

  while( pos < len && ( 
          Character.isLetterOrDigit( smstext.charAt(pos) ) || 
          smstext.charAt(pos) == '_' ) )
    pos++;

 if( pos >= len ) return(-1);
 return(pos);
 
}
String getFieldValue( Set rs , String dollar )
{ if( dollar == null || dollar.length() < 2 || dollar.charAt(0) != '$' )
    return(dollar);

  int i = rs.indexOf( dollar.substring(1));

  return( i == -1 ? dollar : rs.value(i) );
}

boolean isIdentifier( char c)
{ return( Character.isLetterOrDigit(c) || c=='_' ); }



int getSmsId(   ClientSql etn , String where , Set rs )
{ 
  StringBuilder sb = new StringBuilder( where.length() * 2 );
  int i , j ;

  i = 0;
  while( ( j = where.indexOf( '$' , i ) ) != -1 )
   { sb.append( where.substring( i , j ) );
     for( i = ++j ; isIdentifier(where.charAt(i)) ; i++ );
     int n = rs.indexOf( where.substring(j , i ) );
     if( n < 0 ) sb.append( "$"+where.substring(j , i ) );
     else sb.append( escape.cote(rs.value(n) ) );
   }

 sb.append( where.substring( i , where.length() ) );

 Set rs2 = etn.execute( sb.toString() );
 if( !rs2.next() ) return(0);
 try { return( Integer.parseInt(rs2.value(0)) ); }
 catch( Exception e)
  { System.err.println("getSmsId return non Integer : "+rs2.value(0));
    return(-1);
  }

}
/**
 * smsParam : smsId param1 param2 ...
 * smsParam must begin by a smsId ( integer).
 * Optionnally  param1 , param2 ... paramN are msisdn to send the sms.
 * Actually their values are fields to search in the standard qry 
 * customer/post_work.
 * If no optionnal param, sms is sent to "contactPhonenumber1"
**/

public int send( int wkid, String smsParam , ClientSql etn  )
{
  Set rs, rs2;
  String clause, to = null; 
  int r, smsid , n ;
  StringTokenizer st = new StringTokenizer( smsParam, " ");


  smsid = Integer.parseInt(st.nextToken());

  rs = etn.execute(
  "select p.*, c.* from post_work p inner join customer c "+
  " on p.client_key = c.customerid where p.id = "+wkid );
  if(!rs.next()) return(NO_ROW);

  /* Parametres ? */
  if( ! st.hasMoreTokens() ) 
      to = "contactPhonenumber1";
  else to = st.nextToken();

  while( true ) 
  {
   rs2 = etn.execute("select texte,where_clause from sms where sms_id="+smsid );
   if( !rs2.next() )
    return( NO_MAILID );  // Erreur parametrage ou ne pas envoyer

   // Analyse du where_clause

   // No Suiv -> election
   if( ( clause = rs2.value(1) ).length() == 0  ||
       ( r = getSmsId( etn , clause , rs ) ) == smsid ) 
    break;

   // Clause return erreur ou imprevu : pas de Sms
   if( r <= 0 ) return(0);
   smsid = r;
  } 

   String smstxt = rs2.value(0);
   



  String clid = rs.value("customerid");
  System.out.println( "Sms to Send: wid:"+wkid+" clid:"+clid+
    " smsParm:"+smsParam+" elu:"+smsid+" to " + to);

  
  // parse
  StringBuilder sb = new StringBuilder( 1024);
  int i = 0, j = 0, k = 0, l = smstxt.length();

  while( j < l ) 
  {
    i= smstxt.indexOf("db",j);
    if( i != -1 ) 
     { sb.append( smstxt.substring(j,i)) ;
       //k = smstxt.indexOf(" ",i+3);
       k = indexOfEndName( smstxt , i+3 );
       if( k == -1 ) k = l;
       String s  = smstxt.substring(i+2,k );
       if( s.length()> 0 && ( s = rs.value(s) ) != null )
        { sb.append(s); j = k; }
       else
        { sb.append( "db");
          j = i+2 ;
        }
     }
   else 
    { sb.append(smstxt.substring(j));
      break;
    }
  }
     
  //System.out.println("url:"+url+"\n"+sb.toString() );


  try {

  while( to != null )
  { 
    String dest = rs.value(to);
    if( dest == null || (dest=dest.trim()).length() == 0 )
      System.out.println("Sms to Send: wid:"+wkid+" clid:"+clid+
        "nul or empty dest :"+to );

    else
    {
      FileOutputStream bo = new FileOutputStream(queue+"/"+wkid+"_"+dest+".sms");

      bo.write( (
       "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:nss=\"nsSmsWebService\">"+
        "<soapenv:Header/>"+
        "<soapenv:Body>"+
         "<nss:sendSms>"+
            "<nss:origin>0RANGE</nss:origin>"+
            "<nss:msisdn>"+dest+"</nss:msisdn>"+
            "<nss:message>"+sb.toString()+"</nss:message>"+
         "</nss:sendSms>"+
        "</soapenv:Body>"+
       "</soapenv:Envelope>" ).getBytes()) ;

      bo.close();

    }

    if( st.hasMoreTokens() ) 
       to = st.nextToken();
    else
     break;
  }

sender.Free();

return(0);
}


catch( Exception e ) 
{ e.printStackTrace();
  return(-1);
}

}

public void stop()
{ 
   sender.stop();
   sender.Free();
}

public static void main( String a[] )
throws Exception
{

 String smsid;
 int wkid;


  if( a.length == 0 )
    { smsid="15" ; wkid = 2681; }
  else
    { smsid=a[0];
      wkid= Integer.parseInt(a[1]);
    }

  Properties p = new Properties();
  p.load( SendSms2.class.getResourceAsStream("Scheduler.conf") );

  com.etn.Client.Impl.ClientDedie etn =
    new com.etn.Client.Impl.ClientDedie( "MySql",
       "com.mysql.jdbc.Driver",
       p.getProperty("CONNECT") );

  SendSms2 sm = new SendSms2(etn , p );
  int r = sm.send( wkid, smsid, etn);
  System.out.println(""+r );
//  System.exit(r);

}

  

}
