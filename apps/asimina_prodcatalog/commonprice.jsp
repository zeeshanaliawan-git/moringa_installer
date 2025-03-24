<%@ page import="java.text.*"%>
<%!

	class TaxPercentage
	{
                double tax = 0;
                boolean input_with_tax = false;
                boolean output_with_tax = false;
	}
        String getPrice(String price_json, TaxPercentage taxpercentage, boolean logged){
            return getPrice(price_json, taxpercentage, null,1,"", logged, 0, "", 0, "", 0, "");
        }

        String getPrice(String price_json, TaxPercentage taxpercentage, String[] price_diff, int quantity, String bundle_prices, boolean logged){
            return getPrice(price_json, taxpercentage, price_diff,quantity,bundle_prices, logged, 0, "", 0, "", 0, "");
        }

        String getPrice(String price_json, TaxPercentage taxpercentage, boolean logged, double productDiscount, String productDiscountType, double catalogDiscount, String catalogDiscountType, double overallDiscount, String overallDiscountType){
            return getPrice(price_json, taxpercentage, null,1,"", logged, productDiscount, productDiscountType, catalogDiscount, catalogDiscountType, overallDiscount, overallDiscountType);
        }

        String getPrice(String price_json, TaxPercentage taxpercentage, String[] price_diff, int quantity, String bundle_prices, boolean logged, double productDiscount, String productDiscountType, double catalogDiscount, String catalogDiscountType, double overallDiscount, String overallDiscountType){
            return getPrice(price_json, taxpercentage, price_diff,quantity,bundle_prices, logged, productDiscount, productDiscountType, catalogDiscount, catalogDiscountType , 0, "", overallDiscount, overallDiscountType);
        }

        String getPrice(String price_json, TaxPercentage taxpercentage, String[] price_diff, int quantity, String bundle_prices, boolean logged, double productDiscount, String productDiscountType, double catalogDiscount, String catalogDiscountType, double slot_discount_value, String slot_discount_type, double overallDiscount, String overallDiscountType){
            if(parseNull(price_json).length() == 0) return "";
            Gson gson = new Gson(); 
            Type type = new TypeToken<List<Object>>(){}.getType();
            List<Object> list = gson.fromJson(price_json, type);
            String price = "";


            for(int i=0;i<list.size();i++){
                Map<String,String> map = (Map)list.get(i);

                String startDateString = parseNull(map.get("startDate"));
                String endDateString = parseNull(map.get("endDate"));                    

                DateFormat df = new SimpleDateFormat("yyyy-MM-dd"); 
                Date startDate;
                Date endDate;
                Date currentDate = new Date();
                try {
                    startDate = (startDateString.length()==0?new Date():df.parse(startDateString));
                    endDate = (endDateString.length()==0?new Date():df.parse(endDateString));
                    //String newDateString = df.format(startDate);
                    if(currentDate.before(startDate) || currentDate.after(endDate)) continue;
                } catch (ParseException e) {
                    e.printStackTrace();
                }

                String visibleTo = parseNull(map.get("visibleTo"));
                if(visibleTo.length() == 0) visibleTo = "all";

                if(logged){
                    price = parseNull(map.get("price"));
                    if(visibleTo.equals("logged")) break;
                }
                else if(visibleTo.equals("all")){ // for the Not Logged
                    price = parseNull(map.get("price"));
                }
            }

            if(price.length() == 0) return "";
            else{
                double price_before_tax = Double.parseDouble(price); // can include tax at this point depending on the flag.
                if(taxpercentage.input_with_tax){
                    price_before_tax = price_before_tax / (1 + (taxpercentage.tax/100)); // formula to remove tax
                }
                
		//very first is slot discount to be applied
                if(slot_discount_value!=0){
                    if(slot_discount_type.equalsIgnoreCase("fixed")){
                        price_before_tax -= slot_discount_value;
                    }
                    else{
                        price_before_tax -= (price_before_tax*slot_discount_value/100);
                    }
                }
                double diff = 0;
                if(price_diff!=null){
                    for(String s : price_diff){
                        if(s.charAt(0) == '%'){
                            s = s.substring(1);
                            diff += (price_before_tax*Double.parseDouble(s)/100);
                        }
                        else{
                            diff += Double.parseDouble(s);
                        }
                        //System.out.println(diff+"asad");
                    }
                }

		//first we should calculate price before tax for a single item then multiple with quantity
//                double price_before_tax = (Double.parseDouble(price) + diff)*quantity;
                price_before_tax += diff;
                
                if(productDiscount!=0){
                    if(productDiscountType.equalsIgnoreCase("fixed")){
                        price_before_tax -= productDiscount;
                    }
                    else{
                        price_before_tax -= (price_before_tax*productDiscount/100);
                    }
                }

                if(catalogDiscount!=0){
                    if(catalogDiscountType.equalsIgnoreCase("fixed")){
                        price_before_tax -= catalogDiscount;
                    }
                    else{
                        price_before_tax -= (price_before_tax*catalogDiscount/100);
                    }
                }
                
                if(overallDiscount!=0){
                    if(overallDiscountType.equalsIgnoreCase("fixed")){
                        price_before_tax -= overallDiscount;
                    }
                    else{
                        price_before_tax -= (price_before_tax*overallDiscount/100);
                    }
                }

		price_before_tax = price_before_tax*quantity;

		  //bundle discounts are applicable on bundle so we multiple with quantity before applying bundle discounts
                String bundle_diff = "";

              if(bundle_prices.length() > 0)
		{
                    List<Object> bundle_list = gson.fromJson(bundle_prices, type);
                    for(int i=0;i<bundle_list.size();i++){
                        Map<String,String> bundle_map = (Map)bundle_list.get(i);
                        if(quantity >= Integer.parseInt(parseNull(bundle_map.get("amount")))) {
                            bundle_diff = parseNull(bundle_map.get("discount"));
                        }
                    }
                }

                if(bundle_diff.length() > 0){
                    if(bundle_diff.charAt(0) == '%'){
                        bundle_diff = bundle_diff.substring(1);
                        //System.out.println(bundle_diff+" "+price_before_tax);
                        price_before_tax += (price_before_tax*Double.parseDouble(bundle_diff)/100);
                        
                        //System.out.println(bundle_diff+" "+price_before_tax);
                    }
                    else{
                        //System.out.println(bundle_diff+"else");
                        price_before_tax += Double.parseDouble(bundle_diff);
                    }
                }

                if(price_before_tax < 0) price_before_tax = 0;
                
                if(taxpercentage.output_with_tax) price = (price_before_tax + (price_before_tax*taxpercentage.tax/100))+"";
                else price = price_before_tax+""; 

            } 
            return price;
        }

        String getSimplePrice(String price, TaxPercentage taxpercentage, int quantity){
            if(price.length() == 0) return "";
            else{

                double price_before_tax = (Double.parseDouble(price));
                if(taxpercentage.input_with_tax) price_before_tax = price_before_tax / (1 + (taxpercentage.tax/100));

                if(taxpercentage.output_with_tax) price = (price_before_tax + (price_before_tax*taxpercentage.tax/100))*quantity+"";
                else price = price_before_tax*quantity+"";      
                
                //price = (price_before_tax + (price_before_tax*Double.parseDouble(taxpercentage)/100))+"";

            } 
            return price;
        }

        String getSimplePrice(String price, String recurring_price, TaxPercentage taxpercentage, int quantity){
            if(price.length() == 0) return "";
            else{

                double price_before_tax = (Double.parseDouble(price)+Double.parseDouble(recurring_price));
                if(taxpercentage.input_with_tax) price_before_tax = price_before_tax / (1 + (taxpercentage.tax/100));

                if(taxpercentage.output_with_tax) price = (price_before_tax + (price_before_tax*taxpercentage.tax/100))*quantity+"";
                else price = price_before_tax*quantity+"";   
                
                //price = (price_before_tax + (price_before_tax*Double.parseDouble(taxpercentage)/100))+"";

            } 
            return price;
        }

	boolean isPromotion(String json, boolean logged)
	{
		if(parseNull(json).length() == 0) return false;
                Gson gson = new Gson();
                Type type = new TypeToken<List<Object>>(){}.getType();
                List<Object> list = gson.fromJson(json, type);
                String price = "";

                for(int i=0;i<list.size();i++){
                    Map<String,String> map = (Map)list.get(i);

                    String startDateString = parseNull(map.get("startDate"));
                    String endDateString = parseNull(map.get("endDate"));                    
                    
                    DateFormat df = new SimpleDateFormat("yyyy-MM-dd"); 
                    Date startDate;
                    Date endDate;
                    Date currentDate = new Date();
                    try {
                        startDate = (startDateString.length()==0?new Date():df.parse(startDateString));
                        endDate = (endDateString.length()==0?new Date():df.parse(endDateString));
                        //String newDateString = df.format(startDate);
                        if(currentDate.before(startDate) || currentDate.after(endDate)) continue;
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                    
                    String visibleTo = parseNull(map.get("visibleTo"));
                    if(visibleTo.length() == 0) visibleTo = "all";

                    if(logged){
                        price = parseNull(map.get("price"));
			   if(visibleTo.equals("logged")) break;
                    }
                    else if(visibleTo.equals("all")){ // for the Not Logged
                        price = parseNull(map.get("price"));
                    }
                }
                if(price.length() == 0) return false;
                else return true;
	}

	boolean showPromotionBanner(String json, boolean logged)
	{
		if(parseNull(json).length() == 0) return false;
                Gson gson = new Gson();
                Type type = new TypeToken<List<Object>>(){}.getType();
                List<Object> list = gson.fromJson(json, type);
                String price = ""; // price here means PROMO!

                boolean loggedSelected = false;

                for(int i=0;i<list.size();i++){
                    Map<String,String> map = (Map)list.get(i);

                    String startDateString = parseNull(map.get("startDate"));
                    String endDateString = parseNull(map.get("endDate"));                    
                    
                    DateFormat df = new SimpleDateFormat("yyyy-MM-dd"); 
                    Date startDate;
                    Date endDate;
                    Date currentDate = new Date();
                    try {
                        startDate = (startDateString.length()==0?new Date():df.parse(startDateString));
                        endDate = (endDateString.length()==0?new Date():df.parse(endDateString));
                        //String newDateString = df.format(startDate);
                        if(currentDate.before(startDate) || currentDate.after(endDate)) continue;
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }

                    String visibleTo = parseNull(map.get("visibleTo"));
                    if(visibleTo.length() == 0) visibleTo = "all";

                    if(logged){
                        price = parseNull(map.get("showUiBanner"));
                        if(visibleTo.equals("logged")) break;
                    }
                    else if(visibleTo.equals("all")){ // for the Not Logged
                        price = parseNull(map.get("showUiBanner"));
                    }
                }
                if(price.equals("1")) return true;
                else return false;
	}

        boolean isInstallment(String json)
	{   
		if(parseNull(json).length() == 0) return false;
                Gson gson = new Gson();
                Type type = new TypeToken<List<Object>>(){}.getType();
                List<Object> list = gson.fromJson(json, type);
                if(list.size()>0) return true;
                else return false;
	}

	String getFirstInstallmentPrice(String json, TaxPercentage taxpercentage)
	{
		if(parseNull(json).length() == 0) return "";
                Gson gson = new Gson();
                Type type = new TypeToken<List<Object>>(){}.getType();
                List<Object> list = gson.fromJson(json, type);
                String price = "";
                for(int i=0;i<list.size();i++){
                    Map<String,String> map = (Map)list.get(i);
                    price = getSimplePrice(parseNull(map.get("installmentAmount")), taxpercentage, 1);
                    return price;
                }
                return "";
	}

        

	Map<String,String> getLowestInstallmentMap(String json, TaxPercentage taxpercentage)
	{
            if(parseNull(json).length() == 0) return null;
            Gson gson = new Gson();
            Type type = new TypeToken<List<Object>>(){}.getType();
            List<Object> list = gson.fromJson(json, type);
            Map<String,String> min_map = null;
            double min_price_before_tax = 0;
            for(int i=0;i<list.size();i++){
                Map<String,String> map = (Map)list.get(i);
                String recurring_price = map.get("installmentAmount");
                String discount_recurring_price = parseNull(map.get("discountInstallmentAmount"));
                int discount_duration = parseNullInt(map.get("discountDurationValue"));
                double price_before_tax = 0;
                String price = "";
                String startDateString = parseNull(map.get("discountStartDate"));
                String endDateString = parseNull(map.get("discountEndDate"));                    

                DateFormat df = new SimpleDateFormat("yyyy-MM-dd"); 
                Date startDate;
                Date endDate;
                Date currentDate = new Date();
                try {
                        startDate = (startDateString.length()==0?new Date():df.parse(startDateString));
                        endDate = (endDateString.length()==0?new Date():df.parse(endDateString));
                        //String newDateString = df.format(startDate);

                        if(discount_duration>0 && !(currentDate.before(startDate) || currentDate.after(endDate))){
                            price_before_tax = parseNullDouble(discount_recurring_price);
                            price = getSimplePrice(parseNull(discount_recurring_price), taxpercentage, 1);
                            map.put("calculated_price_type","discounted");
                        }
                        else{
                            price_before_tax = parseNullDouble(recurring_price);
                            price = getSimplePrice(parseNull(recurring_price), taxpercentage, 1);
                            map.put("calculated_price_type","normal");
                        } 
                } catch (ParseException e) {
                        e.printStackTrace();
                }
                map.put("calculated_price",price);
                if(min_map==null){
                        min_price_before_tax = price_before_tax;
                        min_map = map;
                }
                else if(min_price_before_tax > price_before_tax){
                        min_price_before_tax = price_before_tax;
                        min_map = map;
                }
            }//end of for
            return min_map;
	}

        int getInstallmentCount(String json){
            if(parseNull(json).length()==0) return 0;
            Gson gson = new Gson();
            Type type = new TypeToken<List<Object>>(){}.getType();
            List<Object> list = gson.fromJson(json, type);

	     return list.size();
        }

	boolean isNew(com.etn.lang.ResultSet.Set rs)
	{
		if("1".equals(rs.value("is_new"))) return true;
		return false;
	}

//	String getPriceSent(String json)
//	{
//		if(parseNull(json).length() == 0) return "";
//              
//		Gson gson = new Gson();
//              Type type = new TypeToken<List<Object>>(){}.getType();
//		List<Object> list = gson.fromJson(json, type);
//		String ps = "";
//		if(list.size() > 0) ps = parseNull(((Map)list.get(0)).get("priceSent"));
//		return ps;
//	}

//	String getCurrencyFreq(String json)
//	{
//		return parseNull(json);
//	}

//	String getCurrency(String json)
//	{
//		if(parseNull(json).length() == 0) return "";
//              
//		Gson gson = new Gson();
//              Type type = new TypeToken<List<Object>>(){}.getType();
//		List<Object> list = gson.fromJson(json, type);
//		String cf = "";
//		if(list.size() > 0) cf = parseNull(((Map)list.get(0)).get("currency"));
//		return cf;
//	}

        String getTaxString(LinkedHashSet<String> taxHS, HashMap<String, Integer> taxNumbers){
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
        
        String getTaxString2(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, LinkedHashSet<String> taxHS, HashMap<String, Integer> taxNumbers){
            Iterator<String> itr=taxHS.iterator();
            String taxString = "";
            int count = 1;
            while(itr.hasNext()){
                if(taxString.length() > 0) taxString +=", ";
                String tax = itr.next();
                taxString +="("+taxNumbers.get(tax)+") "+ libelle_msg(Etn, request, "Taxe de") + " "+tax+"%";
                count++;
            }
            return taxString;
        }

%>