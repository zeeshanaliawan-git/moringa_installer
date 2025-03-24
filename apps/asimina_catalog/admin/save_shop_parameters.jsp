<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*, com.etn.asimina.util.ActivityLog, org.json.* "%>
<%@ include file="../../WEB-INF/include/constants.jsp"%>
<%@ include file="../../WEB-INF/include/commonMethod.jsp"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.Date , java.net.URLEncoder , java.nio.charset.StandardCharsets" %>
<%
    String requestType = parseNull(request.getParameter("requestType"));
    if(!requestType.isEmpty()){
        if(requestType.equals("searchData")){
            String msg = "";
            int status = 1;
            JSONArray rspAry = new JSONArray();

            try{
                String searchType = parseNull(request.getParameter("selectValue"));
                String searchValue = parseNull(request.getParameter("inputValue"));
                String selectedsiteid = getSelectedSiteId(session);

                String query="";
    
                if(searchType.equals("sku")){
                    query = "select distinct pv.sku as id, pv.sku as name from product_variants pv join products p on pv.product_id=p.id join catalogs c on c.id=p.catalog_id where p.product_version='V2' and pv.sku like "+
                        escape.cote("%"+searchValue+"%")+" and c.site_id="+escape.cote(selectedsiteid);

                }else if(searchType.equals("product_name")){
                    query = "select distinct name as id, name from products_definition where name like "+escape.cote("%"+searchValue+"%")+" and site_id="+escape.cote(selectedsiteid);

                }else if(searchType.equals("product_type")){
                    query = "select id, type_name as name from product_types_v2 where type_name like "+escape.cote("%"+searchValue+"%")+" and site_id="+escape.cote(selectedsiteid);

                }else if(searchType.equals("manufacturer")){
                    query = "select distinct p.brand_name as id, p.brand_name as name from products p join catalogs c on p.catalog_id=c.id where p.product_version='V2' and p.brand_name like "+
                        escape.cote("%"+searchValue+"%")+" and c.site_id="+escape.cote(selectedsiteid);

                }else if(searchType.equals("tag")){
                    query = "select id,label as name from tags where label like "+escape.cote("%"+searchValue+"%")+" and site_id="+escape.cote(selectedsiteid);

                }else if(searchType.equals("folder")){
                    query = "select id,name from products_folders where name like "+escape.cote("%"+searchValue+"%")+
                        " and catalog_id=(select id from catalogs where name='Root Catalog' and catalog_version='V2' and site_id="+escape.cote(selectedsiteid)+")";

                }
                Set rs = Etn.execute(query);
                
                while(rs.next()){
                    JSONObject rspObj = new JSONObject();
                    rspObj.put("id",rs.value("id"));
                    rspObj.put("label",rs.value("name"));

                    rspAry.put(rspObj);
                }
            }catch(Exception e){
                e.printStackTrace();
                status = 0;
                msg = e.getMessage();
            }

            JSONObject rsp = new JSONObject();
            rsp.put("data",rspAry);
            rsp.put("status",status);
            rsp.put("message",msg);

            out.write(rsp.toString());
        }
    }else{
        String siteid = parseNull(request.getParameter("id"));
        String msg = ""; 
        ArrayList<String> ignorecols = new ArrayList<String>();
        ignorecols.add("id");
        ignorecols.add("sb_ios_icon");
        ignorecols.add("sb_android_icon");
        ignorecols.add("code");
        ignorecols.add("sb_icon_type");
        ignorecols.add("LANGUE_1");
        ignorecols.add("LANGUE_2");
        ignorecols.add("LANGUE_3");
        ignorecols.add("LANGUE_4");
        ignorecols.add("LANGUE_5");
        ignorecols.add("payment_method");
        ignorecols.add("payment_method_displayName");
        ignorecols.add("payment_method_price");
        ignorecols.add("payment_method_enable");
        ignorecols.add("payment_method_helpText");
        ignorecols.add("payment_method_subText");
        ignorecols.add("payment_method_order");
        ignorecols.add("delivery_method");
        ignorecols.add("delivery_method_displayName");
        ignorecols.add("delivery_method_price");
        ignorecols.add("delivery_method_enable");
        ignorecols.add("delivery_method_helpText");
        ignorecols.add("delivery_method_subType");
        ignorecols.add("delivery_method_mapsDisplay");
        ignorecols.add("delivery_method_order");
        ignorecols.add("fraud_rule_cart_type");
        ignorecols.add("fraud_rule_column");
        ignorecols.add("fraud_rule_day");
        ignorecols.add("fraud_rule_limit");
        ignorecols.add("fraud_rule_enable");
        ignorecols.add("fraud_rule_delete");
        ignorecols.add("fraud_rule_cart_type_new");
        ignorecols.add("fraud_rule_column_new");
        ignorecols.add("fraud_rule_day_new");
        ignorecols.add("fraud_rule_limit_new");
        ignorecols.add("fraud_rule_enable_new");
        // -------------- added 4 cols by hamza
        ignorecols.add("currencyPositions");
        ignorecols.add("priceformatters");
        ignorecols.add("rountodecimals");
        ignorecols.add("showdecimals");

        //------- ignore sticker data
        ignorecols.add("priority");
        ignorecols.add("sname");
        ignorecols.add("DISPLAY_NAME_1");
        ignorecols.add("DISPLAY_NAME_2");
        ignorecols.add("DISPLAY_NAME_3");
        ignorecols.add("DISPLAY_NAME_4");
        ignorecols.add("DISPLAY_NAME_5");
        ignorecols.add("color");

        ignorecols.add("calledfrom");
        //ignore url opentype as its not required
        ignorecols.add("lang_1_continue_shop_url_opentype");
        ignorecols.add("lang_2_continue_shop_url_opentype");
        ignorecols.add("lang_3_continue_shop_url_opentype");
        ignorecols.add("lang_4_continue_shop_url_opentype");
        ignorecols.add("lang_5_continue_shop_url_opentype");

        ignorecols.add("inventory_email_test");
        ignorecols.add("inventory_email_prod");

        //---------- Ignore holidays columns----------

        ignorecols.add("holiday_name");
        ignorecols.add("start_date");
        ignorecols.add("end_date");
        ignorecols.add("language_id");

        //---------- Ignore Excluded Products columns----------

        ignorecols.add("delivery_method_unique_id");
        ignorecols.add("delivery_method_unique_id_type");
        ignorecols.add("delivery_method_excludedType");
        ignorecols.add("delivery_method_excludedItem");
        ignorecols.add("delivery_excluded_product_type");
        ignorecols.add("delivery_excluded_product_value");
        ignorecols.add("excluded_delivery_method");
        ignorecols.add("excluded_delivery_method_sub");

        ignorecols.add("payment_method_unique_id");
        ignorecols.add("payment_method_excludedType");
        ignorecols.add("payment_method_excludedItem");
        ignorecols.add("excluded_product_type");
        ignorecols.add("excluded_product_value");
        ignorecols.add("excluded_payment_method");


        //---------- Ignore Delivery Solts----------
        for (int day = 0; day < 7; day++) {
            String startHourColumnName = "start_hour_" + day + "_" + request.getParameter("language_id");
            String startMinutesColumnName = "start_minutes_" + day + "_" + request.getParameter("language_id");
            String endHourColumnName = "end_hour_" + day + "_" + request.getParameter("language_id");
            String endMinutesColumnName = "end_minutes_" + day + "_" + request.getParameter("language_id");
                
            // Add the column names to the set
            ignorecols.add(startHourColumnName);
            ignorecols.add(startMinutesColumnName);
            ignorecols.add(endHourColumnName);
            ignorecols.add(endMinutesColumnName);
        }
    
        String inventoryQry = "insert into "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".inventory_mail (site_id,email_test,email_prod) values("+escape.cote(siteid)+","+escape.cote(parseNull(request.getParameter("inventory_email_test")))+","+escape.cote(parseNull(request.getParameter("inventory_email_prod")))+") ";
        inventoryQry += "ON DUPLICATE KEY UPDATE ";
        inventoryQry += "email_test = VALUES(email_test),";
        inventoryQry += "email_prod = VALUES(email_prod);";
        int inventoryId = Etn.executeCmd(inventoryQry);

        Set _rs = Etn.execute("Select * from shop_parameters where site_id = " + escape.cote(siteid));

        if(_rs.rs.Rows == 0){
            String cols = "site_id, updated_by,updated_on";
            String vals = escape.cote(siteid) + "," + escape.cote(""+Etn.getId())+",now()";
            for(String parameter : request.getParameterMap().keySet())
            {
                if(ignorecols.contains(parameter)) continue;
                cols += "," + parameter;
                            if(parameter.equals("installment_duration_units")) {
                                String[] installment_duration_units = request.getParameterValues(parameter);
                                String temp_unit = "";
                                for(String unit : installment_duration_units) temp_unit+=(temp_unit.equals("")?"":",")+unit;
                                vals += "," + escape.cote(temp_unit);
                            }
                            else vals += "," + escape.cote(request.getParameter(parameter));
            }
            siteid = "" + Etn.executeCmd("insert into shop_parameters ("+cols+") values ("+vals+")");

        } else {
            String q = "update shop_parameters set updated_on = now(), updated_by = " + escape.cote(""+Etn.getId());
            for(String parameter : request.getParameterMap().keySet())
            {
                if(ignorecols.contains(parameter)) continue;
                q += ", " + parameter + " = ";
                            //q += escape.cote(request.getParameter(parameter));
                            if(parameter.equals("installment_duration_units")) {
                                String[] installment_duration_units = request.getParameterValues(parameter);
                                String temp_unit = "";
                                for(String unit : installment_duration_units) temp_unit+=(temp_unit.equals("")?"":",")+unit;
                                q += escape.cote(temp_unit);

                            }
                            else q += escape.cote(request.getParameter(parameter));
            }
            q += " where site_id = " + escape.cote(siteid);
            Etn.executeCmd(q);
        }

        if(request.getParameter("lang_1_currency")!=null) Etn.executeCmd("insert into langue_msg (LANGUE_REF, LANGUE_1, LANGUE_2, LANGUE_3, LANGUE_4, LANGUE_5) values ("+escape.cote(request.getParameter("lang_1_currency"))+","+escape.cote(request.getParameter("LANGUE_1"))
            +","+escape.cote(request.getParameter("LANGUE_2"))+","+escape.cote(request.getParameter("LANGUE_3"))+","+escape.cote(request.getParameter("LANGUE_4"))+","+escape.cote(request.getParameter("LANGUE_5"))
            +") on duplicate key update LANGUE_REF=VALUES(LANGUE_REF), LANGUE_1=VALUES(LANGUE_1), LANGUE_2=VALUES(LANGUE_2), LANGUE_3=VALUES(LANGUE_3), LANGUE_4=VALUES(LANGUE_4), LANGUE_5=VALUES(LANGUE_5)");


        //-------------------------------- Payment Methods-------------------------//

        String[] payment_methods = request.getParameterValues("payment_method");
        String[] payment_method_displayNames = request.getParameterValues("payment_method_displayName");
        String[] payment_method_prices = request.getParameterValues("payment_method_price");
        String[] payment_method_enables = request.getParameterValues("payment_method_enable");
        String[] payment_method_helpTexts = request.getParameterValues("payment_method_helpText");
        String[] payment_method_subTexts = request.getParameterValues("payment_method_subText");
        String[] payment_method_orders = request.getParameterValues("payment_method_order");

        String[] excluded_product_type = request.getParameterValues("excluded_product_type");
        String[] excluded_product_value = request.getParameterValues("excluded_product_value");
        String[] excluded_payment_method = request.getParameterValues("excluded_payment_method");
		
        if(null != payment_methods){
            for(int i=0; i<payment_methods.length; i++){
                if(payment_methods[i].trim().length() > 0){
                    Etn.executeCmd("update payment_methods set displayName="+escape.cote(payment_method_displayNames[i])+", price="+escape.cote(payment_method_prices[i])+
                        ", enable="+escape.cote(payment_method_enables[i])+", helpText="+escape.cote(payment_method_helpTexts[i])+", subText="+escape.cote(payment_method_subTexts[i])+
                        ", orderSeq="+escape.cote(payment_method_orders[i])+" where site_id = "+escape.cote(siteid)+" and method="+escape.cote(payment_methods[i]));
                }
            }

            Etn.executeCmd("delete from payment_n_delivery_method_excluded_items where method_type='payment' and site_id="+escape.cote(siteid));
			if(excluded_payment_method != null)
			{
				for(int i=0; i<excluded_payment_method.length; i++){
					if(excluded_payment_method[i].trim().length() > 0){
						Etn.executeCmd("insert ignore into payment_n_delivery_method_excluded_items (item_type,item_id,method,site_id,method_type) values ("+
							escape.cote(excluded_product_type[i])+","+escape.cote(excluded_product_value[i])+","+escape.cote(excluded_payment_method[i])+","+
							escape.cote(siteid)+",'payment')");
					}
				}
			}
        }

        //-------------------------------- Delivery Methods-------------------------//
        String[] delivery_methods = request.getParameterValues("delivery_method");
        String[] delivery_method_displayNames = request.getParameterValues("delivery_method_displayName");
        String[] delivery_method_prices = request.getParameterValues("delivery_method_price");
        String[] delivery_method_enables = request.getParameterValues("delivery_method_enable");
        String[] delivery_method_subTypes = request.getParameterValues("delivery_method_subType");
        String[] delivery_method_mapsDisplays = request.getParameterValues("delivery_method_mapsDisplay");
        String[] delivery_method_helpTexts = request.getParameterValues("delivery_method_helpText");
        String[] delivery_method_orders = request.getParameterValues("delivery_method_order");

        String[] delivery_excluded_product_type = request.getParameterValues("delivery_excluded_product_type");
        String[] delivery_excluded_product_value = request.getParameterValues("delivery_excluded_product_value");
        String[] delivery_excluded_payment_method = request.getParameterValues("excluded_delivery_method");
        String[] excluded_delivery_method_sub = request.getParameterValues("excluded_delivery_method_sub");

        try {
            if(null != delivery_methods){
                Etn.executeCmd("delete from delivery_methods where site_id="+escape.cote(siteid));
                for(int i=0; i<delivery_methods.length; i++){
                    if(delivery_methods[i].trim().length() > 0){
                        Etn.executeCmd("insert into delivery_methods set site_id = "+escape.cote(siteid)+", method="+escape.cote(parseNull(delivery_methods[i]))+", displayName="+escape.cote(parseNull(delivery_method_displayNames[i]))+", price="+escape.cote(parseNull(delivery_method_prices[i]))+", enable="+escape.cote(parseNull(delivery_method_enables[i]))+", helpText="+escape.cote(parseNull(delivery_method_helpTexts[i]))+", mapsDisplay="+escape.cote(parseNull(delivery_method_mapsDisplays[i]))+", subType="+escape.cote(parseNull(delivery_method_subTypes[i]))+", orderSeq="+escape.cote(parseNull(delivery_method_orders[i]))
                            +" on duplicate key update displayName=VALUES(displayName), price=VALUES(price), enable=VALUES(enable), helpText=VALUES(helpText), mapsDisplay=VALUES(mapsDisplay), orderSeq=VALUES(orderSeq)");
                    }
                }
                Etn.executeCmd("delete from payment_n_delivery_method_excluded_items where method_type='delivery' and site_id="+escape.cote(siteid));
                for(int i=0; i<delivery_excluded_payment_method.length; i++){
                    if(delivery_excluded_payment_method[i].trim().length() > 0){
                        Etn.executeCmd("insert ignore into payment_n_delivery_method_excluded_items (item_type,item_id,method,site_id,method_type,method_sub_type) values ("+
                            escape.cote(delivery_excluded_product_type[i])+","+escape.cote(delivery_excluded_product_value[i])+","+escape.cote(delivery_excluded_payment_method[i])+
                            ","+escape.cote(siteid)+",'delivery',"+escape.cote(parseNull(excluded_delivery_method_sub[i]))+")");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        //-------------------------------- Fraud Rules-------------------------//

        String[] fraud_rule_cart_types = request.getParameterValues("fraud_rule_cart_type");
        String[] fraud_rule_columns = request.getParameterValues("fraud_rule_column");
        String[] fraud_rule_days = request.getParameterValues("fraud_rule_day");
        String[] fraud_rule_limits = request.getParameterValues("fraud_rule_limit");
        String[] fraud_rule_enables = request.getParameterValues("fraud_rule_enable");
        String[] fraud_rule_deletes = request.getParameterValues("fraud_rule_delete");
        if(null != fraud_rule_columns){
            for(int i=0; i<fraud_rule_columns.length; i++){
                if(fraud_rule_deletes[i].equals("0")){
                    Etn.executeCmd("update fraud_rules set `limit`="+escape.cote(fraud_rule_limits[i])+", `enable`="+escape.cote(fraud_rule_enables[i])+" where site_id = "+escape.cote(siteid)+" and cart_type = "+escape.cote(fraud_rule_cart_types[i])+" and  `column`="+escape.cote(fraud_rule_columns[i])+" and days="+escape.cote(fraud_rule_days[i])+" ");
                } else{
                    Etn.executeCmd("delete from fraud_rules where site_id = "+escape.cote(siteid)+" and cart_type = "+escape.cote(fraud_rule_cart_types[i])+" and `column`="+escape.cote(fraud_rule_columns[i])+" and days="+escape.cote(fraud_rule_days[i])+" ");
                }
            }
        }

        String[] fraud_rule_cart_types_new = request.getParameterValues("fraud_rule_cart_type_new");
        String[] fraud_rule_columns_new = request.getParameterValues("fraud_rule_column_new");
        String[] fraud_rule_days_new = request.getParameterValues("fraud_rule_day_new");
        String[] fraud_rule_limits_new = request.getParameterValues("fraud_rule_limit_new");
        String[] fraud_rule_enables_new = request.getParameterValues("fraud_rule_enable_new");
        if(null != fraud_rule_columns_new){
            for(int i=0; i<fraud_rule_columns_new.length; i++){
                if(fraud_rule_cart_types_new[i].trim().length() > 0 && fraud_rule_columns_new[i].trim().length() > 0 && fraud_rule_days_new[i].trim().length() > 0 && fraud_rule_limits_new[i].trim().length() > 0)
                {
                    try{
                        Integer queryResponse = Etn.executeCmd("insert into fraud_rules set site_id = "+escape.cote(siteid)+", cart_type = "+escape.cote(fraud_rule_cart_types_new[i])+", `limit`="+escape.cote(fraud_rule_limits_new[i])+", `enable`="+escape.cote(fraud_rule_enables_new[i])+", `column`="+escape.cote(fraud_rule_columns_new[i])+", days="+escape.cote(fraud_rule_days_new[i]));
                        if(queryResponse < 0 ) msg = "Duplicate Record! Please change the value to create this rule.";
                    }catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }


        //-------------------------------- Home Delivery Slots ---------------------//
        
        try{
            Etn.executeCmd("delete from "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".delivery_slots where site_id="+escape.cote(siteid));
            for (int day = 0; day <= 6; day++) {
                String[] startHourArray = request.getParameterValues("start_hour_" + day + "_"+request.getParameter("language_id"));
                String[] startMinuteArray = request.getParameterValues("start_minutes_" + day + "_"+request.getParameter("language_id"));
                String[] endHourArray = request.getParameterValues("end_hour_" + day + "_"+request.getParameter("language_id"));
                String[] endMinuteArray = request.getParameterValues("end_minutes_" + day + "_"+request.getParameter("language_id"));
                
                    if (startHourArray != null) {
                        for (int i = 0; i < startHourArray.length; i++) {
                            int dsRs = Etn.executeCmd( "insert into "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".delivery_slots set site_id = "+escape.cote(siteid)+", n_day = "+escape.cote(day+"")+", start_hour = "+escape.cote(startHourArray[i])+", start_min = "+escape.cote(startMinuteArray[i])+", end_hour="+escape.cote(endHourArray[i])+", end_min="+escape.cote(endMinuteArray[i])+", create_by = "+escape.cote(""+Etn.getId())+" ");
                            if(dsRs < 0 ){
                                msg = "Duplicate Record! There is already Home Delivery Slot available on this day";
                            }
                        }
                    } 
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        //-------------------------------- Local Holidays ---------------------------------//
            
        try{
            Etn.executeCmd("DELETE FROM " + com.etn.beans.app.GlobalParm.getParm("COMMONS_DB") + ".local_holidays");
            String[] holiday_names = request.getParameterValues("holiday_name");
            String[] start_dates = request.getParameterValues("start_date");
            String[] end_dates = request.getParameterValues("end_date");
            if (holiday_names != null) 
                for (int i = 0; i < holiday_names.length; i++) {
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                    Date startDate = sdf.parse(start_dates[i]);
                    Date endDate = sdf.parse(end_dates[i]);
                    Calendar calendar = Calendar.getInstance();
                    calendar.setTime(startDate);
                    while (!calendar.getTime().after(endDate)) {
                        Date currentDate = calendar.getTime();
                        String formattedDate = sdf.format(currentDate);
                        Integer queryResponse = Etn.executeCmd( "insert into "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".local_holidays set holiday_name = "+escape.cote(holiday_names[i])+", h_date = "+ escape.cote(formattedDate)+" ");
                        if(queryResponse < 0 ) msg = "Duplicate Record! There is already Holiday available on these dates";
                        calendar.add(Calendar.DAY_OF_MONTH, 1);
                    }
                }
        } catch (Exception e) {
            e.printStackTrace();
        }


        //-------------------------------- Stickers data-------------------------//

        String[] priority = request.getParameterValues("priority");
        String[] sName = request.getParameterValues("sname");
        String[] displayName1 = request.getParameterValues("DISPLAY_NAME_1");
        String[] displayName2 = null;
        if(request.getParameterValues("DISPLAY_NAME_2") != null) displayName2 = request.getParameterValues("DISPLAY_NAME_2");
        String[] displayName3 = null;
        if(request.getParameterValues("DISPLAY_NAME_3") != null) displayName3 = request.getParameterValues("DISPLAY_NAME_3");
        String[] displayName4 = null;
        if(request.getParameterValues("DISPLAY_NAME_4") != null) displayName4 = request.getParameterValues("DISPLAY_NAME_4");
        String[] displayName5 = null;
        if(request.getParameterValues("DISPLAY_NAME_5") != null) displayName5 = request.getParameterValues("DISPLAY_NAME_5");
        String[] color = request.getParameterValues("color");

        if(null != sName){

            Etn.execute("delete from stickers where site_id ="+escape.cote(siteid));
            for(int i=0; i<sName.length; i++){

                if(sName[i].trim().length() > 0){

                    String pc = priority[i].trim();
                    if(pc.length() == 0){

                        pc = i+"";
                    }
                    
                    String sd1 = parseNull(displayName1[i]);
                    String sd2 = "";
                    if(displayName2 != null && displayName2.length > 0) sd2 = parseNull(displayName2[i]);
                    String sd3 = "";
                    if(displayName3 != null && displayName3.length > 0) sd3 = parseNull(displayName3[i]);
                    String sd4 = "";
                    if(displayName4 != null && displayName4.length > 0) sd4 = parseNull(displayName4[i]);
                    String sd5 = "";
                    if(displayName5 != null && displayName5.length > 0) sd5 = parseNull(displayName5[i]);

                    Etn.executeCmd("insert into stickers set site_id = " + escape.cote(siteid) + ", priority = " + escape.cote(pc) + 
                    ", sname = " + escape.cote(sName[i].trim()) + ", color = " + escape.cote(color[i].trim()) + 
                    ", display_name_1 = " + escape.cote(sd1) + ", display_name_2 = " + escape.cote(sd2) + 
                    ", display_name_3 = " + escape.cote(sd3) + ", display_name_4 = " + escape.cote(sd4) + ", display_name_5 = " + escape.cote(sd5));
                }
            }
        }

        if(parseNull(request.getParameter("calledfrom")).length() > 0) {
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"","UPDATED","Portal Parameter","",siteid);

            response.sendRedirect(parseNull(request.getParameter("calledfrom")));
        } else {
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"","UPDATED","Shop Parameter","",siteid);
            if(!msg.isEmpty()) {
                String encodedMsg = URLEncoder.encode(msg, StandardCharsets.UTF_8.toString());
                response.sendRedirect("shop_parameters.jsp?errorMessage=" + encodedMsg);
            } else response.sendRedirect("shop_parameters.jsp");
        }
    }
%>
