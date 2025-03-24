<%-- Reviewed By Awais --%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>

<%
	Set rs = Etn.execute("select *, date_format(priority, '%d/%m/%Y %H:%i:%s') _d from post_work where status = 0 and phase in ('publish', 'publish_ordering', 'delete') order by id ");
	Set rsmenus = Etn.execute("select *, date_format(priority, '%d/%m/%Y %H:%i:%s') _d from "+GlobalParm.getParm("PORTAL_DB")+".post_work where status = 0 and phase in ('publish',  'publish_ordering', 'delete') order by id ");
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
	<title>Pending Actions</title>

	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>

<%
breadcrumbs.add(new String[]{"Pending Actions", ""});
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
			<div>
				<h1 class="h2">Pending Actions</h1>
				<p class="lead"></p>
			</div>
			<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Pending Actions');" title="Add to shortcuts">
				<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
			</button>
		</div>
	<!-- /title -->

	
	<!-- container -->	
	<div class="animated fadeIn">
		<table cellpadding="10" cellspacing="0" border="0" class="table table-hover table-bordered results" >
			<thead>
				<th>Item</th>
				<th>Action</th>
				<th>On</th>
			</thead>
			
			<% while(rs.next()) {
				String item = "";
				if("products".equalsIgnoreCase(rs.value("proces"))) 
				{
					if("publish".equalsIgnoreCase(rs.value("phase"))  || "publish_ordering".equalsIgnoreCase(rs.value("phase")))
					{
						Set rs1 = Etn.execute("select * from products where id = " +  escape.cote(rs.value("client_key")));//change
						if(rs1.next())
						{
							item = "Product : <a target='_blank' style='color:black' href='catalogs/product.jsp?cid="+rs1.value("catalog_id")+"&id="+rs1.value("id")+"'>"+escapeCoteValue(parseNull(rs1.value("lang_1_name")))+"</a>";
						}
					}
					else if("delete".equalsIgnoreCase(rs.value("phase"))) 
					{
						Set rs1 = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".products where id = " + escape.cote(rs.value("client_key")));//change
						if(rs1.next())
						{
							item = "Product : <a target='_blank' style='color:black' href='catalogs/prodproduct.jsp?cid="+rs1.value("catalog_id")+"&id="+rs1.value("id")+"'>"+escapeCoteValue(parseNull(rs1.value("lang_1_name")))+"</a>";
						}
					}
				}
				else if("families".equalsIgnoreCase(rs.value("proces"))) 
				{
					if("publish".equalsIgnoreCase(rs.value("phase"))  || "publish_ordering".equalsIgnoreCase(rs.value("phase")))
					{
						Set rs1 = Etn.execute("select * from familie where id = " + escape.cote(rs.value("client_key")));//change
						if(rs1.next())
						{
							item = "Familie : <a target='_blank' style='color:black' href='catalogs/familie.jsp?id="+rs1.value("id")+"'>"+escapeCoteValue(rs1.value("name"))+"</a>";
						}
					}
					else if("delete".equalsIgnoreCase(rs.value("phase"))) 
					{
						Set rs1 = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".familie where id = " + escape.cote(rs.value("client_key")));//change
						if(rs1.next())
						{
							item = "Familie : <a target='_blank' style='color:black' href='catalogs/prodfamilie.jsp?id="+rs1.value("id")+"'>"+escapeCoteValue(rs1.value("name"))+"</a>";
						}
					}
				}
				else if("catalogs".equalsIgnoreCase(rs.value("proces"))) 
				{
					if("publish".equalsIgnoreCase(rs.value("phase"))  || "publish_ordering".equalsIgnoreCase(rs.value("phase")))
					{
						Set rs1 = Etn.execute("select * from catalogs where id = " + escape.cote(rs.value("client_key")));//change
						if(rs1.next())
						{
							item = "Catalog : <a target='_blank' style='color:black' href='catalogs/catalog.jsp?id="+rs1.value("id")+"'>"+escapeCoteValue(rs1.value("name"))+"</a>";
						}
					}
					else if("delete".equalsIgnoreCase(rs.value("phase"))) 
					{
						Set rs1 = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".catalogs where id = " + escape.cote(rs.value("client_key")));//change
						if(rs1.next())
						{
							item = "Catalog : <a target='_blank' style='color:black' href='catalogs/prodcatalog.jsp?id="+rs1.value("id")+"'>"+escapeCoteValue(rs1.value("name"))+"</a>";
						}
					}
				}
				else if("promotion".equalsIgnoreCase(rs.value("proces"))) 
				{
					//implement this
					/*if("publish".equalsIgnoreCase(rs.value("phase"))  || "publish_ordering".equalsIgnoreCase(rs.value("phase")))
					{
						Set rs1 = Etn.execute("select * from catalogs where id = " + rs.value("client_key"));
						if(rs1.next())
						{
							item = "Promotion : <a target='_blank' style='color:black' href='catalogs/catalog.jsp?id="+rs1.value("id")+"'>"+escapeCoteValue(rs1.value("name"))+"</a>";
						}
					}
					else if("delete".equalsIgnoreCase(rs.value("phase"))) 
					{
						Set rs1 = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".catalogs where id = " + rs.value("client_key"));
						if(rs1.next())
						{
							item = "Promotion : <a target='_blank' style='color:black' href='catalogs/prodcatalog.jsp?id="+rs1.value("id")+"'>"+escapeCoteValue(rs1.value("name"))+"</a>";
						}
					}*/
				}
				else if("translations".equalsIgnoreCase(rs.value("proces"))) 
				{
					item = "<a target='_blank' style='color:black' href='libmsgs.jsp'>Translations</a>";
				}
				String action = "";
				if("publish".equalsIgnoreCase(rs.value("phase"))) action= "Publish to prod";
				else if("publish_ordering".equalsIgnoreCase(rs.value("phase"))) action= "Publish ordering to prod";
				else if("delete".equalsIgnoreCase(rs.value("phase"))) action= "Delete from prod";
  			%>
				<tr>
					<td><%=item%></td>
					<td><%=escapeCoteValue(action)%></td>
					<td><%=escapeCoteValue(rs.value("_d"))%></td>
				</tr>
				<input type='hidden' value='<%=escapeCoteValue(rs.value("id"))%>' name='tarif_id' />
			<% }%>
			<% while(rsmenus.next()) {
				String item = "";
				if("menus".equalsIgnoreCase(rsmenus.value("proces"))) 
				{
					if("publish".equalsIgnoreCase(rsmenus.value("phase")))
					{
						Set rs1 = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PORTAL_DB")+".site_menus where id = " + escape.cote(rsmenus.value("client_key")));//change
						if(rs1.next())
						{
							item = "Menu : <a target='_blank' style='color:black' href='"+com.etn.beans.app.GlobalParm.getParm("MENU_DESIGNER_URL")+"pages/menudesigner.jsp?siteid="+rs1.value("site_id")+"&menuid="+rs1.value("id")+"'>"+escapeCoteValue(rs1.value("name"))+"</a>";
						}
					}
					else if("delete".equalsIgnoreCase(rsmenus.value("phase"))) 
					{
						Set rs1 = Etn.execute("select * from "+com.etn.beans.app.GlobalParm.getParm("PORTAL_PROD_DB")+".site_menus where id = " + escape.cote(rsmenus.value("client_key")));//change
						if(rs1.next())
						{
							item = "Menu : <a target='_blank' style='color:black' href='"+com.etn.beans.app.GlobalParm.getParm("MENU_DESIGNER_URL")+"pages/menudesigner.jsp?siteid="+rs1.value("site_id")+"&menuid="+rs1.value("id")+"'>"+escapeCoteValue(rs1.value("name"))+"</a>";
						}
					}
				}
				String action = "";
				if("publish".equalsIgnoreCase(rsmenus.value("phase"))) action= "Publish to prod";
				else if("delete".equalsIgnoreCase(rsmenus.value("phase"))) action= "Delete from prod";
				%>
				<tr>
					<td><%=item%></td>
					<td><%=escapeCoteValue(action)%></td>
					<td><%=escapeCoteValue(rsmenus.value("_d"))%></td>
				</tr>
				<input type='hidden' value='<%=escapeCoteValue(rsmenus.value("id"))%>' name='tarif_id' />
			<% }%>
		</table>
	</div>
	<!-- /container -->

</main>
</div><!-- /c-body -->
<%@ include file="/WEB-INF/include/footer.jsp" %>

</body>
</html>