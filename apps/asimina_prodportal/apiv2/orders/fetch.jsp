<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm,java.time.*,java.time.format.DateTimeFormatter"%>
<%@ page import="org.json.*, java.util.*,java.util.regex.Pattern,java.util.regex.Matcher" %>

<%!
    String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

    boolean dateTimeValidation(String datetime)
    {
        final String time="T00:00:00";
        try{
            LocalDateTime today = LocalDateTime.parse(datetime+time);
        } catch(Exception e)
        {
            return false;
        }
        return true;
    }

    boolean compareStartEndDate(String startDate, String endDate)
    {
        final String time="T00:00:00";
        LocalDateTime startDatetime = LocalDateTime.parse(startDate+time);
        LocalDateTime endDatetime = LocalDateTime.parse(endDate+time);
        if(endDatetime.compareTo(startDatetime)>=0)
            return true;
        return false;
    }

    boolean isValidEmailAddress(String emailAddress)
	{  
		String  expression="^[\\w\\-]([\\.\\w])+[\\w]+@([\\w\\-]+\\.)+[A-Z]{2,4}$";  
		CharSequence inputStr = emailAddress;  
		Pattern pattern = Pattern.compile(expression,Pattern.CASE_INSENSITIVE);  
		Matcher matcher = pattern.matcher(inputStr);  
		return matcher.matches();    
	}  

    boolean isValidPhoneNumber(String phoneNumber){
        String expression = "^((\\+)\\d{2,3}|0)[1-9](\\d{2}){4}$";  
        CharSequence inputStr = phoneNumber;  
		Pattern pattern = Pattern.compile(expression,Pattern.CASE_INSENSITIVE);  
		Matcher matcher = pattern.matcher(inputStr);  
		return matcher.matches();    
    }

    JSONArray getOrders(Set rs)
    {
        List<String> ignoreCols = new ArrayList<String>();	
        ignoreCols.add("parent_uuid");
        ignoreCols.add("order_snapshot");
        ignoreCols.add("menu_uuid");
        ignoreCols.add("payment_token");
        ignoreCols.add("payment_notif_token");
        ignoreCols.add("lastid");
        ignoreCols.add("ip");


        JSONArray orders = new JSONArray();
        while(rs!=null && rs.next())
        {
            JSONObject order=new JSONObject();
            for (String col : rs.ColName){
                if(ignoreCols.contains(col.toLowerCase())) continue;
               
                try{
                    order.put(col,parseNull(rs.value(col)));
                }catch(JSONException e)
                {
                    e.printStackTrace();
                    continue;
                }
            }
            orders.put(order);
        }
        return orders;
    }
%>

<%
    int status = 0;
    String message = "";
    String err_code = "";
    JSONObject json = new JSONObject();
    JSONObject data = new JSONObject();

    final String method = parseNull(request.getMethod());

    if(method.length()> 0 && method.equalsIgnoreCase("GET")){

        final String SHOP_DB = com.etn.beans.app.GlobalParm.getParm("SHOP_DB");
        final String siteUuid = parseNull(request.getHeader("site-uuid"));

        final String email = parseNull(request.getParameter("user_email"));
        final String firstName = parseNull(request.getParameter("first_name"));
        final String lastName = parseNull(request.getParameter("last_name"));
        final String phoneNumber = parseNull(request.getParameter("phone_no"));
        final String postalCode = parseNull(request.getParameter("postal_code"));
        final String orderReference = parseNull(request.getParameter("order_ref"));
        final String city = parseNull(request.getParameter("city"));
        final String startDate = parseNull(request.getParameter("start_date"));
        final String endDate = parseNull(request.getParameter("end_date"));

        
        if( email.length() > 0 || phoneNumber.length() > 0 || postalCode.length() > 0 || city.length() > 0 || orderReference.length() > 0 || firstName.length() > 0 || lastName.length() > 0 || startDate.length() > 0  || endDate.length() > 0){
            String query = "SELECT * FROM "+SHOP_DB+".orders WHERE site_id = (SELECT id FROM sites where suid="+escape.cote(siteUuid)+") AND ";
            String whereClause = "";
            if(email.length() > 0)
                if(isValidEmailAddress(email))
                    whereClause += " email ="+escape.cote(email)+" AND ";
                else
                {
                    status = 20;
                    err_code = "INVALID_ARGUEMENT";
                    message = "Email Address is invalid";
                }
            if(phoneNumber.length() > 0){
                if(isValidPhoneNumber(phoneNumber))
                    whereClause += " contactPhoneNumber1 ="+escape.cote(phoneNumber)+" AND ";
                else{
                    status = 20;
                    err_code = "INVALID_ARGUEMENT";
                    message = "Phone Number is invalid";
                }
            }
            if(firstName.length() > 0)
                whereClause += " name LIKE "+escape.cote("%"+firstName+"%")+" AND ";
            if(lastName.length() > 0)
                whereClause += " surnames LIKE "+escape.cote("%"+lastName+"%")+" AND ";
            if(postalCode.length() > 0)
                whereClause += " ( bapostalCode ="+escape.cote(postalCode)+" OR  dapostalCode ="+escape.cote(postalCode)+" ) AND ";
            if(orderReference.length() > 0)
                whereClause += " orderRef ="+escape.cote(orderReference)+" AND ";
            if(city.length() > 0)
                whereClause += " ( batowncity like "+escape.cote("%"+city+"%")+" OR  batowncity like "+escape.cote("%"+city+"%")+" ) AND ";
            
            if(startDate.length() > 0 && endDate.length() > 0)
            {
                if(dateTimeValidation(startDate) && dateTimeValidation(endDate))
                {
                    if(compareStartEndDate(startDate,endDate))
                    {
                        whereClause += " creationDate >= "+escape.cote(startDate+" 00:00:00")+" AND  creationDate<="+escape.cote(endDate+" 23:59:59")+" AND ";
                    }
                    else
                    {
                        status = 30;
                        err_code = "INVALID_DATE_RANGE";
                        message = "start Date should be or less than end date";
                    }
                }
                else{
                    status = 20;
                    err_code = "INVALID_ARGUEMENT";
                    message = "Start Date OR End Date is invalid";
                }
            }
            else if(startDate.length() > 0){
                if(dateTimeValidation(startDate))
                    whereClause += " creationDate >= "+escape.cote(startDate+" 00:00:00")+" AND ";
                else{
                    status = 40;
                    err_code = "INVALID_DATE";
                    message = "start date should be in YYYY-MM-DD format";
                }
            }else if(endDate.length() > 0 && dateTimeValidation(endDate)){
                if(dateTimeValidation(startDate))
                    whereClause += " creationDate <= "+escape.cote(endDate+" 23:59:59")+" AND ";
                else{
                    status = 40;
                    err_code = "INVALID_DATE";
                    message = "end date should be in YYYY-MM-DD format";
                }
                
            }

            if(status==0){
                final String finalQuery = query+whereClause.substring(0,whereClause.length()- 4);
                com.etn.util.Logger.info("fetch.jsp", "final Query::"+finalQuery);
                Set rs = Etn.execute(finalQuery);
                data.put("orders",getOrders(rs));
            }
        }else
        {
            status = 10;
            err_code = "REQUIRED_FIELDS_MISSING";
            message = "required fields are missing";    
        }
    }else{
        status=100;
        err_code = "NOT_FOUND";
        message="fetch.jsp doesnot supports "+method+" method";
    }
    
    json.put("status",status);

    if(err_code.length() > 0 && status > 0)
    {
        json.put("err_code",err_code);
        json.put("err_msg",message);
    }else{
        json.put("data",data);
    }

    out.write(json.toString());
%>