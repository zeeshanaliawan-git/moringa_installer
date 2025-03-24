package com.etn.asimina.beans;


import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

public class TaxPercentage
{
	public double tax = 0;
	public boolean input_with_tax = false;
	public boolean output_with_tax = false;
	public boolean tax_exclusive = false;	
	
	public JSONObject toJSON(){
		JSONObject json = new JSONObject();
		try{
			json.put("tax",tax);
			json.put("input_with_tax",input_with_tax);
			json.put("output_with_tax",output_with_tax);
			json.put("tax_exclusive",tax_exclusive);
		}catch(JSONException ex){
			ex.printStackTrace();
		}
		return json;
	}
}
