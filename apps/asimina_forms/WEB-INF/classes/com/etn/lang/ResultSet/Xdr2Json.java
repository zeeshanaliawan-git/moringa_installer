package com.etn.lang.ResultSet;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.IOException;
import com.etn.Client.Impl.ClientDedie;
import com.etn.sql.escape;
import com.etn.util.ArJson;
import com.etn.util.PivotJson;
import com.etn.util.D3MapJson;
import com.etn.util.D3MapJsonChl;


/**
 * class Xdr2Json.
 * Conversion de Xdr au format Json.
 * L' OutputStream peut est direct ou un ByteArray  (GrowBuffer).
 * L'encoding rendu est utf-8.
 * Un rs est retourné sous forme d'Objet Json:
 * { key: default rs_[0-N] , result: Row ou -1 si erreur , 
 *   type: format , data: ...... }
 * Soit prototype javascript 
 * Plusieurs types de rendus sont possibles.
 * JSON_FORMULAIRE : Objet ou ArrayList d'objets { c0=v0,c1=v1,...}
 * JSON_TABLE :  [[ c0,c1,...],[v0atR0,v1atRr0,...],[v0atR1,v1atR1...],...]
 *              ou le Row0 est le nom des colonnes.
 * Par défaut : Si le type n'est pas donné à l'appel ou == 0 
 * le type est résolus par le nombre de rows:
    -o 1 Row => formulaire
    -o Sinon table
 * Des types spécifiques seront ajoutés via surclassing.
 * On peut appeler de façon répètitive la fonction getJson,
 * dans ce cas c'est a l'appelant de gérer la suite des appels.
 * où appeler getJson avec un tableau de rs,  auquel cas 
 * un json dedinitif sera construit.
 */ 

public class Xdr2Json {


OutputStream out;

void wcar( int c ) 
{ try { out.write(c); }
  catch(Exception e) { }
}

void wr( String s) 
{ 
 try {
  out.write( s.getBytes("UTF-8") ); 
 }
 catch ( Exception e ) 
 { e.printStackTrace();
 }
}

String removeSpecialCharInColName(String colName){


  if(colName.length()>0){

    colName = colName.replace("(", "");
    colName = colName.replace(")","");
    colName = colName.replace("*","");
  }
  return colName;
}

void wVal( String s, byte typ ) 
{ 
  switch( typ ) { 
  case 4 : case 5 : case 6 : case 8: 
      wr( (s.length()>0 ? s: "null") );
      break;

  default : 
     { int p , q = 0;
       wcar('"');
       while( ( p = s.indexOf('"',q) ) != -1 )
       { wr( s.substring( q , p) + "\\\"");
         q = p + 1;
       }
       wr( s.substring(q) + "\"" );
       break;
     }
  }
}
  

int w3dJs_Hierach(Set rs)
{ 
  try {
  OutputStreamWriter zout =  new OutputStreamWriter(out);
  new ArJson( new ArraySet(rs) , zout );
  zout.flush();
  return(0);
  }
  catch(Exception aa) { return(-1); }
}
   
int pivotJson(Set rs)
{
  try {
  OutputStreamWriter zout =  new OutputStreamWriter(out);
  new PivotJson( rs , zout );
  zout.flush();
  return(0);
  }
  catch(Exception aa) { return(-1); }    
}

int d3MapJson(Set rs)
{
  try {
  OutputStreamWriter zout =  new OutputStreamWriter(out);
  new D3MapJson( rs , zout );
  zout.flush();
  return(0);
  }
  catch(Exception aa) { return(-1); }    
}

int d3MapJsonChl(Set rs)
{
  try {
  OutputStreamWriter zout =  new OutputStreamWriter(out);
  new D3MapJsonChl( rs , zout );
  zout.flush();
  return(0);
  }
  catch(Exception aa) { return(-1); }    
}

int  wOther(Set rs)
{ System.err.println( "not Implemented" );
  return(0);
}
int wJsonArray( Set rs , boolean ignoreColumnNames)
{
 
    int c = 0;
    wcar('[');
    if(!ignoreColumnNames)
    {
        wr("[\""+removeSpecialCharInColName(rs.ColName[0])+"\"");
        for( int i = 1 ; i < rs.Cols ; i++ ) 
        wr( ",\""+removeSpecialCharInColName(rs.ColName[i])+"\""); 
        wcar(']');
        c++;
    }

 while( rs.next() )
 { 
     if(c++>0) wcar(',');
     wr("[" );
   for( int i = 0 ; i < rs.Cols ; i++ )
    { if( i != 0 ) wcar(',');
      wVal( rs.value(i) , rs.types[i]);
    }
   wcar(']');
  }

  wcar(']');
  //wcar(10);
  return(0);
}
int wJsonObject( Set rs )
{
 
  
 if( rs.rs.Rows > 1 ) 
   wcar('['); 
 
  while( rs.next() ) 
  { if( rs.Row > 1 ) wr("},{"); else wcar('{');
    for( int i = 0 ; i < rs.Cols ; i++ )
      { wr( (i!=0?",":"")+"\""+removeSpecialCharInColName(rs.ColName[i])+"\":");
        wVal(rs.value(i),rs.types[i]);
      }
  }

  wcar('}'); 
  if( rs.rs.Rows > 1 ) wcar(']'); 
  //wcar(10);
  return(0);
}

int wC3Json(Set rs)
{
    wcar('['); 
    
    for(int i=0;i<rs.Cols;i++)
    {
        if(i>0) wcar(',');
        rs.moveFirst();
        wr( "[\""+removeSpecialCharInColName(rs.ColName[i]).replace("\"", "\\\"") +"\""); 
        while(rs.next())
        {
            wcar(',');
            wVal(rs.value(i),rs.types[i]);
        }
        wcar(']');
    }    
    
    wcar(']'); 
    
    return (0);
}
public int getJson( Set rs , String clef, int fmt, boolean ignoreColumnNames )
throws IOException
{ 
  
   if( fmt == 0 && rs != null ) 
     fmt=( rs.rs.Rows > 1 ? 2 : 1 );

   if( rs == null || rs.rs.Rows == 0 ) 
   { wr( "{\"key\":\""+clef+"\",\"result\":"+
         (rs == null?-1:0)+",\"fmt\":"+fmt+",\"data\":null}");
     return(0);
   }
   else
    wr( "{\"key\":\""+clef+"\",\"result\":"+rs.rs.Rows+",\"fmt\":"+fmt+",\"cols\":"+rs.Cols+",\"data\":");


   switch( fmt ) {
   case 1 : wJsonObject( rs ); break;
   case 2 : wJsonArray(rs, ignoreColumnNames); break;
   case 3 : if(w3dJs_Hierach(rs)!=0) 
              wr("null"); 
             break;
   case 4 : wC3Json(rs); break;
   case 5 : if(pivotJson(rs) != 0)
                wr("null");
            break;
   case 6 : if(d3MapJson(rs) != 0)
                wr("null");
            break;
   case 7 : if(d3MapJsonChl(rs) != 0)
                wr("null");
            break;
   default : wOther(rs); break;
   }
  
   wcar('}');
   out.flush();
   return( rs.rs.Rows); 
}

public int getJson( Set rs , String clef, int fmt )
throws IOException
{
    return getJson(rs, clef, fmt, false);
}

public int getJson( Set rs[] , String clefs[] , int fmt[] )
throws IOException
{ 
  int r = 0;
  int z;
 
  wcar('['); 
  for( int i = 0 ; i < rs.length ; i++ ) 
  { if( i!=0) wcar(',');
    try { z=fmt[i]; } catch(Exception u) { z=0; }
    r += getJson( rs[i] , clefs[i] , z , false);
  }

 wcar(']');
 wcar(10);
 return(r);
}
public int getJson( Set rs[]  )
throws IOException
{ 
  String k[] = new String[ rs.length ];
  for( int i = 0 ; i < k.length ; i++ ) 
    k[i] = "rs_"+i;
  return( getJson(rs , k , null));
}

public Xdr2Json( OutputStream o ) { out = o; }

public static void main(String a[] )
throws Exception
{ 

  Xdr2Json json = null;
  ClientDedie etn = new ClientDedie( "MySql" , 
   "com.mysql.jdbc.Driver",
   "jdbc:mysql://127.0.0.1:3306/cemoml?user=root&password=" );
//   String qy = 
//    "select 'bsf\"a' as i, '01/02/2014' as date, '89' as value, 1 as v " +
//"union  " +
//"select 'bsf\"a' as i, '05/02/2014' as date, '109' as value, 2 as v " +
//"union " +
//"select 'bsr' as i, '05/02/2014' as date, '159' as value, 3 as v " +
//"union " +
//"select 'bsr' as i, '10/02/2014' as date, '166' as value, 4 as v" ;

    String qy =
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
	" GROUP BY c.id_commune limit 10 ";

  
  Set bidon = etn.execute( qy);

  json = new Xdr2Json( System.out );
  json.getJson( bidon,"pivot",7  , false);
  

//  ClientDedie etn = new ClientDedie( "MySql" , 
//   "com.mysql.jdbc.Driver",
//   "jdbc:mysql://127.0.0.1:3406/cimamea?user=root&password=" );
//
// 
//  // test 1 : 
//  System.out.println( "<meta charset=\"utf-8\" />\n<script>\nvar test1 = " );
//
//  Set bidon = etn.execute(
//     "select '\"il fait\" beau en été\"' bidon0, 4 as i , pi() as pi, "+
//     "convert('il fait\" bô en été' using latin1) as lat" );
//
//  json = new Xdr2Json( System.out );
//  json.getJson( bidon,"bidon",0  );
//
//  System.out.println(";\ndocument.write(test1.data.LAT+'<BR>');");
//
//  System.out.println("var test2=");
//  bidon.moveFirst();
//  json = new Xdr2Json( System.out );
//  json.getJson( bidon,"bidon",2  );
//
//  System.out.println(";\ndocument.write("+
//    "test2.data[0][3]+' : '+test2.data[1][3]+'<BR>');");
//
//
//
//
//  String searchOn = "4601783";
//
//  Set rs[] = new Set[3];
//  rs[0] = etn.execute(
//        "select customer_id , customer_parent_id ,nom, prenom, adresse, "+
//        "societe, nlignes, solde "+
//        " from exp_client c , ("+
//        " select   count(*) nlignes from exp_nlignes "+
//        " where  customer_id = "+escape.cote(searchOn)+ " ) l "+
//        " where customer_id=" +escape.cote(searchOn)) ;
//
//  rs[1] = etn.execute( "select nu "+
//        "nu, status, date_status, imsi, postpaid, plan_name, active_date,"+
//        " last_cost, terminal, result_balance "+
//        " from exp_nlignes where customer_id = "+
//        escape.cote(searchOn)+" order by active_date desc " );
//
//  String nu = "95102330";
//  rs[2] = etn.execute( 
//   "select typ, nu, semaine, conso, count, balance, begin_date,"+
//   "coalesce(price_plan_name,'' ) plan from ( "+
//   "( select 'DATA' typ,d.* from exp_prepaid_data_week d where nu = "+nu+
//   ") union (select 'VOICE',v.* from exp_prepaid_voice_week v where nu ="+nu+
//   ") union (select 'RECHARGE',v.*,'' plan from "+
//       "exp_prepaid_recharge_week v where nu ="+nu+
//   ") union (select 'BAL',v.*,'' plan from exp_bal_week v where nu = "+nu+
//       " and year(begin_date)=2014 "+
//   ") union (select 'VOICE_POST',v.* from exp_postpaid_voice_week v where nu ="+nu+
//   " and year(begin_date)=2014) order by semaine desc, begin_date desc ) a "+
//   " left join price_plan b on a.plan= b.price_plan_id " );
//
//
//
//  json = new Xdr2Json( System.out );
//
//  
//  System.out.println("var test3=");
//  json.getJson( rs  );
//  
//  System.out.println( 
//    "for( var i in test3 )"+
//   " {"+
//      "var rs = test3[i];"+
//
//     " switch( rs.key) {"+
//    "  case 'rs_0' :"+
//       " document.write('cust:'+rs.data[\"CUSTOMER_ID\"]+'<br>');"+
//      "  break;"+
//     " case 'rs_1' :"+
//       " var nc = rs.data[0].length;"+
//      "  document.write(rs.data[0][nc-1]+':'+rs.data[rs.result][nc-1]+'<br>');"+
//      "  break;"+
//     " case 'rs_2' :"+
//     "   var nc = rs.data[0].length;"+
//     "   document.write(rs.data[0][nc-1]+':'+rs.data[rs.result][nc-1]+'<br>');"+
//     "   break;"+
//    "  }"+
//   " } ; ");
//
//
//  System.out.println("</script>");
}

}


