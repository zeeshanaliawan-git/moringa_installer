<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, com.etn.pages.PagesUtil, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap,  java.util.ArrayList"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="pagesUtil.jsp"%>
<%!
    String trimApplyToUrl(String applyToUrl){
        String url = applyToUrl;
        if(url.toLowerCase().startsWith("https://"))
            url = url.substring(8);
        else if(url.toLowerCase().startsWith("http://"))
            url = url.substring(7);

        url = url.trim();
        if(url.endsWith("/"))
            url = url.substring(0, url.lastIndexOf("/"));

        return url;
    }

    String getSiteDomain(com.etn.beans.Contexte Etn, String siteId){
        Set rs = Etn.execute("SELECT domain FROM "+GlobalParm.getParm("PORTAL_DB")+".sites WHERE id = " + escape.cote(siteId));
        rs.next();
        String domain = parseNull(rs.value("domain")).toLowerCase();
        domain = domain.replace("https://","").replace("http://","");
        if(domain.indexOf("/") > -1) domain = domain.substring(0, domain.indexOf("/"));

        return domain;
    }

    @Deprecated
    String verifyMenuPath(com.etn.beans.Contexte Etn, String menuId, String menuPath, String siteId){

        String currentSiteDomain = getSiteDomain(Etn, siteId);

        if(menuPath.length() == 0)
        {
            return "Menu path cannot empty";
        }

        if(menuPath.startsWith("/")) menuPath = menuPath.substring(1);
        if(!menuPath.endsWith("/")) menuPath = menuPath + "/";

        if(menuPath.equals("/"))
        {
            return "Menu path cannot be /\"";
        }

        String PORTAL_DB = GlobalParm.getParm("PORTAL_DB");

        String qry = "select m.*, s.name as sitename from menus m, "+PORTAL_DB+".sites s "
            + " where s.id = m.site_id and coalesce(m.production_path, '') <> '' and m.production_path = " + escape.cote(menuPath);
        if(menuId.length() > 0) qry += " and m.id <> " + escape.cote(menuId);
        com.etn.util.Logger.debug("verifymenuPath", qry);
        Set rs = Etn.execute(qry);
        if(rs.next())
        {
            String conflictSiteId = parseNull(rs.value("site_id"));
            String conflictDomain = getSiteDomain(Etn, conflictSiteId);

            if(currentSiteDomain.equals(conflictDomain))
            {
                return "Path conflict. Production path given is conflicting with Menu : "+rs.value("name")+" in Site : "+rs.value("sitename")+". Sites with same domain cannot share paths";
            }
            else
            {
                return "WARNING!! Path conflict. Production path given is conflicting with Menu : "+rs.value("name")+" in Site : "+rs.value("sitename");
            }
        }

        qry = " select m.*, s.name as sitename from menus m, "+PORTAL_DB+".sites s where s.id = m.site_id and coalesce(m.production_path, '') <> '' and " + escape.cote(menuPath) + " like concat(production_path,'%') ";
        if(menuId.length() > 0) qry += " and m.id <> " + escape.cote(menuId);
        com.etn.util.Logger.debug("verifymenuPath.jsp", qry);
        rs = Etn.execute(qry);
        if(rs.next())
        {
            String conflictSiteId = parseNull(rs.value("site_id"));
            String conflictDomain = getSiteDomain(Etn, conflictSiteId);

            if(currentSiteDomain.equals(conflictDomain))
            {
                return "Path conflict. Menu : "+rs.value("name")+" in Site : "+rs.value("sitename")+" matches the first part of production path. Sites with same domain cannot share paths";
            }
            else
            {
                return "WARNING!! Path conflict. Menu : "+rs.value("name")+" in Site : "+rs.value("sitename")+" matches the first part of production path";
            }
        }

        qry = " select m.*, s.name as sitename from menus m, "+PORTAL_DB+".sites s where s.id = m.site_id and coalesce(m.production_path, '') <> '' and production_path like " + escape.cote(menuPath + "%") + " ";
        if(menuId.length() > 0) qry += " and m.id <> " + escape.cote(menuId);
        com.etn.util.Logger.debug("verifymenuPath.jsp", qry);

        rs = Etn.execute(qry);
        if(rs.next())
        {
            String conflictSiteId = parseNull(rs.value("site_id"));
            String conflictDomain = getSiteDomain(Etn, conflictSiteId);

            if(currentSiteDomain.equals(conflictDomain))
            {
                return "Path conflict. Production path given matches the first part of Menu : "+rs.value("name")+" in Site : "+rs.value("sitename")+". Sites with same domain cannot share paths";
            }
            else
            {
                return "WARNING!! Path conflict. Production path given matches the first part of Menu : "+rs.value("name")+" in Site : "+rs.value("sitename");
            }
        }

        return "";
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
    int count = 0;

    String requestType = parseNull(request.getParameter("requestType"));
    String siteId = getSiteId(session);

    try{

        if("getList".equalsIgnoreCase(requestType)){
            try{

                String type = parseNull(request.getParameter("type"));

                JSONArray resultList = new JSONArray();
                JSONObject curObj = null;

                q = " SELECT m.id, m.name, bt.name AS template_name, m.updated_ts, l.langue AS language,l1.name updated_by "
                    + " FROM menus m "
                    + " LEFT JOIN login l1 on l1.pid = m.updated_by "
                    + " JOIN language l ON l.langue_id = m.langue_id"
                    + " JOIN bloc_templates bt ON bt.id = m.template_id"
                    + " WHERE m.site_id = " + escape.cote(siteId)
                    + " AND bt.type = " + escape.cote(Constant.SYSTEM_TEMPLATE_MENU)
                    + " ORDER BY m.name ";

                rs = Etn.execute(q);
                while(rs.next()){
                    curObj = new JSONObject();
                    for(String colName : rs.ColName){
                        curObj.put(colName.toLowerCase(), rs.value(colName));
                    }

                    resultList.put(curObj);
                }

                data.put("menus",resultList);
                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in getting menus list. Please try again.", ex);
            }
        }
        else if("saveMenu".equalsIgnoreCase(requestType)){

            try{

                int menuId = parseInt(request.getParameter("menuId"), 0);

                String name = parseNull(request.getParameter("name"));
                String template_id = parseNull(request.getParameter("template_id"));
                String langue_id = parseNull(request.getParameter("langue_id"));

                String templateData = parseNull(request.getParameter("templateData"));

                String errorMsg = "";
                try{
                    if(name.length() == 0){
                        throw new Exception("Name cannot be empty");
                    }
                    else{
                        //check template validity
                        q = "SELECT id FROM menus "
                            + " WHERE name = " + escape.cote(name)
                            + " AND site_id = " + escape.cote(siteId);
                        if(menuId > 0){
                            q += " AND id != " + escape.cote(""+menuId);
                        }

                        rs = Etn.execute(q);
                        if(rs.next()){
                            throw new Exception("Name already exist. please specify different name");
                        }

                    }

                    if(menuId == 0){

                        //only need to check type (template_id) for new
                        //existing catalog type (template_id) cannot be changed
                        if(template_id.length() == 0){
                            throw new Exception("No template selected");
                        }

                        if(errorMsg.length() == 0){
                            //check template validity
                            q = "SELECT id FROM bloc_templates "
                                + " WHERE id = " + escape.cote(template_id)
                                + " AND site_id = " + escape.cote(siteId)
                                + " AND type = " + escape.cote(Constant.SYSTEM_TEMPLATE_MENU);
                            rs = Etn.execute(q);
                            if(!rs.next()){
                                throw new Exception("Invalid template (template does not exist)");
                            }
                        }
                    }

                    try{
                        templateData = (new JSONObject(templateData)).toString();
                    }
                    catch(Exception ex){
                        throw new Exception("Invalid template data JSON");
                    }

                }
                catch(Exception ex){
                    errorMsg = ex.getMessage();
                }


                if(errorMsg.length() > 0){
                    message = errorMsg;
                }
                else{

                    int pid = Etn.getId();

                    //TODO not null column, to be removed next release
                    colValueHM.put("variant", escape.cote("all"));

                    colValueHM.put("name", escape.cote(name));
                    colValueHM.put("langue_id", escape.cote(langue_id));

                    //especial escape function for JSON string
                    colValueHM.put("template_data", escapeCote(templateData));

                    colValueHM.put("updated_ts", "NOW()");
                    colValueHM.put("updated_by", escape.cote(""+pid));

                    if(menuId <= 0){
                        //new
                        colValueHM.put("uuid", "UUID()");
                        colValueHM.put("site_id", escape.cote(siteId));
                        colValueHM.put("template_id", escape.cote(template_id));
                        colValueHM.put("created_by", escape.cote(""+pid));
                        colValueHM.put("created_ts", "NOW()");

                        q = getInsertQuery("menus",colValueHM);
                        menuId = Etn.executeCmd(q);

                        if(menuId <= 0){
                            message = "Error in creating menu. Please try again.";
                        }
                        else{
                            status = STATUS_SUCCESS;
                            message = "Menu created.";
                            data.put("id", menuId);
                        }
                    }
                    else{
                        //existing update
                        q = getUpdateQuery("menus", colValueHM, " WHERE id = " + escape.cote(""+menuId) );

                        count = Etn.executeCmd(q);

                        if(count <= 0){
                            message = "Error in menu. Please try again.";
                        }
                        else{

                            markPagesToGenerate(""+menuId, "menus", Etn);

                            status = STATUS_SUCCESS;
                            message = "menu updated.";
                            data.put("id", menuId);
                        }
                    }

                }
            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving menu. Please try again.",ex);
            }
        }
        else if("getMenuDetail".equalsIgnoreCase(requestType)){

            try{

                String menuId = parseNull(request.getParameter("menuId"));

                q = "SELECT * FROM menus "
                    + " WHERE id = " + escape.cote(menuId)
                    + " AND site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);

                if(!rs.next()){
                    message = "Invalid id";
                }
                else{
                    JSONObject menuObj = getJSONObject(rs);

                    String templateId = rs.value("template_id");
                    JSONArray sectionsList = PagesUtil.getBlocTemplateSectionsData(Etn, templateId);

                    JSONObject templateCode = new JSONObject();
                    templateCode.put("sections",sectionsList);

                    menuObj.put("template_code", templateCode);


                    data.put("menu", menuObj);
                    status = STATUS_SUCCESS;
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in saving menu. Please try again.",ex);
            }
        }
        else if("deleteMenus".equalsIgnoreCase(requestType)){
            try{
                String[] menuIds= request.getParameterValues("ids");

                int totalCount = menuIds.length;
                if(totalCount == 0){
                    throw new SimpleException("Error: No ids found.");
                }

                int deleteCount = 0;
                for(String menuId : menuIds){

                    q = "SELECT SUM(nb_use) as  nb_use "
                        + " FROM ( "
                        + "     SELECT COUNT(0) as nb_use FROM page_templates_items_blocs  "
                        + "     WHERE type = 'menu' AND bloc_id = " + escape.cote(menuId)
                        + " ) t";

                    rs = Etn.execute(q);
                    if(!rs.next()){
                        continue;
                    }

                    int usesCount = parseInt(rs.value("nb_use"),-1);

                    if(usesCount != 0){
                        //skip if usage is not 0
                        continue;
                    }

                    q = "DELETE FROM menus WHERE id = " + escape.cote(menuId);
                    Etn.executeCmd(q);

                    deleteCount += 1;
                }

                if(totalCount == 1){
                    if(deleteCount != 1){
                        throw new SimpleException("Error: Cannot delete. menu is used ");
                    }
                    else{
                        status = STATUS_SUCCESS;
                        message = "menu deleted";
                    }
                }
                else{
                    status = STATUS_SUCCESS;
                    message = deleteCount + " of " + totalCount + " menus deleted";
                    if(deleteCount < totalCount){
                        message += ". menus 'in use' cannot be deleted.";
                    }
                }

            }//try
            catch(Exception ex){
                throw new SimpleException("Error in deleting menus.",ex);
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