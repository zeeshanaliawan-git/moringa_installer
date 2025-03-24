<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.regex.Matcher"%>
<%@ page import="java.util.regex.Pattern"%>
<%@ page import="com.etn.sql.escape"%>

<%@include file="../common.jsp"%>

<%!
	public boolean isValidEmailAddress(String emailAddress)
	{  
		String  expression="^[\\w\\-]([\\.\\w])+[\\w]+@([\\w\\-]+\\.)+[A-Z]{2,4}$";  
		CharSequence inputStr = emailAddress;  
		Pattern pattern = Pattern.compile(expression,Pattern.CASE_INSENSITIVE);  
		Matcher matcher = pattern.matcher(inputStr);  
		return matcher.matches();    
	}  

%>

<%

	String mailid = parseNull(request.getParameter("mailid"));
	String ordertype = parseNull(request.getParameter("ordertype"));
	if(request.getParameter("loadConfiguration") != null)
	{
		Set rs =  Etn.execute("select * from mail_config where id = "+escape.cote(mailid)+" and ordertype = "+escape.cote(ordertype));
		String emailto = "";
		String whereclause = "";
		String attach = "";
		if(rs.next())
		{
			emailto = parseNull(rs.value("email_to"));
			whereclause = parseNull(rs.value("where_clause"));
			attach = parseNull(rs.value("attach"));
		}
		out.write("{\"ATTACH\":\""+attach+"\",\"EMAIL_TO\":\""+emailto+"\",\"WHERE_CLAUSE\":\""+whereclause+"\"}");
	}
	if(request.getParameter("saveConfiguration") != null)
	{
		int rows = 0;
		String emailto = parseNull(request.getParameter("emailto"));
		String whereclause = parseNull(request.getParameter("whereclause"));
		String attach = parseNull(request.getParameter("attach"));
		if(emailto.equals("") && whereclause.equals("") && attach.equals(""))
		{
			rows = Etn.executeCmd("delete from mail_config where id = "+escape.cote(mailid)+" and ordertype = "+escape.cote(ordertype));
		}
		else
		{
			Set rs = Etn.execute("select * from mail_config where id = "+escape.cote(mailid)+" and ordertype = "+escape.cote(ordertype));
//			int rows = 0;
			if(rs.rs.Rows == 0)
			{
				rows = Etn.executeCmd("insert into mail_config (id, ordertype, email_to, where_clause, attach) values ("+escape.cote(mailid)+","+escape.cote(ordertype)+","+escape.cote(emailto)+","+escape.cote(whereclause)+","+escape.cote(attach)+") ");
			}
			else
			{
				rows = Etn.executeCmd("update mail_config set email_to = "+escape.cote(emailto)+", where_clause = "+escape.cote(whereclause)+", attach = "+escape.cote(attach)+" where id = "+escape.cote(mailid)+" and ordertype = "+escape.cote(ordertype));
			}
		}
		if(rows > 0) out.write("{\"MESSAGE\":\"Success\"}");
		else out.write("{\"MESSAGE\":\"Error\"}"); 
	}

%>
