package com.etn.requeteur;



import com.etn.Client.Impl.ClientSql;
import com.etn.beans.Contexte;
import com.etn.lang.ResultSet.ArraySet;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

/**
* Source pour jdk 1.5...
* Sinon supprimer <...>
*/

import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Vector;
import java.util.HashMap;


public class makeSql {
	
	class column_filtre {
		String nomlogique;
		int type;
		String date1;
		String typeDB;
		String valbdd;
		String valihm;
		String diff="";
		
		public column_filtre( String nomlogique,int type,String date1,String typeDB,String valbdd,String valihm,String diff)
		{
		  this.nomlogique = nomlogique; this.type=type;this.date1=date1;this.typeDB=typeDB;this.valbdd=valbdd;this.valihm=valihm;this.diff=diff;
		}

		public column_filtre() {}


		}
		
	
	
	
	
	Qry qy;
	Variable v = new Variable();
	Util u = new Util();
	
	
	
	String ValBddIhm(String bdd[],String ihm[],String val){ 
		String r = "";
		for(int i=0;i<ihm.length;i++){
			System.out.println("ValBddIhm (ihm:"+ihm[i]+"==>bdd:"+bdd[i]+"=val==>"+val+"==>"+ihm[i].equalsIgnoreCase(val));
			if( ihm[i].equalsIgnoreCase(val)){
				String s = bdd[i];
				
				if(s.equals("--vide--")){
					s = "";
				}
				return(s);
			}
		}
		return("");
	}
	
	public int getServeur(){
		return(qy.serveur);
	}
	
	public String getError(){
		return((qy.getErr()==null?"":qy.getErr()));
	}
	
	boolean SiHeure(javax.servlet.http.HttpServletRequest req,String group_by){ 
		boolean b = false;
		String heure_1 = (req==null?"":req.getParameter("h1"));
		String heure_2 = (req==null?"":req.getParameter("h2"));
		
		if(heure_1==null) heure_1="";
		if(heure_2==null) heure_2="";
		
		int periode = 0;
		if(! group_by.equals("")){
			int g  = group_by.substring(1).split(",").length;
			String tab_group_by[] = group_by.substring(1).split(",");
			for(int g2=0;g2<g;g2++){
				if(tab_group_by[g2].indexOf("psdate")!=-1){
					if( tab_group_by[g2].indexOf("semaine")!=-1 || tab_group_by[g2].indexOf("annee")!=-1|| tab_group_by[g2].indexOf("jour")!=-1 
							||tab_group_by[g2].indexOf("mois")!=-1){
							periode = 1;
							
					}
				}
			}
		}
		System.out.println("changement periode="+periode);
		System.out.println("heure_1="+heure_1);
		System.out.println("heure_2="+heure_2);
		//if( periode == 1){
			if( (!"".equals(heure_1)) || (!"".equals(heure_2)) ){
				b = true;
			}
		//}
		System.out.println("SiHeure="+b);
	return(b);

	}
	
	String date_relative (String p1,String p2,String m,boolean heure){
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
	}
	
	

	String replaceKPI2(com.etn.lang.ResultSet.ArraySet a,String kpi){
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
	}
	
	public String[] sql(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String select1,String filtres,String group_by_h,String group_by_v,String type1,boolean filtre_table_u){
		
		String group_by = "";
		String eqpt_select="";
		String filtre_s="";
		String autre_sql="";
		String autre_sql2="";
		
		if( type1 == null) type1="";
		if(select1==null) select1="";
		if(filtres==null) filtres="";
		if(group_by_h==null) group_by_h="";
		if(group_by_v==null) group_by_v="";

		if(group_by_h.equals("")){
			group_by = group_by_v;
		}else{
			group_by = group_by_h + group_by_v;
			//group_by = group_by_v + group_by_h;
		}

		String group_by_2 = (group_by.equals("")?"":group_by.substring(1));
		
		if(request!=null){
			javax.servlet.http.HttpSession session =  request.getSession(true);	
			session.removeAttribute("variable_filtre");
			session.removeAttribute("variable_valeur");
			session.removeAttribute("les_variables");
		
		
		
		System.out.println("************************** VARIABLE ****************************************\n\n");
		
		
			System.out.println("************************** VARIABLE - FILTRE ****************************************\n\n");
			
			System.out.println("Avant remplacement : " + filtres);
			String str_l = v.liste_filtre_variable(filtres,request);
			System.out.println("Après remplacement : " + str_l);
			filtres = str_l;
			
			System.out.println("************************** VARIABLE - FILTRE - FIN ****************************************\n\n");
			
			
			System.out.println("************************** VARIABLE - SELECT  ****************************************\n\n");
			
			System.out.println("Avant remplacement : " + select1);
			String str_l2 = v.liste_valeur_variable(select1,request);
			System.out.println("Après remplacement : " + str_l2);
			select1 = str_l2;
			
			
			
			System.out.println("************************** VARIABLE - SELECT - FIN  ****************************************\n\n");
		
		}

			java.util.HashMap<String,String> h_select = new java.util.HashMap<String,String>();
			
			/*String sqlCompteur = "SELECT distinct concat(if(unite<>'',concat(unite,'('),'count('),'`',c.nomlogique,'`',if(unite<>'',')',')')) champ,c.champ champ2 ,c.nomlogique,dbtable,nom_table_ihm,valbdd,valihm ";
			sqlCompteur+="  FROM catalog c ";
			sqlCompteur+=" WHERE c.filtrable & "+select+" and valbdd <> '' and valihm <> ''";*/
			String sqlCompteur = "SELECT distinct concat(if(unite<>'',concat(unite,'('),'count('),'`',c.nomlogique,'`',if(unite<>'',')',')')) champ,c.champ champ2 ,c.nomlogique,dbtable,nom_table_ihm,valbdd,valihm ";
			sqlCompteur+="  FROM catalog c ";
			//sqlCompteur+=" WHERE  valbdd <> '' and valihm <> '' "; //and valbdd like 'sql:%' //c.filtrable & "+select+"
			sqlCompteur+=" WHERE  ((valbdd <> '' and valihm <> '') or valbdd like 'sql:%')"; //c.filtrable & "+select+"
			
			if( filtre_table_u ){
				if(! type1.equals("") ){
					sqlCompteur+= " and dbtable = "+escape.cote(type1)+"";
				}
			}

			Set rsCompteur = Etn.execute(sqlCompteur);
			while(rsCompteur.next()){
				h_select.put(""+rsCompteur.value("nomlogique")+"_bdd",rsCompteur.value("valbdd"));
				h_select.put(""+rsCompteur.value("nomlogique")+"_ihm",rsCompteur.value("valihm"));
			}
		
		
		System.out.println("************************** VARIABLE - FIN ****************************************\n\n");
		
		
		
		System.out.println("************************** KPI ****************************************\n\n");
		
		System.out.println("SELECT AVANT : " + select1);
		

		if(! select1.equals("")){
			String str_kpi = "";
			String v_kpi[] = select1.split(",");

			//Set rsKPI = Etn.execute("select concat('[',nomkpi"+suffixe_kpi+",']') as nomkpi"+suffixe_kpi+",formule from "+table_kpi+" where constructeur = '"+constructeur+"'");
			Set rsKPI = Etn.execute("select concat('[',nomkpi,']') as nomkpi,formule from kpi where constructeur = "+escape.cote(type1)+"");
			ArraySet ar = new ArraySet(rsKPI);
			ar.index("nomkpi");

			for(int v=0;v < v_kpi.length;v++){
				String kpi= v_kpi[v];
				if(! kpi.equals("")){
					String s2 = replaceKPI2(ar,v_kpi[v]);
					String kpi2 = kpi.replaceAll("\\[","").replaceAll("\\]","")+"";
					System.out.println("kpi renvoyé = "+kpi);
					if(s2.trim().equals(kpi2.trim())){
					//rien
						System.out.println("KPI " + s2 + " non trouvé.");
					}else{
						s2 += " as \""+kpi2+"\"";
					}
					
					
					str_kpi+= ","+ s2;
				}
			}
			
			select1 = str_kpi;
		}
		

		System.out.println("SELECT APRES : " + select1);
		System.out.println("\n\n************************** KPI ****************************************\n\n");
		
		
		System.out.println("************************** PARAMETRE RETOURNESQL2 ****************************************\n\n");
		System.out.println("FITLRES : "+filtres);
		System.out.println("AUTRE_SQL : "+autre_sql);
		System.out.println("AUTRE_SQL2 : "+autre_sql2);
		System.out.println("\n\n*************************** PARAMETRE RETOURNESQL2 ****************************************\n\n");
		
		String sql_filtres = retourneSQL2(filtres,group_by_h,group_by_v,filtre_s,autre_sql,autre_sql2,Etn,type1,filtre_table_u);
		String le_select="";
		
			
		le_select += (! "".equals(group_by)?""+group_by+"":"") ;
		le_select += (! "".equals(select1)?","+select1.substring(1):"");
		
		if(! le_select.equals("")){
			if( le_select.charAt(0) == ','){
				le_select = le_select.substring(1);
			}
		}
		
		String le_select3 = "";
		String le_select2[] = le_select.split(",");
		System.out.println("le_select =========>" + le_select3);
		for(int l=0;l<le_select2.length;l++){
			System.out.println("Replace for bdd ihm ==>" + le_select2[l]+"======>"+h_select.get(le_select2[l]+"_bdd"));
			if( h_select.get(le_select2[l]+"_bdd")!=null){
				if(! h_select.get(le_select2[l]+"_bdd").toString().equals("")){
					String bdd = ( h_select.get(le_select2[l]+"_bdd")==null?"":""+h_select.get(le_select2[l]+"_bdd"));
					String ihm = ( h_select.get(le_select2[l]+"_ihm")==null?"":""+h_select.get(le_select2[l]+"_ihm"));
					//le_select3 += (le_select3.equals("")?"":",")+ "SUBSTRING_INDEX(SUBSTRING_INDEX('"+ihm+"',',',FIND_IN_SET("+le_select2[l]+",'"+bdd+"')),',',-1) as "+le_select2[l];
					if( bdd.startsWith("sql")){
						le_select3 += (le_select3.equals("")?"":",")+ bdd.substring(4) + " as "+le_select2[l];
					}else{
						le_select3 += (le_select3.equals("")?"":",")+ "SUBSTRING_INDEX(SUBSTRING_INDEX('"+ihm+"',',',FIND_IN_SET("+le_select2[l]+",'"+bdd+"')),',',-1) as "+le_select2[l];
					}
				}
			}else{
				le_select3 +=(le_select3.equals("")?"":",")+ le_select2[l];
			}
		}
		le_select = le_select3;

	/*	Qry q = new Qry( Etn );
		java.util.HashMap h = new java.util.HashMap();
		h.put("type",""+(type1.equals("")?"":type1));
		h.put("having1",""+having);

		q.setMap(h);
	*/
		
		
	
		if(!group_by_2.equals("")){
			String g[] =  group_by_2.split(",",-1);
			group_by_2= "";
			for(int y=0;y<g.length;y++){
				group_by_2 += (group_by_2.equals("")?"":",")+(y+1);
			}
		}
		try{
		
			System.out.println("************************** PARAMETRE ENVOYE PAR L'IHM ****************************************\n\n");
		  	System.out.println("SELECT : "+select1);
			System.out.println("FITLRES : "+sql_filtres);
			System.out.println("GROUP BY_HORIZONTAL : "+group_by_h);
			System.out.println("GROUP BY VERTICAL : "+group_by_v);
			System.out.println("\n\n*************************** PARAMETRE ENVOYE PAR L'IHM ****************************************\n\n");

			System.out.println("*************************** PARAMETRE ENVOYE AU REQUETEUR ***********************************************\n\n");
			System.out.println("SELECT : "+ le_select);
			System.out.println("FITLRES : "+sql_filtres);
			System.out.println("GROUP BY: "+ group_by_2);
			//System.out.println("GROUP BY: "+ (group_by.startsWith(",")?group_by.substring(1):group_by));
			System.out.println("\n\n**************************** PARAMETRE ENVOYE AU REQUETEUR **********************************************\n\n");
		
		
		}catch(Exception ee){
			   System.out.println("Parametre envoye - try catch :");
			   System.out.println("select : "+select1);
			   System.out.println("retourneSQL : "+sql_filtres);
			   System.out.println("group_by_h : "+group_by_h);
			   System.out.println("group_by_v : "+group_by_v);
			   qy.setErr(u.getStackTraceAsString(ee));
		   }

		String r_sql [] = null;
		
		//le_select = le_select + "{,m.proces, n0.proces, p0.proces, p1.proces, m.phase, n0.phase, p0.phase, p1.phase}"; 04 04 2012
		
		//le_select = le_select + "{coucou}"; 04 04 2012
		//sql_filtres = sql_filtres + "{coucou}"; 04 04 2012
		
			
		//if( (! "".equals(le_select)) || (! "".equals(sql_filtres)) || (! "".equals(group_by)) ){
		if( (! "".equals(le_select)) || (! "".equals(sql_filtres)) || (! "".equals(group_by_2)) ){
			//r_sql = new String[]{ le_select,sql_filtres,(group_by_v.equals("")?"":group_by.substring(1)) };
			//r_sql = new String[]{ le_select,sql_filtres,(group_by.startsWith(",")?group_by.substring(1):group_by) };
			r_sql = new String[]{ le_select,sql_filtres,group_by_2 };
		}else{
			//r_sql = new String[]{""}; 04 04 2012
			r_sql = new String[]{"","",""};
		}
		return(r_sql);
	}
	
	/***********************************************************************	FUNCTION USED FOR GRAPH	******************************************************************************/

	/*public String[] getGraphColumnAlias(String graphTableSelect)
    {
        String columns[] = graphTableSelect.split(",");
        for(int i=0;i<columns.length;i++)
        {
            columns[i]=columns[i].trim();
            columns[i]=columns[i].substring(0, columns[i].indexOf("."));
        }
        return columns;
    }

    public String[] getGraphTableAlias(String graphTableSelect)
    {
        String columns[] = graphTableSelect.split(",");
        for(int i=0;i<columns.length;i++)
        {
            columns[i]=columns[i].trim();
            columns[i]=columns[i].split(" AS ")[1];
        }
        return columns;
    }*/
    
	public String[] getGraphTableAlias(java.util.HashMap h)//String graphTableSelect
    {
        if( h.get("graphTableSelectClause")!=null && !(""+h.get("graphTableSelectClause")).equals("") ){
        	String graphTableSelect = ""+""+h.get("graphTableSelectClause");
        	String columns[] = graphTableSelect.split(",");
            for(int i=0;i<columns.length;i++)
            {
                columns[i]=columns[i].trim();
                columns[i]=columns[i].substring(0, columns[i].indexOf("."));
            }
            return columns;
        }else{
        	return null;	
        }
    }

	public String[] getGraphColumn(java.util.HashMap h)//String graphTableSelect
    {
    	 if( h.get("graphTableSelectClause")!=null && !(""+h.get("graphTableSelectClause")).equals("")  ){
    	String graphTableSelect = ""+h.get("graphTableSelectClause");
    	String columns[] = graphTableSelect.split(",");
        for(int i=0;i<columns.length;i++)
        {
            columns[i]=columns[i].trim();
            columns[i]=columns[i].split(" AS ")[0].substring( columns[i].split(" AS ")[0].indexOf(".")+1 );
        }
        return columns;
    	 }else{
         	return null;	
         }
    }
	
    public String[] getGraphColumnAlias(java.util.HashMap h)//String graphTableSelect
    {
    	//System.out.println("==>"+h.get("graphTableSelectClause"));
    	if( h.get("graphTableSelectClause")!=null && !(""+h.get("graphTableSelectClause")).equals("")    ){
    	String graphTableSelect = ""+h.get("graphTableSelectClause");
    	String columns[] = graphTableSelect.split(",");
        for(int i=0;i<columns.length;i++)
        {
            columns[i]=columns[i].trim();
            columns[i]=columns[i].split(" AS ")[1];
        }
        return columns;
    	 }else{
         	return null;	
         }
    }
    
    public String[] getGraphWhereTable(java.util.HashMap h){
    	//System.out.println("getGraphWhereTable==>'"+h.get("graphTableWhereColumns")+"'");
    	if( h.get("graphTableWhereColumns")!=null && !(""+h.get("graphTableWhereColumns")).equals("")){
    		String graphWhereTable = ""+h.get("graphTableWhereColumns");
    		String columns[] = graphWhereTable.split(",");
            for(int i=0;i<columns.length;i++)
            {
                columns[i]=columns[i].trim();
                columns[i]=columns[i].split("\\.")[0];
            }
            return columns;
    		
    	}else{
    		return null;
    	}
    }
    
    public String[] getGraphWhereColumn(java.util.HashMap h){
    	if( h.get("graphTableWhereColumns")!=null && !(""+h.get("graphTableWhereColumns")).equals("")){
    		String graphWhereColumn = ""+h.get("graphTableWhereColumns");
    		String columns[] = graphWhereColumn.split(",");
            for(int i=0;i<columns.length;i++)
            {
                columns[i]=columns[i].trim();
                columns[i]=columns[i].split("\\.")[1];
            }
            return columns;
    	}else{
    		return null;
    	}
    }
    
    /***********************************************************************	FUNCTION USED FOR GRAPH (END)	******************************************************************************/
    

	public String sqlQuery(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String select1 ,String filtres,String group_by_h,String group_by_v,String order_by,String type1,boolean filtre_table_u){
            return sqlQuery( Etn, request, select1 , filtres, group_by_h, group_by_v, order_by, type1, filtre_table_u, "", "", "", "","","","");
        }
	
	public String sqlQuery(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String select1 ,String filtres,String group_by_h,String group_by_v,String order_by,String type1,boolean filtre_table_u, String graphTableSelectClause, String graphTableJoinClause, String graphTableWhereClause, String graphTableServerId,String graphTableDbName,String graphTableName, String graphTableWhereColumns){
		String g[] = null;
		String group_by = "";
		java.util.HashMap<String,String> h = new java.util.HashMap<String,String>();
		java.util.HashMap<String,String> h_var = new java.util.HashMap<String,String>();
		h_var.put("filtres",""+filtres);
		h_var.put("valeurs",""+select1);
		String m = (request!=null?v.manqueVariable(request,h_var):"");
		h.put("type",""+(type1.equals("")?"":type1));
		
		if(request!=null){
			System.out.println("request.getParameter(sphereview)==>"+request.getParameter("sphereview"));
			if( request.getParameter("sphereview")!=null ){
				h.put("sphereview","1");
			}
		}
		//h.put("sphereview","");
		
		if( m.equals("")){
		
		qy = new com.etn.requeteur.Qry(Etn);
		

		String having = "";
		
		System.out.println("group_by_h==>"+group_by_h+"=========>"+group_by_h.indexOf("having"));
		System.out.println("group_by_v==>"+group_by_v+"=========>"+group_by.indexOf("having"));

		if(group_by_h.indexOf("having")!=-1){
			having = group_by_h.substring(group_by_h.indexOf("having"));
			group_by_h = group_by_h.substring(0,group_by_h.indexOf("having"));
		}
		if(group_by_v.indexOf("having")!=-1){
			having = group_by_v.substring(group_by_v.indexOf("having"));
			group_by_v = group_by_v.substring(0,group_by_v.indexOf("having"));
		}
		
		group_by_h = group_by_h.trim();
		group_by_v = group_by_v.trim();
		
		if(graphTableSelectClause!=null)
        {
			h.put("graphTableSelectClause",""+graphTableSelectClause);
			h.put("graphTableJoinClause",""+graphTableJoinClause);
			h.put("graphTableWhereClause",""+graphTableWhereClause);
			h.put("graphTableServerId",""+graphTableServerId);
			h.put("graphTableDbName",""+graphTableDbName);
			h.put("graphTableName",graphTableName);
			h.put("graphTableWhereColumns",graphTableWhereColumns);
			
			
	    }
		
		System.out.println("graphTableSelectClause==>"+graphTableSelectClause+"\ngraphTableJoinClause=========>"+graphTableJoinClause);
		
		h.put("having",""+having);
		
		
		
		
		
		g = sql(Etn,request,select1,filtres,group_by_h,	group_by_v,type1,filtre_table_u);
		
		
		System.out.println("g.length == "+g.length);
		if( g==null){ //g.length == 1 04 04 2012
			qy.setErr(qy.getErr());
			return("");
		}else{
			System.out.println("select : "+g[0]+"");
			System.out.println("filtres : "+g[1]+"");
			System.out.println("group by : "+g[2]+"");
			
			System.out.println("having : "+having+"");
			
			String ordre=getIndexOrdre2(g,order_by);//getIndexOrdre(select1,group_by_h,group_by_v,order_by);
			//CHANGED FROM getIndexOrdre to getIndexOrdre2 because of arguments - Asad
                        
			ordre = order_by; //fait par Select.java
			h.put("order_by",""+ordre);
			System.out.println("order by : "+ordre+"");
			
			if( SiHeure(request,g[2])){
				h.put("heure","oui");
			}
			
			qy.setMap(h);
			
			boolean b = qy.parse( g[0],g[1],g[2] );
			
				if( b == false )
			    {
			      	System.out.println("************************** ERREUR ****************************************\n\n");
			       	System.out.println(""+qy.getErr() );
			       	System.out.println("\n\n************************** ERREUR ****************************************\n\n");
			       	return("");
			    }else{
			       	System.out.println("************************** SQL RENVOVE PAR REQUETEUR ****************************************\n\n");
			       	System.out.println(""+qy.getSql());
			       	System.out.println("\n\n************************** SQL RENVOVE PAR REQUETEUR ****************************************\n\n");
			       	
			       	System.out.println("qy.serveur == "+qy.serveur);
			       	/*if(graphTableSelectClause!=null)
                                {
                                    return "SELECT "+graphTableSelectClause+" FROM "+graphTableJoinClause+" WHERE "+graphTableWhereClause;
                                }*/
			       	return(qy.getSql());
			    }
		}
		
		
		
		}else{
		
			qy.setErr("\n\n\nVeuillez renseigner le(s) varaiable(s) suivante(s) :\n " + m);
			return("");
			
		}
	}
	
	public int execQuery(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String select1 ,String filtres,String group_by_h,String group_by_v,String order_by,String requete_id,String requete_name,String requete_desc,String type1,boolean filtre_table_u){
		return execQuery(Etn,request,select1 ,filtres,group_by_h,group_by_v,order_by,requete_id,requete_name,requete_desc,type1,filtre_table_u, "", "", "","","","","");
	}
	
	public int execQuery(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String select1 ,String filtres,String group_by_h,String group_by_v,String order_by,String requete_id,String requete_name,String requete_desc,String type1,boolean filtre_table_u, String graphTableSelectClause, String graphTableJoinClause, String graphTableWhereClause,String graphTableServerId,String graphTableDbName,String graphTableName, String graphTableWhereColumns){
		String g[] = null;
		String group_by="";
		
		java.util.HashMap<String,String> h = new java.util.HashMap<String,String>();
		java.util.HashMap<String,String> h_var = new java.util.HashMap<String,String>();
		h_var.put("filtres",""+filtres);
		h_var.put("valeurs",""+select1);
		String m = (request!=null?v.manqueVariable(request,h_var):"");
		
		if(request!=null){
			if( request.getParameter("sphereview")!=null ){
				h.put("sphereview","1");
			}
		}
				
		if( m.equals("")){
		
		qy = new com.etn.requeteur.Qry(Etn);
		h.put("type",""+(type1.equals("")?"":type1));

		String having = "";
		
		System.out.println("group_by_h==>"+group_by_h+"=========>"+group_by_h.indexOf("having"));
		System.out.println("group_by_v==>"+group_by_v+"=========>"+group_by.indexOf("having"));

		if(group_by_h.indexOf("having")!=-1){
			having = group_by_h.substring(group_by_h.indexOf("having"));
			group_by_h = group_by_h.substring(0,group_by_h.indexOf("having"));
		}
		if(group_by_v.indexOf("having")!=-1){
			having = group_by_v.substring(group_by_v.indexOf("having"));
			group_by_v = group_by_v.substring(0,group_by_v.indexOf("having"));
		}
		
		group_by_h = group_by_h.trim();
		group_by_v = group_by_v.trim();
		
		
		
		h.put("having",""+having);
		h.put("type",""+(type1.equals("")?"":type1));
	
		if(graphTableSelectClause!=null)
        {
			h.put("graphTableSelectClause",""+graphTableSelectClause);
			h.put("graphTableJoinClause",""+graphTableJoinClause);
			h.put("graphTableWhereClause",""+graphTableWhereClause);
			h.put("graphTableServerId",""+graphTableServerId);
			h.put("graphTableDbName",""+graphTableDbName);
			h.put("graphTableName",graphTableName);
			h.put("graphTableWhereColumns",graphTableWhereColumns);
	    }
		
		g = sql(Etn,request,select1,filtres,group_by_h,	group_by_v,type1,filtre_table_u);
		
		System.out.println("g.length == "+g.length);
		if( g==null){ //g.length == 1 04 04 2012
			qy.setErr(qy.getErr());
			return(-1);
		}else{
			System.out.println("select : "+g[0]+"");
			System.out.println("filtres : "+g[1]+"");
			System.out.println("group by : "+g[2]+"");
			
			System.out.println("having : "+having+"");
			
			String ordre=getIndexOrdre2(g,order_by);//getIndexOrdre(select1,group_by_h,group_by_v,order_by);
                        //CHANGED FROM getIndexOrdre to getIndexOrdre2 because of arguments - Asad
			ordre = order_by; //fait par Select.java
			h.put("order_by",""+ordre);
			System.out.println("order by : "+ordre+"");
			
			if( SiHeure(request,g[2])){
				h.put("heure","oui");
			}
			qy.setMap(h);
			
			int id = qy.execute( g[0],g[1],g[2] );
			
				if( id == 0 )
			    {
			      	System.out.println("************************** ERREUR ****************************************\n\n");
			       	System.out.println(""+ qy.getErr() );
			       	System.out.println("\n\n************************** ERREUR ****************************************\n\n");
			       	return(-2);
			    }else{
			       	System.out.println("************************** SQL RENVOVE PAR REQUETEUR ****************************************\n\n");
			       	System.out.println(""+qy.getSql());
			       	System.out.println("\n\n************************** SQL RENVOVE PAR REQUETEUR ****************************************\n\n");
			       	
			      //historisation
			      histoRequete(Etn,request,""+id,requete_id,select1 ,filtres,group_by_h,group_by_v,order_by,type1);
			       	
			       	
			       	return(id);
			    }
		}
		
		
		
		}else{
		
			qy.setErr("\n\n\nVeuillez renseigner le(s) varaiable(s) suivante(s) :\n " + m);
			return(-3);
		}
	
	
			
		
	}
	
	int histoRequete(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String id,String requete_id,String select1 ,String filtres,String group_by_h,String group_by_v,String order_by,String type1){
		return(histoRequete(Etn,request,id,requete_id,select1 ,filtres,group_by_h,group_by_v,order_by,type1,""));
	}
	
	int histoRequete(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request,String id,String requete_id,String select1 ,String filtres,String group_by_h,String group_by_v,String order_by,String type1,String vname){
		int histo_err = -1;
		javax.servlet.http.HttpSession session =  request.getSession(true);
		if(! "0".equals(requete_id)){
			
			String desc_variable_filtre = "";
			String desc_variable_valeur = "";
			
			/*String date_fraicheur = r_date_fraicheur(Etn,type1);
			h.put("date_fraicheur",date_fraicheur);*/
			
			if( session.getAttribute("variable_filtre")!=null){
				desc_variable_filtre = (String) session.getAttribute("variable_filtre");
			}else{
				desc_variable_filtre = "";
			}
			
			if( session.getAttribute("variable_valeur")!=null){
				desc_variable_valeur = (String) session.getAttribute("variable_valeur");
			}else{
				desc_variable_valeur = "";
			}
			
			String sql="";
			
			sql="insert into histo_requete (requete_id, person_id,date_histo,agregations_h,agregations_v,ordre,valeurs,filtres,techno,type_elt,cache_id,date_fraicheur,desc_variable_filtre,desc_variable_valeur,vname) ";
			sql+= " values ("+requete_id+","+Etn.getId()+",now(),"+escape.cote(group_by_h)+","+escape.cote(group_by_v)+","+escape.cote(order_by)+","+escape.cote(select1)+","+escape.cote(filtres)+",0,"+escape.cote(type1)+","+id+",'',"+escape.cote(desc_variable_filtre)+","+escape.cote(desc_variable_valeur)+","+escape.cote(vname)+")";
			
			histo_err = Etn.executeCmd(sql);
		}
		if( histo_err > -1){
			System.out.println(""+Etn.getLastError());
		}
		
		return(histo_err);
		
	}
	
	
	boolean isChiffre(int type){
		if( type == 4  || type == 8 || type ==-5 || type ==-6 || type ==7 || type ==5){
			return(true);
		}else{
			return(false);
		}
	}
	
	int heureSaisie(String cl[]){
		int cpt_h = 0;
		if(cl.length == 2 ){
			if(!cl[1].equals("")){
		    	cpt_h++; 
			}
		}else{
		    if(cl.length == 3 ){
		    	if(!cl[1].equals("")){
		        	cpt_h++; 
		       	}
		    }else{
		        if(cl.length == 4 ){
			    	if(!cl[1].equals("")){          
		            	cpt_h++; 
			    	}
			    	if(!cl[3].equals("")){          
		              cpt_h++; 
			    	}
				}
			}
		}
		return(cpt_h);
	}
	
	public String filtre_date(String[] v){
		int cpt=0;
		String sql="";
		for(int i2 = 0; i2 < v.length;i2++){
			String clause[] = v[i2].split(",");
			if( clause[0].equals("filtreHC") || clause[0].equals("filtreHP")
	        || clause[0].equals("filtresemaine") || clause[0].equals("filtresamedi")
	        || clause[0].equals("filtredimanche") || clause[0].equals("week")
	        || clause[0].equals("month") || clause[0].equals("year")){
				sql+= (cpt==0?"":" and ") + " " + clause[1];
				cpt++;
				
			}
		}
		return(sql);
	}
	
	int getIndexFiltre( ArrayList<column_filtre> ar , String nomlogique )
	{ 
		//System.out.println("getIndexFiltre=>"+ar.size());
	for( int i = 0 ; i < ar.size() ; i++ )
	  {
		//System.out.println(ar.get(i).nomlogique+"==>"+nomlogique);
		if( ar.get(i).nomlogique.equalsIgnoreCase(nomlogique) )
		   
		   return(  i );
	  }
	  //System.out.println("NON TROUVE:"+nom);
	  return(-1);
	}
	
	public String sqlDate(com.etn.beans.Contexte Etn,ArrayList<column_filtre>ar,int c1,String c[],String and_or,boolean heure){
		String sqlDate="";
		 if( and_or.equals(" and ")){
             and_or="";
             }

			
			if( ar.get(c1).date1.equals("psdate")){
				//System.out.println("-->pdate1<--");
				// changement ordre bouba cause compteur v3 deux dates prends 0 et 1
				String psdate[] = {"","00:00:00","","23:59:59"};

				String cl[] = null;
				if(! c[1].equals("")){
					cl = c[1].split(" ");

					for(int v3=0;v3 < cl.length;v3++){
						if(!cl[v3].equals("")){

							psdate[v3] = cl[v3];
						}
					}
				}

				//*************** Si heure saisie dans date du/au ****************
				
				int cpt_h = heureSaisie(cl);
				
				//*************** Si heure saisie dans date du/au  (fin) *****************
				
				sqlDate+=and_or+"  (psdate between ";
				sqlDate+="'"+ u.reverseDate(psdate[0]) + " " + psdate[1]+ "'";
				sqlDate+=" and ";
				sqlDate+="'"+ (psdate[2].equals("")?u.reverseDate(psdate[0]):u.reverseDate(psdate[2])) + " " + psdate[3] + "'";
				sqlDate+=")";
				//System.out.println(" sqlDate = " + sqlDate);
			}else{
				
				if ( ar.get(c1).date1.equals("multi_psdate")){
					sqlDate+=and_or;
					if( heure ){
						for(int i=1;i<c.length;i++){
							sqlDate+=(i==1?"  (":" or ")+ " psdate like '"+com.etn.sql.SqlMap.toDate(Etn,c[i],"DD/MM/YYYY").replaceAll("/","-")+"%'";
						}
					}else{
						for(int i=1;i<c.length;i++){
							sqlDate+=(i==1?"  (":" or ")+ " psdate = '"+com.etn.sql.SqlMap.toDate(Etn,c[i],"DD/MM/YYYY")+"'";
						}
					}
					
					sqlDate+=")";
				}else{
					String recup_t = ar.get(c1).date1;
					//System.out.println("-->nomlogique="+recup_t+"<--");
					
					recup_t = recup_t.substring( recup_t.indexOf("_")+1);
					recup_t = recup_t.substring(0,recup_t.indexOf("("));
					
					
					sqlDate+=and_or;
					if( c.length == 2){
						sqlDate+= date_relative ("",c[1],recup_t,(ar.get(c1).type == 93?true:false));
					}
					if( c.length == 3){
						sqlDate+= date_relative (c[1],c[2],recup_t,(ar.get(c1).type == 93?true:false));
					}

					//System.out.println(" periode_mois = " + sqlDate);
			}

			}
			
			/********************************************	DATE - FIN	*******************************************************/

			
		return(sqlDate);
	}
	
	
	String getIndexOrdre2(String g[],String order){
		String select = g[0];
		System.out.println("getIndexOrdre");
		System.out.println("select==>"+select);
		System.out.println("order==>"+order);
		
		if(order == null) order = "";
		
		if(select.startsWith(",")){
			select = select.substring(1);
		}
		if(order.startsWith(",")){
			order = order.substring(1);
		}
		
		String s = "";
		String o="";
		String select1 = select.toLowerCase();
		String order1 = order.toLowerCase();
		
		if(select1.startsWith(",")){
			select1 = select1.substring(1);
		}
		
		System.out.println("select apres==>"+select1);
		
		//String valeur="";
		
		String tab_order2[] = order1.trim().split(",");
		String tab_select[] = select1.split(",");
		String tab_order[] = order1.split(",");
			
		
		for(int i2=0;i2<tab_order2.length;i2++){
			if(tab_order2[i2].endsWith("desc")){
				//System.out.println("tab_order2==>"+tab_order2[i2]);
				o += (o.equals("")?"":",")+"desc";
			}else{
				//System.out.println("tab_order2==>"+tab_order2[i2]);
				o += (o.equals("")?"":",")+"asc";
			}
		}
		String tab_order3[] = o.split(",");
		
		
		order1 = order1.replace(" asc","");
		order1 = order1.replace(" desc","");
		order1 = order1.trim();
		String[] tab_order4 = order1.split(",");
		
	
		
		for(int i=0;i<tab_order.length;i++){
			for(int i2=0;i2<tab_select.length;i2++){
				//System.out.println("'"+tab_order4[i]+"'=='"+tab_select[i2]+"'");
				String s4 = tab_select[i2];
				//if(!s4.startsWith("[") && !s4.endsWith("]")){
					if(s4.indexOf("(")!=-1 && s4.lastIndexOf(")")!=-1 &&  s4.indexOf("(")< s4.lastIndexOf(")") ){
						s4 = s4.substring(s4.indexOf("(")+1,s4.lastIndexOf(")"));
					}
					//System.out.println("s4="+s4);
					if(tab_order4[i].equals(s4) && !(tab_order4[i].equals("") && tab_select[i2].equals("") )  ){
						if(tab_select[i2].indexOf("psdate")!=-1){ // si psdate,alors tri sur la colonne de date et pas sur la fonction 
							s += (s.equals("")?"":",")+ "psdate "  + tab_order3[i];
						}else{
							s += (s.equals("")?"":",")+ (""+(i2)) + " " + tab_order3[i];
						}
					}
				//}
			}
		}
		
		
		
		return(s);
		
	}
	
	String getIndexOrdre(String select,String group_by_h,String group_by_v,String order){
		System.out.println("getIndexOrdre");
		System.out.println("select==>"+select);
		System.out.println("order==>"+order);
		System.out.println("group_by_h==>"+group_by_h);
		System.out.println("group_by_v==>"+group_by_v);
		
		if(order == null) order = "";
		if(group_by_h == null) group_by_h = "";
		if(group_by_v == null) group_by_v = "";
		
		if(select.startsWith(",")){
			select = select.substring(1);
		}
		if(order.startsWith(",")){
			order = order.substring(1);
		}
		if(group_by_h.startsWith(",")){
			group_by_h = group_by_h.substring(1);
		}
		if(order.startsWith(",")){
			group_by_v = group_by_v.substring(1);
		}
		
		String s = "";
		String o="";
		String select1 = select.toLowerCase();
		String group_by_h1 = group_by_h.toLowerCase();
		String group_by_v1 = group_by_v.toLowerCase();
		String order1 = order.toLowerCase();
		
		String group_by = "";
		if(group_by_h1.equals("")){
			group_by = group_by_v1;
		}else{
			group_by = group_by_h1 + group_by_v1;
			//group_by = group_by_v + group_by_h;
		}
		
		if(group_by.startsWith(",")){
			group_by = group_by.substring(1);
		}
		if( !group_by.equals("") ){
			select1 = group_by+","+select1;
		}
		
		
		
		if(select1.startsWith(",")){
			select1 = select1.substring(1);
		}
		
		System.out.println("select apres==>"+select1);
		
		//String valeur="";
		
		String tab_order2[] = order1.trim().split(",");
		String tab_select[] = select1.split(",");
		String tab_order[] = order1.split(",");
	/*	for(int zz= 0; zz < tab_order2.length;zz++){
			System.out.println("tab_order2["+zz+"]==>"+tab_order2[zz]);
			if( tab_order2[zz].trim().indexOf("as")!=-1){
				
				tab_order2[zz] = tab_order2[zz].trim().substring(0,tab_order2[zz].indexOf(" as")+3);
			}
			valeur += (zz==0?"":",")+""+tab_order2[zz].trim()+"";
	}

		order1 = valeur;*/
		
		
		for(int i2=0;i2<tab_order2.length;i2++){
			if(tab_order2[i2].endsWith("desc")){
				//System.out.println("tab_order2==>"+tab_order2[i2]);
				o += (o.equals("")?"":",")+"desc";
			}else{
				//System.out.println("tab_order2==>"+tab_order2[i2]);
				o += (o.equals("")?"":",")+"asc";
			}
		}
		String tab_order3[] = o.split(",");
		
		
		order1 = order1.replace(" asc","");
		order1 = order1.replace(" desc","");
		order1 = order1.trim();
		String[] tab_order4 = order1.split(",");
		
		
		for(int i=0;i<tab_order.length;i++){
			for(int i2=0;i2<tab_select.length;i2++){
				//System.out.println("'"+tab_order4[i]+"'=='"+tab_select[i]+"'");
				if(tab_order4[i].equals(tab_select[i2])){
					if(tab_select[i2].indexOf("psdate")!=-1){ // si psdate,alors tri sur la colonne de date et pas sur la fonction 
						s += (s.equals("")?"":",")+ "psdate "  + tab_order3[i];
					}else{
						s += (s.equals("")?"":",")+ (""+(i2)) + " " + tab_order3[i];
					}
				}
			}
		}
		
		
		
		return(s);
		
	}
	
	
	
	
	
	public  String retourneSQL2(String f2,String group_by_h,String group_by_v,String filtre_s,String autre_sql,String autre_sql2,com.etn.beans.Contexte Etn,String type_elt,boolean filtre_table_u){
		String sql="";
		String sqlDate="";
		String sql2="";
		String sql3="";

		int cpt = 0;
		int cpt_h = 0;
		
		int i3=0;
		int i4=0;
		
		boolean diff=false;
		String str_diff ="!=";
		int i_diff=0;
		String liste_diff = "";
		
		String v[] =  f2.toLowerCase().split(";");
		//System.out.println("retourneSQL__new=>"+v.length);
		
		
		
		
		String w = "";
		String w2 = "";
		String w3="";
		 
		String group_by = "";
		if(group_by_h==null) group_by_h="";
		if(group_by_v==null) group_by_v="";

		if(group_by_h.equals("")){
			group_by = group_by_v;
		}else{
			group_by = group_by_h + group_by_v;
			//group_by = group_by_v + group_by_h;
		}
		System.out.println("group_by_h="+group_by_h);
		System.out.println("group_by_v="+group_by_v);
		
		boolean heure = false;
		if( group_by.indexOf("heure(psdate)")!=-1 || group_by.indexOf("minimale(psdate)")!=-1){
			heure = true;
		}else{
			heure = false;
		}
		
		for(int i2 = 0; i2 < v.length;i2++){

			 
			 

			if( v[i2].startsWith("{") && v[i2].endsWith("}")){
					sql3 = " and " + v[i2];

			}else{ 		
				
				
							
			String clause[] = v[i2].split(",");
			//
			System.out.println("clause[0]="+clause[0]);
			if(clause[0].indexOf("psdate")!=-1){
			//	w2= "'"+com.etn.util.Substitue.dblCote(clause[0])+"'";
				w+=",'psdate'";
				w2+="psdate";
				w3= " "+clause[0]+"";
			}
			
			if( clause[0].startsWith(str_diff)){
				 liste_diff += "'"+clause[0].replace(str_diff,"")+"'";
				 i_diff++;
			 }

			if(!clause[0].equals("type") && ! clause[0].equals("techno") && clause[0].indexOf("psdate")==-1){
				w+= ","+escape.cote(clause[0])+"";

			}
			}
			}
		
		java.util.HashMap hColumn = new java.util.HashMap();
		 ArrayList<column_filtre>ar = new ArrayList<column_filtre>();
		if(!w.equals("")){
			w = w.substring(1);

			req_ihm ri = new req_ihm();
			sql2=ri.constructionFiltre(Etn,w,w2,w3,liste_diff,i_diff,type_elt);
			Set rs2 = Etn.execute(sql2);
			System.out.println("sql2===========================>"+sql2);
			
			 
			 
			  while( rs2.next() )
			  {
				  	ar.add ( new column_filtre ( 
				  			rs2.value("nomlogique").toLowerCase(),  
				  			Integer.parseInt( (rs2.value("type").equals("")?"0":rs2.value("type")),10), 
				  			rs2.value("date1") , 
				  			rs2.value("typeDB") , 
				  			rs2.value("valbdd"), 
				  			rs2.value("valihm") ,
				  			rs2.value("diff")
				  			) );
			  }
			 
			
			
		}
		
		String le_sql="";
		String prec="";
		int cpt2=0;
		for(int i2 = 0; i2 < v.length;i2++){
			String cl[]= v[i2].toLowerCase().split(",");
			int c1 = getIndexFiltre( ar , cl[0] );
			if(cl[0].indexOf("psdate")!=-1){
				c1 = getIndexFiltre( ar , "psdate" );
			}
			if(cl[0].startsWith("!=")){
				c1 = getIndexFiltre( ar , cl[0].substring(2));
			}
			
			System.out.println("c1:"+c1+"==>"+v[i2].toLowerCase() );
			if(c1!=-1){
				int r = (ar.get(c1).date1.indexOf("psdate")!=-1? u.RetourneIndex(v,ar.get(c1).date1):u.RetourneIndex(v,ar.get(c1).nomlogique));
			 //if(r!=-1){
				 
				 le_sql+=prec;
				 System.out.println("prec("+i2+")="+prec);
				 
				 le_sql+="(";
				 //String c[] =  u.RetourneChaine(f2,r).split(",");
				//System.out.println(ar.get(c1).nomlogique+"==>"+r);
				int nb = (cl.length-1);
				 System.out.println("nb="+nb);
				if( ar.get(c1).valbdd.equals("") && ar.get(c1).valihm.equals("")){
				
				/*if( nb == 1){
					if( (cl[1].equals("--vide--"))){
						le_sql+=  prec+ ar.get(c1).nomlogique + " is null" ;
					}
				}else{*///nb == 1
					
					if( ar.get(c1).nomlogique.equals("psdate")){
						 System.out.println("psdate");
						le_sql+=sqlDate(Etn,ar,c1,cl,prec,heure);
					}else{
						//le_sql+=prec;
						if( nb == 1 || cl[1].startsWith(">") || cl[1].startsWith("<") || cl[1].startsWith("=") || cl[1].startsWith("!=") ){
							
							if( (cl[1].equals("--vide--"))){
								le_sql+=  prec+ ar.get(c1).nomlogique + " is null" ;
							}else{
							
							
								/*if( isChiffre(ar.get(c1).type)){	
									System.out.println("is Chiffre");
									if( cl[1].toLowerCase().indexOf("between")!=-1){
										//System.out.println("between " +c[1]);
										le_sql+= ar.get(c1).nomlogique ;
										String liste = cl[1];
										liste = liste.replaceAll("between","").replaceAll("BETWEEN","");
										liste = liste.trim();
										String liste2[] = liste.split("&");
										le_sql+= " between "+liste2[0];
										le_sql+= " and ";
										le_sql+= ""+liste2[1];
										
									}else{
										//  >,<, = ,!=
										//System.out.println("y-->"+y);
										le_sql+= ar.get(c1).nomlogique +"" + cl[1];
									}
								}else{ //texte
									System.out.println("is Text");
									if( cl[1].toLowerCase().indexOf("like")!=-1){
										le_sql+= ar.get(c1).nomlogique + " " + ar.get(c1).diff + " like "+com.etn.sql.escape.cote(cl[1].replace("like","").replace("LIKE","").trim());
									}else{//!=
										//sql+= nom_logique.replace(str_diff,"") + str_diff + "aa " + com.etn.sql.escape.cote(c[1])+"";
										le_sql+= ar.get(c1).nomlogique.replace(str_diff,"") + " " + ar.get(c1).diff + " in (" + com.etn.sql.escape.cote((cl[1].equals("--vide--")?"":cl[1]))+")";
									}
								}*/
								
								if( cl[1].toLowerCase().indexOf("between")!=-1){
									//System.out.println("between " +c[1]);
									le_sql+= ar.get(c1).nomlogique ;
									String liste = cl[1];
									liste = liste.replaceAll("between","").replaceAll("BETWEEN","");
									liste = liste.trim();
									String liste2[] = liste.split("&");
									le_sql+= " between "+liste2[0];
									le_sql+= " and ";
									le_sql+= ""+liste2[1];
									
								}else{
									//  >,<, = ,!=
									//System.out.println("y-->"+y);
									//System.out.println("aaaa-->"+ar.get(c1).nomlogique + "==>"+cl[1]);
									
									if( cl[1].startsWith(">") || cl[1].startsWith("<") || cl[1].startsWith("=") || cl[1].startsWith("!=") ){
										String u =  cl[1];
										String u2 = cl[1];
										String u3 = "";
										if(cl[1].startsWith("!=") || cl[1].startsWith(">=") || cl[1].startsWith("<=")){
											u = u.substring(0,2);
											u2 = u2.substring(2);
										}else{
											u = u.substring(0,1);
											u2 = u2.substring(1);
										}
										u3 = u + (isChiffre(ar.get(c1).type)?""+u2:""+com.etn.sql.escape.cote(u2)) ;
										le_sql+= ar.get(c1).nomlogique +"" + u3;
									}else{
										if( cl[1].toLowerCase().indexOf("like")!=-1){
											le_sql+= ar.get(c1).nomlogique + " " + ar.get(c1).diff + " like "+com.etn.sql.escape.cote(cl[1].replace("like","").replace("LIKE","").trim());
										}else{//!=
											//sql+= nom_logique.replace(str_diff,"") + str_diff + "aa " + com.etn.sql.escape.cote(c[1])+"";
											le_sql+= ar.get(c1).nomlogique.replace(str_diff,"") + " " + ar.get(c1).diff + " in (" + com.etn.sql.escape.cote((cl[1].equals("--vide--")?"":cl[1]))+")";
										}
									}
								}
								
								
							
							}
						}else{ //plusieurs valeurs
							le_sql += " " + ar.get(c1).nomlogique.replace(str_diff,"") +" "+ar.get(c1).diff+"  in (";
							for(int j2=1;j2 < cl.length;j2++){
								String s1 = (cl[j2].equals("--vide--")?"":cl[j2]);
								le_sql+=""+ com.etn.sql.escape.cote(s1)+"" + ( (cl.length-1)==j2?"":",");
								}
							le_sql+=")";
						}
					}
					//}//nb==1
				}else{
					System.out.println("valdbb sql ==> valihm");
					if( ar.get(c1).valbdd.startsWith("sql")){
						String in = "";
						for(int j=1;j < cl.length;j++){
							//System.out.println("val == "+c[j]);
							if( cl[j].equals("--vide--")){
								in += (in.equals("")?"":",")+"''";
							}else{
								in += (in.equals("")?"":",")+com.etn.sql.escape.cote(cl[j]);
							}
						}
						
					
						String sqlbdd = ar.get(c1).valihm + " in (" + in + ")";
						System.out.println("sqlbdd:"+sqlbdd);
						com.etn.lang.ResultSet.Set rsL = Etn.execute(sqlbdd);
						
						
						
						int cpt_liste = 0;
						if(rsL.rs.Rows > 0){
							
							while(rsL.next()){
								String valeur = "";
								valeur =  com.etn.sql.escape.cote(rsL.value(0));
								le_sql+= ar.get(c1).valbdd.substring(4) + "="+valeur+(cpt_liste==(rsL.rs.Rows-1)?"":" or ");
								cpt_liste++;
							}
							cpt++;
						}
						
						
					}else{
					
						System.out.println("valdbb ==> valihm");
						
						for(int j=1;j < cl.length;j++){
							System.out.println("val == "+cl[j]);
							le_sql+= ar.get(c1).nomlogique+"='"+ValBddIhm(ar.get(c1).valbdd.split(","),ar.get(c1).valihm.split(","),cl[j])+"'"+( (cl.length-1)==j?"":" or ");
						}
						
						cpt++;
					}
				}
			
			le_sql+=")";
			//}//r1
			}else{//cl
				//le_sql+=prec;
				if(cpt2==0){
				String sql_fitre_date = filtre_date(v);
					if(!sql_fitre_date.equals("")){
						le_sql+=sql_fitre_date;
						cpt++;
						cpt2++;
					}
				}
				
			}
			
			//System.out.println("i2="+i2);
			if( v[i2].toLowerCase().equalsIgnoreCase("or") && i2>0 ){
				prec = " or ";	
			}else{
				prec = " and ";
			}
		}//v.length
		
		if(!le_sql.equals("")){
			le_sql=" and ("+le_sql+")";
		}
		
		
		/*for(int i=0;i<v.length;i++){
			System.out.println("==>"+v[i]);
		}*/
		
		return(le_sql);
	}
	
	
		
	
	public int addToInbox(com.etn.beans.Contexte Etn,javax.servlet.http.HttpServletRequest request, String type_aff,String requete_id,String user_id,String requete_name,String id,String group_by_h,String group_by_v,String ordre,String select1,String filtres,String techno,String type1){
		javax.servlet.http.HttpSession session =  request.getSession(true);
		String desc_variable_filtre = "";
		String desc_variable_valeur = "";
		
		/*String date_fraicheur = r_date_fraicheur(Etn,type1);
		h.put("date_fraicheur",date_fraicheur);*/
		
		if( session.getAttribute("variable_filtre")!=null){
			desc_variable_filtre = (String) session.getAttribute("variable_filtre");
		}else{
			desc_variable_filtre = "";
		}
		
		if( session.getAttribute("variable_valeur")!=null){
			desc_variable_valeur = (String) session.getAttribute("variable_valeur");
		}else{
			desc_variable_valeur = "";
		}
		
		String sql="";
		sql+="insert into requete_en_cours (type_aff,requete_id, person_id, statut, nom,id,agregations_h,agregations_v,valeurs,filtres,techno,date_r,type_elt,desc_variable_filtre,desc_variable_valeur) ";
		sql+=" values ("+type_aff+","+requete_id+","+user_id+",1,"+escape.cote(requete_name)+",'"+id+"',"+escape.cote(group_by_h)+","+escape.cote(group_by_v)+","+escape.cote(select1)+",";
		sql+=escape.cote(filtres)+","+escape.cote(techno)+",now(),"+escape.cote(type1)+","+escape.cote(desc_variable_filtre)+","+escape.cote(desc_variable_valeur)+")";
		
		int i = Etn.executeCmd(sql);
		return(i);
	}
	
	
	public static void main(String a[]){
		makeSql m = new makeSql();
		javax.servlet.http.HttpServletRequest req = null;
		Contexte Etn = new Contexte();
		Etn.setContexte("admin","admin");
		Set rs = Etn.execute("SELECT * FROM `requete` where requete_id ="+a[0]);
		
		if(rs.next()){
			String le_sql = m.sqlQuery(Etn,req, rs.value("valeurs"), rs.value("filtres"), rs.value("agregations_h"), rs.value("agregations_v"), rs.value("ordre"),rs.value("type_elt"), false,rs.value("graph_select_clause"),rs.value("graph_join_clause"),rs.value("graph_where_clause"),rs.value("graph_table_server_id"),rs.value("graph_table_dbname"),rs.value("graph_table_name"),rs.value("graph_where_columns"));
			//System.out.println("voir sql("+m.getServeur()+")="+le_sql);
			System.out.println("voir getError :"+m.getError());
			
			/*
			int i = m.execQuery(Etn,req, rs.value("valeurs"), rs.value("filtres"), rs.value("agregations_h"), rs.value("agregations_v"), rs.value("ordre"),"1167","AAA_test_graph_type","AAA_test_graph_type",rs.value("type_elt"), false,rs.value("graph_select_clause"),rs.value("graph_join_clause"),rs.value("graph_where_clause"),rs.value("graph_table_server_id"),rs.value("graph_table_dbname"));
			 
			System.out.println("cache_id :"+i);
			System.out.println("voir getError :"+m.getError());
			System.out.println("voir getError :"+m.getServeur());
			*/
		
		}
		
		/*String le_sql = m.sqlQuery(Etn,req, "filtrable"  , "dbnom,requeteur;", "", "", "catalog" , false);
        System.out.println("MAKESQL QUERY ASAD:"+le_sql);*/

		
		
	}
	
	
}


