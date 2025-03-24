package com.etn.moringa;

import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.Client.Impl.ClientSql;

import java.util.Properties;
import java.io.*;
import java.net.*;

import org.json.*;

public class Util
{
	private final static int UC16Latin1ToAscii7[] = {
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
		if( c < 0xc0 || c > 0xff ) return(c);
		return( UC16Latin1ToAscii7[ c - 0xc0 ] );
	}

	private static String ascii7( String  s )
	{
		char c[] = s.toCharArray();
		for( int i = 0 ; i < c.length ; i++ )
			if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)toAscii7( c[i] );
				return( new String( c ) );
	}
	
	public static String getSiteFolderName(String src)
	{
		return ((removeAccents(src)).replaceAll("[^\\p{IsAlphabetic}\\p{Digit}]", "-")).trim().toLowerCase();
	}
	
	public static String removeAccents(String src)
	{
		if(src == null) return "";
		src = src.trim();
		return ascii7(src);
	}
	
	public static void loadProperties(ClientSql Etn, Properties env)
	{
		//load config from db
		Set rs = Etn.execute("SELECT code,val FROM config");
		while (rs.next()) 
		{
			env.setProperty(rs.value("code"), rs.value("val"));
		}
		String commonsDb = env.getProperty("COMMONS_DB");
		if (commonsDb.trim().length() > 0) 
		{
			//load from commons db but don't override local config
			rs = Etn.execute("SELECT code,val FROM " + commonsDb + ".config");
			while (rs.next()) 
			{
				if (!env.containsKey(rs.value("code"))) 
				{
					env.setProperty(rs.value("code"), rs.value("val"));
				}
			}
		}  		
	}
	
	public static int insertUpdate(ClientSql etn, Set rs, String tablename, Properties env)
	{
		String proddb = env.getProperty("PROD_DB");		
		return insertUpdate(etn, rs, tablename, proddb);
	}
	
	public static int insertUpdate(ClientSql etn, Set rs, String tablename, String dbname)
	{		
		int rows = 0;
		while(rs.next())
		{
			String iq = " insert into "+dbname+"."+tablename+" ";
			String iqcols = "";
			String iqvals = "";
			String uq = " update ";
			String uqcols = "";
			for(int i=0;i< rs.Cols; i++)
			{
				if("site_menus".equals(tablename) && rs.ColName[i].equalsIgnoreCase("published_home_url")) continue;//we should not disturb production value for this
				if("site_menus".equals(tablename) && rs.ColName[i].equalsIgnoreCase("published_404_url")) continue;//we should not disturb production value for this
				if("site_menus".equals(tablename) && rs.ColName[i].equalsIgnoreCase("published_404_cached_id")) continue;//we should not disturb production value for this
				if("site_menus".equals(tablename) && rs.ColName[i].equalsIgnoreCase("published_hp_cached_id")) continue;//we should not disturb production value for this
				
				if("site_menus".equals(tablename) && rs.ColName[i].equalsIgnoreCase("menu_uuid"))
				{
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
					}
					iqcols += rs.ColName[i].toLowerCase();
					iqvals += " UUID() ";	
				}
				else if("sites".equals(tablename) && rs.ColName[i].equalsIgnoreCase("enable_cache"))//by default when a menu is published first time we are going to set cache enabled as users always miss that
				{
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
						uqcols += ", ";
					}
					iqcols += rs.ColName[i].toLowerCase();
					iqvals += " 1 ";
					uqcols += rs.ColName[i].toLowerCase() + " = 1 ";//in production we keep global cache always on
				}
				else if(rs.ColName[i].equalsIgnoreCase("created_on"))
				{
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
					}
					iqcols += rs.ColName[i].toLowerCase();
					iqvals += " now() ";	
				}
				else if(!rs.ColName[i].equalsIgnoreCase("updated_on")) 
				{
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";	
						uqcols += ", ";
					}
					iqcols += "`" + rs.ColName[i].toLowerCase()+ "`";
					iqvals += escape.cote(rs.value(i));	
					uqcols += "`" + rs.ColName[i].toLowerCase()+ "`" + " = " + escape.cote(rs.value(i));			
				}
				else 
				{
					if(i > 0)
					{
						uqcols += ", ";
					}
					uqcols += rs.ColName[i].toLowerCase() + " = now() ";
				}
			} 
			iq += " ( " + iqcols + " ) values ("+iqvals+") ";
			uq += uqcols ;
			//System.out.println(iq + " on duplicate key " + uq);
			int _r = etn.executeCmd(iq + " on duplicate key " + uq);

			if(_r > 0) rows++;
		}
		return rows;
	}

	public static int publishShopParameters(ClientSql etn, String siteid, Properties env)
	{
		try
		{
			System.out.println("Publish Shop parameters ");

			String catalogdb = env.getProperty("CATALOG_DB");
			String prodcatalogdb = env.getProperty("PROD_CATALOG_DB");

			Set rs = etn.execute("select * from "+catalogdb+".shop_parameters where site_id = " + escape.cote(siteid));

			int rows = 0;
			if(rs.rs.Rows > 0)
			{
				etn.executeCmd("delete from "+prodcatalogdb+".shop_parameters where site_id = " + escape.cote(siteid));				
				rows += insertUpdate(etn, rs, "shop_parameters", prodcatalogdb);
			}

			Set rspm = etn.execute("select * from "+catalogdb+".payment_methods where site_id = " + escape.cote(siteid));
			etn.executeCmd("delete from "+prodcatalogdb+".payment_methods where site_id = " + escape.cote(siteid));
			rows += insertUpdate(etn, rspm, "payment_methods", prodcatalogdb);

			Set rsdm = etn.execute("select * from "+catalogdb+".delivery_methods where site_id = " + escape.cote(siteid));
			etn.executeCmd("delete from "+prodcatalogdb+".delivery_methods where site_id = " + escape.cote(siteid));
			rows += insertUpdate(etn, rsdm, "delivery_methods", prodcatalogdb);

			Set rsfr = etn.execute("select * from "+catalogdb+".fraud_rules where site_id = " + escape.cote(siteid));
			etn.executeCmd("delete from "+prodcatalogdb+".fraud_rules where site_id = " + escape.cote(siteid));
			rows += insertUpdate(etn, rsfr, "fraud_rules", prodcatalogdb);			
			return rows;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}	

	public static int publishStickers(ClientSql etn, String siteid, Properties env)
	{
		try
		{
			System.out.println("Publish Stickers ");

			String catalogdb = env.getProperty("CATALOG_DB");
			String prodcatalogdb = env.getProperty("PROD_CATALOG_DB");

			Set rs = etn.execute("select * from "+catalogdb+".stickers where site_id = " + escape.cote(siteid));

			int rows = 0;
			if(rs.rs.Rows > 0)
			{
				etn.executeCmd("delete from "+prodcatalogdb+".stickers where site_id = " + escape.cote(siteid));				
				rows += Util.insertUpdate(etn, rs, "stickers", prodcatalogdb);
			}

			return rows;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}	
	
	public static int publishAlgoliaSettings(ClientSql etn, String siteid, String langId, Properties env)
	{
		try
		{
			System.out.println("Publish Aloglia settings ");

			String catalogdb = env.getProperty("CATALOG_DB");
			String prodcatalogdb = env.getProperty("PROD_CATALOG_DB");

			etn.executeCmd("delete from "+prodcatalogdb+".algolia_default_index where langue_id = "+escape.cote(langId)+" and site_id = "+escape.cote(siteid));
			etn.executeCmd("delete from "+prodcatalogdb+".algolia_indexes where langue_id = "+escape.cote(langId)+" and site_id = "+escape.cote(siteid));
			etn.executeCmd("delete from "+prodcatalogdb+".algolia_rules where langue_id = "+escape.cote(langId)+" and site_id = "+escape.cote(siteid));
			etn.executeCmd("delete from "+prodcatalogdb+".algolia_settings where site_id = "+escape.cote(siteid));

			int rows = 0;
			Set rs = etn.execute("select * from "+catalogdb+".algolia_default_index where langue_id = "+escape.cote(langId)+" and site_id = " + escape.cote(siteid));
			rows += Util.insertUpdate(etn, rs, "algolia_default_index", prodcatalogdb);

			rs = etn.execute("select * from "+catalogdb+".algolia_indexes where langue_id = "+escape.cote(langId)+" and site_id = " + escape.cote(siteid));
			rows += Util.insertUpdate(etn, rs, "algolia_indexes", prodcatalogdb);

			rs = etn.execute("select * from "+catalogdb+".algolia_rules where langue_id = "+escape.cote(langId)+" and site_id = " + escape.cote(siteid));
			rows += Util.insertUpdate(etn, rs, "algolia_rules", prodcatalogdb);

			rs = etn.execute("select * from "+catalogdb+".algolia_settings where site_id = " + escape.cote(siteid));
			rows += Util.insertUpdate(etn, rs, "algolia_settings", prodcatalogdb);

			return rows;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}		
	
	public static JSONObject callApi(String u, String method, String params) throws Exception
	{
		System.out.println("Util.java::callApi url : " + u + " method : " + method);
		
		HttpURLConnection con = null;
		JSONObject resp = null;
		BufferedReader reader = null;
		try
		{				
			URL url = new URL(u);
			
			con = (HttpURLConnection)url.openConnection();					
			con.setRequestMethod(method);

			if("post".equalsIgnoreCase(method))
			{				
				con.setDoInput(true);
				con.setDoOutput(true);
				con.setUseCaches(false);

				OutputStream o = con.getOutputStream();

				o.write(params.toString().getBytes("UTF-8"));
				o.close();								
			}
						
			resp = new JSONObject();			
			int responseCode = con.getResponseCode();
			resp.put("http_code", responseCode);
			
			String responseCharset = Util.getCharset(con.getContentType());
	
			if(responseCode >= 200 && responseCode <= 299) 
			{
                resp.put("status", 0);
				reader = new BufferedReader(new InputStreamReader(con.getInputStream(), responseCharset));			
            }			
			else 
			{
                resp.put("status", responseCode);
				reader = new BufferedReader(new InputStreamReader(con.getErrorStream(), responseCharset));
			}

			StringBuffer sb = new StringBuffer();	
			String inputLine;
			while ((inputLine = reader.readLine()) != null) {
				sb.append(inputLine);
			}
			resp.put("json", new JSONObject(sb.toString()));
		}
		finally
		{
			if(reader != null) reader.close();
			if(con != null) con.disconnect();
		}		
		System.out.println(resp.toString());
		return resp;
	}

	public static String getCharset(String contentType)
	{
		String charset = "UTF-8";//default value
		if(contentType == null) contentType = "";
		if(contentType.indexOf("charset=") > -1)
		{
			charset = contentType.substring(contentType.indexOf("charset=") + 8);
			if(charset.indexOf(";") > -1) charset = charset.substring(0, charset.indexOf(";"));
		}
		return charset;		
	}


    public static String parseNull(Object o) {
        if (o == null) {
            return ("");
        }
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        }
        else {
            return (s.trim());
        }
    }

	public static int parseNullInt(Object o)
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

	public static double parseNullDouble(Object o)
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

	public static long parseNullLong(Object o)
	{
		String s = parseNull(o);
		if(s.length() > 0 ){
			try{
				return Long.parseLong(s);
			}
			catch(Exception e){
				return 0;
			}
		}
		else{
			return 0;
		}
	}

}