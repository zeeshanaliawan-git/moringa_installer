package com.etn.eshop;

import com.etn.eshop.mail.*;

import java.io.*;
import java.net.URL;

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


import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;

public class SendStockMail extends MailFromModel {

    public final int NO_MAILID = 1;
    public final int NO_ROW = 2;
    public final int NO_CONTACT = 3;
    public final int NO_CONNECTION = -1;
    ClientSql etn;
    String repository;
    Properties env;
    String lang;
    InternetAddress FROM;
    InternetAddress REPLY[];
	private Dictionary dictionary;	

    public void addSousPart(MimeMultipart cur, BodyPart lastmodel, int niveau, int souspart) {
        //System.out.println( "niveau:"+niveau+" souspart:"+souspart);
    }

    public SendStockMail(ClientSql etn, Properties conf) throws Exception 
	{
        super(conf);
        this.etn = etn;
        this.env = conf;
        this.lang = "1";

        repository = env.getProperty("MAIL_REPOSITORY");
		dictionary = new Dictionary(etn , conf );		
    }

    InternetAddress setAdr(String adr) 
	{
        try {
            return (new InternetAddress(adr));
        } catch (Exception e) {
            return (null);
        }
    }

    String parseNull(Object o)
    {
      if( o == null )
        return("");
      String s = o.toString();
      if("null".equals(s.trim().toLowerCase()))
        return("");
      else
        return(s.trim());
    }
        
    int setEmail(String email) {
        if(email.equals("")) return 0;
        destTO = new InternetAddress[1];
        destTO[0] = setAdr(email);
        return (1);
    }

    public int send(Set rsMail) 
	{
        if(!rsMail.value("langue_id").equals("")) this.lang = rsMail.value("langue_id");
        else this.lang="1";
        FileInputStream fmodele = null;
        FileOutputStream out = null;
        String attachs[] = null;

        try 
		{
			String mailid = parseNull(rsMail.value("emailTemplateId"));
			if(mailid.length() == 0 || "0".equals(mailid))
			{
				return -1;
			}
			System.out.println("Stock alert email template id : " + mailid);
			String maillang = "";
			Set rsLang = etn.execute("select * from language order by langue_id limit 1");
			if(rsLang.next()) maillang = rsLang.value("langue_code");
			
			if( parseNull(rsMail.value("langue_code")).length() > 0) maillang = parseNull(rsMail.value("langue_code"));

            // Destinataires
            if (setEmail(rsMail.value("email")) == 0) {
                return (NO_CONTACT); // nothing to do
            }

            setFrom(env.getProperty("MAIL_FROM"), env.getProperty("MAIL_FROM_DISPLAY_NAME"));
            setReply(env.getProperty("MAIL_REPLY"));

			String emailtemplate = repository + "/mail" + mailid + "_" + maillang;
			File ftemplate = new File(emailtemplate);
			System.out.println("Try Template : " + emailtemplate);
			if(!ftemplate.exists() || ftemplate.length() == 0) emailtemplate = repository + "/mail" + mailid;
			System.out.println("Final Template : " + emailtemplate);

            fmodele = new FileInputStream(emailtemplate);
            
            Set rsAttributes = etn.execute(" select ca.name, cav.attribute_value from "+env.getProperty("CATALOG_DB")+".product_variants pv inner join "+env.getProperty("CATALOG_DB")+".product_variant_ref pvr on pv.id = pvr.product_variant_id inner join "+env.getProperty("CATALOG_DB")+".catalog_attributes ca on pvr.cat_attrib_id = ca.cat_attrib_id inner join "+env.getProperty("CATALOG_DB")+".catalog_attribute_values cav on pvr.catalog_attribute_value_id = cav.id where pv.id ="+escape.cote(rsMail.value("variant_id")));            
            String attributesString = "";
            while(rsAttributes.next()){
                attributesString += rsAttributes.value(1)+"<br>";
            }
            
            String productUrl = rsMail.value("domain");
            Set rsCachedContent = etn.execute(" select cc.* from "+env.getProperty("PORTAL_DB")+".cached_content cc inner join "+env.getProperty("PORTAL_DB")+".cached_pages cp on cc.cached_page_id = cp.id where cp.menu_id = "+escape.cote(rsMail.value("menu_id"))+" and cc.content_type = 'product' and cc.content_id = "+escape.cote(rsMail.value("product_id")));
            if(rsCachedContent.next()) productUrl+= rsCachedContent.value("published_url");
            
            String variantImage = rsMail.value("domain")+env.getProperty("PRODUCTS_IMG_PATH")+rsMail.value("product_id")+"/";
            Set rsProduct = etn.execute(" select * from "+env.getProperty("CATALOG_DB")+".products where id="+escape.cote(rsMail.value("product_id")));
            String query;
            if(rsProduct.value("product_type").equals("offer_postpaid")||rsProduct.value("product_type").equals("offer_prepaid"))
			{
				query = " select image_file_name as path, image_label as label from "+env.getProperty("CATALOG_DB")+".product_images where product_id = " + escape.cote(rsMail.value("product_id")) + " and langue_id = " + escape.cote(rsMail.value("langue_id")) + " order by sort_order limit 1; ";
			}
			else
			{
				query = "select * from "+env.getProperty("CATALOG_DB")+".product_variant_resources where type='image' and product_variant_id="+escape.cote(rsMail.value("variant_id"))+" and langue_id="+escape.cote(rsMail.value("langue_id"))+" order by sort_order limit 1";
			} 

            Set rsVariantImage = etn.execute(query);
            if(rsVariantImage.next())
			{
                String targetImage = rsVariantImage.value("path");
                if(targetImage.indexOf(".") > -1)
                {
                        String ext = targetImage.substring(targetImage.lastIndexOf("."));
                        String fname = targetImage.substring(0, targetImage.lastIndexOf("."));
                        targetImage = fname + "_email" + ext;
                }
                else targetImage = targetImage + "_email";
                String[] cmdArray = new String[5]; 
                cmdArray[0] = "convert";
                cmdArray[1] = "-resize";
                cmdArray[2] = "100x133";
                cmdArray[3] = env.getProperty("PRODUCTS_UPLOAD_DIRECTORY")+rsMail.value("product_id")+"/"+rsVariantImage.value("path");
                cmdArray[4] = env.getProperty("PRODUCTS_UPLOAD_DIRECTORY")+rsMail.value("product_id")+"/"+targetImage;
                Process process = Runtime.getRuntime().exec(cmdArray, null);
                int retVal = 0;
                retVal = process.waitFor();
                if (retVal != 0) {
                    System.out.println("fail to resize variant image");
                }        
                variantImage+= targetImage;
            } 
            rsProduct = etn.execute("select pv.*, p.lang_"+this.lang+"_name as name, pvd.name as variant_name, p.brand_name, '"+attributesString+"' as attributes, '"+variantImage+"' as variant_image, '"+productUrl+"' as product_url from "+env.getProperty("CATALOG_DB")+".products p inner join "+env.getProperty("CATALOG_DB")+".product_variants pv on p.id=pv.product_id inner join "+env.getProperty("CATALOG_DB")+".product_variant_details pvd on pv.id = pvd.product_variant_id where pv.id="+escape.cote(rsMail.value("variant_id"))+" and pvd.langue_id="+escape.cote(this.lang));
            rsProduct.next();
            String sujet = parseNull(parseNull(rsProduct.value("brand_name"))+" "+parseNull(rsProduct.value("name")))+" "+dictionary.getTranslation(maillang,"est de retour en stock");
            //System.out.println("select pv.*, pvd.name from "+env.getProperty("CATALOG_DB")+".product_variants pv inner join "+env.getProperty("CATALOG_DB")+".product_variant_details pvd on pv.id = pvd.product_variant_id where pv.id="+escape.cote(rsMail.value("variant_id"))+" and pvd.langue_id="+escape.cote(this.lang));
            return (send(fmodele, rsProduct, sujet, attachs));
        } 
		catch (Exception e) 
		{
            e.printStackTrace();
            return (NO_CONNECTION);
        } 
		finally 
		{
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
            mailid = "20";
            wkid = 14183;
        } else if ("test".equals(a[0])) {
            if (a.length != 4) {
                System.exit(1);
            }
            mailid = a[1];
            tosend = a[2];
            orderType = a[3];
            wkid = 1;
        } else {
            mailid = a[0];
            wkid = Integer.parseInt(a[1]);
        }

        Properties p = new Properties();
        p.load(SendStockMail.class.getResourceAsStream("Scheduler.conf"));

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

        SendStockMail sm = new SendStockMail(etn, p);
//System.out.println("####### main send");
        int r = 0/*sm.send(wkid, mailid)*/;
        System.out.println("" + r);
        System.exit(r);

    }
}