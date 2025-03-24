<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
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

	String orderId = parseNull(request.getParameter("orderId"));
	String errCode = parseNull(request.getParameter("errCode"));	

	String isgenericform = "0";
	String cid = customerId;
	if(form_id.length() > 0) 
	{
		cid = form_id;
		isgenericform = "1";
	}
	
	boolean semfree = false;
	
	Set rsErr = Etn.execute("select * from errcode where id = "+escape.cote(errCode)+" ");
	rsErr.next();
	String errMsg = parseNull(rsErr.value("errMessage"));
	String qrys[] = new String[3];
	qrys[0] = "set @curid = 0"; 
	qrys[1] = "update post_work set status = 1, id = @curid := id, errCode = "+escape.cote(errCode)+", errMessage = "+escape.cote(errMsg)+", operador = "+escape.cote((String)session.getAttribute("LOGIN"))+" where status = 0 and is_generic_form = "+escape.cote(isgenericform)+" and client_key = "+escape.cote(cid)+" ";
	qrys[2] = "select @curid as lastLineId ";
	Set rs = Etn.execute(qrys);
	int lastLineId = 0;
	if(rs.next() && rs.next() && rs.next()) lastLineId = Integer.parseInt(rs.value(0));
	boolean isError = false;

	int newPostWorkId = 0;

	if(lastLineId == 0)
	{
		isError = true;
	}
	else
	{
	
		Set rsCancelPhase = Etn.execute("select ph.phase from post_work pw, phases ph where pw.proces = ph.process and ph.phase in ('Cancel','Cancel30') and pw.id = "+escape.cote(""+lastLineId)+" ");
		rsCancelPhase.next();
		String cancelPhase = rsCancelPhase.value("phase");

		System.out.println("select ph.phase from post_work pw, phases ph where pw.proces = ph.process and ph.phase in ('Cancel','Cancel30') and pw.id = "+escape.cote(""+lastLineId)+" ");

		String insertPostWorkLineQry =  "insert into post_work "+
			"(proces, phase, priority, insertion_date, client_key, is_generic_form ) "+
			" select p.proces, "+escape.cote(cancelPhase)+", now(), now(),client_key, is_generic_form "+
			" from post_work p where p.id = " + lastLineId;

			System.out.println(insertPostWorkLineQry);
		
		newPostWorkId = Etn.executeCmd(insertPostWorkLineQry);
			
		if(newPostWorkId > 0)
		{		
			String updatePostWorkLineQry = " update post_work set status = 2, start = if(start is null,insertion_date, start), end = current_timestamp, nextId = "+escape.cote(""+newPostWorkId)+", attempt=attempt+1 where id =  "+escape.cote(""+lastLineId)+" ";//change
			int rowsUpdated = Etn.executeCmd(updatePostWorkLineQry);
			
			String qryLastId = "";
			if(customerId.length() > 0) qryLastId = " Update "+targetTable+" set lastId = "+escape.cote(""+lastLineId)+" where id =  "+escape.cote(customerId)+" ";
			else if(form_id.length() > 0) qryLastId = " Update generic_forms set lastId = "+escape.cote(""+lastLineId)+" where id =  "+escape.cote(form_id)+" ";

			Etn.executeCmd(qryLastId);
			semfree = true;
		}
	}

	if(semfree) Etn.execute("select semfree('"+SEMAPHORE+"')");
%>

<% 
	if(customerId.length() > 0) response.sendRedirect("customerEdit.jsp?customerId="+customerId+"&post_work_id="+newPostWorkId);
	else response.sendRedirect("genericFormEdit.jsp?form_id="+form_id+"&post_work_id="+newPostWorkId);
%>
