<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, com.etn.asimina.util.ActivityLog"%>

<%@ include file="common.jsp"%>
<%!
    String convertToUpperCaseWords(String str)
    {
        char ch[] = str.toCharArray();
        for (int i = 0; i < str.length(); i++) {
            if (i == 0 && ch[i] != ' ' ||
                ch[i] != ' ' && ch[i - 1] == ' ') {
                if (ch[i] >= 'a' && ch[i] <= 'z') {
                    ch[i] = (char)(ch[i] - 'a' + 'A');
                }
            }
            else if (ch[i] >= 'A' && ch[i] <= 'Z')
                ch[i] = (char)(ch[i] + 'a' - 'A');
        }
        String st = new String(ch);
        return st;
    }
    String getNames(com.etn.beans.Contexte Etn,String ids,String type){
    try{
        if(ids.charAt(ids.length()-1) == ',')  ids = ids.substring(0, ids.length() - 1);
        Set rs = null;
        String names = "";
        String q = "";
        System.out.println(ids+"     "+type);
        if(type.equals("menus")){
            q =  "select name  from site_menus where id in ("+ids+")";
        }

        if(q.length()>0)   rs = Etn.execute(q);
        else return "";

        while(rs.next()){
            if(names.length()>0) names += ", ";
            names += parseNull(rs.value(0));
        }
        return names;
    }catch(Exception e){
        return "";
    }
    }
%>
<%
	String ty = parseNull(request.getParameter("type"));
	String id = parseNull(request.getParameter("id"));
	String on = parseNull(request.getParameter("on"));
    String itemName = parseNull(request.getParameter("name"));
    String date = on;

    if(date.equals("-1")) date = "";
    else date = " for "+ date;

	String _d = "";
	if(!"-1".equals(on))
	{
		if(on.length() != 16)
		{
			out.write("{\"response\":\"error\",\"msg\":\"Invalid date/time format. Format must be dd/mm/yyyy hh:mm\"}");
			return;
		}
		on = on + ":00";
		try {
			on =  ItsDate.stamp(ItsDate.getDate(on));
		} catch(Exception e) {
			out.write("{\"response\":\"error\",\"msg\":\"Invalid date/time format. Format must be dd/mm/yyyy hh:mm\"}");
			return;
		}
	}

	String process = getProcess(ty);

	String phase = "publish";
	String msg = "Sucess";
	String resp = "success";
	boolean dosemfree = movephase(Etn, id, process, phase, on);

	String publishon = "";
	Set rs = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') from post_work where status = 0 and phase = 'publish' and client_key = "+escape.cote(id)+" and proces = " +escape.cote(process));
	if(rs.next()) publishon = "Next publish on : " + parseNull(rs.value(0));

	if(!dosemfree)
	{
		resp = "error";
		msg = "Publish already in process";
	}else{
        if(itemName.length()>0)
        {
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,"PUBLISH PROD",convertToUpperCaseWords(process),itemName+date,parseNull(session.getAttribute("SELECTED_SITE_ID")));
        }else{
            ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),id,"PUBLISH PROD",convertToUpperCaseWords(process),getNames(Etn,id,process)+date,parseNull(session.getAttribute("SELECTED_SITE_ID")));
        }
    }

	out.write("{\"response\":\""+resp+"\",\"msg\":\""+msg+"\", \"next_publish_on\":\""+publishon+"\"}");
	if(dosemfree) Etn.execute("select semfree('"+GlobalParm.getParm("SEMAPHORE")+"') ");
%>