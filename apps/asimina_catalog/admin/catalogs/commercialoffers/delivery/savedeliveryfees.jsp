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
        int deliveryfeeId = 0;
	if(id.length() == 0)
	{
            String cols = "created_by, site_id";
            String vals = escape.cote(""+Etn.getId())+", "+escape.cote(site_id);
            for(String parameter : request.getParameterMap().keySet())
            {
                if(parameter.startsWith("applied_to_")) continue;
                cols += "," + parameter;

                if(parameter.endsWith("_description") && parseNull(request.getParameter(parameter)).length() == 0){
                    vals += "," + escape.cote(request.getParameter("lang_1_description"));
                }
                else vals += "," + escape.cote(request.getParameter(parameter));
            }
            deliveryfeeId = Etn.executeCmd("insert into deliveryfees ("+cols+") values ("+vals+")");
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),deliveryfeeId+"","CREATED","Delivery Fee",parseNull(request.getParameter("name")),site_id);

	}
	else
	{
            String q = "update deliveryfees set version = version+1, updated_on = now(), updated_by = " + escape.cote(""+Etn.getId());
            for(String parameter : request.getParameterMap().keySet())
            {
                if(parameter.startsWith("applied_to_")) continue;

                q += ", " + parameter + " = " + escape.cote(request.getParameter(parameter));
            }
            q += " where id = " + escape.cote(id);
            //System.out.println("SAVE PRODUCT : \n"+ q); //debug
            Etn.executeCmd(q);
            deliveryfeeId = parseInt(id);

            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),deliveryfeeId+"","UPDATED","Delivery Fee",parseNull(request.getParameter("name")),site_id);

	}

        if(deliveryfeeId > 0){
            Etn.executeCmd("delete from deliveryfees_rules where deliveryfee_id="+escape.cote(""+deliveryfeeId));
            String[] applied_to_type = request.getParameterValues("applied_to_type");
            String[] applied_to_value = request.getParameterValues("applied_to_value");

            if(applied_to_type != null)
            {
                for(int i=0;i<applied_to_type.length;i++)
                {

                    if(parseNull(applied_to_type[i]).equals("all") || parseNull(applied_to_type[i]).length() != 0 && parseNull(applied_to_value[i]).length() != 0 ) {
                        Etn.executeCmd("insert into deliveryfees_rules (deliveryfee_id, applied_to_type, applied_to_value) values ("+escape.cote(""+deliveryfeeId)+","+escape.cote(applied_to_type[i])+","+escape.cote(applied_to_value[i])+")");

                    }

                }
            }
        }

        //response.sendRedirect("deliveryfee.jsp?id="+id);
    String extUrl = parseNull(com.etn.beans.app.GlobalParm.getParm("CATALOG_EXTERNAL_URL"));
    String params = "?";

    if(id.length() == 0) params += "is_save=";
    else params += "is_edit=";

    if(deliveryfeeId > 0) params += "1";

    if(extUrl.length() == 0) response.sendRedirect("deliveryfees.jsp"+params);
    else response.sendRedirect(extUrl + "admin/catalogs/commercialoffers/delivery/deliveryfees.jsp"+params);
%>