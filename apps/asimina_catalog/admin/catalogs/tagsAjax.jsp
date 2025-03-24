<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray, com.etn.asimina.util.ActivityLog, java.util.LinkedHashMap"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();

    String q = "";
    Set rs = null;

    String requestType = parseNull(request.getParameter("requestType"));
    String id = parseNull(request.getParameter("id"));

    String siteId = getSelectedSiteId(session);

    String PAGES_DB = GlobalParm.getParm("PAGES_DB");

    String folder_id=parseNull(request.getParameter("folder_id"));
    String folder_label="";
    if(folder_id.length() > 0){

        Set rsFolder=Etn.execute("Select id,folder_id from tags_folders where uuid="+escape.cote(folder_id));
    
        if(rsFolder.next()){
            folder_id=rsFolder.value("id");
            folder_label=rsFolder.value("folder_id");
        }
    }

    try{
        if("getTagsList".equalsIgnoreCase(requestType)){
            try{
                JSONArray tagsList = new JSONArray();


                q = "SELECT t.id, t.id as label_id,t.label,''as uuid,t.created_on, SUM(IFNULL(tuses.nb_uses, 0)) AS nb_uses,'tag' as type "
                    + " FROM tags t "
                    + " LEFT JOIN ( "
                    + "     SELECT ct.tag_id, COUNT(ct.catalog_id) as nb_uses, 'catalogs' AS type "
                    + "     FROM catalog_tags ct  "
                    + "     JOIN catalogs c ON c.id = ct.catalog_id AND c.site_id = " + escape.cote(siteId)
                    + "     GROUP BY ct.tag_id "
                    + "     UNION "
                    + "     SELECT pt.tag_id, COUNT(pt.product_id) as nb_uses, 'products' AS type "
                    + "     FROM product_tags pt  "
                    + "     JOIN products p ON p.id = pt.product_id "
                    + "     JOIN catalogs c ON c.id = p.catalog_id AND c.site_id = " + escape.cote(siteId)
                    + "     GROUP BY pt.tag_id "
                    + "     UNION "
                    + "     SELECT bt.tag_id, COUNT(bt.bloc_id) as nb_uses, 'blocs' AS type "
                    + "     FROM "+PAGES_DB+".blocs_tags bt  "
                    + "     JOIN "+PAGES_DB+".blocs b ON b.id = bt.bloc_id AND b.site_id = " + escape.cote(siteId)
                    + "     GROUP BY bt.tag_id "
                    + "     UNION "
                    + "     SELECT pt.tag_id, COUNT(distinct pt.page_id, pt.page_type) as nb_uses, 'pages' AS type "
                    + "     FROM "+PAGES_DB+".pages_tags pt  "
                    + "     JOIN "+PAGES_DB+".pages p ON case when p.type='react' then p.id else p.parent_page_id end = pt.page_id and pt.page_type = p.type AND p.site_id = " + escape.cote(siteId)
                    + "     GROUP BY pt.tag_id "
                    + "     UNION "
                    + "     SELECT mt.tag as tag_id, COUNT(distinct mt.file_id) as nb_uses, 'tags' AS type "
                    + "     FROM "+PAGES_DB+".media_tags mt  "
                    + "     JOIN "+PAGES_DB+".files f ON f.id = mt.file_id and f.site_id = " + escape.cote(siteId)
                    + "     GROUP BY mt.tag "
                    + " ) tuses ON tuses.tag_id = t.id "
                    + " WHERE t.site_id = " + escape.cote(siteId);

                    if(folder_id.length() > 0){
                        q+=" and t.folder_id="+escape.cote(folder_id);
                    }else{
                        q+=" and (t.folder_id is null or t.folder_id='') ";
                    }

                    if(id.length()>0) q += " and t.id = "+escape.cote(id);
                    q += " GROUP BY t.id union select id,folder_id as label_id,name as label,uuid,created_on,0 as nb_uses, 'folder' as type from tags_folders where site_id="+escape.cote(siteId);
                    
                    if(folder_id.length() > 0){
                        q+=" and parent_folder_id="+escape.cote(folder_id);
                    }else{
                        q+=" and parent_folder_id =0 ";
                    }


                rs = Etn.execute(q);
                JSONObject curObj = null;
                while(rs.next()){
                    curObj = new JSONObject();
                    for(String colName : rs.ColName){
                        if(colName.equalsIgnoreCase("nb_uses") && rs.value("type").equalsIgnoreCase("folder")){
                            Set rsTagsCount = Etn.execute("select id from tags where folder_id="+escape.cote(rs.value("id"))+" union select id from tags_folders where parent_folder_id="+escape.cote(rs.value("id")));
                            curObj.put(colName.toLowerCase(), rsTagsCount.rs.Rows);
                        }else{
                            curObj.put(colName.toLowerCase(), rs.value(colName));
                        }
                    }
                    tagsList.put(curObj);
                }

                status = STATUS_SUCCESS;
                data.put("tags",tagsList);

            }//try
            catch(Exception ex){
                message = "Error in getting tags list. Please try again.";
                throw new SimpleException(message, ex);
            }

        }
        else if("saveTag".equalsIgnoreCase(requestType)){
            try{

                String type = parseNull(request.getParameter("type"));

                String label = parseNull(request.getParameter("label"));
                String tagId = parseNull(request.getParameter("tagId"));

                //remove commas (,) if any
                label = label.replaceAll(",","");
                tagId = tagId.replaceAll(",","");

                if(tagId.length() == 0 || label.length() == 0 ){
                    throw new SimpleException("Error: label or ID cannot be empty");
                }

                if("add".equals(type)){
                    //add new
                    q = " SELECT id FROM tags "
                        + " WHERE id = " + escape.cote(tagId)
                        + " AND site_id = " + escape.cote(siteId)
                        + " AND folder_id = " + escape.cote(folder_id);
                    rs = Etn.execute(q);
                    if(rs.next()){
                        throw new SimpleException("Error: Tag ID already exists.");
                    }

                    if(folder_label.length()>0){
                        folder_label="$"+folder_label;
                    }   

                    q = "INSERT INTO tags(id, site_id, label, created_by, created_on,folder_id) VALUES ("
                        + escape.cote(tagId+folder_label) + ", "
                        + escape.cote(siteId) + ", "
                        + escape.cote(label) + ", "
                        + escape.cote(""+Etn.getId()) + ", NOW(), "
                        + escape.cote(folder_id) + ")";

                    int count = Etn.executeCmd(q);
                    if(count < 1){
                        throw new SimpleException("Error in adding new tag record.");
                    }else{
                        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),tagId,"CREATED","Tag",label,siteId);
                    }

                }
                else{
                    //edit existing

                    q = "UPDATE tags SET label = " + escape.cote(label)
                        + " WHERE id = " + escape.cote(tagId);
                    int count = Etn.executeCmd(q);
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"UPDATED",tagId,"Tag",label,siteId);

                }

                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                message = "Error in saving tag record. Please try again.";
                throw new SimpleException(message, ex);
            }

        }
        else if("deleteTags".equalsIgnoreCase(requestType)){
            try{
                String tagLabels = "";
                String tagIds[] = parseNull(request.getParameter("ids")).split(",");
                if(tagIds.length > 0){
                    for(String tagId : tagIds){

                        q = "Select label from tags"
                        + " WHERE  site_id = " + escape.cote(siteId)
                        + " AND    id = " + escape.cote(tagId);
                        rs =  Etn.execute(q);
                        rs.next();
                        if(tagLabels.length() > 0)
                            tagLabels += ", ";
                        tagLabels += parseNull(rs.value("label"));

                        q = " DELETE ct "
                            + " FROM catalog_tags ct "
                            + " JOIN catalogs c ON c.id = ct.catalog_id "
                            + " WHERE  c.site_id = " + escape.cote(siteId)
                            + " AND ct.tag_id = " + escape.cote(tagId);
                        Etn.executeCmd(q);

                        q = " DELETE pt "
                            + " FROM product_tags pt "
                            + " JOIN products p ON p.id = pt.product_id "
                            + " JOIN catalogs c ON c.id = p.catalog_id  "
                            + " WHERE  c.site_id = " + escape.cote(siteId)
                            + " AND pt.tag_id = " + escape.cote(tagId);
                        Etn.executeCmd(q);

                        q = " DELETE bt "
                            + " FROM "+PAGES_DB+".blocs b "
                            + " JOIN "+PAGES_DB+".blocs_tags bt ON b.id = bt.bloc_id "
                            + " WHERE b.site_id = " + escape.cote(siteId)
                            + " AND bt.tag_id = " +  escape.cote(tagId);
                        Etn.executeCmd(q);

                        q = " DELETE pt "
                            + " FROM "+PAGES_DB+".pages_tags pt "
                            + " JOIN "+PAGES_DB+".pages p ON case when p.type='react' then p.id else p.parent_page_id end = pt.page_id and p.type = pt.page_type "
                            + " WHERE  p.site_id = " + escape.cote(siteId)
                            + " AND pt.tag_id = " + escape.cote(tagId);
                        Etn.executeCmd(q);

                        q = " DELETE FROM tags "
                            + " WHERE site_id = " + escape.cote(siteId)
                            + " AND id = " + escape.cote(tagId);
                        Etn.executeCmd(q);

                        status = STATUS_SUCCESS;
                    }
                }
                if(status ==  STATUS_SUCCESS)
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),parseNull(request.getParameter("ids")),"DELETED","Tag",tagLabels,siteId);

            }//try
            catch(Exception ex){
                message = "Error in saving tag record. Please try again.";
                throw new SimpleException(message, ex);
            }
        }
        else if("getTagUses".equalsIgnoreCase(requestType)){
            try{

            	String tagId = parseNull(request.getParameter("tagId"));

                JSONArray catalogsList = new JSONArray();
                q = "SELECT DISTINCT c.id , c.name "
                	+ " FROM catalogs c "
                	+ " JOIN catalog_tags ct ON ct.catalog_id = c.id "
                	+ " WHERE c.site_id = " + escape.cote(siteId)
                	+ " AND ct.tag_id = " + escape.cote(tagId);
                rs = Etn.execute(q);
                JSONObject curObj = null;
                while(rs.next()){
                    curObj = new JSONObject();
                    curObj.put("id", rs.value("id"));
                    curObj.put("name", rs.value("name"));
                    catalogsList.put(curObj);
                }

                JSONArray productsList = new JSONArray();
                q = "SELECT DISTINCT p.id , p.lang_1_name AS name, p.catalog_id as cid "
                	+ " FROM products p "
                	+ " JOIN product_tags pt ON pt.product_id = p.id "
                	+ " JOIN catalogs c ON c.id = p.catalog_id  "
                	+ " WHERE c.site_id = " + escape.cote(siteId)
                	+ " AND pt.tag_id = " + escape.cote(tagId);
                rs = Etn.execute(q);
                while(rs.next()){
                    curObj = new JSONObject();
                    curObj.put("id", rs.value("id"));
                    curObj.put("name", rs.value("name"));
                    curObj.put("cid", rs.value("cid"));
                    productsList.put(curObj);
                }

                JSONArray blocsList = new JSONArray();
                q = "SELECT DISTINCT b.id , b.name"
                    + " FROM "+PAGES_DB+".blocs b "
                    + " JOIN "+PAGES_DB+".blocs_tags bt ON b.id = bt.bloc_id AND bt.tag_id = " + escape.cote(tagId)
                    + " WHERE b.site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                while(rs.next()){
                    curObj = new JSONObject();
                    curObj.put("id", rs.value("id"));
                    curObj.put("name", rs.value("name"));
                    blocsList.put(curObj);
                }

                JSONArray pagesList = new JSONArray();
                q = "SELECT DISTINCT p.id , p.name, p.type"
                    + " FROM "+PAGES_DB+".pages p "
                    + " JOIN "+PAGES_DB+".pages_tags pt ON case when p.type='react' then p.id else p.parent_page_id end = pt.page_id and p.type = pt.page_type AND pt.tag_id = " + escape.cote(tagId)
                    + " WHERE p.site_id = " + escape.cote(siteId);
                rs = Etn.execute(q);
                while(rs.next()){
                    curObj = new JSONObject();
                    curObj.put("id", rs.value("id"));
                    curObj.put("name", rs.value("name"));
                    curObj.put("type", rs.value("type"));
                    pagesList.put(curObj);
                }

                data.put("catalogs",catalogsList);
                data.put("products",productsList);
                data.put("blocs",blocsList);
                data.put("pages",pagesList);

                status = STATUS_SUCCESS;

            }//try
            catch(Exception ex){
                message = "Error in getting tag uses. Please try again.";
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
