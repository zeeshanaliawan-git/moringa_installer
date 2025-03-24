package com.etn.eshop;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.net.URL;
import java.net.URLDecoder;
//import java.net.URLEncoder;
import java.security.KeyManagementException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.util.HashMap;
//import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Properties;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;


/**
 * Class use to generate request for paypal
 * 
 */
public class PayPal  {

 public static final String PWD = "PWD";
 public static final String USER = "USER";
 public static final String VERSION = "VERSION";
 
 private String url  ;
 private String keyPath ;
 private int port;
 private String pass;
 private String proxyUrl = null;
 private int proxyPort;
 private String user;
 private String pwd;
 private String version;
 private int timeout;

 Properties env;
 ClientSql Etn;
 Scheduler sched;
 boolean debug = false;

String send(HashMap<String, String> parameters, StringBuilder input) 
 throws Exception
{

  if (debug) {
   System.out.println("PayPal send IN");
  }
    
  String retour = null; 
  
  try{
  
   KeyStore keyStoreKeys;
   KeyManagerFactory keyMgrFactory;
   SSLContext sslContext;
    
     // Load Key Store
   keyStoreKeys = KeyStore.getInstance("JKS");

    
   keyStoreKeys.load(new FileInputStream(keyPath),pass.toCharArray());
   // Get Key Manager
   keyMgrFactory = KeyManagerFactory.getInstance("SunX509");
   //keyMgrFactory.init()
   keyMgrFactory.init(keyStoreKeys, pass.toCharArray());
    
   // Set SSL Context Type
   sslContext = SSLContext.getInstance("SSL");
   
   // Set SSL Context 
   sslContext.init(keyMgrFactory.getKeyManagers(), null, null);
    
   URL urlConnect = new URL(url);
   
   HttpsURLConnection  connection;
   
   if(proxyUrl!=null && proxyUrl.length()>0){
    Proxy proxy = new Proxy(Proxy.Type.HTTP, new InetSocketAddress(proxyUrl, proxyPort));
    connection = (HttpsURLConnection ) urlConnect.openConnection(proxy);
   }else{
    connection = (HttpsURLConnection ) urlConnect.openConnection();
   }
    
   //StringBuilder input = new StringBuilder();

   //informations de connexion utilisées pour tous les appels vers paypal
   parameters.put(USER, user);
   parameters.put(PWD, pwd);
   parameters.put(VERSION, version);
   
   for(String key : parameters.keySet()){
    if(input.length()!=0){
     input.append("&");
    }
    input.append(key+"="+parameters.get(key));
   }
   

   if(debug) System.out.println("INPUT" + input);

   connection.setSSLSocketFactory(sslContext.getSocketFactory());
   connection.setRequestMethod("POST");
   connection.setConnectTimeout(timeout);
   connection.setDoOutput(true);
   connection.setDoInput(true);  
   PrintWriter out = new PrintWriter(connection.getOutputStream()); 
   out.print(input.toString());
   out.flush();
   out.close();
 
 
   InputStreamReader inReader = new InputStreamReader(connection.getInputStream());
   BufferedReader aReader = new BufferedReader(inReader);
   StringBuffer retour2 = new StringBuffer();
   String aLine;
   while ((aLine = aReader.readLine()) != null)
   retour2.append(aLine);
     
   aReader.close();
   connection.disconnect();

   retour = URLDecoder.decode(retour2.toString(),"UTF-8");

  }
  catch(Exception e){
   e.printStackTrace();
  }
  
  if (debug) {
   System.out.println("PayPal OUT:"+retour);
  }
  
  return retour.toString();
}
 
HashMap<String, String> getMap(String value)
{
  
  if (debug) 
   System.out.println("PayPal getMap "+value);
  
  if( value == null ) return( null);
  
  HashMap<String, String> response = new HashMap<String, String>();

  for(String param : value.split("&"))
  {
    String[] paramValue = param.split("=");
    if(paramValue.length==2)
       response.put(paramValue[0], paramValue[1]);
    else if( paramValue.length==1 )
       response.put(paramValue[0],null);
  }
  
  return response;
}

/****
public String  GetExpressCheckoutDetails( String token )
throws Exception
{
  HashMap<String,String>h = new HashMap<String,String>();
  
  h.put("METHOD", "GetExpressCheckoutDetails");
  h.put("TOKEN", token);

  return( send(h));


}
***/

HashMap<String,String> doFct(  HashMap<String,String> param, String fct,int wid )
throws Exception
{
  StringBuilder input = new StringBuilder();
  String rep = send(param,input);
  Etn.execute( "insert into paypal(id,fct,send,rcv) values("+
     wid+",'"+fct+"',"+escape.cote(input.toString())+","+
     escape.cote(rep)+")");

  return( getMap(rep) );
}
  

HashMap<String,String> doAuthorisation( String tid, String amount, int wid)
throws Exception
{
   HashMap<String,String>h = new HashMap<String,String>();
   h.put("METHOD","DoAuthorization");
   h.put("TRANSACTIONID", tid);
   h.put("AMT", amount);
   h.put("CURRENCYCODE", "EUR");
   
   return( doFct( h, "DoAuthorization",wid) );

}

HashMap<String,String> doCapture( String tid, String amount, int wid, String clid )
throws Exception
{
   HashMap<String,String>h = new HashMap<String,String>();
   h.put("METHOD","DoCapture");
   h.put("AUTHORIZATIONID", tid);
   h.put("AMT", amount);
   h.put("CURRENCYCODE", "EUR");
   h.put("COMPLETETYPE", "Complete");
   h.put("NOTE", "pedido "+clid+" wid "+wid);
   return( doFct( h, "DoCapture",wid) );

}

HashMap<String,String> doVoid( String tid, int wid)
throws Exception
{
   HashMap<String,String>h = new HashMap<String,String>();
   h.put("METHOD","DoVoid");
   h.put("AUTHORIZATIONID", tid);
   h.put("NOTE", "Le printemps arrive");
   return( doFct( h, "DoVoid",wid) );

}

HashMap<String,String> doRefund( String tid, int wid, String clid)
throws Exception
{
   HashMap<String,String>h = new HashMap<String,String>();
   h.put("METHOD","RefundTransaction");
   h.put("TRANSACTIONID", tid);
   h.put("NOTE", "pedido "+clid+" wid "+wid);
   return( doFct( h, "DoRefund",wid) );

}


public PayPal( ClientSql Etn, Properties conf )
 {

   env = conf;

   this.Etn = Etn;
   sched = (Scheduler)env.get("sched");

   if( env.get("DEBUG")!=null ) debug = true;
   if( env.get("PAYPAL_debug") != null ) 
    { if(  env.getProperty("PAYPAL_debug").length() > 0 &&
       "Nn0".indexOf(env.getProperty("PAYPAL_debug").charAt(0)) != -1 )
        debug = false;
      else debug = true;
    }
   
   //PWD = env.getProperty("pwd");
   //USER =  env.getProperty("user");
   //VERSION = env.getProperty("version");
   url = env.getProperty("PAYPAL_url");
   port = 443;
   keyPath = env.getProperty("PAYPAL_keypath");
   pass = env.getProperty("PAYPAL_keypass");
   if( debug)
     System.out.println("using keyPath :"+keyPath);
   user =  env.getProperty("PAYPAL_user");
   pwd = env.getProperty("PAYPAL_pwd");
   version = env.getProperty("PAYPAL_version");
   sched = (Scheduler) env.get("sched");

   
   try {
    timeout = Integer.parseInt(env.getProperty("PAYPAL_timeout")); 
    timeout *= 1000;
   }
   catch( Exception ze) { timeout = 30000; }

   System.out.println("PayPal démarré");

   if( timeout < 10000 ) timeout =  30000;

 }


/**
 * Traduit code d'erreur en action.
 * @return 0 : OK
 * @return -1 : Connexion pblm
 * @return 9: fatal donnee manquent etc...
 * @return 5: retry
 * @return 7: appel incorrect
*/

int errType( String fct , HashMap<String,String>h )
{
  String ack = h.get("ACK");
  
  if( ack != null && ack.equalsIgnoreCase("Success") )
   return(0);

  int err;
  String zerr =  h.get("L_ERRORCODE0") ;
  if( zerr == null ) zerr =  h.get("ERRORCODE0");
  try {
    err = Integer.parseInt(zerr);
  }
  catch( Exception e) { 
     h.put("ERROR_TYPE", "CONNEXION");
      return(-1);
  }

 if( fct.equalsIgnoreCase("DoAuthorization" ) || 
     fct.equalsIgnoreCase("DoCapture") )
 {
    switch( err ) {
    case 10009 : case 10603 : case 10606: case 10626 :
    case 10001 : case 10607 : case 10628 : 
    h.put("ERROR_TYPE" , "RETRY" );
    return(5);

    default : h.put("ERROR_TYPE" , "FATAL" );
    return(9);
    }
 }


  if( fct.equalsIgnoreCase("DoRefund" ) )  
  { if( err == 10001  )  
      { h.put("ERROR_TYPE" , "RETRY" );
        return(5);
      }
   h.put("ERROR_TYPE" , "FATAL" );
   return(9);
  }

  return(7); // ???
}

int payCmd(  int cmd , Set rs, StringBuilder transid, 
                StringBuilder msg, int wid, String clid )
{
  if( rs.value("paypalid").length() < 5 ) 
      return(1);

  String curid = rs.value("paypalid");
  int i = curid.indexOf(',');
  if( i != -1 )
    curid = curid.substring(0,i);
  curid = curid.trim();

 try 
 {
   if( cmd == 1 ) // doAuth + doCapture 
   { 
     String amount = rs.value("price");
     if( amount.length() == 0 || Double.parseDouble(amount) < 0.5 )
        return(2);
     if( Integer.parseInt(rs.value("credit")) >0 && 
         Integer.parseInt(rs.value("debit")) == 0 )
      { msg.append("De crédito ya se ha logrado");
        return( 0 );
      }

     
     HashMap<String,String>h = doAuthorisation( curid, amount, wid);
     if( h.get("ACK").equalsIgnoreCase("Success") == false )
      { if( h.get("L_SHORTMESSAGE0") != null )
           msg.append( h.get("L_SHORTMESSAGE0") );
         return(errType( "DoAuthorization" , h) );
    
      }
     String auth = null; // h.get("AUTHORIZATIONID");
     if( auth == null ) 
       auth = h.get("TRANSACTIONID");
     //String auth = h.get("AUTHORIZATIONID");
     
     System.out.println("Autorizationid:"+auth);
     if( auth == null || auth.length() == 0 )
        return(4);
     
     if( auth.equals( curid) == false )
        transid.append( auth);
     
     // do Capture
     h = doCapture( auth , amount, wid, clid);
     if( h.get("ACK").equalsIgnoreCase("Success") == false )
     {  if( h.get("L_SHORTMESSAGE0") != null )
           msg.append( h.get("L_SHORTMESSAGE0") );
         return(errType( "DoCapture" , h ));
       
     }

     String auth2 = null; //h.get("AUTHORIZATIONID");
     if( auth2 == null )
       auth2 = h.get("TRANSACTIONID");


     if( auth2 != null )
     if( auth2.equals( auth ) == false )
       { if( transid.length() > 0 )
           transid.insert(0, auth2+",");
         else transid.append(auth2);
       }
       
     return(0);

   }
  
   if( cmd == 2 || cmd == 3 ) // refund
   {
     if(Integer.parseInt(rs.value("credit")) == 0 ) 
      { msg.append("El crédito no se ha logrado");
        return(0);
      }
     if(Integer.parseInt(rs.value("debit")) != 0 )
      { msg.append("El flujo se ha logrado");
        return(0);
      }

     /***
     curid =  rs.value("paypalid");
     if( ( i = curid.lastIndexOf(",") ) != -1 ) 
       curid = rs.value("paypalid").substring(i+1);
     curid = curid.trim();
     **/

     HashMap<String,String>h = doRefund( curid,wid, clid );
     if( h.get("ACK").equalsIgnoreCase("Success") == false )
     {   if( h.get("L_SHORTMESSAGE0") != null )
           msg.append( h.get("L_SHORTMESSAGE0") );
         return(errType( "doRefund" , h ));

     }

     String auth =  h.get("TRANSACTIONID");
     if( auth != null &&  auth.equals( curid) == false )
        transid.append( auth);



     return(0);
   }

  return( -2 );
 }
 catch( Exception e )
  { e.printStackTrace();
    return(-1);
  }

}

public int update( int wid , String clid, int  cmd ) 
{
  StringBuilder msg = new StringBuilder(128), transid =  new StringBuilder(128);
  int r = 0 ;
  
  if( debug )
    System.out.println("PayPal wid:"+wid+" clid:"+clid+" fct :"+cmd);

  Set cust = Etn.execute( 
  "select lower(phase) as phase , c.paypalid, c.price, c.debit ,c.credit "+
  ",p.attempt "+
  " from customer c "+
  " inner join post_work p on p.client_key = c.customerid "+
  " where p.id ="+wid+" and customerid = "+clid);

  if( !cust.next() ) // ???
     r = 1;
  else   
   { 
    
     r = payCmd(  cmd , cust , transid,msg, wid, clid );
   }


  switch( r ) 
  {
   case 0 :  // OK
            if( cmd == 2 )   // ne pas continuer
            Etn.executeCmd( "update post_work set errcode= 55"+
               " , status = 9 where id="+wid );
            else 
            Etn.executeCmd( "update post_work set errcode= 0"+
               " where id="+wid );
            sched.endJob( wid , clid );
            if( transid.length() > 0 )
              transid.append( ","+cust.value("paypalid"));
            else transid.append( cust.value("paypalid"));
            
            if( cmd==1 ) 
              Etn.executeCmd( "update customer set credit="+wid+
              ", paypalid = "+escape.cote( transid.toString())+
               " where customerid="+clid );
            else if( cmd==2 ) 
              Etn.executeCmd( "update customer set debit="+wid+
              ", paypalid = "+escape.cote( transid.toString())+
               " where customerid="+clid );

            return(0);

   case -1 :  // Connexion pblm
    { Etn.execute(
     "update post_work set attempt = attempt+1 ,"+
     "priority = date_add(priority,interval +30 minute),"+
     "status = 0, "+
     "errmessage= concat('Paypal connection pblm retry at ',priority),"+
     "start=ifnull(start,now()) "+
     " where id = "+wid );
    }
     return(0);


   case 3 :
   case 4 :
   case 5 : // Retry
   case 6 :
    { 
     
     int essai = Integer.parseInt(cust.value("attempt"));
     
     if( essai < 72 ) 
     Etn.execute(
     "update post_work set attempt = attempt+1 ,"+
     "errcode= 5, "+
     "errmessage="+escape.cote(msg.toString())+
     ",priority=date_add(now(), interval +1 hour) "+
     " where id = "+wid );
     else
     {   
         Etn.execute(
         "update post_work set attempt = attempt+1 ,"+
         "errcode= 5, "+
         "errmessage="+escape.cote(msg.toString())+
         " where id = "+wid );
  
       sched.endJob( wid , clid );
     }
     return(0);
     
    }


   case 9: 
     {   
         Etn.execute(
         "update post_work set attempt = attempt+1 ,"+
         "errcode= 5, "+
         "errmessage="+escape.cote(msg.toString())+
         " where id = "+wid );

       sched.endJob( wid , clid );
     }
     return(0);


   default:  // appel inconséquent
   {
     System.out.println( "PayPal Pas de paypalid wid:"+wid+
         " custid:"+clid+ "r:"+r+
               " message:"+msg.toString());
    
     Etn.execute(
     "update post_work set attempt = attempt+1 ,"+
     " errcode="+(cmd==2?55:0)+" , errmessage='No PayPal'"+
     " where id = "+wid );

      sched.endJob( wid , clid );
     return(r);
   }

 }

}

/********
 public static void main( String a[] )
 throws Exception
 {


   Properties p = new Properties();
   p.load( new FileInputStream( "PayPal.conf") );
   PayPal pp = new PayPal(p);



  //String tid =  "74S803951K484384R";
  //String tid =  "5V043272X8926491G";
  String tid =  "8KW44538NP944835H";
  System.out.println("tid:"+tid);
  //String r = pp.doCapture( tid, "29.00" );
  //String r = pp.doVoid( tid );
  String r = pp.doRefund( tid );

  System.out.println( "doRefund:"+r );
 

  
   if( 1== 0 ) {
   String r = pp.doAuthorisation( tid, amount);
   System.out.println( "doAuthorization:"+r );

  //tid="74S803951K484384R";
  tid=  "5V043272X8926491G";
   int i , j;
   i = r.indexOf("TRANSACTIONID=");
   if( i != -1 ) 
    { i +=  14;
      j = r.indexOf("&",i);
      if( j != -1 )
        tid = r.substring( i,j);
    }

   }
}
**************/


}
