<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, java.util.ArrayList"%>

<%@ include file="common.jsp"%>


<%
	String mid = parseNull(request.getParameter("mid"));

	ArrayList<String> preprodcol = new ArrayList<String>();
	ArrayList<String> prodcol = new ArrayList<String>();
	boolean iscrawling = false;

	Set rs = Etn.execute("select date_format(created_on, '%d/%m/%Y %H:%i:%s') as dt from crawler_audit where menu_id = " + escape.cote(mid) + " and status = 2 and action = 'Crawling' order by id desc ");
	if(rs.next())
	{
		preprodcol.add("Last crawled on " + rs.value("dt"));
	}

	rs = Etn.execute("select * from crawler_audit where menu_id = " + escape.cote(mid) + " and status = 1 order by id desc ");
	if(rs.next())
	{
		iscrawling = true;
		String act = rs.value("action");
		preprodcol.add("<span style='color:red'>" + act + "</span>");
	} 

	String proddb = com.etn.beans.app.GlobalParm.getParm("PROD_DB");

	rs = Etn.execute("select date_format(priority, '%d/%m/%Y %H:%i:%s') as dt from post_work where phase = 'published' and status in (0,2) and client_key = " + escape.cote(mid) + " order by id desc limit 1 ");
	if(rs.next())
	{
		prodcol.add("<span style=''>Last published on "+rs.value("dt")+"</span>");
	}

	rs = Etn.execute("select date_format(created_on, '%d/%m/%Y %H:%i:%s') as dt from "+proddb+".crawler_audit where menu_id = " + escape.cote(mid) + " and status = 2 and action = 'Crawling' order by id desc ");
	if(rs.next())
	{
		prodcol.add("Last crawled on " + rs.value("dt"));		
	}

	boolean showcancelbtn = false;
	rs = Etn.execute("select *, date_format(priority, '%d/%m/%Y %H:%i:%s') as nextpublish from post_work where client_key = " + escape.cote(mid) + " order by id desc limit 1 ");
	if(rs.next())
	{
		if("publish".equals(rs.value("phase")) && "0".equals(rs.value("status")))
		{
			showcancelbtn = true;
			prodcol.add("Next publish on <span style='color:red;'>"+rs.value("nextpublish")+"</span>");
			prodcol.add("<small style='color:red;'>WARNING!!!</small> If you make any changes now those will be published also");
		}
		else if("publish".equals(rs.value("phase")) && "1".equals(rs.value("status"))) prodcol.add("<span style='color:red'>Publish in process</span>");
		else if("published".equals(rs.value("phase")) && "0".equals(rs.value("status"))) 
		{
			Set _rs = Etn.execute("select * from "+proddb+".crawler_errors where menu_id = " + escape.cote(mid) + " order by created_on ");
			if(_rs.rs.Rows > 0)
			{
				prodcol.add("<span style='color:red;font-weight: normal;'><a style='color:red' href='javascript:viewCrawlerErrors()'>View Errors</a></span>"); 
			}		
		}
	}

	rs = Etn.execute("select * from "+proddb+".crawler_audit where menu_id = " + escape.cote(mid) + " and status = 1 order by id desc");
	if(rs.next())
	{
		String act = rs.value("action");
		prodcol.add("<span style='color:red;font-weight: normal;'>"+act+"</span>");
	}
	
	int max = preprodcol.size();
	if(max < prodcol.size()) max = prodcol.size();

	String prehtml = "<div class='col-sm-6'><div class='card' style='height:200px'><div class='card-header' style='height:56px'>Test menu status</div><div class='card-body' style='background-color: #e7f4ff;'>";
	String prodhtml = "<div class='col-sm-6'><div class='card' style='height:200px'><div class='card-header' style='height:56px'>Menu status";

	if(showcancelbtn)
		prodhtml += "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<button type='button' class='btn btn-danger btn-sm pull-right' onclick='javascript:window.location=\\\"cancelaction.jsp?type=menu&id="+mid+"&goto=menudesigner.jsp?menuid="+mid+"\\\";' >Cancel publish</button>";
	prodhtml += "</div><div class='card-body' style='background-color: #fef3e4;'>";

	for(int i=0; i<max; i++)
	{
		prehtml += "<p style='margin: 0;'>";
		if(i < preprodcol.size() && preprodcol.size() > 0) prehtml += preprodcol.get(i);
		else prehtml += "&nbsp;";
		prehtml += "</p>";


		prodhtml += "<p style='margin: 0;'>";
		if(i < prodcol.size() && prodcol.size() > 0) prodhtml += prodcol.get(i);
		else prodhtml += "&nbsp;";
		prodhtml += "</p>";

	}

	prehtml += "</div></div></div>";
	prodhtml += "</div></div></div>";

	out.write("{\"html\":\""+prehtml + prodhtml+"\",\"iscrawling\":\""+iscrawling+"\"}");

%>

