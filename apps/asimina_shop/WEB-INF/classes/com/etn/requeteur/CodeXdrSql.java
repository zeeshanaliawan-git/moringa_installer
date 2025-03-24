/**
* Etance:Requeteur Codage ResultSet
*/
package com.etn.requeteur;
/**
* Classe CodeXdrSql : Codage d'un resultset Sql au format ItsXdr
* @author  alban@etancesys.com	 01/03/1999
* @version 1.0
*/

import com.etn.EtnErr;
import com.etn.ItsDefs;
import com.etn.util.ItsDate;
import com.etn.lang.Xdr;
import com.etn.lang.XdrTypes;
import com.etn.lang.ResultSet.Encoding; 

import java.sql.*;
import java.io.OutputStream;
import java.io.ByteArrayOutputStream;

public  class CodeXdrSql 
{

/** 
* Etat du flag Xdr.Indicateur[1]
*/

public static final byte NORMAL       = 0;
public static final byte SMALL        = 1;
public static final byte BIGLEN       = 2;



/**
* getMetaData :
* Renseigne Xdr.colName
* Xdr.Indicateur[0] ( nb Col )
* et le tableau d'indicateur Xdr.type :
* 0 getString simple , 1 getString + trim , 2 traiement binaire :getBytes() 
**/

private static RefTable[] getMetaData( Xdr xs ,ResultSet rs, int buggy )
throws Exception
 { 
    ResultSetMetaData rm = rs.getMetaData();
    ByteArrayOutputStream bf= new ByteArrayOutputStream();
    int Cols= rm.getColumnCount();
    RefTable tomap[] = new RefTable [ Cols ];
    byte sepaCol = xs.Indicateur[2];
    byte sepaRow = xs.Indicateur[3];
    byte type[] = new byte [ Cols ];
    int i ;
 
    xs.Indicateur[0] = (byte) Cols; 
	
    for( i = 1 ; i <= Cols ; i++ )
      { String s = rm.getColumnName( i ).toUpperCase();
        
        bf.write ( s.getBytes(), 0 ,s.length());
        bf.write ( ( i == Cols )? sepaRow : sepaCol );
       
        System.out.println("col:"+s+" type:"+rm.getColumnType(i)+
         " tableName:"+rm.getTableName(i) );
        RefTable ref = RefTables.get(rm.getTableName(i), s);
        if( ref != null )
         { type[i-1] =  XdrTypes.VARCHAR;
           tomap[i-1] = ref;
         }
        else
        switch (  rm.getColumnType(i) ) {
        case java.sql.Types.INTEGER : //type[i-1] =  XdrTypes.INT; 
                             if(  rm.isAutoIncrement(i)) 
                                 type[i-1] =  XdrTypes.AUTOINCREMENT;
                             else type[i-1] = XdrTypes.INT; 
                              break; 

        case -9 : // ??
        case java.sql.Types.CHAR : 
        case java.sql.Types.VARCHAR: type[i-1] = XdrTypes.VARCHAR; break;
	case java.sql.Types.LONGVARCHAR : type[i-1] = XdrTypes.LONGVARCHAR; break;
        
        case java.sql.Types.BINARY :    System.out.println("BINARY"); 
                             type[i-1] =  XdrTypes.BLOB; break;

        case java.sql.Types.VARBINARY :
        case java.sql.Types.LONGVARBINARY :if(buggy != 0) 
                                      type[i-1] =  XdrTypes.BLOB; 
                                  else
                                      type[i-1] =  XdrTypes.VARCHAR; 
            
                                  break;
        case java.sql.Types.TIMESTAMP : 

                              if( buggy == 8 ) // mysql
                                { type[i-1] = 16;
                                  break;
                                }

        case java.sql.Types.DATE : 
		        type[i-1] = 17; // Date courte
                break;

		
		
		case  java.sql.Types.TIME :
            type[i-1] = 16;
			break;

        case java.sql.Types.FLOAT : 
        case java.sql.Types.REAL : 
        case java.sql.Types.DOUBLE :
             type[i-1] =  XdrTypes.DOUBLE; break; 
        
	case java.sql.Types.NUMERIC :
	case java.sql.Types.DECIMAL : type[i-1] =  XdrTypes.NUMERIC; break;

        case java.sql.Types.TINYINT  :
	    case java.sql.Types.SMALLINT	:
	    case java.sql.Types.BIGINT :type[i-1] =  XdrTypes.INT; break; 
	    
        default : System.err.println("Colonne:"+rm.getColumnName( i )+"Type"+rm.getColumnType(i)+" Inconnu");
		          type[i-1] = 0;
        }
        /** Special Its : Si colonne commence par BIN_ alors BINARY **/   
        if( s.startsWith("BIN_") )  type[i-1] = 2;
        
      }

    xs.colName = bf.toByteArray() ;
    bf.close();
    xs.type = type;  

    return( tomap);
 }
     
/** 
* setSepa.
* renseigne Xdr.Indicateur [2] et [3]
* nota:par defaut les separateurs sont:
* tab ( 9 ,'\t') sepa de champ
* Lf  (10, '\n' ) sepa de ligne
* Codification SMALL
*/
private static void setSepa( Xdr xs )   
{
  if( xs.Indicateur == null )
    {  
       xs.Indicateur = new byte[4] ;
       xs.Indicateur[1] = XdrTypes.SMALL ;
       xs.Indicateur[2] = 9 ; /* sep col tab */
       xs.Indicateur[3] = 10 ; /* sep col lf */
    }
    
}

private static byte[] codeInt( int i )
{
   byte b[] = new byte[4];
   
   b[0] = (byte)( 255 & i) ; i >>= 8;
   b[1] = (byte) (255 & i) ; i >>= 8;
   b[2] = (byte) (255 & i) ; i >>= 8;
   b[3] = (byte) (255 & i) ; 

   return( b );
}
private static byte[] codeShort( int i )
{
   byte b[] = new byte[2];

   b[0] = (byte)( 255 & i) ; i >>= 8;
   b[1] = (byte) (255 & i) ; 

   return( b );
}


/** 
* simpleFormat
* renseigne Xdr.data
* et Xdr.Rows
* Nota: Si le format est binaire, les separateurs doivent etre choisi judicieusement.
*/
private static void simpleFormat( Xdr xs , OutputStream buf , ResultSet rs,
    RefTable tomap[]  )
throws Exception
{
    int i ;
    int Cols;
    String s; 
    int Rows = 0;
    byte sepaCol = xs.Indicateur[2];
    byte sepaRow = xs.Indicateur[3];
    byte desc[] = xs.type; 

    Cols = 255 & xs.Indicateur[0];
    
    
    while( rs.next() )
     {
      for( i = 1 ; i <= Cols  ; i++ )
      {
        switch( (int)desc[i-1] )
        {
	    
        case XdrTypes.VARCHAR : 
             if( (s = rs.getString(i)) != null )
             { if( tomap[i-1] != null ) s = tomap[i-1].toString(s);
               buf.write( Encoding.getBytes(s.trim()) );
             }
             break;

        case XdrTypes.BLOB : byte b[] = rs.getBytes(i) ;
                              if( b != null ) buf.write(b);
                              break;
         // Date et bug odbc
        case 16 : try
                    { Timestamp d = rs.getTimestamp(i);
		      if( d != null )
		        buf.write( ItsDate.get( d.getTime() ).getBytes() );
                    }
                    catch( Exception aa) {}

                 break;

         case 17 : try
                    { Timestamp d = rs.getTimestamp(i);
                         if( d != null )
                                   buf.write( ItsDate.shortDate( d.getTime() ).getBytes() );
                     
                    }
                    catch( Exception aa) {}

                 break;


        default:
		        if( (s = rs.getString(i)) != null )
                   buf.write( Encoding.getBytes(s) );
                 break;
    

         }

        if( i != Cols ) buf.write( sepaCol );
      }
     
     buf.write(sepaRow);
     Rows++;
    }
 
 xs.Rows = Rows;
}     
/**
* varlenFormat
* renseigne Xdr.data
* et Xdr.Rows
*/
private static void varlenFormat( Xdr xs , OutputStream buf , ResultSet rs,
  RefTable tomap[]  )
throws Exception
{
    int i=0,lg ;
    int Cols;
    String s;
    byte b[]=null;
    int Rows = 0;
    byte sepaCol = xs.Indicateur[2];
    byte sepaRow = xs.Indicateur[3];
    boolean slen = (xs.Indicateur[1] & XdrTypes.SMALL) == XdrTypes.SMALL;
    byte desc[] = xs.type;

    Cols = 255 & xs.Indicateur[0];

    while( rs.next() )
     {
      for( i = 1 ; i <= Cols  ; i++ )
      { 
        
        lg = 0;
        switch( (int)desc[i-1] )
        {
		case XdrTypes.VARCHAR : 
		 if( (s = rs.getString(i)) != null )
                 { if( tomap[i-1] != null ) 
                      s = tomap[i-1].toString(s);
                   lg = (b = Encoding.getBytes(s.trim()) ).length;
                 }   
                 break;

        case XdrTypes.BLOB :
                    b = rs.getBytes(i) ;
                   if( b != null ) lg = b.length;
                   break;

        // Timestamp pour buggy odbc qui tronque les heures sur getDate()...
        case 16 : try {
		         Timestamp  d = rs.getTimestamp (i);
		         if( d != null )
				   { b = (ItsDate.get( d.getTime() )).getBytes();
				     lg = b.length ;
                                   }
                   }
                  catch ( Exception aa) {}
                  break;
 
         case 17 : try {
                         Timestamp  d = rs.getTimestamp (i);
                         if( d != null )
                                   { b = (ItsDate.shortDate( d.getTime() )).getBytes();
                                     lg = b.length ;
                                   }
                   }
                  catch ( Exception aa) {}
                  break;


 
        
        default :
                  if( (s = rs.getString(i)) != null )
                     lg=( b = Encoding.getBytes(s) ).length;
                     //lg=( b = s.getBytes() ).length;
    
             break;
        
        }

        if(slen) buf.write( codeShort( lg ) ) ;
          else buf.write( codeInt( lg ) );
       
        if( lg != 0 ) buf.write( b );
      }

     Rows++;
    }

 xs.Rows = Rows;
}
/** 
* CodeXdrSql.
* renseigne Xdr 
* à partir du ResultSet argument
* ferme le ResultSet
*/
public static void encode( Xdr xs ,ResultSet rs , int buggyType  )
throws Exception
 {
    int flags;
    ByteArrayOutputStream buf;
    RefTable tomap[] = null;
 
    setSepa( xs );
    tomap = getMetaData( xs , rs , buggyType);
    flags = 255 & xs.Indicateur[1];
    
    buf = new ByteArrayOutputStream(60000) ;

    switch( flags & XdrTypes.ALLFORMAT ) {
    case XdrTypes.NORMAL : simpleFormat( xs , buf , rs, tomap ); break;
    case XdrTypes.SMALL : 
    case XdrTypes.BIGLEN : varlenFormat(  xs , buf , rs, tomap ); break;
    
    }

   xs.data = buf.toByteArray() ;
   buf.close();

   rs.close();
   // retablir les flags des drivers buggés
   if( buggyType == 0 || buggyType == 8 )  // odbc || mysql
     for( int i = 0 ; i < xs.type.length ; i++ )
	    if( xs.type[i] == 16 || xs.type[i] == 17 ) xs.type[i] = XdrTypes.DATE;
}


}








    

    
    



 
