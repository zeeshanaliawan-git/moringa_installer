package com.etn.asimina.data;

import com.etn.beans.Contexte;
import com.etn.lang.ResultSet.Set;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import com.etn.asimina.beans.Language;
import org.json.JSONObject;
import org.json.JSONArray;


public class LanguageFactory{
    
    private LanguageFactory(){
		refresh();
	}
    public static LanguageFactory instance = new LanguageFactory();
    
    private List<Language> languages = null;    
    
    public final void refresh(){
        try{
            languages = new ArrayList<>();                            
            Contexte db = new Contexte();
            Set rs = db.execute("select `langue_id`,`langue`,`langue_code`,`og_local`,`direction` from `language` order by `langue_id`");
            if(rs != null){			
                while(rs.next()){                    
                    Language l = new Language(rs);
                    if(l != null){
                        languages.add(l);                             
                    }
                }
            }		
        }catch(Exception ex){
            ex.printStackTrace();
        }
	}
    
    public List<Language> get(){
        return languages;
    }
    
    public JSONArray getJSON(){
        return new JSONArray(get());
    }
 
    public Language getLanguage(String code){
        for(Language l : languages){
            if(l.getCode().equals(code)){
                return l;
            }
        }
        return null;
    }
 
    public Language getDefaultLanguage(){
        for(Language l : languages){
            if("1".equals(l.getLanguageId())){
                return l;
            }
        }
        return null;
    } 

    public Language getLanguageOrDefault(String code){
        Language l = getLanguage(code);
        if(l == null){
            return getDefaultLanguage();
        }
        return l;
    }
}
    