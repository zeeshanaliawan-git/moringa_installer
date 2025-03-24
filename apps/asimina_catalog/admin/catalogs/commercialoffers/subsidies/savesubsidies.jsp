 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*, com.etn.asimina.util.ActivityLog"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%

    String id = parseNull(request.getParameter("id"));
    String site_id = parseNull(getSelectedSiteId(session));

    int subsidyId = 0;

    if(id.length() == 0)
    {
            String cols = "created_by, site_id";
            String vals = escape.cote(Etn.getId() + "") + ", " + escape.cote(site_id);

            for(String parameter : request.getParameterMap().keySet())
            {
                if(parameter.equals("redirect_url_opentype")) continue;
                if(parameter.startsWith("associated_to_")) continue;
                cols += "," + parameter;

                if(parameter.endsWith("_description") && parseNull(request.getParameter(parameter)).length() == 0){
                    vals += "," + escape.cote(request.getParameter("lang_1_description"));
                }
                else vals += "," + escape.cote(request.getParameter(parameter));
            }
            subsidyId = Etn.executeCmd("insert into subsidies (" + cols + ") values (" + vals + ")");
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),subsidyId+"","CREATED","Subsidie",parseNull(request.getParameter("name")),site_id);

    }
    else
    {
            String q = "update subsidies set version = version+1, updated_on = now(), updated_by = " + escape.cote("" + Etn.getId());

            for(String parameter : request.getParameterMap().keySet())
            {
				if(parameter.equals("redirect_url_opentype")) continue;
                if(parameter.startsWith("associated_to_")) continue;
                q += ", " + parameter + " = " + escape.cote(request.getParameter(parameter));
            }
            q += " where id = " + escape.cote(id);
            Etn.executeCmd(q);
            subsidyId = parseInt(id);
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),subsidyId+"","UPDATED","Subsidie",parseNull(request.getParameter("name")),site_id);

    }

    if(subsidyId > 0){

        Etn.executeCmd("delete from subsidies_rules where subsidy_id = " + escape.cote("" + subsidyId));
        String[] associated_to_type = request.getParameterValues("associated_to_type_subsidy");
        String[] associated_to_value = request.getParameterValues("associated_to_value_subsidy");

        if(associated_to_type != null)
        {
            for(int i=0; i < associated_to_type.length; i++)
            {
                if(parseNull(associated_to_type[i]).length() != 0 && parseNull(associated_to_value[i]).length() != 0 ) {

                    Etn.executeCmd("insert into subsidies_rules (subsidy_id, associated_to_type, associated_to_value) values (" + escape.cote("" + subsidyId) + "," + escape.cote(associated_to_type[i]) + "," + escape.cote(associated_to_value[i]) + ")");
                }
            }
        }
    }

    String extUrl = parseNull(com.etn.beans.app.GlobalParm.getParm("CATALOG_EXTERNAL_URL"));
    String params = "?";

    if(id.length() == 0) params += "is_save=";
    else params += "is_edit=";

    if(subsidyId > 0) params += "1";

    if(extUrl.length() == 0) response.sendRedirect("subsidies.jsp"+params);
    else response.sendRedirect(extUrl + "admin/catalogs/commercialoffers/subsidies/subsidies.jsp"+params);
%>