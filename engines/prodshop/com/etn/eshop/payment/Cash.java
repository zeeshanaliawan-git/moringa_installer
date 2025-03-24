package com.etn.eshop.payment;

import com.etn.util.ItsDate;

/**
* This class will be called for the cach payments only in which case we will always return success for verify and check status functions. 
* For refund we will always return no refund as we are not supposed to call any API to make refund. Cash refund is handled out of system.
*/

/** 
 * Must be extended.
*/
public class Cash extends PaymentAbstract 
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
		return new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
	}
	
	public PaymentResponse verify(int wkid, String clid, int paymentLogId)
	{
		return new PaymentResponse(PaymentResponse.ResponseCodes.SUCCESS, "");
	}

	public PaymentResponse refund( int wkid , String clid, String param, int paymentLogId )
	{
		return new PaymentResponse(PaymentResponse.ResponseCodes.CASH_NO_REFUND, "", true);
	}
}
