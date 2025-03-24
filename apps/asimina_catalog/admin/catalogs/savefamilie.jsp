<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>

<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.*"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>
<%!

	String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}
%>
<%
	List<String> ignoreparams = new ArrayList<String>();
	ignoreparams.add("id");
	ignoreparams.add("deleteimage");

	List<String> intcols = new ArrayList<String>();

	String id = parseNull(request.getParameter("id"));

	String deleteimage = parseNull(request.getParameter("deleteimage"));
	if("1".equals(deleteimage))
	{
		Etn.executeCmd("update familie set updated_on = now(), updated_by = "+escape.cote(""+Etn.getId())+", img_name = null where id =  " + escape.cote(id));
	}
	else
	{
		if(id.length() == 0)
		{
			String cols = "created_by";
			String vals = escape.cote(""+Etn.getId());
	       	for(String parameter : request.getParameterMap().keySet())
			{
//				if("deleteimage".equals(parameter)) continue;
				if(ignoreparams.contains(parameter)) continue;
				cols += "," + parameter;

				if(intcols.contains(parameter) && parseNull(request.getParameter(parameter)).length() == 0) vals += ", NULL";
				else vals += "," + escape.cote(request.getParameter(parameter));
			}
			id = "" + Etn.executeCmd("insert into familie ("+cols+") values ("+vals+")");
		}
		else
		{
			String q = "update familie set updated_on = now(), updated_by = " + escape.cote(""+Etn.getId());
	       	for(String parameter : request.getParameterMap().keySet())
			{
//				if("deleteimage".equals(parameter)) continue;
				if(ignoreparams.contains(parameter)) continue;

				if(intcols.contains(parameter) && parseNull(request.getParameter(parameter)).length() == 0) q += ", " + parameter + " = NULL ";
				else q += ", " + parameter + " = " + escape.cote(request.getParameter(parameter));
			}
			q += " where id = " + escape.cote(id);
			Etn.executeCmd(q);
		}
	}

	response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
	response.setHeader("Location", "familie.jsp?id="+id);
%>
