
// Reviewed By Awais 
package com.etn.requeteur;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

/**
* Source pour jdk 1.5...
* Sinon supprimer <...>
*/

import java.util.Vector;
import java.util.HashMap;


public class Variable {

String RetourneChaine_v(String tab,int n){
	String t[] = tab.split(";");
	return(t[n]);
	}

int RetourneIndex_v(String tab[],String quoi1){
	int n=-1;
	for( int t =0; t < tab.length; t++){
		if( tab[t].split(",")[0].equalsIgnoreCase(quoi1)){
			n= t;
		}
	}
	return(n);
	}

public void init_variable(javax.servlet.http.HttpServletRequest req,com.etn.beans.Contexte Etn){
	javax.servlet.http.HttpSession session =  req.getSession(true);
	if( session.getAttribute("variable")==null){ 
		
		com.etn.lang.ResultSet.Set rsListe = Etn.execute("SELECT v.variable_id,nom,valeur,description FROM variable v,variable_valeur v2 where v.variable_id = v2.variable_id and person_id="+ escape.cote(""+Etn.getId())+" union select constante_id, constante, valeur,description from constante order by 2");//change
	
		session.removeAttribute("variable");
	
		java.util.HashMap<String,String> h_variable = new java.util.HashMap<String,String>();
	
		while(rsListe.next()){
			h_variable.put("#"+rsListe.value("nom")+"#",rsListe.value("valeur"));
		}
	
		session.setAttribute("variable",h_variable);
	
	}
}

public String details_variables_f(String filtres,String liste){
	String r = "";
	System.out.println("details_variables_f="+filtres);
	String l2[] = filtres.split(";");
	String l3 = "";
	
	if(!filtres.equals("")){
	for(int i=0;i<l2.length;i++){

            System.out.println("$$ ITS INSIDE $$");

		if( l2[i].startsWith("{") && l2[i].endsWith("}") || l2[i].equalsIgnoreCase("or") ){	
			r+=l2[i];	
		}else{
			if( l2[i].indexOf(",")!=-1 ){//rajout du OR dans pas de virgule - 24/02/2012
				l3 = l2[i].split(",")[1];
				if( l3.startsWith("#") && l3.endsWith("#") ){
					r+= descVariable(liste,l3.replaceAll("#",""));
				}else{
					r+=l2[i]+";";	
				}
		
			}
		
		}
	}
	}
	return(r );
}

public String manqueVariable(javax.servlet.http.HttpServletRequest req,java.util.HashMap<String,String> h){
	System.out.println("manqueVariable");
	javax.servlet.http.HttpSession session =  req.getSession(true);
	String str_v = "";
	String filtres = "";
	String valeurs = "";
	
	if( session.getAttribute("variable")!=null){
		@SuppressWarnings("unchecked")
		java.util.HashMap<String,String> h2 = (java.util.HashMap <String,String>) session.getAttribute("variable");
	
	if( h.get("filtres")!=null){
		filtres = ""+h.get("filtres");
		
		if(!filtres.equals("")){
		
		String l2[] = filtres.split(";");
		String l3 = "";
		for(int i=0;i<l2.length;i++){
			
				if( l2[i].startsWith("{") && l2[i].endsWith("}") ){	
					//rien
				}else{
					if( l2[i].indexOf(",")!=-1 ){//rajout du OR dans pas de virgule - 24/02/2012
						l3 = l2[i].split(",")[1];
						if( l3.startsWith("#") && l3.endsWith("#") ){
							if( h2.get(l3) == null){
								System.out.println("\t"+l3.replaceAll("#",""));
								str_v += "- "+l3.replaceAll("#","")+"\n";
							}
						}	 
					}//rajout du OR dans pas de virgule - 24/02/2012
				}
			}
		}
		
	} 
	if( h.get("valeurs")!=null){
		valeurs = ""+h.get("valeurs");
		String l2[] = valeurs.split(",");
		for(int i=0;i<l2.length;i++){
			if( l2[i].startsWith("#") && l2[i].endsWith("#") ){
				if( h2.get(l2[i]) == null){
					System.out.println("\t"+l2[i].replaceAll("#",""));
					str_v += "- "+l2[i].replaceAll("#","")+"\n";
				}
			}
		}
	}
	
	}
	
	return(str_v);
}

public String verif_variable(javax.servlet.http.HttpServletRequest req,com.etn.beans.Contexte Etn){
	javax.servlet.http.HttpSession session =  req.getSession(true);
	String url_r =  com.etn.beans.app.GlobalParm.getParm("URL_REQUETEUR");
	String str_var = "";
	String r = "";
	session.removeAttribute("info_var");
	String sql_var="select distinct nom from variable,variable_valeur ";
	sql_var += " where variable.variable_id = variable_valeur.variable_id ";
	com.etn.lang.ResultSet.Set rsVar = Etn.execute(sql_var);
	
	while(rsVar.next()){
		str_var += "," + rsVar.value(0);
	}
	
	if(! str_var.equals("")){
			str_var = str_var.substring(1);
			String sql_var2 = "select concat(`variables`,' --> ',requete_name) from  requete where  (person_id = "+ escape.cote(""+Etn.getId())+" or partage = 1) and `variables`<>''";//change
			sql_var2+=" and `variables` not in('"+str_var.replaceAll(",","','")+"')";
			
			System.out.println(sql_var2);
			
			com.etn.lang.ResultSet.Set rsVar2 = Etn.execute(sql_var2);
			
			if(  rsVar2.rs.Rows > 0){
	
				String str_var2 = "";
				while(rsVar2.next()){
					str_var2 += "," + rsVar2.value(0);
				}
					
				session.setAttribute("info_var",str_var2);
				r = url_r + "admin/info.jsp";
		
			}else{
					r = "";
			}
	}else{
		r = "";
	}
	/*editing here for home_page*/
        int pId=Etn.getId();

        String que= "Select home_page from person where person_id="+ escape.cote(""+pId)+" ";//change
        com.etn.lang.ResultSet.Set rset=Etn.execute(que); //nico : add com.etn.lang.ResultSet.Set because cause pb with java.util.Set
        if(rset.next()){
            String url=rset.value("home_page");
            if(url==null || url.equals("") || url.equals(" ")){
				String que2="select home_page from profilperson JOIN profil ON profilperson.profil_id = profil.profil_id where person_id="+ escape.cote(""+pId)+" ";//change
				rset=Etn.execute(que2);
				if(rset.next()){
					r=rset.value("home_page");
				}
			}
            else{
                r=url;
			}
        }

        /*done editing*/
	return(r);
}


public String details_variables_v(String valeurs,String liste,int type){
	String r = "";
	System.out.println("details_variables_v="+valeurs);
	String l2[] = valeurs.split(",");
	for(int i=0;i<l2.length;i++){
		if( l2[i].startsWith("#") && l2[i].endsWith("#") ){
			if( type == 0){
				r+= descVariable(liste,l2[i].replaceAll("#",""));
			}else{
				r+= descVariable2(liste,l2[i].replaceAll("#",""));
			}
		
		}else{
			r+=","+l2[i]+"";	
		}
	}
	return(r);
}

public String descVariable(String liste,String var){
	String r = "";
	int f=-1;
	if(! liste.equals("")){
	f = RetourneIndex_v(liste.split(";"),var);
	//System.out.println("descVariable "+liste+" : " + var);
	if( f > -1){
		String c2[] = RetourneChaine_v(liste,f).split(",");
		for(int i3 = 1; i3 < c2.length;i3++){
			r+=","+c2[i3]+"";
		}
	}
	}
	return((r.equals("")?"":" , <b>"+var+" : </b> ("+ r + ")"));
}
public String descVariable2(String liste,String var){
	String r = "";
	int f=-1;
	if(! liste.equals("")){
	f = RetourneIndex_v(liste.split(";"),var);
	//System.out.println("descVariable2 "+liste+" : " + var + "f===>"+f);
	if( f > -1){
		String c2[] = RetourneChaine_v(liste,f).split(",");
		for(int i3 = 1; i3 < c2.length;i3++){
			r+=","+c2[i3]+"";
		}
	}
	}
	return(r);
}
public String getVariable(javax.servlet.http.HttpServletRequest req,String filtre,String valeur){ 
	javax.servlet.http.HttpSession session =  req.getSession(true);
	String r = "";
	
	session.removeAttribute("variable_filtre");
	session.removeAttribute("variable_valeur");
	session.removeAttribute("variables");
	
	liste_filtre_variable(filtre,req);
	liste_valeur_variable(valeur,req);
	
	if( session.getAttribute("les_variables")!=null){
		r = (String) session.getAttribute("les_variables");
	}
	
	session.removeAttribute("variable_filtre");
	session.removeAttribute("variable_valeur");
	session.removeAttribute("variables");
	session.removeAttribute("les_variables");
	
	return(r);
}
void concat_valeur_session(javax.servlet.http.HttpServletRequest req,String nom_var,String nom,String valeur){ 
	String r = "";
	javax.servlet.http.HttpSession session =  req.getSession(true);
	if(session.getAttribute(nom_var)==null){
		r = (nom.equals("")?"":nom + ",") + valeur +";";
	}else{
		r = (String) session.getAttribute(nom_var);
		r += (nom.equals("")?"":nom + ",") + valeur +";";
	}
	
	session.setAttribute(nom_var,r);
	System.out.println("variable "+nom_var+" : " + r);
}
void concat_valeur_session2(javax.servlet.http.HttpServletRequest req,String nom_var,String valeur){ 
	String r = "";
	javax.servlet.http.HttpSession session =  req.getSession(true);
	if(session.getAttribute(nom_var)==null){
		r = valeur;
	}else{
		r = (String) session.getAttribute(nom_var);
		r += "," + valeur;
	}
	
	session.setAttribute(nom_var,r);
	System.out.println("variable "+nom_var+" : " + r);
}
//liste les filtres 
public String liste_filtre_variable(String liste,javax.servlet.http.HttpServletRequest req){ 
	String l = "";
	javax.servlet.http.HttpSession session =  req.getSession(true);
	System.out.println("liste_filtre_variable ==>  " + liste);
	if( session.getAttribute("variable")!=null){
		@SuppressWarnings("unchecked")
		java.util.HashMap<String,String> h = (java.util.HashMap <String,String>) session.getAttribute("variable");
		
		if(!liste.equals("")){
		
		String l2[] = liste.split(";");
		String l3 = "";
		for(int i=0;i<l2.length;i++){
			System.out.println("l2["+i+"] ==>  " + l2[i]);
			if( (l2[i].startsWith("{") && l2[i].endsWith("}")) || l2[i].equalsIgnoreCase("or") ){	
				l+=l2[i]+";";	
			}else{	
				if( l2[i].indexOf(",")!=-1 ){ //rajout du OR dans pas de virgule - 24/02/2012
					l3 = l2[i].split(",")[1];
					if( l3.startsWith("#") && l3.endsWith("#") ){
						concat_valeur_session2(req,"les_variables",l3.replaceAll("#",""));
					}
					if( h.get(l3)!=null){
						l+= l2[i].split(",")[0]+","+h.get(l3)+";";
						concat_valeur_session(req,"variable_filtre",l2[i].split(",")[0],""+h.get(l3));
					}else{
						l+=l2[i]+";";	 //rajout du OR dans pas de virgule - 24/02/2012
					}
				}
		}
		}
	}else{
		l = liste;
	}
	}
	return(l);
}
//liste les valeurs 
public String liste_valeur_variable(String liste,javax.servlet.http.HttpServletRequest req){ 
	String l = "";
	javax.servlet.http.HttpSession session =  req.getSession(true);
	System.out.println("liste_valeur_variable ==>  " + liste);
	if( session.getAttribute("variable")!=null){
		@SuppressWarnings("unchecked")
		java.util.HashMap<String,String> h = (java.util.HashMap <String,String>) session.getAttribute("variable");
		
		String l2[] = liste.split(",");
			
			for(int i=0;i<l2.length;i++){
				if(! l2[i].trim().equals("")){
				if( l2[i].startsWith("#") && l2[i].endsWith("#") ){
					concat_valeur_session2(req,"les_variables",l2[i].replaceAll("#",""));
				}
				if( h.get(l2[i])!=null){
					l+=","+h.get(l2[i]);
					concat_valeur_session(req,"variable_valeur",l2[i].replaceAll("#",""),""+h.get(l2[i]));
				}else{
					l+=","+l2[i]+"";	
				}
			}
		}
	}else{
		l = liste;
	}
	return(l);
}

}