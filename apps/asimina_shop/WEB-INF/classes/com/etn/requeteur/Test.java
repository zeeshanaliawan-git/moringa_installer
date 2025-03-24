package com.etn.requeteur;

import com.etn.lang.ResultSet.Set;
import java.util.ArrayList;


public class Test {

static String sepa =
"###################################################################\n";

static void printResult( int id )
{
  Set rs = Cache.getResultSet(id);

  for( int i = 0 ; i < rs.Cols ; i++ )
    System.out.print(rs.ColName[i]+"\t");

   System.out.println();

  while( rs.next() )
  {
    for( int i = 0 ; i < rs.Cols ; i++ )
     System.out.print(rs.value(i)+"\t");

   System.out.println();
  }


}

public static void main( String a[] )
{

  Qry q = new Qry();
  int cmd = 0;

  if( a.length > 0 )
     cmd = Integer.parseInt( a[0] );
  else
    cmd = 10;


  switch( cmd )
  {

  case 0 : // getTables


  String tbls[] = Conteneur.getTables( 1 , "alcatel");
  System.out.println("tbls -> "+tbls.length );
  for( int i = 0 ; i < tbls.length ;i++ )
         System.out.println(tbls[i]);

  break;

  case 1 : // Explain
{
  Explain exp = new Join(q).explain(1,  "alcatel.trafic_edge,alcatel.DOHOSTL7_cpt_bin,requeteurdev.btsv1 , alcatel.DOHOSTL7_cpt_bin,alcatel.trafic_edge, alcatel.osiris_metriques" );

  if( exp == null )
    System.out.println( q.getErr() );
 else
  {
    System.out.println( exp.getSql() );
    System.out.println( "rows:"+exp.countRow() );
    System.out.println( "join:"+exp.countJoin() );
    System.out.println( "join:"+exp.enumTypeJoin() );
    System.out.println( "Most Bad join:"+exp.mostBad() );
    exp.dump( System.out );
  }

}

case 2 : // Jointures
  new Join(q).setJoin( 1 ,
"alcatel.trafic_edge, alcatel.osiris_metriques, requeteurdev.btsv1, alcatel.trafic_edge, alcatel.trafic_edge, alcatel.trafic_edge, requeteurdev.btsv1, requeteurdev.btsv1, requeteurdev.btsv1" );

break;

case 3 :

  if( a.length != 0 )
  { System.out.println( q.parse( a ) );
/**
      new String[] {
  "psdate as b ,sum(MC01)/max(Volume_edge_UL_BHG)  as plouf, concat(MC01,min(Volume_edge_UL_BHG))" ,
  "ur = 'URM DONGES'" ,
  "bsc,   psdate" } ) );
**/

    q.list(true);
    System.out.println( q.getErr() );
    System.out.println( q.getSql() );

 }
break;

case 4:   // parse et multi
     {
       String zz[] =  {
       "duree_moyenne_TBF_DL_BHD, duree_moyenne_TBF_DL_BHE, MC01" ,
       "constructeur='ALCATEL' , UR='URM DONGES' , week(psdate)=15",
       "week(psdate)" };



        if( q.parse(zz) )
        {
          System.out.println("sql >"+sepa);
          q.list(true);
          System.out.println("Exec:"+q.execute());
        }
        else
        { System.out.println("Err> "+ q.getErr() );
          q.list(true);
        }

      break;
    }

case 5 : // list dbs
       Connecteur c = Conteneur.getConnecteur(1);
       String dbs[] = c.getDbs();
       for( int i = 0 ; i < dbs.length ;i++ )
         System.out.println(dbs[i]);

       break;

case 6:
     {

       String zz[] =  {
       "duree_moyenne_TBF_DL_BHD + duree_moyenne_TBF_DL_BHE MC01 " /**
       "sum(MC01+MC02+MC02A+MC02b)/sum(MC03+MC04+MC02g) "+
       "sum(MC02i +MC03 +MC04 )/sum (MC8d) (sum(v_code_rnc))" **/,
       "constructeur='ALCATEL' , UR='URM DONGES' , week(psdate)=15",
       "week(psdate)" };

       if( q.parse(zz) )
        {
          System.out.println("sql >"+sepa);
          q.list(true);
          System.out.println("Exec:"+q.execute());
        }
        else
        { System.out.println("Err> "+ q.getErr() );
          q.list(true);
        }

      break;
    }

case 7 :
        {

       String zz[] =  {
       "dayname(psdate),id,sum(rel+relb),max(v)",
       "constructeur='ALCATEL' , UR='URM LILLE', psdjoin='relax' , week(psdate)=20",
       "dayname(psdate),id" };

       if( q.parse(zz) )
        {
          System.out.println("sql >"+sepa);
          q.list(true);
          int id = q.execute();
          System.out.println("Exec:"+id);
          if( id > 0 )
            printResult(id);

        }
        else
        { System.out.println("Err> "+ q.getErr() );
          q.list(true);
        }

      break;
    }


case 8 :
        {

       String zz[] =  {
       "id,sum(rel+relb),max(v)",
       "constructeur='ALCATEL' , UR='URM LILLE', psdjoin='dddrelax' ",
       "id" };

       if( q.parse(zz) )
        {
          System.out.println("sql >"+sepa);
          q.list(true);
          int id = q.execute();
          System.out.println("Exec:"+id);
          if( id > 0 )
            printResult(id);

        }
        else
        { System.out.println("Err> "+ q.getErr() );
          q.list(true);
        }

      break;
    }

case 9 :
       {

       String zz[] =  {
"MC14A,MC14B,bsc",
"  (psdate between '2006/10/02 00:00' and '2006/10/02 04:00') and   constructeur in ('ALCATEL') and   UR in ('URM DONGES') and   techno in ('1')",
"bsc"
/****

"((Avg(CELL_1044_0_AVG))+(Avg(CCCH_6_1604_0_AVG)))-(Avg(CELL_1045_0_AVG)),no_bsc,day(psdate)",
"   constructeur in ('NORTEL') and   UR in ('URM MARSEILLE') and   no_bsc in ('83','84','85','86','87','88','89','90') and  psdate between '2006/11/22 23:59' and '2006/11/23 23:59'",
"no_bsc,day(psdate)"

**/

        };

       if( q.parse(zz) )
        {
          System.out.println("sql >"+sepa);
          q.list(true);

          if(1==1) return;

          int id = q.execute();
          System.out.println("Exec:"+id);
          if( id > 0 )
            printResult(id);

        }
        else
        { System.out.println("Err> "+ q.getErr() );
          q.list(true);
        }

      break;
    }

case 10 :
       {
/*
"specialite,avg(pat_poids)",
"constructeur = 'EPR' and UR = 'Gynécologie et obstétrique' ",
"specialite"

 String zz[] =  {
" jour(psdate),count(Numero_EPR) ",
" and (etat_epr='Accepter') and (specialite_epr='Gynécologie et obstétrique')  and (psdate between '2006/01/01 00:00' and '2007/12/31 23:59') ",
" jour(psdate),Specialite_EPR "
};

   String zz[] =  {
   "Specialite_EPR,Acte_but,Acte_technique,Autorite_AFSSAPS,Champ_activite_EPR,count(Specialite_EPR)",
   "and (actif_archive>=10) and (etat_epr='Accepter' or etat_epr='Brouillon') and (specialite_epr='Gynécologie et obstétrique')",
   "Specialite_EPR"


};

String zz[] =  {
"specialite_epr,avg(`Patient_poids`)",
"and (Numero_champ_activite>0) and (specialite_epr='Gynécologie et obstétrique')",
"specialite_epr"};

String zz[] =  {
"etat_dosmedsp,etat_dosmedsp,count(id)",
"and (etat_dosmedsp='accepte' or etat_dosmedsp='rejete')",
"etat_dosmedsp"};
*/
    	  /* String zz[] =  {
    	   " jour(psdate),famille,(sum(`nb_prod`)) as \"nb_prod\"",
    	   "  and (code_campagne='01417DR802173')",
    	   "  jour,famille "};

*/
    	/*   String zz[] =  {
    	   " jour(psdate),code_campagne,categorie,libelle,(sum(`nb_cfa`)) as \"NB_CA\"",
    	  " and (categorie='CNAA' or categorie='CNAI')",
    	  " jour(psdate),code_campagne,categorie,libelle"};
*/
    /*	   String zz[] =  {
    	   " jour(psdate),MC01 as test,MC02,(sum(`MC01`)+sum(`MC02`)) as \"MC_1___2\"",
    	   " and (CELL_NAME='EnneryNord_3') ",
    	   " jour(psdate) "};
*/
    	   
    	  /* String zz[] =  {" nom_omc,jour(psdate),MC01,MC02 as test,(sum(`MC01`)+sum(`MC02`)) as \"MC_1___2\",(MC02/MC01) as \"MC\"",
    	  "  month(psdate)=1 and (CELL_NAME='EnneryNord_3') ",
    	  " nom_omc,jour(psdate)"};
			*/
    	   
    	   
    	/*   String zz[] =  {"  minute(psdate),count(`person`)",
    	  " month(psdate)=2",
    	 "  minute(psdate)"};
*/
    	   
/*
    	   String zz[] =  {" mois(psdate),prestataire,famille,(sum(`nb_prod_conf`)) as \"NB_PROD2\"",
    	  " (code_marche='P')and (code_univers='Fixe')",
    	  " mois(psdate),prestataire,famille"};
*/
/*	String zz[] =  {"heure(psdate),ip as ip2",
	"(ip='10.146.51.108' or ip='10.157.210.245' or ip='10.162.110.181' or ip='10.171.101.4' or ip='10.171.102.4') and (psdate between '2008/09/01 00:00' and '2008/11/30 23:59')",
	"1"};
  */

/*	String zz[] =  {"jour(psdate),sum(`nBytes`)",
 "psdate between 1199142000 and 1199142000 and (nameAppli='Chat' or nameAppli='Control' or nameAppli='DB' or nameAppli='FTP' or nameAppli='Games' or nameAppli='Mail' or nameAppli='MailOrange' or nameAppli='MMS' or nameAppli='News' or nameAppli='Others' or nameAppli='P2P' or nameAppli='StreamAVSP' or nameAppli='Streaming' or nameAppli='Unknown' or nameAppli='VoIP' or nameAppli='VPN' or nameAppli='VVM' or nameAppli='Web')",
"1"};
*/

String zz[] = {"idAppli as usages,APN,jour(psdate),sum(`Volume_down_Octet`),sum(`Volume_up_Octet`)",
"(psdate between '2009/08/25 00:00:00' and '2009/08/25 23:59:59') and ( (bsc in ('AngersLacDeMaine4','AngersLacDeMaine5','AngersLacDeMaine6') and constructeur_topo='alcatel 2g'))",
"1,2,3"};

zz = new String[]{
"idAppli,sum(`Volume_down_Octet`)",
" (psdate between '2010-02-08 10:00' and '2010-02-08 23:59:59')  and (idAppli=0 or idAppli=1)",
"1"
};

zz = new String[]{
"idAppli as Usages,jour(psdate),sum(`Volume_down_Octet`),sum(`Volume_up_Octet`),count(`worstNBytesDn`)",
"(idAppli='3' or idAppli='6' or idAppli='8' or idAppli='11')",
"1,2"
};


  	   

 java.util.HashMap h =  new java.util.HashMap();
 h.put("type","VOLUMETRIE TRAFIC");
// h.put("type","0_COMPTAGE_PROD_JOUR");
 //h.put("type","StatAppli");
 //h.put("having","having count(distinct `ip`)");
// h.put("heure","oui"); 
 
 q.setMap(h);

       if( q.parse(zz) )
        {

    	   System.out.println("sql >"+sepa
          +  q.getSql()+
          "\n"+sepa);

          q.list(true);
          //q.listInfos();


          int id = q.execute();
          System.out.println("Exec:"+id);
          if( id > 0 )
            printResult(id);

        }
        else
        { System.out.println("Err> "+ q.getErr() );
          q.list(true);
        }

   } break;

  }

}

}
