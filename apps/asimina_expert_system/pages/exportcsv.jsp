<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.asimina.util.CommonHelper"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map, java.util.ArrayList"%>
<%@ include file="/WEB-INF/include/queryToJson.jsp" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%
	String jsonid = parseNull(request.getParameter("jsonid"));
	String tag = parseNull(request.getParameter("tag"));
	String showallcols = parseNull(request.getParameter("showallcols"));
	boolean hidecols = true;
	if(showallcols.equals("1")) hidecols = false;

	Set rs = Etn.execute("select * from expert_system_queries where json_id = " + escape.cote(jsonid) + " order by id ");

	HashMap<String,Integer> queryDescriptions = new HashMap<String, Integer>();
	int i = 1;
	String q = "";
	String queryid = "";
	while(rs.next())
	{
		String jsontag = getJsonObjectName(queryDescriptions, parseNull(rs.value("description")), i, parseNull(rs.value("query_type")));
		System.out.println("--------- " + jsontag);
		if(jsontag.equals(tag)) 
		{
			queryid = parseNull(rs.value("id"));
			q = parseNull(rs.value("query"));
			break;
		}
		i ++;
	}

	if(queryid.length() > 0)
	{
		//get query params from request
		Map<String, String> queryParams = new HashMap<String, String>();
		Set rs1 = Etn.execute("select * from expert_system_query_params where json_id = "+escape.cote(jsonid)+" and query_id = " + escape.cote(queryid));
		while(rs1.next())
		{
			queryParams.put(parseNull(rs1.value("param")), parseNull(request.getParameter(rs1.value("param"))));
		}

		q = " " + q + " ";
		for(String param : queryParams.keySet())
		{
			if(q.indexOf("@"+param) < 0) continue;

			String val = queryParams.get(param);
			if(val != null) val = val.trim();
			
			String t = (q.substring(0, q.lastIndexOf("@"+param))).toLowerCase();
			boolean itsCondition = false;

			if(t.indexOf("and") > -1) 
			{
				t = t.substring(t.lastIndexOf("and") + 3).trim();
				itsCondition = true;
			}
			else if(t.indexOf("where") > -1)
			{
				t = t.substring(t.lastIndexOf("where") + 5).trim();
				itsCondition = true;
			}
			if(itsCondition)
			{
				if(t.indexOf("=") > -1 || t.indexOf(" like ") > -1) //its an equi join
				val = escape.cote(val);
				else //we consider its an inclause in which the incoming data will be comma separated and we have to enclose each separately in single qoutes
				{
					String[] ts = val.split(",");
					val = "";
					for(int h=0; h<ts.length; h++)
					{ 
						if(h>0) val += ",";
						val += escape.cote(ts[h].trim());
					}
				}		
			}
			else val = escape.cote(val);

			//for inclause in query we need to send the values in single qoutes already otherwise escape.cote will create problem
			if(!val.startsWith("'") && !val.endsWith("'")) val = escape.cote(val); 
				
			//space added for exact match
			q = q.replace("@"+param + " ", " "+val+" ");
		}

		rs = Etn.execute(q);		

		ArrayList<String> hiddencols = new ArrayList<String>();
		if(hidecols)
		{
			Set rs2 = Etn.execute("select * from expert_system_script where show_col = 0 and json_id = "+escape.cote(jsonid)+" and parent_json_tag = " + escape.cote(tag + ".data[*]"));
			while(rs2.next()) hiddencols.add(rs2.value("json_tag"));
		}
		
		response.setCharacterEncoding("windows-1252");
		response.setContentType("APPLICATION/OCTET-STREAM"); 
		response.addHeader("Content-Disposition","attachment; filename="+ CommonHelper.escapeCoteValue(tag)+".csv");
		response.setHeader("Cache-Control", "private");
		response.setHeader("Pragma", "private");

		String sep = ";";
		for(i=0;i< rs.Cols; i++) 
		{
			if(hidecols && hiddencols.contains("EXPSYS_SPECIAL_COL_" + i) ) continue;
			out.write("\"" + rs.ColName[i] + "\"" + sep);
		}
	
		while(rs.next())
		{	
			out.write("\n");
			for(i=0; i< rs.Cols; i++) 
			{
				if(hidecols && hiddencols.contains("EXPSYS_SPECIAL_COL_" + i) ) continue;
				out.write("\"" + rs.value(i) + "\"" + sep);
			}
		}

	}
	else out.write("No query found for json id : " + CommonHelper.escapeCoteValue(jsonid) + ", tag : " + CommonHelper.escapeCoteValue(tag));
%>