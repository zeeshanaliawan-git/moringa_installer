<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page import="com.etn.lang.ResultSet.Xdr2Json,com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*, java.io.*"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>

<%@ include file="common2.jsp" %>

<%!
	String replaceQueryParams(ServletRequest request, String qry)
	{
		qry = " " + qry + " " ;
			
		Enumeration<String> parameterNames = request.getParameterNames();

		while (parameterNames.hasMoreElements())
		{
			String paramName = parameterNames.nextElement();
			if(qry.indexOf("@@" + paramName + "@@") > -1 ) 
			{
				String[] values = request.getParameterValues(paramName);
				String val = "";
				if(values != null)
				{
					int i=0;
					for(String v : values)
					{
						if(i > 0) val += ",";
						val += escape.cote(parseNull(v));
					}
				}
				else val = escape.cote(parseNull(request.getParameter(paramName)));
				qry = qry.replace("@@" + paramName + "@@", val);
			}
		}
//		System.out.println(qry);
		return qry; 
	}
%>

<%
	String ruleid = parseNull(request.getParameter("__noe_rule_id"));
	String formid = parseNull(request.getParameter("__noe_form_id"));
	String fieldid = parseNull(request.getParameter("__noe_field_id"));

	String triggername = parseNull(request.getParameter("__noe_trigger_name"));
	
	//first check if its mapped field then get json from mapping table
	Set rs = Etn.execute("select field_id, element_trigger from process_rule_fields where rule_id = "+escape.cote(ruleid)+" and field_id = " +  escape.cote(fieldid));
	if(rs.rs.Rows == 0) rs = Etn.execute("select field_id, element_trigger from process_form_fields where form_id = "+escape.cote(formid)+" and field_id = " +  escape.cote(fieldid));	

	rs.next();

	String triggersJson = parseNull(rs.value("element_trigger"));

	if(triggersJson.length() == 0)
	{
		out.write("[]");
		return;
	}
	List<String> qrys = null;
	java.util.Map<String, java.util.List<String>> map = getElementTriggerQueries(triggersJson);
	System.out.println(map);
	for(String key : map.keySet())
	{
		System.out.println(key);
		if(key.equalsIgnoreCase(triggername))
		{
			qrys = map.get(key);
			break;
		}
	}
	//no query found for this particular trigger
	if(qrys == null || qrys.size() == 0)
	{
		out.write("[]");
		return;
	}

	boolean anySelectExecuted = false;
	for(String qry : qrys)
	{
		qry = parseNull(qry);
		System.out.println(qry);
		if(qry.length() == 0) continue;
	
		if(qry.toLowerCase().startsWith("select"))
		{
			OutputStream bOut = null;
			String _out = "";
			try
			{
				qry = replaceQueryParams(request, qry);

				rs = Etn.execute(qry);
				anySelectExecuted = true;
				bOut = new ByteArrayOutputStream();
				Xdr2Json json = new Xdr2Json( bOut );

				json.getJson( rs, "rs", 1, true  );
				_out += bOut.toString().trim();

			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
			finally
			{
				try { if(bOut != null) bOut.close(); } catch(Exception e) {}
			}
			out.write(_out);
		}//end if
		else
		{
			qry = replaceQueryParams(request, qry);
			Etn.executeCmd(qry);
		}
	}//end for queries

	if(!anySelectExecuted)
	{
		//if no select executed return empty json as ajax call is expecting a json
		out.write("[]");
	}
%>  