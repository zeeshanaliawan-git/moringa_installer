<%@ page import="com.etn.asimina.util.FileUtil"%>
<%!boolean deleteFile2(String fil,String path){
	boolean result = false;
	try
	{
	int i;
	if( (i = fil.lastIndexOf('/') ) == -1 ) i = fil.lastIndexOf('\\');
	String file = fil = fil.substring(1+i);
	System.out.println("FICHIER A SUPPRIME :" + file);

	result = new File( path + "/" + file).delete();
	System.out.println("FICHIER SUPPRIME :" + file);
	}catch( Exception ee ) {
		result = false;
		ee.printStackTrace();
	}
	return(result);
}
int CreateFile(String fil,String path,ByteArrayOutputStream out1){

	int i;
	int i2;
	int err=-1;

	if( (i = fil.lastIndexOf('/') ) == -1 ) i = fil.lastIndexOf('\\');
	String file = fil = fil.substring(1+i);

	File path2 = FileUtil.getFile(path);//change
	 FileUtil.mkDirs(path2);//change

	System.out.println("CHEMIN = "+path);
	System.out.println("CHEMIN + FICHIER = "+ path +"/"+ file);


	 boolean success = false;
	 FileOutputStream out2 = null;
	 try
	  {
		out2  = FileUtil.getFileOutputStream( path +"/"+ file);//change
		out2.write(out1.toByteArray());
	    out2.close();
	    err=0;
	  }
	  catch( Exception e )
	  {  /** au cas ou l'utilisateur a interrompu le telechargement
	      * assurer fermeture du fichier out
	      */
	      e.printStackTrace();
	     err=-1;
	     if(out2 != null )
	     try { out2.close();
	           /** A voir je ne suis pas trop sur (Alban **/
	           new File( path +"/"+ file).delete();
			  

	         }
	     catch( Exception ee ) {
	    	 e.printStackTrace();
	     }
		 err=-1;
	 }
	return(err);
	}
String verifFichier(String fic,String col_fic[]){
	String r="";
	try {
		java.io.BufferedReader rdr = new java.io.BufferedReader(new	java.io.FileReader(fic));
		String strLine = rdr.readLine();
		//System.out.println("fic="+fic+"\nstrLine="+strLine);
		//out.write("strLine="+strLine.split("\t").length);
		//out.write("colonne_iris="+colonne_iris.length);
		
						
		String msg_verif = verifColonneFichier(col_fic,strLine.split("\t"));
		r = "<div class='normal' style='font-size:10pt;'><b>R�sultat du contr�le de fichier</b></div><br>";
		if(! msg_verif.equals("")){
			//r+="<div style='display:inline;color:red;font-family:arial;font-size:8pt;'>"+msg_verif+"</div>";
			r = msg_verif;
		}else{
			//r+="<div style='display:inline;color:#008000;font-family:arial;font-size:8pt;'><b>Fichier OK</b></div>";
			r = "";
		}
		return(r);
	} catch (Exception e) {
		return("-100");
	}
	
}
String verifColonneFichier(String[] col_a_verifier,String[] col_fichier){ 
	String err="";
	System.out.println("verifColonneFichier : "+col_a_verifier.length+"=========="+col_fichier.length);
	if(col_a_verifier.length != col_fichier.length){
		err = "-1";
	}else{
		String msg2 ="";
		for(int i=0;i<col_a_verifier.length;i++){
			System.out.println(col_a_verifier[i]+"=========="+col_fichier[i]);
			String col = col_fichier[i];
			if( col.startsWith("\"")){	//enlever guillement
				col = col.substring(1);	
			}
			if( col.endsWith("\"")){	//enlever guillement
				col = col.substring(0,col.length()-1);	
			}
			if(!col_a_verifier[i].trim().equalsIgnoreCase(col.trim())){
				int i2=i+1;
				//msg2+="<tr><td style='border-right:1px solid silver;border-bottom:1px solid silver;'>"+i2+"</td><td style='border-right:1px solid silver;border-bottom:1px solid silver;'>&nbsp;" + col+"</td><td style='border-right:1px solid silver;border-bottom:1px solid silver;'>&nbsp;"+col_a_verifier[i]+"</td></tr>";
				err = "-2";
			}
		}
		if(!msg2.equals("")){
			/*err = "Colonne(s) inconnue(s) <br><br><table width='100%' border='0' cellspacing='0' cellpadding='0' style='border-left:1px solid silver;border-top:1px solid silver;font-family:arial;font-size:8pt;text-align:center;;'>";
			err+="<tr><td style='border-right:1px solid silver;border-bottom:1px solid silver;'><b>Position</b></td>";
			err+="<td style='border-right:1px solid silver;border-bottom:1px solid silver;'><b>Colonne trouv�e</b></td>";
			err+="<td style='border-right:1px solid silver;border-bottom:1px solid silver;'><b>Colonne attendue</b></td></tr>";
			err+="" + msg2 + "</table>";*/
			//err = "-3";
		}
	}
	/*if(!err.equals("")){
		err = "<b>ATTENTION ! </b>" + err;
	}*/
	return(err);
}%>