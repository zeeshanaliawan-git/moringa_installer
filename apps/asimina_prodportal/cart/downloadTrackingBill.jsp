<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>

<%
	String doc=request.getParameter("doc");
	String id=request.getParameter("id");
		
	Set rs = Etn.execute("Select id, site_id from "+GlobalParm.getParm("SHOP_DB")+".orders where parent_uuid = "+escape.cote(id));
	if(rs.next())
	{
		Set rsC = Etn.execute("select * from sites_config where site_id = "+escape.cote(rs.value("site_id"))+" and code = 'invoice_url' ");
		if(rsC.next())
		{
			//we will always send order uuid as parameter uid to customized invoice link
			response.sendRedirect(rsC.value("val")+"?uid="+id);
			return;
		}
	}
	
	String _jsp = "/cart/defaultDownloadBill.jsp?id="+id+"&doc="+doc;
	request.getRequestDispatcher(_jsp).forward(request,response);
%>
