<%
//[][0] => titre menu
//[][1] => url
//[][2] => title
//[][3] => droit
//[][4] => type menu (admin,etc ...)
//[][5] => alternative menu


String tab_menu[][] = new String[14][6];

for(int i=0;i<tab_menu.length;i++){
	tab_menu[i][0] = "";
	tab_menu[i][1] = "";
	tab_menu[i][2] = "";
	tab_menu[i][3] = "";
	tab_menu[i][4] = "";
	tab_menu[i][5] = "";
}


tab_menu[0][0] = libelle_msg(Etn,request,"Requ&ecirc;tes pré-définies"); 
tab_menu[0][1] = url_requeteur+"admin/liste_requete.jsp";
tab_menu[0][2] = libelle_msg(Etn,request,"Requ&ecirc;tes pré-définies");
tab_menu[0][3] = "all";


tab_menu[1][0] = libelle_msg(Etn,request,"Nouvelle requête");
tab_menu[1][1] = url_requeteur+"admin/flexgrid.jsp";
tab_menu[1][5] = url_requeteur+"requete.jsp";
tab_menu[1][3] = "all";

tab_menu[2][0] = "Dashboard 1";
tab_menu[2][1] = url_requeteur+"chart/tdb.jsp";
tab_menu[2][3] = "all";
tab_menu[2][5] = url_requeteur+"chart/tdb_visutt.jsp,"+url_requeteur+"chart/tdb_creat.jsp";



tab_menu[3][0] = "Dashboard 2";
tab_menu[3][1] = url_requeteur+"chart/dashboard_list.jsp";
tab_menu[3][5] = url_requeteur+"chart/my_dashboard2.jsp";
tab_menu[3][3] = "all";

tab_menu[4][0] = libelle_msg(Etn,request,"KPI");
tab_menu[4][1] = url_requeteur+"admin/kpi_admin.jsp";
tab_menu[4][2] = libelle_msg(Etn,request,"KPI");
tab_menu[4][3] = "all";


tab_menu[5][0] = libelle_msg(Etn,request,"Refresh data");
tab_menu[5][1] = url_requeteur+"refresh_data.jsp";
tab_menu[5][2] = libelle_msg(Etn,request,"Refresh data");
tab_menu[5][3] = "all";
tab_menu[5][5] = url_requeteur+"doRefresh.jsp";

tab_menu[6][0] = libelle_msg(Etn,request,"Utilisateur");
tab_menu[6][1] = url_requeteur+"admin/UserInfo.jsp";
tab_menu[6][2] = libelle_msg(Etn,request,"Info utilisateur");
tab_menu[6][3] = "all";

tab_menu[7][0] = libelle_msg(Etn,request,"Libellés");
tab_menu[7][1] = url_requeteur+"admin/lang.jsp";
tab_menu[7][2] = libelle_msg(Etn,request,"Libellé");
tab_menu[7][3] = "admin";

tab_menu[8][0] = libelle_msg(Etn,request,"Variables/Constantes");
tab_menu[8][1] = url_requeteur+"admin/variable_constante.jsp";
tab_menu[8][2] = libelle_msg(Etn,request,"administration des variables et constantes");
tab_menu[8][3] = "admin";

tab_menu[9][0] = "Adminstration";
tab_menu[9][1] = url_requeteur+"admin/requeteur2.jsp";
tab_menu[9][3] = "admin";
tab_menu[9][5] = url_requeteur+"admin/jointure.jsp,"+url_requeteur+"admin/sphereViewAdmin.jsp";

tab_menu[10][0] = "Toucan";
tab_menu[10][1] = "javascript:loadToucan('"+request.getContextPath()+"','"+request.getServletPath()+"')";
tab_menu[10][3] = "admin";


tab_menu[11][0] = "Admin2";
tab_menu[11][1] = url_requeteur+"admin/sphereViewAdmin.jsp";
tab_menu[11][3] = "admin";

tab_menu[12][0] = "Sphere View";
tab_menu[12][1] = url_requeteur+"construction/sphereview.jsp";
tab_menu[12][3] = "admin";

tab_menu[13][0] = "Documentation";
tab_menu[13][1] = url_requeteur+"documentation/documentationsList.jsp";
tab_menu[13][3] = "admin";


%>