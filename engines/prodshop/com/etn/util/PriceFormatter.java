package com.etn.util;

import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.beans.app.GlobalParm;
import java.util.Map;
import java.util.Properties;
import java.util.HashMap;

public class PriceFormatter
{
	private Map<String, Formatter> allFormatters;
	private ClientSql Etn;
	private Properties env;
	
	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
	
	public PriceFormatter( ClientSql Etn , Properties conf )
	{ 
		this.Etn = Etn; 
		this.env = conf;
		loadAll();
	}
	
	private void loadAll()
	{
		if(allFormatters == null) allFormatters = new HashMap<String, Formatter>();
		String catalogDb = env.getProperty("CATALOG_DB");
		Set rs = Etn.execute("select * from "+catalogDb+".language ");
		while(rs.next())
		{
			String prefix = "lang_" + rs.value("langue_id") + "_";
			String lang = rs.value("langue_code");

			Set rsSiteParams = Etn.execute("select site_id, "+prefix+"price_formatter as price_formatter, "+prefix+"round_to_decimals as round_to_decimals, "
										+prefix+"show_decimals as show_decimals from "+catalogDb+".shop_parameters ");
			while(rsSiteParams.next())
			{				
				if(allFormatters.get(rsSiteParams.value("site_id")+"|"+lang) == null)
				{
					allFormatters.put(rsSiteParams.value("site_id")+"|"+lang, new Formatter()); 
				}
				Formatter fmt = allFormatters.get(rsSiteParams.value("site_id")+"|"+lang);
				fmt.formatter = parseNull(rsSiteParams.value("price_formatter"));
				fmt.roundTo = parseNull(rsSiteParams.value("round_to_decimals"));
				fmt.showDecimals = parseNull(rsSiteParams.value("show_decimals"));
			}
		}
	}

	private String getShowDecimals(String siteid, String lang)
	{			
		if(allFormatters == null || allFormatters.isEmpty()) return "";
	
		//even after loading all from db its null then we return 
		if(allFormatters.get(parseNull(siteid)+"|"+parseNull(lang)) == null) return "";
		
		Formatter formatter = allFormatters.get(parseNull(siteid)+"|"+parseNull(lang));
		return formatter.showDecimals;
	}
	
	private String getRoundToDecimals(String siteid, String lang)
	{
		if(allFormatters == null || allFormatters.isEmpty()) return "";
	
		//even after loading all from db its null then we return 
		if(allFormatters.get(parseNull(siteid)+"|"+parseNull(lang)) == null) return "";
		
		Formatter formatter = allFormatters.get(parseNull(siteid)+"|"+parseNull(lang));
		return formatter.roundTo;
	}
	
	private String getPriceFormatter(String siteid, String lang)
	{
		if(allFormatters == null || allFormatters.isEmpty()) return "";
			
		//even after loading all from db its null then we return 
		if(allFormatters.get(parseNull(siteid)+"|"+parseNull(lang)) == null) return "";
		
		Formatter formatter = allFormatters.get(parseNull(siteid)+"|"+parseNull(lang));
		return formatter.formatter;
	}
	
	public String formatPrice(String siteid, String lang, String amnt)
	{
		if(allFormatters == null || allFormatters.get(parseNull(siteid)+"|"+parseNull(lang)) == null)
		{
			loadAll();
		}
		return formatPrice(getPriceFormatter(siteid, lang), getRoundToDecimals(siteid, lang), getShowDecimals(siteid, lang), amnt);
	}
		
	private String formatPrice(String formatter, String roundto, String decimals, String amnt)
	{
		if(formatter == null) formatter = "";
		formatter.trim();

		if(roundto == null) roundto = "";
		roundto.trim();

		if(decimals == null) decimals = "";
		decimals.trim();

		if(amnt == null) amnt = "";
		amnt.trim();

		if(amnt.length() == 0 || formatter.length() == 0) 
		{
			return amnt;
		}
		
		if(Double.parseDouble(amnt) == 0) return "0";

		String finalpattern = "###,###";
		java.text.DecimalFormat nf = null;
		if("french".equals(formatter)) nf =(java.text.DecimalFormat)java.text.NumberFormat.getInstance(java.util.Locale.FRANCE);
		else if("german".equals(formatter)) nf =(java.text.DecimalFormat)java.text.NumberFormat.getInstance(java.util.Locale.GERMAN);
		else if("us".equals(formatter)) nf =(java.text.DecimalFormat)java.text.NumberFormat.getInstance(java.util.Locale.US);
	
		if(roundto.length() > 0)
		{
			String pattern = "#";
			for(int i=0;i<Integer.parseInt(roundto);i++)
			{
				if(i==0) 
				{
					pattern +=".";
				}
				pattern += "0";
			}
			java.text.DecimalFormat df = (java.text.DecimalFormat)java.text.NumberFormat.getNumberInstance(java.util.Locale.US);
			df.applyPattern(pattern);
			amnt = df.format(Double.parseDouble(amnt));
		}
		if(decimals.length() > 0)
		{
			String pattern = "#";
			for(int i=0;i<Integer.parseInt(decimals);i++)
			{
				if(i==0) 
				{
					pattern +=".";
					finalpattern += ".";
				}
				pattern += "0";
				finalpattern += "0";
			}
			java.text.DecimalFormat df = (java.text.DecimalFormat)java.text.NumberFormat.getNumberInstance(java.util.Locale.US);
			df.applyPattern(pattern);
			amnt = df.format(Double.parseDouble(amnt));
		}

		nf.applyPattern(finalpattern);		
		amnt = nf.format(Double.parseDouble(amnt));
		return amnt;
	}
	
	private class Formatter
	{
		public String formatter;
		public String showDecimals;
		public String roundTo;		
	}
}
 