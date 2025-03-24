<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@page import="com.etn.lang.ResultSet.Set"%>
<%@ include file="/common.jsp"%>
<%@page import="com.etn.sql.escape, com.etn.util.ItsDate, com.etn.util.*, com.etn.beans.app.GlobalParm,com.etn.util.Base64, com.etn.asimina.util.*"%>
<%@page import="java.io.*"%>
<%@page import="org.jsoup.*"%>
<%@page import="org.jsoup.nodes.*"%>
<%@page import="org.jsoup.select.*"%>

<%
    String status = "ERROR";

    String type = parseNull(request.getParameter("type"));

    if("add_destination_page".equals(type)){

        String destinationPage = parseNull(request.getParameter("destination_page"));
        String destAddedPage = parseNull(request.getParameter("dest_page_added"));
        String destPageId = parseNull(request.getParameter("dest_page_id"));
        int r = 0;

        if(destinationPage.length() > 0){

            String query = "";
            
            if(destAddedPage.equalsIgnoreCase("true")) query = "INSERT INTO dest_page_settings (destination_page) VALUES (" +  escape.cote(destinationPage) + ")";
            else query = "UPDATE dest_page_settings SET destination_page = " + escape.cote(destinationPage) + " WHERE id = " + escape.cote(destPageId);
            r = Etn.executeCmd(query); 
            if(r > 0) status = "SUCCESS";

        }

        out.write("{\"RESPONSE\":\"" + status + "\", \"DEST_PAGE_ID\":\"" + r + "\"}");
    
    } else if("add_auto_screen".equals(type)){

        String autoScreen = parseNull(request.getParameter("auto_screen"));
        String destPageId = parseNull(request.getParameter("dest_page_id"));
		//IMPORTANT FOR CSS:filename must be cleaned up
        String destPageName = parseNull(request.getParameter("dest_page_name")).replaceAll("/", "").replaceAll("\\\\", "");
        
        if(autoScreen.equalsIgnoreCase("true")) autoScreen = "1";
        else if(autoScreen.equalsIgnoreCase("false")) autoScreen = "0";
        
        try{

            String query = "UPDATE dest_page_settings SET auto_screen = " + escape.cote(autoScreen) + " WHERE id = " + escape.cote(destPageId);
            Etn.execute(query);
            
            String path = GlobalParm.getParm("WEBAPP_FOLDER");
            path = path + destPageName;
            File f = new File(path);

            Document doc = Jsoup.parse(f, "utf-8"); 

            Elements dynamicFilterUi = doc.select("div#es_dynamic_filter_ui");
            dynamicFilterUi.html("<jsp:include page=\"pages/mappedFilters.jsp\" > <jsp:param name=\"dest_page_name\" value=\"" + CommonHelper.escapeCoteValue(destPageName) + "\" /> </jsp:include>");
            
            if(autoScreen.equals("1")){

                Elements bodyElement = doc.select("body");
                Elements scriptFetchDataElement = doc.select("div#script_fetch_data");
                
                if(scriptFetchDataElement.size() == 0){
                    
                    bodyElement.prepend("<div id=\"script_fetch_data\"> <jsp:include page=\"pages/scriptCall.jsp\" > <jsp:param name=\"dest_page_name\" value=\"" + CommonHelper.escapeCoteValue(destPageName) + "\" /> </jsp:include> </div>");
                }
            }

            writeFile(f, doc.toString()); 

            out.write("{\"RESPONSE\":\"SUCCESS\"}");

        }catch(FileNotFoundException fof){
            Etn.execute("DELETE FROM dest_page_settings WHERE destination_page = " + escape.cote(destPageName));
            out.write("{\"RESPONSE\":\"FOF\"}");
        }
        catch(Exception ex){
            
            System.out.println(ex.toString());
        }

    } else if("add_dest_page_filter".equals(type)){
        
        String displayName = parseNull(request.getParameter("display_name"));
        String destPageId = parseNull(request.getParameter("dest_page_id"));
        String usedAsParameter = parseNull(request.getParameter("used_as_parameter"));
        String userFilterType = parseNull(request.getParameter("user_filter_type"));
        StringBuffer createdUserFilter = new StringBuffer();

        if(usedAsParameter.equalsIgnoreCase("true")) usedAsParameter = "1";
        else if(usedAsParameter.equalsIgnoreCase("false")) usedAsParameter = "0";

        String query = "INSERT INTO dest_page_filters (dest_page_id, display_name, user_filter_type, used_as_parameter) VALUES (" +  escape.cote(destPageId) + "," + escape.cote(displayName) + "," + escape.cote(userFilterType) + "," + escape.cote(usedAsParameter) + ")";
        int r = Etn.executeCmd(query);
        
        if(r > 0) status = "SUCCESS";

        Set createdUserFilterRs = Etn.execute("SELECT dps.destination_page, dpf.display_name, dpf.used_as_parameter FROM dest_page_filters dpf, dest_page_settings dps WHERE dpf.dest_page_id = dps.id");

        while(createdUserFilterRs.next()){
            
            createdUserFilter.append("<tr>");
            createdUserFilter.append("<td>");
            createdUserFilter.append(createdUserFilterRs.value("display_name"));
            createdUserFilter.append("</td>");
            createdUserFilter.append("<td>");
            createdUserFilter.append("<input type=\"checkbox\" ");

            if(createdUserFilterRs.value("used_as_parameter").equals("1")) createdUserFilter.append(" checked=\"checked\" ");

            createdUserFilter.append("/>");
            createdUserFilter.append("</td>");
            createdUserFilter.append("<td>");
            createdUserFilter.append(createdUserFilterRs.value("destination_page"));
            createdUserFilter.append("</td>");
            createdUserFilter.append("</tr>");

        }

        out.write(createdUserFilter.toString());

    } else if("add_user_filter_value".equals(type)){
        
        String destPageName = parseNull(request.getParameter("dest_page_name"));
        
        Set rs = Etn.execute("SELECT dps.destination_page, dps.auto_screen, dpf.* FROM dest_page_filters dpf, dest_page_settings dps WHERE dpf.dest_page_id = dps.id AND dps.destination_page = " + escape.cote(destPageName));
        String elementName = "";

        Set updateParamValues = null;
        while(rs.next()){
            
            elementName = parseNull(rs.value("display_name")).replaceAll(" ", "_");
            System.out.println(parseNull(request.getParameter(elementName)));
            Etn.execute("UPDATE expert_system_query_params SET default_value = " );
        }

    }

%>
