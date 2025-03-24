package com.orange.requeteur;

public class Champ {
String nom ;
int typ;
String tstr;
int idx;
int uniq;
String card;
String ix;
int filtrable;

public Champ( String nom ,int typ , String tstr,int filtre)
{
  this.nom = nom; this.typ=typ;this.tstr=tstr;filtrable=filtre;
}

public Champ() {}


}


