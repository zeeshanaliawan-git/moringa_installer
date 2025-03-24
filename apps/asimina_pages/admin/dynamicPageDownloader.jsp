<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, java.util.ArrayList,com.etn.asimina.util.FileUtil"%>
<%@ page import="com.etn.pages.PagesUtil, com.etn.pages.PagesGenerator"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/fileMethods.jsp"%>
<%!

    void writeZipFile(File zipFile, List<File> srcFiles) throws SimpleException{
        try {

        	ZipUtility zipUtility = new ZipUtility();

        	zipUtility.zip(srcFiles, zipFile);

        }
        catch (Exception ex) {
            throw new SimpleException("Error in creating zip file",ex);
        }

    }

%>
<%

    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    String PAGE_TYPE_FREEMARKER = "freemarker", PAGE_TYPE_REACT = "react", PAGE_TYPE_STRUCTURED = "structured";

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();

    String q = "";
    Set rs = null;

    try{

        String requestType = parseNull(request.getParameter("requestType"));
        String pageId = parseNull(request.getParameter("id"));

        q = " SELECT * FROM pages p"
            + " WHERE id = " + escape.cote(pageId)
            + " AND type = " + escape.cote(PAGE_TYPE_REACT);
        Set pageRs = Etn.execute(q);

        if(!pageRs.next()){
            throw new SimpleException("Page not found");
        }

        String publishStatus = pageRs.value("publish_status");
        if(!publishStatus.equals("published")){
            throw new SimpleException("Page is not published. Current status = "+ publishStatus);
        }

        String pageName = pageRs.value("name").trim();

        String BASE_DIR = GlobalParm.getParm("BASE_DIR");
        String PAGES_PUBLISH_FOLDER = GlobalParm.getParm("PAGES_PUBLISH_FOLDER");
        String ZIP_FILE_FOLDER  = "zip/";

        String PAGES_DIR = PAGES_PUBLISH_FOLDER;
        String ZIP_DIR = PAGES_PUBLISH_FOLDER + ZIP_FILE_FOLDER;

        String siteId = pageRs.value("site_id");
        String pagePath = pageRs.value("path");
        String pageVariant = pageRs.value("variant");
        String pageLang = pageRs.value("langue_code");

        String dynamicPagePath = PagesUtil.getDynamicPagePath(siteId , pageLang, pageVariant, pagePath);

        String zipFolderFullPath = ZIP_DIR + dynamicPagePath;

        File zipFolder = FileUtil.getFile(BASE_DIR + zipFolderFullPath);//change
        FileUtil.mkDirs(zipFolder);//change


        String downloadFilePath = "";

        if("index".equals(requestType)){

            String pageFolderFullPath = PAGES_DIR + dynamicPagePath;

            String indexFilePath =  pageFolderFullPath + "index.html";
            String mainJsFilePath =  pageFolderFullPath + "main.js";

            File indexFile = FileUtil.getFile(BASE_DIR + indexFilePath);//change
            File mainJsFile = FileUtil.getFile(BASE_DIR + mainJsFilePath);//change

            if(!indexFile.exists()){
                throw new SimpleException("Error: index.html file not found at " + indexFilePath);
            }

            if(!mainJsFile.exists()){
                throw new SimpleException("Error: main.js file not found at " + mainJsFilePath);
            }

            String zipFileName = getSafeFileName(pageName + " index files.zip");
            String zipFilePath = zipFolderFullPath + zipFileName;
            File zipFile = FileUtil.getFile(BASE_DIR + zipFilePath);//change

            if(zipFile.exists()){
                zipFile.delete();
            }

            ArrayList<File> srcFilesList = new ArrayList<File>();
            srcFilesList.add(indexFile);
            srcFilesList.add(mainJsFile);

            //debug
            // srcFilesList.add(new File(BASE_DIR+pageFolderFullPath+"/test"));
            // HashSet<String> excludeFiles = new HashSet<String>();
            // HashSet<String> excludeDirectories = new HashSet<String>();
            // excludeDirectories.add("node_modules");
            // excludeFiles.add("index.js");
            // ZipUtility zipUtility = new ZipUtility(excludeFiles, excludeDirectories);

            ZipUtility zipUtility = new ZipUtility();
        	zipUtility.zip(srcFilesList, zipFile);

            status = STATUS_SUCCESS;
            message = "zip file written :" + zipFile.getAbsolutePath();

            downloadFilePath = zipFilePath;
        }
        else if("js_css".equals(requestType)){

        	String UPLOADS_FOLDER = GlobalParm.getParm("UPLOADS_FOLDER");
        	String CSS_FOLDER = UPLOADS_FOLDER + "css/";
        	String JS_FOLDER = UPLOADS_FOLDER + "js/";

        	String fileQuery = " SELECT f.*  "
                + " FROM files f  "
                + " JOIN libraries_files lf ON lf.file_id = f.id  "
                + " JOIN libraries l ON l.id = lf.library_id  "
                + " JOIN component_libraries cl ON cl.library_id = l.id  "
                + " JOIN ( "
                + "     SELECT DISTINCT component_id  "
                + "     FROM page_items "
                + "     WHERE component_id > 0 "
                + " 	AND page_id = " + escape.cote(pageId)
                + " ) c ON c.component_id = cl.component_id "
                + " GROUP BY f.id ";

            rs = Etn.execute(fileQuery);

            ArrayList<File> srcFilesList = new ArrayList<File>();

            while(rs.next()){
            	String fileName = rs.value("file_name").trim();
            	String fileType = rs.value("type");

            	String filePath = "";
            	if ("css".equals(fileType)) {
            	    filePath = CSS_FOLDER + fileName;
            	}
            	else if ("js".equals(fileType)) {
            	    filePath = JS_FOLDER + fileName;
            	}

            	if(filePath.length() > 0){
        			File srcFile = FileUtil.getFile(BASE_DIR + filePath);//change
        			if(srcFile.exists()){
        				srcFilesList.add(srcFile);
        			}
        		}
            }

            String zipFileName = getSafeFileName(pageName + " JS CSS files.zip");
            String zipFilePath = zipFolderFullPath + zipFileName;
            File zipFile = FileUtil.getFile(BASE_DIR + zipFilePath);//change

            if(zipFile.exists()){
                zipFile.delete();
            }


            ZipUtility zipUtility = new ZipUtility();
        	zipUtility.zip(srcFilesList, zipFile);

            status = STATUS_SUCCESS;
            message = "zip file written :" + zipFile.getAbsolutePath();

            downloadFilePath = zipFilePath;

        }
        else if("project".equals(requestType)){
        	String COMPILER_DIRECTORY_BASE_DIR = parseNull(GlobalParm.getParm("DYNAMIC_PAGES_COMPILER_DIRECTORY"));

        	String COMPILED_PAGES_DIR = COMPILER_DIRECTORY_BASE_DIR + "pages/";

        	File pageDirectory = FileUtil.getFile(COMPILED_PAGES_DIR + pageId);//change
        	if(!pageDirectory.exists() || !pageDirectory.isDirectory()){
        		throw new Exception("Compiled page directory not found : " + COMPILED_PAGES_DIR + pageId);
        	}

        	ArrayList<File> srcFilesList = new ArrayList<File>();
        	for (File file : pageDirectory.listFiles()) {
        		srcFilesList.add(file);
        	}

            String zipFileName = getSafeFileName(pageName + " react files.zip");
            String zipFilePath = zipFolderFullPath + zipFileName;
            File zipFile = FileUtil.getFile(BASE_DIR + zipFilePath);//change

            if(zipFile.exists()){
                zipFile.delete();
            }

            HashSet<String> excludeFiles = new HashSet<String>();
            HashSet<String> excludeDirectories = new HashSet<String>();
            excludeDirectories.add("node_modules");

            ZipUtility zipUtility = new ZipUtility(excludeFiles, excludeDirectories);
        	zipUtility.zip(srcFilesList, zipFile);

            status = STATUS_SUCCESS;
            message = "zip file written :" + zipFile.getAbsolutePath();

            downloadFilePath = zipFilePath;

        }


        if(status == STATUS_SUCCESS && downloadFilePath.length() > 0){
        	String redirectUrl = request.getContextPath() +"/"+ downloadFilePath;
            response.sendRedirect(redirectUrl);
        }


    }//try
    catch(SimpleException ex){
        status = STATUS_ERROR;
        message = ex.getMessage();
        ex.print();
    }
    catch(Exception ex){
        status = STATUS_ERROR;
        message = ex.getMessage();
        new SimpleException("",ex).print();
    }
%>
<html>
    <head></head>
    <body>
        <%=message%>
        <br>
        <a href="<%=request.getContextPath()%>/">go back</a>
        <script type="text/javascript">
            var status = '<%=status%>';
            var message = '<%=message%>';
            if(status != '1' && typeof window.parent.bootAlert != 'undefined'){
                window.parent.bootAlert(message);
            }

        </script>
    </body>
</html>


