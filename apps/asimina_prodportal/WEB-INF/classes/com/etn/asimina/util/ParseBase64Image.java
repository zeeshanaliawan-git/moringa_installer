package com.etn.asimina.util;

import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.io.FileOutputStream;
import javax.xml.bind.DatatypeConverter;
import java.nio.file.Files;
import java.nio.file.Paths;

public class ParseBase64Image{
    byte [] content;
    String contentType;
    
    public ParseBase64Image(){
    }
    
    public void parse(String base64Image){
        
        String patternString = "data:(image\\/[^;]*);base64,?";

        Pattern pattern = Pattern.compile(patternString);
        Matcher matcher = pattern.matcher(base64Image);
        
        if(matcher.find()){
            this.content = DatatypeConverter.parseBase64Binary(base64Image.replaceFirst(matcher.group(0),""));
            this.contentType = matcher.group(1);
        }
    }
    
    public byte[] getContent(){
        return content;
    }
    
    public String getContentType(){
        return contentType;
    }
    
    public void saveContent(String path){
        FileOutputStream fos = null;
        try{
            fos = new FileOutputStream(path);
            fos.write(content);               
        }catch(Exception ex){
            ex.printStackTrace();
        }finally{
            try{
                if(fos != null) fos.close();
            }catch(Exception ex){
                ex.printStackTrace();
            }
        }
    }
    
    public static String getBase64Image(String path,String contentType){
        try{
            byte[] fileContent = Files.readAllBytes(Paths.get(path));
            String content = DatatypeConverter.printBase64Binary(fileContent);
            return "data:" + contentType + ";base64," + content;
        }catch(Exception ex){            
            ex.printStackTrace();
            return "";
        }        
    }
    
}