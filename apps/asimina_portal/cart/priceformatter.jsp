<%!
	String formatPriceForCart(String formatter, String roundto, String decimals, String amnt)
	{
		return formatPrice(formatter, roundto, decimals, amnt, false);
	}

        String formatPrice(String formatter, String roundto, String decimals, String amnt)
	{
            return formatPrice(formatter, roundto, decimals, amnt, false);
        }

	String formatPrice(String formatter, String roundto, String decimals, String amnt, boolean noformat)
	{
		return com.etn.asimina.util.PortalHelper.formatPrice(formatter, roundto, decimals, amnt, noformat);
	}
%>