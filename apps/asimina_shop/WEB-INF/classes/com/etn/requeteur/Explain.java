package com.etn.requeteur;

import com.etn.lang.ResultSet.Set;
import java.io.PrintStream;


public class Explain {

Set rs;
String sql;

public Explain( String sql , Set rs  )
{ this.rs = rs;
  this.sql = sql;
}

public void dump( PrintStream out )
{
  rs.moveFirst();
  for( int i = 0 ; i < rs.Cols ; i++ )
    out.print( rs.ColName[i]+"\t");

 out.println();

 while( rs.next() )
 { for( int i = 0 ; i < rs.Cols ; i++ )
    out.print( rs.value(i)+"\t");
   out.println();
 }

}

public String getSql() { return(sql); }

public int countJoin() { return( rs.rs.Rows ); }

public int countRow() {
rs.moveFirst();
int n = 0;
while( rs.next() ) n += Integer.parseInt( rs.value("ROWS") );
return( n);
}

public String enumTypeJoin() {
String list = "";

rs.moveFirst();
while( rs.next() ) list +=  rs.value("TYPE")+"\t" ;
return( list );
}

public String mostBad()
{
  int scan = 0;
  int badscan = 0;
  String badJoin = null;

  rs.moveFirst();
  while( rs.next() )
  {
   int n = Integer.parseInt(rs.value("rows"));

   if(
        ( n > 1000 &&
          "ALL".equals(rs.value("TYPE"))  &&
           rs.value("possible_keys").length() == 0
         ) ||
         ( n > 10000 &&
           rs.value("key").length() == 0
         )
      )
    {
        scan += n;
        if( n > badscan )
          { badscan = n;
            badJoin = rs.value("table");
          }
    }
  }


  if( scan > 1000 )
   return( badJoin );

  return( null );

}
}
