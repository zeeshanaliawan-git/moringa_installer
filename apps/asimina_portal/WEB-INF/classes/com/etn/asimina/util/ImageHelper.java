package com.etn.asimina.util;

import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.io.FileOutputStream;
import javax.xml.bind.DatatypeConverter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;
import java.nio.file.Files;
import com.etn.beans.app.GlobalParm;

public abstract class ImageHelper{
    private String imageDirectory = null;
    private byte [] content;
    private String contentType;
    
    private ImageHelper(){
    }
    
    public ImageHelper(String pathConstant,String productId){
        try{
            String uploadDirectory = GlobalParm.getParm(pathConstant);   
            if(uploadDirectory != null){
                uploadDirectory += productId + "/";        
                Path path = Paths.get(uploadDirectory);
                if (!Files.exists(path)) {            
                    Files.createDirectories(path);
                } 
                imageDirectory = uploadDirectory;
            }
        }catch(Exception ex){
            ex.printStackTrace();            
        }
    }
    
    public void saveBase64(String base64Image,String fileName){        
        try{
            if(imageDirectory != null){            
                String patternString = "data:(image\\/[^;]*);base64,?";
                Pattern pattern = Pattern.compile(patternString);
                Matcher matcher = pattern.matcher(base64Image);        
                if(matcher.find()){
                    byte [] content = DatatypeConverter.parseBase64Binary(base64Image.replaceFirst(matcher.group(0),""));            
                    Path path = Paths.get(imageDirectory + fileName);
                    Files.write(path, content);
                }
            }
        }catch(Exception ex){
            ex.printStackTrace();
        }
    }
    
    private String getExtension(String fileName){
        String extension = "";
        int i = fileName.lastIndexOf('.');
        if (i > 0) {
            extension = fileName.substring(i+1);
        }
        return extension;
    }
    
    private String getContentType(String fileName){
        return "image/" + getExtension(fileName);
    }
    
    public String getBase64Image(String fileName){
        try{
            if(imageDirectory != null){
                Path path = Paths.get(imageDirectory + fileName);
                if(Files.exists(path) && Files.isRegularFile(path)){
                    byte[] fileContent = Files.readAllBytes(path);
                    String content = DatatypeConverter.printBase64Binary(fileContent);
                    return "data:" + getContentType(fileName) + ";base64," + content;
                }else{
                    return "";
                }
            }
            return "";
        }catch(Exception ex){            
            ex.printStackTrace();
            return "";
        }        
    }
    
    public String getImageDirectory(){
        return imageDirectory;
    }
}

