package com.etn.eshop.payment;

import com.etn.util.ItsDate;
import com.etn.eshop.Util;
import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.util.Properties;
import java.net.URL;
import java.net.HttpURLConnection;
import javax.net.ssl.HttpsURLConnection;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.io.FileInputStream;
import javax.net.ssl.TrustManagerFactory;
import java.security.KeyStore;
import org.json.*;
import com.etn.util.Base64;
import com.etn.eshop.Scheduler;

/** 
 * Must be extended.
*/
public class PayPal extends PaymentAbstract 
{ 
	private void log(String m)
	{
		if(m == null || m.trim().length() == 0) return;
		System.out.println("Payment::"+m);
	}

	private void logE(String m)
	{
		if(m == null || m.trim().length() == 0) return;
		System.out.println("Payment::ERROR::"+m);
	}


    private String getTime()
    {
        return( ItsDate.getWith(System.currentTimeMillis(),true) );
    }
	
	public PaymentResponse checkStatus(int wkid, String clid, int paymentLogId)
	{
		try
		{
			//for paypal we have no way to check the payment status through API
			//only way to know transaction was done 
			Set rs = etn.execute("select * from orders where id = " + escape.cote(clid));
			rs.next();
			String siteid = rs.value("site_id");
			String transactioncode = Util.parseNull(rs.value("transaction_code"));
			return getStatusFromApi(wkid, clid, transactioncode, paymentLogId, siteid);
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return new PaymentResponse(PaymentResponse.ResponseCodes.SOME_EXCEPTION, "Some error in PayPal payment");
		}		
	}
	
	public PaymentResponse verify(int wkid, String clid, int paymentLogId)
	{
		try
		{
			log("Start verification " + getTime());
			//row check is already done in com.etn.eshop.Payment class so we dont need to recheck
			Set rs = etn.execute("select * from orders where id = " + escape.cote(clid));
			rs.next();
			String siteid = rs.value("site_id");
			String transactioncode = Util.parseNull(rs.value("transaction_code"));
			
			//so far we just have to verify paypal payment
			if(rs.value("payment_status").equalsIgnoreCase("verify_payment"))
			{
				PaymentResponse pr = getStatusFromApi(wkid, clid, transactioncode, paymentLogId, siteid);
				if(pr.getCode() == PaymentResponse.ResponseCodes.SUCCESS)
				{
					//only when payment status was verify_payment then we mark it as success otherwise we do not change the payment_status in db
					etn.executeCmd("update orders set payment_status = 'SUCCESS' where id = "+escape.cote(clid));
				}
				return pr;
			}		
			else if(rs.value("payment_status").equalsIgnoreCase("SUCCESS"))
			{
				return new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
			}		
		}
		catch(Exception e)
		{
			e.printStackTrace();
			return new PaymentResponse(PaymentResponse.ResponseCodes.SOME_EXCEPTION, "Some error in PayPal payment");			
		}
		return new PaymentResponse(PaymentResponse.ResponseCodes.API_ERROR, "");
	}
	
	private PaymentResponse getStatusFromApi(int wkid, String clid, String transactionCode, int paymentLogId, String siteid) throws Exception
	{
		if(transactionCode.length() == 0)
		{
			etn.execute("update payment_actions_logs set resp = 'Transaction code is empty. This means we cannot get the payment info from PayPal and we must mark it as failed' where id = "+escape.cote(""+paymentLogId));
			return new PaymentResponse(PaymentResponse.ResponseCodes.MISSING_INFO, "Transaction code is empty. This means we cannot get the payment info from PayPal and we must mark it as failed", true);
		}
		
		JSONObject resp = callPaypalApi(siteid, transactionCode, paymentLogId);
		int status = resp.getInt("status");
		JSONObject paypalResp = resp.getJSONObject("resp");
		String errmsg = paypalResp.toString();
		if(status == 0)
		{
			if("COMPLETED".equalsIgnoreCase(Util.parseNull(paypalResp.optString("status"))) == true)
			{
				log("Paypal payment is COMPLETED ");		
				return new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
			}
			else
			{
				log("Paypal payment is not COMPLETED ");
				if(Util.parseNull(errmsg).length() == 0) errmsg = "Paypal payment verification failed";
				return new PaymentResponse(PaymentResponse.ResponseCodes.FAILED, errmsg);
			}
		}
		else
		{
			if(Util.parseNull(errmsg).length() == 0) errmsg = "Some api error so retry in 5 minutes";
			return new PaymentResponse(PaymentResponse.ResponseCodes.API_ERROR, errmsg);
		}
		
	}
	
	private JSONObject callPaypalApi(String siteid, String orderId, int paymentLogId) throws Exception
	{
		log("Inside Payment::callPaypalApi " + getTime());				
		HttpURLConnection htp = null;
		JSONObject resp = new JSONObject();
		BufferedReader reader = null;
		try
		{		
			String authorization = Base64.encode((getPortalConfig(siteid, "paypal_client_key") + ":" + getPortalConfig(siteid, "paypal_scrt")).getBytes("UTF-8"));
		
			String _url = getPortalConfig(siteid, "paypal_order_confirmation_url") + orderId;
			etn.executeCmd("update payment_actions_logs set req = "+escape.cote(_url)+" where id = "+escape.cote(""+paymentLogId));
			
			URL ur = new URL(_url);
			htp = (HttpURLConnection) ur.openConnection();
			htp.setRequestMethod("GET");
			htp.setRequestProperty("Content-Type","application/json");
			htp.setRequestProperty("Authorization","Basic "+authorization);
			htp.connect();

			int responseCode = htp.getResponseCode();			
			log("Api Response code :: "+responseCode+" :: " + getTime());
			
			resp.put("http_code", responseCode);
			String responseCharset = Util.getCharset(Util.parseNull(htp.getContentType()));
			if(responseCode >= 200 && responseCode <= 299) 
			{
                resp.put("status", 0);
				reader = new BufferedReader(new InputStreamReader(htp.getInputStream(), responseCharset));			
            }			
			else 
			{
                resp.put("status", responseCode);
				reader = new BufferedReader(new InputStreamReader(htp.getErrorStream(), responseCharset));
			}

			StringBuffer sb = new StringBuffer();	
			String inputLine;
			while ((inputLine = reader.readLine()) != null) {
				sb.append(inputLine);
			}
			log("ret : " + sb.toString());
			resp.put("resp", new JSONObject(sb.toString()));
			etn.executeCmd("update payment_actions_logs set http_code = "+escape.cote(""+responseCode)+", resp = "+escape.cote(sb.toString())+" where id = "+escape.cote(""+paymentLogId));
		}
		finally
		{
			if(reader != null) reader.close();
			if(htp != null) htp.disconnect();
		}		
		return resp;		
	}   

	private String getPortalConfig(String siteid, String code)
	{
		log("Load config : "+code+" for site id : " + siteid);
		Set rs = etn.execute("select * from "+env.getProperty("PORTAL_DB")+".sites_config where site_id = "+escape.cote(siteid)+" and code = "+escape.cote(code));
		if(rs.next()) return rs.value("val");
		return "";
	}

}
