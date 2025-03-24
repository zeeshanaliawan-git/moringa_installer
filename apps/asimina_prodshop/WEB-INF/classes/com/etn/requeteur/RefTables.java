package com.etn.requeteur;

import java.util.HashMap;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSpooled;


public class RefTables {

static HashMap<String,RefTable>refs;




public static void init()
{
   ClientSpooled cl = new ClientSpooled();
   refs = new  HashMap<String,RefTable>();
   Set rs = cl.execute(
      "select dbtable,alias,refqry from reftables order by refqry");
   String qy = "";
   RefTable cur = null;
   while( rs.next() )
    { 
       String alias = rs.value("alias").toUpperCase();
       if( !qy.equals(rs.value("refqry")) )
        { 
    	   System.out.println("table = " + rs.value("dbtable") +" ==>" + rs.value("alias")  ); 
    	   Set rs2 = cl.execute( qy = rs.value("refqry") );
          cur = new RefTable(rs2,alias);
        }
        else cur.addAlias(alias);
            
       refs.put( rs.value("dbtable")+"."+alias , cur );
    }
   
}

public static RefTable get( String table , String alias )
{ return(refs.get(table+"."+alias) ); }


static { init(); }
/**
public static void main(String a[] )
{ RefTable r = RefTables.get("toto","tata");
}
***/


}
