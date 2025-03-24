<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape,com.etn.beans.app.GlobalParm, com.etn.asimina.util.PortalHelper"%>
<%@ page import="org.json.JSONObject,org.json.JSONArray, java.util.*"%>


<%    

    JSONObject respObj = new JSONObject();
	String msg = "";
    int status = 0;


    String id = PortalHelper.parseNull(request.getParameter("id"));
    String orderRef = PortalHelper.parseNull(request.getParameter("orderRef"));
    String email = PortalHelper.parseNull(request.getParameter("q"));

    if(id.length()!=0 || (orderRef.length()!=0 && email.length()!=0)){

        String payment_method = "";
        String delivery_method = "";
        String orderId = "";

        JSONObject orderObj = new JSONObject();        

        String _lang = ""; 
        String langue_id = "";
        
        //if incoming lang was empty or not found in the language table, we will get the first language by default
        try{

            Set __rs1 = Etn.execute("select '0' as _a, langue_code, langue_id from language where langue_code = " + escape.cote(_lang) + " union select '1' as _a, langue_code, langue_id from language where langue_id = 1 order by _a ");
            if(__rs1.next()){
                _lang = PortalHelper.parseNull(__rs1.value("langue_code"));
                langue_id = PortalHelper.parseNull(__rs1.value("langue_id"));
                if(_lang.equals("") || langue_id.equals("")){
                    __rs1 = Etn.execute("select * from language order by langue_id limit 1");
                    if(__rs1.next()){
                        _lang = PortalHelper.parseNull(__rs1.value("langue_code"));
                        langue_id = PortalHelper.parseNull(__rs1.value("langue_id"));

                    }
                }
            }
			
            try{
                
				String query = " select o.*, date_format(o.creationdate, '%Y-%m-%dT%H:%i:%s') as created_ts_iso, c.client_uuid " +
								" from "+GlobalParm.getParm("SHOP_DB")+".orders o left outer join clients c on c.id = o.client_id ";
				if(id.length()==0){
					query += " where o.orderRef="+escape.cote(orderRef)+" and (o.email="+escape.cote(email)+" or o.contactPhoneNumber1="+escape.cote(email)+")";
				}
				else{
					query += " where o.parent_uuid="+escape.cote(id);
				}

                Set rsOrder = Etn.execute(query);
                if(rsOrder.next()){

                    for(String column : rsOrder.ColName) {

                        if(column.toLowerCase().equals("order_snapshot")){

							try {
								JSONObject orderSnapshotObj = new JSONObject(rsOrder.value("order_snapshot"));
								orderObj.put("order_snapshot",orderSnapshotObj);
							} catch(Exception e) {}

                        }else if(column.toLowerCase().equals("spaymentmean")){

                            Set rsPaymentMethod = Etn.execute("select displayName from "+GlobalParm.getParm("CATALOG_DB")+".payment_methods where site_id = " + 
                                escape.cote(rsOrder.value("site_id")) + " and method="+escape.cote(rsOrder.value("spaymentmean")));

                            if(rsPaymentMethod.next()){
								orderObj.put("payment_method_name",rsPaymentMethod.value(0));
                            }
							//send meaningful name
                            orderObj.put("payment_method", rsOrder.value(column));							
                        }
                        else if(column.toLowerCase().equals("shipping_method_id")){

                            Set rsDeliveryMethod = Etn.execute("select displayName from "+GlobalParm.getParm("CATALOG_DB")+".delivery_methods where site_id = " + 
                                escape.cote(rsOrder.value("SITE_ID")) + " and method="+escape.cote(rsOrder.value(column)));

                            if(rsDeliveryMethod.next()){
								orderObj.put("delivery_method_name",rsDeliveryMethod.value(0));
                            }
							//send meaningful name
                            orderObj.put("delivery_method", rsOrder.value(column));

                        }else if(column.toLowerCase().equals("parent_uuid")){
                            
							List<JSONObject> orderItemArray = new ArrayList<>();							
		
                            Set rsOrderItems = Etn.execute("select * from "+GlobalParm.getParm("SHOP_DB")+".order_items where parent_id="+escape.cote(rsOrder.value(column)));
                            
                            while(rsOrderItems.next()){
								JSONObject orderItemsObj = new JSONObject();								
                                for(String itemCol : rsOrderItems.ColName){

                                    if(itemCol.toLowerCase().equals("orderStatus")) continue;//no sense of this column
									
                                    if(itemCol.toLowerCase().equals("product_snapshot")){
                                        try{
                                            orderItemsObj.put("product_snapshot", new JSONObject(rsOrderItems.value(itemCol)));
										} catch (Exception e) {}                                        
                                    }else if(itemCol.toLowerCase().equals("promotion")){
                                        try {
                                            orderItemsObj.put("promotion", new JSONObject(rsOrderItems.value(itemCol)));
                                        } catch (Exception e) {}
                                    }else if(itemCol.toLowerCase().equals("attributes")){
                                        try {
                                            orderItemsObj.put("attributes", new JSONArray(rsOrderItems.value(itemCol)));
                                        } catch (Exception e) {}
                                    }else if(itemCol.toLowerCase().equals("comewiths")){
                                        try {
                                            orderItemsObj.put("come_withs", new JSONArray(rsOrderItems.value(itemCol)));
                                        } catch (Exception e) {}
                                    }else if(itemCol.toLowerCase().equals("additionalfees")){
                                        try {
                                            orderItemsObj.put("additional_fees", new JSONArray(rsOrderItems.value(itemCol)));
                                        } catch (Exception e) {}
                                    }else{
                                        orderItemsObj.put(itemCol.toLowerCase(), rsOrderItems.value(itemCol));
                                    }
                                }

                                orderItemArray.add(orderItemsObj);
                            }
							orderObj.put("items", orderItemArray);
							//lets send a more meaningful name in json .. parent_uuid is confusing name
                            orderObj.put("order_uuid", rsOrder.value(column));

                        }else{
							//we dont want to send the internal ID of client .. also ignore creationdate as we are sending formated date
							if(column.toLowerCase().equals("client_id") || column.toLowerCase().equals("creationdate")
								 || column.toLowerCase().equals("tm")) continue;
							if(column.toLowerCase().equals("id")) orderId = rsOrder.value(column);
                            else orderObj.put(column.toLowerCase(), rsOrder.value(column));
                        }
                        
                    }
					try{
						List<JSONObject> phasesArray = new ArrayList<>();
						Set rsHistorique = Etn.execute("select p.proces, p.phase, p.status, p.errCode, p.errMessage, "+
							" case when p.status in (2,9) then 'completed' else 'pending' end as phase_status, "+
							" date_format(p.start, '%Y-%m-%dT%H:%i:%s') as start_ts_iso, "+
							" date_format(p.end, '%Y-%m-%dT%H:%i:%s') as end_ts_iso, "+
						    " IF(COALESCE(ph.displayName"+langue_id+",'')<>'',ph.displayName"+langue_id+",ph.displayName) as phase_name, ph.orderTrackVisible as phase_tracking_visible "+
							" from "+GlobalParm.getParm("SHOP_DB")+".post_work p inner join "+GlobalParm.getParm("SHOP_DB")+".phases ph on p.proces = ph.process and p.phase = ph.phase "+
							" where p.client_key="+escape.cote(orderId)+
							" order by p.insertion_date, p.id asc");
						while(rsHistorique.next()) {
							JSONObject postWorkPhases = new JSONObject();
							for(String column : rsHistorique.ColName) {
								postWorkPhases.put(column.toLowerCase(), rsHistorique.value(column));
							}
							phasesArray.add(postWorkPhases);
						}
						orderObj.put("phases", phasesArray);
					}catch(Exception e){
						status = 2;
						msg="Error occured while fetching post_work data.";
					}
					
					respObj.put("order",orderObj);

                }
				else {
					status = 5;
					msg = "No order found";
				}
                
            }catch(Exception e){
                status = 2;
                msg="Error occured while fetching data.";
            }
        }catch(Exception e){
            status = 1;
            msg="Error parsing language";
        }

    }else{
        status=10;
        msg="Required fields missing. Either id or order id and email should be provided.";
    }
    respObj.put("status",status);
    respObj.put("message",msg);

    out.write(respObj.toString());
%>