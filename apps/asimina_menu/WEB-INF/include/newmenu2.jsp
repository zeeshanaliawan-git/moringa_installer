<%
	String version = com.etn.beans.app.GlobalParm.getParm("APP_VERSION");
	if(version == null) version = "";
	else version = "v" + version;
%>

<%
	Set ____rsp = Etn.execute("select case coalesce(p2.parent,'') when '' then p2.name else p2.parent end as _parent, " +
				" case coalesce(p2.parent,'') when '' then 0 else 1 end as _isparent, min(p2.rang) as rang " +
				" from page p, page p2 where p2.url = p.url group by _parent order by rang, _parent");

%>

<!-- Fixed navbar -->
<div id="main-menu">
<nav class="navbar navbar-dark bg-dark navbar-expand-md fixed-top">
	<div class="container">
			<a class="navbar-brand" href="<%=com.etn.beans.app.GlobalParm.getParm("GESTION_URL")%>">
				<img src="<%=request.getContextPath()%>/img/logo.png" alt="" style="height:20px;width:auto;vertical-align: bottom;">
				<span class="c-orange" style="font-size: 14pt;font-weight: normal;"> <%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%></span></a>
			<!-- <a class="navbar-brand" href="<//%=com.etn.beans.app.GlobalParm.getParm("ROOT_WEB")%>admin/gestion.jsp"><span class="c-orange" style="font-size: 14pt;font-weight: normal;"><//%=com.etn.beans.app.GlobalParm.getParm("APP_NAME")%></span></a> -->

		<div id="navbar" class="navbar-collapse justify-content-between collapse"">
			<ul class="navbar-nav">
<% while(____rsp.next()) {
		if("0".equals(____rsp.value("_isparent")))
		{
			String ____q = "select * from page p where p.name = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" and coalesce(p.parent) = '' ";
			if(!"admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")) && !"super_admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")))
			{
				____q = "select * from page p, page_profil pr where p.name = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" and coalesce(p.parent) = '' ";
				____q += " and pr.url = p.url " ;
				____q += " and pr.profil_id = " + com.etn.sql.escape.cote((String)session.getAttribute("PROFIL_ID"));
			}
			Set ____rs1 = Etn.execute(____q);
			if(____rs1.next())
			{
				String ____u = parseNull(____rs1.value("url"));
				String ____target = "";
				if("1".equals(____rs1.value("new_tab"))) ____target = " target='_blank' ";
%>
			<li class="nav-item"><a class="nav-link" href="<%=____u%>" <%=____target%>><%=____rs1.value("name")%></a></li>
<%
			}
		}
		else
		{
			String ____q = "select * from page p where p.parent = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" ";
			if(!"admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")) && !"super_admin".equalsIgnoreCase((String)session.getAttribute("PROFIL")))
			{
				____q = "select * from page p, page_profil pr where p.parent = "+com.etn.sql.escape.cote(____rsp.value("_parent"))+" ";
				____q += " and pr.url = p.url " ;
				____q += " and pr.profil_id = " + com.etn.sql.escape.cote((String)session.getAttribute("PROFIL_ID"));
			}
			____q += " order by rang, name ";
			Set ____rs1 = Etn.execute(____q);
			if(____rs1.rs.Rows == 0) continue;

%>
			<li class="dropdown">
			<a href="javascript:void(0)" class="dropdown-toggle nav-link" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><%=____rsp.value("_parent")%><span class="caret"></span></a>
			<div class="dropdown-menu">
			<% while(____rs1.next()) {
				String ____u = parseNull(____rs1.value("url"));
				String ____target = "";
				if("1".equals(____rs1.value("new_tab"))) ____target = " target='_blank' ";
			%>
				<a class="dropdown-item" href="<%=____u%>" <%=____target%>><%=____rs1.value("name")%></a>
			<% } %>
			</div>
			</li>

<%	  	}
} %>
		<li class="nav-item dropdown">
			<a href="javascript:void(0)" class="dropdown-toggle nav-link" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><span class="glyphicon glyphicon-user" aria-hidden="true" style="margin: 0px 10px 0px 0px; font-size:12px"></span><%=(String)session.getAttribute("LOGIN")%></a>
			<div class="dropdown-menu">
				<a class="dropdown-item" href="<%=request.getContextPath()+"/admin/changePassword.jsp"%>">Change Password</a>
			</div>
		</li>
		<li class="nav-item">
			<a class="nav-link" style='cursor:pointer;background:none;border:none;' onclick='javascript:window.location="<%=request.getContextPath()%>/pages/logout.jsp?t=<%=System.currentTimeMillis()%>";' title='Logout'><?xml version="1.0" ?><svg height="16px" version="1.1" viewBox="0 0 268 289" width="16px" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><title/><desc/><defs><path d="M173.333334,25.3802623 C223.825003,43.401838 260,92.0286182 260,149.18753 C260,221.689921 201.797017,280.464721 130,280.464721 C58.2029825,280.464721 0,221.689921 0,149.18753 C0,92.0286182 36.1749969,43.401838 86.666666,25.3802623 L86.6666667,63.414683 C55.7988043,79.3492113 34.6666667,111.776288 34.6666667,149.18753 C34.6666667,202.35595 77.3488539,245.45747 130,245.45747 C182.651146,245.45747 225.333333,202.35595 225.333333,149.18753 C225.333333,111.776288 204.201196,79.3492113 173.333343,63.414688 L173.333333,25.3802568 L173.333334,25.3802623 Z" id="path-1" /><path d="M123.006168,7.10542736e-15 L137.993832,7.10542736e-15 C143.520086,7.10542736e-15 148,4.48683719 148,10.0004348 L148,112.999565 C148,118.522653 143.531675,123 137.993832,123 L123.006168,123 C117.479914,123 113,118.513163 113,112.999565 L113,10.0004348 C113,4.47734715 117.468325,7.10542736e-15 123.006168,7.10542736e-15 Z" id="path-3" /></defs><g fill="none" fill-rule="evenodd" id="Page-1" stroke="none" stroke-width="1"><g id="on_off" transform="translate(4.000000, 0.000000)"><g id="Combined-Shape"><use fill="red" fill-opacity="1" filter="url(#filter-2)" xlink:href="#path-1" /><use fill="red" fill-rule="evenodd" xlink:href="#path-1" /></g><g id="Combined-Shape"><use fill="red" fill-opacity="1" filter="url(#filter-4)" xlink:href="#path-3" /><use fill="red" fill-rule="evenodd" xlink:href="#path-3" /></g></g></g></svg></a>
		</li>
		<li class="nav-item pull-right">
			<small class="nav-link text-muted"><%=version%></small>
		</li>
			</ul>

		</div><!--/.nav-collapse -->

	</div>
</nav>
</div>
<!-- Fixed navbar -->




