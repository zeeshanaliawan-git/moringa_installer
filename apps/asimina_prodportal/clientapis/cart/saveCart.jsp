<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte, org.apache.http.HttpRequest, com.etn.beans.app.GlobalParm, org.json.*, java.util.*,javax.servlet.http.Cookie"%>

<%!

    String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

    boolean checkIfExists(Contexte Etn, String tableName, Map<String,String> params)
    {
        String query = "SELECT * FROM "+tableName+" WHERE ";
        int counter = 1 ;
        for (Map.Entry<String, String> param : 
             params.entrySet())
        {
            if(counter > 1) query += " AND ";
            query += " "+param.getKey()+"="+escape.cote(param.getValue())+" ";
            counter++ ;
        }

        Set rs = Etn.execute(query);
        return (rs.rs.Rows > 0)? true : false;
    }

    boolean checkSite(Contexte Etn, String value)
    {
        return checkIfExists(Etn,"sites",(new HashMap<String, String>()).put("suid",value));
    }

    boolean checkSiteMenu(Contexte Etn, String value)
    {
        return checkIfExists(Etn,"sites_menus",(new HashMap<String, String>()).put("menu_uuid",value));
    }

    boolean saveCart(Contexte Etn, Map<String,String> updatedValues ,Map<String,String> params)
    {
        String query = "UPDATE cart SET ";

        int counter = 1;
        for (Map.Entry<String, String> param : 
             updatedValues.entrySet())
        {
            if(counter > 1) query += " , ";
            query += " "+param.getKey()+"="+escape.cote(param.getValue())+" ";
            counter++ ;
        }

        counter = 1;

        query = " WHERE "
        for (Map.Entry<String, String> param : 
             params.entrySet())
        {
            if(counter > 1) query += " AND ";
            query += " "+param.getKey()+"="+escape.cote(param.getValue())+" ";
            counter++ ;
        }

        System.out.println("Query: " + query);
        int rs = Etn.executeCmd(query);
        if(rs>0) return true;
        return false;
    }


    String getCartSession(Cookie[] cookies) {
        for (Cookie cookie : cookies)
        {
            if( GlobalParm.getParm("CART_COOKIE").equalsIgnoreCase(cookie.getName()))
                return cookie.getValue();
        }
        return "";
    }

%>
<%
    String message = "";
    String err_code = "";
    int status = 0;
    JSONObject json = new JSONObject();
    final String method = parseNull(request.getMethod());
    Cookie[] cookies = request.getCookies();
    String cartSession = getCartSession(cookies);
    try
    {
        
        if(method.length()> 0 && method.equalsIgnoreCase("POST"))
        {
            if(cartSession.length() == 0)
            {
                com.etn.util.Logger.info("SaveCart.jsp","---------------------------------------------");
                com.etn.util.Logger.info("SaveCart.jsp","Cart Session NOT FOUND ::");
                com.etn.util.Logger.info("SaveCart.jsp","---------------------------------------------");
                status = 401;
                err_code = "CART_SESSION_NOT_FOUND";
                message = "THERE IS NO CART SESSION";
            }
            else
            {
                final String siteUuid = parseNull(request.getParameter("site-uuid"));
                final String siteMenu = parseNull(request.getParameter("menu-uid"));
                final String email = parseNull(request.getParameter("email"));
                final String phoneNumber = parseNull(request.getParameter("phone"));

                if(siteUuid.length() > 0)
                {    
                    if(checkSite(Etn,siteUuid))
                    {       
                        if(siteMenu.length() > 0)
                        {
                            if(checkSiteMenu(Etn, siteUuid))
                            {
                                if(email.length() > 0 || phoneNumber.length() > 0)
                                {
                                    Map<String,String> updateValues = new HashMap<String,String>();
                                    if(email.length()>0) updatedValues.put("keepEmail",email);
                                    if(phoneNumber.length()>0) updatedValues.put("keepPhone",phoneNumber);

                                    if(saveCart(Etn,updatedValues,(new HashMap<String,String>()).put("session_id",cartSession)))
                                    {
                                        message="Successfully Saved!";    
                                    }
                                    else
                                    {
                                        status = 20;
                                        err_code = "SERVER_ERROR";
                                        message = "ERROR OCCURRED WHILE UPDATING";
                                    }
                                }
                                else{
                                    status = 50;
                                    err_code = "BAD_REQUEST";
                                    message = "PARAMETER ARE REQUIRED OR INVALID";
                                }

                            }
                            else{
                                status = 40;
                                err_code = "MENU_UUID_INVALID";
                                message = "MENU UUID IS INVALID";
                            }
                        }
                        else{
                            status = 70;
                            err_code = "MENU_UUID_MISSING";
                            message = "MENU UUID required";
                        }    
                    }
                    else{
                        status = 60;
                        err_code = "SITE_UUID_IS_INVALID";
                        message = "SITE UUID invalid";
                    }
                }else{
                    status = 50;
                    err_code = "SITE_UUID_MISSING";
                    message = "SITE UUID REQUIRED";
                }
            }
        }
        else{
            status = 100;
            err_code = "NOT_SUPPORTED";
            message="saveCart.jsp doesnot supports "+method+" method";
        }
    }
    catch(Exception e)
    {
        status = 90;
        err_code = "SERVER_ERROR";
        message = "Something went wrong"; 
    }
    json.put("status",status);

    if(err_code.length() > 0 && status > 0)
    {
        json.put("err_code",err_code);
        json.put("err_msg",message);
    }else
        json.put("msg",message);
    
    out.write(json.toString());
%>

