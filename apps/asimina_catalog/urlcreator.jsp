<%!
	String __parsenull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	String getActualUrl(com.etn.lang.ResultSet.Set rs, com.etn.lang.ResultSet.Set rscatalog, String urltype)
	{
		String url = "";
		String params = "";
		if(urltype.equals("cart"))
		{
			url = parseNull(rs.value("cart_url"));
			params = parseNull(rs.value("cart_url_params"));
			if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PROD_ENVIRONMENT"))) url = parseNull(rs.value("cart_prod_url")); 
		}
		else if(urltype.equals("store_locator"))
		{
			url = parseNull(rs.value("store_locator_url"));
			params = parseNull(rs.value("store_locator_url_params"));
			if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PROD_ENVIRONMENT"))) url = parseNull(rs.value("store_locator_prod_url")); 
		}

		if(url.length() == 0)//no url defined at item level
		{
			if(urltype.equals("cart"))
			{
				url = parseNull(rscatalog.value("cart_url"));
				params = parseNull(rscatalog.value("cart_url_params"));
				if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PROD_ENVIRONMENT"))) url = parseNull(rscatalog.value("cart_prod_url")); 
			}
			else if(urltype.equals("store_locator"))
			{
				url = parseNull(rscatalog.value("store_locator_url"));
				params = parseNull(rscatalog.value("store_locator_url_params"));
				if("1".equals(com.etn.beans.app.GlobalParm.getParm("IS_PROD_ENVIRONMENT"))) url = parseNull(rscatalog.value("store_locator_prod_url")); 
			}
		}

		url = getUrl(url, params, rs);
		if(url.length() == 0) url = "javascript:void(0)";
		return url;
	}

	String getUrl(String url, String params, com.etn.lang.ResultSet.Set rs)
	{
		if(url == null || url.trim().length() == 0) return "";

		if(params != null && params.length() > 0)
		{
			String[] ss = params.split(",");
			for(int i=0; i<ss.length; i++)
			{
				String _param = parseNull(ss[i].substring(11, ss[i].indexOf("</url_param>")));
				String _constval = parseNull(ss[i].substring(ss[i].indexOf("<const_val>") + 11, ss[i].indexOf("</const_val>")));
				String _colval = parseNull(ss[i].substring(ss[i].indexOf("<table_col>") + 11, ss[i].indexOf("</table_col>")));
				if(_constval.length() > 0)
				{
					if(url.contains("?")) url += "&";
					else url += "?";
					url += _param + "=" + _constval;
				}
				else if(_colval.length() > 0)
				{
					if(_colval.equalsIgnoreCase("universe") || _colval.equalsIgnoreCase("business_type"))//these 2 are multiselect fields so we send them as multiple params
					{
						String[] s3 = __parsenull(rs.value(_colval)).split(",");
						if(s3 != null)
						{	
							for(int j=0; j<s3.length; j++)
							{
								if(__parsenull(s3[j]).length() == 0) continue;
								if(url.contains("?")) url += "&";
								else url += "?";
								url += _param + "=" + __parsenull(s3[j]);							
							}
						}
						else 
						{
							if(url.contains("?")) url += "&";
							else url += "?";
							url += _param + "=";
						}
					}
					else if(_colval.equalsIgnoreCase("selected_item_duration"))//special case where a item is loaded for a particular universe then we just send that in url
					{
						if(url.contains("?")) url += "&";
						else url += "?";
						url += _param + "=" + __parsenull("<_selected_item_duration>");
					}
					else if(_colval.equalsIgnoreCase("selected_item_price"))//special case where a item is loaded for a particular universe then we just send that in url
					{
						if(url.contains("?")) url += "&";
						else url += "?";
						url += _param + "=" + __parsenull("<_selected_item_price>");
					}
					else 
					{	
						if(url.contains("?")) url += "&";
						else url += "?";
						url += _param + "=" + __parsenull(rs.value(_colval));
					}
				}
			}
		}

		return url;
	}
%>