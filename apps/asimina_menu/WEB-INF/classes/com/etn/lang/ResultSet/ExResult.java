package com.etn.lang.ResultSet;
import com.etn.lang.Xdr;

/**
* Resulset supportant les methodes set , add , moveTo .
*/
public class ExResult extends Set {
/************ Dans superclasse
public Xdr rs;
protected String colVal[];
protected int Colidx[];
public String ColName[];
protected int Row = 0;
public int Cols = 0;
private int Pos = 0;
public byte sepaChamp = 9;
public byte sepaLigne = 10;
***********/

byte rbuf[][];
boolean touch = false;
public int Last;
byte binary[][];

private void setBuff( int sz )
{ if( sz < 2 ) sz = 2;
  rbuf = new byte[sz][];
}
private void realloc()
{ byte b[][] = new byte[ rbuf.length +  rbuf.length][];
  System.arraycopy( rbuf,0,b,0,rbuf.length );
  rbuf = b ;
}
private void get()
{
  if( colVal == null ) colVal = new String[Cols];

  if( Row < Last )
     setVals( rbuf[Row] , 0 );
  else 
     colVal = new String[Cols];

}
private void write()
{
  int z = 0;
  byte b[];
  int j;

  if( Row == -1 ) return ;
  /**
  * Calcul longueur a allouer
  */
  for( int i = 0 ; i < Cols ; i++ )
    if(  colVal[i] != null ) 
       if( rs.type[i] != 2 ) 
	   z += Encoding.getBytes(colVal[i]).length;
       else
		  z += binary[i].length ;

  j = Cols ;                // 1 Extra byte
  if( flags != 0 ) 
     { j += j;              // 2 Extra byte
       if( flags == 2)  
         j += j;            // 4 Extra byte
     }

  z += j;
  
  if( Row >= rbuf.length ) realloc();
 
  b = rbuf[Row] = new byte[z];
  z = 0;

  for( int i = 0 ; i < Cols ; i++ )
   { if(  colVal[i] != null )
     { 
	   boolean bin = (rs.type[i]==2);
	   if( !bin ) 
	      j = Encoding.getBytes(colVal[i]).length;
         else 
		  j = binary[i].length ;

       if( flags != 0 ) z += setLg( b, z, j);
	   if( bin) 
          System.arraycopy( binary[i], 0 , b , z , j );
       else
          System.arraycopy( Encoding.getBytes(colVal[i]), 0 , b , z , j );
        z += j;
     }
	 else if( flags != 0 ) 
	    z += setLg( b, z, 0);

     if( flags == 0 )
     { if( i == ( Cols - 1 ) )
         b[z] = sepaLigne ;
       else
         b[z] = sepaChamp ;
       z++;
     }
    }
}
private int getShort( byte data[] ,int pos)
{
  return( ( (255 & data[pos+1]) << 8 ) | (255 & data[pos]) );
}
private int getInt( byte data[], int pos )
{
  return( (255 & data[pos+3]) <<24 |
          (255 & data[pos+2]) <<16 |
          (255 & data[pos+1]) <<8 |
          (255 & data[pos]) ) ;

}
private int setLg( byte b[] , int pos , int lg)
{
  b[pos] = (byte)( 255 & lg) ; lg >>= 8;
  b[pos+1] = (byte)( 255 & lg) ; 
  if( flags == 1 ) return(2);
  lg >>= 8;  b[pos+2] = (byte) (255 & lg) ;
  lg >>= 8;  b[pos+3] = (byte) (255 & lg) ;
  return(4);
}
private int getRow( byte b[] , int pos )
{
  int i;
  if( flags == 0 )
   { for(  i = pos ; i < b.length && b[i] != sepaLigne  ; i++ );
     return( i - pos + 1 );
   }
   
  i = pos;
  for( int c = 0 ; c < Cols && i < b.length ; c++ )
    { if(flags==1)
          i += 2 + getShort(rs.data,i);
        else
          i += 4 +  getInt(rs.data,i) ;
    }

  return( i - pos );
}
private void setVals( byte b[] , int pos )
{
  if( flags == 0 )
  {  int j = pos;
     for( int k = 0 ; k < Cols ; k++ )
     { pos = getSeparateur( b , j );
       colVal[k] = Encoding.newString( b , j , pos -j );
       j = pos + 1 ;
     }
   return;
  }
  
  for( int k = 0 ; k < Cols ; k++ )
  { int lg;
    if( flags==1 )
      { lg = getShort(b,pos); pos += 2 ; }
    else
      { lg = getInt(b,pos); pos += 4 ; }
    if( lg > 0 )
      colVal[k] = Encoding.newString( b , pos , lg );
    else colVal[k] = null;
    pos += lg;
  }
}

/**
* Recopie dans rbuf chaque Row du xdr courant.
**/
private void xdrToBuf()
{
  byte b[] = rs.data;
  int i = 0;
  
  for( Row = 0 ; Row < rs.Rows ; Row++ )
  { int lg = getRow( b , i);
    byte alloc[] = new byte[ lg];
    System.arraycopy( b , i , alloc , 0 , lg);
    rbuf[Row] = alloc;
    i += lg;
  }
}
/** 
* Inversion de l'ordre du Set
*/
private void invert()
{
  byte r[] ;
  int i , j;
  i = 0;
  j = rbuf.length -1 ;

  while( i < j )
  {
    r = rbuf[i]; 
    rbuf[i] = rbuf[j];
    rbuf[j] = r;
	i++ ; j--;
   }

}
/**
* Construit un Xdr avec les Separateurs par defaut
*/
private void setXdr( int col,String lib[] )
{ rs = new Xdr();
  rs.Indicateur = new byte[4];
  rs.Indicateur[0] = (byte) col;
  rs.Indicateur[1] = (byte) 1;
  rs.Indicateur[2] = (byte) 9;
  rs.Indicateur[3] = (byte) 10;
  rs.type = new byte[col];
  if( lib != null )
  { String s = "";
    int i;
    for(  i = 0 ; i < lib.length - 1 ; i++ )
       s += lib[i].toUpperCase() + "\t";
    rs.colName = Encoding.getBytes(s + lib[i] + "\n") ;
  }
}
/**
* Construit un ExtResult 
* a partir d'un Xdr
*/
public ExResult( Xdr xs )
{
  init(xs);
  
  setBuff( xs.Rows );
  if( rs.data != null ) xdrToBuf();
  Last = xs.Rows;
  Row = -1 ;
}
/**
* Construit un ExResult 
* a partir d'un Xdr
* en applicant la commande donnee en second argument
*/
public ExResult( Xdr xs, int cmd )
{
  init(xs);
  setBuff( xs.Rows );
  if( rs.data != null ) 
    { xdrToBuf();
	  // Aujourdh'ui seul invert
	  if( (cmd & 1 )== 1 )   invert();
    }
  Last = xs.Rows;
  Row = -1 ;
}


/**
* Construit un ExResult     
* de n colonne
*/
public ExResult(int n)
{ 
  setXdr( n ,null);
  init(rs); 
  setBuff(0);
  Last = rs.Rows = 0;
  Row = -1 ;
}
/**
* Construit un ExResult
* a partir d'un tableau de valeur [Cols][Rows]
* et optionnelement d'un tableau de libelles
* si val est null , le nombre de colonne est la
* longueur du tableau lib.
* Sinon celle du tableau val .
*/
public ExResult( String val[][],String lib[] )
{ int x , y;
  if( val == null ) 
    { y = 0; x = lib.length; }
  else
    {  y = val[0].length ;
       x = val.length ;
    }
 
  setXdr( x, lib);
  init( rs );
  setBuff( y );
  Last = rs.Rows = 0;
  Row = -1 ;
  if( y != 0 )
  for( int i = 0 ; i< y ; i++ )
  { add();
    for( int j = 0 ; j < Cols ; j++ )
      set(j,val[j][i]);
   commit();
  }
}

/*rajout
*/
public  ExResult( String val[][],String lib[] ,int sepCol, int sepRow )
{ buildEx( val , lib ,sepCol,sepRow);
}
private  void buildEx( String val[][],String lib[],int sepCol,int sepRow )
{ int x , y;
  if( val == null ) 
    { y = 0; x = lib.length; }
  else
    {  y = val[0].length ;
       x = val.length ;
    }
 
  setXdr( x, lib,sepCol,sepRow);
  init( rs );
  setBuff( y );
  Last = rs.Rows = 0;
  Row = -1 ;
  if( y != 0 )
  for( int i = 0 ; i< y ; i++ )
  { add();
    for( int j = 0 ; j < Cols ; j++ )
      set(j,val[j][i]);
   commit();
  }
}

/**
* Construit un Xdr avec les Valeurs par defaut
*/
private void setXdr( int col,String lib[],int sepCol, int sepRow )
{ rs = new Xdr();
  rs.Indicateur = new byte[4];
  rs.Indicateur[0] = (byte) col;
  rs.Indicateur[1] = (byte) 0;
  rs.Indicateur[2] = (byte) sepCol;
  rs.Indicateur[3] = (byte) sepRow;
  rs.type = new byte[col];
  if( lib != null )
  { String s = "";
    int i;
  
    for(  i = 0 ; i < lib.length - 1 ; i++ )
       s += lib[i].toUpperCase() +(char) ( 255 &rs.Indicateur[2]);
    
    rs.colName = Encoding.getBytes( s + lib[i].toUpperCase() + (char) ( 255 &rs.Indicateur[3]));
  }
}




/*rajout*/

/**
* eof
*/
public boolean eof()
{
  return( Row >= Last );
}
/**
* @return false si >= Last
*/
public boolean next()
{ 
  if( (Row+1) < Last )
  { Row++; get(); return(true);}
  return( false);
}
/**
* @param row le row courant espace 0..Last-1
* @return false si inexistant
*/
public boolean moveTo(int row)
{
  if( row < Last ) 
    { Row = row;
      if( Row != -1 ) get();
      return(true);
    }
  return(false);
}
/**
* @return false si ResultSet vide
*/
public void moveFirst()
{ moveTo(-1); }
/**
* Prepare l'ajout d'un Row
*/
public void add()
{
  Row = Last;
  get();
}
/**
* Efface le Row Courrant.
*/
public void del()
{
  if( Row < Last )
   {
    int n = Last - Row - 1;
    if( n > 0 )
    System.arraycopy( rbuf , Row + 1 , rbuf , Row , n );
    Last--;
    Row--;
   }
  touch = false;
}
/**
* Valide les modifications 
* effectuee par methode set
*/
public void commit()
{
   if( touch) 
     { write();
       if( Row == Last ) Last = Row +1 ;
     }
   touch = false;
}
/**
* Modifie la valeur de la colonne.
* indice 0-Cols -1
* @param col indice
* @param val valeur
* @return false si hors bornes
*/
public boolean set( int col , String val )
{ 
  try { colVal[col] = val ;  return( touch = true); }  
  catch( Exception e ) { return( false); }
}
/**
* Modifie la valeur de la colonne.
* @param col nom de la colonne case insensitif voir toUpperCase
* @param val valeur
* @return false si colonne inconnue
*/
public boolean set( String col , String val )
{
  return( set( indexOf(col) , val ) );
}
/**
* Idem mais binaire 
*/
public boolean setBytes( int col , byte val[] )
{ if( ( col & 255 ) >= Cols ) return(false);
  if( binary == null ) binary = new byte[ Cols ][];
  colVal[col] = "bin" ;
  binary[col] =  val ;
  rs.type[col] = 2;
  return( touch = true);
}  
public boolean setBytes( String col , byte val[] )
{ return( setBytes( indexOf( col ), val ) ) ; 
}  

/**
* flush : Initialise le Xdr
*/
public void flush()
{  
   int i, l = 0;
   byte b[];

   for( i = 0 ; i < Last ; i++ )
     l += rbuf[i].length ;
   
   b = rs.data = new byte[l];
   rs.Rows = Last;
   l = 0;
   for( i = 0 ; i < Last ; i++ )
     {
      System.arraycopy( rbuf[i] , 0 , b , l ,  rbuf[i].length );
      l += rbuf[i].length ;
     } 
}
public void close()
{ rbuf = null; }
public Xdr getXdr()
{
   flush();
   return( rs );
}


/** Exemple  **/
public static void main( String a[] )
{
 /**
  // un Xdr bidon
  Xdr xs = new Xdr();
  xs.colName = "C0\tC1\tC2\tC3\n".getBytes();
  xs.Indicateur = new byte[4];
  xs.Indicateur[0] = 4; // ncols
  xs.Indicateur[2] = 9; // sepa champ
  xs.Indicateur[3] = 10; // sepa row;

  xs.Rows = 3;
  xs.data = "a\tb\tc\td\ne\tf\tg\th\ni\tj\tk\tl\n".getBytes();
  
 
  ExResult ex = new ExResult( 4 );
  ex.add(); ex.set(0,"a");ex.set("c1","b");ex.set(2,"c");ex.set(3,"d"); ex.commit();
  ex.add();ex.set(0,"e");ex.set("c1","f");ex.set(2,"g");ex.set(3,"h"); ex.commit();
  ex.add();ex.set(0,"i");ex.set("c1","j");ex.set(2,"k");ex.set(3,"l"); ex.commit();
**/
 String v[][] = new String[4][3] ;
 String names[] = new String[4];
 int n = 'a';
 for( int i = 0 ; i < 4 ; i++ ) names[i] = "c"+i;
 for( int r = 0 ; r < 3 ; r++ )
   for( int c = 0 ; c < 4 ; c++ )
       { v[c][r] = ""+(char)(n) ; n++; }

  ExResult ex = new ExResult( v,names );


  System.out.println("un Rs 4 colonnes * 3 Rows ");
  dumpEx( ex);
 
  System.out.println("Methode Update : Row 1 ");
  ex.moveTo(1);
  System.out.println(""+ex.set("c0" , "toto") );
  ex.set(1 , "" );
  ex.set("c2" , "tata" );
  ex.set("c3" , "tutu............tutu" );
  ex.commit();
  dumpEx( ex);

 
  System.out.println("Methode Add : un 4eme Row ");
  ex.add();
  ex.set("c3" , "p" );
  ex.set(1 , "n" );
  ex.set("c2" , "o" );
  ex.set("c0" , "m" );
  ex.commit();
  dumpEx( ex);
  

  System.out.println("Methode Del : Delete Row 1 ");
  ex.moveTo(1);
  ex.del();
  dumpEx( ex);


  System.out.println("Methode flush : ");
  ex.flush();
  System.out.println(new String( ex.rs.data ) );
  System.out.print(""+ ex.rs.Rows +" names:"+new String(ex.rs.colName) );
  for( int i = 0 ; i < 4 ; i++ ) 
     System.out.print(" "+ex.rs.Indicateur[i]);
  System.out.print("\n");
 
 for( int i = 0 ; i <(int) ex.rs.Indicateur[0] ; i++ )
     System.out.print(" "+ex.rs.type[i]);
  System.out.print("\n");
  
  System.out.println("Methode getXdr : ");
  ItsResult rs1 = new ItsResult(ex.getXdr());
  dumpEx( rs1);
  
}
static void dumpEx( Set ex) 
{
  ex.moveFirst();
  while( ex.next() )
    for( int i = 0 ; i < ex.Cols ; i++ )
    {
      System.out.print("["+ex.value(i) +"]"+(i==ex.Cols-1?"\n":"\t") );
    }
}
}
