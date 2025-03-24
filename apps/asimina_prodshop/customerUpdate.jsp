<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.text.DateFormat"%>
<%@ page  import="java.text.DecimalFormat"  %>
<%@ page  import="java.text.DecimalFormatSymbols"  %>
<%@ page  import="java.util.Locale"  %>


<%@ include file="common2.jsp" %>

<%
    ArrayList<String> itemCols = new ArrayList<String>();
    Set rsItemColumns = Etn.execute("select fieldName from field_names where tableName='order_items'");
    while(rsItemColumns.next()) itemCols.add(rsItemColumns.value(0));

    ArrayList<String> excludeCols = new ArrayList<String>();
    excludeCols.add("customerId");
    excludeCols.add("post_work_id");
    excludeCols.add("phase");
    excludeCols.add("phaseDisplayName");
    excludeCols.add("orderId");
    excludeCols.add("comments");
    excludeCols.add("calendarPhase");
    excludeCols.add("resource");
    excludeCols.add("secondary_resource");
    excludeCols.add("service_start_time");
    excludeCols.add("service_end_time");
    excludeCols.add("service_date");
    excludeCols.add("rdv_date");
    excludeCols.add("delivery_slot");

    boolean isError = false;
    String orderId = parseNull(request.getParameter("orderId"));
    String post_work_id = parseNull(request.getParameter("post_work_id"));
    String customerId = parseNull(request.getParameter("customerId"));
    String calendarPhase = parseNull(request.getParameter("calendarPhase"));

    String primaryResource = parseNull(request.getParameter("resource"));
    String secondaryResource = parseNull(request.getParameter("secondary_resource"));
    String client_key = customerId;
    
    String json = "";
    if(primaryResource.equals("")&&secondaryResource.equals("")){
        Etn.executeCmd("update order_items set resource=NULL, secondary_resource=NULL where id="+escape.cote(client_key));
        json = "{\"status\" : \"OK\", \"reason\" : \"\"}";
    }
    else if(!primaryResource.equals("")&&!secondaryResource.equals("")){
        Set rsItems = Etn.execute("select resource, secondary_resource from order_items where id="+escape.cote(client_key));
        rsItems.next();
        if(!rsItems.value(0).equals(primaryResource) || !rsItems.value(1).equals(secondaryResource)){
            String calendar_query = "select c.id, CONCAT(',',c.resources,',') from order_items oi inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products p ON oi.product_ref = p.product_uuid"+
                " inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".calendar c ON p.catalog_id = c.catalog_id AND p.id = c.product_id where c.type=2 AND oi.id ="+escape.cote(client_key)+
                " AND (CONCAT(',',c.resources,',') LIKE "+escape.cote("%,"+primaryResource+",%")+" OR CONCAT(',',c.resources,',') LIKE "+escape.cote("%,"+secondaryResource+",%")+")"+
                " AND c.date=STR_TO_DATE(oi.service_date,'%d-%m-%Y') AND ((HOUR(c.start_time)*60+MINUTE(c.start_time) BETWEEN oi.service_start_time AND ((oi.service_start_time-1)+(oi.quantity*oi.service_duration)))"+
                " OR (HOUR(c.end_time)*60+MINUTE(c.end_time) BETWEEN oi.service_start_time+1 AND ((oi.service_start_time)+(oi.quantity*oi.service_duration))) OR (oi.service_start_time BETWEEN HOUR(c.start_time)*60+MINUTE(c.start_time) AND HOUR(c.end_time)*60+MINUTE(c.end_time)-1)"+
                " OR (((oi.service_start_time)+(oi.quantity*oi.service_duration)) BETWEEN HOUR(c.start_time)*60+MINUTE(c.start_time)+1 AND HOUR(c.end_time)*60+MINUTE(c.end_time)))";

            Set rsCalendar = Etn.execute(calendar_query);
            //System.out.println(calendar_query+rsCalendar.rs.Rows);
            if(rsCalendar.next()){ 
                //System.out.println(rsCalendar.value(1));
                if(rsCalendar.value(1).contains(","+primaryResource+",")) json = "{\"status\" : \"NOK\", \"reason\" : \""+primaryResource+" is not available for the selected timeslot\"}";
                else json = "{\"status\" : \"NOK\", \"reason\" : \""+secondaryResource+" is not available for the selected timeslot\"}";
                isError = true;
            }
            else{
                Set rsOrder = Etn.execute("select oi.product_ref, p.link_id from order_items oi inner join "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products p on oi.product_ref=p.product_uuid where oi.id="+escape.cote(client_key));
                rsOrder.next();
                String product_refs = escape.cote(rsOrder.value("product_ref"));
                if(!rsOrder.value("link_id").equals("")){
                    Set rslink = Etn.execute("SELECT GROUP_CONCAT(CONCAT('\\\'',product_uuid,'\\\'')) FROM "+com.etn.beans.app.GlobalParm.getParm("CATALOG_DB")+".products where link_id="+rsOrder.value("link_id")+" group by link_id");
                    rslink.next();
                    product_refs = rslink.value(0);
                }
                String query = "";
                Set rs = Etn.execute(query="select case when oi.resource="+escape.cote(primaryResource)+" then 'Primary Resource is busy at this time' else 'Secondary Resource is busy at this time' end, oi.* from order_items oi2, order_items oi, post_work p  "+
                    " where oi2.id = "+ escape.cote(client_key)+
                    " and oi.id <> oi2.id  "+
                    //" and oi.product_ref in ("+product_refs+ 
                    " and oi2.service_date = oi.service_date and ( oi.resource = "+escape.cote(primaryResource)+" or oi.secondary_resource = "+escape.cote(secondaryResource) +
                    ") and (oi2.service_start_time between oi.service_start_time and ((oi.service_start_time-1)+(oi.quantity*oi.service_duration)+oi.service_gap) "+
                    " or ((oi2.service_start_time-1)+(oi2.quantity*oi2.service_duration)+oi2.service_gap) between oi.service_start_time and ((oi.service_start_time-1)+(oi.quantity*oi.service_duration)+oi.service_gap)  "+
                    " or oi.service_start_time between oi2.service_start_time and ((oi2.service_start_time-1)+(oi2.quantity*oi2.service_duration)+oi2.service_gap) "+
                    " or ((oi.service_start_time-1)+(oi.quantity*oi.service_duration)+oi.service_gap) between oi2.service_start_time and ((oi2.service_start_time-1)+(oi2.quantity*oi2.service_duration)+oi2.service_gap)) "+
                    " and oi.id = p.client_key and p.status in(0,9) and p.is_generic_form = 0 and p.phase not in ('cancel','cancel30') ");
                //System.out.println(query);
                if(rs.next()){
                    //if(!json.equals("")) json+=",";
                    json = "{\"status\" : \"NOK\", \"reason\" : \""+rs.value(0)+"\"}";
                    isError = true;
                }
                else{
                    Etn.executeCmd("update order_items set resource="+escape.cote(primaryResource)+", secondary_resource="+escape.cote(secondaryResource)+" where id="+escape.cote(client_key));
                    json = "{\"status\" : \"OK\", \"reason\" : \"\"}";
                }
            }

            
        }
        else{
            json = "{\"status\" : \"OK\", \"reason\" : \"No resource change made\"}";
            //isError = true;
        }
    }
    else{
        json = "{\"status\" : \"NOK\", \"reason\" : \"Please select both resources\"}";
        isError = true;
    }

    

    String updateQry = "";
    int rowsUpdated = 0;
    int itemRowsUpdated = 0;
    if(isError){
        System.out.println(json);
        out.write(json);
        return;
    }
    else{
        String updateParameters="";
        String itemUpdateParameters="updatedBy = "+escape.cote(((String)session.getAttribute("LOGIN")))+", updatedDate = current_timestamp";

        Map<String, String[]> parameters = request.getParameterMap();
        for(String parameter : parameters.keySet()) 
         {
                if(excludeCols.contains(parameter)) continue;

                if(itemCols.contains(parameter)){
                    itemUpdateParameters += ", `" + parameter + "` = " + escape.cote(parseNull(request.getParameter(parameter)));
                }
                else if(parameter.equals("email") && parseNull(request.getParameter(parameter)).length() ==0 ){
                    updateParameters += ", `" + parameter + "` = NULL ";
                }
                else if(parameter.equals("delivery_date") && parseNull(request.getParameter(parameter)).length() ==0 ){
                    updateParameters += ", `" + parameter + "` = NULL ";
                }
                else if(parameter.equals("delivery_date") && parseNull(request.getParameter(parameter)).length() > 0 ){
                    System.out.println(escape.cote(""+com.etn.util.ItsDate.getDate(parseNull(request.getParameter(parameter)))));
					//incoming format is dd/mm/yyyy
					String[] sdate = parseNull(request.getParameter(parameter)).split("/");
					
					String ndate = sdate[2]+sdate[1]+sdate[0];
					System.out.println("ndate:"+ndate);
                    updateParameters += ", `" + parameter + "` = "+escape.cote(ndate);
                }
                else{
                    if(!updateParameters.equals("")) updateParameters += ",";
                    updateParameters += "`" + parameter + "` = " + escape.cote(parseNull(request.getParameter(parameter)));
                }
        }

        if(parseNull(com.etn.beans.app.GlobalParm.getParm("POST_WORK_SPLIT_ITEMS")).equals("0")){
            updateQry =  "UPDATE orders SET "+updateParameters+" WHERE id = "+ escape.cote(customerId);
            rowsUpdated = Etn.executeCmd(updateQry);
            itemRowsUpdated = 1;
        }
        else
        {
            updateQry =  "UPDATE order_items SET "+itemUpdateParameters+" WHERE id = "+ escape.cote(customerId); // for order items
            itemRowsUpdated = Etn.executeCmd(updateQry);

            
            updateQry =  "UPDATE customer SET "+updateParameters+" WHERE customerId = "+ escape.cote(customerId);
            rowsUpdated = Etn.executeCmd(updateQry);
        }

        


        
        if(rowsUpdated <= 0 || itemRowsUpdated<=0) isError = true;
        else
        {
                Etn.executeCmd("delete from rlock where is_generic_form = 0 and id = "+escape.cote(customerId)+" and csr = "+escape.cote((String)session.getAttribute("LOGIN"))+" ");

                Etn.execute("select semfree('"+SEMAPHORE+"')");
        }
    }

	String _msg = "";
	String _isErr = "";
	if(isError)
	{
		_msg = "Some error occurred while updating the record";
		_isErr = "1";
	}
	response.sendRedirect("customerEdit.jsp?customerId="+customerId+"&post_work_id="+post_work_id+"&message="+_msg+"&_isErr="+_isErr);

%>