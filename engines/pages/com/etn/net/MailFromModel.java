/**
 * Etance:$Id: MailFromModel.java,v 1.4 2011/02/21 11:31:54 alban Exp $
*/
package com.etn.net;

import java.io.*;
import java.net.URL;

import javax.mail.*;
import javax.mail.internet.*;
import javax.activation.*;

import java.security.*;
import java.security.cert.*;

import javax.net.ssl.*;
import java.util.HashMap;
import java.util.Properties;
import java.util.Enumeration;
import java.util.Date;
import com.etn.util.ItsDate;


import com.etn.lang.ResultSet.Set;



public class MailFromModel {

protected boolean debug;
Properties env;
Session session;
InternetAddress FROM ;
InternetAddress REPLY[];
protected InternetAddress destTO[];
protected InternetAddress destBCC[];
protected InternetAddress destCC[];


public boolean skip( BodyPart modelpart , String modeltype , int niveau , 
     int souspart )
{ 
  if( debug )
   System.out.println( "skip-> niveau:"+niveau+" souspart:"+souspart);

  return( false ); 
}

public void addSousPart( MimeMultipart cur , BodyPart lastmodel, int niveau , int souspart )
{ 
  if( debug )
   System.out.println( "addSousPart-> niveau:"+niveau+" souspart:"+souspart);
}


public String replace( String source , Set rs )
{
  if( rs == null ) return( source );

  StringBuilder src = new StringBuilder( source);
  int i,j,k;
  String val;

  
  i = j = 0 ;
  while( ( i = src.indexOf("db",j) ) != -1 )
  { 
    for( k = i+2 ; k < src.length() && isLetterOrDigit( src.charAt(k) ); k++ );
    String col = src.substring(i+2,k);

    if( ( val = rs.value(col))  != null )
      { src.replace(i,k,val); j = i + val.length(); }
    else j = i+2 ;
  }

 return(src.toString());

}


private boolean isLetterOrDigit(char c)
{
	return (c == '_' || Character.isLetterOrDigit( c ));
}


String getSubType( String srcType )
{
   int i = srcType.indexOf('/');
   int j = ++i;
   while( Character.isLetterOrDigit( srcType.charAt(j) )) j++;
   return( srcType.substring(i,j) );
}


int setHeaders( MimeMessage to , MimeMessage model , Set rs, String sujet )
throws Exception
{ 
 to.setFrom(FROM);
 to.setSender(FROM);
 to.setSentDate(new Date());
 to.setReplyTo( REPLY);
 to.setSubject( sujet );


 if( destTO != null ) 
   to.setRecipients(  Message.RecipientType.TO , destTO );

 if( destBCC != null ) 
   to.addRecipients( Message.RecipientType.BCC , destBCC );
 
 if( destCC != null ) 
   to.addRecipients( Message.RecipientType.CC , destCC );

 for( Enumeration e = model.getAllHeaderLines() ; e.hasMoreElements() ; )
 {
   String s = (String)e.nextElement();
   int i = s.indexOf(':');
   String tag = s.substring(0,i).trim();
   if( tag.equalsIgnoreCase("mime-version") )
     to.setHeader( tag, s.substring( i+1)) ;
   else if( tag.equalsIgnoreCase("Content-Type") )
     to.setHeader("Content-Type", s.substring( i+1)) ;
   // else a voir
   //System.out.println( s );
   
  }

  // debug
  if( debug ) 
  for( Enumeration e = to.getAllHeaderLines() ; e.hasMoreElements() ; )
 {
   System.out.println( (String)e.nextElement() );
 }


 return(0);
 
}



int setMulti( MimeMultipart dest , MimeMultipart src , Set rs, int niveau )
throws Exception
{

  niveau++;
  
  // Init header du MultiPart dest
  dest.setSubType( getSubType(src.getContentType() ));
  if( debug )
  System.out.println( "Multipart subpart:"+src.getCount()+"\nsrc:[" +src.getContentType()+ "] \ndest:["+dest.getContentType()+"]");

  // Les parties du Multipart
  for( int i = 0 ; i < src.getCount() ; i++ )
  { BodyPart p = src.getBodyPart(i);
    String type = p.getContentType();
    if( !skip( p , type, niveau , i ) ) 
    {
      if( debug )
        System.out.println( "Body index "+i+" "+p+" -> "+type );

      if( type.startsWith( "multipart" ) )
      { MimeMultipart content = (MimeMultipart)p.getContent(), 
             d2 = new MimeMultipart();
     
        setMulti( d2 , content , rs, niveau);
        MimeBodyPart dbd = new MimeBodyPart();
        dbd.setContent( d2 );
        dest.addBodyPart( dbd );
      }
      else if( type.startsWith("text") )
      {
        MimeBodyPart ps = (MimeBodyPart)p , pd = new MimeBodyPart();
        /*** Marche pas .... **/
        //copyHeaders( pd , ps);
        pd.setHeader("Content-Type", ps.getContentType() );
          if( debug )
    System.out.println( "Textsubpart:src:[" +ps.getContentType()+ "] dest:["+pd.getContentType()+"]");

        String z = (String)ps.getContent();
        z = replace( z , rs );
       
        pd.setContent(z,ps.getContentType());
        //pd.setContent(z,"text/html");
        dest.addBodyPart(pd);
       }
      else // images etc...
       dest.addBodyPart( p);

   }  // skip

   addSousPart( dest , p, niveau , i );

  }
 
 return(0);

}

  
int setBody( MimePart tosend , MimePart model , Set rs, String attachs[]  )
throws Exception
{ 
  MimeMultipart top = null;

  if( attachs != null && attachs.length > 0 )
  { /** Il faut un multipart Top **/
    top = new MimeMultipart();
    top.setSubType( "mixed" );
  }

  Object o = model.getContent();
  
  if( o instanceof Multipart )
  { 
    MimeMultipart mulsrc = (MimeMultipart) o , muldest = new MimeMultipart();
    if( debug )
      System.out.println( "Multi instance:" +mulsrc.getCount() );

    setMulti( muldest , mulsrc , rs , 0);
    if( debug )
      System.out.println( "Multi instance avt attach:" +muldest.getCount() );

    if( top == null ) // No attach
       tosend.setContent(muldest);
    else 
    { MimeBodyPart p1 = new MimeBodyPart();
      p1.setContent(muldest);
      top.addBodyPart( p1 );
      for( int i = 0 ; i < attachs.length ; i++ )
       {  MimeBodyPart att = new MimeBodyPart();
          /** Si javamail >= 1.4 **/
          att.attachFile(attachs[i]);
          /** javamail < 1.4 
          FileDataSource fds = new FileDataSource(attachs[i]);
          att.setDataHandler(new DataHandler(fds));
          att.setFileName(fds.getName());
          */

          top.addBodyPart(att); 
       }
       tosend.setContent(top);
     }
    //if( debug )
    //  System.out.println( "Multi instance Apres:" +muldest.getCount() );

  }
  else  if( o instanceof MimeBodyPart )
  {
    MimeBodyPart sPart = ( MimeBodyPart ) o, dPart = null;
    String type = sPart.getContentType();
    System.out.println( "MimeBodyPart:" + type);
  
     if( type.startsWith("text") )
      { // Il faut parser...
        dPart = new MimeBodyPart();
        //copyHeaders( dPart , sPart);
        String z = (String)sPart.getContent();
        z = replace( z , rs );
        dPart.setContent(z,type);
        tosend.setContent(dPart,type);
      } 
      else tosend.setContent(sPart,type);
      
  }
  else // Part ???
  if( o instanceof BodyPart )
  { BodyPart sPart = ( BodyPart ) o, dPart = null;
    String type = sPart.getContentType();
    //System.out.println( "BodyPart:" + type);
    tosend.setContent(sPart,type);
  }
  else if(  o instanceof Part )
  { Part part = (Part) o, dPart = null;
    String type = part.getContentType();
    //System.out.println( "BodyPart:" + type);
    tosend.setContent(part,type);
  }
  else
   tosend.setText( replace(o.toString(),rs) );


  return(0);
}

public void setFrom( String from, String displayname) 
throws Exception
{ 
	if(displayname == null) displayname = "";
	FROM = new InternetAddress(from, displayname); 
}

public void setReply( String replyto) 
throws Exception
{ REPLY = new InternetAddress[1];
  REPLY[0] = new InternetAddress(replyto);
}


public MailFromModel( Properties conf )
throws Exception
{ 
  this.env = conf;
 
  // par defaut
  setFrom(env.getProperty("MAIL_FROM"), env.getProperty("MAIL_FROM_DISPLAY_NAME"));
  setReply(env.getProperty("MAIL_REPLY"));

  
  session = Session.getDefaultInstance(env, null);
  debug = (env.get("MAIL_DEBUG") != null  ? true: false) ;
  session.setDebug( env.get("SMTP_DEBUG") != null ) ;

}

public MimeMessage build( InputStream fmodele , Set rs , String sujet,
   String attachs[] )
throws Exception
{

  MimeMessage model= null , tosend = null;
  MimeMultipart top = null;   // pour attachements
  int r = -1;

  sujet = replace( sujet, rs );
  model = new MimeMessage( session , fmodele );
  tosend = new MimeMessage( session );

  if( ( r = setHeaders( tosend , model , rs, sujet ) ) != 0 )
     return(null);

  if( attachs != null && attachs.length > 0 )
  { 
    top = new MimeMultipart();
    top.setSubType( "mixed" );
  }


  if( ( r = setBody( tosend , model , rs, attachs ) ) != 0 )
     return(null);


  return(tosend);
}

public MimeMessage build( InputStream fmodele , Set rs , String sujet)
throws Exception
{ return( build( fmodele, rs, sujet , null ) ); }

public int send(  InputStream fmodele , Set rs , String sujet, String attachs[] )
{ 
  try {
   MimeMessage tosend = build( fmodele , rs , sujet, attachs );
   if( tosend == null ) return(1);
   Transport.send(tosend);
   return(0);
  }
  catch( Exception e ) 
   { e.printStackTrace();
     return( -1 );
   }
}

public int send(  InputStream fmodele , Set rs , String sujet )
{ return( send( fmodele,rs,sujet,null ) ); }


public int writeTo( OutputStream o ,  InputStream fmodele , Set rs , 
   String sujet, String attachs[] )
{ 
  try {
   MimeMessage tosend = build( fmodele , rs , sujet,attachs );
   if( tosend == null ) return(1);
   tosend.writeTo(o);
   return(0);
  }
  catch( Exception e )
   { e.printStackTrace();
     return( -1 );
   }
}

public int writeTo( OutputStream o ,  InputStream fmodele , Set rs ,
   String sujet )
{ return( writeTo( o , fmodele , rs , sujet , null ) ); }



}
