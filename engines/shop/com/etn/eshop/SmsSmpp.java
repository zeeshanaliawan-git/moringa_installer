package com.etn.eshop;

import org.jsmpp.InvalidResponseException;
import org.jsmpp.PDUException;
import org.jsmpp.bean.Alphabet;
import org.jsmpp.bean.BindType;
import org.jsmpp.bean.ESMClass;
import org.jsmpp.bean.GeneralDataCoding;
import org.jsmpp.bean.MessageClass;
import org.jsmpp.bean.NumberingPlanIndicator;
import org.jsmpp.bean.RegisteredDelivery;
import org.jsmpp.bean.SMSCDeliveryReceipt;
import org.jsmpp.bean.TypeOfNumber;
import org.jsmpp.extra.NegativeResponseException;
import org.jsmpp.extra.ResponseTimeoutException;
import org.jsmpp.session.BindParameter;
import org.jsmpp.session.SMPPSession;
import org.jsmpp.util.TimeFormatter;
import org.jsmpp.util.AbsoluteTimeFormatter;
import org.jsmpp.session.SubmitSmResult;

import java.util.StringTokenizer;
import java.util.HashMap;
import java.util.Properties;
import java.util.Date;

import com.etn.sql.escape;
import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;


public class SmsSmpp extends OtherAction
{
	final int SUCCESS = 0;
	final int NO_SMSID = 100;
	final int NO_ROW = 200;
	final int NO_CONTACT = 300;
	final int SOME_EXCEPTION = 400;	
	final int NO_PHONE_NUMBER = 500;
	final int NO_MESSAGE_ID = 600;	
	final int MISSING_CONFIG = 700;	
	final int NO_CONNECTION = -1;	
	static final TimeFormatter TIME_FORMATTER = new AbsoluteTimeFormatter();
	
	public int init( ClientSql etn , Properties conf )
	{ 
		super.init(etn, conf);
		return (0);
	}

	private int indexOfEndName( String smstext , int pos)
	{
		int len = smstext.length();

		while( pos < len && ( Character.isLetterOrDigit( smstext.charAt(pos) ) || smstext.charAt(pos) == '_' ) ) pos++;

		if( pos >= len ) return(-1);
		return(pos);
	}

	private void log(String m)
	{
		System.out.println("SmsSmpp::" + m);
	}

	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		return execute(wkid, clid, param);
	}

	public int execute( int wkid , String clid, String param )
	{
		log("wid:"+wkid+" cl:"+clid+" parm:"+param);
		etn.setSeparateur(2, '\001', '\002');	
		return send(wkid, clid, param);
	}
	
	private int send(int wkid, String clid, String smsid)
	{
		int ret = NO_CONNECTION;
		try
		{
			Set rsSms = etn.execute("select * from sms where sms_id="+smsid );
			if( !rsSms.next() ) return( NO_SMSID );

			Set rsPostWorkSiteId = etn.execute("select o.site_id from post_work p inner join orders o on p.client_key = o.id where p.id ="+ escape.cote(wkid+""));
			rsPostWorkSiteId.next();

			String tracking_url="";
			Set rsSite = etn.execute("select domain from "+env.getProperty("PORTAL_DB")+".sites where id="+escape.cote(rsPostWorkSiteId.value("site_id")));
			if(rsSite.next()) tracking_url = rsSite.value(0)+env.getProperty("CART_URL")+"trackingInfo.jsp";

			log("------ TRACKING URL " + tracking_url);
			
			Set rs = etn.execute( 
			"select o.*, concat("+escape.cote(tracking_url)+",'?id=',o.parent_uuid,'&muid=',o.menu_uuid) as tracking_url from post_work p inner join orders o on p.client_key = o.id where p.id = "+wkid );
			if(!rs.next()) return(NO_ROW);
			
			String contactNumber = Util.parseNull(rs.value("contactPhoneNumber1"));
			if(contactNumber.length() == 0) return NO_PHONE_NUMBER;
			
			if(Util.parseNull(env.getProperty("sms.smpp.host")).length() == 0 ||
				Util.parseNull(env.getProperty("sms.smpp.port")).length() == 0 ||
				Util.parseNull(env.getProperty("sms.smpp.user")).length() == 0 ||
				Util.parseNull(env.getProperty("sms.smpp.password")).length() == 0)
				{
					ret = MISSING_CONFIG;
					return ret;
				}
			
			String lang = rs.value("lang");		
			String langId = "1";//default
			Set rsLang = etn.execute("select * from language where langue_code = "+escape.cote(lang));
			if(rsLang.next()) langId = rsLang.value("langue_id");
			
			log("lang id : " + langId + " code : " + lang);
			String smstxt = rsSms.value("texte");
			if(langId.equals("1") == false) smstxt = Util.parseNull(rsSms.value("lang_"+langId+"_texte"));
			if(smstxt.length() == 0)//no sms template defined for the language then fall back to the first lang sms text
			{
				smstxt = rsSms.value("texte");
			}
			log("SMS Template : " + smstxt);
			
			StringBuilder sb = new StringBuilder(1024);
			int i = 0, j = 0, k = 0, l = smstxt.length();

			while( j < l ) 
			{
				i= smstxt.indexOf("db",j);
				if( i != -1 ) 
				{ 
					sb.append( smstxt.substring(j,i)) ;
					k = indexOfEndName( smstxt , i+3 );
					if( k == -1 ) k = l;
					String s  = smstxt.substring(i+2,k );
					if( s.length()> 0 && ( s = rs.value(s) ) != null )
					{ 
						sb.append(s); j = k; 
					}
					else
					{ 
						sb.append("db");
						j = i+2 ;
					}
				}
				else 
				{ 
					sb.append(smstxt.substring(j));
					break;
				}
			}		
			log("Final SMS : " + sb.toString());
			return sendToSmsc(wkid , clid, contactNumber, sb.toString());
		}
		catch(Exception e)
		{
			e.printStackTrace();
			ret = SOME_EXCEPTION;
		}
		return ret;
	}
	
	private int sendToSmsc(int wkid, String clid, String phoneNumber, String smstxt)
	{
		log("In sendToSmsc");
		int ret = SUCCESS;
		SMPPSession session = null;
		try
		{
			session = new SMPPSession();
			
			String countryCode = Util.parseNull(env.getProperty("sms.smpp.country.code"));
			log("countryCode:"+countryCode);
			if(countryCode.length() > 0 && phoneNumber.startsWith(countryCode) == false)
			{
				//check phone number starts with country code otherwise append country code
				phoneNumber = countryCode + phoneNumber;
			}
			log("Send sms to " + phoneNumber);
			log("Connecting:"+env.getProperty("sms.smpp.host")+":"+env.getProperty("sms.smpp.port")+" user:"+env.getProperty("sms.smpp.user")+" pass:"+env.getProperty("sms.smpp.password"));
			String systemId = session.connectAndBind(env.getProperty("sms.smpp.host"), Util.parseNullInt(env.getProperty("sms.smpp.port")),
						new BindParameter(BindType.BIND_TX, env.getProperty("sms.smpp.user"), env.getProperty("sms.smpp.password"), "",
						TypeOfNumber.UNKNOWN, NumberingPlanIndicator.UNKNOWN, null));
						
			log("Connected with smsc id : " + systemId);
						
			SubmitSmResult result = session.submitShortMessage(null,
                    TypeOfNumber.UNKNOWN, NumberingPlanIndicator.UNKNOWN, env.getProperty("sms.smpp.sender"),
                    TypeOfNumber.UNKNOWN, NumberingPlanIndicator.UNKNOWN, phoneNumber,
                    new ESMClass(), (byte)0, (byte)1,  TIME_FORMATTER.format(new Date()), null,
                    new RegisteredDelivery(SMSCDeliveryReceipt.SUCCESS_FAILURE), (byte)0, new GeneralDataCoding(Alphabet.ALPHA_8_BIT, MessageClass.CLASS1, false), (byte)0, smstxt.getBytes("utf-8"));
			
			String messageId = result.getMessageId();
			log("Message submitted, message_id : " + messageId);
			if(messageId.length() > 0)
			{
				ret = SUCCESS;				
			}
			else
			{
				ret = NO_MESSAGE_ID;
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			ret = SOME_EXCEPTION;
		}
		finally
		{
			if(session != null) session.unbindAndClose();
		}
		return ret;
	}
	
	public static void main(String[] a) throws Exception
	{
		String testNumber = "+224622187878";
		String testMsg = "good morning. message de test avec un peu de français";
		if(a != null && a.length > 0)
		{
			testNumber = Util.parseNull(a[0]);
			if(a.length > 1) testMsg = Util.parseNull(a[1]);
		}
		Properties env = new Properties();
		env = new Properties();
		env.load(Scheduler.class.getResourceAsStream("Scheduler.conf")) ;

		ClientSql Etn = new com.etn.Client.Impl.ClientDedie(  "MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT") );

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
		SmsSmpp s = new SmsSmpp();
		s.init(Etn, env);
		System.out.println(s.sendToSmsc(0,"0",testNumber, testMsg));
	}
}
