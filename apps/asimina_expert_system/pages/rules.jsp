<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="com.etn.sql.escape, com.etn.asimina.util.*"%>


<%@ include file="common.jsp"%>
<%
	String jsonId = parseNull(request.getParameter("jsonid"));
//	if(jsonId.equals("")) jsonId = "1";

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


	String screenName = "";
	String jsonUrl = "";
	String destpage = "";
	Set rsScr = Etn.execute("select * from expert_system_json where id = " + escape.cote(jsonId));
	if(rsScr.next())
	{
		screenName = rsScr.value("screen_name");
		jsonUrl = rsScr.value("url");
		destpage = parseNull(rsScr.value("destination_page"));
	}
	else
	{
		out.write("No screen info found against json id` = " + CommonHelper.escapeCoteValue(jsonId));
		return;
	}

	Set rs = Etn.execute("select c.id as condition_id, c.source_params, c.target_params, c.target_func, c.source_func, c.json_tag, c.operator, c.value, c.intra_condition_operator, r.id as rule_id, r.output_type, r.output_tag, r.output_val, r.exec_order from expert_system_rules r, expert_system_conditions c where r.json_id = "+escape.cote(jsonId)+" and r.id = c.rule_id order by coalesce(exec_order, 10000), r.id, c.id");

	Set rsHtml = Etn.execute("select * from expert_system_html where json_id = " + escape.cote(jsonId));
	boolean allowMatching = false;
	if(rsHtml.rs.Rows > 0) allowMatching = true;


		
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Expert System</title>

<link href="css/abcde.css" rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" />
<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/menu.css">

<style>
.tab1 {border-left: 1px solid #C0C0C0;border-top: 1px solid #C0C0C0;background: white;border-collapse: collapse;empty-cells: show;font-family: arial;font-size: 8pt;}

.tab1 thead th {
	height: 20px;	
	color: #FF6600;
	vertical-align: bottom;	
	font-weight: bold;
	border-right: 1px solid #C0C0C0;
	border-bottom: 1px solid #C0C0C0;
	padding: 5px;
}

.tab1 tr td {
	vertical-align: top;
	border-right: 1px solid #C0C0C0;
	border-bottom: 1px dotted #C0C0C0;
	padding: 7px;
}
.tab2 {border: 1px solid #C0C0C0;background: white;border-collapse: collapse;empty-cells: show;font-family: arial;font-size: 8pt;}

.tab2 thead th {
	height: 20px;	
	color: #FF6600;
	vertical-align: bottom;	
	font-weight: bold;
//	border-right: 1px solid #C0C0C0;
	border-bottom: 1px solid #C0C0C0;
	padding: 5px;
}

.tab2 tr td {
	vertical-align: top;
//	border-right: 1px solid #C0C0C0;
	border-bottom: 1px dotted #C0C0C0;
	padding: 7px;
}

</style>


<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery-ui-1.8.18.custom.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="json.js"></script>

</head>
<body>

    <%@include file="/WEB-INF/include/menu.jsp"%>
	<div style="padding-top:10px;">
		<div style='margin-left:10px;font-size:12px;margin-bottom:15px;'>
			<input type='button' value='< Back' id='backbtn' />
			&nbsp;&nbsp;
			<b>Screen Name : </b><%=CommonHelper.escapeCoteValue(screenName)%>
			<br/>
			<b>Json Url : </b><input type='text' id='jsonurl' value='<%=CommonHelper.escapeCoteValue(jsonUrl)%>' maxlength='250' size='100'/>
			&nbsp;
			<input type='button' value='Reload Json' id='reloadJsonBtn' />
			&nbsp;
			<input type='button' value='View Json' id='viewjsonbtn' />
			&nbsp;
			<input type='button' value='Script Settings' id='scriptScrBtn' />
		</div>
		<div style='margin-left:10px;font-size:12px;margin-bottom:15px;'>
			<b>Destination html path : </b><input type='text' id='destpage' value='<%=CommonHelper.escapeCoteValue(destpage)%>' maxlength='250' size='100'/>
			&nbsp;
			<input type='button' value='Reload Html' id='reloadhtmlbtn' />
			&nbsp;
			<input type='button' value='Test' id='viewtestbtn' />
			&nbsp;
			<input type='button' value='Generate Script' id='genscrbtn' />
		</div>
		<div style='margin-left:10px;font-size:12px; float:left;'>
			<div style="font-weight:bold">JSON</div>
			<div style="border:1px solid gray; padding-left:5px; padding-right:5px" id='json'></div>
		</div>
		<div style='margin-left:10px;font-size:12px; float:left; width:700px;'>
			<div>
			<table width="99%" class="tab2" cellpadding=0 cellspacing=0>
				<tr>
				<td valign="top" width='40%'>	
					<div id='sourcediv' style='cursor:pointer;' onclick="setDivBorder(1)">			
					<table width="100%">
						<tr><td align="center" colspan="3" style="font-weight:bold;">Source</td></tr>
						<tr><td style="font-weight:bold" width="20%">Tag</td><td width="2%" style="font-weight:bold">:&nbsp;</td><td id="selectedJson"></td></tr>
						<tr><td style="font-weight:bold">Property</td><td style="font-weight:bold">:&nbsp;</td><td id="jsonProperty"></td></tr>
						<tr>
							<td style="font-weight:bold">Function</td>
							<td style="font-weight:bold">:&nbsp;</td>
							<td id="jsonFunc">
								<select id='sourceFunc'>
									<option value="">-- select --</option>
									<option value="day">day</option>
									<option value="month">month</option>
									<option value="year">year</option>
									<option value="eval">eval</option>
									<option value="substring">substring</option>
								</select>
								&nbsp;
								<span id='sExtraParamSpan' style='display:none'><b>Params : </b><input type='text' id='sExtraParams' value='' /></span>
							</td>
						</tr>
						<tr>
							<td colspan='3' align='center'><input type='button' value='Reset' onclick='resetSource()'/></td>
						</tr>
					</table>
					</div>
				</td>
				<td valign="top">
					<table width="100%">
						<tr>
							<td align="center" style="font-weight:bold;">Operator</td>
						</tr>
						<tr>
							<td id="jsonOperator" align="center">
								<select id='operator'>
									<option value="">-- select --</option>
									<option value="CONTAINS">contains</option>
									<option value="STARTS">starts with</option>
									<option value="ENDS">ends with</option>
									<option value="EQUALS">=</option>
									<option value="NOT_EQUALS">!=</option>
									<option value="GREATER">&gt;</option>
									<option value="LESSER">&lt;</option>
									<option value="GREATER_EQUALS">&gt;=</option>
									<option value="LESSER_EQUALS">&lt;=</option>
								</select>
							</td>
						</tr>
					</table>
				</td>
				<td valign="top" width='40%'>
					<div id='targetdiv' style='cursor:pointer;' onclick="setDivBorder(2)">			
					<table width="100%">
						<tr><td align="center" colspan="3" style="font-weight:bold;">Target</td></tr>
						<tr><td style="font-weight:bold" width="20%">Tag</td><td width="2%" style="font-weight:bold">:&nbsp;</td><td id="selectedJson2"></td></tr>
						<tr><td style="font-weight:bold">Property</td><td style="font-weight:bold">:&nbsp;</td><td id="jsonProperty2"></td></tr>
						<tr>
							<td style="font-weight:bold">Function</td>
							<td style="font-weight:bold">:&nbsp;</td>
							<td id="jsonFunc2">
								<select id='targetFunc'>
									<option value="">-- select --</option>
									<option value="day">day</option>
									<option value="month">month</option>
									<option value="year">year</option>
									<option value="eval">eval</option>
									<option value="substring">substring</option>
								</select>
								&nbsp;
								<span id='tExtraParamSpan' style='display:none'><b>Params : </b><input type='text' id='tExtraParams' value='' /></span>
							</td>
						</tr>
						<tr>
							<td style="font-weight:bold" nowrap>Matching Value</td>
							<td style="font-weight:bold">:&nbsp;</td>
							<td id="matchingValueTd">
								<input type="text" id="txt1" value="" size="20" />
								<input type="text" id="txt2" value="" size="20" style="display:none"/>
							</td>
						</tr>
						<tr>
							<td colspan='3' align='center'><input type='button' value='Reset' onclick='resetTarget()'/></td>
						</tr>
					</table>
					</div>
				</td>
				</tr>
				<tr>
					<td align="center" colspan="3">
						<input type='button' value='Ok' id='okBtn'/>&nbsp;
						<input type='button' value='Reset All' id='resetBtn'/>
					</td>
				</tr>
			</table>
			<table width="99%" class="tab2" style="margin-top:5px;" cellpadding=0 cellspacing=0>
				<tr><td style="font-weight:bold;" align="center">Condition</td></tr>
				<tr><td height="30px"><div id="conditions"></div></td></tr>
			</table>
			<table width="99%" class='tab2' style="margin-top:5px;">
				<tr><td colspan="3" style="font-weight:bold;" align="center">Output</td></tr>
				<tr>
					<td style='font-weight:bold' width='5%' nowrap>Tag name</td>
					<td style='font-weight:bold' width='2%'>:</td>
					<td><input type='text' style='text-transform: uppercase;' id='variableName' value='' size='20' /></td>
				</tr>
				<tr>
					<td style='font-weight:bold' width='5%' nowrap>Tag value</td>
					<td style='font-weight:bold' width='2%'>:</td>
					<td><input type='text' id='variableValue' value='' size='50' /></td>
				</tr>
				<tr><td colspan="3" align="center"><input type='button' value='Add Rule' id='addRuleBtn' /></td></tr>
			</table>
			</div>
			<br/>
			<table id='allConditions' width="99%" class='tab1' >
				<thead><th width="50%">Condition</th><th width="40%">Output</th><th>Execution Order</th><th></th></thead>
			</table>
			<div id='allconditionssavebtndiv' style='align:center;'><input type='button' id='allconditionssavebtn' value='Save' /> </div>
			<br/>
			<div style='margin-top:10px'>
			<div >To display the results in html, enter the tag Ids for each json tag</div>
			<table id='outputtohtml' width="99%" class='tab1' >
				<thead><th width="50%">Json Tag</th><th width="40%">Output to Html tag Id</th></thead>
			</table>
			<div id='outputtohtmlsavebtndiv' style='align:center;display:none'><input type='button' id='outputtohtmlsavebtn' value='Save' /> </div>
			</div>
		</div>
		<div style='clear:both'></div>
	</div>
</body>
    <script type="text/javascript">
		var allowMatching = <%=CommonHelper.escapeCoteValue(allowMatching)%>;

		jQuery(document).ready(function() {
				var numOfConditions = 0;
				var totalConditions = 0;
				var selectedTagDiv = 1;

				var htmlOutputTags = new Array();
			
				toggleTagDiv=function()
				{
					if(selectedTagDiv == 1) setDivBorder(2);
					else setDivBorder(1);
				};
		
				setDivBorder=function(num)
				{
					selectedTagDiv = num;
					if(selectedTagDiv == 1)
					{
						$("#sourcediv").css("border","2px solid red");
						$("#targetdiv").css("border","none");
					}
					else
					{
						$("#sourcediv").css("border","none");
						$("#targetdiv").css("border","2px solid red");
					}
				};

				setDivBorder(1);

				$("#targetFunc").change(function(){
					if($("#targetFunc").val() == 'substring')
					{
						$("#tExtraParams").val("");
						$("#tExtraParamSpan").show();
					}
					else 					
					{
						$("#tExtraParams").val("");
						$("#tExtraParamSpan").hide();
					}						
				});

				$("#sourceFunc").change(function(){
					if($("#sourceFunc").val() == 'substring')
					{
						$("#sExtraParams").val("");
						$("#sExtraParamSpan").show();
					}
					else 					
					{
						$("#sExtraParams").val("");
						$("#sExtraParamSpan").hide();
					}						
				});

				checkExtraParams=function(funcId, paramId)
				{
					if($("#"+funcId).val() == 'substring')
					{
						if($.trim($("#"+paramId).val()) == '')
						{
							alert("For function substring you must provide start index and end index\nExample: 0,2 or 0, #.length (where # is incoming value)");
							return false;	
						}

						var params = $.trim($("#"+paramId).val());
						if(params.indexOf(",") < 0)
						{
							alert("For function substring you must provide start index and end index\nExample: 0,2 or 0, #.length (where # is incoming value)");
							return false;	
						}


						var p1 = $.trim(params.substring(0, params.indexOf(",")));
						params = $.trim(params.substring(params.indexOf(",")+1));

						if(params.indexOf(",") >= 0)
						{
							alert("For function substring you must provide start index and end index\nExample: 0,2 or 0, #.length (where # is incoming value)");
							return false;	
						}
						else
						{
							var p2 = params;
							if(p1 == '' || p2 == '')
							{
								alert("For function substring you must provide start index and end index\nExample: 0,2 or 0, #.length (where # is incoming value)");
								return false;	
							}
							if(p1.toLowerCase().indexOf(".length") < 0 && p1.match((/[^0-9]/g)))
							{
								alert("For function substring you must provide start index and end index\nExample: 0,2 or 0, #.length (where # is incoming value)");
								return false;	
							}
							if(p2.toLowerCase().indexOf(".length") < 0 && p2.match((/[^0-9]/g)))
							{
								alert("For function substring you must provide start index and end index\nExample: 0,2 or 0, #.length (where # is incoming value)");
								return false;	
							}
						}
					}
					return true;
				};				

				$("#allconditionssavebtn").click(function(){
					var data = "jsonId=<%=CommonHelper.escapeCoteValue(jsonId)%>";
					$(".ruleids").each(function(){
						data += "&ruleId=" + $(this).val();
					});
					$(".execorder").each(function(){
						data += "&execOrder=" + $(this).val();
					});

					$.ajax({
						url : 'saveExecOrder.jsp',
						type: 'POST',
						data : data,
						dataType : 'json',
						success : function(json)
						{		
							if(json.RESPONSE == 'SUCCESS') window.location='rules.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>';
							else alert("Some error occurred");
						}
					});			


				});

				showOutputTagSaveBtn=function()
				{
					if($(".outputtohtml_outputtag").length > 0) $("#outputtohtmlsavebtndiv").show();
					else $("#outputtohtmlsavebtndiv").hide();
				};


				<%
					Set distinctOutputTagsRs = Etn.execute(" select distinct output_tag, coalesce(html_tag_id,'') as html_tag_id from expert_system_rules where output_type = 'U' and json_id = "+escape.cote(jsonId));
					while(distinctOutputTagsRs.next())
					{
						out.write("htmlOutputTags.push({tag:'"+parseNull(distinctOutputTagsRs.value("output_tag"))+"', html_tag_id:'"+parseNull(distinctOutputTagsRs.value("html_tag_id"))+"'});");
						out.write("$('#outputtohtml').append(\"<tr id='outputtohtml_"+parseNull(distinctOutputTagsRs.value("output_tag"))+"'><td><span class='outputtohtml_outputtag'>"+parseNull(distinctOutputTagsRs.value("output_tag"))+"</span></td><td><input type='text' class='outputtohtml_htmltagid' size='30' value='"+parseNull(distinctOutputTagsRs.value("html_tag_id"))+"' /></td></tr>\");");
					}
				%>

				showOutputTagSaveBtn();

				$("#outputtohtmlsavebtn").click(function(){
					var data = "jsonId=<%=CommonHelper.escapeCoteValue(jsonId)%>";
					$(".outputtohtml_outputtag").each(function(){
						data += "&outputTag=" + $.trim($(this).html());
					});
					$(".outputtohtml_htmltagid").each(function(){
						data += "&htmlTagId=" + $.trim($(this).val());
					});

					$.ajax({
						url : 'saveHtmlTagsInfo.jsp',
						type: 'POST',
						data : data,
						dataType : 'json',
						success : function(json)
						{		
							alert(json.MESSAGE);
						}
					});			


				});

				resetForm=function()
				{					
					numOfConditions = 0;
					$("#conditions").html("");
					resetForm2();
				};

				resetForm2=function()
				{
					$("#selectedJson").html("");
					$("#jsonProperty").html("");
					$("#selectedJson2").html("");
					$("#jsonProperty2").html("");
					$("#operator").val("");
					$("#txt1").val("");
					$("#txt2").val("");
					$("#variableName").val("");
					$("#variableValue").val("");
					$("#sourceFunc").val("");
					$("#sExtraParams").val("");
					$("#sExtraParamSpan").hide();
					$("#targetFunc").val("");
					$("#tExtraParams").val("");
					$("#tExtraParamSpan").hide();
				};

				resetSource=function()
				{
					$("#selectedJson").html("");
					$("#jsonProperty").html("");
					$("#sourceFunc").val("");
					$("#sExtraParams").val("");
					$("#sExtraParamSpan").hide();
				};

				resetTarget=function()
				{
					$("#selectedJson2").html("");
					$("#jsonProperty2").html("");
					$("#txt1").val("");
					$("#txt2").val("");
					$("#variableName").val("");
					$("#variableValue").val("");
					$("#targetFunc").val("");
					$("#tExtraParams").val("");
					$("#tExtraParamSpan").hide();
				};

				$("#resetBtn").click(function(){
					resetForm();
				});

				$("#addRuleBtn").click(function(){
					if(numOfConditions <= 0)
					{
						alert("No condition added to rule");
						return;
					}
					var outputType = "";
					var variableName = "";
					var outputVal = "";
					var outputHtml = "";
					var data = "jsonId=<%=CommonHelper.escapeCoteValue(jsonId)%>";

/*					if($("#alertRd").is(":checked"))
					{
						outputType = "S";
						outputVal = $.trim($("#alertmsg").val());
						if(outputVal == "")
						{
							alert("No output message provided");
							$("#alertmsg").focus();
							return;
						}
						outputHtml = "Json Tag = SYSTEM_ALERT" + "<br/>Value = " + outputVal;
						data += "&outputType=S&outputValue="+outputVal;
					}
					else if($("#variableRd").is(":checked"))
					{*/
						outputType = "U";
						variableName = $.trim($("#variableName").val()).toUpperCase();
						outputVal = $.trim($("#variableValue").val());
						if(variableName == "")
						{
							alert("No output json tag name provided");
							$("#variableName").focus();
							return;
						}
						if(outputVal == "")
						{
							alert("No output value provided");
							$("#variableValue").focus();
							return;
						}
						if(variableName == "SYSTEM_ALERT")
						{
							alert("Invalid tag name. SYSTEM_ALERT is a keyword");				
							$("#variableName").focus();
							return;
						}
						outputHtml = "Json Tag = " + variableName + "<br/>Value = " + outputVal;
						data += "&outputType=U&outputValue="+encodeURIComponent(outputVal)+"&outputTagName="+variableName;
//					}	

					$("._condTag").each(function(){
						data += "&jsonTag="+$.trim($(this).html());
					});
					$("._condOp").each(function(){
						data += "&condOp="+$.trim($(this).html());
					});
					$("._condValue").each(function(){
						data += "&condValue="+$.trim($(this).html());
					});
					$(".conditionsOp").each(function(){
						data += "&intraCondOp="+$.trim($(this).val());
					});
					$("._matchingValueType").each(function(){
						data += "&condValueType="+$.trim($(this).val());
					});
					$("._sFunc").each(function(){
						data += "&sFunc="+$.trim($(this).val());
					});
					$("._tFunc").each(function(){
						data += "&tFunc="+$.trim($(this).val());
					}); 
					$("._sParam").each(function(){
						data += "&sParam="+$.trim($(this).val());
					});
					$("._tParam").each(function(){
						data += "&tParam="+$.trim($(this).val());
					});

					$.ajax({
						url : 'saveAlert.jsp',
						type: 'POST',
						data : data,
						dataType : 'json',
						success : function(json)
						{		
							alert(json.MESSAGE);
							if(json.RESPONSE == 'SUCCESS')
							{
								$("#allConditions").append("<tr id='ruleRow_"+json.RULE_ID+"'><td>"+json.CONDITION_HTML+"</td><td><span>"+json.OUTPUT_HTML+"</span></td><td><input type='hidden' class='ruleids' value='"+json.RULE_ID+"'/><input type='text' size='5' class='execorder' value=''/></td><td><input type='button' value='Delete' onclick='delRule(\""+json.RULE_ID+"\")'  /></td></tr>");

								resetForm();
								totalConditions++;		
								
								if(outputType  == 'U')
								{
									var found = false;
									for(var k=0; k<htmlOutputTags.length;k++)
									{
										if($.trim(variableName) == $.trim(htmlOutputTags[k].tag) )
										{
											found = true;
											break;
										}
									}	
									if(!found)
									{
										htmlOutputTags.push({tag:variableName,html_tag_id:''});
										$('#outputtohtml').append("<tr id='outputtohtml_"+variableName+"'><td><span class='outputtohtml_outputtag'>"+variableName+"</span></td><td><input type='text' class='outputtohtml_htmltagid' size='30' value='' /></td></tr>");
										showOutputTagSaveBtn();
									}
								}
								setDivBorder(1);
							}
						}
					});			

				
				});

				$("#operator").change(function(){
					//$("#txt1").hide();
					$("#txt2").hide();
//					$("#txt1").val("");
					$("#txt2").val("");
					if(this.value == "BETWEEN")
					{
						$("#txt1").show();
						$("#txt2").show();
					}
					else $("#txt1").show();					
				});

				$("#okBtn").click(function(){
					if($.trim($("#selectedJson").html()) == "") return;
					if($("#operator").val() == "")
					{
						alert("Select operator");
						$("#operator").focus();
						return;
					}
					if($.trim($("#txt1").val()) == "" && $.trim($("#selectedJson2").html()) == "") 
					{
						alert("Provide matching value or matching tag");
						return;
					}

					if($.trim($("#txt1").val()) != "" && $.trim($("#selectedJson2").html()) != "")
					{
						alert("Either provide matching value or matching tag");
						return;
					}

					if($("#txt2").is(":visible") && $.trim($("#txt2").val()) == "") return;
					
					var _tag = $.trim($("#selectedJson").html());
					var _tagP =  $("#_propSelect").val();
					var _op = $("#operator").val();
					var _opVal = $.trim($("#txt1").val());
					var _opTxt = $("#operator option:selected").text();
					var _sFunc = "";

					var _opValType  = 'V';//by default we asume user is providing matching value
					var _tFunc = "";
					if($.trim($("#selectedJson2").html()) != "")
					{
						_opVal = $.trim($("#selectedJson2").html()) + "." +  $("#_propSelect2").val();
						_opValType  = 'T';//matching tag was selected
//						_tFunc = ;
					}

					var _sFuncTxt = "";
					var _sFuncEndTxt = "";
					if($("#sourceFunc").val() != "") 
					{
						_sFunc = $("#sourceFunc option:selected").text();
						_sFuncTxt = _sFunc + "(";
						if($.trim($("#sExtraParams").val()) != '') _sFuncEndTxt = "," + $.trim($("#sExtraParams").val()) + ")";
						else _sFuncEndTxt = ")";
					}

					var _tFuncTxt = "";
					var _tFuncEndTxt = "";

					if($("#targetFunc").val() != "") 
					{
						_tFunc = $("#targetFunc option:selected").text();
						_tFuncTxt = _tFunc + "(";
						if($.trim($("#tExtraParams").val()) != '') _tFuncEndTxt = "," + $.trim($("#tExtraParams").val()) + ")";
						else _tFuncEndTxt = ")";
					}

					if(!checkExtraParams("sourceFunc","sExtraParams")) return false;
					if(!checkExtraParams("targetFunc","tExtraParams")) return false;

					var _sParam = $.trim($("#sExtraParams").val());
					var _tParam = $.trim($("#tExtraParams").val());

					var _cond = $.trim($("#conditions").html());
					if(numOfConditions > 0) _cond += "<span style='margin-left:2px'><select class='conditionsOp' ><option value='AND'>AND</option><option value='OR'>OR</option></select></span>";					
					_cond += "<span class='_condition'><input type='hidden' class='_sParam' value='"+_sParam+"'/><input type='hidden' class='_tParam' value='"+_tParam+"'/><input type='hidden' class='_sFunc' value='"+_sFunc+"'/><input type='hidden' class='_tFunc' value='"+_tFunc+"'/><input type='hidden' class='_matchingValueType' value='"+_opValType+"'/>"+_sFuncTxt+"<span class='_condTag' style='margin-left:2px'>"+_tag+"."+_tagP+"</span>"+_sFuncEndTxt+" <span class='_condOp' style='display:none'>"+_op+"</span><span style='margin-left:2px'>"+_opTxt+"</span> "+_tFuncTxt+"<span class='_condValue' style='margin-left:2px'>"+_opVal+"</span>"+_tFuncEndTxt+"</span>";

					$("#conditions").html(_cond);
					numOfConditions ++;

					resetForm2(); 
				});
			
			
				$.ajax({
					url : 'loadJson.jsp',
					type: 'POST',
					data : {jsonid : <%=CommonHelper.escapeCoteValue(jsonId)%>},
					success : function(resp)
					{		
						$("#json").html(resp);
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});			

			setJsonTag=function(tagProp)
			{
				if(tagProp == 2)
				{
					var _h = $("#selectedJson").html();
					if($.trim(_h.substring(_h.length - 3)) == '[*]')//ends with [*]
					{
						_h = _h.substring(0, _h.length - 3);
					}
					if($("#_propSelect").val() == "value") _h = _h + "[*]";
					$("#selectedJson").html(_h);	
				}
			};

			setJsonTag2=function(tagProp)
			{
				if(tagProp == 2)
				{
					var _h = $("#selectedJson2").html();
					if($.trim(_h.substring(_h.length - 3)) == '[*]')//ends with [*]
					{
						_h = _h.substring(0, _h.length - 3);
					}
					if($("#_propSelect2").val() == "value") _h = _h + "[*]";
					$("#selectedJson2").html(_h);	
				}
			};			

			setSelectedJson=function(tags, tagProp, tagsType)
			{
				var _id = "selectedJson";
				var _id2 = "jsonProperty";
				var _id3 = "_propSelect";
				var _func = "setJsonTag";
				var resetOthers = true;

				if(selectedTagDiv == 2)
				{
					_id = "selectedJson2";
					_id2 = "jsonProperty2";
					_id3 = "_propSelect2";
					_func = "setJsonTag2";
					resetOthers = false;
				}

				$("#"+_id).html(tags);	
				var _h = "<select id='"+_id3+"' onchange='"+_func+"(\""+tagProp+"\")'>";			
				if(tagProp == 1) _h += "<option value='length'>Length</option>";
				else if(tagProp == 3) _h += "<option value='value'>Value</option>";
				else if(tagProp == 2)
				{
					_h += "<option value='length'>Length</option>";
					_h += "<option value='value'>Value</option>";
				}
				_h += "</select>";

				$("#"+_id2).html(_h);
				if(selectedTagDiv == 1) toggleTagDiv();
/*				if(resetOthers)
				{	
					$("#operator").val("");
					$("#txt1").val("");
					$("#txt2").val("");					
				}*/
		 	};

			delRule=function(ruleId)
			{
				$.ajax({
					url : 'deleteRule.jsp',
					type: 'POST',
					data : {ruleId : ruleId},
					dataType: 'json',
					success : function(json)
					{		
						alert(json.MESSAGE);
						if(json.RESPONSE == 'SUCCESS')  
						{
							$("#ruleRow_"+ruleId).hide();
							if(json.REMOVE_OUTPUT_TAG != '')
							{								
								$('#outputtohtml tr#outputtohtml_'+json.REMOVE_OUTPUT_TAG).remove();
								for(var m=0; m<htmlOutputTags.length; m++)
								{
									if($.trim(htmlOutputTags[m].tag) == $.trim(json.REMOVE_OUTPUT_TAG)) htmlOutputTags.splice(m);
								}
							}
							showOutputTagSaveBtn();
						}
					}
				});							
			};

			
			$("#reloadJsonBtn").click(function(){
				if($.trim($("#jsonurl").val()) == '')
				{
					alert("Provide url to retrieve json from");
					return;
				}
				$.ajax({
					url : $.trim($("#jsonurl").val()),
					type: 'POST',
					dataType : 'json',
					success : function(json)
					{		
						json = clearJsonValues(json);
						$.ajax({ 
							url : 'saveScreen.jsp',
							type: 'POST',
							data : {json : JSON.stringify(json), jsonid : '<%=CommonHelper.escapeCoteValue(jsonId)%>', url : $("#jsonurl").val()},
							dataType : 'json',
							success : function(json1)
							{		
								if(json1.RESPONSE == 'SUCCESS') window.location='rules.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>';
								else alert("Some error occurred");
							}
						});			
					}
				});			
			});
		
			$("#variableName").keypress(function(e){
				var unicode = e.charCode ? e.charCode : e.keyCode;	
				if(unicode == 32) e.preventDefault();
				return true;
			});

			<% if(rs.rs.Rows > 0)
			{
			 	String prevRuleId = "";
				String condHtml = "";
				String outputHtml = "";
				String prevExecOrder = "";
				while(rs.next())
				{
					if(!prevRuleId.equals("") && !prevRuleId.equals(rs.value("rule_id")))
					{
			%>
						$("#allConditions").append("<tr id='ruleRow_<%=prevRuleId%>'><td><%=condHtml%></td><td><span><%=outputHtml%></span></td><td><input type='hidden' class='ruleids' value='<%=prevRuleId%>'/><input type='text' size='5' class='execorder' value='<%=prevExecOrder%>'/></td><td><input type='button' value='Delete' onclick='delRule(\"<%=prevRuleId%>\")'  /></td></tr>");

			<%
						condHtml = "";
						outputHtml = "";
					}

					String sFuncTxt = "";
					String sFuncEndTxt = "";
					if(!parseNull(rs.value("source_func")).equals("")) 
					{
						sFuncTxt = rs.value("source_func") + "(";
						if(parseNull(rs.value("source_params")).equals("")) sFuncEndTxt = ")";
						else sFuncEndTxt = "," + parseNull(rs.value("source_params")) + ")";
					}
					String tFuncTxt = "";
					String tFuncEndTxt = "";
					if(!parseNull(rs.value("target_func")).equals("")) 
					{
						tFuncTxt = rs.value("target_func") + "(";
						if(parseNull(rs.value("target_params")).equals("")) tFuncEndTxt = ")";
						else tFuncEndTxt = "," + parseNull(rs.value("target_params")) + ")";
					}

					condHtml += sFuncTxt + rs.value("json_tag") + sFuncEndTxt + "&nbsp;" + operators.get(rs.value("operator")) + "&nbsp;" + tFuncTxt + rs.value("value") + tFuncEndTxt + "&nbsp;" + rs.value("intra_condition_operator") + "&nbsp;";
					outputHtml = "Json Tag : " + rs.value("output_tag") + "<br/>Value : " + rs.value("output_val").replaceAll("\"","\\\\\"");
					prevRuleId = rs.value("rule_id");
					prevExecOrder = parseNull(rs.value("exec_order"));
				}
			%>
			$("#allConditions").append("<tr id='ruleRow_<%=prevRuleId%>'><td><%=condHtml%></td><td><span><%=outputHtml%></span></td><td><input type='hidden' class='ruleids' value='<%=prevRuleId%>'/><input type='text' size='5' class='execorder' value='<%=prevExecOrder%>'/></td><td><input type='button' value='Delete' onclick='delRule(\"<%=prevRuleId%>\")'  /></td></tr>");
			<% }//if rs.rs.Rows %>

			$("#scriptScrBtn").click(function(){
				window.location = "uiScript.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>";
			});

			$("#viewjsonbtn").click(function(){
				$.ajax({
					url : $.trim($("#jsonurl").val()),
					type: 'POST',
					dataType : 'json',
					success : function(json)
					{		
						var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
						propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
						propriete += ",width=1005" + ",height=800"; 
						win = window.open("","View Json", propriete);
//						$(win.document.body).html(json)
						win.document.open();
						win.document.write(JSON.stringify(json));
						win.document.close();
						win.focus(); 
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});			
			});

			$("#reloadhtmlbtn").click(function(){
				if($("#destpage").val() == '')
				{
					alert("Provide destination page complete url");
					return;
				}
				if(!confirm("Any changes not saved will be lost. Are you sure to continue?")) return;
/*				if($.trim($("#destpage").val()) != '' && !$.trim($("#destpage").val()).toLowerCase().startsWith("http"))
				{
					alert("Provide destination page complete url");
					return;
				}*/
				$.ajax({
					url : "parsehtml.jsp",
					type: 'POST',
					data : {destpage : $("#destpage").val(), jsonid : '<%=CommonHelper.escapeCoteValue(jsonId)%>'},
					dataType : 'json',
					success : function(json)
					{		
						//if(json.RESPONSE == "success" && json.ALLOW_MATCHING == "1") allowMatching = true;
						//if(json.RESPONSE == "success") $("#reloadhtmlbtn").val("Reload Html");
						//alert(json.MSG);
						window.location = "rules.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>";
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});							
			});

			<% if(!allowMatching) { %>
				$("#reloadhtmlbtn").val("Load Html");
			<% } %>

			$("#viewtestbtn").click(function(){	
				var u = $.trim($("#destpage").val());
				if(u == "") return;
				var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
				propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
				propriete += ",width=1005" + ",height=800"; 
				win = window.open("<%=request.getContextPath()%>/"+u,"Test", propriete);
				win.focus(); 								
			});

			$("#genscrbtn").click(function(){
				$.ajax({
					url : "generateRulesScript.jsp",
					type: 'POST',
					data : {jsonid : '<%=CommonHelper.escapeCoteValue(jsonId)%>'},
					dataType : 'json',
					async:false,
					success : function(json)
					{		
						alert(json.MSG);
/*						if(json.RESPONSE == 'SUCCESS')
						{
							$("#downloadScrFile").show();
							$("#updatescrbtnspan").show();
						}*/
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});							
			});

			$("#backbtn").click(function(){
				window.location = "screens.jsp";
			});


		});
    </script> 


</html>