package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import java.util.Properties;

/** 
 * Must be extended.
*/
public class Shell extends OtherAction { 


/**
 * @param rs is the result of the dynaction.eventSql not touched.
 * @param parm is the text after ':'
 * @return must be 0 on Success.
 * All specific errors must be computed in the extended class.
 * execute must be extended. It does nothing here...
*/
public int execute( int wkid , String clid, String param )
{ 
  try {
  String shdir = env.getProperty("SHELL_DIR");
  String cmd[] = new String[4];
  cmd[0] = "/bin/sh";
  cmd[1] = shdir+"/"+param;
  cmd[2] = ""+wkid;
  cmd[3] = clid;
  Process p = Runtime.getRuntime().exec( cmd);
  p.waitFor();
  return(p.exitValue());
  }
  catch( Exception e ) { e.printStackTrace(); return(-1); }

}

public int init( ClientSql sql , Properties conf)
{
  this.env = conf;
  if( ! new java.io.File(env.getProperty("SHELL_DIR") ).exists() )
    { System.err.println( "SHELL_DIR inexistant" );
      return(-1);
    }

  return(0);
}
    


}
