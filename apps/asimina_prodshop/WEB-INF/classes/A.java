import com.etn.lang.Xdr;
import com.etn.lang.ResultSet.*;
import java.io.*;


public class A {

public static void main( String a[] )
{
  try
  {
    String fi = a[0];
    ObjectInputStream o = new ObjectInputStream( 
      new FileInputStream(fi) );
    Set rs = new ItsResult( (Xdr) o.readObject() );
    o.close();

    for( int i = 0 ; i < rs.Cols ; i++ )
      System.out.print(rs.ColName[i]+"\t");
    System.out.println();

    while( rs.next() )
     { for( int i = 0 ; i < rs.Cols ; i++ )
         System.out.print(rs.value(i)+"\t");
        System.out.println();
     }

  }

  catch( Exception e )
  { e.printStackTrace();
  }

}

}

