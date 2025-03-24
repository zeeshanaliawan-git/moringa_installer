<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap, java.io.*, com.etn.asimina.util.*"%>

<%@ include file="common.jsp" %>

<%

	String destPageName = parseNull(request.getParameter("dest_page_name"));

    Set destPageNameRs = Etn.execute("SELECT id FROM expert_system_json WHERE destination_page = " + escape.cote(destPageName) + " ORDER BY 1");

    Set userCreatedFiltersRs = Etn.execute("SELECT dps.destination_page, dps.auto_screen, dpf.* FROM dest_page_filters dpf, dest_page_settings dps WHERE dpf.dest_page_id = dps.id AND dps.destination_page = " + escape.cote(destPageName));

    String jsonScriptCalls = "";
    String jsonParams = "";
    String dbParams = "";
    int count = 0;
    List<String> jsonIdsList = new ArrayList<String>();

    while(destPageNameRs.next()){
		
		jsonIdsList.add(destPageNameRs.value("id"));
        jsonScriptCalls += "\n\t\t\t$.ajax({\n\t\t\t\turl : '/dev_expert_system/generatedJsps/fetchdata_" + destPageNameRs.value("id") + ".jsp',\n\t\t\t\ttype: 'POST',\n\t\t\t\tdata : queryParam,\n\t\t\t\tdataType : 'json',\n\t\t\t\tsuccess : function(json){\n\t\t\t\t\tvar expertSystemJson = _applyExpertSystemRules(json, " + destPageNameRs.value("id") + ");\n\t\t\t\t}\n\t\t\t});";
    }

    while(userCreatedFiltersRs.next()){
	
		dbParams = parseNull(userCreatedFiltersRs.value("display_name")).replaceAll(" ", "_").toLowerCase();
		
		if(dbParams.length() > 0){
			
			jsonParams += "\n\t\t\tqueryParam += 'es_param_" + dbParams + "=' + $('#" + dbParams + "').val();";
			count++;
		} 

		if(count != userCreatedFiltersRs.rs.Rows) jsonParams += "\n\t\t\tqueryParam += '&'";
	}

    if(jsonScriptCalls.length() > 0) jsonScriptCalls = "<script type=\"text/javascript\">\n\tjQuery(document).ready(function() {\n\t\tcallScriptFetchData = function(){ \n\t\t\tvar queryParam = '';" + jsonParams + jsonScriptCalls + "\n\t\t};\n\t});\n</script>";
    
    out.write("\n");

    if(jsonScriptCalls.length() > 0) out.write(jsonScriptCalls);


	out.write("<link href=\""+request.getContextPath()+"/expertSystem.css\" rel=\"stylesheet\" type=\"text/css\" />\n");
	out.write("<script src=\""+request.getContextPath()+"/expertSystemHelper.js\"></script>\n");

	String[] jsonIds = jsonIdsList.toArray(new String[jsonIdsList.size()]);
	String allJsonIds= "";
	for(String jsonId : jsonIds)
	{
		if((new File(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_ui_"+(jsonId.replaceAll("/", "").replaceAll("\\\\", ""))+".js")).length() > 0) 
			out.write("<script src=\""+request.getContextPath()+"/"+GlobalParm.getParm("EXPERT_SYSTEM_GENERATED_JS_URL")+"/expsys_ui_"+(jsonId.replaceAll("/", "").replaceAll("\\\\", ""))+".js\"></script>\n");		
		if((new File(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_rules_"+(jsonId.replaceAll("/", "").replaceAll("\\\\", ""))+".js")).length() > 0) 
			out.write("<script src=\""+request.getContextPath()+"/"+GlobalParm.getParm("EXPERT_SYSTEM_GENERATED_JS_URL")+"/expsys_rules_"+(jsonId.replaceAll("/", "").replaceAll("\\\\", ""))+".js\"></script>\n");		
		if(allJsonIds.equals("")) allJsonIds = escape.cote(jsonId);
		else allJsonIds += "," + escape.cote(jsonId);
 	}//end of for loop jsonids

	boolean d3included = false;
//	Set rs = Etn.execute("select distinct d3chart from expert_system_script where json_id in ("+allJsonIds+") and coalesce(d3chart,'') <> '' ");
	Set rs = Etn.execute("select * from expert_system_script where json_id in ("+allJsonIds+") ");
	boolean included3 = false;
	boolean included3map = false;
	boolean included3mapchl = false;
	boolean includec3 = false;

	while(rs.next())
	{
		if(parseNull(rs.value("d3chart")).length() > 0) included3 = true;
		if(parseNull(rs.value("c3chart")).length() > 0) includec3 = true;
		if(parseNull(rs.value("parent_json_tag")).length() > 0 && parseNull(rs.value("parent_json_tag")).contains("d3mapjson_")) included3map = true;
		if(parseNull(rs.value("parent_json_tag")).length() > 0 && parseNull(rs.value("parent_json_tag")).contains("d3mapchljson_")) included3mapchl = true;
	}
	if(included3)
	{
		out.write("<script src=\""+request.getContextPath()+"/js/d3.v3.min.js\"></script>\n");		
//		out.write("<script src=\""+request.getContextPath()+"/js/d3.layout.js\"></script>\n");	
		d3included = true;
	}
	ArrayList<String> d3chartsadded = new ArrayList<String>();
	rs.moveFirst();
	while(rs.next())
	{
		if(!d3chartsadded.contains(rs.value("d3chart"))) 
		{
			out.write("<link href=\""+request.getContextPath()+"/css/d3/"+rs.value("d3chart")+".css\" rel=\"stylesheet\" type=\"text/css\" />\n");
			d3chartsadded.add(rs.value("d3chart"));
		}
	}	

	out.write("<script type=\"text/javascript\">\n");
	out.write("\tfunction _applyExpertSystemRules(_json, jsonid)\n\t{\n");
	for(String jsonId : jsonIds)
	{
	//	scr += "\t"; 
		String o = "\t\tif(jsonid == '"+CommonHelper.escapeCoteValue(jsonId)+"') {\n";
		o += "\t\t\tif(typeof(_uiDisplay"+CommonHelper.escapeCoteValue(jsonId)+") == 'function') _uiDisplay"+CommonHelper.escapeCoteValue(jsonId)+"(_json)\n";
		o += "\t\t\tif(typeof(_applyExpertSystemRules"+CommonHelper.escapeCoteValue(jsonId)+") == 'function') _applyExpertSystemRules"+CommonHelper.escapeCoteValue(jsonId)+"(_json);\n";
		o += "\t\t}\n";
		out.write(o);
	}
	out.write("\t}\n");
	out.write("</script>\n");	

	//include styling for d3
	//rs = Etn.execute("select * from expert_system_script where json_id in ("+allJsonIds+") and coalesce(d3chart,'') <> '' ");
	rs.moveFirst();
	while(rs.next())
	{
		if(parseNull(rs.value("d3chart")).length() > 0)
			out.write("<script src=\""+request.getContextPath()+"/"+GlobalParm.getParm("EXPERT_SYSTEM_GENERATED_JS_URL")+"/d3_"+rs.value("json_id")+"_" + parseNull(rs.value("parent_json_tag")).replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"_" + parseNull(rs.value("json_tag")).replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+ ".js\"></script>\n");		
	}

	//rs = Etn.execute("select * from expert_system_script where json_id in ("+allJsonIds+") and coalesce(c3chart,'') <> '' ");
	if(includec3)
	{
		out.write("<link href='"+request.getContextPath()+"/css/c3.min.css' rel='stylesheet' type='text/css'>\n");
		if(!d3included) 
		{
			out.write("<script src=\""+request.getContextPath()+"/js/d3.v3.min.js\"></script>\n");		
			d3included = true;
		}
		out.write("<script src=\""+request.getContextPath()+"/js/c3.min.js\"></script>\n");		
		out.write("<script src=\""+request.getContextPath()+"/js/c3components.js\"></script>\n");		
	}
	
	//d3mapjson
	//rs = Etn.execute("select * from expert_system_script where json_id in ("+allJsonIds+") and parent_json_tag like '%d3mapjson_%' ");
	if(included3map)
	{
		//ordering of d3 js is important
		out.write("<link href='"+request.getContextPath()+"/css/leaflet.css' rel='stylesheet' type='text/css'>\n");
		out.write("<script src=\"https://maps.google.com/maps/api/js?v=3&sensor=false\"></script>\n");
		out.write("<script src=\""+request.getContextPath()+"/js/leaflet.js\"></script>\n");
		out.write("<script src=\""+request.getContextPath()+"/js/Google.js\"></script>\n");
		out.write("<script src=\""+request.getContextPath()+"/js/Control.FullScreen.js\"></script>\n");		
		if(!d3included) 
		{
			out.write("<script src=\""+request.getContextPath()+"/js/d3.v3.min.js\"></script>\n");		
			d3included = true;
		}
		out.write("<script src=\""+request.getContextPath()+"/js/leaflet.points-layer.js\"></script>\n");
	}
	if(included3mapchl)
	{
		if(!included3map)
		{
			//ordering of d3 js is important
			out.write("<link href='"+request.getContextPath()+"/css/leaflet.css' rel='stylesheet' type='text/css'>\n");
			out.write("<script src=\"https://maps.google.com/maps/api/js?v=3&sensor=false\"></script>\n");
			out.write("<script src=\""+request.getContextPath()+"/js/leaflet.js\"></script>\n");
			out.write("<script src=\""+request.getContextPath()+"/js/Google.js\"></script>\n");
			out.write("<script src=\""+request.getContextPath()+"/js/Control.FullScreen.js\"></script>\n");		
			if(!d3included) 
			{
				out.write("<script src=\""+request.getContextPath()+"/js/d3.v3.min.js\"></script>\n");		
				d3included = true;
			}
			out.write("<script src=\""+request.getContextPath()+"/js/leaflet.points-layer.js\"></script>\n");
		}
		//all d3 js must be included before this
		out.write("<script src=\""+request.getContextPath()+"/js/chaleur.js\"></script>\n");
	}

%>