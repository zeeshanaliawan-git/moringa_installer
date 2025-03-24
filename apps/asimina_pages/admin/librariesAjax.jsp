<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, com.etn.asimina.util.ActivityLog"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();

    String q = "";
    Set rs = null;
    int count = 0;

    String requestType = parseNull(request.getParameter("requestType"));

    String siteId = getSiteId(session);;
    try{

        if("getList".equalsIgnoreCase(requestType)){
            try{

                JSONArray libList = new JSONArray();
                JSONObject curEntry = null;

                q = " SELECT l.*, COUNT(DISTINCT f.id) AS nb_files,l1.name updatedby, "
                    + "   (COUNT(DISTINCT btl.bloc_template_id) + COUNT(DISTINCT cl.component_id) ) AS nb_uses "
                    + " ,th.name as theme_name, th.status as theme_status, l.theme_id, th.version as  theme_version "
                    + " FROM libraries l "
                    + " LEFT JOIN themes th on th.id = l.theme_id "
                    + " LEFT JOIN login l1 on l1.pid = l.updated_by "
                    + " LEFT JOIN libraries_files lf ON lf.library_id = l.id"
                    + " LEFT JOIN files f ON lf.file_id = f.id"
                    + " LEFT JOIN bloc_templates_libraries btl ON btl.library_id = l.id "
                    + " LEFT JOIN component_libraries cl ON cl.library_id = l.id "
                    + " WHERE l.site_id = " + escape.cote(siteId)
                    + " GROUP BY l.id ";
                rs = Etn.execute(q);
                while(rs.next()){
                    curEntry = new JSONObject();
                    for(String colName : rs.ColName){
                        curEntry.put(colName.toLowerCase(), rs.value(colName));
                    }

                    libList.put(curEntry);
                }

                data.put("libraries",libList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting libraries list. Please try again.",ex);
            }
        }
        if("getCompactList".equalsIgnoreCase(requestType)){
            try{

                JSONArray libList = new JSONArray();
                JSONObject curEntry = null;

                q = " SELECT id , name "
                    + " FROM libraries l "
                    + " WHERE site_id = " + escape.cote(siteId)
                    + " ORDER BY name ASC";
                rs = Etn.execute(q);
                while(rs.next()){
                    curEntry = new JSONObject();
                    for(String colName : rs.ColName){
                        curEntry.put(colName.toLowerCase(), rs.value(colName));
                    }

                    libList.put(curEntry);
                }

                data.put("libraries",libList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting libraries list. Please try again.",ex);
            }
        }
        else if("getLibraryInfo".equalsIgnoreCase(requestType)){
            try{
                String libId = parseNull(request.getParameter("id"));
                String langId = parseNull(request.getParameter("langId"));

                JSONObject libraryObj = new JSONObject();

                q = " SELECT l.*, th.status as theme_status "
                + " FROM libraries l"
                + " LEFT JOIN themes th ON th.id = l.theme_id "
                + " WHERE l.id = " + escape.cote(libId)
                + " AND l.site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if(rs.next()){
                    for(String colName : rs.ColName){
                        libraryObj.put(colName.toLowerCase(), rs.value(colName));
                    }
                }
                else{
                	throw new SimpleException("Invalid parameters");
                }

                JSONArray filesList = new JSONArray();
                JSONObject curEntry = null;

                q = " SELECT lf.file_id AS id, f.file_name AS name "
                	+ " , lf.page_position , lf.sort_order "
                	+ " FROM libraries_files lf "
                	+ " JOIN files f ON f.id = lf.file_id "
                	+ " WHERE library_id = " + escape.cote(libId)
                    + " AND f.site_id = " + escape.cote(siteId)
                    + " AND lf.lang_id = " + escape.cote(langId)
                	+ " ORDER BY lf.page_position, lf.sort_order ASC";
                rs = Etn.execute(q);
                while(rs.next()){
                    curEntry = new JSONObject();
                    for(String colName : rs.ColName){
                        curEntry.put(colName.toLowerCase(), rs.value(colName));
                    }

                    filesList.put(curEntry);
                }

                libraryObj.put("files",filesList);

                data.put("library",libraryObj);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting library.",ex);
            }
        }
        else if("saveLibrary".equalsIgnoreCase(requestType)){
            try{
                String libId = parseNull(request.getParameter("id"));
                String name = parseNull(request.getParameter("name"));
                JSONArray reqJsonArray = new JSONArray(parseNull(request.getParameter("bodyFiles")));
                boolean isNewLib=false;

                int themeVersion = 0;
                int themeId = 0;
                //theme check
                if(libId.length() > 0){
                    q = "SELECT th.status as theme_status, l.theme_version, l.theme_id "
                    + " FROM libraries l "
                    + " LEFT JOIN themes th ON th.id = l.theme_id "
                    + " WHERE l.id = "+escape.cote(libId)
                    + " AND l.is_deleted='0' AND l.site_id = "+escape.cote(siteId);
                   rs =  Etn.execute(q);
                   if(rs.next()){
                       if(rs.value("theme_status").equals(Constant.THEME_LOCKED) && !isSuperAdmin(Etn)){
                           throw new SimpleException("Error: You are not authorized.");
                       }
                       themeId = parseInt(rs.value("theme_id"));
                       themeVersion = parseInt(rs.value("theme_version"));
                   }
                }

                //check name duplicate
                q = "SELECT id FROM libraries "
                    + " WHERE name = " + escape.cote(name)
                    + " AND is_deleted='0' AND is_deleted='0' AND site_id = " + escape.cote(siteId);
                if(libId.length() > 0){
                    q += " AND id != " + escape.cote(libId);
                }
                rs = Etn.execute(q);
                if(rs.next()){
                    throw new SimpleException("Error: name already exist.");
                }

                int pid = Etn.getId();

                colValueHM.put("name",escape.cote(name));
                colValueHM.put("updated_by",escape.cote(""+pid));
                colValueHM.put("updated_ts","NOW()");

                if(parseInt(libId) <= 0){
                	colValueHM.put("created_ts","NOW()");
                	colValueHM.put("created_by",escape.cote(""+pid));
                    colValueHM.put("site_id",escape.cote(siteId));

                	q = getInsertQuery("libraries",colValueHM);

                	int newLibId = Etn.executeCmd(q);
                	if(newLibId <=0){
                		throw new SimpleException("Error in inserting library record");
                	}
                	else{
                		libId = "" + newLibId;
                        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),libId,"CREATED","Libraries",name,siteId);
                	}

                    isNewLib=true;
                }
                else{
                    if(themeId>0){
                        themeVersion = themeVersion + 1;
                        colValueHM.put("theme_version" ,themeVersion+"");
                    }
                	q = getUpdateQuery("libraries", colValueHM, " WHERE is_deleted='0' AND id = " + escape.cote(libId) );
                	int upCount = Etn.executeCmd(q);
                	if(upCount <=0){
                		throw new SimpleException("Error in updating library record");
                	}
                    else{
                        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),libId,"UPDATED","Libraries",name,siteId);
                    }
                }

                int langCount=0;
                String bodyFiles = "";
                String headFiles = "";

                for (Object obj: reqJsonArray) {

                    JSONObject tmpObj = (JSONObject)obj;
                    
                    String langId = tmpObj.getString("lang");   

                    if(!isNewLib){
                        bodyFiles = parseNull(tmpObj.getString("body"));
                        headFiles = parseNull(tmpObj.getString("head"));
                    }else{
                        if(langCount==0){
                            bodyFiles = parseNull(tmpObj.getString("body"));
                            headFiles = parseNull(tmpObj.getString("head"));
                        }
                    }

                    Etn.executeCmd("DELETE FROM libraries_files WHERE library_id = " + escape.cote(libId)+" and lang_id="+escape.cote(langId));

                    String qPrefix = "INSERT INTO libraries_files (library_id,lang_id, file_id, page_position, sort_order) "
                            + " VALUES (" + escape.cote(libId)+","+escape.cote(langId);
                    
                    int sort_order = 0;

                    for(String fileId : bodyFiles.split(",")){
                        if(parseInt(fileId) > 0){
                            q = qPrefix + ", " + escape.cote(fileId)
                                + " , 'body' , " + escape.cote(""+sort_order) + ")";
                            Etn.executeCmd(q);
                            sort_order++;
                        }
                    }                    
                    
                    sort_order = 0;
                    for(String fileId : headFiles.split(",")){
                        if(parseInt(fileId) > 0){
                            q = qPrefix + ", " + escape.cote(fileId)
                                + " , 'head' , " + escape.cote(""+sort_order) + ")";
                            Etn.executeCmd(q);
                            sort_order++;
                        }
                    }
                    langCount++;
                }

                markPagesToGenerate(libId, "libraries_tbl",Etn);

                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving library.",ex);
            }
        }
        else if("deleteLibrary".equalsIgnoreCase(requestType)){
            try{

                String logedInUserId = parseNull(Etn.getId());

                String libId = parseNull(request.getParameter("id"));

                String curName = "";

                q = "SELECT name, theme_id "
                + " FROM libraries "
                + " WHERE id = " + escape.cote(libId)+" AND  site_id = "+ escape.cote(siteId);//change
                rs =  Etn.execute(q);
                if(rs.next()){
                    if(parseInt(rs.value("theme_id")) > 0){ // it is part of theme
                        throw new SimpleException("Cannot delete, library is used in theme, you have to first delete library from theme.");
                    }
                    curName = rs.value("name");
                }

                q = "SELECT COUNT(0) as count FROM bloc_templates_libraries "
                    + " WHERE library_id = " + escape.cote(libId);

                rs = Etn.execute(q);
                rs.next();

                int usesCount = parseInt(rs.value("count"),-1);
                if(usesCount != 0){
                    throw new SimpleException("Cannot delete, libary is used in bloc templates.");
                }

                q = "SELECT COUNT(0) as count FROM component_libraries "
                    + " WHERE library_id = " + escape.cote(libId);

                rs = Etn.execute(q);
                rs.next();

                usesCount = parseInt(rs.value("count"),-1);
                if(usesCount != 0){
                    throw new SimpleException("Cannot delete, library is used in dynamic components.");
                }

                //check duplicate in trash
                Set rsCheckTrash= Etn.execute("SELECT f1.name as 'name1',f1.is_deleted,f2.name as 'name2', f2.is_deleted,f2.id as 'id' FROM libraries f1 "+
                    "left JOIN libraries f2 ON f1.name=f2.name AND f1.id != f2.id AND f1.site_id=f2.site_id "+
                    "WHERE f1.id="+escape.cote(libId)+" AND f1.site_id = " + escape.cote(siteId));
                
                rsCheckTrash.next();
                if(!rsCheckTrash.value("id").equals("")){
                    Etn.executeCmd("delete from libraries WHERE id = "+escape.cote(rsCheckTrash.value("id")));
                }

                Etn.executeCmd("UPDATE libraries SET is_deleted='1',updated_ts=NOW()"+
                    ",updated_by="+escape.cote(logedInUserId)+" WHERE id = "+escape.cote(libId));

                status = STATUS_SUCCESS;

                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),libId,"DELETED","Libraries", curName,siteId);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting library.",ex);
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
