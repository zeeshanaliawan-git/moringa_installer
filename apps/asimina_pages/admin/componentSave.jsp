<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.util.FormRequest, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap,  java.util.UUID, java.io.File, org.apache.commons.fileupload.FileItem, com.etn.asimina.util.ActivityLog,com.etn.asimina.util.FileUtil"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/fileMethods.jsp"%>
<%!
    public void copyOverrideFile(File tempFile, File destFile) throws Exception{
        try{
            if(destFile.exists()){
                destFile.delete();
            }

            copyFile(tempFile, destFile);

            tempFile.delete();
            tempFile = null;
        }
        catch(Exception ex){
            throw new Exception("Error: writing file to disk.",ex);
        }
    }
%>
<%
    String siteId = getSiteId(session);

    String UPLOAD_DIR = GlobalParm.getParm("BASE_DIR") +  GlobalParm.getParm("UPLOADS_FOLDER");

    String COMP_DIR = UPLOAD_DIR + siteId + "/"+ "components/" ;

    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();
    String q = "";
    Set rs = null;

    try{

        File dir = FileUtil.getFile(UPLOAD_DIR);//change
        if(!dir.exists()) {
            throw new Exception("Invalid directory path");
        }

        File compDir = FileUtil.getFile(COMP_DIR);//change
        FileUtil.mkDirs(compDir);//change

        FormRequest formRequest = new FormRequest(this);
        formRequest.parse(request);


        int compId = parseInt(formRequest.getParameter("id"));
        String name = parseNull(formRequest.getParameter("name"));
        //remove all non-alphanumeric characters
        //name = name.replaceAll("[^A-Za-z0-9]","");
        name = name.replaceAll("[^\\p{IsAlphabetic}\\p{Digit}]", "");

        FileItem compFileItem = formRequest.getFile("file");


        if(compId <= 0 && compFileItem == null){
            throw new Exception("Error: Invalid Parameters");
        }



        if(name.length() == 0){
            throw new Exception("Error: name cannot be empty");
        }
        else{
            q = "SELECT id FROM components "
                + " WHERE name = "+ escape.cote(name)
                + " AND site_id = " + escape.cote(siteId);
            if(compId > 0){
                q += " AND id != " + escape.cote("" + compId);
            }
            rs = Etn.execute(q);

            if(rs.next()){
                throw new Exception("Error: Component with same name already exists.");
            }
        }


        String filePath = "";

        if(compFileItem != null){
            String fileName = compFileItem.getName();
            String contentType = compFileItem.getContentType();
            long sizeInBytes = compFileItem.getSize(); //in bytes

            String fileExtension = FileUtil.getFileExtension(fileName);//change

            if(! ".jsx".equalsIgnoreCase(fileExtension) && ! ".js".equalsIgnoreCase(fileExtension)){
                throw new Exception("Error: Unsupported File extension for type");
            }

            //save file to upload dir
            filePath = name + fileExtension;
            File compFile = FileUtil.getFile(COMP_DIR + filePath);//change
            compFileItem.write(compFile);
        }


        colValueHM.clear();
        colValueHM.put("updated_ts","NOW()");
        colValueHM.put("updated_by", ""+Etn.getId());

        if(compId <= 0){


            if(filePath.length() == 0){
                throw new Exception("Error: no file selected.");
            }

            colValueHM.put("site_id", escape.cote(siteId));
            colValueHM.put("name",escape.cote(name));
            colValueHM.put("file_path",escape.cote(filePath));
            colValueHM.put("created_ts", "NOW()");
            colValueHM.put("created_by", ""+Etn.getId());

            q = getInsertQuery("components",colValueHM);
            compId = Etn.executeCmd(q);

            if(compId <= 0){
                throw new Exception("Error in creating new component record");
            }
            else{
                status = STATUS_SUCCESS;
                message = "New component saved";
                data.put("id",""+compId);
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),""+compId,"CREATED","Component",name,siteId);

            }
        }
        else{

            //only update name ,path if new file was uploaded
            if(compFileItem != null){
                colValueHM.put("name", escape.cote(name));
                colValueHM.put("file_path",escape.cote(filePath));
            }

            q = getUpdateQuery("components", colValueHM, " WHERE id = " + escape.cote(""+compId));
            int count = Etn.executeCmd(q);

            if(count <= 0){
                throw new Exception("Error in updating component record");
            }
            else{
                status = STATUS_SUCCESS;
                message = "component saved";
                data.put("id",""+compId);
                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),""+compId,"UPDATED","Component",name,siteId);

            }
        }

        String[] propertyIds = formRequest.getParameterValues("property_id");
        String[] propertyNames = formRequest.getParameterValues("property_name");
        String[] propertyTypes = formRequest.getParameterValues("property_type");
        String[] propertyIsRequireds = formRequest.getParameterValues("property_is_required");

        String[] packageNames = formRequest.getParameterValues("package_name");
        String[] dependencyCompIds = formRequest.getParameterValues("dependency_comp_id");
        String[] libraryIds = formRequest.getParameterValues("library_id");
        String[] compUrlList = formRequest.getParameterValues("comp_url");

        if( areArraysEqualSize(propertyIds, propertyNames, propertyTypes, propertyIsRequireds) ){

            //delete the deleted properties
            ArrayList<String> validPropertyIds = new ArrayList<String>();
            for(int i=0; i<propertyIds.length; i++){
                int propertyId = parseInt(propertyIds[i]);
                if(propertyId > 0){
                    validPropertyIds.add(escape.cote(""+propertyId));
                }
            }
            q = " DELETE FROM component_properties WHERE component_id = " + escape.cote(""+compId);
            if(validPropertyIds.size() > 0){
                q += " AND id NOT IN (" + convertArrayToCommaSeperated(validPropertyIds.toArray()) + " ) ";
            }
            Etn.executeCmd(q);

            for(int i=0; i<propertyIds.length; i++){

                int propertyId = parseInt(propertyIds[i]);
                String propertyName = parseNull(propertyNames[i]);
                String propertyType = parseNull(propertyTypes[i]);
                String propertyIsRequired = parseNull(propertyIsRequireds[i]);

                if(propertyName.length() == 0 || propertyType.length() == 0){
                    continue; //skip, invalid entry
                }

                q = "SELECT id FROM component_properties "
                    + " WHERE component_id = " + escape.cote(""+compId)
                    + " AND name = " + escape.cote(propertyName);
                if(propertyId > 0){
                    q += " AND id != " + escape.cote(""+propertyId);
                }
                rs = Etn.execute(q);
                if(rs.next()){
                    continue; //skip, duplicate
                }

                colValueHM.clear();
                colValueHM.put("component_id",escape.cote(""+compId));
                colValueHM.put("name",escape.cote(propertyName));
                colValueHM.put("type",escape.cote(propertyType));
                colValueHM.put("is_required",escape.cote(propertyIsRequired));

                if(propertyId <= 0){
                    q = getInsertQuery("component_properties", colValueHM);
                    Etn.executeCmd(q);
                }else {
                    q = getUpdateQuery("component_properties", colValueHM, " WHERE id = " + escape.cote(""+propertyId));
                    Etn.executeCmd(q);
                }
            }
        }


        q = " DELETE FROM component_packages WHERE component_id = " + escape.cote(""+compId);
        Etn.executeCmd(q);
        for(String packageName : packageNames){

            if(packageName.trim().length() == 0){
                continue; //skip
            }

            q = " INSERT IGNORE INTO component_packages(component_id, package_name) VALUES ( "
            + escape.cote(""+compId) + ", " + escape.cote(packageName) + ")";
            Etn.executeCmd(q);
        }

        q = " DELETE FROM component_dependencies WHERE dependant_component_id = " + escape.cote(""+compId);
        Etn.executeCmd(q);
        for(String mainCompId : dependencyCompIds){

            if(mainCompId.trim().length() == 0){
                continue; //skip
            }

            q = " INSERT IGNORE INTO component_dependencies(dependant_component_id, main_component_id) VALUES ( "
            + escape.cote(""+compId) + ", " + escape.cote(mainCompId) + ")";
            Etn.executeCmd(q);
        }

        q = " DELETE FROM component_libraries WHERE component_id = " + escape.cote(""+compId);
        Etn.executeCmd(q);
        for(String libraryId : libraryIds){

            if(libraryId.trim().length() == 0){
                continue; //skip
            }

            q = " INSERT IGNORE INTO component_libraries(component_id, library_id) VALUES ( "
            + escape.cote(""+compId) + ", " + escape.cote(libraryId) + ")";
            Etn.executeCmd(q);
        }

        q = " DELETE FROM page_component_urls "
            + " WHERE type = 'component' AND page_item_id = '0' "
            + " AND component_id = " + escape.cote(""+compId);
        Etn.executeCmd(q);
        for(String compUrl : compUrlList){

            if(compUrl.trim().length() == 0){
                continue; //skip
            }

            q = " INSERT IGNORE INTO page_component_urls(type, component_id, page_item_id, url) VALUES ( "
            + " 'component', " + escape.cote(""+compId) + ", '0', " + escape.cote(compUrl) + ")";
            Etn.executeCmd(q);
        }


    }//end try
    catch(Exception e)
    {
        e.printStackTrace();

        status = STATUS_ERROR;
        message = e.getMessage();
    }
    finally{

    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
    out.write(jsonResponse.toString());
%>