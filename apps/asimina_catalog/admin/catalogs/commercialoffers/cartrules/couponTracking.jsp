<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map,com.etn.asimina.util.ActivityLog, java.util.Date, java.text.SimpleDateFormat, com.etn.beans.app.GlobalParm"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>

<%@ include file="/admin/common.jsp"%>

<%
	String cpid = parseNull(request.getParameter("cpid"));
	String selectedsiteid = parseNull(getSelectedSiteId(session));

	Set rsCartRule = Etn.execute("SELECT cp.name, cp.description  FROM cart_promotion cp  WHERE cp.id= "+escape.cote(cpid)+" and cp.site_id = "+escape.cote(selectedsiteid));
	if(rsCartRule.rs.Rows == 0)
	{
		response.sendRedirect("promotions.jsp?msg=Invalid id");
		return;
	}
	rsCartRule.next();

	Set prodrs = Etn.execute("SELECT cp.name, cp.description  FROM "+com.etn.beans.app.GlobalParm.getParm("PROD_DB")+".cart_promotion cp WHERE cp.id= "+escape.cote(cpid)+" and cp.site_id = "+escape.cote(selectedsiteid));
	boolean isPublished = false;
	if(prodrs.rs.Rows > 0) isPublished = true;

	String catalogDb = "";
	String shopDb = com.etn.beans.app.GlobalParm.getParm("SHOP_DB") + ".";
	if(isPublished)
	{
		catalogDb = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
		shopDb = com.etn.beans.app.GlobalParm.getParm("SHOP_PROD_DB") + ".";
	}
	Set rs = Etn.execute("SELECT cpc.* FROM "+catalogDb+"cart_promotion_coupon cpc WHERE cpc.cp_id = "+escape.cote(cpid)+" ORDER BY cpc.id ");

%>

<!DOCTYPE html>

<html>
<head>
    <title>Coupon tracking</title>

    <%@ include file="/WEB-INF/include/headsidebar.jsp"%>


</head>
<body class="c-app" style="background-color:#efefef">
<%@ include file="/WEB-INF/include/sidebar.jsp" %>
<div class="c-wrapper c-fixed-components">
    <%@ include file="/WEB-INF/include/header.jsp" %>
    <div class="c-body">
        <main class="c-main"  style="padding:0px 30px">
    <!-- breadcrumb -->
    <%-- <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<%=request.getContextPath()%>/admin/gestion.jsp">Home</a></li>
            <li class="breadcrumb-item">Commerial rules</li>
            <li class="breadcrumb-item active" aria-current="page">Coupon tracking</li>
        </ol>
    </nav> --%>
    <!-- /breadcrumb -->
    <!-- title -->
    <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
        <div>
            <h1 class="h2"><%if(!isPublished) {out.write("Preprod");} %> Coupon tracking : <%=rsCartRule.value("name")%></h1>
            <p class="lead"></p>
        </div>

        <!-- buttons bar -->
        <div class="btn-toolbar mb-2 mb-md-0">
            <div class="btn-group mr-2" role="group" aria-label="...">
                <a href="promotions.jsp" class="btn btn-primary" >Back</a>
            </div>
        </div>
        <!-- /buttons bar -->
    </div><!-- /d-flex -->
    <!-- /title -->

    <!-- container -->
    <div class="animated fadeIn">
    <div>
    <form name='frm' id='frm' method='post' action='promotions.js' >

        <!-- Coupon tracking -->

        <div id="coupon_tracking">
            <table class="table table-hover table-bordered m-t-20" id="coupon_tracking_resultsdata">
                <thead class="thead-dark">
                    <th style='text-align: center'><input type='checkbox' id='sltall' value='1' /></th>
                    <th style="text-align: left;vertical-align: top;">Coupon code</th>
                    <th style="text-align: left;">Used</th>
                    <th style="text-align: center;">Last date of use</th>
                    <th style="text-align: left;">Nb of use</th>
                    <th style="text-align: left;">Actions</th>
                </thead>
                <tbody>
					<% if(rs.rs.Rows == 0) { out.write("<tr><td colspan='6'>No coupon(s) found</td></tr>"); }
					else {
					while(rs.next()) {
						Set rsOrders = Etn.execute("select date_format(tm, '%d/%m/%Y') as dtm from "+shopDb+"orders where promo_code = "+escape.cote(parseNull(rs.value("coupon_code")))+ " order by tm desc ");
						String lastDateOfUse = "";
						if(rsOrders.next())
						{
							lastDateOfUse = rsOrders.value("dtm");
						}
						String strUsed = "No";
						if(rsOrders.rs.Rows > 0) strUsed = "Yes";
					%>
                    <tr>
                        <td></td>
                        <td><%=parseNull(rs.value("coupon_code"))%></td>
                        <td><%=strUsed%></td>
                        <td><%=lastDateOfUse%></td>
                        <td><%=rsOrders.rs.Rows%></td>
                        <td></td>
                    </tr>
					<% }
					}					%>
                </tbody>
            </table>

        </div>
        <!-- /Coupon tracking -->


    </form>
    </div>
    <div class="row justify-content-end m-t-10"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
    </div>
    <br>

</main>


<%@ include file="../../../prodpublishloginmultiselect.jsp"%>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div>

</body>
</html>
