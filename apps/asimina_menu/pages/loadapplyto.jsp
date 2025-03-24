<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape, com.etn.util.Base64, com.etn.beans.app.GlobalParm"%>

<%@ include file="common.jsp"%>

<%
	String menuid = parseNull(request.getParameter("menuid"));
	String siteid = parseNull(request.getParameter("siteid"));
System.out.println("--- mid : " + menuid);
System.out.println("--- sid : " + siteid);

	Set rs = Etn.execute("select * from menu_apply_to where menu_id = " + escape.cote(menuid) + " order by id ");
%>
<% if(rs.rs.Rows > 0) { %>
<div>
	<form name='rulesfrm' id='rulesfrm' method='post' action='updatemenurules.jsp' >
	<input type='hidden' value='<%=escapeCoteValue(siteid)%>' name='siteid' />
	<input type='hidden' value='<%=escapeCoteValue(menuid)%>' name='menuid' />

	<table class="table table-hover table-bordered m-t-20" style="width:100%">
		<thead class="thead-dark">
			<th width='8%' nowrap>Apply To</th>
			<th>URL/Path</th>
			<th>Prod URL/Path</th>
			<th>GTM</th>
			<th>Cache</th>
			<th width='35%'>Replace tags</th>
			<th width='2%'>&nbsp;</th>
		</thead>
		<% while(rs.next()) {
			
			//get cache value from prod
			String ruleCache = "1";//by default its always 1
			boolean enableCacheCol = true;
			Set rsP = Etn.execute("select * from "+GlobalParm.getParm("PROD_DB")+".menu_apply_to where id = " + escape.cote(rs.value("id")));
			if(rsP.next())
			{
				if(parseNull(rsP.value("apply_type")).equals("url_starting_with") && parseNull(rsP.value("apply_to")).equals("127.0.0.1")) enableCacheCol = false;
				ruleCache = parseNull(rsP.value("cache"));
			}
			else
			{
				if(parseNull(rs.value("apply_type")).equals("url_starting_with") && parseNull(rs.value("apply_to")).equals("127.0.0.1")) enableCacheCol = false;
				ruleCache = parseNull(rs.value("cache"));//if the menu is not published till yet we show the cache flag from preprod 
			}			
			
			%>
			<input type='hidden' value='<%=escapeCoteValue(rs.value("id"))%>' name='id' />
			<input type='hidden' value='<%=escapeCoteValue(parseNull(rs.value("add_gtm_script")))%>' name='add_gtm_script' id='<%=rs.value("id")%>_gtms'/>
			<tr>
				<td  nowrap><%=parseNull(rs.value("apply_type"))%></td>
				<td><input type='text' size='45' class="form-control" name='apply_to' value='<%=escapeCoteValue(parseNull(rs.value("apply_to")))%>' maxlength='255' /></td>
				<td><input type='text' size='45' class="form-control" name='prod_apply_to' value='<%=escapeCoteValue(parseNull(rs.value("prod_apply_to")))%>' maxlength='255' /></td>
				<td align='center'><input type='checkbox' onclick='setgtmval(this,"<%=rs.value("id")%>")' name='n_add_gtm_script' value='1' <%if("1".equals(rs.value("add_gtm_script"))){%>checked<%}%>/></td>
				<td>
				<% if(enableCacheCol){%>
				<select name="trusted_domain_cache" class="form-control" id='<%=rs.value("id")%>_tdomain_cache'>
					<option <%=ruleCache.equals("0")?"selected":""%> value="0">Off</option>
					<option <%=ruleCache.equals("1")?"selected":""%> value="1">On</option>
				</select>
				<%}else{%>
				<input type='hidden' value='<%=ruleCache%>' id='<%=rs.value("id")%>_tdomain_cache' name="trusted_domain_cache" >
				<div style="text-align:center;font-weight:bold"><%=ruleCache.equals("0")?"Off":"On"%></div>
				<%}%>
				</td>
				<td><%=parseNull(rs.value("replace_tags"))%></td>
				<td align='center'>
				<button type="button" class="btn btn-danger btn-sm"  onClick="javascript:deleteapplyto('<%=rs.value("id")%>')" title="Delete"><span class="oi oi-x"></span></button>
				</td>
			</tr>
		<% } %>
		<% if(rs.rs.Rows > 0) { %>
			<!-- <tr><td colspan='5' align='center'><input type='button' value='Save' onclick='updatemenurules()' /></td></tr> -->
		<% } %>
	</table>
	</form>
</div>
<% } %>