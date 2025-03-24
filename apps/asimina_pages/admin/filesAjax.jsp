<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, org.apache.commons.io.FileUtils, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, com.sun.xml.internal.bind.v2.runtime.reflect.opt.Const,com.etn.asimina.util.FileUtil"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../WEB-INF/include/fileMethods.jsp"%>

<%!
    String deleteFiles(Contexte Etn,String id,String siteId,String logedInUserId){
		Set rsFiles=Etn.execute("SELECT type ,file_name from "+GlobalParm.getParm("PAGES_DB")+".files_tbl WHERE times_used =0 AND id = "+
			escape.cote(id)+" AND site_id = " + escape.cote(siteId));
		
		if(rsFiles.next()){
			String fileName = rsFiles.value("file_name");
			String fileType = rsFiles.value("type");
			String TRASH_DIR = GlobalParm.getParm("TRASH_FOLDER") + siteId + "/"+ fileType + "/";
       
            File trashFile = FileUtil.getFile(TRASH_DIR+fileName);//change
            if(trashFile.exists()){
                trashFile.delete();
            }
            if(isMediaType(fileType)){
                String[] folders = {"thumb", "og", "4x3"};
                for(String folder : folders){
                    trashFile = FileUtil.getFile(TRASH_DIR  +  folder + "/" +fileName);//chnage
                    if(trashFile.exists()){
                        trashFile.delete();
                    }
                }
            }         
            Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".libraries_files WHERE file_id = " + escape.cote(id));
            Etn.executeCmd("DELETE FROM "+GlobalParm.getParm("PAGES_DB")+".files_tbl WHERE id = " + escape.cote(id) + 
                " AND site_id = " + escape.cote(siteId));
		}else{
			return "error";
		}
		return "success";
	}
%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();
    String q = "";
    Set rs = null;
	
	//IMPORTANT - We must define sort orders here otherwise sql injection can happen as we getting sortOrder from request
	//and hacker write a query in it
	List<String> possibleSortOrders = new ArrayList<>();
	possibleSortOrders.add("f.updated_ts desc");
	possibleSortOrders.add("f.label asc");
	possibleSortOrders.add("f.label desc");
	possibleSortOrders.add("f.updated_ts asc");
	possibleSortOrders.add("f.updated_ts desc");
	possibleSortOrders.add("f.times_used asc");
	possibleSortOrders.add("f.times_used desc");
	possibleSortOrders.add("f.file_size asc");
	possibleSortOrders.add("f.file_size desc");

    String requestType = parseNull(request.getParameter("requestType"));
    String siteId = getSiteId(session);
    if(parseNull(request.getParameter("site_id")).length()>0)
        siteId = parseNull(request.getParameter("site_id"));

    try{
		if("getAllFilesList".equalsIgnoreCase(requestType)){
	        try{

	        	String fileTypes = parseNull(request.getParameter("fileTypes"));
                String mediatype = parseNull(request.getParameter("mediatype"));
                String showRemoved = parseNull(request.getParameter("showRemoved"));
                String mediaLength = parseNull(request.getParameter("mediaLength"));
                String mediaSearch = parseNull(request.getParameter("mediaSearch"));
                String fileFilter= parseNull(request.getParameter("fileFilter"));
                
				String sortOrder = parseNull(request.getParameter("sortOrder"));
				if(sortOrder.length() > 0 && possibleSortOrders.contains(sortOrder) == false)
				{
					message = "Invalid sort order provided";
					throw new SimpleException(message);					
				}
				
                String pageNumber = parseNull(request.getParameter("pageNumber"));
                
                String caller = parseNull(request.getParameter("caller"));

                int total_records =0;
	            JSONArray filesList = new JSONArray();
	            q = " SELECT f.*, case when f.removal_date<=now() then 'removed' else 'notRemoved' end as is_removed, l.name as updatedby, th.status as theme_status, th.name as theme_name, th.version as theme_version  FROM files f"
                    + " LEFT JOIN themes th on th.id = f.theme_id "
                    + " LEFT JOIN login l on l.pid = f.updated_by "
                    + " WHERE f.site_id = " + escape.cote(siteId);

                if(mediatype.toLowerCase().equals("used")){
                    q+=" AND f.times_used>0";
                }else if(mediatype.toLowerCase().equals("unused")){
                    q+=" AND f.times_used=0";
                }

                if(fileFilter.length()> 0)
                {
                    int counter = 0;
                    String fileFilterQry = "(";
                    for(String ext : fileFilter.split(","))
                    {   
                        if(ext.length() == 0) continue;
                        if(counter > 0) fileFilterQry+=" OR ";
                        fileFilterQry+=" f.file_name like "+escape.cote("%."+ext)+" ";
                        counter ++;
                    }
                    fileFilterQry+=")";
                    if(fileFilterQry.length() > 1) q+= " AND "+fileFilterQry;
                }

                if(showRemoved.toLowerCase().equals("true")){
                    q+=" AND (COALESCE(f.removal_date,'') != '' or  f.removal_date<=now()) ";
                }

	            if(fileTypes.length() > 0){
	            	String[] fileTypesArr = fileTypes.split(",");

	            	q += " AND f.type IN (";
	            	for( int i=0; i<fileTypesArr.length; i++ ){
	            		if(i > 0){
	            			q += ",";
	            		}
	            		q += escape.cote(fileTypesArr[i]);
	            	}
	            	q += " ) ";
	            }else{
                    q += " AND f.type IN ('')";
                }

                if(mediaSearch.length() > 0){
                    q+= " AND (f.label like " + escape.cote('%'+mediaSearch+'%')+" OR f.label like " + escape.cote('%'+mediaSearch+'%')+
                        " or f.alt_name like " + escape.cote('%'+mediaSearch+'%')+")";
                }
                rs = Etn.execute(q);
                if(rs.next()){
                    total_records = rs.rs.Rows;
                }

                if("mediaLibrary".equals(caller)){
                    if(sortOrder.length() > 0){
                        q += " ORDER BY "+sortOrder;
                    }else{
                        q += " ORDER BY f.updated_ts DESC";
                    }
                }

                if(mediaLength.length() > 0){
                    if(pageNumber.equals("1")){
                        q+= " limit 0," + parseInt(mediaLength);
                    }else{
                        q+= " limit " + (parseInt(pageNumber)-1)*parseInt(mediaLength)+","+parseInt(mediaLength);
                    }
                }
	            rs = Etn.execute(q);
	            JSONObject curFile = null;
	            while(rs.next()){
	                curFile = new JSONObject();
	                for(String colName : rs.ColName){
	                    curFile.put(colName.toLowerCase(), rs.value(colName));
	                }

	                filesList.put(curFile);
	            }

	            status = STATUS_SUCCESS;
	            data.put("files",filesList);
	            data.put("total_records",total_records);

	        }//try
	        catch(Exception ex){
	            message = "Error in getting all files list. Please try again.";
	            throw new SimpleException(message, ex);
	        }

	    }
        else if("getFilesListForLibrary".equalsIgnoreCase(requestType)){
            try{
                //only js and css files

                JSONArray filesList = new JSONArray();

                q = "SELECT id, file_name FROM files"
                    + " WHERE type IN ('css','js') "
                    + " AND site_id = " + escape.cote(siteId)
                    + " ORDER BY file_name ASC ";

                rs = Etn.execute(q);
                JSONObject curObj = null;
                while(rs.next()){
                    curObj = new JSONObject();
                    curObj.put("id",rs.value("id"));
                    curObj.put("file_name",rs.value("file_name"));
                    filesList.put(curObj);
                }

                status = STATUS_SUCCESS;
                data.put("files",filesList);

            }//try
            catch(Exception ex){
                message = "Error in getting files list. Please try again.";
                throw new SimpleException(message, ex);
            }

        }
        else if("getFileInfo".equalsIgnoreCase(requestType)){
	        try{

	            String id = parseNull(request.getParameter("id"));
                
	            JSONArray filesList = new JSONArray();
	            q = " SELECT f.*, th.status as theme_status FROM files f"
	            + " LEFT JOIN themes th ON th.id = f.theme_id"
	            + " WHERE f.id = " + escape.cote(id) + " AND f.site_id = " + escape.cote(siteId);
	            rs = Etn.execute(q);
	            if(rs.next()){
	                JSONObject curFile = new JSONObject();
	                for(String colName : rs.ColName){
                        if(colName.equalsIgnoreCase("id")){
                            JSONArray tagsArray = new JSONArray();
                            Set rsTags = Etn.execute("select * from media_tags where file_id="+escape.cote(rs.value(colName)));
                            while(rsTags.next()){
                                tagsArray.put(parseNull(rsTags.value("tag")));
                            }
	                        curFile.put("tags", tagsArray);
                        }
	                    curFile.put(colName.toLowerCase(), rs.value(colName));
	                }

	                data.put("file",curFile);
	                status = STATUS_SUCCESS;
	            }

	        }//try
	        catch(Exception ex){
	            message = "Error in getting all files list. Please try again.";
	            throw new SimpleException(message, ex);
	        }

	    }
	    else if("deleteFile".equalsIgnoreCase(requestType)){
	        try{
                String logedInUserId = parseNull(Etn.getId());
                JSONArray fileIds = new JSONArray(parseNull(request.getParameter("elements")));
                int countError = 0;
                int countOK = 0;
                for(Object fileIdObj : fileIds){
                    try{       
                        String fileId =  fileIdObj.toString();

                        Set rsFiles=Etn.execute("SELECT ft.is_deleted,ft.file_name as 'f1',ft2.is_deleted,ft2.file_name as 'f2',ft2.id as 'id' from "+GlobalParm.getParm("PAGES_DB")+
                            ".files_tbl ft LEFT JOIN "+GlobalParm.getParm("PAGES_DB")+".files_tbl ft2 ON ft.file_name=ft2.file_name AND ft.id != ft2.id "+
                            "and ft.site_id=ft2.site_id WHERE ft.id = "+escape.cote(fileId)+" AND ft.site_id = " + escape.cote(siteId));
                        rsFiles.next();
                        if(!parseNull(rsFiles.value("f2")).equals("")){
                            if(deleteFiles(Etn, parseNull(rsFiles.value("id")), siteId, logedInUserId).equalsIgnoreCase("error"))
                            {
                                throw new SimpleException("Error: Cannot delete. File is in use.");
                            }
                        }

                        q = "SELECT library_id FROM libraries l "
                            + " JOIN libraries_files lf ON l.id = lf.library_id "
                            + " WHERE l.site_id = " + escape.cote(siteId)
                            + " AND lf.file_id = "+ escape.cote(fileId);
                        rs = Etn.execute(q);

                        if(rs.next()){
                            throw new SimpleException("Error: Cannot delete. File is used in libraries or themes.");
                        }

                        q = " SELECT f.file_name, f.type, f.theme_id, f.times_used FROM files as f "
                            + "LEFT JOIN themes th ON th.id = f.theme_id"
                            + " WHERE f.id = " + escape.cote(fileId)
                            + " AND f.site_id = " + escape.cote(siteId);
                        rs = Etn.execute(q);
                        if(!rs.next()){
                            throw new SimpleException("Invalid request.");
                        }
                        if(parseInt(rs.value("theme_id"))>0){ // theme exsits
                            throw new SimpleException("File is used in themes, it cannot be deleted.");
                        }
                        if(parseInt(rs.value("times_used"))>0){
                            throw new SimpleException("Error: Cannot delete. File is in use.");
                        }

                        String fileName = rs.value("file_name");
                        String fileType = rs.value("type");

                        String UPLOAD_DIR = GlobalParm.getParm("BASE_DIR") +  GlobalParm.getParm("UPLOADS_FOLDER") + siteId + "/";
                        String TRASH_DIR = GlobalParm.getParm("TRASH_FOLDER")+ siteId + "/"+ fileType + "/";
                        
                        File trashDir = FileUtil.getFile(TRASH_DIR);//change
                        FileUtil.mkDirs(trashDir);//change

                        String filePath = UPLOAD_DIR  + fileType + "/" +fileName;
                        String trashFilePath = TRASH_DIR +fileName;
                        
                        File file = FileUtil.getFile(filePath);//change
                        File trashFile = FileUtil.getFile(trashFilePath);//change

                        if(file.exists()){
                            try{
                                FileUtils.copyFile(file, trashFile);
                                file.delete();
                            }catch(Exception ex){
                                throw new SimpleException("Error in deleting file. refresh and try again.", ex);
                            }
                        }
                        
                        if(isMediaType(fileType)){
                            String[] folders = {"thumb", "og", "4x3"};
                            for(String folder : folders){
                                trashFile = FileUtil.getFile(TRASH_DIR + folder + "/" );//change
                                FileUtil.mkDirs(trashFile);//change

                                trashFile = FileUtil.getFile(TRASH_DIR  +  folder + "/" +fileName);//change
                                file = FileUtil.getFile(UPLOAD_DIR  + fileType + "/" + folder + "/" +fileName);//change
                                if(file.exists()){
                                    try{
                                        FileUtils.copyFile(file, trashFile);
                                        file.delete();
                                    }catch(Exception ex){
                                        throw new SimpleException("Error in deleting file. Refresh and try again.", ex);
                                    }
                                }
                            }
                        }               

                        Etn.executeCmd("UPDATE files_tbl SET is_deleted='1',updated_ts=NOW()"+
                            ",updated_by="+escape.cote(logedInUserId)+" WHERE times_used=0 AND id = "+escape.cote(fileId));

                        countOK++;
                    }catch(SimpleException se){
                        se.printStackTrace();
                        message += se.getMessage()+"\n";
                        countError++;
                    }
                }
                status = STATUS_SUCCESS;

                data.put("countOk",countOK);
                data.put("countError",countError);
	        }//try
	        catch(Exception ex){
	            message = "Error in deleting file/files. Refresh and try again.";
	            throw new SimpleException(message, ex);
	        }

	    }
        else if("copyFile".equalsIgnoreCase(requestType)){
            try{

                String fileId   = parseNull(request.getParameter("id"));
                String newFileName   = parseNull(request.getParameter("newName"));
                String newFileLabel   = parseNull(request.getParameter("newLabel"));

                if(newFileName.length() == 0){
                    throw new SimpleException("Error: New name cannot be empty.");
                }

                q = "SELECT * FROM files  "
                    + " WHERE id = " + escape.cote(fileId)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Error: Invalid parameters.");
                }

                String fileType = rs.value("type");
                String fileName = rs.value("file_name");

                //add extension of original file to newfilename
                newFileName += FileUtil.getFileExtension(fileName);//change

                q = "SELECT 1 FROM files  "
                    + " WHERE file_name = " + escape.cote(newFileName)
                    + " AND type = " + escape.cote(fileType)
                    + " AND site_id = " + escape.cote(siteId);

                Set rs2 = Etn.execute(q);
                if(rs2.next()){
                    throw new SimpleException("Error: File of same name already exists.");
                }

                String UPLOAD_DIR = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("UPLOADS_FOLDER") + siteId + "/";
                boolean isMediaUpload = isMediaType(fileType);

                if(isMediaUpload){

                    if(newFileLabel.length() == 0){
                        throw new Exception("Error: label cannot be empty.");
                    }

                }

                File srcFile = FileUtil.getFile( UPLOAD_DIR + fileType + "/" + rs.value("file_name"));//change
                File destFile = FileUtil.getFile( UPLOAD_DIR + fileType + "/" + newFileName);//change

                if(!srcFile.exists() || !srcFile.isFile()){
                    throw new SimpleException("Error: Source file does not exist.");
                }

                copyFile(srcFile, destFile);

                colValueHM.clear();
                colValueHM.put("file_name", escape.cote(newFileName));
                colValueHM.put("label",escape.cote(newFileLabel));
                colValueHM.put("type", escape.cote(rs.value("type")));
                colValueHM.put("file_size", escape.cote(rs.value("file_size")));
                colValueHM.put("created_ts","NOW()");
                colValueHM.put("created_by", escape.cote("" + Etn.getId()) );

                colValueHM.put("updated_ts","NOW()");
                colValueHM.put("updated_by", escape.cote("" + Etn.getId()) );
                colValueHM.put("site_id", escape.cote(siteId));

                q = getInsertQuery("files",colValueHM);

                int newFileId = Etn.executeCmd(q);

                status = STATUS_SUCCESS;
                message = "File copied.";

                if(fileType.equals("img")){
                	try{
    	                generateImages(""+newFileId, Etn);
    	            }
    	            catch(Exception ex){
    	                ex.printStackTrace();
    	            }
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in copying bloc.",ex);
            }
        }
        else if("getSafeFileName".equalsIgnoreCase(requestType)){
            try{

                String fileName = parseNull(request.getParameter("fileName"));
                String fileType = parseNull(request.getParameter("fileType"));

                String safeFileName = getSafeFileName(fileName);

                boolean isFileDuplicate = false;
                q = "SELECT id FROM files "
                    + " WHERE file_name = " + escape.cote(safeFileName)
                    + " AND type = " + escape.cote(fileType)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if(rs.next()){
                    isFileDuplicate = true;
                }

                if( !isFileDuplicate ){
                    status = STATUS_SUCCESS;
                }
                else{
                    status = STATUS_ERROR;
                    message = "Error: file already exists.";
                }

                data.put("fileName",safeFileName);

            }//try
            catch(Exception ex){
                message = "Error in getting safe file name. Please try again.";
                throw new SimpleException(message, ex);
            }

        }
        else if("updateFileSizes".equalsIgnoreCase(requestType)){

            try{

                q = "SELECT id, file_name, type, site_id FROM files WHERE file_size = 0";
                rs = Etn.execute(q);


                while(rs.next()){
                    String fileName = rs.value("file_name");
                    String fileType = rs.value("type");
                    String UPLOAD_DIR = GlobalParm.getParm("BASE_DIR") +  GlobalParm.getParm("UPLOADS_FOLDER") + rs.value("site_id") + "/";

                    String filePath = UPLOAD_DIR + fileType + "/" + fileName;

                    File file = FileUtil.getFile(filePath);//change

                    String fileSize = getFileSize(file);

                    q = " UPDATE files SET file_size = " + escape.cote(fileSize)
                        + " WHERE id = " + escape.cote(rs.value("id"));
                    Etn.executeCmd(q);
                }

            }//try
            catch(Exception ex){
                message = "Error in updating file sizes. Please try again.";
                throw new SimpleException(message, ex);
            }

        }
        else if("cleanupUnusedMedia".equalsIgnoreCase(requestType)){
            try{
                boolean isConfirmed = "1".equals(parseNull(request.getParameter("confirmed")));

				q = " SELECT f.file_name, f.type, f.site_id, SUM(IFNULL(t1.uses,0)) as total_uses  "
					+ " FROM files f "
					+ " LEFT JOIN  "
					+ " ( "
					+ "     SELECT f.file_name, count(bd.bloc_id) as uses  "
					+ "     FROM files f, blocs_details bd "
					+ "     WHERE bd.template_data LIKE CONCAT('%',f.file_name,'%') "
					+ "     GROUP BY f.file_name "
					+ "     UNION ALL "
					+ "     SELECT f.file_name, count(scd.id) as uses  "
					+ "     FROM files f, structured_contents_details scd "
					+ "     WHERE scd.content_data LIKE CONCAT('%',f.file_name,'%') "
					+ "     GROUP BY f.file_name "
					+ "     UNION ALL "
					+ "     SELECT f.file_name, count(bt.id) as uses  "
					+ "     FROM files f, bloc_templates bt "
					+ "     WHERE bt.template_code LIKE CONCAT('%',f.file_name,'%') "
					+ "     GROUP BY f.file_name "
					+ " ) as t1 ON t1.file_name = f.file_name "
					+ " WHERE f.type IN ('img','video','other') "
					+ " GROUP BY f.file_name "
					// + " ORDER BY total_uses DESC "
					+ " HAVING SUM(IFNULL(t1.uses,0)) = 0 ";

                if(isConfirmed){
					//delete un-used files
					Logger.debug("### DELETE un-used media files by user id =" + Etn.getId() );
					//rs = Etn.execute(q); //disabled , query needs updates
					int count = 0;
					while(rs.next()){
						try{
							String fileName = rs.value("file_name");
							String fileType = rs.value("type");
                            String curSiteId = rs.value("site_id");

                            String UPLOAD_DIR = GlobalParm.getParm("BASE_DIR") + GlobalParm.getParm("UPLOADS_FOLDER") + curSiteId + "/";

							File destFile = FileUtil.getFile(UPLOAD_DIR + fileType + "/" + fileName);//change
							if(destFile.exists() && destFile.isFile()){
								destFile.delete();
							}
							else{
								Logger.debug("File not found on disk: "+ fileName);//debug
							}

							q = "DELETE FROM files WHERE file_name = " + escape.cote(fileName)
								+ " AND type = " + escape.cote(fileType) + " AND site_id = " + escape.cote(curSiteId);
							Etn.executeCmd(q);
							Logger.debug("File deleted : "+ fileName);//debug //to be removed later

							count++;
						}
						catch(Exception fileEx){
							fileEx.printStackTrace();
						}
					}
					Logger.debug("Files deleted count = " + count);
					data.put("count", count);
					status = STATUS_SUCCESS;

                }
                else{
                	q = "SELECT COUNT(0) as file_count FROM (" + q + " ) t2 ";
                	rs = Etn.execute(q);
                	rs.next();
                    int count = parseInt(rs.value("file_count"));
                    data.put("count",count);
                    status = STATUS_SUCCESS;
                }

            }//try
            catch(Exception ex){
                message = "Error in cleanup unused. Please try again.";
                throw new SimpleException(message, ex);
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
