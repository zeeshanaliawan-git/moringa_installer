<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.*"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.util.Base64"%>

<%!
	String parseNull(Object o) 
	{
		if( o == null )
			return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase()))
			return("");
		else
			return(s.trim());
	}
%>
<%

String ip = com.etn.asimina.util.PortalHelper.getIP(request);
com.etn.util.Logger.info("stats.jsp", "IP : " + ip);
if(com.etn.asimina.util.RobotHelper.getInstance().excludeIpForStats(ip) == false)
{
String a = request.getParameter("a");
String ua = request.getHeader("user-agent");
String _cookie = request.getHeader("cookie");
String screen_width = request.getParameter("screen_width");
String screen_height = request.getParameter("screen_height");
String location_href=request.getParameter("l_href");
String eletype=parseNull(request.getParameter("eletype"));
String eleid=parseNull(request.getParameter("eleid"));
String ctype=parseNull(request.getParameter("ctype"));
String scpageid=parseNull(request.getParameter("scpageid"));
String suid=parseNull(request.getParameter("suid"));
String lang=parseNull(request.getParameter("lang"));
String ref=request.getParameter("ref");


String ourl=request.getParameter("ourl");
String dataflag = parseNull(request.getParameter("df"));
if(dataflag.length() == 0) dataflag = "1";

if(ourl != null && ourl.trim().length() > 0)
{
	try
	{
		ourl = new String(Base64.decode(ourl));
	}
	catch(Exception e) { e.printStackTrace(); }
}

String muid=request.getParameter("muid");

if(session.getAttribute("all_menus") == null)
{

	Set _rs = Etn.execute("select * from site_menus ");
	java.util.Map<String, String> menus = new java.util.HashMap<String, String>();
	while(_rs.next())
	{
		menus.put(_rs.value("menu_uuid"), _rs.value("id"));
	}

	//we dont need to set this to asimina web session as if next time this param is not found in tomcat session it will be populated
	//again so it makes no difference
	session.setAttribute("all_menus", menus);
}

String menuid = ((java.util.Map<String, String>)session.getAttribute("all_menus")).get(muid);
String session_j = com.etn.asimina.session.PortalSession.getInstance().addParameter(Etn, request, response, "MENU_ID_LOADED", menuid);	


String document_title=request.getParameter("document_title");

	String browserSession_j = "";
	String cookietoken = "";
	Cookie[] _cookies = request.getCookies();
	if(_cookies != null) 
	{
       	for (Cookie cookie : _cookies) 
		{ 
			//System.out.println(cookie.getName());            
			if(cookie.getName().equals("_page_token")) cookietoken = cookie.getValue();
			else if(cookie.getName().equalsIgnoreCase("JSESSIONID")) browserSession_j = cookie.getValue();
		}
	}

System.out.println("**********************************************************");
System.out.println("session Id "+session.getId());
System.out.println("Asimina session Id "+session_j);
System.out.println("Browser session Id "+browserSession_j);
System.out.println("**********************************************************");

//System.out.println("ourl : " + request.getParameter("ourl"));
//System.out.println("cookietoken : " + cookietoken);
if(!parseNull(request.getParameter("ourl")).replace("=","").equals(cookietoken.replace("=","")))
{
	System.out.println("MAJOR-ERROR::Stats csrf token not match");
	response.setStatus(javax.servlet.http.HttpServletResponse.SC_FORBIDDEN);	
	return;
}

long currentDateTime = System.currentTimeMillis();
java.util.Date currentDate = new java.util.Date(currentDateTime);
java.text.DateFormat df = new java.text.SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
String tm=df.format(currentDate);

String siteId = "";
Set rsSite = Etn.execute("select id from sites where suid="+escape.cote(suid));
if(rsSite.next()){
	siteId=parseNull(rsSite.value("id"));
}

String sql="insert ignore into stat_log(browser_session_id, date_l,ip,session_j,user_agent,screen_width,screen_height,page_c,page_ref, url, menu_uuid, document_title, has_internet,site_id)";
sql+=" values("+escape.cote(browserSession_j)+", now(),"+escape.cote(ip)+","+escape.cote(session_j)+","+escape.cote(ua)+","+escape.cote(screen_width)+","+escape.cote(screen_height);
sql += ","+escape.cote(location_href)+","+escape.cote(ref)+","+escape.cote(ourl)+","+escape.cote(muid)+", "+escape.cote(document_title)+","+escape.cote(dataflag)+","+escape.cote(siteId)+")";
Etn.executeCmd(sql);


if(eletype.equalsIgnoreCase("commercialcatalog") && ctype.length() > 0){
	eletype = "product";
}else if(eletype.equalsIgnoreCase("structuredcatalog")){
	eleid = scpageid;
}

Etn.executeCmd("Insert into stat_log_page_info (page_c,title,eletype,eleid,site_uuid,lang) values (TRIM(trailing '#' FROM "+escape.cote(location_href)+"),"+
	escape.cote(document_title)+","+escape.cote(eletype)+","+escape.cote(eleid)+","+escape.cote(suid)+","+escape.cote(lang)+") on duplicate key update title="+
	escape.cote(document_title)+",eletype="+escape.cote(eletype)+",eleid="+escape.cote(eleid)+",lang="+escape.cote(lang));


Etn.executeCmd("insert into stat_log_page_ref (id,page_c,page_ref,site_id) values ( SHA2( CONCAT( TRIM(trailing '#' from "+escape.cote(location_href)+"),"+
	escape.cote(ref)+"),256),TRIM(trailing '#' FROM "+escape.cote(location_href)+"),"+escape.cote(ref)+","+escape.cote(siteId)+") on duplicate key update page_c=TRIM(trailing '#' FROM "+escape.cote(location_href)+"),page_ref="+escape.cote(ref));
}
else
{
	com.etn.util.Logger.info("stats.jsp", "IP is of a robot. We are not adding this to stat log table");
}
%>
{"status":0}