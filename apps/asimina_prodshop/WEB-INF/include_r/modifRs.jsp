<%!com.etn.lang.ResultSet.Set Calcul(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rsTableau,String colonne_r,String ligne_r,String cpt3){
    //System.out.println("      ,asdaqfasf               "+ colonne_r+ ligne_r+","+ cpt3);
    //System.out.println("$$$$$$$"+colonne_r +"@,\n@"+ ligne_r+"@,\n@"+ cpt3);
        String les_colonnes = "";
        
        if(!"".equals(colonne_r)){
                les_colonnes = (ligne_r.startsWith(",")?ligne_r:","+ligne_r)+","+colonne_r+","+cpt3;
                   //les_colonnes = colonne_r+(ligne_r.startsWith(",")?ligne_r:","+ligne_r)+cpt3;
        }else{
            les_colonnes = ligne_r+","+cpt3;
        }
 //   out.println("les_colonnes="+les_colonnes.replaceAll(",","--"));
        //if(1==1)return;
    
    
les_colonnes = les_colonnes.replaceAll(",","--");
System.out.println("les_colonnes ====================>"+les_colonnes);
if( les_colonnes.startsWith("--")){
        les_colonnes = les_colonnes.substring(2);
}
    
    rsTableau.moveFirst();

    java.util.HashMap total_p = new java.util.HashMap();
    
    String tab_cpt3[] = les_colonnes.toUpperCase().split("--");
    

    java.util.ArrayList<String> ar = new java.util.ArrayList<String>();
    for(int j=0;j < tab_cpt3.length;j++){
         System.out.println("=====================tab_cpt3["+j+"]"+tab_cpt3[j]);  
        if( !ar.contains(tab_cpt3[j]) ){
                  if(!tab_cpt3[j].equals("")){
                        ar.add(tab_cpt3[j]);
                  }
          }
    }
    
    tab_cpt3 =  ar.toArray( new String[ar.size()] );
    
    String les_cols = "";
    for(int k=0;k<tab_cpt3.length;k++){
        if( tab_cpt3[k].toUpperCase().startsWith("TX_")){
                les_cols+=","+tab_cpt3[k].toUpperCase().replaceAll("TX_","");
        }
    }
//    System.out.println("=========les_cols"+les_cols);
    String tab_cols[]=les_cols.split(",");

    java.util.HashMap<String,Byte> typeCol = getTypeCol(rsTableau);
    /*java.util.HashMap<String,Byte> typeCol = new java.util.HashMap<String,Byte>();
    for(int c=0;c<tab_cols.length;c++){
        if( rsTableau.indexOf(tab_cols[c])>-1){
                typeCol.put(""+tab_cols[c],rsTableau.types[rsTableau.indexOf(tab_cols[c])]);
        }
    }*/
    

    
    rsTableau.moveFirst();
            while(rsTableau.next()){
                for(int k=0;k<tab_cols.length;k++){
                concat_valeur_numeric(total_p,"TX_"+tab_cols[k],rsTableau.value(rsTableau.indexOf(tab_cols[k])),2);
                }
            }
    
            //filtrer la requete 
            com.etn.lang.ResultSet.ExResult exRs = new com.etn.lang.ResultSet.ExResult(null,tab_cpt3,9,10);	
            rsTableau.moveFirst();
            while(rsTableau.next()){
                //System.out.println("==>"+rs.value(rs.indexOf("SUM(NB_1__DEMANDE)")));
                exRs.add();
            for(int k=0;k<tab_cpt3.length;k++){
                String v=tab_cpt3[k];
                //System.out.println("les_colonnes2["+k+"]="+les_colonnes2[k]+"==>"+rs.value(v));
                if( v.startsWith("TX")){
                        //exRs.set(k,""+Double.parseDouble(rsTableau.value(rsTableau.indexOf(v.replaceAll("TX_",""))))*20);		
//	    		out.println(rsTableau.value(rsTableau.indexOf(v.replaceAll("TX_","")))+"======="+total_p.get(v));
                        exRs.set(v,calcul2(rsTableau.value(rsTableau.indexOf(v.replaceAll("TX_",""))),(total_p.get(v)==null?"0.0":""+total_p.get(v))));
                }else{
                   /* System.out.println("rsTableau.indexOf(v)="+rsTableau.indexOf("COUNT(CUSTOMER.`NATIONALITY`)")+" rsTableau.value(rsTableau.indexOf(v))="+rsTableau.value(rsTableau.indexOf(v))+" v="+v+" 2="+rsTableau.value("COUNT(CUSTOMER.`NATIONALITY`)")+" 4="+rsTableau.value("NATIONALITY"));
                   System.out.println(rsTableau.ColName[0]);
                    System.out.println(rsTableau.ColName[1]);
                    System.out.println(rsTableau.ColName[2]);*/
                        String tempCheckString="";
                        if(rsTableau.indexOf(v)==-1)
                            {
                            for(int zz=0;zz<rsTableau.ColName.length;zz++)
                            {
                                String tempColumnName=rsTableau.ColName[zz];
                                tempColumnName=tempColumnName.replaceAll("`","");
                                
                                String beforeBrack=tempColumnName.substring(0,tempColumnName.indexOf("(")+1);
                                int dotIndex=tempColumnName.indexOf(".");
                                if(dotIndex==-1){
                                    
                                    }
                                else{
                                    tempColumnName=beforeBrack+tempColumnName.substring(dotIndex+1);
                                }
                                
                                
                               
                                
                                if(tempColumnName.equals(v))
                                {
                                    tempCheckString=rsTableau.value(rsTableau.indexOf(rsTableau.ColName[zz]));
                                    break;
                                }
                            }
                        }else
                            {
                            tempCheckString=rsTableau.value(rsTableau.indexOf(v));
                        }


                        exRs.set(k,tempCheckString);
                }
	    	
	
            }
                exRs.commit();
            }
            rsTableau.moveFirst();


	    
          /*  for(int c2 = 0;c2<rsTableau.Cols;c2++){
                if( typeCol.get(rsTableau.ColName[c2])!=null){
                        rsTableau.types[c2] = (byte) typeCol.get(rsTableau.ColName[c2]);
                }
            }
            */
	    
	    
            rsTableau =  new com.etn.lang.ResultSet.ItsResult( exRs.getXdr() ); // YAHAN MASLA HAI
            
            putTypeCol(rsTableau,typeCol);
            rsTableau.moveFirst();
            return(rsTableau);

}%>
<%!com.etn.lang.ResultSet.Set Tri(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rs,String[] vertical2){

        java.util.HashMap<String,Byte> typeCol = getTypeCol(rs);
        int date1 = 0;
        int date2 = 0; // ne pas trié une deuxième fois la date
        for(int k=0; k < rs.Cols;k++){
                if(rs.ColName[k].toUpperCase().indexOf("PSDATE")!=-1){
                        date1++;
                }
        }
	
        byte sort3[] = new byte[vertical2.length+(date1>0?1:0)];


        int cpt3=0;
        for(int b=0; b < vertical2.length; b++){
                for(int k=0; k < rs.Cols;k++){
                        if(rs.ColName[k].equalsIgnoreCase(""+vertical2[b])){  // || rs.ColName[k].toUpperCase().indexOf("PSDATE")!=-1 
                                //System.out.println("Tri colonne "+rs.ColName[k]+"  ====================>"+k);
                                sort3[b] = (byte)k;
                                cpt3++;
                                if(rs.ColName[k].toUpperCase().indexOf("PSDATE")!=-1){
                                        date2++;
                                }
                        }
                }
        }
	
        if(date2 == 0){
                for(int k=0; k < rs.Cols;k++){
                        if(rs.ColName[k].toUpperCase().indexOf("PSDATE")!=-1){
                                sort3[cpt3] = (byte)k;
                                //System.out.println("Tri colonne "+rs.ColName[k]+"  ====================>"+k);
                        }
                }
        }
	
        com.etn.lang.ResultSet.ArraySet ar_1 = new com.etn.lang.ResultSet.ArraySet(rs);

        /***************	Trier des dates	*****************/
        for(int c=0;c<ar_1.Cols;c++){
                if(ar_1.ColName[c].indexOf("PSDATE")!=-1 ){
                        if( ! ar_1.ColName[c].equalsIgnoreCase("MOIS(PSDATE)") &&  ! ar_1.ColName[c].equalsIgnoreCase("SEMAINE(PSDATE)") ){
                                ar_1.types[c] = com.etn.lang.XdrTypes.DATE;
                        }
                }
        }
        /***************	Trier des dates	*****************/


        com.etn.lang.ResultSet.SortArray sa_1 = new com.etn.lang.ResultSet.SortArray(ar_1,sort3,com.etn.lang.ResultSet.SortArray.NOCASE);	
        com.etn.lang.ResultSet.ExResult ex_1 = new com.etn.lang.ResultSet.ExResult(null,ar_1.ColName,9,10);	
        while(sa_1.next()){
        ex_1.add();
            for(int k=0;k<sa_1.Cols;k++){
                ex_1.set(k,sa_1.value(k));
            }
        ex_1.commit();
        }
        rs = new com.etn.lang.ResultSet.ItsResult(ex_1.getXdr());
        putTypeCol(rs,typeCol);
        rs.moveFirst();
        return(rs);
}%>
<%!com.etn.lang.ResultSet.Set Limit(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rs,int i_limit){
        //System.out.println("Limit");
	
        java.util.HashMap<String,Byte> typeCol = getTypeCol(rs);
        if(rs!=null){
                com.etn.lang.ResultSet.ExResult ex_1 = new com.etn.lang.ResultSet.ExResult(null,rs.ColName,9,10);
                //System.out.println("rs.rs.Rows="+rs.rs.Rows+"==i_limit="+i_limit);
        if( rs.rs.Rows > i_limit){

                for(int i=0;i<i_limit;i++){
                        rs.next();
                        ex_1.add();
                                for(int k=0;k<rs.Cols;k++){
                                        ex_1.set(k,rs.value(k));
                        }
                        ex_1.commit();
                }
        }
        rs = new com.etn.lang.ResultSet.ItsResult(ex_1.getXdr());
        //System.out.println("rs.rs.Rows après="+rs.rs.Rows);
        putTypeCol(rs,typeCol);
        rs.moveFirst();
        }
        return(rs);
}%>

<%!

com.etn.lang.ResultSet.Set dashboardColFilter(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rs,String filterColName,java.util.HashSet <String> filterColValues){
        
	if (rs != null) {
            java.util.HashMap<String, Byte> typeCol = getTypeCol(rs);
            rs.moveFirst();
            com.etn.lang.ResultSet.ExResult ex_1 = new com.etn.lang.ResultSet.ExResult(null, rs.ColName, 9, 10);
            //System.out.println("rs.rs.Rows="+rs.rs.Rows+"==i_limit="+i_limit);

            while(rs.next()){
                
                boolean fl_colValueInSet = false;
                for (int k = 0; k < rs.Cols; k++) {

                    String colName = rs.ColName[k];
                    if (colName.indexOf("(") != -1) {
                        colName = colName.substring(colName.indexOf("(") + 1);
                        colName = colName.substring(0, colName.indexOf(")"));
                    }
                    
                    String val = rs.value(k);
                    System.out.println("ColName in set=" + colName);
                    System.out.println("value in set=" + val);

                    if (val != null) {
                        val = val.toLowerCase();
                        if ((colName).equalsIgnoreCase(filterColName) && filterColValues.contains(val)) {
                            /*
                             * ex_1.add(); //most probably adding new row.
                             * ex_1.set(k, rs.value(k));
                            ex_1.commit();
                             */
                            fl_colValueInSet = true;
                        }
                    }
                }
                if (fl_colValueInSet) {
                    ex_1.add(); //most probably adding new row.
                    for (int k = 0; k < rs.Cols; k++) {
                        ex_1.set(k, rs.value(k));
                    }
                    ex_1.commit();
                }
                //rs.next();
            }
            rs = new com.etn.lang.ResultSet.ItsResult(ex_1.getXdr());
            //System.out.println("rs.rs.Rows après="+rs.rs.Rows);
            putTypeCol(rs, typeCol);
            rs.moveFirst();
        }
        return (rs);
}
%>

<%!com.etn.lang.ResultSet.Set ForcerTri(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rs,String col,String type){
        //System.out.println("ForcerTri");
        byte sort3[] = new byte[1];
        java.util.HashMap<String,Byte> typeCol = getTypeCol(rs);
        col = col.replaceAll("`","").toUpperCase();
	
        int cpt3=0;
        for(int k=0; k < rs.Cols;k++){
                //System.out.println("ForcerTri (col)='"+rs.ColName[k]+"'==>'"+col.replaceAll("`","").toUpperCase()+"'");
                if(rs.ColName[k].equalsIgnoreCase(""+col)){
                        //System.out.println("ForcerTri2 (col)='"+rs.ColName[k]+"'==>'"+col.replaceAll("`","").toUpperCase()+"'");
                        rs.types[k] = com.etn.lang.XdrTypes.DOUBLE;	
                        sort3[cpt3] = (byte)k;
                        cpt3++;
                }
        }
        //System.out.println("ForcerTri ==>"+cpt3);
        com.etn.lang.ResultSet.ArraySet ar_1 = new com.etn.lang.ResultSet.ArraySet(rs);
	
        int c = com.etn.lang.ResultSet.SortArray.NOCASE;
        if(type.equals("desc")){
                c |=com.etn.lang.ResultSet.SortArray.DESC;
        }
        com.etn.lang.ResultSet.SortArray sa_1 = new com.etn.lang.ResultSet.SortArray(ar_1,sort3,c);	
 
        /*for(int j=0;j < sa_1.Cols;j++){
                System.out.println( sa_1.ColName[j]+"\t");
          }
        System.out.println("\n");
        while(sa_1.next()){
                for(int n1=0;n1<sa_1.Cols;n1++){
                        System.out.println(""+sa_1.value(n1)+"\t");
                }
                System.out.println("\n");
        }
        sa_1.moveFirst();*/
	
        com.etn.lang.ResultSet.ExResult ex_1 = new com.etn.lang.ResultSet.ExResult(null,ar_1.ColName,9,10);	
	
        //System.out.println(""+new String(sa_1.rs.data));
	
        while(sa_1.next()){
            ex_1.add();
            for(int k=0;k<sa_1.Cols;k++){
                ex_1.set(k,sa_1.value(k));
            }
            ex_1.commit();
        }
        rs = new com.etn.lang.ResultSet.ItsResult(ex_1.getXdr());
        putTypeCol(rs,typeCol);
        rs.moveFirst();
        return(rs);
}%>
<%!com.etn.lang.ResultSet.Set modifRs(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rsTableau,java.util.ArrayList<filtre_requete> f_requete,String colonne_r,String ligne_r,String cpt3,java.util.HashMap options){
   
    /*
    System.out.println();
    System.out.println("yes!!");
    System.out.println();
    */
       
        
    
        if( f_requete.size() > 0){
          rsTableau = filtreResult(Etn,rsTableau,rsTableau.ColName,f_requete);
         }
	
        //rajouter la colonne de trie avant modif du rs
        if( options.get("forcer_tri")!=null){
                  if(! options.get("forcer_tri").equals("")){
                        colonne_r = colonne_r + (colonne_r.equals("")?"":",")+options.get("forcer_tri").toString();
                  }
        }
        //rsTableau.moveFirst();
        /*while (rsTableau.next()) {
                    String tempRow="";
                                for (int p = 0; p < rsTableau.Cols; p++) {
                                    tempRow+=rsTableau.value(p)+" ";
                                    //System.out.println(rsTableau.value(p) + "####");
                                }

                                System.out.println(tempRow+" GGG2");
                            }
                rsTableau.moveFirst();
        System.out.println("Calcul say pehlay#################################################################");*/
    rsTableau = Calcul(Etn,rsTableau,colonne_r,ligne_r,cpt3);
    rsTableau = Tri(Etn,rsTableau,ligne_r.split(","));
   
   // out.write("==>'"+options.get("forcer_tri")+"'<br>");
  //  out.write("==>'"+options.get("limit_tab")+"'");
    if( options.get("forcer_tri")!=null){
          if(! options.get("forcer_tri").equals("")){
                rsTableau = ForcerTri(Etn,rsTableau,""+options.get("forcer_tri"),(options.get("forcer_tri2")==null?"asc":""+options.get("forcer_tri2")));
          }
        }
        if( options.get("limit_tab")!=null){
                if(! options.get("limit_tab").equals("0")){
                        rsTableau = Limit(Etn,rsTableau,Integer.parseInt((options.get("limit_tab")==null?""+rsTableau.rs.Rows:""+options.get("limit_tab")),10));
                }
        }
        return(rsTableau);
}%>
<%!String TriCombo(String a,String[] valeur,String[] tab){
        java.lang.StringBuffer buf = new StringBuffer();
	
        if(!a.equalsIgnoreCase("annee(psdate)") && !a.equalsIgnoreCase("mois(psdate)") && !a.equalsIgnoreCase("semaine(psdate)") &&
                        !a.equalsIgnoreCase("jour(psdate)") &&	!a.equalsIgnoreCase("heure(psdate)") &&	!a.equalsIgnoreCase("minute(psdate)")
        ){ 
 java.util.Arrays.sort(valeur, new TriComparator());
 

 for(int v2=0;v2 < valeur.length;v2++){
         buf.append("<option "+(isPresent(tab,valeur[v2])==0?"":"selected")+" value=\""+valeur[v2]+"\">"+valeur[v2]);
 }
 
}else{
        com.etn.lang.ResultSet.ExResult exRs = new com.etn.lang.ResultSet.ExResult(null,a.split(","),9,10);	
        for(int v=0;v<valeur.length;v++){
                exRs.add();
                //System.out.println("les_colonnes2["+v+"]="+valeur[v]+"==>"+valeur[v]);
                exRs.set(a,valeur[v]);
                exRs.commit();
        }
	
        com.etn.lang.ResultSet.Set rs2 =  new com.etn.lang.ResultSet.ItsResult( exRs.getXdr() );
	
        byte sort[] = new byte[1];
        sort[0] = (byte)0;
        com.etn.lang.ResultSet.ArraySet ar = new com.etn.lang.ResultSet.ArraySet(rs2);

	
        for(int c=0;c<ar.Cols;c++){
                if(ar.ColName[c].indexOf("PSDATE")!=-1 ){
                        if( ! ar.ColName[c].equalsIgnoreCase("MOIS(PSDATE)") &&  ! ar.ColName[c].equalsIgnoreCase("SEMAINE(PSDATE)") ){
                                ar.types[c] = com.etn.lang.XdrTypes.DATE;
                        }
                }
        }
        com.etn.lang.ResultSet.SortArray sa1 = new com.etn.lang.ResultSet.SortArray(ar,sort,com.etn.lang.ResultSet.SortArray.NOCASE);
         while(sa1.next()){
           for(int k=0;k<sa1.Cols;k++){
                   buf.append("<option "+(isPresent(tab,sa1.value(k))==0?"":"selected")+" value=\""+sa1.value(k)+"\">"+sa1.value(k));
           }
         }
}
return(buf.toString());
}%>
<%//Récuperer les types de colonnes %>
<%!java.util.HashMap<String,Byte> getTypeCol(com.etn.lang.ResultSet.Set rs){
    
        java.util.HashMap<String,Byte> h = new java.util.HashMap<String,Byte>();
        for(int u=0;u<rs.Cols;u++){
                h.put(rs.ColName[u],rs.types[u]);
                //System.out.println("getTypeCol==>"+rs.ColName[u]+"==>"+rs.types[u]);
        }
        return(h);
}%>
<%//renseigne les types de colonnes %>
<%!java.util.HashMap<String,Byte> putTypeCol(com.etn.lang.ResultSet.Set rs,java.util.HashMap<String,Byte> h){
        for(int u=0;u<rs.Cols;u++){
                if(h.get(rs.ColName[u])!=null){
                        rs.types[u] = h.get(rs.ColName[u]);
                        //System.out.println("putTypeCol==>"+rs.ColName[u]+"==>"+rs.types[u]);
			
                }
        }
        return(h);
}%>
<%!com.etn.lang.Xdr CumulCol(com.etn.lang.ResultSet.Set sa1,String col_group_by2,String col_group_select2){

        java.util.HashMap<String,Byte> typeCol = getTypeCol(sa1);
	
        /*enleve les crochets pour le KPI*/
        col_group_select2 = col_group_select2.replaceAll("\\[","");
        col_group_select2 = col_group_select2.replaceAll("\\]","");
        col_group_select2 = col_group_select2.replaceAll("`","");
        /*enleve les crochets pour le KPI (fin)*/

        col_group_by2 = col_group_by2.toUpperCase();
        col_group_select2 = col_group_select2.toUpperCase();
	
        String col_group_by3[] = col_group_by2.split(",");
        col_group_by2 = "";

        if(col_group_by2.charAt(0)==','){
                col_group_by2 = col_group_by2.substring(1);
        }
        String col_group_by_bis = col_group_by2;

	
        if(col_group_select2.charAt(0)==','){
                col_group_select2 = col_group_select2.substring(1);
        }
        if(col_group_by2.charAt(0)==','){//????
                col_group_by2 = col_group_by2.substring(1);
        }
        //System.out.println("col_group_select2="+col_group_select2);

        String les_colonnes = col_group_by2;
		
        /*if(col_group_by2.charAt(0)==','){//????
                col_group_by2 = col_group_by2.substring(1);
        }*/
	
        les_colonnes += (les_colonnes.endsWith(",")==false?",":"") + col_group_select2;
	
        if(les_colonnes.charAt(0)==','){//????
                les_colonnes = les_colonnes.substring(1);
        }
	
	
        String les_colonnes_bis = col_group_by_bis+","+ col_group_select2; 

        String les_colonnes2[] = col_group_by2.split(",");

        com.etn.lang.ResultSet.ExResult ex = new com.etn.lang.ResultSet.ExResult(null, les_colonnes_bis.split(","),9,10 );
        String col_group_by[] = col_group_by2.split(",");
        String col_group_select[] = col_group_select2.split(",");

        //System.out.println("les_colonnes="+les_colonnes);


        int i=0;
        String key = "";
        String key2="";
        java.util.HashMap h = new java.util.HashMap();
        java.util.HashMap h3 = new java.util.HashMap();

        /*	Recupérer les numérateurs et dénominateurs de chaque KPI*/


        while(sa1.next()){
        key = "";
        for(int v = 0;v< col_group_by.length;v++){
                key+="\t"+sa1.value(col_group_by[v]);		//debut clef hashmap
        }
		
                for(int v2 = 0;v2<col_group_select.length;v2++){
                        if( typeCol.get(col_group_select[v2])!=null){
				
                                int typV = 2;
                                        if( typeCol.get(col_group_select[v2]) == com.etn.lang.XdrTypes.INT){
                                                typV = 1;
                                        }else{
                                                if( typeCol.get(col_group_select[v2]) == com.etn.lang.XdrTypes.DOUBLE && typeCol.get(col_group_select[v2]) == com.etn.lang.XdrTypes.NUMERIC){
                                                        typV = 2;
                                                }
                                        }
                                concat_valeur_numeric(h3,key+"\t"+col_group_select[v2],"0",typV);
                        }
                }
        }
	
        /*	Recupérer les numérateurs et dénominateur de chaque KPI (fin)	*/

        sa1.moveFirst();
        java.util.HashMap h2 = new java.util.HashMap();

        /*	Constituer le resultset */
        while(sa1.next()){
                key2="";
                key="";
                for(int v = 0;v< les_colonnes2.length-1;v++){
                        key+="\t"+sa1.value(les_colonnes2[v]);		//debut clef hashmap
                }

                if( h2.get(""+key)==null){
                        ex.add();
                        key="";
                        for(int v = 0;v< col_group_by.length-1;v++){
                                key+="\t"+sa1.value(col_group_by[v]);		//debut clef hashmap
                                ex.set(col_group_by[v],sa1.value(col_group_by[v]));
                        }
                        for(int k=0;k<col_group_select.length;k++){
                                        ex.set(col_group_select[k],""+getValHashMap(h,key+"\t"+col_group_select[k]));
                        }
                        ex.commit();
                        h2.put(""+key,""+key);
                }
        }

        //trier le resultset

        for(int c=0;c<ex.Cols;c++){
                if(ex.ColName[c].indexOf("PSDATE")!=-1){
                        if( ex.ColName[c].indexOf("MOIS")==-1 && ex.ColName[c].indexOf("SEMAINE")==-1 && ex.ColName[c].indexOf("HEURE")==-1){
                        ex.types[c] = com.etn.lang.XdrTypes.DATE;
                        }
                }
        }
/*
for(int c=0;c<ex.Cols;c++){
        System.out.println("'"+ex.ColName[c]+"'==>"+ ex.ColName[c].indexOf("HEURE"));         
}*/


        com.etn.lang.ResultSet.ArraySet ar = new com.etn.lang.ResultSet.ArraySet( ex.getXdr() );
        byte tri[] = new byte[les_colonnes2.length];
        for(int d=0;d<les_colonnes2.length;d++){
                tri[d]= (byte)d;
        }
        com.etn.lang.ResultSet.Set rsTri = new com.etn.lang.ResultSet.SortArray(ar,tri,com.etn.lang.ResultSet.SortArray.NOCASE);
        putTypeCol(sa1,typeCol);
	
        //trier le resultset (fin)


        com.etn.lang.ResultSet.ExResult ex2 = new com.etn.lang.ResultSet.ExResult(null, les_colonnes_bis.split(","),9,10 );
        while(rsTri.next()){
                ex2.add();
                for(int i2=0;i2<rsTri.Cols;i2++){
                        ex2.set(rsTri.ColName[i2],rsTri.value(i2));
                }
                ex2.commit();
        }

        sa1.moveFirst();
        sa1 = null;
        return(ex2.getXdr());


}%>


<%!com.etn.lang.ResultSet.Set forcerTri3(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rs,String col, String forcer_tri3){
        //System.out.println("ForcerTri");
        byte sort3[] = new byte[1];
        java.util.HashMap<String,Byte> typeCol = getTypeCol(rs);
        col = col.replaceAll("`","").toUpperCase();

        double oVar=0;

        rs.moveFirst();
        double sum=0;
        double n=0;
        double sqr_sum=0;
        while(rs.next()){
            try{
                
                String temp=rs.value(col);
                Double d1=Double.parseDouble(temp);
                sum+=d1;
                
                n=n+1;
                sqr_sum=sqr_sum+d1*d1; //for variance
            }
            catch(Exception ex){
                System.out.println("Error:"+ex.toString());
            }
        }

        if(forcer_tri3.equals("aAvg")||forcer_tri3.equals("bAvg")){
            oVar=sum/n;
        }

        if(forcer_tri3.equals("aVar")||forcer_tri3.equals("bVar")){
            double mean=sum/n;
            oVar=(sqr_sum - sum*mean)/(n - 1);
        }
        
        String[] colArray = new String[rs.Cols];
        for(int i=0; i<rs.Cols; i++){
            colArray[i] = rs.ColName[i];
        }
        //System.out.println("avg="+oVar);
        com.etn.lang.ResultSet.ExResult ex_1 = new com.etn.lang.ResultSet.ExResult(null,colArray,9,10);

        rs.moveFirst();

        while(rs.next()){

            if(    (forcer_tri3.equals("aAvg") && (Double.parseDouble(rs.value(col)) < oVar) )
                || (forcer_tri3.equals("bAvg") && (Double.parseDouble(rs.value(col)) > oVar) )
                || (forcer_tri3.equals("aVar") && (Double.parseDouble(rs.value(col)) < oVar) )
                || (forcer_tri3.equals("bVar") && (Double.parseDouble(rs.value(col)) > oVar) )

                ){
                continue;
            }

            ex_1.add();
            for(int k=0;k<rs.Cols;k++){
                ex_1.set(k,rs.value(k));
            }
            ex_1.commit();
        }
        rs = new com.etn.lang.ResultSet.ItsResult(ex_1.getXdr());
        putTypeCol(rs,typeCol);
        rs.moveFirst();
        return(rs);
}%>
