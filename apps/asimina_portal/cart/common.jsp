
<%!

	String getcurrencyfrequency(String defaultcurrency, String currency, String frequency)
	{
		return com.etn.asimina.util.PortalHelper.getcurrencyfrequency(defaultcurrency, currency, frequency);
	}

	String getcurrencyfrequency(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request, String defaultcurrency, String frequency)
	{
		return com.etn.asimina.util.PortalHelper.getcurrencyfrequency(Etn, defaultcurrency, frequency);
	}

	String parseNull(Object o)
	{
		return com.etn.asimina.util.PortalHelper.parseNull(o);
	}
        
	int parseNullInt(Object o)
	{
		return com.etn.asimina.util.PortalHelper.parseNullInt(o);
	}
        
	double parseNullDouble(Object o)
	{
		return com.etn.asimina.util.PortalHelper.parseNullDouble(o);
	}

    String toProperCase(String s)
	{
		return com.etn.asimina.util.PortalHelper.toProperCase(s);
    }

    String toCamelCase(String name)
	{
		return com.etn.asimina.util.PortalHelper.toCamelCase(name);
    }

    org.json.JSONObject toJSONObject(com.etn.lang.ResultSet.Set rs)
	{
		return com.etn.asimina.util.PortalHelper.toJSONObject(rs);
    }

    org.json.JSONArray toJSONArray(com.etn.beans.Contexte Etn,String query)
	{
		return com.etn.asimina.util.PortalHelper.toJSONArray(Etn, query);
    }

    int getNumber(com.etn.beans.Contexte Etn,String query)
	{
		return com.etn.asimina.util.PortalHelper.getNumber(Etn, query);
    }
%>
