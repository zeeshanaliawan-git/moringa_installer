package com.etn.eshop;

import java.util.Properties;
import java.util.Map;
import java.util.HashMap;
import java.util.LinkedHashMap;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;
import org.json.*;


public class Util
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

	private static int toAscii7( int c )
	{ if( c < 0xc0 || c > 0xff )
		 return(c);
	  return( UC16Latin1ToAscii7[ c - 0xc0 ] );
	}

	public static String removeAccents( String  s )
	{
	  char c[] = s.toCharArray();
	  for( int i = 0 ; i < c.length ; i++ )
	   if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)toAscii7( c[i] );
	  return( new String( c ) );
	}

	public static String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
 
	public static int parseNullInt(Object o)
	{
		if (o == null) return 0;
		String s = o.toString();
		if (s.equals("null")) return 0;
		if (s.equals("")) return 0;
		return Integer.parseInt(s);
	}
	
	public static long parseNullLong(Object o)
	{
		if (o == null) return 0;
		String s = o.toString();
		if (s.equals("null")) return 0;
		if (s.equals("")) return 0;
		return Long.parseLong(s);
	}
	
	public static double parseNullDouble(Object o)
	{
		if (o == null) return 0;
		String s = o.toString();
		if (s.equals("null")) return 0;
		if (s.equals("")) return 0;
		return Double.parseDouble(s);
	}
	
	public static Resource getResource(com.etn.Client.Impl.ClientSql etn, Properties env, String resourcename)
	{
		return getResource(etn, env, resourcename, "primary");//default we get primary always
	}

	public static String getTargetTable(Properties env)
	{
		if("1".equals(parseNull(env.getProperty("POST_WORK_SPLIT_ITEMS")))) return "order_items";
		return "orders";
	}
		
	public static Resource getResource(com.etn.Client.Impl.ClientSql etn, Properties env, String resourcename, String resourcetype)
	{
		Resource r = null;
		Set rs = etn.execute("select * from "+env.getProperty("CATALOG_DB")+".resources where name = "+escape.cote(resourcename)+" and rtype = " + escape.cote(resourcetype));
		if(rs.next())
		{
			r = new Resource();
			r.setName(parseNull(rs.value("name")));
			r.setEmail(parseNull(rs.value("email")));
			r.setPhone(parseNull(rs.value("phone_no")));
			r.setType(parseNull(rs.value("rtype")));
		}
		return r;
	}

	public static Map<String, Resource> getResources(com.etn.Client.Impl.ClientSql etn, Properties env, String productref)
	{
		//default we return primary resources only
		return getResources(etn, env, productref, "primary");
	}

	public static Map<String, Resource> getResources(com.etn.Client.Impl.ClientSql etn, Properties env, String productref, String resourcetype)
	{
		String qry = "";
		if("secondary".equalsIgnoreCase(resourcetype))
		{
			qry = "select service_resources as resources from "+env.getProperty("CATALOG_DB")+".products where product_uuid = " + escape.cote(productref);
		}
		else
		{
			qry = "select case when coalesce(p.link_id,'') <> '' then pl.resources else ps.resources end as resources "+
					" from "+env.getProperty("CATALOG_DB")+".products p left outer join "+env.getProperty("CATALOG_DB")+".product_stocks ps on ps.product_id = p.id "+
					" left outer join "+env.getProperty("CATALOG_DB")+".product_link pl on pl.id = p.link_id "+
					" where p.product_uuid = " + escape.cote(productref);
		}
//		System.out.println("Resources qry ");
//		System.out.println(qry);
		Set rsp = etn.execute(qry);

		rsp.next();
		String rss = parseNull(rsp.value("resources"));

		rss = rss.replace(",","','");

		Map<String, Resource> resources = new LinkedHashMap<String, Resource>();
		Set rsres = etn.execute("select * from "+env.getProperty("CATALOG_DB")+".resources where name in ('"+rss+"') and rtype = " + escape.cote(resourcetype));
		while(rsres.next())
		{
			Resource rsc = new Resource();
			rsc.setName(parseNull(rsres.value("name")));
			rsc.setEmail(parseNull(rsres.value("email")));
			rsc.setPhone(parseNull(rsres.value("phone_no")));
			rsc.setType(parseNull(rsres.value("rtype")));
			resources.put(rsc.getName(), rsc);
		}
		return resources;	
	}
	
	public static Map<String, String> getOrderAdditionalInfoCols(String additionalInfo)
	{
		if(parseNull(additionalInfo).length() == 0) return null;
		Map<String, String> aCols = null;
		try
		{
			JSONObject jAdditionalInfo = new JSONObject(additionalInfo);
			if(jAdditionalInfo.has("sections"))
			{
				aCols = new HashMap<>();
				for(int ss=0;ss<jAdditionalInfo.getJSONArray("sections").length();ss++)
				{
					JSONObject jSection = jAdditionalInfo.getJSONArray("sections").getJSONObject(ss);
					String colPrefix = "";
					String sectionname = parseNull(jSection.getString("name"));
					if(sectionname.length() > 0)
					{
						colPrefix = removeAccents(sectionname.toLowerCase()).replace("-","_").replace(" ","_") + "_";
					}
					if(jSection.has("fields"))
					{
						for(int f=0;f<jSection.getJSONArray("fields").length();f++)
						{
							JSONObject jField = jSection.getJSONArray("fields").getJSONObject(f);
							
							//we will only add text fields to the email template
							if(parseNull(jField.getString("type")).equals("text") == false) continue;
							
							String fieldname = removeAccents(jField.getString("name")).replace("-","_").replace(" ","_");
							String fieldval = "";
							if(jField.has("value") && jField.getJSONArray("value").length() > 0)
							{
								for(int vt=0;vt<jField.getJSONArray("value").length();vt++)
								{
									if(vt > 0) fieldval += ", ";
									fieldval += parseNull(jField.getJSONArray("value").getString(vt));
								}
							}
							
							aCols.put(colPrefix + fieldname, fieldval);
						}
					}
				}
			}
		} 
		catch(Exception ex) { ex.printStackTrace(); }
		return aCols;
	}

	public static String getCharset(String contentType)
	{
		String charset = "UTF-8";//default value
		if(contentType.indexOf("charset=") > -1)
		{
			charset = contentType.substring(contentType.indexOf("charset=") + 8);
			if(charset.indexOf(";") > -1) charset = charset.substring(0, charset.indexOf(";"));
		}
		return charset;		
	}

    public static String encodeJSONStringDB(String str){
        return str.replaceAll("\\\\", "#slash#");
    }

    public static String decodeJSONStringDB(String str){
        return str.replaceAll("#slash#","\\\\");
    }

    /***
    * updated escape cote to preserve slashes (\)
    * which are removed by escape.cote() function
    */
    public static String escapeCoteJson(String str){
        if(str == null || str.trim().length() == 0){
            return escape.cote(str);
        }

        String retStr = escape.cote(encodeJSONStringDB(str));
        retStr = retStr.replaceAll("#slash#","#slash##slash#");
        retStr = decodeJSONStringDB(retStr);

        return retStr;
    }
	
	public static String getSiteConfig(com.etn.Client.Impl.ClientSql Etn, Properties env, String siteid, String code)
	{
		Set rs = Etn.execute("select * from "+env.getProperty("PORTAL_DB")+".sites_config where site_id = "+escape.cote(siteid)+" and code = "+escape.cote(code));
		if(rs.next())
		{
			return parseNull(rs.value("val"));
		}
		return "";
	}
}

