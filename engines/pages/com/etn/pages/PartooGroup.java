package com.etn.pages;

import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

public class PartooGroup {
    private int id;
    private String name;
    private List<String> businesses;

    public PartooGroup(int id, String name) {
        this.id = id;
        this.name = name;
        this.businesses = new ArrayList<>();
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<String> getBusinesses() {
        return businesses;
    }

    public void setBusinesses(JSONArray businessIds) {
        for(int i=0;i<businessIds.length();i++)
        {
            this.businesses.add(businessIds.getString(i));
        }
    }

    public boolean hasBusiness(String business) {
        return businesses.contains(business);
    }

    public void addBusiness(String business) {
        businesses.add(business);
    }

    public void removeBusiness(String business) {
        businesses.remove(business);
    }

    public JSONObject getJSON () {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("id", id);
        jsonObject.put("name", name);
        jsonObject.put("business_count", businesses.size());
        jsonObject.put("business_ids", new JSONArray(businesses));
        return jsonObject;
    }
}
