<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.io.*, com.etn.util.Logger "%>
<%@ page import="com.etn.pages.PagesGenerator"%>


<%!
    String parseNull(Object o) {
        if (o == null) {
            return ("");
        }
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        }
        else {
            return (s.trim());
        }
    }

%>
<%
	/*
	* This jsp is called from portal engine Crawler.java
	* Purpose of this jsp to load the content of page on the disk, apply template to it
	* And return back to Crawler.java which will then recache the generated/published html of the page
	*/

	
	String ip = com.etn.asimina.util.ActivityLog.getIP(request);
	
	if("127.0.0.1".equals(ip) || "localhost".equalsIgnoreCase(ip))
	{
		String pageid = parseNull(request.getParameter("pageid"));
		boolean forProdSite = "1".equals(parseNull(request.getParameter("isprod")));
		
		Logger.info("regeneratepage.jsp","Page ID : " +pageid + " for Prod : "+forProdSite);
		
		String qry = "select * from pages where id = " + escape.cote(pageid);
		if(forProdSite) qry += " and publish_status = 'published' ";//for prod site we just pick published pages
		
		Set rs = Etn.execute(qry);
		if(!rs.next())
		{
			Logger.error("regeneratepage.jsp","Page not found in the database. Page ID : " +pageid);
			response.setStatus( 404 );
			return;
		}
		PagesGenerator pagesGen = new PagesGenerator(Etn);
		boolean generated = pagesGen.regenerateForCache(pageid, forProdSite);
		Logger.info("regeneratepage.jsp","generated:"+generated);
		out.write("regeneratepage.jsp::Page ID:" +pageid + " for-Prod:"+forProdSite+" is-regenerated:"+generated);
	}
	else 
	{
		Logger.error("regeneratepage.jsp","This page cannot be access from external IP");
		response.setStatus( 403 );
	}
%>