<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.lang.ResultSet.Xdr2Json"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="java.io.ByteArrayOutputStream"%>
<%@ page import="java.io.OutputStream"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>


<%!
	String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	String getJsonObjectName(HashMap<String,Integer> queryDescriptions, String qryDescription, int qrySeq, String qryType)
	{
		qryDescription = parseNull(qryDescription).replaceAll(" ","_");
		if(qryDescription.length() == 0) 
		{
			if(parseNull(qryType).equals("d3")) return "d3json_result_qry_"+qrySeq;
			else if(parseNull(qryType).equals("d3map")) return "d3mapjson_result_qry_"+qrySeq;
			else if(parseNull(qryType).equals("d3mapchl")) return "d3mapchljson_result_qry_"+qrySeq;
			else if(parseNull(qryType).equals("c3")) return "c3json_result_qry_"+qrySeq;
			return "result_qry_" + qrySeq;
		}
		else if(queryDescriptions.get(qryDescription.toLowerCase()) == null) 
		{
			queryDescriptions.put(qryDescription.toLowerCase(), 0);
			if(parseNull(qryType).equals("d3")) return "d3json_" + qryDescription;
			else if(parseNull(qryType).equals("d3map")) return "d3mapjson_" + qryDescription;
			else if(parseNull(qryType).equals("d3mapchl")) return "d3mapchljson_" + qryDescription;
			else if(parseNull(qryType).equals("c3")) return "c3json_" + qryDescription;
			return "result_qry_" + qryDescription;
		}
		else
		{
			int i = queryDescriptions.get(qryDescription.toLowerCase());
			i++;
			queryDescriptions.put(qryDescription.toLowerCase(), i);
			if(parseNull(qryType).equals("d3")) return "d3json_" + qryDescription + "_" + i;
			else if(parseNull(qryType).equals("d3map")) return "d3mapjson_" + qryDescription + "_" + i;
			else if(parseNull(qryType).equals("d3mapchl")) return "d3mapchljson_" + qryDescription + "_" + i;
			else if(parseNull(qryType).equals("c3")) return "c3json_" + qryDescription + "_" + i;
			return "result_qry_" + qryDescription + "_" + i;
		}
	}

public String getJsonFromQueries(com.etn.beans.Contexte Etn, String jsonId, Map<String, String> requestQueryParams, boolean useparamdefaultvalues)
{

	String _out = "";
	OutputStream bOut = null;
	HashMap<String,Integer> queryDescriptions = new HashMap<String, Integer>();
	try
	{
		Set rs = Etn.execute("select * from expert_system_queries where json_id = " + escape.cote(jsonId) + " order by id ");

	//System.out.println("getJsonFromQueries(json_id:"+jsonId+" = rs " + (rs!=null?" "+rs.rs.Rows:"vide")); 
		int i = 0;
		while(rs.next())
		{

			Map<String, String> queryParams = new HashMap<String, String>();
			Set rs1 = Etn.execute("select * from expert_system_query_params where json_id = "+escape.cote(jsonId)+" and query_id = " + escape.cote(rs.value("id")));
			while(rs1.next())
			{
				queryParams.put(parseNull(rs1.value("param")), parseNull(rs1.value("default_value")));
			}
				
			bOut = new ByteArrayOutputStream();
			Xdr2Json json = new Xdr2Json( bOut );
			if(i++ > 0) _out += ",";

			String q = " " + rs.value("query") + " ";

			for(String param : queryParams.keySet())
			{
				if(q.indexOf("@"+param) < 0 && q.indexOf("@#"+param) < 0) continue;

				String val = "";

				if(useparamdefaultvalues){

					val = parseNull(queryParams.get(param));

				} else {
					
					val = parseNull(requestQueryParams.get(param));
				}

				if(val != null) val = val.trim();

				if(q.indexOf("@#"+param) > -1) {
					
					//if(val.length() == 0) val = "\"\"";
					q = q.replace("@#"+param + " ", val);	
	
				}else{
	
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

						if((t.indexOf("=") > -1 || t.indexOf(" like ") > -1) && t.indexOf("in") < 0) //its an equi join
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
					}//else val = escape.cote(val);				

					//for inclause in query we need to send the values in single qoutes already otherwise escape.cote will create problem
					if(!val.startsWith("'") && !val.endsWith("'")) val = escape.cote(val); 
					
					//space added for exact match
					q = q.replace("@"+param + " ", " "+val+" ");
				
				}
			}

			//this is the only case when called from expert system to load the json
			//sometimes the json is huge due to too many rows returned by queries.
			//so for expert system fetching json we will put a limit on each query to return not more than 3 rows
			if(useparamdefaultvalues)
			{
				q = " " + q.replaceAll("(\\r|\\n)", " ") + " ";
				if(!q.toLowerCase().contains(" limit ")) q = q + " limit 3 ";
			}
			//System.out.println(q);
			rs1 = Etn.execute(q);			

			boolean reactCall = false;
			if(requestQueryParams.get("____rt") != null && (requestQueryParams.get("____rt")).equals("1")) reactCall = true;

			int fmt = 0;
			if(parseNull(rs.value("query_type")).equals("array"))
			{
				fmt = 2;
				_out += "\"" + getJsonObjectName(queryDescriptions, parseNull(rs.value("description")), i, parseNull(rs.value("query_type"))) + "\":";
			}
			else if(parseNull(rs.value("query_type")).equals("array-with-labels"))
			{
				fmt = 2;
				reactCall = true;
				//for array with labels the actual output is going to be as array so we pass query type as array
				//only difference will be made by the reactCall true
				_out += "\"" + getJsonObjectName(queryDescriptions, parseNull(rs.value("description")), i, "array") + "\":";
			}
			else if(parseNull(rs.value("query_type")).equals("d3"))
			{
				fmt = 3;
				_out += "\"" + getJsonObjectName(queryDescriptions, parseNull(rs.value("description")), i, parseNull(rs.value("query_type"))) + "\":";
			}
			else if(parseNull(rs.value("query_type")).equals("d3map"))
			{
				fmt = 6;
				_out += "\"" + getJsonObjectName(queryDescriptions, parseNull(rs.value("description")), i, parseNull(rs.value("query_type"))) + "\":";
			}
			else if(parseNull(rs.value("query_type")).equals("d3mapchl"))
			{
				fmt = 7;
				_out += "\"" + getJsonObjectName(queryDescriptions, parseNull(rs.value("description")), i, parseNull(rs.value("query_type"))) + "\":";
			}
			else if(parseNull(rs.value("query_type")).equals("c3"))
			{
				String jsonName = getJsonObjectName(queryDescriptions, parseNull(rs.value("description")), i, parseNull(rs.value("query_type")));
				//System.out.println("select xaxis from expert_system_script where parent_json_tag = '"+jsonName+"' and json_tag = 'data[*]' and json_id = " + escape.cote(jsonId));
				Set rs2 = Etn.execute("select xaxis from expert_system_script where parent_json_tag = '"+jsonName+"' and json_tag = 'data[*]' and json_id = " + escape.cote(jsonId));
				if(rs2.next() && "pivot-timeseries".equals(rs2.value("xaxis"))) fmt = 5;
				else fmt = 4;
				_out += "\"" + jsonName + "\":";
			}
			else 
			{
				_out += "\"" + getJsonObjectName(queryDescriptions, parseNull(rs.value("description")), i, parseNull(rs.value("query_type"))) + "\":";
			}
			//System.out.println("fmt:::"+fmt);

			json.getJson( rs1, "rs_"+i, fmt, true, reactCall);
			_out += bOut.toString().trim();

			if(bOut != null) bOut.close();
		}

	}
	catch(Exception e)
	{
		e.printStackTrace();
	}
	finally
	{
		try { if(bOut != null) bOut.close(); } catch(Exception e) {}
	}

	return _out;

}
%>
