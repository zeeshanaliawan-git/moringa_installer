package com.etn.asimina.util;

import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;
import com.etn.util.Logger;
import com.etn.asimina.util.PortalHelper;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

import java.util.Map;
import java.util.HashMap;

import org.json.JSONObject;

public class ApplyPageTemplateHelper
{
	private static final ApplyPageTemplateHelper apt = new ApplyPageTemplateHelper();
	private Map<String, Map<String, String>> pageTemplates = new HashMap<String, Map<String, String>>();
	
	private ApplyPageTemplateHelper(){}
	
	public static ApplyPageTemplateHelper getInstance()
	{
		return apt;
	}
	
	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
	
	public void reloadAll()
	{
		pageTemplates.clear();
	}
	
	public void reload(String pageTemplateId)
	{
		pageTemplates.remove(pageTemplateId);
	}
	
	public void reload(java.util.List<String> ids)
	{
		if(ids == null || ids.isEmpty()) return;
		for(String id : ids) 
		{
			pageTemplates.remove(id);
		}
	}
		
	public String applyTemplate(com.etn.beans.Contexte Etn, String uri, String content)
	{
		org.jsoup.nodes.Document jspDoc = org.jsoup.Jsoup.parse(content, uri);
		org.jsoup.select.Elements eles = jspDoc.select("meta[name=pr:tuid]");			
		if(eles != null && eles.size() > 0)
		{
			String pageTemplateId = parseNull(eles.first().attr("content"));
			if(pageTemplateId.length() > 0 && pageTemplateId.equals("0") == false)
			{
				String langCode = "";
				eles = jspDoc.select("meta[name=pr:lang]");
				if(eles != null && eles.size() > 0) langCode = parseNull(eles.first().attr("content"));
												
				if(langCode.length() > 0) 
				{														
					try
					{					
						String muid = "";
						eles = jspDoc.select("meta[name=pr:muid]");
						if(eles != null && eles.size() > 0) muid = parseNull(eles.first().attr("content"));
						
						Set rs = Etn.execute("select * from site_menus where menu_uuid = "+escape.cote(muid));
						rs.next();
						String siteid = rs.value("site_id");
						String menuid = rs.value("id");
						String menuVersion = rs.value("menu_version");
						
						String currentMenuPath = PortalHelper.getMenuPath(Etn, menuid);
						
						String finalResourcesUrl = parseNull(GlobalParm.getParm("COMMON_RESOURCES_URL"));
						if(finalResourcesUrl.endsWith("/") == false) finalResourcesUrl += "/";
						finalResourcesUrl += siteid + "/";
						Logger.info("ApplyPageTemplateHelper","finalResourcesUrl="+finalResourcesUrl);
					
						String[] ignoreRelUrls = parseNull(GlobalParm.getParm("IGNORE_RELATIVE_URLS")).split(";");
						String cachedResourcesFolder = PortalHelper.getCachedResourcesUrl(Etn, menuid);
						
						boolean bIsProd = "1".equals(parseNull(com.etn.beans.app.GlobalParm.getParm("IS_PRODUCTION_ENV")));
						String prodlogtxt = "";
						if(bIsProd) prodlogtxt = " PROD --";
						
						//for test environment we have to refresh the template every time
						if(pageTemplates.get(pageTemplateId) == null || bIsProd == false)
						{							
							Logger.info("ApplyPageTemplateHelper","Load page template : " + pageTemplateId + " " + langCode);
							//get template and put it in map for next time ... templates dont change often
							String contentDivId = java.util.UUID.randomUUID().toString();
							String pageTemplateApiUrl = "http://127.0.0.1"+GlobalParm.getParm("PAGES_APP_URL")+"api/pageTemplate.jsp?templateUuid="+pageTemplateId+"&lang="+langCode+"&contentId="+contentDivId;
							
							String _jsonStr = org.jsoup.Jsoup.connect(pageTemplateApiUrl).ignoreContentType(true).execute().body();
							JSONObject json = new JSONObject(_jsonStr);
							if(json.getInt("status") == 1)//success and we put template json in map
							{
								Map<String, String> _map = new HashMap<String, String>();
								_map.put("contentDivId", contentDivId);
								
								//fix all urls in the template then put in map
								String templateHtml = parseNull(json.get("data"));
								
								//for prod we always load css/js/imgs from site's resources folder
								if(bIsProd)
								{
									templateHtml = templateHtml.replace(finalResourcesUrl, cachedResourcesFolder);
								}
								
								org.jsoup.nodes.Document templateDoc = org.jsoup.Jsoup.parse(templateHtml);
								
								eles = templateDoc.select("a[href]");
								for(org.jsoup.nodes.Element ele : eles)
								{
									String _r = parseNull(ele.attr("href"));
									
									if(_r.length() == 0 || _r.toLowerCase().startsWith("tel:") || _r.toLowerCase().startsWith("javascript:") || _r.equals("/") || _r.startsWith("#")) continue;
									
									Logger.info("ApplyPageTemplateHelper","--"+prodlogtxt+" Check for relative url : " + _r);
									String _r2 = _r;
									if(_r2.indexOf("?") > -1) _r2 = _r2.substring(0, _r2.indexOf("?"));
									boolean isHtmlPageUrl = false;
									if(_r2.toLowerCase().endsWith(".html")) isHtmlPageUrl = true; 						

									if(_r.toLowerCase().startsWith("http:") == false && _r.toLowerCase().startsWith("https:") == false && isHtmlPageUrl && _r.startsWith("/") == false)
									{										
										Logger.info("ApplyPageTemplateHelper","--"+prodlogtxt+" Appending " + currentMenuPath + " to relative url " + _r);
										ele.attr("href", currentMenuPath + _r);
									}
								}
								
								eles = templateDoc.select("link[href]");
								for(org.jsoup.nodes.Element ele : eles)
								{
									String _rel = parseNull(ele.attr("rel"));
									if(_rel.equalsIgnoreCase("canonical") || _rel.equalsIgnoreCase("shortlink")) continue;
									
									String _r = ele.attr("href");
									if(parseNull(_r).length() == 0 || parseNull(_r).equals("/") || parseNull(_r).startsWith("#") || parseNull(_r).toLowerCase().startsWith("javascript:")) continue;
									
									if(PortalHelper.isLocalResource(_r)) 
									{
										if(bIsProd) 
										{
											_r = _r.replace(finalResourcesUrl, cachedResourcesFolder);							
										}
										_r = _r.replace("http://127.0.0.1","").replace("http://localhost","");
										if(_r.indexOf("?") > -1) _r = _r + "&__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));
										else _r = _r + "?__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));
										ele.attr("href", _r);//setting relative path 
										continue;
									}
								}			
								
								eles = templateDoc.select("script[src]");
								for(org.jsoup.nodes.Element ele : eles)
								{
									String _r = ele.attr("src");					
									if(parseNull(_r).length() == 0 || parseNull(_r).equals("/") || parseNull(_r).startsWith("#")) continue;
									
									if(PortalHelper.isLocalResource(_r)) 
									{
										if(bIsProd) 
										{
											_r = _r.replace(finalResourcesUrl, cachedResourcesFolder);							
										}
										_r = _r.replace("http://127.0.0.1","").replace("http://localhost","");
										if(_r.indexOf("?") > -1) _r = _r + "&__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));
										else _r = _r + "?__v=" + parseNull(GlobalParm.getParm("CSS_JS_VERSION"));						
										ele.attr("src", _r);//setting relative path 
										continue;					
									}
								}
								
								_map.put("html", templateDoc.outerHtml());
								pageTemplates.put(pageTemplateId, _map);
							}
						}
						else Logger.info("ApplyPageTemplateHelper","ApplyPageTemplateHelper::Page template already loaded");
						//in case the pages api return error we will not have json in the map so we have to check for null again
						if(pageTemplates.get(pageTemplateId) != null)
						{
							Map<String, String> _map = pageTemplates.get(pageTemplateId);
							String contentDivId = parseNull(_map.get("contentDivId"));							
							
							org.jsoup.nodes.Element jspBody = jspDoc.select("body").first();
							org.jsoup.nodes.Element jspHead = jspDoc.select("head").first();
							
							String templateHtml = parseNull(_map.get("html"));
							org.jsoup.nodes.Document templateDoc = org.jsoup.Jsoup.parse(templateHtml);
							org.jsoup.nodes.Element templateBody = templateDoc.select("body").first();
							org.jsoup.nodes.Element templateHead = templateDoc.select("head").first();
							org.jsoup.nodes.Element templateContentDiv = templateDoc.select("div[id=content_"+contentDivId+"]").first();
							
							templateHead.append(jspHead.html());
							templateContentDiv.append(jspBody.html());
							
							String requiredJs = com.etn.asimina.util.BlockSystemJsFunctions.getRequiredJs(Etn, templateDoc);
							if(requiredJs.length() > 0 ) templateBody.append(requiredJs);
							
							//if we have added some attributes or classes to html tag those must be added to the html tag of template
							//template html tag can also have its own classes attributes
							org.jsoup.nodes.Element htmlEle = jspDoc.select("html").first();
							org.jsoup.nodes.Element templateHtmlEle = templateDoc.select("html").first();							
							
							java.util.Set<String> htmlClasses = htmlEle.classNames();
							if(htmlClasses != null)
							{
								java.util.Set<String> templateHtmlClasses = templateHtmlEle.classNames();
								for(String cls : htmlClasses)
								{
									if(templateHtmlClasses == null || templateHtmlClasses.contains(cls) == false)
									{
										Logger.info("ApplyPageTemplateHelper", "Adding class : " + cls);
										templateHtmlEle.addClass(cls);
									}
								}
							}
							
							if(htmlEle.attributes() != null)//add these attributes to the html tag in the template ... if the attribute already exists in template then it has more preference
							{
								for(org.jsoup.nodes.Attribute attr : htmlEle.attributes().asList())
								{
									if(parseNull(templateHtmlEle.attr(attr.getKey())).length() == 0)
									{
										Logger.info("ApplyPageTemplateHelper", "Adding attribute "+ attr.getKey() + " : " +attr.getValue());
										templateHtmlEle.attr(attr.getKey(), parseNull(attr.getValue()));
									}
								}
							}
							
							content = templateDoc.outerHtml();
						}
					}
					catch(Exception e)
					{
						e.printStackTrace();
					}
				}
			}
		}
		return content;
	}
}