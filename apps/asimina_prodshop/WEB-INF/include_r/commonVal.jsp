<%@ page import="com.etn.beans.app.GlobalParm"%>
<%
//response.setHeader("Pragma","No-cache");
//response.setHeader("Cache-Control","no-cache");
//response.setHeader("Expires",new java.util.Date(System.currentTimeMillis()-160000).toString());
String urlR = request.getContextPath()+"/requeteur/";
String url_requeteur = com.etn.beans.app.GlobalParm.getParm("URL_REQUETEUR");

boolean sql_ihm_in_local = true;
int i_compteur = 200;
int limit_inbox=50;

//Masque de gestion des champs de la table catalogue (champ filtrable)
int sysfiltre=com.etn.requeteur.Types.sysfiltre;
int sysselect=com.etn.requeteur.Types.sysselect;
int sysgroupe=com.etn.requeteur.Types.sysgroupe;

int filtre=com.etn.requeteur.Types.filtre;
int select=com.etn.requeteur.Types.select;
int groupe=com.etn.requeteur.Types.groupe;
int sysval=com.etn.requeteur.Types.sysval;

int tdb_width = 800;
int tdb_height = 600;


boolean user_national=false;

boolean filtre_table_u = false;

boolean aff_clouds = true;

//String UR[] = {"URM DONGES","URM LILLE","URM LYON","URM MARSEILLE","URM NANCY","URM PARIS","URM TOULOUSE"};
String type[] = {"EPR","SAR","RECO","DOSMEDSP","MED","BILANSP"};

String signe[] = {">=",">","=","<","<=","between"};

String type_kpi[] = {"Chiffre","Ratio"};

String typedb[] = {"Double","Float","Int","String"};

String onglet[] = {"Valeur", "Filtre", "Agrégation/Ordre" };


String onglet_filtre[] = {"Contexte", "Détails Filtres", "Temps" };//"Filtre Avancé"
//liste requete,liste_requete,requete,kpi_admin
String str_filtres1[] = {"le "+onglet_filtre[0].toLowerCase()+"","tous les "+onglet_filtre[0].toLowerCase()+"s","S&eacute;lectionner le ","un "+onglet_filtre[0].toLowerCase()+""};


String onglet_valeur[] = {"Champs","Résultat","KPI"};//","Requete"Valeur Avancée"

String onglet_agregation[] = {"Période", "Critères","Ordre" };//,"Requete""Agregation Avancée"

String unite[] = {"Erlang"};

String type3[] = {"Champ","Nb"};

/*String h_pleines = "TIME(psdate) between '00:00' and '23:59'";

String h_creuses = "TIME(psdate) between '00:00' and '23:00'";*/

String busyhour = "busyh";

String filtresemaine = "DAYOFWEEK(psdate)<=5";

String filtresamedi = "DAYOFWEEK(psdate)=6";

String filtredimanche = "DAYOFWEEK(psdate)=7";

String filtreWE = "DAYOFWEEK(psdate)>=6";


%>
<%!String getSepa(int i) {
	/*String sepa1=",";
	String sepa2=";";*/
	String sepa="";
	if(i==1){
		sepa=",";
	}
	if(i==2){
		sepa=";";
	}
	return(sepa);

}%>
