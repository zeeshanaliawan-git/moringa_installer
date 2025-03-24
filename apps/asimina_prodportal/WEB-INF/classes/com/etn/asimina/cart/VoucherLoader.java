package com.etn.asimina.cart;

import com.etn.beans.Contexte;
import javax.servlet.http.HttpServletRequest;

public interface VoucherLoader {
	public boolean loadVoucher(Contexte Etn, HttpServletRequest request, String siteId, String voucherCode);
}