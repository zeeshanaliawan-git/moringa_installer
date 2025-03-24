package com.etn.eshop;


import java.io.*;
import java.net.URL;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.*;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;



public class QuestionMail 
{
	public final int NO_CONNECTION = -1;
	public final int NO_RECIPIENT = -2;

	ClientSql etn;
	Properties env;
	Session session;
	String lang;
	boolean debug;

	public QuestionMail( ClientSql etn , Properties conf, String lang) throws Exception
	{ 
		this.etn = etn; 
		this.env = conf;
		this.lang = lang;
//		Authenticator auth = new SMTPAuthenticator(env.getProperty("SMTP_AUTH_USER"), env.getProperty("SMTP_AUTH_PWD"));
		
//		this.session = Session.getDefaultInstance(env, auth);
		this.session = Session.getDefaultInstance(env, null);
                session.setDebug(true);

	}

	private String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
        
        private String libelle_msg(String msg){
            Set rs = etn.execute("select * from "+env.getProperty("CATALOG_DB")+".langue_msg where langue_ref="+escape.cote(msg)+" limit 1");
            if(rs.next()){
                if(rs.value("langue_"+this.lang).equals("")) return msg;
                else return rs.value("langue_"+this.lang);
            }
            else{
                etn.execute("insert IGNORE into "+env.getProperty("CATALOG_DB")+".langue_msg(LANGUE_REF) values(TRIM("+ escape.cote(msg)+"))");
            }
            return msg;
        }

	public int send( Set rs, Set rsQuestions )
	{
            return sendToCustomer(rs, rsQuestions);
	}

	public int sendToCustomer( Set rs, Set rsQuestions )
	{ 
		try 
		{
                    String subject = libelle_msg("Question regarding product");

                    String to = parseNull(rs.value("email"));
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
                    
                    String client_uuid = UUID.randomUUID()+"";
                    etn.executeCmd("insert into "+env.getProperty("CATALOG_DB")+".product_question_clients (client_id, question_uuid, client_uuid) values("+escape.cote(rs.value("client_id"))+","+escape.cote(rsQuestions.value("question_uuid"))+","+escape.cote(client_uuid)+")");
                    //System.out.println("insert into "+env.getProperty("CATALOG_DB")+".product_question_clients (client_id, question_uuid, client_uuid) values("+escape.cote(rs.value("client_id"))+","+escape.cote(rsQuestions.value("question_uuid"))+","+escape.cote(client_uuid)+")");

                    String emailBody = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'><html><head><meta http-equiv='content-type' content='text/html;charset=UTF-8'></head>";
                    emailBody += "<body bgcolor='#ffffff' text='#000000'>";
                    emailBody += "<p>"+libelle_msg("Dear Customer,")+"</p>";
                    emailBody += "<p>"+libelle_msg("A user asked a question regarding a product you recently purchased:")+"<br>"+parseNull(rsQuestions.value("question"));
                    emailBody += "</p><p>"+libelle_msg("Follow this link to answer:")+"<br>";
                    emailBody += rsQuestions.value("domain")+parseNull(env.getProperty("ANSWERS_URL"))+"?qid="+parseNull(rsQuestions.value("question_uuid"))+"&muid="+parseNull(rsQuestions.value("menu_uuid"))+"&clid="+client_uuid;
                    emailBody += "</p><p>"+libelle_msg("Regards,")+"<br>";
                    emailBody += parseNull(env.getProperty("MAIL_FROM_DISPLAY_NAME"))+"</p>";

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
		p.load( QuestionMail.class.getResourceAsStream("Scheduler.conf") );
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