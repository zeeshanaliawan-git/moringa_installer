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

    int parseNullInt(Object o)
    {
        if (o == null) return 0;
        String s = o.toString();
        if (s.equals("null")) return 0;
        if (s.equals("")) return 0;
        return Integer.parseInt(s);
    }

%>
<%
        String id = parseNull(request.getParameter("id"));
        String complaint = parseNull(request.getParameter("complaint"));
        String query;
        Set rs = Etn.execute(query = "select pw.phase, pw.proces, pw.id from "+GlobalParm.getParm("SHOP_DB")+".post_work pw inner join "+GlobalParm.getParm("SHOP_DB")+".phases p ON pw.proces = p.process AND p.phase = 'complaints' WHERE pw.status = 9 AND client_key="+escape.cote(id));
        // Proceed only if there is Complaints phase in the process
        if(rs.next()){
            String errMessage= "";
            String errCode = "0";
            Set errRs = Etn.execute("select * from "+GlobalParm.getParm("SHOP_DB")+".errcode where id = "+escape.cote(errCode));
            if(errRs.next()) errMessage = errRs.value("errMessage");
	
            String qrys[] = new String[3];
            qrys[0] = "set @curid = 0";
            qrys[1] = "update "+GlobalParm.getParm("SHOP_DB")+".post_work set status = 1, id = @curid := id, errCode = "+escape.cote(errCode)+", errMessage = "+escape.cote(errMessage)+" where status = 9 and id = "+escape.cote(rs.value("id"));
            qrys[2] = "select @curid as lastLineId ";
            System.out.println(qrys[1]);
            Set rsChangePhase = Etn.execute(qrys);
            int lastLineId = 0;
            if(rsChangePhase.next() && rsChangePhase.next() && rsChangePhase.next()) lastLineId = Integer.parseInt(rsChangePhase.value(0));
            boolean isError = false;
            int newId = 0;
            if(lastLineId == 0)
            {
                out.write("Some Error Occured!1");
            }
    //System.out.println(lastLineId);
            else
            {
                String insertPostWorkLineQry =  "insert into "+GlobalParm.getParm("SHOP_DB")+".post_work "+
                  "(proces, phase, priority, insertion_date, client_key, is_generic_form ) "+
                  " select "+escape.cote(rs.value("proces"))+", 'Complaints', now(), now(),client_key, is_generic_form "+
                  " from "+GlobalParm.getParm("SHOP_DB")+".post_work p where p.id = " + escape.cote(""+lastLineId);

                newId = Etn.executeCmd(insertPostWorkLineQry);

                if(newId > 0)
                {		
                    String updatePostWorkLineQry = " update "+GlobalParm.getParm("SHOP_DB")+".post_work set status = 2, start = if(start is null,insertion_date, start), end = current_timestamp, nextId = "+escape.cote(""+newId)+", attempt=attempt+1 where id = " + lastLineId;
                    int rowsUpdated = Etn.executeCmd(updatePostWorkLineQry);

                    String qryLastId = " Update "+GlobalParm.getParm("SHOP_DB")+".customer set lastId = "+escape.cote(""+lastLineId)+" where customerId = "+escape.cote(id);
                                        
                    Etn.executeCmd(qryLastId);
                    Etn.execute("select semfree('"+GlobalParm.getParm("SHOP_SEMAPHORE")+"')");
                                              
                    int j = Etn.executeCmd("update "+GlobalParm.getParm("SHOP_DB")+".order_items set complaint="+escape.cote(complaint)+" where id="+escape.cote(id));
                    out.write("Complaint Submitted!");
                }
                else out.write("Some Error Occured!");
            }
        }  
        else{
            out.write("No Complaint Phase!");
        }
        
%>