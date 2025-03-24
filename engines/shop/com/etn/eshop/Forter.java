package com.etn.eshop;

import com.etn.util.ItsDate;
import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.eshop.forter.*;

import java.util.*;
import org.json.*;

public class Forter extends OtherAction 
{ 
    private int SUCCESS = 0;
	private int NO_ORDER_FOUND = -1;
	private int NO_FORTER_ORDER_FOUND = 75;
	private int ACTION_NOT_SUPPORTED = -2;
	private int SOME_EXCEPTION = 50;
	private int API_ERROR = 60;
	
	private ApiCaller apiCaller = null;
	
	private void log(String m)
	{
		System.out.println("Forter::"+getTime()+"::"+m);		
	}
	
	private void logE(String m)
	{
		log("ERROR::"+m);
	}
	
	public int init( ClientSql etn , Properties conf )
	{ 
		super.init(etn, conf);
		etn.setSeparateur(2, '\001', '\002');
		apiCaller = new ApiCaller(etn, conf);
		return(0); // OK
	}
	
	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		return execute(wkid, clid, param);
	}	

	public int execute( int wkid , String clid, String param )
	{ 
		log("wid:"+wkid+" cl:"+clid+" parm:"+param);
		if( param.equalsIgnoreCase("validation") )
		{
			return validation(wkid, clid);
		}
		else if( param.equalsIgnoreCase("paymentfailed") )
		{
			return paymentFailed(wkid, clid);
		}
		else if( param.equalsIgnoreCase("PROCESSING") || param.equalsIgnoreCase("SENT") || param.equalsIgnoreCase("COMPLETED")
			|| param.equalsIgnoreCase("CANCELED_BY_MERCHANT") || param.equalsIgnoreCase("CANCELED_BY_CUSTOMER") || param.equalsIgnoreCase("RETURNED")
			|| param.equalsIgnoreCase("NO_SHOW") || param.equalsIgnoreCase("REPLACED"))
		{
			return updateStatus(wkid, clid, param.toUpperCase());
		}
		return ACTION_NOT_SUPPORTED;
	}	
	
	/*
	* This function will notify forter about failed payments
	* In our case we are following post auth scenario where we only know about payment failed or success
	* once we get feedback from third party payment api so we will create an order in forter with failed payment status
	*/
	private int paymentFailed(int wkid, String clid)
	{
		log("In notify wkid : " + wkid + " clid : " + clid + " ts : " + getTime());
		int ret = API_ERROR;
		String msg = "";
		try
		{
			//every country has different payment methods with different statuses returned .. some say failed some say failure
			//for this we will load payment method and status to be notified to forter in database and if the status is different from that
			//we will ignore it. Like pending transaction in case of orange money is something we do not have to notify to forter. We just have to notify them if
			//payment was failed at orange money
			Set rs = etn.execute("select p.payment_method, p.payment_status "+
						" from orders o join payments_ref p on p.id = o.payment_ref_id where o.id = "+escape.cote(clid));
			if(!rs.next()) return NO_ORDER_FOUND;
			
			Set rsc = etn.execute("select * from forter_pay_failed_statuses where payment_method = "+escape.cote(rs.value("payment_method"))+" and payment_status = "+escape.cote(rs.value("payment_status")));
			if(rsc.next())
			{
				//we will call validation function which will actually create the order in forter
				return validation(wkid, clid);
			}
			else
			{
				msg = "Payment status "+rs.value("payment_status")+" does not need to be notified to forter.";
				log("Payment status "+rs.value("payment_status")+" does not need to be notified to forter. Just return success");
				ret = SUCCESS;
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			ret = SOME_EXCEPTION;
			msg = "Some error occurred";
		}

		if(ret == SOME_EXCEPTION || ret == API_ERROR)
		{
			((Scheduler)env.get("sched")).retry( wkid , clid, ret, msg, true, "5" );
		}
		else if(ret == SUCCESS)
		{
			etn.executeCmd("update post_work set errCode = "+escape.cote(ret+"")+", errMessage = "+escape.cote(msg)+" where id = "+escape.cote(""+wkid));
			((Scheduler)env.get("sched")).endJob( wkid , clid );
		}
		log("end notify ts : " + getTime());
		return ret;		
	}
	
	/*
	* This function will call forter validation api and set the forter's status to orders table
	* Depending on this status we can then design the process flow to take appropriate actions
	*/
	private int validation(int wkid, String clid)
	{
		log("In validation wkid : " + wkid + " clid : " + clid + " ts : " + getTime());
		int ret = API_ERROR;
		String msg = "";
		try
		{
			Set rs = etn.execute("select *, UNIX_TIMESTAMP(tm) as checkout_time_seconds, date_format(delivery_date, '%Y-%m-%d') as fmt_delivery_date, UNIX_TIMESTAMP(now()) as now_seconds, "+
						" UNIX_TIMESTAMP(concat(date_format(delivery_date, '%Y-%m-%d'),' ', lpad(delivery_end_hour,2,0), ':', lpad(delivery_end_min,2,0))) as delayed_delivery_ts "+
						" from orders where id = "+escape.cote(clid));
			if(!rs.next()) return NO_ORDER_FOUND;

			Set rsf = etn.execute("select * from forter_order_logs where order_id = "+escape.cote(clid)+" and forter_action = 'validation' and status = 'success' ");
			if(rsf.next())
			{
				log("Validation for this order is already performed so we just return success");
				ret = SUCCESS;
			}
			else
			{		
				String forterJsonBuilderCls = Util.getSiteConfig(etn, env, rs.value("site_id"), "forter_json_builder_cls");
				if(forterJsonBuilderCls.length() == 0) forterJsonBuilderCls = "com.etn.eshop.forter.ForterDefaultJsonBuilder";
				log("We are using "+forterJsonBuilderCls+" as json builder class");
				Class z =  Class.forName( forterJsonBuilderCls );
				ForterJsonBuilderAbstract forterJsonBuilder = (ForterJsonBuilderAbstract) z.newInstance();
				forterJsonBuilder.init(etn, env, wkid, clid);
		
		
				JSONObject jDiscount = null;
				if(Util.parseNull(rs.value("promo_code")).length() > 0)
				{
					jDiscount = new JSONObject();
					jDiscount.put("couponCodeUsed", Util.parseNull(rs.value("promo_code")));
				}
				
				JSONObject jRequest = new JSONObject();
				JSONArray jCartItems = new JSONArray();
				Set rsoi = etn.execute("select * from order_items where parent_id = "+escape.cote(rs.value("parent_uuid")));
				while(rsoi.next())
				{
					JSONObject jProductSnapshot = new JSONObject(rsoi.value("product_snapshot"));
					
					JSONObject jCartItem = new JSONObject();					
					JSONObject jBasicItemData = new JSONObject();
					jCartItem.put("basicItemData", jBasicItemData);
					
					if(jDiscount != null) jBasicItemData.put("discount", jDiscount);
					
					jBasicItemData.put("category", Util.parseNull(jProductSnapshot.optString("type")));												
					jBasicItemData.put("name", rsoi.value("product_full_name"));
					
					JSONObject jPrice = new JSONObject();
					jPrice.put("amountLocalCurrency", rsoi.value("price_value"));
					jPrice.put("currency", rs.value("currency_code"));
					jBasicItemData.put("price", jPrice);
					
					jBasicItemData.put("productId", jProductSnapshot.optString("sku",""));
					jBasicItemData.put("quantity", Util.parseNullInt(rsoi.value("quantity")));
					
					String producttype = "TANGIBLE";
					if("offer_prepaid".equals(rsoi.value("product_type")) || "offer_postpaid".equals(rsoi.value("product_type")) || "simple_virtual_product".equals(rsoi.value("product_type")) || "configurable_virtual_product".equals(rsoi.value("product_type")))
					{
						producttype = "NON_TANGIBLE";
					}
					jBasicItemData.put("type", producttype);
					
					jCartItems.put(jCartItem);
				}
				jRequest.put("cartItems", jCartItems);
				
				JSONObject jConnectionInfo = new JSONObject();
				jConnectionInfo.put("customerIP", rs.value("ip"));
				jConnectionInfo.put("forterTokenCookie", rs.value("forter_token"));
				jConnectionInfo.put("userAgent", rs.value("user_agent"));
				jRequest.put("connectionInformation", jConnectionInfo);
				
				jRequest.put("checkoutTime", Util.parseNullLong(rs.value("checkout_time_seconds")));
				jRequest.put("orderId", rs.value("orderRef"));
				jRequest.put("orderType", "WEB");
				jRequest.put("timeSentToForter", Util.parseNullLong(rs.value("now_seconds")));
				
				JSONObject jTotal = new JSONObject();
				jTotal.put("amountLocalCurrency", rs.value("total_price"));
				jTotal.put("currency", rs.value("currency_code"));
				jRequest.put("totalAmount", jTotal);
				
				JSONArray jPayments = forterJsonBuilder.getPayments();
				if(jPayments != null) jRequest.put("payment", jPayments);
					
				JSONObject jPrimaryRecipient = forterJsonBuilder.getPrimaryRecipient();
				if(jPrimaryRecipient != null) jRequest.put("primaryRecipient", jPrimaryRecipient);
					
				JSONObject jPrimaryDeliveryDetails = forterJsonBuilder.getPrimaryDeliveryDetails();
				if(jPrimaryDeliveryDetails != null) jRequest.put("primaryDeliveryDetails", jPrimaryDeliveryDetails);
				
				String forterId = Util.getSiteConfig(etn, env, rs.value("site_id"), "forter_id");
				String url = "https://" + forterId + "." + Util.getSiteConfig(etn, env, rs.value("site_id"), "forter_validation_url_suffix") + rs.value("orderRef");
				apiCaller.setWkid(wkid);
				apiCaller.setClid(clid);
				Map<String, String> headers = new HashMap<>();
				headers.put("Authorization", "Basic " + Util.getSiteConfig(etn, env, rs.value("site_id"), "forter_api_basic_auth"));
				headers.put("api-version", Util.getSiteConfig(etn, env, rs.value("site_id"), "forter_api_version"));
				headers.put("x-forter-siteid", forterId);
				headers.put("Content-Type","application/json");
				
				JSONObject jResponse = apiCaller.callApi("Forter.validation", url, "POST", jRequest.toString(), headers);
				JSONObject jApiResponse = new JSONObject(jResponse.optString("response","{}"));
				String transactionStatus = "error";
				if(jResponse.getInt("http_code") == 200)
				{
					if(jApiResponse.optString("status","").equalsIgnoreCase("success")) transactionStatus = "success";
					if(transactionStatus.equals("success"))
					{
						String forterDecision = jApiResponse.optString("action", "");
						msg = "Forter decision is " + forterDecision;
						etn.executeCmd("update orders set forter_decision = "+escape.cote(forterDecision)+" where id = "+escape.cote(rs.value("id")));
						ret = SUCCESS;
					}
					else
					{
						msg = jApiResponse.toString();
						ret = API_ERROR;
					}
				}
				else
				{
					msg = jApiResponse.toString();
					ret = API_ERROR;
				}
				
				etn.executeCmd("insert into forter_order_logs (order_id, forter_action, req_json, resp_json, status) "+
						" value ("+escape.cote(rs.value("id"))+", 'validation', "+Util.escapeCoteJson(jRequest.toString())+", "+Util.escapeCoteJson(jApiResponse.toString())+", "+escape.cote(transactionStatus)+")");
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			ret = SOME_EXCEPTION;
			msg = "Some error occurred";
		}
		
		if(ret == SOME_EXCEPTION || ret == API_ERROR)
		{
			((Scheduler)env.get("sched")).retry( wkid , clid, ret, msg, true, "5" );
		}
		else if(ret == SUCCESS)
		{
			etn.executeCmd("update post_work set errCode = "+escape.cote(ret+"")+", errMessage = "+escape.cote(msg)+" where id = "+escape.cote(""+wkid));
			((Scheduler)env.get("sched")).endJob( wkid , clid );
		}
		log("end validation ts : " + getTime());
		return ret;
	}

	/*
	* This function will be called whenever order status changes in dandellion we have to update that in forter
	*/
	private int updateStatus(int wkid, String clid, String status)
	{
		log("In updateStatus wkid : " + wkid + " clid : " + clid + " status : " + status + " ts : " + getTime());
		int ret = API_ERROR;
		String msg = "";
		try
		{
			Set rs = etn.execute("select *, UNIX_TIMESTAMP(tm) as checkout_time_seconds, date_format(delivery_date, '%Y-%m-%d') as fmt_delivery_date, UNIX_TIMESTAMP(now()) as now_seconds, "+
						" UNIX_TIMESTAMP(concat(date_format(delivery_date, '%Y-%m-%d'),' ', lpad(delivery_end_hour,2,0), ':', lpad(delivery_end_min,2,0))) as delayed_delivery_ts "+
						" from orders where id = "+escape.cote(clid));
			if(!rs.next()) return NO_ORDER_FOUND;
			Set rsf = etn.execute("select * from forter_order_logs where order_id = "+escape.cote(clid)+" and forter_action = 'validation' and status = 'success' ");
			if(rsf.next())
			{
				JSONObject jRequest = new JSONObject();
				jRequest.put("eventTime", Util.parseNullLong(rs.value("now_seconds")));
				jRequest.put("orderId", rs.value("orderRef"));
				jRequest.put("updatedStatus", status);
				
				String forterId = Util.getSiteConfig(etn, env, rs.value("site_id"), "forter_id");
				String url = "https://" + forterId + "." + Util.getSiteConfig(etn, env, rs.value("site_id"), "forter_status_upd_url_suffix") + rs.value("orderRef");
				apiCaller.setWkid(wkid);
				apiCaller.setClid(clid);
				Map<String, String> headers = new HashMap<>();
				headers.put("Authorization", "Basic " + Util.getSiteConfig(etn, env, rs.value("site_id"), "forter_api_basic_auth"));
				headers.put("api-version", Util.getSiteConfig(etn, env, rs.value("site_id"), "forter_api_version"));
				headers.put("x-forter-siteid", forterId);
				headers.put("Content-Type","application/json");
				
				JSONObject jResponse = apiCaller.callApi("Forter.updateStatus", url, "POST", jRequest.toString(), headers);
				JSONObject jApiResponse = new JSONObject(jResponse.optString("response","{}"));
				String transactionStatus = "error";
				if(jResponse.getInt("http_code") == 200)
				{
					if(jApiResponse.optString("status","").equalsIgnoreCase("success")) transactionStatus = "success";
					if(transactionStatus.equals("success"))
					{
						msg = jApiResponse.optString("message", "Status updated to "+status+" in forter");
						ret = SUCCESS;
					}
					else
					{
						msg = jApiResponse.toString();
						ret = API_ERROR;
					}
				}
				else
				{
					msg = jApiResponse.toString();
					ret = API_ERROR;
				}

				etn.executeCmd("insert into forter_order_logs (order_id, forter_action, req_json, resp_json, status) "+
						" value ("+escape.cote(rs.value("id"))+", 'validation', "+Util.escapeCoteJson(jRequest.toString())+", "+Util.escapeCoteJson(jApiResponse.toString())+", "+escape.cote(transactionStatus)+")");
				
			}
			else
			{	
				//higly impossible case
				log("No forter order created against this order. Cannot update status in forter.");
				msg = "No forter order created against this order. Cannot update status in forter.";
				return NO_FORTER_ORDER_FOUND;
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			ret = SOME_EXCEPTION;
			msg = "Some error occurred";
		}
		
		if(ret == SOME_EXCEPTION || ret == API_ERROR)
		{
			((Scheduler)env.get("sched")).retry( wkid , clid, ret, msg, true, "5" );
		}
		else if(ret == SUCCESS || ret == NO_FORTER_ORDER_FOUND)
		{
			etn.executeCmd("update post_work set errCode = "+escape.cote(ret+"")+", errMessage = "+escape.cote(msg)+" where id = "+escape.cote(""+wkid));
			((Scheduler)env.get("sched")).endJob( wkid , clid );
		}
		log("end updateStatus ts : " + getTime());
		return ret;
	}
	
	private String getTime()
    {
        return( ItsDate.getWith(System.currentTimeMillis(),false) );
    }

	public static void main(String[] args) throws Exception {

		Properties env = new Properties();
		env = new Properties();
		env.load(com.etn.eshop.Scheduler.class.getResourceAsStream("Scheduler.conf")) ;

		ClientSql Etn = new com.etn.Client.Impl.ClientDedie(  "MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT") );

		//load config from db
		Set rs = Etn.execute("SELECT code,val FROM config");
		while (rs.next())
		{
			env.setProperty(rs.value("code"), rs.value("val"));
		}
		String commonsDb = env.getProperty("COMMONS_DB");
		if (commonsDb.trim().length() > 0)
		{
			//load from commons db but don't override local config
			rs = Etn.execute("SELECT code,val FROM " + commonsDb + ".config");
			while (rs.next())
			{
				if (!env.containsKey(rs.value("code")))
				{
					env.setProperty(rs.value("code"), rs.value("val"));
				}
			}
		}
		
		Forter sm = new Forter();		
		sm.init(Etn,env);
		//System.out.println("Return ::: " + sm.execute(Etn,4726,"1241","validation"));
		System.out.println("Return ::: " + sm.execute(Etn,4726,"1241","COMPLETED"));
		//System.out.println("Return ::: " + sm.execute(Etn,1,"173","partialrefund"));
		//System.out.println("Return ::: " + sm.execute(Etn,1,"173","refund"));
    }
}