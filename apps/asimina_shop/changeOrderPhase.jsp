<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.text.DateFormat"%>

 
<%@ include file="common2.jsp" %>

<%
	String targetTable = "orders";
	if("1".equals(com.etn.beans.app.GlobalParm.getParm("POST_WORK_SPLIT_ITEMS"))) targetTable = "order_items";

    String customerId = parseNull(request.getParameter("customerId"));
    String form_id = parseNull(request.getParameter("form_id"));

    String oldPhase = parseNull(request.getParameter("oldPhase"));    
    String process = parseNull(request.getParameter("process"));
    String nextProcess = parseNull(request.getParameter("nextProcess"));	    
    String nextPhase = parseNull(request.getParameter("nextPhase"));	    
    String orderId = parseNull(request.getParameter("orderId"));	    
    String errCode = parseNull(request.getParameter("errCode"));	    
    String fromDialog = parseNull(request.getParameter("fromDialog"));	    
    String isFromEditScreen = parseNull(request.getParameter("isFromEditScreen"));	 
	String post_work_id = parseNull(request.getParameter("post_work_id"));

//System.out.println(" form_id " + form_id);

	String errMessage= "";
	Set errRs = Etn.execute("select * from errcode where id = "+escape.cote(errCode)+"  ");
	if(errRs.next()) errMessage = errRs.value("errMessage");
	
	String qrys[] = new String[3];
	qrys[0] = "set @curid = 0";
	qrys[1] = "update post_work set status = 1, id = @curid := id, errCode = "+escape.cote(errCode)+", errMessage = "+escape.cote(errMessage)+", operador = "+escape.cote((String)session.getAttribute("LOGIN"))+" where status = 0 and id = "+escape.cote(post_work_id);
	qrys[2] = "select @curid as lastLineId ";
//System.out.println(qrys[1]);
	Set rs = Etn.execute(qrys);
	int lastLineId = 0;
	if(rs.next() && rs.next() && rs.next()) lastLineId = Integer.parseInt(rs.value(0));
	boolean isError = false;
	int newId = 0;
	if(lastLineId == 0)
	{
		isError = true;
	}
//System.out.println(lastLineId);
	else
	{
		String insertPostWorkLineQry =  "insert into post_work "+
		  "(proces, phase, priority, insertion_date, client_key, is_generic_form ) "+
		  " select "+escape.cote(nextProcess)+", "+escape.cote(nextPhase)+", now(), now(),client_key, is_generic_form "+
		  " from post_work p where p.id = " + escape.cote(""+lastLineId);
		
		newId = Etn.executeCmd(insertPostWorkLineQry);
		
		if(newId > 0)
		{		
			String updatePostWorkLineQry = " update post_work set status = 2, start = if(start is null,insertion_date, start), end = current_timestamp, nextId = "+escape.cote(""+newId)+", attempt=attempt+1 where id = " + escape.cote(""+lastLineId);//change
			int rowsUpdated = Etn.executeCmd(updatePostWorkLineQry);
			
			String qryLastId = "";
			if(customerId.length() > 0)
			{
				qryLastId = " Update "+targetTable+" set lastId = "+escape.cote(""+lastLineId)+" where id = "+escape.cote(customerId)+" ";
			}
			else if(form_id.length() > 0)
			{
				qryLastId = " Update generic_forms set lastId = "+escape.cote(""+lastLineId)+" where id = "+escape.cote(form_id)+" ";
			}
			
			if(qryLastId.length() > 0)
			{
				Etn.executeCmd(qryLastId);

				Etn.execute("select semfree('"+SEMAPHORE+"')");
			}
		}
	}
	String json = "{";
	if(fromDialog == null || fromDialog.equals("") || fromDialog.equalsIgnoreCase("false"))//not from graphical screen
	{
		if(isError)
		{
			if(isFromEditScreen.equals("1")) 
			{
				if(customerId.length() > 0) response.sendRedirect("customerEdit.jsp?_refresh=1&post_work_id="+post_work_id+"&customerId="+customerId+"&message=ERROR::The order seem to be already updated to some other phase");
				else response.sendRedirect("genericFormEdit.jsp?_refresh=1&post_work_id="+post_work_id+"&form_id="+form_id+"&message=ERROR::The order seem to be already updated to some other phase");
			}
			else 
			{
				json += "'response':'error','errorMsg':'The order seem to be already updated to some other phase'";
			}
		}
		else
		{
			if(isFromEditScreen.equals("1")) 
			{
				if(customerId.length() > 0) response.sendRedirect("customerEdit.jsp?_phasechangesucc=1&post_work_id="+newId+"&customerId="+customerId);
				else response.sendRedirect("genericFormEdit.jsp?_phasechangesucc=1&post_work_id="+newId+"&form_id="+form_id);
			}
			else 
			{
				json += "'response':'success','errorMsg':'Phase changed successfully'";
			}		
		}
		json+="}";
		out.print(json.replaceAll("'","\""));
	}
	else
	{
		if(isError) {%>ERROR: The order seem to be updated to some other phase already
		<% } else {%>Phase changed successfully<%}%>
<%	}
	
%>
