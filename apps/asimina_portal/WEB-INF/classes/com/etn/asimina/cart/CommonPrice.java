package com.etn.asimina.cart;

import java.util.*;
import java.text.*;
import java.math.BigDecimal;

import org.json.*;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import com.etn.asimina.util.*;
import com.etn.beans.app.GlobalParm;
import com.etn.asimina.beans.*;
import com.etn.asimina.session.*;
import com.etn.util.Logger;


public class CommonPrice
{	
	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo, HashSet<String> variantSet){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, "", variantSet, "", false, null);
	}

	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, "", null, "", false, null);
	}

	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo, String client_id){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, client_id, null, "", false, null);
	}

	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo, String client_id, String subsidy_id){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, client_id, null, subsidy_id, false, null);
	}

	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo, String client_id, HashSet<String> variantSet, String subsidy_id)
	{
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, client_id, variantSet, subsidy_id, false, null);
	}
	
	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo, HashSet<String> variantSet, boolean overwritePrice, String vPrice){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, "", variantSet, "", overwritePrice, vPrice);
	}

	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo, boolean overwritePrice, String vPrice){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, "", null, "", overwritePrice, vPrice);
	}

	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo, String client_id, boolean overwritePrice, String vPrice){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, client_id, null, "", overwritePrice, vPrice);
	}

	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo, String client_id, String subsidy_id, boolean overwritePrice, String vPrice){
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, client_id, null, subsidy_id, overwritePrice, vPrice);
	}

	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo, String client_id, HashSet<String> variantSet, String subsidy_id, boolean overwritePrice, String vPrice)
	{
		return getPrice(Etn, variant_id, taxpercentage, quantity, applyPromo, client_id, variantSet, subsidy_id, overwritePrice, vPrice, null);
	}
	
	public static String getPrice(com.etn.beans.Contexte Etn, String variant_id, TaxPercentage taxpercentage, int quantity, boolean applyPromo, String client_id, HashSet<String> variantSet, String subsidy_id, boolean overwritePrice, String vPrice, String comewith_id)
	{
		boolean logged = false;

		String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
		Set rsVariantPrice = null;
		if(PortalHelper.parseNull(client_id).length() > 0)
		{
			rsVariantPrice = Etn.execute("select price from client_prices where product_variant_id="+escape.cote(variant_id)+" and client_id="+escape.cote(client_id)); // client price
			logged = true;
		}
		String price = "";

		Set rsVariantSubsidies;
		String subsidiesQueryUnion = "";

		if(rsVariantPrice != null && rsVariantPrice.next())
		{
			applyPromo = false;
			price = rsVariantPrice.value("price");
		}
		else
		{
			rsVariantPrice = Etn.execute("select price from "+catalogdb+".product_variants where id="+escape.cote(variant_id));

			rsVariantPrice.next();
			price = rsVariantPrice.value("price");
		}
		
		//this is only allowed for topup cart type
		if(overwritePrice)
		{
			price = PortalHelper.parseNull(vPrice);
		}
		
		double comewithPriceDiff = 0;
		if(PortalHelper.parseNull(comewith_id).length() > 0)
		{
			Set rsCm = Etn.execute("select * from "+catalogdb+".comewiths where id = "+escape.cote(comewith_id));
			if(rsCm.next())
			{
				comewithPriceDiff = PortalHelper.parseNullDouble(rsCm.value("price_difference"));
			}
		}
		
		Set rsVariant = Etn.execute("select pv.*, p.catalog_id, c.catalog_type, p.brand_name, c.site_id, pt.tag_id from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id=pv.product_id inner join "+catalogdb+".catalogs c on p.catalog_id = c.id LEFT JOIN " + catalogdb + ".product_tags pt ON pt.product_id = p.id where pv.id="+escape.cote(variant_id));
		rsVariant.next();
		if(price.length() == 0) return "";
		else
		{
			double price_before_tax = PortalHelper.parseNullDouble(price); // can include tax at this point depending on the flag.
			
			//price difference of comewith will be applied on whatever price is being entered by webmaster
			//this price can be inclusive of tax or exclusive of tax
			Logger.debug("CommonPrice", "variant id : " + variant_id + " price_before_tax : " + price_before_tax);
			price_before_tax = price_before_tax - comewithPriceDiff;
			Logger.debug("CommonPrice", "variant id : " + variant_id + " price_before_tax : " + price_before_tax + " comewithPriceDiff: " +comewithPriceDiff);
			
			if(taxpercentage.input_with_tax != taxpercentage.output_with_tax)
			{
				if(taxpercentage.input_with_tax)
				{
					price_before_tax = price_before_tax / (1 + (taxpercentage.tax/100)); // formula to remove tax
				}
				else
				{
					price_before_tax = (price_before_tax + (price_before_tax*taxpercentage.tax/100)); // now the price is in the format that is shown on front, and it is decided to apply discount on the price shown on front
				}
			}
			
			if(price_before_tax < 0) price_before_tax = 0;

			if(applyPromo)
			{
				String promotionQuery = "select p.* from "+catalogdb+".promotions p inner join "+catalogdb+".promotions_rules pr on p.id=pr.promotion_id where"
										+ " p.site_id = "+escape.cote(rsVariant.value("site_id"))+" and ((pr.applied_to_type='product' and pr.applied_to_value="+escape.cote(rsVariant.value("product_id"))+")"
										+ " or (pr.applied_to_type='catalog' and pr.applied_to_value="+escape.cote(rsVariant.value("catalog_id"))+")"
										+ " or (pr.applied_to_type='sku' and pr.applied_to_value="+escape.cote(rsVariant.value("sku"))+")"
										+ " or (pr.applied_to_type='product_type' and pr.applied_to_value="+escape.cote(rsVariant.value("catalog_type"))+")"
										+ " or (pr.applied_to_type='manufacturer' and pr.applied_to_value="+escape.cote(rsVariant.value("brand_name"))+")"
										+ " or (pr.applied_to_type='tag' and pr.applied_to_value=" + escape.cote(rsVariant.value("tag_id")) + "))"
										+ " group by pr.promotion_id order by p.order_seq";

				Set rsPromotion = Etn.execute(promotionQuery);
				while(rsPromotion.next())
				{
					if(rsPromotion.value("visible_to").equals("logged") && !logged ) continue;
					String startDateString = rsPromotion.value("start_date");
					String endDateString = rsPromotion.value("end_date");
					try {
						//System.out.println(startDate +" " +endDate+" "+currentDate);
						//String newDateString = df.format(startDate);

						if(!isValidDateRange(startDateString, endDateString)) continue;
						else if(startDateString.length()>0){ // because frequency is only applicable when start date is set
							Calendar today = Calendar.getInstance();
							DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
							Date startDate = formatter.parse(startDateString);
							Calendar start = Calendar.getInstance();
							start.setTime(startDate);
							if(rsPromotion.value("frequency").equals("weekly")){
								if(start.get(Calendar.DAY_OF_WEEK)!=today.get(Calendar.DAY_OF_WEEK)) continue;
							}
							else if(rsPromotion.value("frequency").equals("monthly")){
								if(start.get(Calendar.DAY_OF_MONTH)!=today.get(Calendar.DAY_OF_MONTH)) continue;
							}
						}
						if(rsPromotion.value("discount_type").equals("fixed")) price_before_tax -= PortalHelper.parseNullDouble(rsPromotion.value("discount_value"));
						else price_before_tax -= (price_before_tax*PortalHelper.parseNullDouble(rsPromotion.value("discount_value"))/100);

						break;
					} catch (ParseException e) {
						e.printStackTrace();
						return price;
					}
				}

				if(null != variantSet)
				{
					String productId = "";
					String catalogId = "";
					String sku = "";
					String productType = "";
					String manufacturer = "";

					for(String variantId : variantSet)
					{
						rsVariantSubsidies = Etn.execute("select pv.*, p.catalog_id, c.catalog_type, p.brand_name, c.site_id from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id=pv.product_id inner join "+catalogdb+".catalogs c on p.catalog_id = c.id where pv.id="+escape.cote(variantId));

						if(rsVariantSubsidies.next())
						{
							if(productId.length()!=0)
							{
								productId += ", ";
								catalogId += ", ";
								sku += ", ";
								productType += ", ";
								manufacturer += ", ";
							}
							productId += escape.cote(PortalHelper.parseNull(rsVariantSubsidies.value("product_id")));
							catalogId += escape.cote(PortalHelper.parseNull(rsVariantSubsidies.value("catalog_id")));
							sku += escape.cote(PortalHelper.parseNull(rsVariantSubsidies.value("sku")));
							productType += escape.cote(PortalHelper.parseNull(rsVariantSubsidies.value("catalog_type")));
							manufacturer += escape.cote(PortalHelper.parseNull(rsVariantSubsidies.value("brand_name")));
						}
					}

					if(productId.length() > 0)
						subsidiesQueryUnion += " (sr.associated_to_type='product' and sr.associated_to_value in (" + productId + "))";

					if(catalogId.length() > 0)
						subsidiesQueryUnion += " or (sr.associated_to_type='catalog' and sr.associated_to_value in (" + catalogId + "))";

					if(sku.length() > 0)
						subsidiesQueryUnion += " or (sr.associated_to_type='sku' and sr.associated_to_value in (" + sku + "))";

					if(productType.length() > 0)
						subsidiesQueryUnion += " or (sr.associated_to_type='product_type' and sr.associated_to_value in (" + productType + "))";

					if(manufacturer.length() > 0)
						subsidiesQueryUnion += " or (sr.associated_to_type='manufacturer' and sr.associated_to_value in (" + manufacturer + "))";

					if(subsidiesQueryUnion.length() > 0)
						subsidiesQueryUnion = " and (" + subsidiesQueryUnion + ") group by subsidy_id order by s.order_seq";

					if(subsidiesQueryUnion.length() > 0)
					{
						promotionQuery = "select s.* from "+catalogdb+".subsidies s inner join "+catalogdb+".subsidies_rules sr on s.id=sr.subsidy_id where s.site_id = "+escape.cote(rsVariant.value("site_id")) + " and ((s.applied_to_type='product' and s.applied_to_value="+escape.cote(rsVariant.value("product_id"))+")"
										+ " or (s.applied_to_type='catalog' and s.applied_to_value="+escape.cote(rsVariant.value("catalog_id"))+")"
										+ " or (s.applied_to_type='sku' and s.applied_to_value="+escape.cote(rsVariant.value("sku"))+")"
										+ " or (s.applied_to_type='product_type' and s.applied_to_value="+escape.cote(rsVariant.value("catalog_type"))+")"
										+ " or (s.applied_to_type='manufacturer' and s.applied_to_value="+escape.cote(rsVariant.value("brand_name"))+")"
										+ " or (s.applied_to_type='tag' and s.applied_to_value=" + escape.cote(rsVariant.value("tag_id")) + "))" + subsidiesQueryUnion;

						rsPromotion = Etn.execute(promotionQuery);
						while(rsPromotion.next())
						{
							if(rsPromotion.value("visible_to").equals("logged") && !logged ) continue;
							String startDateString = rsPromotion.value("start_date");
							String endDateString = rsPromotion.value("end_date");
							try {
								//System.out.println(startDate +" " +endDate+" "+currentDate);
								//String newDateString = df.format(startDate);

								if(!isValidDateRange(startDateString, endDateString)) continue;

								if(rsPromotion.value("discount_type").equals("fixed")) price_before_tax -= PortalHelper.parseNullDouble(rsPromotion.value("discount_value"));
								else price_before_tax -= (price_before_tax*PortalHelper.parseNullDouble(rsPromotion.value("discount_value"))/100);

								break;
							} catch (ParseException e) {
								e.printStackTrace();
								return price;
							}
						}
					}
				}
				else if(subsidy_id.length()>0)
				{
					promotionQuery = "select * from "+catalogdb+".subsidies where id = "+escape.cote(subsidy_id);

					rsPromotion = Etn.execute(promotionQuery);
					while(rsPromotion.next())
					{
						if(rsPromotion.value("visible_to").equals("logged") && !logged ) continue;
						String startDateString = rsPromotion.value("start_date");
						String endDateString = rsPromotion.value("end_date");
						try {
							//System.out.println(startDate +" " +endDate+" "+currentDate);
							//String newDateString = df.format(startDate);
							if(!isValidDateRange(startDateString, endDateString)) continue;

							if(rsPromotion.value("discount_type").equals("fixed")) price_before_tax -= PortalHelper.parseNullDouble(rsPromotion.value("discount_value"));
							else price_before_tax -= (price_before_tax*PortalHelper.parseNullDouble(rsPromotion.value("discount_value"))/100);

							break;
						} catch (ParseException e) {
							e.printStackTrace();
							return price;
						}
					}
				}
			}

			price_before_tax = price_before_tax*quantity;

			if(price_before_tax < 0) price_before_tax = 0;
			//System.out.println()
			if(taxpercentage.tax_exclusive && taxpercentage.output_with_tax) price_before_tax = price_before_tax / (1 + (taxpercentage.tax/100)); // taxpercentage.output_with_tax means that the price_before_tax includes tax and we needed to show the amount tax exclusive for display purposes on checkout
			else if(!taxpercentage.tax_exclusive && !taxpercentage.output_with_tax) price_before_tax = (price_before_tax + (price_before_tax*taxpercentage.tax/100));
			//System.out.println(formatPrice("us", "3", "3", price_before_tax+"", true));
			price = com.etn.asimina.util.PortalHelper.formatPrice("us", "3", "3", price_before_tax+"", true);//new BigDecimal(price_before_tax+"").toPlainString();
			return price;
		}
	}

    public static boolean isNew(com.etn.lang.ResultSet.Set rs)
    {
        if("1".equals(rs.value("is_new"))) return true;
        return false;
    }

	public static String getTaxString(LinkedHashSet<String> taxHS, HashMap<String, Integer> taxNumbers)
	{
		Iterator<String> itr=taxHS.iterator();
		String taxString = "";
		int count = 1;
		while(itr.hasNext()){
			if(taxString.length() > 0) taxString +=", ";
			String tax = itr.next();
			taxString +="("+taxNumbers.get(tax)+") Taxe de "+tax+"%";
			count++;
		}
		return taxString;
	}

	public static String getTaxString2(com.etn.beans.Contexte Etn, LinkedHashSet<String> taxHS, HashMap<String, Integer> taxNumbers)
	{
		Iterator<String> itr=taxHS.iterator();
		String taxString = "";
		int count = 1;
		while(itr.hasNext()){
			if(taxString.length() > 0) taxString +=", ";
			String tax = itr.next();
			taxString +="("+taxNumbers.get(tax)+") "+ LanguageHelper.getInstance().getTranslation(Etn, "Taxe de") + " "+tax+"%";
			count++;
		}
		return taxString;
	}

    public static JSONArray getAdditionalFee(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String variantPrice, int quantity)
	{
        String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
        String isOrangeApp = com.etn.beans.app.GlobalParm.getParm("IS_ORANGE_APP");
        JSONArray additionalFees = new JSONArray();

        boolean logged = ClientSession.getInstance().isClientLoggedIn(Etn, request);

        Set rsVariant = Etn.execute("SELECT pv.product_id, pv.sku, p.catalog_id, c.catalog_type, p.brand_name, c.site_id, pt.tag_id from " + catalogdb + ".product_variants pv INNER JOIN " + catalogdb + ".products p ON p.id = pv.product_id INNER JOIN " + catalogdb + ".catalogs c ON p.catalog_id = c.id LEFT JOIN " + catalogdb + ".product_tags pt ON pt.product_id = p.id WHERE pv.id = " + escape.cote(variant_id) + " group by 1, 2, 3, 4, 5, 7");

        if(rsVariant.rs.Rows > 0)
		{
            String siteId = "";
            String productId = "";
            String catalogId = "";
            String sku = "";
            String productType = "";
            String manufacturer = "";
            String tags = "";
            int i = 0;

            if(rsVariant.next())
			{
                siteId = escape.cote(rsVariant.value("site_id"));
                productId = escape.cote(rsVariant.value("product_id"));
                catalogId = escape.cote(rsVariant.value("catalog_id"));
                sku = escape.cote(rsVariant.value("sku"));
                productType = escape.cote(rsVariant.value("catalog_type"));
                manufacturer = escape.cote(rsVariant.value("brand_name"));
                tags = escape.cote(rsVariant.value("tag_id"));
            }

            while(rsVariant.next()){

                if((++i) != rsVariant.rs.Rows)
                    tags += ",";

                tags += escape.cote(rsVariant.value("tag_id"));
            }

            LinkedHashMap<String, String> additionalFeeTypeValues = new LinkedHashMap<String, String>();
            additionalFeeTypeValues.put("deposit", "Deposit");
            additionalFeeTypeValues.put("adv_amt", "Advance (amount)");
            additionalFeeTypeValues.put("adv_mnth","Advance (months)");

            String additionalFeeQuery = "select af.*, afr.rule_apply, afr.rule_apply_value FROM "+catalogdb+".additionalfees af INNER JOIN "+catalogdb+".additionalfee_rules afr on af.id = afr.add_fee_id WHERE"
            + " af.site_id = " + siteId + " AND (( afr.element_type = 'product' AND afr.element_type_value =" + productId + ")"
            + " or ( afr.element_type = 'catalog' AND afr.element_type_value = " + catalogId + ")"
            + " or ( afr.element_type = 'sku' AND afr.element_type_value = " + sku + ")"
            + " or ( afr.element_type = 'product_type' AND afr.element_type_value = " + productType + ")"
            + " or ( afr.element_type = 'manufacturer' and afr.element_type_value = " + manufacturer + ")"
            + " or ( afr.element_type = 'tag' and afr.element_type_value IN (" + tags + ")))"
            + " GROUP BY af.id ORDER BY af.order_seq";

            Set rsAdditionalFee = Etn.execute(additionalFeeQuery);
            String startDateString = "";
            String endDateString = "";

            JSONObject additionalFee;
			
			LanguageHelper languageHelper = LanguageHelper.getInstance();

            while(rsAdditionalFee.next())
			{
                if(rsAdditionalFee.value("visible_to").equals("logged") && !logged ) continue;

                startDateString = rsAdditionalFee.value("start_date");
                endDateString = rsAdditionalFee.value("end_date");

                try {
                    if(isValidDateRange(startDateString, endDateString)){

                        additionalFee = new JSONObject();
                        additionalFee.put("name", (isOrangeApp.equals("0")?rsAdditionalFee.value("additional_fee"):languageHelper.getTranslation(Etn, PortalHelper.parseNull(additionalFeeTypeValues.get(rsAdditionalFee.value("rule_apply"))))));
                        additionalFee.put("actual_name", rsAdditionalFee.value("additional_fee"));
                        additionalFee.put("description", PortalHelper.parseNull(rsAdditionalFee.value(prefix+"description")));
                        additionalFee.put("rule_apply_value", PortalHelper.parseNull(rsAdditionalFee.value("rule_apply_value")));
                        additionalFee.put("rule_apply", PortalHelper.parseNull(rsAdditionalFee.value("rule_apply")));
                        if(rsAdditionalFee.value("rule_apply").equals("adv_mnth")){
                            additionalFee.put("price_prefix", PortalHelper.parseNull(rsAdditionalFee.value("rule_apply_value"))+" "+languageHelper.getTranslation(Etn, "mois")+" = ");
                            additionalFee.put("price",PortalHelper.parseNullDouble(variantPrice)*PortalHelper.parseNullDouble(rsAdditionalFee.value("rule_apply_value")));
                        }
                        else{
                            additionalFee.put("price_prefix", "");
                            additionalFee.put("price",PortalHelper.parseNullDouble(rsAdditionalFee.value("rule_apply_value"))*quantity);
                        }

                        additionalFees.put(additionalFee);
                    }

                } catch (ParseException e) {

                    e.printStackTrace();

                } catch (JSONException je){

                    System.out.println(je.toString());
                }
            }
        }

        return additionalFees;
    }

    public static boolean isValidDateRange(String startDateString, String endDateString) throws ParseException {

        DateFormat df = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        Date startDate, endDate, currentDate;

        currentDate = df.parse(df.format(new Date()));

        startDate = (startDateString.length() == 0 ? currentDate : df.parse(startDateString));
        endDate = (endDateString.length() == 0 ? currentDate : df.parse(endDateString));

        if(!(currentDate.before(startDate) || currentDate.after(endDate))) return true;

        return false;
    }

    public static int getQuantityLimit(com.etn.beans.Contexte Etn, String variant_id, JSONArray comewith)
	{
        String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
        Set rsVariant = Etn.execute("select pv.*, p.catalog_id, c.catalog_type, p.brand_name, c.site_id, pt.tag_id from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id=pv.product_id inner join "+catalogdb+".catalogs c on p.catalog_id = c.id LEFT JOIN " + catalogdb + ".product_tags pt ON pt.product_id = p.id where pv.id="+escape.cote(variant_id));
        rsVariant.next();
        String quantityLimitQuery = "select quantity_limit from "+catalogdb+".quantitylimits q inner join "+catalogdb+".quantitylimits_rules qr on q.id=qr.quantitylimit_id where"
            + " q.site_id = "+escape.cote(rsVariant.value("site_id"))+" and quantity_limit>0 and ((qr.applied_to_type='product' and qr.applied_to_value="+escape.cote(rsVariant.value("product_id"))+")"
            + " or (qr.applied_to_type='catalog' and qr.applied_to_value="+escape.cote(rsVariant.value("catalog_id"))+")"
            + " or (qr.applied_to_type='sku' and qr.applied_to_value="+escape.cote(rsVariant.value("sku"))+")"
            + " or (qr.applied_to_type='product_type' and qr.applied_to_value="+escape.cote(rsVariant.value("catalog_type"))+")"
            + " or (qr.applied_to_type='manufacturer' and qr.applied_to_value="+escape.cote(rsVariant.value("brand_name"))+")"
            + " or (qr.applied_to_type='tag' and qr.applied_to_value=" + escape.cote(rsVariant.value("tag_id")) + ")"
            + " or (qr.applied_to_type='all')) group by qr.quantitylimit_id order by q.order_seq";

            //System.out.println(quantityLimitQuery);

        int quantityLimit = PortalHelper.parseNullInt(rsVariant.value("stock"));
        Set rsQuantityLimit = Etn.execute(quantityLimitQuery);
        if(rsQuantityLimit.next()){
            if(PortalHelper.parseNullInt(rsQuantityLimit.value(0)) < quantityLimit) quantityLimit = PortalHelper.parseNullInt(rsQuantityLimit.value(0));
        }

        for(int i=0; i<comewith.length(); i++)
		{
			if("label".equals(PortalHelper.parseNull(comewith.optJSONObject(i).optString("comewith")))) continue;

            JSONObject comewithVariant = comewith.optJSONObject(i).optJSONObject("variant");
            if(comewithVariant.optString("productType").equals("offer_prepaid") || comewithVariant.optString("productType").equals("offer_prepaid")){
                continue;
            }

            if(PortalHelper.parseNullInt(comewithVariant.optString("variantStock")) < quantityLimit) quantityLimit = PortalHelper.parseNullInt(comewithVariant.optString("variantStock"));
        }

        return quantityLimit;
    }

    public static JSONObject getPromotion(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix){
        JSONObject promotion = new JSONObject();
        String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");

        boolean logged = ClientSession.getInstance().isClientLoggedIn(Etn, request);

        Set rsVariant = Etn.execute("select pv.*, p.catalog_id, c.catalog_type, p.brand_name, c.site_id, pt.tag_id from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id=pv.product_id inner join "+catalogdb+".catalogs c on p.catalog_id = c.id LEFT JOIN " + catalogdb + ".product_tags pt ON pt.product_id = p.id where pv.id="+escape.cote(variant_id));
        rsVariant.next();

        String promotionQuery = "select p.*, concat(p.end_date,'') fmt_end_date from "+catalogdb+".promotions p inner join "+catalogdb+".promotions_rules pr on p.id=pr.promotion_id where"
            + " p.site_id = "+escape.cote(rsVariant.value("site_id"))+" and discount_value!=0 and ((pr.applied_to_type='product' and pr.applied_to_value="+escape.cote(rsVariant.value("product_id"))+")"
            + " or (pr.applied_to_type='catalog' and pr.applied_to_value="+escape.cote(rsVariant.value("catalog_id"))+")"
            + " or (pr.applied_to_type='sku' and pr.applied_to_value="+escape.cote(rsVariant.value("sku"))+")"
            + " or (pr.applied_to_type='product_type' and pr.applied_to_value="+escape.cote(rsVariant.value("catalog_type"))+")"
            + " or (pr.applied_to_type='manufacturer' and pr.applied_to_value="+escape.cote(rsVariant.value("brand_name"))+")"
            + " or (pr.applied_to_type='tag' and pr.applied_to_value=" + escape.cote(rsVariant.value("tag_id")) + "))"
            + " group by pr.promotion_id order by p.order_seq";

        Set rsPromotion = Etn.execute(promotionQuery);
        while(rsPromotion.next())
		{
			if(rsPromotion.value("visible_to").equals("logged") && !logged ) continue;
            String startDateString = rsPromotion.value("start_date");
            String endDateString = rsPromotion.value("end_date");
            try {
                //System.out.println(startDate +" " +endDate+" "+currentDate);
                //String newDateString = df.format(startDate);
                if(!isValidDateRange(startDateString, endDateString)) continue;

                promotion.put("flash_sale", rsPromotion.value("flash_sale"));
                promotion.put("end_date", rsPromotion.value("fmt_end_date"));
                promotion.put("flash_sale_quantity", rsPromotion.value("flash_sale_quantity"));
                promotion.put("duration", rsPromotion.value("duration"));
                promotion.put("promotion_start_date", startDateString);
                promotion.put("promotion_end_date", endDateString);
                promotion.put("description", rsPromotion.value(prefix+"description"));
                promotion.put("title", rsPromotion.value(prefix+"title"));
                promotion.put("order_seq", rsPromotion.value("order_seq"));
                return promotion;
            } catch (Exception e) {
                e.printStackTrace();
                return promotion;
            }
        }
        return promotion;
    }

    public static JSONArray getPromotions(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix)
	{
        JSONArray promotions = new JSONArray();
        String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
		
		boolean logged = ClientSession.getInstance().isClientLoggedIn(Etn, request);

        Set rsVariant = Etn.execute("select pv.*, p.catalog_id, c.catalog_type, p.brand_name, c.site_id, pt.tag_id from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id=pv.product_id inner join "+catalogdb+".catalogs c on p.catalog_id = c.id LEFT JOIN " + catalogdb + ".product_tags pt ON pt.product_id = p.id where pv.id="+escape.cote(variant_id));
        rsVariant.next();

        String promotionQuery = "select p.*, concat(p.end_date,'') fmt_end_date from "+catalogdb+".promotions p inner join "+catalogdb+".promotions_rules pr on p.id=pr.promotion_id where"
            + " p.site_id = "+escape.cote(rsVariant.value("site_id"))+" and discount_value!=0 and ((pr.applied_to_type='product' and pr.applied_to_value="+escape.cote(rsVariant.value("product_id"))+")"
            + " or (pr.applied_to_type='catalog' and pr.applied_to_value="+escape.cote(rsVariant.value("catalog_id"))+")"
            + " or (pr.applied_to_type='sku' and pr.applied_to_value="+escape.cote(rsVariant.value("sku"))+")"
            + " or (pr.applied_to_type='product_type' and pr.applied_to_value="+escape.cote(rsVariant.value("catalog_type"))+")"
            + " or (pr.applied_to_type='manufacturer' and pr.applied_to_value="+escape.cote(rsVariant.value("brand_name"))+")"
            + " or (pr.applied_to_type='tag' and pr.applied_to_value=" + escape.cote(rsVariant.value("tag_id")) + "))"
            + " group by pr.promotion_id order by p.order_seq";

        Set rsPromotion = Etn.execute(promotionQuery);
        while(rsPromotion.next())
		{
			if(rsPromotion.value("visible_to").equals("logged") && !logged ) continue;

            String startDateString = rsPromotion.value("start_date");
            String endDateString = rsPromotion.value("end_date");
            try {
                //System.out.println(startDate +" " +endDate+" "+currentDate);
                //String newDateString = df.format(startDate);
                if(!isValidDateRange(startDateString, endDateString)) continue;

                JSONObject promotion = new JSONObject();
                promotion.put("flash_sale", rsPromotion.value("flash_sale"));
                promotion.put("end_date", rsPromotion.value("fmt_end_date"));
                promotion.put("flash_sale_quantity", rsPromotion.value("flash_sale_quantity"));
                promotion.put("duration", rsPromotion.value("duration"));
                promotion.put("promotion_start_date", startDateString);
                promotion.put("promotion_end_date", endDateString);
                promotion.put("description", rsPromotion.value(prefix+"description"));
                promotion.put("title", rsPromotion.value(prefix+"title"));
                promotion.put("order_seq", rsPromotion.value("order_seq"));
                promotion.put("discount_type", rsPromotion.value("discount_type"));
                promotion.put("discount_value", rsPromotion.value("discount_value"));
                promotions.put(promotion);//return promotion;
            } catch (Exception e) {
                e.printStackTrace();
                return promotions;
            }
        }
        return promotions;
    }

    public static JSONArray getComewith(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id){
        return getComewith(Etn, request, variant_id, prefix, langue_id, "");
    }

    public static JSONArray getComewith(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id, String comewith_excluded){
        return getComewith(Etn, request, variant_id, prefix, langue_id, comewith_excluded, false);
    }

    public static JSONArray getComewith(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id, String comewith_excluded, boolean isQuotation){
        return getComewith(Etn, request, variant_id, prefix, langue_id, comewith_excluded, isQuotation, "");
    }

    public static JSONArray getComewith(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id, String comewith_excluded, boolean isQuotation, String menu_id){
        return getComewith(Etn, request, variant_id, prefix, langue_id, comewith_excluded, isQuotation, menu_id, 1, "");
    }

    public static JSONArray getComewith(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id, String comewith_excluded, boolean isQuotation, String menu_id, int quantity, String selectedVariant){

        String cachedResourcesFolder = "";
		if(menu_id.length() > 0) cachedResourcesFolder = com.etn.asimina.util.PortalHelper.getCachedResourcesUrl(Etn, menu_id);

        JSONArray comewiths = new JSONArray();
        String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
        Set rsVariant = Etn.execute("select pv.product_id, pv.sku, p.catalog_id, c.catalog_type, p.brand_name, c.site_id, pt.tag_id from "+catalogdb+".product_variants pv inner join "+catalogdb+".products p on p.id=pv.product_id inner join "+catalogdb+".catalogs c on p.catalog_id = c.id LEFT JOIN " + catalogdb + ".product_tags pt ON pt.product_id = p.id where pv.id="+escape.cote(variant_id));


		String client_id = "";
		boolean logged = false;
		Client client = ClientSession.getInstance().getLoggedInClient(Etn, request);
		if(client != null)
		{
			logged = true;
			client_id = client.getProperty("id");
		}		
		
        if(rsVariant.rs.Rows > 0){

            String siteId = "";
            String productId = "";
            String catalogId = "";
            String sku = "";
            String productType = "";
            String manufacturer = "";
            String tags = "";
            int i = 0;

            if(rsVariant.next()){

                siteId = rsVariant.value("site_id"); // siteId = escape.cote(rsVariant.value("site_id"));
                productId = escape.cote(rsVariant.value("product_id"));
                catalogId = escape.cote(rsVariant.value("catalog_id"));
                sku = escape.cote(rsVariant.value("sku"));
                productType = escape.cote(rsVariant.value("catalog_type"));
                manufacturer = escape.cote(rsVariant.value("brand_name"));
                tags = escape.cote(rsVariant.value("tag_id"));
            }

            while(rsVariant.next()){

                if((++i) != rsVariant.rs.Rows)
                    tags += ",";

                tags += escape.cote(rsVariant.value("tag_id"));
            }

            String comewith_excluded_clause = "";
            if(!comewith_excluded.equals("")){
                comewith_excluded_clause = " c.id NOT IN("+comewith_excluded+") and";
            }
            String comewithQuery = "select * from "+catalogdb+".comewiths c inner join "+catalogdb+".comewiths_rules cr on c.id = cr.comewith_id and site_id = "+escape.cote(siteId)+" where " + comewith_excluded_clause
                + " ((cr.associated_to_type='product' and cr.associated_to_value="+productId+")"
                + " or (cr.associated_to_type='catalog' and cr.associated_to_value="+catalogId+")"
                + " or (cr.associated_to_type='sku' and cr.associated_to_value="+sku+")"
                + " or (cr.associated_to_type='product_type' and cr.associated_to_value="+productType+")"
                + " or (cr.associated_to_type='manufacturer' and cr.associated_to_value="+manufacturer+")"
                + " or (cr.associated_to_type = 'tag' and cr.associated_to_value IN (" + tags + ")))"
                + " group by cr.comewith_id order by c.order_seq";

            Set rsComewith = Etn.execute(comewithQuery);
            while(rsComewith.next())
			{
				if(rsComewith.value("visible_to").equals("logged") && !logged) continue;// check rule applied to logged in user or all
                String startDateString = rsComewith.value("start_date");
                String endDateString = rsComewith.value("end_date");
                try {
                    //System.out.println(startDate +" " +endDate+" "+currentDate);
                    //String newDateString = df.format(startDate);
                    if(!isValidDateRange(startDateString, endDateString)) continue;

                    if(startDateString.length()>0){ // because frequency is only applicable when start date is set
                        Calendar today = Calendar.getInstance();
                        DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
                        Date startDate = formatter.parse(startDateString);
                        Calendar start = Calendar.getInstance();
                        start.setTime(startDate);
                        if(rsComewith.value("frequency").equals("weekly")){
                            if(start.get(Calendar.DAY_OF_WEEK)!=today.get(Calendar.DAY_OF_WEEK)) continue;
                        }
                        else if(rsComewith.value("frequency").equals("monthly")){
                            if(start.get(Calendar.DAY_OF_MONTH)!=today.get(Calendar.DAY_OF_MONTH)) continue;
                        }
                    }
                    String variantSku = "";
                    String variantId = "";
                    String variantName = "";
                    String imageUrl = "";
                    String productName = "";
                    productId = "";
                    String whereClause = "";
                    String value = rsComewith.value("applied_to_value");

					//assumption is we are only allowing 1 selectable comewith to be associated to the product ... if we add more than 1 selectable comewith code will not work
                    if("select".equals(rsComewith.value("variant_type")) && selectedVariant.length()>0) whereClause = " pv.id="+escape.cote(selectedVariant);
                    else if(rsComewith.value("applied_to_type").equals("sku")) whereClause = " pv.sku="+escape.cote(value);
                    else{
                        whereClause = " p.id="+escape.cote(value);//+" order by pv.is_default desc, pv.id asc limit 1";
                        if(!rsComewith.value("variant_type").equals("select")) whereClause +=" order by pv.is_default desc, pv.id asc limit 1";
                        else whereClause +=" order by pv.order_seq ";

                    }


                    JSONArray selectableVariants = new JSONArray();
                    JSONObject selectableVariant;
                    JSONObject variant = new JSONObject();
					
					boolean showamountwithtax = false;

                    Set rsProduct = Etn.execute("select p.*, pv.id as product_variant_id, pv.stock as variant_stock,pv.commitment, "+
							" c.price_tax_included, c.show_amount_tax_included, c.tax_percentage, pv.sku as variant_sku, "+
							" case when p.product_type = 'offer_postpaid' or p.product_version <> 'V1' then pv.frequency else '' end as frequency, "+
							" (select name from "+catalogdb+".product_variant_details pvd where pvd.product_variant_id = pv.id and langue_id = " + escape.cote(langue_id) + ") as name "+
							" from "+catalogdb+".products p inner join "+catalogdb+".catalogs ct on ct.id = p.catalog_id and ct.site_id = "+escape.cote(siteId)+
							" inner join "+catalogdb+".product_variants pv on p.id=pv.product_id inner join "+catalogdb+".catalogs c on p.catalog_id = c.id where pv.is_active=1 and "+whereClause);

                    while(rsProduct.next()){

                        variantSku = PortalHelper.parseNull(rsProduct.value("variant_sku"));
                        variantId = PortalHelper.parseNull(rsProduct.value("product_variant_id"));
                        variantName = PortalHelper.parseNull(rsProduct.value("name"));

                        variant = new JSONObject();
                        variant = PortalHelper.toJSONObject(rsProduct);

                        boolean pricetaxincluded = ("1".equals(PortalHelper.parseNull(rsProduct.value("price_tax_included")))?true:false);
                        showamountwithtax = ("1".equals(PortalHelper.parseNull(rsProduct.value("show_amount_tax_included")))?true:false);


                        TaxPercentage taxpercentage = new TaxPercentage();
                        TaxPercentage taxpercentageWT = new TaxPercentage(); // to output without tax
                        taxpercentage.tax = PortalHelper.parseNullDouble(rsProduct.value("tax_percentage"));
                        taxpercentageWT.tax = taxpercentage.tax;
                        taxpercentage.input_with_tax = pricetaxincluded;
                        taxpercentageWT.input_with_tax = pricetaxincluded;
                        taxpercentage.output_with_tax = showamountwithtax;
                        taxpercentageWT.output_with_tax = showamountwithtax;
                        taxpercentage.tax_exclusive = false;
                        taxpercentageWT.tax_exclusive = true;

						//new rule is we must apply promotion on comewith as well if any applicable
                        variant.put("unit_price", (rsComewith.value("comewith").equals("product")?getPrice(Etn, variantId, taxpercentage, 1, true, client_id, null, "", false, null, rsComewith.value("id")):"0"));
                        variant.put("unit_price_wt", (rsComewith.value("comewith").equals("product")?getPrice(Etn, variantId, taxpercentageWT, 1, true, client_id, null, "", false, null, rsComewith.value("id")):"0"));
                        variant.put("price", (rsComewith.value("comewith").equals("product")?getPrice(Etn, variantId, taxpercentage, quantity, true, client_id, null, "", false, null, rsComewith.value("id")):"0"));
                        variant.put("priceWT", (rsComewith.value("comewith").equals("product")?getPrice(Etn, variantId, taxpercentageWT, quantity, true, client_id, null, "", false, null, rsComewith.value("id")):"0"));
						
						//lets not apply comewith price difference here as well so that we can get the original prices without any promo or comewith price diff
                        variant.put("original_unit_price", (rsComewith.value("comewith").equals("product")?getPrice(Etn, variantId, taxpercentage, 1, false, client_id):"0"));
                        variant.put("original_unit_price_wt", (rsComewith.value("comewith").equals("product")?getPrice(Etn, variantId, taxpercentageWT, 1, false, client_id):"0"));
                        variant.put("original_price", (rsComewith.value("comewith").equals("product")?getPrice(Etn, variantId, taxpercentage, quantity, false, client_id):"0"));
                        variant.put("original_priceWT", (rsComewith.value("comewith").equals("product")?getPrice(Etn, variantId, taxpercentageWT, quantity, false, client_id):"0"));

                        productName = rsProduct.value(prefix+"name");
                        productId = rsProduct.value("id");
                        if(rsProduct.value("product_type").startsWith("offer_")){
                            Set rsImages = Etn.execute("select image_file_name from "+catalogdb+".product_images where product_id="+escape.cote(productId)+" and langue_id="+escape.cote(langue_id));

                            if(rsImages.next()) imageUrl = rsImages.value("image_file_name");
                        }
                        else{
                            Set rsVariantImages = Etn.execute("select path from "+catalogdb+".product_variant_resources where type='image' and product_variant_id="+escape.cote(variantId)+" and langue_id="+escape.cote(langue_id)+" order by sort_order");

                            if(rsVariantImages.next()) imageUrl = rsVariantImages.value("path");
                        }

                        if(imageUrl.length()>0){
                            String imagePathPrefix = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + ("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV"))?"":siteId+"/") + "img/4x3/";
                            String imageUrlPrefix = GlobalParm.getParm("MEDIA_LIBRARY_UPLOADS_URL") + ("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV"))?"":siteId+"/");
                            if("1".equals(GlobalParm.getParm("IS_PRODUCTION_ENV")))
                            {
                                    imageUrlPrefix = cachedResourcesFolder;
                            }
                            imageUrlPrefix = imageUrlPrefix + "img/thumb/";
                            String imagePath = imagePathPrefix + imageUrl;
                            String _version = PortalHelper.getImageUrlVersion(imagePath);
                            imageUrl = imageUrlPrefix + imageUrl + _version;
                        }
                        selectableVariant = new JSONObject();
                        selectableVariant.put("product_type", rsProduct.value("product_type"));
                        selectableVariant.put("variantName", rsProduct.value("name"));
                        selectableVariant.put("imageUrl", imageUrl);
                        selectableVariant.put("variant_id", variantId);
                        selectableVariant.put("sku", variantSku);
                        selectableVariant.put("stock", rsProduct.value("variant_stock"));
                        selectableVariants.put(selectableVariant);
                    }



                    JSONObject comewith = new JSONObject();
                    comewith.put("id", rsComewith.value("id"));
                    comewith.put("comewith", rsComewith.value("comewith"));
                    comewith.put("type", rsComewith.value("type"));
                    comewith.put("title", rsComewith.value("title"));
                    comewith.put("description", rsComewith.value(prefix+"description"));
                    comewith.put("productName", productName);
                    comewith.put("product_id", productId);
                    comewith.put("imageUrl", imageUrl);
                    comewith.put("variant_id", variantId);
                    comewith.put("sku", variantSku);
                    comewith.put("variantName", variantName);
                    comewith.put("variant", variant);
                    comewith.put("selectableVariants", selectableVariants);
                    comewith.put("applied_to_type", rsComewith.value("applied_to_type"));
                    comewith.put("applied_to_value", rsComewith.value("applied_to_value"));
                    comewith.put("associated_to_type", rsComewith.value("associated_to_type"));
                    comewith.put("associated_to_value", rsComewith.value("associated_to_value"));
                    comewith.put("variant_type", rsComewith.value("variant_type"));
                    comewith.put("show_amount_with_tax", showamountwithtax);

                    comewiths.put(comewith);
                } catch (Exception e) {
                    e.printStackTrace();
                    return comewiths;
                }
            }
        }
        return comewiths;
    }

    public static JSONArray getSubsidiesOnVariant(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id){

        String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
        JSONArray subsidies = new JSONArray();
        JSONArray products = new JSONArray();
        JSONArray variants = new JSONArray();
        String appliedToType = "";
        String appliedToValue = "";
        TaxPercentage taxpercentage = new TaxPercentage();


        boolean logged = ClientSession.getInstance().isClientLoggedIn(Etn, request);


        Set rsVariant = Etn.execute("SELECT pv.*, p.catalog_id, c.catalog_type, p.brand_name, c.site_id, pt.tag_id from " + catalogdb + ".product_variants pv INNER JOIN " + catalogdb + ".products p ON p.id = pv.product_id INNER JOIN " + catalogdb + ".catalogs c ON p.catalog_id = c.id LEFT JOIN " + catalogdb + ".product_tags pt ON pt.product_id = p.id WHERE pv.id = " + escape.cote(variant_id));

        if(rsVariant.next()){

//            String associatedToType = "";

  //          if(rsVariant.value("product_id").length() > 0)

            String subsidiesQuery = "select * FROM " + catalogdb + ".subsidies WHERE"
            + " site_id = " + escape.cote(rsVariant.value("site_id")) + " AND (( applied_to_type = 'product' AND applied_to_value = " + escape.cote(rsVariant.value("product_id")) + ")"
            + " or ( applied_to_type = 'catalog' AND applied_to_value = " + escape.cote(rsVariant.value("catalog_id")) + ")"
            + " or ( applied_to_type = 'sku' AND applied_to_value = " + escape.cote(rsVariant.value("sku")) + ")"
            + " or ( applied_to_type = 'product_type' AND applied_to_value = " + escape.cote(rsVariant.value("catalog_type")) + ")"
            + " or ( applied_to_type = 'manufacturer' and applied_to_value = " + escape.cote(rsVariant.value("brand_name")) + ")"
            + " or ( applied_to_type = 'tag' and applied_to_value = " + escape.cote(rsVariant.value("tag_id")) + "))"
            + " ORDER BY order_seq";

            Set rsSubsidies = Etn.execute(subsidiesQuery);

            while(rsSubsidies.next())
			{
				if(rsSubsidies.value("visible_to").equals("logged") && !logged) continue; // check rule applied to logged in user or all
                
				String startDateString = rsSubsidies.value("start_date");
                String endDateString = rsSubsidies.value("end_date");

                try {

                    if(isValidDateRange(startDateString, endDateString)){                        
                        JSONObject subsidy = new JSONObject();
                        subsidy.put("subsidy_id", PortalHelper.parseNull(rsSubsidies.value("id")));
                        subsidy.put("name", PortalHelper.parseNull(rsSubsidies.value("name")));
                        subsidy.put("lang_1_description", PortalHelper.parseNull(rsSubsidies.value("lang_1_description")));
                        subsidy.put("lang_2_description", PortalHelper.parseNull(rsSubsidies.value("lang_2_description")));
                        subsidy.put("lang_3_description", PortalHelper.parseNull(rsSubsidies.value("lang_3_description")));
                        subsidy.put("lang_4_description", PortalHelper.parseNull(rsSubsidies.value("lang_4_description")));
                        subsidy.put("lang_5_description", PortalHelper.parseNull(rsSubsidies.value("lang_5_description")));
                        subsidy.put("visible_to", PortalHelper.parseNull(rsSubsidies.value("visible_to")));
                        subsidy.put("discount_type", PortalHelper.parseNull(rsSubsidies.value("discount_type")));
                        subsidy.put("discount_value", PortalHelper.parseNull(rsSubsidies.value("discount_value")));
                        subsidy.put("url", PortalHelper.parseNull(rsSubsidies.value("redirect_url")));

                        subsidies.put(subsidy);
                    }

                } catch (ParseException e) {

                    e.printStackTrace();

                } catch (JSONException je){

                    System.out.println(je.toString());
                }
            }
        }

        return subsidies;
    }

    public static JSONArray getSubsidies(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String variant_id, String prefix, String langue_id){

        String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
        JSONArray subsidies = new JSONArray();
        JSONArray products = new JSONArray();
        JSONArray variants = new JSONArray();
        String appliedToType = "";
        String appliedToValue = "";
        TaxPercentage taxpercentage = new TaxPercentage();
		
		String client_id = "";
		boolean logged = false;
		Client client = ClientSession.getInstance().getLoggedInClient(Etn, request);
		if(client != null)
		{
			logged = true;
			client_id = client.getProperty("id");
		}		
					
		LanguageHelper languageHelper = LanguageHelper.getInstance();

        Set rsVariant = Etn.execute("SELECT pv.*, p.catalog_id, c.catalog_type, p.brand_name, c.site_id, pt.tag_id from " + catalogdb + ".product_variants pv INNER JOIN " + catalogdb + ".products p ON p.id = pv.product_id INNER JOIN " + catalogdb + ".catalogs c ON p.catalog_id = c.id LEFT JOIN " + catalogdb + ".product_tags pt ON pt.product_id = p.id WHERE pv.id = " + escape.cote(variant_id));

        if(rsVariant.next()){

            String subsidiesQuery = "select s.*, sr.associated_to_type, sr.associated_to_value FROM " + catalogdb + ".subsidies s INNER JOIN " + catalogdb + ".subsidies_rules sr on s.id = sr.subsidy_id WHERE"
            + " s.site_id = " + escape.cote(rsVariant.value("site_id")) + " AND (( sr.associated_to_type = 'product' AND sr.associated_to_value = " + escape.cote(rsVariant.value("product_id")) + ")"
            + " or ( sr.associated_to_type = 'catalog' AND sr.associated_to_value = " + escape.cote(rsVariant.value("catalog_id")) + ")"
            + " or ( sr.associated_to_type = 'sku' AND sr.associated_to_value = " + escape.cote(rsVariant.value("sku")) + ")"
            + " or ( sr.associated_to_type = 'product_type' AND sr.associated_to_value = " + escape.cote(rsVariant.value("catalog_type")) + ")"
            + " or ( sr.associated_to_type = 'manufacturer' and sr.associated_to_value = " + escape.cote(rsVariant.value("brand_name")) + ")"
            + " or ( sr.associated_to_type = 'tag' and sr.associated_to_value = " + escape.cote(rsVariant.value("tag_id")) + "))"
            + " GROUP BY s.id ORDER BY s.order_seq";

            Set rsSubsidies = Etn.execute(subsidiesQuery);
            String startDateString = "";
            String endDateString = "";

            JSONObject subsidy;

            while(rsSubsidies.next())
			{
				if(rsSubsidies.value("visible_to").equals("logged") && !logged) continue;// check rule applied to logged in user or all

                startDateString = rsSubsidies.value("start_date");
                endDateString = rsSubsidies.value("end_date");

                try {

                    if(isValidDateRange(startDateString, endDateString)){

                        JSONObject product = new JSONObject();

                        appliedToType = PortalHelper.parseNull(rsSubsidies.value("applied_to_type"));
                        appliedToValue = PortalHelper.parseNull(rsSubsidies.value("applied_to_value"));

                        subsidy = new JSONObject();
                        subsidy.put("name", languageHelper.getTranslation(Etn, PortalHelper.parseNull(rsSubsidies.value("name"))));
                        subsidy.put("description", PortalHelper.parseNull(rsSubsidies.value(prefix+"description")));
                        subsidy.put("discount_type", PortalHelper.parseNull(rsSubsidies.value("discount_type")));
                        subsidy.put("discount_value", PortalHelper.parseNull(rsSubsidies.value("discount_value")));
                        subsidy.put("applied_to_type", appliedToType);
                        subsidy.put("applied_to_value", appliedToValue);
                        subsidy.put("associated_to_type", PortalHelper.parseNull(rsSubsidies.value("associated_to_type")));
                        subsidy.put("associated_to_value", PortalHelper.parseNull(rsSubsidies.value("associated_to_value")));
                        subsidy.put("url", PortalHelper.parseNull(rsSubsidies.value("__url")));

                        products = new JSONArray();
                        String params = "";

                        if(appliedToType.equalsIgnoreCase("sku")){

                            params = " AND pv.sku = " + escape.cote(appliedToValue);

                        } else if(appliedToType.equalsIgnoreCase("product")){

                            params = " AND pv.product_id = " + escape.cote(appliedToValue);

                        } else if(appliedToType.equalsIgnoreCase("product_type")){

                            params = " AND p.product_type = " + escape.cote(appliedToValue);

                        } else if(appliedToType.equalsIgnoreCase("catalog")){

                            params = " AND p.catalog_id = " + escape.cote(appliedToValue);

                        } else if(appliedToType.equalsIgnoreCase("manufacturer")){

                            params = " AND p.brand_name = " + escape.cote(appliedToValue);

                        } else if(appliedToType.equalsIgnoreCase("tag")){

                            params = " AND pt.tag_id = " + escape.cote(appliedToValue);

                        }

                        Set allProductsRs = Etn.execute("SELECT p.lang_1_name as name, p.id FROM "+catalogdb+".products p INNER JOIN "+catalogdb+".product_variants pv ON p.id = pv.product_id LEFT JOIN "+catalogdb+".product_tags pt ON p.id = pt.product_id WHERE 1=1 " + params + " group by pv.product_id");

                        while(allProductsRs.next()){

                            product = new JSONObject();
                            variants = new JSONArray();

                            product.put("id", PortalHelper.parseNull(allProductsRs.value("id")));
                            product.put("name", PortalHelper.parseNull(allProductsRs.value("name")));

                            Set allVariantsRs = Etn.execute("SELECT p.*, pv.id as product_variant_id, pv.*, c.price_tax_included, c.show_amount_tax_included, c.tax_percentage, (select name from "+catalogdb+".product_variant_details pvd where pvd.product_variant_id = pv.id and langue_id = " + escape.cote(langue_id) + ") as name FROM "+catalogdb+".product_variants pv, "+catalogdb+".products p, "+catalogdb+".catalogs c WHERE pv.product_id = p.id and p.catalog_id = c.id and product_id = " + escape.cote(PortalHelper.parseNull(allProductsRs.value("id"))));

                            while(allVariantsRs.next()){

                                JSONObject variant = new JSONObject();

                                variant = PortalHelper.toJSONObject(allVariantsRs);

                                boolean pricetaxincluded = ("1".equals(PortalHelper.parseNull(allVariantsRs.value("price_tax_included")))?true:false);
                                boolean showamountwithtax = ("1".equals(PortalHelper.parseNull(allVariantsRs.value("show_amount_tax_included")))?true:false);

                                taxpercentage.tax = PortalHelper.parseNullDouble(allVariantsRs.value("tax_percentage"));
                                taxpercentage.input_with_tax = pricetaxincluded;
                                taxpercentage.output_with_tax = showamountwithtax;
                                taxpercentage.tax_exclusive = !showamountwithtax;

                                variant.put("price", getPrice(Etn, PortalHelper.parseNull(allVariantsRs.value("id")), taxpercentage, 1, true, client_id));

                                variants.put(variant);
                            }

                            product.put("variants", variants);
                            products.put(product);
                        }

                        subsidy.put("products", products);

                        subsidies.put(subsidy);
                    }

                } catch (ParseException e) {

                    e.printStackTrace();

                } catch (JSONException je){

                    System.out.println(je.toString());
                }
            }
        }

        return subsidies;
    }

    public static JSONArray getSelectedVariantSubsidies(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, String appliedToType, String appliedToValue, String siteId, String prefix){

        String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
        JSONArray subsidies = new JSONArray();

		String client_id = "";
		boolean logged = false;
		Client client = ClientSession.getInstance().getLoggedInClient(Etn, request);
		if(client != null)
		{
			logged = true;
			client_id = client.getProperty("id");
		}		

        String subsidiesQuery = "select s.*, sr.associated_to_type, sr.associated_to_value FROM " + catalogdb + ".subsidies s INNER JOIN " + catalogdb + ".subsidies_rules sr on s.id = sr.subsidy_id WHERE"
        + " s.site_id = " + escape.cote(siteId) + " AND"
        + " s.applied_to_type = " + escape.cote(appliedToType) + " and s.applied_to_value = " + escape.cote(appliedToValue)
        + " GROUP BY s.id ORDER BY s.order_seq";

//        System.out.println(subsidiesQuery);
        Set rsSubsidies = Etn.execute(subsidiesQuery);
        String startDateString = "";
        String endDateString = "";

        JSONObject subsidy;
		
		LanguageHelper languageHelper = LanguageHelper.getInstance();

        while(rsSubsidies.next())
		{
			if(rsSubsidies.value("visible_to").equals("logged") && !logged) continue;// check rule applied to logged in user or all
            startDateString = rsSubsidies.value("start_date");
            endDateString = rsSubsidies.value("end_date");

            try {

                if(isValidDateRange(startDateString, endDateString)){

                    subsidy = new JSONObject();
                    subsidy.put("name", languageHelper.getTranslation(Etn, PortalHelper.parseNull(rsSubsidies.value("name"))));
                    subsidy.put("description", PortalHelper.parseNull(rsSubsidies.value(prefix+"description")));
                    subsidy.put("discount_type", PortalHelper.parseNull(rsSubsidies.value("discount_type")));
                    subsidy.put("discount_value", PortalHelper.parseNull(rsSubsidies.value("discount_value")));
                    subsidy.put("applied_to_type", PortalHelper.parseNull(rsSubsidies.value("applied_to_type")));
                    subsidy.put("applied_to_value", PortalHelper.parseNull(rsSubsidies.value("applied_to_value")));
                    subsidy.put("associated_to_type", PortalHelper.parseNull(rsSubsidies.value("associated_to_type")));
                    subsidy.put("associated_to_value", PortalHelper.parseNull(rsSubsidies.value("associated_to_value")));

                    subsidies.put(subsidy);
                }

            } catch (ParseException e) {

                e.printStackTrace();

            } catch (JSONException je){

                System.out.println(je.toString());
            }
        }

        return subsidies;
    }

}