<%@page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");  

String signe[] = {"=",">=",">","<","<="};


String tab_col_stock[] = new String[]{"codesap","marca", "description","terminalARPA", "stock_icp","stock_virtuel","pendiente_producto", "rotation_hebdo", "type", "date_saisie", "date_icp", "reserve", "actif","gama_alta"};
String tab_col_stock_other[] = new String[]{"codesap", "description", "stock_icp","stock_virtuel","pendiente_producto", "rotation_hebdo", "type", "date_saisie", "date_icp", "reserve", "actif","gama_alta"};

java.util.TreeMap<String,String> h_statusStock = new java.util.TreeMap<String,String>();

h_statusStock.put("1000","defaultThreshold");
//h_statusStock.put("1001","manualThreshold");
h_statusStock.put("1002","alwaysInStock");
h_statusStock.put("1003","alwaysOutOfStock");
h_statusStock.put("1004","alwaysPreOrder");
//h_statusStock.put("1005","manualPreOrder");
h_statusStock.put("1006","alwaysComingSoon");

String tab_gama_alta[] = new String[]{"","0","1"};
%>
<%!
String[] tableStock(String table){
	System.out.println("tableStock="+table);
	String t[] = new String[2];
	if(table.equalsIgnoreCase("terminal")){
		t[0] = "stock";
		t[1] = "";
	}else{
		t[0] = "stock_other";
		if(table.equalsIgnoreCase("accesorio")){
			t[1] = "1";
		}else{
			if(table.equalsIgnoreCase("regalo")){
				t[1] = "0";
			}else{
				if(table.equalsIgnoreCase("sim")){
					t[0] = "sim";
					t[1] = "2";	
				}
			}
		}
	}
	System.out.println("0==>"+t[0]+"\n1==>"+t[1]);
	return(t);
}
%>
