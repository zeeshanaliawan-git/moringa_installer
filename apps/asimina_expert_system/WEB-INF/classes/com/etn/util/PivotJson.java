package com.etn.util;

import java.io.Writer;
import java.io.OutputStreamWriter;
import com.etn.lang.ResultSet.Set;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class PivotJson {

final boolean debug ;
// Pour debug : On fait une identation pour lisibilité du resultat 
final Set rs;  

boolean returnRowsFormat;

Writer out;
boolean ioErr = false;
int pivotedCols = 0;
Map<String, PivotObject> pivotObjects = null;

void print( int c ) 
{ try { out.write(c); } catch(Exception e){ioErr=true;} }

void print( String s ) 
{ try { out.write(s); } catch(Exception e){ioErr=true;} }
 

/**
 * build.
 * Construction du json resultat via appel récursif.
 * Les globales de la classe ont été initialisées.
*/
void build(Set rs)
{
    this.pivotedCols = rs.Cols-1;
    while(rs.next())
    {
        PivotObject po = pivotObjects.get(rs.value(0));
        boolean addColNames = false;
        if(po == null)
        {
            po = new PivotObject();
            po.colNames = new ArrayList<String>(rs.Cols-1);
            po.colValues = new ArrayList<List<String>>();
            pivotObjects.put(rs.value(0), po);
            addColNames = true;
        }
        List<String> colValues = new ArrayList<String>(rs.Cols-1);
        po.colValues.add(colValues);
        for(int i=1; i<rs.ColName.length; i++)
        {
           // System.out.println("## " + ar.value(i));
            if(addColNames) po.colNames.add(rs.value(0).toUpperCase().replace("\"", "\\\"") + " " + rs.ColName[i].replace("\"", "\\\""));
            colValues.add(rs.value(i).replace("\"", "\\\""));
        }
    }
}

void writeK()
{
    print("[");

    int i=0;
    for(String key : pivotObjects.keySet())
    {
        if(i++ > 0) print(",");
                
        for(int j=0; j<pivotObjects.get(key).colNames.size(); j++)
        {
            if(j>0) print(",");
            print("[");            
            print("\""+pivotObjects.get(key).colNames.get(j) +"\"");
            for(int k=0; k<pivotObjects.get(key).colValues.size(); k++)
            {
                print(",");
                print("\""+pivotObjects.get(key).colValues.get(k).get(j) +"\"");
            }
            print("]");
        }
        
    }
    
//    for(String key : pivotObjects.keySet())
//    {
//        for(int j=0; j< pivotObjects.get(key).colNames.size(); j++)
//        {
//            if(i++ > 0) print(",");
//            print("\"" + pivotObjects.get(key).colNames.get(j) + "\"");
//        }
//    }
//    print("]");    
//    
//    i=0;
//    for(String key : pivotObjects.keySet())
//    {
//        for(int j=0; j< pivotObjects.get(key).colValues.size(); j++)
//        {            
//            print(",[");
//            int m = 0;
//            for(int k=0; k<(i*pivotedCols); k++)
//            {
//                if(m++ > 0) print(",");
//                print("\"\"");
//            }
//            for(int k=0; k < pivotObjects.get(key).colValues.get(j).size(); k++)
//            {
//                if(m++ > 0) print(",");
//                print("\"" + pivotObjects.get(key).colValues.get(j).get(k) + "\"");
//            }
//            for(int k=0; k<(pivotObjects.size()-(i*pivotedCols)); k++)
//            {
//                if(m++ > 0) print(",");
//                print("\"\"");
//            }            
//            print("]");
//        }
//        i++;
//    }
    print("]");    
        
}

void writeKRows()
{
    print("[");
    print("[");

    int i=0;
    
    for(String key : pivotObjects.keySet())
    {
        for(int j=0; j< pivotObjects.get(key).colNames.size(); j++)
        {
            if(i++ > 0) print(",");
            print("\"" + pivotObjects.get(key).colNames.get(j) + "\"");
        }
    }
    print("]");    
    
    i=0;
    for(String key : pivotObjects.keySet())
    {
        for(int j=0; j< pivotObjects.get(key).colValues.size(); j++)
        {            
            print(",[");
            int m = 0;
            for(int k=0; k<(i*pivotedCols); k++)
            {
                if(m++ > 0) print(",");
                print("\"\"");
            }
            for(int k=0; k < pivotObjects.get(key).colValues.get(j).size(); k++)
            {
                if(m++ > 0) print(",");
                print("\"" + pivotObjects.get(key).colValues.get(j).get(k) + "\"");
            }
            for(int k=0; k<(pivotObjects.size()-(i+1))*pivotedCols; k++)
            {
                if(m++ > 0) print(",");
                print("\"\"");
            }            
            print("]");
        }
        i++;
    }
    print("]");    
        
}

/**
 * ArJson.
 * @param rs : Un Set trié col 0..lastCol.
 * @param out : Le flux de sortie.
 * @param debug : Indentation si true
*/
public PivotJson ( Set rs , Writer o, boolean debug, boolean returnRowsFormat )
{ 
  this.rs = rs;
  this.out = o;
  this.debug=debug;
  this.returnRowsFormat = returnRowsFormat;
  this.pivotObjects = new LinkedHashMap<String, PivotObject>();
  build(rs);
  if(returnRowsFormat) writeKRows();
  else writeK();
  if( ioErr ) System.err.println( "OutputStream erreur" );
}

public PivotJson ( Set rs , Writer o )
{ this( rs , o , false, false ); }

public PivotJson ( Set rs , Writer o, boolean returnRowsFormat )
{ this( rs , o , false, returnRowsFormat ); }

public PivotJson ( Set rs )
{ this( rs , new OutputStreamWriter(System.out) , false, false ); }

public PivotJson ( Set rs, boolean debug )
{ this( rs , new OutputStreamWriter(System.out) , debug, false ); }


public static void main( String a[] )
throws Exception
{
   String qy = 
    "select 'bsf' as i, '01/02/2014' as date, '89' as value " +
"union  " +
"select 'bsf' as i, '05/02/2014' as date, '109' as value " +
"union " +
"select 'bsr' as i, '05/02/2014' as date, '159' as value " +
"union " +
"select 'bsr' as i, '10/02/2014' as date, '166' as value" ;

com.etn.Client.Impl.ClientDedie Etn = 
  new com.etn.Client.Impl.ClientDedie( 
   "MySql",
   "com.mysql.jdbc.Driver",
   "jdbc:mysql://127.0.0.1:3306/eshop3?user=root&password=admin" );

 Set ar =  Etn.execute(qy) ;
 PivotJson z = new PivotJson( ar, false );
 
}


    private class PivotObject
    {
        List<String> colNames;
        List<List<String>> colValues;

        public PivotObject() {
        }
    }

}

