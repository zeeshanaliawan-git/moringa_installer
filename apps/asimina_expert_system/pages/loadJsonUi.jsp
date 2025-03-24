<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>

<%@ include file="common.jsp" %>
<%@ include file="jsonParser.jsp" %>


<%!
	class Tag
	{
		String type;
		String id;
		String name;
	}

	String getIsSelected(String val, String currentVal)
	{
		if(val.equalsIgnoreCase(currentVal)) return "selected";
		return "";
	}

	String getFullPath(List<String> tags)
	{
		String s = "";
		for(String t : tags)
		{
			if(s.length() > 0) s += "." + t;
			else s = t;
		}
//System.out.println(s);
		return s;
	}

	String getHtmlSuggestion(String key, boolean isArray, List<Tag> tags, boolean isObject, boolean parentIsArray, int count, Map<String, JsonToHtml> configs, String defaultHeaderName, List<String> tagsPath)
	{
		String counter = ""+java.util.UUID.randomUUID();
		String jsonTag = key;
		if(isArray) jsonTag = key + "[*]";
//		System.out.println("key = " + key + ", path = " + getFullPath(tagsPath));
		String parentJsonTag = getFullPath(tagsPath);
		String _h = "<input type=\"hidden\" id=\"jsontags_"+counter+"\" name=\"jsontags\" value=\""+jsonTag+"\" /><input type=\"hidden\" id=\"parentjsontags_"+counter+"\" name=\"parentjsontags\" value=\""+parentJsonTag+"\" />";


		boolean isC3D3 = false;
		if(getActualParent(parentJsonTag).startsWith("d3json_") || getActualParent(parentJsonTag).startsWith("c3json_") || getActualParent(parentJsonTag).startsWith("d3mapjson_")|| getActualParent(parentJsonTag).startsWith("d3mapchljson_")) isC3D3 = true;

		if(isObject && !isC3D3) 
		{
			//we need to set these empty hidden inputs here so that the count of fields remain same when form is submitted
			_h += "<input type=\"hidden\" name=\"d3charts\" value=\"\" /><input type=\"hidden\" name=\"c3charts\" value=\"\" /><input type=\"hidden\" name=\"selectedoutputtags\" value=\"\" /><input type=\"hidden\" name=\"showmaxrows\" value=\"\" /><input type=\"hidden\" name=\"addpaginations\" value=\"0\" /><input type=\"hidden\" name=\"showcols\" value=\"\" /><input type=\"hidden\" name=\"colheaders\" value=\"\" /><input type=\"hidden\" name=\"colHeaderCss\" value=\"\" /><input type=\"hidden\" name=\"colcss\" value=\"\" /><input type=\"hidden\" name=\"colnums\" value=\"\" /><input type=\"hidden\" name=\"functions\" value=\"\"/><input type=\"hidden\" name=\"fieldnames\" value=\"\"/><input type=\"hidden\" name=\"fillfroms\" value=\"\"/><input type=\"hidden\" name=\"fieldtypes\" value=\"\"/>";
			return _h;
		}

		//here we skipping key, result, fmt tags inside they json returned by Alban's classes. These tags are no use for us on the front end so we dont want html to be auto generated for these
		if((getActualParent(parentJsonTag).startsWith("d3json_") || getActualParent(parentJsonTag).startsWith("d3mapjson_") || getActualParent(parentJsonTag).startsWith("d3mapchljson_") || getActualParent(parentJsonTag).startsWith("c3json_") || getActualParent(parentJsonTag).startsWith("result_qry_")) &&
		   (key.equals("key") || key.equals("result") || key.equals("fmt") || key.equals("cols")) )
		{
			//we need to set these empty hidden inputs here so that the count of fields remain same when form is submitted
			_h += "<input type=\"hidden\" name=\"d3charts\" value=\"\" /><input type=\"hidden\" name=\"c3charts\" value=\"\" /><input type=\"hidden\" name=\"selectedoutputtags\" value=\"\" /><input type=\"hidden\" name=\"showmaxrows\" value=\"\" /><input type=\"hidden\" name=\"addpaginations\" value=\"0\" /><input type=\"hidden\" name=\"showcols\" value=\"\" /><input type=\"hidden\" name=\"colheaders\" value=\"\" /><input type=\"hidden\" name=\"colHeaderCss\" value=\"\" /><input type=\"hidden\" name=\"colcss\" value=\"\" /><input type=\"hidden\" name=\"colnums\" value=\"\" /><input type=\"hidden\" name=\"functions\" value=\"\"/><input type=\"hidden\" name=\"fieldnames\" value=\"\"/><input type=\"hidden\" name=\"fillfroms\" value=\"\"/><input type=\"hidden\" name=\"fieldtypes\" value=\"\"/>";
			return _h;
		}

		String configKey = jsonTag;
		if(!parentJsonTag.equals("")) configKey = parentJsonTag + "." + jsonTag;
		JsonToHtml c = configs.get(configKey);
		String selected = "";
		if(parentIsArray)
		{
			String showColsN = "";
			String showColsY = "";			
			String colHdr = "";
			String colSeq = "";
			String functions = "";
			String fieldtype = "";
			String fieldName = "";
			String fillFrom = "";
			String colCss = "";
			String colHeaderCss = "";

			if(c == null)
			{
//				System.out.println(key + " " + defaultHeaderName);
				if(!defaultHeaderName.equals("")) colHdr = defaultHeaderName;
				else colHdr = key;
				colSeq = "" + (count + 1);
				showColsY = "selected";
			}
			else
			{
				colHdr = c.colHeader.replaceAll("&","&amp;");
				colSeq = c.colSeqNum;
				colCss = c.colCss;
				colHeaderCss = c.colHeaderCss;
				functions = c.functions;
				if(c.showCol.equals("0")) showColsN = "selected";
				else showColsY = "selected";
				fieldtype = c.fieldType;
				fieldName = c.fieldName;
				fillFrom = c.fillFrom;
			}

			//we need to set these empty hidden inputs here so that the count of fields remain same when form is submitted
			_h += "<input type=\"hidden\" name=\"d3charts\" value=\"\" /><input type=\"hidden\" name=\"c3charts\" value=\"\" /><input type=\"hidden\" name=\"selectedoutputtags\" value=\"\" /><input type=\"hidden\" name=\"showmaxrows\" value=\"\" /><input type=\"hidden\" name=\"addpaginations\" value=\"0\" />";
			_h += "<div style=\"border-top:1px solid #eee;float:left; font-size:8pt;width:530px; padding-top:1px; padding-bottom:1px;\">";
			_h += "<div>Show Col?&nbsp;<select name=\"showcols\" onchange=\"somethingchanged()\"><option "+showColsN+" value=\"0\">No</option><option "+showColsY+" value=\"1\">Yes</option></select>";
			_h += "&nbsp;&nbsp;&nbsp;Col # <input type=\"text\" name=\"colnums\" value=\""+colSeq+"\" size=\"2\" onchange=\"somethingchanged()\"/>";
			_h += "&nbsp;&nbsp;&nbsp;Col Css <input type=\"text\" name=\"colcss\" value=\""+colCss+"\" size=\"30\" onchange=\"somethingchanged()\"/> </div>";
			_h += "<div>Col header <input type=\"text\" name=\"colheaders\" value=\""+colHdr+"\" size=\"30\" onchange=\"somethingchanged()\"/>";
			_h += "&nbsp;&nbsp;&nbsp;Col Header Css <input type=\"text\" name=\"colHeaderCss\" value=\""+colHeaderCss+"\" size=\"30\" onchange=\"somethingchanged()\"/></div>";
			_h += "<div style=\"margin-top:2px;\">JS Functions <input type=\"text\" name=\"functions\" value=\""+functions+"\" size=\"70\" onchange=\"somethingchanged()\"/></div>";
			_h += "<div style=\"margin-top:2px;\">Output as <select name=\"fieldtypes\" onchange=\"somethingchanged()\"><option "+getIsSelected("label",fieldtype)+" value=\"label\">Label</option><option "+getIsSelected("text",fieldtype)+" value=\"text\">Text field</option><option "+getIsSelected("select",fieldtype)+" value=\"select\">Drop down</option></select>";
			_h += "&nbsp;&nbsp;&nbsp;Output field name <input type=\"text\" name=\"fieldnames\" value=\""+fieldName+"\" size=\"30\" onchange=\"somethingchanged()\"/>";
			_h += "</div>";
			_h += "<div style=\"margin-top:2px;\">Fill from <input type=\"text\" name=\"fillfroms\" value=\""+fillFrom+"\" size=\"30\" onchange=\"somethingchanged()\"/>";
			_h += "</div>";
			_h += "</div>";
		}
		else
		{
			String matchTo = key;
			String maxRows = "";
			boolean idfoundinhtml = false;
			String isPaginationYes = "";
			String isPaginationNo = "selected";
			String d3chart = "";
			String c3chart = "";
			String xaxis= "";
			String xcols = "";
			String ycols = "";
			String c3col_graph_type = "";
			String c3_col_groups = "";

			if(c != null) 
			{
				matchTo = c.htmlTag;
				maxRows = c.maxRows;
				if(c.pagination.equals("1"))
				{
					isPaginationYes = "selected";
					isPaginationNo = "";
				}
				d3chart = c.d3chart;
				c3chart = c.c3chart;
				xaxis = c.xaxis;
				xcols = c.xcols;
				ycols = c.ycols;
				c3col_graph_type = c.c3col_graph_type;
				c3_col_groups = c.c3_col_groups;
			}
			//if(matchTo.equals("")) matchTo = key;
			
			boolean saveRequired = false;
			_h += "<div style=\"float:left;font-size:8pt;width:530px;; padding-top:1px; padding-bottom:1px;\"><select name=\"selectedoutputtags\" onchange=\"somethingchanged()\">";				
			_h += "<option value=\"\">-- Select output tag --</option>";

			if(isArray && !isC3D3)
			{
				for(int i=0;i<tags.size();i++)
				{
					if(!tags.get(i).type.equalsIgnoreCase("table")) continue;
					if(tags.get(i).id.equalsIgnoreCase(matchTo)) 
					{
						selected = "selected";
						idfoundinhtml = true;
						if(c == null) saveRequired = true;//means we are proposing the html tag so must be saved before generating the script
					}
					else selected = "";
					_h += "<option "+selected+" value=\""+tags.get(i).id+"\">"+tags.get(i).id+"</option>";
				}
				if(c != null && !idfoundinhtml && !c.htmlTag.equals("")) _h += "<option style=\"color:red;\" selected value=\""+c.htmlTag+"\">"+c.htmlTag+"</option>";
			}
			else
			{
				for(int i=0;i<tags.size();i++)
				{
					if(tags.get(i).type.equalsIgnoreCase("table")) continue;
					if(tags.get(i).id.equalsIgnoreCase(matchTo)) 
					{
						selected = "selected";
						idfoundinhtml = true;
						if(c == null) saveRequired = true;//means we are proposing the html tag so must be saved before generating the script
					}
					else selected = "";
					_h += "<option "+selected+" value=\""+tags.get(i).id+"\">"+tags.get(i).id+"</option>";
				}
				if(c != null && !idfoundinhtml && !c.htmlTag.equals("")) _h += "<option style=\"color:red;\" selected value=\""+c.htmlTag+"\">"+c.htmlTag+"</option>";
			}
			_h += "</select>";

			if(getActualParent(parentJsonTag).startsWith("d3json_") && key.equals("data")) 
			{
				_h += "&nbsp;&nbsp;&nbsp;<select name='d3charts'>";
				_h += "<option value=''>-- d3 --</option>";				
				selected = "";
				if(d3chart.equals("circlepacking")) selected = "selected";
				_h += "<option value='circlepacking' "+selected+">Circle</option>";

				selected = "";
				if(d3chart.equals("reingoldtilfordtree")) selected = "selected";
				_h += "<option value='reingoldtilfordtree' "+selected+">Circle 2</option>";

				selected = "";
				if(d3chart.equals("dndtree")) selected = "selected";
				_h += "<option value='dndtree' "+selected+">Dnd tree</option>";

				selected = "";
				if(d3chart.equals("packhierarchy")) selected = "selected";
				_h += "<option value='packhierarchy' "+selected+">Pack Hierarchy</option>";

				selected = "";
				if(d3chart.equals("partition")) selected = "selected";
				_h += "<option value='partition' "+selected+">Partition</option>";

				selected = "";
				if(d3chart.equals("sunbursttree")) selected = "selected";
				_h += "<option value='sunbursttree' "+selected+">Sunburst tree</option>";

				selected = "";
				if(d3chart.equals("tree")) selected = "selected";
				_h += "<option value='tree' "+selected+">Tree</option>";

				selected = "";
				if(d3chart.equals("treemap")) selected = "selected";
				_h += "<option value='treemap' "+selected+">Treemap</option>";

				_h += "</select>";
			}
			else if(getActualParent(parentJsonTag).startsWith("c3json_") && key.equals("data")) 
			{
				String _tKey = configKey.replace("[*]","").replace(".","_");		
				
				_h += "<br/><select name='c3charts' onchange='c3chartchanged(this,\""+_tKey+"\");somethingchanged()'>";
				_h += "<option value=''>-- c3 --</option>";				

				selected = "";
				if(c3chart.equals("area")) selected = "selected";
				_h += "<option value='area' "+selected+">Area chart</option>";

				selected = "";
				if(c3chart.equals("bar")) selected = "selected";
				_h += "<option value='bar' "+selected+">Bar chart</option>";

				selected = "";
				if(c3chart.equals("combination")) selected = "selected";
				_h += "<option value='combination' "+selected+">Combination chart</option>";

				selected = "";
				if(c3chart.equals("donut")) selected = "selected";
				_h += "<option value='donut' "+selected+">Donut chart</option>";

				selected = "";
				if(c3chart.equals("gauge")) selected = "selected";
				_h += "<option value='gauge' "+selected+">Gauge chart</option>";

				selected = "";
				if(c3chart.equals("line")) selected = "selected";
				_h += "<option value='line' "+selected+">Line chart</option>";

				selected = "";
				if(c3chart.equals("pie")) selected = "selected";
				_h += "<option value='pie' "+selected+">Pie chart</option>";

				selected = "";
				if(c3chart.equals("scatter")) selected = "selected";
				_h += "<option value='scatter' "+selected+">Scatter chart</option>";

				selected = "";
				if(c3chart.equals("spline")) selected = "selected";
				_h += "<option value='spline' "+selected+">Spline chart</option>";

				selected = "";
				if(c3chart.equals("stackedbar")) selected = "selected";
				_h += "<option value='stackedbar' "+selected+">Stacked bar chart</option>";

				selected = "";
				if(c3chart.equals("step")) selected = "selected";
				_h += "<option value='step' "+selected+">Step chart</option>";


				_h += "</select>";

				String _s = "";
				if(c!=null) _s = getValue(c.extras, "zoom");
				_h += "<br/><b>Zoom enabled&nbsp;&nbsp;</b><select name='"+_tKey+"_zoom'>";
				String _chk = "";
				if(_s.equals("true")) _chk = "selected";
				_h += "<option value='false'>No</option><option "+_chk+" value='true'>Yes</option></select>";

				String display = "display:none";
				if(c3chart.equals("combination")) display = "";

				_h += "<div id='"+_tKey+"_c3colgraphtypespan' style='"+display+"'><span><table cellpadding=0 cellspacing=0 id='"+_tKey+"_c3colgraphtypetbl'>";
				_h += "<thead><th>Col Name</th><th>Type</th>";
				if(c3col_graph_type.length() > 0)
				{
					String[] tgt = c3col_graph_type.split(",");
					for(int u=0;u<tgt.length;u++)	
					{
						if(parseNull(tgt[u]).length() > 0)
						{
							String[] tgt2 = tgt[u].split(":");
							String __colgraphtype = parseNull(tgt2[1]);
							_h += "<tr><td><input type='text' class='_c3colgraphtypecolname' name='"+_tKey+"_c3colgraphtypecolname' size='20' value='"+parseNull(tgt2[0])+"'/></td>";
							_h += "<td><select class='_c3colgraphtypegraph' name='"+_tKey+"_c3colgraphtypegraph' ><option value=''>-------</option>";
							selected = "";
							if(__colgraphtype.equals("area")) selected = "selected";
							_h += "<option value='area' "+selected+">Area</option>";
							selected = "";
							if(__colgraphtype.equals("bar")) selected = "selected";
							_h += "<option value='bar' "+selected+">Bar</option>";
							selected = "";
							if(__colgraphtype.equals("step")) selected = "selected";
							_h += "<option value='step' "+selected+">Step</option>";
							_h += "</select></td></tr>";
						}
					}
				}

				for(int z=0; z < 5; z++) 
					_h += "<tr><td><input type='text' class='_c3colgraphtypecolname' name='"+_tKey+"_c3colgraphtypecolname' size='20' value=''/></td><td><select class='_c3colgraphtypegraph' name='"+_tKey+"_c3colgraphtypegraph' ><option value=''>-------</option><option value='area'>Area</option><option value='bar'>Bar</option><option value='step'>Step</option></select></td></tr>";
				_h += "</table></span><span style='font-size:8pt'>By default all columns will be shown as line graph</span>";
				_h += "<br/><br/><span><b>Column groups</b>&nbsp;<input type='text' name='"+_tKey+"_c3colgroups' value='"+parseNull(c3_col_groups)+"' size='50' /><br><span style='font-size:8pt'>Bar columns to be shown as stacked bars should be provided here. Format is col1,col2#col3,col4 First group is col1 & col2 which will be stacked and second stack is col3 & col4</span></span>";
				_h += "</div>";
				_h += "<br/>";

				_h += "<b>x-axis</b>&nbsp;&nbsp;<select class='c3xaxis' id='"+_tKey+"_xaxis' name='"+_tKey+"_xaxis' onchange='xaxischange(\""+_tKey+"\");somethingchanged()'>";
				_h += "<option value=''>------------</option>";				
				selected = "";
				if(xaxis.equals("category")) selected = "selected";
				_h += "<option value='category' "+selected+">Category</option>";				
				selected = "";
				if(xaxis.equals("timeseries")) selected = "selected";
				_h += "<option value='timeseries' "+selected+">Timeseries</option>";				
				selected = "";
				if(xaxis.equals("pivot-timeseries")) selected = "selected";
				_h += "<option value='pivot-timeseries' "+selected+">Pivot Timeseries</option>";				
				_h += "</select>";

				display = "display:none";
				String categoryXCol = xcols;
				if(!xaxis.equals("category")) categoryXCol = "";
				if(xaxis.equals("category")) display = "";
				_h += "&nbsp;&nbsp;&nbsp;<span id='"+_tKey+"_c3categorycolspan' style='"+display+"' ><b>Category col</b>&nbsp;&nbsp;<input type='text' onchange='somethingchanged()' id='"+_tKey+"_c3categorycol' name='"+_tKey+"_c3categorycol' size='30' value='"+categoryXCol+"'/></span>";
	
				display = "display:none";
				if(xaxis.equals("timeseries")) display = "";
				_h += "&nbsp;&nbsp;&nbsp;<span id='"+_tKey+"_c3timeseriesxyspan' style='"+display+"' >";
				_h += "<table cellpadding=0 cellspacing=0 id='"+_tKey+"_c3timeseriesxytbl'>";
				_h += "<thead><th>X Col</th><th>Y Col</th></thead>";
				if(xaxis.equals("timeseries"))
				{
					String[] _xcols = xcols.split(",");
					String[] _ycols = ycols.split(",");
					if(_xcols != null)
					{
						for(int z=0; z < _xcols.length; z++) 
							_h += "<tr><td><input type='text' onchange='somethingchanged()' id='"+_tKey+"_c3timeseriesxcols' name='"+_tKey+"_c3timeseriesxcols' size='30' value='"+_xcols[z]+"'/></td><td><input type='text' onchange='somethingchanged()' id='"+_tKey+"_c3timeseriesycols' name='"+_tKey+"_c3timeseriesycols' size='30' value='"+_ycols[z]+"'/></td></tr>";
					}
				}
				for(int z=0; z < 3; z++) 
					_h += "<tr><td><input type='text' id='"+_tKey+"_c3timeseriesxcols' name='"+_tKey+"_c3timeseriesxcols' size='30' value=''/></td><td><input type='text' id='"+_tKey+"_c3timeseriesycols' name='"+_tKey+"_c3timeseriesycols' size='30' value=''/></td></tr>";

				_h += "</table>";
				_h += "</span>";
			}
			else if(getActualParent(parentJsonTag).startsWith("d3mapchljson_") && key.equals("data")) 
			{
				String _tKey = configKey.replace("[*]","").replace(".","_");		

				_h += "&nbsp;&nbsp;&nbsp;<span >";
				_h += "<table cellpadding=0 cellspacing=0>";
				String _s = "";
				if(c!=null) _s = getValue(c.extras, "geo_type");
				_h += "<tr><td>Geo type</td><td>&nbsp;:&nbsp;</td><td><input type='text' size='30' value='"+_s+"' name='"+_tKey+"_geotype' /></td></tr>";
				_s = "";
				if(c!=null) _s = getValue(c.extras, "scale");
				_h += "<tr><td>Scale</td><td>&nbsp;:&nbsp;</td><td><input type='text' size='3' value='"+_s+"' name='"+_tKey+"_scale' /></td></tr>";
				_h += "</table>";
				_h += "</span>";
			}
			else if(getActualParent(parentJsonTag).startsWith("d3mapjson_") && key.equals("data")) 
			{
				String _tKey = configKey.replace("[*]","").replace(".","_");		

				_h += "&nbsp;&nbsp;&nbsp;<span >";
				_h += "<table cellpadding=0 cellspacing=0>";
				String _s = "";
				if(c!=null) _s = getValue(c.extras, "geo_type");
				_h += "<tr><td>Geo type</td><td>&nbsp;:&nbsp;</td><td><input type='text' size='30' value='"+_s+"' name='"+_tKey+"_geotype' /></td></tr>";
				_s = "";
				_h += "</table>";
				_h += "</span>";
			}


			if(isArray && !isC3D3) _h += "<input type=\"hidden\" name=\"d3charts\" value=\"\" /><input type=\"hidden\" name=\"c3charts\" value=\"\" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Show max rows : <input type=\"text\" name=\"showmaxrows\" value=\""+maxRows+"\" size=\"4\" onchange=\"somethingchanged()\"/>&nbsp;&nbsp;&nbsp;&nbsp;Add pagination : <select onchange=\"somethingchanged()\" name=\"addpaginations\"><option "+isPaginationNo+" value=\"0\">No</option><option "+isPaginationYes+" value=\"1\">Yes</option></select>";
			else if(getActualParent(parentJsonTag).startsWith("d3json_") && key.equals("data")) _h += "<input type=\"hidden\" name=\"c3charts\" value=\"\" /><input type=\"hidden\" name=\"showmaxrows\" value=\"\" /><input type=\"hidden\" name=\"addpaginations\" value=\"0\" />";
			else if(getActualParent(parentJsonTag).startsWith("d3mapjson_") && key.equals("data")) _h += "<input type=\"hidden\" name=\"d3charts\" value=\"\" /><input type=\"hidden\" name=\"c3charts\" value=\"\" /><input type=\"hidden\" name=\"showmaxrows\" value=\"\" /><input type=\"hidden\" name=\"addpaginations\" value=\"0\" />";
			else if(getActualParent(parentJsonTag).startsWith("d3mapchljson_") && key.equals("data")) _h += "<input type=\"hidden\" name=\"d3charts\" value=\"\" /><input type=\"hidden\" name=\"c3charts\" value=\"\" /><input type=\"hidden\" name=\"showmaxrows\" value=\"\" /><input type=\"hidden\" name=\"addpaginations\" value=\"0\" />";
			else if(getActualParent(parentJsonTag).startsWith("c3json_") && key.equals("data")) _h += "<input type=\"hidden\" name=\"d3charts\" value=\"\" /><input type=\"hidden\" name=\"showmaxrows\" value=\"\" /><input type=\"hidden\" name=\"addpaginations\" value=\"0\" />";
			else _h += "<input type=\"hidden\" name=\"d3charts\" value=\"\" /><input type=\"hidden\" name=\"c3charts\" value=\"\" /><input type=\"hidden\" name=\"showmaxrows\" value=\"\" /><input type=\"hidden\" name=\"addpaginations\" value=\"0\" />";

			_h += "<input type=\"hidden\" name=\"showcols\" value=\"\" /><input type=\"hidden\" name=\"colheaders\" value=\"\" /><input type=\"hidden\" name=\"colHeaderCss\" value=\"\" /><input type=\"hidden\" name=\"colcss\" value=\"\" /><input type=\"hidden\" name=\"colnums\" value=\"\" /><input type=\"hidden\" name=\"fieldtypes\" value=\"\"/><input type=\"hidden\" name=\"functions\" value=\"\"/><input type=\"hidden\" name=\"fieldnames\" value=\"\"/><input type=\"hidden\" name=\"fillfroms\" value=\"\"/>";
			_h += "</div>";
			if(saveRequired) _h += "<input type=\"hidden\" class=\"saveRequired\" value=\"1\" />";
		}
		if(!parentIsArray) _h += "<div style=\"float:right; width:20px\"><input type=\"checkbox\" class=\"updatetags\" value=\""+counter+"\" /></div>";
		return _h;
	}

	String getHtml(Map<String, Object> map, int level, List<Tag> tags, boolean parentIsArray, String parentJsonTag, Map<String, JsonToHtml> configs, List<String> tagsPath )
	{
		String html = "";
		int width = 310;
		int margin = 0;
		margin = 15*level;
		width = width - margin;

		int count = 0;
		for(String key : map.keySet())
		{   
			String font = "";
			String fontcolor = "";
			if(level == 0) fontcolor = "color:green;";
			else if(level == 1) fontcolor = "color:blue;";
			else if(level == 2) fontcolor = "color:black;";
			else if(level == 3) fontcolor = "color:red;";
			String border = "";
			if(parentIsArray) border = "border-top:1px solid #eee;";

			if(getActualParent(parentJsonTag).startsWith("d3json_") && key.equals("data"))
			{
				String uiSuggestion = getHtmlSuggestion(key, ((MyObject)map.get(key)).isArray, tags, ((MyObject)map.get(key)).isObject, parentIsArray, count++, configs, parseNull(((MyObject)map.get(key)).defaultHeaderName), tagsPath);
//System.out.println("in here");
				if(level == 0) html += "<div style=\"border-top:1px solid #ccc; padding-top:2px; padding-bottom:2px;\">";
				html += "<div style=\"margin-left:"+margin+"px; width:"+width+"px; font-size:11px; float:left;"+border+font+fontcolor+"\">"+key+"</div>" + uiSuggestion;
				html += "<div style=\"clear:both\"></div>";
				if(level == 0) html += "</div>";         
			}
			else if(getActualParent(parentJsonTag).startsWith("d3mapjson_") && key.equals("data"))
			{
				String uiSuggestion = getHtmlSuggestion(key, ((MyObject)map.get(key)).isArray, tags, ((MyObject)map.get(key)).isObject, parentIsArray, count++, configs, parseNull(((MyObject)map.get(key)).defaultHeaderName), tagsPath);
//System.out.println(uiSuggestion);
				if(level == 0) html += "<div style=\"border-top:1px solid #ccc; padding-top:2px; padding-bottom:2px;\">";
				html += "<div style=\"margin-left:"+margin+"px; width:"+width+"px; font-size:11px; float:left;"+border+font+fontcolor+"\">"+key+"</div>" + uiSuggestion;
				html += "<div style=\"clear:both\"></div>";
				if(level == 0) html += "</div>";         
			}
			else if(getActualParent(parentJsonTag).startsWith("d3mapchljson_") && key.equals("data"))
			{
				String uiSuggestion = getHtmlSuggestion(key, ((MyObject)map.get(key)).isArray, tags, ((MyObject)map.get(key)).isObject, parentIsArray, count++, configs, parseNull(((MyObject)map.get(key)).defaultHeaderName), tagsPath);
//System.out.println(uiSuggestion);
				if(level == 0) html += "<div style=\"border-top:1px solid #ccc; padding-top:2px; padding-bottom:2px;\">";
				html += "<div style=\"margin-left:"+margin+"px; width:"+width+"px; font-size:11px; float:left;"+border+font+fontcolor+"\">"+key+"</div>" + uiSuggestion;
				html += "<div style=\"clear:both\"></div>";
				if(level == 0) html += "</div>";         
			}
			else if(getActualParent(parentJsonTag).startsWith("c3json_") && key.equals("data"))
			{
				String uiSuggestion = getHtmlSuggestion(key, ((MyObject)map.get(key)).isArray, tags, ((MyObject)map.get(key)).isObject, parentIsArray, count++, configs, parseNull(((MyObject)map.get(key)).defaultHeaderName), tagsPath);
//System.out.println(uiSuggestion);
				if(level == 0) html += "<div style=\"border-top:1px solid #ccc; padding-top:2px; padding-bottom:2px;\">";
				html += "<div style=\"margin-left:"+margin+"px; width:"+width+"px; font-size:11px; float:left;"+border+font+fontcolor+"\">"+key+"</div>" + uiSuggestion;
				html += "<div style=\"clear:both\"></div>";
				if(level == 0) html += "</div>";         
			}
			else
			{

//			String s = level + " " + key;
//			if(map.get(key) instanceof MyObject) s += " " +((MyObject)map.get(key)).isArray;
//			System.out.println(level + " " + key);
				if(level == 0) html += "<div style=\"border-top:1px solid #ccc; padding-top:2px; padding-bottom:2px;\">";
 
				String uiSuggestion = "";

				if(map.get(key) instanceof MyObject) uiSuggestion = getHtmlSuggestion(key, ((MyObject)map.get(key)).isArray, tags, ((MyObject)map.get(key)).isObject, parentIsArray, count++, configs, parseNull(((MyObject)map.get(key)).defaultHeaderName), tagsPath);
				else uiSuggestion = getHtmlSuggestion(key, false, tags, false, parentIsArray, count++, configs, "", tagsPath); 

				if(map.get(key) instanceof MyObject && (((MyObject)map.get(key)).isArray || ((MyObject)map.get(key)).isObject)) font = "font-weight:bold;";

				String reusehtml = "";
				if(!key.contains("___escp_") && level == 0) reusehtml = "&nbsp;&nbsp;&nbsp;<input type='button' value='reuse' onclick='reuse(\""+key+"\")' />";
				else if(key.contains("___escp_") && level == 0) reusehtml = "&nbsp;&nbsp;&nbsp;<input type='button' value='Remove' onclick='removereuse(\""+key+"\")' />";

				html += "<div style=\"margin-left:"+margin+"px; width:"+width+"px; font-size:11px; float:left;"+border+font+fontcolor+"\">"+key+reusehtml+"</div>"+uiSuggestion;
				html += "<div style=\"clear:both\"></div>";
            
				if(map.get(key) instanceof MyObject)
				{
					if(((MyObject)map.get(key)).isArray) tagsPath.add(key + "[*]");
					else tagsPath.add(key);
					level ++;
					html += getHtml(((MyObject)map.get(key)).map, level, tags, ((MyObject)map.get(key)).isArray, key, configs, tagsPath);
					level --;
					tagsPath.remove(tagsPath.size() - 1);
				}   			
				if(level == 0) html += "</div>";         
			}
		}
		return html;
	}


%>
<%
	String jsonId = parseNull(request.getParameter("jsonid"));
//	if(jsonId.equals("")) jsonId = "1";

	Set rsScr = Etn.execute("select json from expert_system_json where id = " + escape.cote(jsonId));

	try{ 

		rsScr.next();
	}catch(Exception e){

		e.printStackTrace();
	}

	JsonParser parser = new JsonParser();
	Map<String, Object> map = parse(parser, rsScr.value("json"), new ArrayList<ColsDatas>());        
	List<Tag> tags = new ArrayList<Tag>();
	Set rsHtml = Etn.execute("select * from expert_system_html where json_id = " + escape.cote(jsonId));
	while(rsHtml.next())
	{
		Tag t = new Tag();
		t.type = parseNull(rsHtml.value("tag_type"));
		t.id = parseNull(rsHtml.value("tag_id"));
		t.name = parseNull(rsHtml.value("tag_name"));
		tags.add(t);
	}
	
	Map<String, JsonToHtml> configs = new HashMap<String, JsonToHtml>();
	Set rsScript = Etn.execute("select * from expert_system_script where json_id = "  + escape.cote(jsonId));
	while(rsScript.next())
	{
		JsonToHtml c = new JsonToHtml();
		c.tag = parseNull(rsScript.value("json_tag"));
		c.parentTag = parseNull(rsScript.value("parent_json_tag"));
		c.htmlTag = parseNull(rsScript.value("html_tag"));
		c.maxRows = parseNull(rsScript.value("max_rows"));
		c.showCol = parseNull(rsScript.value("show_col"));
		c.colHeader = parseNull(rsScript.value("col_header"));
		c.colSeqNum = parseNull(rsScript.value("col_seq_num"));
		c.functions = parseNull(rsScript.value("functions"));
		c.fieldType = parseNull(rsScript.value("field_type"));
		c.fieldName = parseNull(rsScript.value("field_name"));
		c.fillFrom = parseNull(rsScript.value("fill_from"));
		c.pagination = parseNull(rsScript.value("add_pagination"));
		c.colCss = parseNull(rsScript.value("col_value_css"));
		c.colHeaderCss = parseNull(rsScript.value("col_header_css"));
		c.d3chart = parseNull(rsScript.value("d3chart"));
		c.c3chart = parseNull(rsScript.value("c3chart"));
		c.xaxis = parseNull(rsScript.value("xaxis"));
		c.xcols = parseNull(rsScript.value("xcols"));
		c.ycols = parseNull(rsScript.value("ycols"));
		c.c3col_graph_type = parseNull(rsScript.value("c3col_graph_type"));
		c.c3_col_groups = parseNull(rsScript.value("c3_col_groups"));
		c.extras = parseNull(rsScript.value("extra_fields"));

		String key = c.tag;
		if(!c.parentTag.equals("")) key = c.parentTag + "." + c.tag;
		configs.put(key, c);
	}

	int level = 0;
	List<String> tagsPath = new ArrayList<String>();

	Map<String, Object> newmap = new LinkedHashMap<String, Object>();
	for(String key : map.keySet())
	{
		newmap.put(key, map.get(key));
		Set r1 = Etn.execute("select * from expert_system_reuse_json where json_id = " + escape.cote(jsonId) + " and json_tag = " + escape.cote(key));
		while(r1.next())
		{
			newmap.put(key + "___escp_" + r1.value("id"), map.get(key));
		}
	}

	String html = getHtml(newmap, level, tags, false, "", configs, tagsPath);

	out.write(html);
%>