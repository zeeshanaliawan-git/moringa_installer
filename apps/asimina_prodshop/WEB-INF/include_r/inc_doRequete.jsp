<%@page import="com.etn.beans.Contexte"%>
<%@page import="java.io.OutputStream"%>
<%!


int ldoRequete(Contexte Etn, String liste_requete, HttpServletRequest request,int filtre ){
com.etn.lang.ResultSet.Set rs = Etn.execute("select * from requete where requete_id in ("+liste_requete+")");
String g[] = null;
while(rs.next()){
g = sql(Etn,request,rs.value("valeurs"),rs.value("filtres"),filtre,rs.value("agregations_h"),rs.value("agregations_v") ,rs.value("type_elt"));

System.out.println("début requete : "+ rs.value("requete_name") +"<br><br>");

if( g.length == 1){
	System.out.println("Erreur.");
}else{
	/**
	out.write("select : "+g[0]+"<br><br>");
	out.write("filtres : "+g[1]+"<br><br>");
	out.write("group by : "+g[2]+"<br><br>");
	**/
	com.etn.requeteur.Qry q = new com.etn.requeteur.Qry(Etn);
	java.util.HashMap h = new java.util.HashMap();
	h.put("type",""+(rs.value("type_elt").equals("")?"":rs.value("type_elt")));
	q.setMap(h);

	if( g.length == 1){

		System.out.println( AfficheErreur(q.getErr(),"2"));
		return(-1);
	}else{

			int id = q.execute( g[0],g[1],g[2] );

			if( id == 0 )
		    {
				System.out.println("************************** ERREUR ****************************************<br>");
				System.out.println(""+ q.getErr() );
				System.out.println("<br>************************** ERREUR ****************************************<br>");
		    }else{
		    	System.out.println("************************** SQL RENVOVE PAR REQUETEUR ****************************************<br>");
		    	System.out.println(""+q.getSql());
		    	System.out.println("<br>************************** SQL RENVOVE PAR REQUETEUR ****************************************<br>");

		       	int histo_err = -1;
		    	if(! "0".equals(rs.value("requete_id"))){
		    		String date_fraicheur = r_date_fraicheur(Etn,rs.value("type_elt"));
		    		h.put("date_fraicheur",date_fraicheur);
		    		histo_err = Etn.executeCmd("insert into histo_requete (requete_id, person_id,date_histo,agregations_h,agregations_v,valeurs,filtres,techno,type_elt,cache_id,date_fraicheur) values ("+rs.value("requete_id")+","+Etn.getId()+",now(),'"+Substitue.dblCote(rs.value("agregations_h"))+"','"+Substitue.dblCote(rs.value("agregations_v"))+"','"+Substitue.dblCote(rs.value("valeurs"))+"','"+Substitue.dblCote(rs.value("filtres"))+"',"+rs.value("techno")+",'"+Substitue.dblCote(rs.value("type_elt"))+"',"+id+",'"+date_fraicheur+"')");
		    	}
		    	if( histo_err > -1){
		    		System.out.println(""+Etn.getLastError());
		    	}else{
		    		System.out.println("histo requete = "+histo_err);
		    	}

		    }
	}
}

}
return(0);
}
%>