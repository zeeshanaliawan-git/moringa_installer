<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap, com.etn.asimina.util.CommonHelper"%>
<%@ page import="com.etn.sql.escape, java.io.File, com.etn.beans.app.GlobalParm"%>

<%@ include file="common.jsp" %>
<%
	String jsonId = parseNull(request.getParameter("jsonid"));
	String msg = parseNull(request.getParameter("msg"));
	String generateScriptAutomatic = parseNull(request.getParameter("generateScriptAutomatic"));

	String screenName = "";
	String jsonUrl = "";
	String destpage = "";
	String anyManualChanges = "0";
	Set rsScr = Etn.execute("select screen_name, url, destination_page, any_manual_changes, script_file, last_backup from expert_system_json where id = " + escape.cote(jsonId));

	if(rsScr.next())
	{
		screenName = rsScr.value("screen_name");
		jsonUrl = rsScr.value("url");
		destpage = parseNull(rsScr.value("destination_page"));
		anyManualChanges = parseNull(rsScr.value("any_manual_changes"));

	}
	else
	{
		out.write("No screen info found against json id = " + CommonHelper.escapeCoteValue(jsonId));
		return;
	}

	boolean generatedHtmlFound = false;
	try
	{
		File _file = new File(GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_JSP_FOLDER") + "html_" + (jsonId.replaceAll("/", "").replaceAll("\\\\", "")) + ".jsp");
		if(_file.length() > 0) generatedHtmlFound = true;
	}
	catch(Exception e) {}

	Set rsHtml = Etn.execute("select * from expert_system_html where json_id = " + escape.cote(jsonId));
	boolean allowMatching = false;
	if(rsHtml.rs.Rows > 0) allowMatching = true;

	Set rsRules = Etn.execute("select * from expert_system_rules where json_id = " + escape.cote(jsonId)); 
	String rulesBtn = "";
	if(rsRules.rs.Rows > 0) rulesBtn = "background-color:green;color:white;font-weight:bold;";
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Expert System</title>

<link href="css/abcde.css" rel="stylesheet" type="text/css" />
<link type="text/css" rel="stylesheet" href="<%=request.getContextPath()%>/css/menu.css">

<link rel="stylesheet" type="text/css" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" />

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

.no-close .ui-dialog-titlebar {display: none }

</style>



<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery-ui-1.8.18.custom.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="json.js"></script>

</head>
<body>

    <%@include file="/WEB-INF/include/menu.jsp"%>
	<div style="padding-top:10px; margin-left:10px;">
		<div style='margin-left:10px;font-size:12px;'>
			<input type='button' value='< Back' id='backbtn' />
			&nbsp;&nbsp;
			<b>Screen Name : </b><%=screenName%>&nbsp;&nbsp;&nbsp;
			&nbsp; 
			<b>Json Url : </b><input type='text' id='jsonurl' value='<%=jsonUrl.replaceAll("'","&#39;")%>' maxlength='250' size='100'/>
			&nbsp;
			<input type='button' value='Reload Json' id='reloadJsonBtn' />
			&nbsp;
			<input type='button' value='Json Query' id='jsonQryBtn' />
			&nbsp;
<!-- 			<input type='button' value='Requete Query' id='jsonQryRequeteBtn' />
			&nbsp;
 -->			<input type='button' value='View Json' id='viewjsonbtn' />
			&nbsp;
			<input style='<%=rulesBtn%>' type='button' value='Rules Screen' id='rulesScrBtn' />
		</div>
		<div style='margin-left:10px;font-size:12px;margin-bottom:15px;'>
			<b>Destination html path : </b><input type='text' id='destpage' value='<%=destpage%>' maxlength='250' size='100'/>
			&nbsp;
			<input type='button' value='Reload Html' id='reloadhtmlbtn' />
			&nbsp;
			<input type='button' value='Test' id='viewtestbtn' />
			&nbsp;
			<input type='button' value='Generate Html' id='generateHtmlBtn' />
			<% if(generatedHtmlFound) { %>
				&nbsp;
				<input type='button' value='Download Html' id='downloadHtmlBtn' />
			<%}%>
		</div>
		<div style='margin-left:10px;font-size:12px;margin-bottom:20px;'>
			<div style='text-align:center; width:1000px'>
				<input type='button' value='Reset All' id='resetbtn' />
				&nbsp;&nbsp;&nbsp;
				<input type='button' value='Save Settings' id='savebtn' />
				&nbsp;&nbsp;&nbsp;
				<input type='button' value='Generate Script' id='genscrbtn' />
				&nbsp;&nbsp;&nbsp;
				<% 
					String displayUpdateBtn = "display:none;";
					if(!parseNull(rsScr.value("script_file")).equals("")) displayUpdateBtn = "";
				%>
				<span style='<%=displayUpdateBtn%>' id='updatescrbtnspan'>
					<input type='button' value='Update Script for all' id='updallscrbtn' />
					&nbsp;&nbsp;&nbsp;
					<input type='button' value='Update Script' id='updscrbtn' />
					&nbsp;&nbsp;&nbsp;
				</span>
				<input type='button' value='Backup Script' id='bkupbtn' />
			</div>
			<div style='float:left; width:900px;'>
				<div style="font-weight:bold;">
					<div style="float:left; width:320px;">Incoming JSON</div>
					<div style="float:left; width:530px;">Output Html Tag</div>
					<div style="float:left; width:30px;">Update?</div>
					<div style="clear:both"></div>
				</div> 
				<form id='myfrm' action='saveScriptSettings.jsp' method='post'>					
					<div style="border:1px solid gray; padding-left:5px; padding-right:5px" id='json'>Loading please wait ..........</div>
					<input type='hidden' name='jsonid' value='<%=CommonHelper.escapeCoteValue(jsonId)%>' />
				</form>
			</div>
			<div style='float:left; margin-left:10px;'>
				<div style="font-weight:bold;">Script Files</div>
				<div style='border:1px solid gray; padding-left:15px; padding-right:15px; padding-bottom:2px;'>
					<% if(anyManualChanges.equals("1")) {%>
						<div id='manualwarning' style='font-weight:bold; color:red'>WARNING!!! There are manual changes <br/> in script file</div>
					<% }%>
					<% 
						String displayScrFile = "display:none;";
						if(!parseNull(rsScr.value("script_file")).equals("")) displayScrFile = "";
						String displayBackupFile = "display:none;";
						if(!parseNull(rsScr.value("last_backup")).equals("")) displayBackupFile = "";
					%>
					<div style='padding-top:2px;<%=displayScrFile%>' id='downloadScrFile'><a href='javascript:download(1)'>Download script file</div></a>
					<div style='margin-bottom:10px;<%=displayScrFile%>' id='downloadScrFile2'><input type='button' value='Edit Script' id='editscriptbtn' /></div>
					<div style='margin-bottom:10px;<%=displayBackupFile%>' id='downloadBackupFile'><a href='javascript:download(2)'>Download backup script file</div></a>
				</div>
				<div style='margin-top:15px'>
					<input type='button' value='Instructions' onclick="openinstructions()"/>
				</div>
			</div>
			<div style='clear:both'></div>
		</div>
	</div>
	<input type='hidden' id='anymanualchanges' value='<%=anyManualChanges%>' />
<div id="loader" style='display:none' title=""><img src='img/loading_timer.gif' alt='Please wait...' /></div>
</body>
    <script type="text/javascript">

		var allowMatching = <%=allowMatching%>;

		var somethingischanged = false;

		jQuery(document).ready(function() {

	       	$("#loader").dialog({
       	     		bgiframe: true, autoOpen: false, height: "auto", width:"auto", modal: true, resizable : false,
				closeOnEscape: false,
				dialogClass: 'no-close'
			});

			reloadJson=function()
			{

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
								if(json1.RESPONSE == 'SUCCESS') window.location='uiScript.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>';
								else alert("Some error occurred");
							}
						});			
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});			
			};

			$("#reloadJsonBtn").click(function(){
				if($.trim($("#jsonurl").val()) == '')
				{
					alert("Provide url to retrieve json from");
					return;
				}
				if(!confirm("Any unsaved changes in script will be lost. Do you wish to continue reload json?")) return;
				reloadJson();
			});

			$("#savebtn").click(function(){
				$("#myfrm").submit();
			});

			$.ajax({
				url : 'loadJsonUi.jsp',
				type: 'POST',
				data : {jsonid : <%=CommonHelper.escapeCoteValue(jsonId)%>},
				async : false,
				beforeSend: function()
				{
					$("#loader").dialog('open');
				},
				success : function(html)
				{		
					$("#loader").dialog('close');
					$("#json").html(html);
					//we suggest html tags to user for the very first time so we have to indicate to them to save settings before generating script
					if($(".saveRequired").length > 0) somethingischanged = true;
				},
				error : function()
				{
					$("#loader").dialog('close');
					alert("Some error occurred while communicating with the server");
				}
			});		
			
			<% if(!allowMatching) { %>
				$("#reloadhtmlbtn").val("Load Html");
			<% } %>

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
						alert(json.MSG);
						//window.location = "uiScript.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>";
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});							
			});

			generateTheScript=function()
			{
				$.ajax({
					url : "generateScript.jsp",
					type: 'POST',
					data : {jsonid : '<%=CommonHelper.escapeCoteValue(jsonId)%>'},
					dataType : 'json',
					async:false,
					success : function(json)
					{		
						alert(json.MSG);
						if(json.RESPONSE == 'SUCCESS')
						{
							$("#downloadScrFile").show();
							$("#downloadScrFile2").show();
							$("#updatescrbtnspan").show();
							showHideWarning(0);
//							$("#manualwarning").hide();
//							$("#anymanualchanges").val('0');
						}
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});							
			};

			$("#genscrbtn").click(function(){
				if(somethingischanged && !confirm("There seems to be some changes in configuration. Continue without save means changes wont be visible in generated file")) return;

				if($("#anymanualchanges").val() == '1')
					if(!confirm("There are manual changes in script which will be lost. Are you sure to regenerate all script?")) return;

				backupTheFile(false);
				generateTheScript();
			});

			$("#updallscrbtn").click(function(){
				if(somethingischanged && !confirm("There seems to be some changes in configuration. Continue without save means changes wont be visible in generated file")) return;

				var data = "jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>&preserveManualChanges=1";
				$.ajax({
					url : "generateScript.jsp",
					type: 'POST',
					data : data,
					dataType : 'json',
					async:false,
					success : function(json)
					{		
						alert(json.MSG);
						if(json.RESPONSE == 'SUCCESS' && json.ANY_MANUAL_CHANGES == '1')
						{
							showHideWarning(1);
//							$("#manualwarning").show();
//							$("#anymanualchanges").val('1');
						}
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});							
			});

			$("#updscrbtn").click(function(){
				if(!$('.updatetags').is(':checked'))
				{
					alert("Select tags for which to update the script file");
					return;
				}

				if(somethingischanged && !confirm("There seems to be some changes in configuration. Continue without save means changes wont be visible in generated file")) return;

				var data = "jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>&updateScript=1";
				$('.updatetags').each(function(){
					if(this.checked)
					{
						var val = $(this).val();
						var selectedTag = $("#jsontags_"+val).val();
						var selectedParentTag = $("#parentjsontags_"+val).val();
						data += "&updatejsontags="+selectedTag;
						data += "&updateparentjsontags="+selectedParentTag;
					}
				});

				$.ajax({
					url : "generateScript.jsp",
					type: 'POST',
					data : data,
					dataType : 'json',
					async:false,
					success : function(json)
					{		
						alert(json.MSG);
						if(json.RESPONSE == 'SUCCESS' && json.ANY_MANUAL_CHANGES == '1')
						{
							showHideWarning(1);
//							$("#manualwarning").show();
//							$("#anymanualchanges").val('1');
						}
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});							
			});

			$("#bkupbtn").click(function(){
				backupTheFile(true);
			});

			backupTheFile=function(showMsg)
			{
				var _res = 0;
				$.ajax({ 
					url : "backupScript.jsp",
					type: 'POST',
					data : {jsonid : '<%=CommonHelper.escapeCoteValue(jsonId)%>'},
					dataType : 'json',
					async:false,
					success : function(json)
					{		
						if(showMsg) alert(json.MSG);
						if(json.RESPONSE=='SUCCESS') $("#downloadBackupFile").show();
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
						_res = 1;
					}
				});			
				return _res;				
			};


			var files;
			// Grab the files and set them to our variable
			prepareUpload=function(event)
			{
				files = event.target.files;
			};

			// Add events
			$('input[type=file]').on('change', prepareUpload);


			$("#resetbtn").click(function(){
				if(!confirm("This will reset all json to html configuration and will delete script files. Are you sure you want to continue?")) return;
				$.ajax({
					url : "resetScript.jsp",
					type: 'POST',
					data : {jsonid : '<%=CommonHelper.escapeCoteValue(jsonId)%>'},
					dataType : 'json',
					async:false,
					success : function(json)
					{		
						window.location = "uiScript.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>";
						
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});							
			});

			download=function(file)
			{
				window.location = "download.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>&filetype="+file;
			};

			somethingchanged=function()
			{
				somethingischanged = true;
			};

			openinstructions=function()
			{
				var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
				propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
				propriete += ",width=1005" + ",height=800"; 
				win = window.open("instructions.html","Instructions", propriete);
				win.focus(); 
			};

			$("#viewtestbtn").click(function(){	
				var u = $.trim($("#destpage").val());
				if(u == "") return;
				var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
				propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
				propriete += ",width=1005" + ",height=800"; 
				win = window.open("<%=request.getContextPath()%>/"+u,"Test", propriete);
				win.focus(); 								
			});
	
			$("#rulesScrBtn").click(function(){
				window.location = "rules.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>";
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
			
			$("#editscriptbtn").click(function(){
				var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
				propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
				propriete += ",width=1005" + ",height=800"; 
				win = window.open("<%=request.getContextPath()%>/pages/editScript.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>","Edit Script", propriete);
				win.focus(); 								
			});

			showHideWarning=function(anymanualchanges)
			{
				//alert(anymanualchanges);
				if(anymanualchanges == 1)
				{
					$("#manualwarning").show();
					$("#anymanualchanges").val('1');
				}
				else
				{
					$("#manualwarning").hide();
					$("#anymanualchanges").val('0');
				}
			};

			$("#jsonQryBtn").click(function(){
				var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
				propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
				propriete += ",width=1005" + ",height=800"; 
				win = window.open("<%=request.getContextPath()%>/pages/editQueries.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>","Edit Queries", propriete);
				win.focus(); 								
			});

			$("#jsonQryRequeteBtn").click(function(){
				var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
				propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
				propriete += ",width=1250" + ",height=800"; 
				win = window.open("<%=request.getContextPath()%>/pages/editQueriesRequete.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>","Edit Queries", propriete);
				win.focus(); 								
			});

			reloadAfterQuery=function(generatedFilename)
			{
				$("#jsonurl").val(generatedFilename);
				reloadJson();
			};
			

			$("#generateHtmlBtn").click(function(){
				if(somethingischanged && !confirm("There seems to be some changes in configuration. Continue without save means changes wont be visible in generated html")) return;

				if(!confirm("Are you sure to generate html?")) return;

				$("#myfrm").attr('action','generateHtml.jsp');
				$("#myfrm").submit();
			});

			$("#downloadHtmlBtn").click(function(){
				window.location = "download.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>&filetype=generatedHtml";
			});

			<% if(msg.length() > 0) {%>
				alert('<%=CommonHelper.escapeCoteValue(msg)%>');
			<% } %>
			
			<% if(generateScriptAutomatic.equals("1")) { %>
				generateTheScript();
			<% } %>



			xaxischange=function(key)
			{
				var id = key + "_xaxis";
				if($("#" + id).val() == 'category')
				{
					$("#" + key + "_c3timeseriesxyspan").hide();
					$("#" + key + "_c3categorycolspan").show();
				}
				else if($("#" + id).val() == 'timeseries')
				{
					$("#" + key + "_c3categorycolspan").hide();
					$("#" + key + "_c3timeseriesxyspan").show();
				}
				else
				{
					$("#" + key + "_c3categorycolspan").hide();
					$("#" + key + "_c3timeseriesxyspan").hide();
				}
			};

			c3chartchanged=function(obj, key)
			{
				if($(obj).val() == 'combination')
				{
					$('#' + key + '_c3colgraphtypespan').show();
				}
				else
				{
					$('#' + key + '_c3colgraphtypespan').hide();
				}
			};

			$("#backbtn").click(function(){
				window.location = "screens.jsp";
			});

			removereuse=function(tag)
			{
				if(!confirm("Are you sure to delete this mapping?")) return;
				var cont = true;
				if(somethingischanged) 
				{
					if(!confirm("There are some unsaved changes. Remove copy tag will make you loose your other changes. Are you sure to continue?")) cont = false;
				}
				if(cont)
				{
					$.ajax({
						url : "reusetag.jsp",
						type: 'POST',
						data : {jsonid : <%=CommonHelper.escapeCoteValue(jsonId)%>, tag : tag, isremove : "1"},
						dataType : 'json',
						success : function(json)
						{		
							if(json.response == 'success') window.location = "uiScript.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonId)%>";
							else alert("Some error occurred while removing reuse tag");
						},
						error : function()
						{
							alert("Some error occurred while communicating with the server");
						}
					});								
				}

			}

			reuse=function(tag)
			{
				$.ajax({
					url : "reusetag.jsp",
					type: 'POST',
					data : {jsonid : <%=CommonHelper.escapeCoteValue(jsonId)%>, tag : tag},
					dataType : 'json',
					success : function(json)
					{		
						if(json.response == 'success') alert("To view new tag you must reload the screen");
						else alert("Some error occurred while reusing the tag");
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});			
			};
		});
    </script> 


</html>