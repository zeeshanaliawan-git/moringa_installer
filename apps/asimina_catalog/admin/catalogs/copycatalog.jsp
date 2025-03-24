<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="java.io.*, com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.HashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ include file="../../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../../WEB-INF/include/constants.jsp"%>

<%@ include file="../common.jsp"%>

<%
	String scriptfile = GlobalParm.getParm("CHEMIN") + "/WEB-INF/copyimages.sh";

	String docopy = parseNull(request.getParameter("docopy"));
	String msg = "";

	if("1".equals(docopy))
	{
		String copyfrom = parseNull(request.getParameter("copyfromcatid"));
		String copyproducts = parseNull(request.getParameter("copyproducts"));
		String newname = parseNull(request.getParameter("newname"));
		String q = "insert into catalogs (created_by,created_on,name,lang_1_heading,lang_2_heading,lang_3_heading,lang_4_heading,lang_5_heading, "+
			"lang_1_details_heading,lang_2_details_heading,lang_3_details_heading,lang_4_details_heading,lang_5_details_heading, "+
			"is_special,lang_1_price_formatter,lang_2_price_formatter,lang_3_price_formatter,lang_4_price_formatter,lang_5_price_formatter, "+
			"lang_1_currency,lang_2_currency,lang_3_currency,lang_4_currency,lang_5_currency, "+
			"lang_1_round_to_decimals,lang_2_round_to_decimals,lang_3_round_to_decimals,lang_4_round_to_decimals,lang_5_round_to_decimals, "+
			"lang_1_show_decimals,lang_2_show_decimals,lang_3_show_decimals,lang_4_show_decimals,lang_5_show_decimals, "+
			"cart_url,cart_url_params,store_locator_url,store_locator_url_params,cart_prod_url,store_locator_prod_url, "+
			"lang_1_hub_page_heading,lang_2_hub_page_heading,lang_3_hub_page_heading,lang_4_hub_page_heading,lang_5_hub_page_heading, "+
			"lang_1_top_banner_path,lang_2_top_banner_path,lang_3_top_banner_path,lang_4_top_banner_path,lang_5_top_banner_path, "+
			"lang_1_bottom_banner_path,lang_2_bottom_banner_path,lang_3_bottom_banner_path,lang_4_bottom_banner_path,lang_5_bottom_banner_path)  "+
			" select " + Etn.getId() +", now(), "+escape.cote(newname)+",lang_1_heading,lang_2_heading,lang_3_heading,lang_4_heading,lang_5_heading, "+
			"lang_1_details_heading,lang_2_details_heading,lang_3_details_heading,lang_4_details_heading,lang_5_details_heading, "+
			"is_special,lang_1_price_formatter,lang_2_price_formatter,lang_3_price_formatter,lang_4_price_formatter,lang_5_price_formatter, "+
			"lang_1_currency,lang_2_currency,lang_3_currency,lang_4_currency,lang_5_currency, "+
			"lang_1_round_to_decimals,lang_2_round_to_decimals,lang_3_round_to_decimals,lang_4_round_to_decimals,lang_5_round_to_decimals, "+
			"lang_1_show_decimals,lang_2_show_decimals,lang_3_show_decimals,lang_4_show_decimals,lang_5_show_decimals, "+
			"cart_url,cart_url_params,store_locator_url,store_locator_url_params,cart_prod_url,store_locator_prod_url, "+
			"lang_1_hub_page_heading,lang_2_hub_page_heading,lang_3_hub_page_heading,lang_4_hub_page_heading,lang_5_hub_page_heading, "+
			"lang_1_top_banner_path,lang_2_top_banner_path,lang_3_top_banner_path,lang_4_top_banner_path,lang_5_top_banner_path, "+
			"lang_1_bottom_banner_path,lang_2_bottom_banner_path,lang_3_bottom_banner_path,lang_4_bottom_banner_path,lang_5_bottom_banner_path"+
			" from catalogs where id = " + escape.cote(copyfrom);
		int newcatid = Etn.executeCmd(q);
		if(newcatid > 0)
		{
			Map<String, String> productimgs = new HashMap<String, String>();
			Map<String, String> sbarimgs = new HashMap<String, String>();
			int products = 0;
			if("1".equals(copyproducts))
			{
				Set rs = Etn.execute("select * from products where catalog_id = " + escape.cote(copyfrom));
				while(rs.next())
				{
					q = "insert into products (created_by,created_on,catalog_id,universe,is_new,show_basket,order_seq, "+
						"image_name,image_actual_name,lang_1_name,lang_2_name,lang_3_name,lang_4_name,lang_5_name, "+
						"lang_1_summary,lang_2_summary,lang_3_summary,lang_4_summary,lang_5_summary, "+
						"lang_1_features,lang_2_features,lang_3_features,lang_4_features,lang_5_features, "+
						"lang_1_listing_tab,lang_2_listing_tab,lang_3_listing_tab,lang_4_listing_tab,lang_5_listing_tab, "+
						"lang_1_meta_keywords,lang_2_meta_keywords,lang_3_meta_keywords,lang_4_meta_keywords,lang_5_meta_keywords, "+
						"lang_1_meta_description,lang_2_meta_description,lang_3_meta_description,lang_4_meta_description,lang_5_meta_description, "+
						"price,promo_price,lang_1_currency,lang_2_currency,lang_3_currency,lang_4_currency,lang_5_currency, "+
						"lang_1_currency_freq,lang_2_currency_freq,lang_3_currency_freq,lang_4_currency_freq,lang_5_currency_freq, "+
						"show_store_locator,cart_url,cart_url_params,store_locator_url,store_locator_url_params, "+
						"cart_prod_url,store_locator_prod_url,lang_1_pricesent,lang_2_pricesent,lang_3_pricesent,lang_4_pricesent,lang_5_pricesent) "+
						" select " + Etn.getId() +", now(), " + newcatid + ","+escape.cote(newbt)+",universe,is_new,show_basket,order_seq, "+
						"image_name,image_actual_name,lang_1_name,lang_2_name,lang_3_name,lang_4_name,lang_5_name, "+
						"lang_1_summary,lang_2_summary,lang_3_summary,lang_4_summary,lang_5_summary, "+
						"lang_1_features,lang_2_features,lang_3_features,lang_4_features,lang_5_features, "+
						"lang_1_listing_tab,lang_2_listing_tab,lang_3_listing_tab,lang_4_listing_tab,lang_5_listing_tab, "+
						"lang_1_meta_keywords,lang_2_meta_keywords,lang_3_meta_keywords,lang_4_meta_keywords,lang_5_meta_keywords, "+
						"lang_1_meta_description,lang_2_meta_description,lang_3_meta_description,lang_4_meta_description,lang_5_meta_description, "+
						"price,promo_price,lang_1_currency,lang_2_currency,lang_3_currency,lang_4_currency,lang_5_currency, "+
						"lang_1_currency_freq,lang_2_currency_freq,lang_3_currency_freq,lang_4_currency_freq,lang_5_currency_freq, "+
						"show_store_locator,cart_url,cart_url_params,store_locator_url,store_locator_url_params, "+
						"cart_prod_url,store_locator_prod_url,lang_1_pricesent,lang_2_pricesent,lang_3_pricesent,lang_4_pricesent,lang_5_pricesent "+
						" from products where id = " + rs.value("id");
					int newprodid = Etn.executeCmd(q);
					if(newprodid > 0)
					{
						products ++;
						if(parseNull(rs.value("image_name")).length() > 0)
						{
							String newiname = parseNull(rs.value("image_name"));
							newiname = newiname.substring(newiname.lastIndexOf("."));
							newiname = newprodid + newiname;
							productimgs.put(parseNull(rs.value("image_name")), newiname);
							Etn.executeCmd("update products set image_name = " + escape.cote(newiname) + " where id = " + escape.cote(""+newprodid));//change
						}

						q = "insert into product_tabs (product_id, lang_1_tab_name, lang_2_tab_name, lang_3_tab_name, lang_4_tab_name, lang_5_tab_name, "+
							" lang_1_tab_text, lang_2_tab_text, lang_3_tab_text, lang_4_tab_text, lang_5_tab_text, order_seq ) "+
							" select "+newprodid+", lang_1_tab_name, lang_2_tab_name, lang_3_tab_name, lang_4_tab_name, lang_5_tab_name, "+
							" lang_1_tab_text, lang_2_tab_text, lang_3_tab_text, lang_4_tab_text, lang_5_tab_text, order_seq "+
							" from product_tabs where product_id = " + rs.value("id");

						Etn.executeCmd(q);

						q = " insert into share_bar (created_by,created_on,id,ptype,og_image,lang_1_og_title,lang_1_og_description,lang_1_twitter_message,lang_1_twitter_site, "+
							" lang_1_email_subject,lang_1_email_message,lang_1_email_popin_title,lang_1_sms_text,lang_2_og_title,lang_2_og_description, "+
							" lang_2_twitter_message,lang_2_twitter_site,lang_2_email_subject,lang_2_email_message,lang_2_email_popin_title,lang_2_sms_text, "+
							" lang_3_og_title,lang_3_og_description,lang_3_twitter_message,lang_3_twitter_site,lang_3_email_subject,lang_3_email_message,lang_3_email_popin_title,lang_3_sms_text, "+
							" lang_4_og_title,lang_4_og_description,lang_4_twitter_message,lang_4_twitter_site,lang_4_email_subject,lang_4_email_message,lang_4_email_popin_title,lang_4_sms_text, "+
							" lang_5_og_title,lang_5_og_description,lang_5_twitter_message,lang_5_twitter_site,lang_5_email_subject,lang_5_email_message,lang_5_email_popin_title,lang_5_sms_text, "+
							" og_type) "+
							" select " + Etn.getId() +", now(), " + newprodid +",ptype,og_image,lang_1_og_title,lang_1_og_description,lang_1_twitter_message,lang_1_twitter_site, "+
							" lang_1_email_subject,lang_1_email_message,lang_1_email_popin_title,lang_1_sms_text,lang_2_og_title,lang_2_og_description, "+
							" lang_2_twitter_message,lang_2_twitter_site,lang_2_email_subject,lang_2_email_message,lang_2_email_popin_title,lang_2_sms_text, "+
							" lang_3_og_title,lang_3_og_description,lang_3_twitter_message,lang_3_twitter_site,lang_3_email_subject,lang_3_email_message,lang_3_email_popin_title,lang_3_sms_text, "+
							" lang_4_og_title,lang_4_og_description,lang_4_twitter_message,lang_4_twitter_site,lang_4_email_subject,lang_4_email_message,lang_4_email_popin_title,lang_4_sms_text, "+
							" lang_5_og_title,lang_5_og_description,lang_5_twitter_message,lang_5_twitter_site,lang_5_email_subject,lang_5_email_message,lang_5_email_popin_title,lang_5_sms_text, "+
							" og_type from share_bar where ptype = 'product' and id = " +  rs.value("id");

						if(Etn.executeCmd(q) > 0)
						{
							Set r1 = Etn.execute("select * from share_bar where ptype = 'product' and id = " + escape.cote(""+newprodid));//change
							r1.next();

							if(parseNull(r1.value("og_image")).length() > 0)
							{
								String newiname = parseNull(r1.value("og_image"));
								newiname = newiname.substring(newiname.lastIndexOf("."));
								newiname = newprodid + newiname;
								sbarimgs.put(parseNull(r1.value("og_image")), newiname);
								Etn.executeCmd("update share_bar set og_image = " + escape.cote(newiname) + " where ptype = 'product' and id = " + escape.cote(""+newprodid));//change
							}
						}
					}
				}
			}
			msg = "New catalog " + newname + " created ";
			if("1".equals(copyproducts)) msg += " with " + products + " products";


			if(!productimgs.isEmpty())
			{
				for(String key : productimgs.keySet())
				{
					System.out.println("copy img : " + key + " to " + productimgs.get(key));
					try {
						Runtime.getRuntime().exec(scriptfile + " "+GlobalParm.getParm("PRODUCTS_UPLOAD_DIRECTORY")+"/"+key + " "+GlobalParm.getParm("PRODUCTS_UPLOAD_DIRECTORY")+"/"+productimgs.get(key));
					} catch(Exception e) { e.printStackTrace(); }
				}
			}
			if(!sbarimgs.isEmpty())
			{
				for(String key : sbarimgs.keySet())
				{
					System.out.println("copy sbarimg : " + key + " to " + sbarimgs.get(key));
					try {
						Runtime.getRuntime().exec(scriptfile + " "+GlobalParm.getParm("PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY")+"/"+key + " "+GlobalParm.getParm("PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY")+"/"+sbarimgs.get(key));
					} catch(Exception e) { e.printStackTrace(); }
				}
			}
		}
		else msg = "Some error while copying catalog";
	}

	Set rsc = Etn.execute("select * from catalogs where is_special = 0 order by name");

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
	<title>Catalogs Administration</title>

	<SCRIPT LANGUAGE="JavaScript" SRC="<%=request.getContextPath()%>/js/jquery.min.js"></script>

		<%@ include file="/WEB-INF/include/head2.jsp"%>

<script>
	function copy()
	{
		if(document.forms[0].copyfromcatid.value =='')
		{
			alert("Select a catalog to copy");
			return;
		}
		if(document.forms[0].newname.value =='')
		{
			alert("Enter new name of catalog");
			return;
		}
		document.forms[0].submit();
	}
</script>

</head>
<body>
		<%@ include file="/WEB-INF/include/newmenu2.jsp"%>

	<center>
		<h2>Copy Catalogs</h2>
	</center>

		<div id='mycontainer'>
			<input type='button' value='Back' onclick='javascript:window.location="catalogs.jsp";' />
			<br>
			<center>
			<form name='frm' method='post' action='copycatalog.jsp'>
			<input type='hidden' value='1' name='docopy' >
			<table cellpadding='0' cellspacing='0' border='0'>
				<tr>
					<td style='font-weight:bold;'>Copy from</td>
					<td style='font-weight:bold;'>&nbsp;:&nbsp;</td>
					<td>
						<select name='copyfromcatid' id='copyfromcatid'>
							<option value=''>-----------------</option>
							<% while(rsc.next()){%>
								<option value='<%=escapeCoteValue(rsc.value("id"))%>'><%=escapeCoteValue(rsc.value("name"))%></option>
							<%}%>
						</select>
					</td>
				</tr>
				<tr>
					<td style='font-weight:bold;'>Copy products?</td>
					<td style='font-weight:bold;'>&nbsp;:&nbsp;</td>
					<td><input type='checkbox' name='copyproducts' value='1' checked ></td>
				</tr>
				<tr>
					<td style='font-weight:bold;'>New catalog name</td>
					<td style='font-weight:bold;'>&nbsp;:&nbsp;</td>
					<td><input type='text' name='newname' value='' size='50' maxlength='255' ></td>
				</tr>
				<tr>
					<td colspan='3' align='center'><br></td>
				</tr>
				<tr>
					<td colspan='3' align='center'><input type='button' value='Copy' onclick='copy()'></td>
				</tr>
			</table>
			</form>
			</center>
		</div>
</body>
<script>
	<% if(msg.length() > 0) {%>alert("<%=msg%>");<%}%>
</script>
</html>