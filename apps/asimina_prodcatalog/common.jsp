<%!
final static int UC16Latin1ToAscii7[] = {
'A','A','A','A','A','A','A','C',
'E','E','E','E','I','I','I','I',
'D','N','O','O','O','O','O','X',
'0','U','U','U','U','Y','S','Y',
'a','a','a','a','a','a','a','c',
'e','e','e','e','i','i','i','i',
'o','n','o','o','o','o','o','/',
'0','u','u','u','u','y','s','y' };

int  toAscii7( int c )
{ if( c < 0xc0 || c > 0xff )
     return(c);
  return( UC16Latin1ToAscii7[ c - 0xc0 ] );
}

String ascii7( String  s )
{
  char c[] = s.toCharArray();
  for( int i = 0 ; i < c.length ; i++ )
   if( c[i] >= 0xc0 && c[i] < 256 ) c[i] = (char)toAscii7( c[i] );
  return( new String( c ) );
}

	String removeAccents(String a)
	{
		if(a == null) return "";
		a = a.trim();
		a = ascii7(a);
		return a;
	}

	String fixTabname(String a)
	{
		if(a == null) return "";
		a = ascii7(a.trim());
		a = a.replace("'","").replace("\"","").replace(" ","").replaceAll("[^a-zA-Z0-9]+","_");
		return a;
	}

	String getcurrencyfrequency(String defaultcurrency, String currency, String frequency)
	{
		String s = "";
		if(parseNull(currency).length() > 0) s = parseNull(currency);
		else if(parseNull(defaultcurrency).length() > 0) s = parseNull(defaultcurrency);

		if(parseNull(frequency).length() > 0)
		{
			if(s.length() > 0) s += "/";
			s += parseNull(frequency);
		}
		return s;
	}

	String getcurrencyfrequency(javax.servlet.http.HttpServletRequest request, String defaultcurrency, String defaultcurrencytranslated, String frequency, String frequencytranslated)
	{
		String s = "";
		if(parseNull(defaultcurrency).length() > 0) s = defaultcurrencytranslated;

		if(parseNull(frequency).length() > 0)
		{
			if(s.length() > 0) s += "/";
			s += frequencytranslated;
		}
		return s;
	}

	String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
        int parseNullInt(Object o)
        {
            if (o == null) return 0;
            String s = o.toString();
            if (s.equals("null")) return 0;
            if (s.equals("")) return 0;
            return Integer.parseInt(s);
        }
        double parseNullDouble(Object o)
        {
            if (o == null) return 0;
            String s = o.toString();
            if (s.equals("null")) return 0;
            if (s.equals("")) return 0;
            return Double.parseDouble(s);
        }

	String getEncodedActionButtonUrl(String _actBtnUrl)
	{
		if(_actBtnUrl == null || _actBtnUrl.trim().length() == 0 ) return "";
		try
		{
			_actBtnUrl = _actBtnUrl.trim();
			if(_actBtnUrl.toLowerCase().startsWith("http://") || _actBtnUrl.toLowerCase().startsWith("https://")) return _actBtnUrl;

			if(_actBtnUrl.indexOf(":") > -1)
			{
				String _p1 = _actBtnUrl.substring(0, _actBtnUrl.indexOf(":"));
				String _p2 = _actBtnUrl.substring(_actBtnUrl.indexOf(":"));
				_p2 = _p2.substring(1);
				_actBtnUrl = _p1  + ":" + java.net.URLEncoder.encode(_p2, "UTF-8");
			}
			return _actBtnUrl;
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return "";
		}
	}

	boolean isEcommerceEnabled(com.etn.beans.Contexte Etn, String siteid)
	{
		boolean isEnabled = false;
		com.etn.lang.ResultSet.Set rs = Etn.execute("select * from " + com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") +".sites where id = " +com.etn.sql.escape.cote(siteid) );
		if(rs.next())
		{
			isEnabled = "1".equals(rs.value("enable_ecommerce"));
		}
		return isEnabled;
	}

    /**
    * Addd by ABJ to convert queries to JSONArray
    */

    String toProperCase(String s){
         return s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
    }

    String toCamelCase(String name){
        String [] parts = name.split("_");

        String camelCase = null;

        for(String part : parts){
            if(camelCase == null){
                camelCase = part.toLowerCase();
            }else{
                camelCase = camelCase + toProperCase(part);
            }
        }
        return camelCase;
    }

    org.json.JSONObject toJSONObject(com.etn.lang.ResultSet.Set rs){
        String [] colNames = rs.ColName;
        org.json.JSONObject data = new org.json.JSONObject();
        for(String colName : colNames){
            data.put(toCamelCase(colName),rs.value(colName));
        }
        return data;
    }

    org.json.JSONArray toJSONArray(com.etn.beans.Contexte Etn,String query){
        org.json.JSONArray data = new org.json.JSONArray();

        com.etn.lang.ResultSet.Set rs = Etn.execute(query);
        if(rs != null){
            while(rs.next()){
                data.put(toJSONObject(rs));
            }
        }
        return data;
    }

    int getNumber(com.etn.beans.Contexte Etn,String query){
        int num = 0;
        com.etn.lang.ResultSet.Set rs = Etn.execute(query);
        if(rs != null && rs.next()){
            num = Integer.parseInt(rs.value(0));
        }
        return num;
    }

	String getImageUrlVersion(String file)
	{
		try
		{
			java.nio.file.Path path = java.nio.file.Paths.get(file);
			java.nio.file.attribute.BasicFileAttributes attr = java.nio.file.Files.readAttributes(path, java.nio.file.attribute.BasicFileAttributes.class);

			if(parseNull(attr.lastModifiedTime().toString()).length() > 0)
			{
				return "?ts="+ parseNull(attr.lastModifiedTime().toString()).replaceAll("[^0-9]", "");
			}
		}
		catch(Exception e) {}
		return "";
	}

	String getSiteId(javax.servlet.http.HttpSession session) {
        return parseNull(session.getAttribute("SELECTED_SITE_ID"));
    }

	String getSiteByCatalogId(com.etn.beans.Contexte Etn,String catalogId)
	{
		Set rs = Etn.execute("Select * FROM catalogs where id="+escape.cote(catalogId));
		rs.next();
		return parseNull(rs.value("site_id"));
	}

	String getSiteByProductId(com.etn.beans.Contexte Etn,String id)
	{
		Set rs = Etn.execute("select site_id from catalogs inner join products on products.catalog_id = catalogs.id WHERE products.id="+escape.cote(id));
		rs.next();
		return parseNull(rs.value("site_id"));
	}

	/*java.util.List<com.etn.asimina.beans.Language> getLangs(com.etn.beans.Contexte Etn, javax.servlet.http.HttpSession session)
    {
        return SiteHelper.getSiteLangs(Etn,getSelectedSiteId(session));
    }

    java.util.List<com.etn.asimina.beans.Language> getLangs(com.etn.beans.Contexte Etn, String siteId)
    {
        return SiteHelper.getSiteLangs(Etn,siteId);
    }

	String getSelectedSiteId(javax.servlet.http.HttpSession session) {
        return parseNull(session.getAttribute("SELECTED_SITE_ID"));
    }*/

%>