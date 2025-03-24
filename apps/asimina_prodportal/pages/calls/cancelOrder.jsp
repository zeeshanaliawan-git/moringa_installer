<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.util.*"%>
<%!
    String parseNull(Object o)
    {
        if( o == null )
        return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase()))
        return("");
        else
        return(s.trim());
    }

%>
<%
    String customerId = parseNull(request.getParameter("customerId"));

    String oldPhase = parseNull(request.getParameter("oldPhase"));    
    String process = parseNull(request.getParameter("process"));
    String nextProcess = parseNull(request.getParameter("nextProcess"));	    
    String nextPhase = parseNull(request.getParameter("nextPhase"));	    
    String errCode = parseNull(request.getParameter("errCode")); 
    String post_work_id = parseNull(request.getParameter("post_work_id"));
    String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);

    String json = "{";

    Set rsClient = Etn.execute("select * from "+GlobalParm.getParm("SHOP_DB")+".customer where client_id="+escape.cote(client_id)+" and customerId="+escape.cote(customerId));
    if(rsClient.next()){
    
	String errMessage= "";
	Set errRs = Etn.execute("select * from "+GlobalParm.getParm("SHOP_DB")+".errcode where id = "+escape.cote(errCode)+"  ");
	if(errRs.next()) errMessage = errRs.value("errMessage");
	
	String qrys[] = new String[3];
	qrys[0] = "set @curid = 0";
	qrys[1] = "update "+GlobalParm.getParm("SHOP_DB")+".post_work set status = 1, id = @curid := id, errCode = "+escape.cote(errCode)+", errMessage = "+escape.cote(errMessage)+", operador = 'portal' where status = 0 and id = "+escape.cote(post_work_id);
	qrys[2] = "select @curid as lastLineId ";
//System.out.println(qrys[1]);
	Set rs = Etn.execute(qrys);
	int lastLineId = 0;
	if(rs.next() && rs.next() && rs.next()) lastLineId = Integer.parseInt(rs.value(0));
	boolean isError = false;
	int newId = 0;
//System.out.println(lastLineId);
	if(lastLineId == 0)
	{
		isError = true;
	}
	else
	{
		String insertPostWorkLineQry =  "insert into "+GlobalParm.getParm("SHOP_DB")+".post_work "+
		  "(proces, phase, priority, insertion_date, client_key, is_generic_form ) "+
		  " select "+escape.cote(nextProcess)+", "+escape.cote(nextPhase)+", now(), now(),client_key, is_generic_form "+
		  " from "+GlobalParm.getParm("SHOP_DB")+".post_work p where p.id = " + escape.cote(""+lastLineId);
		
		newId = Etn.executeCmd(insertPostWorkLineQry);
		
		if(newId > 0)
		{		
			String updatePostWorkLineQry = " update "+GlobalParm.getParm("SHOP_DB")+".post_work set status = 2, start = if(start is null,insertion_date, start), end = current_timestamp, nextId = "+escape.cote(""+newId)+", attempt=attempt+1 where id = " + lastLineId;
			int rowsUpdated = Etn.executeCmd(updatePostWorkLineQry);
			
			String qryLastId = "";
			if(customerId.length() > 0)
			{
				qryLastId = " Update "+GlobalParm.getParm("SHOP_DB")+".customer set lastId = "+escape.cote(""+lastLineId)+" where customerId = "+escape.cote(customerId)+" ";
                                Etn.executeCmd(qryLastId);

				Etn.execute("select semfree('"+GlobalParm.getParm("SHOP_SEMAPHORE")+"')");
			}
		}
	}

        if(isError)
        {
                json += "'response':'error','errorMsg':'The order seem to be already updated to some other phase'";
        }
        else
        {
                json += "'response':'success','errorMsg':'Phase changed successfully'";

        }
    }
    else{
        json += "'response':'error','errorMsg':'You are not authorized to cancel this order'";
    }
    json+="}";
    out.print(json.replaceAll("'","\""));
	
%>