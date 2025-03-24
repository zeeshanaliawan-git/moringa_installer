<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.sql.escape, com.etn.lang.parser.HtmlSaxParser, java.io.FileInputStream, java.util.List, java.util.ArrayList, java.io.File"%>
<%@ page import="org.jsoup.*"%>
<%@ page import="org.jsoup.nodes.*"%>
<%@ page import="org.jsoup.select.*"%>

<%@ include file="/common.jsp"%>

<%!
	
	public class Tag
	{
		String name;
		String type;
		String id;
	}

	public class ParseHtml extends HtmlSaxParser {

		List<Tag> tags;
	
		public ParseHtml()
		{
			tags = new ArrayList<Tag>();
		}
    
		public void startElement( int tag, byte raw[], int len )
    		{
			String _t = "";
       		if(tag == DIV) _t = "DIV";
			else if (tag == SPAN) _t = "SPAN";
			else if (tag == TABLE) _t = "TABLE";
			else if (tag == INPUT) _t = "INPUT";
			else if (tag == SELECT) _t = "SELECT";
			else if (tag == TD) _t = "TD";
			else return;

			Tag t = new Tag();
			t.type = _t;

			parseAttribute(raw, len);
			t.name = parseNull(getValue("name"));
			t.id = parseNull(getValue("id"));
//			System.out.println("$$$$ " + _t + " " + t.name + " " + t.id);

			if(!t.name.trim().equals("") || !t.id.trim().equals("")) tags.add(t);			
	    	}
	}


%>
<%
	String jsonId = parseNull(request.getParameter("jsonid"));
	String destpage = parseNull(request.getParameter("destpage"));

	try {

//		System.out.println("$$$$$$$ " + destpage);
		String path = GlobalParm.getParm("WEBAPP_FOLDER");
		path = path + destpage.replaceAll("/", "").replaceAll("\\\\", "");
		File f = new File(path);

		if(f.length() == 0 || !f.exists())
		{
			out.write("{\"RESPONSE\":\"error\",\"MSG\":\"No destination page found\"}");
			return;
		}
		else
		{
			ParseHtml p = new ParseHtml();
			p.parse(new FileInputStream(path));

			if(p.tags.isEmpty())
			{
				out.write("{\"RESPONSE\":\"success\",\"ALLOW_MATCHING\":\"0\"}");				
			}
			else
			{
				Etn.executeCmd("delete from expert_system_html where json_id = " + escape.cote(jsonId));
				for(Tag t : p.tags)
				{
					Etn.executeCmd("insert into expert_system_html (json_id, tag_type, tag_id, tag_name) values ("+escape.cote(jsonId)+","+escape.cote(t.type)+","+escape.cote(t.id)+","+escape.cote(t.name)+") ");
				}
				Etn.executeCmd("update expert_system_json set destination_page = " + escape.cote(destpage) + " where id = " + escape.cote(jsonId));
				out.write("{\"RESPONSE\":\"success\",\"ALLOW_MATCHING\":\"1\",\"MSG\":\"Html parsed successfully!!!\"}");
			}
		}
	}
	catch( Exception aa )
	{ 
		aa.printStackTrace();
		out.write("{\"RESPONSE\":\"error\",\"MSG\":\"Some error occurred while parsing destination page\"}");
	}

%>

