<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap, java.io.*, com.etn.beans.app.GlobalParm, com.etn.asimina.util.*"%>

<%@ include file="common.jsp" %>

<%
	String jsonCss = "{\"css\":[";
	String jsonJs = "\"js\":[";
	String jsonFunction = "\"es_function\":\"";
	String jsonSearchBtnFunction = "\"es_sb_function\":\"";
	String anyParams = "\"anyParams\":\"1\"";


	jsonCss += "{\"path\":\""+request.getContextPath()+"/expertSystem.css\"}";
	jsonJs += "{\"path\":\""+request.getContextPath()+"/expertSystemHelper.js\"}";
	jsonJs += ",{\"path\":\""+GlobalParm.getParm("CKEDITOR_WEB_APP")+"js/jquery-1.9.1.min.js\"";
	jsonJs += ", \"children\":[{\"path\":\""+GlobalParm.getParm("CKEDITOR_WEB_APP")+"js/bootstrap.min.js\"}]}";

	String[] jsonIds = request.getParameterValues("jsonId");
	String allJsonIds= "";

	for(String jsonId: jsonIds)
	{

		Set esjrs = Etn.execute("SELECT * FROM expert_system_json WHERE json_uuid = "+escape.cote(jsonId));
		esjrs.next();
		String jid = esjrs.value("id");

		Set rs = Etn.execute("SELECT * FROM expert_system_query_params WHERE json_id = " + escape.cote(jid) + " AND param NOT LIKE '%__session_%'");
		if(rs.rs.Rows>0)
		{
			jsonSearchBtnFunction += "$('#__submit_form_es_"+CommonHelper.escapeCoteValue(jsonId)+"').click(function(){";
			jsonSearchBtnFunction += "var isPreview = '';";
			jsonSearchBtnFunction += "if(ckd.getURLParameter('is_preview') != undefined){ isPreview = '&is_preview='+ckd.getURLParameter('is_preview'); } ";
			jsonSearchBtnFunction += " ckd.fetchData($('#___es_desgin_layout_main_').attr('fetch-data-es-url'), $('#___es_desgin_layout_main_').attr('data-jsonid'), $('#__es_form_params_"+CommonHelper.escapeCoteValue(jsonId)+"').serialize()+isPreview); ";
	        jsonSearchBtnFunction += "return false;";
       	    jsonSearchBtnFunction += "});";
		}
		else anyParams = "\"anyParams\":\"0\"";
		jsonSearchBtnFunction += "\"";
	}

	for(String jsonId : jsonIds)
	{

		Set esjrs = Etn.execute("SELECT * FROM expert_system_json WHERE json_uuid = "+escape.cote(jsonId));
		esjrs.next();
		String jid = esjrs.value("id");

		if((new File(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_ui_"+CommonHelper.escapeCoteValue(jid)+".js")).length() > 0) 
			jsonJs += ",{\"path\":\""+request.getContextPath()+"/"+GlobalParm.getParm("EXPERT_SYSTEM_GENERATED_JS_URL")+"/expsys_ui_"+CommonHelper.escapeCoteValue(jid)+".js\"}";
		if((new File(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_SCRIPT_FOLDER") + "/expsys_rules_"+CommonHelper.escapeCoteValue(jid)+".js")).length() > 0) 
			jsonJs += ",{\"path\":\""+request.getContextPath()+"/"+GlobalParm.getParm("EXPERT_SYSTEM_GENERATED_JS_URL")+"/expsys_rules_"+CommonHelper.escapeCoteValue(jid)+".js\"}";
		if(allJsonIds.equals("")) allJsonIds = escape.cote(jid);
		else allJsonIds += "," + escape.cote(jid);
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
		jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/d3.v3.min.js\"}";
//		out.write("<script src=\'"+request.getContextPath()+"/js/d3.layout.js\'></script>\n");	
		d3included = true;
	}
	ArrayList<String> d3chartsadded = new ArrayList<String>();
	rs.moveFirst();
	while(rs.next())
	{
		if(!d3chartsadded.contains(rs.value("d3chart")) && parseNull(rs.value("d3chart")).length() > 0) 
		{
			jsonCss += ",{\"path\":\""+request.getContextPath()+"/css/d3/"+rs.value("d3chart")+".css\"}";
			d3chartsadded.add(rs.value("d3chart"));
		}
	}	

	jsonFunction += " { ";

	for(String jId : jsonIds)
	{

		Set esjrs = Etn.execute("SELECT * FROM expert_system_json WHERE json_uuid = "+escape.cote(jId));
		esjrs.next();
		String jnid = esjrs.value("id");

		String o = " if(jsonid == '"+CommonHelper.escapeCoteValue(jId)+"') { ";
		o += "if(typeof(_uiDisplay"+jnid+") == 'function'){ _uiDisplay"+CommonHelper.escapeCoteValue(jnid)+"(_json); } ";
		o += "if(typeof(_applyExpertSystemRules"+CommonHelper.escapeCoteValue(jnid)+") == 'function') _applyExpertSystemRules"+CommonHelper.escapeCoteValue(jnid)+"(_json); ";
		o += "}";
		jsonFunction += o;
	}
	jsonFunction += "}";
	jsonFunction += "\"";

/*
	jsonFunction += "\tfunction _applyExpertSystemRules(_json, jsonid)\n\t{\n";

	for(String jsonId : jsonIds)
	{
		String o = "\t\tif(jsonid == '"+CommonHelper.escapeCoteValue(jsonId)+"') {\n";
		o += "\t\t\tif(typeof(_uiDisplay"+CommonHelper.escapeCoteValue(jsonId)+") == 'function') _uiDisplay"+CommonHelper.escapeCoteValue(jsonId)+"(_json)\n";
		o += "\t\t\tif(typeof(_applyExpertSystemRules"+CommonHelper.escapeCoteValue(jsonId)+") == 'function') _applyExpertSystemRules"+CommonHelper.escapeCoteValue(jsonId)+"(_json);\n";
		o += "\t\t}\n";
		jsonFunction += o;
	}
	jsonFunction += "\t}\n";
	jsonFunction += "\"}";

*/	//include styling for d3
	//rs = Etn.execute("select * from expert_system_script where json_id in ("+allJsonIds+") and coalesce(d3chart,'') <> '' ");
	rs.moveFirst();
	while(rs.next())
	{
		if(parseNull(rs.value("d3chart")).length() > 0)
			jsonJs += ",{\"path\":\""+request.getContextPath()+"/"+GlobalParm.getParm("EXPERT_SYSTEM_GENERATED_JS_URL")+"/d3_"+CommonHelper.escapeCoteValue(rs.value("json_id"))+"_" + parseNull(rs.value("parent_json_tag")).replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+"_" + parseNull(rs.value("json_tag")).replaceAll("\\[\\*\\]","").replaceAll("\\.","_")+ ".js\"}";
	}

	//rs = Etn.execute("select * from expert_system_script where json_id in ("+allJsonIds+") and coalesce(c3chart,'') <> '' ");
	if(includec3)
	{
		jsonCss += ",{\"path\":\""+request.getContextPath()+"/css/c3.min.css\"}";

		if(!d3included) 
		{
			jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/d3.v3.min.js\"}";
			d3included = true;
		}
		jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/c3.min.js\"}";
		jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/c3components.js\"}";
	}
	
	//d3mapjson
	//rs = Etn.execute("select * from expert_system_script where json_id in ("+allJsonIds+") and parent_json_tag like '%d3mapjson_%' ");
	if(included3map)
	{
		//ordering of d3 js is important
		jsonCss += ",{\"path\":\""+request.getContextPath()+"/css/leaflet.css\"}";
		jsonJs += ",{\"path\":\"https://maps.google.com/maps/api/js?v=3&sensor=false\"}";
		jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/leaflet.js\"}";
		jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/Google.js\"}";
		jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/Control.FullScreen.js\"}";

		if(!d3included) 
		{
			jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/d3.v3.min.js\"}";
			d3included = true;
		}
		jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/leaflet.points-layer.js\"}";

	}
	if(included3mapchl)
	{
		if(!included3map)
		{
			//ordering of d3 js is important
			jsonCss += ",{\"path\":\""+request.getContextPath()+"/css/leaflet.css\"}";
			jsonJs += ",{\"path\":\"https://maps.google.com/maps/api/js?v=3&sensor=false\"}";
			jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/leaflet.js\"}";
			jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/Google.js\"}";
			jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/Control.FullScreen.js\"}";

			if(!d3included) 
			{
				jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/d3.v3.min.js\"}";
				d3included = true;
			}
			jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/leaflet.points-layer.js\"}";

		}
		//all d3 js must be included before this
		jsonJs += ",{\"path\":\""+request.getContextPath()+"/js/chaleur.js\"}";
	}

	jsonCss += "]";
	jsonJs += "]";
	out.write(jsonCss+","+jsonJs+","+jsonFunction+","+jsonSearchBtnFunction+","+anyParams+"}");
%>
