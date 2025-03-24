<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set,  com.etn.pages.PagesUtil, org.json.JSONObject, org.json.JSONArray, java.util.LinkedHashMap"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%
    /**
    * for  "catalog" table in "catalog" databse module
    **/
    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();

    String q = "";
    Set rs = null;
    int count = 0;

    String requestType = parseNull(request.getParameter("requestType"));

	try{
		String siteId = getSiteId(session);
        String CATALOG_DB = GlobalParm.getParm("CATALOG_DB");
	    if("getCatalogsList".equalsIgnoreCase(requestType)){
	    	try{

	    		JSONArray retList = new JSONArray();

				q = " SELECT c.id, c.catalog_uuid AS uuid, c.name, c.catalog_type "
	                + " FROM "+CATALOG_DB+".catalogs c"
                    + " WHERE c.site_id = " + escape.cote(siteId)
                    + " ORDER BY c.name ASC";
				rs = Etn.execute(q);
				while(rs.next()){
					JSONObject curObj = new JSONObject();
					for(String colName : rs.ColName){
						curObj.put(colName.toLowerCase(), rs.value(colName));
					}

					retList.put(curObj);
				}

				data.put("catalogs",retList);
				status = STATUS_SUCCESS;

	    	}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in getting catalogs list. Please try again.",ex);
	    	}
	    }
	    else if("test".equalsIgnoreCase(requestType)){
	    	try{

			}//try
	    	catch(Exception ex){
				throw new SimpleException("Error in testing.",ex);
	    	}
	    }
        else{
            message = "Invalid params";
        }

    }
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
