<%//@page contentType="text/html; charset=UTF-8" %>
<%!String reverseDate(String date1){
	try{
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

	}catch(Exception ee){
		return("");
}

}%>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%@include file="/WEB-INF/include/commonVal.jsp" %>
<%
String s=request.getParameter("s");


java.util.Calendar caltest= new java.util.GregorianCalendar();
String day=""+caltest.get(caltest.DAY_OF_MONTH);
String month=""+(caltest.get(caltest.MONTH)+1);
String year=""+caltest.get(caltest.YEAR);
if(day.length()==1)	day="0"+day;
if(month.length()==1)	month="0"+month;
if(year.length()==1)	year="0"+year;

String table=request.getParameter("tipo");
String t[] = tableStock(table);
table = t[0];

String type_col = t[1];


String tab_champs[] = tab_col_stock;
if(!table.equalsIgnoreCase("stock")){
	tab_champs = tab_col_stock_other;
}

if(s==null){
//String tab_champ[] = new String[]{"referencia","descripcion_ref","stock_disponible_portabilidad","stock_virtuel","reserva","col1","date_update"};



String champ = request.getParameter("champ");
if(champ == null) champ = "";
String valeur = request.getParameter("valeur");
if(valeur == null) valeur = "";
String cle = request.getParameter("cle");
if(cle == null) cle = "";
String cle_v = request.getParameter("cle_v");
if(cle_v == null) cle_v = "";

String reserve="";


String sql="";

String date1 = year+"/"+month+"/"+day;
String date2 = day+"/"+month+"/"+year;
if(tab_champs[Integer.parseInt(champ,10)].equals("date_saisie")){
	valeur = reverseDate(valeur);
	date2 = "";
}

if(tab_champs[Integer.parseInt(champ,10)].equals("stock_virtuel")){
	Etn.execute(sql="update "+table+" set stock_saisie="+escape.cote(valeur)+",pendiente_producto=0"+(table.equalsIgnoreCase("stock")?",enplataforma=0":"")+",cancelled=0 where codesap="+escape.cote(cle_v)+"");
}
 if(tab_champs[Integer.parseInt(champ,10)].equals("gama_alta")){
       Etn.execute(sql="update mapterminal set scoretest="+escape.cote(valeur)+" where codesap="+escape.cote(cle_v)+"");
   }

sql="update "+table+" set "+tab_champs[Integer.parseInt(champ,10)]+"="+escape.cote(valeur)+"";
if(!tab_champs[Integer.parseInt(champ,10)].equals("date_saisie")){
	sql+= ",date_saisie = "+escape.cote(date1);
}
if(tab_champs[Integer.parseInt(champ,10)].equals("actif")){
	if(valeur.equals("1004")){
		reserve = "1";
	}else{
		reserve = "0";
	}
	sql+= ",reserve = "+escape.cote(reserve);
}




sql+= " where "+tab_champs[Integer.parseInt(cle,10)]+"="+escape.cote(cle_v);
System.out.println(""+sql);
int cmd = Etn.executeCmd(sql); 
out.clearBuffer();
System.out.println(""+cmd);
sql="";

if(cmd>0){
	if(tab_champs[Integer.parseInt(champ,10)].equals("terminalARPA") || tab_champs[Integer.parseInt(champ,10)].equals("marca")){
		sql="update mapterminal set "+tab_champs[Integer.parseInt(champ,10)]+"="+escape.cote(valeur)+"";
		sql+= " where codesap="+escape.cote(cle_v);
		Etn.execute(""+sql);
	}
}

String st="";
String r_sup_stock = "";
String ppr="";
String empl="";
String ca="";
String sv="";

if(tab_champs[Integer.parseInt(champ,10)].equals("stock_virtuel")){
	if(cmd>0){
		Set rs = Etn.execute(sql="select stock_saisie as st,((rotation_hebdo)>(stock_saisie-stock_virtuel)) as r_sup_stock,pendiente_producto,stock_virtuel as sv"+(table.equalsIgnoreCase("stock")?",enplataforma,cancelled":"")+" from "+table+" s where "+tab_champs[Integer.parseInt(cle,10)]+"="+escape.cote(cle_v) + "");
		System.out.println(""+sql);
		if(rs.next()){
			st = rs.value("st");
			sv = rs.value("sv");
			r_sup_stock = rs.value("r_sup_stock");
			ppr = rs.value("pendiente_producto");
			empl = rs.value("enplataforma");
			ca = rs.value("cancelled");
		}
	}
}



out.write( "{\n");
String  n = "";
  out.print(( n+"\"cmd\": \""+cmd+"\""));
  n = ",\n";
  out.print(( n+"\"r_sup_stock\": \""+r_sup_stock+"\""));
	n = ",\n";
  out.print(( n+"\"date_update\": \""+date2+"\""));
  n = ",\n";
  out.print(( n+"\"st\": \""+st+"\""));
  n = ",\n";
  out.print(( n+"\"ppr\": \""+ppr+"\""));
  n = ",\n";
  out.print(( n+"\"sv\": \""+sv+"\""));
 /* n = ",\n";
  out.print(( n+"\"empl\": \""+empl+"\""));
  n = ",\n";
  out.print(( n+"\"ca\": \""+ca+"\""));*/
  
  if(!reserve.equals("")){
	  n = ",\n";
	  out.print(( n+"\"reserve\": \""+reserve+"\""));
  }
  
  out.write( "\n}");
}else{
	if(request.getParameter("s").equals("1")){
		String  n = "";
		out.clearBuffer();
		String codesap = request.getParameter("codesap");
		String marca = request.getParameter("marca2");
		String terminalARPA = request.getParameter("terminalARPA");
		String description = request.getParameter("description");
		String stock_saisie = request.getParameter("stock_saisie");
	
		int cmd = 0;
		out.write( "{\n");
		if(table.equalsIgnoreCase("stock")){
			cmd = Etn.executeCmd("insert into mapterminal (codesap,terminalIDEUP,marca,terminalARPA) values ("+escape.cote(codesap)+","+escape.cote(description)+","+escape.cote(marca)+","+escape.cote(terminalARPA)+")");
			
			
			
			
			if(Etn.getLastError()!=null){
				if(Etn.getLastError().indexOf("Duplicate")!=-1){
				out.print(( n+"\"cmd\": \"-2\""));
				n = ",\n";
				out.print(( n+"\"cmd_err\":\""+(Etn.getLastError().indexOf("ix_code")!=-1?"Code Sap":"Nom du terminal")+" \""));
				}else{
					out.print(( n+"\"cmd\": \"-3\""));
					n = ",\n";
					out.print(( n+"\"cmd_err\": \"\""));
					Etn.execute("delete from mapterminal where codesap = "+escape.cote(codesap));
				}
			}
		}else{
			cmd=1;
		}
			
		if(cmd>0){
			String sql2="insert into "+table+" (codesap,stock_saisie,date_icp,date_saisie,actif"+(table.equalsIgnoreCase("stock")?"":",type,description")+") values ";
			sql2+="("+escape.cote(codesap)+","+escape.cote(stock_saisie)+",now(),curdate(),1"+(table.equalsIgnoreCase("stock")?"":","+type_col+","+escape.cote(description))+")";
			
			int cmd2 = Etn.executeCmd(sql2);
	
			if(Etn.getLastError()!=null){
				out.print(( n+"\"cmd\": \"-3\""));
				n = ",\n";
				out.print(( n+"\"cmd_err\": \"\""));
				Etn.execute("delete from mapterminal where codesap = "+escape.cote(codesap));
			}else{
				if(cmd2>0){
					n = "";
					String sql3="select s.codesap";
					
					if(table.equalsIgnoreCase("stock")){
						sql3+=" , m.marca";
					}
					
					if(table.equalsIgnoreCase("stock")){
						sql3+=", m.terminalIDEUP ";
					}else{
						sql3+=", description ";
					}
					
					
					if(table.equalsIgnoreCase("stock")){
						sql3+=",m.terminalARPA";
					}
					
					
					sql3+=" ,stock_icp, stock_saisie as nb,pendiente_producto,rotation_hebdo,0,date_saisie,date_icp ";
					sql3+= " from "+table+" s ";
					
					if(table.equalsIgnoreCase("stock")){
						sql3+= " ,mapterminal m where m.codesap = s.codesap and ";
					}else{
						sql3+= " where ";
					}
					
					sql3+= "  s.codesap = " + escape.cote(codesap);
					
					Set rsR = Etn.execute(sql3);
					System.out.println("sql3==>"+sql3);
					if(rsR.next()){
						out.print(( n+"\"cmd\": \""+cmd2+"\""));
						n = ",\n";
						for(int y=0;y<rsR.Cols;y++){
							out.print(( n+"\"col"+y+"\": \""+rsR.value(y)+"\""));
							n = ",\n";
						}
					}
					
				}
			}
			
		}
		
		
		
		
	}
	if(request.getParameter("s").equals("2")){
		out.clearBuffer();
		out.write( "{\n");
		String n ="";
		String codesap = request.getParameter("codesap");
		int cmd3 = Etn.executeCmd("delete from mapterminal where codesap = " + escape.cote(codesap));
		if(cmd3>=0){
			cmd3 = Etn.executeCmd("delete from stock where codesap = " + escape.cote(codesap));
		}
		out.print(( n+"\"cmd\": \""+cmd3+"\""));
	}
	out.write( "\n}");
}
%>

