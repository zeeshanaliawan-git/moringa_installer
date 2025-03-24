package com.etn.eshop;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import java.security.*;
import java.security.cert.*;

import javax.net.ssl.*;
import java.util.HashMap;
import java.util.Properties;
import com.etn.util.ItsDate;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;


public class SendSms {

public final int NO_MAILID = 1;
public final int NO_ROW = 2;
public final int NO_CONTACT = 3;
public final int NO_CONNECTION = -1;


ClientSql etn;
String url;
Properties env;

public SendSms( ClientSql etn , Properties conf )
{ 
  this.etn = etn; 
  this.env = conf;
  
  url = env.getProperty("SMS_URL");
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


public int send( int wkid, String smsid )
{
  

  Set rs = etn.execute("select texte from sms where sms_id="+smsid );
  if( !rs.next() )
    return( NO_MAILID );

  String smstxt = rs.value(0);


  rs = etn.execute( 
  "select p.*, c.* from post_work p inner join customer c "+
  " on p.client_key = c.customerid where p.id = "+wkid );
  if(!rs.next()) return(NO_ROW);

  String clid = rs.value("customerid");

  if( rs.value("phonetosendsms").length() != 10 ) 
    return(NO_CONTACT);
  
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
     
 
  try {

  String urlParams = "?username="+env.getProperty("SMS_USER")+"&password="+env.getProperty("SMS_PASSWD")+"&from="+env.getProperty("SMS_FROM")+"&to="+rs.value("phonetosendsms")+"&text="+URLEncoder.encode(sb.toString(),"UTF-8");
  System.out.println("url:"+url+urlParams);

  URL ur = new URL(url+urlParams);
  HttpURLConnection con = (HttpURLConnection)ur.openConnection();

  con.setRequestMethod("GET");
//  con.setDoOutput( false);
//  con.setDoInput( true);
//  con.setRequestProperty("Content-Type", "text/plain; charset=UTF-8");
  con.setRequestProperty("Accept-Charset", "UTF-8");

 ByteArrayOutputStream bo = new ByteArrayOutputStream();

// con.setRequestProperty("Content-Length", ""+bo.size() );
 con.connect();

// OutputStream os = con.getOutputStream();
// os.write(bo.toByteArray() );
// os.close();

 System.out.println("Status:"+ con.getResponseCode() );

 InputStream in = con.getInputStream();
     // .. etc...
 byte b[] = new byte[4096];

// bo.reset();
 while( ( i = in.read(b) ) != -1 )
    bo.write(b,0,i);

 in.close();
 con.disconnect();
System.out.println("$$$$$$$$$$$$$ " + bo.toString());
 int ret = ( bo.toString().toLowerCase().indexOf("accepted for delivery") != -1 ? 0 : 1 ) ;
 return ret;


}

catch( Exception e ) 
{ e.printStackTrace();
  return(NO_CONNECTION);
}

}

public static void main( String a[] )
throws Exception
{

 String smsid;
 int wkid;


  if( a.length == 0 )
    { smsid="50" ; wkid = 1; }
  else
    { smsid=a[0];
      wkid= Integer.parseInt(a[1]);
    }

  Properties p = new Properties();
  p.load( SendSms.class.getResourceAsStream("Scheduler.conf") );

  com.etn.Client.Impl.ClientDedie etn =
    new com.etn.Client.Impl.ClientDedie( "MySql",
       "com.mysql.jdbc.Driver",
       p.getProperty("CONNECT") );

  SendSms sm = new SendSms(etn , p );
  int r = sm.send( wkid, smsid);
  System.out.println(""+r );
  System.exit(r);

}

  

}
