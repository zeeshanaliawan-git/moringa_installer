<%@ page import="java.util.StringTokenizer"%>
<%@ page import="com.etn.lang.ResultSet.ArraySet"%>
<%@ page import="com.etn.lang.ResultSet.*"%>
<%//,String requete_id ,String requete_name,String requete_desc %>
<%!String[] sql(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String select1,String filtres,int filtre,String group_by_h,String group_by_v,String type1,int select,boolean filtre_table_u){
	
	String group_by = "";
	String eqpt_select="";
	String filtre_s="";
	String autre_sql="";
	String autre_sql2="";
	
	if( type1 == null) type1="";
	if(select1==null) select1="";
	if(filtres==null) filtres="";
	if(group_by_h==null) group_by_h="";
	if(group_by_v==null) group_by_v="";

	if(group_by_h.equals("")){
		group_by = group_by_v;
	}else{
		group_by = group_by_h + group_by_v;
		//group_by = group_by_v + group_by_h;
	}

	javax.servlet.http.HttpSession session =  request.getSession(true);	
	session.removeAttribute("variable_filtre");
	session.removeAttribute("variable_valeur");
	session.removeAttribute("les_variables");
	
	
	System.out.println("************************** VARIABLE ****************************************\n\n");
	
	
		System.out.println("************************** VARIABLE - FILTRE ****************************************\n\n");
		
		System.out.println("Avant remplacement : " + filtres);
		String str_l = liste_filtre_variable(filtres,request);
		System.out.println("Après remplacement : " + str_l);
		filtres = str_l;
		
		System.out.println("************************** VARIABLE - FILTRE - FIN ****************************************\n\n");
		
		
		System.out.println("************************** VARIABLE - SELECT  ****************************************\n\n");
		
		System.out.println("Avant remplacement : " + select1);
		String str_l2 = liste_valeur_variable(select1,request);
		System.out.println("Après remplacement : " + str_l2);
		select1 = str_l2;
		
		
		
		System.out.println("************************** VARIABLE - SELECT - FIN  ****************************************\n\n");
	

		java.util.HashMap<String,String> h_select = new java.util.HashMap<String,String>();
		
		/*String sqlCompteur = "SELECT distinct concat(if(unite<>'',concat(unite,'('),'count('),'`',c.nomlogique,'`',if(unite<>'',')',')')) champ,c.champ champ2 ,c.nomlogique,dbtable,nom_table_ihm,valbdd,valihm ";
		sqlCompteur+="  FROM catalog c ";
		sqlCompteur+=" WHERE c.filtrable & "+select+" and valbdd <> '' and valihm <> ''";*/
		String sqlCompteur = "SELECT distinct concat(if(unite<>'',concat(unite,'('),'count('),'`',c.nomlogique,'`',if(unite<>'',')',')')) champ,c.champ champ2 ,c.nomlogique,dbtable,nom_table_ihm,valbdd,valihm ";
		sqlCompteur+="  FROM catalog c ";
		sqlCompteur+=" WHERE  valbdd <> '' and valihm <> '' and valbdd like 'sql:%'"; //c.filtrable & "+select+"
	
		if( filtre_table_u ){
			if(! type1.equals("") ){
				sqlCompteur+= " and dbtable = '"+com.etn.util.Substitue.dblCote(type1)+"'";
			}
		}

		Set rsCompteur = Etn.execute(sqlCompteur);
		while(rsCompteur.next()){
			h_select.put(""+rsCompteur.value("nomlogique")+"_bdd",rsCompteur.value("valbdd"));
			h_select.put(""+rsCompteur.value("nomlogique")+"_ihm",rsCompteur.value("valihm"));
		}
	
	
	System.out.println("************************** VARIABLE - FIN ****************************************\n\n");
	
	
	
	System.out.println("************************** KPI ****************************************\n\n");
	
	System.out.println("SELECT AVANT : " + select1);
	

	if(! select1.equals("")){
		String str_kpi = "";
		String v_kpi[] = select1.split(",");

		//Set rsKPI = Etn.execute("select concat('[',nomkpi"+suffixe_kpi+",']') as nomkpi"+suffixe_kpi+",formule from "+table_kpi+" where constructeur = '"+constructeur+"'");
		Set rsKPI = Etn.execute("select concat('[',nomkpi,']') as nomkpi,formule from kpi where constructeur = '"+type1+"'");
		ArraySet ar = new ArraySet(rsKPI);
		ar.index("nomkpi");

		for(int v=0;v < v_kpi.length;v++){
			String kpi= v_kpi[v];
			if(! kpi.equals("")){
				String s2 = replaceKPI2(ar,v_kpi[v]);
				String kpi2 = kpi.replaceAll("\\[","").replaceAll("\\]","")+"";
				System.out.println("kpi renvoyé = "+kpi);
				if(s2.trim().equals(kpi2.trim())){
				//rien
					System.out.println("KPI " + s2 + " non trouvé.");
				}else{
					s2 += " as \""+kpi2+"\"";
				}
				
				
				str_kpi+= ","+ s2;
			}
		}
		
		select1 = str_kpi;
	}
	

	System.out.println("SELECT APRES : " + select1);
	System.out.println("\n\n************************** KPI ****************************************\n\n");
	
	
	System.out.println("************************** PARAMETRE RETOURNESQL2 ****************************************\n\n");
	System.out.println("FITLRES : "+filtres);
	System.out.println("AUTRE_SQL : "+autre_sql);
	System.out.println("AUTRE_SQL2 : "+autre_sql2);
	System.out.println("\n\n*************************** PARAMETRE RETOURNESQL2 ****************************************\n\n");
	
	makeSql m1 = new makeSql();
	
	String sql_filtres = m1.retourneSQL2(filtre_s,group_by_h,group_by_v,filtre_s,autre_sql,autre_sql2,Etn,type1,filtre_table_u);//retourneSQL2(filtres,request,filtre_s,autre_sql,autre_sql2,Etn,type1);
	String le_select="";
	
		
	le_select += (! "".equals(group_by)?""+group_by+"":"") ;
	le_select += (! "".equals(select1)?","+select1.substring(1):"");
	
	if(! le_select.equals("")){
		if( le_select.charAt(0) == ','){
			le_select = le_select.substring(1);
		}
	}
	
	String le_select3 = "";
	String le_select2[] = le_select.split(",");
	System.out.println("le_select =========>" + le_select3);
	for(int l=0;l<le_select2.length;l++){
		System.out.println("Replace for bdd ihm ==>" + le_select2[l]+"======>"+h_select.get(le_select2[l]+"_bdd"));
		if( h_select.get(le_select2[l]+"_bdd")!=null){
			if(! h_select.get(le_select2[l]+"_bdd").toString().equals("")){
				String bdd = ( h_select.get(le_select2[l]+"_bdd")==null?"":""+h_select.get(le_select2[l]+"_bdd"));
				String ihm = ( h_select.get(le_select2[l]+"_ihm")==null?"":""+h_select.get(le_select2[l]+"_ihm"));
				le_select3 += (le_select3.equals("")?"":",")+ "SUBSTRING_INDEX(SUBSTRING_INDEX('"+ihm+"',',',FIND_IN_SET("+le_select2[l]+",'"+bdd+"')),',',-1) as "+le_select2[l];
			}
		}else{
			le_select3 +=(le_select3.equals("")?"":",")+ le_select2[l];
		}
	}
	le_select = le_select3;

/*	Qry q = new Qry( Etn );
	java.util.HashMap h = new java.util.HashMap();
	h.put("type",""+(type1.equals("")?"":type1));
	h.put("having1",""+having);

	q.setMap(h);
*/
	try{
	
		System.out.println("************************** PARAMETRE ENVOYE PAR L'IHM ****************************************\n\n");
	  	System.out.println("SELECT : "+select1);
		System.out.println("FITLRES : "+sql_filtres);
		System.out.println("GROUP BY_HORIZONTAL : "+group_by_h);
		System.out.println("GROUP BY VERTICAL : "+group_by_v);
		System.out.println("\n\n*************************** PARAMETRE ENVOYE PAR L'IHM ****************************************\n\n");

		System.out.println("*************************** PARAMETRE ENVOYE AU REQUETEUR ***********************************************\n\n");
		System.out.println("SELECT : "+ le_select);
		System.out.println("FITLRES : "+sql_filtres);
		System.out.println("GROUP BY: "+ (group_by_v.equals("")?"":group_by.substring(1)));
		System.out.println("\n\n**************************** PARAMETRE ENVOYE AU REQUETEUR **********************************************\n\n");
	
	
	}catch(Exception ee){
		   //out.write("<body onload=\"afficheAlert('Erreur : ','test');\"><form name='f2'><textarea id='test'>"+getStackTraceAsString(ee)+"</textarea>");
		   AfficheErreur("500",request.getParameter("export1"));
		   System.out.println("Parametre envoye - try catch :");
		   System.out.println("select : "+select1);
		   System.out.println("retourneSQL : "+sql_filtres);
		   System.out.println("group_by_h : "+group_by_h);
		   System.out.println("group_by_v : "+group_by_v);
		   System.out.println("ERREUR : " + getStackTraceAsString(ee));
	   }

	String r_sql [] = null;
		
	if( (! "".equals(le_select)) || (! "".equals(sql_filtres)) || (! "".equals(group_by)) ){
		r_sql = new String[]{ le_select,sql_filtres,(group_by_v.equals("")?"":group_by.substring(1)) };
	}else{
		r_sql = new String[]{""};
	}
	return(r_sql);
}
%>
