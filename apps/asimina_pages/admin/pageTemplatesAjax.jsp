<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, java.util.Map, com.etn.asimina.util.ActivityLog"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%!
    String _firstName = "usman";
    double pointVal = 9.3;
    boolean isGood = false;

    int num1 = 5;
    int num2 =6;


    public String getDefaultPageTemplateCode(){
        return "<!DOCTYPE html>\n<html>\n    <head>\n        \n    </head>\n    <body>\n        ${content}\n    </body>\n</html>";
    }

    public String createDefaultTemplate(String siteId, com.etn.beans.Contexte Etn) throws Exception, SimpleException{
        //oprator precedence
        int result = num1 * num2 + 10;
        String first_name = "Rohan";
        String last_name = "Asif";
        String full_name  = first_name + " " +last_name; // Rohan Asif
        

        String q = "SELECT id FROM page_templates WHERE is_system = '1' AND site_id = " + escape.cote(siteId);
        Set rs = Etn.execute(q);

        if(rs.next()){
			throw new SimpleException("Default template already exists");
		}

        String pid = "" + Etn.getId();

        q = "INSERT INTO page_templates (name, site_id, custom_id, description, template_code, is_system, uuid, created_ts, updated_ts, created_by, updated_by ) VALUES "
            + " ( 'Default template', " + escape.cote(siteId) + ", 'default_template', 'Default page template', "
            + escapeCote(getDefaultPageTemplateCode()) + ", "
            + " '1', UUID(), NOW(), NOW(), " + escape.cote(pid) + ", " + escape.cote(pid) + " ) ";
        int templateIdInt = Etn.executeCmd(q);
        if(templateIdInt <= 0){
        	throw new SimpleException("Error in creating default page template");
        }

        String templateId = ""+templateIdInt;

        PagesUtil.createOrGetContentRegionId(templateId, Etn, Etn.getId());

        return templateId;

    }

%>
<%
    final int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    Map<String, String> colValueHM = new LinkedHashMap<>();

    String q = "";
    Set rs = null;
    int count = 0;

    String requestType = parseNull(request.getParameter("requestType"));

    String logedInUserId = parseNull(Etn.getId());

	try{
		String siteId = getSiteId(session);
	    if("getList".equalsIgnoreCase(requestType)){
	    	try{

	    		JSONArray retList = new JSONArray();

				q = " SELECT pt.*, COUNT(p.id) AS nb_use, l.name updatedby, 'page template' as type  "
				    + ", th.name as theme_name, th.version as theme_version, th.status as theme_status, pt.theme_id "
				    + " FROM page_templates pt"
                    + " LEFT JOIN themes th ON th.id = pt.theme_id "
                    + " LEFT JOIN login l ON l.pid = pt.updated_by "
                    + " LEFT JOIN pages p ON pt.id = p.template_id "
                    + " WHERE pt.site_id = " + escape.cote(siteId)
                    + " GROUP BY pt.id ";
				rs = Etn.execute(q);
				while(rs.next()){
					JSONObject curTemplate = getJSONObject(rs);
					retList.put(curTemplate);
				}

				data.put("templates",retList);
				status = STATUS_SUCCESS;

	    	}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in getting page templates list. Please try again.",ex);
	    	}
	    }
	    else if("getInfo".equalsIgnoreCase(requestType)){
             try{
	            String templateId = parseNull(request.getParameter("templateId"));


	            q = "SELECT pt.* "
                    + " FROM page_templates pt "
                    + " WHERE id = " + escape.cote(templateId)
                    + " AND site_id = " + escape.cote(siteId);

	            rs = Etn.execute(q);
	            if(!rs.next()){
	                throw new SimpleException("Invalid parameters");
	            }

	            JSONObject templateData = getJSONObject(rs);
                templateData.remove("template_code");

	            data.put("template", templateData);
	            status = STATUS_SUCCESS;

	        }//try
	        catch(Exception ex){
	            throw new SimpleException("Error in getting template info. Please try again.",ex);
	        }
	    }
	    else if("getTemplateData".equalsIgnoreCase(requestType)){
	        try{
                String id = parseNull(request.getParameter("templateId"));

                String templateCode = "";
                JSONArray itemsList = new JSONArray();

                q = "SELECT template_code FROM page_templates "
                    + " WHERE id = " + escape.cote(id)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);

                if(rs.next()){
                    templateCode = rs.value("template_code");

                    List<Language> langsList = getLangs(Etn,getSiteId(session));

                    q = "SELECT * FROM page_templates_items "
                        + " WHERE page_template_id = "+ escape.cote(id)
                        + " ORDER BY sort_order ASC, id ASC";
                    rs = Etn.execute(q);
                    while(rs.next()){

                        JSONObject itemJson = getJSONObject(rs);
                        itemsList.put(itemJson);

                        JSONArray itemDetails = new JSONArray();
                        itemJson.put("details", itemDetails);

                        String itemId = rs.value("id");

                        for ( Language curLang : langsList ) {
                        	String langId = ""+curLang.getLanguageId();

                        	JSONObject detailObj = new JSONObject();
                        	itemDetails.put(detailObj);

                        	detailObj.put("langue_id", langId);

                        	JSONArray blocsList = new JSONArray();
                        	detailObj.put("blocs", blocsList);

                        	q = " SELECT css_classes, css_style FROM page_templates_items_details "
                        		+ " WHERE item_id = " + escape.cote(itemId)
                        		+ " AND langue_id = " + escape.cote(langId);
                        	Set detailRs = Etn.execute(q);
                        	if(detailRs.next()){
                        	  	detailObj.put("css_classes", detailRs.value("css_classes"));
                        	  	detailObj.put("css_style", detailRs.value("css_style"));
                        	}
                        	else{
                        		detailObj.put("css_classes", "");
                        	  	detailObj.put("css_style", "");
                        	}


                        	q = " SELECT * FROM ("
                                + " SELECT b.id, b.name, pb.type AS type, pb.sort_order FROM page_templates_items_blocs pb "
                        	 	+ " JOIN blocs b ON b.id = pb.bloc_id AND pb.type = 'bloc' "
                        	 	+ " WHERE pb.item_id = " + escape.cote(itemId)
                        		+ " AND pb.langue_id = " + escape.cote(langId)
                                + " ) AS t "
                                + " ORDER BY sort_order ";

                        	detailRs = Etn.execute(q);
                        	while(detailRs.next()){
                        		JSONObject blocObj = new JSONObject();
                        		blocObj.put("id", detailRs.value("id"));
                        		blocObj.put("name", detailRs.value("name"));
                                blocObj.put("type", detailRs.value("type"));
                        		blocsList.put(blocObj);
                        	}

                        }//for lang

                    }//while items

                }

                data.put("template_code",templateCode);
                data.put("items",itemsList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting sections data. Please try again.", ex);
            }
	    }
        else if("deleteTemplates".equalsIgnoreCase(requestType)){
            try{
                String[] templateIds= request.getParameterValues("templateIds");

                int totalCount = templateIds.length;
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                int deleteCount = 0;
                String deletedTemplateIds = "";
                String deletedTemplateNames = "";
                for(String templateId : templateIds){
                    if(parseInt(templateId,0) < 1){
                        continue;
                    }

                    q = " SELECT  pt.id, pt.is_system, COUNT(p.id) AS nb_use, pt.name "
                        + " FROM page_templates_tbl pt"
                        + " LEFT JOIN pages p ON pt.id = p.template_id "
                        + " WHERE pt.site_id = " + escape.cote(siteId)
                        + " AND pt.id = " + escape.cote(templateId)
                        + " and pt.is_deleted='0' AND pt.is_system = 0 "
                        + " GROUP BY pt.id ";

                    rs = Etn.execute(q);
                    if(!rs.next()){
                        continue;
                    }
                    else{
                    	int usesCount = parseInt(rs.value("nb_use"),-1);
	                    if(usesCount != 0){
	                        continue;
	                    }
                    }

                    // if template is a part of theme then it cannot be deleted
                    q = "SELECT pt.theme_id FROM page_templates_tbl pt "
                        + " LEFT JOIN themes th ON th.id = pt.theme_id"
                        + " WHERE pt.id = " + escape.cote(templateId)
                        + " and pt.is_deleted='0' AND pt.site_id = " + escape.cote(siteId);

                    rs =  Etn.execute(q);
                    if(rs.next() && parseInt(rs.value("theme_id"))>0){ //it is part of theme
                        continue;
                    }

                    //check duplicate in trash
                    Set rsCheckTrash= Etn.execute("SELECT bt1.* FROM page_templates_tbl bt1 JOIN page_templates_tbl bt2 ON bt1.site_id=bt2.site_id"+
                        " AND bt1.custom_id=bt2.custom_id AND bt1.id!=bt2.id where bt1.id="+escape.cote(templateId));

                    if(rsCheckTrash.rs.Rows==0){
                        Etn.executeCmd("UPDATE page_templates_tbl SET is_deleted='1',updated_ts=NOW(),updated_by="+escape.cote(logedInUserId)+
                            " WHERE id = "+escape.cote(templateId));

                        deletedTemplateIds += templateId +",";
                        deletedTemplateNames += parseNull(rs.value("name"))+", ";
                        deleteCount += 1;
                    }
                }

                if(totalCount == 1){
                    if(deleteCount != 1){
                        throw new SimpleException("Cannot delete: Templates who have identical in trash and in use are not deleted.");
                    }
                    else{
                        status = STATUS_SUCCESS;
                        message = "Template deleted";
                    }
                }
                else{
                    status = STATUS_SUCCESS;
                    message = deleteCount + " of " + totalCount + " templates deleted";
                    if(deleteCount < totalCount){
                        message += ". Templates who have identical in trash and in use are not deleted.";
                    }
                }
                if(status == STATUS_SUCCESS)
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),deletedTemplateIds,"DELETED","Page Templates",deletedTemplateNames,siteId);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting templates.",ex);
            }
        }
	    else if("saveTemplate".equalsIgnoreCase(requestType) || "copyTemplate".equalsIgnoreCase(requestType)){
	    	try{

		   	 	int templateId = parseInt(request.getParameter("id"), 0);

                String name = parseNull(request.getParameter("name"));
		   	 	String custom_id = parseNull(request.getParameter("custom_id"));
		   	 	String description = parseNull(request.getParameter("description"));

		   	 	int copyId = parseInt(request.getParameter("copyId"), 0);
		   	 	boolean isCopyTemplate = "copyTemplate".equalsIgnoreCase(requestType);

                String errorMsg = "";
                int themeVersion = 0;
                int themeId = 0;
                // check if this template is part of locked theme or not
                if(templateId > 0){
                    q = "SELECT pt.theme_id, pt.theme_version, th.status as theme_status FROM page_templates_tbl pt "
                        + " LEFT JOIN themes th ON th.id = pt.theme_id"
                        + " WHERE pt.id = " + escape.cote(templateId+"")
                        + " and pt.is_deleted='0' AND pt.site_id = " + escape.cote(siteId);

                    rs =  Etn.execute(q);
                    if(rs.next()){
                        if(!isSuperAdmin(Etn) && rs.value("theme_status").equals(Constant.THEME_LOCKED)){
                             throw new SimpleException("You are not authorized.");
                        }
                        themeId = parseInt(rs.value("theme_id"));
                        themeVersion = parseInt(rs.value("theme_version"));
                    } else{
                         throw new SimpleException("Invalid template Id.");
                    }
                }

                if(name.length() == 0){
                    errorMsg += "Name cannot be empty";
                }
                if(custom_id.length() == 0){
                    errorMsg += "Template ID cannot be empty";
                }
                if(errorMsg.length() == 0){
                    //check duplicate path+variant
                    q = "SELECT id FROM page_templates_tbl "
                        + " WHERE custom_id = " + escape.cote(custom_id)
                        + " and is_deleted='0' AND site_id = " + escape.cote(siteId);
                    if(templateId > 0){
                        q += " AND id != " + escape.cote(""+templateId);
                    }

                    rs = Etn.execute(q);
                    if(rs.next()){
                        errorMsg = "Template ID already exist. please specify different ID.";
                    }
                }
                if(isCopyTemplate){

                	//means its a copy request
                	if(templateId > 0){
                		//something very wrong
                		throw new SimpleException("Invalid parameters for copying template.");
                	}

                	q = "SELECT id FROM page_templates_tbl "
                        + " WHERE id = " + escape.cote(""+copyId)
                        + " and is_deleted='0' AND site_id = " + escape.cote(siteId);

                    rs = Etn.execute(q);
                    if(!rs.next()){
                        errorMsg = "Invalid Copy Template ID.";
                    }
                }

                if(errorMsg.length() > 0){
                    message = errorMsg;
                }
                else{

                    int pid = Etn.getId();

                    colValueHM.put("name", escape.cote(name));
                    colValueHM.put("custom_id", escape.cote(custom_id));
                    colValueHM.put("description", escape.cote(description));

                    colValueHM.put("updated_ts", "NOW()");
                    colValueHM.put("updated_by", escape.cote(""+pid));

                    if(templateId <= 0){
                        //new template
                        colValueHM.put("template_code", escapeCote(getDefaultPageTemplateCode()));
                        colValueHM.put("created_ts", "NOW()");
                        colValueHM.put("created_by", escape.cote(""+pid));
                        colValueHM.put("site_id", escape.cote(siteId));
                        colValueHM.put("uuid", "UUID()");

                        q = getInsertQuery("page_templates_tbl",colValueHM);

                        templateId = Etn.executeCmd(q);

                        if(templateId <= 0){
                            message = "Error in creating page template. Please try again.";
                        }
                        else{

                        	if(isCopyTemplate){
                        		//copy
                        		try{

                        			String newTemplateId = "" + templateId;
                        			q = " SELECT description, template_code "
                        				+ " FROM page_templates_tbl WHERE is_deleted='0' and id = " + escape.cote(""+copyId);
                        			rs = Etn.execute(q);
                        			rs.next();
                        			q = " UPDATE page_templates_tbl "
                        				+ " SET description = " + escape.cote(rs.value("description"))
                        				+ " , template_code = " + escape.cote(rs.value("template_code"))
                        				+ " WHERE is_deleted='0' and id = " + escape.cote(newTemplateId);
                        			Etn.executeCmd(q);

                        			q = " SELECT * FROM page_templates_items "
                        			 	+ " WHERE page_template_id = " + escape.cote(""+copyId);
                        			rs = Etn.execute(q);
                        			while(rs.next()){

                        				String curItemId = rs.value("id");

                        				colValueHM.clear();
                        				colValueHM.put("page_template_id", newTemplateId);
                        				colValueHM.put("name", escape.cote(rs.value("name")));
                        				colValueHM.put("custom_id", escape.cote(rs.value("custom_id")));
                        				colValueHM.put("sort_order", escape.cote(rs.value("sort_order")));
                        				colValueHM.put("created_by", escape.cote(""+pid));
                        				colValueHM.put("updated_by", escape.cote(""+pid));
                        				colValueHM.put("created_ts", "NOW()");
                        				colValueHM.put("updated_ts", "NOW()");
                        				q = getInsertQuery("page_templates_items", colValueHM);
                        				int newItemId = Etn.executeCmd(q);

                        				if(newItemId <= 0){
                        					throw new Exception("Error in copying region id: "+ curItemId);
                        				}

                        				q = "INSERT INTO page_templates_items_details(item_id, langue_id, css_classes, css_style)  "
                        					+ " SELECT "+escape.cote(""+newItemId)+" AS item_id, langue_id, css_classes, css_style "
                        					+ " FROM page_templates_items_details "
                        					+ " WHERE item_id = " + escape.cote(curItemId);
                        				Etn.executeCmd(q);

                        				q = "INSERT INTO page_templates_items_blocs(item_id, langue_id, bloc_id, type, sort_order)  "
                        					+ " SELECT "+escape.cote(""+newItemId)+" AS item_id, langue_id, bloc_id, type, sort_order "
                        					+ " FROM page_templates_items_blocs "
                        					+ " WHERE item_id = " + escape.cote(curItemId);
                        				Etn.executeCmd(q);
                        			}

                        		}
                        		catch(Exception copyEx){
                        			copyEx.printStackTrace();
                        			//delete the new template
                        			q = "DELETE pt, items, details, bl "
										+ " FROM page_templates_tbl pt "
										+ " LEFT JOIN page_templates_items items ON pt.id = items.page_template_id "
										+ " LEFT JOIN page_templates_items_details details ON details.item_id = items.id "
										+ " LEFT JOIN page_templates_items_blocs bl ON bl.item_id = items.id "
										+ " WHERE pt.is_deleted='0' and pt.id = " + escape.cote(""+templateId);
								    Etn.executeCmd(q);
                        			throw new SimpleException("Error in copying template regions");
                        		}

                        	}

                        	String regionId = PagesUtil.createOrGetContentRegionId(""+templateId, Etn, Etn.getId());

                            status = STATUS_SUCCESS;
                            message = "Page template created.";
                            data.put("id", templateId);
                            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),templateId+"","CREATED","Page Template",name,siteId);

                        }
                    }
                    else{
                        //existing template update
                        // udpate the theme version if it is part of a theme
                        if(themeId>0){
                            themeVersion = themeVersion + 1;
                            colValueHM.put("theme_version",escape.cote(themeVersion+""));
                        }

                    	q = "SELECT is_system FROM page_templates WHERE id = " + escape.cote(""+templateId);
                    	rs = Etn.execute(q);
                    	rs.next();
                    	if(!"0".equals(rs.value("is_system"))){
                    		colValueHM.remove("name");
                    		colValueHM.remove("custom_id");
                    	}

                        q = getUpdateQuery("page_templates", colValueHM,
                        	" WHERE id = " + escape.cote(""+ templateId) + " AND site_id = " + escape.cote(siteId) );
                        count = Etn.executeCmd(q);

                        if(count <= 0){
                            message = "Error in updating page template. Please try again.";
                        }
                        else{

                            markPagesToGenerate(""+templateId, "page_templates",Etn);

                            status = STATUS_SUCCESS;
                            message = "Page template updated.";
                            data.put("id", templateId);
                            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),templateId+"","UPDATED","Page Template",name,siteId);
                        }
                    }

                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving page template. Please try again.",ex);
            }
	    }
        else if("saveTemplateData".equalsIgnoreCase(requestType)){
            try{

                String templateId = parseNull(request.getParameter("id"));

                JSONObject dataJson = new JSONObject(request.getParameter("data"));

                String templateCode = dataJson.getString("template_code");
                JSONArray regionsList = dataJson.getJSONArray("regions");

                q = "SELECT pt.name, th.status as themeStatus, pt.theme_id, pt.theme_version FROM page_templates_tbl pt "
                    + " LEFT JOIN themes th ON th.id = pt.theme_id "
                    + " WHERE pt.id = " + escape.cote(templateId)
                    + " and pt.is_deleted='0' AND pt.site_id  = " + escape.cote(siteId);
                rs = Etn.execute(q);

                if(!rs.next()){
                    throw new SimpleException("Invalid params");
                }

                if(rs.value("themeStatus").equals(Constant.THEME_LOCKED) && !isSuperAdmin(Etn)){
                    throw new SimpleException("You are not authorized");
                }
                int themeVersion = parseInt(rs.value("theme_version"));
                int themeId = parseInt(rs.value("theme_id"));

                String templateName = rs.value("name");

                int pid = Etn.getId();
                ArrayList<String> regionIdsList = new ArrayList<>();

                String contentRegionId = PagesUtil.createOrGetContentRegionId(""+templateId, Etn, Etn.getId());
                regionIdsList.add(escape.cote(contentRegionId));

                for (int i=0; i<regionsList.length(); i++ ) {
                	JSONObject region = regionsList.getJSONObject(i);

                	int regionId = parseInt(region.getString("id"));

                	if( contentRegionId.equals(""+regionId) || "content".equals(region.getString("custom_id")) ){
						//skip default content region, only set its sort_order
						q = "UPDATE page_templates_items SET sort_order = " + escape.cote(""+i)
							+ " WHERE id = " + escape.cote(""+regionId);
						Etn.executeCmd(q);
						continue;
					}

                	colValueHM.clear();
                	colValueHM.put("name", escape.cote(region.getString("name")));
                	colValueHM.put("custom_id", escape.cote(region.getString("custom_id")));
                	colValueHM.put("sort_order", escape.cote(""+i));
                	colValueHM.put("updated_ts", "NOW()");
                	colValueHM.put("updated_by", escape.cote(""+pid));

                	if(regionId <= 0){

                		colValueHM.put("page_template_id", escape.cote(templateId));
                		colValueHM.put("created_ts", "NOW()");
                		colValueHM.put("created_by", escape.cote(""+pid));

                		q = getInsertQuery("page_templates_items", colValueHM);
                		int newId = Etn.executeCmd(q);
                		regionId = newId;
                	}
                	else{

                		q = getUpdateQuery("page_templates_items", colValueHM, " WHERE id = " + escape.cote(""+regionId));
                        Etn.executeCmd(q);
                	}

                	regionIdsList.add(escape.cote(""+regionId));

                    //region_details
                    JSONArray regionDetails = region.optJSONArray("details");
                    if(regionDetails == null) regionDetails = new JSONArray();

                    List<Language> langsList = getLangs(Etn,getSiteId(session));


                    for(Language curLang : langsList){
                        String langId = ""+curLang.getLanguageId();

                        String css_classes = "";
                        String css_style = "";

                        JSONObject detailObj = null;
                        for ( int j=0; j<regionDetails.length(); j++ ) {
                        	JSONObject curObj = regionDetails.optJSONObject(j);
                        	if(curObj != null && langId.equals(curObj.optString("langue_id"))){
                        		detailObj = curObj;
                        		break;
                        	}
                        }

                        JSONArray blocsList = null;
                        if(detailObj != null){
                        	css_classes = detailObj.optString("css_classes", "");
                        	css_style = detailObj.optString("css_style", "");
                        	blocsList = detailObj.optJSONArray("blocs");
                        }

                        colValueHM.clear();
                        colValueHM.put("item_id", escape.cote(""+regionId));
                        colValueHM.put("langue_id", escape.cote(langId));
                        colValueHM.put("css_classes", escape.cote(css_classes));
                        colValueHM.put("css_style", escape.cote(css_style));
                        q = getInsertQuery("page_templates_items_details",colValueHM);
                        q += " ON DUPLICATE KEY UPDATE css_classes=VALUES(css_classes), css_style=VALUES(css_style)";
                        Etn.executeCmd(q);

						q = "DELETE FROM page_templates_items_blocs WHERE item_id = "+escape.cote(""+regionId)
							+ " AND langue_id = " + escape.cote(langId);
						Etn.executeCmd(q);

						String qPrefix = "INSERT INTO page_templates_items_blocs (item_id, langue_id, bloc_id, type, sort_order) VALUES ("
							+ escape.cote(""+regionId) + "," + escape.cote(langId) + ",";
						if(blocsList != null){
							for(int j=0; j< blocsList.length(); j++){
								JSONObject blocObj = blocsList.getJSONObject(j);
								q = qPrefix + escape.cote(blocObj.getString("id"))
									+ "," + escape.cote("bloc")
									+ "," + escape.cote(""+j) + " )";
								Etn.executeCmd(q);
							}
						}
                    }//for langList


                }//for regionsList

                //cleanup deleted regions
                q = "DELETE d FROM page_templates_items_details d "
                	+ " JOIN page_templates_items i ON i.id = d.item_id "
                	+ " WHERE i.page_template_id = " + escape.cote(""+templateId);
                if(regionIdsList.size() > 0){
                    q += " AND i.id NOT IN ( " + String.join(",",regionIdsList) + ")";
                }
                Etn.executeCmd(q);

                q = "DELETE b FROM page_templates_items_blocs b "
                	+ " JOIN page_templates_items i ON i.id = b.item_id "
                	+ " WHERE i.page_template_id = " + escape.cote(""+templateId);
                if(regionIdsList.size() > 0){
                    q += " AND i.id NOT IN ( " + String.join(",",regionIdsList) + ")";
                }
                Etn.executeCmd(q);

                q = "DELETE FROM page_templates_items WHERE page_template_id = " + escape.cote(""+templateId);
                if(regionIdsList.size() > 0){
                    q += " AND id NOT IN ( " + String.join(",",regionIdsList) + ")";
                }
                Etn.executeCmd(q);

                // Save template code (JSON) at the end , using special escaping
                colValueHM.clear();
                colValueHM.put("template_code",escapeCote(templateCode));
               	if(themeId>0){
               	    themeVersion  = themeVersion + 1;
                    colValueHM.put("theme_version",escapeCote(themeVersion+"")); // update theme version
               	}
                q = getUpdateQuery("page_templates_tbl", colValueHM," WHERE is_deleted='0' and id = " + escape.cote(templateId));
                q = "UPDATE page_templates SET  = " +
               	Etn.executeCmd(q);

               	markPagesToGenerate(""+templateId, "page_templates_tbl",Etn);

               	status = STATUS_SUCCESS;

                ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),""+templateId,"UPDATED","Page Template",templateName,siteId);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving page template data. Please try again.",ex);
            }
        }
        else if("getUses".equalsIgnoreCase(requestType)){
            try{
                String templateId = parseNull(request.getParameter("templateId"));

                JSONArray  resultList = new JSONArray();
                JSONObject curEntry = null;

                q = " SELECT DISTINCT id, name, path , variant, langue_code, site_id, published_ts"
                    + " FROM pages p "
                    + " WHERE template_id = " + escape.cote(templateId)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                while(rs.next()){
                    curEntry = new JSONObject();

                    String path = rs.value("path");
                    String variant = rs.value("variant");
                    String langue_code = rs.value("langue_code");
                    String pageHtmlPath =  "/" + langue_code + "/" + variant + "/" + path;

                    curEntry.put("id", rs.value("id"));
                    curEntry.put("name", rs.value("name"));
                    curEntry.put("path", pageHtmlPath);
                    curEntry.put("is_published", rs.value("published_ts").length() > 0 ? "1":"0");

                    resultList.put(curEntry);
                }

                data.put("pages", resultList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in template uses. Please try again.",ex);
            }
        }
        else if("createDefaultTemplate".equalsIgnoreCase(requestType)){
            try{
                String templateId = createDefaultTemplate(siteId, Etn);

				if(templateId.length() > 0 ){
                	status = STATUS_SUCCESS;
                	data.put("template_id", templateId);
				}

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in creating default template. Please try again.",ex);
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
