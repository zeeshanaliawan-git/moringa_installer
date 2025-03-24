package com.etn.asimina.beans;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

public class CartError
{
	public static final String INSUFFICIENT_STOCK = "INSUFFICIENT_STOCK";
	public static final String EMPTY_CART = "EMPTY_CART";
	public static final String PROMO_ERROR = "PROMO_ERROR";
	public static final String DELIVERY_ERROR = "DELIVERY_ERROR";
	
	private String _type;
	private String returnUrl;
	private String message;
	
	JSONObject toJSON(){
		JSONObject json = new JSONObject();
		try{
			json.put("type",_type);
			json.put("returnUrl",returnUrl);
			json.put("message",message);
		}catch(JSONException ex){
			ex.printStackTrace();
		}
		return json;
	}

    public String getType() {
        return _type;
    }

    public void setType(String _type) {
        this._type = _type;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getReturnUrl() {
        return returnUrl;
    }

    public void setReturnUrl(String returnUrl) {
        this.returnUrl = returnUrl;
    }

}
