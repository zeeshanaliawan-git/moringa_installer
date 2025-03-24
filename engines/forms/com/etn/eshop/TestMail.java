package com.etn.eshop;


import java.io.*;
import java.net.URL;

import javax.mail.*;
import javax.mail.internet.*;
import java.util.*;

import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;



public class TestMail
{
        public final int NO_CONNECTION = -1;
        public final int NO_RECIPIENT = -2;

        Properties env;
        Session session;
        boolean debug;
		ClientSql Etn;

        public TestMail(  ) throws Exception
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

        private String getColHtml(String col, String v)
        {
                if(parseNull(v).length() == 0) return "";
                return "<tr><td style='font-weight:bold;'>"+col+"</td><td style='font-weight:bold;'>&nbsp;:&nbsp;</td><td>"+parseNull(v)+"</td></tr>";
        }

        public int send( String to )
        {
                try
                {
                        String subject = "Test email";


                        if(to.length() == 0)
                        {
                                System.out.println("TestMail::ERROR::No recipients");
                                return NO_RECIPIENT;
                        }

                        ArrayList<String> tos = new ArrayList<String>();
                        if(to != null)
                        {
                                String[] _tos = to.split(";");
                                if(_tos != null)
                                {
                                        for(String _t : _tos)
                                        {
                                                if(parseNull(_t).length() > 0) tos.add(parseNull(_t));
                                        }
                                }
                        }
                        if(tos.isEmpty())
                        {
                                System.out.println("TestMail::ERROR::No recipients");
                                return NO_RECIPIENT;
                        }

                        MimeMessage message = new MimeMessage(session);

                        message.setFrom(new InternetAddress(env.getProperty("MAIL_FROM")));
                        if(parseNull(env.getProperty("MAIL_REPLY")).length() > 0) message.setReplyTo(new InternetAddress[] { new InternetAddress(env.getProperty("MAIL_REPLY"))});



                        for(String _to : tos)
                        {
                                System.out.println("Adding recipient : " + _to);
                                message.addRecipient(Message.RecipientType.TO, new InternetAddress(_to));
                        }

                        message.setSubject(subject);

                        String emailBody = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'><html><head><meta http-equiv='content-type' content='text/html;charset=UTF-8'></head>";

                        emailBody += "<body bgcolor='#ffffff' text='#000000'>";
                        emailBody += "<div>This is a test email</div><br><br>";
                        emailBody += "<div>smtp server : "+env.getProperty("mail.smtp.host")+"</div>";
                        emailBody += "<div>smtp port : "+env.getProperty("mail.smtp.port")+"</div>";
                        emailBody += "<div>smtp auth : "+env.getProperty("mail.smtp.auth")+"</div>";
                        emailBody += "<div>smtp user : "+env.getProperty("mail.smtp.auth.user")+"</div>";
                        emailBody += "<div>smtp pwd : "+env.getProperty("mail.smtp.auth.pwd")+"</div>";
                        emailBody += "</body>";
                        emailBody += "</html>";

                        message.setContent(emailBody, "text/html; charset=utf-8");

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
                System.out.println("________main++++++++++");
                                if(a == null || a.length == 0)
                                {
                                        System.out.println("pass email address to send test email");
                                        return ;
                                }

                System.out.println("------ in contact us mail");
                TestMail sm = new TestMail( );
                sm.send(a[0]);
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
                                                                                                                                          
