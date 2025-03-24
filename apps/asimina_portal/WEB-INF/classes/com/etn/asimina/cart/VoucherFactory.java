package com.etn.asimina.cart;

import com.etn.lang.ResultSet.Set;
import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;

public class VoucherFactory {
	
	private VoucherLoader voucherLoader;
	
	public VoucherFactory(String className) throws Exception
	{		
		com.etn.util.Logger.info("VoucherFactory","Load class : " + className);
		if(className == null || className.trim().length() == 0) voucherLoader = new DefaultVoucherLoader();
		else
		{
			Class z = Class.forName( className );
			voucherLoader = (VoucherLoader) z.newInstance();
		}
	}
	
	public VoucherLoader getVoucherLoader()
	{
		return voucherLoader;
	}
}