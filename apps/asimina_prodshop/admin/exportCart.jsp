<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" /><%@page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%><%@page import="java.io.*"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ include file="../common.jsp" %>
<%
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");

	String filename = "commandes";	
    
	response.setCharacterEncoding("UTF-8");
	response.setContentType("APPLICATION/OCTET-STREAM"); 
	response.addHeader("Content-Disposition","attachment; filename="+ filename+".csv");
	response.setHeader("Cache-Control", "private");
	response.setHeader("Pragma", "private");

    String startDt = parseNull(request.getParameter("startDate"));
	String endDt = parseNull(request.getParameter("endDate"));

    String query="SELECT DISTINCT crt.*,CASE WHEN COALESCE(crt.payment_method,'')!='' THEN 'Step number 3' "
		+" WHEN COALESCE(crt.delivery_method,'')!='' THEN 'Step number 2'"
		+" WHEN COALESCE(crt.name,'')!='' THEN 'Step number 1'   ELSE 'Step number 0' END AS step, "
		+" DATE_FORMAT(crt.created_on, '%d/%m/%Y') as fmt_created_on, pm.displayName as paymentMethodName,"
		+" dm.displayName as deliveryMethodName,crt.visited_cart_page as visited FROM " 
		+ com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") + ".cart crt "
		+" JOIN "+ com.etn.beans.app.GlobalParm.getParm("PORTAL_DB") + ".cart_items crt_itms ON crt_itms.cart_id=crt.id "
		+" LEFT JOIN "+ com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".payment_methods pm ON pm.site_id = crt.site_id AND pm.method = crt.payment_method "
		+" LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".delivery_methods dm ON dm.site_id = crt.site_id AND dm.method = crt.delivery_method "
		+" AND COALESCE(dm.subType,'') = COALESCE(crt.delivery_type,'') "
		+" WHERE (crt.created_on BETWEEN " + escape.cote(startDt + "000000") + " AND " + escape.cote(endDt + "235959")+ ") "
		+" ORDER BY crt.id DESC";

	Set rs = Etn.execute(query);

	out.write("\"Cart Date\",\"First Name\",\"Last Name\",\"Email\",\"Phone Number\",\"Payment Method\",\"Delivery Method\",\"Step\",\"Cart Saved?\"");
	while(rs.next())
	{
        String step="";
        if(parseNull(rs.value("visited")).equals("0")){
            step="Add to cart";
            
        }else{
            if(parseNull(rs.value("step")).equalsIgnoreCase("step number 0")){
                step="Cart";
            }
            else if(parseNull(rs.value("step")).equalsIgnoreCase("step number 1")){
                step="Personal Details";
            }
            else if(parseNull(rs.value("step")).equalsIgnoreCase("step number 2")){
                step="Delivery Mode";
            }
            else if(parseNull(rs.value("step")).equalsIgnoreCase("step number 3")){
                step="Payment Method";
            }
        }

        out.write("\n\""+rs.value("fmt_created_on")+"\",\""+rs.value("name")+"\",\""+rs.value("surnames")+
            "\",\""+rs.value("email")+"\",\""+rs.value("contactPhoneNumber1")+"\",\""+rs.value("paymentMethodName")+"\",\""
            +rs.value("deliveryMethodName")+"\",\""+step+"\",\""+rs.value("keepEmail")+"\""
            );
            
	}
%>