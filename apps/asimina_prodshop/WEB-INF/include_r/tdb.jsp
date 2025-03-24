<%@ page import="java.text.*"%>
<%!String replaceVide(String s2){ 
        String s = "";
        if( s2 == null){
                s = "0.0";
        }else{
                if( s2.equals("")){
                        s = "";
                }else{
                        s = s2;
                }
        }
        s = s.replace(',','.');
        return(s);
}%>

<%!

public void incrementValue(DefaultCategoryDataset d,String value, Comparable rowKey,Comparable columnKey) {
        //double existing = 0.0;
        //if(! value.equals("")){
        //double value2 = Double.parseDouble(value);
        /*try{
                Number n = d.getValue(rowKey, columnKey);

                if (n != null) {
                        existing = n.doubleValue();
                }
        }catch(Exception e){
                 existing = 0.0;
        }*/
    
         //d.setValue(existing + value2, rowKey, columnKey);
    
        //}

    java.util.HashSet<String> valueSet=new java.util.HashSet<String>();
    incrementValue(d,value,rowKey,columnKey,valueSet);

}


public void incrementValue(DefaultCategoryDataset d,String value, Comparable rowKey,   Comparable columnKey, java.util.HashSet<String> valSet) {
        double existing = 0.0;
        if(! value.equals("")){
        double value2 = Double.parseDouble(value);
        /*try{
                Number n = d.getValue(rowKey, "Others");
		
                if (n != null) {
                        existing = n.doubleValue();
                }
        }catch(Exception e){
                 existing = 0.0;
        }
         */

       /* System.out.println();
        System.out.println("####ROWKEY="+rowKey);
        System.out.println("####ColumnKEY="+columnKey);*/
        
        if(!valSet.isEmpty() && valSet.contains(columnKey)){
            //d.setValue(existing + value2, rowKey, "Others");
            d.setValue(existing + value2, rowKey, "Others");
            
        }
        else{
            d.setValue(value2, rowKey, columnKey);
        }
        
        }
}

%>
<%
//Reconstruction du resultset si la granularité de la requete n'est pas égale à la sélection Champ de ligne + Champ de colonne dans TDB

%>
<%!com.etn.lang.ResultSet.ItsResult Cumul(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rs,String key1,String key2,String[] valeur2,String date){
       
    System.out.println("~~~ in old Date Filter ~~~");
    
       DateFormat df = new SimpleDateFormat("dd/MM/yyyy");
       Date toDate=null;
       Date fromDate=null;
       String []dates={};

        if(date!=null){
            dates=date.split(",");

            try{

            toDate=df.parse(dates[0]);
            fromDate=df.parse(dates[1]);
            }
            catch (ParseException e){
               e.printStackTrace();
            }

        }
         
        boolean fl_matched=false;
        

        /*copying old cumul*/



String total1 = "";

java.util.HashMap total = new java.util.HashMap();		//faire le cumul
java.util.HashMap nbr_key = new java.util.HashMap();		//compter le nombre fois que la clef apparait
java.util.HashMap typeValeur = new java.util.HashMap();		//type de la valeur : ratio ...

int cpt = 1;
if(! key2.equals("")){	//si champs de colonne
        cpt++;
}
String liste_valeur = "";

while( rs.next()){
        
        
        String k1 =rs.value(key1);
        
        String k2 = (key2.equals("")?"":rs.value(key2));


        Date k1Date=null;
        if(k1!=null){

        try {
            k1Date = df.parse(k1);
            
        } catch (ParseException e) {
            e.printStackTrace();
        }

  
        if(k1Date!=null){
            if(k1Date.compareTo(toDate)>=0 && k1Date.compareTo(fromDate)<=0){
                fl_matched=true;
            }
        }


        }
        
        if(fl_matched){
            for(int i2=cpt;i2<valeur2.length;i2++){

                liste_valeur+=",'"+valeur2[i2]+"'";
                String key3=(!key2.equals("")?k1+";"+k2+";"+valeur2[i2].toUpperCase().trim():k1+";"+valeur2[i2].toUpperCase().trim());

                concat_valeur_numeric(total,key3.trim(),rs.value(valeur2[i2].trim()),2);
                concat_valeur_numeric(nbr_key,key3.trim(),"1",1);

            }
        }

        
        }

        
String sql="";

if( liste_valeur.startsWith(",") ){
        liste_valeur = liste_valeur.substring(1);
}

//type de la valeur : ratio ...
if(! liste_valeur.equals("") ){
        com.etn.lang.ResultSet.Set rsListeKPI = Etn.execute(sql="select nomkpi,type from kpi where nomkpi in ("+liste_valeur+")");
        while(rsListeKPI.next()){
                typeValeur.put(""+rsListeKPI.value("nomkpi").trim().toUpperCase(),""+rsListeKPI.value("type").trim().toLowerCase());
        }
}
//System.out.println(""+sql);

com.etn.lang.ResultSet.ExResult exRs = new com.etn.lang.ResultSet.ExResult(null,valeur2,9,10);


String key_A="";

rs.moveFirst();
/*	Constituer le resultset */
while(rs.next()){
        fl_matched=false;

        String k1=rs.value(key1);
        Date k1Date=new Date();

         

        if(k1!=null){
            /*for(int i=0;i<dates.length;i++){
                if(k1.compareToIgnoreCase(dates[i])==0){
                    fl_matched=true;
                }
            }*/
            try {
                k1Date = df.parse(k1);

             } catch (ParseException e) {
                e.printStackTrace();
             }

            
            if(k1Date.compareTo(toDate)>=0 && k1Date.compareTo(fromDate)<=0){
                fl_matched=true;
            }

        }
        
        if(fl_matched){

        java.util.HashMap h2 = new java.util.HashMap();
        key_A="";

        if(! key2.equals("")){
                key_A = rs.value(key1) + (key2.equals("")?"":";"+rs.value(key2));
        }else{
                key_A = rs.value(key1) ;
        }
        for(int v = cpt;v< valeur2.length;v++){
                key_A+=";"+valeur2[v];		//debut clef hashmap

        //System.out.println("key_A="+key_A);
        if( h2.get(""+key_A)==null){
                exRs.add();
                key_A="";

                if(! key2.equals("")){
                        key_A = rs.value(key1) + (key2.equals("")?"":";"+rs.value(key2));
                        exRs.set(0,rs.value(key1));
                        exRs.set(1,rs.value(key2));
                }else{
                        key_A = rs.value(key1) ;
                        exRs.set(0,rs.value(key1));
                }

                        key_A+=";"+valeur2[v];		//debut clef hashmap

                        total1 = ( total.get(""+key_A)==null?"":""+total.get(""+key_A));

                        //System.out.println(key_A+"total1="+total1);

                        String typ1 = (typeValeur.get(""+valeur2[v])==null?"":""+typeValeur.get(""+valeur2[v]));
                        if( typ1.equals("ratio") ){
                                //System.out.println("nbr_key="+nbr_key.get(""+key_A)+"==>"+key_A);
                                total1 = calcul2(total1,(nbr_key.get(""+key_A)==null?"":""+nbr_key.get(""+key_A)));
                        }

                        exRs.set(valeur2[v],total1);

                exRs.commit();
                h2.put(""+key_A,""+key_A);
        }
        }
        //System.out.println("Key_A="+key_A);
        }//if fl_matched

        

}
/*	Constituer le resultset */

com.etn.lang.ResultSet.ItsResult rs2 =  new com.etn.lang.ResultSet.ItsResult( exRs.getXdr() );
rs2.moveFirst();
return(rs2);



        /***/

        
  }
%>


<%!com.etn.lang.ResultSet.ItsResult Cumul(com.etn.beans.Contexte Etn,com.etn.lang.ResultSet.Set rs,String key1,String key2,String[] valeur2){
  

String total1 = "";

java.util.HashMap total = new java.util.HashMap();		//faire le cumul
java.util.HashMap nbr_key = new java.util.HashMap();		//compter le nombre fois que la clef apparait
java.util.HashMap typeValeur = new java.util.HashMap();		//type de la valeur : ratio ...

int cpt = 1;
if(! key2.equals("")){	//si champs de colonne 
        cpt++;
}
String liste_valeur = "";

while( rs.next()){

        
        
        String k1 =rs.value(key1);
        String k2 = (key2.equals("")?"":rs.value(key2));
        /*
        System.out.println("---------old cumul---------");
        System.out.println("Key1="+key1);
        System.out.println("Key2="+key2);
        System.out.println("K1="+k1);
        System.out.println("K2="+k2);*/


        for(int i2=cpt;i2<valeur2.length;i2++){

                
                liste_valeur+=",'"+valeur2[i2]+"'";
                String key3=(!key2.equals("")?k1+";"+k2+";"+valeur2[i2].toUpperCase().trim():k1+";"+valeur2[i2].toUpperCase().trim());

               
                //System.out.println(key3+"====>"+"'"+rs.value(valeur2[i2].trim())+"'");
                concat_valeur_numeric(total,key3.trim(),rs.value(valeur2[i2].trim()),2);
                concat_valeur_numeric(nbr_key,key3.trim(),"1",1);
                //System.out.println("nbr_key1="+nbr_key.get(""+key3.trim())+"==>"+key3.trim());
        }
}	
String sql="";

if( liste_valeur.startsWith(",") ){
        liste_valeur = liste_valeur.substring(1);
}

//type de la valeur : ratio ...
if(! liste_valeur.equals("") ){
        com.etn.lang.ResultSet.Set rsListeKPI = Etn.execute(sql="select nomkpi,type from kpi where nomkpi in ("+liste_valeur+")");
        while(rsListeKPI.next()){
                typeValeur.put(""+rsListeKPI.value("nomkpi").trim().toUpperCase(),""+rsListeKPI.value("type").trim().toLowerCase());
        }
}
//System.out.println(""+sql);

for(int k=0;k<valeur2.length;k++){
    System.out.println("A=="+valeur2[k]);
}

com.etn.lang.ResultSet.ExResult exRs = new com.etn.lang.ResultSet.ExResult(null,valeur2,9,10);


String key_A="";

rs.moveFirst();
/*	Constituer le resultset */
while(rs.next()){
        java.util.HashMap h2 = new java.util.HashMap();
        key_A="";

        if(! key2.equals("")){
                key_A = rs.value(key1) + (key2.equals("")?"":";"+rs.value(key2));
        }else{
                key_A = rs.value(key1) ;
        }
        for(int v = cpt;v< valeur2.length;v++){
                key_A+=";"+valeur2[v];		//debut clef hashmap
	
        //System.out.println("key_A="+key_A);
        if( h2.get(""+key_A)==null){
                exRs.add();
                key_A="";
		
                if(! key2.equals("")){
                        key_A = rs.value(key1) + (key2.equals("")?"":";"+rs.value(key2));
                        exRs.set(0,rs.value(key1));
                        exRs.set(1,rs.value(key2));
                }else{
                        key_A = rs.value(key1) ;
                        exRs.set(0,rs.value(key1));
                }
		
                        key_A+=";"+valeur2[v];		//debut clef hashmap
			
                        total1 = ( total.get(""+key_A)==null?"":""+total.get(""+key_A));
		
                        //System.out.println(key_A+"total1="+total1);
			
                        String typ1 = (typeValeur.get(""+valeur2[v])==null?"":""+typeValeur.get(""+valeur2[v]));
                        if( typ1.equals("ratio") ){
                                //System.out.println("nbr_key="+nbr_key.get(""+key_A)+"==>"+key_A);
                                total1 = calcul2(total1,(nbr_key.get(""+key_A)==null?"":""+nbr_key.get(""+key_A)));
                        }
	
			
                        exRs.set(valeur2[v],total1);

                exRs.commit();
                
                
                h2.put(""+key_A,""+key_A);
        }
    }
       
}
/*	Constituer le resultset */

com.etn.lang.ResultSet.ItsResult rs2 =  new com.etn.lang.ResultSet.ItsResult( exRs.getXdr() );
rs2.moveFirst();
return(rs2);
}%>
