 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*, com.etn.asimina.util.ActivityLog"%>
<%@ include file="../../../../WEB-INF/include/constants.jsp"%>
<%@ include file="../../../../WEB-INF/include/commonMethod.jsp"%>

<%!


    String randomAlphaNumeric(int count) {

        String alphaNumeric = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder builder = new StringBuilder();

        while (count-- != 0) {

            int character = (int)(Math.random()*alphaNumeric.length());
            builder.append(alphaNumeric.charAt(character));
        }

        return builder.toString();
    }


%>
<%

    String id = parseNull(request.getParameter("id"));
    int promotionId = 0;

    String cols = "";
    String vals = "";
    String name = parseNull(request.getParameter("name"));
    String description = parseNull(request.getParameter("description"));
    String visibleTo = parseNull(request.getParameter("visible_to"));
    String startDate = parseNull(request.getParameter("start_date"));
    String endDate = parseNull(request.getParameter("end_date"));
    int autoGenerateCouponCode = parseInt(request.getParameter("auto_generate_cc"));
    String couponCode = parseNull(request.getParameter("coupon_code"));
    String usesPerCoupon = parseNull(request.getParameter("uses_per_coupon"));
    String usesPerCustomer = parseNull(request.getParameter("uses_per_customer"));
    String couponCodePrefix = parseNull(request.getParameter("coupon_code_prefix"));
    int couponQuantity = parseInt(request.getParameter("coupon_quantity"));
    int couponCodeLength = parseInt(request.getParameter("coupon_code_length"));
    int ruleField = parseInt(request.getParameter("rule_field"));
    String ruleType = parseNull(request.getParameter("rule_type"));
    String verifyCondition = parseNull(request.getParameter("verify_condition"));
    String ruleCondition = parseNull(request.getParameter("rule_condition"));
    String ruleConditionValue = parseNull(request.getParameter("rule_condition_value"));
    String discountType = parseNull(request.getParameter("discount_type"));
    String discountValue = parseNull(request.getParameter("discount_value"));
    String slct_element_on = parseNull(request.getParameter("slct_element_on"));
    String[] elementsOn = request.getParameterValues("element_on");
    String[] elementsOnValue = request.getParameterValues("element_on_value");
	
	//if there are multiple Element Ons coming in request means those are product or skus so we set in parent
	//table element_on to be list in this case
	if(elementsOn != null && elementsOn.length > 0) slct_element_on = "list";
	else if(slct_element_on.equals("cart_total") == false && slct_element_on.equals("shipping_fee") == false)
	{
		//from front end its coming product or sku in this field so it will become list
		slct_element_on = "list";
	}
	if(slct_element_on.length() == 0) slct_element_on = "cart_total";

    String selectedsiteid = parseNull(getSelectedSiteId(session));

    if(startDate.length() > 0){

        if(startDate.contains(" ")){

            String[] token = startDate.split(" ");
            startDate = convertDateToStandardFormat(token[0], "yyyy/MM/dd") + " " + token[1];

        }else{

            startDate = convertDateToStandardFormat(startDate, "yyyy/MM/dd");
        }

    }

    if(endDate.length() > 0){

        if(endDate.contains(" ")){

            String[] token = endDate.split(" ");
            endDate = convertDateToStandardFormat(token[0], "yyyy/MM/dd") + " " + token[1];

        }else{

            endDate = convertDateToStandardFormat(endDate, "yyyy/MM/dd");
        }

    }
	
	String extUrl = parseNull(com.etn.beans.app.GlobalParm.getParm("CATALOG_EXTERNAL_URL"));
    String params = "?";
	
	if(couponCode.length() > 0)
	{
		String q = "Select c.* from cart_promotion_coupon cp join cart_promotion c on c.id = cp.cp_id where cp.coupon_code = "+escape.cote(couponCode);
		if(id.length() > 0) q += " and cp.cp_id <> " + escape.cote(id);

		Set rsq = Etn.execute(q);
		if(rsq.rs.Rows > 0)
		{
			params += "errmsg=coupon code must be unique";
			if(extUrl.length() == 0) response.sendRedirect("promotions.jsp"+params);
			else response.sendRedirect(extUrl + "admin/catalogs/commercialoffers/cartrules/promotions.jsp"+params);
			return;
		}
	}

    if(id.length() == 0)
    {
        cols = "site_id, created_by, name, description, visible_to, start_date, end_date, auto_generate_cc, uses_per_coupon, uses_per_customer, coupon_quantity, cc_length, cc_prefix, rule_field, rule_type, verify_condition, rule_condition, rule_condition_value, discount_type, discount_value, element_on ";

        vals = escape.cote(selectedsiteid) + "," + escape.cote(""+Etn.getId());

        if(name.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(name);

        if(description.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(description);

        if(visibleTo.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(visibleTo);

        if(startDate.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(startDate);

        if(endDate.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(endDate);

        vals += ", " + escape.cote(autoGenerateCouponCode+"");

        if(usesPerCoupon.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(usesPerCoupon);

        if(usesPerCustomer.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(usesPerCustomer);

        if((""+couponQuantity).length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(""+couponQuantity);

        if((""+couponCodeLength).length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(""+couponCodeLength);

        if(couponCodePrefix.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(couponCodePrefix);

        vals += ", " + escape.cote(ruleField+"");

        if(ruleType.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(ruleType);

        if(verifyCondition.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(verifyCondition);

        if(ruleCondition.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(ruleCondition);

        if(ruleConditionValue.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(ruleConditionValue);

        if(discountType.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(discountType);

        if(discountValue.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(discountValue);

        if(slct_element_on.length() == 0) vals += ", NULL";
        else vals += ", " + escape.cote(slct_element_on);

        promotionId = Etn.executeCmd("INSERT INTO cart_promotion(" + cols + ") VALUES (" + vals + ")");

        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),promotionId+"","CREATED","Cart Rule",parseNull(request.getParameter("name")),selectedsiteid);


    }
    else
    {
        String q = "update cart_promotion set version = version + 1, updated_on = now(), updated_by = " + escape.cote(""+Etn.getId());

        if(name.length() == 0) q += ", name = NULL";
        else q += ", name = " + escape.cote(name);

        if(description.length() == 0) q += ", description = NULL";
        else q += ", description = " + escape.cote(description);

        if(visibleTo.length() == 0) q += ", visible_to = NULL";
        else q += ", visible_to = " + escape.cote(visibleTo);

        if(startDate.length() == 0) q += ", start_date = NULL";
        else q += ", start_date = " + escape.cote(startDate);

        if(endDate.length() == 0) q += ", end_date = NULL";
        else q += ", end_date = " + escape.cote(endDate);

        q += ", auto_generate_cc = " + escape.cote(autoGenerateCouponCode+"");

        if(usesPerCoupon.length() == 0) q += ", uses_per_coupon = NULL";
        else q += ", uses_per_coupon = " + escape.cote(usesPerCoupon);

        if(usesPerCustomer.length() == 0) q += ", uses_per_customer = NULL";
        else q += ", uses_per_customer = " + escape.cote(usesPerCustomer);

        if((""+couponQuantity).length() == 0) q += ", coupon_quantity = NULL";
        else q += ", coupon_quantity = " + escape.cote(""+couponQuantity);

        if((""+couponCodeLength).length() == 0) q += ", cc_length = NULL";
        else q += ", cc_length = " + escape.cote(""+couponCodeLength);

        if(couponCodePrefix.length() == 0) q += ", cc_prefix = NULL";
        else q += ", cc_prefix = " + escape.cote(couponCodePrefix);

        q += ", rule_field = " + escape.cote(ruleField+"");

        if(ruleType.length() == 0) q += ", rule_type = NULL";
        else q += ", rule_type = " + escape.cote(ruleType);

        if(verifyCondition.length() == 0) q += ", verify_condition = NULL";
        else q += ", verify_condition = " + escape.cote(verifyCondition);

        if(ruleCondition.length() == 0) q += ", rule_condition = NULL";
        else q += ", rule_condition = " + escape.cote(ruleCondition);

        if(ruleConditionValue.length() == 0) q += ", rule_condition_value = NULL";
        else q += ", rule_condition_value = " + escape.cote(ruleConditionValue);

        if(discountType.length() == 0) q += ", discount_type = NULL";
        else q += ", discount_type = " + escape.cote(discountType);

        if(discountValue.length() == 0) q += ", discount_value = NULL";
        else q += ", discount_value = " + escape.cote(discountValue);

        if(slct_element_on.length() == 0) q += ", element_on = 'cart_total' ";
        else q += ", element_on = " + escape.cote(slct_element_on);

        q += " where id = " + escape.cote(id);

        Etn.executeCmd(q);
        promotionId = parseInt(id);

        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),promotionId+"","UPDATED","Cart Rule",parseNull(request.getParameter("name")),selectedsiteid);

    }

    if(promotionId > 0){

        Set rsCoupon = Etn.execute("SELECT * FROM cart_promotion_coupon WHERE cp_id = " + escape.cote(""+promotionId));

        if(rsCoupon.rs.Rows == 0){

            if(autoGenerateCouponCode == 0){

                cols = "cp_id, coupon_code";
                vals = escape.cote("" + promotionId);

                if(couponCode.length() == 0) vals += ", NULL";
                else vals += ", " + escape.cote(couponCode);

                Etn.executeCmd("INSERT INTO cart_promotion_coupon(" + cols + ") VALUES (" + vals + ")");

            } else if(autoGenerateCouponCode == 1){

                int count = 0;
                String randomCoupon = "";
                for(int i=0; i < couponQuantity; i++){

                    count = couponCodeLength-parseInt(couponCodePrefix.length());
                    randomCoupon = couponCodePrefix + randomAlphaNumeric(count);
                    Etn.executeCmd("INSERT INTO cart_promotion_coupon(cp_id, coupon_code) VALUES (" + escape.cote(""+promotionId) + "," + escape.cote(randomCoupon) + ")");
                }
            }
        }
		
		Etn.executeCmd("delete from cart_promotion_on_elements where cart_promo_id = "+escape.cote(""+promotionId));
		
		if(elementsOn != null)
		{
			for(int s=0;s<elementsOn.length;s++)
			{
				if(parseNull(elementsOn[s]).length() > 0 && parseNull(elementsOnValue[s]).length() > 0)
				{
					Etn.executeCmd("insert into cart_promotion_on_elements (cart_promo_id, element_on, element_on_value) value ("+escape.cote(""+promotionId)+", "+escape.cote(parseNull(elementsOn[s]))+", "+escape.cote(parseNull(elementsOnValue[s]))+")");
				}
			}
		}
		
    }

    if(id.length() == 0) params += "is_save=";
    else params += "is_edit=";

    if(promotionId > 0) params += "1";

    if(extUrl.length() == 0) response.sendRedirect("promotions.jsp"+params);
    else response.sendRedirect(extUrl + "admin/catalogs/commercialoffers/cartrules/promotions.jsp"+params);

%>