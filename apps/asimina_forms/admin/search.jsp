<%@page import="com.etn.beans.Contexte"%>
<%@page import="com.etn.lang.Xml.Rs2Xml"%>
<%@page import="com.etn.sql.escape"%>

<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.util.ItsDate"%>
<%@ page import="java.util.*, java.io.*, org.apache.commons.fileupload.*, org.apache.commons.fileupload.servlet.*, org.apache.commons.fileupload.disk.*,java.text.SimpleDateFormat,com.etn.asimina.util.FileUtil"%>
<%@ page import="org.json.*"%>
<%@ page import="com.etn.beans.app.GlobalParm"%>
<%@ page import="com.etn.util.Base64"%>
<%@ page import="com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language" %>
<%@ include file="../common2.jsp" %>

<!DOCTYPE html>

<html>
<head>
	<title>Form Replies</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

	<style type="text/css">

	    th, td { white-space: nowrap; }
		.ui-dialog { z-index: 99999 !important ;}
 	</style>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">

<%
	Set formFilterRs = Etn.execute("SELECT form_id FROM "+GlobalParm.getParm("CATALOG_DB")+".person_forms pf inner join profilperson pp on pp.person_id = pf.person_id inner join profil p on p.profil_id = pp.profil_id where p.assign_site='1' and pf.person_id="+escape.cote(""+Etn.getId()));
    List<String> formIds = new ArrayList<String>();

    while(formFilterRs.next())
    {
        formIds.add(parseNull(formFilterRs.value("form_id")));
    }

	String siteId = getSelectedSiteId(session);

	String formid = parseNull(request.getParameter("___fid"));
	String isDeleteId = parseNull(request.getParameter("isdelete"));
	String isUserSearch = parseNull(request.getParameter("is_user_search"));
	String isGame = parseNull(request.getParameter("isGame"));
	String contentType = parseNull(request.getContentType());
	String importClientMsg = "";

	if(formIds.size() >0  && !formIds.contains(formid))
	{
	    response.setStatus(javax.servlet.http.HttpServletResponse.SC_MOVED_TEMPORARILY);
       	response.setHeader("Location", "process.jsp?msg=Form not found");
		return;
	}

	if(contentType.length() > 0 && contentType.contains("multipart/form-data")){


		try{
			System.out.println("=================>");
	        String field = "";
	        String value = "";
	        String multipleFieldValue = "";
			String fileName = "";
			String fileExtension = "";
			String modifiedFileName = "";
			String tableName = "";
			String formType = "";

	        String mid = "";
	        String menuLang = "";

	        String userIp = request.getHeader("X-FORWARDED-FOR");  
	        if (userIp == null) userIp = "";  

			Set rs = Etn.execute("SELECT * FROM process_forms pf WHERE pf.form_id = " + escape.cote(formid));

			if(rs.next()){

				tableName = parseNull(rs.value("table_name"));
				formType = parseNull(rs.value("type"));
			}

			Set menuRs = Etn.execute("select sm.id, sm.lang from " + GlobalParm.getParm("PROD_PORTAL_DB") + ".sites s, " + GlobalParm.getParm("PROD_PORTAL_DB") + ".site_menus sm where s.id = sm.site_id and s.id = " + escape.cote(siteId) + " limit 1");

			if(menuRs.next()){

				mid = parseNull(menuRs.value("id"));
				menuLang = parseNull(menuRs.value("lang"));
			}

			FileItemFactory factory = new DiskFileItemFactory();
			ServletFileUpload upload = new ServletFileUpload(factory);
			
			List items = null;

			upload.setHeaderEncoding("UTF-8");
			items = upload.parseRequest(request);

			Iterator itr = items.iterator();
			List<FileItem> files = new ArrayList<FileItem>();

			Map<String, String> filesMap = new HashMap<String, String>();

	        while (itr.hasNext()) {

				FileItem item = (FileItem)(itr.next());

				if (!item.isFormField()) {

					field = item.getFieldName();
					value = item.getName();

					if(filesMap.containsKey(field)){

						multipleFieldValue = filesMap.get(field) + "!@##@!" + value;
						filesMap.put(field, multipleFieldValue);

					} else {

						filesMap.put(field, value);
					}

					files.add(item);
				} 
			}

			for(FileItem fi : files) {

				java.text.DateFormat df = new java.text.SimpleDateFormat("ddMMyyHHmmss");
				String currentDate = df.format(new Date());

				//cleanup file name so that user has not uploaded a file with some paths in it to abuse the system
				String f = parseNull(fi.getName()).replaceAll("/", "").replaceAll("\\\\", "");

				if(f.length() > 0 ) {

					fileName = f.substring(0, f.length()-4);
					fileExtension = f.substring(f.length()-4, f.length());
					modifiedFileName = fileName + currentDate + fileExtension;

					if(fileExtension.equalsIgnoreCase(".csv")) {
						
						// if(!new File(GlobalParm.getParm("FORM_UPLOADS_ROOT_PATH") + "importuserdata").exists())
						    FileUtil.mkDir(GlobalParm.getParm("FORM_UPLOADS_ROOT_PATH") + "importuserdata");//change
							// new File(GlobalParm.getParm("FORM_UPLOADS_ROOT_PATH") + "importuserdata").mkdir();

						String importFilePath = GlobalParm.getParm("FORM_UPLOADS_ROOT_PATH") + "importuserdata/" + modifiedFileName;

						int count = 0;

		 				File inputFile = FileUtil.getFile(importFilePath);//change
						fi.write(inputFile);

						BufferedReader br = new BufferedReader(new FileReader(importFilePath));

						String readLine = "";
						String params = "form_id, created_on, created_by, updated_by, userip, mid, menu_lang, is_admin";
						String values = "";
						int usernameIndex = 0;
						int emailIndex = 0;
						String username = "";
						String email = "";
						boolean formHasLoginField = false;
						int columnCount = 0;

						if((readLine = br.readLine()) != null){

							String[] userData = readLine.split(";");
							columnCount = userData.length;

							if(userData.length > 0){

								if(userData[0].equalsIgnoreCase("email"))
									emailIndex = 0;

								if(userData[0].equalsIgnoreCase("login")){
									usernameIndex = 0;
									formHasLoginField = true;
								}

								String val = userData[0].substring(0, userData[0].length());
								if(val.startsWith("\""))
									val = val.substring(1);

								if(val.endsWith("\""))
									val = val.substring(0, val.length()-1);

								params += ",_etn_" + val + ",";
							}

							for(int i=1; i < userData.length; i++){

								if(userData[i].equalsIgnoreCase("email") || userData[i].equalsIgnoreCase("email;"))
									emailIndex = i;

								if(userData[i].equalsIgnoreCase("login") || userData[i].equalsIgnoreCase("login;")){
									usernameIndex = i;
									formHasLoginField = true;
								}

								String val = userData[i];
								if(val.startsWith("\""))
									val = val.substring(1);

								if(val.endsWith("\""))
									val = val.substring(0, val.length()-1);

								params += "_etn_" + val + ",";
							}

							if(params.length() > 0){

								params = params.substring(0, params.length()-1);
							}

						}

						int rowCount = 0;
						while ((readLine = br.readLine()) != null) {

							rowCount++;
							String[] userData = readLine.split("\\;",-1);

							values = escape.cote(formid) + ",NOW()," + Etn.getId() + "," + Etn.getId() + "," + escape.cote(userIp) + "," + escape.cote(mid) + "," + escape.cote(menuLang) + ",1";

							if(userData.length > 0){

								String v = userData[0].substring(0, userData[0].length());

								if(v.startsWith("\""))
									v = v.substring(1);

								if(v.endsWith("\""))
									v = v.substring(0, v.length()-1);

								values +=  "," + escape.cote(v) + ",";
								username = userData[usernameIndex];

								if(username.startsWith("\""))
									username = username.substring(1);

								if(username.endsWith("\""))
									username = username.substring(0, username.length()-1);

								email = userData[emailIndex];

								if(email.startsWith("\""))
									email = email.substring(1);

								if(email.endsWith("\""))
									email = email.substring(0, email.length()-1);

							}

							for(int i=1; i < userData.length-1; i++){

								String vs = userData[i];

								if(vs.startsWith("\""))
									vs = vs.substring(1);

								if(vs.endsWith("\""))
									vs = vs.substring(0, vs.length()-1);

								values += escape.cote(vs) + ",";

							}

							if(userData.length > 0){

								if(usernameIndex == 0){

									username = username.substring(0, username.length());
									if(username.startsWith("\""))
										username = username.substring(1);

									if(username.endsWith("\""))
										username = username.substring(0, username.length()-1);

								}

								if(emailIndex == 0){

									email = email.substring(0, email.length());
	
									if(email.startsWith("\""))
										email = email.substring(1);

									if(email.endsWith("\""))
										email = email.substring(0, email.length()-1);
								}

								String vss = userData[userData.length-1].substring(0, userData[userData.length-1].length());

								if(vss.startsWith("\""))
									vss = vss.substring(1);

								if(vss.endsWith("\""))
									vss = vss.substring(0, vss.length()-1);

								values += escape.cote(vss) + ",";

							}

							if(values.length() > 0){

								values = values.substring(0, values.length()-1);

								if(usernameIndex == (userData.length-1)){

									username = username.substring(0, username.length()-2);
								}

								if(emailIndex == (userData.length-1)){

									email = email.substring(0, email.length()-2);
								}


							}

							if(columnCount == userData.length){

								JSONObject verifyClientObject = verifyClient(Etn, request, formHasLoginField, username, email, GlobalParm.getParm("PROD_PORTAL_DB"), siteId, formType);

								JSONObject verifyUserCustomTableObject = verifyUserInCustomTable(Etn, request, formHasLoginField, username, email, formType, tableName);

								if(verifyClientObject.getString("status").equals("0") && verifyUserCustomTableObject.getString("status").equals("0")){

									int rowId = Etn.executeCmd("INSERT INTO " + tableName + "(" + params + ") VALUES(" + values + ")");
									//System.out.println("INSERT INTO " + tableName + "(" + params + ") VALUES(" + values + ")");
									if(rowId > 0){

						                Etn.execute("INSERT INTO post_work(proces, phase, priority, insertion_date, client_key, form_table_name) VALUES (" + escape.cote(tableName) + "," + escape.cote("FormSubmitted") + ", NOW(), NOW() ," + escape.cote(""+rowId) + "," + escape.cote(tableName) + ")");

						                Etn.execute("select semfree('" + GlobalParm.getParm("SEMAPHORE") + "');");
		
										if(formHasLoginField){

											importClientMsg += "Row no " + rowCount + ":\t\t"+libelle_msg(Etn, request, "Successfully registered")+"<br/>";

										} else {

											importClientMsg += "Row no " + rowCount + ":\t\t"+libelle_msg(Etn, request, "Successfully registered")+"<br/>";
										}

									}

								} else {

//									if(formHasLoginField){

									importClientMsg += "Row no " + rowCount + ":\t\t"+verifyUserCustomTableObject.getString("message")+"<br/>";
/*
									} else {

										importClientMsg += "Row:\t\t"+verifyClientObject.getString("message")+"<br/>";
									}
*/
								}
							} else {

								importClientMsg += "Row no " + rowCount + ":\t\t Provided columns count or values doesn't matched.<br/>";
/*
								if(formHasLoginField){

									importClientMsg += username+":\t\t Provided columns count or values doesn't matched for this username.<br/>";

								} else {

									importClientMsg += email+":\t\t Provided columns count or values doesn't matched for this email.<br/>";
								}								
*/
							}
						}

					} else {

						importClientMsg = "Only CSV file accepted.";
					}

				} else {

					importClientMsg = "Found no file.";
				}
			}
		} /*catch(IOException ioe){
		
			errorLogging.append(ioe.toString());
			displayErrorLogging(modifiedFileName);
			ioe.printStackTrace();
		}*/ catch(IllegalStateException ise){

			ise.printStackTrace();

		} catch (FileUploadException e) {
			
			e.printStackTrace();
		} catch (Exception e) {

			e.printStackTrace();
		}


%>
		<script type="text/javascript">
			
			$(document).ready(function(){

				$("#import_client_modal").modal("show");
			})

		</script>

<%

	}

	if(isDeleteId.equals("1")){

		String tblnme = parseNull(request.getParameter("___noe_tbl"));
		String pkey = parseNull(request.getParameter("___noe_prkey"));
		String[] deleteid = request.getParameterValues("selectedids");
		for(String id : deleteid){
			
			if(id.length() > 0){

				int rid = Etn.executeCmd("delete from " + tblnme + " where " + pkey + " = " + escape.cote(id));
		
		        if(rid > 0) {
		            Etn.executeCmd("DELETE FROM " + GlobalParm.getParm("PROD_PORTAL_DB") + ".clients WHERE site_id = " + escape.cote(siteId) + " and form_row_id = " + escape.cote(id));
		        }
			}
		}
	}

	Set rsf = Etn.execute("SELECT * FROM process_forms WHERE form_id = " + escape.cote(formid));
	Set selectedListRs = null;
	Map selectedElementValueMap = new HashMap<String, String>();
	int dbColumnCount = 0;
	if(rsf.rs.Rows == 0)
	{
		out.write("<div style='text-align:center; margin-top:20px; font-weight:bold; color:red'>Form not published yet</div>");
		return;
	}

	rsf.next();

	String processname = parseNull(rsf.value("process_name"));
	String lang = parseNull(request.getParameter("lang"));
	String formType = parseNull(rsf.value("type"));
	String lsu = parseNull(request.getParameter("lsu"));
	
	if(lang.length() == 0)
		lang = getLangs(Etn,session).get(0).getCode();

	String langId = LanguageFactory.instance.getLanguage(lang).getLanguageId();

	Set selectedFilterRs = Etn.execute("select f.*, pffd.*, m.show_range from form_search_fields m, process_form_fields f, process_form_field_descriptions pffd where f.form_id = m.form_id and f.field_id = m.field_id and f.form_id = pffd.form_id and f.field_id = pffd.field_id and m.form_id = " + escape.cote(formid) + " and pffd.langue_id = " + escape.cote(langId) + " order by coalesce(m.display_order) ");
	Set selectedResultRs = Etn.execute("select f.*, pffd.* from form_result_fields m, process_form_fields f, process_form_field_descriptions pffd where f.form_id = m.form_id and f.field_id = m.field_id and f.form_id = pffd.form_id and f.field_id = pffd.field_id and m.form_id = " + escape.cote(formid) + " and pffd.langue_id = " + escape.cote(langId) + " order by coalesce(m.display_order) ");

	String tablename = rsf.value("table_name");
	String primarykey = tablename + "_id";
	boolean loadTestSiteUser = false;
	String testSiteUserParams = "";
	String loadButtonLabel = "Load test site data";
	String portalDB = GlobalParm.getParm("PROD_PORTAL_DB");

	if(lsu.length() > 0 && lsu.equals("1")){
		loadTestSiteUser = true;
		portalDB = GlobalParm.getParm("PORTAL_DB");
	}
	if(!loadTestSiteUser){
		testSiteUserParams = " and COALESCE(portalurl,'prod_user') NOT LIKE '%\\_portal/' ";
		loadButtonLabel = "Load test site data";
	
	} else {

		testSiteUserParams = " and COALESCE(portalurl,'prod_user') LIKE '%\\_portal/' ";
		loadButtonLabel = "Load prod site data";
	}
	
	String createdOnDateFrom = parseNull(request.getParameter("___rngf_created_on"));
	String createdOnDateTo = parseNull(request.getParameter("___rngt_created_on"));
    String repliesDateFrom = createdOnDateFrom;
    String repliesDateTo = createdOnDateTo;

	String qry = "select pw.id as post_work_id, ct.*, '' as user_last_login from " + tablename + " ct LEFT JOIN post_work pw ON pw.form_table_name = " + escape.cote(tablename) + " and pw.client_key = ct." + primarykey+ " where 1 = 1 "+ testSiteUserParams ;
	if(formType.equals("forgot_password")){
		qry = "SELECT COALESCE(cl.id,'') as ck_id, cte._etn_email AS _etn_email, cte._etn_login AS _etn_login, cl.mobile_number as _etn_mobile_phone, cl.last_login_on AS user_last_login, cl.avatar as _etn_avatar, COALESCE(cl.civility,'Mr.') as _etn_civility, cl.client_uuid AS clientUuid, cte.created_on as created_on, cte."+tablename+"_id as "+tablename+"_id, cte.rule_id as rule_id, cte.portalurl as portalurl FROM "+tablename+" cte LEFT JOIN "+portalDB+".clients cl ON cl.site_id = "+escape.cote(siteId)+" AND cte._etn_login = cl.username WHERE 1 = 1 "+testSiteUserParams;
	}
	else if(formType.equals("sign_up")){
		qry="SELECT COALESCE(pw.id,'') AS post_work_id, abc.* FROM ("+signUpFormQuery(Etn,selectedResultRs,tablename,portalDB,testSiteUserParams,siteId)+" ) AS abc left join post_work pw on pw.form_table_name = "+escape.cote(tablename)+" and pw.client_key = abc."+tablename+"_id WHERE 1 = 1 "+testSiteUserParams;
	}
	
	boolean issearched = false;

	String gotoUrl = "";
	String filteredColumns = "";


	while(selectedResultRs.next())
		filteredColumns+=parseNull(selectedResultRs.value("db_column_name"))+",";
	
	selectedResultRs.moveFirst();

	if(isUserSearch.length() > 0 && isUserSearch.equals("1")){

		while(selectedFilterRs.next())
		{
			
			String param = parseNull(selectedFilterRs.value("db_column_name"));
			String _type = parseNull(selectedFilterRs.value("type"));
			if("text".equalsIgnoreCase(_type) || "textarea".equalsIgnoreCase(_type)  || "textfield".equalsIgnoreCase(_type) || "password".equalsIgnoreCase(_type)  || "autocomplete".equalsIgnoreCase(_type))
			{
				String val = parseNull(request.getParameter(param));
				if(val.length() > 0)
				{
					qry += " and " + param + " like " + escape.cote(val + "%");
					gotoUrl += "&" + param + "=" + val;
					issearched = true;
				}
			}
			else if("1".equals(parseNull(selectedFilterRs.value("show_range"))))
			{
				String fval = parseNull(request.getParameter("___rngf_"+selectedFilterRs.value("db_column_name")));
				String tval = parseNull(request.getParameter("___rngt_"+selectedFilterRs.value("db_column_name")));

				if(fval.length() > 0)
				{
					fval = buildDateFr(fval);
					qry += " and " + param + " >= " + escape.cote(fval);
					gotoUrl += "&" + param + "=" + fval;
					issearched = true;
				}
				if(tval.length() > 0)
				{
					tval = buildDateFr(tval);
					qry += " and " + param + " <= " + escape.cote(tval);
					gotoUrl += "&" + param + "=" + tval;
					issearched = true;
				}
			}
			else
			{
				String val = parseNull(request.getParameter(param));
				if(val.length() > 0)
				{
					qry += " and " + param + " like " + escape.cote(val + "%");
					gotoUrl += "&" + param + "=" + val;
					issearched = true;
				}
			}
		}
	}
	
	if(createdOnDateFrom.length() > 0) {
		long l1 = ItsDate.getDate(parseNull(createdOnDateFrom));
		String z1 = ItsDate.stamp(l1);
		
		String outputPattern = "yyyy-MM-dd HH:mm:ss";
        SimpleDateFormat inputFormat = new SimpleDateFormat("yyyyMMddHHmmss");
        SimpleDateFormat outputFormat = new SimpleDateFormat(outputPattern);
		Date date = inputFormat.parse(z1);
		String formattedDate = outputFormat.format(date);
		qry += " and created_on >= " + escape.cote(formattedDate);
		issearched = true;
	}

	if(createdOnDateTo.length() > 0) {
		long l1 = ItsDate.getDate(parseNull(createdOnDateTo));
		String z1 = ItsDate.stamp(l1);
		z1 = z1.substring(0,8) + "235959";
		String outputPattern = "yyyy-MM-dd HH:mm:ss";
        SimpleDateFormat inputFormat = new SimpleDateFormat("yyyyMMddHHmmss");
        SimpleDateFormat outputFormat = new SimpleDateFormat(outputPattern);
		Date date = inputFormat.parse(z1);
		String formattedDate = outputFormat.format(date);
		qry += " and created_on <= " + escape.cote(formattedDate);
		issearched = true;
	}
	////if no criteria given we will search demands added past 4 weeks
	/*if(!issearched && (repliesDateFrom.length() == 0  || repliesDateTo.length() == 0)) 
	{
		Set rsD = Etn.execute("select DATE_FORMAT(adddate(now(), interval -30 day), '%d/%m/%Y') as replies_date_from, DATE_FORMAT(now(), '%d/%m/%Y') as replies_date_to ");
		rsD.next();
	    if(repliesDateFrom.length() == 0) repliesDateFrom = rsD.value("replies_date_from");
	    if(repliesDateTo.length() == 0) repliesDateTo = rsD.value("replies_date_to");
		
		qry += " and created_on >= "+repliesDateFrom+" and created_on <="+repliesDateTo;
	}*/

	if(formType.equals("simple"))
		qry +=  " GROUP BY ct."+tablename+"_id ";
	else if (formType.equals("sign_up"))
		qry +=  " GROUP BY abc._etn_login ";
	
	qry += " ORDER BY created_on DESC "; 

	session.setAttribute("qry",qry);
	if(filteredColumns.length() > 0)
	session.setAttribute("filteredColumns",filteredColumns.substring(0,filteredColumns.length()-1));

    int nbLignes = parseNullInt(request.getParameter("nbLignes")); // Nombre de commandes max affichees par pages
    if(nbLignes<=0) nbLignes = 25;
    String orderBy = parseNull(request.getParameter("orderBy"));
    int p = parseNullInt(request.getParameter("p"));
    int limFin = nbLignes;
	
	qry +=  " LIMIT " + p + ", " + limFin;
	
	Set results = Etn.executeWithCount(qry);
	int nbRes = Etn.UpdateCount;

	selectedFilterRs.moveFirst(); 

%>

	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div>
			<%
				if(formType.equalsIgnoreCase("simple")){
			%>
					<h1 class="h2">Form : <%=escapeCoteValue(processname)%></h1>
			<%
				} else if(formType.equalsIgnoreCase("sign_up")){
			%>
					<h1 class="h2">Clients</h1>
			<%
				}
			%>
				<p class="lead"></p>
			</div>

			<!-- buttons bar -->
			<div class="btn-toolbar mb-2 mb-md-0">
			<%
				if(formType.equalsIgnoreCase("sign_up")){
			%>
					<div class="btn-group mr-2" role="group" aria-label="...">

<!-- 						<button type="button" class="btn btn-success" id="importBtn" onclick='importCsv()'>Import CSV</button>
 -->
						<div class="custom-file">
							<label for="file-upload" class="btn btn-success">
								Import CSV
							</label>
						</div> 
		
					</div>

					<div class="btn-group mr-2" role="group" aria-label="...">
						<button type="button" class="btn btn-success" id="exportBtn" onclick='downloadTemplate()'>Download template</button>
					</div>
			<%
				}
			%>
				<div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" class="btn btn-success" id="exportBtn" onclick='exportCsv()'>Export to CSV</button>
				</div>
				<div class="btn-group mr-2" role="group" aria-label="...">
					<a href="<% if(isGame.equals("1")){%>games.jsp<%} else {%>process.jsp<%}%>" class="btn btn-primary" id="backBtn" >Back</a>
				</div>
				<div class="btn-group" role="group" aria-label="...">
                    <button type="button" class="btn btn-primary mr-2" onclick='javascript:window.location.href=window.location.href;' title="Refresh">
                    	<i data-feather="refresh-cw"></i>
                    </button>
				</div>
				<div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" class="btn btn-danger" id="deleteBtn" onclick=''>Delete</button>
				</div>

				<div class="btn-group mr-2" role="group" aria-label="...">
					<button type="button" class="btn btn-success" id="loadTestSiteUserBtn" load-user="<%=loadTestSiteUser%>" onclick=''><%=loadButtonLabel%></button>
				</div>
			<%
				if(formType.equalsIgnoreCase("sign_up")){
			%>
					<div class="btn-group mr-2" role="group" aria-label="...">
						<button type="button" class="btn btn-success btn-modal add_user_by_admin" id="add_new_user" role='button' data-toggle='modal' data-target='#add_user_by_admin'>Add user</button>
					</div>
			<%
				}
			%>				
			</div>
			<!-- /buttons bar -->
		</div>
	<!-- /title -->


	<!-- container -->
	<div class="animated fadeIn">
		<div>

			<% out.write(getSearchCriteriaHtml(Etn, selectedFilterRs, formid, request, repliesDateFrom, repliesDateTo, isDeleteId, lsu)); %>

			<div style='margin-top:15px'>
	
				<div style="display:none">
				<form id="expFrm" action="downloadCsv.jsp" method="post">						
					<input type='hidden' name='filename' value="<%=processname.replace("\"","\\\"")%>" >
					<input type='hidden' name='selectedids' id='selectedids' value="">						
					<input type='hidden' name='formid' value="<%=formid%>">
				</form>
				</div>
				<div class="card" >
					<div class="card-header">
						<div class="float-lg-left" style="padding: 5px;">
							Show
							<select name="nbLignes" class="" id="nbLignes" onchange="refreshScreen()">
								<option value="25">25</option>
								<option <%=nbLignes==50?"selected":""%> value="50">50</option>
								<option <%=nbLignes==100?"selected":""%> value="100">100</option>
							</select>
							Results
						</div>
						<div class="card-header-actions">
						<nav aria-label="Page navigation ">
						<ul class="pagination pull-right" style="margin:0">
		<%
			if (p > 0)
				out.write("<li class='page-item'> <a class='page-link' href='javascript:gotoPage(\""+orderBy+"\",\""+(p - nbLignes)+"\");' aria-label='Previous'> <span aria-hidden='true'>&laquo;</span> </a> </li>");
							for (int i = 1; i <= (nbRes / nbLignes) + 1; i++) {
									String active = "";
									if(i-1==p/nbLignes) active = "active";
									if (i == 1 && (p / nbLignes) > 3) {
										out.write("<li class='page-item "+active+"'> <a class='page-link' href='javascript:gotoPage(\""+orderBy+"\",0);'>"
													+ i
													+ "</a> </li>");
									}
						if (((i > (p / nbLignes) - 3) && (i < (p / nbLignes) + 5))) {
							out.write("<li class='page-item "+active+"'> <a class='page-link' href='javascript:gotoPage(\""+orderBy+"\",\""+((i - 1) * nbLignes)+"\")"+ "'>"+ i + "</a> </li>");
						}
						if (i == (nbRes / nbLignes)
								&& ((p / nbLignes) < (nbRes / nbLignes - 3))) {
							out.write("<li class='page-item "+active+"'> <a class='page-link' href='javascript:gotoPage(\""+orderBy+"\",\""+(((nbRes/nbLignes))* nbLignes)+"\")'>"+ ((nbRes/nbLignes)+1)+"</a> </li>");
						}

					}
					if (p <= (nbRes - nbLignes))
						out.write("<li class='page-item'> <a class='page-link' href='javascript:gotoPage(\""+orderBy+"\",\""+(p + nbLignes)+"\")' aria-label='Next'> <span aria-hidden='true'>&raquo;</span> </a> </li>");

		%>

						</ul>
						<em style="float:right;padding:6px 12px"><%=nbRes%> Records found</em>
						</nav>
						</div>
					</div>
					<div class="p-0 card-body">
						<form id='datafrm' class='form-horizontal' role='form' action='search.jsp?___fid=<%=escapeCoteValue(formid)%>' method='post' style='overflow:auto'>

							<input type="hidden" name="hide_modal" id="hide_modal" value="0">
							<input type="hidden" name="isdelete" id="isdelete" value="">
							<input type='hidden' name='___noe_tbl' value='<%=escapeCoteValue(tablename)%>' >
							<input type='hidden' name='___noe_prkey' value='<%=escapeCoteValue(primarykey)%>' >
							<input type='hidden' name='___noe_formid' value='<%=escapeCoteValue(formid)%>' >
							<input type='hidden' id='appcontext' value='<%=request.getContextPath()%>/' >
							<input type='hidden' id='___rngf_created_on_2' name='___rngf_created_on' value='<%=escapeCoteValue(repliesDateFrom)%>' >
							<input type='hidden' id='___rngt_created_on_2' name='___rngt_created_on' value='<%=escapeCoteValue(repliesDateTo)%>' >

							<%
								out.write(displayFormReplies(Etn, selectedResultRs, results, primarykey, formid, tablename, siteId, formType));
							%>

						</form>
					</div>
				</div>

				<form name="importUserDataFrm" id="importUserDataFrm" class="form-horizontal" role="form" action="search.jsp?___fid=<%=formid%>" enctype="multipart/form-data" method="post" autocomplete="off">

					<input type="hidden" name="mid_import" value="">
					<input type="hidden" name="menu_lang_import" value="">
					<input style="display: none;" id="file-upload" name="file-upload" type="file" accept=".csv, text/csv"/>
					<input type="hidden" name="is_ud_import" value="1">

				</form>

				<form id="exportUserDatatemplte" action="download.jsp?___fid=<%=formid%>" method="post">
					<input type="hidden" name="exp_formid" value='<%=formid%>'>
					<input type='hidden' name='exp_filename' value="<%=processname.replace("\"","\\\"")%>" >
				</form>
			</div>

			<!-- Reset Password -->
			<div class="modal fade" id="reset_password" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="reset_password form" aria-hidden="true">
				<div class='modal-dialog ' role='document'>
					<div class='modal-content'>
						<div class="mx-3 mt-3">
								<button type='button' class='close' data-dismiss='modal' onclick='javascript:$("#newPassword").val("");' aria-label='Close'>
									<span aria-hidden='true'>&times;</span>
								</button>
							
									<% Set rs = Etn.execute("Select form_id, table_name from "+GlobalParm.getParm("FORM_DB")+".process_forms where type='forgot_password' and site_id="+escape.cote(siteId));
										System.out.println("rows:"+rs.rs.Rows);
										if(rs.next()) {%>
										<div class='modal-title'>
											<div class='mr-2 my-3'>
												<a style="cursor:pointer;text-decoration:underline;"  title id="send_email">Send Reset Password Link</a>
											</div>
										</div>
										<strong class='mr-2'>OR</strong>
									<%
										}
									%>
							<div class='modal-title my-3'>Change Password</div>
						</div>
						<div class='modal-body'>
							<div style='font-size:10pt; text-align:center;'>
								<div id='validation-message'></div>
								<div>
									<input class='form-control' placeholder='New password' type='password' autocomplete='new-password' value='' id='newPassword' maxlength='50' size='30' />
								</div>
							</div>

							<div class='modal-footer'>
								<button type='button' class='btn btn-light' data-dismiss='modal' onclick='javascript:$("#newPassword").val("");'>Cancel</button>								
								<button type='button' class='btn btn-primary' id="change_password">Change Password</button>
							</div>
						</div>
					</div>
				</div>
			</div> 

			<!-- Modal edit form -->
			<div class="modal fade" id="view_form" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Edit form" aria-hidden="true">
				<div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document">
					<div class="modal-content">
						<div class="modal-header">
							<h5 class="modal-title" id="">Reply from :</h5>
	
							<button type="button" class="close" data-dismiss="modal" aria-label="Close">
								<span aria-hidden="true">&times;</span>
							</button>

						</div>

						<div id="view_form_content" class="modal-body">
								
						</div>

						<div class="modal-footer">
							<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
						</div>
					</div>
				</div>
			</div>

			<!-- Modal add new user by admin -->
			<div class="modal fade" id="add_user_by_admin" tabindex="-1" role="dialog" data-backdrop="static" aria-labelledby="Edit form" aria-hidden="true">
				<div class="modal-dialog modal-lg modal-dialog-slideout process-modal" role="document" style="width: 850px;">
					<div class="modal-content">
						<div class="modal-header">
							<h5 class="modal-title" id="">Add new user</h5>
	
							<button type="button" class="close" data-dismiss="modal" aria-label="Close">
								<span aria-hidden="true">&times;</span>
							</button>

						</div>

						<div id="add_user_content" class="modal-body" style="height: 85vh;">
								
						</div>

						<div class="modal-footer">
							<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
						</div>
					</div>
				</div>
			</div>


			</div>
			<div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
	</div>
	<br>
	<div id="dialogWindow" style="z-index: 140000000"></div>

	<div class="modal fade" id="import_client_modal" tabindex="-1" role="dialog" aria-labelledby="Import client modal" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered" role="document">
			<div class="modal-content">
				<div class="modal-header">
					<h5 class="modal-title" id="import_client_title">Import client detail</h5>
					<button type="button" class="close" data-dismiss="modal"></button>
				</div>
				<div style="height: 50vh; overflow-y: auto;" class="modal-body" id="import_client_msg"><%=importClientMsg.toString()%></div>
				<div class="modal-footer">
					<button type="button" class="btn btn-secondary" data-dismiss="modal"><%=libelle_msg(Etn, request, "Close")%></button>
				</div>
			</div>
		</div>
	</div>


</main>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

<script type="text/javascript" >

	function refreshScreen()
	{		
		gotoPage('<%=orderBy%>', '<%=p%>', $("#nbLignes").val());
	}

	function gotoPage(orderby, p, nbLignes)
	{		
		if(!nbLignes) nbLignes = "<%=nbLignes%>";
		from = document.getElementById('___rngf_created_on_2').value;
		to = document.getElementById('___rngt_created_on_2').value;
		let params = "___fid=<%=formid%>&lsu=<%=lsu%>&orderBy="+orderby+"&p="+p+"&nbLignes="+nbLignes+"&___rngf_created_on="+from+"&___rngt_created_on="+to;
		console.log("params",params);
		<% selectedFilterRs.moveFirst();
		while(selectedFilterRs.next()){
			out.write("params += '&"+parseNull(selectedFilterRs.value("db_column_name"))+"="+parseNull(request.getParameter(parseNull(selectedFilterRs.value("db_column_name"))))+"';\n");
		} %>
		let _url = "search.jsp?"+params;
		window.location=_url;
	}

	var usr = {};

	$(document).ready(function() {
		
		flatpickr(".ctextdate", {
			dateFormat: "d/m/Y",
			enableTime: false,
			allowInput: true
		});

		flatpickr(".ctextdatetime", {
			dateFormat: "d/m/Y H:i",
			enableTime: true,
			allowInput: true
		});

		flatpickr(".textdate", {
			dateFormat: "Y-m-d",
			enableTime: false,
			allowInput: true
		});

		flatpickr(".textdatetime", {
			dateFormat: "Y-m-d H:i",
			enableTime: true,
			allowInput: true
		});


		$("#change_password").on('click',function(){ resetPassword(<%= lsu.equals("1") %>,<%= false %>)});

	    $('input[type="file"]').change(function(e){
	        
	        var fullFileName = e.target.files[0].name;
	        var fileName = "";
	        var fileExtension = "";

	        if(fullFileName.length > 0){

	        	fileName = fullFileName.substring(0, fullFileName.length-4);
	        	fileExtension = fullFileName.substring(fullFileName.length-4, fullFileName.length);

	        	if(fileExtension !== ".csv"){
	        		alert("Expected only csv file.");
	        		return false;
	        	}

				bootConfirm("Are you sure to import the file?<br/>filename : <b>" + fullFileName + "</b>",function(result)	{

					if(result) $("#importUserDataFrm").submit();		
				});
	        }
	    });

		$("#deleteBtn").on("click", function(){

			if($(".slt_option:checked").length > 0){
				if(confirm("Are you sure to delete the replies?")){
					$("#isdelete").val("1")
					$("#datafrm").submit();
				}

			} else {
				alert("No replies selected.");				
			}

		});

		$("#loadTestSiteUserBtn").on("click", function(){

			var loadTestUser = "";

			if($(this).attr("load-user")=="true")
				loadTestUser = $("#appcontext").val()+"admin/search.jsp?___fid=<%=formid%>";
			else
				loadTestUser = $("#appcontext").val()+"admin/search.jsp?___fid=<%=formid%>&lsu=1";

			window.location.href = loadTestUser;

		});

		$(".view_form").on("click", function(){

		    jQuery.ajax({

		        url : '<%=request.getContextPath()%>/editForms.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: { 
		        	"form_id": '<%=formid%>',
		        	"tid": jQuery(this).attr("pk-id"),
		        	"rule_id": jQuery(this).attr("rule-id"),
		        	"post_work_id": jQuery(this).attr("pw-id")
		        },
		        success : function(response)
		        {
		        	jQuery("#view_form_content").html("");
		        	jQuery("#view_form_content").html(response);

		        }
		    });
		});

		$(".add_user_by_admin").on("click", function(){

		    jQuery.ajax({

		        url : '<%=request.getContextPath()%>/admin/addUser.jsp',
		        type: 'POST',
		        dataType: 'HTML',
		        data: { 
		        	"id": '<%=formid%>',
		        	"lang": '<%=lang%>'
		        },
		        success : function(response)
		        {
		        	jQuery("#add_user_content").html("");
		        	jQuery("#add_user_content").html(response);
		        }
		    });
		});

		onSearch=function()
		{
			$("#searchfrm").submit();
		};

		openForEdit=function(id, rid)
		{
			win = window.open("<%=request.getContextPath()%>/editForms.jsp?tid="+id+"&rule_id="+rid+"&form_id=<%=formid%>", "<%=formid%>");
			win.focus();
		};
		
		importCsv=function()
		{

		}
		
		exportCsv=function()
		{
			if(confirm("This will export the current criteria data. If you want to change export criteria, click search first and then export"))
			{
				var sids = [];
				$(".slt_option:checked").each(function(){
					sids.push($(this).val());
				});

				$("#selectedids").val(sids);
				$("#expFrm").submit();
			}
		}

		resetPassword = function(lsu,isEmail)
		{
			let flag=true;
			if(!isEmail){
				if(document.getElementById('newPassword').value == ''){ 
					alert('Enter password');
		        	flag = false;
				}
			}
			if(flag){
				$("#validation-message").removeClass("text-danger");
				$("#validation-message").text("");
				jQuery.ajax({
					url: '<%=request.getContextPath()%>/admin/ajax/resetClientPassword.jsp',
					data: { uuid : usr.uuid ,site_id: '<%=siteId%>' , login: usr.login, email: usr.email, password : document.getElementById('newPassword').value, lsu : lsu, isEmail: isEmail },
					type: 'POST',
					dataType: 'json',
					success : function(json) {
						if(json.STATUS == "ERROR")
						{
							bootNotifyError(json.msg);
						}
						else if(json.STATUS == "INVALID"){
							$("#validation-message").addClass("text-danger");
							$("#validation-message").text(json.msg);
							//	alert("Password must be at least 12 characters long with one uppercase letter, one lowercase letter, one number and one special character. Special characters allowed are !@#$%^&*");
						}
						else
						{
							bootNotify(json.msg,"success");
							$("#reset_password").modal('hide');
						}
					}
				});
			}
		}

		$('#reset_password').on('hidden.bs.modal', function (e) {
			$("#newPassword").val("");
			usr={};
			// do something...
		})

		deleteReply=function(id,uuid,tablename,portaldb)
		{	
			bootConfirm("Are you sure to delete the user?",function(result)	
			{
				if(result) 
				{
					$.ajax({
						url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
						method : 'post',
						dataType : 'json',
						data : {
							action: 'delete_reply',
							id: id,
							portaldb: portaldb,
							site_id: '<%=siteId%>',
							uuid: uuid,
							formid: '<%=formid%>'
						},
						success : function(json)
						{
							if(json.resp == 'success')
							{
								window.location.href = window.location.href + "&___rngf_created_on="+$("#___rngf_created_on_2").val()+"&___rngt_created_on="+$("#___rngt_created_on_2").val();
							}
						},
					});
				}		
			});
		}

		downloadTemplate=function(){

			$("#exportUserDatatemplte").submit();
		}

		updateUserStatus=function(username, isUserActive, portaldb){

			if(!confirm("Are you sure to lock the user?")) return;

			$.ajax({
				url : '<%=request.getContextPath()%>/admin/ajax/backendAjaxEditForm.jsp',
				method : 'post',
				dataType : 'json',
				data : {
					"action": 'update_user_status',
					"username": username,
					"is_user_active": isUserActive,
					"portaldb": portaldb
				},
				success : function(json)
				{
					if(json.resp == 'success')
					{
						window.location.href = window.location.href;
					}
				},
			});
		}
		
		$('#resultsdata .reset-password-btn').on('click',function(e){

			usr.login = e.target.dataset.login;
			usr.uuid = e.target.dataset.uuid;
			usr.email = e.target.dataset.email;

			$("#reset_password").modal("show");
			$("#send_email").one('click',function(e){ resetPassword(<%= lsu.equals("1") %>,<%= true %>)});
		})

		hideModal=function(v){

			$("#view_form").modal("toggle");
			$("#add_user_by_admin").modal("toggle");
			
			$("#hide_modal").val(v)
		}

		replyBack = function(){

			$("#reply_back_frm").submit();
		}

		selectDeleteReply = function(checkbox){

			if($(checkbox).is(":checked")){

				$(checkbox).next().val($(checkbox).val());
	
			} else {

				$(checkbox).next().val("");
			}

		}

		onAddDemand=function()
		{
			alert("onAddDemand")
			win = window.open("<%=request.getContextPath()%>/forms.jsp?form_id=<%=formid%>", "_blank");
			win.focus();
		};

		enableInlineEdit=function(id)
		{
			$("div[id^=span_" + id + "_]").hide();
			$("#edit_btn_" + id).hide();

			$("div[id^=inlinefrm_" + id).show();
			$("#sbmt_btn_" + id).show();
		};

		cancelUpdate=function(id)
		{
			$("#inlinefrm_" + id).hide();
			$("#no_inline_edit_" + id).show();
		};

		updateRow=function(id)
		{
			var allok = true;
			$("." + id + "_required").each(function(){
				if($.trim($(this).val()) == '') allok = false;
			});
			if(!allok)
			{
				alert("Some of required fields are missing");
				return false;
			}
			$.ajax({
				url : 'updateInline.jsp',
				method : 'post',
				dataType : 'json',
				data : $("#inlinefrm_" + id).serialize(),
				success : function(json)
				{
					if(json.resp == 'success')
					{
						$("."+id+"_fields").each(function(){
							$("#span_" + $(this).attr('id')).html($(this).val());
						});

						$("#inlinefrm_" + id).hide();
						$("#no_inline_edit_" + id).show();
					}
					else alert(json.msg);
				},
			});
		};

		pop_show_txt = function(objet, dialogId, title) {

		    if ($("#" + dialogId + "_dialog").dialog().dialog("isOpen") == true) {
		        $("#" + dialogId + "_dialog").dialog().dialog("close");
		    }

		    var obj = objet;
		    var x = $(obj).position().left + $(obj).outerWidth();
		    var y = $(obj).position().top - $(document).scrollTop(); // calcul de la

		    var html = "<textarea id='" + dialogId + "_updated' style='width: 100%; height: 95%;' >" + $("#"+dialogId).html() + "</textarea>";

		    $("#" + dialogId + "_dialog").dialog().dialog("option", "title", title);
		    var position = $(obj).position();
		    $("#" + dialogId + "_dialog").dialog().dialog('option', 'position', [ x, y ]);

		    $("#" + dialogId + "_dialog").html(html);

		    var createdDialog = $("#" + dialogId + "_dialog").dialog({
		        height : '180',
		        width : '180',
		        minWidth : 520,
		        resizable : true,
		        draggable : true,
		        modal : false,
		        close : function(ev, ui) {

	                $("#" + dialogId + "_dialog").dialog("close");
		        },
		        buttons : {
		            'Save' : function() {

		            	$("#"+dialogId).html($("#"+dialogId+"_updated").val());
		            	$(obj).val($("#"+dialogId+"_updated").val());

		                $("#" + dialogId + "_dialog").dialog("close");
		            }
		        }
		    });

		    createdDialog.dialog("open");
		}
	
		goback = function(){

			window.location = "process.jsp";
		}

		onviewflow = function(clientKey, tableName) {

			jQuery.ajax({
				url: 'orderFlow.jsp',
				type: 'POST',
				data: {client_key : clientKey, table_name: tableName, fromDialog: true},
				success: function(resp) {
					resp = jQuery.trim(resp);
					jQuery("#dialogWindow").html(resp);

					var opt = {
					        autoOpen: false,
					        width: 550,
					        height:450,
					        title: 'Details'
					};

					jQuery("#dialogWindow").dialog(opt).dialog("open");

				}
			});

		}

		onChangePhaseBtn = function(tableId, process, currentPhase, nextProcess, nextPhase, fromDialog, post_work_id) {

			if(!confirm("Are you sure to change the phase?")) return;
			jQuery.ajax({
				url : 'showChangePhase.jsp',
				type: 'POST',
				data: {post_work_id:post_work_id, tid: tableId, process: process, currentPhase: currentPhase, nextProcess: nextProcess, nextPhase:nextPhase, fromDialog:fromDialog, isFromEditScreen: '1'},
				success : function(resp)
				{
					jQuery("#dialogWindow").html(resp);
					if(resp.indexOf("changePhaseErrMsg") > -1) //this will be only in case there were multiple errcodes so we show them in dialog window
					{
						jQuery("#dialogWindow").dialog('option','title','Change Phase');
						jQuery("#dialogWindow").dialog('option','height','auto');
						jQuery("#dialogWindow").dialog('option','width','500px');
						jQuery("#dialogWindow").dialog('open');
					}
				}
			});
		}

		onOkChangePhase = function(tableId, process, currentPhase, nextProcess, nextPhase, fromDialog,post_work_id, _errCode) {

			var errCode = "";
			if(_errCode)//means automatically calling this in case where there is only 1 err code
			{
				errCode = _errCode;
			}
			else
			{
				document.getElementById('changePhaseErrMsg').innerHTML = "";
				var anySelected = false;

				for(var i=0; i<document.getElementsByName("changePhaseErrCode").length; i++)
				{
					if(document.getElementsByName("changePhaseErrCode")[i].checked)
					{
						anySelected = true;
						errCode = document.getElementsByName("changePhaseErrCode")[i].value;
						break;
					}
				}
				if(!anySelected)
				{
					document.getElementById('changePhaseErrMsg').innerHTML = "Seleccionar un c&oacute;digo de error";
					return;
				}
			}

            if(tableId=="") window.location='changeOrderPhase.jsp?post_work_id='+post_work_id+'&tid='+tableId+'&oldPhase='+currentPhase+'&process='+process+'&nextProcess='+nextProcess+'&nextPhase='+nextPhase+'&errCode='+errCode+'&fromDialog='+fromDialog+'&isFromEditScreen=1';
            else{
                jQuery.ajax({
                    url : 'changeOrderPhase.jsp?post_work_id='+post_work_id+'&tid='+tableId+'&oldPhase='+currentPhase+'&process='+process+'&nextProcess='+nextProcess+'&nextPhase='+nextPhase+'&errCode='+errCode+'&fromDialog='+fromDialog,
                    type: 'POST',
                    dataType: 'json',
                    success : function(data)
                    {
						if(data.response=="success")
						{
                            alert("Success");
							window.location.reload(true);
                        }
                        else{
                            alert(data.errorMsg);
                        }
                    }
                });
            }
		}

		$("#sltall").click(function()
		{
			if($(this).is(":checked"))
			{
				$(".slt_option").each(function(){
					$(this).prop("checked",true)
					$(this).next().val($(this).val());
				});
			}
			else
			{
				$(".slt_option").each(function(){
					$(this).prop("checked",false)
					$(this).next().val("");
				});
			}
		});

		$(".slt_option").click(function()
		{
			$("#sltall").prop("checked",false);
		});
	});

</script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/triggers.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/bootbox.min.js"></script>



</body>
</html>