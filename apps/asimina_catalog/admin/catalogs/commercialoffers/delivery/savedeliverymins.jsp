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
        int deliveryminId = 0;
	if(id.length() == 0)
	{
            String cols = "created_by, site_id";
            String vals = escape.cote(""+Etn.getId())+", "+escape.cote(site_id);
            for(String parameter : request.getParameterMap().keySet())
            {
                //if(parameter.startsWith("applied_to_")) continue;
                cols += "," + parameter;

                if(parameter.endsWith("_description") && parseNull(request.getParameter(parameter)).length() == 0){
                    vals += "," + escape.cote(request.getParameter("lang_1_description"));
                }
                else vals += "," + escape.cote(request.getParameter(parameter));
            }
            deliveryminId = Etn.executeCmd("insert into deliverymins ("+cols+") values ("+vals+")");

            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),deliveryminId+"","CREATED","Delivery Minimum",parseNull(request.getParameter("name")),site_id);

	}
	else
	{
            String q = "update deliverymins set version = version+1, updated_on = now(), updated_by = " + escape.cote(""+Etn.getId());
            for(String parameter : request.getParameterMap().keySet())
            {
                //if(parameter.startsWith("applied_to_")) continue;

                q += ", " + parameter + " = " + escape.cote(request.getParameter(parameter));
            }
            q += " where id = " + escape.cote(id);
            //System.out.println("SAVE PRODUCT : \n"+ q); //debug
            Etn.executeCmd(q);
            deliveryminId = parseInt(id);

            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),deliveryminId+"","UPDATED","Delivery Minimum",parseNull(request.getParameter("name")),site_id);



	}

        //response.sendRedirect("deliverymin.jsp?id="+id);
    String extUrl = parseNull(com.etn.beans.app.GlobalParm.getParm("CATALOG_EXTERNAL_URL"));
    String params = "?";

    if(id.length() == 0) params += "is_save=";
    else params += "is_edit=";

    if(deliveryminId > 0) params += "1";

    if(extUrl.length() == 0) response.sendRedirect("deliverymins.jsp"+params);
    else response.sendRedirect(extUrl + "admin/catalogs/commercialoffers/delivery/deliverymins.jsp"+params);
%>