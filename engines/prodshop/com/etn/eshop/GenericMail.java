package com.etn.eshop;


import java.io.*;
import java.net.URL;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.*;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.net.MailFromModel;



public class GenericMail extends MailFromModel
{
	public final int NO_CONNECTION = -1;
	public final int NO_RECIPIENT = -2;
    public final int NO_CONTACT = 3;
	private Dictionary dictionary;
    
	String repository;
    InternetAddress FROM;
    InternetAddress REPLY[];

	ClientSql etn;
	Properties env;
	Session session;
	String lang;

	public GenericMail( ClientSql etn , Properties conf) throws Exception
	{ 
		super(conf);
		this.etn = etn; 
		this.env = conf;
		this.lang = "1";
		this.repository = env.getProperty("MAIL_REPOSITORY");
		this.dictionary = new Dictionary(etn , conf );

		Authenticator auth = null;
		if(parseNull(env.getProperty("mail.smtp.auth")).length() > 0 && Boolean.parseBoolean(parseNull(env.getProperty("mail.smtp.auth"))) == true)
		{
			System.out.println("use smtp authentication");
			auth = new SMTPAuthenticator(env.getProperty("mail.smtp.auth.user"), env.getProperty("mail.smtp.auth.pwd"));
		}
		this.session = Session.getDefaultInstance(env, auth);
		session.setDebug(true);
	}

    InternetAddress setAdr(String adr) 
	{
        try {
            return (new InternetAddress(adr));
        } catch (Exception e) {
            return (null);
        }
    }

    String parseNull(Object o)
    {
      if( o == null )
        return("");
      String s = o.toString();
      if("null".equals(s.trim().toLowerCase()))
        return("");
      else
        return(s.trim());
    }
        
    int setEmail(String email) {
        if(email.equals("")) return 0;
        destTO = new InternetAddress[1];
        destTO[0] = setAdr(email);
        return (1);
    }


	public int send(Set rsMail) 
	{
        FileInputStream fmodele = null;
        FileOutputStream out = null;
        String attachs[] = null;

        try 
		{
			String mailid = parseNull(rsMail.value("emailTemplateId"));
			if(mailid.length() == 0 || "0".equals(mailid))
			{
				return -1;
			}
			System.out.println("Email template id : " + mailid);
			String maillang = "";
			Set rsLang = etn.execute("select * from language order by langue_id limit 1");
			if(rsLang.next()) maillang = rsLang.value("langue_code");
			
			if( parseNull(rsMail.value("lang")).length() > 0) maillang = parseNull(rsMail.value("lang"));

            // Destinataires
            if (setEmail(rsMail.value("email")) == 0) {
                return (NO_CONTACT); // nothing to do
            }

            setFrom(env.getProperty("MAIL_FROM"), env.getProperty("MAIL_FROM_DISPLAY_NAME"));
            setReply(env.getProperty("MAIL_REPLY"));

			String emailtemplate = repository + "/mail" + mailid + "_" + maillang;
			File ftemplate = new File(emailtemplate);
			System.out.println("Try Template : " + emailtemplate);
			if(!ftemplate.exists() || ftemplate.length() == 0) emailtemplate = repository + "/mail" + mailid;
			System.out.println("Final Template : " + emailtemplate);
			Set rsSubject =etn.execute("select * from mails where id="+escape.cote(mailid));
			rsSubject.next();
            fmodele = new FileInputStream(emailtemplate);
            etn.executeCmd("update "+env.getProperty("PORTAL_DB")+".cart set incomplete_cart_mail_sent='1' where id="+escape.cote(rsMail.value("id")));
			// Change sujet according to language e.g sujet2,sujet3
            return (send(fmodele, rsMail, rsSubject.value("sujet"), null));
        } 
		catch (Exception e) 
		{
            e.printStackTrace();
            return (NO_CONNECTION);
        } 
		finally 
		{
            try {
                if (fmodele != null) {
                    fmodele.close();
                }
                if (out != null) {
                    out.close();
                }
            } catch (Exception ze) {
            }
        }


    }

	public int send( String email, String subject, String emailText )
	{ 
		try 
		{
			String to = parseNull(email);
			if(to.length() == 0)
			{
					System.out.println("GenericMail::ERROR::No recipients");
					return NO_RECIPIENT;
			}

			MimeMessage message = new MimeMessage(session);

			message.setFrom(new InternetAddress(env.getProperty("MAIL_FROM"), parseNull(env.getProperty("MAIL_FROM_DISPLAY_NAME"))));
			message.setReplyTo(new InternetAddress[] { new InternetAddress(env.getProperty("MAIL_REPLY"))});

			message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));

			message.setSubject(subject);

			String emailBody = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'><html><head><meta http-equiv='content-type' content='text/html;charset=UTF-8'></head>";
			emailBody += "<body bgcolor='#ffffff' text='#000000'>";
			emailBody += emailText;
			emailBody += "</body>";
			emailBody += "</html>";
			message.setContent(emailBody, "text/html; charset=utf-8");
//			message.setText(emailBody);

			Transport.send(message);
			return 1;
		}
		catch( Exception e ) 
		{ 
			e.printStackTrace();
			System.out.println(e.getMessage());
			return(NO_CONNECTION);
		}
	}

	public static void main( String a[] ) throws Exception
	{
		Properties p = new Properties();
		p.load( GenericMail.class.getResourceAsStream("Scheduler.conf") );
	}

	private class SMTPAuthenticator extends javax.mail.Authenticator 
	{
		private String username;
		private String password;
		public SMTPAuthenticator(String username, String password)
		{
			this.username = username;
			this.password = password;
		}

       	public PasswordAuthentication getPasswordAuthentication() 
		{
			return new PasswordAuthentication(username, password);
		}
	}

}