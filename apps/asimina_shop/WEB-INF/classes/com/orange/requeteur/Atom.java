package com.orange.requeteur;
import java.util.HashMap;
/**
* Information sur 1 element requete
*/
public class Atom {
// Infos obtenues par scan
String val; // valeur scan
int type;   // type au sens requeteur Types
int fct;    // fonction au sens Types  fonction
int level;  // niveau de recursivite
int group;  // groupe de l'atom
// Infos obtenues par perquistion du Catalogue
// Nulles en général si pertinent pour le type
int con;      // Id de connection
String db;    // database
String table; // table
String champ; // nom physique du champ
TableInfo ti; // pointeur sur infos Table
}


