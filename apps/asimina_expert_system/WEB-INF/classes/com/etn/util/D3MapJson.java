package com.etn.util;

import java.io.Writer;
import java.io.OutputStreamWriter;
import com.etn.lang.ResultSet.Set;

public class D3MapJson {

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
    print('{');
    niv++;
    indent(niv);
    print("\"type\":\"FeatureCollection\"");
    print(',');
    indent(niv);
    print("\"features\":[");
    
    int i=0;
    while(rs.next())
    {
        if(i++>0) print(',');
        niv++;
        indent(niv);
        print('{');
        niv++;
        indent(niv);
        print("\"type\":\"Feature\",");
        indent(niv);
        print("\"properties\":{");
        niv++;        
        for(int j=0; j<rs.ColName.length; j++)
        {
            if(j>0) print(',');
            indent(niv);
            print("\""+rs.ColName[j].replace("\"", "\\\"").toLowerCase()+"\":\""+rs.value(j).replace("\"", "\\\"")+"\"");
        }
        niv--;
        indent(niv);
        print("},");
        indent(niv);
        print("\"geometry\":{");        
        niv++;
        indent(niv);
        print("\"type\":\"Point\",");
        indent(niv);
        print("\"coordinates\":[");
        niv++;
        indent(niv);
        print(rs.value("longitude") + "," + rs.value("latitude"));
        niv--;
        indent(niv);
        print(']');
        niv--;
        indent(niv);
        print('}');
        niv--;
        indent(niv);
        print('}');
        niv--;
    }
    
    indent(niv);
    print(']');
    niv--;
    indent(niv);    
    print('}');
}

/**
 * ArJson.
 * @param rs : Un Set triÃ© col 0..lastCol.
 * @param out : Le flux de sortie.
 * @param debug : Indentation si true
*/
public D3MapJson ( Set rs , Writer o, boolean debug )
{ 
  this.rs = rs;
  this.out = o;
  this.debug=debug;
  build(rs);
  if( ioErr ) System.err.println( "OutputStream erreur" );
}

public D3MapJson ( Set rs , Writer o )
{ this( rs , o , false); }

public D3MapJson ( Set rs )
{ this( rs , new OutputStreamWriter(System.out) , false); }

public D3MapJson ( Set rs, boolean debug )
{ this( rs , new OutputStreamWriter(System.out) , debug ); }


public static void main( String a[] )
throws Exception
{
   String qy = 
    "select  region, cell, a.ci , longitude, latitude, sum(volume) as traffic, round " +
    "((sum(failure) * 100) / sum(volume), 2) as 'quality' " +
    "from location a, topo b " +
    "where imsi = 612345678912345 " +
    "and a.ci = b.ci " +
    "and month(date) in ('10', '11') " +
    "group by region, cell " +
    "order by sum(volume) desc, region ";

com.etn.Client.Impl.ClientDedie Etn = 
  new com.etn.Client.Impl.ClientDedie( 
   "MySql",
   "com.mysql.jdbc.Driver",
   "jdbc:mysql://127.0.0.1:9306/cem_oml?user=root&password=" );

 Set ar =  Etn.execute(qy) ;
 System.out.println("=== " + ar.rs.Rows);
   OutputStreamWriter zout =  new OutputStreamWriter(System.out);
 D3MapJson z = new D3MapJson( ar, zout, true);
 zout.flush();
 
}

}

