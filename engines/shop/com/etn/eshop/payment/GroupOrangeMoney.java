package com.etn.eshop.payment;

import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;
import com.etn.eshop.OtherAction;
import com.etn.eshop.Scheduler;
import com.etn.eshop.Util;
import com.etn.util.Base64;
import com.etn.eshop.ApiCaller;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.security.KeyStore;
import java.util.Properties;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;
import javax.net.ssl.X509TrustManager;

public class GroupOrangeMoney extends PaymentAbstract
{
	private ApiCaller apiCaller;
	class AccessToken
	{
		AccessToken() {}
		AccessToken(String token, long expiry, String type)
		{
			this.token = token;
			this.expiry = expiry;
			this.type = type;
		}
		String token = "";
		long expiry = 0;
		String type = "";
	}

	private Map<String, AccessToken> accessTokens = null;
	
	private void log(String m)
	{
		System.out.println("GroupOrangeMoney::" + m);
	}

	private void logE(String m)
	{
		System.out.println("GroupOrangeMoney::ERROR::" + m);
	}

	public int init( ClientSql etn , Properties conf )
	{ 
		super.init(etn, conf);
		accessTokens = new HashMap<String, AccessToken>();
		
		apiCaller = new ApiCaller(etn, conf);
		return(0); // OK
	}
	
	private String getAccessToken(String siteid)
	{
		log("get access token for site id : " + siteid);
		if(accessTokens.get(siteid) == null)
		{
			return "";			
		}
		return Util.parseNull(accessTokens.get(siteid).token);
	}

	private long getTokenExpiry(String siteid)
	{
		log("get token expiry for site id : " + siteid);
		if(accessTokens.get(siteid) == null)
		{
			return 0;			
		}
		return accessTokens.get(siteid).expiry;
	}

	private String getPortalConfig(String siteid, String code)
	{
		log("Load config : "+code+" for site id : " + siteid);
		log("select * from "+env.getProperty("PORTAL_DB")+".sites_config where site_id = "+escape.cote(siteid)+" and code = "+escape.cote(code));
		Set rs = etn.execute("select * from "+env.getProperty("PORTAL_DB")+".sites_config where site_id = "+escape.cote(siteid)+" and code = "+escape.cote(code));
		if(rs.next()) return Util.parseNull(rs.value("val"));
		return "";
	}

	private String getForceOrangeToken(String siteid) throws Exception
	{
		String orangeScrt = getPortalConfig(siteid, "orange_scrt");
		if(orangeScrt.length() == 0)
		{
			throw new Exception("ERROR: Orange API not specified.");
		}
		
		Map<String, String> requestHeaders = new HashMap<>();
		requestHeaders.put("Authorization", "Basic "+orangeScrt);
		requestHeaders.put("Content-Type", "application/x-www-form-urlencoded");

		boolean useProxy = true;//by default we assume we will use proxy if its configured
		String orange_api_use_proxy = getPortalConfig(siteid, "orange_api_use_proxy");
		if("false".equalsIgnoreCase(orange_api_use_proxy) || "0".equals(orange_api_use_proxy)) useProxy = false;
		JSONObject rspObj = apiCaller.callApi("GroupOrangeMoney.getForceOrangeToken", getPortalConfig(siteid, "orange_api_token"), "POST", "grant_type=client_credentials", requestHeaders, useProxy);

		if(accessTokens.get(siteid) == null)
		{
			accessTokens.put(siteid, new AccessToken());
		}
		
		String token = "";
		String tokenType = "";
		long expiry = 0;
		if(rspObj.getInt("http_code") == 200)
		{		
			JSONObject jResp = new JSONObject(rspObj.optString("response","{}"));
			token = jResp.optString("access_token","");
			tokenType = jResp.optString("token_type","");
			expiry = (System.currentTimeMillis()/1000) + Util.parseNullInt(jResp.optString("expires_in",""));
		}
		
		AccessToken aToken = accessTokens.get(siteid);
		aToken.token = token;
		aToken.expiry = expiry;
		aToken.type = tokenType;
		
		return aToken.token;
	}
	
	private String getOrangeAccessToken(String siteid) throws Exception
	{
        try
		{
            String accessToken = "";
			
            //first check expiry
			long diff = getTokenExpiry(siteid) - (System.currentTimeMillis()/1000);
			log("Expiring in: "+diff+" seconds");

            //if not expired
			//here we checking that diff be more than 10 seconds to be on safe side
            if(diff > 10){
				accessToken = getAccessToken(siteid);
            }

            if(accessToken.length() == 0)
			{
				accessToken = getForceOrangeToken(siteid);
            }

            //if still accessToken is empty
            if(accessToken.length() > 0)
			{
                return accessToken;
            }
            else
			{
				apiCaller.addLogEntry("GroupOrangeMoney.getOrangeAccessToken", "Access token not found");
                throw new Exception("Error in contacting Orange.");
            }

        }//main try
        finally
		{
             //if(response != null) response.close();
        }
    }

	public PaymentResponse verify( int wkid, String clid, int paymentLogId )
	{
		try
		{			
			log("In verify");
			apiCaller.setWkid(wkid);
			apiCaller.setClid(clid);

			Set rsOrder = etn.execute("select * from orders where id = " + escape.cote(clid));
			rsOrder.next();
			String siteid = rsOrder.value("site_id");
			log("Order payment_ref_id : " + rsOrder.value("payment_ref_id"));
			Set rsPaymentsRef = etn.execute("select * from payments_ref where id="+escape.cote(rsOrder.value("payment_ref_id")));
			rsPaymentsRef.next();
			
			JSONObject data = new JSONObject();
			data.put("order_id",Util.parseNull(rsPaymentsRef.value("payment_id")));
			data.put("pay_token",Util.parseNull(rsPaymentsRef.value("payment_token")));
			data.put("amount",Util.parseNull(rsPaymentsRef.value("total_price")));

			String tokenApiUrl = getPortalConfig(siteid, "orange_api_transactionstatus");

			Map<String, String> requestHeaders = new HashMap<>();
			requestHeaders.put("Authorization", "Bearer "+getOrangeAccessToken(siteid));
			requestHeaders.put("Content-Type", "application/json");
			
			boolean useProxy = true;//by default we assume we will use proxy if its configured
			String orange_api_use_proxy = getPortalConfig(siteid, "orange_api_use_proxy");
			if("false".equalsIgnoreCase(orange_api_use_proxy) || "0".equals(orange_api_use_proxy)) useProxy = false;
			JSONObject rsOrange = apiCaller.callApi("GroupOrangeMoney.verify", tokenApiUrl, "POST", data.toString(), requestHeaders, useProxy);				
			
			updateLogs(data, rsOrange, paymentLogId);
			
			if(rsOrange.getInt("status")==0)
			{
				JSONObject tmpObj = new JSONObject(rsOrange.optString("response","{}"));
				if(tmpObj.getString("status").equalsIgnoreCase("success"))
				{
					return new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
				}
				else
				{
					return new PaymentResponse(PaymentResponse.ResponseCodes.VERIFICATION_FAILED, "Payment verification failed");
				}
			}			
		}
		catch(Exception e)
		{
			e.printStackTrace();
			apiCaller.addLogEntry("GroupOrangeMoney.verify", e.getMessage());
			return new PaymentResponse(PaymentResponse.ResponseCodes.SOME_EXCEPTION, "Some error in GroupOrangeMoney payment");
		}
		return new PaymentResponse(PaymentResponse.ResponseCodes.API_ERROR, "API error GroupOrangeMoney payment");
	}
	
	private void updateLogs(JSONObject req, JSONObject resp, int paymentLogId)
	{
		String httpCode = "";
		try {
			httpCode = ""+resp.getInt("http_code");
		} catch (Exception e) {}
		String rStr = "";
		try {
			rStr = resp.optString("response","{}");
		} catch (Exception e) {}
		etn.executeCmd("update payment_actions_logs set http_code = "+escape.cote(httpCode)+", req = "+escape.cote(req.toString())+", resp = "+escape.cote(rStr)+" where id = "+escape.cote(""+paymentLogId));
	}
	
	public PaymentResponse checkStatus( int wkid, String clid, int paymentLogId )
	{
		try
		{	
			log("In checkStatus");
			apiCaller.setWkid(wkid);
			apiCaller.setClid(clid);

			Set rsOrder = etn.execute("select * from orders where id = " + escape.cote(clid));
			rsOrder.next();
			String siteid = rsOrder.value("site_id");
			log("Order payment_ref_id : " + rsOrder.value("payment_ref_id"));
			Set rsPaymentsRef = etn.execute("select * from payments_ref where id="+escape.cote(rsOrder.value("payment_ref_id")));
			rsPaymentsRef.next();
			
			boolean isPaymentSuccess = "1".equals(rsPaymentsRef.value("is_success"));
			
			if(isPaymentSuccess == false)
			{
				JSONObject data = new JSONObject();
				data.put("order_id",Util.parseNull(rsPaymentsRef.value("payment_id")));
				data.put("pay_token",Util.parseNull(rsPaymentsRef.value("payment_token")));
				data.put("amount",Util.parseNull(rsPaymentsRef.value("total_price")));

				String tokenApiUrl = getPortalConfig(siteid, "orange_api_transactionstatus");

				Map<String, String> requestHeaders = new HashMap<>();
				requestHeaders.put("Authorization", "Bearer "+getOrangeAccessToken(siteid));
				requestHeaders.put("Content-Type", "application/json");
				
				boolean useProxy = true;//by default we assume we will use proxy if its configured
				String orange_api_use_proxy = getPortalConfig(siteid, "orange_api_use_proxy");
				if("false".equalsIgnoreCase(orange_api_use_proxy) || "0".equals(orange_api_use_proxy)) useProxy = false;
				JSONObject rsOrange = apiCaller.callApi("GroupOrangeMoney.checkStatus", tokenApiUrl, "POST", data.toString(), requestHeaders, useProxy);
				
				updateLogs(data, rsOrange, paymentLogId);
				
				if(rsOrange.getInt("status")==0)
				{
					JSONObject tmpObj = new JSONObject(rsOrange.optString("response","{}"));
					if(tmpObj.optString("status","").equalsIgnoreCase("initiated"))
					{
						//we must retry in this case
						return new PaymentResponse(PaymentResponse.ResponseCodes.TXN_PENDING, "Payment is still in initiated state. Retry again.");
					}
					else if(tmpObj.optString("status","").equalsIgnoreCase("success"))
					{
						int id = updatePaymentRef(Util.parseNull(rsPaymentsRef.value("id")), Util.parseNull(tmpObj.optString("status")), "1", Util.parseNull(tmpObj.optString("txnid")));

						if(id>0)
						{
							id = updateOrderInfo(clid, rsPaymentsRef.value("id"));
							
							if(id>0)
							{
								return new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
							}
							else
							{
								return new PaymentResponse(PaymentResponse.ResponseCodes.SOME_EXCEPTION, "Orders not updated due to some error.");
							}
						}
						else
						{
							return new PaymentResponse(PaymentResponse.ResponseCodes.SOME_EXCEPTION, "Payment ref not updated due to some error.");
						}
					}
					else if(tmpObj.optString("status","").equalsIgnoreCase("failed"))
					{
						updatePaymentRef(Util.parseNull(rsPaymentsRef.value("id")), Util.parseNull(tmpObj.optString("status")), "0", Util.parseNull(tmpObj.optString("txnid")));
						updateOrderInfo(clid, rsPaymentsRef.value("id"));
						
						String msg = tmpObj.toString();
						if(Util.parseNull(msg).length() == 0) msg = "Payment failed.";							
						return new PaymentResponse(PaymentResponse.ResponseCodes.FAILED, msg);
					}
				}
			}
			else
			{
				log("Payment is already marked success");
				return new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
			}
			
		}
		catch(Exception e)
		{
			e.printStackTrace();
			apiCaller.addLogEntry("GroupOrangeMoney.checkStatus", e.getMessage());
			return new PaymentResponse(PaymentResponse.ResponseCodes.SOME_EXCEPTION, "Some error in GroupOrangeMoney payment");
		}
		return new PaymentResponse(PaymentResponse.ResponseCodes.API_ERROR, "API error GroupOrangeMoney payment");
	}
	
	private int updatePaymentRef(String paymentRefId, String status, String isSuccess, String txnId)
	{
		String query = "UPDATE payments_ref SET updated_ts = now(), payment_status = " + escape.cote(status)
		+ " ,is_success = "+escape.cote(isSuccess)+", payment_txn_id = " + escape.cote(txnId)
		+ " WHERE id=" + escape.cote(paymentRefId);
		
		return etn.executeCmd(query);
	}
	
	private int updateOrderInfo(String clid, String paymentRefId)
	{
		//fetch info from db again as we have updated some columns already
		Set rsPaymentsRef = etn.execute("select * from payments_ref where id = "+escape.cote(paymentRefId));
		rsPaymentsRef.next();
		return etn.executeCmd("update orders set updated_ts = now() "+
				",payment_ref_id="+escape.cote(Util.parseNull(rsPaymentsRef.value("id")))+
				",payment_id="+escape.cote(Util.parseNull(rsPaymentsRef.value("payment_id")))+
				",payment_token="+escape.cote(Util.parseNull(rsPaymentsRef.value("payment_token")))+
				",payment_url="+escape.cote(Util.parseNull(rsPaymentsRef.value("payment_url")))+
				",payment_notif_token="+escape.cote(Util.parseNull(rsPaymentsRef.value("payment_notif_token")))+
				",payment_status="+escape.cote(Util.parseNull(rsPaymentsRef.value("payment_status")))+
				",payment_txn_id="+escape.cote(Util.parseNull(rsPaymentsRef.value("payment_txn_id")))+
				",transaction_code="+escape.cote(Util.parseNull(rsPaymentsRef.value("payment_txn_id")))+
				",payment_ref_total_amount="+escape.cote(Util.parseNull(rsPaymentsRef.value("total_price")))+
				",payment_is_success="+escape.cote(Util.parseNull(rsPaymentsRef.value("is_success")))+
				" where id = "+escape.cote(clid));				
		
	}

	public static void main( String a[] ) throws Exception
	{
		int wkid = 2443;
		String clid = "663";

		Properties env = new Properties();
		env = new Properties();
		env.load(Scheduler.class.getResourceAsStream("Scheduler.conf")) ;

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

		GroupOrangeMoney gom = new GroupOrangeMoney();		
		gom.init(Etn,env);
		PaymentResponse pr = gom.checkStatus( wkid, clid, -1 );
		System.exit(pr.getCode());
	}
}