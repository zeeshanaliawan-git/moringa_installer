package com.etn.asimina.beans;

import java.util.Map;
import java.util.HashMap;

import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import com.etn.asimina.util.PortalHelper;

public class CartItem
{
	private Map<String, String> properties;
	
	private ProductVariant variant;
	private int position;
	
	private boolean available = true;
	
	public JSONObject toJSON(){
		JSONObject json = new JSONObject(properties);
		try{
			json.put("variant",variant.toJSON());
			json.put("position",position);
			json.put("available",available);
		}catch(JSONException ex){
			ex.printStackTrace();
		}
		return json;
	}
	 
	//these properties are all the columns in cart_items table
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

	//getter setter
    public void setProperties(Map<String, String> properties) {
        this.properties = properties;
    }

    public ProductVariant getVariant() {
        return variant;
    }

    public void setVariant(ProductVariant variant) {
        this.variant = variant;
    }

    public boolean isAvailable() {
        return available;
    }

    public void setAvailable(boolean available) {
        this.available = available;
    }	

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }

	public boolean isProduct()
	{
		return PortalHelper.isProduct(this.getVariant().getProductType());
	}

	public boolean isOffer()
	{
		return PortalHelper.isOffer(this.getVariant().getProductType());
	}
	
	public String getProductType()
	{
		//for v2 products, we have new product types which we consider to be either offer or product
		//so this function will return either its product or offer else return the actual product type of product
		String productType = this.getVariant().getProductType();
		if("product".equals(productType) || "simple_product".equals(productType) || "configurable_product".equals(productType)) return "product";
		//in v2 products we dont have any concept of prepaid or postpaid offers so we just return offer
		if("offer_prepaid".equals(productType) || "offer_postpaid".equals(productType) || "simple_virtual_product".equals(productType) || "configurable_virtual_product".equals(productType)) return "offer";
		
		return productType;
	}
	
	public boolean hasFrequency()
	{
		//for v1 products when its offer_postpaid or offer_prepaid that has frequency always
		//for v2 we check if frequency length is greater than 0 means frequency is set for any type of product
		
		String productType = this.getVariant().getProductType();		
		if("offer_postpaid".equals(productType) || "offer_prepaid".equals(productType)) return true;
		if(this.getVariant().getFrequency().length() > 0) return true;
		return false;
	}
}