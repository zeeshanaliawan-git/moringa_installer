package com.etn.eshop.payment;

import com.etn.Client.Impl.ClientSql;
import java.util.Properties;


/*
* This class must be implemented for all payment methods to handle actions like payment status check, verification or refunds
* You must not call endJob or retry from your actions. Endjob or Retry will be the responsibility of class com.etn.eshop.Payment
* For generic return codes like success, payment pending, payment/refund/verification failed, api error or some exception you must use codes
* defined in ResponseCodes in PaymentResponse. This will keep the error codes consistent and easier to handle this in the process itself.
*/
public abstract class PaymentAbstract 
{ 
	public ClientSql etn;
	public Properties env;

	public int init( ClientSql etn , Properties conf )
	{ 
		this.etn = etn;
		this.env = conf;
		return(0); // OK
	}
		
	public PaymentResponse checkStatus( int wkid , String clid, int paymentLogId )
	{ 
		return null;
	}

	public PaymentResponse verify( int wkid , String clid, int paymentLogId )
	{ 
		return null;
	}

	public PaymentResponse refund( int wkid , String clid, String param, int paymentLogId )
	{ 
		return null;
	}

	public PaymentResponse revalidate( int wkid , String clid, int paymentLogId )
	{ 
		return null;
	}

}
