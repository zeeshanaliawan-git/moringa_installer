package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.eshop.payment.PaymentAbstract;
import com.etn.eshop.payment.PaymentResponse;

import java.util.Properties;
import java.util.Map;
import java.util.HashMap;

public class Payment extends OtherAction 
{ 
	private int SUCCESS = 0;
	private int NO_ROW = -1;
	private int UNSUPPORTED_PAYMENT_METHOD = -50;
	private int UNSUPPORTED_ACTION = -60;
	private Map<String, PaymentAbstract> paymentActions = null;

	public int init( ClientSql etn , Properties conf )
	{ 		
		super.init(etn, conf);
		
		paymentActions = new HashMap<>();
		Set rs = etn.execute("Select * from payment_actions");
                
		while( rs.next() )
		{
			try
			{
				log("Initializing class "+rs.value("className"));
				Class z =  Class.forName( rs.value("className") );
				PaymentAbstract paymentAction = (PaymentAbstract) z.newInstance();
				paymentAction.init(etn, conf);
				
				paymentActions.put(rs.value("payment_method"), paymentAction);
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
        }		
		
		return(0); // OK
	}
	
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

	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		return execute(wkid, clid, param);
	}
	
	private int initLog(int wkid, String clid, String paymentMethod, String actionType)
	{
		return etn.executeCmd("insert into payment_actions_logs (wkid, clid, payment_method, action_type) "+
					" value ("+escape.cote(""+wkid)+", "+escape.cote(clid)+", "+escape.cote(paymentMethod)+", "+escape.cote(actionType)+")");
	}

	public int execute( int wkid , String clid, String param )
	{ 
		log("Payment wid:"+wkid+" cl:"+clid+" parm:"+param);
		
		Set rs = etn.execute("select * from orders where id = "+escape.cote(clid));
		if(rs.next())
		{
			String siteid = rs.value("site_id");
			double totalPrice = Util.parseNullDouble(rs.value("total_price"));
			
			boolean isExternal = "1".equals(rs.value("is_external"));
			
			String paymentMethod = Util.parseNull(rs.value("spaymentmean"));
						
			PaymentResponse pr = null;
			int paymentLogId = -1;
			log("Payment method:"+paymentMethod);
			log("Total to pay:"+totalPrice);
			if(totalPrice <= 0 && paymentMethod.length() == 0)
			{
				log("Nothing to pay so in this case payment method can be empty so we must return success");
				pr = new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "total to pay is zero, skip payment "+param, true);
			}
			else
			{
				if(paymentActions.get(paymentMethod) == null) 
				{
					logE("No action found for the payment method");
					return UNSUPPORTED_PAYMENT_METHOD;
				}
				
				if("checkStatus".equalsIgnoreCase(param))
				{
					if(isExternal)
					{
						log("Order is an external order in which case we are not responsible to check the payment status as we do not have all information about payment");
						pr = new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
					}
					else
					{
						paymentLogId = initLog(wkid, clid, paymentMethod, "checkStatus");
						pr = paymentActions.get(paymentMethod).checkStatus(wkid, clid, paymentLogId);
					}
				}
				else if("verify".equalsIgnoreCase(param))
				{
					if(isExternal)
					{
						log("Order is an external order in which case we are not responsible to verify payment as we do not have all information about payment");
						pr = new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
					}
					else
					{
						paymentLogId = initLog(wkid, clid, paymentMethod, "verify");
						pr = paymentActions.get(paymentMethod).verify(wkid, clid, paymentLogId);
					}
				}
				else if("revalidate".equalsIgnoreCase(param))
				{
					Set _rs = etn.execute("select * from payment_actions where payment_method = "+escape.cote(paymentMethod));
					_rs.next();
					if("1".equals(_rs.value("revalidation_required")))
					{
						//cyber source payment must be revalidated before actual processing of order
						//it can take some time ( even couple of days at times ) to capture a payment from customer's credit card
						//in which case we must confirm payment is actually completed with funds transferred and then we process order
						//Not all payment methods need revalidation so we keep a flag in payment_actions table for such payment methods
						paymentLogId = initLog(wkid, clid, paymentMethod, "revalidate");
						pr = paymentActions.get(paymentMethod).revalidate(wkid, clid, paymentLogId);
					}
					else
					{
						log("Payment method : " + paymentMethod + " does not require revalidation. We return success");
						pr = new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
					}
				}
				else if(param.toLowerCase().startsWith("refund"))
				{
					Set rsLog = etn.execute("select * from payment_actions_logs where action_type = 'refund' and clid = "+escape.cote(clid)+" and status = 'success'");
					if(rsLog.rs.Rows > 0)
					{
						log("Transaction is already refunded. No need to refund again.");
						pr = new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
					}
					else
					{
						paymentLogId = initLog(wkid, clid, paymentMethod, "refund");
						//maybe for refund we have to implement partial refund or full refund cases separately
						pr = paymentActions.get(paymentMethod).refund(wkid, clid, param, paymentLogId);
					}
				}
			}
			
			if(pr == null)
			{
				return UNSUPPORTED_ACTION;
			}
			
			etn.executeCmd("update payment_actions_logs set error_code = "+escape.cote(""+pr.getCode())+", error_msg = "+escape.cote(Util.parseNull(pr.getMessage()))+" where id = "+escape.cote(""+paymentLogId));				
			//these two error code means we had some issue calling API so we have to try it again
			if(pr.getCode() >= 0 && pr.getCode() != PaymentResponse.ResponseCodes.API_ERROR && pr.getCode() != PaymentResponse.ResponseCodes.SOME_EXCEPTION)
			{
				etn.executeCmd("update payment_actions_logs set status = 'success' where id = "+escape.cote(""+paymentLogId));				
			}
			
			if(pr.getEndJob())
			{
				//status success means we passed this phase as we are doing endJob				
				endJob(wkid, clid, pr.getCode(), pr.getMessage());
			}
			//for negative error codes we must stay in that phase rather retrying and wasting engine time
			else if(pr.getCode() >= 0)
			{
				retry(wkid, clid, pr.getCode(), pr.getMessage(), pr.getRetryMinutes());
			}	
			
			return pr.getCode();
		}
		return NO_ROW;
	}
	
	private void endJob(int wkid, String clid, int errCode, String errMsg)
	{		
		etn.executeCmd("update post_work set errCode="+escape.cote(""+errCode)+", errMessage="+escape.cote(Util.parseNull(errMsg))+" where id="+escape.cote(""+wkid));
		((Scheduler)env.get("sched")).endJob( wkid , clid);
	}

	private void retry(int wkid, String clid, int errCode, String errMsg, int retryMinutes)
	{
		((Scheduler)env.get("sched")).retry( wkid , clid, errCode, Util.parseNull(errMsg), true, ""+retryMinutes );
	}
}
