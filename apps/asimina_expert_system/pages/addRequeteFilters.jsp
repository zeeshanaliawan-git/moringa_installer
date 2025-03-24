<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, java.io.*, com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="java.net.*"%>
<%@ page import="java.io.*"%>
<%@ page import="java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken"%>

<%@ include file="common.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Add requete column filter</title>

<link href="css/abcde.css" rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" />
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />

<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery-ui-1.8.18.custom.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../js/bootstrap.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="json.js"></script>

<style type="text/css">
	
	.form-group {
		margin-right: 15px;
	}

	.close-img{
		float: right;
		margin-left: 10px;
		margin-top: 4px;
	}

	.tag {
		padding: 10px;
		background-color: #13bb54;
		float: left;
		color: #ffffff;
		border-radius: 4px;
		margin-right: 15px;
		margin-top: 5px;
	}

</style>

<script type="text/javascript">

	jQuery(document).ready(function() {

		remove_column_filter = function(element){

			var id = $(element).parent().attr("id");
			var token = id.split("-_");

			var index = eval("selectedColumnArray_"+token[2]).indexOf($("#"+id).children()[0].innerHTML);
			if(index > -1){
				
				eval("selectedColumnArray_"+token[2]).splice(index,1);
				eval("selectedOperatorArray_"+token[2]).splice(index,1);
				eval("selectedColumnValueArray_"+token[2]).splice(index,1);
				eval("selectedColumnOptionValueArray_"+token[2]).splice(index,1);
			} 

			$(element).parent().remove();
		};

		requete_column_apply = function(requete_id){

			if(!validation(requete_id)) return false;

			var selectedColumn = $("#requete_column_operator_"+requete_id+" :selected").text();
			var selectedColumnOptionValue = $("#requete_column_operator_"+requete_id+" :selected").val();
			var selectedSessionVariable = $("#session_var_filter_"+requete_id+" :selected").val();
			var selectedOperator = $("#apply_operator_"+requete_id+" :selected").val();

			eval("selectedColumnArray_"+requete_id).push(selectedColumn);

			var requeteWhereClause = "";
			
			if(selectedOperator=="equalsto"){

				eval("selectedOperatorArray_"+requete_id).push("=")
				eval("selectedColumnOptionValueArray_"+requete_id).push(selectedColumnOptionValue);

				if(selectedSessionVariable.length>0){
		
					requeteWhereClause = "<label>" + selectedColumn + "</label>&nbsp;<label>=</label>&nbsp;<label>@___session_" + selectedSessionVariable+"</label>";
					eval("selectedColumnValueArray_"+requete_id).push("___session_" + selectedSessionVariable);

				}else{

					requeteWhereClause = "<label>" + selectedColumn + "</label>&nbsp;<label>=</label>&nbsp;<label>@" + selectedColumn+"</label>";
					eval("selectedColumnValueArray_"+requete_id).push(selectedColumn)
				}
			} else if(selectedOperator=="in"){

				eval("selectedOperatorArray_"+requete_id).push("IN");
				eval("selectedColumnOptionValueArray_"+requete_id).push(selectedColumnOptionValue);


				if(selectedSessionVariable.length>0){

					requeteWhereClause = "<label>" + selectedColumn + "</label>&nbsp;<label>=</label>&nbsp;<label>@___session_" + selectedSessionVariable+"</label>";
					eval("selectedColumnValueArray_"+requete_id).push("___session_" + selectedSessionVariable)
				}else{

					requeteWhereClause = "<label>" + selectedColumn + "</label>&nbsp;<label>IN</label>&nbsp;<label>(@" + selectedColumn+")</label>";
					eval("selectedColumnValueArray_"+requete_id).push(selectedColumn)
				}
			} else if(selectedOperator=="like"){

				eval("selectedOperatorArray_"+requete_id).push("LIKE");
				eval("selectedColumnOptionValueArray_"+requete_id).push(selectedColumnOptionValue);

				if(selectedSessionVariable.length>0){

					requeteWhereClause = "<label>" + selectedColumn + "</label>&nbsp;<label>=</label>&nbsp;<label>@___session_" + selectedSessionVariable+"</label>";
					eval("selectedColumnValueArray_"+requete_id).push("___session_" + selectedSessionVariable)
				}else{

					requeteWhereClause = "<label>" + selectedColumn + "</label>&nbsp;<label>LIKE</label>&nbsp;<label>(@" + selectedColumn+")</label>";
					eval("selectedColumnValueArray_"+requete_id).push(selectedColumn)
				}
			}

			if($("#"+requete_id+"_requete_where_clause").html().length>0) 
				$("#"+requete_id+"_requete_where_clause").html($("#"+requete_id+"_requete_where_clause").html()+"<div id=\"filter-_tag-_"+requete_id+"-_"+$("#requete_column_operator_"+requete_id+" :selected").val()+"\" class=\"tag\">"+requeteWhereClause+"<span style=\"cursor: pointer;\" onclick=\"remove_column_filter(this)\" class=\"glyphicon glyphicon-remove close-img\"></span></div>");
			else
				$("#"+requete_id+"_requete_where_clause").html("<div id=\"filter-_tag-_"+requete_id+"-_"+$("#requete_column_operator_"+requete_id+" :selected").val()+"\" class=\"tag\">"+requeteWhereClause+"<span style=\"cursor: pointer;\" onclick=\"remove_column_filter(this)\" class=\"glyphicon glyphicon-remove close-img\"></span></div>");

			$("#requete_column_operator_"+requete_id).val(0);
			$("#session_var_filter_"+requete_id).val(0);
			$("#apply_operator_"+requete_id).val(0);

		}

		validation = function(requete_id){

			if($("#requete_column_operator_"+requete_id+" :selected").val() == ""){

				alert("Kindly select any column.");
				$("#requete_column_operator_"+requete_id).focus();
				return false;	
			} 

			if($("#apply_operator_"+requete_id+" :selected").val() == ""){

				alert("Kindly select any operator.");
				$("#apply_operator_"+requete_id).focus();
				return false;					
			}
			
			return true;
		}

		$("#saveRequeteQueries").click(function(){

			var url = "?jsonid="+$("#json_id").val();

			if($("#requeteQueryIdParam").val().length == 0) url += "&save=1";
			else url += "&edit=1&query_id="+$("#requeteQueryIdParam").val();

			

			if(selectedRequeteIdArray.length>0) url += "&reqeute_selected_queries_param="+selectedRequeteIdArray;

			for(var i=0; i<selectedRequeteIdArray.length; i++){

				if(eval("selectedColumnArray_"+selectedRequeteIdArray[i]).length>0) url += "&requete_sel_filtrcol_"+selectedRequeteIdArray[i]+"="+eval("selectedColumnArray_"+selectedRequeteIdArray[i]);

				if(eval("selectedColumnValueArray_"+selectedRequeteIdArray[i]).length>0) url += "&requete_sel_filtrcol_val_"+selectedRequeteIdArray[i]+"="+eval("selectedColumnValueArray_"+selectedRequeteIdArray[i]);

				if(eval("selectedColumnOptionValueArray_"+selectedRequeteIdArray[i]).length>0) url += "&requete_sel_filtrcol_opt_val_"+selectedRequeteIdArray[i]+"="+eval("selectedColumnOptionValueArray_"+selectedRequeteIdArray[i]);
				
				if(eval("selectedOperatorArray_"+selectedRequeteIdArray[i]).length>0) url += "&requete_sel_filtroptr_"+selectedRequeteIdArray[i]+"="+eval("selectedOperatorArray_"+selectedRequeteIdArray[i]);
			}
			console.log(url);

			window.opener.location = "<%=request.getContextPath()%>/pages/editQueriesRequete.jsp"+url;
			window.close(); 
		});
	});

</script>

</head>
<%
	String requeteQueryIdParam = parseNull(request.getParameter("query_id"));
	String jsonId = parseNull(request.getParameter("json_id"));
	String[] requeteId = request.getParameterValues("requete_id");
	URL reqeuteUrl = null, tableRequeteUrl = null;
	BufferedReader in = null, tableIn = null;
	String requeteQueryColumnResponse = "", tableRequeteInfoResponse = "";;
	String requeteColumnList = "", tableRequeteInfo = "";
	String requeteQueryName = "", requeteQueryId = "";

	out.write("<script type=\"text/javascript\">");
	out.write("\t\tvar selectedRequeteIdArray = [];\n");

	for(int i=0; i<requeteId.length; i++){
		
		out.write("\t\tvar selectedColumnArray_"+requeteId[i]+" = [];\n");
		out.write("\t\tvar selectedColumnValueArray_"+requeteId[i]+" = [];\n");
		out.write("\t\tvar selectedColumnOptionValueArray_"+requeteId[i]+" = [];\n");
		out.write("\t\tvar selectedOperatorArray_"+requeteId[i]+" = [];\n");

		out.write("selectedRequeteIdArray.push(\""+requeteId[i]+"\");\n");
	}

	out.write("</script>");
	out.write("<div class=\"container\">");
	out.write("<div style=\"color: #cd3c14; font-size: 0.8em;\">Note: You can use the session variable as an paramter value else the selected column name will be used as a parameter.</div>");
 	for(int i=0; i<requeteId.length; i++){
		
		out.write("<div class=\"well\" style=\"overflow: hidden;\" >");
		out.write("<form role=\"form\" class=\"form-inline\" style=\"margin-bottom: 30px;\">");
	
		requeteColumnList = "";
		tableRequeteInfo = "";
		try{

			reqeuteUrl = new URL(GlobalParm.getParm("REQUETE_WEB_APP")+"?f=info_requete&requete_id="+requeteId[i]);
			in = new BufferedReader( new InputStreamReader(reqeuteUrl.openStream()));

			while ((requeteQueryColumnResponse = in.readLine()) != null) requeteColumnList += requeteQueryColumnResponse;
			
			if(requeteColumnList.length()>0){

				tableRequeteUrl = new URL(GlobalParm.getParm("REQUETE_WEB_APP")+"?f=liste_requete&requete_id="+requeteId[i]);
				tableIn = new BufferedReader( new InputStreamReader(tableRequeteUrl.openStream()));

				while ((tableRequeteInfoResponse = tableIn.readLine()) != null) tableRequeteInfo += tableRequeteInfoResponse;
				
				if(tableRequeteInfo.length()>0){

					Gson gson = new Gson();
			        Type stringObjectMap = new TypeToken<List<Object>>(){}.getType();
				    List<Object> list = gson.fromJson(tableRequeteInfo, stringObjectMap);
				    Iterator itr = list.iterator();

				    if(itr.hasNext()){
						
						Map<String, String> map = (Map) itr.next();
						requeteQueryName = map.get("requete_name");
						requeteQueryId = map.get("requete_id");
						out.write("<div class=\"col-sm-12\" style=\"text-align: center;\"> <label>Query name : "+requeteQueryName+"</label></div>");
						out.write("<div class=\"form-group\"> <label> Column name </label> : ");
					}

					tableIn.close();
				}
	
				Gson gson = new Gson();
		        Type stringObjectMap = new TypeToken<List<Object>>(){}.getType();
			    List<Object> list = gson.fromJson(requeteColumnList, stringObjectMap);
			    Iterator itr = list.iterator();

				out.write("<select class=\"form-control\" id=\"requete_column_operator_"+requeteId[i]+"\"><option value=\"\">---select---</option>");
			    while(itr.hasNext()){
	
					Map<String, String> map = (Map) itr.next();
					out.write("<option value=\""+map.get("nom_table_ihm")+"_"+map.get("nomlogique")+"\">");
					out.write(map.get("nomlogique"));
					out.write("</option>");
				}
				out.write("</select></div>");
				out.write(" <div class=\"form-group\"> <label> Operator : </label> <select class=\"form-control\" id=\"apply_operator_"+requeteId[i]+"\"> <option value=\"\">---select---</option> <option value=\"equalsto\">Equals to</option> </select> </div>");
				out.write(" <div class=\"form-group\"> <label> Session variable : </label> <select class=\"form-control\" id=\"session_var_filter_"+requeteId[i]+"\"> <option value=\"\"></option> <option value=\"login\">Email</option> <option value=\"client_id\">Client id</option> <option value=\"profil\">Logged in user</option> </select> </div>");
				out.write("<button type=\"button\" onclick=\"requete_column_apply("+requeteId[i]+")\" class=\"btn btn-success\">Apply filter</button>");

				Set requeteQueryIdRs = Etn.execute("SELECT * FROM expert_system_query_params WHERE json_id = "+escape.cote(jsonId)+" AND query_id = "+escape.cote(requeteQueryIdParam));
				out.write("<div id=\""+requeteQueryId+"_requete_where_clause\">");


				while(requeteQueryIdRs.next()){
					
					out.write("<div id=\"filter-_tag-_"+requeteId[i]+"-_"+requeteQueryIdRs.value("requete_column_value")+"\" class=\"tag\"><label>" + requeteQueryIdRs.value("requete_column_param") + "</label> &nbsp; <label> " + requeteQueryIdRs.value("requete_column_operator") + " </label> &nbsp; <label>" + requeteQueryIdRs.value("param") + "</label><span style=\"cursor: pointer;\" onclick=\"remove_column_filter(this)\" class=\"glyphicon glyphicon-remove close-img\"></span></div>");
				}
			
				requeteQueryIdRs.moveFirst();
				out.write("\n<script id=\"filling_array\" type=\"text/javascript\">\n");
				
				while(requeteQueryIdRs.next()){

					out.write("\teval(\"selectedColumnArray_\"+"+requeteId[i]+").push('"+requeteQueryIdRs.value("requete_column_param")+"')\n");
					out.write("\teval(\"selectedColumnValueArray_\"+"+requeteId[i]+").push('"+requeteQueryIdRs.value("param")+"')\n");
					out.write("\teval(\"selectedColumnOptionValueArray_\"+"+requeteId[i]+").push('"+requeteQueryIdRs.value("requete_column_value")+"')\n");
					out.write("\teval(\"selectedOperatorArray_\"+"+requeteId[i]+").push('"+requeteQueryIdRs.value("requete_column_operator")+"')\n");
					out.write("$('#filling_array').remove();\n");
				}

				out.write("</script>\n");	
				out.write("</div>");
			}

			in.close();
		}catch(Exception e){
//			System.out.println(e.toString());
			e.printStackTrace();
		}finally{
			if(null != in) in.close();
		}
	
		out.write("</form>");
		out.write("</div>");
	}
	
	out.write("</div>");

	out.write("<div class=\"col-sm-12\" style=\"text-align: center;\"><button type=\"button\" id=\"saveRequeteQueries\" class=\"btn btn-success\">Save</button></div>");
	out.write("<input type=\"hidden\" id=\"json_id\" value=\""+jsonId+"\"/>"); 
	out.write("<input type=\"hidden\" id=\"requeteQueryIdParam\" value=\""+requeteQueryIdParam+"\"/>"); 

%> 


<body>
	
</body>
</html>