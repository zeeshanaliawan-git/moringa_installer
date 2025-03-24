<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/admin/common.jsp"%>
<%
 
        String term = "%"+parseNull(request.getParameter("term"))+"%";
        String type = parseNull(request.getParameter("type"));
        String selectedsiteid = parseNull(getSelectedSiteId(session));
        boolean addComma = false;

        out.write("[");

        if(type.equals("delivery_method")){

            Set rs = Etn.execute("select method, displayName from delivery_methods where site_id = "+escape.cote(selectedsiteid) + " AND displayName LIKE " + escape.cote(term));

            while(rs.next()){

                if(addComma) out.write(",");

                out.write("{\"id\":\""+rs.value(0)+"\",\"value\":\""+rs.value(1)+"\"}");
                addComma = true;
            }
        }
        else if(type.equals("payment_method")){

            Set rs = Etn.execute("select method, displayName from payment_methods where site_id = "+escape.cote(selectedsiteid) + " AND displayName LIKE " + escape.cote(term) );

            while(rs.next()){

                if(addComma) out.write(",");

                out.write("{\"id\":\""+rs.value(0)+"\",\"value\":\""+rs.value(1)+"\"}");
                addComma = true;
            }
        }

        out.write("]");

%>