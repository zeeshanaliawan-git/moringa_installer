<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, org.json.JSONObject, org.json.JSONArray"%>
<%@ include file="../../WEB-INF/include/commonMethod.jsp"%>
<%
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    String q = "";
    Set rs = null;

    String COMMONS_DB = GlobalParm.getParm("COMMONS_DB");
    String siteId = getSelectedSiteId(session);

    try{

     	String requestType = parseNull(request.getParameter("requestType"));
        if("search".equalsIgnoreCase(requestType)){
            try{
		     	int langId = parseInt(request.getParameter("langId"));
                String searchTerm = parseNull(request.getParameter("searchTerm"));
		     	String fullUrl = parseNull(request.getParameter("fullUrl"));

		        JSONArray urlList = new JSONArray();
		        JSONObject curUrl = null;

                String selectClause = " CONCAT(name,' : ',page_path) AS label ";
                if(langId <= 0){
                	//no lang specified
                    selectClause = " CONCAT(name,' (', langue_code ,'): ',page_path) AS label ";
                }

		        if("1".equals(fullUrl)){
		        	selectClause += " , internal_prod_url AS value";
		        }
                else{
                    selectClause += " , page_path AS value";
                }

		        q = " SELECT " + selectClause
		        	//+ " , content_type"//debug
		        	+ " FROM "+ COMMONS_DB + ".content_urls "
		            + " WHERE content_type <> 'file' and site_id = " + escape.cote(siteId);

		        if(langId > 0){
		        	q += " AND langue_id = " + escape.cote(""+langId);
		        }

		        if(searchTerm.length() > 0){
		        	searchTerm = "%"+searchTerm+"%";
		        	q += " AND ( name LIKE " + escape.cote(searchTerm)
		        		+ " OR page_path LIKE " + escape.cote(searchTerm)
		        		+ " ) ";
		        }

                //for files , langue_id filter does not apply for file type
                q += " UNION ALL  SELECT CONCAT(name,' : ',page_path) AS label, page_path AS value  "
                    + " FROM "+ COMMONS_DB + ".content_urls "
                    + " WHERE content_type = 'file' "
                    + " AND site_id = " + escape.cote(siteId);
                if(searchTerm.length() > 0){
                    q += " AND ( name LIKE " + escape.cote(searchTerm)
                        + " OR page_path LIKE " + escape.cote(searchTerm)
                        + " ) ";
                }

		        q += " ORDER BY label, value ";

                //Logger.debug(q);
		        rs = Etn.execute(q);

		        while(rs.next()){
		            curUrl = new JSONObject();
		            for(String colName : rs.ColName){
		                curUrl.put(colName.toLowerCase(), rs.value(colName));
		            }
		            urlList.put(curUrl);
		        }

		        data.put("urls",urlList);
		        status = STATUS_SUCCESS;
	        }//try
            catch(Exception ex){
                throw new SimpleException("Error in searching url. Please try again.",ex);
            }
        }
        else if("validate".equalsIgnoreCase(requestType)){
            try{
		     	String url = parseNull(request.getParameter("url"));
		     	int langId = parseInt(request.getParameter("langId"));
		     	String fullUrl = parseNull(request.getParameter("fullUrl"));

		        q = " SELECT 1 FROM "+ COMMONS_DB + ".content_urls "
		            + " WHERE ( site_id = " + escape.cote(siteId);

		        if(langId > 0){
		        	q += " AND langue_id = " + escape.cote(""+langId);
		        }

		        if(!"1".equals(fullUrl)){
		        	q += " AND page_path = " + escape.cote(url);
		        }
		        else{
		        	q += " AND internal_prod_url = " + escape.cote(url);
		        }

                q += " ) ";

                //for file type langue_id does not apply
                q += "OR ( content_type = 'file' AND site_id = " + escape.cote(siteId)
                    + " AND page_path = " + escape.cote(url) + ")";

                //Logger.debug(q);
		        rs = Etn.execute(q);
		        boolean isValid = false;
		        if(rs.next()){
		        	isValid = true;
		        }

		        data.put("isValid",isValid);
		        status = STATUS_SUCCESS;
	        }//try
            catch(Exception ex){
                throw new SimpleException("Error in validating url. Please try again.",ex);
            }
        }

    }//try
    catch(SimpleException ex){
        message = ex.getMessage();
        ex.print();
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
    out.write(jsonResponse.toString());
%>
