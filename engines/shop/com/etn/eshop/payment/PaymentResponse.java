package com.etn.eshop.payment;

public class PaymentResponse
{ 
	private int code = -1;
	private String message;	
	private boolean endJob;	
	private int retryMinutes = 5;//default 5 minutes for all retry actions
	
	public PaymentResponse(int code, String message)
	{
		this.code = code;
		this.message = message;		
	}
	
	public PaymentResponse(int code, String message, boolean endJob)
	{
		this.code = code;
		this.message = message;
		this.endJob = endJob;		
	}

	public PaymentResponse(int code, String message, boolean endJob, int retryMinutes)
	{
		this.code = code;
		this.message = message;
		this.endJob = endJob;		
		this.retryMinutes = retryMinutes;
	}
	
	public int getCode()
	{
		return this.code;
	}
	
	public int getRetryMinutes()
	{
		return this.retryMinutes;
	}
	
	public void setRetryMinutes(int retryMinutes)
	{
		this.retryMinutes = retryMinutes;
	}
	
	public String getMessage()
	{
		return this.message;
	}
	
	public boolean getEndJob()
	{
		//DO NOT CHANGE THESE CONDITIONS
		if(this.code < 0) return false;
		//these are 3 valid cases in which we do not have to retry and we just do endjob so that process can move
		if(this.code == ResponseCodes.SUCCESS || this.code == ResponseCodes.FAILED || this.code == ResponseCodes.VERIFICATION_FAILED) return true;
		//these 2 cases we will not do endjob ... we will always go to retry for API_ERROR and SOME_EXCEPTION
		if(this.code == ResponseCodes.API_ERROR || this.code == ResponseCodes.SOME_EXCEPTION) return false;
		
		return this.endJob;
	}
	
	//If you have a new error code no need to add it here as we will just keep the generic error codes in this file
	//In case of a new error code just pass the endjob true/false so that com.etn.eshop.Payment class can do appropriate action at the end
	public static class ResponseCodes
	{
		public static final int SUCCESS = 0;
		public static final int TXN_PENDING = 35;
		public static final int FAILED = 40;		
		public static final int MISSING_INFO = 70;
		public static final int API_ERROR = 60;
		public static final int SOME_EXCEPTION = 50;
		public static final int CASH_NO_REFUND = 10;
		public static final int VERIFICATION_FAILED = 19;
		
		public static final int METHOD_NOT_IMPLEMENTED = -20;
	}
}
