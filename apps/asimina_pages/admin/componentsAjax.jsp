<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set,  com.etn.pages.PagesUtil, com.etn.pages.PagesGenerator, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, com.etn.asimina.util.ActivityLog"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();

    String q = "";
    Set rs = null;
    int count = 0;
    String siteId = getSiteId(session);

    String requestType = parseNull(request.getParameter("requestType"));

    try{

        if("getList".equalsIgnoreCase(requestType)){
            try{
                JSONArray retList = new JSONArray();
                JSONObject curObj = null;

                q = " SELECT c.id, c.name, c.site_id, c.file_path, c.created_ts, c.updated_ts, "
                    + " c.thumbnail_status,l.name updated_by "
                    + " FROM components c"
                    + " LEFT JOIN login l on l.pid = c.updated_by "
                    + " WHERE c.site_id = " + escape.cote(getSiteId(session));
                rs = Etn.execute(q);
                while(rs.next()){
                    curObj = new JSONObject();
                    for(String colName : rs.ColName){
                        curObj.put(colName.toLowerCase(), rs.value(colName));
                    }

                    JSONArray compProperties = new JSONArray();
					curObj.put("properties",compProperties);

                    JSONArray urls = new JSONArray();
                    curObj.put("urls",urls);

                    retList.put(curObj);

                    q = "SELECT *"
                    	+ " FROM component_properties cp "
                    	+ " WHERE component_id = " + escape.cote(rs.value("id"));
					Set cRs = Etn.execute(q);
					while(cRs.next()){
						curObj = new JSONObject();
	                    for(String colName : cRs.ColName){
	                        curObj.put(colName.toLowerCase(), cRs.value(colName));
	                    }
	                    compProperties.put(curObj);
					}

                    q = "SELECT url  "
                        + " FROM page_component_urls  "
                        + " WHERE type = 'component' AND page_item_id = '0' "
                        + " AND component_id = " + escape.cote(rs.value("id"));
                    cRs = Etn.execute(q);
                    while(cRs.next()){
                        urls.put(cRs.value("url"));
                    }
                }

                data.put("components",retList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting components list. Please try again.",ex);
            }
        }
        else if("getListShort".equalsIgnoreCase(requestType)){
            try{

                JSONArray retList = new JSONArray();
                JSONObject curObj = null;

                q = " SELECT c.id, c.name, GROUP_CONCAT(cp.`name` SEPARATOR ', ') AS properties "
                    + " FROM components c"
                    + " JOIN component_properties cp ON cp.component_id = c.id"
                    + " WHERE c.site_id = " + escape.cote(getSiteId(session))
                    + " GROUP BY c.id"
                    + " ORDER BY c.name, cp.name";
                rs = Etn.execute(q);
                while(rs.next()){
                    curObj = new JSONObject();
                    for(String colName : rs.ColName){
                        curObj.put(colName.toLowerCase(), rs.value(colName));
                    }
                    retList.put(curObj);
                }

                data.put("components",retList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting components list. Please try again.",ex);
            }
        }
        else if("getComponentInfo".equalsIgnoreCase(requestType)){
            try{
                String compId = parseNull(request.getParameter("id"));

                JSONObject retObj = new JSONObject();

				JSONObject curObj = new JSONObject();

                q = " SELECT * "
                    + " FROM components c"
                    + " WHERE c.site_id = " + escape.cote(getSiteId(session))
				 	+ " AND id = " + escape.cote(compId);
                rs = Etn.execute(q);
                if(rs.next()){
                    retObj = new JSONObject();
                    for(String colName : rs.ColName){
                        retObj.put(colName.toLowerCase(), rs.value(colName));
                    }


					JSONArray properties = new JSONArray();
					retObj.put("properties",properties);

					JSONArray packages = new JSONArray();
					retObj.put("packages",packages);

					JSONArray dependencies = new JSONArray();
					retObj.put("dependencies",dependencies);

                    JSONArray libraries = new JSONArray();
                    retObj.put("libraries",libraries);

                    JSONArray urls = new JSONArray();
                    retObj.put("urls",urls);

                    q = "SELECT *"
                    	+ " FROM component_properties cp "
                    	+ " WHERE component_id = " + escape.cote(compId);
					rs = Etn.execute(q);
					while(rs.next()){
						curObj = new JSONObject();
	                    for(String colName : rs.ColName){
	                        curObj.put(colName.toLowerCase(), rs.value(colName));
	                    }
	                    properties.put(curObj);
					}

					q = "SELECT *"
                    	+ " FROM component_packages  "
                    	+ " WHERE component_id = " + escape.cote(compId);
					rs = Etn.execute(q);
					while(rs.next()){
						curObj = new JSONObject();
	                    for(String colName : rs.ColName){
	                        curObj.put(colName.toLowerCase(), rs.value(colName));
	                    }
	                    packages.put(curObj);
					}

					q = "SELECT id, name "
                    	+ " FROM components c "
                    	+ " JOIN component_dependencies cd ON cd.main_component_id = c.id "
                    	+ " WHERE dependant_component_id = " + escape.cote(compId);
					rs = Etn.execute(q);
					while(rs.next()){
						curObj = new JSONObject();
	                    for(String colName : rs.ColName){
	                        curObj.put(colName.toLowerCase(), rs.value(colName));
	                    }
	                    dependencies.put(curObj);
					}

                    q = "SELECT library_id  "
                        + " FROM component_libraries  "
                        + " WHERE component_id = " + escape.cote(compId);
                    rs = Etn.execute(q);
                    while(rs.next()){
                        curObj = new JSONObject();
                        curObj.put("library_id",rs.value("library_id"));
                        libraries.put(curObj);
                    }

                    q = "SELECT url  "
                        + " FROM page_component_urls  "
                        + " WHERE type = 'component' AND page_item_id = '0' "
                        + " AND component_id = " + escape.cote(compId);
                    rs = Etn.execute(q);
                    while(rs.next()){
                        urls.put(rs.value("url"));
                    }

                }

                data.put("component",retObj);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in component info. Please try again.",ex);
            }
        }
        else if("deleteComponent".equalsIgnoreCase(requestType)){
            try{
                String compIds = parseNull(request.getParameter("id"));
                int deleteCounter = 0;
                String compNames = "";
                for(String compId : compIds.split(",")){

                    q = "SELECT id, file_path, name FROM components "
                    	+ " WHERE id = " + escape.cote(compId)
                    	+ " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);
                    if(!rs.next()){
                    	throw new SimpleException("Invalid parameters");
                    }
                    String  compName = parseNull(rs.value("name"));
                    if(!compName.equals("")) compNames += compName+", ";
                    String filePath = rs.value("file_path");

                    //do not delete if component in use
    				q = "SELECT main_component_id FROM component_dependencies "
    				 	+ " WHERE main_component_id = " + escape.cote(compId);
    				rs = Etn.execute(q);

    				if(rs.rs.Rows > 0){
    					throw new SimpleException("Cannot delete as some other components are dependent on this component.");
    				}


    				q = "SELECT component_id FROM page_items "
    				 	+ " WHERE component_id = " + escape.cote(compId);
    				rs = Etn.execute(q);

    				if(rs.rs.Rows > 0){
    					throw new SimpleException("Cannot delete. This component is used in pages.");
    				}

    			 	//go ahead and delete
    				q = " DELETE FROM component_properties "
    					+ " WHERE component_id = " + escape.cote(compId);
    				Etn.executeCmd(q);

    				q = " DELETE FROM component_packages "
    					+ " WHERE component_id = " + escape.cote(compId);
    				Etn.executeCmd(q);

    				q = " DELETE FROM component_dependencies "
    					+ " WHERE dependant_component_id = " + escape.cote(compId);
    				Etn.executeCmd(q);

    				q = " DELETE FROM components "
    					+ " WHERE id = " + escape.cote(compId);
    				Etn.executeCmd(q);

                    try{
                        String UPLOAD_DIR = GlobalParm.getParm("BASE_DIR") +  GlobalParm.getParm("UPLOADS_FOLDER");
                        String COMP_DIR = UPLOAD_DIR + siteId + "/" + "components/" ;
                        File compFile = new File(COMP_DIR + filePath);
                        if(compFile.exists()){
                            compFile.delete();
                        }
                    }
                    catch(Exception tEx){

                    }
                    deleteCounter++;
                }
                if(deleteCounter>0)
                    status = STATUS_SUCCESS;

                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),compIds,"DELETED","Component",compNames,siteId);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting component. Please try again.",ex);
            }
        }
        else if("generatePreview".equalsIgnoreCase(requestType)){
            try{
                boolean isGenerate = "1".equals(parseNull(request.getParameter("isGenerate")));
                String compIds[]= request.getParameterValues("compIds");

                int totalCount = compIds.length;
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                String publishStatus = isGenerate ? "queued":"unpublished";
                String retStatus = isGenerate ? "queued for generation":"deleted";

                q = "UPDATE components SET thumbnail_status = " + escape.cote(publishStatus)
                        + " WHERE site_id = " + escape.cote(siteId)
                        + " AND id = ";
                for(String curCompId : compIds){
                    Etn.executeCmd(q + escape.cote(curCompId));
                }

                if(isGenerate){
                    q = "SELECT semfree(" + escape.cote(parseNull(GlobalParm.getParm("SEMAPHORE"))) + ");";
                    Etn.execute(q);
                }

                status = STATUS_SUCCESS;
                message = "" + totalCount + " component previews " + retStatus;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in preview publish/unpublish. Please try again.",ex);
            }
        }
        else if("getThumbnailPreview".equalsIgnoreCase(requestType)){

            try{
                String id = parseNull(request.getParameter("id"));

                q = "SELECT thumbnail_status, thumbnail_file_name, html FROM components "
                    + " WHERE id = " + escape.cote(id)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if(rs.next()){

                    if(rs.value("thumbnail_status").equals("published")){
                    	String EXTERNAL_LINK =  GlobalParm.getParm("EXTERNAL_LINK");
                    	String UPLOADS_FOLDER =  GlobalParm.getParm("UPLOADS_FOLDER");

    					String fileName = rs.value("thumbnail_file_name");
    					String thumbnailUrl = EXTERNAL_LINK + UPLOADS_FOLDER
    							+ siteId + "/component_images/" + fileName;

    					data.put("thumbnailUrl",thumbnailUrl);
                    	data.put("html",rs.value("html"));
                    	status = STATUS_SUCCESS;
                    }

                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting log.",ex);
            }
        }
        else if("getLog".equalsIgnoreCase(requestType)){

            try{
                String id = parseNull(request.getParameter("id"));

                q = "SELECT thumbnail_log FROM components "
                    + " WHERE id = " + escape.cote(id)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if(rs.next()){
                    String log = parseNull(rs.value("thumbnail_log"));
                    data.put("log", log);

                    status = STATUS_SUCCESS;
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting log.",ex);
            }
        }
        else if("test".equalsIgnoreCase(requestType)){
            try{

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in testing.",ex);
            }
        }

    }
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
