<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="java.io.FileOutputStream, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>


<%@ include file="common.jsp" %>

<%!
	class MyTag extends JsonToHtml
	{
		String htmltagtype = "";
		String id;
	}

%>
<%
	String jsonid = parseNull(request.getParameter("jsonid"));


	//this path is relative to generatedJsps folder. We need to include applyRules.jsp from that path
	String expertSystemPath = GlobalParm.getParm("EXPERT_SYSTEM_RELATIVE_PATH_TO_GENERATE_JSP");

	String path = GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_HTML_FOLDER");

	String generatedHtmlPath = GlobalParm.getParm("EXPERT_SYSTEM_GENERATED_HTML_RELATIVE_PATH");//this path is relative to the webapp path

	String filename = "html_" + CommonHelper.escapeCoteValue(jsonid) + ".jsp";

	String jqueryUrl = GlobalParm.getParm("EXPERT_SYSTEM_JQUERY_URL");



	String generateScriptAutomatic = "0";
	String msg = "";

	Set rs = Etn.execute("select * from expert_system_script where json_id = " + escape.cote(jsonid) + " order by id ");

	if(rs.rs.Rows > 0)
	{
		Map<String, MyTag> tags = new LinkedHashMap<String, MyTag>();

		ArrayList<String> parents = new ArrayList<String>();
		while(rs.next())
		{
			if(parseNull(rs.value("parent_json_tag")).length() > 0) parents.add(parseNull(rs.value("parent_json_tag")));
		}

		rs.moveFirst();
		while(rs.next())
		{
			MyTag tag = new MyTag();
			tag.tag = parseNull(rs.value("json_tag"));
			tag.parentTag = parseNull(rs.value("parent_json_tag"));
			tag.htmlTag = parseNull(rs.value("html_tag"));
			tag.maxRows = parseNull(rs.value("max_rows"));
			tag.showCol = parseNull(rs.value("show_col"));
			tag.colHeader = parseNull(rs.value("col_header"));
			tag.colSeqNum = parseNull(rs.value("col_seq_num"));
			tag.functions = parseNull(rs.value("functions"));
			tag.fieldType = parseNull(rs.value("field_type"));
			tag.fieldName = parseNull(rs.value("field_name"));
			tag.fillFrom = parseNull(rs.value("fill_from"));
			tag.pagination = parseNull(rs.value("add_pagination"));
			tag.colCss = parseNull(rs.value("col_value_css"));
			tag.colHeaderCss = parseNull(rs.value("col_header_css"));
			tag.d3chart = parseNull(rs.value("d3chart"));
			tag.c3chart = parseNull(rs.value("c3chart"));
			tag.xaxis = parseNull(rs.value("xaxis"));
			tag.xcols = parseNull(rs.value("xcols"));
			tag.ycols = parseNull(rs.value("ycols"));
			tag.c3col_graph_type = parseNull(rs.value("c3col_graph_type"));
			tag.c3_col_groups = parseNull(rs.value("c3_col_groups"));
			tag.extras = parseNull(rs.value("extra_fields"));
			tag.id = parseNull(rs.value("id"));

			String key = tag.tag;
			if(!tag.parentTag.equals("")) key = tag.parentTag + "." + tag.tag;
			tags.put(key, tag); 	

			//these are special tags which dont need html generated for them
			if((getActualParent(tag.parentTag).startsWith("d3json_") || getActualParent(tag.parentTag).startsWith("d3mapjson_") || getActualParent(tag.parentTag).startsWith("d3mapchljson_") || getActualParent(tag.parentTag).startsWith("c3json_") || getActualParent(tag.parentTag).startsWith("result_qry_")) &&
			   (tag.tag.equals("key") || tag.tag.equals("result") || tag.tag.equals("fmt") || tag.tag.equals("cols")) )
			{
				continue;
			}

			if(!parseNull(tag.parentTag).endsWith("[*]"))//in case of columns inside the table we just have to add table in html. columns are added automatically so we are not setting htmlid for these
			{
				boolean htmltagempty = false;
				if(tag.htmlTag.length() == 0) 
				{
					htmltagempty = true;
					tag.htmlTag = parseNull(tag.tag);
				}
				//c3 tag is table tag but as we have to handle it special we remove [*] from it
				if(tag.c3chart.length() > 0 && tag.htmlTag.endsWith("[*]")) tag.htmlTag = tag.htmlTag.substring(0, tag.htmlTag.lastIndexOf("[*]"));

				tag.htmltagtype = "SPAN";
//System.out.println(tag.tag + " " + tag.htmlTag + " " + tag.htmltagtype);

				if(tag.htmlTag.endsWith("[*]"))
				{
					tag.htmlTag = tag.htmlTag.replace("[*]","");
					tag.htmltagtype = "TABLE";
				}
				else if(!htmltagempty && tag.tag.endsWith("[*]")) tag.htmltagtype = "TABLE";//in-case html tag was already set we still need to set its type otherwise it always set to SPAN

				if(htmltagempty) if(parseNull(tag.parentTag).length() > 0) tag.htmlTag = parseNull(tag.parentTag) + "." + tag.htmlTag;
				tag.htmlTag = tag.htmlTag.replaceAll("\\.","_");
//System.out.println(tag.tag + " " + tag.htmlTag + " " + tag.htmltagtype);
				if(parents.contains(key) && !tag.htmltagtype.equals("TABLE")) tag.htmlTag = "";
			}
		}

		FileOutputStream fos = null;
		boolean filegenerated = true;
		try
		{

			rs = Etn.execute("select * from expert_system_json where id = "  + escape.cote(jsonid));
			rs.next();
			String jsonUuid = rs.value("json_uuid");
		
			String output = "<html>\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n";	
			output += "<script LANGUAGE='JavaScript' SRC='"+jqueryUrl+"'></script>\n";
			output += "<jsp:include page=\"../applyRules.jsp\" >\n\t<jsp:param name=\"jsonUuid\" value=\""+jsonUuid+"\" />\n</jsp:include>\n";
			output += "</head>\n<body>\n<div style='margin-bottom:10px'>\n";

			Set rsParams = Etn.execute("select distinct param from expert_system_query_params where json_id = " + escape.cote(jsonid));
			if(rsParams.rs.Rows > 0) output += "\t<div style='margin-bottom:20px;'>\n";
			while(rsParams.next())
			{
				output += "\t\t<div><span style='font-weight:bold; '>"+rsParams.value("param")+"</span>&nbsp;<span><input type='text' name='"+rsParams.value("param")+"' id='param_"+rsParams.value("param")+"' value='' /></span></div>\n";
			}
			if(rsParams.rs.Rows > 0) 
			{
				output += "\t\t<div><input type='button' id='searchBtn' value='Search' /></div>\n";
				output += "\t</div>\n";
			}

			String prevParent = "";
			for(String key : tags.keySet())
			{
				MyTag tag = tags.get(key);

				int marginTop = 3;
				String curParent = tag.parentTag;
				if(curParent.indexOf(".") > -1) curParent = curParent.substring(0, curParent.indexOf("."));
				if(prevParent.length() > 0 && !prevParent.equals(curParent)) marginTop += 15;
				if(tag.htmlTag.trim().length() == 0	) continue;
				output += "\t<div style='margin-top:"+marginTop+"px; font-size:12px;'>\n";
				if(getActualParent(tag.parentTag).startsWith("d3json_") && tag.tag.startsWith("data")) 
				{
					if("treemap".equals(tag.d3chart))
					{
						output += "\t\t<div >click or option-click to descend or ascend: <select id='"+tag.htmlTag+"_size_count_select'><option value='size'>Size</option><option value='count'>Count</option></select></div>";
					}
					output += "\t\t<div id='"+tag.htmlTag+"'></div>";
				}
				else if(getActualParent(tag.parentTag).startsWith("d3mapjson_") && tag.tag.startsWith("data")) 
				{
					output += "\t\t<div id='"+tag.htmlTag+"' style='width: 700px; height: 433px;'></div>";
				}
				else if(getActualParent(tag.parentTag).startsWith("d3mapchljson_") && tag.tag.startsWith("data")) 
				{
					output += "\t\t<div id='"+tag.htmlTag+"' style='width: 700px; height: 433px;'></div>";
				}
				else if(getActualParent(tag.parentTag).startsWith("c3json_") && tag.tag.startsWith("data")) 
				{
					output += "\t\t<div id='"+tag.htmlTag+"'></div>";
				}
				else if(tag.htmltagtype.equals("SPAN"))
				{
					output += "\t\t<span style='font-weight:bold; color:blue;'>"+tag.tag+"</span>&nbsp;<span id='"+tag.htmlTag+"'></span>\n";
				}
				else if(tag.htmltagtype.equals("TABLE"))
				{
					output += "\t\t<table cellpadding='2' cellspacing='2' border='1' id='"+tag.htmlTag+"' style='font-size:12px'></table>\n";
				}
				output += "\t</div>\n";
				prevParent = curParent;
			}	

			output += "</div>\n</body>\n";
			output += "<script type=\"text/javascript\">\n";
			output += "jQuery(document).ready(function() {\n";

			String _url = parseNull(rs.value("url"));
			if(_url.indexOf("?") > -1) _url = _url.substring(0, _url.indexOf("?"));
			if(rsParams.rs.Rows > 0) 	
			{
				output += "\t$('#searchBtn').click(function(){\n";
				output += "\t\t$.ajax({\n";
				output += "\t\t\turl : '"+_url+"',\n";			
				output += "\t\t\ttype: 'POST',\n";
				output += "\t\t\tdataType : 'json',\n";

				String data = "";
				rsParams.moveFirst();
				int j=0;
				while(rsParams.next())
				{
					if(j++ > 0) data += ", ";
					data += rsParams.value("param") + ": $('#param_"+rsParams.value("param")+"').val()";
				}

				output += "\t\t\tdata : {"+data+"},\n";
			
				output += "\t\t\tsuccess : function(json)\n";
				output += "\t\t\t{\n";		
				output += "\t\t\t\tvar expertSystemJson = _applyExpertSystemRules(json, "+CommonHelper.escapeCoteValue(jsonid)+");\n";
				output += "\t\t\t}//end of success\n";
				output += "\t\t});\n";										
				output += "\t});\n";
			}
			else
			{
				output += "\t$.ajax({\n";
				output += "\t\turl : '"+_url+"',\n";
				output += "\t\ttype: 'POST',\n";
				output += "\t\tdataType : 'json',\n";
				output += "\t\tsuccess : function(json)\n";
				output += "\t\t{\n";		
				output += "\t\t\tvar expertSystemJson = _applyExpertSystemRules(json, "+CommonHelper.escapeCoteValue(jsonid)+");\n";
				output += "\t\t}//end of success\n";
				output += "\t});\n";										
			}
			output += "});\n";
			output += "</script>\n";
			output += "</html>\n";
System.out.println("save to file : " + path + filename);
			fos = new FileOutputStream(path + filename);
			fos.write(output.getBytes("utf8"));
			fos.close();	

			Etn.execute("update 	expert_system_json set destination_page = "+escape.cote(generatedHtmlPath + filename)+" where id = " + escape.cote(jsonid));	
		}
		catch(Exception e)
		{
			if(fos != null) fos.close();
			e.printStackTrace();	
			filegenerated = false;
			msg = "Error generating file!!!";
		}
	
		if(filegenerated)
		{
			Etn.executeCmd("delete from expert_system_html where json_id = " + escape.cote(jsonid));	

			for(String key : tags.keySet())
			{
				MyTag tag = tags.get(key);
				if(tag.htmlTag.length() > 0) 
				{
					Etn.executeCmd("insert into expert_system_html (json_id, tag_type, tag_id) values ("+escape.cote(jsonid)+","+escape.cote(tag.htmltagtype)+","+escape.cote(tag.htmlTag)+") ");
					Etn.executeCmd("update expert_system_script set html_tag = "+escape.cote(tag.htmlTag)+" where id = " + escape.cote(tag.id));
				}
			}
			generateScriptAutomatic = "1";
			msg = "Html file generated successfully!!!";
		}
	}
%>
<html>
<body>
	<form name='frm' id='frm' method='post' action='uiScript.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonid)%>'>
		<input type='hidden' name = 'msg' value='<%=CommonHelper.escapeCoteValue(msg)%>' />
		<input type='hidden' name = 'generateScriptAutomatic' value='<%=CommonHelper.escapeCoteValue(generateScriptAutomatic)%>' />
	</form>
</body>
<script>
	document.frm.submit();
</script>
</html>
