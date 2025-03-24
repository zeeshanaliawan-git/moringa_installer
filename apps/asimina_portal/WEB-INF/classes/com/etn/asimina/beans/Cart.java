package com.etn.asimina.beans;

import com.etn.lang.ResultSet.Set;
import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;
import com.etn.util.Logger;
import com.etn.asimina.util.*;

import java.util.*;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

public class Cart
{
	private List<CartItem> items = null;
	private Map<String, String> properties;

	//extra properties required
	private String lang;
	private String langId;
	private String menuId;
	private String menuUuid;
    private double grandTotal = 0;
    private double grandTotalWT = 0;
    private double grandTotalRecurring = 0;
    private double grandTotalRecurringWT = 0;
	
	private Map<String, Double> grandTotalRecurringMap = null;
	private Map<String, Double> grandTotalRecurringWTMap = null;
	
	//this is currency label provided on portal parameters screen 
	//if no currency label is provided then this will be currency selected on portal parameters screen
	private String defaultCurrency = "";
	
	//this is the currency selected in the portal parameters
	private String currencyCode = "";
	
	private String priceFormatter = "";
	private String roundTo = "";
	private String showDecimals = "";
	private String langColumnPrefix = "";	
	private HashMap<String, Integer> taxNumbers = null;
	
	private List<CartError> errors;
	
	private double totalTax = 0;
    private double totalTaxRecurring = 0;	
	
	private int articlesCount = 0;
	
	private String paymentDisplayName = "";
	private double paymentFees = 0;
	private double shippingFees = 0;
    private double defaultShippingFees = 0;
	private String deliveryDisplayName = "";
	private boolean promoApplied = false;
	private String promoAppliedType = "";
	private double promoValue = 0;	
	private JSONArray calculatedCartDiscounts;
	private boolean showAmountWithTax;
	private boolean priceTaxIncluded;
	
	private double totalCartDiscount = 0;
	private double totalShippingDiscount = 0;

    private String terms = "";
	private String termsErrorMsg = "";
	private String cartMessage = "";
	private boolean checkoutRequireLogin;
	
	private boolean allowMultipleCatalogsCheckout;
	
	private boolean allowDeliverOutsideDep;
	private String deliverOutsideDepErrorMsg;
	
	private String shippingFeeStr;
	
	public JSONObject toJSON(){
		JSONObject json = new JSONObject(properties);
		try{
			json.put("items",new JSONArray());
			if(items != null){
				for(CartItem item : items){
					json.getJSONArray("items").put(item.toJSON());
				}
			}
			json.put("lang",lang);
			json.put("langId",langId);
			json.put("menuId",menuId);
			json.put("menuUuid",menuUuid);
			json.put("grandTotal",grandTotal);
			json.put("grandTotalWT",grandTotalWT);
			json.put("grandTotalRecurring",grandTotalRecurring);
			json.put("grandTotalRecurringWT",grandTotalRecurringWT);
			
			if(this.grandTotalRecurringMap != null)
			{
				JSONArray jArr = new JSONArray();
				for(String k : grandTotalRecurringMap.keySet())
				{
					JSONObject jObj = new JSONObject();
					jObj.put("frequency", k);
					jObj.put("total_amount", grandTotalRecurringMap.get(k));
					jArr.put(jObj);
				}
				json.put("grandTotalRecurringMap", jArr);
			}
			
			if(this.grandTotalRecurringWTMap != null)
			{
				JSONArray jArr = new JSONArray();
				for(String k : grandTotalRecurringWTMap.keySet())
				{
					JSONObject jObj = new JSONObject();
					jObj.put("frequency", k);
					jObj.put("total_amount", grandTotalRecurringWTMap.get(k));
					jArr.put(jObj);
				}
				json.put("grandTotalRecurringWTMap", jArr);
			}
			
			json.put("defaultCurrency",defaultCurrency);
			json.put("currencyCode",currencyCode);
			json.put("priceFormatter",priceFormatter);
			json.put("roundTo",roundTo);
			json.put("showDecimals",showDecimals);
			json.put("langColumnPrefix",langColumnPrefix);
			json.put("taxNumbers",new JSONObject());
			if(taxNumbers != null){
				for(String key : taxNumbers.keySet()){
					json.getJSONObject("taxNumbers").put(key,taxNumbers.get(key).intValue());
				}
			}
			json.put("errors",new JSONArray());
			if(errors != null){
				for(CartError error : errors){
					json.getJSONArray("errors").put(error.toJSON());
				}
			}		
			json.put("totalTax",totalTax);
			json.put("totalTaxRecurring",totalTaxRecurring);
			json.put("articlesCount",articlesCount);
			json.put("paymentDisplayName",paymentDisplayName);
			json.put("paymentFees",paymentFees);
			json.put("shippingFees",shippingFees);
			json.put("defaultShippingFees",defaultShippingFees);
			json.put("deliveryDisplayName",deliveryDisplayName);
			json.put("promoApplied",promoApplied);
			json.put("promoAppliedType",promoAppliedType);
			json.put("promoValue",promoValue);
			json.put("calculatedCartDiscounts",calculatedCartDiscounts);
			json.put("showAmountWithTax",showAmountWithTax);
			json.put("priceTaxIncluded",priceTaxIncluded);
			json.put("totalCartDiscount",totalCartDiscount);
			json.put("terms",terms);
			json.put("termsErrorMsg",termsErrorMsg);
			json.put("cartMessage",cartMessage);
			json.put("checkoutRequireLogin",checkoutRequireLogin);
			json.put("allowMultipleCatalogsCheckout",allowMultipleCatalogsCheckout);
			json.put("allowDeliverOutsideDep",allowDeliverOutsideDep);
			json.put("deliverOutsideDepErrorMsg",deliverOutsideDepErrorMsg);
			json.put("shippingFeeStr",shippingFeeStr);
			json.put("hasError",hasError());
			json.put("isEmpty",isEmpty());
			json.put("hasStockError",hasStockError());
			json.put("hasPromoError",hasPromoError());
			json.put("hasDeliveryError",hasDeliveryError());
		}catch(JSONException ex){
			ex.printStackTrace();
		}
		return json;
	}
	
	//these properties are all the columns in cart table
	//etn always return column names in upper case
	//for safe side to make the case same we put them in lowercase and later check in lowercase
	public void addProperty(String key, String val)
	{
		if(this.properties == null) this.properties = new HashMap<String, String>();
		this.properties.put(key.toLowerCase(), val);
	}
	
	public String getProperty(String prop)
	{
		if(this.properties == null || this.properties.size() == 0) return null;
		for(String key : this.properties.keySet())
		{
			//we set in lowercase
			if(key.equals(prop.toLowerCase())) return this.properties.get(key);
		}
		return null;
	}
	
	public boolean hasError()
	{
		if(this.errors != null && this.errors.isEmpty() == false) return true;
		return false;
	}
	
	public boolean isEmpty()
	{
		if(this.items == null || this.items.isEmpty() == true) return true;
		return false;
	}
	
	public CartError getError(String errType)
	{
		if(this.errors == null || this.errors.isEmpty() == true) return null;
		for(CartError err : this.errors)
		{
			if(err.getType().equals(errType)) return err;
		}
		return null;
	}
	
	public boolean hasStockError()
	{
		if(this.errors == null || this.errors.isEmpty() == true) return false;
		for(CartError err : this.errors)
		{
			if(err.getType().equals(CartError.INSUFFICIENT_STOCK)) return true;
		}
		return false;		
	}

	public boolean hasPromoError()
	{
		if(this.errors == null || this.errors.isEmpty() == true) return false;
		for(CartError err : this.errors)
		{
			if(err.getType().equals(CartError.PROMO_ERROR)) return true;
		}
		return false;		
	}

	public boolean hasDeliveryError()
	{
		if(this.errors == null || this.errors.isEmpty() == true) return false;
		for(CartError err : this.errors)
		{
			if(err.getType().equals(CartError.DELIVERY_ERROR)) return true;
		}
		return false;		
	}
	
	public void addError(String errType, String returnUrl)
	{
		addError(errType, null, returnUrl);
	}

	public void addError(String errType, String message, String returnUrl)
	{
		if(this.errors == null) this.errors = new ArrayList<CartError>();
		CartError cErr = new CartError();
		cErr.setType(errType);
		cErr.setMessage(message);
		cErr.setReturnUrl(returnUrl);
		this.errors.add(cErr);
	}

	//getters and setters
    public boolean isAllowMultipleCatalogsCheckout() {
        return allowMultipleCatalogsCheckout;
    }

    public void setAllowMultipleCatalogsCheckout(boolean allowMultipleCatalogsCheckout) {
        this.allowMultipleCatalogsCheckout = allowMultipleCatalogsCheckout;
    }

    public int getArticlesCount() {
        return articlesCount;
    }

    public void setArticlesCount(int articlesCount) {
        this.articlesCount = articlesCount;
    }

    public JSONArray getCalculatedCartDiscounts() {
        return calculatedCartDiscounts;
    }

    public void setCalculatedCartDiscounts(JSONArray calculatedCartDiscounts) {
        this.calculatedCartDiscounts = calculatedCartDiscounts;
    }

    public String getCartMessage() {
        return cartMessage;
    }

    public void setCartMessage(String cartMessage) {
        this.cartMessage = cartMessage;
    }

    public boolean isCheckoutRequireLogin() {
        return checkoutRequireLogin;
    }

    public void setCheckoutRequireLogin(boolean checkoutRequireLogin) {
        this.checkoutRequireLogin = checkoutRequireLogin;
    }

    public String getDefaultCurrency() {
        return defaultCurrency;
    }

    public void setDefaultCurrency(String defaultCurrency) {
        this.defaultCurrency = defaultCurrency;
    }

    public double getDefaultShippingFees() {
        return defaultShippingFees;
    }

    public void setDefaultShippingFees(double defaultShippingFees) {
        this.defaultShippingFees = defaultShippingFees;
    }

    public String getDeliveryDisplayName() {
        return deliveryDisplayName;
    }

    public void setDeliveryDisplayName(String deliveryDisplayName) {
        this.deliveryDisplayName = deliveryDisplayName;
    }

    public List<CartError> getErrors() {
        return errors;
    }

    public void setErrors(List<CartError> errors) {
        this.errors = errors;
    }

    public double getGrandTotal() {
        return grandTotal;
    }

    public void setGrandTotal(double grandTotal) {
        this.grandTotal = grandTotal;
    }

    public double getGrandTotalRecurring() {
        return grandTotalRecurring;
    }

    public void setGrandTotalRecurring(double grandTotalRecurring) {
        this.grandTotalRecurring = grandTotalRecurring;
    }

    public double getGrandTotalRecurringWT() {
        return grandTotalRecurringWT;
    }

    public void setGrandTotalRecurringWT(double grandTotalRecurringWT) {
        this.grandTotalRecurringWT = grandTotalRecurringWT;
    }

    public double getGrandTotalWT() {
        return grandTotalWT;
    }

    public void setGrandTotalWT(double grandTotalWT) {
        this.grandTotalWT = grandTotalWT;
    }

    public List<CartItem> getItems() {
        return items;
    }

    public void setItems(List<CartItem> items) {
        this.items = items;
    }

    public String getLang() {
        return lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getLangColumnPrefix() {
        return langColumnPrefix;
    }

    public void setLangColumnPrefix(String langColumnPrefix) {
        this.langColumnPrefix = langColumnPrefix;
    }

    public String getLangId() {
        return langId;
    }

    public void setLangId(String langId) {
        this.langId = langId;
    }

    public String getMenuUuid() {
        return menuUuid;
    }

    public void setMenuUuid(String menuUuid) {
        this.menuUuid = menuUuid;
    }

    public String getPaymentDisplayName() {
        return paymentDisplayName;
    }

    public void setPaymentDisplayName(String paymentDisplayName) {
        this.paymentDisplayName = paymentDisplayName;
    }

    public double getPaymentFees() {
        return paymentFees;
    }

    public void setPaymentFees(double paymentFees) {
        this.paymentFees = paymentFees;
    }

    public String getPriceFormatter() {
        return priceFormatter;
    }

    public void setPriceFormatter(String priceFormatter) {
        this.priceFormatter = priceFormatter;
    }

    public boolean isPriceTaxIncluded() {
        return priceTaxIncluded;
    }

    public void setPriceTaxIncluded(boolean priceTaxIncluded) {
        this.priceTaxIncluded = priceTaxIncluded;
    }

    public boolean isPromoApplied() {
        return promoApplied;
    }

    public void setPromoApplied(boolean promoApplied) {
        this.promoApplied = promoApplied;
    }

    public String getPromoAppliedType() {
        return promoAppliedType;
    }

    public void setPromoAppliedType(String promoAppliedType) {
        this.promoAppliedType = promoAppliedType;
    }

    public double getPromoValue() {
        return promoValue;
    }

    public void setPromoValue(double promoValue) {
        this.promoValue = promoValue;
    }

    public String getRoundTo() {
        return roundTo;
    }

    public void setRoundTo(String roundTo) {
        this.roundTo = roundTo;
    }

    public double getShippingFees() {
        return shippingFees;
    }

    public void setShippingFees(double shippingFees) {
        this.shippingFees = shippingFees;
    }

    public boolean isShowAmountWithTax() {
        return showAmountWithTax;
    }

    public void setShowAmountWithTax(boolean showAmountWithTax) {
        this.showAmountWithTax = showAmountWithTax;
    }

    public String getShowDecimals() {
        return showDecimals;
    }

    public void setShowDecimals(String showDecimals) {
        this.showDecimals = showDecimals;
    }

    public HashMap<String, Integer> getTaxNumbers() {
        return taxNumbers;
    }

    public void setTaxNumbers(HashMap<String, Integer> taxNumbers) {
        this.taxNumbers = taxNumbers;
    }

    public String getTerms() {
        return terms;
    }

    public void setTerms(String terms) {
        this.terms = terms;
    }

    public String getTermsErrorMsg() {
        return termsErrorMsg;
    }

    public void setTermsErrorMsg(String termsErrorMsg) {
        this.termsErrorMsg = termsErrorMsg;
    }

    public double getTotalCartDiscount() {
        return totalCartDiscount;
    }

    public void setTotalCartDiscount(double totalCartDiscount) {
        this.totalCartDiscount = totalCartDiscount;
    }

    public double getTotalShippingDiscount() {
        return totalShippingDiscount;
    }

    public void setTotalShippingDiscount(double totalShippingDiscount) {
        this.totalShippingDiscount = totalShippingDiscount;
    }

    public double getTotalTax() {
        return totalTax;
    }

    public void setTotalTax(double totalTax) {
        this.totalTax = totalTax;
    }

    public double getTotalTaxRecurring() {
        return totalTaxRecurring;
    }

    public void setTotalTaxRecurring(double totalTaxRecurring) {
        this.totalTaxRecurring = totalTaxRecurring;
    }  
    
    public boolean isAllowDeliverOutsideDep() {
        return allowDeliverOutsideDep;
    }

    public void setAllowDeliverOutsideDep(boolean allowDeliverOutsideDep) {
        this.allowDeliverOutsideDep = allowDeliverOutsideDep;
    }

    public String getDeliverOutsideDepErrorMsg() {
        return deliverOutsideDepErrorMsg;
    }

    public void setDeliverOutsideDepErrorMsg(String deliverOutsideDepErrorMsg) {
        this.deliverOutsideDepErrorMsg = deliverOutsideDepErrorMsg;
    }

    public String getShippingFeeStr() {
        return shippingFeeStr;
    }

    public void setShippingFeeStr(String shippingFeeStr) {
        this.shippingFeeStr = shippingFeeStr;
    }

    public String getMenuId() {
        return menuId;
    }

    public void setMenuId(String menuId) {
        this.menuId = menuId;
    }	
	
    public String getCurrencyCode() {
        return currencyCode;
    }

    public void setCurrencyCode(String currencyCode) {
        this.currencyCode = currencyCode;
    }
	
	public Map<String, Double> getGrandTotalRecurringMap()
	{
		return grandTotalRecurringMap;
	}
	
	public void setGrandTotalRecurringMap(Map<String, Double> grandTotalRecurringMap)
	{
		this.grandTotalRecurringMap = grandTotalRecurringMap;
	}
	 
	public Map<String, Double> getGrandTotalRecurringWTMap()
	{
		return grandTotalRecurringWTMap;
	}
	
	public void setGrandTotalRecurringWTMap(Map<String, Double> grandTotalRecurringWTMap)
	{
		this.grandTotalRecurringWTMap = grandTotalRecurringWTMap;
	}
}