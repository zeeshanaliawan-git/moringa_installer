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
<%@ page import="java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, com.etn.asimina.util.CommonHelper"%>

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
	String edit = parseNull(request.getParameter("edit"));
	String esQueryId = parseNull(request.getParameter("query_id"));
	String[] qrys = request.getParameterValues("qry");
	String[] qrydescs = request.getParameterValues("qrydesc");
	String[] qrysType = request.getParameterValues("query_type");
	String[] isRequeteQuery = request.getParameterValues("is_requete_query");
	String[] requeteQueryIdValue = request.getParameterValues("requete_query_id_value");
	String[] esQueryIdValue = request.getParameterValues("es_query_id"); 
	String requeteSelectedQueries = parseNull(request.getParameter("reqeute_selected_queries_param"));
	String requeteSelectedQueriesUpdate = parseNull(request.getParameter("reqeute_selected_queries_update"));
	String requeteSelectedFilterColumns;
	String requeteSelectedFilterColumnsValue;
	String requeteSelectedFilterColumnsOptionValue;
	String requeteSelectedFilterColumnOperators;
	String[] requeteSelectedQueriesToken = null;

//	String[] qryparams = request.getParameterValues("qryparams");
//	String[] paramsdefaultvalue = request.getParameterValues("paramsdefaultvalue");

	String[] qrycounts = request.getParameterValues("qrycounts");

	String filename = "fetchdata_" + CommonHelper.escapeCoteValue(jsonid) + ".jsp";

	String reloadJson = parseNull(request.getParameter("reloadJson"));
	boolean filegenerated = true;

	String[] requeteSelectedFilterColumnsToken = null;
	String[] requeteSelectedFilterColumnsValueToken = null;
	String[] requeteSelectedFilterColumnsOptionValueToken = null;
	String[] requeteSelectedFilterColumnOperatorsToken = null;
 	
	if(edit.equals("1"))
	{
		Etn.executeCmd("DELETE FROM expert_system_query_params WHERE json_id = "+escape.cote(jsonid)+" AND query_id = "+escape.cote(esQueryId));

		URL reqeuteUrl = null;
		BufferedReader in = null;
		String requeteQueryResponse = "";
		String requeteSelectedFilterParams = "";
		String requeteQuery = "";

		requeteSelectedFilterColumns = parseNull(request.getParameter("requete_sel_filtrcol_"+requeteSelectedQueries));
		requeteSelectedFilterColumnsValue = parseNull(request.getParameter("requete_sel_filtrcol_val_"+requeteSelectedQueries));
		requeteSelectedFilterColumnsOptionValue = parseNull(request.getParameter("requete_sel_filtrcol_opt_val_"+requeteSelectedQueries));		
		requeteSelectedFilterColumnOperators = parseNull(request.getParameter("requete_sel_filtroptr_"+requeteSelectedQueries));

		requeteSelectedFilterColumnsToken = requeteSelectedFilterColumns.split(",");
		requeteSelectedFilterColumnsValueToken = requeteSelectedFilterColumnsValue.split(",");
		requeteSelectedFilterColumnsOptionValueToken = requeteSelectedFilterColumnsOptionValue.split(",");
		requeteSelectedFilterColumnOperatorsToken = requeteSelectedFilterColumnOperators.split(",");

		for(int j=0; j<requeteSelectedFilterColumnsToken.length; j++){
			
			requeteSelectedFilterParams += "&filter"+requeteSelectedFilterColumnsToken[j]+"=@"+requeteSelectedFilterColumnsValueToken[j];
		}

		try{ 

			reqeuteUrl = new URL(GlobalParm.getParm("REQUETE_WEB_APP")+"?f=sql_requete&requete_id="+requeteSelectedQueries+"&format=json"+requeteSelectedFilterParams);
			in = new BufferedReader( new InputStreamReader(reqeuteUrl.openStream()));
			while ((requeteQueryResponse = in.readLine()) != null) requeteQuery += requeteQueryResponse;

			in.close();

		}catch(Exception e){
			System.out.println(e.toString());
		}finally{
			if(null != in) in.close();				
		}
	
		String updateQry = "UPDATE expert_system_queries SET query = "+escape.cote(requeteQuery)+" WHERE id = "+escape.cote(esQueryId);
		Etn.executeCmd(updateQry);

		for(int j=0; j<requeteSelectedFilterColumnsToken.length; j++){
			
			String insQuery = "INSERT INTO expert_system_query_params(json_id, param, query_id, requete_column_value, requete_column_operator, requete_column_param) VALUES (" + escape.cote(jsonid) + "," + escape.cote(requeteSelectedFilterColumnsValueToken[j]) + "," + escape.cote(esQueryId) + "," + escape.cote(requeteSelectedFilterColumnsOptionValueToken[j]) + "," + escape.cote(requeteSelectedFilterColumnOperatorsToken[j]) + "," + escape.cote(requeteSelectedFilterColumnsToken[j]) + ")";

			Etn.executeCmd(insQuery);
		}
	}

	if(save.equals("1"))
	{

		String requeteQuery = "";
		String requeteQueryName = "";
		String requeteQueryTable = "";
		String requeteQueryDescription = "";
		URL reqeuteUrl = null;
		BufferedReader in = null;
		String requeteQueryResponse = "";
		String requeteSelectedFilterParams = "";

		requeteSelectedQueriesToken = requeteSelectedQueries.split(",");
		for(int i=0; i<requeteSelectedQueriesToken.length; i++){
			
			requeteQuery = "";
			requeteQueryTable = "";
			requeteSelectedFilterParams = "";
			
			requeteSelectedFilterColumns = parseNull(request.getParameter("requete_sel_filtrcol_"+requeteSelectedQueriesToken[i]));
			requeteSelectedFilterColumnsValue = parseNull(request.getParameter("requete_sel_filtrcol_val_"+requeteSelectedQueriesToken[i]));
			requeteSelectedFilterColumnsOptionValue = parseNull(request.getParameter("requete_sel_filtrcol_opt_val_"+requeteSelectedQueriesToken[i]));		
			requeteSelectedFilterColumnOperators = parseNull(request.getParameter("requete_sel_filtroptr_"+requeteSelectedQueriesToken[i]));

			requeteSelectedFilterColumnsToken = requeteSelectedFilterColumns.split(",");
			requeteSelectedFilterColumnsValueToken = requeteSelectedFilterColumnsValue.split(",");
			requeteSelectedFilterColumnsOptionValueToken = requeteSelectedFilterColumnsOptionValue.split(",");
			requeteSelectedFilterColumnOperatorsToken = requeteSelectedFilterColumnOperators.split(",");
			
			for(int j=0; j<requeteSelectedFilterColumnsToken.length; j++){

				if(requeteSelectedFilterColumnsToken[j].length()>0){

					requeteSelectedFilterParams += "&filter"+requeteSelectedFilterColumnsToken[j]+"=@"+requeteSelectedFilterColumnsValueToken[j];
				}
			}
			
			try{ 

				reqeuteUrl = new URL(GlobalParm.getParm("REQUETE_WEB_APP")+"?f=sql_requete&requete_id="+requeteSelectedQueriesToken[i]+"&format=json"+requeteSelectedFilterParams);
				in = new BufferedReader( new InputStreamReader(reqeuteUrl.openStream()));
				while ((requeteQueryResponse = in.readLine()) != null) requeteQuery += requeteQueryResponse;

				in.close();

			}catch(Exception e){
				System.out.println(e.toString());
			}finally{
				
				if(null != in) in.close();	

				try{
	
					requeteQueryResponse = "";
					reqeuteUrl = new URL(GlobalParm.getParm("REQUETE_WEB_APP")+"?f=liste_requete&requete_id="+requeteSelectedQueriesToken[i]);
					in = new BufferedReader( new InputStreamReader(reqeuteUrl.openStream()));
					while((requeteQueryResponse = in.readLine()) != null) requeteQueryTable += requeteQueryResponse;

					in.close();
				}catch(Exception e){
					
					System.out.println(e.toString());
				}finally{
					if(null != in) in.close();
				}
				
			}

			if(requeteQueryTable.length()>0){

				Gson gson = new Gson();
		        Type stringObjectMap = new TypeToken<List<Object>>(){}.getType();
			    List<Object> list = gson.fromJson(requeteQueryTable, stringObjectMap);
			    Iterator itr = list.iterator();

			    while(itr.hasNext()){

					Map<String, String> map = (Map) itr.next();
					requeteQueryName = map.get("requete_name").replace("&#32;"," ");
				}
			}

			if(requeteQuery.length()>0){
				
				requeteQuery = requeteQuery.trim();
				requeteQuery = requeteQuery.replaceAll("(\\r|\\n)", " ");
				String insertQuery = "INSERT INTO expert_system_queries(json_id, query, created_by, query_type, description, is_requete_query, requete_query_id) VALUES (" + escape.cote(jsonid) + "," + escape.cote(requeteQuery) + "," + escape.cote((String)session.getAttribute("LOGIN")) + "," + escape.cote("array") + "," + escape.cote(requeteQueryName) + ",1," + escape.cote(requeteSelectedQueriesToken[i]) + ")";

				int qid = Etn.executeCmd(insertQuery);

				for(int j=0; j<requeteSelectedFilterColumnsToken.length; j++){
					
					if(requeteSelectedFilterColumnsToken[j].length()>0){

						String insQuery = "INSERT INTO expert_system_query_params(json_id, param, query_id, requete_column_value, requete_column_operator, requete_column_param) VALUES (" + escape.cote(jsonid) + "," + escape.cote(requeteSelectedFilterColumnsValueToken[j]) + "," + escape.cote(qid+"") + "," + escape.cote(requeteSelectedFilterColumnsOptionValueToken[j]) + "," + escape.cote(requeteSelectedFilterColumnOperatorsToken[j]) + "," + escape.cote(requeteSelectedFilterColumnsToken[j]) + ")";

						Etn.executeCmd(insQuery);
					}
				}
			}
		}

//		String bigQuery = " ";
		if(parseNull(qrys).length()>0){

			Etn.executeCmd("delete from expert_system_queries where json_id = " + escape.cote(jsonid));

			String rqid = "";
			String esqid = "";
			Set esqRs = null;


			for(int i=0; i<qrys.length;i++)
			{

				requeteSelectedFilterParams = "";
				requeteQuery = "";
				requeteQueryTable = "";
				esqRs = null;

				if(parseNull(qrys[i]).length()>0 && parseNull(esQueryIdValue[i]).length()>0){
						
					esqid = esQueryIdValue[i];
					esqRs = Etn.execute("SELECT * FROM expert_system_query_params WHERE query_id = "+escape.cote(esqid));
					Etn.executeCmd("delete from expert_system_query_params where json_id = " + escape.cote(jsonid) + " AND query_id = " + escape.cote(esqid));
				}
				

				if(parseNull(isRequeteQuery[i]).equals("0")){

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
								if(_query.indexOf("@"+qryparams[j]+" ") > -1 || _query.indexOf("@"+qryparams[j]+"\n") > -1)
									Etn.executeCmd("insert into expert_system_query_params (json_id, param, default_value, query_id) values ("+escape.cote(jsonid)+","+escape.cote(qryparams[j])+","+escape.cote(parseNull(paramsdefaultvalue[j]))+", "+escape.cote(""+_qryid)+") "); 
							}
						}
					}
	
				}else{

					rqid = requeteQueryIdValue[i];
					while(null!=esqRs && esqRs.next()){
						requeteSelectedFilterParams += "&filter"+parseNull(esqRs.value("param"))+"=@"+parseNull(esqRs.value("requete_column_param"));
					}				

					try{ 

						reqeuteUrl = new URL(GlobalParm.getParm("REQUETE_WEB_APP")+"?f=sql_requete&requete_id="+rqid+"&format=json"+requeteSelectedFilterParams);
						in = new BufferedReader( new InputStreamReader(reqeuteUrl.openStream()));
						while ((requeteQueryResponse = in.readLine()) != null) requeteQuery += requeteQueryResponse;

						in.close();

					}catch(Exception e){
						System.out.println(e.toString());
					}finally{
						
						if(null != in) in.close();

						try{
			
							requeteQueryResponse = "";

							reqeuteUrl = new URL(GlobalParm.getParm("REQUETE_WEB_APP")+"?f=liste_requete&requete_id="+rqid);
							in = new BufferedReader( new InputStreamReader(reqeuteUrl.openStream()));
							while((requeteQueryResponse = in.readLine()) != null) requeteQueryTable += requeteQueryResponse;

							in.close();
						}catch(Exception e){
							
							System.out.println(e.toString());
						}finally{
							if(null != in) in.close();
						}
					}

					if(requeteQueryTable.length()>0){

						Gson gson = new Gson();
				        Type stringObjectMap = new TypeToken<List<Object>>(){}.getType();
					    List<Object> list = gson.fromJson(requeteQueryTable, stringObjectMap);
					    Iterator itr = list.iterator();

					    while(itr.hasNext()){

							Map<String, String> map = (Map) itr.next();
							requeteQueryName = map.get("requete_name").replace("&#32;"," ");
						}
					}			

					if(requeteQuery.length()>0){
						
						requeteQuery = requeteQuery.trim();
						requeteQuery = requeteQuery.replaceAll("(\\r|\\n)", " ");
						String insertQuery = "INSERT INTO expert_system_queries(json_id, query, created_by, query_type, description, is_requete_query, requete_query_id) VALUES (" + escape.cote(jsonid) + "," + escape.cote(requeteQuery) + "," + escape.cote((String)session.getAttribute("LOGIN")) + "," + escape.cote("array") + "," + escape.cote(requeteQueryName) + ",1," + escape.cote(rqid) + ")";

						int qid = Etn.executeCmd(insertQuery);

						if(null!=esqRs) esqRs.moveFirst();

						while(null!=esqRs&&esqRs.next()){

							String insQuery = "INSERT INTO expert_system_query_params(json_id, param, query_id, requete_column_value, requete_column_operator, requete_column_param) VALUES (" + escape.cote(jsonid) + "," + escape.cote(esqRs.value("param")) + "," + escape.cote(qid+"") + "," + escape.cote(esqRs.value("requete_column_value")) + "," + escape.cote(esqRs.value("requete_column_operator")) + "," + escape.cote(esqRs.value("requete_column_param")) + ")";

							Etn.executeCmd(insQuery);
						}
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
		else if(requeteSelectedQueriesToken.length == 0) filegenerated = false;//making sure if all queries are deleted we dont reload the json or it can mess up things
	}


	Set rsParams = Etn.execute("select distinct param from expert_system_query_params where json_id = " + escape.cote(jsonid));
	URL reqeuteUrl = null;
	BufferedReader in = null;
	String requeteQueryListResponse = "";
	String requeteQueryListJson = "";
 
	try{

		reqeuteUrl = new URL(GlobalParm.getParm("REQUETE_WEB_APP")+"?f=liste_requete");
//		reqeuteUrl = new URL(GlobalParm.getParm("REQUETE_WEB_APP")+"ws/es.jsp?f=launch_requete&requete_id=1357&format=json");
		in = new BufferedReader( new InputStreamReader(reqeuteUrl.openStream()));

		while ((requeteQueryListResponse = in.readLine()) != null) requeteQueryListJson += requeteQueryListResponse;
		
		in.close();
	}catch(Exception e){
		System.out.println(e.toString());
	}finally{
		if(null != in) in.close();
	}

	Set rs = Etn.execute(" select * from expert_system_queries where json_id = " + escape.cote(jsonid) + " order by id ");

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/Strict.dtd">
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Expert System</title>

<link href="css/abcde.css" rel="stylesheet" type="text/css" />

<link rel="stylesheet" type="text/css" href="css/ui-lightness/jquery-ui-1.8.18.custom.css" />
<link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />

<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="js/jquery-ui-1.8.18.custom.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../js/bootstrap.min.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="json.js"></script>

</head>
<body>
	<center>
		<form name='myForm' id='myForm' action='editQueriesRequete.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonid)%>' method='post'>
			<input type='hidden' name='save' value='1' />
			<input type='hidden' name='reloadJson' id='reloadJson' value='0' />
			<input type="hidden" id="reqeute_selected_queries_update" name="reqeute_selected_queries_update" value="">
			<div style="margin-top: 10px;">
				<div style='float:left;width:13%'>
					<div style='font-weight:bold; color:white; background:gray'>Query Parameters</div>		
					<div style='text-align:left'>
						<table id='params' cellspacing=0 cellpadding=0 border=0 class="resultat" width="100%">
							<thead><th>Params</th></thead>
							<% while(rsParams.next()) {%>
							<tr>
								<td><%=rsParams.value("param")%></td>
							</tr>
							<% } %>
						</table>
					</div>
				</div>
				<div style='height:580px; overflow:auto;float: left;width: 60%;'>
					<table class="resultat" cellpadding="0" cellspacing="0" border="0" id="qryTable" width="100%">
					<%  
						int qrycount = 0;
						while(rs.next()) { %>			
						<tr>			
							<input type='hidden' name='qrycounts' value='<%=qrycount%>' />	
							<td align='center'><b>Query Name : </b><input type='text' name='qrydesc' class='qrydesc' maxlength='100' size='50' value='<%=parseNull(rs.value("description"))%>'/><input type="hidden" name="is_requete_query" value='<%=parseNull(rs.value("is_requete_query"))%>' /><input type="hidden" name="requete_query_id_value" id="requete_query_id_value" value='<%=parseNull(rs.value("requete_query_id"))%>' /><input type="hidden" name="es_query_id" id="es_query_id" value='<%=parseNull(rs.value("id"))%>' /><br/><textarea <% if(parseNull(rs.value("is_requete_query")).equals("1")){ %> readonly <% } %> id="<%=qrycount%>_qry" rows='5' cols='100' name='qry' class="qry"><%=parseNull(rs.value("query"))%></textarea></td>			
							<td>
								<div id='<%=rs.value("id")%>' style="float: right; margin-top: -50px;">

									<%
										if(parseNull(rs.value("is_requete_query")).equals("1") && parseNull(rs.value("requete_query_id")).length()>0){
									%>
											<span id='<%=parseNull(rs.value("requete_query_id"))%>' style="cursor: pointer;" onclick="edit_es_query(this);" class="glyphicon glyphicon-pencil"></span>
									<%
										}
									%>
										<span style="cursor: pointer;" onclick="delete_es_query(this);" class="glyphicon glyphicon-remove close-img"></span>
								</div>
								<div>								
									<select name='query_type'>
										<option value=''>----</option>
										<option value='array' <%if(parseNull(rs.value("query_type")).equals("array")){%>selected<%}%> >Array</option>
										<option value='array-with-labels' <%if(parseNull(rs.value("query_type")).equals("array-with-labels")){%>selected<%}%> >Array with labels</option>
										<option value='c3' <%if(parseNull(rs.value("query_type")).equals("c3")){%>selected<%}%> >C3</option>
										<option value='d3' <%if(parseNull(rs.value("query_type")).equals("d3")){%>selected<%}%> >D3</option>
										<option value='d3map' <%if(parseNull(rs.value("query_type")).equals("d3map")){%>selected<%}%> >D3Map</option>
										<option value='d3mapchl' <%if(parseNull(rs.value("query_type")).equals("d3mapchl")){%>selected<%}%> >D3MapChl</option>
									</select>
								</div>
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
							<td align='center'><b>Query Name : </b><input type='text' name='qrydesc' class='qrydesc' maxlength='100' size='50' value=''/><input type="hidden" name="is_requete_query" value='0' /><input type="hidden" name="es_query_id" id="es_query_id" value='' /><br/><textarea id="<%=qrycount%>_qry" rows='5' cols='100' name='qry' class="qry"></textarea></td>			
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
				<div style="width: 2%; float: left; margin-top: 290px;">
					<span id="saveRequeteQuery" style="cursor: pointer; font-size: x-large;" class="glyphicon glyphicon-arrow-left"></span>
				</div>
				<div style='width:25%;float: left;'>
					<div style='font-weight:bold; color:white; background:gray'>Requete Queries</div>		
					<div style="text-align: left; margin-top: 5px;">
						<%
							if(requeteQueryListJson.length()>0){
								String selected = "";
						%>
								<table cellspacing=0 cellpadding=0 border=0 class="resultat" width="100%">
									<thead><th>Queries :</th></thead>
									<tr>
										<td>											
											<select name="reqeute_selected_queries" id="reqeute_selected_queries" multiple="" style="margin-top: 5px;height:540px; width: 100%;">
										<%
												Gson gson = new Gson();
										        Type stringObjectMap = new TypeToken<List<Object>>(){}.getType();
											    List<Object> list = gson.fromJson(requeteQueryListJson, stringObjectMap);
											    Iterator itr = list.iterator();

											    while(itr.hasNext()){
													Map<String, String> map = (Map) itr.next();
										%>
													<option value='<%=map.get("requete_id")%>' ><%=map.get("requete_name")%></option>								
										<%
												}
										%>
											</select>									
										</td>
									</tr>
								</table>

						<%
							}
						%>
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
			var reloadurl = '<%=generateJspsUrl%><%=filename%>?__es=1';

//			var paramcounter = 0;
			<% 
				rsParams.moveFirst();	
				while(rsParams.next())
				{ 
			%>
					params.push('<%=rsParams.value("param")%>');
//					if(paramcounter++ == 0) reloadurl += "?";
//					else reloadurl += "&";
//					reloadurl += "<%=rsParams.value("param")%>=<%=parseNull(rsParams.value("default_value"))%>";
			<%				
				}		
			%>

			edit_es_query = function(element){

				var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
				propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
				propriete += ",width=1250" + ",height=800"; 
				win = window.open("<%=request.getContextPath()%>/pages/addRequeteFilters.jsp?requete_id="+$(element).attr("id")+"&query_id="+$(element).parent().attr("id")+"&json_id=<%=CommonHelper.escapeCoteValue(jsonid)%>","Requete column filter", propriete);
				win.focus();
			}

			delete_es_query = function(element){

				if(!confirm("Are you sure to delete this query?")) return false;

				$.ajax({
					url : "deleteExpertSystemQuery.jsp",
					type: 'POST',
					data : {query_id : $(element).parent().attr("id")},
					dataType : 'json',
					success : function(json)
					{		
						if(json.RESPONSE=="SUCCESS") window.location = "editQueriesRequete.jsp?jsonid=<%=CommonHelper.escapeCoteValue(jsonid)%>&save=1";
					},
					error : function()
					{
						alert("Some error occurred while communicating with the server");
					}
				});								

			}

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
				Set rsqpr = Etn.execute("select * from expert_system_query_params where query_id = " + rs.value("id"));
				while(rsqpr.next())
				{
			%>
				$('#<%=qrycount%>_params').append("<tr><td><input type='hidden' name='<%=qrycount%>_qryparams' value='<%=rsqpr.value("param")%>' /><%=rsqpr.value("param")%></td><td><input type='text' name='<%=qrycount%>_paramsdefaultvalue' class='paramsdefaultvalue' value='<%=parseNull(rsqpr.value("default_value"))%>' size='25' /></td></tr>"); 							
				pushqryparam('<%=qrycount%>','<%=rsqpr.value("param")%>');
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

				var requeteObj = $(".glyphicon-pencil");
				var requeteId = "";

				for(var i=0; i<requeteObj.length; i++){
					requeteId += $(requeteObj).attr("id");
					if(i!=(requeteObj.length-1)) requeteId += ",";
				}
				$("#reqeute_selected_queries_update").val(requeteId);
				saveDataEsQuery();
			});

			$("#saveRequeteQuery").click(function(){
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
					if(confirm("Some of the parameters have no default value. Are you sure to continue with save?")){

						var selectedRequeteQueries = $("#reqeute_selected_queries").val();
						var requeteQueriesParams = "";

						if(selectedRequeteQueries.length>0) requeteQueriesParams = "?";

						for(var i=0; i<selectedRequeteQueries.length; i++){

							requeteQueriesParams += "requete_id="+selectedRequeteQueries[i];
							if(i != (selectedRequeteQueries.length-1)) requeteQueriesParams += "&";
						}

						requeteQueriesParams += "&json_id=<%=CommonHelper.escapeCoteValue(jsonid)%>";
						var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
						propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
						propriete += ",width=1250" + ",height=800"; 
						win = window.open("<%=request.getContextPath()%>/pages/addRequeteFilters.jsp"+requeteQueriesParams,"Requete column filter", propriete);
						win.focus(); 								

//						$("#myForm").submit();
					} 
				}	
				else{
					var selectedRequeteQueries = $("#reqeute_selected_queries").val();
					var requeteQueriesParams = "";

					if(selectedRequeteQueries.length>0) requeteQueriesParams = "?";

					for(var i=0; i<selectedRequeteQueries.length; i++){

						requeteQueriesParams += "requete_id="+selectedRequeteQueries[i];
						if(i != (selectedRequeteQueries.length-1)) requeteQueriesParams += "&";
					}

					requeteQueriesParams += "&json_id=<%=CommonHelper.escapeCoteValue(jsonid)%>";
					var propriete = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
					propriete += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
					propriete += ",width=1250" + ",height=800"; 
					win = window.open("<%=request.getContextPath()%>/pages/addRequeteFilters.jsp"+requeteQueriesParams,"Requete column filter", propriete);
					win.focus(); 								
					//$("#myForm").submit();
				} 
			}

			saveDataEsQuery=function()
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
				saveDataEsQuery();
			});

			$("#saveBtn").click(function(){
				$("#reloadJson").val("0");
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
				if(v != '' && v.indexOf("@") > -1)
				{
					var vs = v.split("@");
					//we ignore the first index as its always the first part of query
					for(var i = 1; i < vs.length; i++)
					{
						var pr = $.trim(vs[i]);
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