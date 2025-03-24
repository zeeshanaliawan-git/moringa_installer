<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>


<% response.setHeader("X-Frame-Options","deny"); %>

<%@ include file="common.jsp"%>
<%@ include file="common2.jsp"%>

<%!
	String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	String getDomain(String url)
	{
		String domain = url;
		if(domain.toLowerCase().indexOf("https://") > -1) domain = domain.substring(domain.toLowerCase().indexOf("https:") + 8);
		else if(domain.toLowerCase().indexOf("http://") > -1) domain = domain.substring(domain.toLowerCase().indexOf("http:") + 7);

		if(domain.indexOf("/") > -1) domain = domain.substring(0, domain.indexOf("/"));
		return domain.trim();
	}

%>
<%
	String accessid = parseNull(request.getParameter("auid"));
	String clientid = parseNull(request.getParameter("cid"));
	String puid = parseNull(request.getParameter("puid"));
	String muid = parseNull(request.getParameter("muid"));
	String selecteddate = parseNull(request.getParameter("sltd"));


	Set rs = Etn.execute("select * from clients where coalesce(is_super_user,0) = 1 and client_uuid = " + escape.cote(accessid));
	if(rs == null || rs.rs.Rows == 0) 
	{
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_PERMANENTLY);
		response.setHeader("Location", "suunathorized.html");
		return;
	}	
	rs.next();

	//Etn.executeCmd("update clients set client_uuid = '' where id = " + escape.cote(rs.value("id")));

	Set rsm = Etn.execute("select m.*, s.name as sitename from site_menus m, sites s where s.id = m.site_id and m.menu_uuid = " + escape.cote(muid));
	if(rsm == null || rsm.rs.Rows == 0) 
	{
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_PERMANENTLY);
		response.setHeader("Location", "suunathorized.html");
		return;
	}
	rsm.next();

	Set rscli = Etn.execute("select * from clients where coalesce(is_super_user,0) = 0 and id = " + clientid);
	if(rscli == null || rscli.rs.Rows == 0) 
	{
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_PERMANENTLY);
		response.setHeader("Location", "suunathorized.html");
		return;
	}
	rscli.next();

	String catalogdb = GlobalParm.getParm("CATALOG_DB");

	Set rsp = Etn.execute("select * from "+catalogdb+".products where product_uuid = " + escape.cote(puid));
	if(rsp == null || rsp.rs.Rows == 0) 
	{
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_PERMANENTLY);
		response.setHeader("Location", "suunathorized.html");
		return;
	}
	rsp.next();

	Set rsc = Etn.execute("select * from cached_pages where is_url_active = 1 and menu_id = " +escape.cote(rsm.value("id")) + " and url like " + escape.cote("%/product.jsp?%cat="+rsp.value("catalog_id")+"&%&id="+rsp.value("id")));	
	if(rsc == null || rsc.rs.Rows == 0) 
	{
		response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_PERMANENTLY);
		response.setHeader("Location", "suerror.html");
		return;
	}
	rsc.next();
	
	String sendredirectlink = GlobalParm.getParm("SEND_REDIRECT_LINK");
	String sitefolder = getSiteFolderName(rsm.value("sitename"));	
	String domain = getDomain(rsc.value("url"));
	String localpath = getLocalPath(Etn, rsc.value("url"));


	session.setAttribute("login_muid", muid);

	session.setAttribute("su_login", rs.value("username"));
	session.setAttribute("su_login_email", rs.value("email"));
	session.setAttribute("su_client_id", rs.value("id"));
	session.setAttribute("su_client_site_id", rs.value("site_id"));
	session.setAttribute("su_profil", "super_user");			

	session.setAttribute("login", rscli.value("username"));
	session.setAttribute("login_email", rscli.value("email"));
	session.setAttribute("client_id", rscli.value("id"));
	session.setAttribute("client_site_id", rs.value("site_id"));
	session.setAttribute("profil", "logged_in_user");

	String _path =  sendredirectlink + sitefolder + "/" + getFolderId(Etn, domain)  + localpath + java.net.URLEncoder.encode(rsc.value("filename"), "utf-8");
	response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
	response.setHeader("X-Frame-Options","deny");
	response.setHeader("Location", _path);


%>

