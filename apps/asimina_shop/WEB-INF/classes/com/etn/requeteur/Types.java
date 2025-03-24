package com.etn.requeteur;

public class Types {

/**
* type d'un atom
*/
public static final int INCONNU = 0 ;
public static final int LNOM = 1 ;
public static final int FONCTION = 2 ;
public static final int ARITHM = 3 ;
public static final int CONST = 4 ;
public static final int OPSQL = 5 ;
public static final int PUNCT = 6 ;
public static final int AS = 7 ;
public static final int OPLOG = 8 ;
public static final int PSDATE = 9 ;
public static final int ESCAPE = 10 ;
public static final int INTERNE = 11 ;
public static final int NOATOM = 12 ;

/**
* Etat d'un type (ored) a ignorer
*/
public static final int NOP  = 1024 ;

/**
* Noms des types
*/
private static final String noms[] = {
"INCONNU",
"CHAMP",
"FONCTION",
"ARITHM",
"CONST",
"OPSQL",
"PUNCT",
"AS",
"OPLOG",
"PSDATE",
"ESCAPE",
"INTERNE",
"NOATOM" };




/**
* Fonction d'un Atom
* champ filtrable du catalogue
*/
public static final int SELECTABLE = 1 ;
public static final int WHEREABLE  = 2 ;
public static final int GROUPABLE  = 4 ;
public static final int SELECTABLE_GRAPH = 8 ;
public static final int WHEREABLE_GRAPH = 16 ;

/**
* Granularité
*/
public static final int G_MINUTE = 1 | 1024;
public static final int G_HEURE = 2  | 512;
public static final int G_JOUR  = 4 |   256;
public static final int G_SEMAINE  = 8 | 128  ;
public static final int G_MOIS  = 16  ;
public static final int G_ANNEE  = 32  ;

public static final int D_MINUTE = 6;
public static final int D_HEURE = 60;
public static final int D_JOUR  = 1440;
public static final int D_SEMAINE  = 10080;
public static final int D_MOIS  =   43920;
public static final int D_ANNEE  =   527040;

/**
* formats de Date a afficher
*/
public static final int 		F_MINUTE = 1;
public static final int 		F_HEURE  = 2;
public static final int 		F_JOUR  = 3;
public static final int 		F_SEMAINE = 4;
public static final int 		F_MOIS = 5;
public static final int     F_ANNEE = 6;

/**
* Hierarchie equipements
*/
public static final String eqpNiveau[] = { "'reseau'", "'ur'", "'omc'","'msc'", "'bsc'", "'site'", "'bts'", "'trx'" };


protected static boolean isGranTime( int gran) { return( (gran & 1536) != 0 ); }

protected static String getName( Atom a )
{ return( noms[ a.type & (~NOP) ] );
}

public static final int sysfiltre=2;
public static final int sysselect=1;
public static final int sysgroupe=4;

public static final int filtre=16;
public static final int select=8;
public static final int groupe=32;
public static final int sysval=64;


}

