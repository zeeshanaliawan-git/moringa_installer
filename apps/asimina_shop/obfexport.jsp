<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" /><%@page import="com.etn.lang.ResultSet.Set"%><%@page import="java.io.*"%><%!
String parseNull(Object o) {
  if( o == null )
    return("");
  String s = o.toString();
  if("null".equals(s.trim().toLowerCase()))
    return("");
  else
    return(s.trim());
}
%><%
	request.setCharacterEncoding("UTF-8");
	response.setCharacterEncoding("UTF-8");

	String qry = parseNull(session.getAttribute("IBO_EXPORT_QRY"));
	String filename = "commandes";	
	//System.out.println(qry);
	Set rs = Etn.execute(qry);		
	response.setCharacterEncoding("UTF-8");
	response.setContentType("APPLICATION/OCTET-STREAM"); 
	response.addHeader("Content-Disposition","attachment; filename="+ filename+".csv");
	response.setHeader("Cache-Control", "private");
	response.setHeader("Pragma", "private");
	//String sep = ";"; 
	out.write("\"Order Ref\";\"Order Date\";\"Status change date\";\"Name\";\"Status\";\"Message\";\"Process\";\"Delivery mode\";\"Delivery by\";\"Address line 1\";\"Telephone\";\"Email\";\"Total paid\";\"SKU\";\"Product name\";\"Quantity\";\"Price before discount\";\"Price after discount\"");
	while(rs.next())
	{	
            out.write("\n\""+rs.value("orderRef")+"\";\""+rs.value("creationDate")+"\";\""+rs.value("insertion_date")+"\";\""+rs.value("name")+" "+rs.value("surnames")+"\";\""+rs.value("phaseDisplayName")+"\";\"");
            Set rsHistoricStatus = Etn.execute("SELECT * from post_work where client_key = " + com.etn.sql.escape.cote(rs.value("customerId")) + " order by id ASC ");
            Set rsLastErrMsg = Etn.execute("SELECT errMessage from post_work where id = " + com.etn.sql.escape.cote(rs.value("lastId")) + " ");
            rsLastErrMsg.next();
            if (!(rs.value("errMessage").equals("")) && (rsHistoricStatus.rs.Rows == 1))
            {
                if(rs.value("errMessage").startsWith("{")) out.write((new org.json.JSONObject(rs.value("errMessage"))).optString("message",""));
                else out.write(rs.value("errMessage"));   
            }
            else if ((rsHistoricStatus.rs.Rows > 1 && !(rsLastErrMsg.value("errMessage").equals("")))){
                if(rsLastErrMsg.value("errMessage").startsWith("{")) out.write((new org.json.JSONObject(rsLastErrMsg.value("errMessage"))).optString("message",""));
                else out.write(rsLastErrMsg.value("errMessage"));
            }
            out.write("\";\""+rs.value("proces")+"\"");
            org.json.JSONObject orderSnapshot = new org.json.JSONObject(rs.value("order_snapshot"));
            out.write(";\""+orderSnapshot.getString("deliveryDisplayName")+"\"");
            Set rsDeliveredBy = Etn.execute("select p.First_name, p.last_name from post_work pw inner join login l on pw.operador = l.name inner join person p on l.pid = p.person_id where pw.nextid = ( select id from post_work where phase = 'ColisRemis' and client_key="+com.etn.sql.escape.cote(rs.value("customerId"))+")");
            //System.out.println("select p.First_name, p.last_name from post_work pw inner join login l on pw.operador = l.name inner join person p on l.pid = p.person_id where pw.nextid = ( select id from post_work where phase = 'ColisRemis' and client_key="+com.etn.sql.escape.cote(rs.value("customerId"))+")");
            if(rsDeliveredBy.next()) out.write(";\""+rsDeliveredBy.value(0)+" "+rsDeliveredBy.value(1)+"\"");
            else out.write(";\"\"");
            out.write(";\""+rs.value("daline1")+"\"");
            out.write(";\""+rs.value("contactPhoneNumber1")+"\"");
            out.write(";\""+rs.value("email")+"\"");
            out.write(";\""+rs.value("total_price")+"\"");
            
            Set rsOrderItems = Etn.execute("SELECT * from order_items where parent_id = " + com.etn.sql.escape.cote(rs.value("parent_uuid")) + " order by id ASC ");
            boolean isFirst = true;
            while(rsOrderItems.next()){
                if(!isFirst) out.write("\n;;;;;;;;;;;;");
                out.write(";\""+(new org.json.JSONObject(rsOrderItems.value("product_snapshot"))).optString("sku","")+"\"");
                out.write(";\""+rsOrderItems.value("product_name")+"\"");
                out.write(";\""+rsOrderItems.value("quantity")+"\"");    
                out.write(";\""+rsOrderItems.value("price_old_value")+"\"");
                out.write(";\""+rsOrderItems.value("price_value")+"\"");         
                
                isFirst = false;
            }
	}
%>