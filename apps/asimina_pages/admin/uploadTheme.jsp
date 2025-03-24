<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set,  com.etn.util.FormRequest, java.io.File, java.util.LinkedHashMap, org.apache.commons.fileupload.FileItem, java.nio.file.Path, java.nio.file.Paths, java.nio.file.Files, java.nio.file.StandardCopyOption, org.apache.commons.compress.archivers.ArchiveEntry, org.apache.commons.compress.compressors.gzip.GzipCompressorInputStream, org.apache.commons.compress.archivers.tar.TarArchiveInputStream, org.apache.commons.compress.utils.IOUtils, java.util.regex.Pattern,com.etn.asimina.util.FileUtil"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%!
    public Path createFileInDirectory(ArchiveEntry entry,Path targetDir)
        throws IOException {
      Path targetDirResolved = targetDir.resolve(entry.getName());
      Path normalizePath = targetDirResolved.normalize();

      if (!normalizePath.startsWith(targetDir)) {
        throw new IOException(" The compressed file has been damaged : " + entry.getName());
      }
      return normalizePath;
    }

    public boolean isValidExtension(String[] fileTypes ,String ext) throws IOException{
       HashSet<String> set ;
       boolean isValid = false;
       for(String type: fileTypes){
            set = new HashSet<>(Arrays.asList(PagesUtil.ALLOWED_FILETYPES.get(type)));
            if(set.contains(ext)){
                 isValid = true;
                 break;
            }
        }
        return isValid;
    }
%>
<%
    String selectedSiteId = getSiteId(session);
    String TEMP_DIR = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("UPLOADS_FOLDER")+"temp";

    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    String q = "";
    Set rs = null;
    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();
    int pid = Etn.getId();
    String siteId = getSiteId(session);

    try {
        File dir = FileUtil.getFile(TEMP_DIR);//change
        if (!dir.exists()) {
            dir = FileUtil.mkDir(TEMP_DIR);
        }
        FormRequest formRequest = new FormRequest(this);
        formRequest.setMaxFileSize(50000000);  // 50 MB
        formRequest.parse(request);

        FileItem fileItem = formRequest.getFile("inputThemeFile");

        String  reqeustType = formRequest.getParameter("requestType");

        if(fileItem == null){
            throw new Exception("Error: no file uploaded.");
        }

        String fileName =  fileItem.getName();
        fileName =  fileName.replaceAll("/", "").replaceAll("\\\\", "");
        String fileExtension = "";

        int dotIndex = fileName.lastIndexOf(".");
        if (dotIndex > 0 && (dotIndex + 1) < fileName.length()) {
            fileExtension = parseNull(fileName.substring(dotIndex + 1));
        }
        
        if(!fileExtension.equals("gz")){
            throw new Exception("Error: Unsupported File extension");
        }

        
        File destDir = FileUtil.getFile(TEMP_DIR);//change
        FileUtil.mkDirs(destDir);//change
        
        String tempFilePath = TEMP_DIR +File.separator + fileName;
        File tempFolder = FileUtil.getFile(tempFilePath);//change

        // save file to temp dir
        fileItem.write(tempFolder);

        // untar the file
         Path source = Paths.get(tempFilePath);
         // Where is the decompression
         Path target = Paths.get(tempFilePath);

         if (Files.notExists(source)) {
            throw new IOException(" The file you want to extract does not exist ");
         }
        HashSet<String> themeContents = new HashSet<>(Arrays.asList("files", "libraries", "media", "templates", "system templates", "page templates"));
        boolean flag = false;
        String themeFolderPath = "";
        boolean foundThemeFile = false;
        try (InputStream fi = Files.newInputStream(source);
               BufferedInputStream bi = new BufferedInputStream(fi);
               GzipCompressorInputStream gzi = new GzipCompressorInputStream(bi);
               TarArchiveInputStream ti = new TarArchiveInputStream(gzi))
       {
            BufferedReader br = null;
            StringBuilder sb = new StringBuilder();
            ArchiveEntry entry;
            Path themeFolder = null;

            while ((entry = ti.getNextEntry()) != null) {

                if(!entry.isDirectory() &&  entry.getName().equalsIgnoreCase("theme.json")){
                    foundThemeFile = true;
                    byte[] buf = new byte[(int) entry.getSize()];
                    int readed  = IOUtils.readFully(ti, buf);

                    //readed should equal buffer size
                    if(readed != buf.length) {
                        throw new RuntimeException("Read bytes count and entry size differ");
                    }

                    String theme = new String(buf, StandardCharsets.UTF_8);

                    try{
                        JSONObject themeObject = new JSONObject(theme);
                        String name = themeObject.getString("name");
                        String version = themeObject.getString("version");
                        String description = themeObject.getString("description");
                        String themeStatus = themeObject.getString("status");
                        String asimina_version = themeObject.getString("asimina_version");

                        String pattern = "^[1-9]\\d*(\\.[0-9]\\d*){2}$";
                        boolean matches = Pattern.matches(pattern, version);
                        String[] minAsiminaVersion =  GlobalParm.getParm("MIN_ASIMINA_VERSION").split("\\.");
                        String[] themeAsiminaVersion =  asimina_version.split("\\.");
                        boolean versionAcceptable = false;

                        if(parseInt(themeAsiminaVersion[0]) > parseInt(minAsiminaVersion[0])){
                            versionAcceptable = true;
                        } else if(parseInt(themeAsiminaVersion[0]) == parseInt(minAsiminaVersion[0])){
                             if(parseInt(themeAsiminaVersion[1]) > parseInt(minAsiminaVersion[1])){
                                    versionAcceptable = true;
                             } else if(parseInt(themeAsiminaVersion[1]) == parseInt(minAsiminaVersion[1])){
                                 if(parseInt(themeAsiminaVersion[2]) >= parseInt(minAsiminaVersion[2])){
                                     versionAcceptable = true;
                                 }
                             }
                        }
                        q = "SELECT id FROM themes"
                        + " WHERE name = "+ escape.cote(name)
                        + " AND version = "+escape.cote(version)
                        + " AND site_id = "+escape.cote(siteId);
                        rs = Etn.execute(q);

                        if(rs.next()){
                            message = "Theme of name "+name+" and version "+version +" already exsits";
                        } else if(!matches){
                            message = "Invalid version pattern";
                        } else if(!versionAcceptable){
                            message = "Theme needs to be updated to app version "+GlobalParm.getParm("MIN_ASIMINA_VERSION");
                            message += ". Minimum required version is "+GlobalParm.getParm("MIN_ASIMINA_VERSION")
                                    + " and current theme supports version of "+asimina_version;
                        } else{
                            String themeUuid  = getUUID();
                            colValueHM.put("name", escape.cote(name));
                            colValueHM.put("uuid", escape.cote(themeUuid));
                            colValueHM.put("version", escape.cote(version));
                            colValueHM.put("description", escape.cote(description));
                            colValueHM.put("status", escape.cote(themeStatus));
                            colValueHM.put("asimina_version", escape.cote(asimina_version));
                            colValueHM.put("created_ts", "NOW()");
                            colValueHM.put("updated_ts", "NOW()");
                            colValueHM.put("created_by", pid+"");
                            colValueHM.put("updated_by", pid+"");
                            colValueHM.put("site_id", siteId);

                            q = getInsertQuery("themes",colValueHM);
                            int result = Etn.executeCmd(q);

                            if(result > 0){
                                // get theme folder from uuid
                                themeFolderPath = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("THEMES_FOLDER") + siteId + File.separator + themeUuid;
                                themeFolder = Paths.get(themeFolderPath);

                                if(!Files.exists(themeFolder)){
                                    themeFolder = Files.createDirectories(themeFolder);
                                }

                                // add all content folders in theme folder
                                for(String content : themeContents){
                                    Path contentFolder = Paths.get(themeFolder + File.separator + content);
                                    Files.createDirectory(contentFolder);
                                }
                                flag = true;
                            } else{
                              message = "Error in creating theme";
                            }
                        }
                    }catch (org.json.JSONException ex){
                        message = "Invalid theme json file";
                    }
                    break; // break the loop as we only want to process the theme.json
                }
            }
        }

        if(flag){ // fill the content folders with files
            if (Files.notExists(source)) {
                throw new IOException(" The file you want to extract does not exist ");
            }
            ArchiveEntry entry;
            try (InputStream fi = Files.newInputStream(source);
                   BufferedInputStream bi = new BufferedInputStream(fi);
                   GzipCompressorInputStream gzi = new GzipCompressorInputStream(bi);
                   TarArchiveInputStream ti = new TarArchiveInputStream(gzi))
           {
               Path targetPath = Paths.get(themeFolderPath);

               while ((entry = ti.getNextEntry()) != null){
                   if(entry.getName().equalsIgnoreCase("theme.json")){
                       Path targetFile  = createFileInDirectory(entry, targetPath); // create theme.josn file in folder
                       Files.copy(ti, targetFile, StandardCopyOption.REPLACE_EXISTING); // copy the content from tar to theme.josn
                    } else {
                        // filter only files
                        if(!entry.isDirectory()){
                            Path file = Paths.get(entry.getName());
                            String contentName = file.getParent().getFileName().toString(); // get file parent folder name
                            themeContents.contains(contentName); // validate that this  content folder exist in our theme contents list
                            String ext =  getFileExtension(file.getFileName().toString());
                            boolean validFile = false;
                            // validate the file data and file type inside content folder
                            switch(contentName){
                                case Constant.THEME_CONTENT_FILES:
                                    validFile = isValidExtension(new String[] {"js", "css", "fonts"}, ext);
                                    break;
                                case Constant.THEME_CONTENT_MEDIA:
                                    validFile = isValidExtension(new String[] {"img", "video", "other"}, ext);
                                    break;
                                case Constant.THEME_CONTENT_LIBRARIES:
                                case Constant.THEME_CONTENT_TEMPLATES:
                                case Constant.THEME_CONTENT_PAGE_TEMPALTES:
                                case Constant.THEME_CONTENT_SYSTEM_TEMPLATES:
                                    validFile = ext.equals("json");
                                    break;
                            }
                            // copy file to respective folder in theme
                           if(validFile){
                               Path targetFile  = createFileInDirectory(entry,targetPath); // create file
                               Files.copy(ti, targetFile, StandardCopyOption.REPLACE_EXISTING); // copoy the  file data to respective file
                           }
                        }
                    }
                }
                // delete the file in tar.gz temp
                Files.delete(Paths.get(tempFilePath));
                status = STATUS_SUCCESS;
                message = "Theme uploaded successfully";
           }
       } else if(!foundThemeFile) {
            message = "Error: theme.json not found";
       }
    }//end try
    catch (Exception e) {
        e.printStackTrace();
        status = STATUS_ERROR;
        message = e.getMessage();
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status", status);
    jsonResponse.put("message", message);
    jsonResponse.put("data", data);
    out.write(jsonResponse.toString());
%>