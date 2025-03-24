package com.etn.eshop.forter;

import com.etn.sql.escape;
import com.etn.eshop.Util;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;

import java.util.Properties;
import org.json.JSONArray;
import org.json.JSONObject;

public class ForterDefaultJsonBuilder extends ForterJsonBuilderAbstract
{
	public int init( ClientSql etn , Properties conf, int wkid , String clid )
	{ 
		super.init(etn, conf, wkid, clid);
		return(0); // OK
	}

	public JSONArray getPayments(  ) throws Exception
	{
		Set rsOrder = etn.execute("select *, UNIX_TIMESTAMP(tm) as checkout_time_seconds, date_format(delivery_date, '%Y-%m-%d') as fmt_delivery_date, "+
					" UNIX_TIMESTAMP(concat(date_format(delivery_date, '%Y-%m-%d'),' ', lpad(delivery_end_hour,2,0), ':', lpad(delivery_end_min,2,0))) as delayed_delivery_ts "+
					" from orders where id = "+escape.cote(clid));
		rsOrder.next();
		
		JSONArray jPayments = new JSONArray();
		JSONObject jPayment = new JSONObject();
		JSONObject jAmount = new JSONObject();
		jAmount.put("amountLocalCurrency", rsOrder.value("total_price"));
		jAmount.put("currency", rsOrder.value("currency_code"));
		jPayment.put("amount", jAmount);
		
		String countryCode = Util.getSiteConfig(etn, env, rsOrder.value("site_id"), "forter_country_code");
		
		JSONObject jBillingDetails = new JSONObject();
		JSONObject jAddress = new JSONObject();
		if(Util.parseNull(rsOrder.value("baline1")).length() > 0) jAddress.put("address1", Util.parseNull(rsOrder.value("baline1")));
		if(Util.parseNull(rsOrder.value("baline2")).length() > 0) jAddress.put("address2", Util.parseNull(rsOrder.value("baline2")));
		if(Util.parseNull(rsOrder.value("batowncity")).length() > 0) jAddress.put("city", Util.parseNull(rsOrder.value("batowncity")));
		if(Util.parseNull(rsOrder.value("bapostalCode")).length() > 0) jAddress.put("zip", Util.parseNull(rsOrder.value("bapostalCode")));
		jAddress.put("country", countryCode);
		jBillingDetails.put("address", jAddress);
		
		JSONObject jPersonalDetails = new JSONObject();
		jPersonalDetails.put("firstName", Util.parseNull(rsOrder.value("name")));
		jPersonalDetails.put("lastName", Util.parseNull(rsOrder.value("surnames")));
		jPersonalDetails.put("email", Util.parseNull(rsOrder.value("email")));
		jBillingDetails.put("personalDetails", jPersonalDetails);
		
		JSONArray jPhones = new JSONArray();
		JSONObject jPhone = new JSONObject();
		jPhone.put("phone", Util.parseNull(rsOrder.value("contactPhoneNumber1")));
		jPhones.put(jPhone);
		jBillingDetails.put("phone", jPhones);
		
		jPayment.put("billingDetails", jBillingDetails);
		
		String paymentStatus = "";
		Set rsP = etn.execute("Select * from payments_ref where id = "+escape.cote(rsOrder.value("payment_ref_id")));
		if(rsP.next())
		{
			paymentStatus = rsP.value("payment_status");
		}
		
		if("orange_money".equals(rsOrder.value("spaymentmean")))
		{					
			JSONObject jOrangeMoney = new JSONObject(); 
			jOrangeMoney.put("digitalWalletName", "OTHER");
			JSONObject jUnderlyingPaymentMethod = new JSONObject(); 
			jUnderlyingPaymentMethod.put("underlyingPaymentMethodType", "UNKNOWN");
			jOrangeMoney.put("underlyingPaymentMethod", jUnderlyingPaymentMethod);
			jOrangeMoney.put("payerAccountCountry", countryCode);
			jOrangeMoney.put("paymentSuccessStatus", paymentStatus);
			jOrangeMoney.put("freeTextDigitalWalletName", "Orange money");
			
			jPayment.put("digitalWallet", jOrangeMoney);
		}
		
		jPayments.put(jPayment);
		
		return jPayments;
	}

	public JSONObject getPrimaryRecipient(  ) throws Exception
	{ 
		Set rsOrder = etn.execute("select *, UNIX_TIMESTAMP(tm) as checkout_time_seconds, date_format(delivery_date, '%Y-%m-%d') as fmt_delivery_date, "+
					" UNIX_TIMESTAMP(concat(date_format(delivery_date, '%Y-%m-%d'),' ', lpad(delivery_end_hour,2,0), ':', lpad(delivery_end_min,2,0))) as delayed_delivery_ts "+
					" from orders where id = "+escape.cote(clid));
		rsOrder.next();
		
		String countryCode = Util.getSiteConfig(etn, env, rsOrder.value("site_id"), "forter_country_code");
		
		JSONObject jPrimaryRecipient = new JSONObject();

		JSONObject jAddress = new JSONObject();
		if(Util.parseNull(rsOrder.value("baline1")).length() > 0) jAddress.put("address1", Util.parseNull(rsOrder.value("baline1")));
		if(Util.parseNull(rsOrder.value("baline2")).length() > 0) jAddress.put("address2", Util.parseNull(rsOrder.value("baline2")));
		if(Util.parseNull(rsOrder.value("batowncity")).length() > 0) jAddress.put("city", Util.parseNull(rsOrder.value("batowncity")));
		if(Util.parseNull(rsOrder.value("bapostalCode")).length() > 0) jAddress.put("zip", Util.parseNull(rsOrder.value("bapostalCode")));
		jAddress.put("country", countryCode);
		jPrimaryRecipient.put("address", jAddress);
		
		JSONObject jPersonalDetails = new JSONObject();
		jPersonalDetails.put("firstName", Util.parseNull(rsOrder.value("name")));
		jPersonalDetails.put("lastName", Util.parseNull(rsOrder.value("surnames")));
		jPersonalDetails.put("email", Util.parseNull(rsOrder.value("email")));
		jPrimaryRecipient.put("personalDetails", jPersonalDetails);
		
		JSONArray jPhones = new JSONArray();
		JSONObject jPhone = new JSONObject();
		jPhone.put("phone", Util.parseNull(rsOrder.value("contactPhoneNumber1")));
		jPhones.put(jPhone);
		jPrimaryRecipient.put("phone", jPhones);
		
		return jPrimaryRecipient;		
	}

	public JSONObject getPrimaryDeliveryDetails(  ) throws Exception
	{ 
		Set rsOrder = etn.execute("select *, UNIX_TIMESTAMP(tm) as checkout_time_seconds, date_format(delivery_date, '%Y-%m-%d') as fmt_delivery_date, "+
					" UNIX_TIMESTAMP(concat(date_format(delivery_date, '%Y-%m-%d'),' ', lpad(delivery_end_hour,2,0), ':', lpad(delivery_end_min,2,0))) as delayed_delivery_ts "+
					" from orders where id = "+escape.cote(clid));
		rsOrder.next();
		
		boolean hasOffers = false;
		boolean hasProducts = false;
		Set rsoi = etn.execute("select * from order_items where parent_id = "+escape.cote(rsOrder.value("parent_uuid")));
		while(rsoi.next())
		{
			if("offer_prepaid".equals(rsoi.value("product_type")) || "offer_postpaid".equals(rsoi.value("product_type")) || "simple_virtual_product".equals(rsoi.value("product_type")) || "configurable_virtual_product".equals(rsoi.value("product_type")))
			{
				hasOffers = true;
			}
			else
			{
				hasProducts = true;
			}
		}
		
		String deliveryType = "PHYSICAL";
		if(hasOffers && hasProducts) deliveryType = "HYBRID";
		else if(hasOffers && hasProducts == false) deliveryType = "DIGITAL";		
		
		String deliveryMethod = Util.parseNull(rsOrder.value("delivery_type"));
		if(deliveryMethod.length() == 0) deliveryMethod = rsOrder.value("shipping_method_id");
		JSONObject jDeliveryDetails = new JSONObject();
		jDeliveryDetails.put("deliveryMethod", deliveryMethod);
		jDeliveryDetails.put("deliveryType", deliveryType);
		
		if(Util.parseNull(rsOrder.value("delivery_date")).length() > 0 && Util.parseNull(rsOrder.value("delivery_date")).equals("0000-00-00") == false)
		{
			jDeliveryDetails.put("delayedDeliveryDate", rsOrder.value("fmt_delivery_date"));
			jDeliveryDetails.put("delayedDeliveryTime", rsOrder.value("delayed_delivery_ts"));
		}
		
		if(Util.parseNullDouble(rsOrder.value("delivery_fees")) > 0)
		{
			JSONObject jDeliveryPrice = new JSONObject();
			jDeliveryPrice.put("amountLocalCurrency", rsOrder.value("delivery_fees"));
			jDeliveryPrice.put("currency", rsOrder.value("currency_code"));
			jDeliveryDetails.put("deliveryPrice", jDeliveryPrice);			
		}
		return jDeliveryDetails;
	}
	
}