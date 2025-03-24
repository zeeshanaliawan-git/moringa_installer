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

    String logedInUserId = parseNull(Etn.getId());

    String q = "";
    Set rs = null;

    String requestType = parseNull(request.getParameter("requestType"));
    String id = parseNull(request.getParameter("id"));

    String siteId = getSelectedSiteId(session);

    String PAGES_DB = GlobalParm.getParm("PAGES_DB");

    try{
        if("getTagsList".equalsIgnoreCase(requestType)){
            try{
                JSONArray tagsList = new JSONArray();

                q="SELECT ft.*,COUNT(crt.tag_id) AS 'nb_uses' FROM "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".forum_tags ft "+
                "LEFT JOIN "+com.etn.beans.app.GlobalParm.getParm("PROD_PORTAL_DB")+".client_review_tags crt ON crt.tag_id=ft.tag_id where ft.site_id="+escape.cote(siteId)+" GROUP BY ft.tag_id";

                rs = Etn.execute(q);
                JSONObject curObj = null;
                while(rs.next()){
                    curObj = new JSONObject();
                    for(String colName : rs.ColName){
                        curObj.put(colName.toLowerCase(), rs.value(colName));
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
                    q = "SELECT tag_id FROM "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".forum_tags"
                        + " WHERE tag_id = " + escape.cote(tagId)+" and site_id="+escape.cote(siteId);
                    rs = Etn.execute(q);
                    if(rs.next()){
                        throw new SimpleException("Error: Tag ID already exists.");
                    }

                    q = "INSERT INTO "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".forum_tags(tag_id,tag_name,created_on,created_by,site_id) VALUES ("
                        + escape.cote(tagId) + ", "
                        + escape.cote(label) + ", "
                        + "NOW(), "
                        + escape.cote(logedInUserId) + ", "
                        + escape.cote(siteId) +")";

                    int count = Etn.executeCmd(q);
                    if(count < 1){
                        throw new SimpleException("Error in adding new tag record.");
                    }else{
                        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),tagId,"CREATED","Forum Tag",label,siteId);
                    }

                }
                else{
                    //edit existing

                    q = "UPDATE "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".forum_tags SET tag_name = " + escape.cote(label)
                        + " WHERE tag_id = " + escape.cote(tagId)+" and site_id="+escape.cote(siteId);
                    int count = Etn.executeCmd(q);
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"UPDATED",tagId,"Forum Tag",label,siteId);

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

                        q = "Select tag_name from "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".forum_tags"
                        + " WHERE tag_id = " + escape.cote(tagId)+" and site_id="+escape.cote(siteId);
                        rs =  Etn.execute(q);
                        rs.next();
                        if(tagLabels.length() > 0)
                            tagLabels += ", ";
                        tagLabels += parseNull(rs.value("label"));

                        q = "DELETE FROM "+com.etn.beans.app.GlobalParm.getParm("COMMONS_DB")+".forum_tags WHERE tag_id = " + escape.cote(tagId)+" and site_id="+escape.cote(siteId);
                        
                        Etn.executeCmd(q);

                        status = STATUS_SUCCESS;
                    }
                }
                if(status ==  STATUS_SUCCESS)
                    ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),parseNull(request.getParameter("ids")),"DELETED","Forum Tag",tagLabels,siteId);

            }//try
            catch(Exception ex){
                message = "Error in saving tag record. Please try again.";
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
