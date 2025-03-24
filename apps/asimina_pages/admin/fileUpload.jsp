<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set,java.text.SimpleDateFormat,java.util.Date,  com.etn.util.FormRequest, org.json.JSONObject, org.json.JSONArray, java.io.File, java.util.LinkedHashMap, org.apache.commons.fileupload.FileItem, com.etn.asimina.util.ActivityLog,java.util.UUID,com.etn.asimina.util.FileUtil"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%!

%>
<%

    // NOTE:
    // This fileUpload is used for all types of file upload
    // from media libary to upload media files like images, video, other ( pdf, doc, etc)
    // from files screen  to upload  css, js and font files

    String selectedSiteId = getSiteId(session);
    String UPLOAD_DIR = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("UPLOADS_FOLDER");

    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    String q = "";
    Set rs = null;

    try {

        File dir = FileUtil.getFile(UPLOAD_DIR);//change
        if (!dir.exists()) {
            throw new Exception("Invalid upload directory path");
        }

        UPLOAD_DIR += selectedSiteId + "/";

        long CONFIG_MAX_FILE_UPLOAD_SIZE = parseLong(getMaxFileUploadSize("default"));
        long CONFIG_MAX_FILE_UPLOAD_SIZE_OTHER = parseLong(getMaxFileUploadSize("other"));
        long CONFIG_MAX_FILE_UPLOAD_SIZE_VIDEO = parseLong(getMaxFileUploadSize("video"));

        // get max possible size
        long maxFileSize = 30 * 1024 * 1024;
        if(maxFileSize < CONFIG_MAX_FILE_UPLOAD_SIZE ){
            maxFileSize = CONFIG_MAX_FILE_UPLOAD_SIZE;
        }
        if(maxFileSize < CONFIG_MAX_FILE_UPLOAD_SIZE_OTHER ){
            maxFileSize = CONFIG_MAX_FILE_UPLOAD_SIZE_OTHER;
        }
        if(maxFileSize < CONFIG_MAX_FILE_UPLOAD_SIZE_VIDEO ){
            maxFileSize = CONFIG_MAX_FILE_UPLOAD_SIZE_VIDEO;
        }

        FormRequest formRequest = new FormRequest(this);
        formRequest.setMaxFileSize( maxFileSize );
        formRequest.parse(request);

        int fileId = parseInt(formRequest.getParameter("id"));
        String origFileName = parseNull(formRequest.getParameter("name"));
        String label = parseNull(formRequest.getParameter("label"));
        String fileType = parseNull(formRequest.getParameter("fileType"));

        String altName = parseNull(formRequest.getParameter("altName"));
        String mediaTags = parseNull(formRequest.getParameter("mediaTags"));
        String description = parseNull(formRequest.getParameter("description"));
        String removalDate = parseNull(formRequest.getParameter("removalDate"));
        String updateThumbnailVar = parseNull(formRequest.getParameter("updateThumbnailVar"));
        String thumbnailName = parseNull(formRequest.getParameter("thumbnailName"));
        FileItem thumbnail = formRequest.getFile("thumbnail");


        String fileName = getSafeFileName(origFileName);

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMddHHmmss");

        FileItem fileItem = formRequest.getFile("file");

        String[] allowedFileTypes = PagesUtil.getAllowedFileTypes(fileType);

        if(allowedFileTypes.length == 0){
            throw new Exception("Error: Invalid Parameters");
        }

        boolean isMediaUpload = isMediaType(fileType);

        if(isMediaUpload){

            if(label.length() == 0){
                throw new Exception("Error: label cannot be empty");
            }

        }

        if(!isMediaUpload || fileId <= 0){
            //non media file upload rules , js/css/fonts

            if(fileItem == null){
                throw new Exception("Error: no file uploaded.");
            }

            if(fileId < 0 || fileName.length() == 0){
                throw new Exception("Error: Invalid Parameters");
            }
        }

        String fileExtension = "";
        fileExtension = FileUtil.getFileExtension(fileName).replace(".", "");//change

        boolean fileTypeFound = false;
        if (allowedFileTypes.length > 0) {
            for (String curAllowedType : allowedFileTypes) {
                if (curAllowedType.equals(fileExtension.toLowerCase())) {
                    fileTypeFound = true;
                    break;
                }
            }
        }
        if (!fileTypeFound) {
            throw new Exception("Error: Unsupported File extension for type '" + fileType + "' ");
        }

        int themeVersion = 0;
        int themeId = 0;
        // locked theme check
        q = "SELECT th.status theme_status, f.theme_id, f.theme_version FROM files f  "
            + " LEFT JOIN themes th ON th.id = f.theme_id"
            + " WHERE f.file_name = " + escape.cote(fileName)
            + " AND f.type = " + escape.cote(fileType)
            + " AND f.site_id = " + escape.cote(selectedSiteId);
        rs = Etn.execute(q);
        if (rs.next()) {
            if(rs.value("theme_status").equals(Constant.THEME_LOCKED) && !isSuperAdmin(Etn)){
                throw new Exception("Only super admin can update this file");
            } else{
                themeId = parseInt(rs.value("theme_id"));
                themeVersion = parseInt(rs.value("theme_version"));
            }
        }
        if(isMediaUpload){
            if(fileId > 0){
                q = "SELECT file_name, type FROM files "
                + " WHERE file_name = " + escape.cote(fileName)
                + " AND type = " + escape.cote(fileType)
                + " AND site_id = " + escape.cote(selectedSiteId);
                rs = Etn.execute(q);
                if (rs.next()) {
                    fileName = rs.value("file_name");
                    fileType = rs.value("type");
                }

            }
            else{
                q = "SELECT id FROM files "
                + " WHERE file_name = " + escape.cote(fileName)
                + " AND type = " + escape.cote(fileType)
                + " AND site_id = " + escape.cote(selectedSiteId);
                rs = Etn.execute(q);
                if (rs.next()) {
                    fileId = parseInt(rs.value("id"));
                }
            }
        }
        else{
            q = "SELECT id FROM files "
            + " WHERE file_name = " + escape.cote(fileName)
            + " AND site_id = " + escape.cote(selectedSiteId) + " and type = " + escape.cote(fileType);
            if (fileId > 0) {
                q += " AND id != " + escape.cote("" + fileId);
            }
            rs = Etn.execute(q);
            if (rs.next()) {
                fileId = parseInt(rs.value("id"));
            }
        }

        File destDir = FileUtil.getFile(UPLOAD_DIR + fileType + "/");//change
        FileUtil.mkDirs(destDir);//change
        
        File destFile = FileUtil.getFile(UPLOAD_DIR + fileType + "/" + fileName);//change

        String fileSize = "";
        if(fileItem != null){
            fileItem.write(destFile);
            long sizeInBytes = fileItem.getSize();
            fileSize = convertBytesToKilobytes(sizeInBytes);
        }

        if(thumbnail != null){
            int lastIndex = thumbnailName.lastIndexOf(".");
            if (lastIndex != -1) {
                thumbnailName = UUID.randomUUID().toString()+"."+thumbnailName.substring(lastIndex + 1);
            }else{
                thumbnailName =  UUID.randomUUID().toString();
            }

            File thumbnailDir = FileUtil.getFile(UPLOAD_DIR + "thumbnail" + "/");//change
            FileUtil.mkDirs(thumbnailDir);//change
            

            File thumbnailDestFile = FileUtil.getFile(UPLOAD_DIR + "thumbnail" + "/" + thumbnailName);//change
            thumbnail.write(thumbnailDestFile);
        }

        LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();
        colValueHM.put("label",escape.cote(label));
        colValueHM.put("updated_ts","NOW()");
        colValueHM.put("updated_by", escape.cote("" + Etn.getId()) );
        colValueHM.put("alt_name", escape.cote(altName));
        colValueHM.put("description", escape.cote(description));
        if(removalDate.length()==0){
            removalDate=null;
        }
        colValueHM.put("removal_date", escape.cote(removalDate));
        if(thumbnailName.length()>0 || updateThumbnailVar.equals("1")){
            colValueHM.put("thumbnail", escape.cote(thumbnailName));
        }

        if (fileId == 0) {
            colValueHM.put("file_name", escape.cote(fileName));
            colValueHM.put("type", escape.cote(fileType));
            colValueHM.put("file_size", escape.cote(fileSize));
            colValueHM.put("created_ts","NOW()");
            colValueHM.put("created_by", escape.cote("" + Etn.getId()) );
            colValueHM.put("site_id", selectedSiteId);
            q = getInsertQuery("files", colValueHM);

            fileId = Etn.executeCmd(q);
            if (fileId <= 0) {
                throw new Exception("Error in inserting record. Please try again.");
            }else{
                Etn.executeCmd("delete from media_tags where file_id="+escape.cote("" + fileId));
                if(mediaTags.length()>0){
                    String[] tagsArray = mediaTags.split(",");
                    for(int i=0;i<tagsArray.length;i++){
                        Etn.executeCmd("insert into media_tags (file_id,tag) values ("+escape.cote("" + fileId)+", "+escape.cote(tagsArray[i])+")");
                    }
                }
            }

            status = STATUS_SUCCESS;
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),fileId+"","UPLOADED","Media Library",fileName, selectedSiteId);
            data.put("id", fileId);

        }
        else {
            //update existing
            if(themeId>0){ // part of a theme
                themeVersion = themeVersion + 1;
                colValueHM.put("theme_version", themeVersion+"");
            }

            if(fileSize.length() > 0){
                colValueHM.put("file_size", escape.cote(fileSize));

                if("img".equals(fileType)){
                    colValueHM.put("images_generated","'0'");
                }
            }

            if(thumbnail!=null || updateThumbnailVar.equals("1")){
                Set rsThumbnail = Etn.execute("select thumbnail from files where id="+escape.cote("" + fileId));
                if(rsThumbnail.next() && parseNull(rsThumbnail.value("thumbnail")).length()>0){

                    File fileToDelete = FileUtil.getFile(UPLOAD_DIR + "thumbnail" + "/" +parseNull(rsThumbnail.value("thumbnail")));//change
                    if (fileToDelete.exists()) {
                        boolean deleted = fileToDelete.delete();
                        if (!deleted) {
                            message = " Could not update thumbnail due to some error.";
                            File rollBackThumbnail = FileUtil.getFile(UPLOAD_DIR + "thumbnail" + "/" + thumbnailName);//change
                            if (rollBackThumbnail.exists()) {
                                rollBackThumbnail.delete();
                            }
                        }
                    }
                }
            }

            q = getUpdateQuery("files",colValueHM, " WHERE id = " + escape.cote("" + fileId) + " AND site_id = " + escape.cote(selectedSiteId));
            int flag = Etn.executeCmd(q);
            if (flag <= 0) {
                throw new Exception("Error in updating record. Please try again.");
            }else{
                Etn.executeCmd("delete from media_tags where file_id="+escape.cote("" + fileId));
                if(mediaTags.length()>0){
                    String[] tagsArray = mediaTags.split(",");
                    for(int i=0;i<tagsArray.length;i++){
                        Etn.executeCmd("insert into media_tags (file_id,tag) values ("+escape.cote("" + fileId)+", "+escape.cote(tagsArray[i])+")");
                    }
                }
            }
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),fileId+"","UPDATED","Media Library",fileName, selectedSiteId);

            status = STATUS_SUCCESS;
            data.put("id", fileId);

            if ("css".equals(fileType) || "js".equals(fileType)) {
                markPagesToGenerate("" + fileId, "files", Etn);
            }
        }

        if(status == STATUS_SUCCESS && "img".equals(fileType)){
            try{
                generateImages(""+fileId, Etn);
            }
            catch(Exception ex){
                ex.printStackTrace();
            }
        }

    }//end try
    catch (Exception e) {
        e.printStackTrace();
        status = STATUS_ERROR;
        message = e.getMessage();
    }
    finally {
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status", status);
    jsonResponse.put("message", message);
    jsonResponse.put("data", data);
    out.write(jsonResponse.toString());
%>