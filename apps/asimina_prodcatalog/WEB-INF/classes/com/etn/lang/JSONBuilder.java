/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.etn.lang;

import java.util.List;
import java.lang.StringBuilder;
/**
 *
 * @author Ali Bin Jamil
 */
public class JSONBuilder {
    private StringBuilder json = null;
    public JSONBuilder(){   
        json = new StringBuilder();
    }
    
    public JSONBuilder startObject(){
        json.append("{");
        return this;
    }
    
    public JSONBuilder endObject(){
        json.append("}");
        return this;
    }
    
    public JSONBuilder startArray(){
        json.append("[");
        return this;
    }
    
    public JSONBuilder endArray(){
        json.append("]");
        return this;
    }
    
    public JSONBuilder addDelimiter (){
        json.append(",");
        return this;
    }
    
    public JSONBuilder add(String key, String value){
        json.append("\"").append(key).append("\"").append(":").append("\"").append(value).append("\"");
        return this;
    }    
    public JSONBuilder add(String key, boolean value){
        json.append("\"").append(key).append("\"").append(":").append(value);
        return this;
    }
    
    public JSONBuilder add(String key, int value){
        json.append("\"").append(key).append("\"").append(":").append(value);
        return this;
    }
	
    public JSONBuilder add(String key, JSONBuilder jsonBuilder){
        json.append("\"").append(key).append("\"").append(":").append(jsonBuilder.toString());
        return this;
    }
	
	public JSONBuilder add(String value){
        json.append("\"").append(value).append("\"");
        return this;
    }
	public JSONBuilder add(int value){
        json.append(value);
        return this;
    }
	public JSONBuilder add(boolean value){
        json.append(value);
        return this;
    }


	
    public JSONBuilder so(){
        return this.startObject();
    }
    
    public JSONBuilder eo(){
        return this.endObject();
    }
    
    public JSONBuilder d(){
        return this.addDelimiter();
    }
    
    public JSONBuilder sa(){
        return this.startArray();
    }
    
    public JSONBuilder ea(){
        return this.endArray();
    }
    
    public JSONBuilder a(String key,String value){
        return this.add(key, value);
    }
    
    public JSONBuilder a(String key,boolean value){
        return this.add(key, value);
    }
    public JSONBuilder a(String key,int value){
        return this.add(key, value);
    }
	public JSONBuilder a(String key, JSONBuilder jsonBuilder){
        return this.add(key,jsonBuilder);
    }
	
	public JSONBuilder a(String value){        
        return this.add(value);
    }
	public JSONBuilder a(int value){
        return this.add(value);
    }
	public JSONBuilder a(boolean value){
        return this.add(value);
    }

    @Override
    public String toString(){
       return json.toString();        
    }
}
