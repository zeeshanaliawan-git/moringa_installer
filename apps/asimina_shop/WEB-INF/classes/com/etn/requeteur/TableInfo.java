package com.etn.requeteur;

/**
* Info sur table.
* En particulier resolution equipement et temps
*/
public class TableInfo {
String jDate[];      // Les champs de resolutions date
int minutes;         // Unite de la resolution date
String jTopo;        // champ de jointure equipement
String granularite;  // itype de l'equipement pour cette table.

/**
* TableInfo.
* @param granEquipement type de l'equipement.
* @param champ_de_jointure  champ de jointure equipement.
* @param gminutes Unite de la resolution datei.
* @param champ_de_jointure_date Les champs de resolution: date separateur
*  ',' .
*/
public TableInfo( String granEquipement , String champ_de_jointure ,
      String gminutes, String champ_de_jointure_date)
{
  granularite = granEquipement;
  jTopo = champ_de_jointure;
  if( gminutes.length() == 0 ) minutes = 0;
    else minutes = Integer.parseInt( gminutes );
  jDate = champ_de_jointure_date.split(",");

  for( int i = 0 ; i < jDate.length ;i++ )
  { String s = jDate[i].trim().toLowerCase();
  if(!s.equals("")){
  if( s.charAt(0) != '`' ) jDate[i] = "`"+s+"`"; else jDate[i] = s;
    //System.out.println("jDate["+i+"]="+s);
  }

  }

}

}

