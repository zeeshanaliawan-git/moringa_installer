package com.etn.asimina.util;

import javax.servlet.http.HttpServlet;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import org.apache.commons.fileupload.FileItem;
import javax.servlet.http.HttpServletRequest;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import javax.servlet.ServletContext;
import java.io.File;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

public class ParseFormRequest{
	private HttpServlet servlet;
	private List<FileItem> files = new ArrayList<FileItem>();
	private Map<String,List<String>> params = new HashMap<String,List<String>>();
	private boolean filesAreValid = true;
	
	public ParseFormRequest(HttpServlet jsp){
		this.servlet = jsp;
	}
	public void parse(HttpServletRequest request) throws Exception{
		DiskFileItemFactory factory = new DiskFileItemFactory();

		// Configure a repository (to ensure a secure temp location is used)
		ServletContext servletContext = servlet.getServletConfig().getServletContext();
		File repository = (File) servletContext.getAttribute("javax.servlet.context.tempdir");
		factory.setRepository(repository);

		// Create a new file upload handler
		ServletFileUpload upload = new ServletFileUpload(factory);

		// Parse the request
		List<FileItem> items = upload.parseRequest(request);			
		
		for(FileItem item : items){
			if(item.isFormField()){				
				String name = item.getFieldName();
				String value = com.etn.util.XSSHandler.clean(item.getString("UTF-8"));
				if(!params.containsKey(name)){
					params.put(name,new ArrayList<String>());
				}
				params.get(name).add(value);				
			}else{
				long fileSize = item.getSize();
				String fileType = item.getContentType();
				boolean fileIsValid = true;
				if(fileSize > 5242880){
					filesAreValid = false;
					fileIsValid = false;
				}
				if(isValidFileType(fileType) == false){
					filesAreValid = false;
					fileIsValid = false;
				}
				if(fileIsValid){
					files.add(item);
				}
			}			
		}
	}
    
    private boolean isValidFileType(String fileType){
		switch(fileType){			
			case "image/jpeg":
			case "image/jpg":
			case "image/gif":
			case "image/bmp":
			case "image/png":
				return true;
		}
		return false;
	}
    
    public String getParameter(String name){
		if(params.containsKey(name) && params.get(name).size() == 1){
			return params.get(name).get(0);
		}
		return "";
	}
    
    public String [] getParameterValues(String name){
        if(params.containsKey(name)){
            return params.get(name).toArray(new String[params.get(name).size()]);
        }
        return new String[0];
    }
    
    public Map<String,List<String>> getParameterMap(){
        return params;
    }
    
    public Set<String> keySet(){
        return params.keySet();
    }
    
    public boolean areFilesValid(){
		return filesAreValid;
	}
}    