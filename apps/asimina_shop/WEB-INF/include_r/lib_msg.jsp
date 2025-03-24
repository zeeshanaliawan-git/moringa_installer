<%!String libelle_msg(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest req,String lib){ 
String msg="";
boolean voir = false;
//Etn.execute("insert IGNORE into langue_msg(LANGUE_REF) values("+ com.etn.sql.escape.cote(lib.trim())+")");

if( Etn.lang != 0){
javax.servlet.http.HttpSession session =  req.getSession(true);
if( session.getAttribute("libelle_msg")==null){ 
	msg = (voir?"--":"")+lib;
}else{
	java.util.HashMap<String,String> h_msg = (java.util.HashMap <String,String>) session.getAttribute("libelle_msg");
	String lib2 = lib.replaceAll("[éèêë]","e").toUpperCase();
	if( h_msg.get(lib2)!=null){
		if(! h_msg.get(lib2).toString().equals("")){
			msg = h_msg.get(lib2).toString();
		}else{
			msg =  (voir?"--":"")+lib;
		}
	}else{
		msg = (voir?"--":"")+lib;
//		Etn.execute("insert IGNORE into langue_msg(LANGUE_REF) values("+ com.etn.sql.escape.cote(lib)+")");
                //Etn.execute("insert into langue_msg(LANGUE_REF) values("+ com.etn.sql.escape.cote(lib)+")");
	}
}
}else{
	msg = lib;
}
return(msg);
}%>
<%!void init_msg(javax.servlet.http.HttpServletRequest req,com.etn.beans.Contexte Etn){
	javax.servlet.http.HttpSession session =  req.getSession(true);
	
	if( Etn.lang != 0){
	
	if( session.getAttribute("libelle_msg")==null){ 
		
		com.etn.lang.ResultSet.Set rsListe = Etn.execute("select LANGUE_REF,LANGUE_"+(Etn.lang) + " as LANGUE from langue_msg");
	
		session.removeAttribute("libelle_msg");
	
		java.util.HashMap<String,String> h_msg = new java.util.HashMap<String,String>();
	
		while(rsListe.next()){
			h_msg.put(rsListe.value("LANGUE_REF").replaceAll("[éèêë]","e").toUpperCase(),rsListe.value("LANGUE"));
		}
		session.setAttribute("libelle_msg",h_msg);
	}
	}
}
%>