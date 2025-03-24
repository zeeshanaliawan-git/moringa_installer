<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.LinkedHashMap, org.json.*, com.etn.pages.*, java.util.regex.Pattern, java.nio.file.attribute.BasicFileAttributes, java.util.function.BiPredicate, java.nio.file.*"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/fileMethods.jsp"%>

<%!
    public HashSet<String> getAllThemeContents(){
           return new HashSet<>(Arrays.asList(
           Constant.THEME_CONTENT_FILES,
           Constant.THEME_CONTENT_LIBRARIES,
           Constant.THEME_CONTENT_MEDIA,
           Constant.THEME_CONTENT_TEMPLATES,
           Constant.THEME_CONTENT_SYSTEM_TEMPLATES,
           Constant.THEME_CONTENT_PAGE_TEMPALTES));
    }

    public String[] getFileTypes(String contentType){
        if(contentType.equals("files")) return new String[]{"js","css","fonts"};
        else if(contentType.equals("media")) return new String[]{"img", "video", "other"};
        else return new String[]{};
    }

    public String getSQLInQuery(String[] types , boolean include){
        String q = "";
        if(types.length > 0){
                q = " AND type ";
                if(!include) q += " NOT ";
                q += " IN (";
                for(String type : types){
                  q += escape.cote(type)+ ",";
                }
                q = q.substring(0 ,q.length()-1);
                q += " )";
          }
        return q;
    }

    public boolean isThemeContentItemUpdated(Contexte Etn, String themeId, String siteId, String tableName, String uniqueKeyCol, String itemUniqueKey){
        String q = " SELECT id "
            + " FROM "+tableName
            + " WHERE theme_id = "+escape.cote(themeId)
            + " AND theme_version > 0"
            + " AND site_id = "+escape.cote(siteId)
            + " AND "+uniqueKeyCol+" = "+escape.cote(itemUniqueKey);
        Set rs =  Etn.execute(q);
        if(rs.next()){
            return true;
        }
        return false;
    }

    public int getThemeContentUpdatedItemsCount(Contexte Etn, String themeId, String siteId, String tableName, String[] includedTypes, String[] excludedTypes){
        String q = " SELECT COUNT(theme_id) count"
            + " FROM "+tableName
            + " WHERE theme_id = "+escape.cote(themeId)
            + " AND theme_version > 0"
            + " AND site_id = "+escape.cote(siteId);
            q += getSQLInQuery(includedTypes, true);
            q += getSQLInQuery(excludedTypes, false);
        Set rs =  Etn.execute(q);
        if(rs.next()){
            return parseInt(rs.value("count"));
        }
        return 0;
    }

    public void syncContentFiles(Set rs, Path themeContentPath, String uploadFolderPath){
        while(rs.next()){
           String fileName =  rs.value("file_name");
           String sourceFilePath =  uploadFolderPath + File.separator + rs.value("type") + File.separator + fileName;
           Path sourceFile = Paths.get(sourceFilePath);
           String targetFilePath = themeContentPath + File.separator + fileName;
           Path targetFile = Paths.get(targetFilePath);
           try{
               Files.copy(sourceFile, targetFile,StandardCopyOption.REPLACE_EXISTING);
           } catch (Exception ex){
                ex.printStackTrace();
               continue; // ignore;
           }
        }
    }

    public void syncContentData(Contexte Etn, Set rs, String themeId, Path contentFolder, String siteId, String itemType, String uniqueKeyType, String contentType ) throws Exception{
        HashMap<String, JSONObject> updatedContentItmes = new HashMap<>();
        HashSet<String> uniqueIds = new HashSet<>();
        EntityExport entityExport = new EntityExport(Etn, siteId);
        JSONObject exportItem = new JSONObject();

        while(rs.next()){
           String uniqueId =  rs.value(uniqueKeyType);

           switch(contentType){
           case Constant.THEME_CONTENT_LIBRARIES:
               exportItem = entityExport.getLibraryExportJson(rs.value("id"));
               break;
           case Constant.THEME_CONTENT_TEMPLATES:
           case Constant.THEME_CONTENT_SYSTEM_TEMPLATES:
               exportItem = entityExport.getBlocTemplateExportJson(rs.value("id"));
               break;
           case Constant.THEME_CONTENT_PAGE_TEMPALTES:
               exportItem = entityExport.getPageTemplateExportJson(rs.value("id"));
               break;
           }
           updatedContentItmes.put(uniqueId, exportItem);
           uniqueIds.add(uniqueId);
        }
        updateContentItems(contentFolder, itemType, uniqueKeyType, uniqueIds ,updatedContentItmes);
    }

    public void updateContentItems(Path contentFolder, String itemType, String uniqueKeyType, HashSet<String> updatedItemsKeys, HashMap<String, JSONObject> updatedContentItmes ) throws IOException{
        final BiPredicate<Path, BasicFileAttributes> predicate = (path, attrs)
            -> attrs.isRegularFile() && path.getFileName().toString().endsWith(".json");

        List<Path> files = Files.find(contentFolder, 1, predicate)
            .collect(Collectors.toList());
        for(Path file : files) {
           StringBuilder fileContent = new StringBuilder();
            // read file
            try (Stream<String> dataStream = Files.lines(file, StandardCharsets.UTF_8))
            {
                dataStream.forEach(s -> fileContent.append(s).append(System.getProperty("line.separator")));
            } catch (IOException e) {
                continue;
            }

            JSONObject fileJsonObject = new JSONObject(fileContent.toString());
            JSONObject exportInfo = fileJsonObject.optJSONObject("export_info");
            JSONArray items = fileJsonObject.getJSONArray("items");
            JSONArray updatedItems = new JSONArray();
            for(Object object : items){
                JSONObject item =  (JSONObject)object;
                if(item.getString("item_type").equals(itemType)){
                    String uniqueId = item.getJSONObject("system_info").getString(uniqueKeyType);
                    if(updatedItemsKeys.contains(uniqueId)){
                        JSONObject updatedItem = updatedContentItmes.get(uniqueId);
                        updatedItems.put(updatedItem);
                    } else{
                        updatedItems.put(item);
                    }
                }
            }
            // save the file
            JSONObject updatedFileObject = new JSONObject();
            updatedFileObject.put("export_info", exportInfo);
            updatedFileObject.put("items",updatedItems );
            try {
                Files.write(file, updatedFileObject.toString().getBytes());}
            catch (IOException e) {
                continue;
            }
        }
    }
    public void syncThemeContentItems(Contexte Etn, String contentType, String themeId, String themeUuid, String siteId, String[] uniqueIds) throws Exception{
        String q;
        Set rs;
        String themesFolderPath = GlobalParm.getParm("BASE_DIR")+ GlobalParm.getParm("THEMES_FOLDER") + siteId;
        String uploadFolderPath = GlobalParm.getParm("BASE_DIR")+ GlobalParm.getParm("UPLOADS_FOLDER") + siteId;

        String themeContentPath = themesFolderPath +  File.separator + themeUuid + File.separator + contentType;
        Path themeContentFolder = Paths.get(themeContentPath);

        String inQeury = "";
        if(uniqueIds.length > 0){
            inQeury += " IN (";
            for(String uniqueId : uniqueIds){
                inQeury += escape.cote(uniqueId) + ",";
            }
            inQeury = inQeury.substring(0 ,inQeury.length()-1);
            inQeury += ")";
        } else {
            return;
        }
        switch (contentType){
            case Constant.THEME_CONTENT_FILES:
            case Constant.THEME_CONTENT_MEDIA:
                q = "SELECT * FROM files"
                + " WHERE theme_id = "+escape.cote(themeId)
                + " AND theme_version > 0 "
                + " AND site_id = "+escape.cote(siteId)
                + " AND file_name "+ inQeury;
                rs = Etn.execute(q);
                syncContentFiles(rs, themeContentFolder, uploadFolderPath);
                q = "UPDATE files SET theme_version = 0"
                + " WHERE theme_id  = "+escape.cote(themeId)
                + " AND site_id = "+escape.cote(siteId)
                + " AND file_name "+ inQeury;
                Etn.execute(q);
                break;
            case Constant.THEME_CONTENT_LIBRARIES:
                q = "SELECT * FROM libraries"
                + " WHERE theme_id = "+escape.cote(themeId)
                + " AND theme_version > 0 "
                + " AND  site_id = "+escape.cote(siteId)
                + " AND name "+ inQeury;
                rs = Etn.execute(q);
                syncContentData(Etn,rs, themeId, themeContentFolder, siteId, "library", "name", contentType );
                // reset the data
                q = "UPDATE libraries SET theme_version = 0 "
                + " WHERE theme_id  = "+escape.cote(themeId)
                + " AND site_id = "+escape.cote(siteId)
                + " AND name "+ inQeury;
                Etn.execute(q);
                break;
            case Constant.THEME_CONTENT_TEMPLATES:
            case Constant.THEME_CONTENT_SYSTEM_TEMPLATES:
                q = "SELECT * FROM bloc_templates"
                + " WHERE theme_id = "+escape.cote(themeId)
                + " AND theme_version > 0 "
                + " AND site_id = "+escape.cote(siteId)
                + " AND custom_id "+ inQeury;
                rs = Etn.execute(q);
                syncContentData(Etn,rs, themeId, themeContentFolder, siteId, "bloc_template", "custom_id", contentType );
                // reset the data
                q = "UPDATE bloc_templates SET theme_version = 0 "
                + " WHERE theme_id  = "+escape.cote(themeId)
                +"  AND site_id = "+escape.cote(siteId)
                + " AND custom_id "+ inQeury;
                Etn.execute(q);
                break;
            case Constant.THEME_CONTENT_PAGE_TEMPALTES:
                q = "SELECT * FROM page_templates "
                + " WHERE theme_id = "+escape.cote(themeId)
                + " AND theme_version > 0 "
                + " AND site_id = "+escape.cote(siteId)
                + " AND custom_id "+ inQeury;
                rs = Etn.execute(q);
                syncContentData(Etn,rs, themeId, themeContentFolder, siteId, "page_template", "custom_id", contentType );
                // reset the data
                q = "UPDATE page_templates"
                + " SET theme_version = 0"
                + " WHERE theme_id  = "+escape.cote(themeId)
                + " AND site_id = "+escape.cote(siteId)
                + " AND custom_id "+ inQeury;
                Etn.execute(q);
                break;
        }
    }

    public void syncThemeContent(Contexte Etn, String contentType, String themeId, String themeUuid, String siteId) throws Exception{
        String q;
        Set rs;
        String themesFolderPath = GlobalParm.getParm("BASE_DIR")+ GlobalParm.getParm("THEMES_FOLDER") + siteId;
        String uploadFolderPath = GlobalParm.getParm("BASE_DIR")+ GlobalParm.getParm("UPLOADS_FOLDER") + siteId;

        String themeContentPath = themesFolderPath +  File.separator + themeUuid + File.separator + contentType;
        Path themeContentFolder = Paths.get(themeContentPath);
        String[] types;
        switch (contentType){
            case Constant.THEME_CONTENT_FILES:
                types =  getFileTypes(contentType);
                q = "SELECT * FROM files"
                + " WHERE theme_id = "+escape.cote(themeId)
                + " AND theme_version > 0"
                + " AND site_id = "+escape.cote(siteId);
                q += getSQLInQuery(types,true);
                rs = Etn.execute(q);

                syncContentFiles(rs, themeContentFolder, uploadFolderPath);

                q = "UPDATE files SET theme_version = 0"
                + " WHERE theme_id  = "+escape.cote(themeId)
                + " AND  site_id = "+escape.cote(siteId);
                q += getSQLInQuery(types,true);
                Etn.execute(q);
                break;
            case Constant.THEME_CONTENT_MEDIA:
                types =  getFileTypes(contentType);
                q = "SELECT * FROM files"
                + " WHERE theme_id = "+escape.cote(themeId)
                + " AND theme_version > 0 "
                + " AND site_id = "+ escape.cote(siteId);
                q += getSQLInQuery(types,true);
                rs = Etn.execute(q);

                syncContentFiles(rs, themeContentFolder, uploadFolderPath);

                q = "UPDATE files SET theme_version = 0"
                + " WHERE theme_id  = "+escape.cote(themeId)
                + " AND site_id = "+escape.cote(siteId);
                q += getSQLInQuery(types,true);
                Etn.execute(q);
                break;
            case Constant.THEME_CONTENT_LIBRARIES:
                q = "SELECT * FROM libraries WHERE theme_id = "+escape.cote(themeId) +" AND theme_version > 0 AND site_id = "+escape.cote(siteId);
                rs = Etn.execute(q);

                syncContentData(Etn,rs, themeId, themeContentFolder, siteId, "library", "name", contentType );
                // reset the data
                q = "UPDATE libraries SET theme_version = 0 WHERE theme_id  = "+escape.cote(themeId)+" AND site_id = "+escape.cote(siteId);
                Etn.execute(q);
                break;
            case Constant.THEME_CONTENT_TEMPLATES:
                q = "SELECT * FROM bloc_templates "
                + " WHERE theme_id = "+escape.cote(themeId)
                + " AND theme_version > 0 "
                + " AND site_id = "+escape.cote(siteId);
                q += getSQLInQuery(Constant.getSystemTemplateTypes(),false);
                rs = Etn.execute(q);

                syncContentData(Etn,rs, themeId, themeContentFolder, siteId, "bloc_template", "custom_id", contentType );
                // reset the data
                q = "UPDATE bloc_templates SET theme_version = 0 "
                + " WHERE theme_id  = "+escape.cote(themeId)
                + " AND site_id = "+escape.cote(siteId);
                q += getSQLInQuery(Constant.getSystemTemplateTypes(),false);
                Etn.execute(q);
                break;
            case Constant.THEME_CONTENT_SYSTEM_TEMPLATES:
                q = "SELECT * FROM bloc_templates "
                + " WHERE theme_id = "+escape.cote(themeId)
                + " AND theme_version > 0 "
                + " AND site_id = "+escape.cote(siteId);
                q += getSQLInQuery(Constant.getSystemTemplateTypes(),true);
                rs = Etn.execute(q);

                syncContentData(Etn,rs, themeId, themeContentFolder, siteId, "bloc_template", "custom_id", contentType );
                // reset the data
                q = "UPDATE bloc_templates SET theme_version = 0 "
                + " WHERE theme_id  = "+escape.cote(themeId)
                + " AND site_id = "+escape.cote(siteId);
                q += getSQLInQuery(Constant.getSystemTemplateTypes(),true);
                Etn.execute(q);
                break;
            case Constant.THEME_CONTENT_PAGE_TEMPALTES:
                q = "SELECT * FROM page_templates WHERE theme_id = "+escape.cote(themeId) +" AND theme_version > 0 AND site_id = "+escape.cote(siteId);
                rs = Etn.execute(q);
                syncContentData(Etn,rs, themeId, themeContentFolder, siteId, "page_template", "custom_id", contentType );
                // reset the data
                q = "UPDATE page_templates SET theme_version = 0 WHERE theme_id  = "+escape.cote(themeId)+" AND site_id = "+escape.cote(siteId);
                Etn.execute(q);
                break;
        }
    }

    public Boolean addFilesInTheme(Contexte Etn, Set rsTheme, String uploadFolderPath, String themesFolderPath,
     String siteId, String fileName, String isOverwrite, String themeContent, String themeId) throws SimpleException{
        try{
            String ext =  getFileExtension(fileName);
            String[] fileTypes = {};
            String fileType = "";

            if(themeContent.equals(Constant.THEME_CONTENT_FILES)){
                fileTypes = new String[]{"js","css","fonts"};
            }else if(themeContent.equals(Constant.THEME_CONTENT_MEDIA)){
                 fileTypes = new String[]{"img", "video", "other"};
            }
            fileType = ThemesUtil.getFileTypeFromExtension(fileTypes, ext);

            // check extension is valid ?
            if(!ThemesUtil.validateFileExtension(fileTypes, ext)){
                throw new SimpleException("Invalid file type.");
            }

            String sourceFilePath = uploadFolderPath + File.separator + fileType + File.separator +  fileName;
            Path sourceFile = Paths.get(sourceFilePath);
            String targetFilePath = themesFolderPath + File.separator + rsTheme.value("uuid") + File.separator +  themeContent + File.separator + fileName;
            Path targetFile = Paths.get(targetFilePath);

            if(!Files.exists(sourceFile)){
                throw new SimpleException("Source file not found.");
            }
            if(Files.exists(targetFile)){
                if("1".equals(isOverwrite)){
                    Files.write(targetFile, Files.readAllBytes(sourceFile));
                }else{
                    throw new SimpleException("File already exists.");
                }
            } else{
                Path file  = Files.createFile(targetFile); // create new file
                Files.write(targetFile, Files.readAllBytes(sourceFile));
            }
            if(rsTheme.value("publish_status").equals("published")){ //if theme is publihsed then set the theme id in table
                String q = "UPDATE files SET theme_id = "+escape.cote(themeId)+" WHERE file_name = "+escape.cote(fileName)+" AND site_id = "+escape.cote(siteId);
                Etn.executeCmd(q);
            }
        }catch (Exception ex){
            throw new SimpleException("Error in saving, please try again .",ex);
        }

        return true;
    }

    public Boolean addImportItemInTheme(ServletRequest request, Contexte Etn, Set rsTheme, String siteId, String themesFolderPath ) throws SimpleException{

        try{
            String id = parseNull(request.getParameter("id"));
            String uniqueId = parseNull(request.getParameter("uniqueId"));
            String themeId = parseNull(request.getParameter("themeId"));
            String themeContent = parseNull(request.getParameter("themeContent"));
            String templateType = parseNull(request.getParameter("templateType"));
            String isOverwrite = parseNull(request.getParameter("overwrite"));

            EntityExport entityExport = new EntityExport(Etn, siteId);
            JSONObject dataJson = new JSONObject();
            String tableName = "";
            String uniqueKeyCol = "custom_id";
            switch(themeContent){
                case Constant.THEME_CONTENT_LIBRARIES:
                    dataJson = entityExport.getLibraryExportJson(id);
                    tableName = "libraries";
                    uniqueKeyCol = "name";
                    break;
                case Constant.THEME_CONTENT_SYSTEM_TEMPLATES: case Constant.THEME_CONTENT_TEMPLATES:
                     dataJson = entityExport.getBlocTemplateExportJson(id);
                     tableName = "bloc_templates";
                    break;
                case Constant.THEME_CONTENT_PAGE_TEMPALTES:
                     dataJson = entityExport.getPageTemplateExportJson(id);
                     tableName = "page_templates";
                     break;
            }

            String contentFolderPath = themesFolderPath + File.separator + rsTheme.value("uuid")+ File.separator + themeContent;
            Path contentFolder =  Paths.get(contentFolderPath);

            final BiPredicate<Path, BasicFileAttributes> predicate = (path, attrs)
                -> attrs.isRegularFile() && path.getFileName().toString().endsWith(".json");

            // get the first json file from folder
            try (final Stream<Path> stream = Files.find(contentFolder, 1, predicate)) {
                Optional<Path> result  = stream.findFirst();

                if(result.isPresent()){
                   Path file =  result.get();
                   StringBuilder fileContent = new StringBuilder();
                    // read file
                    try (Stream<String> dataStream = Files.lines(file, StandardCharsets.UTF_8))
                    {
                        dataStream.forEach(s -> fileContent.append(s).append(System.getProperty("line.separator")));
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                    // convert file data string to json
                    JSONObject fileJsonObject = new JSONObject(fileContent.toString());
                    JSONObject exportInfo = fileJsonObject.optJSONObject("export_info");
                    JSONArray items = fileJsonObject.getJSONArray("items");
                    JSONArray  updatedItems = new JSONArray();

                    if(isOverwrite.equals("1")){
                        for(int i = 0; i < items.length(); i++){
                            JSONObject item = items.getJSONObject(i);
                            String itemUniqueId = "";

                            if(themeContent.equals(Constant.THEME_CONTENT_LIBRARIES)){
                                itemUniqueId = item.getJSONObject("system_info").getString("name");
                            } else{
                                itemUniqueId = item.getJSONObject("system_info").getString("custom_id");
                            }

                            if(itemUniqueId.equals(uniqueId)){
                                updatedItems.put(dataJson);
                            } else {
                                updatedItems.put(item);
                            }
                        }
                    } else{
                        updatedItems = items;
                        updatedItems.put(dataJson); // jsut append new template data wih items
                    }
                    // overwrite data in  file
                    JSONObject updatedFileObject = new JSONObject();
                    updatedFileObject.put("export_info",exportInfo );
                    updatedFileObject.put("items",updatedItems );

                    Files.write(file, updatedFileObject.toString().getBytes());
                } else { // no file exsits
                    JSONObject fileJson = new JSONObject();
                    JSONArray items = new JSONArray();
                    String  fileName = "";
                    fileName = "";

                    if(themeContent.equals(Constant.THEME_CONTENT_LIBRARIES)){
                        fileName = "libraries.json";
                    } else{
                        fileName = "bloc_template.json";
                    }

                    String filePath = contentFolderPath + File.separator + fileName;
                    Path file  = Files.createFile(Paths.get(filePath));

                    items.put(dataJson);
                    fileJson.put("exportInfo", new JSONObject());
                    fileJson.put("items", items);

                    Files.write(file, fileJson.toString().getBytes());
                }
            }
            if(rsTheme.value("publish_status").equals("published")){ //if theme is publihsed then set the theme id in table
                String q = "UPDATE "+tableName+" SET theme_id = "+escape.cote(themeId)+" WHERE  "+uniqueKeyCol+" = "+escape.cote(uniqueId)+" AND site_id = "+escape.cote(siteId);
                Etn.executeCmd(q);
            }
        }catch (Exception ex){
            throw new SimpleException("Error in saving, please try again .",ex);
        }
        return true;
    }

    public int getNbItemsFromDetailsLang(JSONObject item){
        int nbItems = 0;
        if(item.optJSONArray("detail_langs")!=null){
            JSONArray detailLangs = item.getJSONArray("detail_langs");
            for(int i=0;i<detailLangs.length();i++){
                JSONObject detail = detailLangs.getJSONObject(i);
                nbItems+=detail.getJSONArray("body_files").length() + detail.getJSONArray("head_files").length();
            }
        }else{
            nbItems=item.getJSONArray("body_files").length() + item.getJSONArray("head_files").length();
        }
        return nbItems;
    }
%>

<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<>();

    String q = "";
    Set rs = null;
    int pid = Etn.getId();


	String siteId = getSiteId(session);
    String requestType = parseNull(request.getParameter("requestType"));
    String themesFolderPath = GlobalParm.getParm("BASE_DIR")+ GlobalParm.getParm("THEMES_FOLDER") + siteId;
    String uploadFolderPath = GlobalParm.getParm("BASE_DIR")+ GlobalParm.getParm("UPLOADS_FOLDER") + siteId;

    try{
        if("getThemesList".equalsIgnoreCase(requestType)){
            try{
                JSONArray themesList = new JSONArray();
                JSONObject themeObject;
                q = "SELECT th.*, l2.name AS updated_by  "
                    + " , IF(ISNULL( th.published_ts ),'',CONCAT(th.published_ts, ' by ', l1.name)) AS published_ts "
                    + " , IF(th.to_publish = 1, CONCAT('Publish on ',DATE_ADD(th.to_publish_ts , INTERVAL 5 MINUTE)), "
                    + "       IF(th.to_unpublish=1,CONCAT('Un-publish on ',DATE_ADD(th.to_unpublish_ts , INTERVAL 5 MINUTE)) ,'')) AS to_publish_ts "
                + " FROM themes th "
                + " LEFT JOIN login l1 on l1.pid = th.published_by "
                + " LEFT JOIN login l2 on l2.pid = th.updated_by "
                + " WHERE th.site_id = "+escape.cote(siteId);
                rs =  Etn.execute(q);
                while (rs.next()){
                    themeObject = new JSONObject();
                    for(String colName : rs.ColName){
                        themeObject.put(colName.toLowerCase(), rs.value(colName));
                    }
                    String themeId = rs.value("id");
                    q = "SELECT COUNT(*) updated_items FROM "
                    + "("
                    + " SELECT theme_version FROM bloc_templates WHERE theme_id = "+escape.cote(themeId)+" AND theme_version > 0 AND site_id = "+escape.cote(siteId)
                    + " UNION "
                    + " SELECT theme_version FROM page_templates WHERE theme_id = "+escape.cote(themeId)+" AND theme_version > 0 AND site_id = "+escape.cote(siteId)
                    + " UNION"
                    + " SELECT theme_version FROM libraries WHERE theme_id = "+escape.cote(themeId)+" AND theme_version > 0 AND site_id = "+escape.cote(siteId)
                    + " UNION "
                    + " SELECT theme_version FROM files WHERE theme_id = "+escape.cote(themeId)+" AND theme_version > 0 AND site_id = "+escape.cote(siteId)
                    + ") as t";

                    Set rsTheme = Etn.execute(q);
                    String publishStatus = rs.value("publish_status");

                    if(rsTheme.next()){
                        int updatedItems = parseInt(rsTheme.value("updated_items"));
                        if(updatedItems > 0 ){
                            publishStatus = "changed";
                        }
                    }
                    themeObject.put("publish_status", publishStatus);
                    themesList.put(themeObject);
                }
                data.put("themes",themesList);
                status = STATUS_SUCCESS;

            }catch (Exception ex){
                throw new SimpleException("Error in getting themes list. Please try again.",ex);
            }
        } else if("getThemeData".equalsIgnoreCase(requestType)){
            try{
                JSONObject themeObject = new JSONObject();
                String id = parseNull(request.getParameter("id"));
                q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND id = "+escape.cote(id);
                rs =  Etn.execute(q);
                if(rs.next()){
                    for(String colName : rs.ColName){
                        themeObject.put(colName.toLowerCase(), rs.value(colName));
                    }
                    data.put("theme", themeObject);
                    status = STATUS_SUCCESS;
                } else {
                    message = "Invalid theme id";
                }
            }catch (Exception ex){
                throw new SimpleException("Error in getting theme data. Please try again.",ex);
            }
        } else if("addEditTheme".equalsIgnoreCase(requestType)){
            String id = parseNull(request.getParameter("id")); //  this is out of try as we need to show message on catch
            try{
                if(id.length() >0 ){
                    q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND id = "+escape.cote(id);
                    rs =  Etn.execute(q);
                    if(!rs.next()){
                        message = "Invalid theme id";
                    }
                    if(!isSuperAdmin(Etn) && rs.value("status").equals(Constant.THEME_LOCKED)){
                        throw new SimpleException("Only super admin can update the locked themes.");
                    }
                }

                String name = parseNull(request.getParameter("name"));
                String description = parseNull(request.getParameter("description"));
                String themeStatus = parseNull(request.getParameter("status"));
                String version = parseNull(request.getParameter("version"));
                String asimina_version = GlobalParm.getParm("APP_VERSION");
                String uuid = getUUID();

                if(id.length() > 0){
                    asimina_version = rs.value("asimina_version");
                    uuid = rs.value("uuid");
                }
                // only super admin can lock theme check
                if(!isSuperAdmin(Etn)){
                    if(themeStatus.equals(Constant.THEME_LOCKED)){
                        throw new SimpleException("Only super admin can lock the theme.");
                    }
                }

                // check duplicate
                q = "SELECT id FROM themes "
                + " WHERE name = "+escape.cote(name)
                + " AND version  = "+escape.cote(version)
                + " AND site_id = "+escape.cote(siteId);
                if(id.length()>0){
                    q += " AND id != "+escape.cote(id);
                }

                Set rsCheck = Etn.execute(q);
                if(rsCheck.next()){
                    throw new SimpleException("Theme with name "+name+" and version "+version+" already exsits.");
                }
                // version check
                String pattern = "^[1-9]\\d*(\\.[0-9]\\d*){2}$";
                boolean matches = Pattern.matches(pattern, version);

                if(!matches){
                    throw new SimpleException("Invalid theme version, vesion formate should be n.n.n ");
                }

                colValueHM.put("name", escape.cote(name));
                colValueHM.put("description", escape.cote(description));
                colValueHM.put("version", escape.cote(version));
                if(themeStatus.length() > 0){
                    colValueHM.put("status", escape.cote(themeStatus));
                }
                colValueHM.put("updated_ts", "NOW()");
                colValueHM.put("updated_by", escape.cote(""+pid));
                if(id.length() == 0){
                    colValueHM.put("asimina_version", escape.cote(asimina_version));
                    colValueHM.put("created_ts", "NOW()");
                    colValueHM.put("created_by", escape.cote(""+pid));
                    colValueHM.put("uuid", escape.cote(uuid));
                    colValueHM.put("site_id", escape.cote(siteId));
                    colValueHM.put("status", escape.cote(Constant.THEME_OPENED));
                }

                if(id.length()>0){
                    q = getUpdateQuery("themes", colValueHM, "WHERE id = "+escape.cote(id));
                } else{
                    q = getInsertQuery("themes", colValueHM);
                }
                int count = Etn.executeCmd(q);

                if(count > 0 ){
                    String themeFolderPath = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("THEMES_FOLDER") +siteId + File.separator + uuid;
                    Path themeFolder =  Paths.get(themeFolderPath);
                    // if new theme then create empty theme  and its contents
                    if(id.length() == 0){
                        Files.createDirectories(themeFolder);
                        for(String content : getAllThemeContents()){
                            Path contentFolder = Paths.get(themeFolderPath+File.separator+content);
                            Files.createDirectory(contentFolder);
                        }
                    }
                    // saving/updating theme.json file
                    JSONObject themeObject = new JSONObject();
                    themeObject.put("name", name);
                    themeObject.put("version", version);
                    themeObject.put("description", description);
                    themeObject.put("status", themeStatus);
                    themeObject.put("asimina_version", asimina_version);

                    Path targetFile = themeFolder.resolve("theme.json");
                    Files.write(targetFile, themeObject.toString().getBytes());

                    data.put("themeId", uuid);// response data

                    String action = "created";
                    if(id.length()>0){
                        action = "updated";
                    }
                    message = "Theme "+action+" successfully";
                    status = STATUS_SUCCESS;
                    //  save logs
                    if(id.length() > 0){
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),id ,"UPDATED", "Theme", name+" V"+version, siteId);
                    } else{
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),id ,"CREATED", "Theme", name+" V"+version, siteId);
                    }
                } else {
                    message = "Error updating theme, please try again";
                }
            }catch (Exception ex){
                String action = "creating";
                if(id.length()>0){
                    action = "updating";
                }
                throw new SimpleException("Error in "+action+" theme. Please try again.",ex);
            }
        } else if("getThemeContents".equalsIgnoreCase(requestType)){
            try{
                HashSet<String> themeContents = getAllThemeContents();
                JSONArray themeContentsList = new JSONArray();

                String themeId = parseNull(request.getParameter("id"));
                q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND id = "+escape.cote(themeId);
                rs =  Etn.execute(q);

                if(rs.next()){
                    String themeUuid =  rs.value("uuid");
                    String themeFolderPath = GlobalParm.getParm("BASE_DIR")+GlobalParm.getParm("THEMES_FOLDER")+siteId+File.separator+themeUuid;

                    List<Path> contentsPaths =  Files.walk(Paths.get(themeFolderPath), 1)
                    .filter(p -> Files.isDirectory(p))
                    .collect(Collectors.toList());

                    for(Path cotnentPath : contentsPaths){
                        String contentName =  cotnentPath.getFileName().toString();

                        if(themeContents.contains(contentName)){
                            JSONObject contentData = new JSONObject();
                            contentData.put("name", contentName);
                            // get last modified date of folder
                            contentData.put("last_modified", ThemesUtil.lastModified(cotnentPath));

                            // get files count
                            int count = 0;
                            int updatedItems = 0;
                            String itemType;
                            String[] types;
                            switch(contentName){
                                case Constant.THEME_CONTENT_FILES:
                                    types = new String[] {"js", "css", "fonts"};
                                    count = ThemesUtil.getContentFiles(types, cotnentPath).size();
                                    updatedItems = getThemeContentUpdatedItemsCount(Etn, themeId, siteId, "files",types, new String[]{} );
                                    break;
                                case Constant.THEME_CONTENT_MEDIA:
                                    types = new String[] {"img", "video", "other"};
                                    count = ThemesUtil.getContentFiles(types, cotnentPath).size();
                                    updatedItems = getThemeContentUpdatedItemsCount(Etn, themeId, siteId, "files", types, new String[]{});
                                    break;
                                case Constant.THEME_CONTENT_LIBRARIES:
                                    count = ThemesUtil.getAllContentItems(Etn, siteId, cotnentPath, "library").size();
                                    updatedItems = getThemeContentUpdatedItemsCount(Etn, themeId, siteId, "libraries", new String[]{},  new String[]{});
                                    break;
                                case Constant.THEME_CONTENT_TEMPLATES:
                                    count  = ThemesUtil.getAllContentItems(Etn, siteId, cotnentPath, "bloc_template").size();
                                    updatedItems = getThemeContentUpdatedItemsCount(Etn, themeId, siteId, "bloc_templates",new String[]{}, Constant.getSystemTemplateTypes());
                                    break;
                                case Constant.THEME_CONTENT_SYSTEM_TEMPLATES:
                                    count  = ThemesUtil.getAllContentItems(Etn, siteId, cotnentPath, "bloc_template").size();
                                    updatedItems = getThemeContentUpdatedItemsCount(Etn, themeId, siteId, "bloc_templates", Constant.getSystemTemplateTypes(), new String[]{});
                                    break;
                                case Constant.THEME_CONTENT_PAGE_TEMPALTES:
                                    count  = ThemesUtil.getAllContentItems(Etn, siteId, cotnentPath, "page_template").size();
                                    updatedItems = getThemeContentUpdatedItemsCount(Etn, themeId, siteId, "page_templates", new String[]{}, new String[]{});
                                    break;
                            }
                            // remove the conent from the set as it has found.
                            themeContents.remove(contentName);
                            contentData.put("nb_items", count);
                            contentData.put("syncRequired", updatedItems > 0 );
                            themeContentsList.put(contentData);
                        }
                    }
                    status = STATUS_SUCCESS;
                    // add the content which are not found in the theme and set there default values
                    for(String content :themeContents){
                        JSONObject contentObject = new JSONObject();
                        contentObject.put("name", content);
                        contentObject.put("nb_items", 0);
                        contentObject.put("last_modified", "");
                        themeContentsList.put(contentObject);
                    }
                    data.put("themeContents", themeContentsList);
                } else {
                    message = "Invalid theme id";
                }
            }catch (Exception ex){
                ex.printStackTrace();
                throw new SimpleException("Error in getting theme contents data. Please try again.",ex);
            }
        } else if("getThemeContentData".equalsIgnoreCase(requestType)){
            try{
                String themeId = parseNull(request.getParameter("themeId"));
                String themeContent = parseNull(request.getParameter("themeContent"));

                HashSet<String> themeContents = getAllThemeContents();
                JSONArray themeContentData = new JSONArray();

                q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND id = "+escape.cote(themeId);
                Set rsTheme =  Etn.execute(q);

                if(rsTheme.next()){
                    String themeName = rsTheme.value("name")+"V"+rsTheme.value("version");
                    String themeStatus = rsTheme.value("status");
                    String themeContentFolderPath =  themesFolderPath + File.separator + rsTheme.value("uuid") + File.separator+ themeContent;
                    Path contentPath = Paths.get(themeContentFolderPath);
                    if(Files.exists(contentPath) && Files.isDirectory(contentPath) && themeContents.contains(themeContent)){
                        // get all files from folder

                        switch(themeContent){
                            case Constant.THEME_CONTENT_FILES:
                            case Constant.THEME_CONTENT_MEDIA:
                                 String[] fileTypes = new String[] {"js", "css", "fonts"};
                                 if(Constant.THEME_CONTENT_MEDIA.equals(themeContent)){
                                    fileTypes = new String[] {"img", "video", "other"};
                                 }
                                 List<Path> mediafilesPath = ThemesUtil.getContentFiles(fileTypes, contentPath);
                                 for(Path path : mediafilesPath){
                                    String fileName = path.getFileName().toString();
                                    JSONObject fileInfo = new JSONObject();
                                    String extension =  ThemesUtil.getFileExtension(path);
                                    DecimalFormatSymbols symbols = new DecimalFormatSymbols();
                                    symbols.setDecimalSeparator('.');
                                    DecimalFormat nf = new DecimalFormat("#.##", symbols);

                                    fileInfo.put("id","");
                                    fileInfo.put("size",  nf.format((double)Files.size(path) / 1024)+" KB"); // in Kb
                                    fileInfo.put("last_modified", ThemesUtil.lastModified(path));
                                    fileInfo.put("type", ThemesUtil.getFileTypeFromExtension(fileTypes, extension ));
                                    fileInfo.put("extension", extension);
                                    fileInfo.put("theme", themeName);
                                    fileInfo.put("themeStatus", themeStatus);
                                    fileInfo.put("uniqueId",fileName);
                                    fileInfo.put("name", fileName);
                                    boolean isUpdated = isThemeContentItemUpdated(Etn, themeId, siteId, "files", "file_name" , fileName);
                                    fileInfo.put("syncRequired", isUpdated);
                                    themeContentData.put(fileInfo);
                                 }
                                break;
                            case Constant.THEME_CONTENT_LIBRARIES:
                                List<JSONObject> libraryItems = ThemesUtil.getAllContentItems(Etn, siteId, contentPath, "library");
                                for(JSONObject jsonObject : libraryItems){
                                    try {
                                        JSONObject item = jsonObject.getJSONObject("item");
                                        JSONObject libInfo = new JSONObject();
                                        int nbItems =  getNbItemsFromDetailsLang(item);
                                        String name = item.getJSONObject("system_info").getString("name");
                                        libInfo.put("nb_files", nbItems);
                                        libInfo.put("id", item.getJSONObject("internal_info").getString("id"));
                                        libInfo.put("status", jsonObject.getString("status"));
                                        libInfo.put("error", jsonObject.getString("error"));
                                        libInfo.put("theme", themeName);
                                        libInfo.put("name", name);
                                        libInfo.put("themeStatus", themeStatus);
                                        libInfo.put("last_modified", ThemesUtil.lastModified(contentPath));
                                        libInfo.put("uniqueId", name);
                                        libInfo.put("libData", item);
                                        boolean isUpdated = isThemeContentItemUpdated(Etn, themeId, siteId, "libraries", "name" , name);
                                        libInfo.put("syncRequired", isUpdated);
                                        themeContentData.put(libInfo);
                                    } catch (JSONException ex){
                                        ex.printStackTrace();
                                        continue;
                                    }
                                }
                                break;
                            case Constant.THEME_CONTENT_SYSTEM_TEMPLATES:
                            case Constant.THEME_CONTENT_PAGE_TEMPALTES:
                            case Constant.THEME_CONTENT_TEMPLATES:
                                String itemType = Constant.THEME_CONTENT_PAGE_TEMPALTES.equals(themeContent)? "page_template" : "bloc_template";
                                List<JSONObject> templateItems = ThemesUtil.getAllContentItems(Etn, siteId, contentPath, itemType);
                                String tableName = Constant.THEME_CONTENT_PAGE_TEMPALTES.equals(themeContent)? "page_templates" : "bloc_templates";

                                for(JSONObject jsonObject : templateItems){
                                    try {

                                        JSONObject item = jsonObject.getJSONObject("item");
                                        JSONObject templateInfo = new JSONObject();
                                        JSONObject systemInfo = item.getJSONObject("system_info");
                                        String customId = systemInfo.getString("custom_id");
                                        templateInfo.put("id", item.getJSONObject("internal_info").getString("id"));
                                        templateInfo.put("status", jsonObject.getString("status"));
                                        templateInfo.put("error", jsonObject.getString("error"));
                                        templateInfo.put("custom_id", customId);
                                        templateInfo.put("uniqueId", customId);
                                        templateInfo.put("type", item.getString("item_type"));
                                        templateInfo.put("theme", themeName);
                                        templateInfo.put("name", systemInfo.getString("name"));
                                        templateInfo.put("themeStatus", themeStatus);
                                        templateInfo.put("description", systemInfo.getString("description"));
                                        templateInfo.put("last_modified", ThemesUtil.lastModified(contentPath));

                                        boolean isUpdated = isThemeContentItemUpdated(Etn, themeId, siteId, tableName, "custom_id" , customId);
                                        templateInfo.put("syncRequired", isUpdated);

                                        themeContentData.put(templateInfo);
                                    } catch (JSONException ex){
                                        ex.printStackTrace();
                                        continue;
                                    }
                                }
                                break;
                        }
                        status = STATUS_SUCCESS;
                        data.put("themeContents", themeContentData);
                    }
                    else{
                      message = "Content "+themeContent+" not found in theme";
                    }
                }
                else{
                    message = "Invalid theme id";
                }
            } catch (Exception ex){
                ex.printStackTrace();
                throw new SimpleException("Error in getting theme contents data. Please try again.",ex);
            }
        } else if("deleteTheme".equalsIgnoreCase(requestType)){
               try{
                String[] ids = request.getParameterValues("id");
                int totalThemes =  ids.length;
                int deletedThemesCount = 0;
                String deletedNames = "";
                for(String id :ids){
                    id = parseNull(id);
                    if(id.length() == 0){
                       continue;
                    }

                    q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND id = "+escape.cote(id);
                    rs =  Etn.execute(q);
                    if(rs.next()){ // valid theme
                        if((!isSuperAdmin(Etn) && rs.value("status").equals(Constant.THEME_LOCKED)) || rs.value("publish_status").equals("published")){
                            continue;
                        }
                        deletedNames += rs.value("name")+" V"+rs.value("version") +", ";
                        int rec = Etn.executeCmd("DELETE FROM themes WHERE id = "+escape.cote(id));
                        if(rec > 0){
                           // delete theme folder path
                            String deleteThemePath =  themesFolderPath + File.separator + rs.value("uuid");
                            // delte all theme files
                             try (Stream<Path> walk = Files.walk(Paths.get(deleteThemePath))) {
                                  walk
                                      .sorted(Comparator.reverseOrder())
                                      .forEach( file -> {
                                          try {
                                              Files.delete(file);
                                          }
                                          catch (IOException e) {
                                              e.printStackTrace();
                                          }
                                      });
                              }
                            deletedThemesCount++;
                        }
                    }
                }
                if(totalThemes == 1  && deletedThemesCount == 1){
                    message = "Theme deleted";
                    status = STATUS_SUCCESS;
                    // activity logs
                    ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),
                      convertArrayToCommaSeperated(ids)
                      ,"DELETED", "Theme", deletedNames.substring(0, deletedNames.length()-2), siteId);
                } else if(totalThemes > 1){
                    message = deletedThemesCount+" themes deleted";
                    if(deletedThemesCount  != totalThemes){
                        message += " out of "+totalThemes;
                    }
                    // activity logs
                     ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),
                      convertArrayToCommaSeperated(ids)
                      ,"DELETED", "Theme", deletedNames.substring(0, deletedNames.length()-2), siteId);
                    status = STATUS_SUCCESS;
                }else {
                    message = "Could not delete theme";
                }
            }catch (Exception ex){
                throw new SimpleException("Error in getting theme data. Please try again.",ex);
            }
        } else if("addNewContentItem".equalsIgnoreCase(requestType)){
            try{
                String themeContent = parseNull(request.getParameter("themeContent"));
                String themeId = parseNull(request.getParameter("themeId"));

                q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND id = "+escape.cote(themeId);
                Set rsTheme =  Etn.execute(q);
                if(rsTheme.next()){ // valid theme
                    if(!isSuperAdmin(Etn)  && rsTheme.value("status").equals(Constant.THEME_LOCKED)){
                        throw new SimpleException("Theme is locked, you are not authorized.");
                    }
                    boolean result;
                    if(themeContent.equals(Constant.THEME_CONTENT_FILES) || themeContent.equals(Constant.THEME_CONTENT_MEDIA)  ){
                        result =  addFilesInTheme(Etn, rsTheme, uploadFolderPath, themesFolderPath, siteId
                        , parseNull(request.getParameter("uniqueId")), parseNull(request.getParameter("overwrite")),
                         parseNull(request.getParameter("themeContent")) ,parseNull(request.getParameter("themeId")));
                    } else if(themeContent.equals(Constant.THEME_CONTENT_LIBRARIES)){
                        if(parseNull(request.getParameter("addLibraryFiles")).equals("1")){
                            String libId = parseNull(request.getParameter("id"));
                            q = "SELECT f.file_name,lg.langue_code FROM libraries l "
                            + " LEFT JOIN libraries_files lf ON lf.library_id = l.id"
                            + " LEFT JOIN files f ON lf.file_id = f.id"
                            + " LEFT JOIN language lg ON lg.langue_id = lf.lang_id"
                            + " WHERE l.site_id = " + escape.cote(siteId)
                            + " AND l.id = "+escape.cote(libId);
                            rs = Etn.execute(q);
                            while(rs.next()){
                                addFilesInTheme(Etn, rsTheme, uploadFolderPath, themesFolderPath, siteId, rs.value("file_name"), "1",
                                Constant.THEME_CONTENT_FILES, parseNull(request.getParameter("themeId")));
                            }
                        }
                        result = addImportItemInTheme(request, Etn, rsTheme, siteId, themesFolderPath);
                    } else{
                        result = addImportItemInTheme(request, Etn, rsTheme, siteId, themesFolderPath);
                    }
                    if(result){
                        message = "Added successfully";
                        status = STATUS_SUCCESS;
                    }
                } else {
                    message = "Invalid theme id";
                }
            }catch (Exception ex){
                throw new SimpleException("Error in getting theme data. Please try again.",ex);
            }
         } else if("deleteContentItems".equalsIgnoreCase(requestType)){
               try{
                    String[] ids = request.getParameterValues("ids");
                    String contentType = parseNull(request.getParameter("contentType"));
                    String themeId = parseNull(request.getParameter("themeId"));

                    int totalItems =  ids.length;
                    int deletedCount = 0;

                    q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND id = "+escape.cote(themeId);
                    rs =  Etn.execute(q);
                    if(!rs.next()){ // valid theme
                          throw new SimpleException("Invalid theme id.");
                    }
                    if(rs.value("status").equals(Constant.THEME_LOCKED) && !isSuperAdmin(Etn)){ // valid theme
                          throw new SimpleException("Cannot delete items from locked theme.");
                    }

                    switch (contentType){
                        case Constant.THEME_CONTENT_FILES:
                        case Constant.THEME_CONTENT_MEDIA:
                            for(String fileName : ids){
                                fileName = parseNull(fileName);
                                if(fileName.length() == 0){
                                   continue;
                                }
                                String deleteFilePath =  themesFolderPath + File.separator + rs.value("uuid") + File.separator +  contentType + File.separator + fileName;
                                Path deleteFile = Paths.get(deleteFilePath);
                                if(!Files.exists(deleteFile)){
                                    continue;
                                } else{
                                    Files.delete(deleteFile);
                                    deletedCount++;
                                    if(rs.value("publish_status").equals("published")){
                                        Etn.executeCmd("UPDATE files SET theme_id = 0 WHERE file_name = "+escape.cote(fileName)+" AND site_id = "+escape.cote(siteId));
                                    }
                                }
                            }
                            break;
                        case Constant.THEME_CONTENT_LIBRARIES:
                        case Constant.THEME_CONTENT_TEMPLATES:
                        case Constant.THEME_CONTENT_SYSTEM_TEMPLATES:
                        case Constant.THEME_CONTENT_PAGE_TEMPALTES:
                            String tableName  = "bloc_templates";
                            String uniqueKeyCol  = "custom_id";
                            if(Constant.THEME_CONTENT_LIBRARIES.equals(contentType)){
                                tableName = "libraries";
                                uniqueKeyCol = "name";
                            } else if(Constant.THEME_CONTENT_PAGE_TEMPALTES.equals(contentType)){
                                tableName = "page_templates";
                            }

                            HashSet<String> uniqueIds = new HashSet<>(Arrays.asList(ids));
                            String contentFolderPath =  themesFolderPath + File.separator + rs.value("uuid") + File.separator +contentType + File.separator;
                            Path contentFolder = Paths.get(contentFolderPath);

                            List<String> deletedLibraryFiles = new ArrayList<>();
                            HashSet<String> nonDeletedLibraryFiles = new HashSet<>();

                            // file validator
                            final BiPredicate<Path, BasicFileAttributes> predicate = (path, attrs)
                                -> attrs.isRegularFile() && path.getFileName().toString().endsWith(".json");

                            //get all json files
                            List<Path> files =  Files.find(contentFolder, 1, predicate).collect(Collectors.toList());

                            List<String> langs = new ArrayList<>();
                            for (Path file : files) {
                                StringBuilder fileContent = new StringBuilder();
                                int deletedMarkedItems  = 0;
                                // read file
                                Stream<String> dataStream = Files.lines(file, StandardCharsets.UTF_8);
                                dataStream.forEach(s -> fileContent.append(s).append(System.getProperty("line.separator")));

                                // convert file data to json object
                                JSONObject fileJsonObject = new JSONObject(fileContent.toString());
                                JSONObject exportInfo = fileJsonObject.optJSONObject("export_info");
                                JSONArray items = fileJsonObject.getJSONArray("items");
                                JSONArray updatedItems = new JSONArray();
                                for(int i = 0; i < items.length(); i++){
                                    JSONObject item = items.getJSONObject(i);
                                    String itemUniqueId = "";

                                    if(contentType.equals(Constant.THEME_CONTENT_LIBRARIES)){
                                        itemUniqueId = item.getJSONObject("system_info").getString("name");
                                    } else{
                                        itemUniqueId = item.getJSONObject("system_info").getString("custom_id");
                                    }

                                    if(!uniqueIds.contains(itemUniqueId)){
                                        updatedItems.put(item);

                                        // collect non deleted library files to delete them later
                                        if(contentType.equals(Constant.THEME_CONTENT_LIBRARIES)){
                                            if(item.optJSONArray("detail_langs")!=null){
                                                JSONArray detailLangs = item.getJSONArray("detail_langs");
                                                for(int j=0;j<detailLangs.length();j++){
                                                    JSONArray bodyFiles =  detailLangs.getJSONObject(j).getJSONArray("body_files");
                                                    for(int y = 0; y < bodyFiles.length(); y++){
                                                        JSONObject fileObj =  (JSONObject)bodyFiles.get(y);
                                                        nonDeletedLibraryFiles.add(fileObj.getString("name"));
                                                    }
                                                    
                                                    JSONArray headFiles =  detailLangs.getJSONObject(j).getJSONArray("head_files");
                                                    for(int y = 0; y < headFiles.length(); y++){
                                                        JSONObject fileObj =  (JSONObject)headFiles.get(y);
                                                        nonDeletedLibraryFiles.add(fileObj.getString("name"));
                                                    }
                                                }
                                            }else{
                                                JSONArray bodyFiles =  item.getJSONArray("body_files");
                                                for(int y = 0; y < bodyFiles.length(); y++){
                                                    JSONObject fileObj =  (JSONObject)bodyFiles.get(y);
                                                    nonDeletedLibraryFiles.add(fileObj.getString("name"));
                                                }

                                                JSONArray headFiles = item.getJSONArray("head_files");
                                                for(int y = 0; y < headFiles.length(); y++){
                                                    JSONObject fileObj =  (JSONObject)headFiles.get(y);
                                                    nonDeletedLibraryFiles.add(fileObj.getString("name"));
                                                }
                                            }
                                        }
                                    } else {
                                        // collect deleted library files to delete them later
                                        if(contentType.equals(Constant.THEME_CONTENT_LIBRARIES)){
                                            if(item.optJSONArray("detail_langs")!=null){
                                                JSONArray detailLangs = item.getJSONArray("detail_langs");
                                                for(int j=0;j<detailLangs.length();j++){
                                                    JSONArray bodyFiles =  detailLangs.getJSONObject(j).getJSONArray("body_files");
                                                    for(int y = 0; y < bodyFiles.length(); y++){
                                                        JSONObject fileObj =  (JSONObject)bodyFiles.get(y);
                                                        deletedLibraryFiles.add(fileObj.getString("name"));
                                                    }
                                                    
                                                    JSONArray headFiles =  detailLangs.getJSONObject(j).getJSONArray("head_files");
                                                    for(int y = 0; y < headFiles.length(); y++){
                                                        JSONObject fileObj =  (JSONObject)headFiles.get(y);
                                                        deletedLibraryFiles.add(fileObj.getString("name"));
                                                    }
                                                }
                                            }else{
                                                JSONArray bodyFiles =  item.getJSONArray("body_files");
                                                for(int y = 0; y < bodyFiles.length(); y++){
                                                    JSONObject fileObj =  (JSONObject)bodyFiles.get(y);
                                                    deletedLibraryFiles.add(fileObj.getString("name"));
                                                }

                                                JSONArray headFiles = item.getJSONArray("head_files");
                                                for(int y = 0; y < headFiles.length(); y++){
                                                    JSONObject fileObj =  (JSONObject)headFiles.get(y);
                                                    deletedLibraryFiles.add(fileObj.getString("name"));
                                                }
                                            }
                                        }
                                        // mark the item as deleted
                                        deletedMarkedItems++;
                                        if(rs.value("publish_status").equals("published")){
                                            Etn.executeCmd("UPDATE "+tableName+" SET theme_id = 0 WHERE  "+uniqueKeyCol+" = "+escape.cote(itemUniqueId)+" AND site_id = "+escape.cote(siteId));
                                        }
                                    }
                                }
                                // update the file items
                                fileJsonObject.put("items", updatedItems);
                                Files.write(file, fileJsonObject.toString().getBytes());
                                deletedCount += deletedMarkedItems;
                            }
                            // delete library files
                            if(contentType.equals(Constant.THEME_CONTENT_LIBRARIES)){
                                for(String file : deletedLibraryFiles){
                                    if(!nonDeletedLibraryFiles.contains(file)){
                                        // delete the file
                                       String deleteFilePath =  themesFolderPath + File.separator + rs.value("uuid") + File.separator +  Constant.THEME_CONTENT_FILES + File.separator + file;
                                       Path deleteFile = Paths.get(deleteFilePath);
                                        if(!Files.exists(deleteFile)){
                                            continue;
                                        } else{
                                            Files.delete(deleteFile);
                                        }
                                    }
                                }
                            }
                        }
                    String contentItem = "file";
                    if(contentType.equals(Constant.THEME_CONTENT_MEDIA)){
                        contentItem = "media file";
                    } else if(!contentType.equals(Constant.THEME_CONTENT_FILES)){
                        contentItem =  contentType.substring(0, contentType.length()-1);
                    }
                    if(totalItems == 1  && deletedCount == 1){
                        message = contentItem+" deleted";
                        status = STATUS_SUCCESS;
                    } else if(totalItems > 1){
                        message = totalItems+" "+contentItem+"(s) deleted";
                        if(deletedCount  != totalItems){
                            message += " out of "+totalItems;
                        }
                        status = STATUS_SUCCESS;
                    }else {
                        message = "Could not delete "+contentItem+"(s)";
                    }
            }catch (Exception ex){
                throw new SimpleException("Error in deleting items. Please try again.",ex);
            }
        }
        else if("publishTheme".equalsIgnoreCase(requestType)){
            try{
                String themeId = parseNull(request.getParameter("themeId"));
                String publishTimeStr = parseNull(request.getParameter("publishTime"));
                String publishTime = ""; //default

                if(publishTimeStr.equalsIgnoreCase("now")){
                    publishTime = "NOW()";
                }
                else {
                    //parse publish date time to standard format
                    publishTime = convertDateTimeToStandardFormat(publishTimeStr, "yyyy-MM-dd HH:mm");

                    if(publishTime.length() == 0){
                        throw new Exception("Error: Invalid publish on time");
                    }
                    publishTime = escape.cote(publishTime);
                }

                q = "SELECT * FROM themes WHERE id = "+escape.cote(themeId)+" AND site_id = "+escape.cote(siteId);
                rs =  Etn.execute(q);
                if(!rs.next()){
                    throw new Exception("Error: Invalid theme Id");
                }
                String version = rs.value("asimina_version");
                String[] minAsiminaVersion =  GlobalParm.getParm("MIN_ASIMINA_VERSION").split("\\.");
                String[] themeAsiminaVersion =  version.split("\\.");
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

                if(!versionAcceptable){
                    message = "Theme needs to be updated to app version "+GlobalParm.getParm("MIN_ASIMINA_VERSION");
                    message += ". Minimum required version is "+GlobalParm.getParm("MIN_ASIMINA_VERSION")
                            + " and current theme supports app of version "+version;
                } else{
                    q = "SELECT * FROM themes WHERE id = "+escape.cote(themeId)+" AND site_id = "+escape.cote(siteId);
                    rs = Etn.execute(q);
                    if(!rs.next()){
                        throw new Exception("Error: Invalid theme Id");
                    }
                    int rows = 0;
                    // invalide all the to_pubish and to_unpublish
                    q = "UPDATE themes SET"
                    + " to_publish = 0, to_unpublish = 0,"
                    + " to_publish_ts = NULL, to_unpublish_ts = NULL,"
                    + " to_publish_by = NULL, to_unpublish_by = NULL"
                    + " WHERE site_id = "+escape.cote(siteId);

                    rows = Etn.executeCmd(q);
                    if(rows > 0 ){
                        colValueHM.put("to_publish", "1");
                        colValueHM.put("to_publish_by",escape.cote(""+Etn.getId()));
                        colValueHM.put("to_publish_ts", publishTime);
                        // colValueHM.put("publish_status",escape.cote("queued"));
                        q = getUpdateQuery("themes", colValueHM, " WHERE id = "+escape.cote(themeId));

                        rows =  Etn.executeCmd(q);
                        if(rows > 0){
                            // regenerate all pages
                            q = "UPDATE structured_contents "
                            + " SET  to_generate = 1, to_generate_by = "+escape.cote(pid+"")
                            + " WHERE site_id = "+escape.cote(siteId);
                            Etn.executeCmd(q);

                            q = "UPDATE pages "
                            + " SET  to_generate = 1, to_generate_by = "+escape.cote(pid+"")
                            + " WHERE site_id = "+escape.cote(siteId)
                            + " AND type != "+escape.cote(Constant.PAGE_TYPE_STRUCTURED);
                            Etn.executeCmd(q);
                            status = STATUS_SUCCESS;
                            message = "Theme is marked for publishing";
                            ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),
                            themeId ,"PUBLISHED", "Theme", rs.value("name")+" V"+rs.value("version"), siteId);
                        } else{
                            message = "Error in publishing theme";
                        }
                    } else{
                        message = "Error in publishing theme";
                    }
                }
            }catch (Exception ex){
                throw new SimpleException("Error in publishing theme.",ex);
            }
        }
        else if("unpublishTheme".equalsIgnoreCase(requestType)){
            try{
                String themeId = parseNull(request.getParameter("themeId"));
                String publishTimeStr = parseNull(request.getParameter("publishTime"));
                String publishTime = ""; //default

                if(publishTimeStr.equalsIgnoreCase("now")){
                    publishTime = "NOW()";
                }
                else {
                    //parse publish date time to standard format
                    publishTime = convertDateTimeToStandardFormat(publishTimeStr, "yyyy-MM-dd HH:mm");

                    if(publishTime.length() == 0){
                        throw new Exception("Error: Invalid publish on time");
                    }
                    publishTime = escape.cote(publishTime);
                }
                q = "SELECT * FROM themes WHERE id = "+escape.cote(themeId)+" AND site_id = "+escape.cote(siteId);
                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new Exception("Error: Invalid theme Id");
                }
                int rows = 0;
                // invalide all the to_pubish and to_unpublish
                q = "UPDATE themes SET"
                + " to_publish = 0, to_unpublish = 0,"
                + " to_publish_ts = NULL, to_unpublish_ts = NULL,"
                + " to_publish_by = NULL, to_unpublish_by = NULL"
                + " WHERE site_id = "+escape.cote(siteId);

                rows = Etn.executeCmd(q);

                if(rows > 0 ){
                    colValueHM.put("to_unpublish","1");
                    colValueHM.put("to_unpublish_by",escape.cote(""+Etn.getId()));
                    colValueHM.put("to_unpublish_ts", publishTime);
                    // colValueHM.put("publish_status",escape.cote("queued"));
                    q = getUpdateQuery("themes", colValueHM, " WHERE id = "+escape.cote(themeId));
                    rows =  Etn.executeCmd(q);
                    if(rows > 0){
                        status = STATUS_SUCCESS;
                        message = "Theme is marked for unpublishing";
                        ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),themeId ,
                        "UNPUBLISHED", "Theme", rs.value("name")+" V"+rs.value("version"), siteId);
                    } else{
                        message = "Error in unpublishing theme";
                    }
                } else{
                    message = "Error in unpublishing theme";
                }

            }catch (Exception ex){
                throw new SimpleException("Error in unpublishing theme.",ex);
            }
        }
        else if("syncTheme".equalsIgnoreCase(requestType)){
            try{
                String themeUuid = parseNull(request.getParameter("themeId"));
                String[] contents = {
                    Constant.THEME_CONTENT_FILES,
                    Constant.THEME_CONTENT_LIBRARIES,
                    Constant.THEME_CONTENT_MEDIA,
                    Constant.THEME_CONTENT_TEMPLATES,
                    Constant.THEME_CONTENT_SYSTEM_TEMPLATES,
                    Constant.THEME_CONTENT_PAGE_TEMPALTES
                };
                q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND uuid = "+escape.cote(themeUuid);
                rs =  Etn.execute(q);
                if(!rs.next()){ // valid theme
                    message = "Invalid theme id";
                }
                else
                {
                    String themeId =  rs.value("id");
                    for(String content : contents){
                        syncThemeContent(Etn, content, themeId, themeUuid ,siteId);
                    }
                    status = STATUS_SUCCESS;
                    message = "Synced successfully";
                    ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), themeId ,
                    "SYNCED", "Theme", rs.value("name")+" V"+rs.value("version"), siteId);
                }

            }catch (Exception ex){
                throw new SimpleException("Error in syncing theme.",ex);
            }
        }
        else if("syncThemeContent".equalsIgnoreCase(requestType)){
            try{
                String themeId = parseNull(request.getParameter("themeId"));
                String themeContent = parseNull(request.getParameter("themeContent"));

                q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND id = "+escape.cote(themeId);
                rs =  Etn.execute(q);
                if(!rs.next()){ // valid theme
                    message = "Invalid theme id";
                } else{
                    syncThemeContent(Etn, themeContent, themeId, rs.value("uuid") ,siteId);
                    status = STATUS_SUCCESS;
                    message = "Synced successfully";
                }
            }catch (Exception ex){
                throw new SimpleException("Error in syncing theme content.",ex);
            }
        }
        else if("syncThemeContentItems".equalsIgnoreCase(requestType)){
            try{
                String themeId = parseNull(request.getParameter("themeId"));
                String themeContent = parseNull(request.getParameter("themeContent"));
                String[] itemIds = request.getParameterValues("itemIds");

                q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND id = "+escape.cote(themeId);
                rs =  Etn.execute(q);
                if(!rs.next()){ // valid theme
                    message = "Invalid theme id";
                } else{
                    if(itemIds.length == 0){
                        throw new SimpleException("No items found.");
                    }
                    syncThemeContentItems(Etn, themeContent, themeId,  rs.value("uuid"), siteId, itemIds);
                    status = STATUS_SUCCESS;
                    message = "Synced successfully";
                }
            }catch (Exception ex){
                throw new SimpleException("Error in syncing theme content item.",ex);
            }
        } else if("copyTheme".equalsIgnoreCase(requestType)){
            try{
                String themeId = parseNull(request.getParameter("id"));
                String themeName = parseNull(request.getParameter("name"));
                String themeVersion = parseNull(request.getParameter("version"));
                String themeDescription = parseNull(request.getParameter("description"));
                String themeStatus = parseNull(request.getParameter("status"));

                if(!isSuperAdmin(Etn)){
                    if(themeStatus.equals(Constant.THEME_LOCKED)){
                        throw new SimpleException("Only super admin can lock the theme.");
                    }
                }
                String themeUuid = getUUID();

                q = "SELECT * FROM themes WHERE site_id = "+escape.cote(siteId)+" AND id = "+escape.cote(themeId);
                rs =  Etn.execute(q);
                if(!rs.next()){ // valid theme
                    message = "Invalid theme id";
                } else{
                    String sourceThemeUuid = rs.value("uuid");
                    String asiminaVersion = rs.value("asimina_version");

                    // check duplicate
                    q = "SELECT id FROM themes "
                    + " WHERE name = "+escape.cote(themeName)
                    + " AND version  = "+escape.cote(themeVersion)
                    + " AND site_id = "+escape.cote(siteId);

                    rs = Etn.execute(q);
                    if(rs.next()){
                        throw new SimpleException("Theme of this name and version already exsits.");
                    }
                    String pattern = "^[1-9]\\d*(\\.[0-9]\\d*){2}$";
                    boolean matches = Pattern.matches(pattern, themeVersion);

                    if(!matches){
                        throw new SimpleException("Invalid version format, format should be n.n.n");
                    }
                    String sourceThemeFolderPath = themesFolderPath + File.separator + sourceThemeUuid;
                    Path sourceThemeFolder = Paths.get(sourceThemeFolderPath);

                    String targetThemeFolderPath = themesFolderPath + File.separator + themeUuid;
                    Path targetThemeFolder = Paths.get(targetThemeFolderPath);

                    Files.createDirectory(targetThemeFolder);// create main theme folder
                    HashSet<String> themeContents = getAllThemeContents(); //all inside theme content folders

                    for(String content: themeContents){
                        Path targetContentFolder = Paths.get(targetThemeFolderPath + File.separator + content);
                        Path soruceContentFolder = Paths.get(sourceThemeFolderPath + File.separator + content);
                        Files.createDirectory(targetContentFolder); //create content folder

                        if(Files.exists(soruceContentFolder)){ // get files from source content folder
                            Files.walk(soruceContentFolder, 1)
                            .parallel()
                            .forEach(sourceFile ->{
                                if(Files.isRegularFile(sourceFile)){
                                    Path targetFile = targetContentFolder.resolve(sourceFile.getFileName()); // create the file
                                    try {
                                        Files.copy(sourceFile, targetFile);
                                    }
                                    catch (IOException e) {
                                        e.printStackTrace();
                                    }
                                }
                            });
                        }
                    }
                    // create theme.json
                    Path themeFile = Paths.get(targetThemeFolderPath +File.separator+ "theme.json");
                    if(!Files.exists(themeFile)){
                        Files.createFile(themeFile);
                    }
                    JSONObject themeFileContent = new JSONObject();
                    themeFileContent.put("name", themeName);
                    themeFileContent.put("description", themeDescription);
                    themeFileContent.put("asimina_version", asiminaVersion);
                    themeFileContent.put("version", themeVersion);
                    themeFileContent.put("status", status);
                    Files.write(themeFile,themeFileContent.toString().getBytes());

                    // now enter the new theme is DB
                    colValueHM.put("name", escape.cote(themeName));
                    colValueHM.put("uuid", escape.cote(themeUuid));
                    colValueHM.put("site_id", escape.cote(siteId));
                    colValueHM.put("version", escape.cote(themeVersion));
                    colValueHM.put("asimina_version", escape.cote(asiminaVersion));
                    colValueHM.put("description", escape.cote(themeDescription));
                    colValueHM.put("status", escape.cote(themeStatus));
                    colValueHM.put("created_ts", "NOW()");
                    colValueHM.put("updated_ts", "NOW()");
                    colValueHM.put("created_by", escape.cote(pid+""));
                    colValueHM.put("updated_by", escape.cote(pid+""));
                    q =  getInsertQuery("themes", colValueHM);
                    int rows = Etn.executeCmd(q);

                    if(rows > 0){
                        status = STATUS_SUCCESS;
                        message = "Copied successfully";
                    } else{
                        message = "Error in copying theme";
                    }
                }
            }catch (Exception ex){
                throw new SimpleException("Error in copying theme content.",ex);
            }
        }
    }//try
    catch(SimpleException ex){
        message = ex.getMessage();
        ex.print();
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
    out.write(jsonResponse.toString());
%>
