<%@ page import="java.text.*, java.math.BigDecimal"%>
<%@ page import="org.json.*"%>
<%!
	String getPrice(com.etn.beans.Contexte Etn, String variant_id, com.etn.asimina.beans.TaxPercentage taxpercentage, int quantity, boolean applyPromo, HashSet<String> variantSet){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, "", variantSet, "");
	}

	String getPrice(com.etn.beans.Contexte Etn, String variant_id, com.etn.asimina.beans.TaxPercentage taxpercentage, int quantity, boolean applyPromo){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, "", null, "");
	}

	String getPrice(com.etn.beans.Contexte Etn, String variant_id, com.etn.asimina.beans.TaxPercentage taxpercentage, int quantity, boolean applyPromo, String client_id){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, client_id, null, "");
	}

	String getPrice(com.etn.beans.Contexte Etn, String variant_id, com.etn.asimina.beans.TaxPercentage taxpercentage, int quantity, boolean applyPromo, String client_id, String subsidy_id){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, client_id, null, subsidy_id);
	}

	String getPrice(com.etn.beans.Contexte Etn, String variant_id, com.etn.asimina.beans.TaxPercentage taxpercentage, int quantity, boolean applyPromo, String client_id, HashSet<String> variantSet, String subsidy_id)
	{
		return com.etn.asimina.cart.CommonPrice.getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, client_id, variantSet, subsidy_id);
	}

    boolean isNew(com.etn.lang.ResultSet.Set rs)
    {
		return com.etn.asimina.cart.CommonPrice.isNew(rs);
    }

	String getTaxString(LinkedHashSet<String> taxHS, HashMap<String, Integer> taxNumbers)
	{
		return com.etn.asimina.cart.CommonPrice.getTaxString(taxHS, taxNumbers);
	}

	String getTaxString2(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, LinkedHashSet<String> taxHS, HashMap<String, Integer> taxNumbers)
	{
		return com.etn.asimina.cart.CommonPrice.getTaxString2(Etn, taxHS, taxNumbers);
	}

    JSONArray getAdditionalFee(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String variantPrice, int quantity)
	{
		return com.etn.asimina.cart.CommonPrice.getAdditionalFee(Etn, request, variant_id, prefix, variantPrice, quantity);
    }

    boolean isValidDateRange(String startDateString, String endDateString) throws ParseException 
	{
		return com.etn.asimina.cart.CommonPrice.isValidDateRange(startDateString, endDateString);
    }

    JSONObject getPromotion(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix)
	{
		return com.etn.asimina.cart.CommonPrice.getPromotion(Etn, request, variant_id, prefix);
    }

    JSONArray getPromotions(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix)
	{
		return com.etn.asimina.cart.CommonPrice.getPromotions(Etn, request, variant_id, prefix);
    }

    JSONArray getComewith(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id){
        return getComewith(Etn, request, variant_id, prefix, langue_id, "");
    }

    JSONArray getComewith(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id, String comewith_excluded){
        return getComewith(Etn, request, variant_id, prefix, langue_id, comewith_excluded, false);
    }

    JSONArray getComewith(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id, String comewith_excluded, boolean isQuotation){
        return getComewith(Etn, request, variant_id, prefix, langue_id, comewith_excluded, isQuotation, "");
    }

    JSONArray getComewith(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id, String comewith_excluded, boolean isQuotation, String menu_id){
        return getComewith(Etn, request, variant_id, prefix, langue_id, comewith_excluded, isQuotation, menu_id, 1, "");
    }

    JSONArray getComewith(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id, String comewith_excluded, boolean isQuotation, String menu_id, int quantity, String selectedVariant)
	{
		return com.etn.asimina.cart.CommonPrice.getComewith(Etn, request, variant_id, prefix, langue_id, comewith_excluded, isQuotation, menu_id, quantity, selectedVariant);
    }

    JSONArray getSubsidiesOnVariant(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id)
	{
		return com.etn.asimina.cart.CommonPrice.getSubsidiesOnVariant(Etn, request, variant_id);
    }

    JSONArray getSubsidies(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id)
	{
		return com.etn.asimina.cart.CommonPrice.getSubsidies(Etn, request, variant_id, prefix, langue_id);
    }

    JSONArray getSelectedVariantSubsidies(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String appliedToType, String appliedToValue, String siteId, String prefix)
	{
		return com.etn.asimina.cart.CommonPrice.getSelectedVariantSubsidies(Etn, request, appliedToType, appliedToValue, siteId, prefix);
    }

%>