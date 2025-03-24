<%//@ include file="/WEB-INF/include_r/i_top.jsp"%>
<%@ page import="java.lang.Math"%>
<%@ page import="java.util.GregorianCalendar"%>
<%@ page import="java.util.Calendar"%>
<%@ page import="com.etn.util.ItsDate"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>

 
<%@ include file="/WEB-INF/include_r/modifRs.jsp"%>


<%!int droit(javax.servlet.http.HttpServletRequest req,String tab2){ 
	int i3=0;
	String tab[] = tab2.split(",");
	
	
	javax.servlet.http.HttpSession session =  req.getSession(true);
	if( session.getAttribute("str_droit")==null){ 
		return(-2);
	}else{
		
		for(int i2 = 0;i2<tab.length;i2++){
			if( tab[i2].equals("all") ) {
				return(1);
			}
		}
		
		//System.out.println("aaa="+(""+session.getAttribute("str_droit")));
		String d[] = (""+session.getAttribute("str_droit")).split(",");
		for(int i = 0;i<d.length;i++){
			for(int i2 = 0;i2<tab.length;i2++){
				//System.out.println(d[i]+"==="+tab[i2]);
				if( d[i].equalsIgnoreCase(tab[i2]) ){
					return(0);
				}
			}
		}
	}
	return(-1);
}%>

<%!String TriColonne(String la_colonne_a_trier,String ord,String col,String f,String p){ 
	return("ReSort('"+la_colonne_a_trier.trim()+"','"+("asc".equals(ord)?"desc":"asc")+"','"+col.trim()+"',"+f+",'"+p+"');");
}%>
<%!boolean deleteFile(String path,String cache_id){
	boolean result = false;
	if(! cache_id.equals("")){
		try
		{
		int i;
		result = new java.io.File( path +"/_"+  cache_id).delete();
		System.out.println("fichier supprimé : "+path +"/_"+ cache_id);
		}catch( Exception ee ) {
			result = false;
			ee.printStackTrace();
		}
		return(result);
	}else{
		return(false);
	}
} %> 
<%!void supprCache(String cache_id,com.etn.beans.Contexte Etn){
	boolean b = deleteFile(com.etn.requeteur.Cache.cacheDir,""+cache_id);
	int i = Etn.executeCmd("delete from requete_en_cours where id in("+cache_id+")");
//	i = Etn.executeCmd("delete from thread_work where id in("+cache_id+")");
//	i = Etn.executeCmd("delete from histo_requete where cache_id in("+cache_id+")");
}

%>
<%!String donneTechno(String t,String[] t2){
	String r="";
	if( t==null){
		r="";
	}else{
		if("".equals(t)){
			r="";
		}else{
			r = t2[Integer.parseInt(t)];
		}
	}
return(r);
}%>

<%!String TextEncode(String g){
	String r="";

	for (int y=0 ; y < g.length();y++) {
		if( g.charAt(y)=='"')
			r+="&quot;";
		else
			r+=g.charAt(y);
	}
	return (r);
}
%>

<%!String reverseDate(String date1){
if(! "".equals(date1)){
	String d="";
	d = date1.substring( date1.lastIndexOf("/")+1 ) ;
		d += "/"+ date1.substring( date1.indexOf("/")+1, date1.lastIndexOf("/") );
		d += "/"+ date1.substring(0,date1.indexOf("/"));
		//System.out.println("reverseDate : date1="+date1+"\td"+d);
		return(d);

}else{
	return("");
}

}%>

<%!double arrondir(String a){

	int arr=2;
	if(a==null) a="";

	double nbr2=Math.pow(10,arr);
	double arrondi=0.0;
	if(!a.equals("")){
			double b = Double.parseDouble(a);
			arrondi=(Math.round(b*nbr2))/nbr2;
	}
	return( arrondi );
}
%>

<%!String comboYear(String a){
	String o ="";
	int beginYear=2005;
	int lastYear=2007;
	String s = "";

	o+="<select name=\"annee\">\n";

	if(a.equals("")){s="selected";}
	o+="<option "+s+" value=\"\">--Tout-\n";
	s="";

	for(int i=lastYear;i>=beginYear;i--){
		if(a.equals(""+(""+i).substring(2))){s="selected";}

		o+="<option "+s+" value=\""+(""+i).substring(2)+"\">"+i+"\n";
		s="";
	}
	o+="</select>";
	return(o);
}%>

<%!String calendrier2(String nom,String valeur,String onBlur){

	String i = "<input type=\"text\" id=\""+nom+"\" name=\""+nom+"\" onblur=\"testDate(this);\"  value=\""+valeur+"\" size=\"8\">&nbsp;";
		i+="<img src=\"img/mission2/calendrier.gif\"";
		i+=" style=\"cursor:hand;\"";
		i+=" value=\"...\"";
		i+=" name=\"c\"";
		i+=" onclick=\"newcal2(this.sourceIndex-1);\"";
		i+=" onblur=\""+onBlur+"\"";
		i+=" title=\"Sélectionner une date par le calendrier\"";
		i+=" width=\"15\" height=\"15\">";

		return(i);
}%>
<%!String calendrier(String nom,String valeur,String onBlur,String f){

	String i = "<input type=\"text\" id=\""+nom+"\" name=\""+nom+"\" value=\""+valeur+"\" size=\"8\">&nbsp;";
	//format=D libelle=\""+nom+"\"
		i+="<img src=\"img/general_calendar.gif\"";
		i+=" style=\"cursor:pointer;\"";
		i+=" value=\"...\"";
		i+=" name=\"c\"";
		i+=" onclick=\"Calendrier('"+f+"');\"";
		i+=" title=\"Sélectionner une date\"";
		i+=" >";

		return(i);
}
%>
<%!String calendrier3(String nom,String valeur,String onBlur,String f){

	String i = "<div style='position:relative;'><input type=\"text\" id=\""+nom+"\" name=\""+nom+"\" value=\""+valeur+"\"  "+onBlur+"  size=\"20\">&nbsp;";
	//format=D libelle=\""+nom+"\"
		i+="<img src=\"img/general_calendar.gif\"";
		i+=" style=\"cursor:pointer;\"";
		i+=" value=\"...\"";
		i+=" name=\"c\"";
		i+=" onclick=\"Calendrier2('"+f+"');\"";
		i+=" title=\"Sélectionner une date\"";
		i+=" ><div style='position:absolute;' id='info_dates'></div></div>";

		return(i);
}
%>

<%!String AfficheSelect(String tab[],String name,String pos,String valVide,String event,String val1, String val2){


	// tab = le tableau des valeur
	// name = le nom du select
	// pos = permet de positionner le selected
	// valVide = pour afficher un titre ...
	// event = rajouteur un evenement ou un autre attribut (id,alt ...)
	// val1 = rajout une valeur
	// val2 = libellé


	String d="";

	d+="<select name=\""+name+"\" "+ event+">\n";

	if(! val1.equals("")){
		d+="<option value=\""+val1+"\">"+val2+"\n";
	}

	if(! valVide.equals("")){
		d+="<option ";
		if(pos.equals("")){
			d+=" selected ";
		}
		d+=" value=\"\">"+valVide+"\n";
	}

		for(int i=1;i < tab.length;i++){
			d+="<option ";

			if(pos.equals(""+i)){
				d+=" selected ";
			}

			d+=" value=\""+i+"\">"+tab[i]+"\n";
		}

	d+="</select>\n";

return(d);
}
%>
<%!String RetourneChaine(String tab,int n){
	String t[] = tab.split(";");
	return(t[n]);
	}
%>

<%!	int RetourneIndex(String tab[],String quoi1){
	int n=-1;
	for( int t =0; t < tab.length; t++){
		if( tab[t].split(",")[0].equalsIgnoreCase(quoi1)){
			n= t;
		}
	}
	return(n);
	}
%>
<% %>

<%/*! String retourneSQL(String f2){
String sql="";

String v[] =  f2.split(";");

for(int i2 = 0; i2 < v.length;i2++){
	String clause[] = v[i2].split(",");
	sql+= (i2==0?" ":" and ");
	sql+="  " + clause[0] + " = " ;
	for(int j=1;j < 2;j++){
		sql+="'"+ com.etn.util.Substitue.dblCote(clause[j])+"'" + ( (clause.length-1)==j?"":",");
	}
	sql+="";
}
return(sql);

}*/%> 
<%!String date_relative (String p1,String p2,String m,boolean heure){
	System.out.println("date_relative="+m);
	int p1a = 0;
	int p2a = 0;
	if("".equals(p1)){
		p1a = 0;
	}else{
		p1a = Integer.parseInt(p1,10);
	}
	if("".equals(p2)){
		p2a = 0;
	}else{
		p2a = Integer.parseInt(p2,10);
	}

	String r[]= new String[2];
	String r1="";
	String r2="";
	String r3="";
	java.util.Calendar caltest= new java.util.GregorianCalendar();

	java.util.Calendar caltest2= new java.util.GregorianCalendar();


	
	if( m.equals("mois")){
		caltest.add(java.util.Calendar.MONTH,-p1a);
		caltest.set(Calendar.DAY_OF_MONTH, caltest.getActualMaximum(Calendar.DAY_OF_MONTH));
	}else{
		if( m.equals("jour")){
			caltest.add(java.util.Calendar.DATE,-p1a);
		}else{
			caltest.add(java.util.Calendar.WEEK_OF_YEAR ,-p1a);
		}
	}

	String day=""+caltest.get(caltest.DAY_OF_MONTH);
	String month=""+(caltest.get(caltest.MONTH)+1);
	String year=""+caltest.get(caltest.YEAR);
	if(day.length()==1)	day="0"+day;
	if(month.length()==1)	month="0"+month;
	if(year.length()==1)	year="0"+year;

	
	
	
	r2 = year+"-"+month+"-"+day;

	if( m.equals("mois")){	
	caltest2.add(java.util.Calendar.MONTH,-p2a);
	}else{
		if( m.equals("jour")){
			caltest2.add(java.util.Calendar.DATE,-p2a);
		}else{
			if( m.equals("semaine")){
				caltest2.add(java.util.Calendar.WEEK_OF_YEAR ,-p2a);
			}
		}
	}
	
	
	
	day=""+caltest2.get(caltest2.DAY_OF_MONTH);
	month=""+(caltest2.get(caltest2.MONTH)+1);
	year=""+caltest2.get(caltest2.YEAR);
	if(day.length()==1)	day="0"+day;
	if(month.length()==1)	month="0"+month;
	if(year.length()==1)	year="0"+year;
	
	if( m.equals("mois")){
		day = "01";
	}
	
	
	//r3 = year+"-"+month+"-01";
	r3 = year+"-"+month+"-"+day;
	
	if(heure){
		r3 += " 00:00:00";
	}
	if(heure){
		r2 += " 23:59:59";
	}

	r1 = " (psdate between '"+r3+"' and '"+r2+"')";
	return(r1);
}%>

<%!String ValBddIhm(String bdd[],String ihm[],String val){ 
	String r = "";
	for(int i=0;i<ihm.length;i++){
		if( ihm[i].equalsIgnoreCase(val)){
			String s = bdd[i];
			System.out.println("ValBddIhm (ihm:"+ihm[i]+"==>bdd:"+bdd[i]+"val==>"+val);
			if(s.equals("--vide--")){
				s = "";
			}
			return(s);
		}
	}
	return("");
}%>
<%
/*
Retourne les filtres de la requete pour liste.jsp
f2 : liste des champs et valeurs
ou : condition or
*/
%>
<%!String retourneSQL_filtres(String f2,String ou,String s2,String quoi2,String quoi3,String type_recherche,com.etn.beans.Contexte Etn){
String constr="";
String ur = "";
String techno="";
String sql="";
int i3=0;
int i4=0;

String niv1="";
String niv2="";

String v[] =  f2.split(";");
if(f2.indexOf(";")!=-1){


	String w = "";
	
	for(int i2 = 0; i2 < v.length;i2++){
	String clause[] = v[i2].split(",");
	if(!clause[0].equals("type") && ! clause[0].equals("techno")){
		w+= ",'"+com.etn.util.Substitue.dblCote(clause[0])+"'";
	}
	}

	if(!w.equals("")){
		w = w.substring(1);

		com.etn.lang.ResultSet.Set rs = Etn.execute("select distinct (nomlogique) as nomlogique,type  "+
		" from catalog inner join serveur o on( o.id = catalog.serveur ) "+
		" where catalog.techno = 0 and nomlogique in("+w+")");


		while(rs.next()){
				int r=-1;
				r = RetourneIndex(v,rs.value("nomlogique"));
				//System.out.println("nom logique = "+r+"---"+rs.value("nomlogique"));
				if( r > -1){
					String c[] =  RetourneChaine(f2,r).split(",");
					if( c.length == 1){
						if( (c[1].equals("--vide--"))){
								sql+=" and " + c[0] + " is null" ;
						}

					}else{

						if( rs.value("nomlogique").equals("psdate")){
							//System.out.println("psdate");
							String psdate[] = {"","00:00","","23:59"};
							String cl[] = null;
							if(! c[1].equals("")){
								cl = c[1].split(" ");
								for(int v3=0;v3 < cl.length;v3++){
									if(!cl[v3].equals("")){
										psdate[v3] = cl[v3];
									}
								}
							}

							sql+=" and (psdate between ";
							sql+="'"+ reverseDate(psdate[0]) + " " + psdate[1]+ "'";
							sql+=" and ";
							sql+="'"+ (psdate[2].equals("")?reverseDate(psdate[0]):reverseDate(psdate[2])) + " " + psdate[3] + "'";
							sql+=")";


						}else{

							sql+=" and (" ;
											for(int j=1;j < c.length;j++){
															String s = (c[j].equals("--vide--")?"":c[j]);

															if(rs.value("type").equals("4")){
												sql+= "" + c[0] + c[1] ;

											}else{

												 sql+= c[0]+"=";
																 sql+="'"+ com.etn.util.Substitue.dblCote(s)+"'" + ( (c.length-1)==j?"":" or ");
											}


											}
											sql+=")";

						}
						}
					}//r > -1

				}
			}


}


return(sql);
}
%>

<%!String calculatrice(String id1){
String r="";
String style="width:25px;font-size:12px;color:white;border: 1px solid black;background-color: #EF6215;font-weight:bold;cursor:pointer;";
r+="<center style=\"border-top:1px solid black;\">";
r+="<input type=\"button\" value=\"(\" style=\""+style+"\" onclick=\"mettreL('(','"+id1+"');\">";
r+="<input type=\"button\" value=\")\" style=\""+style+"\" onclick=\"mettreL(')','"+id1+"');\">";
r+="<input type=\"button\" value=\"+\" style=\""+style+"\" onclick=\"mettreL('+','"+id1+"');\">";
r+="<input type=\"button\" value=\"-\" style=\""+style+"\" onclick=\"mettreL('-','"+id1+"');\">";
r+="<input type=\"button\" value=\"/\" style=\""+style+"\" onclick=\"mettreL('/','"+id1+"');\">";
r+="<input type=\"button\" value=\"X\" style=\""+style+"\" onclick=\"mettreL('*','"+id1+"');\">";
r+="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
r+="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
r+="<input type=\"button\" value=\"OK\" style=\"font-size:12px;color:white;border: 1px solid black;background-color: #EF6215;font-weight:bold;\" onclick=\"validerV('"+id1+"');\">";
r+="</center>";
r+="<textarea  rows=\"6\" style=\"width: 100%;border: 1px solid #EF6215;\"  id=\""+id1+"\"></textarea>";

return(r);
}
%>

<%!
 public String getStackTraceAsString(Throwable e) {
		java.io.ByteArrayOutputStream bytes = new java.io.ByteArrayOutputStream();
		java.io.PrintWriter writer = new java.io.PrintWriter(bytes, true);
		e.printStackTrace(writer);
		return bytes.toString();
	}
%>
<%!String AfficheErreur(String msg,String type1){
	String r="";
	r+="<body "+(!type1.equals("2")?"onload=\"afficheAlert('Erreur : ','test');\"":"")+">";
	if(type1.equals("2")){
		r+="<pre>"+msg+"</pre>";
	}else{
		r+="<form name='f2'><textarea id='test'>"+msg+"</textarea>";
	}
	
	r+="</form>";
	return(r);
}%>
<%!String[] retourneValeur1(java.util.HashMap h,String[] s,int index){
		String r[] = null;
		if( h.get(""+s[index])==null){
			r = new String[]{""};
		}else{
			r = ( (String) h.get(""+s[index])).split(";")   ;
		}
		return(r);
	}%>

	<%!int retourneValeur2(java.util.HashMap h,String s[],int index){
		int i = 0;
		if( h.get(""+s[index])==null){
			i = 0;
		}else{
			i = ( (String) h.get(""+s[index])).split(";").length   ;
		}
		return(i);
	}%>
	<%!

// retourne la valeur a partir l'index fournit pour une colonne

String retourneValeur3(java.util.HashMap h,String[] s,int index){
		String r = "";
		if( h.get(""+s[index])==null){
			r = "";
		}else{
			String r2[] = retourneValeur1(h,s,index);
			if( r2[index] == null){
				r = "";
			}else{
				r =  r2[index]   ;
			}

		}
		return(r);
	}%>
	<%!String retourneValeur4(java.util.HashMap h,String[] s,int index,String[] l,int index2){
		String r = "";
		r=	 ((String) h.get(""+s[index])).split(";")[index2];
		return(r);
	}%>
	<%!int valeurExiste(java.util.HashMap h,String colName,String valeur){
	int r = 0;
	if( h.get(colName)==null){
		r = 0;
	}else{
		String t = (String) h.get(""+colName);
		java.util.StringTokenizer st = new java.util.StringTokenizer(t,";");

		while(st.hasMoreElements()){
			String s = st.nextToken();
			if(! "".equals(s)  ){
				if( s.equalsIgnoreCase(valeur)){
					return(1);
				}
			}
}
}
return(r);
}%>
<%!void compteValeur(java.util.HashMap h,String colName,String valeur){
	if( h.get(colName)==null){
		h.put(colName,""+valeur+";");
	}else{
		String v = (String) h.get(colName);
		if( valeurExiste(h,colName,valeur) == 0){
			h.put(colName,""+v+valeur+";");
		}
	}
}
%>
<%!void concat_valeur(java.util.HashMap h,String key,String val,String sepa){
	if(h.get(key)==null){
		h.put(key,val);
	}else{
		String r = "";
		r = ""+h.get(key);
		r= r + sepa + val;
		h.put(key,r);
	}
}%>
<%!void concat_valeur_distinct(java.util.HashMap h,String key,String val,String sepa){
	if(h.get(key)==null){
		h.put(key,val);
	}else{
		String r = "";
		String v = (h.get(key)==null?"":""+h.get(key));
		if(! v.equals(val)){
			r = ""+h.get(key);
			r= r + sepa + val;
			h.put(key,r);
		}
	}
}%>
<%!String libelle(String str,com.etn.beans.Contexte Etn){
	String str2 = "";
	if(!"".equals(str.trim())){
	str2 = str.trim();
	str2 = str2.trim();
	str2 = str2.replaceAll("`","");
	if( str2.indexOf("(")!=-1){
		str2 = str2.substring(str2.indexOf("(")+1);

	}
	if(  str2.lastIndexOf(")")!=-1){
		str2 = str2.substring(0,str2.lastIndexOf(")"));
	}
	str2 = str2.trim();
	//System.out.print("str='"+str+"'");
	str2 =	com.etn.beans.app.LangWriter.msg(str2,Etn);
	
	if( str2.equals("")){
		System.out.println("Non traduit : "+str+"");
		str2 = str;
	}
	}
	return(str2);
}%>

<%!String tableau(int id,com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest req,String o,String a,String compteur,String o2){
String otmp = o;
String atmp = a;
String tab = "";
com.etn.lang.ResultSet.Set rsTableau = com.etn.requeteur.Cache.getResultSet(id);
tab = "<table id='tableau' style='border-left:1px solid silver;' width='100%' cellspacing='0' align='center' cellpadding='3' border='0'><tr>";
if(!otmp.equals(""))
	compteur = atmp+"--"+otmp+"--"+compteur;
else
	compteur = atmp+"--"+compteur;

if(!o2.equals(""))
{
	compteur += o2;
}
String cpteur[]= compteur.split("--");
for( int b = 0 ; b < cpteur.length ; b++ ){
	if( b < cpteur.length-1)
		tab+="<th class='v'>"+libelle_msg(Etn,req,cpteur[b])+"</td>" ;
	else
		tab+="<th class='v'>"+libelle_msg(Etn,req,cpteur[b])+"</td></tr><tr>";
}

rsTableau.moveFirst();
while( rsTableau.next() )
{
	for( int b = 0 ; b < cpteur.length  ; b++ ){
		String tmp = rsTableau.value(cpteur[b]);

		if( b < cpteur.length-1)
		{
			if(tmp==null)
				tab+="<td>--</td>";
			else
				tab+="<td>"+tmp+"</td>";
		}
		else
		{
			if(tmp==null)
				tab+="<td>--</td></tr><tr>" ;
			else
				tab+="<td>"+tmp+"</td></tr><tr>";
		}
	}
}

tab+="</tr></table>";
return(tab);
}%>
<%!String type_donnee(java.util.HashMap h,int j,com.etn.lang.ResultSet.Set rs){
	String s = "";
	String s2 = "";
	if( h.get(""+rs.ColName[j].trim())!=null){
	String val = ""+h.get(""+rs.ColName[j].trim());
		if( val.trim().equalsIgnoreCase("ratio")){
			s = "%";
		}else{
			s = " ";
		}
	}
	return(s);
}
%>
<%!String Taux(String str){
	java.text.DecimalFormat nf = new java.text.DecimalFormat("0.00%");
 

	if( str == null ){
		return("--");
	}else{
		if( str.equals("null")){
			return("--");	
		}else{
			/*Double a = Double.parseDouble(str);
			a *= 100.0;
			a = Math.floor(a+0.5);
			a /= 100.0; */
			return (nf.format(Double.parseDouble(str)));
//			return (nf.format(a));
			
	}
	}
}%>
<%!String typeValeur2(String str,java.util.HashMap h,int j,com.etn.lang.ResultSet.Set rs){
	String s = "";
	String s2 = "";
	
	//System.out.println(rs.ColName[j].trim()+" in format "+(String)h.get(""+rs.ColName[j].trim()+"_format"));
	
	if(	rs.ColName[j].trim().startsWith("TX_")){
		return( Taux(str));
		//System.out.println("in format "+(String)h.get(""+rs.ColName[j].trim()+"_format"));
		
	}else{
	try{
		
		String mf=(String)h.get(""+rs.ColName[j].trim()+"_format");
		if(mf !=null && !"".equals(mf.trim())){
			java.text.DecimalFormat nf = new java.text.DecimalFormat(mf);
			// System.out.println("in format "+(String)h.get(""+rs.ColName[j].trim()+"_format"));
			return (nf.format(Double.parseDouble(str)));
		}else
		{

		}
		} catch(Exception e){
			//System.out.println("format Error  4 "+rs.ColName[j]+"  "+(String)h.get(""+rs.ColName[j].trim()+"_format"));
		}
	}

	if( h.get(""+rs.ColName[j].trim())==null){
		s2 = str;
	}else{
		String val = ""+h.get(""+rs.ColName[j].trim());
		//System.out.println(""+rs.ColName[j]+"==>"+val);
		if( val.trim().equalsIgnoreCase("ratio")){
			s = "%";
		}else{
			s = " ";
		}
		s2 = str + s;
	}
	return(s2);
}
%>
<%!String typeValeur2(String str,java.util.HashMap h,com.etn.lang.ResultSet.Set rs){
	String s = "";
	String s2 = "";
	//System.out.print(""+rs.ColName[rs.indexOf(str)]+"==>");
	
	
	if( h.get(""+rs.ColName[rs.indexOf(str)].trim())==null){
		s2 = rs.value(str);
	}else{
		String val = ""+h.get(""+rs.ColName[rs.indexOf(str)].trim());
		//System.out.println(""+val);
		if( val.trim().equalsIgnoreCase("ratio")){
			s = "%";
		}else{
			s = " ";
		}
		s2 = rs.value(str) + s;
	}
	
	return(s2);
}
%>
<%!void concat_valeur_numeric(java.util.HashMap h,String key,String val,int type1){

	java.text.NumberFormat form = java.text.NumberFormat.getInstance();
	form.setMinimumFractionDigits(2);
	form.setMaximumFractionDigits(2);

	try{

	String val2 = (val==null?"":val);
	val2 = (val2.equals("")?(type1==1?"0":"0.0"):val2);
	if(h.get(key)==null){
		h.put(key,""+val2);
	}else{
		String r = "";
		r = ""+h.get(key);
		if( type1==1){
			int r1 = Integer.parseInt(r,10);
			r1+=Integer.parseInt(val2,10);
			h.put(key,r1);
		}else{
			double r2 = Double.parseDouble(r);
			r2+=Double.parseDouble(val2);
			h.put(key,r2);
			
			/*Double r2 = Double.parseDouble(r);
			r2+=Double.parseDouble(val2);
			r2 *= 10000.0;
			r2 = Math.floor(r2+0.5);
			r2 /= 10000.0; 
			h.put(key,r2);*/
		}

		//System.out.println(key+"-->"+h.get(key)+"");
	}

	}catch(Exception e){
		//System.out.println("concat_valeur_numeric : " + key+"-->"+h.get(key)+"");
		//e.printStackTrace();
		//throw e;
	}

}%>
<%!String calcul2(String un,String deux){
	double r = 0.00;
	if( un == null) un = "";
	if( deux == null) deux = "";
	if( (!un.equals("")) && (!deux.equals("")) ){
		double a = Double.parseDouble(un);
		double b = Double.parseDouble(deux);
		r= a/b;
	}else{
		r=0.00;
	}
	return(""+r);
}%>
<%!String aff_valeur_numeric(String valeur){
	String r="";

	java.text.NumberFormat form = java.text.NumberFormat.getInstance();
	form.setMinimumFractionDigits(2);
	form.setMaximumFractionDigits(2);

	if(valeur==null){
		r = "";
	}else{
		if(!"".equals(valeur)){
			r = form.format(Double.parseDouble(valeur));
		}else{
			r = "";
		}
	}
	return(r);
}%>
<%!String r_date_fraicheur(com.etn.beans.Contexte Etn,String table){
	String r = "0000-00-00";
	String sql= "";
	com.etn.lang.ResultSet.Set rsDate = Etn.execute(sql="SELECT max(date_fraicheur) as date_fraicheur,nom_table FROM `batch` where nom_table = "+com.etn.sql.escape.cote(table)+" group by 2");
	//System.out.println(""+sql);
	if(rsDate.next()){
		r=reverseDate(rsDate.value(0));
	}else{
		r = "0000-00-00";
	}
	return(r);
}
%>
<%!String replaceKPI2(com.etn.lang.ResultSet.ArraySet a,String kpi){
	String  k = kpi;
	java.util.StringTokenizer st = new java.util.StringTokenizer(kpi,"[]");

	while(st.hasMoreElements()){
		String s = st.nextToken();
		if(! "".equals(s)  ){
			int u = a.getRow("["+s+"]"); //recuperation de la ligne dans le ArraySet
			if( u > -1){
				if( s.equals(a.value(u,"formule"))){
					k = s;
				}else{
					k = k.replaceAll("\\["+s+"\\]","("+replaceKPI2(a,a.value(u,"formule"))+")");
				}
			}
		}
	}
	return(k);
}%>
<%!
class filtre_requete{
	String champ;
	String valeur;

	public filtre_requete (String c,String v) {
		this.champ = c; this.valeur = v ;
		}
	}
%>
<%!int getIndexChamp(java.util.ArrayList<filtre_requete> ar,String c,String v)
	{
	int r = 0;

	for( int i = 0 ; i < ar.size() ; i++ )
		{
		 if(  ar.get(i).champ.equalsIgnoreCase(c) &&  ar.get(i).valeur.equalsIgnoreCase(v) ){
			r = 1;
		}

		}
		return(r);
	}
%>

<%!int getIndexChamp2(java.util.ArrayList<filtre_requete> ar,String c)
	{
	for( int i = 0 ; i < ar.size() ; i++ )
		{
		 if(  ar.get(i).champ.equalsIgnoreCase(c)  ){
			 return(1);
		}
		}
		 return(0);
	}
%>
<%!com.etn.lang.ResultSet.ItsResult filtreResult(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rs,String[] valeur2,java.util.ArrayList<filtre_requete> ar){
	//System.out.println("debut filtreResult");
	
	/*for(int ii=0;ii<valeur2.length;ii++){
		System.out.println("'"+valeur2[ii]+"'<br>");
	}*/
	java.util.HashMap<String,Byte> typeCol = getTypeCol(rs);
	com.etn.lang.ResultSet.ExResult exRs = new com.etn.lang.ResultSet.ExResult(null,valeur2,9,10);

	rs.moveFirst();
	java.util.HashMap l = new  java.util.HashMap();
	int ligne = 0;
	while(rs.next()){
		l.put(""+ligne,"");
		for(int c=0;c<rs.Cols;c++){
			int r = getIndexChamp2(ar,rs.ColName[c].trim());
			int r2 = getIndexChamp(ar,rs.ColName[c].trim(),rs.value(rs.ColName[c].trim()));
			
			if( r == 0){
				//System.out.println("trouvé champ"+rs.ColName[c].trim());
			}else{
				if(r2 == 1){
					//System.out.println("trouvé champ et valeur "+rs.ColName[c].trim()+"==>"+rs.value(rs.ColName[c].trim()));
					//l.put(""+ligne,"");
				}else{
					l.remove(""+ligne);
				}
			}
		}
		ligne++;
	}
	rs.moveFirst();
	ligne = 0;
	while(rs.next()){
		if( l.get(""+ligne)!=null){
			exRs.add();
			for(int c=0;c<rs.Cols;c++){
				exRs.set(c,rs.value(rs.ColName[c].trim()));
			}
			exRs.commit();
		}
		ligne++;
	}
	rs.moveFirst();
	com.etn.lang.ResultSet.ItsResult rs2 =  new com.etn.lang.ResultSet.ItsResult( exRs.getXdr() );
	putTypeCol(rs2,typeCol);
	//System.out.println("fin filtreResult");
	return(rs2);
}%>
<%!String[] liste_valeur_distinct(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rs,String str){ 
	if(!"".equals(str)){
	java.util.ArrayList<filtre_requete> ar = new java.util.ArrayList<filtre_requete>();
	java.util.ArrayList<String> ar2 = new java.util.ArrayList<String>();
	
	if( rs != null ){
	
	rs.moveFirst();
	while(rs.next()){
		if( rs.value(str) != null){	//si champ à changé
			int r2 = getIndexChamp(ar,str,rs.value(str));
			if( r2 == 0){
				//System.out.println("r="+r2+"--str="+str+"==>"+rs.value(str));
				ar2.add(rs.value(str));
				ar.add( new filtre_requete(str,rs.value(str)));
			}
		}
	}
	rs.moveFirst();
	String t[] = new String[ar2.size()];
	return( ar2.toArray(t) );
	
	}else{
		return( new String[]{""} );
	}
	
	}else{
		return( new String[]{""} ); 
	}
}
%>
<%!int isPresent(String[] liste,String valeur){
	if( liste != null){
		for(int i=0;i<liste.length;i++){
			if( liste[i].equalsIgnoreCase(valeur)){
				return(1);
			}
		}
	}else{
		return(0);
	}
	return(0);
}
%>
<%!String liste_hashMap(java.util.HashMap h,String sepa){
	java.util.Set lesCles = h.keySet() ;
	java.util.Iterator it = lesCles.iterator() ;

	Object o;
	
	String r  = "";
	while (it.hasNext()){
	    o = it.next();
	    r+=  o+""+sepa;
	  }
	
		
	return(""+r);
}%>
<%!String getValHashMap(java.util.HashMap h,String key){
	if( h.get(key)==null){		
		return("");
	}else{
		return(""+h.get(key));	
	}
}%>
<%!int diff_between_th(int current,String[] t){
	if( current == (t.length-1)){
		return(-1);
	}else{
		int t1 = Integer.parseInt(t[current],10);
		int t2 = Integer.parseInt(t[current+1],10);
		return( t2 - t1);
	}
	
}%>
<%!int th_present(String[] t,int i,int val,java.util.HashMap h,String sepa3){
	if( i == 0){
		return(-1);
	}else{
		String liste[] = getValHashMap(h,t[i-1]).split(sepa3);
		for(int l=0;l<liste.length;l++){
			if( liste[l].equals(""+val)){
				return(0);				
			}
		}
	}
	return(-1);
}
%>
<%!String criteres_selectiones(String requete_name,String filtre_r,String valeur_r,String ligne_r,String colonne_r,String valeur_a,String valeur_o,String style){
	String r = "";
	
	if( valeur_a.equals("")){
		valeur_a = "&nbsp;";
	}
	if( valeur_o.equals("")){
		valeur_o = "&nbsp;";
	}
	
	r="<br><table width='100%' id='details_r' border='0' align='center' cellspacing='0' cellpadding='0' class='affichage' "+(style.equals("")?"":"style='"+style+"'")+">";
    r+="<tr><td class='aff1' height='25' colspan='2'><b>critères sélectionnés</b>&nbsp;<font style='color:black;font-size:8pt;'>(requête : "+requete_name+")</font></td></tr>";
    r+="<tr><td class='aff2'><b>&nbsp;filtre :</b></td><td class='lab_select0' style='background:white;border:0px solid white;border-bottom: 1px solid #CCCCCC'>"+filtre_r+"</td></tr>";
    r+="<tr><td class='aff2'><b>&nbsp;valeur :</b></td><td class='lab_select1' style='background:white;border:0px solid white;border-bottom: 1px solid #CCCCCC'>"+valeur_r+"</td></tr>";
    r+="<tr><td class='aff2'><b>&nbsp;granularité&nbsp;ligne :</b></td><td class='lab_select2' style='background:white;border:0px solid white;border-bottom: 1px solid #CCCCCC;'>"+ligne_r+"</td></tr>";
    r+="<tr><td class='aff2'><b>&nbsp;granularité&nbsp;colonne :</b></td><td class='lab_select2' style='background:white;border:0px solid white;border-bottom: 1px solid #CCCCCC;'>"+(colonne_r.equals("")?"--":colonne_r)+"</td></tr>";
    r+="<tr><td class='aff2'><b>&nbsp;Filtrage&nbsp;abscisse :</b></td><td class='lab_select2' style='background:white;border:0px solid white;border-bottom: 1px solid #CCCCCC;'>"+valeur_a+"</td></tr>";
    r+="<tr><td class='aff3' nowrap='nowrap'><b>&nbsp;Filtrage&nbsp;ordonnées :</b></td><td class='lab_select2' style='background:white;border:0px solid white;'>"+valeur_o+"</td></tr>";
    r+="</table><br>";
	
	return(r);
}
%>
<%!
public class TriComparator 
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
void debug(String s)
{ boolean dbg=false; if(dbg) System.out.println(s+" ==> "); }

void debug(String s , String t)
{ boolean dbg=false; if(dbg) System.out.println(s+" ==> "+t);}

void debug(String s , String t, boolean dbg)
{ if(dbg) System.out.println(s+" ==> "+t);
}
double[] getCoordLambert2ToWGS84(double x1,double y1){
try{
  conv.coord.Coordonnee c = new conv.coord.Coordonnee("LAMBERT2",x1,y1);
  conv.coord.Coordonnee c2 = c.get_Coord_in_WGS84();
  double d[] = new double[2];
  d[0] = c2.get_latitude();
  d[1] = c2.get_longitude();
  debug("getCoordLambert2ToWGS84 : \nX("+x1+")="+d[0]+"\nY("+y1+"):"+d[1]);
  return(d);
}catch(Exception ee){
  double d[] = new double[2];
  d[0] = 0.0;
  d[1] = 0.0;
  return(d);
}
}
%>