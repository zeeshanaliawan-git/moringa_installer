package com.etn.asimina.util;

import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.util.Logger;

import java.text.Normalizer;

/**
 * This class provides some helper functions to get the prefix for URLs where the content will be cached eventually
 * Any changes to this class means it must be copied in all webapps
 */
public class UrlHelper {
    public static boolean lastIsUnique = true;
    public static String lastType = "";
    public static String lastId = "";
    public static String lastMsg = "";

    private static String parseNull(Object o) {
        if (o == null) return ("");
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        }
        else {
            return (s.trim());
        }
    }

	final static int UC16Latin1ToAscii7[] = {
	'A','A','A','A','A','A','A','C',
	'E','E','E','E','I','I','I','I',
	'D','N','O','O','O','O','O','X',
	'0','U','U','U','U','Y','S','Y',
	'a','a','a','a','a','a','a','c',
	'e','e','e','e','i','i','i','i',
	'o','n','o','o','o','o','o','/',
	'0','u','u','u','u','y','s','y' };

	private static int toAscii7( int c )
	{ if( c < 0xc0 || c > 0xff )
		 return(c);
	  return( UC16Latin1ToAscii7[ c - 0xc0 ] );
	}

	public static String ascii7( String  s )
	{
	  char c[] = s.toCharArray();
	  for( int i = 0 ; i < c.length ; i++ )
	   if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)toAscii7( c[i] );
	  return( new String( c ) );
	}

	private static int compAscii7( String a , String b )
	{ if( a==null) return( b==null?0:1);
	  if( b == null ) return(-1);
	  return(  ascii7(a).compareTo( ascii7(b) ) );
	}

	public static boolean equals7( String a , String b )
	{ return( compAscii7( a ,b ) == 0 ); }

	public static String removeAccents(String src)
	{
		if(src == null) return "";
		src = src.trim();
		return ascii7(src);
	}

    public static String removeSpecialCharacters(String s) {
        if (s == null) return "";
        //on UI we replace space by -
        s = s.replace(" ", "-");
        //on UI we are only allowing - in file name/path so we do here
        //return s.replaceAll("[^A-Za-z0-9-]", "");
        return s.replaceAll("[^\\p{IsAlphabetic}\\p{Digit}-]", "");
    }

    public static boolean isUrlUnique(Contexte Etn, String siteid, int langueid, String type, String id, String url) {
        return isUrlUnique(Etn, siteid, langueid, type, id, url, null);
    }

    public static boolean isUrlUnique(Contexte Etn, String siteid, int langueid, String type, String id, String url, StringBuffer sb) {
        Set rs = Etn.execute("select * from " + GlobalParm.getParm("PREPROD_CATALOG_DB") + ".language where langue_id = " + escape.cote("" + langueid));
        rs.next();
        return isUrlUnique(Etn, siteid, rs.value("langue_code"), type, id, url, sb);
    }

    //this function will check the url in pages/forms/catalogs/products
    public static boolean isUrlUnique(Contexte Etn, String siteid, String languecode, String type, String id, String url) {
        return isUrlUnique(Etn, siteid, languecode, type, id, url, null);
    }

    public static boolean isUrlUnique(Contexte Etn, String siteid, String languecode, String type, String id, String url, StringBuffer sb) {
        final String commonsDb = GlobalParm.getParm("COMMONS_DB");

        UrlHelper.lastIsUnique = true;
        UrlHelper.lastType = UrlHelper.lastId = UrlHelper.lastMsg = "";

        //because in the view we append '.html' to all paths (except media files)
        String htmlUrl = url + ".html";

        String q = " SELECT content_type, content_id, name  "
                   + " FROM " + commonsDb + ".content_urls"
                   + " WHERE site_id = " + escape.cote(siteid)
                   + " AND langue_code = " + escape.cote(languecode)
                   + " AND page_path = " + escape.cote(htmlUrl);
        if (parseNull(type).length() > 0 && parseNull(id).length() > 0) {
            q += " AND CONCAT(content_type,'_',content_id) != " + escape.cote(type + "_" + id);
        }
        Set rs = Etn.execute(q);
        // Logger.debug("##Url Q: " + q);
        // Logger.debug("##Rows : " + rs.rs.Rows);
        if (rs.next()) {
            String contentType = rs.value("content_type");
            String contentId = rs.value("content_id");
            String contentName = rs.value("name");

            UrlHelper.lastIsUnique = false;
            UrlHelper.lastType = contentType;
            UrlHelper.lastId = contentId;
            UrlHelper.lastMsg = contentType + " : " + contentName + " (ID:" + contentId + ") has same url ";

            Logger.debug("UrlHelper", "URL clash with another " + contentType + " url");
            if (sb != null) sb.append(UrlHelper.lastMsg);
            return false;
        }

        return true;
    }

    public static String getProductSuggestedPath(Contexte Etn, String productid)
    {
        String catalogDb = GlobalParm.getParm("PREPROD_CATALOG_DB");

        Set rs = Etn.execute("select c.id as catalogid, c.name as catalogname, p.brand_name, p.lang_1_name, p.lang_2_name, p.lang_3_name, p.lang_4_name, p.lang_5_name from " + catalogDb + ".products p, " + catalogDb + ".catalogs c where c.id = p.catalog_id and p.id = " + escape.cote(productid));
        rs.next();
        String catalogid = parseNull(rs.value("catalogid"));

        String productname = "";
        if (parseNull(rs.value("lang_1_name")).length() > 0) {
            productname = parseNull(rs.value("lang_1_name"));
        }
        else if (parseNull(rs.value("lang_2_name")).length() > 0) {
            productname = parseNull(rs.value("lang_2_name"));
        }
        else if (parseNull(rs.value("lang_3_name")).length() > 0) {
            productname = parseNull(rs.value("lang_3_name"));
        }
        else if (parseNull(rs.value("lang_4_name")).length() > 0) {
            productname = parseNull(rs.value("lang_4_name"));
        }
        else if (parseNull(rs.value("lang_5_name")).length() > 0) {
            productname = parseNull(rs.value("lang_5_name"));
        }

        if (productname.length() == 0) productname = productid;

        String brandname = parseNull(rs.value("brand_name"));
        if (brandname.length() > 0) {
            brandname = brandname.replace(" ", "-");//on UI we replace space with - in brand name to create default path so do same here
            productname = brandname + "-" + productname;//on ui - is added between brandname and product name so do same here
        }

        String path = UrlHelper.removeSpecialCharacters(UrlHelper.removeAccents(productname.toLowerCase()));
        path = path.replace("--","-").replace("--","-").replace("--","-").replace("--","-");
        return path;
    }

    //Old obsolete code
    //this function will check the url in pages/forms/catalogs/products
    /*
    @Deprecated
	public static boolean isUrlUniqueOld(Contexte Etn, String siteid, String languecode, String type, String id, String url, StringBuffer sb)
	{
		String pagesDb = GlobalParm.getParm("PAGES_DB");
		String formsDb = GlobalParm.getParm("FORMS_DB");
		String catalogDb = GlobalParm.getParm("PREPROD_CATALOG_DB");

		UrlHelper.lastIsUnique = true;
		UrlHelper.lastType = UrlHelper.lastId = UrlHelper.lastMsg = "";

		Set rsL = Etn.execute("select * from "+catalogDb+".language where langue_code = " + escape.cote(languecode));
		rsL.next();
		String langueId = rsL.value("langue_id");

		//check non-structured pages
		String q = " select id, name from "+pagesDb+".pages " +
			" where type != 'structured' " +
			" and concat (case when variant = 'logged' then concat(variant,'/') else '' end, path) = " + escape.cote(url) +
			" and site_id = " + escape.cote(siteid) +
			" and langue_code = " + escape.cote(languecode);
		if("page".equalsIgnoreCase(type) && parseNull(id).length() > 0) q += " and id <> " + escape.cote(id);

		Logger.debug(q);
		Set rs = Etn.execute(q);
		if(rs.next())
		{
			UrlHelper.lastIsUnique = false;
			UrlHelper.lastType = "page";
			UrlHelper.lastId = rs.value("id");
			UrlHelper.lastMsg = "Page : " + rs.value("name") + " (ID:"+rs.value("id")+") has same url ";

			Logger.error("UrlHelper","URL clash with another page url");
			if(sb != null) sb.append(UrlHelper.lastMsg);
			return false;
		}

		//check structured pages
		q = " select sc.id, sc.name " +
			" from "+pagesDb+".pages p  " +
			" join "+pagesDb+".structured_contents_details scd ON scd.page_id = p.id " +
			" join "+pagesDb+".structured_contents sc ON sc.id = scd.content_id " +
			" join "+pagesDb+".structured_catalogs c ON c.id = sc.catalog_id " +
			" LEFT JOIN "+pagesDb+".structured_catalogs_details cd ON cd.catalog_id = c.id " +
			" where p.type = 'structured'  " +
			" and p.site_id = " + escape.cote(siteid) +
			" and p.langue_code = " + escape.cote(languecode) +
			" and cd.langue_id = " + escape.cote(langueId) +
			" and concat ( " +
			" 	case when p.variant = 'logged' then concat(p.variant,'/') else '' end, " +
			" 	case when LENGTH(IFNULL(cd.path_prefix,'')) > 0 then concat(cd.path_prefix,'/') else '' end, " +
			" 	p.path ) = " + escape.cote(url);
		if("page".equalsIgnoreCase(type) && parseNull(id).length() > 0) q += " and p.id <> " + escape.cote(id);
		Logger.debug(q);
		rs = Etn.execute(q);
		if(rs.next())
		{
			UrlHelper.lastIsUnique = false;
			UrlHelper.lastType = "page";
			UrlHelper.lastId = rs.value("id");
			UrlHelper.lastMsg = "Structured Page : " + rs.value("name") + " (ID:"+rs.value("id")+") has same url ";

			Logger.error("UrlHelper","URL clash with another structured page url");
			if(sb != null) sb.append(UrlHelper.lastMsg);
			return false;
		}

		q = "select p.id, p.lang_1_name from "+catalogDb+".catalogs c, "+catalogDb+".products p, "+catalogDb+".product_descriptions pd " +
			" where p.id = pd.product_id " +
			" and c.id = p.catalog_id " +
			" and c.site_id = " + escape.cote(siteid) +
			" and pd.page_path = " + escape.cote(url) +
			" and pd.langue_id = " + escape.cote(langueId);
		if("product".equalsIgnoreCase(type)  && parseNull(id).length() > 0) q += " and p.id <> " + escape.cote(id);

		Logger.debug(q);
		rs = Etn.execute(q);
		if(rs.next())
		{
			UrlHelper.lastIsUnique = false;
			UrlHelper.lastType = "product";
			UrlHelper.lastId = rs.value("id");
			UrlHelper.lastMsg = "Product : " + rs.value("lang_1_name") + " (ID:"+rs.value("id")+") has same url ";

			Logger.error("UrlHelper","URL clash with another product");
			if(sb != null) sb.append(UrlHelper.lastMsg);
			return false;
		}

		q = " select c.id, c.name " +
			" from "+catalogDb+".catalog_descriptions cd, "+catalogDb+".catalogs c " +
			" where cd.page_path = " + escape.cote(url) +
			" and cd.langue_id = " + escape.cote(langueId) +
			" and cd.catalog_id = c.id " +
			" and c.site_id = " + escape.cote(siteid);
		if("catalog".equalsIgnoreCase(type)  && parseNull(id).length() > 0) q += " and c.id <> " + escape.cote(id);

		Logger.debug(q);
		rs = Etn.execute(q);
		if(rs.next())
		{
			UrlHelper.lastIsUnique = false;
			UrlHelper.lastType = "catalog";
			UrlHelper.lastId = rs.value("id");
			UrlHelper.lastMsg = "Catalog : " + rs.value("name") + " (ID:"+rs.value("id")+") has same url ";

			Logger.error("UrlHelper","URL clash with another catalog");
			if(sb != null) sb.append(UrlHelper.lastMsg);
			return false;
		}

		q = " select c.form_id, c.process_name " +
			" from "+formsDb+".process_form_descriptions cd, "+formsDb+".process_forms c "+
			" where concat (case when c.variant = 'logged' then concat(c.variant,'/') else '' end, cd.page_path) = " + escape.cote(url) +
			" and cd.langue_id = " + escape.cote(langueId) +
			" and cd.form_id = c.form_id " +
			" and c.site_id = " + escape.cote(siteid);
		if("form".equalsIgnoreCase(type)  && parseNull(id).length() > 0) q += " and c.form_id <> " + escape.cote(id);

		Logger.debug(q);
		rs = Etn.execute(q);
		if(rs.next())
		{
			UrlHelper.lastIsUnique = false;
			UrlHelper.lastType = "form";
			UrlHelper.lastId = rs.value("form_id");
			UrlHelper.lastMsg = "Form : " + rs.value("process_name") + " (ID:"+rs.value("form_id")+") has same url ";

			Logger.error("UrlHelper","URL clash with another form");
			if(sb != null) sb.append(UrlHelper.lastMsg);
			return false;
		}

		return true;
	}
*/
}
