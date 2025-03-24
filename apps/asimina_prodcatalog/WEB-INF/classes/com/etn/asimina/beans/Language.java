package com.etn.asimina.beans;

import com.etn.lang.ResultSet.Set;

public class Language {
    private String languageId;
    private String language;
    private String code;
    private String ogLocal;
    private String direction;    
    
    
    public Language(){
    }
    
    public Language(Set rs){
        this.languageId = rs.value("langue_id");
        this.language = rs.value("langue");
        this.code = rs.value("langue_code");
        this.ogLocal = rs.value("og_local");
        this.direction = rs.value("direction");             
    }
    
    public String getLanguageId() {
        return languageId;
    }

    public void setLanguageId(String languageId) {
        this.languageId = languageId;
    }

    public String getLanguage() {
        return language;
    }

    public void setLanguage(String language) {
        this.language = language;
    }

    public String getCode() {
        return code;
    }
    
 
    public void setCode(String code) {
        this.code = code;
    }

    public String getOgLocal() {
        return ogLocal;
    }

    public void setOgLocal(String ogLocal) {
        this.ogLocal = ogLocal;
    }

    public String getDirection() {
        return direction;
    }

    public void setDirection(String direction) {
        this.direction = direction;
    }    
    
}