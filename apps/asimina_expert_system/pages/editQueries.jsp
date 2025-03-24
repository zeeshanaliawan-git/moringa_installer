<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, java.io.*, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.sql.escape, com.etn.asimina.util.CommonHelper"%>

<%@ include file="common.jsp" %>
<%
	String jsonid = parseNull(request.getParameter("jsonid"));
	String msg = parseNull(request.getParameter("message"));
	
	String path = GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_JSP_FOLDER");
	String generateJspsUrl = GlobalParm.getParm("EXPERT_SYSTEM_GENERATE_JSP_URL");
	String fetchdatatemplate = GlobalParm.getParm("EXPERT_SYSTEM_FETCH_JSP_TEMPLATE");

//	String path = "/usr/local/apache-tomcat-7.0.29/webapps/cimenter/generatedJsps/";
//	String generateJspsUrl = "/cimenter/generatedJsps/";//this path is respective url to expert system url 
//	String fetchdatatemplate = "/usr/local/apache-tomcat-7.0.29/webapps/cimenter/expertSystem/fetchdatatemplate.jsp";

	String save = parseNull(request.getParameter("save"));
	String[] qrys = request.getParameterValues("qry");
	String[] qrydescs = request.getParameterValues("qrydesc");
	String[] qrysType = request.getParameterValues("query_type");

//	String[] qryparams = request.getParameterValues("qryparams");
//	String[] paramsdefaultvalue = request.getParameterValues("paramsdefaultvalue");

	String[] qrycounts = request.getParameterValues("qrycounts");

	String filename = "fetchdata_" + CommonHelper.escapeCoteValue(jsonid.replaceAll("/", "").replaceAll("\\\\", "")) + ".jsp";

	String reloadJson = parseNull(request.getParameter("reloadJson"));
	boolean filegenerated = true;

	if(save.equals("1"))
	{
		Etn.executeCmd("delete from expert_system_queries where is_requete_query = 0 and json_id = " + escape.cote(jsonid));
		Etn.executeCmd("delete from expert_system_query_params where json_id = " + escape.cote(jsonid));

//		String bigQuery = " ";
		for(int i=0; i<qrys.length;i++)
		{
			int _qryid = 0;
			String _query = " " + parseNull(qrys[i]).replaceAll("(\\r|\\n)", " ") + " ";

			if(parseNull(qrys[i]).length() > 0) _qryid = Etn.executeCmd("insert into expert_system_queries (json_id, query, created_by, query_type, description) values ("+escape.cote(jsonid)+","+escape.cote(parseNull(_query))+","+escape.cote((String)session.getAttribute("LOGIN"))+","+escape.cote(parseNull(qrysType[i]))+","+escape.cote(parseNull(qrydescs[i]))+") ");

			if(_qryid > 0)
			{
				String qrycount = qrycounts[i];
				String[] qryparams = request.getParameterValues(qrycount+"_qryparams");
				String[] paramsdefaultvalue = request.getParameterValues(qrycount+"_paramsdefaultvalue");

				if(qryparams != null)
				{
					for(int j=0; j<qryparams.length;j++)
					{	

						//making sure any parameter no more used in queries are not inserted		
						//adding space after param to make sure it does exact match
						if(_query.indexOf("@"+qryparams[j]+" ") > -1 || _query.indexOf("@"+qryparams[j]+"\n") > -1 || _query.indexOf("@#"+qryparams[j]+" ") > -1 || _query.indexOf("@#"+qryparams[j]+"\n") > -1)
							Etn.executeCmd("insert into expert_system_query_params (json_id, param, default_value, query_id) values ("+escape.cote(jsonid)+","+escape.cote(qryparams[j])+","+escape.cote(parseNull(paramsdefaultvalue[j]))+", "+escape.cote(""+_qryid)+") "); 
					}
				}
			}
		}
		msg = "Saved successfully!!!";
		File file = new File(path + filename);

		if(file.length() <= 0)
//		if(true)
		{
			FileOutputStream fos = null;
			FileInputStream fis = null;
			try
			{
				byte[] bytes = new byte[1024];
				fis = new FileInputStream(fetchdatatemplate);
			
				String output = "";	
				int i=-1;
				while(( i = fis.read(bytes) ) != -1)
				{
					output += new String(bytes,0,i,"utf8");
				}

				output = output.replaceAll("##jsonid##",CommonHelper.escapeCoteValue(jsonid));
				
				fos = new FileOutputStream(path + filename);
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
				msg = "Error generating file";
				filegenerated = false;
			}
		}
		else if(qrys.length == 0) filegenerated = false;//making sure if all queries are deleted we dont reload the json or it can mess up things
	}


	Set rsParams = Etn.execute("select distinct param from expert_system_query_params where json_id = " + escape.cote(jsonid));

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Expert System</title>

<link href="css/abcde.css" rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" />

<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery-ui-1.8.18.custom.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="json.js"></script>

</head>
<body>
	<center>
		<form name='myForm' id='myForm' action='editQueries.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonid)%>' method='post'>
			<input type='hidden' name='save' value='1' />
			<input type='hidden' name='reloadJson' id='reloadJson' value='0' />
			<div>
				<div style='float:left;width:15%'>
					<div style='font-weight:bold; color:white; background:gray'>Query Parameters</div>		
					<div style='text-align:left'>
						<table id='params' cellspacing=0 cellpadding=0 border=0 class="resultat" width="100%">
							<thead><th>Params</th></thead>
							<% while(rsParams.next()) {%>
							<tr>
								<td><%=CommonHelper.escapeCoteValue(rsParams.value("param"))%></td>
							</tr>
							<% } %>
						</table>
					</div>
				</div>
				<div style='float:left;width:84%'>
					<div style='font-weight:bold; color:white; background:gray'>Queries</div>		
					<div style='font-weight:bold; color:red;'>
						Note: Avoid changing query name after html mapping is done or your html mapping will be lost. 
						<br/>
						<!-- You can also use the mentioned session varriable as an parameters like @___session_login, @___session_client_id and @___session_profil -->
					</div>
					<div style='height:580px; overflow:auto;'>
						<table class="resultat" cellpadding="0" cellspacing="0" border="0" id="qryTable" width="100%">
						<%  
							int qrycount = 0;
							Set rs = Etn.execute(" select * from expert_system_queries where is_requete_query = 0 and json_id = " + escape.cote(jsonid) + " order by id ");
							while(rs.next()) { %>			
							<tr>			
								<input type='hidden' name='qrycounts' value='<%=qrycount%>' />	
								<td align='center'><b>Query Name : </b><input type='text' name='qrydesc' class='qrydesc' maxlength='100' size='50' value='<%=CommonHelper.escapeCoteValue(parseNull(rs.value("description")))%>'/><br/><textarea id="<%=qrycount%>_qry" rows='5' cols='100' name='qry' class="qry"><%=CommonHelper.escapeCoteValue(parseNull(rs.value("query")))%></textarea></td>			
								<td>
									<select name='query_type'>
										<option value=''>----</option>
										<option value='array' <%if(parseNull(rs.value("query_type")).equals("array")){%>selected<%}%> >Array</option>
										<option value='array-with-labels' <%if(parseNull(rs.value("query_type")).equals("array-with-labels")){%>selected<%}%> >Array with labels</option>
										<option value='c3' <%if(parseNull(rs.value("query_type")).equals("c3")){%>selected<%}%> >C3</option>
										<option value='d3' <%if(parseNull(rs.value("query_type")).equals("d3")){%>selected<%}%> >D3</option>
										<option value='d3map' <%if(parseNull(rs.value("query_type")).equals("d3map")){%>selected<%}%> >D3Map</option>
										<option value='d3mapchl' <%if(parseNull(rs.value("query_type")).equals("d3mapchl")){%>selected<%}%> >D3MapChl</option>
									</select>
								</td>
								<td>
									<table id='<%=qrycount%>_params' cellspacing=0 cellpadding=0 border=0 width="100%"> 
									</table>
								</td>
							</tr>								
						<% 		qrycount++;
							} %>
							<tr>				
								<input type='hidden' name='qrycounts' value='<%=qrycount%>' />	
								<td align='center'><b>Query Name : </b><input type='text' name='qrydesc' class='qrydesc' maxlength='100' size='50' value=''/><br/><textarea id="<%=qrycount%>_qry" rows='5' cols='100' name='qry' class="qry"></textarea></td>			
								<td>
									<select name='query_type'>
										<option value=''>----</option>
										<option value='array'>Array</option>
										<option value='array-with-labels'>Array with labels</option>
										<option value='c3'>C3</option>
										<option value='d3'>D3</option>
										<option value='d3map'>D3Map</option>
										<option value='d3mapchl'>D3MapChl</option>
									</select>
								</td>
								<td>
									<table id='<%=qrycount%>_params' cellspacing=0 cellpadding=0 border=0 width="100%"> 
									</table>
								</td>
							</tr>
						</table>
						<% qrycount++; %>
					</div>
				</div>
			</div>
			<div style='clear:both'>				
                     	<input type='button' value='Add Query' id='addMoreBtn'/>&nbsp;&nbsp;<input type='button' value='Save' id='saveBtn'/>&nbsp;&nbsp;<input type='button' value='Save and reload Json' id='saveReloadBtn'/>
			</div>
		</form>
	</center>
	<div id="dialogWindow" title="Query parameters"></div>
</body>
	<script type="text/javascript">
		jQuery(document).ready(function() {

			var qrycount = '<%=qrycount%>';

			var params = new Array();
			var qryparams = new Array();
			var reloadurl = '<%=generateJspsUrl%><%=CommonHelper.escapeCoteValue(filename)%>?__es=1';

//			var paramcounter = 0;
			<% 
				rsParams.moveFirst();	
				while(rsParams.next())
				{ 
			%>
					params.push('<%=CommonHelper.escapeCoteValue(rsParams.value("param"))%>');
//					if(paramcounter++ == 0) reloadurl += "?";
//					else reloadurl += "&";
//					reloadurl += "<%=rsParams.value("param")%>=<%=parseNull(rsParams.value("default_value"))%>";
			<%				
				}		
			%>

			pushqryparam=function(id, p)
			{
				if(!qryparams[id]) qryparams[id] = new Array();
				var o = qryparams[id];
				o.push(p);
			};	

			<% 
			qrycount = 0;
			rs.moveFirst(); 
			while(rs.next()) {
				Set rsqpr = Etn.execute("select * from expert_system_query_params where query_id = " + escape.cote(rs.value("id")));
				while(rsqpr.next())
				{
			%>
				$('#<%=qrycount%>_params').append("<tr><td><input type='hidden' name='<%=qrycount%>_qryparams' value='<%=CommonHelper.escapeCoteValue(rsqpr.value("param"))%>' /><%=CommonHelper.escapeCoteValue(rsqpr.value("param"))%></td><td><input type='text' name='<%=qrycount%>_paramsdefaultvalue' class='paramsdefaultvalue' value='<%=CommonHelper.escapeCoteValue(parseNull(rsqpr.value("default_value")))%>' size='25' /></td></tr>"); 							
				pushqryparam('<%=qrycount%>','<%=CommonHelper.escapeCoteValue(rsqpr.value("param"))%>');
			<%					
				}
				qrycount++;
			}
			%>

			$("#dialogWindow").dialog({
				bgiframe: true, autoOpen: false, height: 450, width:760, modal: true, resizable : false
			});			

			<% if(!msg.equals("")) { %>
				alert('<%=CommonHelper.escapeCoteValue(msg)%>');
			<% } %>

			$("#addMoreBtn").click(function(){
				$("#qryTable").append("<tr><input type='hidden' name='qrycounts' value='"+qrycount+"' /><td align='center'><b>Query Name : </b><input type='text' name='qrydesc' class='qrydesc' maxlength='100' size='50' value=''/><br/><textarea id='"+qrycount+"_qry' rows='5' cols='100' name='qry' class='qry'></textarea></td><td><select name='query_type'><option value=''>----</option><option value='array'>Array</option><option value='array-with-labels'>Array with labels</option><option value='c3'>C3</option><option value='d3'>D3</option><option value='d3map'>D3Map</option><option value='d3mapchl'>D3MapChl</option></select></td><td><table id='"+qrycount+"_params' cellspacing=0 cellpadding=0 border=0 width='100%'></table></td></tr>");
				$(".qry")[$(".qry").length-1].focus();
				qrycount++;
			});

			checkAllOk=function()
			{
				var allOk = true;
				$(".qry").each(function(){
					if($.trim($(this).val()) != '' && $.trim($(this).val()).toLowerCase().indexOf('select') != 0) allOk = false;					
				});
				return allOk;			
			};

			$("#saveBtn").click(function(){
				$("#reloadJson").val("0");
				saveData();
			});

			saveData=function()
			{
				if(!checkAllOk()) 
				{
					alert("Only select queries are allowed");
					return;
				}
				if(!allDefaultValuesGiven())
				{
					if(confirm("Some of the parameters have no default value. Are you sure to continue with save?")) $("#myForm").submit();
				}	
				else $("#myForm").submit();
			}

			$("#saveReloadBtn").click(function(){
				$("#reloadJson").val("1");
				saveData();
			});

			allDefaultValuesGiven=function()
			{
				var allgiven = true;
				$(".paramsdefaultvalue").each(function(){
					if($.trim($(this).val()) == '') allgiven = false;
				});
				return allgiven;
			}

			$(".qrydesc").bind('keypress', function (event) {
				var keyCode = event.keyCode || event.which
				// Don't validate the input if below arrow, delete and backspace keys were pressed 
				if (keyCode == 8 || keyCode == 32 || keyCode == 9 || keyCode == 39 || keyCode == 37 || keyCode == 46) { // Left / Up / Right / Down Arrow, Backspace, Delete keys
				    return;
				}
				var regex = new RegExp("^[_a-zA-Z0-9\b]+$");
				var key = String.fromCharCode(!event.charCode ? event.which : event.charCode);
				if (!regex.test(key)) {       
					event.preventDefault();
					return false;
				}			
			});
		
			$(".qry").live('change',function()
			{				
				var v = $.trim($(this).val());
				if(v != '')
				{
					var vs = v.split("@");					

					//we ignore the first index as its always the first part of query
					for(var i = 1; i < vs.length; i++)
					{
						var pr = $.trim(vs[i]);
						//this is @# so we remove # from it
						if(pr.indexOf("#") == 0 && pr.length > 1) pr = pr.substring(1);
						if(pr.indexOf(" ") > -1) pr = pr.substring(0, pr.indexOf(" "));
//						alert(pr);
						if(pr.indexOf("\n") > -1) pr = pr.substring(0, pr.indexOf("\n"));								
//						alert(pr);
						if(isNewParam(pr))
						{
							$("#params").append("<tr><td><input type='hidden' name='qryparams' value='"+pr+"' />" + pr + "</td></tr>"); 
							params.push(pr);
						}
						var _id = $(this).attr('id');
						_id = _id.substring(0, _id.indexOf("_"));
//alert(_id);
						if(isNewQryParam(_id, pr))
						{
							$('#'+_id+'_params').append("<tr><td><input type='hidden' name='"+_id+"_qryparams' value='"+pr+"' />" + pr + "</td><td><input type='text' name='"+_id+"_paramsdefaultvalue' class='paramsdefaultvalue' value='' size='25' /></td></tr>"); 							
							pushqryparam(_id, pr);
						}
//						alert(_id);
					}
				}
			});

			isNewQryParam=function(id, p)
			{
				if(qryparams[id])
				{
					var o = qryparams[id];
					var isNew = true;
					for(var i=0; i<o.length; i++) if(o[i] == p) isNew = false;
					return isNew;
				}
				else return true;
			};
		
			isNewParam=function(p)
			{
				var isNew = true;
				for(var i=0; i<params.length;i++) if(params[i] == p) isNew = false;
				return isNew;
			};

			$("#savebtn").click(function(){
				if(!confirm("Are you sure to update the script with this version?")) return;
				$("#myform").submit();
			});

			<% if(reloadJson.equals("1") && filegenerated) { %>
				opener.reloadAfterQuery(reloadurl);
			<% } %>

		});
	</script>
</html>