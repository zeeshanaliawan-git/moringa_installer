package com.etn.eshop;

import com.etn.eshop.mail.*;

import java.io.*;
import java.net.URL;
import java.net.URLDecoder;

import javax.mail.*;
import javax.mail.internet.*;

import java.security.*;
import java.security.cert.*;

import javax.net.ssl.*;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Arrays;
import java.util.Properties;
import java.util.Enumeration;
import java.util.StringTokenizer;
import java.util.Date;
import com.etn.util.ItsDate;
import com.etn.sql.escape;
import com.etn.net.MailFromModel;
import com.etn.eshop.Dictionary;
import com.etn.util.PriceFormatter;


import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;

import org.json.*;
import java.math.BigDecimal;

public class SendMail extends MailFromModel {

    public final int NO_MAILID = 1;
    public final int NO_ROW = 2;
    public final int NO_CONTACT = 3;
    public final int NO_CONNECTION = -1;
    protected ClientSql etn;
    protected String repository;
    protected Properties env;
    protected InternetAddress FROM;
    protected InternetAddress REPLY[];
    protected boolean withContrat = false;
	protected Dictionary dictionary;
	protected PriceFormatter priceFormatter;
    String CATALOG_DB = null;

    public void addSousPart(MimeMultipart cur, BodyPart lastmodel, int niveau, int souspart) {
        //System.out.println( "niveau:"+niveau+" souspart:"+souspart);
    }

    public SendMail(ClientSql etn, Properties conf) throws Exception {
        super(conf);
        this.etn = etn;
        this.env = conf;

        repository = env.getProperty("MAIL_REPOSITORY");
		dictionary = new Dictionary(etn , conf );
		priceFormatter = new PriceFormatter(etn , conf );
        CATALOG_DB = this.env.getProperty("CATALOG_DB");
    }

    protected String getFieldValue(Set rs, String dollar)
	{
        if (dollar == null || dollar.length() < 2 || dollar.charAt(0) != '$') {
            return (dollar);
        }

        int i = rs.indexOf(dollar.substring(1));

        return (i == -1 ? dollar : rs.value(i));
    }

    protected boolean isIdentifier(char c) {
        return (Character.isLetterOrDigit(c) || c == '_');
    }

    /**
     * getMailId.
     *
     * @return mailid > 0
     */
    protected int getMailId(int wkid, String where, Set rs) {
        StringBuilder sb = new StringBuilder(where.length() * 2);
        int i, j;

        i = 0;
        while ((j = where.indexOf('$', i)) != -1) {
            sb.append(where.substring(i, j));
            for (i = ++j; isIdentifier(where.charAt(i)); i++);
            int n = rs.indexOf(where.substring(j, i));
            if (n < 0) {
                sb.append("$" + where.substring(j, i));
            } else {
                sb.append(escape.cote(rs.value(n)));
            }
        }

        sb.append(where.substring(i, where.length()));

        Set rs2 = etn.execute(sb.toString());
        if (!rs2.next()) {
            return (0);
        }
        try {
            return (Integer.parseInt(rs2.value(0)));
        } catch (Exception e) {
            System.err.println("getMailId return non Integer : " + rs2.value(0));
            return (-1);
        }

    }

    protected InternetAddress setAdr(String adr) {
        try {
            return (new InternetAddress(adr));
        } catch (Exception e) {
            return (null);
        }
    }

    protected String parseNull(Object o)
    {
      if( o == null )
        return("");
      String s = o.toString();
      if("null".equals(s.trim().toLowerCase()))
        return("");
      else
        return(s.trim());
    }


    protected int parseNullInt(Object o)
    {
        String s = parseNull(o);
        if(s.length() > 0 ){
            try{
                return Integer.parseInt(s);
            }
            catch(Exception e){
                return 0;
            }
        }
        else{
            return 0;
        }
    }


    protected double parseNullDouble(Object o)
    {
        String s = parseNull(o);
        if(s.length() > 0 ){
            try{
                return Double.parseDouble(s);
            }
            catch(Exception e){
                return 0;
            }
        }
        else{
            return 0;
        }
    }

    /**
     * setRecipients Analyse du champ email_to Alimente destTO , destCC ,
     * destBCC
     *
     * @return le nombre d'adresse trouvée ou 0 si aucun destinataire
     */
    protected int setRecipients(Set rs) {
        String s;
        int i, j;
        String z[];
        int nadr = 0;
        InternetAddress t[];

        //reseting these
        destTO = destCC = destBCC = null;

		String emails = parseNull(rs.value("email_to"));
		System.out.println("email_to : " + emails);
		System.out.println("Send emails to : " + emails);
        StringTokenizer st = new StringTokenizer(emails, " \t,;\r\n");
        z = new String[st.countTokens()];

//	System.out.println("z.length = " + z.length);
        if (z.length == 0) {
            destTO = new InternetAddress[1];
            destTO[0] = setAdr(rs.value("email"));
            return (1);
        }


        i = 0;
        while (st.hasMoreTokens()) {
            z[i++] = st.nextToken();
        }

		for(int _j=0;_j<z.length;_j++)
		{
			if("resourceslist".equalsIgnoreCase(z[_j]))
			{
				String emailresourceslist = "";
				Map<String, Resource> resources = Util.getResources(etn, env, rs.value("product_ref"));

				if(resources !=null && !resources.isEmpty())
				{
					int _r = 0;
					for(String rscname : resources.keySet())
					{
						if(_r ++ > 0) emailresourceslist += ":";
						emailresourceslist += parseNull(resources.get(rscname).getEmail());
					}
				}
	//			System.out.println("emailresourceslist " + emailresourceslist);
				z[_j] = emailresourceslist ;
			}
			else if("assignedresource".equalsIgnoreCase(z[_j]))
			{
				String resourceemail = "";
				Resource resource= Util.getResource(etn, env, parseNull(rs.value("resource")));
				if(resource != null) resourceemail = resource.getEmail();
				z[_j] = resourceemail;
			}
			else if("storemail".equalsIgnoreCase(z[_j]))
			{
				try{
								JSONObject selectedBoutique = new JSONObject(URLDecoder.decode(rs.value("selected_boutique"), "UTF-8"));
								String storeName = parseNull(selectedBoutique.getString("name"));
								String storeCity = parseNull(selectedBoutique.getString("city"));
								Set rsStoreEmail = etn.execute("select email from store_emails where name="+escape.cote(storeName)+" and city="+escape.cote(storeCity));
								if(rsStoreEmail.next()){
									z[_j] = rsStoreEmail.value(0);
								}
								else{
									z[_j] = "";
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
			}

		}

        System.out.println("z0:" + z[0]);



        // TO...
        if (z[0].equalsIgnoreCase("nomail")) // to = all : separated email addrs
        {
            if (z.length == 1) {
                return (0);
            }
			String[] _tos = z[1].split(":");
			if(_tos != null)
			{
				destTO = new InternetAddress[_tos.length];
				for(int _k=0; _k < _tos.length; _k++)
				{
					 System.out.println("############# " + getFieldValue(rs, _tos[_k]));
					 destTO[_k] = setAdr(getFieldValue(rs, _tos[_k]));
				}
			}
            z[0] = z[1] = null;
        }
		else
		{
			destTO = new InternetAddress[1];
            destTO[0] = setAdr(rs.value("email"));
        }

        nadr = (destTO[0] == null ? 0 : 1);
        if (nadr == 0) {
            destTO = null;
        }

        t = new InternetAddress[z.length];

        for (i = j = 0; i < z.length; i++) {
            if (z[i] != null && z[i].startsWith("cc:")) {
                InternetAddress it = setAdr(
                        getFieldValue(rs, z[i].substring(z[i].indexOf(':') + 1)));
                if (it != null) {
                    t[j++] = it;
                }
                z[i] = null;
            }
        }

        if (j != 0) {
            destCC = new InternetAddress[j];
            nadr += j;
            System.arraycopy(t, 0, destCC, 0, j);
        }

        // All non null are  now bcc
        for (i = j = 0; i < z.length; i++) {
            if (z[i] != null) {
                InternetAddress it = setAdr(
                        getFieldValue(rs, z[i].substring(z[i].indexOf(':') + 1)));
                if (it != null) {
                    t[j++] = it;
                }
            }
        }

        if (j != 0) {
            destBCC = new InternetAddress[j];
            nadr += j;
            System.arraycopy(t, 0, destBCC, 0, j);
        }

        return (nadr);
    }

    public int send(Set rs, String maillang, String mailident)
	{
        int r, mailid = Integer.parseInt(mailident);
        FileInputStream fmodele = null;
        FileOutputStream out = null;

        try
		{
			System.out.println("in send mail 2");
			if(parseNull(maillang).length() == 0)
			{
				//set first language as default
				Set rslang = etn.execute("select * from language order by langue_id ");
				rslang.next();
				maillang = rslang.value("langue_code");
			}

            // Destinataires
            if (setRecipients(rs) == 0) {
                return (NO_CONTACT); // nothing to do
            }

            System.out.println("TO:" + destTO[0].toString());
            System.out.println("CC:" + (destCC != null ? Arrays.toString(destCC) : "null"));
            System.out.println("BCC:" + (destBCC != null ? Arrays.toString(destBCC) : "null"));

            setFrom(env.getProperty("MAIL_FROM"), env.getProperty("MAIL_FROM_DISPLAY_NAME"));
            if(parseNull(env.getProperty("MAIL_REPLY")).length() > 0) setReply(env.getProperty("MAIL_REPLY"));

			Set rslang = etn.execute("select * from language order by langue_id ");
			int langcount = 1;
            while(rslang.next())
			{
				if(maillang.equals(rslang.value("langue_code"))) break;
				langcount++;
			}
			System.out.println("Subject column : " + "sujet_lang_"+langcount);
			String sujet = parseNull(rs.value("sujet_lang_"+langcount));
            if(sujet.length() == 0) sujet = rs.value("sujet");

			System.out.println("Final Subject : " + sujet);

			String emailtemplate = repository + "/mail" + mailid + "_" + maillang;
			File ftemplate = new File(emailtemplate);
			System.out.println("Try Template : " + emailtemplate);
			if(!ftemplate.exists() || ftemplate.length() == 0) emailtemplate = repository + "/mail" + mailid;
			System.out.println("Final Template : " + emailtemplate);

            fmodele = new FileInputStream(emailtemplate);

            return (send(fmodele, rs, sujet, null));
        }
		catch (Exception e)
		{
            e.printStackTrace();
            if (debug)
			{
                System.out.println("MAIL: mailident:" + mailident);
            }
            return (NO_CONNECTION);
        }
		finally
		{
            try
			{
                if (fmodele != null)
				{
                    fmodele.close();
                }
                if (out != null)
				{
                    out.close();
                }
            }
			catch (Exception ze) {}
        }
	}

    private String getCurrencyPosition(String position, String price, String currency, boolean isVertical){
        if(isVertical){
            if(position.equals("before")){
                return currency +"<br/>"+ price;
            } else{
                return price +"<br/>"+ currency;
            }
        } else{
            if(position.equals("before")){
                return currency +" "+ price;
            } else{
                return price +" "+ currency;
            }
        }
    }

    public int send(int wkid, String mailident)
	{
        int r, mailid = Integer.parseInt(mailident);
        FileInputStream fmodele = null;
        FileOutputStream out = null;
        ArrayList<String> atts = new ArrayList<String>();
        String attachs[] = null;
        String s;

        try {

            Set rs = null;
//System.out.println("################## in send");
            while (true) {
                Set rsp = etn.execute("select * from post_work where id = " + wkid);
                rsp.next();

                if ("1".equals(rsp.value("is_generic_form")))
				{
                    s = " select p.*, g.*, m.sujet, m.sujet_lang_2, m.sujet_lang_3, m.sujet_lang_4, m.sujet_lang_5, a.email_to, a.where_clause, a.attach, cl.first_time_pass, g.lang as menu_lang from post_work p inner join generic_forms g on p.client_key = g.id "
                            + " inner join mails m on m.id = " + mailid + " left join mail_config a on  a.id = m.id left outer join "+env.getProperty("PORTAL_DB")+".clients cl on cl.email = g.email where p.id = " + wkid;
                } else {
                    Set rsOrder = etn.execute("Select * from orders where id = " + escape.cote(rsp.value("client_key")));
                    rsOrder.next();				

					String ordersiteid = rsOrder.value("site_id");
					String orderuuid = rsOrder.value("parent_uuid");
					String orderlang = rsOrder.value("lang");

					String _olang = rsOrder.value("lang");
                    boolean hasOffer = false;
                    Set rsOffers = etn.execute("select oi.id from order_items oi inner join orders o on o.parent_uuid = oi.parent_id where oi.product_type='offer_postpaid' and o.id = " + escape.cote(rsp.value("client_key")));
                    if(rsOffers.next()) hasOffer = true;

                    // getCurrency Position
                    String currencyPosition = "after";
                    Set rsCurrencyPosition = etn.execute("SELECT langue_id FROM "+CATALOG_DB+".language where langue_code = " + escape.cote(_olang));
                    if(rsCurrencyPosition.next()){
                        String langId = rsCurrencyPosition.value(0);
                        rsCurrencyPosition = etn.execute("SELECT lang_"+langId+"_currency_position FROM "+CATALOG_DB+".shop_parameters WHERE site_id = "+escape.cote(ordersiteid));
                        if(rsCurrencyPosition.next()){
                           currencyPosition =  rsCurrencyPosition.value(0);
                        }
                    } // if any error occur it will show the default value


                    Set rsOrderItems = etn.execute("Select oi.* from order_items oi inner join orders o on o.parent_uuid = oi.parent_id where o.id = " + escape.cote(rsp.value("client_key")));
                    String itemsList = "";
                    String itemsRows = "<table bgcolor=\"#000000\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\"\n" +
                        "   style=\"max-width: 640px; background-color: #000000;\">\n" +
                        "<tbody>\n" +
                        "<tr>\n" +
                        "    <td height=\"20\"></td>\n" +
                        "</tr>\n" +
                        "<tr>\n" +
                        "    <td>\n" +
                        "        <table bgcolor=\"#000000\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\"\n" +
                        "               style=\"max-width: 640px; background-color: #000000;\">\n" +
                        "            <tbody>\n" +
                        "            <tr>\n" +
                        "                <td width=\"25\" class=\"grownonmobile\"></td>\n" +
                        "                <td>\n" +
                        "                    <table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                        "                        <tbody>\n" +
                        "                        <tr>\n" +
                        "                            <td width=\""+(hasOffer?"332":"441")+"\" class=\"columnSizeMobile\" style=\"color: #FFFFFF; font-weight: bold; font-size: 16px; line-height:16px; vertical-align: middle;\">"+dictionary.getTranslation(_olang,"Produits")+"</td>\n" +
                        "                            <td style=\"min-width: 4px;\"></td>\n" +
                        "                            <td align=\"right\" width=\"105\" class=\"secondColumnSizeMobile\" style=\"color: #FFFFFF; font-weight: bold; font-size: 16px; line-height:16px; vertical-align: middle; text-align:left;\">"+dictionary.getTranslation(_olang,"Prix")+"<br/>"+dictionary.getTranslation(_olang,"en")+" "+rsOrder.value("currency")+"</td>\n";

                    if(hasOffer) itemsRows += "<td width=\"4\"></td>\n" +
                        "                            <td class=\"secondColumnSizeMobile\" style=\"color: #FFFFFF; font-weight: bold; font-size: 16px; line-height:16px; vertical-align: middle; text-align:left;\" width=\"105\">"+dictionary.getTranslation(_olang,"Prix/mois")+"<br>"+dictionary.getTranslation(_olang,"en")+" "+rsOrder.value("currency")+"</td>";

                        itemsRows += "                        </tr>\n" +
                                    "                        </tbody>\n" +
                                    "                    </table>\n" +
                                    "                </td>\n" +
                                    "                <td width=\"25\" class=\"grownonmobile\"></td>\n" +
                                    "            </tr>\n" +
                                    "            </tbody>\n" +
                                    "        </table>\n" +
                                    "    </td>\n" +
                                    "</tr>\n" +
                                    "<tr>\n" +
                                    "    <td height=\"20\"></td>\n" +
                                    "</tr>\n" +
                                    "</tbody></table><table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\"><tbody>";
                    String payment_method = rsOrder.value("spaymentmean");
                    String total_price = rsOrder.value("total_price");
                    String tracking_url = "";
                    JSONObject orderSnapshot = new JSONObject(rsOrder.value("order_snapshot"));

                    Set rsSite = etn.execute("select domain from "+env.getProperty("PORTAL_DB")+".sites where id="+escape.cote(rsOrder.value("site_id")));
                    if(rsSite.next())
					{
						tracking_url = rsSite.value("domain")+env.getProperty("CART_URL")+"trackingInfo.jsp";
					}
					
					String invoiceUrl = Util.getSiteConfig(etn, env, ordersiteid, "invoice_url");
					if(invoiceUrl.length() > 0)
					{
						if(invoiceUrl.indexOf("?") >= 0) invoiceUrl += "&";
						invoiceUrl += "?";
						invoiceUrl += "uid="+orderuuid;
					}
					System.out.println("Invoice url : " + invoiceUrl);

                    int totalQuantity = 0;
                    double totalToPay = 0;
                    double totalFixed = 0;
                    double totalRecurring = 0;
                    boolean isFirst = true;
                    while(rsOrderItems.next()){
                        String itemImageUrl = rsSite.value("domain")+env.getProperty("CART_URL")+"itemImage.jsp?id="+rsOrderItems.value("id")+"&parent_id="+rsOrderItems.value("parent_id");
                        totalQuantity += parseNullInt(rsOrderItems.value("quantity"));
                        totalToPay += parseNullDouble(rsOrderItems.value("price_value"));
                        if(rsOrderItems.value("product_type").equals("offer_postpaid")){
                            totalRecurring += parseNullDouble(rsOrderItems.value("price_value"));
                        }
                        else{
                            totalFixed += parseNullDouble(rsOrderItems.value("price_value"));
                        }

                        JSONObject productSnapshot = new JSONObject(rsOrderItems.value("product_snapshot"));
                        JSONObject promotion = new JSONObject(rsOrderItems.value("promotion"));
                        JSONArray attributes = new JSONArray(parseNull(productSnapshot.get("attributes")));
                        JSONArray additionalFee = new JSONArray(rsOrderItems.value("additionalfees"));
                        JSONArray comewith = new JSONArray(rsOrderItems.value("comewiths"));

                        String attributesString = "";
                        for(int i=0; i<attributes.length(); i++){
							String _attribValue = attributes.getJSONObject(i).optString("label", "");
							if(_attribValue.length() == 0) _attribValue = attributes.getJSONObject(i).getString("value");
                            attributesString += "<br>"+ dictionary.getTranslation(_olang, _attribValue);
                        }

                        String productName = (rsOrderItems.value("product_type").equals("offer_postpaid")?rsOrderItems.value("product_name")+" "+productSnapshot.get("variantName"):rsOrderItems.value("product_full_name"));
                        itemsList+= "\n"+productName;

                        for(int i=0; i<attributes.length(); i++){
							if(i == 0) itemsList += " - ";
							if(i>0) itemsList += " / ";
							String _attribValue = attributes.getJSONObject(i).optString("label", "");
							if(_attribValue.length() == 0) _attribValue = attributes.getJSONObject(i).getString("value");
							
                            itemsList+= _attribValue;
                        }
						if(parseNullInt(rsOrderItems.value("quantity")) > 1)
						{
							itemsList+= " ( x"+parseNullInt(rsOrderItems.value("quantity"))+" )";
						}
						if(rsOrderItems.value("product_type").equals("offer_postpaid") && parseNullInt(productSnapshot.get("duration"))>0)
						{
							itemsList+= " ( "+dictionary.getTranslation(_olang,"Engagement")+" "+productSnapshot.get("duration")+" "+dictionary.getTranslation(_olang,"mois")+" )";
						}
                        itemsList += " - "+ getCurrencyPosition(currencyPosition, rsOrderItems.value("price_value"), rsOrder.value("currency"), false);
						if(rsOrderItems.value("product_type").equals("offer_postpaid") && parseNullInt(productSnapshot.get("duration"))>0)
						{
							itemsList += "/"+dictionary.getTranslation(_olang,"mois");
						}

                        if(!isFirst) itemsRows += "<tr>\n" +
                        "    <td align=\"left\" valign=\"top\" width=\"100%\" height=\"1\" style=\"border:0; background-color: #CCCCCC; border-collapse:collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; mso-line-height-rule: exactly; line-height: 1px;\"><!--[if gte mso 15]>&nbsp;<![endif]--></td>\n" +
                        "</tr>";
                        itemsRows += "<tr>\n" +
                            "    <td height=\"20\"></td>\n" +
                            "</tr>\n" +
                            "\n" +
                            "<tr>\n" +
                            "    <td>\n" +
                            "        <table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                            "            <tbody>\n" +
                            "            <tr>\n" +
                            "                <td width=\"25\" class=\"grownonmobile\"></td>\n" +
                            "                <td width=\"100\" class=\"hideMobile\" height=\"100%\">\n" +
                            "                    <img src=\""+itemImageUrl+"\" alt=\"\" style=\"display:block; width: 100px; margin: auto; text-align: center; border:0;\">\n" +
                            "                </td>\n" +
                            "                <td width=\"20\" class=\"hideMobile\"></td>\n" +
                            "                <td>\n" +
                            "                    <table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                            "                        <tbody>\n" +
                            "                        <tr>\n" +
                            "                            <td width=\""+(hasOffer?"212":"321")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\">"+productName+"&nbsp;</td>\n" +
                            "                            <td style=\"min-width: 4px;\"></td>\n" +
                            "                            <td align=\"right\" style=\"\">\n" +
                            "                                <table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                            "                                    <tbody>\n" +
                            "                                    <tr style=\""+(rsOrderItems.value("price_old_value").equals(rsOrderItems.value("price_value"))?"display:none;":"")+"\">\n" +
                            "                                        <td align=\"right\" width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 14px; line-height:14px; text-decoration: line-through; color:#666666; text-align:left; \">"+(rsOrderItems.value("product_type").equals("offer_postpaid")?"":priceFormatter.formatPrice(ordersiteid, orderlang, rsOrderItems.value("price_old_value")))+"</td>\n" +
                            "                                    </tr>\n" +
                            "                                    <tr>\n" +
                            "                                        <td align=\"right\" width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;  text-align:left;\">"+(rsOrderItems.value("product_type").equals("offer_postpaid")?"":priceFormatter.formatPrice(ordersiteid, orderlang, rsOrderItems.value("price_value")))+"</td>\n" +
                            "                                    </tr>\n" +
                            "                                    </tbody>\n" +
                            "                                </table>\n" +
                            "                            </td>\n";
                        if(hasOffer){
                            itemsRows += "<td width=\"4\"></td>\n" +
                            "<td>\n" +
                            "    <table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">\n" +
                            "        <tbody>\n" +
                            "        <tr style=\""+(rsOrderItems.value("price_old_value").equals(rsOrderItems.value("price_value"))?"display:none;":"")+"\">\n" +
                            "            <td class=\"secondColumnSizeMobile\" style=\"font-size: 14px; line-height:14px; text-decoration: line-through; color:#666666; text-align:left;\" width=\"105\">"+(rsOrderItems.value("product_type").equals("offer_postpaid")?priceFormatter.formatPrice(ordersiteid, orderlang, rsOrderItems.value("price_old_value")):"")+"</td>\n" +
                            "        </tr>\n" +
                            "        <tr>\n" +
                            "            <td class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\" width=\"105\">"+(rsOrderItems.value("product_type").equals("offer_postpaid")?priceFormatter.formatPrice(ordersiteid, orderlang, rsOrderItems.value("price_value")):"")+"</td>\n" +
                            "        </tr>\n" +
                            "        </tbody>\n" +
                            "    </table>\n" +
                            "</td>";
                        }
                            itemsRows+="                        </tr>\n" +
                            "                        <tr>\n" +
                            "                            <td height=\"15\"></td>\n" +
                            "                        </tr>\n" +
                            "                         <tr>\n" +
                            "                            <td width=\""+(hasOffer?"212":"321")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px;\">"+attributesString+"</td>\n" +
                            "                            <td style=\"min-width: 4px;\"></td>\n" +
                            "                            <td align=\"right\" width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; \"></td>\n" +
                            "                         </tr>\n";

                            if(parseNullInt(rsOrderItems.value("quantity"))>1){
                                itemsRows += "<tr>\n" +
                            "                            <td height=\"15\"></td>\n" +
                            "                        </tr>\n" +
                            "                        <tr>\n" +
                            "                            <td width=\""+(hasOffer?"212":"321")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\">"+dictionary.getTranslation(_olang,"Quantité")+" : "+rsOrderItems.value("quantity")+"</td>\n" +
                            "                            <td style=\"min-width: 4px;\"></td>\n" +
                            "                            <td align=\"right\" width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;  text-align:left;\"></td>\n" +
                            "                        </tr>\n";
                            }

                            if(rsOrderItems.value("product_type").equals("offer_postpaid")){
                                itemsRows += "<tr>\n" +
                            "                            <td height=\"15\"></td>\n" +
                            "                        </tr>\n" +
                            "                        <tr>\n" +
                            "                            <td width=\""+(hasOffer?"212":"321")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px;\">"+(parseNullInt(productSnapshot.get("duration"))==0?dictionary.getTranslation(_olang,"Sans engagement"):dictionary.getTranslation(_olang,"Engagement")+" "+productSnapshot.get("duration")+" "+dictionary.getTranslation(_olang,"mois"))+"</td>\n" +
                            "                            <td style=\"min-width: 4px;\"></td>\n" +
                            "                            <td align=\"right\" width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;  text-align:left;\"></td>\n" +
                            "                        </tr>\n";
                                if(promotion.has("duration")&&parseNullInt(promotion.get("duration"))>0){
                                    itemsRows += "<tr>\n" +
                                "                            <td height=\"15\"></td>\n" +
                                "                        </tr>\n" +
                                "                        <tr>\n" +
                                "                            <td width=\""+(hasOffer?"212":"321")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px;\">"+dictionary.getTranslation(_olang,"Promotion pendant")+" "+promotion.get("duration")+" "+dictionary.getTranslation(_olang,"mois")+"</td>\n" +
                                "                            <td style=\"min-width: 4px;\"></td>\n" +
                                "                            <td align=\"right\" width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;  text-align:left;\"></td>\n" +
                                "                        </tr>\n";
                                }
                            }

                            if(rsOrderItems.value("product_type").equals("offer_prepaid")){
                                itemsRows += "<tr>\n" +
                            "                            <td height=\"15\"></td>\n" +
                            "                        </tr>\n" +
                            "                        <tr>\n" +
                            "                            <td width=\""+(hasOffer?"212":"321")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px;\">"+dictionary.getTranslation(_olang,"Sans engagement")+"</td>\n" +
                            "                            <td style=\"min-width: 4px;\"></td>\n" +
                            "                            <td align=\"right\" width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;  text-align:left;\"></td>\n" +
                            "                        </tr>\n";
                            }

                            for(int i=0; i<additionalFee.length(); i++){
								if(parseNullDouble(additionalFee.getJSONObject(i).getString("price")) == 0) continue;
                                totalToPay += parseNullDouble(additionalFee.getJSONObject(i).getString("price"));
                                totalFixed += parseNullDouble(additionalFee.getJSONObject(i).getString("price"));
                                itemsList += "\n"+additionalFee.getJSONObject(i).getString("name")+" - "+additionalFee.getJSONObject(i).getString("price");
                                itemsRows += "<tr>\n" +
                            "                            <td height=\"15\"></td>\n" +
                            "                        </tr>\n" +
                            "                        <tr>\n" +
                            "                            <td width=\""+(hasOffer?"212":"321")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\">"+additionalFee.getJSONObject(i).getString("name")+"</td>\n" +
                            "                            <td style=\"min-width: 4px;\"></td>\n" +
                            "                            <td align=\"right\" width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;  text-align:left;\">"+priceFormatter.formatPrice(ordersiteid, orderlang, additionalFee.getJSONObject(i).getString("price"))+"</td>\n" +
                            "                        </tr>\n";
                            }

                            for(int i=0; i<comewith.length(); i++){
                                itemsList += "\n"+comewith.getJSONObject(i).getString("title");
                                itemsRows += "<tr>\n" +
                            "                            <td height=\"15\"></td>\n" +
                            "                        </tr>\n" +
                            "                        <tr>\n" +
                            "                            <td width=\""+(hasOffer?"212":"321")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\">"+comewith.getJSONObject(i).getString("title")+"</td>\n" +
                            "                            <td style=\"min-width: 4px;\"></td>\n" +
                            "                            <td align=\"right\" width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;  text-align:left;\">"+dictionary.getTranslation(_olang,"Inclus")+"</td>\n" +
                            "                        </tr>\n";
                            }
                            itemsList+= "\n";

                            itemsRows += "                        </tbody>\n" +
                            "                    </table>\n" +
                            "                </td>\n" +
                            "                <td width=\"25\" class=\"grownonmobile\"></td>\n" +
                            "            </tr>\n" +
                            "            </tbody>\n" +
                            "        </table>\n" +
                            "    </td>\n" +
                            "</tr>\n" +
                            "<tr>\n" +
                            "    <td height=\"20\"></td>\n" +
                            "</tr>\n";

                            isFirst = false;
                    }

                    itemsRows += "</tbody></table><table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                            "<tbody>\n" +
                            "<tr>\n" +
                            "    <td align=\"left\" valign=\"top\" width=\"100%\" height=\"1\" style=\"border:0; background-color: #000000; border-collapse:collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; mso-line-height-rule: exactly; line-height: 1px;\"><!--[if gte mso 15]>&nbsp;<![endif]--></td>\n" +
                            "</tr>\n" +
                            "<tr>\n" +
                            "    <td height=\"20\"></td>\n" +
                            "</tr>\n" +
                            "<tr>\n" +
                            "    <td>\n" +
                            "        <table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                            "            <tbody>\n" +
                            "            <tr>\n" +
                            "                <td width=\"25\" class=\"grownonmobile\"></td>\n" +
                            "                <td>\n" +
                            "                    <table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                            "                        <tbody>\n" +
                            "                        <tr>\n" +
                            "                            <td width=\""+(hasOffer?"332":"441")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\">"+dictionary.getTranslation(_olang,"Total")+" ("+totalQuantity+" "+dictionary.getTranslation(_olang,"article(s)")+")</td>\n" +
                            "                            <td style=\"min-width: 4px;\"></td>\n" +
                            "                            <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold; \">"+priceFormatter.formatPrice(ordersiteid, orderlang, new BigDecimal(totalFixed+"").stripTrailingZeros().toPlainString())+"</td>\n";
                            if(hasOffer){
                                itemsRows += "<td width=\"4\"></td>\n" +
                                        "                 <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\"></td>";
                            }
                            itemsRows += "                        </tr>\n";

                    JSONArray calculatedCartDiscounts = orderSnapshot.getJSONArray("calculatedCartDiscounts");
					JSONObject promoCodeDiscountObj = null;
                    for(int i=0; i<calculatedCartDiscounts.length(); i++){
						if(calculatedCartDiscounts.getJSONObject(i).optString("couponCode","").length() > 0) promoCodeDiscountObj = calculatedCartDiscounts.getJSONObject(i);
						
                        totalToPay -= parseNullDouble(calculatedCartDiscounts.getJSONObject(i).getString("discountValue"));
                        totalFixed -= parseNullDouble(calculatedCartDiscounts.getJSONObject(i).getString("discountValue"));
                        if(calculatedCartDiscounts.getJSONObject(i).getString("couponCode").length()>0){
                            itemsRows += "                        <tr>\n" +
                                "                            <td height=\"15\"></td>\n" +
                                "                        </tr>\n" +
                                "                        <tr>\n" +
                                "                            <td width=\""+(hasOffer?"332":"441")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px;\">"+dictionary.getTranslation(_olang,"Remise code promo")+" \""+calculatedCartDiscounts.getJSONObject(i).getString("couponCode")+"\"</td>\n" +
                                "                            <td style=\"min-width: 4px;\"></td>\n" +
                                "                            <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; \">-"+priceFormatter.formatPrice(ordersiteid, orderlang, calculatedCartDiscounts.getJSONObject(i).getString("discountValue"))+"</td>\n";
                            if(hasOffer){
                                itemsRows += "<td width=\"4\"></td>\n" +
                                        "                 <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\"></td>";
                            }
                            itemsRows += "                        </tr>\n";
                        }
                        else{
                            itemsRows += "                        <tr>\n" +
                                "                            <td height=\"15\"></td>\n" +
                                "                        </tr>\n" +
                                "                        <tr>\n" +
                                "                            <td width=\""+(hasOffer?"332":"441")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px;\">"+dictionary.getTranslation(_olang,"Remise panier")+"</td>\n" +
                                "                            <td style=\"min-width: 4px;\"></td>\n" +
                                "                            <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; \">-"+priceFormatter.formatPrice(ordersiteid, orderlang, calculatedCartDiscounts.getJSONObject(i).getString("discountValue"))+"</td>\n";
                            if(hasOffer){
                                itemsRows += "<td width=\"4\"></td>\n" +
                                        "                 <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\"></td>";
                            }
                            itemsRows += "                        </tr>\n";
                        }
                    }
                    if(parseNullDouble(rsOrder.value("payment_fees"))>0){
                        itemsRows += "                        <tr>\n" +
                                "                            <td height=\"15\"></td>\n" +
                                "                        </tr>\n" +
                                "                        <tr>\n" +
                                "                            <td width=\""+(hasOffer?"332":"441")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px;\">"+dictionary.getTranslation(_olang,"Frais de paiement")+"</td>\n" +
                                "                            <td style=\"min-width: 4px;\"></td>\n" +
                                "                            <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; \">"+priceFormatter.formatPrice(ordersiteid, orderlang, rsOrder.value("payment_fees"))+"</td>\n";
                        if(hasOffer){
                            itemsRows += "<td width=\"4\"></td>\n" +
                                    "                 <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\"></td>";
                        }
                        itemsRows += "                        </tr>\n";
                    }
                    if(parseNullDouble(rsOrder.value("delivery_fees"))>0){
                        itemsRows += "                        <tr>\n" +
                                "                            <td height=\"15\"></td>\n" +
                                "                        </tr>\n" +
                                "                        <tr>\n" +
                                "                            <td width=\""+(hasOffer?"332":"441")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px;\">"+dictionary.getTranslation(_olang,"Frais de livraison")+"</td>\n" +
                                "                            <td style=\"min-width: 4px;\"></td>\n" +
                                "                            <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; \">"+priceFormatter.formatPrice(ordersiteid, orderlang, rsOrder.value("delivery_fees"))+"</td>\n";
                        if(hasOffer){
                            itemsRows += "<td width=\"4\"></td>\n" +
                                    "                 <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\"></td>";
                        }
                        itemsRows += "                        </tr>\n";
                    }


                            itemsRows += "                        <tr>\n" +
                            "                            <td height=\"15\"></td>\n" +
                            "                        </tr>\n" +
                            "                        <tr>\n" +
                            "                            <td height=\"15\"></td>\n" +
                            "                        </tr>\n" +
                            "                        </tbody>\n" +
                            "                    </table>\n" +
                            "                </td>\n" +
                            "                <td width=\"25\" class=\"grownonmobile\"></td>\n" +
                            "            </tr>\n" +
                            "            </tbody>\n" +
                            "        </table>\n" +
                            "    </td>\n" +
                            "</tr>\n" +
                            "\n" +
                            "<tr>\n" +
                            "    <td height=\"20\"></td>\n" +
                            "</tr>\n" +
                            "\n" +
                            "<tr>\n" +
                            "    <td align=\"left\" valign=\"top\" width=\"100%\" height=\"1\" style=\"border:0; background-color: #000000; border-collapse:collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; mso-line-height-rule: exactly; line-height: 1px;\"><!--[if gte mso 15]>&nbsp;<![endif]--></td>\n" +
                            "</tr>\n" +
                            "<tr>\n" +
                            "    <td height=\"20\"></td>\n" +
                            "</tr>\n" +
                            "<tr>\n" +
                            "    <td>\n" +
                            "        <table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                            "            <tbody>\n" +
                            "            <tr>\n" +
                            "                <td width=\"25\" class=\"grownonmobile\"></td>\n" +
                            "                <td>\n" +
                            "                    <table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                            "                        <tbody>\n" +
                            "                        <tr>\n" +
                            "                            <td height=\"15\"></td>\n" +
                            "                        </tr>\n" +
                            "                        <tr>\n" +
                            "                            <td width=\""+(hasOffer?"332":"441")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\">"+dictionary.getTranslation(_olang,"Montant à payer")+"</td>\n" +
                            "                            <td style=\"min-width: 4px;\"></td>\n" +
                            "                            <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold; \">"+ getCurrencyPosition(currencyPosition, priceFormatter.formatPrice(ordersiteid, orderlang, total_price), rsOrder.value("currency"), true)+"</td>\n";
                            if(hasOffer){
                                itemsRows += "<td width=\"4\"></td>\n" +
                                "                 <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold; color: #000000;\">"+getCurrencyPosition(currencyPosition, priceFormatter.formatPrice(ordersiteid, orderlang, new BigDecimal(totalRecurring+"").stripTrailingZeros().toPlainString()), rsOrder.value("currency")+"/"+dictionary.getTranslation(_olang,"mois"), true) +"</td>";
                            }
                            itemsRows += "                        </tr>\n" +
                            "                        </tbody>\n" +
                            "                    </table>\n" +
                            "                </td>\n" +
                            "                <td width=\"25\" class=\"grownonmobile\"></td>\n" +
                            "            </tr>\n" +
                            "            </tbody>\n" +
                            "        </table>\n" +
                            "    </td>\n" +
                            "</tr>\n" +
                            "<tr>\n" +
                            "    <td height=\"20\"></td>\n" +
                            "</tr>\n" +
                            "\n" +
                            "<tr>\n" +
                            "    <td align=\"left\" valign=\"top\" width=\"100%\" height=\"1\" style=\"border:0; background-color: #000000; border-collapse:collapse; mso-table-lspace: 0pt; mso-table-rspace: 0pt; mso-line-height-rule: exactly; line-height: 1px;\"><!--[if gte mso 15]>&nbsp;<![endif]--></td>\n" +
                            "</tr>\n" +
                            "\n" +
                            "<tr>\n" +
                            "    <td height=\"20\"></td>\n" +
                            "</tr>\n" +
                            "\n" +
                            "<tr>\n" +
                            "    <td>\n" +
                            "        <table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                            "            <tbody>\n" +
                            "            <tr>\n" +
                            "                <td width=\"25\" class=\"grownonmobile\"></td>\n" +
                            "                <td>\n" +
                            "                    <table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\n" +
                            "                        <tbody>\n";
                            if(!(payment_method.equals("cash_on_delivery")||payment_method.equals("cash_on_pickup")) && parseNullDouble(total_price)>0){
                                itemsRows += "                        <tr>\n" +
                                "                            <td width=\""+(hasOffer?"332":"441")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\">"+dictionary.getTranslation(_olang,"Déjà payé")+"</td>\n" +
                                "                            <td style=\"min-width: 4px;\"></td>\n" +
                                "                            <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\">"+ getCurrencyPosition(currencyPosition, priceFormatter.formatPrice(ordersiteid, orderlang, total_price), rsOrder.value("currency"), true)+"</td>\n";
                                if(hasOffer){
                                    itemsRows += "                            <td width=\"4\"></td>\n" +
                                    "                            <td width=\"105\" class=\"secondColumnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\"></td>\n";
                                }
                                itemsRows += "                        </tr>\n" +
                                "                        <tr>\n" +
                                "                            <td height=\"15\"></td>\n" +
                                "                        </tr>\n";
                            }
                            if(totalRecurring>0 || (payment_method.equals("cash_on_delivery")||payment_method.equals("cash_on_pickup")) && parseNullDouble(total_price)>0){
                                itemsRows += "                        <tr>\n" +
                                "                            <td width=\""+(hasOffer?"332":"441")+"\" class=\"columnSizeMobile\" style=\"font-size: 16px; line-height:16px; font-weight: bold;\">"+dictionary.getTranslation(_olang,"Reste à payer")+"</td>\n" +
                                "                            <td style=\"min-width: 4px;\"></td>\n" +
                                "                            <td width=\"105\" class=\"secondColumnSizeMobile priceColor\" style=\"font-size: 16px; line-height:16px; font-weight: bold; color: #F16E00;\">"+((payment_method.equals("cash_on_delivery")||payment_method.equals("cash_on_pickup") && parseNullDouble(total_price)>0)?getCurrencyPosition(currencyPosition, priceFormatter.formatPrice(ordersiteid, orderlang, total_price), rsOrder.value("currency"), true):"")+"</td>\n";
                                if(hasOffer && totalRecurring>0){
                                    itemsRows += "                            <td width=\"4\"></td>\n" +
                                    "                            <td width=\"105\" class=\"secondColumnSizeMobile priceColor\" style=\"font-size: 16px; line-height:16px; font-weight: bold; color: #F16E00;\">"+getCurrencyPosition(currencyPosition, priceFormatter.formatPrice(ordersiteid, orderlang, new BigDecimal(totalRecurring+"").stripTrailingZeros().toPlainString()), rsOrder.value("currency")+"/"+dictionary.getTranslation(_olang,"mois"), true) +"</td>\n";
                                }
                                itemsRows += "                        </tr>\n";
                            }
                            itemsRows += "                        </tbody>\n" +
                            "                    </table>\n" +
                            "                </td>\n" +
                            "                <td width=\"25\" class=\"grownonmobile\"></td>\n" +
                            "            </tr>\n" +
                            "            </tbody>\n" +
                            "        </table>\n" +
                            "    </td>\n" +
                            "</tr>" +
                            "<tr>\n" +
                            "    <td height=\"50\"></td>\n" +
                            "</tr>\n" +
                            "</tbody></table>";


					String remainingPromoValue = "";
					if(promoCodeDiscountObj != null)
					{
						remainingPromoValue = ""+(parseNullDouble(promoCodeDiscountObj.optString("originalRuleValue")) - parseNullDouble(promoCodeDiscountObj.optString("discountValue")));
						remainingPromoValue = priceFormatter.formatPrice(ordersiteid, orderlang, remainingPromoValue);
						remainingPromoValue = getCurrencyPosition(currencyPosition, remainingPromoValue, rsOrder.value("currency"), false);
					}
					
					Map<String, String> additionalInfoCols = Util.getOrderAdditionalInfoCols(rsOrder.value("additional_info"));

                    HashMap<String, String> paymentImages = new HashMap<String, String>();
                    paymentImages.put("credit_card", "/src/assets/icons/payment-method/Visa.png");
                    paymentImages.put("cash_on_delivery", "/src/assets/icons/payment-method/ic_Currency_money.png");
                    paymentImages.put("cash_on_pickup", "/src/assets/icons/payment-method/ic_Currency_money.png");
                    paymentImages.put("orange_money", "/src/assets/icons/payment-method/Orangemoney.png");
                    paymentImages.put("paypal", "/src/assets/icons/payment-method/Paypal.png");
                    paymentImages.put("orange_money_obf", "/src/assets/icons/payment-method/Orangemoney.png");
                    paymentImages.put("tingg", "/src/assets/icons/payment-method/tingg.png");


                    s = "select c.*, case c.shipping_method_id when 'home_delivery' then concat(c.salutation, ' ', c.name, ' ', c.surnames) else '' end as delivery_name"
                                + ", case c.shipping_method_id when 'home_delivery' then c.email else '' end as delivery_email"
                                + ", case c.shipping_method_id when 'home_delivery' then 'Email : ' else '' end as delivery_email_label"
                                + ", case c.shipping_method_id when 'home_delivery' then concat("+escape.cote(dictionary.getTranslation(_olang, "Téléphone"))+",' : ', c.contactPhoneNumber1) else '' end as delivery_phone"
                                + ", case when coalesce(c.spaymentmean,'') = '' then 'display:none;' else '' end as displaypaymentoption "
                                + ", case when coalesce(c.shipping_method_id,'') = '' then 'display:none;' else '' end as displaydeliveryoption "
                                + ", case when c.spaymentmean='cash_on_delivery' or c.spaymentmean='cash_on_pickup' then '' else concat("+escape.cote(dictionary.getTranslation(_olang, "Numéro de transaction"))+",' : ', c.transaction_code) end as payment_transaction_code"
                                + ", "+escape.cote(tracking_url)+" as tracking_url "
                                + ", "+escape.cote(invoiceUrl)+" as invoice_url "
                                + ", "+escape.cote(rsSite.value("domain")+parseNull(paymentImages.get(payment_method)))+" as payment_icon, "+escape.cote(itemsList)+" as itemslist, "+escape.cote(itemsRows)+" as itemsrows, sum(oi.quantity) as totalQuantity"
                                + ", IF(COALESCE(ph.displayName1,'')<>'',ph.displayName1,ph.displayName) as phaseDisplayName, date_format(p.insertion_date, '%d/%m/%Y') as insertion_date"
                                + ", m.sujet, m.sujet_lang_2, m.sujet_lang_3, m.sujet_lang_4, m.sujet_lang_5, a.email_to, a.where_clause, a.attach, c.lang as menu_lang "
                                + ", day(creationDate) as day, month(creationDate) as month, year(creationDate) as year, "+escape.cote(remainingPromoValue)+" as remaining_promo_value "
                                + ", date_format(rdv_date, '%d/%m/%Y') as slot_date, date_format(rdv_date, '%H:%i') as slot_start_time, case date_format(rdv_date, '%H:%i') when '11:30' then '13:30' when '13:30' then '15:00' when '18:30' then '20:30' else '22:00' end as slot_end_time";
					
					if(additionalInfoCols != null)
					{
						for(Map.Entry<String, String> entry : additionalInfoCols.entrySet())
						{
							s += ", "+escape.cote(entry.getValue()) + " as " + entry.getKey();
						}
					}
								
					s += " from post_work p inner join customer c on c.customerid = p.client_key inner join phases ph ON p.proces = ph.process AND p.phase = ph.phase inner join order_items oi on oi.parent_id = c.parent_uuid "
                            + " inner join mails m on m.id = " + mailid + " left join mail_config a on  a.id = m.id and a.ordertype = c.orderType where p.id = " + wkid + " group by oi.parent_id";
                }
				
//				System.out.println(">>>>>>>>>>>>>>>>>>>>>>----------------------------------------");
//				System.out.println(s);
                rs = etn.execute(s);

                //System.out.println(s);
                if (!rs.next()) {
                    return (NO_ROW);
                }

                // Analyse du where_clause
                s = rs.value("where_clause");
                if (s.length() == 0) {
                    break;
                }

                if ((r = getMailId(wkid, s, rs)) == mailid) {
                    break;
                }
                if (r <= 0) {
                    return (0);
                }
                mailid = r;
//System.out.println("################## in send : " + mailid);
            }

            //System.out.println("mailid:"+mailid);

 	     String maillang = "fr";//default language
	     if(rs != null && parseNull(rs.value("menu_lang")).length() > 0) maillang = parseNull(rs.value("menu_lang"));

            // Destinataires
            if (setRecipients(rs) == 0) {
                return (NO_CONTACT); // nothing to do
            }
            System.out.println("TO:" + destTO[0].toString());
            System.out.println("CC:" + (destCC != null ? Arrays.toString(destCC) : "null"));
            System.out.println("BCC:" + (destBCC != null ? Arrays.toString(destBCC) : "null"));

            setFrom(env.getProperty("MAIL_FROM"), env.getProperty("MAIL_FROM_DISPLAY_NAME"));
            if(parseNull(env.getProperty("MAIL_REPLY")).length() > 0) setReply(env.getProperty("MAIL_REPLY"));

	     Set rslang = etn.execute("select * from language order by langue_id ");
	     int langcount = 1;
            while(rslang.next())
	     {
	     	if(maillang.equals(rslang.value("langue_code"))) break;
	       langcount++;
	     }
	     System.out.println("Subject column : " + "sujet_lang_"+langcount);
	     String sujet = parseNull(rs.value("sujet_lang_"+langcount));
            if(sujet.length() == 0) sujet = rs.value("sujet");

	     System.out.println("Final Subject : " + sujet);

            String toattach = rs.value("attach");

	     String emailtemplate = repository + "/mail" + mailid + "_" + maillang;
	     File ftemplate = new File(emailtemplate);
		System.out.println("Try Template : " + emailtemplate);
	     if(!ftemplate.exists() || ftemplate.length() == 0) emailtemplate = repository + "/mail" + mailid;
		System.out.println("Final Template : " + emailtemplate);

            fmodele = new FileInputStream(emailtemplate);

            if( toattach.indexOf("pdfBill") != -1 )
            {
               atts.add(
                 new PdfBill(etn,env).makePdf(rs.value("customerid"), rs.value("orderRef"), "bill") );
            }

            if( toattach.indexOf("pdfRecap") != -1 )
            {
               atts.add(
                 new PdfBill(etn,env).makePdf(rs.value("customerid"), rs.value("orderRef"), "recap") );
            }


            if (toattach.indexOf("calendarevent_") != -1) {

                SendCalendar sc = new SendCalendar(etn, env);
                if(toattach.indexOf("calendarevent_assign_client") != -1){
                    File icsFile = sc.getCalendarFile(wkid, SendCalendar.EVENT_TYPE_ASSIGN, SendCalendar.EVENT_EMAIL_CLIENT);
                    if(icsFile != null){
                        atts.add(icsFile.getAbsolutePath());
                    }
                }
                else if(toattach.indexOf("calendarevent_assign_resource") != -1){
                    File icsFile = sc.getCalendarFile(wkid, SendCalendar.EVENT_TYPE_ASSIGN, SendCalendar.EVENT_EMAIL_RESOURCE);
                    if(icsFile != null){
                        atts.add(icsFile.getAbsolutePath());
                    }
                }
                else if(toattach.indexOf("calendarevent_cancel_client") != -1){
                    File icsFile = sc.getCalendarFile(wkid, SendCalendar.EVENT_TYPE_CANCEL, SendCalendar.EVENT_EMAIL_CLIENT);
                    if(icsFile != null){
                        atts.add(icsFile.getAbsolutePath());
                    }
                }
                else if(toattach.indexOf("calendarevent_cancel_resource") != -1){
                    File icsFile = sc.getCalendarFile(wkid, SendCalendar.EVENT_TYPE_CANCEL, SendCalendar.EVENT_EMAIL_RESOURCE);
                    if(icsFile != null){
                        atts.add(icsFile.getAbsolutePath());
                    }
                }

//for(String sss : atts) System.out.println("--------------------------------- " + sss);

                // atts.add(
                //         new Pdf(env).makePdf((String) env.get("MAIL_PS_MODELE"), rs));
            }

/*            if (toattach.indexOf("contrat") != -1) {
                atts.add(
                        new Pdf(env).makePdf((String) env.get("MAIL_PS_MODELE"), rs));
            }
*/

            if (atts.size() > 0) {
                attachs = atts.toArray(new String[atts.size()]);
                for (int n = 0; n < attachs.length; n++) {
                    System.out.println("Attachs[" + n + "] = " + attachs[n]);
                }
            }

            return (send(fmodele, rs, sujet, attachs));
        } catch (Exception e) {
            e.printStackTrace();
            if (debug) {
                System.out.println("MAIL: wid:" + wkid);
            }
            return (NO_CONNECTION);
        } finally {
            try {
                if (fmodele != null) {
                    fmodele.close();
                }
                if (out != null) {
                    out.close();
                }
                if (attachs != null) {
                    for (int n = 0; n < attachs.length; n++) {
                        if (attachs[n] != null) {
                            //new File(attachs[n]).delete();
                        }
                    }
                }
            } catch (Exception ze) {
            }
        }


    }

    public int test(int wkid, String mailident) {
        int r, mailid = Integer.parseInt(mailident);
        FileInputStream fmodele = null;
        FileOutputStream out = null;
        ArrayList<String> atts = new ArrayList<String>();
        String attachs[] = null;
        String s;


        try {

            Set rs = null;
//System.out.println("################## in send");
            while (true) {
                rs =
                        etn.execute(s =
                        "select  p.*, c.*, round(c.ORDER_COST_DAY_AFTER_PROMO) as ORDER_COST_DAY_AFTER_PROMO, round(c.price) as price, "
                        + "p.id as wkid,  "
                        + "c.creationDate as fecha,c.ordertype,"
                        + "previousOperator as opdonante, day(creationDate) as dia ,"
                        + "month(creationDate) as mes ,  year(creationDate) as ano, "
                        + "hour(creationDate) as heure , minute(creationDate) as minute, "
                        + " case (typeOfPaymentCurrentOperator) "
                        + "when 'contrato' then 'C'"
                        + "when ('tjt' or 'prepago') then 'T'"
                        + "end as forma_pago_donante ,"
                        + "previousIccidSim as simDonante,"
                        + "name as nombre,"
                        + "surnames as apelidos,"
                        + "identityType as tipodoc,"
                        + "identityId as numdoc,"
                        + "if(sex='H','M','F') sexo,"
                        + "nationality as natio,"
                        + "dateOfBirth as naciemento,"
                        + "paypalid as paypalid, "
                        + "m.sujet ,"
                        + "a.email_to, a.where_clause, a.attach,  "
                        + " (select round(m.cost_day_before_promo) from materiels m where m.customerid = c.customerid and product_type = 7 ) as terminal_cost_day_before_promo, "
                        + " (select round(m.cost_day_after_promo) from materiels m where m.customerid = c.customerid and product_type = 7 ) as terminal_cost_day_after_promo, "
                        + " (select m.quantity from materiels m where m.customerid = c.customerid and product_type = 7 ) as terminal_qty, "
                        + " (select replace(replace(replace(m.SKU_DISPLAY_NAME_L1,'PAYMU sku',''),'PAYMA sku',''),'PAYGA sku','') from materiels m where m.customerid = c.customerid and product_type = 7 ) as terminal_sku_display_name, "
                        + " (select round(m.cost_day_before_promo) from materiels m where m.customerid = c.customerid and product_type = 6 ) as sim_cost_day_before_promo, "
                        + " (select round(m.cost_day_after_promo) from materiels m where m.customerid = c.customerid and product_type = 6 ) as sim_cost_day_after_promo, "
                        + " (select m.quantity from materiels m where m.customerid = c.customerid and product_type = 6 ) as sim_qty, "
                        + " (select m.SKU_DISPLAY_NAME_L1 from materiels m where m.customerid = c.customerid and product_type = 6 ) as sim_sku_display_name, "
                        + " (select round(m.cost_day_before_promo) from materiels m where m.customerid = c.customerid and product_type = 5 and subtype_name in ('talkplan','dataplan') ) as tarif_cost_day_before_promo, "
                        + " (select round(m.cost_day_after_promo) from materiels m where m.customerid = c.customerid and product_type = 5 and subtype_name in ('talkplan','dataplan') ) as tarif_cost_day_after_promo, "
                        + " (select m.quantity from materiels m where m.customerid = c.customerid and product_type = 5 and subtype_name in ('talkplan','dataplan') ) as tarif_qty, "
                        + " (select m.SKU_DISPLAY_NAME_L1 from materiels m where m.customerid = c.customerid and product_type = 5 and subtype_name in ('talkplan','dataplan') ) as tarif_sku_display_name, "
                        + " (select round(m.rec_price_after_promo) from materiels m where m.customerid = c.customerid and product_type = 5 and subtype_name in ('talkplan','dataplan') ) as tarif_rec_price_after_promo, "
                        + " (select round(m.cost_day_before_promo) from materiels m where m.customerid = c.customerid and subtype_name='vas' ) as vas_data_cost_day_before_promo, "
                        + " (select round(m.cost_day_after_promo) from materiels m where m.customerid = c.customerid and subtype_name='vas' ) as vas_data_cost_day_after_promo, "
                        + " (select m.quantity from materiels m where m.customerid = c.customerid and subtype_name='vas' ) as vas_data_qty, "
                        + " (select m.product_display_name from materiels m where m.customerid = c.customerid and subtype_name='vas' ) as vas_product_name, "
                        + " (select m.SKU_DISPLAY_NAME_L1 from materiels m where m.customerid = c.customerid and subtype_name='vas' ) as vas_sku_display_name, "
                        + " (select m.SKU_DISPLAY_NAME_L1 from materiels m where m.customerid = c.customerid and product_type = 1 ) as pack_name, "
                        + " (select round(m.cost_day_after_promo) from materiels m where m.customerid = c.customerid and product_type = 1 ) as pack_price, "
                        + " (select round(m.rec_price_after_promo) from materiels m where m.customerid = c.customerid and product_type = 1 ) as pack_rec_price "
                        + " from post_work p inner join customer c "
                        + " on p.client_key = c.customerid "
                        + " inner join mails m on m.id = " + mailid
                        + " left join mail_config a on  a.id = m.id and a.ordertype = c.ordertype "
                        + " where p.id = " + wkid);

                System.out.println(s);
                if (!rs.next()) {
                    return (NO_ROW);
                }

                // Analyse du where_clause
                s = rs.value("where_clause");
                if (s.length() == 0) {
                    break;
                }

                if ((r = getMailId(wkid, s, rs)) == mailid) {
                    break;
                }
                if (r <= 0) {
                    return (0);
                }
                mailid = r;
//System.out.println("################## in send : " + mailid);
            }

            //System.out.println("mailid:"+mailid);

            // Destinataires
            if (setRecipients(rs) == 0) {
                return (NO_CONTACT); // nothing to do
            }
            System.out.println("TO:" + destTO[0].toString());
            System.out.println("CC:" + (destCC != null ? Arrays.toString(destCC) : "null"));
            System.out.println("BCC:" + (destBCC != null ? Arrays.toString(destBCC) : "null"));

            // par defaut
            setFrom(env.getProperty("MAIL_FROM"), env.getProperty("MAIL_FROM_DISPLAY_NAME"));
            if(parseNull(env.getProperty("MAIL_REPLY")).length() > 0) setReply(env.getProperty("MAIL_REPLY"));


            String sujet = rs.value("sujet");
            String toattach = rs.value("attach");
//System.out.println("$$$$$$$$$$$$ mail repository " + repository);
            fmodele = new FileInputStream(repository + "/mail" + mailid);

            atts.add(new String(("/tmp/méditel.pdf").getBytes(), "UTF-8"));

            if (atts.size() > 0) {
                attachs = atts.toArray(new String[atts.size()]);
                for (int n = 0; n < attachs.length; n++) {
                    System.out.println("Attachs[" + n + "] = " + attachs[n]);
                }
            }



            return (send(fmodele, rs, sujet, attachs));
        } catch (Exception e) {
            e.printStackTrace();
            if (debug) {
                System.out.println("MAIL: wid:" + wkid);
            }
            return (NO_CONNECTION);
        } finally {
            try {
                if (fmodele != null) {
                    fmodele.close();
                }
                if (out != null) {
                    out.close();
                }
                if (attachs != null) {
                    for (int n = 0; n < attachs.length; n++) {
                        if (attachs[n] != null) {
                            new File(attachs[n]).delete();
                        }
                    }
                }
            } catch (Exception ze) {
            }
        }
    }

    public static void main(String a[])
            throws Exception {

        String mailid;
        int wkid;
        String orderType = null, tosend = null;


        if (a.length == 0) {
            mailid = "1";
            wkid = 2209;
        } else if ("test".equals(a[0])) {
            if (a.length != 4) {
                System.exit(1);
            }
            mailid = a[1];
            tosend = a[2];
            orderType = a[3];
            wkid = 2209;
        } else {
            mailid = a[0];
            wkid = Integer.parseInt(a[1]);
        }

        Properties p = new Properties();
        p.load(SendMail.class.getResourceAsStream("Scheduler.conf"));

        com.etn.Client.Impl.ClientDedie etn =
                new com.etn.Client.Impl.ClientDedie("MySql",
                "com.mysql.jdbc.Driver",
                p.getProperty("CONNECT"));

        if (tosend != null && orderType != null) {
            etn.execute("update customer "
                    + " set ordertype =" + escape.cote(orderType)
                    + ", email = " + escape.cote(tosend)
                    + " where customerid = 1 ");
        }

        SendMail sm = new SendMail(etn, p);
//System.out.println("####### main send");
        int r = sm.send(wkid, mailid);
        System.out.println("" + r);
        System.exit(r);

    }
}