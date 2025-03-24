package com.etn.eshop;


import java.io.*;
import java.net.URL;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.*;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;



public class DashboardMail
{
	public final int NO_CONNECTION = -1;
	public final int NO_RECIPIENT = -2;

	ClientSql etn;
	Properties env;
	Session session;
	boolean debug;

	public DashboardMail( ClientSql etn , Properties conf) throws Exception
	{
		this.etn = etn;
		this.env = conf;
		
		Authenticator auth = null;
		if(parseNull(env.getProperty("mail.smtp.auth")).length() > 0 && Boolean.parseBoolean(parseNull(env.getProperty("mail.smtp.auth"))) == true)
		{
			System.out.println("use smtp authentication");
			auth = new SMTPAuthenticator(env.getProperty("mail.smtp.auth.user"), env.getProperty("mail.smtp.auth.pwd"));
		}

		this.session = Session.getDefaultInstance(env, auth);
		session.setDebug(true);

	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	public int send(  Set rsDashboardMail  )
	{
		return sendToCustomer(rsDashboardMail);
	}

	public int sendToCustomer( Set rsDashboardMail )
	{
		try
		{
                    String subject = rsDashboardMail.value("subject");
                    String to = parseNull(rsDashboardMail.value("email"));

                    if(to.length() == 0)
                    {
                            System.out.println("QuestionMail::ERROR::No recipients");
                            return NO_RECIPIENT;
                    }

                    MimeMessage message = new MimeMessage(session);

                    message.setFrom(new InternetAddress(env.getProperty("MAIL_FROM"), parseNull(env.getProperty("MAIL_FROM_DISPLAY_NAME"))));
                    message.setReplyTo(new InternetAddress[] { new InternetAddress(env.getProperty("MAIL_REPLY"))});
                    message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
                    message.setSubject(subject);

                    MimeBodyPart messageBodyPart1 = new MimeBodyPart();
                    messageBodyPart1.setText(rsDashboardMail.value("message"));

                    MimeBodyPart messageBodyPart2 = new MimeBodyPart();
                    messageBodyPart2.attachFile(env.getProperty("DASHBOARD_PDF_PATH")+rsDashboardMail.value("dashboard_pdf"));

                    Multipart multipart = new MimeMultipart();
                    multipart.addBodyPart(messageBodyPart1);
                    multipart.addBodyPart(messageBodyPart2);

//                    String emailBody = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'><html><head><meta http-equiv='content-type' content='text/html;charset=UTF-8'></head>";
//                    emailBody += "<body bgcolor='#ffffff' text='#000000'>";
//                    emailBody += "<p>"+rsDashboardMail.value("message")+"</p>";
//                    emailBody += "</body>";
//                    emailBody += "</html>";
//                    message.setContent(emailBody, "text/html; charset=utf-8");

                    message.setContent(multipart);

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
		p.load( DashboardMail.class.getResourceAsStream("Scheduler.conf"));
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