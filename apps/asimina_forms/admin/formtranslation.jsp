<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.util.Base64, java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, java.net.*, java.util.*, org.json.*"%>

<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="common.jsp"%>

<%
	String loadTranslation = parseNull(request.getParameter("load_translaion"));
	String selectedFormId = parseNull(request.getParameter("fid"));
	String dbname = com.etn.beans.app.GlobalParm.getParm("FORMS_DB");
	String url = "";

	if(loadTranslation.length() > 0 && loadTranslation.equals("load_translaion") && selectedFormId.length() > 0){
		
		String query = "SELECT label, placeholder, options, title, success_msg, err_msg FROM " + dbname + ".process_forms pf, " + dbname + ".process_form_fields pff WHERE pf.form_id = pff.form_id AND pf.form_id = " + escape.cote(selectedFormId) + " AND type NOT IN ( " + escape.cote("imgupload") + "," + escape.cote("button") + "," + escape.cote("fileupload") + ")";

		String label = "";
		String placeholder = "";
		String formTitle = "";
		String formSuccessMsg = "";
		String errorMessage = "";
		String options = "";

		Set rs = Etn.execute(query);

		JSONObject optionJson = null;      
		JSONArray optionTxtArray = null;

		List<String> labels = new ArrayList<String>();
		
		labels.add("Select an option");
		labels.add("You must fill the value");

		while(rs.next()){

			label = parseNull(rs.value("label"));
			placeholder = parseNull(rs.value("placeholder"));
			formTitle = parseNull(rs.value("title"));
			formSuccessMsg = parseNull(rs.value("success_msg"));
			errorMessage = parseNull(rs.value("err_msg"));
			options = parseNull(rs.value("options"));

			labels.add(label);
			labels.add(placeholder);
			labels.add(formTitle);
			labels.add(formSuccessMsg);
			labels.add(errorMessage);

			if(options.length() > 0){

				optionJson = new JSONObject(options);
				optionTxtArray = optionJson.getJSONArray("txt");
				
				for(int i=0; i < optionTxtArray.length(); i++){

					labels.add(optionTxtArray.get(i).toString());
				}
			}
		}

		url = "formtranslation.jsp?fid="+selectedFormId;
		request.setAttribute("langue_ref_list", labels);
	}

%>

 <!DOCTYPE html>
<html>
<head>
	<title>Translation</title>


	<SCRIPT LANGUAGE="JavaScript" SRC="<%=request.getContextPath()%>/js/jquery.min.js"></script>

	<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/boosted.min.css" />

	<script type="text/javascript">
		
		function load_form_translation(){

			$("#form_template").submit();
		}

	</script>
</head>
<body style="min-height: 2000px; padding-top: 70px;">

	<jsp:include page="libmsgs.jsp">
		<jsp:param name="requestingpage" value="<%=url%>"/>
	</jsp:include>

</body>
</html>