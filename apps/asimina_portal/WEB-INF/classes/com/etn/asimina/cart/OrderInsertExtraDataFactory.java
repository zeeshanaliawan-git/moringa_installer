package com.etn.asimina.cart;

import com.etn.lang.ResultSet.Set;
import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;

public class OrderInsertExtraDataFactory {
	
	private OrderInsertExtraDataImpl extraDataImpl;
	
	public OrderInsertExtraDataFactory(String className) throws Exception
	{		
		com.etn.util.Logger.info("OrderInsertExtraDataFactory","Load class : " + className);
		Class z = Class.forName( className );
		extraDataImpl = (OrderInsertExtraDataImpl) z.newInstance();
	}
	
	public OrderInsertExtraDataImpl getImplementationClass()
	{
		return extraDataImpl;
	}
}