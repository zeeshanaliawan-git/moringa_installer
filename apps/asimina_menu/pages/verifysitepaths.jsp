<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, java.util.Map, java.util.LinkedHashMap, com.etn.beans.app.GlobalParm, org.json.JSONObject"%>
<%@ include file="common.jsp"%>
<%!
	String getSiteDomain(com.etn.beans.Contexte Etn, String siteid)
	{
		Set rs = Etn.execute("select * from sites where id = " + escape.cote(siteid));
		rs.next();
		return formatSiteDomain(rs.value("domain"));
	}

	String formatSiteDomain(String siteDomain){
		String domain = parseNull(siteDomain).toLowerCase();
		domain = domain.replace("https://","").replace("http://","");
		if(domain.indexOf("/") > -1) domain = domain.substring(0, domain.indexOf("/"));

		return domain;
	}
%>
<%


    int status = 0;  //0=error, 1=success, 2=warning
    String message = "";

    try{

		String siteId = getSiteId(session);
		String siteDomain = parseNull(request.getParameter("siteDomain"));
		String prodPaths = parseNull(request.getParameter("prodPaths"));

		String formattedSiteDomain = formatSiteDomain(siteDomain);

	    String[] prodPathList = prodPaths.split(",");

    	//check if empty , else format the path
    	for (int i=0; i<prodPathList.length; i++ ) {
    		String prodPath = parseNull(prodPathList[i]).toLowerCase();
    		if(prodPath.length() == 0){
    			status = 0;
    			throw new Exception("Prod path cannot be empty");
    		}
    		else{
    			if(prodPath.startsWith("/")){
    				prodPath = prodPath.substring(1);
    			}

    			if(!prodPath.endsWith("/")) {
    				prodPath = prodPath + "/";
    			}
    		}
    		prodPathList[i] = prodPath;
    	}

    	for (int i=0; i<prodPathList.length; i++ ) {
    		String curProdPath = parseNull(prodPathList[i]);

            //compare each prod path to every other prod path for substring startWith
    		for (int j=0; i!=j && j<prodPathList.length; j++ ) {

    			if( prodPathList[j].startsWith(curProdPath) ){
    				status = 0;
    				throw new Exception("Prod path conflict. Different languages of site cannot share production paths.");
    			}
    		}

    		String q = " SELECT s.id, s.name, s.domain, sd.production_path, sd.langue_id , l.langue_code, l.langue "
    			+ " FROM sites s JOIN sites_details sd ON s.id = sd.site_id "
    			+ " JOIN language l ON l.langue_id = sd.langue_id "
    			+ " WHERE s.id != " + escape.cote(siteId)
    			+ " AND (  sd.production_path LIKE " + escape.cote(curProdPath+"%")+""
                + "     OR " + escape.cote(curProdPath)+" LIKE IF(TRIM(sd.production_path) != '', CONCAT( sd.production_path, '%' ), '') )";
            //Logger.info(q);
    		Set rs = Etn.execute(q);
    		while(rs.next()){
    			String conflictedSiteDomain = formatSiteDomain(rs.value("domain"));
    			if( formattedSiteDomain.equals(conflictedSiteDomain) ){
    				status = 0;
    				throw new Exception("Path conflict. Production path : "+curProdPath+" is conflicting with Site : "+rs.value("name")+" for language : "+rs.value("langue")+". Sites with same domain cannot share paths");
    			}
    		}

    	}

    	status = 1;
    	message = "";

    }
    catch(Exception ex){
    	status = 0;
    	message = ex.getMessage();
    	ex.printStackTrace();
    }

    JSONObject retObj = new JSONObject();
    retObj.put("status", status);
    retObj.put("message", message);

    out.write(retObj.toString());

%>