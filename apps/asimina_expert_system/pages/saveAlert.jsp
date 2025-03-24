<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.asimina.util.*"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.etn.sql.escape"%>

<%@ include file="common.jsp" %>

<%
	Map<String, String> operators = new HashMap<String, String>();
	operators.put("CONTAINS","contains");
	operators.put("STARTS","starts with");
	operators.put("ENDS","ends with");
	operators.put("EQUALS","=");
	operators.put("NOT_EQUALS","!=");
	operators.put("GREATER","&gt;");
	operators.put("LESSER","&lt;");
	operators.put("GREATER_EQUALS","&gt;=");
	operators.put("LESSER_EQUALS","&lt;=");

	String jsonId = parseNull(request.getParameter("jsonId"));

	String outputType = parseNull(request.getParameter("outputType"));
	String outputValue = parseNull(request.getParameter("outputValue"));
	String outputTagName = parseNull(request.getParameter("outputTagName"));

	String[] jsonTags = request.getParameterValues("jsonTag");
	String[] condOps = request.getParameterValues("condOp");
	String[] condVals = request.getParameterValues("condValue");
	String[] intraCondOps = request.getParameterValues("intraCondOp");
	String[] condValueTypes = request.getParameterValues("condValueType");
	String[] sFuncs = request.getParameterValues("sFunc");
	String[] tFuncs = request.getParameterValues("tFunc");

	String[] sParams = request.getParameterValues("sParam");
	String[] tParams = request.getParameterValues("tParam");

	String resp = "SUCCESS";
	String message = "Rule added successfully";
	int ruleId = 0;
	String conditionHtml = "";
	String outputHtml = "";

	if(jsonTags == null)
	{
		resp = "ERROR";
		message = "No conditions added to save";
	}
	else
	{
		String htmlTagId = "";
		if(!outputTagName.equals(""))
		{
			Set rsHtmlTag = Etn.execute("select html_tag_id from expert_system_rules where coalesce(html_tag_id,'') <> '' and output_tag = "+escape.cote(outputTagName)+" and json_id = " + escape.cote(jsonId));
			if(rsHtmlTag.next()) htmlTagId = rsHtmlTag.value("html_tag_id");
		}

//		outputValue = CommonHelper.escapeCoteValue(outputValue);

		if(outputTagName.equals("")) outputTagName = "SYSTEM_ALERT";
		ruleId = Etn.executeCmd("insert into expert_system_rules (json_id, output_type, output_tag, output_val, created_by, html_tag_id) values ("+escape.cote(jsonId)+","+escape.cote(outputType)+","+escape.cote(outputTagName)+","+escape.cote(outputValue)+","+escape.cote(""+Etn.getId())+","+escape.cote(htmlTagId)+") " );

		outputHtml = "Json Tag : " + CommonHelper.escapeCoteValue(outputTagName) + "<br/>Value : " + CommonHelper.escapeCoteValue(outputValue);
		
		for(int i=0; i<jsonTags.length; i++)
		{
			String _op = condOps[i];
			String _val = condVals[i];
			String _condValueType = condValueTypes[i];
			String _intraOp = "";
			String _sFunc = parseNull(sFuncs[i]);
			String _tFunc = parseNull(tFuncs[i]);

			String _sParam = parseNull(sParams[i]);
			String _tParam = parseNull(tParams[i]);


			if((i+1) < jsonTags.length) _intraOp = intraCondOps[i];
			Etn.executeCmd("insert into expert_system_conditions (rule_id, json_tag, operator, value, intra_condition_operator, value_type, source_func, target_func, source_params, target_params) values ("+escape.cote(""+ruleId)+","+escape.cote(jsonTags[i])+","+escape.cote(_op)+","+escape.cote(_val)+","+escape.cote(_intraOp)+", "+escape.cote(_condValueType)+", "+escape.cote(_sFunc)+", "+escape.cote(_tFunc)+", "+escape.cote(_sParam)+", "+escape.cote(_tParam)+") ");

			String sFuncTxt = "";
			String sFuncEndTxt = "";
			if(!_sFunc.equals("")) 
			{
				sFuncTxt = _sFunc + "(";
				if(_sParam.equals("")) sFuncEndTxt = ")";
				else sFuncEndTxt = "," + _sParam + ")";
			}
			String tFuncTxt = "";
			String tFuncEndTxt = "";
			if(!_tFunc.equals("")) 
			{
				tFuncTxt = _tFunc + "(";
				if(_tParam.equals("")) tFuncEndTxt = ")";
				else tFuncEndTxt = "," + _tParam + ")";
			}
			conditionHtml += CommonHelper.escapeCoteValue(sFuncTxt) + CommonHelper.escapeCoteValue(jsonTags[i]) + CommonHelper.escapeCoteValue(sFuncEndTxt) + "&nbsp;" + 
						operators.get(CommonHelper.escapeCoteValue(_op)) + "&nbsp;" + tFuncTxt + CommonHelper.escapeCoteValue(_val) + 
						CommonHelper.escapeCoteValue(tFuncEndTxt) + "&nbsp;" + CommonHelper.escapeCoteValue(_intraOp) + "&nbsp;";
		}
	}
	
%>

{"RESPONSE":"<%=resp%>","MESSAGE":"<%=message%>","RULE_ID":"<%=ruleId%>","CONDITION_HTML":"<%=conditionHtml%>","OUTPUT_HTML":"<%=outputHtml.replaceAll("\"","\\\\\"")%>"}