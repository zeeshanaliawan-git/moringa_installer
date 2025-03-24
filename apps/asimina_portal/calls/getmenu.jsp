<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.Contexte, org.json.*"%>
<%@ page import="org.json.JSONArray,org.json.JSONObject"%>

<%!
    String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
    
    void writeJSON(HttpServletResponse response,String json) throws java.io.IOException{
		response.setStatus(HttpServletResponse.SC_OK);
        response.setContentType("application/json");
		response.getWriter().write(json);
		response.getWriter().flush();
		response.getWriter().close();		
	}
%>

<%
    String menuId = parseNull(request.getParameter("menuId"));
	Etn.setSeparateur(2, '\001', '\002');
    Set rs = Etn.execute("select h.header_html from site_menus m, site_menu_htmls h where m.id = h.menu_id and m.menu_uuid = " + escape.cote(menuId));
    JSONObject menu = new JSONObject();
    if(rs != null && rs.next()){
        menu.put("header",rs.value("header_html"));
    }
    writeJSON(response,menu.toString());
%>