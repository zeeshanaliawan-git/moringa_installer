package com.etn.requeteur;


public class Util {

public String getStackTraceAsString(Throwable e) {
		java.io.ByteArrayOutputStream bytes = new java.io.ByteArrayOutputStream();
		java.io.PrintWriter writer = new java.io.PrintWriter(bytes, true);
		e.printStackTrace(writer);
		return bytes.toString();
	}

public String RetourneChaine(String tab,int n){
		String t[] = tab.split(";");
		System.out.println("RetourneChaine="+n);
		return(t[n]);
	}

public int RetourneIndex(String tab[],String quoi1){
	
	try{
	int n=-1;
	for( int t =0; t < tab.length; t++){
		if( tab[t].split(",")[0].equalsIgnoreCase(quoi1)){
			n= t;
		}
	}
	System.out.println("RetourneIndex="+n);
	return(n);
	

}catch (Exception e) {
	System.out.println("RetourneIndex="+tab.toString()+"=="+quoi1);
	return(-2);
}
}

public String reverseDate(String date1){
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

	}

}