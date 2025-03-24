<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" /><%@ page import="java.util.HashMap"%><%@ page import="com.etn.beans.*"%><%@ page import="com.etn.beans.app.GlobalParm"%><%@ page import="com.etn.lang.ResultSet.Set" %><%@ page import="com.etn.util.*"%><%@ page import="java.io.*"%><%@ page import="java.util.*"%><%@ include file="/WEB-INF/include/fichier.jsp" %><%
int i=0;
int i2;
String tab_stock[] = new String[]{"sede","referencia", "descripcion_ref", "stock_total_portabilidad", 
		"stock_disponible_portabilidad", "comprometido_portabilidad", "pendiente_portabilidad", 
		"stock_total_no_portabilidad", "disponible_no_portabilidad", "comprometido_no_portabilidad", 
		"pendiente_no_portabilidad","date_update","date_import"};

String tab_stock2[] = new String[tab_stock.length-2];
for(int z=0;z<tab_stock2.length;z++){
	tab_stock2[z] = tab_stock[z];
}


String fic = "";
String osiris = "";
String group_by = "";
String constructeur = "";
String path= System.getProperty("java.io.tmpdir") + "/stock";
String t =  ""+System.currentTimeMillis();

java.util.HashMap<String,String> h = new java.util.HashMap<String,String>();

InputStream in = request.getInputStream();
FormDataFilter frm = new FormDataFilter(in);

//System.out.println("DEBUG ==>" + frm);

ByteArrayOutputStream Myout1 =  null;
//java.util.HashMap h =  new java.util.HashMap();
  String f[] ;
  int z = 0;

  if(frm == null){
	  out.write("Pas de fichier importé.");
  }
  
  while( ( f = frm.getField() ) != null )
  {
	 //System.out.println("DEBUG => f[0]="+f[0]+"--->"+f[1]);

    if( frm.isStream())
    {
     	String nom1= f[0];

     	/*fichier recommendation*/
     	if (nom1.equals("file")){
     		fic = f[1];

     		if( "".equals(fic)){
     			//out.println("DEBUG => f[0]="+f[0]+"--->"+f[1]);
     			h.put("fichier",fic);
     			h.put("err","Nom de fichier vide");
     		}else{
     			//out.println("DEBUG => ici");
     			if( (i2 = fic.lastIndexOf('/') ) == -1 ) i2 = fic.lastIndexOf('\\');
     			fic = fic.substring(1+i2);
				h.put("fichier",fic);
				h.put("err","");
	     		Myout1 = new ByteArrayOutputStream(4096);
	     		frm.writeTo(Myout1);
     		}
		}
    }
}//fin du while

//out.write("Fichier "+fic+" importé.");

int err = CreateFile(fic,path,Myout1);
if( err <= -1){
	h.put("err","Erreur création fichier");
}else{
	h.put("err","");
	
	
	String r = verifFichier(path+"/"+fic,tab_stock2);
	System.out.println("============>ICI='"+r+"'");
	r = r.replace("\r\n","");
	if(r.equals("")){
	
	String strSQL = "truncate import_stock";
	Etn.execute(strSQL);
	
		
	strSQL = "LOAD DATA INFILE '" + path+"/"+fic+"' REPLACE INTO TABLE import_stock FIELDS TERMINATED BY '\\t' ENCLOSED BY '\"' LINES TERMINATED BY '\\r\\n' IGNORE 1 LINES ";
	int cmd = Etn.executeCmd(strSQL);
	System.out.println("LOAD DATA INFILE ==>"+cmd);
		if(cmd<=-1){
			h.put("err","Erreur chargement");
		}else{
			h.put("ligne_i",""+cmd);
			//String col = "referencia, descripcion_ref, stock_total_portabilidad,date_update,date_import,stock_saisie";//,stock_saisie
			//String col2 = "codesap, description, stock_icp,date_update,date_import,if(stock_saisie=0 or stock_saisie='' or stock_saisie is null,stock_icp,stock_saisie)";//,stock_icp
			//String sql2 = "replace into stock("+col+") select "+col2+" from import_stock i,stock s left join on s.referencia = i.codesap ";//insert IGNORE
			 
			
			String sql_d = "delete from import_stock where sede = 'canarias'";
			Etn.executeCmd(sql_d);
			
			
			String sql2 = "update stock s,import_stock s2 set s.stock_icp = (s2.stock_disponible_portabilidad+s2.disponible_no_portabilidad) where s2.referencia = s.codesap";
			
			cmd = Etn.executeCmd(sql2);
			if(cmd<=-1){
				h.put("err","Erreur insertion");
				h.put("ligne_i2","-1");
			}else{
				h.put("ligne_i2",""+cmd);
			}
			
			 String sql3 = "update stock_other s,import_stock s2 set s.stock_icp = (s2.stock_disponible_portabilidad+s2.disponible_no_portabilidad) where s2.referencia = s.codesap";
				
				int cmd3 = Etn.executeCmd(sql3);
				if(cmd3>0){
					h.put("ligne_i3",""+cmd3);
				}else{
					h.put("ligne_i3","-1");
				}
				
				String sql4 = "update sim s,import_stock s2 set s.stock_icp = (s2.stock_disponible_portabilidad+s2.disponible_no_portabilidad) where s2.referencia = s.codesap";
				
				int cmd4 = Etn.executeCmd(sql4);
				if(cmd4>0){
					h.put("ligne_i4",""+cmd4);
				}else{
					h.put("ligne_i4","-1");
				}
			
		}
	}else{
		h.put("err",r);//Erreur fichier
		h.put("ligne_i","0");
		//out.write("<pre>"+r+"</pre>");
	}
}
//out.clearBuffer();

out.print( '{');
String  n = "";
for( Iterator<String>it = h.keySet().iterator(); it.hasNext(); )
{ String cle = it.next();
  out.print(( n+cle+" : \""+h.get(cle).toString()+"\""));
  //out.write("\nerr : \""+r+"\"");
  n = ",\n";
}
out.print( '}');
%>