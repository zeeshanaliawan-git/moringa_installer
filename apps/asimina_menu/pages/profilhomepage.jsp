<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.asimina.util.ActivityLog"%>
<%@ page import="java.io.UnsupportedEncodingException"%>
<%@ page import="java.security.MessageDigest"%>
<%@ page import="java.security.NoSuchAlgorithmException"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="common.jsp"%>


<%
	String siteid = parseNull(getSiteId(request.getSession()));

	String isprod = parseNull(request.getParameter("isprod"));
	String dbname = "";
	if("1".equals(isprod)) dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";//"prod_portal.";

	   String[] ids = request.getParameterValues("id");
       String[] profils = request.getParameterValues("profil");
       String[] menuids = request.getParameterValues("menu_id");
       String[] homepage = request.getParameterValues("homepage");

   if(profils!=null)
	{
       	Etn.executeCmd("delete from " +dbname+ "client_profils where site_id = " + escape.cote(siteid));
        String  _ids = "";
        String  names = "";
		for(int i=0; i<profils.length;i++)
		{
          	if(!profils[i].equals(""))
			{
				Etn.executeCmd("insert into " +dbname+ "client_profils set site_id = "+escape.cote(siteid)+", menu_id = "+escape.cote(menuids[i])+", id="+escape.cote(ids[i])+", profil="+escape.cote(profils[i])+", homepage="+escape.cote(homepage[i]));
                if(_ids.length()>0) _ids += ",";
                if(names.length()>0) names += ", ";
                _ids += ids[i];
                names += profils[i];
			}
		}
        ActivityLog.addLog(Etn,request,parseNull(session.getAttribute("LOGIN")),_ids,"UPDATED","Client Profils",names,siteid);
	}


   Set rsProfils = Etn.execute("select * from " +dbname+ "client_profils where site_id = "+escape.cote(siteid));

	Set rsMenus = Etn.execute("select m.id, m.name, s.id as siteid, s.name as sname from "+dbname+"site_menus m, "+dbname+"sites s where s.id = "+escape.cote(siteid)+" and s.id = m.site_id order by s.name, m.name");



%>

<html>
<head>
	<title>Client Profils</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{"System", ""});
breadcrumbs.add(new String[]{"Prod Site", ""});
breadcrumbs.add(new String[]{"Client Profils", ""});
%>

</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
	<!-- title -->
	<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
			<div style="width: 100%;">
				<h1 class="h2 float-left">Client Profils</h1>
				<p class="lead"></p>
				<button class="btn btn-success float-right" onclick="$('#frm').submit()">Save</button>
			</div>
			<button type="button" class="btn btn-secondary ml-2 mt-3 d-flex justify-content-center align-items-center" onclick="addToShortcut('Client Profils');" title="Add to shortcuts">
				<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
			</button>
	</div>
	<!-- /title -->
		<!-- container -->
	<div class="animated fadeIn">
	<form name='frm' id='frm' action='<%=("1".equals(isprod)?"prodprofilhomepage.jsp":"profilhomepage.jsp")%>' method='post'>
		<table id="mainTable" cellpadding=0 cellspacing=0 border=0 width='50%' class="table table table-hover table-vam m-t-20">
			<thead class="thead-dark">
					<tr>
							<th>Profil</th>
							<th>Menu</th>
							<th>Home Page</th>
						</tr>
			</thead>
                    <%
                    while(rsProfils.next()){
                    %>
			<tr>
				<td>
                                    <input type='hidden' name='id' value="<%=rsProfils.value("id")%>"/>
                                    <input type='text' size='50' name='profil' value="<%=rsProfils.value("profil")%>" class="form-control"/></td>
				<td>
					<select name='menu_id' class='menu_ids form-control'>
					<%
					rsMenus.moveFirst();
					while(rsMenus.next()) {
						String selected = "";
						if(parseNull(rsProfils.value("menu_id")).equals(rsMenus.value("id"))) selected = "selected";
						out.write("<option "+selected+" value='"+rsMenus.value("id")+"'>"+escapeCoteValue(rsMenus.value("sname") + " - " + rsMenus.value("name"))+"</option>");
					} %>
					</select>
				</td>

				<td><input type='text' size='500' name='homepage' value="<%=rsProfils.value("homepage")%>" class="form-control"/></td>
			</tr>
                    <%}%>
			<tr>
				<td style="width:15%">
                                    <input type='hidden' name='id'/>
                                    <input type='text' size='50' name='profil' class="form-control"/>
				</td>
				<td style="width:25%">
					<select name='menu_id' class='menu_ids form-control'>
					<option value=''>-- Menu --</option>
					<%
					rsMenus.moveFirst();
					while(rsMenus.next()) {
						out.write("<option value='"+rsMenus.value("id")+"'>"+escapeCoteValue(rsMenus.value("sname") + " - " + rsMenus.value("name"))+"</option>");
					} %>
					</select>
				</td>

				<td><input type='text' size='500' name='homepage' class="form-control" /></td>
			</tr>
		</table>
	</form>
	</div>
            <button class="btn btn-primary btn-lg" style="border-radius: 50%;margin: 0 auto;display: block;font-size: 20px;" onclick="addRow()">+</button>
	<!-- /container -->
</main>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- /app-body -->
<script>
function addRow()
{
	var h = '<tr>';
	h += '<td style="width:15%">';
	h += '<input type="hidden" name="id"/>';
	h += '<input type="text" size="50" name="profil" class="form-control"/>';
	h += '</td>';
	h += '<td style="width:25%">';
	h += '<select name="menu_id" class="menu_ids form-control">';
	h += '<option value="">-- Menu --</option>';
	<%
	rsMenus.moveFirst();
	while(rsMenus.next()) { %>
		h += '<option value="<%=rsMenus.value("id")%>"><%=escapeCoteValue(rsMenus.value("sname") + " - " + rsMenus.value("name"))%></option>';
	<% } %>
	h += '</select>';
	h += '</td>';
	h += '<td><input type="text" size="500" name="homepage" class="form-control" /></td>';
	h += '</tr>';

	$("#mainTable").append(h);
}
</script>
</html>