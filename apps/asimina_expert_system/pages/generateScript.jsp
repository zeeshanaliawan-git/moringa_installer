<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.io.*, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>

<%@ include file="common.jsp" %>
<%!
	//for reusing a json results, we create special tags which ends with ___escp_<id> where <id> is id of table expert_system_reuse_json. 
	//These special tags are actually not going to be there in the json returned actually
	//so before using tags for script generation, we have to remove ___escp_<id> from tag names. After removing ___escp_<id> from tags, the tag becomes the actual tag 
	//name returned when data is fetched
	String fixTag(String tag)
	{
//		System.out.println("------------- " + tag);
		if(tag == null || tag.trim().length() == 0 || tag.indexOf("___escp_") < 0) return tag;
		//we need to fix this
		String t = "";
		if(tag.indexOf(".") > -1)
		{
			String[] ts = tag.split("\\.");
			for(int i=0; i<ts.length; i++)
			{
				if(i>0) t += ".";
				if(ts[i].indexOf("___escp_") > -1) t += ts[i].substring(0, ts[i].indexOf("___escp_"));
				else t += ts[i];
			}
		}
		else t = tag.substring(0, tag.indexOf("___escp_")); 
//System.out.println("======= " + t);
		return t;
	}

	String getFunctions(Map<String, String> supportedJsFunctions, String jsonId, JsonToHtml c)
	{
		String parentTag = fixTag(c.parentTag);

		String s = "";
		if(!c.functions.equals(""))
		{
			String[] funcs = c.functions.split(",");
			for(String f : funcs)
			{
				if(f.indexOf(":") == -1) continue;
				f = f.trim();
				String functionname = f.substring(0, f.indexOf(":"));
				functionname = supportedJsFunctions.get(functionname.toLowerCase());
//				if(functionname != null) s += " "+functionname+"=\""+f.substring(f.indexOf(":") + 1)+"(\\\'_es_'+___" + CommonHelper.escapeCoteValue(jsonId) + "__count+'\\\',____" + CommonHelper.escapeCoteValue(jsonId) + "_json."  + (parentTag.replaceAll("\\[\\*\\]","")).replaceAll("\\.","_")+"[\'+__i+\'])\" ";
				if(functionname != null) s += " "+functionname+"=\""+f.substring(f.indexOf(":") + 1)+"(\\\'_es_'+___" + CommonHelper.escapeCoteValue(jsonId) + "__count+'\\\',____" + CommonHelper.escapeCoteValue(jsonId) + "_json."  + (parentTag.replaceAll("\\[\\*\\]",""))+"[\'+__i+\'])\" ";

			}
			
		}
		return s;
	}

	String getIfCondition(String tagPath)
	{
		if(tagPath.indexOf(".") == -1) return tagPath;
		String[] ts = tagPath.split("\\.");
		String s = "";
		String prev = "";
		for(String t : ts)
		{
			if(s.length() == 0) 
			{
				s = t;	
				prev = t;
			}
			else 
			{
				s += " && " + prev + "." + t;
				prev += "." + t;
			}
		}

		return s;
	}

	String getScriptCode(String jsonId, Map<String, String> supportedJsFunctions, JsonToHtml c)
	{
		String s = "";

		String _cTag = fixTag(c.tag);
		if(_cTag.indexOf("[*]") > -1) _cTag = _cTag.substring(0, _cTag.indexOf("[*]"));
		String tagPath = "iJson." + _cTag;
		if(!c.parentTag.equals("")) tagPath = "iJson." + fixTag(c.parentTag) + "." + _cTag;

		//unfixedtagpath is used to keep script variables/classes/ids unique ... whereas when we have to fetch data from json we use tagPath
		String unfixedTagPath = c.tag;
		if(unfixedTagPath.indexOf("[*]") > -1) unfixedTagPath = unfixedTagPath.substring(0, unfixedTagPath.indexOf("[*]"));
		unfixedTagPath = "iJson." + unfixedTagPath;
		if(!c.parentTag.equals("")) unfixedTagPath = "iJson." + c.parentTag + "." + c.tag;

		//c3 json tag also ends with [*] as its the same table format but we dont have to add table for it
		if(c.tag.indexOf("[*]") > -1 && !parseNull(c.htmlTag).equals("") && c.c3chart.length() == 0)
		{
			s += "\n";
			if(!c.childs.keySet().isEmpty() && c.hasVisibleCols)
			{
				s += "\n\t//<"+unfixedTagPath.toUpperCase()+">\n";

				s += "\tif(";
				s += getIfCondition(tagPath) + " && ";
				s += " $('#"+c.htmlTag+"') ";
				s += ") {\n";
				String header = "<thead>";
				boolean anyValidHdr = false;
				boolean anyFunction = false;
				for(String _k : c.childs.keySet())
				{	
					JsonToHtml child = c.childs.get(_k);
					if(child.showCol.equals("0")) continue;
					if(!child.colHeader.equals("")) anyValidHdr = true;
					String _css = "";
					if(!child.colHeaderCss.equals("")) _css = " class=\""+child.colHeaderCss+"\" ";
					header += "<th "+_css+">"+child.colHeader+"</th>";			
					if(!child.functions.equals("")) anyFunction = true;
				}
				header += "</thead>";
				if(anyValidHdr) s += "\t\t$('#"+c.htmlTag+"').append('"+header+"');\n";
				String upperLimit = "";
				boolean needPagination = false;
				if(!c.maxRows.equals("0") && !c.maxRows.equals("")) 
				{
					upperLimit = c.maxRows;
					if(c.pagination.equals("1")) needPagination = true;
				}
				s += "\t\tvar _limit = " + tagPath+".length;\n";
				if(!needPagination && !upperLimit.equals("")) s += "\t\tif(_limit > " + upperLimit + ") _limit = " + upperLimit + ";\n";
				s += "\t\tfor(var __i = 0; __i < _limit; __i++) {\n";
				if(needPagination) 
				{
					s += "\t\t\tvar __trDisplay = 'display:none';\n";
					s += "\t\t\tif(__i < "+upperLimit+") __trDisplay = '';\n";
				}
				else s += "\t\t\tvar __trDisplay = '';\n";

				s += "\t\t\tvar __row = '<tr style=\"'+__trDisplay+'\" class=\""+unfixedTagPath.replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"\" id=\""+unfixedTagPath.replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"_'+__i+'\">';\n";
				s += "\t\t\t__row += '<input type=\"hidden\" id=\""+unfixedTagPath.replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"_pageno\" value=\"0\" />';\n";
				int i=0;
				int showingCols = 0;
				for(String _k : c.childs.keySet())
				{	
					JsonToHtml child = c.childs.get(_k);
					boolean specialArray = false;
					String valueFromTag = tagPath+"[__i]."+child.tag;	
					if(child.tag.startsWith("EXPSYS_SPECIAL_COL_")) 
					{
						valueFromTag = tagPath+"[__i]["+i+"]";	
						specialArray = true;
					}
					if(child.showCol.equals("1")) 
					{		
						showingCols ++;
						String _css = "";
						if(!child.colCss.equals("")) _css = " class=\""+child.colCss+"\" ";

						s += "\t\t\t__row += '<td "+_css+">';\n";

						if(child.fieldType.equalsIgnoreCase("label"))
						{
							String _style = "";
							if(child.hasClickFunction()) _style = "cursor:pointer; text-decoration:underline; ";
 							s += "\t\t\t__row += '<span class=\""+(unfixedTagPath+"."+child.tag).replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"\" style=\""+_style+"\" "+getFunctions(supportedJsFunctions, jsonId, child)+" id=\"_es_'+___" + CommonHelper.escapeCoteValue(jsonId) + "__count+'\">'+"+valueFromTag+"+'</span>';\n";
						}
						else if(child.fieldType.equalsIgnoreCase("text"))
						{
							String _fieldName = "";
							if(!child.fieldName.equals("")) _fieldName = " name=\""+child.fieldName+"\" ";
 							s += "\t\t\t__row += '<input class=\""+(unfixedTagPath+"."+child.tag).replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"\" type=\"text\" "+_fieldName+" "+getFunctions(supportedJsFunctions, jsonId, child)+" id=\"_es_'+___" + CommonHelper.escapeCoteValue(jsonId) + "__count+'\" value=\"'+"+valueFromTag+"+'\">';\n";
						}
						else if(child.fieldType.equalsIgnoreCase("select"))
						{
							String _fieldName = "";
							if(!child.fieldName.equals("")) _fieldName = " name=\""+child.fieldName+"\" ";
 							s += "\t\t\t__row += '<select class=\""+(unfixedTagPath+"."+child.tag).replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"\" type=\"text\" "+_fieldName+" "+getFunctions(supportedJsFunctions, jsonId, child)+" id=\"_es_'+___" + CommonHelper.escapeCoteValue(jsonId) + "__count+'\">';\n";
							if(!child.fillFrom.equals(""))
							{
								s += "\t\t\tfor(var ___u=0; ___u<"+child.fillFrom+".length; ___u++) {\n";
								s += "\t\t\t\tvar __selected = \"\";\n";
								s += "\t\t\t\tif("+valueFromTag+" == "+child.fillFrom+"[___u].key) __selected = \"selected\";\n";
								s += "\t\t\t\t__row += '<option '+__selected+' value=\"+"+child.fillFrom+"[___u].key+\">'+"+child.fillFrom+"[___u].value+'</option>'\n";
								s += "\t\t\t}\n";
							}
							s += "\t\t\t__row += '</select>';\n";
						}
						else if(child.fieldType.equalsIgnoreCase("radio"))
						{
							String _fieldName = "";
							if(!child.fieldName.equals("")) _fieldName = " name=\""+child.fieldName+"\" ";
							if(!child.fillFrom.equals(""))
							{
								s += "\t\t\tfor(var ___u=0; ___u<"+child.fillFrom+".length; ___u++) {\n";
	 							s += "\t\t\t\t__row += '<input class=\""+(unfixedTagPath+"."+child.tag).replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"\" type=\"radio\" "+_fieldName+" "+getFunctions(supportedJsFunctions, jsonId, child)+" id=\"_es_'+___" + CommonHelper.escapeCoteValue(jsonId) + "__count+'\">'+"+child.fillFrom+"[___u].value;\n";
								s += "\t\t\t}\n";
							}
							s += "\t\t\t__row += '</select>';\n";
						}
						s += "\t\t\t__row += '</td>';\n";
						s += "\t\t\t___" + CommonHelper.escapeCoteValue(jsonId) + "__count++;\n";
					}
		
					i++;
				}//end of for
				s += "\t\t\t__row += '</tr>';\n";
				s += "\t\t\t$('#"+c.htmlTag+"').append(__row);\n";
				s += "\t\t}\n";//end of for loop
				if(needPagination)
				{
					String pageRow = "<tr><td align=\"center\" colspan=\""+showingCols+"\" id=\""+unfixedTagPath.replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"_pagination\"></td></tr>";
					s += "\t\t$('#"+c.htmlTag+"').append('"+pageRow+"');\n";
					s += "\t\tshowPagination("+upperLimit+", \'"+unfixedTagPath.replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"\');\n";
				}
				s += "\t}\n";
				s += "\t//</"+unfixedTagPath.toUpperCase()+">\n";
			}
		}
		else if(!parseNull(c.htmlTag).equals(""))
		{
			s += "\n\t//<"+unfixedTagPath.toUpperCase()+">\n";

			s += "\tif(";
			if(!c.parentTag.equals("")) s += " iJson." + fixTag(c.parentTag) + " && " ;
			s += tagPath + " && ";
			s += " $('#"+c.htmlTag+"') ";		
			s += ") {\n";
			if(c.d3chart.length() > 0)
			{
				s += "\t\td3_"+CommonHelper.escapeCoteValue(jsonId)+"_"+c.parentTag.replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"_"+c.tag.replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"_load("+tagPath+");\n";
			}
			else if(c.c3chart.length() > 0)
			{
				String xaxis = c.xaxis;
				String catCol = "";
				String timeseriesXY = "''";
				if("category".equals(c.xaxis) && c.xcols.length() > 0) catCol = c.xcols.toUpperCase();
				else if("timeseries".equals(c.xaxis)) 
				{
					timeseriesXY = "{";
					String[] _xcols = c.xcols.split(",");
					String[] _ycols = c.ycols.split(",");
					for(int zz=0; zz<_xcols.length; zz++)
					{
						if(zz > 0) timeseriesXY += ",";
						timeseriesXY += "\'"+_ycols[zz].toUpperCase()+"\':\'"+_xcols[zz].toUpperCase()+"\'";
					}
					timeseriesXY += "}";
				}
				else if("pivot-timeseries".equals(c.xaxis)) 
				{
					xaxis = "timeseries";
					timeseriesXY = "{";
//					String[] _xcols = c.xcols.split(",");
//					String[] _ycols = c.ycols.split(",");
//					for(int zz=0; zz<_xcols.length; zz++)
//					{
//						if(zz > 0) timeseriesXY += ",";
//						timeseriesXY += "\'"+_ycols[zz].toUpperCase()+"\':\'"+_xcols[zz].toUpperCase()+"\'";
//					}
					timeseriesXY += "}";
				}
				
				String colsPath = "cols";
				if(tagPath.indexOf(".") > -1) colsPath = tagPath.substring(0, tagPath.lastIndexOf(".")) + ".cols";

				String iszoom = "false";
				if(getValue(c.extras, "zoom").length() > 0) iszoom = getValue(c.extras, "zoom");

				if("pivot-timeseries".equals(c.xaxis)) s += "\t\tc3_pivot("+tagPath+",'#"+c.htmlTag+"','"+c.c3chart+"','"+xaxis+"', "+colsPath+", '"+c.c3col_graph_type+"', '"+c.c3_col_groups+"',"+iszoom+");\n";
				else s += "\t\tc3_chart_load("+tagPath+",'#"+c.htmlTag+"','"+c.c3chart+"','"+xaxis+"','"+catCol+"',"+timeseriesXY+", '"+c.c3col_graph_type+"', '"+c.c3_col_groups+"',"+iszoom+");\n";
			}
			else if(c.parentTag.contains("d3mapjson_"))//its a d3map json
			{
				String geotype = getValue(c.extras, "geo_type");
				s += "\t\td3MapInit("+tagPath+",\""+c.htmlTag +"\",\""+geotype+"\");\n";
			//	s += "\t\t$(\"#"+c.htmlTag+"\").show();\n";
			}
			else if(c.parentTag.contains("d3mapchljson_"))//its a d3map json
			{
				String geotype = getValue(c.extras, "geo_type");
				String scale = getValue(c.extras, "scale");
				s += "\t\td3MapInitChoropleth("+tagPath+",\""+c.htmlTag+"\",\""+geotype+"\",\""+scale+"\");\n";
			}
			else
			{	
				s += "\t\tif($('#"+c.htmlTag+"').is('input') || $('#"+c.htmlTag+"').is('textarea')) $('#"+c.htmlTag+"').val("+tagPath+");\n";
				s += "\t\telse $('#"+c.htmlTag+"').html("+tagPath+");\n";
			}
			s += "\t}\n";
//			//for maps we have to hide container if there is no data returned by d3mapjson tag
//			if(c.parentTag.contains("d3mapjson_"))
//			{
//				s += "\telse $(\"#"+c.htmlTag+"\").hide();\n"; 
//			}
//			s += "\t//</"+unfixedTagPath.toUpperCase()+">\n";
		}
		else if(!c.childs.keySet().isEmpty())
		{			
			for(String _k : c.childs.keySet()) 
			{
				JsonToHtml child = c.childs.get(_k);
				s += getScriptCode(jsonId, supportedJsFunctions, child);
			}
		}
		return s;
	}

	JsonToHtml findParent(Map<String, JsonToHtml> configs, String parentTag)
	{
		String t = parentTag;
		if(parentTag.indexOf(".") > -1) 
		{
			t = parentTag.substring(0, parentTag.indexOf("."));
			return findParent(configs.get(t).childs, parentTag.substring(parentTag.indexOf(".") + 1));
		}
		else return configs.get(t);
	}

	String getInnerQry(String tag, String parentTag)
	{	
		if(tag.equals("")) return "";
		String grandParent = tag;
		if(!parentTag.equals("")) grandParent = parentTag + "." + tag;
		String q = " (json_tag = "+escape.cote(tag)+" and coalesce(parent_json_tag,'') = "+escape.cote(parentTag)+") or ";
		q += " (coalesce(parent_json_tag,'') = "+escape.cote(grandParent)+") or ";
		if(parentTag.indexOf(".") < 0)
		{
			tag = parentTag;
			parentTag = "";
		}		
		else
		{
			tag = parentTag.substring(parentTag.lastIndexOf(".") + 1);
			parentTag = parentTag.substring(0, parentTag.indexOf("."));
		}

		q += getInnerQry(tag, parentTag);
		return q;
	}

%>
<%
	Map<String, String> supportedJsFunctions = new HashMap<String, String>();
	supportedJsFunctions.put("onclick", "onclick");
	supportedJsFunctions.put("onblur", "onblur");
	supportedJsFunctions.put("onfocus", "onfocus");
	supportedJsFunctions.put("onchange", "onchange");

	String anyManualChanges = "0";

	String jsonId = parseNull(request.getParameter("jsonid"));
	try {
		int jj = Integer.parseInt(jsonId);
	} catch(Exception e) {
		out.write("{\"MSG\":\"Unable to generate script!!!\", \"RESPONSE\":\"ERROR\", \"ANY_MANUAL_CHANGES\":\""+anyManualChanges+"\"}");
		return;
	}
	
	String updateScript = parseNull(request.getParameter("updateScript"));

	String preserveManualChanges = parseNull(request.getParameter("preserveManualChanges"));


	String[] updatejsontags = request.getParameterValues("updatejsontags");
	String[] updateparentjsontags = request.getParameterValues("updateparentjsontags");

	ArrayList<String> updateTags = new ArrayList<String>();

	String q = "select * from expert_system_script where json_id = " + escape.cote(jsonId);
	if(updatejsontags != null && updatejsontags.length > 0)
	{
		q += " and (";
		for(int i=0; i<updatejsontags.length; i++)
		{
			q += getInnerQry(parseNull(updatejsontags[i]), parseNull(updateparentjsontags[i]));

			String u = "";
			if(parseNull(updateparentjsontags[i]).equals("")) u = "iJson." + updatejsontags[i];
			else u = "iJson." + parseNull(updateparentjsontags[i]) + "." + parseNull(updatejsontags[i]);
			u = u.replaceAll("\\[\\*\\]","");
			updateTags.add(u.toUpperCase());
		}
		q = q.substring(0, q.length() - 3);
		q += ") ";
	}
	
	q += " order by parent_json_tag asc, coalesce(col_seq_num,0) asc, id asc ";

	//System.out.println(q);
	Set rs = Etn.execute(q);

	Map<String, JsonToHtml> configs = new LinkedHashMap<String, JsonToHtml>();
	while(rs.next())
	{
		JsonToHtml c = new JsonToHtml();		
		c.tag = (parseNull(rs.value("json_tag")));
		c.parentTag = (parseNull(rs.value("parent_json_tag")));
		c.htmlTag = parseNull(rs.value("html_tag"));
		c.maxRows = parseNull(rs.value("max_rows"));
		c.showCol = parseNull(rs.value("show_col"));
		c.colHeader = parseNull(rs.value("col_header"));
		c.colSeqNum = parseNull(rs.value("col_seq_num"));
		c.functions = parseNull(rs.value("functions"));
		c.fieldType = parseNull(rs.value("field_type"));
		c.fieldName = parseNull(rs.value("field_name"));		
		c.fillFrom = parseNull(rs.value("fill_from"));
		c.pagination = parseNull(rs.value("add_pagination"));
		c.colCss = parseNull(rs.value("col_value_css"));
		c.colHeaderCss = parseNull(rs.value("col_header_css"));
		c.d3chart = parseNull(rs.value("d3chart"));
		c.c3chart = parseNull(rs.value("c3chart"));
		c.xaxis = parseNull(rs.value("xaxis"));
		c.xcols = parseNull(rs.value("xcols"));
		c.ycols = parseNull(rs.value("ycols"));
		c.c3col_graph_type = parseNull(rs.value("c3col_graph_type"));
		c.c3_col_groups = parseNull(rs.value("c3_col_groups"));
		c.extras = parseNull(rs.value("extra_fields"));

		//its an array so add child json tags to it
		if(!c.parentTag.equals(""))
		{
			JsonToHtml parent = findParent(configs, c.parentTag);
			if(parent != null) 
			{
				parent.childs.put(c.tag, c); //parent can be null in case no html tag was selected for it so we ignore its childs as well as in case of array childs can only appear with parent
				if(c.showCol.equals("1")) parent.hasVisibleCols = true; 
			}
		}
		else// if(c.htmlTag.equals(""))//means some html output tag is selected so we have to generate script for this otherwise we ignore it and its childs
		{
			configs.put(c.tag, c);
		}
	}
	String globalCode = "";
	ArrayList<String> globalVarsAdded = new ArrayList<String>();
	Set rsHtmls = Etn.execute("select * from expert_system_script where (parent_json_tag like '%[*]' or add_pagination = 1) and json_id = " + escape.cote(jsonId));
	boolean setGlobalJson = false;
	if(rsHtmls.rs.Rows > 0)
	{
		globalCode += "var ____" + jsonId + "_json;\n";
		setGlobalJson = true;
	}


	rsHtmls = Etn.execute("select html_tag from expert_system_script where coalesce(html_tag,'') <> '' and json_id = " + escape.cote(jsonId));
	String s = "\tvar ___" + jsonId + "__count = "+(Integer.parseInt(jsonId) * 1000)+";\n";
	if(setGlobalJson) s += "\t____" + jsonId + "_json = iJson;\n";
	//generating reset code
	s += "\n\t//<RESET_CODE>\n";
	while(rsHtmls.next())
	{
		if(parseNull(rsHtmls.value("html_tag")).equals("")) continue;
//System.out.println(rsHtmls.value("html_tag"));
		s += "\tif($('#"+parseNull(rsHtmls.value("html_tag"))+"')) {\n";
		s += "\t\tif($('#"+parseNull(rsHtmls.value("html_tag"))+"').is('input') || $('#"+parseNull(rsHtmls.value("html_tag"))+"').is('textarea')) $('#"+parseNull(rsHtmls.value("html_tag"))+"').val('');\n";
		s += "\t\telse $('#"+parseNull(rsHtmls.value("html_tag"))+"').html('');\n";
		s += "\t}\n";
	}

	s += "\t//</RESET_CODE>\n\n";
	s += "\t//<CODE_START>\n";

	String manualChangesScript = "";
	//here we are going to read the previous generated file and get the tags which are not selected by user for updated and append those in new file
	if(updateScript.equals("1") || preserveManualChanges.equals("1"))
	{
		String oldScript = "";
		BufferedReader br = null;
		try
		{
			br = new BufferedReader(new InputStreamReader(new FileInputStream(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_ui_"+jsonId+".js")));
			String line = null;
			boolean start = false;
			boolean manualStart = false;
			boolean allowLine = true;
			while ((line = br.readLine()) != null) {
				if(line.trim().equals("//</CODE_START>")) start = false;
				if(line.trim().equals("//</MANUAL_CHANGES>")) manualStart = false;
				if(start)
				{
					if(line.trim().equals(""))
					{
						if(allowLine) 
						{
							oldScript += line + "\n";
							allowLine = false;
						}
					}
					else
					{
						oldScript += line + "\n";
						allowLine = true;
					}
				}
				if(manualStart)
				{
					manualChangesScript += line + "\n";
					allowLine = true;
				}
				if(line.trim().equals("//<CODE_START>")) start = true;
				if(line.trim().equals("//<MANUAL_CHANGES>")) manualStart = true;
			}			
			br.close();
		}
		catch(Exception e)
		{
			if(br != null) br.close();
		}

		if(updateScript.equals("1"))
		{		
			for(String t : updateTags)
			{
				if(oldScript.indexOf("//<"+t+">") == -1) continue;
				String p1 = oldScript.substring(0, oldScript.indexOf("//<"+t+">"));
				String p2 = oldScript.substring(oldScript.indexOf("//</"+t+">")+6+t.length());
				oldScript = p1 + p2;
			}	
			s += oldScript;
		}
	}	

	for(String key : configs.keySet())
	{
		s += getScriptCode(jsonId, supportedJsFunctions, configs.get(key));
	}



	s += "\t//</CODE_START>\n";
	s += "\n\t//<MANUAL_CHANGES>\n";
	if(updateScript.equals("1") || preserveManualChanges.equals("1"))
	{
		if(manualChangesScript.trim().length() > 0) anyManualChanges = "1";
		s += manualChangesScript;
	}
	s += "\t//</MANUAL_CHANGES>\n";

	FileOutputStream fos = null;
	String resp = "SUCCESS";
	try
	{
		s = "/**This file is generated by Expert System.\nPlease do not change the function name and do not remove the xml tags added to the file.\nMissing xml tags can lead to errors in file after system updates the script file."+
		    "\nYou can update the code if required and upload the file to system.\nBefore update backup the current version.\nRegenerating of file or updating particular tags by system will lead to lose of your changes.\n**/\n" +
		    "//<GLOBAL_VARS>\n"+globalCode+"//</GLOBAL_VARS>\n" +
		    "function _uiDisplay"+jsonId+"(iJson) {\n\tif(!iJson) return;\n" + s + "}\n";

		fos = new FileOutputStream(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_ui_"+jsonId+".js");
		fos.write(s.getBytes("utf8"));
		fos.close();
		Etn.executeCmd("update expert_system_json set any_manual_changes = "+escape.cote(anyManualChanges)+", script_file = "+escape.cote("expsys_ui_"+jsonId+".js")+" where id = " + escape.cote(jsonId));
	}
	catch(Exception e)
	{
		if(fos != null) fos.close();
		e.printStackTrace();	
		resp = "ERROR";	
	}

	//generate d3 scripts
	rs = Etn.execute("select * from expert_system_script where json_id = " + escape.cote(jsonId) + " and coalesce(d3chart,'') <> '' ");
	String path = GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER");
//	String templatepath = "/usr/local/apache-tomcat-7.0.29/webapps/cimenter/expertSystem/d3templates/";
	String templatepath = GlobalParm.getParm("EXPERT_SYSTEM_D3_TEMPLATES_PATH");

	while(rs.next())
	{
		fos = null;
		FileInputStream fis = null;
		try
		{
			byte[] bytes = new byte[1024];
			fis = new FileInputStream(templatepath + rs.value("d3chart") + "template");
		
			String output = "";	
			int i=-1;
			while(( i = fis.read(bytes) ) != -1)
			{
				output += new String(bytes,0,i,"utf8");
			}
			output = output.replaceAll("##obj##", "d3_"+jsonId+"_" + parseNull(rs.value("parent_json_tag")).replaceAll("\\[\\*\\]","").replaceAll("\\.","_") + "_" + parseNull(rs.value("json_tag")).replaceAll("\\[\\*\\]","").replaceAll("\\.","_"));
			output = output.replaceAll("##container##", "#"+rs.value("html_tag")); 
			output = output.replaceAll("##obj_size_count_select##", "#"+rs.value("html_tag")+"_size_count_select");
				
			fos = new FileOutputStream(path + "d3_"+jsonId+"_" + parseNull(rs.value("parent_json_tag")).replaceAll("\\[\\*\\]","").replaceAll("\\.","_") + "_" + parseNull(rs.value("json_tag")).replaceAll("\\[\\*\\]","").replaceAll("\\.","_") + ".js");
			fos.write(output.getBytes("utf8"));
			fos.close();
			fis.close();
				
//				msg = "File "+ filename + " generated";
		}
		catch(Exception e)
		{
			if(fos != null) fos.close();
			if(fis != null) fis.close();
			e.printStackTrace();	
		}
	}

%>
{"MSG":"Script generated!!!", "RESPONSE":"<%=resp%>", "ANY_MANUAL_CHANGES":"<%=anyManualChanges%>"}