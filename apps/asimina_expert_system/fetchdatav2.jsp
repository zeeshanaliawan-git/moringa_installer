<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@page import="com.etn.lang.ResultSet.Set"%>
<%@include file="common.jsp"%>
<%@page import="com.etn.sql.escape, com.etn.util.ItsDate, com.etn.util.*, com.etn.beans.app.GlobalParm,com.etn.util.Base64"%>
<%@page import="java.io.*"%>

<%!

    public Map<String, String> getHeadersInfo(HttpServletRequest request) {

        Map<String, String> map = new HashMap<String, String>();

        Enumeration headerNames = request.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String key = (String) headerNames.nextElement();
            String value = request.getHeader(key);
            map.put(key, value);
        }

        return map;
    }

%>

<%
    String env = parseNull(request.getParameter("env"));
	
	Map<String, String> dbs = new HashMap<String, String>();
	if("T".equals(env))//call is from test site
	{
		com.etn.util.Logger.info("fetchdatav2.jsp","Call is from test environment so we will use test site dbs");
		//in products query we have catalog_db and preprod_catalog_db reference .. when admin mode these both 
		//will be same but in public mode it will be different
		dbs.put("preprod_catalog_db", com.etn.beans.app.GlobalParm.getParm("PREPROD_CATALOG_DB"));
		dbs.put("catalog_db", com.etn.beans.app.GlobalParm.getParm("PREPROD_CATALOG_DB"));
		dbs.put("portal_db", com.etn.beans.app.GlobalParm.getParm("PREPROD_PORTAL_DB"));
		dbs.put("shop_db", com.etn.beans.app.GlobalParm.getParm("PREPROD_SHOP_DB"));		
	}
	else
	{
		dbs.put("preprod_catalog_db", com.etn.beans.app.GlobalParm.getParm("PREPROD_CATALOG_DB"));
		dbs.put("catalog_db", com.etn.beans.app.GlobalParm.getParm("PROD_CATALOG_DB"));
		dbs.put("portal_db", com.etn.beans.app.GlobalParm.getParm("PROD_PORTAL_DB"));
		dbs.put("shop_db", com.etn.beans.app.GlobalParm.getParm("PROD_SHOP_DB"));
	}

    String qsuuid = parseNull(request.getParameter("qid"));
    String suid = parseNull(request.getParameter("suid"));
    String queryid = parseNull(request.getParameter("cid"));
	if(suid.length() > 0 && queryid.length() > 0)
	{
		qsuuid = "";
		Set _rs = Etn.execute("Select * from "+dbs.get("portal_db")+".sites where suid = "+escape.cote(suid));
		if(_rs.next())
		{
			Set _rs1 = Etn.execute("select * from query_settings where site_id = "+escape.cote(_rs.value("id"))+" and query_id = "+escape.cote(queryid));
			if(_rs1.next()) qsuuid = _rs1.value("qs_uuid");
		}
	}
	
    Set rs = Etn.execute("select qs.*, COALESCE((select name from es_queries esq where esq.id = qs.query_sub_type_id), 'forms') as query_category from query_settings_published qs where qs.qs_uuid = "+escape.cote(qsuuid));

    if(rs.next()){

	    String siteid = parseNull(rs.value("site_id"));

	    if(rs.value("access").equals("private")){

	        Map<String, String> headerInfo = getHeadersInfo(request);

	    	String queryKey = parseNull(headerInfo.get("key"));
	
			if(queryKey.length() == 0)
			{

				out.write("{\"msg\":\"Key is missing in header\"}");		
				return;
			}
    
	    	if(!queryKey.equals(rs.value("query_key"))){

				out.write("{\"message\":\"Key is not valid.\"}");
				return;
	    	}
		}

		Map<String, String[]> parameters = request.getParameterMap();
		Map<String, List<String>> whereClauseParameterMap = new HashMap<String, List<String>>();
		List<String> list;

		JSONArray filterSettings = new JSONArray(rs.value("filter_settings"));

		String filterValue = "";
		String filterColumn = "";
		String pageNo = parseNull(request.getParameter("pageNo"));

		for(int i=0; i < filterSettings.length(); i++){

			JSONObject filterJsonObject = (JSONObject) filterSettings.get(i);

			filterValue = filterJsonObject.get("filter_value").toString();
			filterColumn = filterJsonObject.get("filter_column_name").toString();

			if(filterJsonObject.get("is_variable").equals("1")){

				for(String parameter : parameters.keySet()) {

					for(int z=0; z<parameters.get(parameter).length; z++){

						if(filterJsonObject.get("filter_column_name").equals(parameter)){

							if(whereClauseParameterMap.containsKey(parameter)){

								list = whereClauseParameterMap.get(parameter);
								list.add(escape.cote(parseNull(parameters.get(parameter)[z])));

							} else {

								list = new ArrayList<String>();
								list.add(escape.cote(parseNull(parameters.get(parameter)[z])));
								whereClauseParameterMap.put(parameter, list);
							}
	
						}
					}
				}

				if(!whereClauseParameterMap.containsKey(filterJsonObject.get("filter_column_name").toString())){

					list = new ArrayList<String>();
					list.add("''");
					whereClauseParameterMap.put(filterJsonObject.get("filter_column_name").toString(), list);
				}
			}
		}

		try{

		    out.write(getJSONPlainStructureFromQuery(whereClauseParameterMap, Etn, siteid, qsuuid, pageNo, dbs, true));

		} catch(Exception e){
			e.printStackTrace();
		}

	} else {

		out.write("{\"message\":\"Id is not valid.\"}");
	}

%>