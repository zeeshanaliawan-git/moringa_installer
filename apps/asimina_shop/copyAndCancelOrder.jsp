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
    String customerId = parseNull(request.getParameter("customerId"));
    String orderId = parseNull(request.getParameter("orderId"));
    String isCancel = parseNull(request.getParameter("isCancel"));	
    String isCopy = parseNull(request.getParameter("isCopy"));	
    String errCode = parseNull(request.getParameter("errCode"));	
	
	boolean semfree = false;
	
	String newOrderId = "";
	int newCustomerId = 0;

	if(isCopy.equals("1"))
	{
		Set lastLineRs = Etn.execute("select id from post_work where status = '0' and client_key = "+escape.cote(customerId)+" ");
		lastLineRs.next();
		int lastLineId = Integer.parseInt(lastLineRs.value("id"));

		newOrderId = "" + System.currentTimeMillis();//temporarily set to this
		newCustomerId = Etn.executeCmd(" insert into customer ( orderId,creationDate,orderType,orderStatus,tm,sfid,identityId,name, " +
								" surnames,nationality,dateOfBirth,contactPhoneNumber1,contactPhoneNumber2,email,  " +
								" account,IdentityType,sex,roadType,roadName,roadNumber,stair,floorNumber,apartmentNumber, " +
								" postalCode,locality,state,tarif,tarifData,cpOperator,cpTarifV,cpTarifD,typeOfPaymentCurrentOperator, " +
								" previousOperator,iccidSim,previousIccidSim,msisdn,imei,terminal,terminalsap,horarioDesde,horarioHasta, " +
								" solicitud,idarpa,contrato,changeWindowDate,portabilityCodeRequest,insurance,oldMsisdn, " +
								" logistic,price,canon,iva,subscript,codesap,factura,comments ) " +
								" select '"+newOrderId+"',current_timestamp,orderType,orderStatus,current_timestamp,sfid,identityId,name, " +
								" surnames,nationality,dateOfBirth,contactPhoneNumber1,contactPhoneNumber2,email, " +
								" account,IdentityType,sex,roadType,roadName,roadNumber,stair,floorNumber,apartmentNumber, " +
								" postalCode,locality,state,tarif,tarifData,cpOperator,cpTarifV,cpTarifD,typeOfPaymentCurrentOperator, " +
								" previousOperator,iccidSim,previousIccidSim,msisdn,imei,terminal,terminalsap,horarioDesde,horarioHasta, " +
								" solicitud,idarpa,contrato,changeWindowDate,portabilityCodeRequest,insurance,oldMsisdn, " +
								" logistic,price,canon,iva,subscript,codesap,factura,comments from customer where customerId = "+escape.cote(customerId)+" ");
								
		Etn.executeCmd("update customer set orderId = concat(right(left(0+creationDate,8),6),hex(12345+customerid)) where customerId = "+escape.cote("" + newCustomerId)+" ");
		Set rsCust = Etn.execute("select orderId from customer where customerId = "+escape.cote("" + newCustomerId)+" ");
		rsCust.next();
		newOrderId = rsCust.value("orderId");
								
	    int newPostWorkLine = Etn.executeCmd("insert into post_work "+
              "(proces, phase, priority, insertion_date, client_key ) "+
              " select p.proces, 'DataCheck', now(), now(), "+escape.cote(""+newCustomerId)+" "+
              " from post_work p where p.id = "+escape.cote(""+lastLineId)+" ");//change
			
		
		semfree = true;
	}
	
	if(isCancel.equals("1"))
	{
		Set rsErr = Etn.execute("select * from errcode where id = "+escape.cote(errCode)+" ");
		rsErr.next();
		String errMsg = parseNull(rsErr.value("errMessage"));
		String qrys[] = new String[3];
		qrys[0] = "set @curid = 0"; 
		qrys[1] = "update post_work set status = 1, id = @curid := id, errCode = "+escape.cote(errCode)+", errMessage = "+escape.cote(errMsg)+", operador = "+escape.cote((String)session.getAttribute("LOGIN"))+" where status = 0 and client_key = "+escape.cote(customerId)+" ";
		qrys[2] = "select @curid as lastLineId ";
		Set rs = Etn.execute(qrys);
		int lastLineId = 0;
		if(rs.next() && rs.next() && rs.next()) lastLineId = Integer.parseInt(rs.value(0));
		boolean isError = false;
		if(lastLineId == 0)
		{
			isError = true;
		}
		else
		{
		
			Set rsCancelPhase = Etn.execute("select ph.phase from post_work pw, phases ph where pw.proces = ph.process and ph.phase in ('Cancel','Cancel30') and pw.id = "+escape.cote(""+lastLineId)+" ");
			rsCancelPhase.next();
			String cancelPhase = rsCancelPhase.value("phase");

			String insertPostWorkLineQry =  "insert into post_work "+
				"(proces, phase, priority, insertion_date, client_key ) "+
				" select p.proces, "+escape.cote(cancelPhase)+", now(), now(),client_key "+
				" from post_work p where p.id = "+escape.cote(""+lastLineId)+" ";//change
			
			int rowsUpdated = Etn.executeCmd(insertPostWorkLineQry);
			
			if(rowsUpdated > 0)
			{		
				//Update LastId dans customer
				String updatePostWorkLineQry = " update post_work set status = 2, start = if(start is null,insertion_date, start), end = current_timestamp, nextId = "+escape.cote(""+rowsUpdated)+", attempt=attempt+1 where id = " + lastLineId;
				rowsUpdated = Etn.executeCmd(updatePostWorkLineQry);
				
				String qryLastId = " Update customer set lastId = "+escape.cote(""+lastLineId)+" where customerId =  "+escape.cote(customerId)+" ";
				Etn.executeCmd(qryLastId);
				semfree = true;
			}
		}
	}

	if(semfree) Etn.execute("select semfree('"+SEMAPHORE+"')");
%>

<% 
	if(isCopy.equals("1")) response.sendRedirect("customerEdit.jsp?customerId="+newCustomerId);
	else if(isCancel.equals("1")) response.sendRedirect("customerEdit.jsp?customerId="+customerId);
%>
