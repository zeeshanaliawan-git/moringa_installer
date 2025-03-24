package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.util.Properties;
import java.util.Random;
import java.util.List;
import java.util.ArrayList;
import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.ByteArrayOutputStream;
import java.util.Map;
import java.util.HashMap;

/** 
 * Must be extended.
*/
public class AsiminaClientForgotPassword extends OtherAction 
{ 

	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		return execute(wkid, clid, param);
	}

	public int execute( int wkid , String clid, String param )
	{ 
		System.out.println("Sql wid:"+wkid+" cl:"+clid+" parm:"+param);
		if( param.equalsIgnoreCase("clientforgotpassword") )
		{
			return clientForgotPassword(wkid, clid);
		}
		else
		{
			System.out.println("Function not supported");
			return -1;
		}
	}
	
	private int clientForgotPassword(int wkid, String clid)
	{
		int retVal = 0;
		try
		{			
			System.out.println("in clientForgotPassword");
			System.out.println("wkid:"+wkid);
			System.out.println("clid:"+clid);

			Set rsS = etn.execute("SELECT form_table_name FROM post_work WHERE id = " + escape.cote(wkid+""));
			if(rsS.next())
			{
				String tableName = Util.parseNull(rsS.value("form_table_name"));
				System.out.println("tableName:"+tableName);
				Set tableRs = etn.execute("SELECT ct.*, pf.site_id, pf.is_email_cust FROM " + tableName + " ct, process_forms pf WHERE ct.form_id = pf.form_id and " + tableName + "_id = " + escape.cote(clid));

				if(tableRs.next()){

					String formId = Util.parseNull(tableRs.value("form_id"));
					String siteId = Util.parseNull(tableRs.value("site_id"));
					boolean isProd = false;
					String portalUrl = Util.parseNull(tableRs.value("portalurl"));
					String dbname = env.getProperty("PROD_PORTAL_DB");
					
					String email = Util.parseNull(tableRs.value("_etn_email"));
					String username = Util.parseNull(tableRs.value("_etn_login"));
					
					String password = Util.parseNull(tableRs.value("_etn_password"));
					String forgotPasswordMenuId = Util.parseNull(tableRs.value("mid"));
					String isMailFormCustomer = Util.parseNull(tableRs.value("is_email_cust"));

					System.out.println("siteId:" + siteId  + " dbname:" + dbname + " password:" + password + " username: "+username + " email : "+email);

					if(portalUrl.toLowerCase().contains("_portal")) dbname = env.getProperty("PORTAL_DB");						
					if(isMailFormCustomer.length() == 0)
						isMailFormCustomer = "0";

					String forgotPasswordMenuUuid = "";

					if(forgotPasswordMenuId.length() == 0){

						Set _rsM = etn.execute("select 0 as seq, sm.id, lang, site_id, menu_uuid from language l, " + dbname + ".site_menus sm where l.langue_code = sm.lang and l.langue_id = 1 and sm.is_active = 1 and sm.site_id = " + escape.cote(siteId) + " UNION select 1 as seq, id, lang, site_id, menu_uuid from " + dbname + ".site_menus sm where sm.is_active = 1 and sm.site_id = " + escape.cote(siteId) + "  order by seq, id");

						if(_rsM.next()) forgotPasswordMenuUuid = Util.parseNull(_rsM.value("menu_uuid"));

					} else {

						Set _rsM = etn.execute("select * from "+dbname+".site_menus where id="+escape.cote(forgotPasswordMenuId));
						if(_rsM.next()) forgotPasswordMenuUuid = Util.parseNull(_rsM.value("menu_uuid"));

					}

					if(forgotPasswordMenuUuid.length() == 0) 
					{
						System.out.println("GRAVE:: menu uuid is not found");
					}
					
					Set _rsPortalConfig = etn.execute("select * from "+dbname+".config where code = 'EXTERNAL_LINK' ");
					_rsPortalConfig.next();
					String _portalUrl = Util.parseNull(_rsPortalConfig.value("val"));
					
					String whereclause = "";
					if(email.length() > 0) whereclause += " and email = "+escape.cote(email);
					if(username.length() > 0) whereclause += " and username = "+escape.cote(username);
					System.out.println("select * from "+dbname+".clients where site_id = " + escape.cote(siteId) + whereclause);
					Set rs = etn.execute("select * from "+dbname+".clients where site_id = " + escape.cote(siteId) + whereclause);
					if(rs.rs.Rows == 0)
					{
						System.out.println("User didn't exists in clients table");				
						etn.execute("UPDATE post_work SET errcode = " + escape.cote("20") + ", errMessage = " + escape.cote("User didn't exists.") + " WHERE id = " + escape.cote(wkid+""));
					}
					else
					{
						rs.next();
						String clientid = rs.value("id");
						username = rs.value("username");
						email = rs.value("email");
						System.out.println("clientid : " + clientid + " username : " + username + " email : "+ email);
						String sendEmailVerification = "1";
						String verificationToken = java.util.UUID.randomUUID().toString();

						if(isMailFormCustomer.equals("1")){

							sendEmailVerification = "0";
							String domain = "";
							Set sitesRs = etn.execute("select domain from " + dbname + ".sites where id = " + escape.cote(siteId));
							
							if(sitesRs.next()){

								domain = Util.parseNull(sitesRs.value("domain"));

								if(domain.substring(0,domain.length()-1).equals("/"))
									domain = domain.substring(0,domain.length()-1);
							}

							etn.execute("UPDATE post_work SET errcode = " + escape.cote("0") + " WHERE id = " + escape.cote(wkid+""));

							etn.execute("update " + tableName + " set _etn_forgotpassword_link = " + escape.cote(domain + _portalUrl + "pages/resetpass.jsp?t=" + verificationToken + "&muid=" + forgotPasswordMenuUuid) + " WHERE " + tableName + "_id = " + escape.cote(clid));
							etn.executeCmd("update " + tableName + " set _etn_email = "+escape.cote(email)+" where "+ tableName + "_id = " + escape.cote(clid));
						}
						
						etn.executeCmd("update "+dbname+".clients set forgot_pass_token = "+escape.cote(verificationToken)+", forgot_password = " + escape.cote(sendEmailVerification) + ", forgot_pass_muid = " + escape.cote(forgotPasswordMenuUuid) + ", forgot_pass_token_expiry = adddate(now(), interval 3 hour) where site_id = " + siteId + " and id = " + escape.cote(clientid));
					}
				}
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}

		if(retVal == 0 || retVal == 20)
		{
			((Scheduler)env.get("sched")).endJob( wkid , clid );			
		}
		return retVal;
	}
	
}
