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
import com.etn.asimina.authentication.AsiminaAuthentication;
import com.etn.asimina.authentication.AsiminaAuthenticationHelper;
import com.etn.asimina.authentication.AsiminaAuthenticationResponse;

/** 
 * Must be extended.
*/
public class AsiminaClient extends OtherAction 
{ 

	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		return execute(wkid, clid, param);
	}

	public int execute( int wkid , String clid, String param )
	{ 
		System.out.println("Sql wid:"+wkid+" cl:"+clid+" parm:"+param);
		if( param.equalsIgnoreCase("create") )
		{
			return createClient(wkid, clid);
		}
		else
		{
			System.out.println("Function not supported");
			return -1;
		}
	}

	String resizeImage(InputStream input, int width, int height, String ofilename) throws IOException 
	{
        BufferedImage originalImage = ImageIO.read(input);
		
        // get file extension
        String fileExtension = ofilename.substring(ofilename.lastIndexOf(".") + 1);
		String s1 = "data:image/jpeg;base64,";
		int iType = BufferedImage.TYPE_INT_RGB;
		if(fileExtension.toLowerCase().equals(".png")) 
		{
			s1 = "data:image/png;base64,";
			iType = BufferedImage.TYPE_INT_ARGB;
		}
		
        BufferedImage newResizedImage = new BufferedImage(width, height, iType);
        Graphics2D g = newResizedImage.createGraphics();

        g.setBackground(Color.WHITE);
        g.setPaint(Color.WHITE);

        // background transparent
        //g.setComposite(AlphaComposite.Src);
        g.fillRect(0, 0, width, height);

        /* try addRenderingHints()
        // VALUE_RENDER_DEFAULT = good tradeoff of performance vs quality
        // VALUE_RENDER_SPEED   = prefer speed
        // VALUE_RENDER_QUALITY = prefer quality
        g.setRenderingHint(RenderingHints.KEY_RENDERING,
                              RenderingHints.VALUE_RENDER_QUALITY);

        // controls how image pixels are filtered or resampled
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
                              RenderingHints.VALUE_INTERPOLATION_BILINEAR);

        // antialiasing, on
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
                              RenderingHints.VALUE_ANTIALIAS_ON);*/

        Map<RenderingHints.Key,Object> hints = new HashMap<>();
        hints.put(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        hints.put(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        hints.put(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.addRenderingHints(hints);

        // puts the original image into the newResizedImage
        g.drawImage(originalImage, 0, 0, width, height, null);
        g.dispose();

		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		ImageIO.write(newResizedImage, fileExtension, baos);
		byte[] bytes = baos.toByteArray();		
		
		return s1 + com.etn.util.Base64.encode(bytes);
    }
	
	private int createClient(int wkid, String clid)
	{
		int retVal = 0;
		try
		{
			
		
			List<String> ignoreColumns = new ArrayList<String>();

			ignoreColumns.add("SITE_ID");
			ignoreColumns.add("SIGN_UP_SSP5_ID");
			ignoreColumns.add("RULE_ID");
			ignoreColumns.add("FORM_ID");
			ignoreColumns.add("CREATED_ON");
			ignoreColumns.add("CREATED_BY");
			ignoreColumns.add("UPDATED_ON");
			ignoreColumns.add("UPDATED_BY");
			ignoreColumns.add("LASTID");
			ignoreColumns.add("MENU_LANG");
			ignoreColumns.add("MID");
			ignoreColumns.add("PORTALURL");
			ignoreColumns.add("USERIP");
			ignoreColumns.add("IS_ADMIN");
			ignoreColumns.add("_ETN_LOGIN");
			ignoreColumns.add("_ETN_PASSWORD");
			ignoreColumns.add("_ETN_AVATAR");
			ignoreColumns.add("_ETN_FIRST_NAME");
			ignoreColumns.add("_ETN_LAST_NAME");
			ignoreColumns.add("MENU_LANG");
			ignoreColumns.add("_ETN_EMAIL");
			ignoreColumns.add("_ETN_CIVILITY");
			ignoreColumns.add("_ETN_MOBILE_PHONE");
			ignoreColumns.add("_ETN_AGREEMENT");
			ignoreColumns.add("_ETN_CONFIRMATION_LINK");
			ignoreColumns.add("IS_EMAIL_CUST");
			
			

			System.out.println("in createClient");
			Set rsS = etn.execute("SELECT form_table_name FROM post_work WHERE id = " + escape.cote(wkid+""));
			if(rsS.next())
			{
				String tableName = Util.parseNull(rsS.value("form_table_name"));
				ignoreColumns.add((tableName +  "_id").toUpperCase());
				
				Set tableRs = etn.execute("SELECT ct.*, pf.site_id, pf.is_email_cust FROM " + tableName + " ct, process_forms pf WHERE ct.form_id = pf.form_id and " + tableName + "_id = " + escape.cote(clid));
				String[] additionalColumns = tableRs.ColName;
				String fileName = "";
				String formId = "";
				String path = "";
				String imgBase64 = "";
				String gender = "";

				if(tableRs.next()){

					formId = Util.parseNull(tableRs.value("form_id"));
					fileName = Util.parseNull(tableRs.value("_etn_avatar"));
					gender = Util.parseNull(tableRs.value("_etn_civility"));
					path = "";

					if(fileName.length() > 0){

						path = env.getProperty("FORM_UPLOADS_ROOT_PATH") + formId + "/" + clid + "/"+ fileName;
	                	InputStream fis = new FileInputStream(path);
						
						int _width = 36;
						int _height = 36;
						if(Util.parseNull(env.getProperty("AVATAR_WIDTH")).length() > 0 && Util.parseNull(env.getProperty("AVATAR_HEIGHT")).length() > 0)
						{
							try 
							{
								_width = Integer.parseInt(Util.parseNull(env.getProperty("AVATAR_WIDTH")));
								_height = Integer.parseInt(Util.parseNull(env.getProperty("AVATAR_HEIGHT")));
							} 
							catch(Exception _ex)
							{
								_ex.printStackTrace();
								_width = 36;
								_height = 36;
							}
						}
						
	                	imgBase64 = resizeImage(fis, _width, _height, fileName);
					
					} else {

						if( gender.equalsIgnoreCase("Mr.") ){

							imgBase64 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAYAAAA6/NlyAAAACXBIWXMAAAsTAAALEwEAmpwYAAAF0WlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDIgNzkuMTYwOTI0LCAyMDE3LzA3LzEzLTAxOjA2OjM5ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIwLTA5LTIzVDEzOjA0OjQzKzAyOjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDIwLTA5LTIzVDEzOjA0OjQzKzAyOjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMC0wOS0yM1QxMzowNDo0MyswMjowMCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo5NTU1NTllYi02NWM1LWQzNGMtODgwNS0xNDQ2MDM4Y2M1YzUiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDoxMDIwMWViZC04MWExLTBkNDEtODhj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";


						} else {

                            imgBase64 = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAYAAAA6/NlyAAAACXBIWXMAAAsTAAALEwEAmpwYAAAF0WlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDIgNzkuMTYwOTI0LCAyMDE3LzA3LzEzLTAxOjA2OjM5ICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLmNvbS9waG90b3Nob3AvMS4wLyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ0MgMjAxOCAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDIwLTA5LTIzVDEzOjA2OjE5KzAyOjAwIiB4bXA6TWV0YWRhdGFEYXRlPSIyMDIwLTA5LTIzVDEzOjA2OjE5KzAyOjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyMC0wOS0yM1QxMzowNjoxOSswMjowMCIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDo2ODg5OTRiNC05MmE5LWQ1NGItYTJjMy1lMDNhZjVkOTcyOTAiIHhtcE1NOkRvY3VtZW50SUQ9ImFkb2JlOmRvY2lkOnBob3Rvc2hvcDpiN2NkN2I0NS0wY2FjLWExNDEtYmQ4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";

						}

					}

					String additionalColumnValueJson = "";					
					for(int i=0; i<additionalColumns.length; i++){	

						if(ignoreColumns.contains(additionalColumns[i]))
							continue; 

						additionalColumnValueJson += "\"" + additionalColumns[i].toLowerCase() + "\":\"" + Util.parseNull(tableRs.value(additionalColumns[i])) + "\",";
					}


					if(additionalColumnValueJson.length() > 0)
						additionalColumnValueJson = "{" + additionalColumnValueJson.substring(0, additionalColumnValueJson.length()-1) + "}";

					String siteId = Util.parseNull(tableRs.value("site_id"));
					String isAdmin = Util.parseNull(tableRs.value("is_admin"));
					boolean isProd = false;
					String portalUrl = Util.parseNull(tableRs.value("portalurl"));
					String dbname = env.getProperty("PROD_PORTAL_DB");
					String username = Util.parseNull(tableRs.value("_etn_login"));
					String password = Util.parseNull(tableRs.value("_etn_password"));
					String isMailFormCustomer = Util.parseNull(tableRs.value("is_email_cust"));
					String signupMenuId = Util.parseNull(tableRs.value("mid"));
					
					System.out.println("siteId:" + siteId  + " dbname:" + dbname + " password:" + password);
					
					
					
//					String dbname = "dev_portal";//will update the prod value before commit

					if(isMailFormCustomer.length() == 0)
						isMailFormCustomer = "0";

					if(username.length() == 0){

						username = Util.parseNull(tableRs.value("_etn_email"));
					}
					System.out.println("PortalUrl: " + portalUrl);
					if(portalUrl.toLowerCase().contains("_portal")) dbname = env.getProperty("PORTAL_DB");						
					if("1".equals(isAdmin)) dbname = env.getProperty("PROD_PORTAL_DB");
					
					AsiminaAuthenticationHelper asiminaAuthenticationHelper = new AsiminaAuthenticationHelper(etn,siteId,dbname,env.getProperty("CLIENT_PASS_SALT"));
					AsiminaAuthentication asiminaAuthentication = asiminaAuthenticationHelper.getAuthenticationObject();
					
					String signupMenuUuid = "";

					if(signupMenuId.length() == 0){

						Set _rsM = etn.execute("select 0 as seq, sm.id, lang, site_id, menu_uuid from language l, " + dbname + ".site_menus sm where l.langue_code = sm.lang and l.langue_id = 1 and sm.is_active = 1 and sm.site_id = " + escape.cote(siteId) + " UNION select 1 as seq, id, lang, site_id, menu_uuid from " + dbname + ".site_menus sm where sm.is_active = 1 and sm.site_id = " + escape.cote(siteId) + "  order by seq, id");

						if(_rsM.next()) signupMenuUuid = Util.parseNull(_rsM.value("menu_uuid"));

					} else {

						Set _rsM = etn.execute("select * from "+dbname+".site_menus where id="+escape.cote(signupMenuId));
						if(_rsM.next()) signupMenuUuid = Util.parseNull(_rsM.value("menu_uuid"));
					}

					if(signupMenuUuid.length() == 0) 
					{
						System.out.println("GRAVE:: menu uuid is not found");
					}
					
					Set _rsPortalConfig = etn.execute("select * from "+dbname+".config where code = 'EXTERNAL_LINK' ");
					_rsPortalConfig.next();
					String _portalUrl = Util.parseNull(_rsPortalConfig.value("val"));

					Set rs = etn.execute("select * from "+dbname+".clients where site_id = " + escape.cote(siteId) + " and username = " + escape.cote(username));
					if(rs.rs.Rows > 0)
					{
						System.out.println("User already exists in clients table");				
						etn.execute("UPDATE post_work SET errcode = " + escape.cote("20") + ", errMessage = " + escape.cote("User already exists.") + " WHERE id = " + escape.cote(wkid+""));
					}
					else
					{

						String sendEmailVerification = "1";
						String verificationToken = java.util.UUID.randomUUID().toString();

						if(username.length() > 0){

							if(isMailFormCustomer.equals("1")){

								sendEmailVerification = "0";
								String domain = "";
								Set sitesRs = etn.execute("select domain from " + dbname + ".sites where id = " + escape.cote(siteId));
								System.out.println("select domain from " + dbname + ".sites where id = " + escape.cote(siteId));
								if(sitesRs.next()){

									domain = Util.parseNull(sitesRs.value("domain"));

									if(domain.length() > 0) {

										if(domain.substring(0,domain.length()-1).equals("/"))
											domain = domain.substring(0,domain.length()-1);
									} else{

										System.out.println("Domain is not assigned in sites table.");
									}
								}

								etn.execute("UPDATE post_work SET errcode = " + escape.cote("10") + " WHERE id = " + escape.cote(wkid+""));
		
								if(asiminaAuthenticationHelper.isDefaultAuthentication()){
									etn.execute("update " + tableName + " set _etn_confirmation_link = " + escape.cote(domain + _portalUrl + "pages/verify.jsp?t=" + verificationToken + "&muid=" + signupMenuUuid) + " WHERE " + tableName + "_id = " + escape.cote(clid));
								}
							}
/*
							//remove send email fields
							int i = etn.executeCmd("insert into "+dbname+".clients (username, email, name, surname, mobile_number, is_verified, created_date, client_uuid, site_id, signup_menu_uuid, additional_info, avatar, civility) "+
										" values ("+escape.cote(username)+", "+escape.cote(Util.parseNull(tableRs.value("_etn_email")))+", "+escape.cote(Util.parseNull(tableRs.value("_etn_first_name")))+", "+escape.cote(Util.parseNull(tableRs.value("_etn_last_name")))+", "+escape.cote(Util.parseNull(tableRs.value("_etn_mobile_phone")))+", 0, now(), UUID(), " + escape.cote(Util.parseNull(siteId)) + ", " + escape.cote(signupMenuUuid) + ", " + escape.cote(additionalColumnValueJson) + ", " + escape.cote(imgBase64) + ", " + escape.cote(gender) + ") ");
*/

							AsiminaAuthenticationResponse asiminaAuthenticationResponse = 
								asiminaAuthentication.createUser(
									username,
									Util.parseNull(tableRs.value("_etn_email")),
									Util.parseNull(password),
									Util.parseNull(tableRs.value("_etn_first_name")),
									Util.parseNull(tableRs.value("_etn_last_name")),
									Util.parseNull(tableRs.value("_etn_last_name")) + ", " + Util.parseNull(tableRs.value("_etn_first_name")),
									Util.parseNull(tableRs.value("_etn_mobile_phone")),
									"0",
									signupMenuUuid,
									additionalColumnValueJson,
									imgBase64,
									gender,
									null,
									null,
									null,									
									false
								);
								
							if(asiminaAuthenticationResponse.isDone() == false){
								System.out.println("Error:" +  asiminaAuthenticationResponse.getMessage() + " " + asiminaAuthenticationResponse.getDescription());
							}

							if(asiminaAuthenticationHelper.isDefaultAuthentication() == false){
								AsiminaAuthentication defaultAsiminaAuthentication = asiminaAuthenticationHelper.getDefaultAuthenticationObject();
								defaultAsiminaAuthentication.createUser(
									username,
									Util.parseNull(tableRs.value("_etn_email")),
									Util.parseNull(password),
									Util.parseNull(tableRs.value("_etn_first_name")),
									Util.parseNull(tableRs.value("_etn_last_name")),
									Util.parseNull(tableRs.value("_etn_last_name")) + ", " + Util.parseNull(tableRs.value("_etn_first_name")),
									Util.parseNull(tableRs.value("_etn_mobile_phone")),
									"1",
									signupMenuUuid,
									additionalColumnValueJson,
									imgBase64,
									gender,
									null,
									null,
									null,									
									false
								);
							}

							if(asiminaAuthenticationResponse.isDone())
							{
								if(asiminaAuthenticationHelper.isDefaultAuthentication()){
									etn.executeCmd("update "+dbname+".clients set send_verification_email = " + escape.cote(sendEmailVerification) + ",verification_token = " + escape.cote(verificationToken) + ",form_row_id = " + escape.cote(clid) + ",verification_token_expiry = adddate(now(), interval 24 hour) where username = " + escape.cote(username) + " and site_id = " + escape.cote(Util.parseNull(siteId)));		
									System.out.println("update "+dbname+".clients set send_verification_email = " + escape.cote(sendEmailVerification) + ",verification_token = " + escape.cote(verificationToken) + ",form_row_id = " + escape.cote(clid) + ",verification_token_expiry = adddate(now(), interval 24 hour) where username = " + escape.cote(username) + " and site_id = " + escape.cote(Util.parseNull(siteId)));						
								}else{
									etn.executeCmd("update "+dbname+".clients set send_verification_email = 0, form_row_id = " + escape.cote(clid) + " where username = " + escape.cote(username) + " and site_id = " + escape.cote(Util.parseNull(siteId)));
									etn.execute("UPDATE post_work SET errcode = " + escape.cote("30") + " WHERE id = " + escape.cote(wkid+""));
								}
								etn.execute("select semfree("+escape.cote(env.getProperty("SELFCARE_SEMAPHORE"))+")");
							}
							else
							{

								etn.executeCmd("update "+dbname+".clients set send_verification_email = 0, form_row_id = " + escape.cote(clid) + " where username = " + escape.cote(username) + " and site_id = " + escape.cote(Util.parseNull(siteId)));
								etn.execute("UPDATE post_work SET errcode = " + escape.cote("30") + " WHERE id = " + escape.cote(wkid+""));

								System.out.println("Error while creating client");
								System.out.println(asiminaAuthenticationResponse.getMessage());
								System.out.println(asiminaAuthenticationResponse.getDescription());
								retVal = -2;
							}
						} else {

								System.out.println("Login name is mandatory.");
								retVal = -2;
						}
											
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
