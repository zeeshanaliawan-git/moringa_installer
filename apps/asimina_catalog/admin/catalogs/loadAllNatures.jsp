<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.sql.escape,com.etn.beans.app.GlobalParm"%>
<%@ include file="../../WEB-INF/include/commonMethod.jsp"%>
<%

	String catapulteDb = com.etn.beans.app.GlobalParm.getParm("CATAPULTE_DB");

	String q = "SELECT 1 as o, coalesce(categorie,'zzzzzzzzzz') as familie,  "
				+ " rubrique as nature, 1 as c "
				+ " FROM "+catapulteDb+".natures n"
				+ " WHERE coalesce(n.profession,'Z-COMMUN') = 'Z-COMMUN' "
				+ " ORDER BY o, c desc, familie, nature";

	Set rs = Etn.execute(q);

%>

    <div class="container-fluid col-md-10 invoice_nature_container" style="height:400px; width:700px; ">
		<div class="semi-transparent30 col-md-12 w-100" style="overflow:auto">
			<%
				String prevFamily = "";
				int familyCount = 0;
				while(rs!= null && rs.next()) {
				if(!prevFamily.equals(rs.value("familie"))) {
					familyCount++;
			%>
				<div style="font-size:8pt; margin-top:15px; cursor:pointer; clear:both;" onclick="showHideNatureChilds('<%=familyCount%>')">
					<input type='hidden' id='genre_is_hidden_<%=familyCount%>' value='1' />
					<div style='padding-top:3px; float:left;'>
						<div id='genre_collapse_<%=familyCount%>' style='width: 0; height: 0; border-top: 4px solid transparent;border-bottom: 4px solid transparent;border-left: 4px solid black;'></div>
						<div id='genre_expand_<%=familyCount%>' style='display:none; width: 0; height: 0; border-left: 4px solid transparent;border-right: 4px solid transparent;border-top: 4px solid black;'></div>
					</div>
   	              	<div style='float:left;padding-left:3px;'>
   	              		<b><%=rs.value("familie").replaceAll("zzzzzzzzzz","Autres")%></b>
   	              	</div>
					<div style='clear:both'></div>
				</div>
				<% }//if %>
				<div class='genre_childs genre_childs_<%=familyCount%>' style='display:none; clear:both; padding-left:35px; font-size:10pt;'>
					<a style='font-size:9pt;color:#333; ' href='javascript:setNature("<%=rs.value("nature")%>")' > <%=rs.value("nature")%></a>
				</div>
			<%
					prevFamily = rs.value("familie");
				}//while
			%>
		</div>
	</div>

