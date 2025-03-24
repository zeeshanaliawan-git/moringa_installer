<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, java.util.List,com.etn.asimina.util.ActivityLog, com.etn.asimina.util.SiteHelper, com.etn.asimina.beans.Language"%>

<%!
	String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

    String getSelectedSiteId(javax.servlet.http.HttpSession session)
    {
        return parseNull(session.getAttribute("SELECTED_SITE_ID"));
    }
%>

<%
	String requestingpage = parseNull(request.getParameter("requestingpage"));
	String reqtype = parseNull(request.getParameter("reqtype"));
	String delflag = parseNull(request.getParameter("delflag"));

	String retPath = "libmsgs.jsp";
	if("1".equals(delflag))
	{
		int dc = Etn.executeCmd("delete from langue_msg where rtrim(ltrim(coalesce(LANGUE_1,''))) = '' and rtrim(ltrim(coalesce(LANGUE_2,''))) = '' and rtrim(ltrim(coalesce(LANGUE_3,''))) = '' and rtrim(ltrim(coalesce(LANGUE_4,''))) = '' and rtrim(ltrim(coalesce(LANGUE_5,''))) = ''");
		ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"","DELETED","Translations","Un-used words/phrases deleted",parseNull(getSelectedSiteId(session)));
		retPath += "?dc="+dc;
	}
	else
	{		

		System.out.println("siteId=="+getSelectedSiteId(session));
		List<Language> langsList = SiteHelper.getSiteLangs(Etn,getSelectedSiteId(session));

		String[] langref = request.getParameterValues("LANGUE_REF");

		String upd = " update langue_msg set updated_on = now(), updated_by = " + escape.cote(""+Etn.getId());
		for(int i=0; i<langref.length; i++)
		{
			String q = "";
			for(Language lang : langsList)
			{
				q += ", LANGUE_" + lang.getLanguageId() + " = " + escape.cote(request.getParameterValues("LANGUE_" + lang.getLanguageId())[i]);
			}
			q += " where LANGUE_REF = " + escape.cote(langref[i]);
					if(i<10) System.out.println(">>>"+upd+q);
			Etn.executeCmd(upd + q );
		}
		ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),"","UPDATED","Translations","Translations updated",parseNull(getSelectedSiteId(session)));
	}

	response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
	if(requestingpage.length() > 0) response.setHeader("Location", requestingpage);
	else response.setHeader("Location", retPath);

%>