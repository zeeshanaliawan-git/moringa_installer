package com.etn.eshop;


import java.io.*;
// import java.net.Authenticator;
// import java.net.PasswordAuthentication;
import java.net.URL;
import java.net.URLEncoder;

import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.common.BitMatrix;

import javax.activation.*;
import javax.mail.*;
import javax.mail.internet.*;
import java.util.*;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.eshop.Dictionary;
import com.etn.sql.escape;


public class SendMail
{
	public final int NO_CONNECTION = -1;
	public final int NO_RECIPIENT = -2;

	ClientSql etn;
	Properties env;
	Session session;
	boolean debug;

	public SendMail( ClientSql etn , Properties conf ) throws Exception
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
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	public int forgotPassword( Set rs, boolean isprod, Dictionary dictionary  )
	{
		try
		{
			String to = parseNull(rs.value("email"));
			boolean sendSms = "1".equals(env.getProperty("SEND_FORGOT_PASS_SMS"));
			String phonenumber = parseNull(rs.value(env.getProperty("SMS_DEFAULT_COLUMN")));

			if(!sendSms && to.length() == 0)
			{
				System.out.println("SendMail::ERROR::No recipients");
				return NO_RECIPIENT;
			}
			else if(sendSms && phonenumber.length() == 0 && to.length() == 0)
			{
				System.out.println("SendMail::ERROR::No recipients");
				return NO_RECIPIENT;
			}

			String menuUuid = parseNull(rs.value("forgot_pass_muid"));
			String dbname = "";
			String forgotpassurl = env.getProperty("PREPROD_FORGOT_PASS_URL");
			if(isprod)
			{
				dbname = parseNull(env.getProperty("PROD_DB")) + ".";
				forgotpassurl = env.getProperty("PROD_FORGOT_PASS_URL");
			}

			String lang = "";
			Set rsm = etn.execute("select * from "+dbname+"site_menus where menu_uuid= "+ escape.cote(menuUuid));
			if(rsm.next()) lang = parseNull(rsm.value("lang"));

			String token = java.util.UUID.randomUUID().toString();
			etn.executeCmd("update "+dbname+"clients set forgot_pass_token = "+escape.cote(token)+", forgot_pass_token_expiry = adddate(now(), interval 3 hour) where id = " + rs.value("id"));

			String url = forgotpassurl + "?t="+token+"&muid="+parseNull(rs.value("forgot_pass_muid"));

			String subject = dictionary.getTranslation(lang, "Forgot Password");
			if(to.length() > 0)
			{
				MimeMessage message = new MimeMessage(session);

				message.setFrom(new InternetAddress(env.getProperty("MAIL_FROM"), parseNull(env.getProperty("MAIL_FROM_DISPLAY_NAME"))));
				message.setReplyTo(new InternetAddress[] { new InternetAddress(env.getProperty("MAIL_REPLY"))});

				System.out.println("Adding recipient : " + to);
				message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));

				message.setSubject(subject);

				String emailBody = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'><html><head><meta http-equiv='content-type' content='text/html;charset=UTF-8'></head>";
				emailBody += "<body bgcolor='#ffffff' text='#000000'>";
				emailBody += "<div>";
				emailBody += dictionary.getTranslation(lang, "Dear customer") + "<br><br>";
				emailBody += dictionary.getTranslation(lang, "Kindly click the following link in order to reset your password")  + "<br><br>";
				emailBody += "<a href='"+url+"'>"+url+"</a><br>";
				emailBody += "<div style='color:red'>" + dictionary.getTranslation(lang, "Above link will expire in 3 hours")  + "</div>";
				emailBody += "</div>";
				emailBody += "</body>";
				emailBody += "</html>";
				message.setContent(emailBody, "text/html; charset=utf-8");
//				message.setText(emailBody);

				Transport.send(message);
				System.out.println("ISPROD:"+isprod+" Email sent to client ID : "+rs.value("id") );
			}
			if(sendSms && phonenumber.length() > 0)
			{
				String smsurl = parseNull(env.getProperty("SMS_GATEWAY_URL"));
				smsurl = smsurl.replace("<phone_number>", phonenumber);

				MimeMessage message = new MimeMessage(session);

				message.setFrom(new InternetAddress(env.getProperty("SMS_MAIL_FROM"), parseNull(env.getProperty("MAIL_FROM_DISPLAY_NAME"))));
				message.setReplyTo(new InternetAddress[] { new InternetAddress(env.getProperty("MAIL_REPLY"))});

				System.out.println("Adding recipient : " + smsurl);
				message.addRecipient(Message.RecipientType.TO, new InternetAddress(smsurl));

				message.setSubject(subject);

				String emailBody = dictionary.getTranslation(lang, "Reset") + " ";
				emailBody += url;
				emailBody += " " + dictionary.getTranslation(lang, "Above link will expire in 3 hours");
				message.setContent(emailBody, "text/html; charset=utf-8");
//				message.setText(emailBody);

				Transport.send(message);
				System.out.println("ISPROD:"+isprod+" SMS Email sent to client ID : "+rs.value("id") );

			}
			return 1;
		}
		catch( Exception e )
		{
			e.printStackTrace();
			System.out.println(e.getMessage());
			if( debug) System.out.println("ISPROD:"+isprod+" Forgot pass email not sent : client id :"+rs.value("id"));
			return(NO_CONNECTION);
		}

	}

	private String getEmailTemplate(String content)
	{
		String emailBody = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'><html><head><meta http-equiv='content-type' content='text/html;charset=UTF-8'></head>";
		emailBody += "<body bgcolor='#ffffff' text='#000000'>";
		emailBody += "<div>";
		emailBody += content;
		emailBody += "</div>";
		emailBody += "</body>";
		emailBody += "</html>";
		return emailBody;
	}

	private MimeMessage getMessage(String mailFrom, String displayName, String mailReply,String to,String subject,String content) throws Exception
	{
		MimeMessage message = new MimeMessage(session);
		message.setFrom(new InternetAddress(mailFrom, displayName));
		message.setReplyTo(new InternetAddress[] { new InternetAddress(mailReply)});
		message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
		message.setSubject(subject);
		message.setContent(getEmailTemplate(content), "text/html; charset=utf-8");
		return message;
	}

	private String getProductName(Set rs)
	{
		if(parseNull(rs.value("lang_1_name")).length()>0) return parseNull(rs.value("lang_1_name"));
		if(parseNull(rs.value("lang_2_name")).length()>0) return parseNull(rs.value("lang_2_name"));
		if(parseNull(rs.value("lang_3_name")).length()>0) return parseNull(rs.value("lang_3_name"));
		if(parseNull(rs.value("lang_4_name")).length()>0) return parseNull(rs.value("lang_4_name"));
		if(parseNull(rs.value("lang_5_name")).length()>0) return parseNull(rs.value("lang_5_name"));
		return "";
	}

	public int minimumStockEmail(Set rs, Dictionary dictionary, String to, String lang, String langId ,String siteId, String siteName)
	{
		try
		{
			if(to.length() == 0)
			{
				System.out.println("SendMail::ERROR::No recipients");
				return NO_RECIPIENT;
			}

			String subject = dictionary.getTranslation(lang, "Minimum Stock Threshold Alert");
			
			if(to.length() > 0)
			{
				MimeMessage message = new MimeMessage(session);

				System.out.println("Adding recipient : " + to);
				
				String content = "";
				
				content += dictionary.getTranslation(lang, "Dear "+to) + "<br><br>";
				content += dictionary.getTranslation(lang, "We have reached the minimum stock threshold for certain products in our inventory.") + "<br><br>";
				
				int counter = 1;
				content += dictionary.getTranslation(lang, "Site Name")+": <strong>"+siteName+"</strong>" + "<br></br>";

				while(rs.next())
				{
					if(parseNull(rs.value("stock_thresh")).equals("0") || parseNull(rs.value("stock_thresh")).length() == 0) continue;

					if(counter == 1){
						content +="<table style='border:1px solid black;border-collapse:collapse;'><thead><tr><th style='border:1px solid black;'>"+dictionary.getTranslation(lang,"Product Name")+"</th><th style='border:1px solid black;'>"+dictionary.getTranslation(lang,"Catalog Name")+"</th><th style='border:1px solid black;'>"+dictionary.getTranslation(lang,"Current Stock")+"</th><th style='border:1px solid black;'>"+dictionary.getTranslation(lang,"Minimum Thresh")+"</th></tr></thead><tbody>";
					}
					content += "<tr>" ;
					content += "<td style='border:1px solid black;' >" +dictionary.getTranslation(lang, (parseNull(rs.value("lang_"+langId+"_name")).length()>0) ? parseNull(rs.value("lang_"+langId+"_name")) : getProductName(rs)) + "</td>";
					content += "<td style='border:1px solid black;' >" +parseNull(rs.value("catalog_name"))+"</td>";
					content += "<td style='border:1px solid black;' >" +parseNull(rs.value("stock"))+"</td>";
					content += "<td style='border:1px solid black;' >" +parseNull(rs.value("stock_thresh"))+ "</td>";
					content += "</tr>";
					if(counter == rs.rs.Rows) content += "</tbody></table>";
					counter++;
				}

				message = getMessage(env.getProperty("MAIL_FROM"), parseNull(env.getProperty("MAIL_FROM_DISPLAY_NAME")), env.getProperty("MAIL_REPLY"), to, subject, content);
				
				if(counter > 1) 
					Transport.send(message);
				else
					return 0;
					
				System.out.println("minimumStockThreshold: Email sent to : "+to);
			}
			
			return 1;
		}
		catch( Exception e )
		{
			e.printStackTrace();
			System.out.println(e.getMessage());
			if( debug) System.out.println("minimumStockEmail: Stock Threshold email not sent : client id :"+to);
			return(NO_CONNECTION);
		}
	}


	public int forgotPasswordAdmin( Set rs, Dictionary dictionary, String dbname, String forgotpassurl )
	{
		try
		{
			String to = parseNull(rs.value("e_mail"));

			if(to.length() == 0)
			{
				System.out.println("SendMail::ERROR::No recipients");
				return NO_RECIPIENT;
			}
			if(forgotpassurl.startsWith("/") == false) forgotpassurl = "/" + forgotpassurl;

			String token = java.util.UUID.randomUUID().toString();
			Set rsP = etn.execute("select * from "+dbname+"person where person_id = " + escape.cote(rs.value("person_id")));
			rsP.next();
			String referrer = parseNull(rsP.value("forgot_password_referrer"));
			if(referrer.endsWith("/")) referrer = referrer.substring(0, referrer.lastIndexOf("/"));

			etn.executeCmd("update "+dbname+"person set forgot_pass_token = "+escape.cote(token)+", forgot_pass_token_expiry = adddate(now(), interval 3 hour) where person_id = " + escape.cote(rs.value("person_id")));

			String lang = parseNull(env.getProperty("default_admin_user_lang"));
			String langId = "0";
			Set rsL = etn.execute("select * from "+dbname+"login where pid = "+ escape.cote(rs.value("person_id")));
			if(rsL.next()) langId = parseNull(rsL.value("language"));
			if(langId.equals("0") == false && langId.length() > 0)
			{
				rsL = etn.execute("select * From "+dbname+"language where langue_id = "+escape.cote(langId));
				if(rsL.next()) lang = parseNull(rsL.value("langue_code"));
			}
			if(lang.length() == 0) lang = parseNull(env.getProperty("default_admin_user_lang"));
			//double check
			if(lang.length() == 0) lang = "en";
			System.out.println("forgotPasswordAdmin:lang:"+lang);

			String url = referrer + forgotpassurl + "?t="+token;
			String subject = dictionary.getTranslation(lang, "Forgot Password");
			if(to.length() > 0)
			{
				MimeMessage message = new MimeMessage(session);

				message.setFrom(new InternetAddress(env.getProperty("MAIL_FROM"), parseNull(env.getProperty("MAIL_FROM_DISPLAY_NAME"))));
				message.setReplyTo(new InternetAddress[] { new InternetAddress(env.getProperty("MAIL_REPLY"))});

				System.out.println("Adding recipient : " + to);
				message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));

				message.setSubject(subject);

				String emailBody = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'><html><head><meta http-equiv='content-type' content='text/html;charset=UTF-8'></head>";
				emailBody += "<body bgcolor='#ffffff' text='#000000'>";
				emailBody += "<div>";
				emailBody += dictionary.getTranslation(lang, "Dear")+" " + parseNull(rsP.value("first_name")) + "<br><br>";
				emailBody += dictionary.getTranslation(lang, "Kindly click the following link in order to reset your password") + "<br><br>";
				emailBody += "<a href='"+url+"'>"+url+"</a><br>";
				emailBody += "<div style='color:red'>" + dictionary.getTranslation(lang, "Above link will expire in 3 hours")  + "</div>";
				emailBody += "</div>";
				emailBody += "</body>";
				emailBody += "</html>";
				message.setContent(emailBody, "text/html; charset=utf-8");
//				message.setText(emailBody);

				Transport.send(message);
				System.out.println("forgotPasswordAdmin: Email sent to : "+rs.value("e_mail") );
			}
			return 1;
		}
		catch( Exception e )
		{
			e.printStackTrace();
			System.out.println(e.getMessage());
			if( debug) System.out.println("forgotPasswordAdmin: Forgot pass email not sent : client id :"+rs.value("id"));
			return(NO_CONNECTION);
		}
	}

	public static String getGoogleAuthenticatorBarCode(String secretKey, String account, String issuer) {
		try {
			return "otpauth://totp/"
					+ URLEncoder.encode(issuer + ":" + account, "UTF-8").replace("+", "%20")
					+ "?secret=" + URLEncoder.encode(secretKey, "UTF-8").replace("+", "%20")
					+ "&issuer=" + URLEncoder.encode(issuer, "UTF-8").replace("+", "%20");
		} catch (UnsupportedEncodingException e) {
			throw new IllegalStateException(e);
		}
	}

	public static void createQRCode(String barCodeData, String filePath, int height, int width)
        throws WriterException, IOException {
		BitMatrix matrix = new MultiFormatWriter().encode(barCodeData, BarcodeFormat.QR_CODE,width, height);
		try (FileOutputStream out = new FileOutputStream(filePath)) {
			MatrixToImageWriter.writeToStream(matrix, "png", out);
		}
		
	}

	

	public int qrCodeEmail( Set rs, String appName, String lang, Dictionary dictionary )
	{
		try
		{
			String to = parseNull(rs.value("email"));
			String secretKey = parseNull(rs.value("secret_key"));
			String barCodeUrl = getGoogleAuthenticatorBarCode(secretKey, to, appName);
			String dir = parseNull(env.getProperty("qrcodes_dir"));
			String filepath=dir+appName.replaceAll(" ","")+"/";
			
			MimeMultipart _multipart = new MimeMultipart("related");

			File qrDir = new File(filepath);
			if(!qrDir.exists()){
				qrDir.mkdirs();
			}

			filepath+=parseNull(rs.value("name"))+".png";

			createQRCode(barCodeUrl,filepath,200,200);

			if(to.length() == 0)
			{
				System.out.println("SendMail::ERROR::No recipients");
				return NO_RECIPIENT;
			}
			
			String subject = dictionary.getTranslation(lang, appName + " two factor authentication");
			if(to.length() > 0)
			{
				MimeMessage message = new MimeMessage(session);

				message.setFrom(new InternetAddress(env.getProperty("MAIL_FROM"), parseNull(env.getProperty("MAIL_FROM_DISPLAY_NAME"))));
				message.setReplyTo(new InternetAddress[] { new InternetAddress(env.getProperty("MAIL_REPLY"))});

				System.out.println("Adding recipient : " + to);
				message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));

				message.setSubject(subject);

				String messageBodyHtml = "<div>"+dictionary.getTranslation(lang, "Dear")+" "+rs.value("first_name")+",</div>";
				messageBodyHtml += "<br>";
				messageBodyHtml += "<div>"+dictionary.getTranslation(lang, "Two factor authentication is now enabled for your account.")+"</div>";
				messageBodyHtml += "<div>"+dictionary.getTranslation(lang, "Scan the attached QR code using the Google authenticator app and use the TOTP shown in the app for login.")+"</div>";
				messageBodyHtml += "<br><br>";
				messageBodyHtml += "<div>"+dictionary.getTranslation(lang, "To download the Google authenticator app use the following links")+"</div>";
				messageBodyHtml += "<div>"+dictionary.getTranslation(lang, "For Android")+" <a href='https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&pli=1'>"+dictionary.getTranslation(lang, "click here")+"</a></div>";
				messageBodyHtml += "<div>"+dictionary.getTranslation(lang, "For iOS")+" <a href='https://apps.apple.com/us/app/google-authenticator/id388497605'>"+dictionary.getTranslation(lang, "click here")+"</a></div>";
				messageBodyHtml += "<br><br>";
				BodyPart htmlPart = new MimeBodyPart();
				htmlPart.setContent( messageBodyHtml, "text/html; charset=utf-8" );
				_multipart.addBodyPart(htmlPart);
	
				BodyPart messageBodyPart = new MimeBodyPart();
            	DataSource source = new FileDataSource(filepath);
				messageBodyPart.setDataHandler(new DataHandler(source));
				messageBodyPart.setHeader("Content-ID", "<image>");
				messageBodyPart.setFileName("QrCode.png");
				_multipart.addBodyPart(messageBodyPart);
				message.setContent(_multipart);

				Transport.send(message);

				File file = new File(filepath);
				if(file.exists()){
					file.delete();
                }
				
				System.out.println("TwoFactorAuthentication: Email sent to : "+rs.value("email") );
			}
			return 1;
		}
		catch( Exception e )
		{
			e.printStackTrace();
			System.out.println(e.getMessage());
			if( debug) System.out.println("TwoFactorAuthentication: 2FA email not sent : person id :"+rs.value("id"));
			return(NO_CONNECTION);
		}
	}

	public int userVerificationEmail( Set rs, boolean isprod, Dictionary dictionary  )
	{
		try
		{
			String to = parseNull(rs.value("email"));

			if(to.length() == 0)
			{
				System.out.println("SendMail::ERROR::No recipients");
				return NO_RECIPIENT;
			}

			String menuUuid = parseNull(rs.value("signup_menu_uuid"));
			String dbname = "";
			String verifyurl = env.getProperty("USER_VERIFICATION_URL");
			if(isprod)
			{
				dbname = parseNull(env.getProperty("PROD_DB")) + ".";
				verifyurl = env.getProperty("PROD_USER_VERIFICATION_URL");
			}

			String lang = "";
			Set rsm = etn.execute("select * from "+dbname+"site_menus where menu_uuid= "+ escape.cote(menuUuid));
			if(rsm.next()) lang = parseNull(rsm.value("lang"));

			String token = java.util.UUID.randomUUID().toString();
			etn.executeCmd("update "+dbname+"clients set verification_token = "+escape.cote(token)+", verification_token_expiry = adddate(now(), interval 24 hour) where id = " + rs.value("id"));

			String url = verifyurl + "?t="+token+"&muid="+parseNull(rs.value("signup_menu_uuid"));

			String subject = dictionary.getTranslation(lang, "Account verification");
			if(to.length() > 0)
			{
				MimeMessage message = new MimeMessage(session);

				message.setFrom(new InternetAddress(env.getProperty("MAIL_FROM"), parseNull(env.getProperty("MAIL_FROM_DISPLAY_NAME"))));
				message.setReplyTo(new InternetAddress[] { new InternetAddress(env.getProperty("MAIL_REPLY"))});

				System.out.println("Adding recipient : " + to);
				message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));

				message.setSubject(subject);

				String emailBody = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'><html><head><meta http-equiv='content-type' content='text/html;charset=UTF-8'></head>";
				emailBody += "<body bgcolor='#ffffff' text='#000000'>";
				emailBody += "<div>";
				emailBody += dictionary.getTranslation(lang, "Dear") + " " + rs.value("name") + "," + "<br><br>";
				emailBody += dictionary.getTranslation(lang, "Kindly click the following link in order to verify your account")  + "<br><br>";
				emailBody += "<a href='"+url+"'>"+url+"</a><br>";
				emailBody += "<div style='color:red'>" + dictionary.getTranslation(lang, "Above link will expire in 24 hours")  + "</div>";
				emailBody += "</div>";
				emailBody += "</body>";
				emailBody += "</html>";
				message.setContent(emailBody, "text/html; charset=utf-8");
//				message.setText(emailBody);

				Transport.send(message);
				System.out.println("ISPROD:"+isprod+" Email sent to client ID : "+rs.value("id") );
			}

			return 1;
		}
		catch( Exception e )
		{
			e.printStackTrace();
			System.out.println(e.getMessage());
			if( debug) System.out.println("ISPROD:"+isprod+" verification email not sent : client id :"+rs.value("id"));
			return(NO_CONNECTION);
		}

	}

	public static void main( String a[] ) throws Exception
	{
		Properties p = new Properties();
		p.load( SendMail.class.getResourceAsStream("Scheduler.conf") );

		com.etn.Client.Impl.ClientDedie etn = new com.etn.Client.Impl.ClientDedie( "MySql", "org.mariadb.jdbc.Driver", p.getProperty("CONNECT"));
		System.out.println("------ in contact us mail");
		SendMail sm = new SendMail(etn , p );
		Dictionary dict = new Dictionary(etn , p );

		Set rs = etn.execute("select * from  clients limit 1 ");
		rs.next();
		sm.forgotPassword(rs, false, dict);
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
