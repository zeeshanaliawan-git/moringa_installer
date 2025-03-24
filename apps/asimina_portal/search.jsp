<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ include file="common2.jsp" %>
<%@ include file="lib_msg.jsp" %>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, com.etn.util.Base64"%>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.util.*" %>

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


	private String searchWordHighlight(String value, String word, String color){

		StringBuffer output = new StringBuffer("");
		int wordIndex = value.toLowerCase().indexOf(word.toLowerCase());

		if(wordIndex != -1){

			output.append(value.substring(0,wordIndex));
			output.append("<span style=\"color: "+color+"; font-weight: bold;\">");
			output.append(value.substring(wordIndex,wordIndex+word.length()));
			output.append("</span>");
			output.append(value.substring(wordIndex+word.length(),value.length()));
		}else{

			output.append(value);
		}

		return output.toString();
	}

%>
<%
	String _error_msg = "Some error occurred while processing search";
	//this is used in headerfooter.jsp and logofooter.jsp
	String __pageTemplateType = "default";
	
%>
<%@ include file="headerfooter.jsp"%>
<%
	

	String ___q = parseNull(request.getParameter("q"));
	String searchLink = "";
	HashMap<String, HashMap<String, String>> searchWordMap = new HashMap<String, HashMap<String, String>>();
	HashMap<String, String> dataMap = new HashMap<String, String>();
	Process searchStringProcess;

	try {
	    
	    String siteName = "";
	    String siteNameQuery = "SELECT s.name as sitename FROM site_menus sm, sites s " + 
							"WHERE sm.site_id = s.id AND sm.is_active = 1 AND sm.menu_uuid = "+escape.cote(___muuid);

	    Set siteNameRs = Etn.execute(siteNameQuery);

	    if(siteNameRs != null && siteNameRs.next())
	    	siteName = siteNameRs.value("sitename");

        String sitefolder = getSiteFolderName(siteName);
        String basedir = com.etn.beans.app.GlobalParm.getParm("BASE_DIR") + com.etn.beans.app.GlobalParm.getParm("DOWNLOAD_PAGES_FOLDER");		
        searchLink = getMenuPath(Etn, _menuid);

        if(!basedir.trim().endsWith("/")) 
        	basedir = basedir + "/";
        
        basedir += sitefolder + "/" + _lang + "/";

		String path = basedir;
		String word = ___q;
		String charLimit = "100";
		String dir = com.etn.beans.app.GlobalParm.getParm("PORTAL_SEARCH_SHELL_SCRIPT")+"search.sh ";
		String runBash = "/bin/sh "+dir+path+" "+word+" "+charLimit;
		
		searchStringProcess = Runtime.getRuntime().exec(runBash);

		int errCode = searchStringProcess.waitFor();
		String line = "";
		String key = "", value = "", title = "";
		System.out.println("Echo command executed, any errors? " + (errCode == 0 ? "No" : "Yes")+" "+ errCode);
		
		BufferedReader searchStringReader = new BufferedReader(new InputStreamReader(searchStringProcess.getInputStream()));
		

		while ((line = searchStringReader.readLine())!= null) {
			key = line.substring(0,line.indexOf(".html|"))+".html";
			value = line.substring(line.indexOf(".html|")+6, line.indexOf("__t|"));
			title = "<b>"+line.substring(line.indexOf("__t|")+4, line.length())+"</b>";

			dataMap.put(key+"value",searchWordHighlight(value, word, "#777"));
			dataMap.put(key+"title",searchWordHighlight(title,word, "#ff6600"));

			searchWordMap.put(key, dataMap);

		}

	} catch (Exception e) {
		e.printStackTrace();
	}

%>
<!doctype html>
<html lang="<%=_lang%>" dir="<%=langDirection%>">
<head>	
<%=_headhtml%>
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/boosted.min.css">
	<link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>menu_resources/css/orangeHelvetica.min.css">
    <link rel="stylesheet" href="<%=com.etn.beans.app.GlobalParm.getParm("EXTERNAL_LINK")%>css/style.css">
<style>
  
  .etn-orange-portal-- table.results tr td{
    padding: 15px;
  }
</style>

</head>
<body>

<%=_headerHtml%>
<div class="PageTitle"> 
   <div class="container"> 
    <h1><%=libelle_msg(Etn, request, "Search Results")%> (<%=searchWordMap.size()%>)</h1>
   </div> 
</div> 
<div class="container etn-orange-portal--">	
	<table class="table table-hover results">
	<%
		for( String name : searchWordMap.keySet() ){
	%>
		  	<tr class="row">
		  		<td>
		  			<a style="text-decoration: none;color:#666; outline:none !important" href="<%=searchLink+name.toString()%>" > <%=searchWordMap.get(name).get(name+"title").toString()%> <br/>
		  			<span><%=searchWordMap.get(name).get(name+"value").toString()%></span>
					</a>

		  		</td>
		  	</tr>
	<%
		}

		if(searchWordMap.size() ==0){
	%>
			<tr>
				<td><%=libelle_msg(Etn, request, "Keyword not Found(s).")%></td>
			</tr>
	<%
		}
	%>
	</table>
	
</div>

 <%=_footerHtml%>

 <%=_endscriptshtml%>
</body>
</html>