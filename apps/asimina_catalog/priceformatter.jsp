<%!
	String formatPriceForCart(String formatter, String roundto, String decimals, String amnt)
	{
		return formatPrice(formatter, roundto, decimals, amnt);
	}

	String formatPrice(String formatter, String roundto, String decimals, String amnt)
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
%>