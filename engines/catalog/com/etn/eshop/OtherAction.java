package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import java.util.Properties;

/** 
 * Must be extended.
*/
public abstract class OtherAction { 

ClientSql etn;
Properties env;

/**
 * Called at init.
*/
public int init( ClientSql etn , Properties conf )
{ this.etn = etn;
  this.env = conf;
  return(0); // OK
}
/**
 * @param rs is the result of the dynaction.eventSql not touched.
 * @param parm is the text after ':'
 * @return must be 0 on Success.
 * All specific errors must be computed in the extended class.
 * execute must be extended. It does nothing here...
*/
public int execute( int wkid , String clid, String param )
{ 
  return( -1 );

}
public int execute( ClientSql etn, int wkid , String clid, String param )
{
  return( -1 );

}

}
