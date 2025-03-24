package com.etn.util;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.ServletContext;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.io.File;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

public class FormRequest {

    protected HttpServlet servlet;
    protected Map<String, FileItem> files = new HashMap<String, FileItem>();
    protected Map<String, List<String>> params = new HashMap<String, List<String>>();
    protected boolean filesAreValid = true;
    protected List<String> validFileTypes;
    protected long maxFileSize = 5242880;

    public FormRequest(HttpServlet jsp) {
        this.servlet = jsp;
        this.validFileTypes = new ArrayList<String>();
    }

    public FormRequest(HttpServlet jsp, List<String> validFileTypes) {
        this.servlet = jsp;
        this.validFileTypes = validFileTypes;
    }

    public void setMaxFileSize(long maxFileSize) {
        this.maxFileSize = maxFileSize;
    }

    public void parse(HttpServletRequest request) throws Exception {
        DiskFileItemFactory factory = new DiskFileItemFactory();

        // Configure a repository (to ensure a secure temp location is used)
        ServletContext servletContext = servlet.getServletConfig().getServletContext();
        File repository = (File) servletContext.getAttribute("javax.servlet.context.tempdir");
        factory.setRepository(repository);

        // Create a new file upload handler
        ServletFileUpload upload = new ServletFileUpload(factory);

        // Parse the request
        List<FileItem> items = upload.parseRequest(request);

        for (FileItem item : items) {
            String name = item.getFieldName();
            if (item.isFormField()) {
                String value = item.getString("UTF-8");
                if (!params.containsKey(name)) {
                    params.put(name, new ArrayList<String>());
                }
                params.get(name).add(value);
            }
            else {
                long fileSize = item.getSize();
                String fileType = item.getContentType();
                boolean fileIsValid = (fileSize < this.maxFileSize)
                    && (isValidFileType(fileType));

                if (fileIsValid) {
                    if (item.getSize() > 0 && item.getName().length() > 0) {
                        files.put(name, item);
                    }
                }
                else {
                    this.filesAreValid = false;
                }
            }
        }
    }

    protected boolean isValidFileType(String fileType) {
        boolean retVal = true;
        if (this.validFileTypes != null && this.validFileTypes.size() > 0) {
            retVal = false;
            for (String validFileType : this.validFileTypes) {
                if (validFileType.equals(fileType)) {
                    retVal = true;
                    break;
                }
            }
        }
        return retVal;
    }

    public String getParameter(String name) {
        if (params.containsKey(name) && params.get(name).size() == 1) {
            return params.get(name).get(0);
        }
        return "";
    }

    public String[] getParameterValues(String name) {
        if (params.containsKey(name)) {
            return params.get(name).toArray(new String[params.get(name).size()]);
        }
        return new String[0];
    }

    public Map<String, List<String>> getParameterMap() {
        return params;
    }

    public Set<String> keySet() {
        return params.keySet();
    }

    public FileItem getFile(String fieldName) {
        if (files.containsKey(fieldName)) {
            return files.get(fieldName);
        }
        return null;
    }

    public Map<String, FileItem> getFilesMap() {
        return this.files;
    }

    public boolean areFilesValid() {
        return filesAreValid;
    }
}
