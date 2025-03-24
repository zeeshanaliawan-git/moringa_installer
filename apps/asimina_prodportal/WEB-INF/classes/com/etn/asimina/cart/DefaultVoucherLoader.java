package com.etn.asimina.cart;

import com.etn.beans.Contexte;
import javax.servlet.http.HttpServletRequest;

public class DefaultVoucherLoader implements VoucherLoader {
	//asimina voucher is the cart rule which are already in the database so we have to do nothing here
	public boolean loadVoucher(Contexte Etn, HttpServletRequest request, String siteId, String voucherCode) {
		return true;
	}
}