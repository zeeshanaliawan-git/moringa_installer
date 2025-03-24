package com.etn.requeteur;

import java.util.HashMap;
import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.requeteur.Types;
import java.util.ArrayList;
import com.etn.lang.ResultSet.ArraySet;

public class Catalog {

final String DEBUTSEP = "`";
final String FINSEP = "`";

Atom atoms[];
Qry qy;

boolean check()
{
  int os = 0;
  int minutes=-1;
  String equip = "?";
 // System.out.println("atoms.length="+atoms.length);
  for ( int i = 0 ; i < atoms.length ; i++ )
   if( atoms[i].type == Types.LNOM )
     { Atom a = atoms[i];

    // System.out.println("check("+atoms[i].val+")="+atoms[i].champ+"=>"+atoms[i].con);


        if( a.con == 0 )
         {
            qy.setErr( "Catalog (non trouvé): "+a.val) ;
            return(false);
         }
       else
       if( os != a.con )
         { if( os != 0 ) qy.multiple = true;
           os = a.con;
         }

  /*** A Afiner
      if( a.ti != null )
        { if( minutes !=  a.ti.minutes )
            if( minutes == -1 ) minutes = a.ti.minutes;
              else { qy.setErr( "Unites de temps disparates: "+a.val) ;
                     return( false);
                   }
          if( equip.equals(a.ti.granularite) == false )
            if( equip.charAt(0) == '?' ) equip = a.ti.granularite;
            else { qy.setErr( "Equipements disparates: "+a.val) ;
                   return( false);
                 }
        }
   ***/

     }



  if( !qy.multiple )
     qy.serveur = os;

  return( true );

}

boolean addInfo( Set rs, HashMap <String,TableInfo>tblInfo )
{
  String v = rs.value("nomlogique");
  int mask = Integer.parseInt( rs.value("filtrable"));
  boolean ok = false;

  // Renseigne les Atoms comportant ce nom logique
  for( int i = 0 ; i< atoms.length ; i++ )
  {

    Atom a = atoms[i];

    //if(v.equalsIgnoreCase(a.val))
    /*if(a.type==11)
    System.out.println("a.type="+a.type+">a.val="+a.val+">v-->"+v+">a.champ="+a.champ);
	*/

    if(  a.type == Types.INTERNE && v.equalsIgnoreCase("psdate") ){
    	  a.con = Integer.parseInt(rs.value("serveur"));
          a.db = rs.value("dbnom");
          a.table = rs.value("dbtable");

          a.champ = qy.psdate;
         // System.out.println("psdate :"+a.champ);
          a.ti = null;
    }



    if( a.type == Types.LNOM  && v.equalsIgnoreCase(a.val) )
    {

    	/*if(v.equalsIgnoreCase("psdate")){
    		a.val = qy.psdate;
    	}*/


    	 a.con = Integer.parseInt(rs.value("serveur"));
         a.db = rs.value("dbnom");
         a.table = rs.value("dbtable");

         a.champ = DEBUTSEP+rs.value("champ")+FINSEP;

         //System.out.println("a.type="+a.type+">a.val="+a.val+"-->"+v);
       // System.out.println("----------->a.table="+a.table+"->a.champ"+a.champ+"<------------------");


         String tcle = ""+a.con+a.db+"."+a.table;
         TableInfo ti = tblInfo.get(tcle);
         if( ti == null )
          { ti =  new TableInfo(
               rs.value("granEquipement"), rs.value("champ_de_jointure"),
               rs.value("granulariteTemporelle"), rs.value("champ_de_jointure_date") );
             tblInfo.put( tcle , ti);
          }
         a.ti = ti;

        ok = true; // au moin un champ
    }


  }


 return( ok);
}

boolean hasDate()
{
  for( int i = 0 ; i < atoms.length ; i++ )
    if( atoms[i].type == Types.PSDATE )
       return( true);
  return( false);
}

/**
* rempli les atoms en perqisitionnant le catalog
*/
public boolean set( )
{
  String wh = null;

  int gran  = qy.granul() ;
  if( Types.isGranTime(gran) )
     gran = Types.D_HEURE ;
   else if( ( gran & Types.G_JOUR )!=0 )
      gran = Types.D_JOUR;
   else if( ( gran & Types.G_SEMAINE )!=0 )
      gran = Types.D_SEMAINE;
   else if( ( gran & Types.G_MOIS )!=0 )
      gran = Types.D_MOIS;
   else
      gran = Types.D_MOIS * 60 ;

  int gEqp = qy.nivEqp;

  //System.out.print("t="+qy.ctx);
  HashMap p = qy.ctx;
  String type_requete = p.get("type")==null?"":(String) p.get("type");
  String psdate = "";
 // System.out.println("type_requete="+type_requete);
  
  String having = p.get("having")==null?"":(String) p.get("having");
  //System.out.println(qy.ctx+"==having="+having);
  

  if( atoms != null ){// 04 04 2012
  for( int i = 0 ; i < atoms.length ; i++ )
  {
	  //System.out.println("aaaa:"+atoms[i].champ);
   
	  if(atoms[i].fct!=Types.SELECTABLE_GRAPH && atoms[i].fct!=Types.WHEREABLE_GRAPH){
    if( atoms[i].type == Types.LNOM || atoms[i].type == Types.PSDATE )
    {

      if( wh != null ) wh += " or (";
       else wh = "(";

      wh += "nomlogique = '"+atoms[i].val+"'";
      if( atoms[i].val.equalsIgnoreCase("psdate")){
    	  wh+= " and nom_table_ihm='"+type_requete+"'";
      }
      if( atoms[i].fct != 1 ){
         wh += " and filtrable & "+atoms[i].fct;
        // System.out.println("fct:"+atoms[i].fct+" -> "+atoms[i].val);
      }

     wh += ")";

    }
  }
  }
  }
  //wh += " and filtrable > 0 ";

   //commenter pour pouvoir faire une requete graph sans aucun parametre // 04 04 2012
 /* if( wh == null || wh.length() <= 2  )
   {
     qy.setErr( "Requête Inconsistante" );
     return( false);
   }*/


  String dbg ;
  Set rs = qy.con.execute( dbg =
   "select "+
   "coalesce(if(granulariteTemporelle='',0,granulariteTemporelle),1440) granulariteTemporelle,"+
   "lower(nomlogique) nomlogique , lower(champ) champ, "+
   "dbtable , dbnom ,serveur, filtrable, "+
   "granEquipement, champ_de_jointure,"+
   "champ_de_jointure_date,'0' as f_proces  from catalog "+
   "inner join serveur o on( o.id = catalog.serveur ) " +
   "where "+
  "("+wh+") and filtrable > 0 and coalesce(granulariteTemporelle,1440) <= "+gran+
  " order by 2,5,6,1,7 desc");

  qy.req_catalog = dbg; 

  System.out.println( dbg);

  
  
  //ajout des infos colonne,table, serveur ... pour permettre le requetage des tables sous-jointure process
  makeSql m = new makeSql();
   
  
  com.etn.lang.ResultSet.ExResult exRs = new com.etn.lang.ResultSet.ExResult(null,rs.ColName);	
  rs.moveFirst();
  while(rs.next()){
  	//System.out.println("==>"+rs.value(rs.indexOf("SUM(NB_1__DEMANDE)")));
  	exRs.add();
  for(int k=0;k<rs.Cols;k++){
  	String v=rs.ColName[k].trim();
  	//System.out.println("les_colonnes2["+k+"]="+les_colonnes2[k]+"==>"+rs.value(v));
  	exRs.set(k,rs.value(rs.indexOf(v)));

  }
  	exRs.commit();
  }
  
  if( p!=null ){
	  
	  /*graph select*/
	  String tab[] = m.getGraphColumn(p);
	  String tab2[] = m.getGraphColumnAlias(p);
	  String tab3[] = m.getGraphTableAlias(p);
	  
	  /*graph where*/
	  String tab4[] = m.getGraphWhereTable(p);
	  String tab5[] = m.getGraphWhereColumn(p);
	  
	  if(tab!=null){
	  for(int i=0;i<tab.length;i++){
		  //System.out.println("graphTableSelectClause("+i+")= "+tab2[i]+" ="+tab[i] + "======"+tab3[i]);
		  exRs.add();
		  exRs.set("champ",tab[i]);
		  exRs.set("nomlogique",tab2[i]);
		  exRs.set("dbtable",tab3[i]);
		  /*exRs.set("dbnom","otarie");
		  exRs.set("serveur","2");*/
		  
		  exRs.set("dbnom",""+ p.get("graphTableDbName"));
		  exRs.set("serveur",""+p.get("graphTableServerId"));
		  
			  
		  exRs.set("filtrable","63");
		  exRs.set("granulariteTemporelle","1");
		  exRs.set("f_proces","1");
		  
		  exRs.commit();
	  }
	  }
	  
	  if(tab4!=null){
		  for(int i=0;i<tab4.length;i++){
			  exRs.add();
			  System.out.println("getGraphWhereTable("+i+")= "+tab4[i]+" ="+tab5[i]);
			  exRs.set("champ",tab5[i]);
			  exRs.set("nomlogique",tab5[i]);
			  
			  exRs.set("dbtable",tab4[i]);
			  
			  exRs.set("dbnom",""+ p.get("graphTableDbName"));
			  exRs.set("serveur",""+p.get("graphTableServerId"));
			  
			  exRs.set("filtrable","63");
			  exRs.set("granulariteTemporelle","1");
			  exRs.set("f_proces","1");
			  
			  exRs.commit();
		  }
	  }
  }
  
  rs.moveFirst();
  rs =  new com.etn.lang.ResultSet.ItsResult( exRs.getXdr() );
  rs.moveFirst();
  //ajout des infos colonne,table, serveur ... pour permettre le requetage des tables sous-jointure process - fin
  
 // System.out.println("==>"+new String(rs.rs.data));
  
  
  //commenter pour pouvoir faire une requete graph sans aucun parametre // 04 04 2012
  //qy.set_req_catalog = rs;
  
  if( rs.rs.Rows == 0){
	  qy.setErr( "Compteur(s)/Kpi(s) non disponible.") ;
	  return( false);
  }
	  
  //byte indic[] = ajusteTm( rs ); // 04 04 2012
  byte indic[] = (rs.rs.Rows == 0?null:ajusteTm( rs )); 
  if( indic == null )
    return( false);

  /*
  System.out.println("===============     AVANT compressQry       ===========================");

  for(int j=0;j<rs.Cols;j++)
            System.out.print(rs.ColName[j]+"\t");

    System.out.print("\n");
    while(rs.next()){
            for(int j=0;j<rs.Cols;j++)
                    System.out.print(rs.value(j)+"\t");

            System.out.print("\n");
    }

    rs.moveFirst();
   */
  
  compressQry( indic , rs);

  /*
System.out.println("===============	APRES compressQry	===========================");
  
  for(int j=0;j<rs.Cols;j++)
	  System.out.print(rs.ColName[j]+"\t");
  
  System.out.print("\n");
  while(rs.next()){
	  for(int j=0;j<rs.Cols;j++)
		  System.out.print(rs.value(j)+"\t");
	  
	  System.out.print("\n");
  }
	  
  rs.moveFirst();
  */
  
  qy.tinf = new HashMap<String,TableInfo>();
  String last = "";
  /*while( rs.next() )
   {
	  if( rs.value("nomlogique").equals("psdate") ){
		  //psdate = rs.value("champ");
		  qy.psdate= rs.value("dbtable")+"."+DEBUTSEP+rs.value("champ")+FINSEP;
	  }


	  String cle= rs.value(1)+rs.value(4)+rs.value(5);
    // System.out.println("cle:"+cle+" -> "+rs.value(3));
     if( last.equals(cle) == false )
      if(addInfo(rs,qy.tinf)) last = cle;
   }*/

  int i = -1;
  while( rs.next() )
   { //String cle= rs.value(1)+rs.value(4)+rs.value(5);
     //System.out.println("cle:"+cle+" -> "+rs.value(3));
     //if( last.equals(cle) == false )
	  
	  if( rs.value("nomlogique").equals("psdate") ){
		  //psdate = rs.value("champ");
		  qy.psdate= rs.value("dbtable")+"."+DEBUTSEP+rs.value("champ")+FINSEP;
	  } 
	  
     i++;
     if( indic[i] == 1 )
       addInfo(rs,qy.tinf);
   }

  return( check() );

}

/****/




/**
 * Initialiser le tableau indic :
 * On marque dans le tableau indic le row util pour chaque clef.
 * sous condition == ref
 * retour : 0 Ok
 *          > 0 nouvelle granularite
 *          -1  echec
*/
int setIndic( byte indic[] , int clefs[] , byte stamp[], int ref )
{
 int lastk = 0;
 int j = 1;
 for( int i = 0 ; i < indic.length ; i++ )
 { indic[i] = 0;
   if( clefs[i] == lastk )
     { if( j == 0 ) 
        { if( stamp[i] == ref ) 
          { indic[i] = 1; 
            j = 1; 
          }
          else if( stamp[i] < ref  ) 
               return( stamp[i] );
        }
     }
    else 
     { 
       if( j == 0 ) // pas d'égalisation possible
         return(-1); 
       lastk = clefs[i];
       j = 0;
       i--;
     }
 }   
   
 return(0);
}


byte [] ajusteTm( Set rs )
{
 byte indic[] = new byte[rs.rs.Rows];
 byte stamp[] = new byte[rs.rs.Rows];
 int clefs[] = new int[rs.rs.Rows];

 /**
 * Remplir les 2 tableaux clefs et stamp
 */
 for( int i = 0 ; i < rs.rs.Rows ; i++ )
 { 
   rs.next();
	  stamp[i] = (byte) 0;
   //clefs[i] = (rs.value(1)+rs.value(5)+rs.value(6)).hashCode();
	  clefs[i] = (rs.value(1)+rs.value(4)+rs.value(5)).hashCode();
 }

 rs.moveFirst();

 /**
 * Initialiser le tableau indic : 
 * On marque dans le tableau indic le row util pour chaque clef.
 * sous condition == ref
 */
 int ref =  stamp[0];
 int extref;
 while( true )
 { extref = setIndic( indic , clefs , stamp, 255 & ref );
   if( extref == -1 )
     { qy.setErr("Egalisation temporelle impossible");
       return(null);
      }

   if( extref == 0 )
    {  // Maj de la globale de granularite tempo de la requete
      // setTmQy( ref );
       return( indic );
    }

  // System.out.println("On égalise  was:"+ref+"  to:"+ extref);
   ref = extref;
 }


 
}



void arrange( ArrayList<String>elu , ArrayList<String>tbls[] )
{
	HashMap p2 = qy.ctx;
	  String type_requete = p2.get("type")==null?"":(String) p2.get("type");
	  int poids_suppl=0;
	
// Simple cotation des diverses tables 
 HashMap<String,Integer>cote = new  HashMap<String,Integer>();
 
 for( int i = 0 ; i < tbls.length ; i++ )
  if( tbls[i] != null )
   { ArrayList<String> t = tbls[i];
     for( int j = 0 ; j < t.size(); j++ )
       { Integer a = cote.get(t.get(j) );
       if( (""+t.get(j)).equalsIgnoreCase(type_requete)){
    		 poids_suppl=100;
    		  }else{
    		poids_suppl=0;
    	         }
       
         if( a == null ) cote.put(t.get(j), new Integer(1) + poids_suppl );
          else cote.put(t.get(j), new Integer( a.intValue()+1) );
       }
    }

 // et donc le choix non parfait dans certain cas 
 for( int i = 0 ; i < tbls.length ; i++ )
  if( tbls[i] != null )
   { ArrayList<String> t = tbls[i];
     int point = 0;
     int choix = 0;
     for( int j = 0 ; j < t.size(); j++ )
      { int p = cote.get(t.get(j)).intValue();
      	//System.out.println("point("+t.get(j)+")===>"+p);
        if( p > point ) { point = p; choix = j; }
      }
     String table = t.get(choix);
     if(!elu.contains(table) ) elu.add(table);
    }

}


/**
* On cherche a compresser les diverses tables possibles pour la requete/granul
* indic indique le premier row possible 
*/
void compressQry( byte indic[] , Set rs )
{
  
  ArraySet ar = new ArraySet(rs); 
  
  // Les tables elues
  ArrayList<String>elu = new ArrayList<String>();

  // Le nombre de champs
  int nbc = 0;
  for( int i = 0 ; i < indic.length ; i++ )
   if( indic[i] != 0 ) nbc++;

  // Les tables par champ
@SuppressWarnings("unchecked")   // bug java 1.5 sur array
  ArrayList<String>tbls[] = (ArrayList<String>[]) new ArrayList[nbc];
  
  // Init du tableau tbls et elus
  int choix = 0;
  int itbl = 0;

  for( int i = 0 ; i < indic.length ; i++ )
    if( indic[i] == 1 ) 
     { 
       ArrayList<String>t = new ArrayList<String>();
       tbls[itbl++] = t;
       int gran = Integer.parseInt( ar.value(i,0) );
       String champ =  ar.value(i, "nomlogique");
       String tbl = ar.value(i,"dbtable");
       t.add(tbl);
       int j ;
       for( j = i + 1 ;  Integer.parseInt( ar.value(j,0) ) == gran &&
               champ.equals(  ar.value(j, "nomlogique") ) ; j++ )
         t.add( ar.value(j,"dbtable"));

       if( j == (i+1) ) // Seul table pour ce champ
         { if( !elu.contains(tbl) ) 
             elu.add(tbl);
         }
       else 
          choix++;
     }
       
 
  // Si pas de choix ... pas d'optimisation     
  if( choix == 0 ) return;

  // On réduit le tableau tbls :
  // On choisit les tables obligatoires pour 
  // Les champs multivalués.
  choix = 0;
  for( int i = 0 ; i < nbc ; i++ )
    if( tbls[i].size() == 1 )
       tbls[i] = null;
    else
    { ArrayList<String>t = tbls[i];
      for( int j = 0 ; j < t.size(); j++ )
       if( elu.contains(t.get(j)) )
         { tbls[i] = null;  break; }
    }
  

  // Les choix restants
  choix = 0;
  for( int i = 0  ; i < nbc ; i++ )
    if( tbls[i] != null ) 
       choix++;

 
  // Choisir par arrangement
  if( choix != 0 )
   arrange( elu , tbls );

  // Finalement maj de tableau indic
  for( int i = 0 ; i < indic.length ; i++ )
  if( indic[i] != 0 )
  { String tbl = ar.value(i,"dbtable");
    if( elu.contains(tbl) ) 
      continue;
    int j = i+1;
    while( !elu.contains( ar.value(j,"dbtable") ) )
      if(++j == indic.length || indic[j] != 0) 
           return;  // ???
    indic[i] = 0 ; indic[j] = 1; i = j;
  }

}
/****/


public Catalog( Qry q)
{
   qy = q;
   atoms = qy.atoms;
}




}
