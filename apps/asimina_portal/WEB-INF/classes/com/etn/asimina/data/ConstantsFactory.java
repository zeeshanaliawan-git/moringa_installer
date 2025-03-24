package com.etn.asimina.data;

import com.etn.beans.Contexte;
import com.etn.lang.ResultSet.Set;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import org.json.JSONObject;
import org.json.JSONArray;
import com.etn.beans.app.GlobalParm;
import com.etn.asimina.beans.KeyValuePair;


public class ConstantsFactory{
    private ConstantsFactory(){
		refresh();
	}
    
    public static ConstantsFactory instance = new ConstantsFactory();
    
    Map<String,Map<String,ArrayList<KeyValuePair<String,String>>>> constants = null;
    
    public final void refresh(){
        try{
            constants = new HashMap<>();            
            
            Contexte db = new Contexte();
            Set rs = db.execute("select `group`,`parent_key`,`key`,`value`,`sort_order` from `" + GlobalParm.getParm("COMMONS_DB") + "`.`constants` order by `group`,`parent_key`,`sort_order`,`value`");
            if(rs != null){			
                while(rs.next()){
                    String group = rs.value("group");
                    if(!constants.containsKey(group)){
                        constants.put(group,new HashMap<String,ArrayList<KeyValuePair<String,String>>>());
                    }
                    String parentKey = rs.value("parent_key");
                    if(!constants.get(group).containsKey(parentKey)){
                        constants.get(group).put(parentKey,new ArrayList<KeyValuePair<String,String>>());
                    }
                    constants.get(group).get(parentKey).add(new KeyValuePair<>(rs.value("key"),rs.value("value")));                    
                }
            }		
        }catch(Exception ex){
            ex.printStackTrace();
        }
	}
    
    public Map<String,Map<String,ArrayList<KeyValuePair<String,String>>>> get(String [] groups){
        Map<String,Map<String,ArrayList<KeyValuePair<String,String>>>> current = new HashMap<>();
        for(String group : groups){
            current.put(group,constants.get(group));
        }
        return current;
    }
    
    public Map<String,Map<String,ArrayList<KeyValuePair<String,String>>>> get(){
        return constants;
    }
    
    public List<KeyValuePair<String,String>> get(String group){
		return get(group,"");
	}
	
	public List<KeyValuePair<String,String>> get(String group,String parentKey){
		if(constants.containsKey(group)){
            return constants.get(group).get(parentKey);
        }
        return new ArrayList<>();
	}
    
    public JSONObject getJSON(String [] groups){        
        return new JSONObject(get(groups));
    }
    
    public JSONObject getJSON(){
        return new JSONObject(get());
    }
    
    public JSONArray getJSON(String group){
		return getJSON(group,"");
	}
	
	public JSONArray getJSON(String group,String parentKey){		
        return new JSONArray(get(group,parentKey));
	}
    
    
    public String getOptions(String key,String group){
		return getOptions(key,group,"");
	}
	
	public String getOptions(String key, String group,String parentKey){		
        String options = "";
        List<KeyValuePair<String,String>> constants = get(group,parentKey);
        for(KeyValuePair constant : constants){
            if(constant.getKey().equals(key)){
                options += "<option value='" + constant.getKey() + "' selected>" + constant.getValue() + "</option>";
            }else{
                options += "<option value='" + constant.getKey() + "'>" + constant.getValue() + "</option>";
            }
        }
        return options;
	}
}