<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>

<%@ include file="common2.jsp" %>

<%
	String targetTable = "orders";
	if("1".equals(com.etn.beans.app.GlobalParm.getParm("POST_WORK_SPLIT_ITEMS"))) targetTable = "order_items";
	String customerId = parseNull(request.getParameter("customerId"));
	String form_id = parseNull(request.getParameter("form_id"));

	String orderId = parseNull(request.getParameter("orderId"));
	String post_work_id = parseNull(request.getParameter("post_work_id"));
	boolean isFull = Boolean.parseBoolean(request.getParameter("isFull"));
	
	String resp = "SUCCESS";
	String msg = "";
	Set rs = Etn.execute("select id from post_work where nextid = "+escape.cote(post_work_id)+" ");
	
	int lastId = 0;
	String reversedToId = "";
	if(rs.rs.Rows == 0)
	{
		resp = "ERROR";
		msg = "Order already in first phase";	
	}
	else
	{
		rs.next();
		lastId = Integer.parseInt(rs.value("id"));
		if(isFull)
		{
			List<String> ids = new ArrayList<String>();	
			String nextId = post_work_id;
			do
			{				
				rs = Etn.execute("select id, proces, ph.phase, reverse from post_work pw, phases ph where pw.proces = ph.process and pw.phase = ph.phase and nextid = "+escape.cote(nextId)+" ");
				if(rs.next())
				{
					if(rs.value("reverse").equals("R"))
					{
						ids.add(rs.value("id"));
						nextId = rs.value("id");
					}
					else break;
				}
				else break;
			}while(true);
			
			if(ids.size() == 0)
			{
				resp = "ERROR";
				msg = "Reverse not allowed on previous phase";
			}
			else
			{			
				String qrys[] = new String[3];
				qrys[0] = "set @curid = 0";
				qrys[1] = "update post_work set status = 1, id = @curid := id, operador = "+escape.cote((String)session.getAttribute("LOGIN"))+" where status = 0 and id = "+escape.cote(post_work_id)+" ";
				qrys[2] = "select @curid as latestLineId ";
				rs = Etn.execute(qrys);
				int latestLineId = 0;
				if(rs.next() && rs.next() && rs.next()) latestLineId = Integer.parseInt(rs.value(0));

				if(latestLineId > 0)
				{
					boolean semfree=false;
					Etn.executeCmd("delete from post_work where id = "+escape.cote(""+latestLineId)+" ");	
					int index =0;
					for(String curId : ids)
					{
						if(index+1 == ids.size())//dont delete this instead update it
						{
							Etn.executeCmd("update post_work set priority = now(), status=0, errCode = 0, errMessage = null, start = null, end = null, attempt=0, nextid=0, flag=0 where id = "+escape.cote(curId)+" ");
							rs = Etn.execute("select id from post_work where nextid = "+escape.cote(curId)+" ");
							reversedToId = curId;
							if(rs.rs.Rows == 0)
							{
								if(customerId.length() > 0) Etn.executeCmd("update "+targetTable+" set lastId = 0 where id = "+escape.cote(customerId)+" ");
								else if(form_id.length() > 0) Etn.executeCmd("update generic_forms set lastId = 0 where id = "+escape.cote(form_id)+" ");
							}
							else
							{
								rs.next();
								if(customerId.length() > 0) Etn.executeCmd("update "+targetTable+" set lastId = "+escape.cote(rs.value("id"))+" where id = "+escape.cote(customerId)+" ");
								else if(form_id.length() > 0) Etn.executeCmd("update generic_forms set lastId = "+escape.cote(rs.value("id"))+" where id = "+escape.cote(form_id)+" ");
							}
						}
						else Etn.executeCmd("delete from post_work where id = "+escape.cote(curId)+" ");	
						index++;
						semfree=true;
					}
					if(semfree) Etn.execute("select semfree('"+SEMAPHORE+"')");
				}
				else
				{
					resp = "ERROR";
					msg = "Order seems to be updated already. Refresh it and then try again";					
				}
			}
		}
		else
		{
			rs = Etn.execute("select reverse from phases ph, post_work pw where pw.id = "+escape.cote(""+lastId)+" and pw.proces = ph.process and pw.phase = ph.phase ");
			rs.next();
			if(rs.value("reverse").equals("R"))//we can reverse
			{
				String qrys[] = new String[3];
				qrys[0] = "set @curid = 0";
				qrys[1] = "update post_work set status = 1, id = @curid := id, operador = "+escape.cote((String)session.getAttribute("LOGIN"))+" where status = 0 and id = "+escape.cote(post_work_id)+" ";
				qrys[2] = "select @curid as latestLineId ";
				rs = Etn.execute(qrys);
				int latestLineId = 0;
				if(rs.next() && rs.next() && rs.next()) latestLineId = Integer.parseInt(rs.value(0));

				if(latestLineId > 0)
				{
					Etn.executeCmd("delete from post_work where id = "+escape.cote(""+latestLineId)+" ");			
					Etn.executeCmd("update post_work set priority = now(), status=0, errCode = 0, errMessage = null, start = null, end = null, attempt=0, nextid=0, flag=0 where id = "+escape.cote(""+lastId)+" ");
					rs = Etn.execute("select id from post_work where nextid = "+escape.cote(""+lastId)+" ");
					reversedToId = ""+lastId;
					if(rs.rs.Rows == 0)
					{
						if(customerId.length() > 0) Etn.executeCmd("update "+targetTable+" set lastId = 0 where id = "+escape.cote(customerId)+" ");
						else if(form_id.length() > 0) Etn.executeCmd("update generic_forms set lastId = 0 where id = "+escape.cote(form_id)+" ");
					}
					else
					{
						rs.next();
						if(customerId.length() > 0) Etn.executeCmd("update "+targetTable+" set lastId = "+escape.cote(rs.value("id"))+" where id = "+escape.cote(customerId)+" ");
						else if(form_id.length() > 0) Etn.executeCmd("update generic_forms set lastId = "+escape.cote(rs.value("id"))+" where id = "+escape.cote(form_id)+" ");
					}
					Etn.execute("select semfree('"+SEMAPHORE+"')");
				}
				else
				{
					resp = "ERROR";
					msg = "Order seems to be updated already. Refresh it and then try again";					
				}
			}
			else
			{
				resp = "ERROR";
				msg = "Reverse not allowed on previous phase";
			}
		}
	}
	
%>
{"STATUS":"<%=resp%>","MESSAGE":"<%=msg%>","REVERSED_TO":"<%=reversedToId%>"}