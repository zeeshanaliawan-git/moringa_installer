<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, java.util.Map, java.util.LinkedHashMap"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%

    String selectedsiteid = "";
    Set rs = Etn.execute("select coalesce(selected_site_id,'') as selected_site_id from "+GlobalParm.getParm("COMMONS_DB")+".user_sessions where catalog_session_id = " + escape.cote(""+request.getSession().getId()));
    if(rs.next()) selectedsiteid = rs.value("selected_site_id");
    if(selectedsiteid.length() == 0)
    {
        response.sendRedirect(request.getContextPath() + "/admin/gestion.jsp?err=1");
        return;
    }


    String token = com.etn.asimina.util.UIHelper.getWebappAuthToken(Etn, request);
	
    String url = parseNull(request.getParameter("_url"));
    if(url.length() == 0)
    {
        response.sendRedirect(request.getContextPath() + "/admin/gestion.jsp");
        return;
    }
%>
<html>
<body>
    <form name='afrm' method='post' action='<%=url%>'>
        <input type='hidden' name='__wt' value='<%=token%>' />
    </form>
</body>
<script>
    document.afrm.submit();
</script>
</html>
