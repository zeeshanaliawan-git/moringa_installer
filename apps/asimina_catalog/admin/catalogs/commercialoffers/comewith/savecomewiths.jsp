 <jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*, com.etn.asimina.util.ActivityLog"%>
<%@ include file="../../../../WEB-INF/include/constants.jsp"%>
<%@ include file="../../../../WEB-INF/include/commonMethod.jsp"%>

<%!
	double parseDouble(String s)
	{		
		try {
			return Double.parseDouble(s);
		} catch(Exception e) {
			e.printStackTrace();
		}
		return 0;
	}

%>
<%

    String id = parseNull(request.getParameter("id"));
    String site_id = parseNull(getSelectedSiteId(session));

    int comewithId = 0;

    if(id.length() == 0)
    {
            String cols = "created_by, site_id";
            String vals = escape.cote(Etn.getId() + "") + ", " + escape.cote(site_id);

            for(String parameter : request.getParameterMap().keySet())
            {
                if(parameter.startsWith("associated_to_")) continue;
                cols += "," + parameter;

                if(parameter.endsWith("_description") && parseNull(request.getParameter(parameter)).length() == 0){
                    vals += "," + escape.cote(request.getParameter("lang_1_description"));
                }
                else if(parameter.equals("price_difference") && parseNull(request.getParameter(parameter)).length() == 0){
                    vals += "," + escape.cote(""+parseDouble(request.getParameter(parameter)));
                }
                else vals += "," + escape.cote(request.getParameter(parameter));
            }
            comewithId = Etn.executeCmd("insert into comewiths (" + cols + ") values (" + vals + ")");

            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),comewithId+"","CREATED","Come-With",parseNull(request.getParameter("name")),site_id);
    }
    else
    {
            String q = "update comewiths set version = version+1, updated_on = now(), updated_by = " + escape.cote("" + Etn.getId());

            for(String parameter : request.getParameterMap().keySet())
            {
                if(parameter.startsWith("associated_to_")) continue;
                if(parameter.equals("price_difference") && parseNull(request.getParameter(parameter)).length() == 0){
					q += ", " + parameter + " = " + escape.cote(""+parseDouble(request.getParameter(parameter)));
                }
				else
				{					
					q += ", " + parameter + " = " + escape.cote(request.getParameter(parameter));
				}
            }
            q += " where id = " + escape.cote(id);

            Etn.executeCmd(q);
            comewithId = parseInt(id);

            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),comewithId+"","UPDATED","Come-With",parseNull(request.getParameter("name")),site_id);
    }

    if(comewithId > 0){

        Etn.executeCmd("delete from comewiths_rules where comewith_id = " + escape.cote("" + comewithId));
        String[] associated_to_type = request.getParameterValues("associated_to_type_comewith");
        String[] associated_to_value = request.getParameterValues("associated_to_value_comewith");

        if(associated_to_type != null)
        {
            for(int i=0; i < associated_to_type.length; i++)
            {
                if(parseNull(associated_to_type[i]).length() != 0 && parseNull(associated_to_value[i]).length() != 0 ) {

                    Etn.executeCmd("insert into comewiths_rules (comewith_id, associated_to_type, associated_to_value) values (" + escape.cote("" + comewithId) + "," + escape.cote(associated_to_type[i]) + "," + escape.cote(associated_to_value[i]) + ")");
                    System.out.println("insert into comewiths_rules (comewith_id, associated_to_type, associated_to_value) values (" + escape.cote("" + comewithId) + "," + escape.cote(associated_to_type[i]) + "," + escape.cote(associated_to_value[i]) + ")");
                }
            }
        }
    }

    String extUrl = parseNull(com.etn.beans.app.GlobalParm.getParm("CATALOG_EXTERNAL_URL"));
    String params = "?";

    if(id.length() == 0) params += "is_save=";
    else params += "is_edit=";

    if(comewithId > 0) params += "1";

    if(extUrl.length() == 0) response.sendRedirect("comewiths.jsp"+params);
    else response.sendRedirect(extUrl + "admin/catalogs/commercialoffers/comewith/comewiths.jsp"+params);

%>