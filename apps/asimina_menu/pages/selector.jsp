<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape"%>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ include file="common.jsp"%>
<%
	String url = request.getParameter("url");
	if(url == null) url = "";
	url = url.trim();
%>
<html>
<head>
	<title>Portal</title>
	<%@ include file="/WEB-INF/include/head2.jsp"%>
	<link type="text/css" rel="stylesheet" href="../css/portal.css" />

</head>
<body>
	<div>
	<center>
		<table cellpadding=0 cellspacing=0 border=0>
			<tr>
				<td>Load URL</td>
				<td>&nbsp;:&nbsp;</td>
				<td><input type='text' id='url' value='<%=escapeCoteValue(url)%>' maxlength='255' size='70' /></td>
			</tr>
			<tr>
				<td colspan="3" align=center><input type='button' value='Go' id='gobtn' /></td>
			</tr>
		</table>
		<p>
			<b>Instructions:</b> After the page is loaded, right click on the sections which you want to be replaced by top menu.
		</p>
	<center>
	</div>
</body>
<script>
	jQuery(document).ready(function() {
		$("#gobtn").click(function(){
			if(!isValidUrl($("#url").val()))
			{
				alert("Provide valid URL starting with http/https");
				return;
			}
			window.location = "sectionselector.jsp?url=" + $("#url").val();
		});

		isValidUrl=function(url)
		{
			if($.trim(url).toLowerCase().indexOf("https:") != 0 && $.trim(url).toLowerCase().indexOf("http:") != 0)
				return false;
			return true;
		};
	});
</script>
</html>
