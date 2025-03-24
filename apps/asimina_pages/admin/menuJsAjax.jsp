<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap, java.util.Map, com.etn.asimina.util.ActivityLog, com.etn.beans.Etn"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%!
    protected int unpublishMenuJs(String[] menuJsIds, Contexte Etn, String siteId, StringBuilder logIds, StringBuilder logNames) {

        String q;
        Set rs;
        int pubCount = 0;
        for(String menuJsId : menuJsIds){
            if(parseInt(menuJsId,0) <= 0){
                continue;
            }

            q = "SELECT name FROM menu_js "
                + " WHERE id = " + escape.cote(menuJsId)
                + " AND site_id = " + escape.cote(siteId);
            rs = Etn.execute(q);
            if(!rs.next()) {
                continue;
            }
            String menuName = rs.value("name");

            q = "UPDATE menu_js mj "
                + " SET mj.publish_status = 'unpublished', mj.published_ts = NOW(), mj.publish_log = '' "
                + " , mj.published_by = " + escape.cote(""+Etn.getId())
                + " WHERE mj.id = " + escape.cote(menuJsId)
                + " AND mj.site_id = " + escape.cote(siteId);
            Etn.executeCmd(q);


            logIds.append(menuJsId).append(",");
            logNames.append(parseNull(menuName)).append(",");

            pubCount++;
        }

        return pubCount;
    }

    protected int publishMenuJs(String[] menuJsIds, Contexte Etn, String siteId, StringBuilder logIds, StringBuilder logNames, String lang) throws Exception{

        String errorLog = "";
        String q;
        Set rs;
        int pubCount = 0;
        for(String menuJsId : menuJsIds){
            if(parseInt(menuJsId,0) <= 0){
                continue;
            }
            try{


                q = "SELECT mjd.*, mj.name AS name , l.langue_code"
                + " FROM menu_js mj"
                + " JOIN menu_js_details mjd ON mj.id = mjd.menu_js_id"
                + " JOIN language l ON l.langue_id = mjd.langue_id "
                + " WHERE mj.id = " + escape.cote(menuJsId)
                + " AND mj.site_id = " + escape.cote(siteId);
				if(parseNull(lang).length() > 0)
				{
					q += " and l.langue_code = "+escape.cote(lang);
				}
				System.out.println("Publishing menu js : " + q);
                rs = Etn.execute(q);

                if(rs.rs.Rows <= 0) continue;

                String menuName = "";
                HashMap<String, JSONObject> langJsonHM = new HashMap<>(rs.rs.Rows);
                //collect json for all langs if there error even in one we do not push any of the json and set error log
                while(rs.next()) {
                    menuName = rs.value("name");
                    try{
                        JSONObject menuJsJson = getMenuJsJson(rs, Etn, true);
                        langJsonHM.put(rs.value("langue_id"), menuJsJson);
                    }
                    catch (Exception ex) {
                        errorLog += "\nException in Publish Menu= " + menuName
                        + ", lang = " + rs.value("langue_code")
                        + ", error => " + ex.getMessage();
                        throw ex;
                    }
                }

                for(String langId : langJsonHM.keySet()) {
                    q = "UPDATE menu_js_details "
                    + " SET published_json = " + escapeCote(langJsonHM.get(langId).toString())
                    + " WHERE menu_js_id = " + escape.cote(menuJsId)
                    + " AND langue_id = " + escape.cote(langId);
                    Etn.executeCmd(q);
                }

                q = "UPDATE menu_js mj "
                    + " SET mj.publish_status = 'published' , mj.published_ts = NOW(), mj.publish_log = '' "
                    + " , mj.published_by = " + escape.cote(""+Etn.getId())
                    + " WHERE mj.id = " + escape.cote(menuJsId)
                    + " AND mj.site_id = " + escape.cote(siteId);
                Etn.executeCmd(q);

                logIds.append(menuJsId).append(",");
                logNames.append(parseNull(menuName)).append(",");

                pubCount++;
            }
            catch(Exception ex){
                Logger.debug("Error in publishing menu js = " + menuJsId);
                ex.printStackTrace();
            }
        }
        if(errorLog.length() > 0){
            throw new Exception(errorLog);
        }
        return pubCount;
    }

    protected JSONObject getMenuJsJson(Set rs, Contexte Etn, boolean isForPublish) throws Exception{
        JSONObject retObj = new JSONObject();

        String langId = rs.value("langue_id");
        String headerBlocId = rs.value("header_bloc_id");
        String headerBlocType = rs.value("header_bloc_type");
        String footerBlocId = rs.value("footer_bloc_id");
        String footerBlocType = rs.value("footer_bloc_type");

        PagesGenerator pagesGen = new PagesGenerator(Etn);
        JSONObject headerJson = getBlocJson(headerBlocId, headerBlocType, langId, pagesGen, isForPublish);
        JSONObject footerJson = getBlocJson(footerBlocId, footerBlocType, langId, pagesGen, isForPublish);

        String bodyCss = "";
        String bodyJs = "";
        String headerHtml = "";
        String footerHtml = "";

        LinkedHashSet<String> headCssFilesSet = new LinkedHashSet<>();
        LinkedHashSet<String> cssFilesSet = new LinkedHashSet<>();
        LinkedHashSet<String> jsFilesSet = new LinkedHashSet<>();
		LinkedHashSet<String> headJsFilesSet = new LinkedHashSet<>();
        // all these has to be in sequence
        // header.head -> footer.head -> header.body -> footer.body
        // adding to linked hash set so as to keep in sequence and also not to repeat a file

        appendEntries(headerJson, "head", headCssFilesSet, headJsFilesSet);
        appendEntries(footerJson, "head", headCssFilesSet, headJsFilesSet);
        appendEntries(headerJson, "body", cssFilesSet, jsFilesSet);
        appendEntries(footerJson, "body", cssFilesSet, jsFilesSet);

        if(headerJson != null){
            bodyCss += headerJson.getString("bodyCss") + "\n";
            bodyJs += headerJson.getString("bodyJs") + "\n";
            headerHtml += headerJson.getString("blocHtml");
        }

        if(footerJson != null){
            bodyCss += footerJson.getString("bodyCss") + "\n";
            bodyJs += footerJson.getString("bodyJs") + "\n";
            footerHtml += footerJson.getString("blocHtml");
        }

        retObj.put("headCssFiles", new JSONArray(headCssFilesSet));
        retObj.put("cssFiles", new JSONArray(cssFilesSet));
        retObj.put("jsFiles", new JSONArray(jsFilesSet));
        retObj.put("headJsFiles", new JSONArray(headJsFilesSet));
        retObj.put("bodyCss", bodyCss);
        retObj.put("bodyJs", bodyJs);
        retObj.put("header", headerHtml);
        retObj.put("footer", footerHtml);

        // debug
        // Logger.debug("header_json = "+ headerJson.toString());
        // Logger.debug("footer_json = "+ footerJson.toString());

        return retObj;
    }

    protected JSONObject getBlocJson(String blocId, String blocType, String langId, PagesGenerator pagesGen, boolean isForPublish) throws Exception{
        if(parseInt(blocId) > 0){
            if(Constant.SYSTEM_TEMPLATE_MENU.equals(blocType)){
                return null;// menu type is obsolete, should not be in data
            }
            else{
                return pagesGen.getBlocHtmlByLang(blocId, langId, isForPublish);
            }
        }

        return null;
    }

    protected void addAllStringEntries(LinkedHashSet<String> targetSet, JSONArray list){
        for(Object o : list){
            if(o instanceof String){
                targetSet.add((String)o);
            }
        }
    }

     protected void appendEntries(JSONObject srcJson, String type,
        LinkedHashSet<String> cssFilesSet, LinkedHashSet<String> jsFilesSet){

        if(srcJson != null){
            addAllStringEntries(cssFilesSet, srcJson.getJSONArray(type + "CssFiles"));
            addAllStringEntries(jsFilesSet, srcJson.getJSONArray(type + "JsFiles"));
        }
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

    try{
        String siteId = getSiteId(session);
        if("getList".equalsIgnoreCase(requestType)){
            try{

                JSONArray retList = new JSONArray();

                q = " SELECT mj.*, l.name updatedby, case when publish_status = 'published' and published_ts < updated_ts then 'changed' else publish_status end as row_status "
                    + " FROM menu_js mj"
                    + " LEFT JOIN login l ON l.pid = mj.updated_by "
                    + " WHERE mj.site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                while(rs.next()){
                    JSONObject curObj = getJSONObject(rs);
                    retList.put(curObj);
                }

                data.put("menuJs",retList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting menu JS list. Please try again.",ex);
            }
        }
        else if("getInfo".equalsIgnoreCase(requestType)){
             try{
                String menuJsId = parseNull(request.getParameter("id"));

                q = "SELECT mj.* "
                    + " FROM menu_js mj "
                    + " WHERE id = " + escape.cote(menuJsId)
                    + " AND site_id = " + escape.cote(siteId);

                rs = Etn.execute(q);
                if(!rs.next()){
                    throw new SimpleException("Invalid parameters");
                }
                JSONObject retObj = getJSONObject(rs);

                JSONArray detailsList = new JSONArray();
                retObj.put("details", detailsList);
                q = "SELECT  mjd.* "
                    + " ,COALESCE(h1.name,'') AS header_bloc_name, COALESCE(f1.name,'') AS footer_bloc_name "
                    + " FROM menu_js_details mjd "
                    + " LEFT JOIN blocs h1 ON h1.id = mjd.header_bloc_id AND mjd.header_bloc_type = 'bloc' AND h1.site_id =" + escape.cote(siteId)
                    + " LEFT JOIN blocs f1 ON f1.id = mjd.footer_bloc_id AND mjd.footer_bloc_type = 'bloc' AND f1.site_id =" + escape.cote(siteId)
                    + " WHERE menu_js_id = " + escape.cote(menuJsId);

                rs = Etn.execute(q);
                while(rs.next()){
                    detailsList.put(getJSONObject(rs));
                }

                data.put("menu_js", retObj);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting template info. Please try again.",ex);
            }
        }
        else if("saveMenuJs".equalsIgnoreCase(requestType)){
            try{
                int menuJsId = parseInt(request.getParameter("id"), 0);

                String name = parseNull(request.getParameter("name"));
                String description = parseNull(request.getParameter("description"));
                JSONArray detailsList = new JSONArray(request.getParameter("details"));

                String errorMsg = "";
                if(name.length() == 0){
                    errorMsg += "Name cannot be empty";
                }
                else {
                    q = "SELECT id FROM menu_js  "
                        + " WHERE name = " + escape.cote(name)
                        + " AND site_id = " + escape.cote(siteId);
                    if(menuJsId > 0){
                        q += " AND id != " + escape.cote(""+menuJsId);
                    }

                    rs = Etn.execute(q);
                    if(rs.next()){
                        errorMsg = "Name already exist. please specify different name.";
                    }
                }

                if(errorMsg.length() > 0){
                    throw new SimpleException(errorMsg);
                }

                String pid = ""+Etn.getId();
                colValueHM.clear();
                colValueHM.put("name", escape.cote(name));
                colValueHM.put("description", escape.cote(description));
                colValueHM.put("updated_by", escape.cote(pid));
                colValueHM.put("updated_ts", "NOW()");

                if(menuJsId <= 0){
                    //new
                    colValueHM.put("site_id", escape.cote(siteId));
                    colValueHM.put("uuid", "UUID()");
                    colValueHM.put("created_by", escape.cote(pid));
                    colValueHM.put("created_ts", "NOW()");
                    q = getInsertQuery("menu_js", colValueHM);
                    int newId = Etn.executeCmd(q);
                    if(newId <= 0){
                        throw new SimpleException("Error in creating menu js record. Please try again.");
                    }
                    menuJsId = newId;
                }
                else{
                    //update
                    q = getUpdateQuery("menu_js", colValueHM, " WHERE id = " + escape.cote(""+menuJsId));
                    Etn.executeCmd(q);
                }

                //process details
                if(menuJsId > 0){
                    List<Language> langList = getLangs(Etn,siteId);
                    for(Language curLang : langList){
                        String curLangId = curLang.getLanguageId();

                        String header_bloc_id = "0";
                        String header_bloc_type = "bloc";
                        String footer_bloc_id = "0";
                        String footer_bloc_type = "bloc";
                        for(int i = 0; i < detailsList.length(); i++) {
                            JSONObject detailObj = detailsList.getJSONObject(i);
                            if(curLangId.equals(detailObj.optString("langue_id"))){
                                header_bloc_id = detailObj.optString("header_bloc_id", "0");

                                footer_bloc_id = detailObj.optString("footer_bloc_id", "0");
                                break;
                            }
                        }
                        colValueHM.clear();
                        colValueHM.put("menu_js_id", escape.cote(""+menuJsId));
                        colValueHM.put("langue_id", escape.cote(curLangId));
                        colValueHM.put("header_bloc_id", escape.cote(header_bloc_id));
                        colValueHM.put("header_bloc_type", escape.cote(header_bloc_type));
                        colValueHM.put("footer_bloc_id", escape.cote(footer_bloc_id));
                        colValueHM.put("footer_bloc_type", escape.cote(footer_bloc_type));
                        q = getInsertQuery("menu_js_details", colValueHM).replace("INSERT INTO", "REPLACE INTO");
                        Etn.executeCmd(q);
                    }
                }

                status = STATUS_SUCCESS;
                data.put("id",menuJsId);

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting saving menu js. Please try again.",ex);
            }
        }
        else if("copyMenuJs".equalsIgnoreCase(requestType)){
            try{
                String copyId = parseNull(request.getParameter("copyId"));
                String name = parseNull(request.getParameter("name"));
                String description = parseNull(request.getParameter("description"));

                String errorMsg = "";
                if(name.length() == 0){
                    errorMsg += "Name cannot be empty";
                }
                else {
                    q = "SELECT id FROM menu_js  "
                        + " WHERE name = " + escape.cote(name)
                        + " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);
                    if(rs.next()){
                        errorMsg = "Name already exist. please specify different name.";
                    }
                }

                q = "SELECT * FROM menu_js  "
                    + " WHERE id = " + escape.cote(copyId)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                if (!rs.next()) {
                    throw new SimpleException("Invalid parameters.");
                }

                if(errorMsg.length() > 0){
                    throw new SimpleException(errorMsg);
                }

                for (String colName : rs.ColName) {
                    colValueHM.put(colName.toLowerCase(), escape.cote(rs.value(colName)));
                }

                String pid = "" + Etn.getId();
                colValueHM.remove("id");
                colValueHM.put("uuid", "UUID()");
                colValueHM.put("name", escape.cote(name));
                colValueHM.put("description", escape.cote(description));
                colValueHM.put("updated_by", escape.cote(pid));
                colValueHM.put("updated_ts", "NOW()");
                colValueHM.put("created_by", escape.cote(pid));
                colValueHM.put("created_ts", "NOW()");

                q = getInsertQuery("menu_js", colValueHM);
                int newMenuJsId = Etn.executeCmd(q);
                if(newMenuJsId <= 0){
                    throw new SimpleException("Error in copying menu js record. Please try again.");
                }

                //copy details
                q = "INSERT INTO menu_js_details(menu_js_id, langue_id, header_bloc_id, header_bloc_type, footer_bloc_id, footer_bloc_type, published_json)  "
                + " SELECT " + escape.cote(""+newMenuJsId) + " AS menu_js_id, langue_id, header_bloc_id, header_bloc_type, footer_bloc_id, footer_bloc_type, published_json "
                + " FROM menu_js_details "
                + " WHERE menu_js_id = " + escape.cote(copyId);
                Etn.executeCmd(q);

                status = STATUS_SUCCESS;
                message = "Menu JS copied.";
                data.put("id",newMenuJsId);

            }
            catch(Exception ex){
                throw new SimpleException("Error in copying menu js.",ex);
            }
        }
        else if("deleteMenuJs".equalsIgnoreCase(requestType)){
            try{
                String[] menuJsIds= request.getParameterValues("ids");

                int totalCount = menuJsIds.length;
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                int deleteCount = 0;
                String deletedIds = "";
                String deletedNames = "";
                for(String menuJsId : menuJsIds){
                    if(parseInt(menuJsId,0) <= 1){
                        continue;
                    }

                    q = "SELECT name FROM menu_js "
                        + " WHERE id = " + escape.cote(menuJsId)
                        + " AND site_id = " + escape.cote(siteId);
                    rs = Etn.execute(q);
                    if(!rs.next()) {
                        continue;
                    }
                    String menuName = rs.value("name");

                    q = "DELETE mj, details "
                        + " FROM menu_js mj "
                        + " LEFT JOIN menu_js_details details ON mj.id = details.menu_js_id "
                        + " WHERE mj.id = " + escape.cote(menuJsId)
                        + " AND mj.site_id = " + escape.cote(siteId);
                    Etn.executeCmd(q);

                    deletedIds += menuJsId + ",";
                    deletedNames += parseNull(menuName) + ", ";

                    deleteCount += 1;
                }

                if(deleteCount == totalCount){
                    message = deleteCount + " of " + totalCount + " entries deleted";
                    status = STATUS_SUCCESS;
                    ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")), deletedIds, "DELETED", "Menu JS", deletedNames, siteId);
                }
                else{
                    message = "Error in deleting menu js";
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting menu js.",ex);
            }
        }
        else if("regenerateMenuJsKey".equalsIgnoreCase(requestType)){
            try{
                String id = parseNull(request.getParameter("id"));


                q = "UPDATE menu_js SET uuid = UUID() WHERE id = " + escape.cote(id)
                     + " AND site_id = " + escape.cote(siteId);
                int updateCount = Etn.executeCmd(q);
                if(updateCount > 0){
                    status = STATUS_SUCCESS;
                    message = "New key generated";
                }
                else{
                    throw new SimpleException("Invalid parameters");
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting menu js.",ex);
            }
        }
        else if("publishUnpublish".equalsIgnoreCase(requestType)){
            try{
                String action= parseNull(request.getParameter("action"));
                String[] menuJsIds= request.getParameterValues("ids");

                int totalCount = menuJsIds.length;
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                int pubCount = 0;
                StringBuilder logIds = new StringBuilder();
                StringBuilder logNames = new StringBuilder();
                if ("publish".equals(action)) {
                    try{
                        pubCount = publishMenuJs(menuJsIds, Etn, siteId, logIds, logNames, "");
                    }
                    catch(Exception ex){
                        throw new SimpleException("Error in publishing menu js : \n" + ex.getMessage());
                    }
                }
                else if ("unpublish".equals(action)) {
                    pubCount = unpublishMenuJs(menuJsIds, Etn, siteId, logIds, logNames);
                }

                if(logIds.length() > 0){
                    ActivityLog.addLog(Etn, request, parseNull(session.getAttribute("LOGIN")),
                        logIds.toString(), action.toUpperCase()+"ED", "Menu JS", logNames.toString(), siteId);
                }

                if(pubCount == totalCount){
                    message = pubCount + " of " + totalCount + " entries " + action + "ed.";
                    status = STATUS_SUCCESS;
                }
                else{
                    message = "Error in " + action + "ing menu js";
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in publish/unpublish menu js.",ex);
            }
        }
		//this request type is called from crawler so we pass the site id in it
        else if("clearcache".equalsIgnoreCase(requestType)){
            try{
                String[] menuJsIds= request.getParameterValues("ids");
                String lang = parseNull(request.getParameter("lang"));
                String pSiteid = parseNull(request.getParameter("siteid"));

                int totalCount = menuJsIds.length;
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                int pubCount = 0;
                StringBuilder logIds = new StringBuilder();
                StringBuilder logNames = new StringBuilder();
				try{
					pubCount = publishMenuJs(menuJsIds, Etn, pSiteid, logIds, logNames, lang);
				}
				catch(Exception ex){
					throw new SimpleException("Error in publishing menu js : \n" + ex.getMessage());
				}

                if(pubCount == totalCount){
                    message = pubCount + " of " + totalCount + " entries " + requestType + "ed.";
                    status = STATUS_SUCCESS;
                }
                else{
                    message = "Error in " + requestType + "ing menu js";
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in clearcache menu js.",ex);
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
