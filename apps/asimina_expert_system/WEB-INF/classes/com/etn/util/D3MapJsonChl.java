package com.etn.util;

import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.etn.lang.ResultSet.Set;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class D3MapJsonChl {

final boolean debug ;
final String indents = "\t\t\t\t\t\t\t\t\t\t\t\t\t\t" ;

int niv=0;
// Pour debug : On fait une identation pour lisibilitÃ© du resultat
final Set rs;

Writer out;
boolean ioErr = false;

void print( int c )
{ try { out.write(c); } catch(Exception e){ioErr=true;} }

void print( String s )
{ try { out.write(s); } catch(Exception e){ioErr=true;} }

/**
 * indent.
 * en debug : on rend lisible
*/
void indent(int niv )
{
  if( debug)
    print("\n"+indents.substring(0,niv));

}

private String parseNull(Object o)
{
    if( o == null )
    return("");
    String s = o.toString();
    if("null".equals(s.trim().toLowerCase()))
    return("");
    else
    return(s.trim());
}


/**
 * build.
 * Construction du json resultat via appel rÃ©cursif.
 * Les globales de la classe ont Ã©tÃ© initialisÃ©es.
*/
void build(Set rs)
{

	Map<String, Object> resultat = new LinkedHashMap<String, Object>();
	List<Map<String, Object>> listCommunes = new ArrayList<Map<String, Object>>();
	Map<String, Object> commune = new LinkedHashMap<String, Object>();
    HashMap<String, Object> prp = new HashMap<String, Object>();
    while(rs.next())
    {
    	commune = new HashMap<String, Object>();
    	commune.put("type", "Feature");
    	prp = new HashMap<String, Object>();
    	prp.put("commune", rs.value("commune"));
    	prp.put("indicator", rs.value("indicator"));
    	prp.put("nb_imsi", rs.value("nb_imsi"));
    	prp.put("aupu", rs.value("aupu"));
    	commune.put("properties", prp);
    	prp = new HashMap<String, Object>();
    	prp.put("type", "MultiPolygon");
    	prp.put("coordinates", rs.value("geometry_c"));
    	commune.put("geometry", prp);
    	listCommunes.add(commune);        
    }
    resultat.put("type", "FeatureCollection");
    resultat.put("features", listCommunes);
    print(getJson(resultat).replaceAll(":\"\\[", ":\\[").replaceAll("\\]\"}", "\\]}"));
}

/**
 * Méthode qui permet de récuperer le JSON de l'affichage de tous les composants de la synthèse
 * 
 * @return String json
 */
public String getJson(Object test) {
	String json = null;
	if (test != null) {
		json = serialize(test);
	}
	return json;
}

/**
 * Serialise json file
 * 
 * @param obj Hashmap resultat
 * @return json serialised
 */
private String serialize(Object obj) {
	// Gson gson = new Gson();
	Gson gson = new GsonBuilder().serializeNulls().create();
	String json = gson.toJson(obj);
	return json;
}


/**
 * ArJson.
 * @param rs : Un Set triÃ© col 0..lastCol.
 * @param out : Le flux de sortie.
 * @param debug : Indentation si true
*/
public D3MapJsonChl ( Set rs , Writer o, boolean debug )
{
  this.rs = rs;
  this.out = o;
  this.debug=debug;
  build(rs);
  if( ioErr ) System.err.println( "OutputStream erreur" );
}

public D3MapJsonChl ( Set rs , Writer o )
{ this( rs , o , false); }

public D3MapJsonChl ( Set rs )
{ this( rs , new OutputStreamWriter(System.out) , false); }

public D3MapJsonChl ( Set rs, boolean debug )
{ this( rs , new OutputStreamWriter(System.out) , debug ); }


public static void main( String a[] )
throws Exception
{
	// QUERY EXAMPLES
    String qy_ =
	"SELECT c.commune AS commune,c.json AS geometry_c, AVG(qual) AS indicator " +
	"FROM geo_communes c "+
	"LEFT JOIN geo_com_cells cc ON cc.id_commune = c.id_commune "+
	"LEFT JOIN "+ 
	"(SELECT 0.75 * (10 - "+
	" ((10 * (SUM(OckoOnnet) +  SUM(OcKoOffNet) + SUM(OcKoFixeOrange) + SUM(OcKoFixeSotelma) + SUM(OcKoInt) + SUM(OcKoCustServ) + "+
	" SUM(OcKoShort) + SUM(OcKoOther))) / "+
	" (SUM(OcInitOnNet) + SUM(OcInitOffNet) + SUM(OcInitFixeOrange) + SUM(OcInitFixeSotelma) + SUM(OcInitInt) "+
	" + SUM(OcInitCustServ) + SUM(OcInitShort) + SUM(OcInitOther)))) "+
	" + 0.25 * (10 - (10 * (SUM(SmsMoKoOnNet) + SUM(SmsMoKoOffNet) +  SUM(SmsMoKoInt) + SUM(SmsMoKoOther) + SUM(SmsMtKoOnNet) + "+
	" SUM(SmsMtKoOffNet) + SUM(SmsMtKoInt) + SUM(SmsMtKoOther))) / (SUM(SmsMookOnNet) + SUM(SmsMookOffNet) +  SUM(SmsMookInt) + SUM(SmsMookOther) + SUM(SmsMtokOnNet) + SUM(SmsMtokOffNet) + "+
	" SUM(SmsMtokInt) + SUM(SmsMtokOther)))  AS qual,`LstCi`,`LstLac` "+  
	" FROM  encode_cols_agreg j "+
	" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) "+ 
	" GROUP BY `LstCi`,`LstLac`) "+
	" toto ON cc.ci = toto.LstCi AND cc.lac = toto.LstLac "+
	" GROUP BY c.id_commune ";
	   
    String qy3 = "select nom, qoe from encode_cols_agreg_area_mois a, area b WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH ))  and a.type = 'commune' and a.id = b.id ";
    
	   
    String qy2 =
	"SELECT c.nom_region AS commune,c.json AS geometry_c, AVG(qual) AS indicator " +
	"FROM geo_regions c "+
	"LEFT JOIN geo_reg_cells cc ON cc.id_region = c.id_region "+
	"LEFT JOIN "+ 
	"(SELECT 0.75 * (10 - "+
	" ((10 * (SUM(OckoOnnet) +  SUM(OcKoOffNet) + SUM(OcKoFixeOrange) + SUM(OcKoFixeSotelma) + SUM(OcKoInt) + SUM(OcKoCustServ) + "+
	" SUM(OcKoShort) + SUM(OcKoOther))) / "+
	" (SUM(OcInitOnNet) + SUM(OcInitOffNet) + SUM(OcInitFixeOrange) + SUM(OcInitFixeSotelma) + SUM(OcInitInt) "+
	" + SUM(OcInitCustServ) + SUM(OcInitShort) + SUM(OcInitOther)))) "+
	" + 0.25 * (10 - (10 * (SUM(SmsMoKoOnNet) + SUM(SmsMoKoOffNet) +  SUM(SmsMoKoInt) + SUM(SmsMoKoOther) + SUM(SmsMtKoOnNet) + "+
	" SUM(SmsMtKoOffNet) + SUM(SmsMtKoInt) + SUM(SmsMtKoOther))) / (SUM(SmsMookOnNet) + SUM(SmsMookOffNet) +  SUM(SmsMookInt) + SUM(SmsMookOther) + SUM(SmsMtokOnNet) + SUM(SmsMtokOffNet) + "+
	" SUM(SmsMtokInt) + SUM(SmsMtokOther)))  AS qual,`LstCi`,`LstLac` "+  
	" FROM  encode_cols_agreg j "+
	" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) "+ 
	" GROUP BY `LstCi`,`LstLac`) "+
	" toto ON cc.ci = toto.LstCi AND cc.lac = toto.LstLac "+
	" GROUP BY c.id_region ";
    
    String qy1c = " SELECT c.`commune` AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
 " FROM geo_communes  c " +
 " LEFT JOIN ( " +
 " SELECT b.id, qoe FROM encode_cols_agreg_area_mois a, area b " + 
 " WHERE a.type = 'commune'  AND a.id = b.id AND startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) " + 
 " ) qy_qoe ON qy_qoe.id = c.id_commune ";
    
    String qy1r = " SELECT c.nom_region AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
 " FROM geo_regions  c " +
 " LEFT JOIN ( " +
 " SELECT b.id, qoe FROM encode_cols_agreg_area_mois a, area b " +
 " WHERE a.type = 'region'  AND a.id = b.id AND startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) " + 
 " ) qy_qoe ON qy_qoe.id = c.id_region ";
    
    

    String qy2c = " SELECT c.`commune` AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
 " FROM geo_communes  c " +
 " LEFT JOIN " +
" ( select b.id,round((100 - (100 * qoe)/ (select qoe from encode_cols_agreg_area_mois b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) and b.id = a.id and type = 'commune')),2) as qoe " +
" from encode_cols_agreg_area_mois a, area b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 0 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 0 MONTH )) and a.type = 'commune' " +
" and a.id = b.id ) " +
" qy_qoe ON qy_qoe.id = c.id_commune ";
 
     
    String qy2r = " SELECT c.nom_region AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
 " FROM geo_regions  c " +
 " LEFT JOIN " +
" ( select b.id,round((100 - (100 * qoe)/ (select qoe from encode_cols_agreg_area_mois b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) and b.id = a.id and type = 'region')),2) as qoe " +
" from encode_cols_agreg_area_mois a, area b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 0 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 0 MONTH )) and a.type = 'region' " + 
" and a.id = b.id) " +
" qy_qoe ON qy_qoe.id = c.id_region ";
    

 
     
    String qy3r = " SELECT c.nom_region AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
 " FROM geo_regions  c " +
 " LEFT JOIN " +
" ( select b.id,round((100 - (100 * (OcInitOnNet + OcInitOffNet + OcInitFixeOrange + OcInitFixeSotelma +  " +
" OcInitCustServ + OcInitShort + OcInitOther + OcInitOnNet3g + OcInitOffNet3g + OcInitFixeOrange3G + OcInitFixeSotelma3G + " +
" OcInitCustServ3g + OcInitShort3g + OcInitOther3g))/ (select (OcInitOnNet + OcInitOffNet + OcInitFixeOrange + OcInitFixeSotelma + " +
" OcInitCustServ + OcInitShort + OcInitOther + OcInitOnNet3g + OcInitOffNet3g + OcInitFixeOrange3G + OcInitFixeSotelma3G + " +
" OcInitCustServ3g + OcInitShort3g + OcInitOther3g) from encode_cols_agreg_area_mois b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND " + 
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) and b.id = a.id and type = 'region')),2) qoe " +

" from encode_cols_agreg_area_mois a, area b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 0 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 0 MONTH )) and a.type = 'region' and a.id = b.id ) " +
" qy_qoe ON qy_qoe.id = c.id_region ";
    
    String qy3c = " SELECT c.`commune` AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
 " FROM geo_communes  c " +
 " LEFT JOIN " +
" ( select b.id,round((100 - (100 * (OcInitOnNet + OcInitOffNet + OcInitFixeOrange + OcInitFixeSotelma + " +
" OcInitCustServ + OcInitShort + OcInitOther + OcInitOnNet3g + OcInitOffNet3g + OcInitFixeOrange3G + OcInitFixeSotelma3G +  " +
" OcInitCustServ3g + OcInitShort3g + OcInitOther3g))/ (select (OcInitOnNet + OcInitOffNet + OcInitFixeOrange + OcInitFixeSotelma + " +
" OcInitCustServ + OcInitShort + OcInitOther + OcInitOnNet3g + OcInitOffNet3g + OcInitFixeOrange3G + OcInitFixeSotelma3G +  " +
" OcInitCustServ3g + OcInitShort3g + OcInitOther3g) from encode_cols_agreg_area_mois b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) and b.id = a.id and type = 'commune')),2) qoe " +
" from encode_cols_agreg_area_mois a, area b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 0 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 0 MONTH )) and a.type = 'commune' and a.id = b.id ) " +
" qy_qoe ON qy_qoe.id = c.id_commune ";
  
    
    String qy4r = " SELECT c.nom_region AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
 " FROM geo_regions  c " +
 " LEFT JOIN " +
" ( select b.id,round((100 - (100 * (SmsMoOkOnNet + SmsMoOkOffNet + SmsMoOkInt + SmsMoOkOther + SmsMoOkOnNet3g + SmsMoOkOffNet3g +  " +
" SmsMoOkInt3g + SmsMoOkOther3g))/ (select (SmsMoOkOnNet + SmsMoOkOffNet + SmsMoOkInt + SmsMoOkOther + SmsMoOkOnNet3g + " +
" SmsMoOkOffNet3g + SmsMoOkInt3g + SmsMoOkOther3g) from encode_cols_agreg_area_mois b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) and b.id = a.id and type = 'region')),2) qoe " +
" from encode_cols_agreg_area_mois a, area b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 0 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 0 MONTH )) and a.type = 'region' and a.id = b.id )	 " +
" qy_qoe ON qy_qoe.id = c.id_region ";
    
    
    String qy4c = " SELECT c.`commune` AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
 " FROM geo_communes  c " +
 " LEFT JOIN " +
" ( select b.id,round((100 - (100 * (SmsMoOkOnNet + SmsMoOkOffNet + SmsMoOkInt + SmsMoOkOther + SmsMoOkOnNet3g + SmsMoOkOffNet3g + SmsMoOkInt3g + SmsMoOkOther3g))/ " +
" (select (SmsMoOkOnNet + SmsMoOkOffNet + SmsMoOkInt + SmsMoOkOther + SmsMoOkOnNet3g + SmsMoOkOffNet3g + SmsMoOkInt3g + SmsMoOkOther3g)  " +
" from encode_cols_agreg_area_mois b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND  " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) and b.id = a.id and type = 'commune')),2) qoe " +
" from encode_cols_agreg_area_mois a, area b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 0 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 0 MONTH )) and a.type = 'commune' and a.id = b.id ) " +
" qy_qoe ON qy_qoe.id = c.id_commune ";
    
    
     
String qy5r = " SELECT c.nom_region AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
		 " FROM geo_regions  c " +
		 " LEFT JOIN " +
" (select b.id,round((100 - (100 * aupu_voix)/ (select aupu_voix from encode_cols_agreg_area_mois b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) and b.id = a.id and b.type = 'region')),2) qoe " +
" from encode_cols_agreg_area_mois a, area b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 0 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 0 MONTH )) and b.type = 'region' and a.id = b.id )  " +
" qy_qoe ON qy_qoe.id = c.id_region ";


String qy5c = " SELECT c.`commune` AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
		 " FROM geo_communes  c " +
		 " LEFT JOIN " +
		 " ( select b.id,round((100 - (100 * aupu_voix)/ (select aupu_voix from encode_cols_agreg_area_mois b " +
		 " WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND " +
		 " LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) and b.id = a.id and b.type = 'commune')),2) qoe " +
		 " from encode_cols_agreg_area_mois a, area b  " +
		 " WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 0 MONTH) , '%Y-%m-01') AND " +
		 " LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 0 MONTH )) and a.type = 'commune'  and a.id = b.id ) " +
		 " qy_qoe ON qy_qoe.id = c.id_commune ";


String qy6r = " SELECT c.nom_region AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
		 " FROM geo_regions  c " +
		 " LEFT JOIN " +
" ( select b.id,round((100 - (100 * aupu_sms)/ (select aupu_sms from encode_cols_agreg_area_mois b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) and b.id = a.id and b.type = 'region')),2) qoe " +
" from encode_cols_agreg_area_mois a, area b " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 0 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 0 MONTH )) and a.type = 'region' and a.id = b.id )  " +
" qy_qoe ON qy_qoe.id = c.id_region ";


String qy6c = " SELECT c.`commune` AS commune, qy_qoe.qoe AS indicator ,c.json AS geometry_c " +
		 " FROM geo_communes  c " +
		 " LEFT JOIN " +
" (select b.id,round((100 - (100 * aupu_sms)/ (select aupu_sms from encode_cols_agreg_area_mois b " + 
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 1 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 1 MONTH )) and b.id = a.id and type = 'commune')),2) qoe " +
" from encode_cols_agreg_area_mois a, area b  " +
" WHERE startdate BETWEEN DATE_FORMAT( DATE_SUB( NOW( ) , INTERVAL 0 MONTH) , '%Y-%m-01') AND " +
" LAST_DAY( DATE_SUB( NOW( ) , INTERVAL 0 MONTH )) and a.type = 'commune' and a.id = b.id ) " +
" qy_qoe ON qy_qoe.id = c.id_commune ";
    		
    		
    		
    		

    com.etn.Client.Impl.ClientDedie Etn = new com.etn.Client.Impl.ClientDedie(
    		"MySql",
    		"com.mysql.jdbc.Driver",
    		"jdbc:mysql://192.168.2.76:9406/cem_oml?user=root&password=" );

    Set ar =  Etn.execute(qy6c) ;
    System.out.println("=== " + ar.rs.Rows);
    OutputStreamWriter zout =  new OutputStreamWriter(System.out);
    D3MapJsonChl z = new D3MapJsonChl( ar, zout, true);
    zout.flush();
}
}



