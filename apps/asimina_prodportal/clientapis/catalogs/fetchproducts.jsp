<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, com.etn.beans.Contexte, com.etn.beans.app.GlobalParm, java.util.*, org.apache.commons.lang3.*, com.google.gson.*, com.google.gson.reflect.TypeToken, java.lang.reflect.Type, org.json.*, com.etn.util.Base64"%>
<%@ page import="org.json.JSONArray,org.json.JSONObject"%>
<%@ page import="com.etn.asimina.beans.*, com.etn.util.Logger"%>
<%@ page import="com.etn.asimina.beans.Language,com.etn.asimina.data.LanguageFactory, com.etn.asimina.util.*"%>

<%@ include file="productcommons.jsp"%>
<%
	String ids = PortalHelper.parseNull(request.getParameter("id"));
	String suid = PortalHelper.parseNull(request.getParameter("suid"));
	String lang = PortalHelper.parseNull(request.getParameter("lang"));
	String _type = "";

	JSONObject jResp = newJsonObject();	
	if(ids.length() == 0 || suid.length() == 0)
	{
		jResp.put("status", 15);
		jResp.put("err_code", "required_data_missing");
		jResp.put("err_msg", "Site uid or folder(s) uid must be provided");
		out.write(jResp.toString());
		return;
	}

	Logger.debug("clientapis/catalogs/fetchproducts.jsp","ids:"+ids);
	Logger.debug("clientapis/catalogs/fetchproducts.jsp","suid:"+suid);
	Logger.debug("clientapis/catalogs/fetchproducts.jsp","lang:"+lang);

	String catalogdb = GlobalParm.getParm("CATALOG_DB");
	
	String langQry = "select * from language where langue_code = "+escape.cote(lang)+" order by langue_id";
	if(lang.length() == 0) langQry = " select * from language order by langue_id ";
	Set rsLang = Etn.execute(langQry);
	rsLang.next();
	lang = rsLang.value("langue_code");	
	String prefix = "lang_" + rsLang.value("langue_id");
	
	Set rsSite = Etn.execute("select * from sites where suid = "+escape.cote(suid));
	rsSite.next();
	String siteid = rsSite.value("id");	

	String menuid = "";
	Set rsMenu = Etn.execute("Select id from site_menus where site_id = "+escape.cote(siteid)+ " and lang = "+escape.cote(lang));
	if(rsMenu.next())
	{
		menuid = PortalHelper.parseNull(rsMenu.value(0));
	}
	
	String menuPath = PortalHelper.getMenuPath(Etn, menuid);

	JSONObject jData = newJsonObject();	
	JSONArray jFolders = new JSONArray();
	jData.put("folders", jFolders);	
	
	String[] allIds = ids.split(",");
	if(allIds != null)
	{
		boolean recFound = false;
		String catalogid = "";
		String folderid = "";
		
		for(String id : allIds)
		{
			System.out.println("in id : " + id);
			
			Set rsCat = Etn.execute("select * from "+catalogdb+".catalogs where site_id = "+escape.cote(siteid)+" and catalog_uuid = "+escape.cote(id));
			if(rsCat.next())
			{
				catalogid = PortalHelper.parseNull(rsCat.value("id"));
				recFound = true;
				_type = "catalog";
			}
			else
			{
				Set rsF = Etn.execute("select * from "+catalogdb+".products_folders where site_id = "+escape.cote(siteid)+" and uuid = "+escape.cote(id));
				if(rsF.next())
				{
					_type = "folder";
					catalogid = PortalHelper.parseNull(rsF.value("catalog_id"));
					folderid = PortalHelper.parseNull(rsF.value("id"));
					recFound = true;
				}
			}
			Logger.debug("clientapis/catalogs/fetchproducts.jsp",recFound+"recFound");
			Logger.debug("clientapis/catalogs/fetchproducts.jsp",siteid+"siteid");			
			if(recFound == false)
			{
				Logger.error("no folder found against ID : " + id);
			}			
			else
			{
				rsCat = Etn.execute("Select *, date_format(created_on, '%Y-%m-%dT%h:%i:%s') created_on_iso, date_format(updated_on, '%Y-%m-%dT%h:%i:%s') updated_on_iso from "+catalogdb+".catalogs where id = "+escape.cote(catalogid));
				rsCat.next();

				JSONObject jCatalog = newJsonObject();	
				JSONObject jInfo = newJsonObject();
				jCatalog.put("info", jInfo);
				jFolders.put(jCatalog);
				if("catalog".equals(_type))
				{
					jInfo.put("type", "catalog");
					jInfo.put("name", PortalHelper.parseNull(rsCat.value("name")));
					jInfo.put("id", PortalHelper.parseNull(rsCat.value("catalog_uuid")));		
					jInfo.put("created_on", PortalHelper.parseNull(rsCat.value("created_on_iso")));		
					jInfo.put("updated_on", PortalHelper.parseNull(rsCat.value("updated_on_iso")));		
				}
				else
				{
					Set rsF = Etn.execute("select *, date_format(created_on, '%Y-%m-%dT%h:%i:%s') created_on_iso, date_format(updated_on, '%Y-%m-%dT%h:%i:%s') updated_on_iso from "+catalogdb+".products_folders where uuid = "+escape.cote(id));
					rsF.next();
					jInfo.put("type", "folder");
					jInfo.put("name", PortalHelper.parseNull(rsF.value("name")));
					jInfo.put("id", PortalHelper.parseNull(rsF.value("uuid")));		
					jInfo.put("created_on", PortalHelper.parseNull(rsF.value("created_on_iso")));		
					jInfo.put("updated_on", PortalHelper.parseNull(rsF.value("updated_on_iso")));		
				}
				
				jInfo.put("products_type", PortalHelper.parseNull(rsCat.value("catalog_type")));
				jInfo.put("show_amount_tax_included", "1".equals(PortalHelper.parseNull(rsCat.value("show_amount_tax_included"))));
				jInfo.put("price_tax_included", "1".equals(PortalHelper.parseNull(rsCat.value("price_tax_included"))));
				jInfo.put("buy_status", PortalHelper.parseNull(rsCat.value("buy_status")));
				jInfo.put("default_sorting", PortalHelper.parseNull(rsCat.value("default_sort")));
				jInfo.put("tax_percentage", PortalHelper.parseNullDouble(rsCat.value("tax_percentage")));
				jInfo.put("variant", PortalHelper.parseNull(rsCat.value("html_variant")));
					
				jData.put("language", lang);
				
				jInfo.put("title", PortalHelper.parseNull(rsCat.value(prefix + "_heading")));
				jInfo.put("description", PortalHelper.parseNull(rsCat.value(prefix + "_description")));
				jInfo.put("essentials_alignment", PortalHelper.parseNull(rsCat.value("essentials_alignment_" + prefix)));
				
				if("catalog".equals(_type))
				{
					Set rsCatDetails = Etn.execute("Select c.* from "+catalogdb+".catalog_descriptions c where c.langue_id = "+escape.cote(rsLang.value("langue_id"))+" and c.catalog_id = "+escape.cote(catalogid));
						
					while(rsCatDetails.next())
					{		
						String cUrl = PortalHelper.parseNull(rsCatDetails.value("canonical_url"));
						if(cUrl.length() > 0) cUrl = menuPath + cUrl + ".html";
				
						jInfo.put("canonical_url", cUrl);
						jInfo.put("path_prefix", PortalHelper.parseNull(rsCatDetails.value("folder_name")));
					}		
				}
				else
				{
					Set rsF = Etn.execute("select pd.* from "+catalogdb+".products_folders f join "+catalogdb+".products_folders_details pd on pd.folder_id = f.id and pd.langue_id = "+escape.cote(rsLang.value("id"))+" where f.uuid = "+escape.cote(id));
					rsF.next();
					jInfo.put("path_prefix", PortalHelper.parseNull(rsF.value("path_prefix")));
				}
					
				String clientid = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
				
				JSONArray jProducts = new JSONArray();
				
				String qry = "Select * from "+catalogdb+".products " +
							" where catalog_id = "+escape.cote(catalogid);
				if(_type.equals("folder"))
				{
					qry += " and folder_id = "+escape.cote(folderid);
				}	
				qry += " order by order_seq, id ";
				
				Set rsP = Etn.execute(qry);
				while(rsP.next())
				{
					jProducts.put(getProductDetails(Etn, request, rsP.value("product_uuid"), siteid, lang, clientid));
				}
				
				jCatalog.put("products", jProducts);
			}
		}
	}
	
	jData.put("shop_parameters", getShopParameters(Etn, siteid, rsLang.value("langue_id")));
	
	jResp.put("status", 0);
	jResp.put("data", jData);		
	out.write(jResp.toString());
%>