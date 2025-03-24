<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.*, java.time.*, java.time.format.DateTimeFormatter, java.io.*, com.etn.beans.app.GlobalParm,org.json.JSONObject,org.json.JSONArray"%>
<%@ include file="/common2.jsp" %>

<%
    JSONObject obj = new JSONObject();
    String status = "true";
    String message = "";
    String siteId=parseNull(session.getAttribute("SELECTED_SITE_ID"));
    String requestType = parseNull(request.getParameter("requestType"));
    
    String portalDb = parseNull(GlobalParm.getParm("PORTAL_DB"))+".";
    String catalogDb = parseNull(GlobalParm.getParm("CATALOG_DB"))+".";
    String pagesDb = parseNull(GlobalParm.getParm("PAGES_DB"))+".";
    String commonDb = parseNull(GlobalParm.getParm("COMMONS_DB"))+".";
    int langId=0;

    Set rsLang = Etn.execute("select langue_id from "+commonDb+"sites_langs where site_id="+escape.cote(siteId)+" order by langue_id limit 1");
    if(rsLang.next()){
        langId=Integer.parseInt(parseNull(rsLang.value("langue_id")));
    }


    try{
        
        if(requestType.equalsIgnoreCase("autocomplete")){
    		String value = parseNull(request.getParameter("value"));
    		String filterType = parseNull(request.getParameter("filterType"));
            
            String query="";
            if(filterType.equalsIgnoreCase("product")){
                query = "select p.id,p.lang_"+langId+"_name as name from "+catalogDb+"products p left join "+catalogDb+"catalogs c on c.id=p.catalog_id where p.lang_"+langId+"_name like "+escape.cote("%"+value+"%")+" and c.site_id="+escape.cote(siteId);
            }else if(filterType.equalsIgnoreCase("commercialcatalog")){
                query = "select id,name from "+catalogDb+"catalogs where name like "+escape.cote("%"+value+"%")+" and site_id="+escape.cote(siteId);
            }else if(filterType.equalsIgnoreCase("structuredcatalog")){
                query = "select id,name from "+pagesDb+"structured_contents where name like "+escape.cote("%"+value+"%")+" and site_id="+escape.cote(siteId);
            }else if(filterType.equalsIgnoreCase("page")){
                query = "select id,name from "+pagesDb+"freemarker_pages where name like "+escape.cote("%"+value+"%")+" and site_id="+escape.cote(siteId);
            }

            JSONArray respArray = new JSONArray();
            Set rs = Etn.execute(query);
            while(rs.next()){

                JSONObject respObj = new JSONObject();
                respObj.put("id",rs.value("id"));
                respObj.put("name",rs.value("name"));
                respArray.put(respObj);
            }
            obj.put("data",respArray);
        }
        else if(requestType.equalsIgnoreCase("removeFilter")){

            String itemId = parseNull(request.getParameter("itemId"));
            String filterId = parseNull(request.getParameter("filterId"));

            if(itemId.length() > 0){
                Etn.executeCmd("delete from  dashboard_filters_items WHERE id="+escape.cote(itemId));
            }

            if(filterId.length() > 0){
                Etn.executeCmd("delete from  dashboard_filters WHERE id="+escape.cote(filterId));
            }
            
            message = "Deleted successfully.";
        }
        else if(requestType.equalsIgnoreCase("addFilter")){

            String name = parseNull(request.getParameter("name"));
            if(name.length() > 0){
                Etn.executeCmd("insert into dashboard_filters (filter_name,site_id,created_by) values("+escape.cote(name)+","+escape.cote(siteId)+","+escape.cote(""+Etn.getId())+")");
                message = "Added successfully.";
            }else{
                message = "Filter name can not be empty.";
            }
        }
        else{
            status = "false";
            message = "Invalid request type.";
        }

    }catch(Exception e){
        status = "false";
        message = e.getMessage();
    }
    obj.put("status",status);
    obj.put("message",message);

    out.write(obj.toString());
%>
