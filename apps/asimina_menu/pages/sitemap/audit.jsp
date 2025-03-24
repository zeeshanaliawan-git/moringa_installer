<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("utf-8");
response.setCharacterEncoding("utf-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate"%>
<%@ page import="com.etn.sql.escape"%>
<%@ page import="com.etn.beans.Contexte, java.util.LinkedHashMap"%>
<%@include file="../common.jsp"%>
<%@include file="urlcommons.jsp"%>

<%
	String isprod = parseNull(request.getParameter("isprod"));
	String orderby = parseNull(request.getParameter("orderby"));
	if(orderby.length() == 0) orderby = "cdd";

	String dtf = parseNull(request.getParameter("dtf"));
	String dtt = parseNull(request.getParameter("dtt"));
	String user = parseNull(request.getParameter("user"));
	String resp = parseNull(request.getParameter("resp"));

	String titlePrefix = "Test Site";
	String dbname = "";
	if("1".equals(isprod)) 
	{
		titlePrefix = "Prod Site";
		dbname = com.etn.beans.app.GlobalParm.getParm("PROD_DB") + ".";
	}


	int p = parseNullInt(request.getParameter("p"));
	int nbLignes = 30;

	boolean anySearchCriteriaGiven = false;
	String qry = "select s.*, l.name as pname from "+dbname+"sitemap_audit s left outer join "+dbname+"login l on l.pid = s.created_by where 1=1 ";

	if(user.length() > 0)
	{
		anySearchCriteriaGiven = true;
		qry += " and l.name like " + escape.cote(user+ "%");
	}
	if(resp.length() > 0)
	{
		anySearchCriteriaGiven = true;
		qry += " and s.success = " + escape.cote(resp);
	}
	if (dtf.length() > 0 && dtt.length() > 0)
	{
		try
		{
              	long l1 = ItsDate.getDate(dtf);
              	long l2 = ItsDate.getDate(dtt);
              	String z1 = null, z2 = null;
              	if (l1 > l2)
              	{
              		z1 = ItsDate.stamp(l2);
              		z1 = z1.substring(0,8);
              		z2 = ItsDate.stamp(l1);
              		z2 = z2.substring(0,8);
              	}
              	else
              	{
              		z1 = ItsDate.stamp(l1);
              		z1 = z1.substring(0,8);
              		z2 = ItsDate.stamp(l2);
              		z2 = z2.substring(0,8);
              	}
              	qry += " and s.created_on between " + z1 + " and " + z2;
              	anySearchCriteriaGiven = true;
		}
		catch (Exception e)
		{
			out.write("<b><font color='red'>Wrong format of date</font color></b>");
		}
	}
	else if (dtf.length() > 0 && dtt.length() <= 0)
	{
		long l1 = ItsDate.getDate(dtf);
		String z1 = ItsDate.stamp(l1);
		z1 = z1.substring(0,8);
		qry += " and s.created_on >= " + z1;
		anySearchCriteriaGiven = true;
	}
	else if (dtf.length() <= 0 && dtt.length() > 0)
	{
		long l2 = ItsDate.getDate(dtt);
		String z2 = ItsDate.stamp(l2);
		z2 = z2.substring(0,8);
		qry += " and s.created_on <= " + z2;
	}

/*	if(!anySearchCriteriaGiven)
	{
		qry += " and s.created_on between date_add(now(), interval -30 day) and now() ";
	}*/

	if("cdd".equals(orderby)) qry += " order by created_on desc ";
	else if("cda".equals(orderby)) qry += " order by created_on asc ";

	qry += " limit " + p + ", " + nbLignes;

	Set rs = Etn.executeWithCount(qry);
	int nbRes = Etn.UpdateCount;
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
	<title>Sitemap Audit</title>
	<%@ include file="/WEB-INF/include/headsidebar.jsp"%>
<%	
breadcrumbs.add(new String[]{titlePrefix, ""});
breadcrumbs.add(new String[]{"Sitemap Audit", ""});
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
				<h1 class="h2">Sitemap Audit</h1>
				<p class="lead"></p>
			</div>

			<button type="button" class="btn btn-secondary ml-2 d-flex justify-content-center align-items-center" onclick="addToShortcut('Sitemap Audit');" title="Add to shortcuts">
				<i class="feather m-0 w-100" style='stroke:<%=(isMarkedForShortcut)?"yellow;":"#636f83;"%>' id='shortcutStar' data-feather="star"></i>
			</button>

	</div>
	<!-- /title -->

<!-- container -->
	<div class="animated fadeIn">
		<div>
	          	<form action='audit.jsp' method='post' name='frm1'>
			<input type='hidden' name='isprod' value='<%=escapeCoteValue(isprod)%>' >
			<div class="row form-horizontal">
		              <div class="col-12 form-group">
		       	       <label class="col-sm-2" style="font-weight: normal;">Date From <input type='text' id='dtf' name='dtf' value='<%=escapeCoteValue(dtf)%>' size='6' maxlengh='10' class="form-control"></label>
       		       	<label class="col-sm-2" style="font-weight: normal;">Date To <input type='text' id='dtt' name='dtt' value='<%=escapeCoteValue(dtt)%>' size='6' maxlengh='10' class="form-control"></label>
	       		       <label class="col-sm-2" style="font-weight: normal;">User <input type='text' id='user' name='user' value='<%=escapeCoteValue(user)%>' size='8' maxlengh='75' class="form-control"></label>
	       		       <label class="col-sm-2" style="font-weight: normal;">Response <select id='resp' name='resp' class="form-control">
	       	       	      <option value=''>All</option>
		       	             <option <%if("0".equals(resp)){%>selected<%}%> value='0'>Error</option>
       		       	      <option <%if("1".equals(resp)){%>selected<%}%> value='1'>Success</option>
	              		    </select>
					</label>
			              <label class="btn-group">
       			         <button type="button" class="btn btn-success" onclick='javascript:document.forms[0].submit()'>Search</button>
              			  <button type="button" class="btn btn-light" onclick='clearform()'>Reset</button>
		       	       </label>
	       	       </div>
			</div>
		</form>
		</div>

		<div>
		<table class="table table-hover table-striped table-vam m-t-20" id="results">
			<thead class="thead-dark">
				<th>
					<%if("cdd".equals(orderby)) {%>
						<a href='javascript:repost("cda")' style='border:0; text-decoration:none;color:white;'>Date&nbsp;<span class="glyphicon glyphicon-chevron-down"></span></a><!-- <img src='../../img/arrowDown.png'> -->
					<%} else if("cda".equals(orderby)) {%>
						<a href='javascript:repost("cdd")' style='border:0; text-decoration:none;color:white'>Date&nbsp;<span class="glyphicon glyphicon-chevron-up"></span></a><!-- <img src='../../img/arrowUp.png'> -->
					<%}%>
				</th>
				<th>User</th>
				<th>Response</th>
				<th>Action</th>
			</thead>
		<% while(rs.next())
		{
			String success = "Success";
			if(parseNull(rs.value("success")).equals("0")) success = "Error";
		%>
			<tr>
				<td><%=escapeCoteValue(parseNull(rs.value("created_on")))%></td>
				<td><%=escapeCoteValue(parseNull(rs.value("pname")))%></td>
				<td><%=escapeCoteValue(parseNull(success))%></td>
				<td><%=(parseNull(rs.value("action")))%></td>
			</tr>
		<%}%>
		</table>
		</div>

		<div style='clear:both; margin-top:8px;'>
			<center>
			<%
                    	if (p > 0) out.write("<a class='number' href='javascript:goto(\""+(p - nbLignes)+"\")'>&#9668; Previous</a>&nbsp;&nbsp;&nbsp;");
			int upperlimit = (nbRes / nbLignes);
			if(nbRes % nbLignes != 0) upperlimit ++;
                                    for (int i = 1; i <= upperlimit; i++) {
                                            if (i == 1 && (p / nbLignes) > 3) {
                                                out.write("<a class='number' href='javascript:goto(\""+(0)+"\")'>"
                                                            + i
                                                            + "</a>" + "&nbsp;&nbsp;&nbsp;&nbsp;");
                                            }
                                                if (((i > (p / nbLignes) - 3) && (i < (p / nbLignes) + 5))) {
                                                        if (p == 0 && i == 0) {
                                                                out.write("<b>");
                                                        } else if ((i - 1) == p / nbLignes) {
                                                                out.write("&nbsp;<b id=\"numsel\">");
                                                        }
                                                        out.write("<a class='number' href='javascript:goto(\""+(((i - 1) * nbLignes))+"\")'>"
                                                                                        + i
                                                                                        + "</a>");
                                                        if (p == 0 && i == 0) {
                                                                out.write("</b>");
                                                        } else if ((i - 1) == p / nbLignes) {
                                                                out.write("</b>");
                                                        }
								out.write("&nbsp;");

                                                }
                                                if (i == (nbRes / nbLignes)
                                                                && ((p / nbLignes) < (nbRes / nbLignes - 3))) {
                                                        out.write("&nbsp;&nbsp;&nbsp;&nbsp;<a class='navigation' href='javascript:goto(\""+((((nbRes/nbLignes))* nbLignes))+"\")'>"
                                                                                        + ((nbRes/nbLignes)+1)+"</a>");
                                                }

                                        }
                                        if (p < (nbRes - nbLignes))
                                                out.write("&nbsp;&nbsp;&nbsp;<a class='number' href='javascript:goto(\""+((p + nbLignes))+"\")'>Next &#9658;</a>");

                                        switch (nbRes) {
                                        case 0: out.write("<br/><br/><span style='color: #FF6600'>No records found</span>");
                                                        break;
                                        case 1: out.write("<br/><br/><span style='color: #FF6600'>1 record found</span>");
                                                        break;
                                        default: out.write("<br/><br/><span style='color: #FF6600'>" + nbRes + " records found</span>");
                                        }
       	       %>
	            	</center>
		</div>

		<div style='display:none'>
		<form id='gotoform' method='post' action='audit.jsp'>
			<input type='hidden' name='isprod' value='<%=escapeCoteValue(isprod)%>' />
			<input type='hidden' name='orderby' id="__orderby" value='<%=escapeCoteValue(orderby)%>' />
			<input type='hidden' name="dtf" value='<%=escapeCoteValue(dtf)%>' />
			<input type='hidden' name="dtt" value='<%=escapeCoteValue(dtt)%>' />
			<input type='hidden' name="user" value='<%=escapeCoteValue(user)%>' />
			<input type='hidden' name="resp" value='<%=escapeCoteValue(resp)%>' />
			<input type='hidden' name='p' id='__p' value='<%=p%>' />

		</form>
		</div>

		<br>
		<div class="row justify-content-end"><a href="#"  class="arrondi htpage">^ Top of screen ^</a></div>
</div>

<!-- /container -->
</main>
<%@ include file="/WEB-INF/include/footer.jsp" %>
</div><!-- /app-body -->
<script>
jQuery(document).ready(function()
{
	$( "#dtf" ).flatpickr({dateFormat: "d/m/Y"});
       $( "#dtt" ).flatpickr({dateFormat: "d/m/Y"});

	clearform=function()
	{
		$("#dtf").val('');
		$("#dtt").val('');
		$("#user").val('');
		$("#resp").val('');
	};

	goto=function(p)
	{
		$("#__p").val(p);
		$("#gotoform").submit();
	};

	repost=function(orderby)
	{
		$("#__orderby").val(orderby);
		$("#gotoform").submit();
	};

});
</script>

</body>
</html>