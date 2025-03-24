<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ include file="../common.jsp" %>

<%
	String customerId = parseNull(request.getParameter("customerId"));	
	String form_id = parseNull(request.getParameter("form_id"));	

	String id = customerId;
	String isgenericform = "0";
	if(form_id.length() > 0) 
	{
		id = form_id;
		isgenericform = "1";
	}
	
	Set rs = Etn.execute("select * from rlock where id  = "+escape.cote(id)+" and is_generic_form = " + escape.cote(isgenericform));
	
	if(rs.rs.Rows == 0)
	{
		int rows = Etn.executeCmd("insert into rlock (id, is_generic_form, csr) values ("+escape.cote(id)+","+escape.cote(isgenericform)+","+escape.cote((String)session.getAttribute("LOGIN"))+") ");
		if(rows == 0)
		{
%>
			{
				"STATUS":"ERROR",
				"STATUS_CODE":"0"
			}			
<%		}
		else
		{
%>
			{
				"STATUS":"SUCCESS",
				"STATUS_CODE":"0"
			}
<%
		}
	}
	else
	{
		rs.next();
		if(rs.value("csr").equalsIgnoreCase((String)session.getAttribute("LOGIN"))) 
		{
			Etn.executeCmd("update rlock set tm = current_timestamp where id = "+escape.cote(customerId)+" and is_generic_form = " + escape.cote(isgenericform));
%>
			{
				"STATUS":"SUCCESS",
				"STATUS_CODE":"1"
			}			
<%			
		}
		else
		{
%>
			{
				"STATUS":"ERROR",
				"STATUS_CODE":"1"
			}			
<%
		}
	}
%>
