package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import java.util.*;
import com.etn.sql.escape;
import java.lang.Process;
import java.io.*;
import org.jsoup.*;
import com.etn.util.Base64;
import com.etn.moringa.Crawler;
import com.etn.moringa.CacheUtil;
import com.etn.moringa.Util;


public class Publish extends OtherAction 
{
	final static int UC16Latin1ToAscii7[] = {
	'A','A','A','A','A','A','A','C',
	'E','E','E','E','I','I','I','I',
	'D','N','O','O','O','O','O','X',
	'0','U','U','U','U','Y','S','Y',
	'a','a','a','a','a','a','a','c',
	'e','e','e','e','i','i','i','i',
	'o','n','o','o','o','o','o','/', 
	'0','u','u','u','u','y','s','y' };

	private int toAscii7( int c )
	{ if( c < 0xc0 || c > 0xff )
		 return(c);
	  return( UC16Latin1ToAscii7[ c - 0xc0 ] );
	}

	private String ascii7( String  s )
	{
	  char c[] = s.toCharArray();
	  for( int i = 0 ; i < c.length ; i++ )
	   if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)toAscii7( c[i] );
	  return( new String( c ) );
	}


	public int execute( ClientSql etn, int wkid , String clid, String param )
	{			
		etn.setSeparateur(2, '\001', '\002');
		if("menu".equalsIgnoreCase(param)) return publishMenu(etn, wkid, clid);
		if("breadcrumbs".equalsIgnoreCase(param)) return refreshBreadcrumbs(etn, wkid, clid);
		return -1;
	}

	private String escapeCoteValue(String str) 
	{
		if (str != null && str.length() > 0) 
		{
	       	return str.replace("'", "&#39;").replace("\"", "&#34;").replace("<", "&lt;").replace(">", "&gt;");
		}
	       else 
		{
	       	return str;
		}
	}

	private String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
	
	private void log(String m)
	{
		System.out.println("Publish.java::"+m);
	}
	
	private String getMenuItemClass(String openas)
	{
		String _cls = "";

		if("new_window".equals(parseNull(openas)))
		{
			_cls = _cls + " o_menu_open_new_window ";					
		}
		else if("new_tab".equals(parseNull(openas)))
		{
			_cls = _cls + " o_menu_open_new_tab ";					
		}
		return _cls;
	}
	
	String getMenuDirection(ClientSql Etn, String lang)
	{
		String proddb = env.getProperty("PROD_DB");

		String menudirection = "";
		Set rsdr = Etn.execute("select * from "+proddb+".language where langue_code = " + escape.cote(lang));
		if(rsdr.next()) menudirection = parseNull(rsdr.value("direction"));
		if(menudirection.length() > 0) menudirection = " dir='"+menudirection+"' ";
		return menudirection;
	}

	private String getLogoUrl(String logourl, String homepageurl)
	{		
		if(logourl.length() == 0) logourl = homepageurl ;
		else
		{
			if(logourl.startsWith("http://") || logourl.startsWith("https://"))
			{
				logourl = logourl.replace("http:","").replace("https:","");
			}
			else logourl = "//" + logourl;
		}
		return logourl;
	}

	String generateHeader(ClientSql Etn, String menuid) throws Exception
	{
		String proddb = env.getProperty("PROD_DB") + ".";
				
		String menuresourcesurl = env.getProperty("PROD_MENU_RESOURCES_URL");
		String menuimagespath = env.getProperty("PROD_MENU_PHOTO_URL");
		
		Set rs = Etn.execute("select m.*, s.enable_ecommerce as s_enable_ecommerce, s.site_auth_enabled as site_auth_enabled from "+proddb+"site_menus m,"+proddb+"sites s where s.id = m.site_id and m.id = " + escape.cote(menuid));
		rs.next();
		String siteid = rs.value("site_id");

		if("1".equals(rs.value("hide_header"))) return "";

		boolean debug =  env.get("DEBUG")!=null || env.get("SCHED_DEBUG") != null;
		
		CacheUtil cacheUtil = new CacheUtil(env, true, debug);
		String cachedResourcesFolder = cacheUtil.getCachedResourcesUrl(Etn, menuid);
		
		String menuPublishPath = parseNull(env.getProperty("PROD_PUBLISHER_SEND_REDIRECT_LINK")) + cacheUtil.getMenuCacheFolder(Etn, menuid);		
		
		String homepageurl = cacheUtil.getExternalLink(parseNull(rs.value("prod_homepage_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);
		String mlang = parseNull(rs.value("lang"));
		String menuUuid = parseNull(rs.value("menu_uuid"));
		String logofile = parseNull(rs.value("logo_file"));
		if(logofile.length() > 0) logofile = menuimagespath + logofile;
//		else logofile = menuresourcesurl+"img/logo_002.png";

		String smalllogofile = parseNull(rs.value("small_logo_file"));
		if(smalllogofile.length() > 0) smalllogofile = menuimagespath + smalllogofile;
		else smalllogofile = logofile; 

		String logotext = parseNull(rs.value("logo_text"));

		String logourl = getLogoUrl(parseNull(rs.value("logo_url")), homepageurl);

		String menudirection = getMenuDirection(Etn, parseNull(rs.value("lang")));
		boolean showSearchBar = "1".equals(rs.value("show_search_bar"));
		String searchapi = parseNull(rs.value("search_api"));
		String searchbarlabel = parseNull(rs.value("search_bar_label"));

		boolean showLoginBar = ("1".equals(rs.value("show_login_bar")) || "1".equals(rs.value("site_auth_enabled")));
		//boolean menuauthenabled = "1".equals(rs.value("show_login_bar"));
		boolean enableCart = "1".equals(rs.value("enable_cart"));
		boolean enableECommerce = "1".equals(rs.value("s_enable_ecommerce"));
		if(!enableECommerce) enableCart = false;//if ecommerce is not enabled we will not show cart functionality will be disabled

		String loginButtonLabel = parseNull(rs.value("login_button_label"));
		String logoutButtonLabel = parseNull(rs.value("logout_button_label"));
		String forgotPasswordLabel = parseNull(rs.value("forgot_password_label"));
		String signUpLabel = parseNull(rs.value("sign_up_label"));

		String loginUsernameLabel = parseNull(rs.value("login_username_label"));
		String loginPasswordLabel = parseNull(rs.value("login_password_label"));

		String regurl = parseNull(rs.value("register_prod_url"));
		String forgotpassurl = parseNull(rs.value("forgot_pass_prod_url"));
		String myaccounturl = parseNull(rs.value("my_account_prod_url"));
        
		String defaultSize = parseNull(rs.value("default_size"));
		boolean animateOnScroll = "1".equals(parseNull(rs.value("animate_on_scroll")));
		boolean hideTopNav = "1".equals(parseNull(rs.value("hide_top_nav")));

		String signuplocation = env.getProperty("PROD_EXTERNAL_LINK")+"pages/signup.jsp?muid=" + menuUuid;
		String forgotpasslocation = env.getProperty("PROD_EXTERNAL_LINK")+"pages/forgotpassword.jsp?muid=" + menuUuid;
		String myaccountlocation = env.getProperty("PROD_EXTERNAL_LINK")+"pages/myaccount.jsp?muid=" + menuUuid;
		String changepassword = env.getProperty("PROD_EXTERNAL_LINK")+"pages/changepassword.jsp?muid=" + menuUuid;

		//if no url provided we will use portal registration page
		if(regurl.length() > 0) 
		{
			if(regurl.startsWith("http://127.0.0.1")) signuplocation = env.getProperty("PROD_EXTERNAL_LINK")+"process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+Base64.encode(regurl.getBytes("UTF-8"));
			else signuplocation = regurl;
		}
		if(forgotpassurl.length() > 0) 
		{
			if(forgotpassurl.startsWith("http://127.0.0.1")) forgotpasslocation = env.getProperty("PROD_EXTERNAL_LINK")+"process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+Base64.encode(forgotpassurl.getBytes("UTF-8"));
			else forgotpasslocation = forgotpassurl;
		}
		if(myaccounturl.length() > 0) 
		{
			if(myaccounturl.startsWith("http://127.0.0.1"))	myaccountlocation = env.getProperty("PROD_EXTERNAL_LINK")+"process.jsp?___mid="+Base64.encode(menuid.getBytes("UTF-8"))+"&___mu="+Base64.encode(myaccounturl.getBytes("UTF-8"));
			else myaccountlocation = myaccounturl; 
		}

		Set rsLang = Etn.execute("select * from "+proddb+"language where langue_code = " + escape.cote(mlang));
		rsLang.next();
		java.util.HashMap<String,String> dict = loadTranslations(Etn, rsLang.value("langue_id"));

		String m = "<div class='etnhf-MainOverlay'></div><header class=' __crawl__menu __menu_0 ' role='banner' "+menudirection+" id='etn-portal-header' data-default-size='" + defaultSize + "' data-animate-on-scroll='" + animateOnScroll + "' data-hide-top-nav='" + hideTopNav + "'>";
		m += "<nav role='navigation'>";

		Set rsm = null;
		Set rsl = null;
		if(hideTopNav == false)
		{
			//header level 1
			m += "<div class='etnhf-MenuTop'>";
			m += "<div class='etnhf-container'>";


			rsm = Etn.execute("select  * from "+proddb+"menu_items where display_in_header = 1 and is_right_align = 0 and menu_id = " + escape.cote(menuid) + " and menu_item_id = -30 order by coalesce(order_seq, 999999), id " );
			if(rsm.rs.Rows > 0)
			{
				m += "<div class='etnhf-MenuTop-blockLeft'>";
				m += "<ul class='etnhf-MenuTop-main'>";
				while(rsm.next())
				{
					String mclick = parseNull(rsm.value("display_name"));
					if(mclick.length() == 0) mclick = parseNull(rsm.value("name"));

					if(mclick.length() > 0)
					{
						String _u = cacheUtil.getExternalLink(parseNull(rsm.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder) ;

						String _cls = "";
						if("1".equals(parseNull(rsm.value("default_selected")))) _cls = "etnhf-active";
						_cls = _cls + " " + getMenuItemClass(parseNull(rsm.value("open_as")));
						String _licls = "";
						if(parseNull(rsm.value("visible_to")).length() > 0)
						{
							_licls = " etnhf-d-none " + parseNull(rsm.value("visible_to")) + " ";
						}

						String _namel = parseNull(rsm.value("display_name"));
						if(_namel.length() == 0) _namel = parseNull(rsm.value("name"));

						m += "<li class='"+_licls+"'><a href='"+_u+"' class='___portalmenulink "+_cls+" etn-data-layer-event' data-dl_event_category='header' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_namel)+"'>";
						if(parseNull(rsm.value("menu_photo")).length() > 0) m += "<img class='etnhf-align-middle' src='"+menuimagespath+parseNull(rsm.value("menu_photo"))+"' alt='"+escapeCoteValue(_namel)+"'>";
						m += escapeCoteValue(_namel);
						if(parseNull(rsm.value("menu_photo")).length() > 0) m += "</img>";
						m += "</a></li>";
					}
				}

				m += "</ul>";//MenuTop-main
				m += "</div>";//MenuTop-blockLeft
			}

			//get items for right align block
			rsm = Etn.execute("select  * from "+proddb+"menu_items where display_in_header = 1 and is_right_align = 1 and menu_id = " + escape.cote(menuid) + " and menu_item_id = -30 order by coalesce(order_seq, 999999), id " );
			rsl = Etn.execute("Select * from "+proddb+"additional_menu_items where menu_id = " + escape.cote(menuid) + " and link_type = 'language' order by order_seq, id ");
			if(rsm.rs.Rows > 0 || rsl.rs.Rows > 0)
			{
				m += "<div class='etnhf-MenuTop-blockRight'>";
				if(rsm.rs.Rows > 0) m += "<ul class='etnhf-MenuTop-secondary'>";
				while(rsm.next())
				{
					String mclick = parseNull(rsm.value("display_name"));
					if(mclick.length() == 0) mclick = parseNull(rsm.value("name"));

					if(mclick.length() > 0)
					{
						String _u = cacheUtil.getExternalLink(parseNull(rsm.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder) ;

						String _cls = "";
						if("1".equals(parseNull(rsm.value("default_selected")))) _cls = "etnhf-active";
						_cls = _cls + " " + getMenuItemClass(parseNull(rsm.value("open_as")));
						String _licls = "";
						if(parseNull(rsm.value("visible_to")).length() > 0)
						{
							_licls = " etnhf-d-none " + parseNull(rsm.value("visible_to")) + " ";
						}

						String _namel = parseNull(rsm.value("display_name"));
						if(_namel.length() == 0) _namel = parseNull(rsm.value("name"));

						m += "<li class='"+_licls+"'><a href='"+_u+"' class='___portalmenulink __page_type "+_cls+" etn-data-layer-event' data-dl_event_category='header' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_namel)+"'>";
						if(parseNull(rsm.value("menu_photo")).length() > 0) m += "<img src='"+menuimagespath+parseNull(rsm.value("menu_photo"))+"' alt='"+escapeCoteValue(_namel)+"' class='etnhf-align-middle'>";
						m += escapeCoteValue(_namel);
						if(parseNull(rsm.value("menu_photo")).length() > 0) m += "</img>";
						m += "</a></li>";
					}
				}
				if(rsm.rs.Rows > 0) m += "</ul>";//MenuTop-secondary

				if(rsl.rs.Rows > 0) m += "<ul class='etnhf-MenuTop-lang'>";
				while(rsl.next())
				{
					String langcls = "";
					String tomenuid = parseNull(rsl.value("to_menu_id"));
					String tourl = "";
					if(tomenuid.length() > 0 && !"0".equals(tomenuid))
					{
						Set tomenurs = Etn.execute("select * from "+proddb+"site_menus where id = " + escape.cote(tomenuid));
						if(tomenurs.next())
						{
							if(parseNull(tomenurs.value("logo_url")).length() > 0) 
							{
								tourl = parseNull(tomenurs.value("logo_url"));
								//safe bet is to add http instead of https or // as we never know the second menu has ssl configured or not
								if(!tourl.toLowerCase().startsWith("http:") && !tourl.toLowerCase().startsWith("https:") && !tourl.toLowerCase().startsWith("/")) tourl = "http://" + tourl;
							}
							else
							{
								tourl = parseNull(tomenurs.value("prod_homepage_url"));
								String toMenuPath = cacheUtil.getMenuPath(Etn, tomenuid);
								tourl = cacheUtil.getExternalLink(tourl, tomenuid, Etn, toMenuPath, siteid, cachedResourcesFolder);
							}
						}
					}
					else langcls = "etnhf-active";
					m += "<li><a class='"+langcls+" ___portalmenulink  ___languagelink etn-data-layer-event' data-dl_event_category='header' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(parseNull(rsl.value("label")))+"' href='"+tourl+"'>"+escapeCoteValue(parseNull(rsl.value("label")))+"</a></li>";
				}
				if(rsl.rs.Rows > 0) m += "</ul>";//MenuTop-lang

				m += "</div>";//MenuTop-blockRight
			}

			m += "</div>";//container
			m += "</div>";//MenuTop
			//end header level 1
		}

		//second level menu

		//desktop menu
		m += "<div class='etnhf-MenuDesktop'>";
		m += "<div class='etnhf-container'>";
		
		String logodisplay = "";
		String logotextmargin = "";
		if(logofile.length() == 0) 
		{
			logodisplay="display:none !important;";
			logotextmargin="margin-left:0px !important;";
		}

		m += "<a class='etnhf-MenuDesktop-brand ___portalmenulink ___portalhomepagelink etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='logo' id='___portalhomepagelink' href='"+logourl+"' style='"+logodisplay+"'><span class='etnhf-MenuDesktop-brand-small' style='display:none;'><img style='max-width:30px;max-height:30px' src='"+smalllogofile+"' alt='logo' class='etnhf-o-logo'></span><span class='etnhf-MenuDesktop-brand-large'><img style='max-width:50px;max-height:50px' src='"+logofile+"' alt='logo' class='etnhf-o-logo'></span></a>";

		if(logotext.length() > 0) m += "<div class='etnhf-MenuDesktop-brandText' style='"+logotextmargin+"font-size:23px;'><div class='etnhf-MenuDesktop-brandFontSize'><a class='___portalmenulink ___portalhomepagelink etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='logo' href='"+logourl+"'>"+logotext+"</a></div></div>";

		m += "<div class='etnhf-MenuDesktop-collapse'>";
		m += "<ul class='etnhf-MenuDesktop-nav'>";

		int mTypeCount = 0;//count must be global as we want class names to be different
		int sbLevelOneCount = 0;//count must be global as we want class names to be different

		rsm = Etn.execute("select  * from "+proddb+"menu_items where display_in_header = 1 and menu_id = " + escape.cote(menuid) + " and menu_item_id = -20 order by coalesce(order_seq, 999999), id " );
		while(rsm.next())
		{
			String mclick = parseNull(rsm.value("display_name"));
			if(mclick.length() == 0) mclick = parseNull(rsm.value("name"));
			if(mclick.length() == 0) continue;
			String pagetype = mclick;
			String _u = cacheUtil.getExternalLink(parseNull(rsm.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);

			String itemid = parseNull(rsm.value("id"));
			String _name = parseNull(rsm.value("display_name"));
			if(_name.length() == 0) _name = parseNull(rsm.value("name"));

			String _cls = getMenuItemClass(parseNull(rsm.value("open_as")));

			String _licls = "";
			if(parseNull(rsm.value("visible_to")).length() > 0)
			{
				_licls = " etnhf-d-none " + parseNull(rsm.value("visible_to")) + " ";
			}

			m += "<li class='"+_licls+" etnhf-MenuDesktop-nav-item'>";

			String mTypeCountClass = "__page_type_"+(mTypeCount++);
			Set rsm1 = Etn.execute("select  * from "+proddb+"menu_items where display_in_header = 1 and menu_id = " + escape.cote(menuid) + " and menu_item_id = "+escape.cote(itemid)+" order by coalesce(order_seq, 999999), id " );
			if(rsm1.rs.Rows == 0)
			{
				m += "<a class='etnhf-MenuDesktop-nav-link etnhf-collapsed ___portalmenulink __page_type "+mTypeCountClass+" "+_cls+" etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"' href='"+_u+"'>"+escapeCoteValue(_name);
				m += "<div class='etnhf-MenuDesktop-orangeHoverDecoration'><span></span></div>";
				m += "</a>";
			}
			else
			{
				m += "<a class='etnhf-MenuDesktop-nav-link etnhf-collapsed ___portalmenulink __page_type "+mTypeCountClass+" etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"' href='javascript:void(0)'>"+escapeCoteValue(_name);
				m += "<div class='etnhf-MenuDesktop-orangeHoverDecoration'><span></span></div>";
				m += "</a>";

				m += "<div class='etnhf-MenuDesktop-nav-panel etnhf-collapse'>";
				m += "<div class='etnhf-container'>";

				m += "<div class='etnhf-MenuDesktop-subHeader'>";
				m += "<a href='"+_u+"' class='etnhf-MenuDesktop-subHeader-link ___portalmenulink "+_cls+" etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"'>"+escapeCoteValue(_name)+"<span data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-right.svg'></span></a>";
				m += "</div>";//MenuDesktop-subHeader

				m += "<ul class='etnhf-MenuDesktop-subNav'>";

				boolean showPhoto = false;
				boolean photoShown = false;
				int megamenucols = 4;
				if(parseNull(rsm.value("menu_photo")).length() > 0 || parseNull(rsm.value("menu_photo_text")).length() > 0  || parseNull(rsm.value("menu_photo_tag_line")).length() > 0 )
				{
					megamenucols = 3;
					showPhoto = true;
				}

				int colsShown = 0;
				int i=0;
				while(rsm1.next())
				{
					String sbLevelOneClass = "__menu_sb1_" + (sbLevelOneCount++);
					String _cls1 = getMenuItemClass(parseNull(rsm1.value("open_as")));
					String _licls1 = "";
					if(parseNull(rsm1.value("visible_to")).length() > 0)
					{
						_licls1 = " etnhf-d-none " + parseNull(rsm1.value("visible_to")) + " ";
					}

					mclick = parseNull(rsm1.value("display_name"));
					if(mclick.length() == 0) mclick = parseNull(rsm1.value("name"));
					String _u1 = cacheUtil.getExternalLink(parseNull(rsm1.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);

					String _name1 = parseNull(rsm1.value("display_name"));
					if(_name1.length() == 0) _name1 = parseNull(rsm1.value("name"));
					String _menuIcon1 = parseNull(rsm1.value("menu_icon"));

					String itemid1 = parseNull(rsm1.value("id"));
					Set rsm2 = Etn.execute("select  * from "+proddb+"menu_items where display_in_header = 1 and menu_id = " + escape.cote(menuid) + " and menu_item_id = "+escape.cote(itemid1)+" order by coalesce(order_seq, 999999), id " );

					if(i != 0 && i % megamenucols == 0)
					{
						//add empty li
						for(int k=0; k < (megamenucols - colsShown); k++)
						{
							m += "<li class='etnhf-MenuDesktop-subItem'></li>";
						}
						if(showPhoto)
						{
							showPhoto = false;
							m += "<li class='etnhf-MenuDesktop-subItem'><img src='"+menuimagespath+parseNull(rsm.value("menu_photo"))+"' alt='image sous menu'></li>";
							photoShown = true;
						}
						else if(photoShown)//photo was shown so in this case one extra li will always be added for photo column
						{
							m += "<li class='etnhf-MenuDesktop-subItem'></li>";
						}
						m += "</ul>";//MenuDesktop-subNav
						m += "<ul class='etnhf-MenuDesktop-subNav'>";
						colsShown = 0;
					}

					String _mimg = "";
					m += "<li class='etnhf-MenuDesktop-subItem "+_licls1+"'>";
					colsShown++;

					if(parseNull(rsm1.value("menu_photo")).length() > 0) _mimg = "<img src='"+menuimagespath+parseNull(rsm1.value("menu_photo"))+"' atl='"+escapeCoteValue(_name1)+"' />";

					m += "<a class='__menu_sb1 "+sbLevelOneClass+" "+mTypeCountClass+" ___portalmenulink "+_cls1+" etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"_"+escapeCoteValue(_name1)+"' href='"+_u1+"'>";
					if(_mimg.length() > 0) m += _mimg;
					else 
					{
						if(_menuIcon1.length() > 0) m += "<img src='"+menuimagespath+_menuIcon1+"' >";
						m += escapeCoteValue(_name1.trim());
					}
					m += "</a>";

					if(rsm2.rs.Rows > 0) 
					{
						m += "<div><ul class='etnhf-MenuDesktop-subSubNav'>";

						while(rsm2.next())
						{
							String _cls2 = getMenuItemClass(parseNull(rsm2.value("open_as")));
							String _licls2 = "";
							if(parseNull(rsm2.value("visible_to")).length() > 0)
							{
								_licls2 = " etnhf-d-none " + parseNull(rsm2.value("visible_to")) + " ";
							}
	
	
							mclick = parseNull(rsm2.value("display_name"));
							if(mclick.length() == 0) mclick = parseNull(rsm2.value("name"));
							String _u2 = cacheUtil.getExternalLink(parseNull(rsm2.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);
	
							String _name2 = parseNull(rsm2.value("display_name"));
							if(_name2.length() == 0) _name2 = parseNull(rsm2.value("name"));
	
							m += "<li class='etnhf-MenuDesktop-subSubItem "+_licls2+"'><a class='__menu_sb2 "+sbLevelOneClass+" ___portalmenulink "+_cls2+" etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name1)+"_"+escapeCoteValue(_name2)+"' href='"+_u2+"'>"+escapeCoteValue(_name2)+"</a></li>";
						}
						//if sublevel 1 has no further links but has a link on itself then we add link directly to it
						//otherwise if there are sublevel 2 links then the sublevel2 link will go as a separate link plus also on parent
						if(parseNull(rsm1.value("prod_url")).length() > 0)
						{
							String linklabel = parseNull(rsm1.value("link_label"));
							if(linklabel.length() == 0) linklabel = parseNull(rsm1.value("display_name"));
							if(linklabel.length() == 0) linklabel = parseNull(rsm1.value("name"));
		
							m += "<li class='etnhf-MenuDesktop-subSubItem etnhf-item-bold "+_licls1+"'><a class='___portalmenulink "+_cls1+" etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"_"+escapeCoteValue(linklabel)+"' href='"+_u1+"'>"+escapeCoteValue(linklabel)+"</a></li>";
						}
	
						m += "</ul></div>";//MenuDesktop-subSubNav
					}

					m += "</li>";//MenuDesktop-subItem

					i++;

				}//while

				//add empty li
				for(int k=0; k < (megamenucols - colsShown); k++)
				{
					m += "<li class='etnhf-MenuDesktop-subItem'></li>";
				}

				if(showPhoto)
				{
					showPhoto = false;
					m += "<li class='etnhf-MenuDesktop-subItem'><img src='"+menuimagespath+parseNull(rsm.value("menu_photo"))+"' alt='image sous menu'></li>";
				}
				else if(photoShown)//photo was shown so in this case one extra li will always be added for photo column
				{
					m += "<li class='etnhf-MenuDesktop-subItem'></li>";
				}
				m += "</ul>";//MenuDesktop-subNav

				m += "</div>";//container
				m += "</div>";//MenuDesktop-nav-panel collapse

			}//else rsm1.rs.Rows == 0

			m += "</li>";//MenuDesktop-nav-item
		}

		m += "</ul>";//MenuDesktop-nav

		//user navigation
		if(showSearchBar || showLoginBar || enableCart)
		{
			m += "<ul class='etnhf-MenuDesktop-userNav'>";

			if(showSearchBar)
			{
				m += "<li class='etnhf-MenuDesktop-userNav-item'>";
				m += "<a class='etnhf-MenuDesktop-userNav-link etnhf-search-btn ___portalmenulink' href='javascript:void(0)'>";
				m += "<span class='etnhf-MenuDesktop-userNav-svg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-search.svg'></span>";
				m += "</a>";
				m += "</li>";

			}
			if(enableCart)
			{
				m += "<li class='etnhf-MenuDesktop-userNav-item ___portal_cart_container'>";
				m += "<a class='etnhf-MenuDesktop-userNav-link ___portal_cart_url ___portalmenulink etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='cart' href='javascript:void(0)'>";
				m += "<span class='etnhf-MenuDesktop-userNav-svg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-shopping.svg'>";
				m += "<span class='etnhf-circle-number ___portal_cart_count'>0</span>";
				m += "</span>";
				m += "</a>";
				m += "</li>";
			}
			if(showLoginBar)
			{
				m += "<li class='etnhf-MenuDesktop-userNav-item etnhf-user-connexion-item ___portal_login_container etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='login'>";
				m += "<span class='etnhf-MenuDesktop-userNav-link etnhf-user-connexion-btn'>";
				m += "<span class='etnhf-user-avatar-circle' id='_mrng_avatar' style='width:36px !important;height:36px !important;'>";
				m += "<span class='etnhf-MenuDesktop-userNav-svg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-avatar.svg'></span>";
				m += "</span>";
				m += "</span>";
				m += "<div class='etnhf-user-connexion-triangle'></div>";
				m += "</li>";
				m += "<li class='etnhf-MenuDesktop-userNav-item'>";
				m += "<span class='etnhf-MenuDesktop-userNav-loggedUser'></span>";
				m += "</li>";
			}
			m += "</ul>";//MenuDesktop-userNav
		}
		// end user navigation


		m += "</div>";//MenuDesktop-collapse

		m += "</div>";//container
		m += "</div>";//MenuDesktop
		//end desktop menu

		//mobile menu
		m += "<div class='etnhf-MenuMobile'>";
		m += "<div class='etnhf-container'>";
		m += "<a class='etnhf-MenuMobile-brand ___portalmenulink ___portalhomepagelink etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='logo' id='___portalhomepagelinkmobile' href='"+logourl+"'><img src='"+smalllogofile+"' alt='logo' ></a>";

		if(logotext.length() > 0) m += "<div class='etnhf-MenuMobile-brandText'>"+logotext+"</div>";

		m += "<ul class='etnhf-MenuMobile-mainLinks'>";

		//user navigation
		if(showLoginBar || enableCart)
		{
			if(enableCart)
			{
				m += "<li class='etnhf-MenuMobile-mainLinks-item  ___portal_cart_container' >";
				m += "<a class='etnhf-MenuMobile-mainLinks-link ___portal_cart_url ___portalmenulink etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='cart' href='javascript:void(0)'>";
				m += "<span class='etnhf-MenuMobile-mainLinks-svg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-shopping.svg'>";
				m += "<span class='etnhf-circle-number ___portal_cart_count'>0</span>";
				m += "</span>";
				m += "</a>";
				m += "</li>";
			}
			if(showLoginBar)
			{
				m += "<li class='etnhf-MenuMobile-mainLinks-item etnhf-user-connexion-item  ___portal_login_container etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='login' >";
				m += "<span class='etnhf-MenuMobile-mainLinks-link etnhf-user-connexion-btn' href='javascript:void(0)'>";
				m += "<span class='etnhf-user-avatar-circle' id='_mrng_avatar' style='width:36px !important;height:36px !important;'>";
				m += "<span class='etnhf-MenuMobile-mainLinks-svg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-avatar.svg'></span>";
				m += "</span>";
				m += "</span>";
				m += "<div class='etnhf-user-connexion-triangle'></div>";
				m += "</li>";
			}
		}
		// end user navigation

		m += "<li class='etnhf-MenuMobile-mainLinks-item'>";
		m += "<div class='etnhf-MenuMobile-mainLinks-link etnhf-burgerIcon'>";
		m += "<span class='etnhf-burgerIcon-1'></span>";
		m += "<span class='etnhf-burgerIcon-2'></span>";
		m += "<span class='etnhf-burgerIcon-3'></span>";
		m += "</div>";
		m += "</li>";//MenuMobile-mainLinks-item
		m += "</ul>";//MenuMobile-mainLinks

		m += "<div class='etnhf-MenuMobile-wrapper etnhf-isScrollable'>";
		m += "<div class='etnhf-MenuMobile-collapse'>";
		m += "<div class='etnhf-container'>";

		if(showSearchBar)
		{
			String searchCls = "moringaheadersearchfield";
			String searchBtnId = "externalmobilesearchbtn";
			if("internal".equalsIgnoreCase(searchapi)) 
			{
				searchCls = "internalmoringaheadersearchfield";
				searchBtnId = "internalmobilesearchbtn";
			}
			else if("url".equalsIgnoreCase(searchapi)) 
			{
				searchCls = "urlmoringaheadersearchfield";
				searchBtnId = "urlmobilesearchbtn";
			}

			m += "<div class='etnhf-MenuMobile-search'>";
			m += "<form action='javascript:return false;'>";
			m += "<label for='moringamobilesearchfield' id='"+searchBtnId+"' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-search.svg'></label>";
			m += "<input type='text' id='moringamobilesearchfield' class='"+searchCls+"' placeholder='"+escapeCoteValue(searchbarlabel)+"'>";
			m += "</form>";
			m += "</div>";
		}

		m += "<ul class='etnhf-MenuMobile-nav'>";

		rsm = Etn.execute("select  * from "+proddb+"menu_items where display_in_header = 1 and menu_id = " + escape.cote(menuid) + " and menu_item_id = -20 order by coalesce(order_seq, 999999), id " );
		while(rsm.next())
		{
			String mclick = parseNull(rsm.value("display_name"));
			if(mclick.length() == 0) mclick = parseNull(rsm.value("name"));
			if(mclick.length() == 0) continue;
			String pagetype = mclick;
			String _u = cacheUtil.getExternalLink(parseNull(rsm.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);

			String itemid = parseNull(rsm.value("id"));
			String _name = parseNull(rsm.value("display_name"));
			if(_name.length() == 0) _name = parseNull(rsm.value("name"));

			String _cls = getMenuItemClass(parseNull(rsm.value("open_as")));

			String _licls = "";
			if(parseNull(rsm.value("visible_to")).length() > 0)
			{
				_licls = " etnhf-d-none " + parseNull(rsm.value("visible_to")) + " ";
			}

			m += "<li class='"+_licls+" etnhf-MenuMobile-nav-item'>";

			Set rsm1 = Etn.execute("select  * from "+proddb+"menu_items where display_in_header = 1 and menu_id = " + escape.cote(menuid) + " and menu_item_id = "+escape.cote(itemid)+" order by coalesce(order_seq, 999999), id " );
			if(rsm1.rs.Rows == 0)
			{
				m += "<a href='"+_u+"' class='etnhf-MenuMobile-nav-link etnhf-collapsed "+_cls+" ___portalmenulink etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"'>";
				m += "<span class='etnhf-MenuMobile-nav-link-text'>"+escapeCoteValue(_name)+"</span>";
				m += "<span class='etnhf-MenuMobile-nav-link-svg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-right.svg'></span>";
				m += "</a>";
			}
			else
			{
				m += "<a href='javascript:void(0)' class='etnhf-MenuMobile-nav-link etnhf-collapsed ___portalmenulink etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"'>";
				m += "<span class='etnhf-MenuMobile-nav-link-text'>"+escapeCoteValue(_name)+"</span>";
				m += "<span class='etnhf-MenuMobile-nav-link-svg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-right.svg'></span>";
				m += "</a>";


				m += "<div class='etnhf-MenuMobile-nav-panel etnhf-collapse'>";

				m += "<div class='etnhf-MenuMobile-subHeader'>";
				m += "<div class='etnhf-container'>";
				m += "<a href='javascript:void(0)' class='etnhf-MenuMobile-subHeader-link ___portalmenulink etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"'>";
				m += "<span data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-left.svg'></span>";
				m += escapeCoteValue(_name);
				m += "</a>";
				m += "</div>";//container
				m += "</div>";//MenuMobile-subHeade

				m += "<div class='etnhf-container'>";
				m += "<ul class='etnhf-MenuMobile-subNav'>";

				while(rsm1.next())
				{

					String _cls1 = getMenuItemClass(parseNull(rsm1.value("open_as")));
					String _licls1 = "";
					if(parseNull(rsm1.value("visible_to")).length() > 0)
					{
						_licls1 = " etnhf-d-none " + parseNull(rsm1.value("visible_to")) + " ";
					}

					mclick = parseNull(rsm1.value("display_name"));
					if(mclick.length() == 0) mclick = parseNull(rsm1.value("name"));
					String _u1 = cacheUtil.getExternalLink(parseNull(rsm1.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);

					String _name1 = parseNull(rsm1.value("display_name"));
					if(_name1.length() == 0) _name1 = parseNull(rsm1.value("name"));
					String _menuIcon1 = parseNull(rsm1.value("menu_icon"));

					String itemid1 = parseNull(rsm1.value("id"));
					Set rsm2 = Etn.execute("select  * from "+proddb+"menu_items where display_in_header = 1 and menu_id = " + escape.cote(menuid) + " and menu_item_id = "+escape.cote(itemid1)+" order by coalesce(order_seq, 999999), id " );

					m += "<li class='etnhf-MenuMobile-subItem "+_licls1+"'>";

					//in mobile view if the sublevel 1 has a link but no childs we add link directly to sublevel1 ... but if sublevel1 has childs and also a link then we dont add link here on sublevel1 
					//but instead add that link to the special link added after its childs are added
					String sublevel1link = "javascript:void(0)";
					String sublevel1cls = "";
					if(rsm2.rs.Rows == 0)
					{
						sublevel1link = _u1;
						sublevel1cls = _cls1; 
					}

					String _miconhtml = "";
					m += "<a class='etnhf-MenuMobile-subItem-link ___portalmenulink "+sublevel1cls+" etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"_"+escapeCoteValue(_name1)+"' href='"+sublevel1link+"'>";
					if(_menuIcon1.length() > 0) _miconhtml = "<img src='"+menuimagespath+_menuIcon1+"'>";
					m += "<div>"+_miconhtml+"</span>";
					m += escapeCoteValue(_name1);
					m += "</div>";
					m += "<span class='etnhf-MenuMobile-subItem-svg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-right.svg'></span>";
					m += "</a>";

					if(rsm2.rs.Rows > 0)  
					{
						m += "<div class='etnhf-MenuMobile-subSubNavWrapper'>";
						m += "<div class='etnhf-MenuMobile-subSubBack'>";
						m += "<div class='etnhf-container'>";
						m += "<span data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-left.svg'></span>";
						m += escapeCoteValue(_name1);
						m += "</div>";
						m += "</div>";

						m += "<div class='etnhf-container'>";
						m += "<ul class='etnhf-MenuMobile-subSubNav'>";

						while(rsm2.next())
						{
							String _cls2 = getMenuItemClass(parseNull(rsm2.value("open_as")));
							String _licls2 = "";
							if(parseNull(rsm2.value("visible_to")).length() > 0)
							{
								_licls2 = " etnhf-d-none " + parseNull(rsm2.value("visible_to")) + " ";
							}


							mclick = parseNull(rsm2.value("display_name"));
							if(mclick.length() == 0) mclick = parseNull(rsm2.value("name"));
							String _u2 = cacheUtil.getExternalLink(parseNull(rsm2.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);

							String _name2 = parseNull(rsm2.value("display_name"));
							if(_name2.length() == 0) _name2 = parseNull(rsm2.value("name"));

							m +="<li class='etnhf-MenuMobile-subSubItem "+_licls2+"'>";
							m +="<a href='"+_u2+"' class='___portalmenulink etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name1)+"_"+escapeCoteValue(_name2)+"'>"+escapeCoteValue(_name2);
							m +="<span class='etnhf-MenuMobile-subItem-svg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-right.svg'></span>";
							m +="</a>";
							m +="</li>";
						}

						m += "</ul>";//MenuMobile-subSubNav'>
						m += "</div>";//container						

						//check if the main item has link add its link separately for mobile view
						if(parseNull(rsm1.value("prod_url")).length() > 0)
						{
							String linklabel = parseNull(rsm1.value("link_label"));
							if(linklabel.length() == 0) linklabel = parseNull(rsm1.value("display_name"));
							if(linklabel.length() == 0) linklabel = parseNull(rsm1.value("name"));
		
							m += "<div class='etnhf-MenuMobile-subSubFooter'>";
							m += "<div class='etnhf-container'>";
							m += "<a href='"+_u1+"' class='___portalmenulink "+_cls1+" etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"_"+escapeCoteValue(linklabel)+"'>"+escapeCoteValue(linklabel)+"<span data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-right.svg'></span></a>";
							m += "</div>";//container
							m += "</div>";//MenuMobile-subSubFooter
						}

						m += "</div>";//MenuMobile-subSubNavWrapper
					}

					m += "</li>";//MenuMobile-subItem
				}
				m += "</ul>";//MenuMobile-subNav
				m += "</div>";//container

				//check if parent has a URL then display it for mobile menu
				if(parseNull(rsm.value("prod_url")).length() > 0)
				{
					m += "<div class='etnhf-MenuMobile-subFooter'>";
					m += "<div class='etnhf-container'>";
					String linklabel = parseNull(rsm.value("link_label"));
					if(linklabel.length() == 0) linklabel = parseNull(rsm.value("display_name"));
					if(linklabel.length() == 0) linklabel = parseNull(rsm.value("name"));
	
					m += "<a class='___portalmenulink "+_cls+" etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"_"+escapeCoteValue(linklabel)+"' href='"+_u+"'>"+escapeCoteValue(linklabel)+"<span data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-right.svg'></span></a>";
	
					m += "</div>";//container
					m += "</div>";//MenuMobile-subFooter
				}

				m += "</div>";//MenuMobile-nav-panel collapse

			}//else rsm1.rs.Rows == 0

			m += "</li>";//MenuDesktop-nav-item
		}

		m += "</ul>";//MenuMobile-nav
		m += "</div>";//container

		//top header right side links
		rsm = Etn.execute("select  * from "+proddb+"menu_items where display_in_header = 1 and is_right_align = 1 and menu_id = " + escape.cote(menuid) + " and menu_item_id = -30 order by coalesce(order_seq, 999999), id " );
		if(rsm.rs.Rows > 0)
		{
			m += "<div class='etnhf-MenuMobile-bottom-mainLinks'>";
			m += "<div class='etnhf-container'>";
			m += "<ul>";

			while(rsm.next())
			{
				String mclick = parseNull(rsm.value("display_name"));
				if(mclick.length() == 0) mclick = parseNull(rsm.value("name"));
				if(mclick.length() > 0)
				{
					String _u = cacheUtil.getExternalLink(parseNull(rsm.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder) ;

					String _cls = "";
					if("1".equals(parseNull(rsm.value("default_selected")))) _cls = "etnhf-active";
					_cls = _cls + " " + getMenuItemClass(parseNull(rsm.value("open_as")));
					String _licls = "";
					if(parseNull(rsm.value("visible_to")).length() > 0)
					{
						_licls = " etnhf-d-none " + parseNull(rsm.value("visible_to")) + " ";
					}
					String _namer = parseNull(rsm.value("display_name"));
					if(_namer.length() == 0) _namer = parseNull(rsm.value("name"));

					m += "<li class='"+_licls+"'><a href='"+_u+"' class='___portalmenulink "+_cls+" etn-data-layer-event' data-dl_event_category='header' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_namer)+"'>";
					m += "<div>";

					if(parseNull(rsm.value("menu_photo")).length() > 0) m += "<span class='etnhf-linkIconSvg'><img src='"+menuimagespath+parseNull(rsm.value("menu_photo"))+"' alt='"+escapeCoteValue(_namer)+"' class='etnhf-align-middle'>";
					m += escapeCoteValue(_namer);
					if(parseNull(rsm.value("menu_photo")).length() > 0) m += "</img></span>";
					m += "</div>";
					m += "<span class='etnhf-angleRightSvg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-right.svg'></span>";
					m += "</a></li>";
				}
			}

			m += "</ul>";
			m += "</div>";//container
			m += "</div>";//MenuMobile-bottom-mainLinks
		}

		//top header left side links
		rsm = Etn.execute("select  * from "+proddb+"menu_items where display_in_header = 1 and is_right_align = 0 and menu_id = " + escape.cote(menuid) + " and menu_item_id = -30 order by coalesce(order_seq, 999999), id " );
		if(rsm.rs.Rows > 0)
		{

			m += "<div class='etnhf-MenuMobile-bottom-mainLinks'>";
			m += "<div class='etnhf-container'>";
			m += "<ul>";

			while(rsm.next())
			{
				String mclick = parseNull(rsm.value("display_name"));
				if(mclick.length() == 0) mclick = parseNull(rsm.value("name"));
				if(mclick.length() > 0)
				{
					String _u = cacheUtil.getExternalLink(parseNull(rsm.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder) ;

					String _cls = "";
					if("1".equals(parseNull(rsm.value("default_selected")))) _cls = "etnhf-active";
					_cls = _cls + " " + getMenuItemClass(parseNull(rsm.value("open_as")));
					String _licls = "";
					if(parseNull(rsm.value("visible_to")).length() > 0)
					{
						_licls = " etnhf-d-none " + parseNull(rsm.value("visible_to")) + " ";
					}

					String _namer = parseNull(rsm.value("display_name"));
					if(_namer.length() == 0) _namer = parseNull(rsm.value("name"));

					m += "<li class='"+_licls+"'><a href='"+_u+"' class='___portalmenulink "+_cls+" etn-data-layer-event' data-dl_event_category='header' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_namer)+"'>";
					m += "<div>";

					if(parseNull(rsm.value("menu_photo")).length() > 0) m += "<span class='etnhf-linkIconSvg'><img src='"+menuimagespath+parseNull(rsm.value("menu_photo"))+"' alt='"+escapeCoteValue(_namer)+"' class='etnhf-align-middle' >";
					m += escapeCoteValue(_namer);
					if(parseNull(rsm.value("menu_photo")).length() > 0) m += "</img></span>";
					m += "</div>";
					m += "<span class='etnhf-angleRightSvg' data-hf-svg='"+menuresourcesurl+"assets/icons/icon-angle-right.svg'></span>";
					m += "</a></li>";
				}
			}

			m += "</ul>";
			m += "</div>";//container
			m += "</div>";//MenuMobile-bottom-mainLinks

		}

		//language links
		rsl = Etn.execute("Select * from "+proddb+"additional_menu_items where menu_id = " + escape.cote(menuid) + " and link_type = 'language' order by order_seq, id ");
		if(rsl.rs.Rows > 0)
		{
			m += "<div class='etnhf-MenuMobile-bottom-langLinks'>";
			m += "<div class='etnhf-container'>";
			m += "<ul>";
			while(rsl.next())
			{
				String langcls = "";
				String tomenuid = parseNull(rsl.value("to_menu_id"));
				String tourl = "";
				if(tomenuid.length() > 0 && !"0".equals(tomenuid))
				{
					Set tomenurs = Etn.execute("select * from "+proddb+"site_menus where id = " + escape.cote(tomenuid));
					if(tomenurs.next())
					{
						if(parseNull(tomenurs.value("logo_url")).length() > 0) 
						{
							tourl = parseNull(tomenurs.value("logo_url"));
							//safe bet is to add http instead of https or // as we never know the second menu has ssl configured or not
							if(!tourl.toLowerCase().startsWith("http:") && !tourl.toLowerCase().startsWith("https:") && !tourl.toLowerCase().startsWith("/")) tourl = "http://" + tourl;
						}
						else
						{
							tourl = parseNull(tomenurs.value("prod_homepage_url"));
							String toMenuPath = cacheUtil.getMenuPath(Etn, tomenuid);
							tourl = cacheUtil.getExternalLink(tourl, tomenuid, Etn, toMenuPath, siteid, cachedResourcesFolder);
						}
					}
				}
				else langcls = "etnhf-active";
				m += "<li><a class='"+langcls+" ___portalmenulink  ___languagelink etn-data-layer-event' data-dl_event_category='header' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(parseNull(rsl.value("label")))+"' href='"+tourl+"'>"+escapeCoteValue(parseNull(rsl.value("label")))+"</a></li>";

			}
			m += "</ul>";
			m += "</div>";//container
			m += "</div>";//MenuMobile-bottom-langLinks
		}

		m += "</div>";//MenuMobile-collapse
		m += "</div>";//etnhf-MenuMobile-wrapper etnhf-isScrollable

		m += "</div>";//container
		m += "</div>";//MenuMobile
		//end mobile menu

		//desktop search bar
		if(showSearchBar)
		{
			String searchCls = "moringaheadersearchfield";
			String searchBtnId = "externaldesktopsearchbtn";
			if("internal".equalsIgnoreCase(searchapi)) 
			{
				searchCls = "internalmoringaheadersearchfield";
				searchBtnId = "internaldesktopsearchbtn";
			}
			else if("url".equalsIgnoreCase(searchapi)) 
			{
				searchCls = "urlmoringaheadersearchfield";
				searchBtnId = "urldesktopsearchbtn";
			}

			m += "<div class='etnhf-NavSearch' aria-expanded='false'>";
			m += "<div class='etnhf-container'>";
			m += "<form class='etnhf-SearchForm' action='javascript:return false;'>";
			m += "<div class='etnhf-SearchForm-inputWrapper'>";
			m += "<input type='text' class='etnhf-SearchForm-input "+searchCls+"' id='moringadesktopsearchfield'>";
			m += "<div class='etnhf-SearchForm-inputButton'>";
			m += "<span class='etnhf-SearchForm-inputClear' style='display: none;'><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='30px' height='30px' viewBox='0 0 30 30' version='1.1'>";
			m += "<g id='icon/icon-close' stroke='none' stroke-width='1' fill='none' fill-rule='evenodd'>";
			m += "<path d='M25.5,12 L18,12 L18,4.5 C18,3.67158 17.32842,3 16.5,3 L13.5,3 C12.67158,3 12,3.67158 12,4.5 L12,12 L4.5,12 C3.67158,12 3,12.67158 3,13.5 L3,16.5 C3,17.32842 3.67158,18 4.5,18 L12,18 L12,25.5 C12,26.32842 12.67158,27 13.5,27 L16.5,27 C17.32842,27 18,26.32842 18,25.5 L18,18 L25.5,18 C26.32842,18 27,17.32842 27,16.5 L27,13.5 C27,12.67158 26.32842,12 25.5,12' id='Fill-1' fill='#000000' transform='translate(15.000000, 15.000000) rotate(-315.000000) translate(-15.000000, -15.000000) '></path>";
			m += "</g>";
			m += "</svg></span>";
			m += "<span class='etnhf-SearchForm-inputSearch' ><svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='30px' height='30px' viewBox='0 0 30 30' version='1.1'>";
			m += "<g id='icon/icon-search' stroke='none' stroke-width='1' fill='none' fill-rule='evenodd'>";
			m += "<path d='M12.765625,6.125 C9.098125,6.125 6.125,9.098125 6.125,12.765625 C6.125,16.433125 9.098125,19.40625 12.765625,19.40625 C16.433125,19.40625 19.40625,16.433125 19.40625,12.765625 C19.40625,9.098125 16.433125,6.125 12.765625,6.125 M27.7714062,26.5972813 L26.5972813,27.7714063 C26.2934375,28.07525 25.7961875,28.07525 25.4923437,27.7714063 L18.437125,20.7162187 C16.8382812,21.85875 14.8805313,22.53125 12.765625,22.53125 C7.37221875,22.53125 3,18.1590312 3,12.765625 C3,7.37221875 7.37221875,3 12.765625,3 C18.1590312,3 22.53125,7.37221875 22.53125,12.765625 C22.53125,14.8805313 21.85875,16.8382813 20.7162187,18.4370938 L27.7714062,25.4923125 C28.0752812,25.7962188 28.0752812,26.2934063 27.7714062,26.5972813' id='Fill-1' fill='#000000'></path>";
			m += "</g>";
			m += "</svg></span>";
			m += "</div>";
			m += "</div>";
			m += "<button type='submit' class='etnhf-SearchForm-submit etnhf-btn etnhf-btn-secondary etn-data-layer-event' data-dl_event_category='menu' data-dl_event_action='button_click' data-dl_event_label='search' id='"+searchBtnId+"'>"+escapeCoteValue(searchbarlabel)+"</button>";
			m += "</form>";
			m += "</div>";
			m += "</div>";
		}

		if(showLoginBar)
		{
			m += "<div class='etnhf-container'>";
			m += "<div class='etnhf-ConnexionCart etnhf-ConnexionCart-offline'>";
			m += "<div class='etnhf-ConnexionCart-inner'>";
			m += "<div class='etnhf-ConnexionCart-title'>"+escapeCoteValue(getTranslation(Etn, dict, "Déjà client?"))+"</div>";
			m += "<div class='etnhf-ConnexionCart-btn'>";
			m += "<button type='button' class='etnhf-btn etnhf-btn-primary'>"+escapeCoteValue(loginButtonLabel)+"</button>";
			m += "</div>";
			m += "<div class='etnhf-ConnexionCart-title'>"+escapeCoteValue(getTranslation(Etn, dict, "Nouveau client?"))+"</div>";
			m += "<a href='"+signuplocation+"' class='etnhf-ConnexionCart-link moringa-no-crawl ___portalmenulink'>"+escapeCoteValue(signUpLabel)+"</a>";
			m += "</div>";
			m += "<div class='etnhf-ConnexionCart-close'>";
			m += "<span></span>";
			m += "<span></span>";
			m += "</div>";
			m += "</div>";
			m += "<div class='etnhf-ConnexionCart etnhf-ConnexionCart-form'>";
			m += "<div class='etnhf-ConnexionCart-inner'>";
			m += "<div class='etnhf-ConnexionCart-title'>"+escapeCoteValue(getTranslation(Etn, dict, "Se connecter"))+"</div>";
			m += "<div class='alert alert-danger' id='_loginalertdiv' style='display:none'></div>";
			m += "<form action='javascript:return false;' id='___portal_login_frm' autocomplete='off' >";
			m += "<input type='hidden' name='muid' value='"+menuUuid+"'>";
			m += "<input type='hidden' name='logintoken' id='___logintoken' value=''>";
			m += "<div class='etnhf-form-group'>";
			m += "<label for='username'>"+escapeCoteValue(loginUsernameLabel)+" *</label>";
			m += "<input class='etnhf-form-control' type='text' autocomplete='off' name='username' >";
			m += "</div>";
			m += "<div class='etnhf-form-group'>";
			m += "<label for='connexion-password'>"+escapeCoteValue(loginPasswordLabel)+" *</label>";
			m += "<input class='etnhf-form-control' type='password' autocomplete='off' name='password' >";
			m += "</div>";
			m += "<div class='etnhf-form-group'>";
			m += "<label class='etnhf-custom-control etnhf-custom-checkbox'>";
			m += "<input class='etnhf-custom-control-input' type='checkbox' value='1' name='rememberme'>";
			m += "<span class='etnhf-custom-control-label'></span>";
			m += "<span class='etnhf-custom-control-description'>"+escapeCoteValue(getTranslation(Etn, dict, "Souviens-toi de moi"))+"</span>";
			m += "</label>";
			m += "</div>";
			m += "<div class='etnhf-form-group'>";
			m += "<a href='"+forgotpasslocation+"' class='moringa-no-crawl ___portalmenulink'>"+escapeCoteValue(forgotPasswordLabel)+"</a>";
			m += "</div>";
			m += "<div class='etnhf-form-group'>";
			m += "<a href='"+signuplocation+"' class='moringa-no-crawl ___portalmenulink'>"+escapeCoteValue(getTranslation(Etn, dict, "Nouveau client?"))+"</a>";
			m += "</div>";
			m += "<input class='etnhf-btn etnhf-btn-primary' type='button' onclick='__doPortalLogin()' value='"+escapeCoteValue(loginButtonLabel)+"'>";
			m += "</form>";
			m += "</div>";
			m += "<div class='etnhf-ConnexionCart-close'>";
			m += "<span></span>";
			m += "<span></span>";
			m += "</div>";
			m += "</div>";
			m += "<div class='etnhf-ConnexionCart etnhf-ConnexionCart-connected'>";
			m += "<div class='etnhf-ConnexionCart-inner'>";
			m += "<div class='etnhf-ConnexionCart-header'>";
			m += "<div class='etnhf-ConnexionCart-titleWrapper' style='padding-left:0px !important'>";
			m += "<div class='etnhf-ConnexionCart-title'>"+escapeCoteValue(getTranslation(Etn, dict, "Bienvenue"))+"</div>";
			m += "<div class='etnhf-ConnexionCart-title' id='___lcname'></div>";
			m += "<div class='etnhf-ConnexionCart-title' id='___lcnum'></div>";
			m += "</div>";
			m += "</div>";		
			m += "<a href='"+myaccountlocation+"' class='etnhf-ConnexionCart-link moringa-no-crawl ___portalmenulink'>"+escapeCoteValue(getTranslation(Etn, dict, "Gérer mon profil"))+"</a>";
			m += "<a href='"+changepassword+"' class='etnhf-ConnexionCart-link moringa-no-crawl ___portalmenulink'>"+escapeCoteValue(getTranslation(Etn, dict, "Changer le mot de passe"))+"</a>";			
			m += "<div class='etnhf-ConnexionCart-btn'>";
			m += "<button type='button' class='etnhf-btn etnhf-btn-secondary' onclick='__doPortalLogout()'>"+escapeCoteValue(logoutButtonLabel)+"</button>";
			m += "</div>";
			m += "</div>";
			m += "<div class='etnhf-ConnexionCart-close'>";
			m += "<span></span>";
			m += "<span></span>";
			m += "</div>";
			m += "</div>";
			m += "</div>";
		}


		m += "</nav>";
		m += "</header>";
		return m;
	}

	String generateFooter(ClientSql Etn, String menuid) throws Exception
	{
		String proddb = env.getProperty("PROD_DB") + ".";

		String menuimagespath = env.getProperty("PROD_MENU_PHOTO_URL");

		Set rs = Etn.execute("select * from "+proddb+"site_menus where id = " + escape.cote(menuid));
		rs.next();		

		if("1".equals(rs.value("hide_footer")))
		{
			return "";
		}
		
		String siteid = rs.value("site_id");

		boolean debug =  env.get("DEBUG")!=null || env.get("SCHED_DEBUG") != null;

		CacheUtil cacheUtil = new CacheUtil(env, true, debug);

		String cachedResourcesFolder = cacheUtil.getCachedResourcesUrl(Etn, menuid);		
		String menuPublishPath = parseNull(env.getProperty("PROD_PUBLISHER_SEND_REDIRECT_LINK")) + cacheUtil.getMenuCacheFolder(Etn, menuid);		
		
		String menudirection = getMenuDirection(Etn, parseNull(rs.value("lang")));
		String m = "";

		//gray footer
		Set rsm2 = Etn.execute("select  * from "+proddb+"menu_items where menu_id = " + escape.cote(menuid) + " and menu_item_id = -15 order by coalesce(order_seq, 999999), id " );
		if(rsm2.next())
		{
			String pagetype = parseNull(rsm2.value("display_name"));
			if(pagetype.length() == 0) pagetype = parseNull(rsm2.value("name"));

			String _nameg = parseNull(rsm2.value("footer_display_name"));
			if(_nameg.length() == 0) _nameg = parseNull(rsm2.value("display_name"));
			if(_nameg.length() == 0) _nameg = parseNull(rsm2.value("name"));

			m += "<div class='etnhf-gray-footer etnhf-bg-light __crawl__menu __menu_2'  id='etn-gray-footer'>";
			m += "<div class='etnhf-container'>";
			m += "<h2 class='etnhf-h1' style='font-weight:bold'>"+escapeCoteValue(_nameg)+"</h2>";
			m += "<div class='etnhf-row'>";

			Set rsm3 = Etn.execute("select * from "+proddb+"menu_items where menu_id = " + escape.cote(menuid) + " and menu_item_id = " + escape.cote(parseNull(rsm2.value("id"))) + " order by coalesce(order_seq, 999999), id ");

			String _cls = "etnhf-col-3 etnhf-text-center";
			if(rsm3.rs.Rows == 1) _cls = "etnhf-col-12 etnhf-text-center";
			else if(rsm3.rs.Rows == 2) _cls = "etnhf-col-6 etnhf-text-center";
			else if(rsm3.rs.Rows == 3) _cls = "etnhf-col-4 etnhf-text-center";
			else if(rsm3.rs.Rows == 4) _cls = "etnhf-col-3 etnhf-text-center";
			else if(rsm3.rs.Rows > 4) _cls = "etnhf-col-2 etnhf-text-center";

			while(rsm3.next())
			{
				String _cls2 = getMenuItemClass(parseNull(rsm3.value("open_as")));
				String _licls2 = "";
				if(parseNull(rsm3.value("visible_to")).length() > 0)
				{
					_licls2 = " etnhf-d-none " + parseNull(rsm3.value("visible_to")) + " ";
				}

				String mclick = parseNull(rsm3.value("display_name"));
				if(mclick.length() == 0) mclick = parseNull(rsm3.value("name"));

				String _nameg2 = parseNull(rsm3.value("footer_display_name"));
				if(_nameg2.length() == 0) _nameg2 = parseNull(rsm3.value("display_name"));
				if(_nameg2.length() == 0) _nameg2 = parseNull(rsm3.value("name"));

				String _u1 = cacheUtil.getExternalLink(parseNull(rsm3.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);
				m += "<div class='"+_cls+" "+_licls2+"'><a class='__page_type ___portalmenulink "+_cls2+" etn-data-layer-event' data-dl_event_category='footer' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_nameg2)+"' href='"+_u1+"'>";
				if(parseNull(rsm3.value("menu_photo")).length() > 0) m += "<img class='etnhf-img-fluid' src='"+menuimagespath+parseNull(rsm3.value("menu_photo"))+"' alt='"+escapeCoteValue(parseNull(rsm3.value("name")))+"'>";
				m += "<p class='etnhf-f20 etnhf-ft13'>"+escapeCoteValue(_nameg2)+"</p></a>";
				m += "</div>";
			}

			m += "</div>";//row
			m += "</div>";//container
			m += "</div>";//contact o-lightgray
		}

		m += "<div class='etnhf-HomeFooter __crawl__menu __menu_1' id='etn-portal-footer'>";

		Set rsf = Etn.execute("Select * from "+proddb+"additional_menu_items where menu_id = " + escape.cote(menuid) + " and link_type = 'social_media' order by order_seq ");
		if(rsf.rs.Rows > 0)
		{
			m += "<div class='etnhf-HomeFooter-head'>";
			m += "<div class='etnhf-container'>";
			m += "<div class='etnhf-SocialNetworks etnhf-isDark'>";
			m += "<span class='etnhf-SocialNetworks-title'>"+escapeCoteValue(parseNull(rs.value("follow_us_bar_label")))+"</span>";

			while(rsf.next())
			{
				//NOTE::For follow-us bar we always use the column URL as there is no prod_url option on menu designer
				String _u = parseNull(rsf.value("url"));
				String _cls = "etnhf-o-follow-" + parseNull(rsf.value("name"));
				String _id = "o-follow-" + parseNull(rsf.value("name"));
				String _span = parseNull(rs.value("follow_us_bar_label")) + " " + parseNull(rsf.value("name"));
				m += "<a href='"+_u+"' target='_blank' class='"+_cls+" ___portalmenulink etn-data-layer-event' data-dl_event_category='footer' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(parseNull(rsf.value("name")))+"' onclick='setCookie(\""+_id+"\", \"followbar_visited\", 730);' id='"+_id+"'>";
				if("facebook".equals(parseNull(rsf.value("name"))))
				{
					m += "<span>";
					m += "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 20 20'>";
					m += "<path fill-rule='evenodd' d='M13.37 4H15V1.13c-.79-.09-1.585-.133-2.38-.13-2.35 0-4 1.49-4 4.23v2.36H6v3.2h2.66V19h3.18v-8.21h2.66l.39-3.2h-3.05v-2c0-.97.25-1.59 1.53-1.59z'></path>";
					m += "</svg>";
					m += "</span>";
					m += "<span class='etnhf-SocialNetworks-background' style='background-color:#1877f2;'></span>";
					m += "<span class='etnhf-SocialNetworks-colorfulCircle' style='border-color:#1877f2;'></span>";
					m += "<span class='etnhf-SocialNetworks-backgroundCircle'></span>";
				}
				else if("instagram".equals(parseNull(rsf.value("name"))))
				{
					m += "<span>";
					m += "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 20 20'>";
					m += "<path fill-rule='evenodd' d='M17.301 13.579a3.723 3.723 0 0 1-3.723 3.723H6.42A3.723 3.723 0 0 1 2.7 13.58V6.422A3.723 3.723 0 0 1 6.42 2.7h7.157A3.723 3.723 0 0 1 17.3 6.423v7.156zM19 6.422A5.423 5.423 0 0 0 13.578 1H6.42A5.422 5.422 0 0 0 1 6.423v7.156A5.421 5.421 0 0 0 6.421 19h7.157A5.422 5.422 0 0 0 19 13.579V6.422zm-8.97 6.542a2.852 2.852 0 0 1-2.847-2.848A2.85 2.85 0 0 1 10.03 7.27a2.85 2.85 0 0 1 2.848 2.846 2.851 2.851 0 0 1-2.848 2.848zm0-7.293a4.45 4.45 0 0 0-4.444 4.445 4.45 4.45 0 0 0 4.444 4.446 4.45 4.45 0 0 0 4.445-4.446A4.45 4.45 0 0 0 10.03 5.67zm4.705-1.357a1.058 1.058 0 1 0 0 2.117 1.058 1.058 0 0 0 0-2.117z'></path>";
					m += "</svg>";
					m += "</span>";
					m += "<span class='etnhf-SocialNetworks-background' style='background-color:#C13584;'></span>";
					m += "<span class='etnhf-SocialNetworks-colorfulCircle' style='border-color:#C13584;'></span>";
					m += "<span class='etnhf-SocialNetworks-backgroundCircle'></span>";
				}
				else if("linkedin".equals(parseNull(rsf.value("name"))))
				{
					m += "<span>";
					m += "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 20 20'>";
					m += "<path fill-rule='evenodd' d='M1.32 19h3.7V7h-3.7v12zM3.18 1a2.17 2.17 0 1 0-.02 4.34A2.17 2.17 0 0 0 3.18 1zm11.37 5.68a3.9 3.9 0 0 0-3.53 1.94V7H7.44v12h3.73v-5.95c0-1.57.29-3.08 2.23-3.08s1.94 1.79 1.94 3.18V19h3.68v-6.59c0-3.24-.7-5.73-4.47-5.73z'></path>";
					m += "</svg>";
					m += "</span>";
					m += "<span class='etnhf-SocialNetworks-background' style='background-color:#007bb5;'></span>";
					m += "<span class='etnhf-SocialNetworks-colorfulCircle' style='border-color:#007bb5;'></span>";
					m += "<span class='etnhf-SocialNetworks-backgroundCircle'></span>";
				}
				else if("newsletter".equals(parseNull(rsf.value("name"))))
				{
					m += "<span>";
					m += "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 20 20'>";
					m += "<path d='M17.788 2H0v13.425a2.201 2.201 0 0 0 2.21 2.2H20V4.157C20 2.937 19.008 2 17.788 2zm.337 4.691l-5.906 5.684h-.005c-.579.575-1.364.874-2.228.874-.865 0-1.65-.299-2.23-.874h-.015l-5.866-5.68V4.532C4.225 6.854 8.5 11 8.5 11c.383.4.903.57 1.478.57.609 0 1.157-.245 1.544-.67h.003l6.599-6.399v2.19z'></path>";
					m += "</svg>";
					m += "</span>";
					m += "<span class='etnhf-SocialNetworks-background' style='background-color:#f16e00;'></span>";
					m += "<span class='etnhf-SocialNetworks-colorfulCircle' style='border-color:#f16e00;'></span>";
					m += "<span class='etnhf-SocialNetworks-backgroundCircle'></span>";
				}
				else if("twitter".equals(parseNull(rsf.value("name"))))
				{		
					m += "<span>";
					m += "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 20 20'>";
					m += "<path fill-rule='evenodd' d='M19.12 3.89a7.61 7.61 0 0 1-2.26.64 4 4 0 0 0 1.73-2.23 8 8 0 0 1-2.5 1A3.88 3.88 0 0 0 13.21 2a4 4 0 0 0-3.83 5 11.1 11.1 0 0 1-8.12-4.22 4.1 4.1 0 0 0-.54 2 4.06 4.06 0 0 0 1.8 3.35 3.87 3.87 0 0 1-1.79-.5v.05a4 4 0 0 0 3.16 4 4 4 0 0 1-1 .14 4.53 4.53 0 0 1-.74-.07 4 4 0 0 0 3.68 2.8 7.73 7.73 0 0 1-4.89 1.73H0a11 11 0 0 0 6 1.81c7.24 0 11.21-6.15 11.21-11.49v-.53a8 8 0 0 0 1.91-2.18z'></path>";
					m += "</svg>";
					m += "</span>";
					m += "<span class='etnhf-SocialNetworks-background' style='background-color:#1da1f2;'></span>";
					m += "<span class='etnhf-SocialNetworks-colorfulCircle' style='border-color:#1da1f2;'></span>";
					m += "<span class='etnhf-SocialNetworks-backgroundCircle'></span>";
				}
				else if("whatsapp".equals(parseNull(rsf.value("name"))))
				{
					m += "<span>";
					m += "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 20 20'>";
					m += "<path fill-rule='evenodd' d='M10.143 1c5.041 0 9.143 4.1 9.143 9.143 0 5.041-4.102 9.143-9.143 9.143a9.141 9.141 0 0 1-4.306-1.08l-3.827 1.05a.8.8 0 0 1-.938-1.1l1.389-3.058A9.079 9.079 0 0 1 1 10.143C1 5.1 5.102 1 10.143 1zm0 1.597c-4.16 0-7.546 3.385-7.546 7.546 0 1.593.492 3.118 1.424 4.408a.798.798 0 0 1 .08.796l-.871 1.92 2.5-.688a.79.79 0 0 1 .614.082 7.536 7.536 0 0 0 3.799 1.027c4.161 0 7.546-3.385 7.546-7.545 0-4.161-3.385-7.546-7.546-7.546zm-2.89 3.37c.145 0 .286.032.414.104.392.222.595.778.776 1.17l.062.137c.123.282.234.62.183.915-.058.343-.33.633-.547.888-.147.171-.168.318-.046.504.716 1.194 1.712 2.062 3.01 2.58a.48.48 0 0 0 .178.038.314.314 0 0 0 .252-.131c.224-.277.446-.82.79-.96a.863.863 0 0 1 .332-.064c.352 0 .711.19 1.001.364.357.213.952.475 1.05.915.045.213.004.438-.08.64-.28.682-.977 1.118-1.684 1.254a2.237 2.237 0 0 1-.41.038c-.5 0-.953-.169-1.448-.332a7.715 7.715 0 0 1-1.597-.76 9.1 9.1 0 0 1-2.56-2.376 10.153 10.153 0 0 1-.59-.899c-.24-.409-.454-.84-.565-1.303a2.61 2.61 0 0 1-.073-.588c-.01-.7.258-1.407.812-1.858a1.21 1.21 0 0 1 .74-.276z'></path>";
					m += "</svg>";
					m += "</span>";
					m += "<span class='etnhf-SocialNetworks-background' style='background-color:#25d366;'></span>";
					m += "<span class='etnhf-SocialNetworks-colorfulCircle' style='border-color:#25d366;'></span>";
					m += "<span class='etnhf-SocialNetworks-backgroundCircle'></span>";
				}
				else if("youtube".equals(parseNull(rsf.value("name"))))
				{
					m += "<span>";
					m += "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 20 20'>";
					m += "<path fill-rule='evenodd' d='M8 13V7l5.196 3L8 13zm11.582-7.814a2.505 2.505 0 0 0-1.768-1.768C16.254 3 10 3 10 3s-6.254 0-7.814.418c-.86.23-1.538.908-1.768 1.768C0 6.746 0 10 0 10s0 3.254.418 4.814c.23.86.908 1.538 1.768 1.768C3.746 17 10 17 10 17s6.254 0 7.814-.418a2.504 2.504 0 0 0 1.768-1.768C20 13.254 20 10 20 10s0-3.254-.418-4.814z'></path>";
					m += "</svg>";
					m += "</span>";
					m += "<span class='etnhf-SocialNetworks-background' style='background-color:#ff0000;'></span>";
					m += "<span class='etnhf-SocialNetworks-colorfulCircle' style='border-color:#ff0000;'></span>";
					m += "<span class='etnhf-SocialNetworks-backgroundCircle'></span>";
				}
				else if("snapchat".equals(parseNull(rsf.value("name"))))
				{
					m += "<span>";
					m += "<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 20 20'>";
					m += "<path d='M5.829 4.533c-.6 1.344-.363 3.752-.267 5.436-.648.359-1.48-.271-1.951-.271-.49 0-1.075.322-1.167.802-.066.346.089.85 1.201 1.289.43.17 1.453.37 1.69.928.333.784-1.71 4.403-4.918 4.931-.251.041-.43.265-.416.519.056.975 2.242 1.357 3.211 1.507.099.134.179.7.306 1.131.057.193.204.424.582.424.493 0 1.312-.38 2.738-.144 1.398.233 2.712 2.215 5.235 2.215 2.345 0 3.744-1.991 5.09-2.215.779-.129 1.448-.088 2.196.058.515.101.977.157 1.124-.349.129-.437.208-.992.305-1.123.96-.149 3.156-.53 3.211-1.505.014-.254-.165-.477-.416-.519-3.154-.52-5.259-4.128-4.918-4.931.236-.557 1.252-.755 1.69-.928.814-.321 1.222-.716 1.213-1.173-.011-.585-.715-.934-1.233-.934-.527 0-1.284.624-1.897.286.096-1.698.332-4.095-.267-5.438-1.135-2.543-3.66-3.829-6.184-3.829-2.508 0-5.014 1.268-6.158 3.833z'/>";
					m += "</svg>";
					m += "</span>";
					m += "<span class='etnhf-SocialNetworks-background' style='background-color:#fffc00;'></span>";
					m += "<span class='etnhf-SocialNetworks-colorfulCircle' style='border-color:#fffc00;'></span>";
					m += "<span class='etnhf-SocialNetworks-backgroundCircle'></span>";
				}
				
				m += "</a>";
			}

			m += "</div>";
			m += "</div>";
			m += "</div>";
		}

		Set rsm = Etn.execute("select  * from "+proddb+"menu_items where menu_id = " + escape.cote(menuid) + " and menu_item_id = -20 order by coalesce(order_seq, 999999), id " );
		int i=0;

		m += "<div class='etnhf-HomeFooter-body'>";
		m += "<div class='etnhf-container'>";
		m += "<div class='etnhf-HomeFooter-body-top'>";

		java.util.Map<String, String> uls = new java.util.LinkedHashMap<String, String>();
		//default is 4 cols
		uls.put("0", "");
		uls.put("1", "");
		uls.put("2", "");
		uls.put("3", "");
		if(rsm.rs.Rows > 0)
		{
			int _rcnt = 0;
			int mTypeCount = 0;//counts must be global to keep unique class names
			int sbLevelOneCount = 0;//counts must be global to keep unique class names

			while(rsm.next())
			{
				if(!"1".equals(rsm.value("display_in_footer"))) continue;

				String mTypeCountClass = "__page_type_"+(mTypeCount++);

				String ulsIndex = "" + _rcnt % 4;
				_rcnt++; 
				
				String ulHtml = uls.get(ulsIndex);

				String pagetype = parseNull(rsm.value("display_name"));
				if(pagetype.length() == 0) pagetype = parseNull(rsm.value("name"));

				String mclick = parseNull(rsm.value("display_name"));
				if(mclick.length() == 0) mclick = parseNull(rsm.value("name"));

				String _u = cacheUtil.getExternalLink(parseNull(rsm.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);
				String _cls = getMenuItemClass(parseNull(rsm.value("open_as")));
				String _licls = "";
				String grandparentcls = "";
				if(parseNull(rsm.value("visible_to")).length() > 0)
				{
					_licls = " etnhf-d-none " + parseNull(rsm.value("visible_to")) + " ";
					grandparentcls = _licls;
				}

				String itemid = parseNull(rsm.value("id"));
				String _name = parseNull(rsm.value("footer_display_name"));
				if(_name.length() == 0) _name = parseNull(rsm.value("display_name"));
				if(_name.length() == 0) _name = parseNull(rsm.value("name"));

				Set rsm1 = Etn.execute("select  * from "+proddb+"menu_items where menu_id = " + escape.cote(menuid) + " and menu_item_id = "+escape.cote(itemid)+" order by coalesce(order_seq, 999999), id " );
				ulHtml += "<li>";

				ulHtml += "<div class='etnhf-HomeFooter-navSection'>";
				if(parseNull(rsm.value("prod_url")).length() > 0) ulHtml += "<a class='__page_type ___portalmenulink "+mTypeCountClass+" "+_cls+" etn-data-layer-event' data-dl_event_category='footer' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"' href='"+_u+"' >" + escapeCoteValue(_name) + "</a>";
				else ulHtml += "<a class='__page_type ___portalmenulink "+mTypeCountClass+" etn-data-layer-event' data-dl_event_category='footer' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"' href='javascript:void(0)'>" + escapeCoteValue(_name) + "</a>";
				ulHtml += "</div>";

				String extraUlHtml = "";
				if(parseNull(rsm.value("prod_url")).length() > 0)
				{
					String linklabel = parseNull(rsm.value("link_label"));
					if(linklabel.length() == 0) linklabel = parseNull(rsm.value("display_name"));
					if(linklabel.length() == 0) linklabel = parseNull(rsm.value("name"));

					extraUlHtml += "<li class='"+_licls+"'><a class='___portalmenulink "+_cls+"   etnhf-d-md-none  etn-data-layer-event' data-dl_event_category='footer' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(linklabel)+"' href='"+_u+"' >" + escapeCoteValue(linklabel) + "</a></li>";
				}							
				
				ulHtml += "<ul class='etnhf-HomeFooter-dropdown'>";
				if(rsm1.rs.Rows > 0)
				{
					while(rsm1.next())
					{
						String sbLevelOneClass = "__menu_sb1_" + (sbLevelOneCount++);
						mclick = parseNull(rsm1.value("display_name"));
						if(mclick.length() == 0) mclick = parseNull(rsm1.value("name"));

						_u = cacheUtil.getExternalLink(parseNull(rsm1.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);

						_name = parseNull(rsm1.value("footer_display_name"));
						if(_name.length() == 0) _name = parseNull(rsm1.value("display_name"));
						if(_name.length() == 0) _name = parseNull(rsm1.value("name"));

						String _cls1 = getMenuItemClass(parseNull(rsm1.value("open_as")));
						String _licls1 = "";
						String parentcls = grandparentcls;
						if(parseNull(rsm1.value("visible_to")).length() > 0)
						{
							parentcls = parentcls + " etnhf-d-none " + parseNull(rsm1.value("visible_to")) + " ";
							_licls1 = parentcls;
						}

						if("1".equals(rsm1.value("display_in_footer")))
						{
							ulHtml += "<li class='"+_licls1+"'><a class='__menu_sb1 "+sbLevelOneClass+" "+mTypeCountClass+" ___portalmenulink "+_cls1+" etn-data-layer-event' data-dl_event_category='footer' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"' href='"+_u+"' >"+escapeCoteValue(_name)+"</a></li>";
						}
						rsm2 = Etn.execute("select  * from "+proddb+"menu_items where menu_id = " + escape.cote(menuid) + " and menu_item_id = "+escape.cote(rsm1.value("id"))+" order by coalesce(order_seq, 999999), id " );
						while(rsm2.next())
						{
							if(parseNull(rsm2.value("prod_url")).length() > 0)
							{
								mclick = parseNull(rsm2.value("display_name"));
								if(mclick.length() == 0) mclick = parseNull(rsm2.value("name"));

								_u = cacheUtil.getExternalLink(parseNull(rsm2.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);

								_name = parseNull(rsm2.value("footer_display_name"));
								if(_name.length() == 0) _name = parseNull(rsm2.value("display_name"));
								if(_name.length() == 0) _name = parseNull(rsm2.value("name"));

								String _cls2 = getMenuItemClass(parseNull(rsm2.value("open_as")));
								String _licls2 = parentcls;
								if(parseNull(rsm2.value("visible_to")).length() > 0)
								{
									_licls2 = _licls2 + " etnhf-d-none " + parseNull(rsm2.value("visible_to")) + " ";
								}

								if("1".equals(rsm2.value("display_in_footer")))
								{
									ulHtml += "<li class='"+_licls2+"'><a class='__menu_sb2 "+sbLevelOneClass+" ___portalmenulink "+_cls2+" etn-data-layer-event' data-dl_event_category='footer' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"' href='"+_u+"' >"+escapeCoteValue(_name)+"</a></li>";
								}
							}
						}
					}//while
				}//if
				
				ulHtml += extraUlHtml;				
				ulHtml += "</ul>";//etnhf-HomeFooter-dropdown
				ulHtml += "</li>";
				i++;
				uls.put(ulsIndex, ulHtml);
			}

			m += "<div class='etnhf-row'>";
			for(String idx : uls.keySet())
			{
				String ulHtml = uls.get(idx);
				if(ulHtml.length() == 0) continue;

				m += "<div class='etnhf-col'>";
				m += "<ul>" + ulHtml + "</ul>";
				m += "</div>";//etnhf-col
			}
			m += "</div>";//etnhf-row
		}
		m += "</div>";//etnhf-HomeFooter-body-top

		rsm = Etn.execute("select  * from "+proddb+"menu_items where display_in_footer = 1 and menu_id = " + escape.cote(menuid) + " and menu_item_id = -30 and coalesce(default_selected,0) = 0 order by coalesce(order_seq, 999999), id " );
		if(rsm.rs.Rows > 0)
		{
			m += "<div class='etnhf-HomeFooter-body-bottom'>";
			while(rsm.next())
			{
				String mclick = parseNull(rsm.value("display_name"));
				if(mclick.length() ==0) mclick = parseNull(rsm.value("name"));

				String _u = cacheUtil.getExternalLink(parseNull(rsm.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);

				String _cls = getMenuItemClass(parseNull(rsm.value("open_as")));
				String _licls = "";
				if(parseNull(rsm.value("visible_to")).length() > 0)
				{
					_licls = " etnhf-d-none " + parseNull(rsm.value("visible_to")) + " ";
				}

				String _name = parseNull(rsm.value("footer_display_name"));
				if(_name.length() == 0) _name = parseNull(rsm.value("display_name"));
				if(_name.length() == 0) _name = parseNull(rsm.value("name"));

				m += "<a class='etnhf-HomeFooter-body-bottom-link1 ___portalmenulink "+_cls+" "+_licls+" etn-data-layer-event' data-dl_event_category='footer' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"' href='"+_u+"'>";
				if(parseNull(rsm.value("menu_photo")).length() > 0) m += "<img src='"+menuimagespath+parseNull(rsm.value("menu_photo"))+"' alt='"+escapeCoteValue(_name)+"'>";
				m += escapeCoteValue(_name)+"</a>";
			}
			m += "</div>";
		}

		m += "</div>";//container
		m += "</div>";//etnhf-HomeFooter-body

		rsm = Etn.execute("select  * from "+proddb+"menu_items where menu_id = " + escape.cote(menuid) + " and menu_item_id = -10 order by coalesce(order_seq, 999999), id " );
		if(rsm.rs.Rows > 0)
		{
			m += "<div class='etnhf-HomeFooter-foot'>";
			m += "<div class='etnhf-container'>";
			while(rsm.next())
			{
				String mclick = parseNull(rsm.value("display_name"));
				if(mclick.length() ==0) mclick = parseNull(rsm.value("name"));

				String _u = cacheUtil.getExternalLink(parseNull(rsm.value("prod_url")), menuid, Etn, menuPublishPath, siteid, cachedResourcesFolder);
				String _cls = getMenuItemClass(parseNull(rsm.value("open_as")));
				String _licls = "";
				if(parseNull(rsm.value("visible_to")).length() > 0)
				{
					_licls = " etnhf-d-none " + parseNull(rsm.value("visible_to")) + " ";
				}

				String _name = parseNull(rsm.value("footer_display_name"));
				if(_name.length() == 0) _name = parseNull(rsm.value("display_name"));
				if(_name.length() == 0) _name = parseNull(rsm.value("name"));

				m += "<a class='___portalmenulink "+_cls+" "+_licls+" etn-data-layer-event' data-dl_event_category='footer' data-dl_event_action='button_click' data-dl_event_label='"+escapeCoteValue(_name)+"' href='"+_u+"'>"+escapeCoteValue(_name)+"</a>";
			}
			m += "</div>";//container
			m += "</div>";//o-footer-bottom
		}

		m += "</div>";

		return m;

	}

	private int refreshBreadcrumbs(ClientSql etn, int wkid, String clid)
	{
		//breadcrumbs are only implemented in production so we always set isprod flag true here
		String proddb = env.getProperty("PROD_DB");
		try
		{			
			etn.executeCmd("delete from "+proddb+".crawler_errors where menu_id = " + escape.cote(clid));
			
			com.etn.moringa.BreadCrumbs br = new com.etn.moringa.BreadCrumbs(etn, env, true, true, false);
			br.updateHtmls(clid);
		    ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch(Exception e)
		{
			etn.executeCmd("insert into "+proddb+".crawler_errors (menu_id, err) values("+escape.cote(clid)+",'Publish::Error refreshing breadcrumbs') ");
			e.printStackTrace();
			return -1;
		}
	}

	private int publishMenu(ClientSql etn, int wkid, String clid)
	{
		Set rs = etn.execute("Select * from site_menus where id = " + escape.cote(clid));
		if(rs.rs.Rows == 0) return -1;
		rs.next();
		
		if("v2".equalsIgnoreCase(rs.value("menu_version"))) return publishV2Menu(etn, wkid, clid);
		return publishV1Menu(etn, wkid, clid);
	}
		
	private int publishV1Menu(ClientSql etn, int wkid, String clid)
	{
		log("In publishV1Menu");
		String proddb = env.getProperty("PROD_DB");
		try 
		{
			Set rs = etn.execute("Select * from site_menus where id = " + escape.cote(clid));
			if(rs.rs.Rows == 0) return -1;

			int rows = 0;			
			rs.next();
			String siteid = rs.value("site_id");
			String menulang = parseNull(rs.value("lang"));
			
			Set rsLang = etn.execute("select * from language where langue_code = "+escape.cote(menulang));
			rsLang.next();
			String langueId = rsLang.value("langue_id");

			rs = etn.execute("select * from sites where id = " + escape.cote(siteid));
			rows += Util.insertUpdate(etn, rs, "sites", env);

			rs = etn.execute("Select * from site_menus where id = " + escape.cote(clid));
			rows += Util.insertUpdate(etn, rs, "site_menus", env);
			rs.moveFirst();

			String jsscriptfilename = ascii7(parseNull(rs.value("javascript_filename"))).replace(" ","-");
			if(parseNull(rs.value("logo_file")).length() > 0)
			{
				Process proc = Runtime.getRuntime().exec(env.getProperty("COPY_SCRIPT") + " " + parseNull(rs.value("logo_file")) + " " + env.getProperty("MENU_IMAGES_FOLDER") + " " + env.getProperty("PROD_MENU_IMAGES_FOLDER")  );
				int r = proc.waitFor();					
			}
			if(parseNull(rs.value("small_logo_file")).length() > 0)
			{
				Process proc = Runtime.getRuntime().exec(env.getProperty("COPY_SCRIPT") + " " + parseNull(rs.value("small_logo_file")) + " " + env.getProperty("MENU_IMAGES_FOLDER") + " " + env.getProperty("PROD_MENU_IMAGES_FOLDER")  );
				int r = proc.waitFor();					
			}
			if(parseNull(rs.value("favicon")).length() > 0)
			{
				Process proc = Runtime.getRuntime().exec(env.getProperty("COPY_SCRIPT") + " " + parseNull(rs.value("favicon")) + " " + env.getProperty("MENU_IMAGES_FOLDER") + " " + env.getProperty("PROD_MENU_IMAGES_FOLDER")  );
				int r = proc.waitFor();					
			}

			rs = etn.execute("Select * from menu_items where menu_id = " + escape.cote(clid));
			rows += Util.insertUpdate(etn, rs, "menu_items", env);
			rs.moveFirst();
			while(rs.next())
			{
				if(parseNull(rs.value("menu_photo")).length() > 0)
				{
					Process proc = Runtime.getRuntime().exec(env.getProperty("COPY_SCRIPT") + " " + parseNull(rs.value("menu_photo")) + " " + env.getProperty("MENU_IMAGES_FOLDER") + " " + env.getProperty("PROD_MENU_IMAGES_FOLDER")  );
					int r = proc.waitFor();					
					rows ++;
				}
				if(parseNull(rs.value("menu_icon")).length() > 0)
				{
					Process proc = Runtime.getRuntime().exec(env.getProperty("COPY_SCRIPT") + " " + parseNull(rs.value("menu_icon")) + " " + env.getProperty("MENU_IMAGES_FOLDER") + " " + env.getProperty("PROD_MENU_IMAGES_FOLDER")  );
					int r = proc.waitFor();					
					rows ++;
				}
			}
			etn.executeCmd("delete from "+proddb+".menu_items where menu_id = "+escape.cote(clid)+" and id not in (select id from menu_items where menu_id = " +escape.cote(clid)+" ) ");

			//if prod_apply_to is not given it means preprod apply_to and prod_apply_to are same
			//we are not selecting cache, cache_refresh_interval, cache_refresh_on at time of publish as prod will have its own settings for cache
			//we are not suppose to publish cache rules from preprod to prod
			rs = etn.execute("select add_gtm_script, id, menu_id, apply_type, apply_to, replace_tags, case coalesce(prod_apply_to,'') when '' then apply_to else prod_apply_to end as prod_apply_to from menu_apply_to where menu_id = " + escape.cote(clid));
			rows += Util.insertUpdate(etn, rs, "menu_apply_to", env);
			etn.executeCmd("delete from "+proddb+".menu_apply_to where menu_id = "+escape.cote(clid)+" and id not in (select id from menu_apply_to where menu_id = " +escape.cote(clid)+ " ) ");
			//we always enable the cache for 127.0.0.1 for production as users always forget to enable it
			etn.executeCmd("update "+proddb+".menu_apply_to set cache = 1 where menu_id = "+escape.cote(clid)+" and apply_type = 'url_starting_with' and apply_to = '127.0.0.1' ");
			

			rs = etn.execute("Select * from additional_menu_items where menu_id = " + escape.cote(clid));
			rows += Util.insertUpdate(etn, rs, "additional_menu_items", env);
			etn.executeCmd("delete from "+proddb+".additional_menu_items where menu_id = "+escape.cote(clid)+" and id not in (select id from additional_menu_items where menu_id = " +escape.cote(clid)+ " ) ");

			etn.executeCmd("delete from "+proddb+".menu_click_rules where menu_id = " + escape.cote(clid));
			rs = etn.execute("select * from menu_click_rules where menu_id = " + escape.cote(clid));
			rows += Util.insertUpdate(etn, rs, "menu_click_rules", env);

			etn.executeCmd("delete from "+proddb+".co_form_settings where site_id = "+escape.cote(siteid));
			rs = etn.execute("select * from co_form_settings where site_id = "+escape.cote(siteid));
			rows += Util.insertUpdate(etn, rs, "co_form_settings", env);
						
			rows += Util.publishShopParameters(etn, siteid, env);
			rows += Util.publishStickers(etn, siteid, env);
			rows += Util.publishAlgoliaSettings(etn, siteid, langueId, env);
			publishingIdcheckConfig(etn, siteid);
			Set _rs1 = etn.execute("Select menu_id from "+proddb+".site_menu_htmls where menu_id = " + escape.cote(clid));
			if(_rs1.rs.Rows == 0)//first time publishing of menu
			{
				etn.executeCmd("insert into "+proddb+".site_menu_htmls (menu_id) values ("+escape.cote(clid)+") ");
			}
			
			String headerhtml = generateHeader(etn, clid);
			String footerhtml = generateFooter(etn, clid);
			
			rows += etn.executeCmd("update "+proddb+".site_menu_htmls set tmp_header_html = '', tmp_footer_html = '', header_html = "+escape.cote(headerhtml)+", footer_html = "+escape.cote(footerhtml)+" where menu_id = " + clid);
			
			if(rows > 0)
			{
				//not marking all pages as refresh_now ... instead after menu publish call the crawler to refresh cache .. and then call the url replacer to fix the urls
				etn.executeCmd("update "+proddb+".cached_pages set refresh_now = 0, cached = 0, last_time_url_active = is_url_active, is_url_active = 0 where menu_id =  " + escape.cote(clid));

				try
				{
					log("Publish::Going to call crawler for menu id : " + clid);

					boolean debug =  env.get("DEBUG")!=null || env.get("SCHED_DEBUG") != null;

					CacheUtil cacheUtil = new CacheUtil(env, true, debug);		
					String currentMenuPath = cacheUtil.getMenuPath(etn, clid);		
					
					etn.executeCmd("delete from "+proddb+".crawler_errors where menu_id = " + escape.cote(clid));
					etn.executeCmd("update "+proddb+".crawler_audit set status = 2 where menu_id = " + escape.cote(clid));
					
					Crawler crawler = new Crawler(etn, env, true, debug);
					crawler.start(clid);


					//after crawler does it work we need to generate a javascript url for published menu which actually be called by external sites to load our menu
					if(jsscriptfilename.length() > 0)
					{													
						if(!jsscriptfilename.toLowerCase().endsWith(".js")) jsscriptfilename = jsscriptfilename + ".js";

						Set rss = etn.execute("select * from "+proddb+".sites where id = " + escape.cote(siteid));
						rss.next();
		
						Set rsmenu = etn.execute("select * from "+proddb+".site_menus where id = " + escape.cote(clid));
						rsmenu.next(); 
						
						String extraJsToLoad = rsmenu.value("extra_js_mjs");//semi colon seperated list
						
						Set rsHtmls = etn.execute("select header_html_1, footer_html_1 from "+proddb+".site_menu_htmls where menu_id = " + escape.cote(clid));
						rsHtmls.next();

						String sitedomain = parseNull(rss.value("domain"));
						if(sitedomain.endsWith("/")) sitedomain = sitedomain.substring(0, sitedomain.lastIndexOf("/"));
						String menurespath = parseNull(env.getProperty("PROD_MENU_RESOURCES_URL"));
							
						String mjs = "(function() {\n";
						int _tab = 1;
						mjs += appendTabs(_tab) + "var $prereqs = (" + "\n";
						_tab++;
						mjs += appendTabs(_tab) + "'<style>html { font-size:16px !important; } </style>' +" + "\n";
						mjs += appendTabs(_tab) + "'<link href=\""+sitedomain+menurespath+"css/newui/headerfooter.css?__v="+env.getProperty("CSS_JS_VERSION")+"\" rel=\"stylesheet\" type=\"text/css\">' " + "\n";

						if("1".equals(parseNull(rsmenu.value("show_search_bar"))) && "external".equals(parseNull(rsmenu.value("search_api"))) )
						{
							mjs += appendTabs(_tab) + "+ '<link rel=\"stylesheet\" href=\"https://img.ke.woopic.com/resources/external/emea/completion/v4-0/sources/css/completion.min.css\"> ' " + "\n";
						}
						_tab--;
						mjs += appendTabs(_tab) + ");\n\n";

						//min version of header which will just have the top most menu bar
						String mjsmin = mjs;

						headerhtml = parseNull(rsHtmls.value("header_html_1"));
						footerhtml = parseNull(rsHtmls.value("footer_html_1"));
	
						org.jsoup.nodes.Document doc = Jsoup.parse(headerhtml);
						org.jsoup.select.Elements eles = doc.select("a[href]");					
						for(org.jsoup.nodes.Element ele : eles)
						{
							String _r = ele.attr("href");
							//url starting with double slash is normally the logo url where we dont give the http or https and double slash picks it from browser
							//so we ignore these urls also
							if(_r.toLowerCase().startsWith("javascript:") || _r.toLowerCase().startsWith("#") || _r.startsWith("//")) continue;
							if(_r.startsWith("/"))
							{
								_r = sitedomain + _r;
								ele.attr("href", _r);
							}
						}
	
						eles = doc.select("img[src]");					
						for(org.jsoup.nodes.Element ele : eles)
						{
							String _r = ele.attr("src");
							if(_r.toLowerCase().startsWith("data:")) continue;
							if(_r.startsWith("/"))
							{
								_r = sitedomain + _r;
								ele.attr("src", _r);
							}
						}
						eles = doc.select("span[data-hf-svg]");					
						for(org.jsoup.nodes.Element ele : eles)
						{
							String _r = ele.attr("data-hf-svg");
							if(_r.startsWith("/"))
							{
								_r = sitedomain + _r;
								ele.attr("data-hf-svg", _r);
							}
						}

						eles = doc.select("header#etn-portal-header");
						if(eles != null) headerhtml = eles.first().toString();

						//initializing top bar headerhtml
						String headerhtmltop = headerhtml;

						headerhtml = headerhtml.replace("'","\\\'").replace("\t"," ").replace("\n", " ");	
						
						mjs += appendTabs(_tab) + "var $headermenu = (" + "\n";
						_tab++;
						mjs += appendTabs(_tab) + "'" + headerhtml + "' \n";

/*						doc = Jsoup.parse(headerhtmltop);
						eles = doc.select("div#o-secondtopmenu");
						if(eles != null) eles.remove();

						eles = doc.select("header#etn-mosse-header");
						if(eles != null) headerhtmltop = eles.first().toString();

						headerhtmltop = headerhtmltop.replace("'","\\\'").replace("\t"," ").replace("\n", " ");	
						mjsmin += appendTabs(_tab) + "'" + headerhtmltop + "' \n";*/

						// so far we are not sure what mjsmin will have so adding complete header to it as well
						mjsmin += appendTabs(_tab) + "'" + headerhtml + "' \n";

						_tab--;
						mjs += appendTabs(_tab) + "); \n\n";
						mjsmin += appendTabs(_tab) + "); \n\n";


						//footer starts
						doc = Jsoup.parse(footerhtml);
						eles = doc.select("a[href]");					
						for(org.jsoup.nodes.Element ele : eles)
						{
							String _r = ele.attr("href");
							if(_r.toLowerCase().startsWith("javascript:") || _r.toLowerCase().startsWith("#")) continue;
							if(_r.startsWith("/"))
							{
								_r = sitedomain + _r;
								ele.attr("href", _r);
							}
						}		

						eles = doc.select("img[src]");					
						for(org.jsoup.nodes.Element ele : eles)
						{
							String _r = ele.attr("src");
							if(_r.toLowerCase().startsWith("data:")) continue;
							if(_r.startsWith("/"))
							{
								_r = sitedomain + _r;
								ele.attr("src", _r);
							}
						}
						eles = doc.select("span[data-hf-svg]");					
						for(org.jsoup.nodes.Element ele : eles)
						{
							String _r = ele.attr("data-hf-svg");
							if(_r.startsWith("/"))
							{
								_r = sitedomain + _r;
								ele.attr("data-hf-svg", _r);
							}
						}

						eles = doc.select("div#etn-portal-footer");
						if(eles != null && eles.size() > 0) footerhtml = eles.first().toString();
						footerhtml = footerhtml.replace("'","\\\'").replace("\t"," ").replace("\n", " ");

	
						mjs += appendTabs(_tab) + "var $footermenu = (" + "\n";
						_tab++;
						mjs += appendTabs(_tab) + "'"+footerhtml+"'" + "\n";
						_tab--;
						mjs += appendTabs(_tab) + "); \n\n";

						//mjs += appendTabs(_tab) + "$(\"#mosse-header\").append( $headermenu ); \n\n";					
						//mjsmin += appendTabs(_tab) + "$(\"#mosse-header\").append( $headermenu ); \n\n";					

						mjs += appendTabs(_tab) + "if(document.getElementById(\"mosse-header\")) document.getElementById(\"mosse-header\").innerHTML =  $prereqs + $headermenu ; \n\n";					
						mjsmin += appendTabs(_tab) + "if(document.getElementById(\"mosse-header\")) document.getElementById(\"mosse-header\").innerHTML = $prereqs + $headermenu ; \n\n";					

						mjs += appendTabs(_tab) + "if(document.getElementById(\"mosse-footer\")) { if(document.getElementById(\"mosse-header\")) { document.getElementById(\"mosse-footer\").innerHTML = $footermenu ;} else { document.getElementById(\"mosse-footer\").innerHTML = $prereqs + $footermenu ;}} \n\n";

						mjs += appendTabs(_tab) + "var script = document.createElement(\"script\");  \n";
						mjs += appendTabs(_tab) + "script.type  = \"text/javascript\";   \n";

						String _searchVars = "";
						if("1".equals(parseNull(rsmenu.value("show_search_bar")))  && "url".equals(parseNull(rsmenu.value("search_api"))) )
						{
							String __searchUrl = parseNull(rsmenu.value("search_bar_url"));
							if(!__searchUrl.toLowerCase().startsWith("http:") && !__searchUrl.toLowerCase().startsWith("https:"))
							{
								if(!__searchUrl.toLowerCase().startsWith("/")) __searchUrl = currentMenuPath + __searchUrl;
								__searchUrl = sitedomain + __searchUrl;
							}
							_searchVars = " var ____searchurl = '"+__searchUrl+"'; var ____searchparam = '"+parseNull(rsmenu.value("search_params"))+"'; ";
						}
						
						mjs += appendTabs(_tab) + "script.text = \" "+_searchVars+" var ______portalurl2 = '"+env.getProperty("PROD_PORTAL_ENTRY_URL")+"'; var ______portalurl = '"+env.getProperty("PROD_EXTERNAL_LINK")+"';\";  \n";
						mjs += appendTabs(_tab) + "document.body.appendChild(script);  \n\n";

/*						mjs += appendTabs(_tab) + "var script = document.createElement(\"script\"); \n";
						mjs += appendTabs(_tab) + "script.type = \"text/javascript\"; \n";
						mjs += appendTabs(_tab) + "script.src = \""+sitedomain+menurespath+"js/newui/portalbundle.js\"; \n";
						mjs += appendTabs(_tab) + "document.body.appendChild(script); \n\n";*/

						mjs += appendTabs(_tab) + "var script = document.createElement(\"script\");  \n";
						mjs += appendTabs(_tab) + "script.type  = \"text/javascript\";   \n";
						mjs += appendTabs(_tab) + "script.text = \"var __loadWithNoConflict = false; if(typeof window.jQuery != 'undefined') __loadWithNoConflict = true;\";  \n";
						mjs += appendTabs(_tab) + "document.body.appendChild(script);  \n\n";

/*						mjs += appendTabs(_tab) + "var script = document.createElement(\"script\");  \n";
						mjs += appendTabs(_tab) + "script.type  = \"text/javascript\";   \n";
						mjs += appendTabs(_tab) + "script.text = \"var ___portaljquery = $;\";  \n";
						mjs += appendTabs(_tab) + "document.body.appendChild(script);  \n\n";
*/
						//callback for loading scripts in a sequence
						mjs += "\n" + appendTabs(_tab) + "var script = document.createElement(\"script\");  \n";
						mjs += appendTabs(_tab) + "script.type  = \"text/javascript\";  \n";
						mjs += appendTabs(_tab) + "script.text = \"function portalLoadScripts(array,callback){\\nvar loader = function(src,handler){\\nvar script = document.createElement('script');\\nscript.src = src;\\nscript.onload = script.onreadystatechange = function(){\\nscript.onreadystatechange = script.onload = null;\\nhandler();\\n}\\nvar head = document.getElementsByTagName('head')[0];\\n(head || document.body).appendChild( script );\\n};\\n(function run(){\\nif(array.length!=0){\\nloader(array.shift(), run);\\n}else{\\ncallback && callback();\\n}\\n})();\\n};\";\n";
						mjs += appendTabs(_tab) + "document.body.appendChild(script);  \n\n";
						
						List<String> mjsscripts0 = new ArrayList<String>();
						mjsscripts0.add(sitedomain+menurespath+"js/newui/portalbundle.js?__v="+env.getProperty("CSS_JS_VERSION"));
						
						List<String> mjsscripts = new ArrayList<String>();
						mjsscripts.add(sitedomain+menurespath+"js/newui/headerfooterbundle.js?__v="+env.getProperty("CSS_JS_VERSION"));
							
						mjsmin += appendTabs(_tab) + "var script = document.createElement(\"script\");  \n";
						mjsmin += appendTabs(_tab) + "script.type  = \"text/javascript\";   \n";
						mjsmin += appendTabs(_tab) + "script.text = \" "+"+_searchVars+" +" var ______portalurl2 = '"+env.getProperty("PROD_PORTAL_ENTRY_URL")+"'; var ______portalurl = '"+env.getProperty("PROD_EXTERNAL_LINK")+"';\";  \n";
						mjsmin += appendTabs(_tab) + "document.body.appendChild(script);  \n\n";

/*						mjsmin += appendTabs(_tab) + "var script = document.createElement(\"script\"); \n";
						mjsmin += appendTabs(_tab) + "script.type = \"text/javascript\"; \n";
						mjsmin += appendTabs(_tab) + "script.src = \""+sitedomain+menurespath+"js/newui/portalbundle.js\"; \n";
						mjsmin += appendTabs(_tab) + "document.body.appendChild(script); \n\n";*/

						mjsmin += appendTabs(_tab) + "var script = document.createElement(\"script\");  \n";
						mjsmin += appendTabs(_tab) + "script.type  = \"text/javascript\";   \n";
						mjsmin += appendTabs(_tab) + "script.text = \"var __loadWithNoConflict = false; if(typeof window.jQuery != 'undefined') __loadWithNoConflict = true;\";  \n";
						mjsmin += appendTabs(_tab) + "document.body.appendChild(script);  \n\n";

/*						mjsmin += appendTabs(_tab) + "var script = document.createElement(\"script\");  \n";
						mjsmin += appendTabs(_tab) + "script.type  = \"text/javascript\";   \n";
						mjsmin += appendTabs(_tab) + "script.text = \"var ___portaljquery = $;\";  \n";
						mjsmin += appendTabs(_tab) + "document.body.appendChild(script);  \n\n";*/
	
						//callback for loading scripts in a sequence
						mjsmin += "\n" + appendTabs(_tab) + "var script = document.createElement(\"script\");  \n";
						mjsmin += appendTabs(_tab) + "script.type  = \"text/javascript\";  \n";
						mjsmin += appendTabs(_tab) + "script.text = \"function portalLoadScripts(array,callback){\\nvar loader = function(src,handler){\\nvar script = document.createElement('script');\\nscript.src = src;\\nscript.onload = script.onreadystatechange = function(){\\nscript.onreadystatechange = script.onload = null;\\nhandler();\\n}\\nvar head = document.getElementsByTagName('head')[0];\\n(head || document.body).appendChild( script );\\n};\\n(function run(){\\nif(array.length!=0){\\nloader(array.shift(), run);\\n}else{\\ncallback && callback();\\n}\\n})();\\n};\";\n";
						mjsmin += appendTabs(_tab) + "document.body.appendChild(script);  \n\n";

						List<String> mjsminscripts0 = new ArrayList<String>();
						mjsminscripts0.add(sitedomain+menurespath+"js/newui/portalbundle.js?__v="+env.getProperty("CSS_JS_VERSION"));
						
						List<String> mjsminscripts = new ArrayList<String>();
						mjsminscripts.add(sitedomain+menurespath+"js/newui/headerfooterbundle.js?__v="+env.getProperty("CSS_JS_VERSION"));
						
						String callbackfunction = "function(){ window.document.dispatchEvent(new Event('moringa.loadmenu', {bubbles: true, cancelable: true}));";												
						if("1".equals(parseNull(rsmenu.value("show_search_bar")))  && "external".equals(parseNull(rsmenu.value("search_api"))) )
						{
							callbackfunction += " var dsearch = new OrangeSearch(); dsearch.__initCompleter('"+parseNull(rsmenu.value("search_completion_url"))+"','"+parseNull(rsmenu.value("search_params"))+"','"+parseNull(rsmenu.value("search_bar_url"))+"','moringadesktopsearchfield'); var msearch = new OrangeSearch(); msearch.__initCompleter('"+parseNull(rsmenu.value("search_completion_url"))+"','"+parseNull(rsmenu.value("search_params"))+"','"+parseNull(rsmenu.value("search_bar_url"))+"','moringamobilesearchfield');";
						}
						callbackfunction += "___portaljquery('.o-topbar').each(function(){";
						callbackfunction += "___portaljquery(this).attr('data-lf-top-fixed','');";
						callbackfunction += "});";

						callbackfunction += "___portaljquery('.o-navbar').each(function(){";
						callbackfunction += "___portaljquery(this).attr('data-lf-top-fixed','');";
						callbackfunction += "});";
						
						callbackfunction += " }";

						if("1".equals(parseNull(rsmenu.value("show_search_bar")))  && "external".equals(parseNull(rsmenu.value("search_api"))) )
						{
							mjsscripts.add("https://img.ke.woopic.com/resources/external/emea/completion/v4-0/sources/js/completion.min.js");
						}
						
						if(extraJsToLoad.length() > 0)
						{
							String[] extraJsToLoadList = extraJsToLoad.split(";");
							if(extraJsToLoadList != null)
							{
								for(String _extraJs : extraJsToLoadList)
								{
									if(parseNull(_extraJs).length() > 0)
									{
										if(_extraJs.indexOf("?") > -1) _extraJs += "&";
										else _extraJs += "?";
										_extraJs += "__tm="+System.currentTimeMillis();
										mjsscripts.add(parseNull(_extraJs));
										mjsminscripts0.add(parseNull(_extraJs));
									}
								}
							}
						}						
						
						String callbackfunction0 = " function(){ if(__loadWithNoConflict) { ___portaljquery = $.noConflict(true); } else { ___portaljquery = window.jQuery; } ";
						callbackfunction0 += "portalLoadScripts([";
						int cnt = 0;
						for(String mjsscript : mjsscripts)
						{
							if(cnt++ > 0) callbackfunction0 += ",";
							callbackfunction0 += "'" + mjsscript + "'";
						}
						callbackfunction0 += "],"+callbackfunction+");} ";												

						mjs += appendTabs(_tab) + "var script = document.createElement(\"script\");  \n";
						mjs += appendTabs(_tab) + "script.type  = \"text/javascript\";  \n";
						mjs += appendTabs(_tab) + "script.text = \"portalLoadScripts([";
						cnt = 0;
						for(String mjsscript : mjsscripts0)
						{
							if(cnt++ > 0) mjs += ",";
							mjs += "'" + mjsscript + "'";
						}
						mjs += "],"+callbackfunction0+");\";  \n";
						mjs += appendTabs(_tab) + "document.body.appendChild(script);  \n";

						mjsmin += appendTabs(_tab) + "var script = document.createElement(\"script\");  \n";
						mjsmin += appendTabs(_tab) + "script.type  = \"text/javascript\";  \n";
						mjsmin += appendTabs(_tab) + "script.text = \"portalLoadScripts([";
						cnt = 0;
						for(String mjsscript : mjsminscripts0)
						{
							if(cnt++ > 0) mjsmin += ",";
							mjsmin += "'" + mjsscript + "'";
						}
						mjsmin += "],"+callbackfunction0+");\";  \n";

						mjs += appendTabs(_tab) + "\nconst hpurl = document.currentScript.getAttribute('data-hp_url');  \n";
						mjs += appendTabs(_tab) + "if(hpurl && document.getElementById('___portalhomepagelink')) document.getElementById('___portalhomepagelink').setAttribute('href', hpurl);  \n";

						mjsmin += appendTabs(_tab) + "\nconst hpurl = document.currentScript.getAttribute('data-hp_url');  \n";
						mjsmin += appendTabs(_tab) + "if(hpurl && document.getElementById('___portalhomepagelink')) document.getElementById('___portalhomepagelink').setAttribute('href', hpurl);  \n";

						mjs += "\n})();\n";
						mjsmin += "\n})();\n";
				
						mjsmin = mjs;//with new menu structure we are not yet sure how to generate the minimum header
							
						String menujspath = parseNull(env.getProperty("PROD_MENU_JS_PATH"));

						FileOutputStream fout = null;
						try
						{
							fout = new FileOutputStream (menujspath + jsscriptfilename);
							fout.write(mjs.getBytes("UTF-8"));
							fout.flush();	
						}
						catch(Exception e)
						{
							etn.executeCmd("insert into "+proddb+".crawler_errors (menu_id, err) values("+escape.cote(clid)+",'Publish::Error saving js file') ");
							e.printStackTrace();
						}					
						finally
						{
							if(fout != null) fout.close();
						}

						fout = null;
						try
						{
							fout = new FileOutputStream (menujspath + "top-" + jsscriptfilename);
							fout.write(mjsmin.getBytes("UTF-8"));
							fout.flush();	
						}
						catch(Exception e)
						{
							etn.executeCmd("insert into "+proddb+".crawler_errors (menu_id, err) values("+escape.cote(clid)+",'Publish::Error saving js file') ");
							e.printStackTrace();
						}					
						finally
						{
							if(fout != null) fout.close();
						}

					}
				}
				catch(Exception e)
				{
					etn.executeCmd("insert into "+proddb+".crawler_errors (menu_id, err) values("+escape.cote(clid)+",'Publish::Error crawling site') ");
					e.printStackTrace();
				}
			}
		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) 
		{ 
			etn.executeCmd("insert into "+proddb+".crawler_errors (menu_id, err) values("+escape.cote(clid)+",'Publish::Error crawling site') ");
			e.printStackTrace(); return(-1); 
		}
	}

	private int publishingIdcheckConfig(ClientSql etn, String site_id)
	{
		String proddb = env.getProperty("PROD_DB");
		System.out.println("Publishing IDcheck configurations for site ID : "+site_id);
		etn.execute("DELETE FROM " + proddb + ".idcheck_config_wordings where config_id=(SELECT id FROM idcheck_configurations WHERE site_id="+ escape.cote(site_id)+" )");
		etn.execute("DELETE FROM " + proddb + ".idcheck_configurations where site_id="+ escape.cote(site_id));
		etn.execute("DELETE FROM " + proddb + ".idcheck_doc_capture_conf where idcheck_iframe_conf_id=(SELECT id FROM idcheck_iframe_conf WHERE site_id="+ escape.cote(site_id)+" )");
		etn.execute("DELETE FROM " + proddb + ".idcheck_iframe_conf where site_id="+ escape.cote(site_id));

		int rows = 0;

		Set rs = etn.execute("SELECT * FROM idcheck_config_wordings where config_id = (SELECT id FROM idcheck_configurations WHERE site_id="+ escape.cote(site_id)+" )");
		rows += Util.insertUpdate(etn, rs, "idcheck_config_wordings", env);	

		rs = etn.execute("SELECT * FROM idcheck_configurations where site_id="+ escape.cote(site_id));
		rows += Util.insertUpdate(etn, rs, "idcheck_configurations", env);	

		rs = etn.execute("SELECT * FROM idcheck_doc_capture_conf where idcheck_iframe_conf_id = (SELECT id FROM idcheck_iframe_conf WHERE site_id="+ escape.cote(site_id)+" )");
		rows += Util.insertUpdate(etn, rs, "idcheck_doc_capture_conf", env);	

		rs = etn.execute("SELECT * FROM idcheck_iframe_conf where site_id="+ escape.cote(site_id));
		rows += Util.insertUpdate(etn, rs, "idcheck_iframe_conf", env);	

		System.out.println("Published IDcheck configurations ");
		return rows;
	}
	
	private void publishMenuJs(ClientSql etn, String siteid, String lang)
	{
		try
		{
			System.out.println("in publishMenuJs");
			String pagesdb = env.getProperty("PAGES_DB");
			//fetching green rows only
			String qr = "select * from "+pagesdb+".menu_js where site_id = "+escape.cote(siteid)+" and publish_status = 'published' and updated_ts < published_ts ";
			System.out.println(qr);
			Set rs = etn.execute(qr);
			if(rs != null && rs.rs.Rows > 0)
			{
				String apiUrl = parseNull(env.getProperty("INTERNAL_CALL_LINK")) + env.getProperty("PAGES_WEBAPP_URL") 
								+ "api/publishMenuJs.jsp?requestType=clearcache&siteid="+siteid+"&lang="+lang;

				while(rs.next())
				{
					apiUrl += "&ids="+rs.value("id");
				}
				
				Util.callApi(apiUrl, "GET", "");
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
	}

	private int publishV2Menu(ClientSql etn, int wkid, String clid)
	{
		log("In publishV2Menu");
		String proddb = env.getProperty("PROD_DB");
		try 
		{
			Set rs = etn.execute("Select * from site_menus where id = " + escape.cote(clid));
			if(rs.rs.Rows == 0) return -1;

			int rows = 0;			
			rs.next();
			String siteid = rs.value("site_id");
			String menulang = parseNull(rs.value("lang"));
			
			Set rsLang = etn.execute("select * from language where langue_code = "+escape.cote(menulang));
			rsLang.next();
			String langueId = rsLang.value("langue_id");

			rs = etn.execute("select * from sites where id = " + escape.cote(siteid));
			rows += Util.insertUpdate(etn, rs, "sites", env);

			rs = etn.execute("Select * from site_menus where id = " + escape.cote(clid));
			rows += Util.insertUpdate(etn, rs, "site_menus", env);
			rs.moveFirst();

			rs = etn.execute("Select * from sites_details where site_id = " + escape.cote(siteid) + " and langue_id = "+escape.cote(langueId));
			rows += Util.insertUpdate(etn, rs, "sites_details", env);
			rs.moveFirst();

			rs = etn.execute("select * from sites_apply_to where site_id = " + escape.cote(siteid));
			rows += Util.insertUpdate(etn, rs, "sites_apply_to", env);
			etn.executeCmd("delete from "+proddb+".sites_apply_to where site_id = "+escape.cote(siteid)+" and id not in (select id from sites_apply_to where site_id = " +escape.cote(siteid)+ " ) ");			
			//we always enable the cache for 127.0.0.1 for production as users always forget to enable it
			etn.executeCmd("update "+proddb+".sites_apply_to set cache = 1 where site_id = "+escape.cote(siteid)+" and apply_type = 'url_starting_with' and apply_to = '127.0.0.1' ");
			
			rows += Util.publishShopParameters(etn, siteid, env);
			rows += Util.publishStickers(etn, siteid, env);
			rows += Util.publishAlgoliaSettings(etn, siteid, langueId, env);
			publishingIdcheckConfig(etn, siteid);
			
			publishMenuJs(etn, siteid, menulang);
			
			if(rows > 0)
			{
				//not marking all pages as refresh_now ... instead after menu publish call the crawler to refresh cache .. and then call the url replacer to fix the urls
				etn.executeCmd("update "+proddb+".cached_pages set refresh_now = 0, cached = 0, last_time_url_active = is_url_active, is_url_active = 0 where menu_id =  " + escape.cote(clid));

				try
				{
					log("Going to call crawler for menu id : " + clid);

					boolean debug =  env.get("DEBUG")!=null || env.get("SCHED_DEBUG") != null;

					CacheUtil cacheUtil = new CacheUtil(env, true, debug);		
					String currentMenuPath = cacheUtil.getMenuPath(etn, clid);		
					
					etn.executeCmd("delete from "+proddb+".crawler_errors where menu_id = " + escape.cote(clid));
					etn.executeCmd("update "+proddb+".crawler_audit set status = 2 where menu_id = " + escape.cote(clid));
					
					Crawler crawler = new Crawler(etn, env, true, debug);
					crawler.start(clid);
					
					log("Indicate application server to reload all page templates for site id : " + siteid);
					try{
						org.jsoup.Jsoup.connect(env.getProperty("PROD_RELOAD_SINGLETONS_INTERNAL_URL")+"?siteid="+siteid);
					} catch (Exception ex) { 
						log("ERROR:: Failed to reload page templates");
						ex.printStackTrace(); 
					}
					
				}
				catch(Exception e)
				{
					etn.executeCmd("insert into "+proddb+".crawler_errors (menu_id, err) values("+escape.cote(clid)+",'Publish::Error crawling site') ");
					e.printStackTrace();
				}
			}
			((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) 
		{ 
			etn.executeCmd("insert into "+proddb+".crawler_errors (menu_id, err) values("+escape.cote(clid)+",'Publish::Error crawling site') ");
			e.printStackTrace(); return(-1); 
		}
	}

	private String appendTabs(int _tab)
	{
		String s = "";
		for(int i=0; i<_tab; i++) s += "\t";
		return s;
	}

	private String getTranslation(ClientSql Etn, String lang, String label) throws Exception
	{
		String proddb = env.getProperty("PROD_DB") + ".";
	
		Set rs = Etn.execute("select * from "+proddb+"language where langue_code = " + com.etn.sql.escape.cote(lang));
		if(rs.next())
		{
			Set trs = Etn.execute("select * from "+proddb+"langue_msg where LANGUE_REF = " + com.etn.sql.escape.cote(label));
			if(trs.next())
			{
				String trans = parseNull(trs.value("LANGUE_" + rs.value("langue_id")));
				return trans;
			}
			else
			{
				//we always insert in preprod translation table so that translations can be added and published then
				Etn.execute("insert IGNORE into langue_msg(LANGUE_REF) values(TRIM("+ com.etn.sql.escape.cote(label)+"))");
				return label;
			}
		}
		else return label;
	}

	private String lib_removeAccents(String a)
	{
       	if(a == null) return "";
		a = a.trim();
		a = lib_ascii7(a);
		return a;
	}
	private java.util.HashMap<String,String> loadTranslations(ClientSql Etn, String langid)
	{
		String proddb = env.getProperty("PROD_DB") + ".";

		Set rsListe = Etn.execute("select LANGUE_REF,LANGUE_"+(langid) + " as LANGUE from "+proddb+"langue_msg");
		java.util.HashMap<String,String> h_msg = new java.util.HashMap<String,String>();

		while(rsListe.next())
		{
			h_msg.put(lib_removeAccents(rsListe.value("LANGUE_REF")).toUpperCase(),rsListe.value("LANGUE"));
		}
		return h_msg;
	}
	private String getTranslation(ClientSql Etn, java.util.HashMap<String,String> h_msg, String lib)
	{
		if(h_msg == null || h_msg.size() == 0) return "";
		if(lib == null || lib.trim().length() == 0) return "";

		String msg="";

		String lib2 = lib_removeAccents(lib).toUpperCase();
		if( h_msg.get(lib2)!=null)
		{
			if(! h_msg.get(lib2).toString().trim().equals(""))
			{
				msg = h_msg.get(lib2).toString();
			}
			else
			{
				msg =  lib;
			}
		}
		else
		{	
			msg = lib;
			//insert into preprod lib as there we provide translation and its then published
			Etn.execute("insert IGNORE into langue_msg(LANGUE_REF) values(TRIM("+ com.etn.sql.escape.cote(lib)+"))");
		}
		return(msg);
	}

	private String lib_ascii7( String  s )
	{
		char c[] = s.toCharArray();
		for( int i = 0 ; i < c.length ; i++ )
			if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)lib_toAscii7( c[i] );
		return( new String( c ) );
	}

	private int  lib_toAscii7( int c )
	{ 
		if( c < 0xc0 || c > 0xff ) return(c);
		return( UC16Latin1ToAscii7[ c - 0xc0 ] );
	}

}
