
<style>
<!--
.temp { border: 1px solid #77d5f7; background: #0078ae url(../css/jquery/images/ui-bg_glass_45_0078ae_1x400.png) 50% 50% repeat-x; font-weight: normal; color: #ffffff;height: 25px; }
.temp3 { border: 1px solid #77d5f7; background: #0078ae url(../css/jquery/images/ui-bg_gloss-wave_45_e14f1c_500x100.png) 50% 50% repeat-x; font-weight: normal; color: #ffffff;height: 25px; }

.hbloc { font-family: trebuchet MS;margin: 0px;padding: 0px;margin-top: 5px;border: 1px solid #4297D7; background: #0078ae url(../css/jquery/images/ui-bg_gloss-wave_55_5c9ccc_500x100.png) 50% 50% repeat-x;
 font-weight: normal; color: #ffffff;padding-top: 8px; padding-bottom: 8px; vertical-align: middle;font-weight: bold;text-indent: 10px;text-align: left;width: 98%;font-size: 8pt; }
.shbloc {font-family: trebuchet MS;background: #F5F8F9/*#EAF4FD #F2F2F2*/;margin: 0px;padding: 0px;border: 1px solid #C5DBEC;width: 100%;margin-top: 5px;}

.cloud {border: 1px solid red;}

-->
</style>
<script type="text/javascript" src="../js/toucan.js"></script>
<div class="bandtop2" style="padding-bottom: 15px;">
<center>
<%
String uri = request.getRequestURI();
String getURI = request.getRequestURI();
//out.write("getURI="+getURI);
//out.write("str_droit="+session.getAttribute("str_droit"));
%>


<%@include file="/WEB-INF/include_r/les_menus.jsp" %>


<table class="bandcad" cellpadding="0" cellspacing="0" border="0" height="30" style="border-bottom: 0px solid #AAD1E1;">
<tr>
<!-- <td align="center" valign="bottom"><a href="<%=request.getContextPath()%>" class="logo"><%=libelle_msg(Etn,request,"requeteur")%></a>
		<br><b style="color: #9FDCFF;font-size: 8pt;font-style: italic;font-family: trebuchet MS;">v<%=version_requeteur%>&nbsp;(béta)</b></td> -->
<td valign="top">
	<table cellpadding="0" cellspacing="0" border="0" class="bandlink" width="100%">
			<tr>			
<%
int i_tab_menu=0;
int i_tab_menu2=0;
boolean droit_menu = false;
for(int i=0;i<tab_menu.length;i++){
	//out.write(""+i_tab_menu+"=="+(tab_menu.length-1)+"<br>");
	boolean b_menu = false;
	
	int z = droit(request,tab_menu[i][3]);
	
	//out.write(tab_menu[i][0]+"="+z+"<br>");
	if(z>-1){
	
		if( tab_menu[i][1].equals(getURI) ){
			b_menu = true;
			i_tab_menu2++;
		}
		//out.write(getURI+"==>"+tab_menu[i][5]+"==>"+tab_menu[i][5].indexOf(getURI)+"<br>");
		if( tab_menu[i][5].indexOf(getURI)!=-1  ){
			
			b_menu = true;
			i_tab_menu2++;
		}
	
	%>
	<td>
	<a <%=(tab_menu[i][2].equals("")?"":" title=\""+tab_menu[i][2]+"\"")%>  href="<%=tab_menu[i][1]%>" <%if(b_menu){out.write("style='color:#C1ED63;font-size:10pt;'");}%>  ><%=tab_menu[i][0]%></a>
	</td>
	<%if(i_tab_menu < (tab_menu.length-1) ){ %>
	<td class="bandsep">&#9474;</td>		
	<%
	} 
	}%>
<%i_tab_menu++;
}
%>
			</tr>
	</table>

</td>
</tr>
</table>
<%

boolean p_menu = false;
if(p_menu) {%>
<table class="bandcad" cellpadding="0" cellspacing="0" border="0" height="30" style="border-bottom: 0px solid #AAD1E1;">
	<tr>
		<td ><a href="<%=request.getContextPath()%>/" class="logo"><%=libelle_msg(Etn,request,"requeteur")%></a>
		<b style="color: #9FDCFF;font-size: 8pt;font-style: italic;font-family: trebuchet MS;">v<%=version_requeteur%></b></td>
		<td>
		<table cellpadding="0" cellspacing="0" border="0" class="bandlink" width="100%">
			<tr>				
				<td>
				<a href="<%=url_requeteur+"/"%>admin/liste_requete.jsp" title="<%=libelle_msg(Etn,request,"Requ&ecirc;tes pré-définies")%>"><%=libelle_msg(Etn,request,"Requ&ecirc;tes pré-définies")%>
				</a></td>
				<td class="bandsep">&#9474;</td>
				<td>
				<a href="<%=url_requeteur+"/"%>requete.jsp"><%=libelle_msg(Etn,request,"Nouvelle requête")%>
				</a></td>
				<td class="bandsep">&#9474;</td>
				<td>
				<a href="<%=url_requeteur+"/"%>admin/flexgrid.jsp" title="Creview">Creview
				</a></td>
				<td class="bandsep">&#9474;</td>
				<td>
				<a href="<%=url_requeteur+"/"%>chart/dashboard_list.jsp" title="Dashboards">Dashboards
				</a></td>	
				<td class="bandsep">&#9474;</td>			
				<!-- <td align="center">
				<a href="<%//=url_requeteur+"/"%>chart/tdb.jsp" title="<%=libelle_msg(Etn,request,"Tableau de bord")%>"><%//=libelle_msg(Etn,request,"Tableau de bord")%>
				</a></td>	 -->			
				<td>
				<a href="<%=url_requeteur+"/"%>admin/kpi_admin.jsp" title="<%=libelle_msg(Etn,request,"KPI")%>"><%=libelle_msg(Etn,request,"KPI")%>
				</a></td>
				<td class="bandsep">&#9474;</td>
				<td>
				<a href="<%=url_requeteur+"/"%>refresh_data.jsp" title="<%=libelle_msg(Etn,request,"Refresh data")%>"><%=libelle_msg(Etn,request,"Refresh data")%>
				</a></td>
			
				<%if(isAdmin){ %>
				<td class="bandsep">&#9474;</td>
				<td> 
				<a href="<%=url_requeteur+"/"%>admin/UserInfo.jsp" title="<%=libelle_msg(Etn,request,"Info utilisateur")%>"><%=libelle_msg(Etn,request,"Utilisateur")%>
				</a></td>
				<td class="bandsep">&#9474;</td>
				<td>
				<a href="<%=url_requeteur+"/"%>admin/lang.jsp" title="<%=libelle_msg(Etn,request,"Libellé")%>"><%=libelle_msg(Etn,request,"Libellés")%>
				</a></td>
				<td class="bandsep">&#9474;</td>
				<td>
				<a href="<%=url_requeteur+"/"%>admin/variable_constante.jsp" title="<%=libelle_msg(Etn,request,"administration des variables et constantes")%>"><%=libelle_msg(Etn,request,"Variables/Constantes")%>
				</a></td>
				<td class="bandsep">&#9474;</td>
				<!-- <td align="center">
				<a href="<%//=url_requeteur+"/"%>admin/catalogue2.jsp" title="<%//=libelle_msg(Etn,request,"Catalogue")%>"><%//=libelle_msg(Etn,request,"Catalogue")%>
				</a></td>
				<td align="center">
				<a href="<%//=url_requeteur+"/"%>admin/jointure.jsp" title="<%//=libelle_msg(Etn,request,"Jointure")%>"><%//=libelle_msg(Etn,request,"Jointure")%>
				</a></td>
				<td align="center">
				<a href="<%//=url_requeteur+"/"%>admin/import.jsp" title="<%//=libelle_msg(Etn,request,"Import")%>"><%//=libelle_msg(Etn,request,"Import")%>
				</a></td>
				<td  align="center">
				<a href="<%//=url_requeteur+"/"%>admin/exclusion.jsp" title="<%//=libelle_msg(Etn,request,"Exclusion")%>"><%//=libelle_msg(Etn,request,"Exclusion")%>
				</a></td>
				<td align="center">
				<a href="<%//=url_requeteur+"/"%>admin/serveur.jsp" title="<%//=libelle_msg(Etn,request,"Serveur")%>"><%//=libelle_msg(Etn,request,"Serveur")%>
				</a></td> -->
				<td>
				<a href="<%=url_requeteur+"/"%>admin/requeteur2.jsp" title="New Admin">New Admin
				</a></td>
                                <td class="bandsep">&#9474;</td>
                                <td>
				<a href="javascript:loadToucan('<%=request.getContextPath()%>','<%=request.getServletPath()%>')" title="Toucan">Toucan
                                </a></td>
				
				
				<%} %>
			
		</table>
		</td>
		
	</tr>
</table>
<%} %>
</center>

</div>

<%if(i_tab_menu2==0){ %>
<br><table align="center"><tr><td><img src="<%=url_requeteur%>img/exclamation.png" border="0"></td><td>Vous n'avez pas les droits !</td></tr></table>
</body></html>
<%
if(1==1)return;
} %>

<!-- <div style="background: url('<%=request.getContextPath()%>/css/jquery/images/ui-bg_gloss-wave_75_2191c0_500x100.png') repeat-x 50%;margin:0px;padding:0px;padding:3px;"></div>-->

<!-- <div class="temp">test</div>
<div class="temp2">test2</div>   -->