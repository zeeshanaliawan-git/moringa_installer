<%@ page import="com.etn.lang.ResultSet.*"%><%@ page import="java.util.StringTokenizer"%><%@ page import="java.util.Hashtable"%><%@ page import="java.lang.String"%><%@ page import="java.net.URLEncoder"%><%@ page import="java.util.Enumeration"%><%!


Hashtable add(Hashtable a ,Hashtable exclu, String w){
	if(w==null || w.trim().equals("")  || exclu.get(w.toUpperCase())!=null || w.length()==1 )return(a);
	
	
	if (a.get(w.toUpperCase())==null){
		
		
		a.put(w.toUpperCase(),w+" 1");
	}else {
		String lw=(String)a.get(w.toUpperCase());
//		System.out.println("==lw="+lw+"==w="+w);
		a.put(w.toUpperCase(),""+lw.split(" ")[0]+" "+(Integer.parseInt(lw.split(" ")[1])+1));
		
	}
	
	String t=(String)a.get("#TOTAL#");
	if (t==null){
		a.put("#TOTAL#","0");
		t="0";
	}
	a.put("#TOTAL#",""+(Integer.parseInt(t)+1));
	
	
	return(a);
	
}

class MyComparatorNom implements java.util.Comparator {
	   public int compare(Object o1, Object o2) {
	      String[] a1 = (String[])o1; // second dimension arrays  
	      String[] a2 = (String[])o2; // must be same length
	   
	      return(a1[0].compareToIgnoreCase(a2[0] ));
	     
	      
	   }
	}


//je trie
class MyComparatorFreq implements java.util.Comparator {
public int compare(Object o1, Object o2) {
   String[] a1 = (String[])o1; // second dimension arrays  
   String[] a2 = (String[])o2; // must be same length
  
   if (Integer.parseInt(a1[1]) == Integer.parseInt(a2[1])) return(0);
   if (Integer.parseInt(a1[1])>Integer.parseInt(a2[1])) return(-1);
		return(1);      
   
}
}

%>
<%

// modifiable

int MaxMot=40;   // NB Max de mots autorisé
	// type 4 
int seuil1 =8; // % de mots  vus dans l'odre decroissante de présence
	// type 3 
int seuil2 =25;  
	// type 2
int seuil3 =65;  
	// type 1
					

Hashtable exclu  = new Hashtable();
//exclu.put("","");
exclu.put("POUR","1");
exclu.put("DE","1");
exclu.put("PAR","1");
exclu.put("D","1");
exclu.put("ET","1");
exclu.put("-","1");



String[] separateur={" ","--","=",",","/",";","\\\\","\\\n","\\\r","\\\t",":","'","\\\"","\\+"};


/// fin de modificable

//String cloud_sql="";
{
Hashtable sCloud=(Hashtable) session.getAttribute("Cloud");
if (sCloud==null) sCloud= new Hashtable();

if (request.getParameter("cadd")!=null)
	sCloud.put(request.getParameter("cadd"),"ok");
if (request.getParameter("cdel")!=null)
	sCloud.remove(request.getParameter("cdel"));

 session.setAttribute("Cloud",sCloud);



Hashtable brume = new Hashtable();


String origineCloud=ri.getOrigineCloud();	
// etendre la recher à la description
// etendre la recher à la description
Set rs=Etn.execute(ri.requeteCloud(Etn,request,h_query));


//je compte les mots
int total=0;
if(rs.rs.Rows > 0){

while (rs.next()){
	
	String smots=rs.value("clef");
	for (int i=0;i<separateur.length;i++)
		smots=smots.replaceAll(separateur[i]," ");
	String[] mots=smots.split(" ");
	for (int i=0;i<mots.length;i++)
		brume=add(brume,exclu, mots[i]);
	
}
total=Integer.parseInt((String)brume.get("#TOTAL#"));
}
brume.remove("#TOTAL#");
Enumeration k = brume.keys();



java.util.Vector v = new java.util.Vector(brume.keySet());
//java.util.Collections.sort(v);

// je recopie dans une table Triable
String[][] nuage=new String[brume.keySet().size()][3];
int li=0;
for (Enumeration e = v.elements(); e.hasMoreElements();) {

  String key = (String) e.nextElement();
  String val=((String) brume.get(key)).split(" ")[0];
  int nb=Integer.parseInt(((String) brume.get(key)).split(" ")[1]);
  nuage[li][0]=val;
  nuage[li][1]=((String) brume.get(key)).split(" ")[1];
  
  li++;
}








//  TRI par frequence descendante
MyComparatorFreq mc = new MyComparatorFreq(); // instance of comparator
java.util.Arrays.sort(nuage,mc); // sort 2D array using comparator to handle 2'nd dim





// regles d'attribution des classes 

if (MaxMot>0){
for(int ik=0;ik<nuage.length;ik++){

	if (ik<seuil1*MaxMot/100) 
		nuage[ik][2]="4";
	else if (ik<seuil2*MaxMot/100) 
		nuage[ik][2]="3";
	else if (ik<seuil3*MaxMot/100) 
		nuage[ik][2]="2";
	else if (ik>seuil3*MaxMot/100 && ik< MaxMot) 
		nuage[ik][2]="1";
	else nuage[ik][2]="0"; 
	
}	
}


// je tri par ordre alpha   pour l'affichage 

MyComparatorNom mca = new MyComparatorNom(); 
java.util.Arrays.sort(nuage,mca);
%>
 

 
<table border="0" cellpadding="0" cellspacing="0" width="100%" align="center" style="margin-bottom: 5px;">
<tr>
<td>
<fieldset id='fieldset_mot_c' style="width: 95%;padding: 2px;" >
<legend ><%=libelle_msg(Etn,request,"Mots Clés")%></legend>
<% 

for(int ik=0;ik<nuage.length;ik++){


	  
	  String  nb=nuage[ik][1];
	  String val=nuage[ik][0];
	  String numClasse=nuage[ik][2];
	  // si 0 je n'affiche pas
		  if(!"0".equals(numClasse)){
		  
		  String style="";
			// action vers la selection et filtre
			String act="";
		  if(sCloud.get(val)==null)
			  act="cadd";
		  else  {
			  act="cdel";
			  style="s";
			  cloud_sql+=" and  "+origineCloud+" like '%"+ val +"%'";
		  }
		  
	  	%>  <a href="?<%=act %>=<%=(val) %>" title='<%=nb %>'>
	  		<font class="<%=style %>brume<%=numClasse%>"><%=val.toUpperCase()%></font></a>
	  		&nbsp;&nbsp;
	  		<%
	  
	  }
}
}

%>
</fieldset>
</td></tr></table>
