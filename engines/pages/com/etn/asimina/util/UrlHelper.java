package com.etn.asimina.util;

import com.etn.beans.Etn;
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
	{ 
		if( c < 0xc0 || c > 0xff )
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
	{ 
		if( a==null) return( b==null?0:1);
		if( b == null ) return(-1);
		return(  ascii7(a).compareTo( ascii7(b) ) );
	}

	public static boolean equals7( String a , String b )
	{ 
		return( compAscii7( a ,b ) == 0 ); 
	}

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

    public static boolean isUrlUnique(Etn Etn, String siteid, int langueid, String type, String id, String url) {
        return isUrlUnique(Etn, siteid, langueid, type, id, url, null);
    }

    public static boolean isUrlUnique(Etn Etn, String siteid, int langueid, String type, String id, String url, StringBuffer sb) {
        Set rs = Etn.execute("select * from " + GlobalParm.getParm("PREPROD_CATALOG_DB") + ".language where langue_id = " + escape.cote("" + langueid));
        rs.next();
        return isUrlUnique(Etn, siteid, rs.value("langue_code"), type, id, url, sb);
    }

    //this function will check the url in pages/forms/catalogs/products
    public static boolean isUrlUnique(Etn Etn, String siteid, String languecode, String type, String id, String url) {
        return isUrlUnique(Etn, siteid, languecode, type, id, url, null);
    }

    public static boolean isUrlUnique(Etn Etn, String siteid, String languecode, String type, String id, String url, StringBuffer sb) {
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

    public static String getProductSuggestedPath(Etn Etn, String productid)
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

}
