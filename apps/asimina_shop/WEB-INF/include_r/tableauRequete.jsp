<%!
public class AlphabeticComparator 
implements java.util.Comparator{
  public int compare(Object o1, Object o2) {
    String s1 = (String)o1;
    String s2 = (String)o2;
    return s1.toLowerCase().compareTo(
      s2.toLowerCase());
  }
}
%>
<%!
 public String getStackTraceAsString2(Throwable e) {
		java.io.ByteArrayOutputStream bytes = new java.io.ByteArrayOutputStream();
		java.io.PrintWriter writer = new java.io.PrintWriter(bytes, true);
		e.printStackTrace(writer);
		return bytes.toString();
	}
%>
<%
//	Paramètre AfficheTableau
//  ------------------------
//	Etn	: le contexte 
//	rs 	: le resultset
//	aff_valeur	:
//		0 : tableau "normal"
//		1 : tableau ligne
//		2 : tableau colonne
//		3 : tableau ligne bis
//		4 : tableau ligne 3
//	ligne	: nom des colonnes a mettre en ligne (champs séparé par des virgules)
//	colonne	: nom des colonnes a mettre en colonne (champs séparé par des virgules)
//	valeur	: nom des colonnes (champs séparé par des virgules)
//	options : afficher total lignes, total colonnes, détails ...
%>
<%!String AfficheTableau(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest req,com.etn.lang.ResultSet.Set rs,String aff_valeur,String ligne,String colonne,String valeur,String ordre,java.util.HashMap options){
	java.lang.StringBuilder buf = new StringBuilder(64000);
	java.lang.StringBuilder buf2 = new StringBuilder(4000);
	//buf2.append("rs.rs.Rows="+rs.Cols);
	try{	
	
//ligne --> vertical
//colonne --> horizontal

int nbr_case_limit = (options.get("source")==null?20000:70000);	//nombre de case limite du tableau
int nbr_case = 0;

String les_index="";
String sepa="!";
String sepa2="ù";
String sepa3 = "£";
String valeur_vide="(vide)";

nbr_case = rs.Cols*rs.rs.Rows;

if(nbr_case>nbr_case_limit){
	if( options.get("source")==null){
		String msg="";
		
		msg="<center><table style='font-size:11px;border:1px dotted silver;background-color:#FFEBBF;text-align:center;'><tr><td><img src='../img/messagebox_info.png' border='0'></td><td>Le nombre d'élément retourné est trop important.<br>";
		System.out.println("export_xls="+options.get("export_xls"));
		if(options.get("export_xls")!=null){
			msg+="Veuillez cliquer sur le lien pour exporter le résultat de <a style='text-decoration:underline;font-weight:bold;cursor:pointer;' onclick=\""+options.get("export_xls")+"\">"+ options.get("titre") +"</a></td></tr></table>";
		}
		msg+="</center><br>";
		return(msg);
	}else{
		return("export");
	}
}else{
	//buf2.append("nbr_case2:"+nbr_case);
/*
java.util.HashMap typeValeur = new java.util.HashMap();
java.util.HashMap total = new java.util.HashMap();
java.util.HashMap nbr_key = new java.util.HashMap();
*/
java.util.HashMap typeValeur = new java.util.HashMap();
java.util.HashMap typeValeur2 = new java.util.HashMap();
java.util.HashMap total = new java.util.HashMap();
java.util.HashMap total2 = new java.util.HashMap();
java.util.HashMap totaux = new java.util.HashMap();
java.util.HashMap nbr_key = new java.util.HashMap();
java.util.HashMap nbr_key2 = new java.util.HashMap();

/*java.lang.StringBuffer buf = new StringBuffer();
java.lang.StringBuffer buf2 = new StringBuffer();*/



//buf2.append("<pre>"+new String(rs.rs.data)+"</pre>");

if( colonne.equals("")){
	/*if(! aff_valeur.equals("0")){
		buf.append("<br><center><font style='color:red;font-size:11px;'>"+libelle_msg(Etn,req,"Vous n'avez pas sélectionné de champ pour l'agrégation par colonnes, l'affichage à été basculé (non enregistré) en mode ligne")+".<br><br></font></center>");
		buf.append("<br><center><font style='color:#808080;font-size:11px;'>"+libelle_msg(Etn,req,"Vous n'avez pas sélectionné de champ pour l'agrégation par colonnes, l'affichage à été basculé (non enregistré) en mode ligne")+".<br><br></font></center>");
		
	}
	aff_valeur = "0";
	*/
}
if(aff_valeur.equals("0")){
	if(! colonne.equals("")){
		if( options.get("affiche_total_colonne")!=null){
			if( options.get("affiche_total_colonne").equals("1")){		
				buf.append("<br><center><font style='color:#808080/*red*/;font-size:11px;'>"+libelle_msg(Etn,req,"Vous avez sélectionné un champ pour l'agrégation par colonnes et un mode ligne pour l'affichage,cela va provoquer une décalage dans les totaux en colonnes")+".<br><br></font></center>");
			}
		}
	}
}

/*if(aff_valeur.equals("0")){
	nbr_case = rs.Cols*rs.rs.Rows;
	buf2.append("nbr_case du tableau : " + nbr_case);
}
if(aff_valeur.equals("1")){
	
}
if(aff_valeur.equals("2")){
	
}
if(aff_valeur.equals("3")){
	
}
if(aff_valeur.equals("4")){
	
}*/




if(!"".equals(ligne)){
	if( ligne.charAt(0)==','){
		ligne = ligne.substring(1);
	}
}

if(!"".equals(colonne)){
	if(  colonne.charAt(0)==',' ){
		colonne = colonne.substring(1);
	}
}

if(!"".equals(valeur)){
	if( valeur.charAt(0)==','){
		valeur = valeur.substring(1);
	}
}

String liste_valeur = "";//valeur;

String liste_valeur2[] = valeur.toUpperCase().split(",");
HashMap liste_valeur3 = new HashMap();
 
for(int zz= 0; zz < liste_valeur2.length;zz++){
	if( liste_valeur3.get(liste_valeur2[zz])==null){
		if( liste_valeur2[zz].indexOf(" AS")!=-1){/*traitement des AS */
			liste_valeur2[zz] = liste_valeur2[zz].substring(liste_valeur2[zz].indexOf(" AS")+3);
		}
		liste_valeur += (zz==0?"":",")+"'"+liste_valeur2[zz]+"'";
		liste_valeur3.put(liste_valeur2[zz],"");
	}
}
valeur = "";

/*traitement des AS */
for(int zz= 0; zz < liste_valeur2.length;zz++){
		if( liste_valeur2[zz].trim().indexOf(" AS")!=-1){
			liste_valeur2[zz] = liste_valeur2[zz].trim().substring(0,liste_valeur2[zz].indexOf(" AS")+3);
		}
		valeur += (zz==0?"":",")+""+liste_valeur2[zz].trim()+"";
}

if(!"".equals(valeur)){
	if( valeur.charAt(0)==','){
		valeur = valeur.substring(1);
	}
}
/*traitement des AS */

String sqlKPI="select nomkpi,type,typedb,unite as format from kpi where nomkpi in ("+liste_valeur+")";
if(options.get("type_elt")!=null){
	if(!options.get("type_elt").equals("")){
		sqlKPI+=" and constructeur = '"+options.get("type_elt")+"'";
	}
}
com.etn.lang.ResultSet.Set rsListeKPI = Etn.execute(sqlKPI);
while(rsListeKPI.next()){
	//System.out.println("'"+rsListeKPI.value("nomkpi").trim().toUpperCase()+"'==>'"+rsListeKPI.value("format").trim().toLowerCase()+"'");
	typeValeur.put(""+rsListeKPI.value("nomkpi").trim().toUpperCase(),""+rsListeKPI.value("type").trim().toLowerCase());
	typeValeur.put(""+rsListeKPI.value("nomkpi").trim().toUpperCase()+"_format",""+rsListeKPI.value("format"));
	typeValeur2.put(""+rsListeKPI.value("nomkpi").trim().toUpperCase(),""+rsListeKPI.value("typedb").trim().toLowerCase());
	
	//System.out.println("'"+rsListeKPI.value("nomkpi").trim().toUpperCase()+"'==>'"+rsListeKPI.value("typedb").trim().toLowerCase()+"'");
	
}

if(!valeur.equals("")){
	valeur = valeur.replaceAll("\\[","");
	valeur = valeur.replaceAll("\\]","");
	//valeur = valeur.replaceAll("`","");
}

valeur = valeur.toUpperCase();
ligne = ligne.toUpperCase();
colonne = colonne.toUpperCase();


/*System.out.println("valeur="+valeur);
System.out.println("ligne="+ligne);
System.out.println("colonne="+colonne);*/

String vertical2[] = ligne.split(",");
String horizontal2[] = colonne.split(",");	
String valeur2[] = valeur.split(",");
String les_valeurs[]=valeur.split(",");


String les_colonnes = "";

if(!"".equals(colonne)){
les_colonnes = colonne+","+ligne+","+valeur;
}else{
	les_colonnes = ligne+","+valeur;
}
String les_colonnes2[] = les_colonnes.split(",");

//System.out.println("les_colonnes="+les_colonnes);

		
//if(  aff_valeur.equals("0") || aff_valeur.equals("1") || aff_valeur.equals("3") || aff_valeur.equals("4") ){
/****************************************************************	TOTAL LIGNE	**********************************************************************/
if( options.get("affiche_total_ligne")!=null){
	if( options.get("affiche_total_ligne").equals("1")){

			while( rs.next()){
				String key = "";
				for(int i=0;i<vertical2.length;i++){
					String valeur_r = rs.value(vertical2[i]);
					if(valeur_r == null ) valeur_r="";
					if( valeur_r.equals("")) valeur_r = valeur_vide;
					key+=(i==0?"":sepa)+valeur_r;
				}
				
				for(int i2=0;i2<valeur2.length;i2++){
					String key2=key+sepa+valeur2[i2].toUpperCase().trim();
					//buf2.append(""+rs.value(valeur2[i2].trim())+"====>"+rs.types[rs.indexOf(valeur2[i2].trim())]+"==>"+rs.ColName[rs.indexOf(valeur2[i2].trim())]);
					
					int typV = 2;
					
					int col = rs.indexOf(valeur2[i2].toUpperCase().trim());
					//System.out.println("col='"+valeur3+"'====>col="+col + "==>"+rs.types[1] );
					//buf2.append("col='"+valeur3+"'====>col="+col + "==>"+rs.types[col]+"<br>");
					
					if(col>-1){
						if(rs.types[col] == com.etn.lang.XdrTypes.INT){
							typV = 1;
						}else{
							if(rs.types[col] == com.etn.lang.XdrTypes.DOUBLE && rs.types[col] == com.etn.lang.XdrTypes.NUMERIC){
								typV = 2;
							}
						}
					}
					
					String typC = "";   
					if( typeValeur2.get(""+valeur2[i2].toUpperCase().trim()) != null){
						typC = ""+ typeValeur2.get(""+valeur2[i2].toUpperCase().trim());
					}
					//buf2.append("'"+valeur2[i2].trim()+"'====>typC="+typC);
					//System.out.println("'"+valeur2[i2].trim()+"'====>typC="+typC);
					
					if (! typC.equals("") ){
						if( typC.equalsIgnoreCase("float") || typC.equalsIgnoreCase("double") ){
							typV = 2;
						}else{
							if(  typC.equalsIgnoreCase("int") ){
								typV = 1 ;
							}
						}
					}
					
					if( typV > 0 ){
						//buf2.append("'"+valeur2[i2].trim()+"'====>"+rs.value(valeur2[i2].trim()));
						concat_valeur_numeric(total,key2.trim(),rs.value(valeur2[i2].trim()),typV);	//total
						concat_valeur_numeric(nbr_key,key2.trim(),"1",1);							//nbr de valeur
						
						//buf2.append("'"+valeur2[i2].trim()+"'====>"+total.get(key2));
						
					}
				}
			}

	}
}
/****************************************************************	TOTAL LIGNE	**********************************************************************/
/****************************************************************	TOTAL LIGNE	**********************************************************************/
rs.moveFirst();
/*********************************************************************	TOTAL COLONNE	***************************************************************/

if( options.get("affiche_total_colonne")!=null){
	if( options.get("affiche_total_colonne").equals("1")){
		
	
	while( rs.next()){
		String key = "";
		for(int i=0;i<horizontal2.length;i++){
			String valeur_r = rs.value(horizontal2[i]);
			if(valeur_r == null ) valeur_r="";
			if( valeur_r.equals("")) valeur_r = valeur_vide;
			key+=(i==0?"":sepa)+valeur_r;
		}
		for(int i2=0;i2<valeur2.length;i2++){
			String key2=key+sepa+valeur2[i2].toUpperCase().trim();
			
			
			
			
			int typV = 2;
			String typC = "";
			String valeur3  = valeur2[i2].toUpperCase().trim();
			
			int col = rs.indexOf(valeur3);
			//System.out.println("col='"+valeur3+"'====>col="+col + "==>"+rs.types[1] );
			//buf2.append("col='"+valeur3+"'====>col="+col + "==>"+rs.types[col]+"<br>");
			
			if(col>-1){
				if(rs.types[col] == com.etn.lang.XdrTypes.INT){
					typV = 1;
				}else{
					if(rs.types[col] == com.etn.lang.XdrTypes.DOUBLE && rs.types[col] == com.etn.lang.XdrTypes.NUMERIC){
						typV = 2;
					}
				}
			}
			
			/*if(valeur3.equals("")){
				valeur3 = valeur_vide;
			}*/
			
			if( typeValeur2.get(""+valeur3) != null){
				typC = ""+ typeValeur2.get(""+valeur2[i2].toUpperCase().trim());
			}
			//System.out.println("'"+valeur3+"'====>typC="+typC);
			
			
			
			
			if (! typC.equals("") ){
				
				if( typC.equalsIgnoreCase("float") || typC.equalsIgnoreCase("double") ){
					typV = 2;
				}else{
					if(  typC.equalsIgnoreCase("int") ){
						typV = 1 ;
					}
				}
				
			}
			//buf2.append("totaux_"+valeur2[i2].trim()+"====>typV="+typV+"<br>");
			//buf2.append("'"+valeur3+"'====>typV="+typV+"<br>");
			if( typV > 0 ){
				concat_valeur_numeric(total2,key2.trim(),rs.value(valeur2[i2].trim()),typV);	//total
				concat_valeur_numeric(nbr_key2,key2.trim(),"1",1);							//nbr de valeur
				
				
				if( valeur2[i2].startsWith("TX_")){
					concat_valeur_numeric(totaux,"totaux_"+valeur2[i2].trim(),rs.value(valeur2[i2].trim()),2); 		//totaux
				}else{
					//buf2.append("totaux_"+valeur2[i2].trim()+"====>typV="+typV+"<br>");
					//buf2.append(valeur2[i2].trim()+"("+typV+")====>"+rs.value(valeur2[i2].trim())+"<br>");
					concat_valeur_numeric(totaux,"totaux_"+valeur2[i2].trim(),rs.value(valeur2[i2].trim()),typV);
				}
				
				//buf2.append("totaux_"+valeur2[i2].trim()+"====>"+totaux.get("totaux_"+valeur2[i2].trim())+"<br>");
				
			}
		}
	}

	}
}

/*********************************************************************	TOTAL COLONNE	***************************************************************/
//}


java.util.Set lesCles = total.keySet() ;
java.util.Iterator it = lesCles.iterator() ;

/*	DEBUG	
Object obj;
String r ="";
  
while (it.hasNext()){
obj = it.next();
r=  ""+obj;	
	buf2.append(r+"==>"+nbr_key.get(""+r)+"<br>");
}
	DEBUG	*/

//buf2.append("<br>");
//buf2.append("<br>");

rs.moveFirst();


//filtrer la requete sur les colonne(s) sélectionnée(s)
java.util.HashMap<String,Byte> typeCol = getTypeCol(rs);
com.etn.lang.ResultSet.ExResult exRs = new com.etn.lang.ResultSet.ExResult(null,les_colonnes2,9,10);	
rs.moveFirst();
while(rs.next()){
	//System.out.println("==>"+rs.value(rs.indexOf("SUM(NB_1__DEMANDE)")));
	exRs.add();
for(int k=0;k<les_colonnes2.length;k++){
	String v=les_colonnes2[k].trim();
	//System.out.println("les_colonnes2["+k+"]="+les_colonnes2[k]+"==>"+rs.value(v));
	exRs.set(k,rs.value(rs.indexOf(v)));

}
	exRs.commit();
}
rs.moveFirst();
rs =  new com.etn.lang.ResultSet.ItsResult( exRs.getXdr() );
putTypeCol(rs,typeCol);
rs.moveFirst();
//filtrer la requete sur les colonne(s) sélectionnée(s) - fin 

//index pour l'ArraySet
for(int j=0;j < (rs.Cols-les_valeurs.length);j++){	
	les_index+=","+rs.ColName[j];
}
if(! les_index.equals("")){
	les_index = les_index.substring(1);
	}


/*buf.append("<br>"); 
buf.append("<br>");
buf.append("<br>");*/


byte sort3[] = new byte[vertical2.length];


int cpt3=0;
for(int b=0; b < vertical2.length; b++){
	for(int k=0; k < rs.Cols;k++){
		if(rs.ColName[k].equalsIgnoreCase(""+vertical2[b])){
			//buf2.append("col='"+rs.ColName[k]+"'====>==>"+rs.types[k]+"<br>");
			sort3[b] = (byte)k;
			cpt3++;
		}
	}
}


com.etn.lang.ResultSet.ArraySet ar_1 = new com.etn.lang.ResultSet.ArraySet(rs);

/***************	Trier des dates	*****************/
for(int c=0;c<ar_1.Cols;c++){
	if(ar_1.ColName[c].indexOf("PSDATE")!=-1 ){
		if( ! ar_1.ColName[c].equalsIgnoreCase("MOIS(PSDATE)") &&  ! ar_1.ColName[c].equalsIgnoreCase("SEMAINE(PSDATE)") ){
			ar_1.types[c] = com.etn.lang.XdrTypes.DATE;
		}
	}
}
/***************	Trier des dates	*****************/


int trier_auto=0;
if( options.get("forcer_tri")==null ){
	trier_auto++;
}
if( ordre != null && !ordre.equals("") ){
	trier_auto++;
}	
	

if(trier_auto==0){ 
//buf2.append("aa=>"+options.get("forcer_tri"));
com.etn.lang.ResultSet.SortArray sa_1 = new com.etn.lang.ResultSet.SortArray(ar_1,sort3,com.etn.lang.ResultSet.SortArray.NOCASE);	
com.etn.lang.ResultSet.ExResult ex_1 = new com.etn.lang.ResultSet.ExResult(null,ar_1.ColName,9,10);	
while(sa_1.next()){
	ex_1.add();
for(int k=0;k<sa_1.Cols;k++){
	ex_1.set(k,sa_1.value(k));

}
	ex_1.commit();
}
rs = new com.etn.lang.ResultSet.ItsResult(ex_1.getXdr());
}


HashMap total3  = new HashMap();
//tableau "normal"
if( aff_valeur.equals("-1")){ //0
	
	
	
   }else{

	   
	   if( rs.rs.Rows > 0){
	   //Prendre les valeurs
	   com.etn.lang.ResultSet.ArraySet ar3 = new com.etn.lang.ResultSet.ArraySet(rs);

	   String m2 [] = les_index.split(",");
	   ar3.index(m2);	//ar.index(m.split(","));
	   
	   
	   com.etn.lang.ResultSet.ArraySet ar = null;	//vertical
	   com.etn.lang.ResultSet.ArraySet ar2 = null;	//horizontal
	   
  		//buf2.append("ordre="+ordre);
	   
	   boolean with_no_order = false;
	   if( ordre == null || ordre.equals("") ){
		   with_no_order = true;
	   }
	   
	   //if( ordre == null && ordre.equals("") ){
		if( with_no_order ){
	   
	   /************************	TRI	RESULTSET *****************************/

	   byte sort[] = new byte[vertical2.length];
	   byte sort2[] = new byte[horizontal2.length];

	   int cpt=0;
	   for(int b=0; b < vertical2.length; b++){
	   	for(int k=0; k < ar3.Cols;k++){
	   		if(ar3.ColName[k].equalsIgnoreCase(""+vertical2[b])){
	   			sort[b] = (byte)k;
	   			cpt++;
	   		}
	   	}
	   }

	   cpt=0;
	   for(int bh=0; bh < horizontal2.length; bh++){
	   	for(int kh=0; kh < ar3.Cols;kh++){
	   		if(ar3.ColName[kh].equalsIgnoreCase(""+horizontal2[bh])){
	   			sort2[bh] = (byte)kh;
	   			cpt++;
	   		}
	   	}
	   }

	   
	   /***************	Trier des dates	*****************/
	   for(int c=0;c<ar3.Cols;c++){
	   	if(ar3.ColName[c].indexOf("PSDATE")!=-1 ){
	   		if( ! ar3.ColName[c].equalsIgnoreCase("MOIS(PSDATE)") &&  ! ar3.ColName[c].equalsIgnoreCase("SEMAINE(PSDATE)") ){
	   			ar3.types[c] = com.etn.lang.XdrTypes.DATE;
	   		}
	   	}
	   }
	   /***************	Trier des dates	*****************/

	   com.etn.lang.ResultSet.SortArray sa1 = new com.etn.lang.ResultSet.SortArray(ar3,sort,com.etn.lang.ResultSet.SortArray.NOCASE);	//vertical
	   com.etn.lang.ResultSet.SortArray sa2 = new com.etn.lang.ResultSet.SortArray(ar3,sort2,com.etn.lang.ResultSet.SortArray.NOCASE);	//horizontal

	   

	   
	   /************************	TRI	RESULTSET *****************************/
	  

	   com.etn.lang.ResultSet.ExResult ex1 = new com.etn.lang.ResultSet.ExResult(null,sa1.ColName,9,10);	//vertical
	   while(sa1.next()){
	   	ex1.add();
	   for(int k=0;k<sa1.Cols;k++){
	   	ex1.set(k,sa1.value(k));

	   }
	   	ex1.commit();
	   }
	   com.etn.lang.ResultSet.ExResult ex2 = new com.etn.lang.ResultSet.ExResult(null,sa2.ColName,9,10);	//horizontal
	   while(sa2.next()){
	   	ex2.add();
	   for(int k=0;k<sa2.Cols;k++){
	   	ex2.set(k,sa2.value(k));

	   }
	   	ex2.commit();
	   }

	   ar = new com.etn.lang.ResultSet.ArraySet(ex1.getXdr());	//vertical
	   ar2 = new com.etn.lang.ResultSet.ArraySet(ex2.getXdr());	//horizontal

	   }else{
	   
	   ar = new com.etn.lang.ResultSet.ArraySet(rs);	//vertical
	   ar2 = new com.etn.lang.ResultSet.ArraySet(rs);	//horizontal
	   }
	   
	//	 buf2.append("<pre>"+new String(ar.rs.data)+"</pre><br><br>");
	//	 buf2.append("<pre>"+new String(ar2.rs.data)+"</pre>");
	   
	   String m3 [] = les_index.split(",");

	   ar.index(m3);
	   ar2.index(m3);

	   int p = ar.rs.Rows;

	   int c = vertical2.length;

	   String key="";
	   String key_code="";
	   String prev_key="";

	   java.util.HashMap h_valeurUnique = new java.util.HashMap();

	   //Parcours des valeurs horizontal
	   String h_key="";
	   String h_key_code="";

	   for(int p2 = 0; p2 < ar2.Rows ; p2++){
	   	key = "";
	   	key_code="";
	   	for(int h=0;h < horizontal2.length;h++){
	   		String s = ar2.value(p2,horizontal2[h]);
	   		if(!"".equalsIgnoreCase(horizontal2[h])){
	   		if( s!=null){
	   			key += 	(s.equals("")?valeur_vide:s) + sepa;
	   			compteValeur(h_valeurUnique,horizontal2[h],s);
	   		}
	   		}
	   	}

	   	if(! key.equalsIgnoreCase(prev_key)){
	   		prev_key = key;
	   		h_key +=key+sepa2;
	   	}
	   }

	   //Parcours des valeurs horizontal -fin

	   key="";
	   key_code="";
	   prev_key="";

	   //Parcours des valeurs vertical
	   String v_key="";
	   String v_key_code="";

	   for(int p2 = 0; p2 < ar.Rows ; p2++){
	   	key = "";
	   	key_code="";
	   	for(int v=0;v < vertical2.length;v++){
	   		String s = ar.value(p2,vertical2[v]);
	   		if(!"".equalsIgnoreCase(vertical2[v])){
	   		if( s!=null){
	   			key += (s.equalsIgnoreCase("")?valeur_vide:s)+sepa;
	   			compteValeur(h_valeurUnique,vertical2[v],s);
	   		}
	   	}
	   	}

	   	if(! key.equalsIgnoreCase(prev_key)){
	   		prev_key = key;
	   		v_key += key+sepa2;

	   	}
	   }
	   
	   
	   if(ligne.equals("") && colonne.equals("")){
		   //buf2.append("ar.Rows="+ar.Rows);
		  /* for(int p2 = 0; p2 < ar.Rows ; p2++){
			   	key = "";
			   	key_code="";
			   	for(int v=0;v < valeur2.length;v++){
			   		String s = ar.value(p2,valeur2[v]);
			   		if(!"".equalsIgnoreCase(valeur2[v])){
			   		if( s!=null){
			   			key += (s.equalsIgnoreCase("")?valeur_vide:s)+sepa;
			   			compteValeur(h_valeurUnique,valeur2[v],s);
			   		}
			   	}
			   	}

			   	if(! key.equalsIgnoreCase(prev_key)){
			   		prev_key = key;
			   		v_key += key+sepa2;

			   	}
			   }*/
			/*
		   key = "";
		   key_code="";
		   prev_key="";
		   for(int p2 = 0; p2 < ar2.Rows ; p2++){
			   	key = "";
			   	key_code="";
			   	for(int h=0;h < valeur2.length;h++){
			   		String s = ar2.value(p2,valeur2[h]);
			   		if(!"".equalsIgnoreCase(valeur2[h])){
			   		if( s!=null){
			   			key += 	(s.equals("")?valeur_vide:s) + sepa;
			   			compteValeur(h_valeurUnique,valeur2[h],s);
			   		}
			   		}
			   	}

			   	if(! key.equalsIgnoreCase(prev_key)){
			   		prev_key = key;
			   		h_key +=key+sepa2;
			   	}
			   }
		   */
	   }
	   
	   
	   /*TRIE*/
	   
	   String str_h[] = h_key.split(sepa2);
	   String str_v[] = v_key.split(sepa2);
/*
	   HashMap verifH = new HashMap();
	   HashMap verifV = new HashMap();

	   	if(!colonne.toLowerCase().startsWith("annee(psdate)") && 
	   			!colonne.toLowerCase().startsWith("mois(psdate)") &&
	   			!colonne.toLowerCase().startsWith("semaine(psdate)") &&
	   			!colonne.toLowerCase().startsWith("jour(psdate)") &&
	   			!colonne.toLowerCase().startsWith("heure(psdate)") &&
	   			!colonne.toLowerCase().startsWith("minute(psdate)")
	   	){
	     java.util.Arrays.sort(str_h, new AlphabeticComparator());
	   	}
	     
	   	if(!ligne.toLowerCase().startsWith("annee(psdate)") && 
	   			!ligne.toLowerCase().startsWith("mois(psdate)") &&
	   			!ligne.toLowerCase().startsWith("semaine(psdate)") &&
	   			!ligne.toLowerCase().startsWith("jour(psdate)") &&
	   			!ligne.toLowerCase().startsWith("heure(psdate)") &&
	   			!ligne.toLowerCase().startsWith("minute(psdate)")
	   	){
	     java.util.Arrays.sort(str_v, new AlphabeticComparator());
	   	}

	   String h_key2 = "";
	   String v_key2 = "";

	      for(int j=0;j < str_v.length;j++){
	        //    buf2.append(str_v[j]+"---->"+sepa2+"<br>");
	       //      buf2.append(str_v[j]+"-->"+verifV.get(str_v[j]+sepa2)+"<br>");
	             if( verifV.get(str_v[j]+sepa2)==null){
	             v_key2+=str_v[j]+sepa2;
	               verifV.put(str_v[j]+sepa2,"");
	             }
	     }
	    for(int j=0;j < str_h.length;j++){
	        //     buf2.append(str_h[j]+"-->"+verifH.get(str_h[j]+sepa2)+"<br>");
	             if( verifH.get(str_h[j]+sepa2)==null){
	               h_key2+=str_h[j]+sepa2;
	               verifH.put(str_h[j]+sepa2,"");
	             }
	     }

	    String str_h_new[] = h_key2.split(sepa2);
	    String str_v_new[] = v_key2.split(sepa2);

	     str_h = str_h_new;
	     str_v = str_v_new;

	     h_key = h_key2;
	     v_key = v_key2;
*/

	   /*DEBUG
	   for(int nbr= 0;nbr < rs.Cols;nbr++){
	   	//out.write(rs.ColName[nbr]+"-->"+h_valeurUnique.get(""+rs.ColName[nbr])+"<br>");
	   	if( h_valeurUnique.get(""+rs.ColName[nbr]) != null){
	   		String valColName = (String) h_valeurUnique.get(""+rs.ColName[nbr]);
	   		out.write(rs.ColName[nbr]+"-->"+valColName.split(";").length+"<br>");
	   	}
	   }*/
	   //Parcours des valeurs vertical -fin

	   /*TRIE   
	   for(int nbr= 0;nbr < rs.Cols;nbr++){
	   	//buf2.append(rs.ColName[nbr]+"-->"+h_valeurUnique.get(""+rs.ColName[nbr])+"<br>");
	   	if( h_valeurUnique.get(""+rs.ColName[nbr]) != null){
	   		String valColName[] = ((String) h_valeurUnique.get(""+rs.ColName[nbr])).split(";");
	   	//	out.write(rs.ColName[nbr]+"-->"+valColName.split(";").length+"<br>");
	   		//buf2.append(rs.ColName[nbr]+"<br>");
	   		 java.util.Arrays.sort(valColName, new AlphabeticComparator());
	   		 
	   		 String str="";
	   		for(int i=0;i< valColName.length ; i++){
	   		 	  	str+= valColName[i] +";";
	   		}
	   		h_valeurUnique.put(rs.ColName[nbr],str);
	   	}
	   }
	   */
	   
	   //Parcours horizontal-vertical
	//   String str_h[] = h_key.split(sepa2);
	//   String str_v[] = v_key.split(sepa2);

	   /* DEBUG
	   buf2.append("h_key="+h_key.replaceAll(sepa2,"<br>")+"<br>");
	   buf2.append("v_key="+v_key.replaceAll(sepa2,"<br>")+"<br>");
	   buf2.append("horizontal : <br>");
	   for(int j=0;j < str_h.length;j++){
		   buf2.append(str_h[j]+"<br>");
	   }
	   buf2.append("<br>");
	   buf2.append("vertical : <br>");
	   for(int j2=0;j2 < str_v.length;j2++){
		   buf2.append(str_v[j2]+"<br>");
	   }
	   DEBUG*/

	   int h0 = vertical2.length;
	   
	  /*******************************************************************	TABLEAU LIGNE	*********************************************************************/
	   if( aff_valeur.equals("1")){

			//out.println("<br><table id='tableau' cellspacing='0' align='center' cellpadding='3' border='0'><tr><td class='td1' colspan='"+(h0+1)+"'>&nbsp;</td>");
			 buf.append("<br><table id='tableau' cellspacing='0' cellpadding='2' border='0'><tr><td  colspan='"+(h0+1)+"' class='h'>&nbsp;</td>");

			//LES CHAMPS AGREGATION HORIZONTALE
			for(int j=0;j < str_h.length;j++){
				 buf.append("<td align='center' class='h'>"+ colonne.replaceAll(",","&nbsp;") +"</td>");
			}
			buf.append("</tr>");
			//LES VALEURS DES CHAMPS AGREGATION HORIZONTALE

			buf.append("<tr>");

			//LES CHAMPS AGREGATION VERTICALE
			for(int z=0;z < vertical2.length;z++){
				buf.append("<td class='h'>"+libelle_msg(Etn,req,vertical2[z])+"</td>");
			}
			buf.append("<td class='h'>"+libelle_msg(Etn,req,"Données")+"</td>");
			for(int j=0;j < str_h.length;j++){
				buf.append("<td align='center' class='h'>&nbsp;"+ str_h[j].replaceAll(sepa,"<br>") +"</td>");

			}
			buf.append("</tr>");

			//LES VALEURS DES CHAMPS AGREGATION VERTICALE
			/*for(int j=0;j < str_h.length;j++){
				for(int j3=0;j3 < valeur2.length;j3++){
					buf.append("<td width='"+(100/valeur2.length)+"%' class='h2'>"+ valeur2[j3] +"</td>");
				}
			}*/
			buf.append("</tr>");

			//LES VALEURS
			for(int j2=0;j2 < str_v.length;j2++){

			for(int j3=(rs.Cols-valeur2.length);j3 < rs.Cols;j3++){


				String val = str_v[j2];

				if(! val.equals("")){
					val = val.substring(0,val.lastIndexOf(sepa));
				}

				buf.append("<tr><td class='v'>"+val.replaceAll(sepa,"</td><td class='v'>").replaceAll(valeur_vide,"&nbsp;")+"</td>");
				buf.append("<td width='"+(100/valeur2.length)+"%' class='d'>"+ libelle_msg(Etn,req,rs.ColName[j3]) +"</td>");//nowrap='nowrap'
				for(int j=0;j < str_h.length;j++){
				 java.util.regex.Pattern modele = java.util.regex.Pattern.compile(sepa);
					String u4 = str_h[j] + str_v[j2];

					String u2[] = modele.split(u4);
					for(int u3=0; u3 < u2.length;u3++){
						if (u2[u3].equals(valeur_vide)) u2[u3]="";
					}

					int u = ar.getRow(u2);

						String str = ar.value(u,j3);
						if( str == null){
							buf.append("<td>--</td>");
						}else{
							 str = str.replaceAll("\\.",",");
							 buf.append("<td>"+str+"</td>");
						}

				}
				buf.append("</tr>");
				}
			}
			buf.append("</table>");
			/*******************************************************************	TABLEAU LIGNE	*********************************************************************/
		}else{
			/*******************************************************************	TABLEAU COLONNE	*********************************************************************/
		
		if( aff_valeur.equals("2")){
		buf.append("<br><table id='tableau' cellspacing='0' cellpadding='2' border='0'><tr><td colspan='"+h0+"' style='border:1px solid white;'>&nbsp;</td>");

		//LES CHAMPS AGREGATION HORIZONTALE
		for(int j=0;j < str_h.length;j++){
			buf.append("<th colspan='"+valeur2.length+"'  class='h'>"+ colonne.replaceAll(","," ") +"</td>");
			//out.print("<th colspan='"+valeur2.length+"'  class='h'>"+ horizontal.replaceAll(",","&nbsp;") +"</td>");
		}
		//LES VALEURS DES CHAMPS AGREGATION HORIZONTALE
		buf.append("</tr><tr><td  colspan='"+h0+"' style='border:1px solid white;'>&nbsp;</td>");
		for(int j=0;j < str_h.length;j++){
			buf.append("<th colspan='"+valeur2.length+"'  class='h'>&nbsp;"+ str_h[j].replaceAll(sepa,"<br>") +"</td>");

		}
		buf.append("</tr>");




		buf.append("<tr>");
		//buf.append("<td class='td1a' colspan='"+h0+"'>&nbsp;</td>");

		//LES CHAMPS AGREGATION VERTICALE
		for(int z=0;z < vertical2.length;z++){
			buf.append("<td class='h2'>"+vertical2[z]+"</td>");
		}

		//LES VALEURS DES CHAMPS AGREGATION VERTICALE
		for(int j=0;j < str_h.length;j++){
			for(int j3=0;j3 < valeur2.length;j3++){
				buf.append("<td width='"+(100/valeur2.length)+"%' class='h2'>"+ valeur2[j3] +"</td>");
			}
		}
		buf.append("</tr>");

		int b = rs.Cols-valeur2.length ;
		/*out.write("rs.Cols="+rs.Cols+"<br>");
		out.write("cpt_code="+cpt_code+"<br>");
		out.write("valeur2.length="+valeur2.length+"<br>");
		out.write("(v_key_code.equals()&&v_key_code.equals())="+(v_key_code.equals("")&&v_key_code.equals(""))+"<br>");
		*/

		//LES VALEURS
		for(int j2=0;j2 < str_v.length;j2++){

			//out.write("str_v["+j2+"]="+str_v[j2]+"<br>");

			String val = str_v[j2];
			if(! val.equals("")){
				val = val.substring(0,val.lastIndexOf(sepa));
			}
			//.substring(0,val.lastIndexOf(sepa))

			buf.append("<tr>");


			buf.append("<td class='v'>"+val.replaceAll(sepa,"</td><td class='v'>").replaceAll(valeur_vide,"&nbsp;")+"</td>");
			for(int j=0;j < str_h.length;j++){
				java.util.regex.Pattern modele = java.util.regex.Pattern.compile(sepa);
				String u4 = str_h[j] + str_v[j2];
				//out.write("--->"+u4+"<---<br>");

				String u2[] = modele.split( u4  );
				/*buf.append("<td>");*/
				for(int u3=0; u3 < u2.length;u3++){
					if (u2[u3].equals(valeur_vide)) u2[u3]="";
				//	out.write("->"+u2[u3]+"");
				}
				/*buf.append("</td>");*/
				int u = ar.getRow( u2  );
				//if ((str_h[j] + sepa + str_v[j2]).split(sepa).length==3) throw new Exception ("3 filtres");
				//u = ar.getRow( new String[]{"URM DONGES","ALCATEL","1800",""}  );
				//out.write(u4+"-->u="+u+"-->"+ar.value(u,2)+"-->"+ar.value(u,"-110+(SUM(CELL_1624_0_CUM))/(SUM(CELL_1600_0_CUM)/480+SUM(CELL_1603_0_CUM)/470)"));

				for(int j3=b;j3 < rs.Cols;j3++){
					String str = ar.value(u,j3);
					if( str == null){
						buf.append("<td>--</td>");
					}else{
						 str = str.replaceAll("\\.",",");
						 str = typeValeur2(str,typeValeur,j3,rs);
						 
						 buf.append("<td>"+str+"</td>");

					}
				}


			}
			buf.append("</tr>");
		}
		buf.append("</table>");
		/*******************************************************************	TABLEAU COLONNE	*********************************************************************/
		}else{
			//tableau ligne bis
			if( aff_valeur.equals("3")){
				
			
			int cpt_ligne =1;
			int cpt_col =1;

			//compte le nombre de ligne total
			for(int v=0;v< vertical2.length;v++){
				cpt_ligne*= retourneValeur2(h_valeurUnique,vertical2,v);
			}
			//compte le nombre de colonne total
			for(int h=0;h< horizontal2.length;h++){
				cpt_col*= retourneValeur2(h_valeurUnique,horizontal2,h);
			}

			//compte le nombre de ligne total
			cpt_ligne *= valeur2.length;


			String  v2a="";
			for(int v=vertical2.length-1;v>=1;v--){ // vertical2.length-1 : on decale le rowspan
				v2a += ","+ retourneValeur2(h_valeurUnique,vertical2,v);
			}

			v2a = v2a+",1";	// dernière valeur : pas besoin de rowspan
			if( v2a.charAt(0)==','){
				v2a = v2a.substring(1);
			}


			/*Création des rowspans*/
			String  v2b="";
			String rowSpan[] = v2a.split(",");
			int v_debut = 0;
			//int v_fin = 0;
			for(int v=0;v<rowSpan.length;v++){
				if(v==0){
					v_debut = cpt_ligne/retourneValeur2(h_valeurUnique,vertical2,v);
				}else{
					v_debut = v_debut/retourneValeur2(h_valeurUnique,vertical2,v);
				}
				v2b += "," + v_debut;
				//v_fin = v_debut;
			}

			if( v2b.charAt(0)==','){
				v2b = v2b.substring(1);
			}
			/*Création des rowspans*/

			/*Création des colspan*/

			String h2b="";
			int h_debut = 0;
			//int h_fin = 0;
			for(int h=0;h<horizontal2.length;h++){
				if(h==0){
					h_debut = cpt_col/retourneValeur2(h_valeurUnique,horizontal2,h);
				}else{
					h_debut = h_debut/retourneValeur2(h_valeurUnique,horizontal2,h);
				}
				h2b += "," + h_debut;
				//h_fin = h_debut;
			}

			if( h2b.charAt(0)==','){
				h2b = h2b.substring(1);
			}
			/*Création des colspan*/

//		      Creation des valeurs de colonnes possibles  à vide



		int max_h = 1;
		  for(int h=0;h<horizontal2.length;h++){
		  max_h*=	retourneValeur2(h_valeurUnique,horizontal2,h);
		 }
		 //out.write("max_h="+max_h);
		String tab_h[] = new String[max_h*2];

		for(int max_h2=0;max_h2<max_h;max_h2++){
		  tab_h[max_h2] = "";
		}

		int cpt_h=0;
		int multipli_h=1;
		int pred_multi_h=1;
		int left_multi_h=max_h;
		  for(int h=0;h<horizontal2.length;h++){
				    cpt_h=0;
						multipli_h= retourneValeur2(h_valeurUnique,horizontal2,h);
						pred_multi_h=pred_multi_h*multipli_h;

					for(int i10=0; i10 < max_h /  left_multi_h ;i10++){
						for(int j10=0; j10 < multipli_h ;j10++) {
							for (int k=0;k<  max_h / pred_multi_h;k++){
		         		//tab_h[ cpt_h  ] +=(tab_h[ cpt_h  ].equals("")?"":sepa)+ retourneValeur4(h_valeurUnique,horizontal2,h,null,j10);
		         		tab_h[ cpt_h  ] +=retourneValeur4(h_valeurUnique,horizontal2,h,null,j10) + sepa;
					   		cpt_h++;
		       		}
				}

		     }
			 left_multi_h=left_multi_h/ retourneValeur2(h_valeurUnique,horizontal2,h);
		  }
		/*buf.append("<br><table border=1>");

		  for(int max_h2=0;max_h2<max_h;max_h2++){
				buf.append("<tr><td>"+max_h2+"</td><td>"+tab_h[max_h2]+"</td></tr>");

		  }
		  buf.append("</table><br>");
		*/
		// on expand les colonnes aux valeurs possibles;
		str_h=tab_h;


		// fin de   Creation des valeurs de colonnes possibles  à vide


		//Creation des valeurs de  lignes  à vide

		int max_v = 1;
		for(int v=0;v<vertical2.length;v++){
		max_v*=	retourneValeur2(h_valeurUnique,vertical2,v);
		}
		//out.write("max_v="+max_v);
		String tab_v[] = new String[max_v*2];

		for(int max_v2=0;max_v2<max_v;max_v2++){
		tab_v[max_v2] = "";
		}

		int cpt_v=0;
		int multipli_v=1;
		int pred_multi_v=1;
		int left_multi_v=max_v;
		for(int v=0;v<vertical2.length;v++){
			    cpt_v=0;
					multipli_v= retourneValeur2(h_valeurUnique,vertical2,v);
					pred_multi_v=pred_multi_v*multipli_v;

				for(int i10=0; i10 < max_v /  left_multi_v ;i10++){
					for(int j10=0; j10 < multipli_v ;j10++) {
						for (int k=0;k<  max_v / pred_multi_v;k++){
		     		//tab_h[ cpt_h  ] +=(tab_h[ cpt_h  ].equals("")?"":sepa)+ retourneValeur4(h_valeurUnique,horizontal2,h,null,j10);
		     		tab_v[ cpt_v  ] +=retourneValeur4(h_valeurUnique,vertical2,v,null,j10) + sepa;
				   		cpt_v++;
		   		}
			}

		 }
		 left_multi_v=left_multi_v/ retourneValeur2(h_valeurUnique,vertical2,v);
		}
		/*buf.append("<br><table border=1>");

		for(int max_v2=0;max_v2<max_v;max_v2++){
			buf.append("<tr><td>"+max_v2+"</td><td>"+tab_v[max_v2]+"</td></tr>");

		}
		buf.append("</table><br>");
		*/

		//on expand les colonnes aux valeurs possibles;
		str_v=tab_v;



		//fin de   Creation des valeurs de lignes possibles  à vide


		String rowSpan2[] = v2b.split(",");
		String colSpan2[] = h2b.split(",");
		
	/*	out.println("<br>v2a="+v2a+"<br>");
		out.println("<br>v2b="+v2b+"<br>");
		out.println("<br>h2b="+h2b+"<br>");
	*/


		buf.append("<br><table id='tableau' cellspacing='0' tableau='1' cellpadding='2' border='0'>");

		//affichage des colonnes
		int prec_c = 1;
		int col1 = 0;
		for(int i5=0;i5< horizontal2.length;i5++){
			buf.append("<tr>");
			if( col1==(horizontal2.length-1)){
				for(int v=0;v< vertical2.length;v++){
					buf.append("<td class='vtop'>"+libelle_msg(Etn,req,vertical2[v])+"</td>");
				}
				buf.append("<td class='vtop'>"+libelle_msg(Etn,req,"Données")+"</td>");
			}else{
				buf.append("<td  class='h' colspan='"+(vertical2.length+1)+"'>&nbsp;</td>");
			}

			String ligne1[] = ((String) h_valeurUnique.get(""+horizontal2[i5])).split(";");

			for(int i6=0;i6<prec_c;i6++){
					for(int l=0;l<ligne1.length;l++){
						buf.append("<td class='h' "+(colSpan2[i5].equals("1")?"":"colspan='"+colSpan2[i5]+"'")+">"+ligne1[l]+"</td>");
				}
			}
			
			if( options.get("affiche_total_ligne")!=null){
				if( options.get("affiche_total_ligne").equals("1")){
			
					if(i5==0){
						buf.append("<td rowspan='"+horizontal2.length+"' class='total'>"+libelle_msg(Etn,req,"Total")+"</td>");//total
					}
			
				}
			}
			
			buf.append("</tr>");
			prec_c *= ligne1.length;
			col1++;
		}
		//affichage des colonnes

		//création du tableau
		String nbr_ligne[] = new String[cpt_ligne];
		for(int li=0;li<nbr_ligne.length;li++){
			nbr_ligne[li]="";
		}

		int ligne_old = 1;
		int ligne_old2 = 1;
		/*Parcours des lignes **/
		for(int i5=0;i5< vertical2.length;i5++){
					//si un seul nom de colonne
					if( vertical2.length==1){
						String ligne2[] = ((String) h_valeurUnique.get(""+vertical2[i5])).split(";");
						ligne_old = (i5==0?1:ligne2.length);
						int i_old = 0;
						for(int l=0;l<ligne2.length;l++){
							int i7=Integer.parseInt(rowSpan2[i5],10);
							nbr_ligne[l*i7] =  nbr_ligne[l*i7] + "<th class='v' rowspan='"+rowSpan2[i5]+"'>"+ligne2[l]+"</th>";
						}

					}else{
						//si plusieurs colonne ligne
						String ligne2[] = ((String) h_valeurUnique.get(""+vertical2[i5])).split(";");		//tableau de valeurs
						String ligne2a[] = ((String) h_valeurUnique.get(""+vertical2[i5])).split(";");		//tableau de valeurs
						String ligne2_i = ((String) h_valeurUnique.get(""+vertical2[i5]));					//les valeurs
						String ligne3="";

						ligne_old = (i5==0?ligne2.length:ligne_old2);

						//mutilplier autant de fois chaques colonnes
						for(int l2=0;l2<ligne_old;l2++){
							if( i5 == 0 ){
								ligne3 = ligne2_i;
							}else{
								ligne3 += ligne2_i;
							}


						}
						ligne2 = ligne3.split(";");
						int nbr4 = ligne2.length;

						//si première colonne
						if( ligne2.length == ligne2a.length){
							int i7=Integer.parseInt(rowSpan2[i5],10);
							for(int l=0;l<ligne2.length;l++){
								nbr_ligne[l*i7] =  nbr_ligne[l*i7] + "<th class='v' rowspan='"+rowSpan2[i5]+"'>"+ligne2[l]+"</th>";
							}
						}else{
							if( ligne2.length > ligne2a.length){
								int i7=Integer.parseInt(rowSpan2[i5],10);
								int y = 0;

								for(int l=0;l< ligne2.length;l++){
									nbr_ligne[y*i7] =  nbr_ligne[y*i7] + "<th class='v' rowspan='"+rowSpan2[i5]+"'>"+(i5==0?ligne2a[y]:ligne2[y])+"</th>";
									y++;
								}
								y=0;
							}
							}
						ligne_old = 1;
						ligne_old2 = ligne2.length;
						}
					}
		/*Parcours des lignes **/

		int cpt_ligne3 = 0;

		//LES VALEURS

		for(int j2=0;j2 < max_v;j2++){
			for(int j3=(rs.Cols-valeur2.length);j3 < rs.Cols;j3++){
				nbr_ligne[cpt_ligne3] = nbr_ligne[cpt_ligne3] + "<td class='d' >"+libelle_msg(Etn,req,rs.ColName[j3])+"</td>";	//Données : affichage compteur ou KPI

				String val = str_v[j2];

				if(! val.equals("")){
					val = val.substring(0,val.lastIndexOf(sepa));
				}
				for(int j=0;j < max_h;j++){
					java.util.regex.Pattern modele = java.util.regex.Pattern.compile(sepa);
					String u4 = str_h[j] + str_v[j2];
					
					//buf2.append(u4+"<br>");
					
					String u2[] = modele.split(u4);
					for(int u3=0; u3 < u2.length;u3++){
						if (u2[u3].equals(valeur_vide)) u2[u3]="";
					}

					int u = ar.getRow(u2);
						String str = ar.value(u,j3);
						if( str == null){
							nbr_ligne[cpt_ligne3] = nbr_ligne[cpt_ligne3] + "<td class='c2'>--</td>";			//les valeurs
						}else{ 
							 //str = str.replaceAll("\\.",",");
							 String str2 = typeValeur2(str,typeValeur,j3,rs);
							 nbr_ligne[cpt_ligne3] = nbr_ligne[cpt_ligne3] + "<td class='c1'>"+str2+"</td>";	//les valeurs
						}
				}
				
				
				if( options.get("affiche_total_ligne")!=null){
					if( options.get("affiche_total_ligne").equals("1")){
				
						String total1 = ( total.get(""+str_v[j2]+rs.ColName[j3].trim())==null?"":""+total.get(""+str_v[j2]+rs.ColName[j3].trim()));
						String typ1 = (typeValeur.get(""+rs.ColName[j3].trim())==null?"":""+typeValeur.get(""+rs.ColName[j3].trim()));
						String typ1a = (typeValeur.get(""+rs.ColName[j3].trim()+"_format")==null?"":""+typeValeur.get(""+rs.ColName[j3].trim()+"_format"));
						
						if( typ1a.equals("")){
							if( typ1.equals("ratio") ){
								//buf2.append( total1 + "("+rs.ColName[j3].trim()+")====>" + nbr_key.get(""+rs.ColName[j3].trim())+"<br>");
								total1 = calcul2(total1,(nbr_key.get(""+str_v[j2]+rs.ColName[j3].trim())==null?"":""+nbr_key.get(""+str_v[j2]+rs.ColName[j3].trim())));
							}
							//buf.append("'"+str_v[j2]+rs.ColName[j3].trim()+"'<br>");
							//nbr_ligne[cpt_ligne3] = nbr_ligne[cpt_ligne3] + "<td class='total'>"+aff_valeur_numeric(total1)+""+(typ1.equals("ratio")?"%":"")+"</td>";
							nbr_ligne[cpt_ligne3] = nbr_ligne[cpt_ligne3] + "<td class='total'>"+(typ1.equals("ratio")?aff_valeur_numeric(total1):total1)+""+(typ1.equals("ratio")?"%":"")+"</td>";
						}else{
							String total_l = typeValeur2(total1,typeValeur,j3,rs);
							nbr_ligne[cpt_ligne3] = nbr_ligne[cpt_ligne3] + "<td class='total'>"+total_l+"</td>";
						}
					
					}
				}
				
				cpt_ligne3++;
				}
			
			}

		for(int li=0;li<nbr_ligne.length;li++){
			buf.append("<tr>"+nbr_ligne[li]+"</tr>");
		}
		
/*********************************************************************	TOTAL COLONNE	***************************************************************/

if( options.get("affiche_total_colonne")!=null){
					if( options.get("affiche_total_colonne").equals("1")){		

		for(int j3=(rs.Cols-valeur2.length);j3 < rs.Cols;j3++){
			buf.append("<tr><td class='totalbot' >"+libelle_msg(Etn,req,"Total")+"</td><td class='totalbot' >"+libelle_msg(Etn,req,rs.ColName[j3])+"</td>");//nowrap='nowrap'
			
			for(int j=0;j < max_h;j++){
						String total2a = (total2.get( str_h[j] +rs.ColName[j3].trim())==null?"":""+total2.get( str_h[j] +rs.ColName[j3].trim()));
						String typ2 = (typeValeur.get(""+rs.ColName[j3].trim())==null?"":""+typeValeur.get(""+rs.ColName[j3].trim()));
						String typ2a = (typeValeur.get(""+rs.ColName[j3].trim()+"_format")==null?"":""+typeValeur.get(""+rs.ColName[j3].trim()+"_format"));
						
						if( typ2a.equals("")){
							if( typ2.equals("ratio") ){
								total2a = calcul2(total2a,(nbr_key2.get(""+str_h[j]+rs.ColName[j3].trim())==null?"":""+nbr_key2.get(""+str_h[j]+rs.ColName[j3].trim())));
							}
							buf.append("<td class='totalbot'>"+(typ2.equals("ratio")?aff_valeur_numeric(total2a):total2a)+""+(typ2.equals("ratio")?"%":"")+"</td>");
						}else{
							String total_c = typeValeur2(total2a,typeValeur,j3,rs);
							buf.append("<td class='totalbot'>"+total_c+"</td>");
						}
							
			//			buf2.append( str_h[j] +rs.ColName[j3] + "<br>");
				}
			buf.append("<td class=totalbot>"+totaux.get("totaux_"+rs.ColName[j3].trim())+"</td></tr>");
			}
		/*********************************************************************	TOTAL COLONNE	***************************************************************/
	}
}				
		
		
		buf.append("</table>");
		buf.append("<br><br>");

		}else{
			//tableau ligne 3 
			
			//buf2.append("aff_valeur="+aff_valeur+"<br>");
			if( aff_valeur.equals("0") || aff_valeur.equals("4")  ){
			
			/*if(! h_key.equals("")){
				h_key = h_key.substring(0,h_key.length());
			}
			if(! v_key.equals("")){
				v_key = v_key.substring(0,v_key.length());
			}*/
			
			String str_h3[] = h_key.split(sepa2);
			String str_v3[] = v_key.split(sepa2);
		   
			//System.out.println("h_key==>"+h_key+"\n");
			//System.out.println("v_key==>"+v_key+"\n");
			
			
			/*******************************************	CREATION DES RESULTSET	*************************************/
		   	com.etn.lang.ResultSet.ExResult ex3 = new com.etn.lang.ResultSet.ExResult(null,horizontal2,9,10);	//horizontal
		   	for(int j=0;j < str_h3.length;j++){
		   		ex3.add();
		   		String str_h2[] = str_h3[j].split(sepa);
		   			for(int k=0;k<str_h2.length;k++){
		   				ex3.set(k,str_h2[k]);
		 			}
		   		ex3.commit();
		   }
		   com.etn.lang.ResultSet.ExResult ex4 = new com.etn.lang.ResultSet.ExResult(null,vertical2,9,10);	//vertical
		   for(int j2=0;j2 < str_v3.length;j2++){
		   		ex4.add();
				String str_v2[] = str_v3[j2].split(sepa);  
		   			for(int k=0;k<str_v2.length;k++){
		   				ex4.set(k,str_v2[k]);
		   			}
		   		ex4.commit();
		   }

		   
		
		   
			com.etn.lang.ResultSet.ArraySet arH = new com.etn.lang.ResultSet.ArraySet(ex3.getXdr());	//horizontal
			com.etn.lang.ResultSet.ArraySet arV = new com.etn.lang.ResultSet.ArraySet(ex4.getXdr());	//vertical
	
			/*******************************************	CREATION DES RESULTSET	*************************************/
			
			
			/**********************************************	Calcul des rowspan	*****************************************/
			arV.moveFirst();
		   	String prec= "";
		   	HashMap rowspan = new HashMap();
			for(int k=0;k<vertical2.length;k++){
				int y = 0;
				prec= "";
			   	prec= ""+arV.value(vertical2[k]);
			   	concat_valeur_distinct(rowspan,vertical2[k],""+y,sepa3);
			//	buf2.append("V1 :"+y+")"+arV.value(vertical2[k])+"<br>");
				y = y + 1;
				
				arV.moveFirst();
				while(arV.next()){
					if(!prec.equalsIgnoreCase(arV.value(vertical2[k]))){
						concat_valeur_distinct(rowspan,vertical2[k],""+y,sepa3);
					}else{
						if( th_present(vertical2,k,y,rowspan,sepa3)==0){
							concat_valeur_distinct(rowspan,vertical2[k],""+y,sepa3);
						}
					}
		//			buf2.append("V2 :"+y+")"+arV.value(vertical2[k])+"<br>");
					prec = arV.value(vertical2[k]);
					y = y + 1;
				}  
				arV.moveFirst();
			}
				
			arH.moveFirst();
			/**********************************************	Calcul des rowspan	*****************************************/
			
			/**********************************************	Calcul des colspan	*****************************************/
				prec= "";
				HashMap colspan = new HashMap();
				for(int k=0;k<horizontal2.length;k++){
					int y = 0;
					prec= "";
					prec= ""+arH.value(horizontal2[k]);
				   	concat_valeur_distinct(colspan,horizontal2[k],""+y,sepa3);
			//		buf2.append("H1 :"+y+")"+arH.value(horizontal2[k])+"<br>");
					arH.moveFirst();
					y++;
					while(arH.next()){
						if(!prec.equalsIgnoreCase(arH.value(horizontal2[k]))){
							concat_valeur_distinct(colspan,horizontal2[k],""+y,sepa3);
						}else{
							if( th_present(horizontal2,k,y,colspan,sepa3)==0){
								concat_valeur_distinct(colspan,horizontal2[k],""+y,sepa3);
							}
						}
			//			buf2.append("H2 :"+y+")"+arH.value(horizontal2[k])+"<br>");
						prec = arH.value(horizontal2[k]);
						y++;
					}
					arH.moveFirst();
				}
				/**********************************************	Calcul des colspan	*****************************************/
			   
				/*			 DEBUG
				buf2.append("<br>");
				buf2.append("<br>");
				
				buf2.append("COLSPAN : <br>");
				String liste[] = liste_hashMap(colspan,sepa3).split(sepa3);
				for(int l=0;l<liste.length;l++){
					buf2.append("key : " + liste[l] + "===>" + getValHashMap(colspan,liste[l]));
					buf2.append("<br>");
				}
				
				buf2.append("ROWSPAN : <br>");
				String liste2[] = liste_hashMap(rowspan,sepa3).split(sepa3);
				for(int l=0;l<liste2.length;l++){
					buf2.append("key : " + liste2[l] + "===>" + getValHashMap(rowspan,liste2[l]));
					buf2.append("<br>");
				}
				*/		
				
				ar.moveFirst();
				
				//buf2.append(arV.Rows+"valeur2.length="+valeur2.length);
				
				//création du tableau
				String[] tab = new String[(arV.Rows*valeur2.length)];
				if(ligne.equals("") && colonne.equals("")){	
					tab = new String[rs.rs.Rows];
				}
				
				for(int ii=0;ii<tab.length;ii++){
					tab[ii] = "";
				}
				for(int k=0;k<vertical2.length;k++){
					String col_tab[] = getValHashMap(rowspan,vertical2[k]).split(sepa3);
					for(int i=0;i<col_tab.length;i++){
					if(!(""+diff_between_th(i,col_tab)).equals("-1")){
						tab[Integer.parseInt(col_tab[i],10)*valeur2.length] += "<th class='v' rowspan='"+(diff_between_th(i,col_tab)*valeur2.length)+"'>"+arV.value(Integer.parseInt(col_tab[i],10),vertical2[k])+"</th>";
					}
					}
				}
				buf2.append("<br>");
			
				buf.append("<table id='tableau' cellspacing='0' tableau='1' cellpadding='2' border='0'>");
				
				
				if(!ligne.equals("") || !colonne.equals("")){	
				//buf.append("<tr><td colspan='"+vertical2.length+"'></td>");
				buf.append("<tr>");
				for(int v=0;v< vertical2.length;v++){
					buf.append("<td class='vtop' rowspan='"+horizontal2.length+"'>"+libelle_msg(Etn,req,vertical2[v])+"</td>");
				}	
				buf.append("<td class='vtop' rowspan='"+horizontal2.length+"' valign='center'>"+libelle_msg(Etn,req,"Données")+"</td>");
				if(colonne.equals("") && !ligne.equals("")){
					buf.append("<td class='vtop' rowspan='"+horizontal2.length+"' valign='center'>"+libelle_msg(Etn,req,"Valeurs")+"</td>");
				}
				
				//buf.append("colonne="+colonne);
				
				for(int k=0;k<horizontal2.length;k++){
				/*	if( k>0){
						buf.append("<tr><td colspan='"+(vertical2.length)+"'></td>");
					}*/
					String col_tab[] = getValHashMap(colspan,horizontal2[k]).split(sepa3);
					for(int i=0;i<col_tab.length;i++){
						if(!(""+diff_between_th(i,col_tab)).equals("-1")){
							buf.append("<td class='vtop' colspan='"+diff_between_th(i,col_tab)+"'>"+arH.value(Integer.parseInt(col_tab[i],10),horizontal2[k])+"</td>");
						}
					}
					if( options.get("affiche_total_ligne")!=null){
						if( options.get("affiche_total_ligne").equals("1")){
					
							if(k==0){
								buf.append("<td rowspan='"+horizontal2.length+"' class='total'>"+libelle_msg(Etn,req,"Total")+"</td>");//total
							}
					
						}
					}
					buf.append("</tr>");
				}
				}
				
				int cpt_ligne3 = 0;
				String key_v = "";
				String key_h = "";
				
				if(ligne.equals("") && colonne.equals("")){	
					
					   for( int i = 0 ; i < rs.Cols ; i++ ){
					 	   buf.append("<th class='vtop'>"+ libelle_msg(Etn,req,rs.ColName[i])+"</th>" );
					   }
					   buf.append("</tr>");
					   while( rs.next() )
					   {
						
						 int nbrCol = rs.Cols;
					     for( int i = 0 ; i < nbrCol ; i++ ){
						String j= rs.value(i);
				        if(j==null){
					    	tab[cpt_ligne3] = tab[cpt_ligne3] + "<td class='c2'>--</td>";
						}else{
							tab[cpt_ligne3] = tab[cpt_ligne3] + "<td class='c1'>"+("".equals(j)?"--":typeValeur2(j,typeValeur,i,rs) )+"</td>";
						}
					     }
					     cpt_ligne3++;
					   }
					
				}else{	
					
				for(int j2=0;j2 < str_v3.length;j2++){
					for(int j3=rs.Cols-valeur2.length;j3 < rs.Cols;j3++){
						
						if(ligne.equals("")){
							tab[cpt_ligne3] = tab[cpt_ligne3] + "<td class='d' >&nbsp;</td>";
						}
						tab[cpt_ligne3] = tab[cpt_ligne3] + "<td class='d' >"+libelle_msg(Etn,req,rs.ColName[j3])+"</td>";	//Données : affichage compteur ou KPI
																													//nowrap='nowrap'
						           
												
						for(int j=0;j < str_h3.length;j++){
							java.util.regex.Pattern modele = java.util.regex.Pattern.compile(sepa);
							String u4 = str_h3[j] + str_v3[j2];
							
							//buf2.append(u4+"<br>");
							
							String u2[] = modele.split(u4);
							for(int u3=0; u3 < u2.length;u3++){
								if (u2[u3].equals(valeur_vide)) u2[u3]="";
							}

							int u = ar.getRow(u2);
								String str = ar.value(u,j3);
								if( str == null){
									tab[cpt_ligne3] = tab[cpt_ligne3] + "<td class='c2'>--</td>";			//les valeurs
								}else{ 
									 //str = str.replaceAll("\\.",",");
									 String str2 = typeValeur2(str,typeValeur,j3,rs);
									 tab[cpt_ligne3] = tab[cpt_ligne3] + "<td class='c1'>"+str2+"</td>";	//les valeurs
								}
						}
						
						if( options.get("affiche_total_ligne")!=null){
							if( options.get("affiche_total_ligne").equals("1")){
						
								String total1 = ( total.get(""+str_v3[j2]+rs.ColName[j3].trim())==null?"":""+total.get(""+str_v3[j2]+rs.ColName[j3].trim()));
								String typ1 = (typeValeur.get(""+rs.ColName[j3].trim())==null?"":""+typeValeur.get(""+rs.ColName[j3].trim()));
								String typ1a = (typeValeur.get(""+rs.ColName[j3].trim()+"_format")==null?"":""+typeValeur.get(""+rs.ColName[j3].trim()+"_format"));
								
								
								if(ligne.equals("") && !colonne.equals("")  ){
									//buf2.append("AAAAAAA"+colonne+"<br>");
									total1 = (totaux.get("totaux_"+rs.ColName[j3].trim())==null?"":""+totaux.get("totaux_"+rs.ColName[j3].trim()));
								}
								
								if( typ1a.equals("")){
									if( typ1.equals("ratio") ){
										total1 = calcul2(total1,(nbr_key.get(""+str_v3[j2]+rs.ColName[j3].trim())==null?"":""+nbr_key.get(""+str_v3[j2]+rs.ColName[j3].trim())));
									}
									if( rs.ColName[j3].trim().startsWith("TX_") ){
										total1 = typeValeur2(total1,typeValeur,j3,rs);
									}
									tab[cpt_ligne3] = tab[cpt_ligne3] + "<td class='total'>"+(typ1.equals("ratio")?aff_valeur_numeric(total1):total1)+""+(typ1.equals("ratio")?"%":"")+"</td>";
								}else{
									String total_l = typeValeur2(total1,typeValeur,j3,rs);
									tab[cpt_ligne3] = tab[cpt_ligne3] + "<td class='total'>"+total_l+"</td>";
								}
								
							} 
						}
						cpt_ligne3++;
						}
					}
				
				}
			
				for(int i=0;i<tab.length;i++){
					buf.append("<tr>"+tab[i]+"</tr>");
				}
				
				
				if(ligne.equals("") && colonne.equals("")){	
					if( options.get("affiche_total_colonne")!=null){
						if( options.get("affiche_total_colonne").equals("1")){		
						buf.append("<tr>");	
						buf.append("<td class='totalbot' colspan='"+vertical2.length+"'>"+libelle_msg(Etn,req,"Total")+"</td>");
						for(int j=1;j < valeur2.length+1;j++){
							buf.append("<td class='totalbot'>"+totaux.get("totaux_"+rs.ColName[j].trim()) +"</td>");
							}
						}
					}
				}else{
				
				/*********************************************************************	TOTAL COLONNE	***************************************************************/

				if( options.get("affiche_total_colonne")!=null){
									if( options.get("affiche_total_colonne").equals("1")){		

						int yy=0;
						int nbr_col1=rs.Cols-valeur2.length;
						
						
						for(int j3=(nbr_col1);j3 < rs.Cols;j3++){
							buf.append("<tr>"+(yy==0?"<td class='totalbot' rowspan='"+valeur2.length+"' colspan='"+(vertical2.length)+"'>"+libelle_msg(Etn,req,"Total")+"</td>":"")+"<td class='totalbot' >"+libelle_msg(Etn,req,rs.ColName[j3])+"</td>");
							//buf2.append("str_h3.length="+str_h3.length);
							for(int j=0;j < str_h3.length;j++){
								//buf2.append("str_h3.length+rs.ColName="+str_h3[j] +rs.ColName[j3].trim());	
								
								
								String total2a = (total2.get( str_h3[j] +rs.ColName[j3].trim())==null?"":""+total2.get( str_h3[j] +rs.ColName[j3].trim()));
								
								if(!ligne.equals("") && colonne.equals("")  ){
									//buf2.append("AAAAAAA"+colonne+"<br>");
									total2a = (totaux.get("totaux_"+rs.ColName[j3].trim())==null?"":""+totaux.get("totaux_"+rs.ColName[j3].trim()));
								}
								
										String typ2 = (typeValeur.get(""+rs.ColName[j3].trim())==null?"":""+typeValeur.get(""+rs.ColName[j3].trim()));
										String typ2a = (typeValeur.get(""+rs.ColName[j3].trim()+"_format")==null?"":""+typeValeur.get(""+rs.ColName[j3].trim()+"_format"));
										
										if( typ2a.equals("")){
											if( typ2.equals("ratio") ){
												total2a = calcul2(total2a,(nbr_key2.get(""+str_h3[j]+rs.ColName[j3].trim())==null?"":""+nbr_key2.get(""+str_h3[j]+rs.ColName[j3].trim())));
											}
											if( rs.ColName[j3].trim().startsWith("TX_") ){
												total2a = typeValeur2(total2a,typeValeur,j3,rs);
											}
											buf.append("<td class='totalbot'>"+(typ2.equals("ratio")?aff_valeur_numeric(total2a):total2a)+""+(typ2.equals("ratio")?"%":"")+"</td>");
										}else{
											String total_c = typeValeur2(total2a,typeValeur,j3,rs);
											buf.append("<td class='totalbot'>"+total_c+"</td>");
										}
										
								}
							if( rs.ColName[j3].trim().startsWith("TX_")){
								buf.append("<td class=totalbot>"+Taux(""+totaux.get("totaux_"+rs.ColName[j3].trim()))+"</td></tr>");
							}else{
								buf.append("<td class=totalbot>"+totaux.get("totaux_"+rs.ColName[j3].trim())+"</td></tr>");
							}
							
							yy++;
							}
						/*********************************************************************	TOTAL COLONNE	***************************************************************/
					}
				}
				}
				buf.append("</table>");
			}//else tableau ligne 4
		} 	
	}
	}

	}else{
		buf.append("<center>"+libelle_msg(Etn,req,"Pas de résultat")+".</center>");
	}

	}


  
	return( buf2.toString() + buf.toString() );


}//nbr_case	

	}catch(Exception ee){
		System.out.println(""+getStackTraceAsString2(ee));
                ee.printStackTrace();
		return("<br><center>"+libelle_msg(Etn,req,"Erreur sur la requête")+".</center><br>");	
	}

}


	
%>

