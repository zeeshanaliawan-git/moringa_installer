package com.orange.requeteur;

import java.sql.*;
import java.io.File;
import java.io.FileOutputStream;
import java.io.ObjectOutputStream;
import java.io.PrintStream;
import com.etn.lang.Xdr;
import com.etn.sql.escape;
import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.CodeXdrSql;
import java.util.HashMap;


/**
* Thread r�alisant la(es) requetes.
* Cr�� les thread fils s'il y a lieu.
* Renvoit un id sur cr�ation.
* et un Resultat sur get(id).
*/

public class ThrQry extends Thread {
int id;
int sqlId;
Qry qy;


int setInfo()
{
  return( qy.con.executeCmd(
   "replace into thread_work (id , sqlid , tm , serveur, debut,fin,statut,"+
   "errcode,sqltext,errtext) values("+
   id+","+sqlId+",now(),"+qy.serveur+",now(),null,0,0,"+
   escape.cote(qy.qSql)+ ",null)"));

}
void setFini( String erreur, int errCode )
{
  if( erreur != null )
  qy.con.executeCmd(
   "update thread_work set fin=now(), statut=2,errCode="+errCode+",errtext="+
   escape.cote(erreur)+" where id = "+id );
  else
    qy.con.executeCmd(
   "update thread_work set fin=now(), statut=1 where id = "+id );
}

public void run()
{
  Connecteur ct = null;
  Connection cx = null;
  String erreur = null;
  int errCode=0;
  try {
  int parm[] = new int[1];
  System.out.println("Phase0:"+qy.serveur+"("+System.currentTimeMillis()+")");
  ct = Conteneur.getConnecteur(qy.serveur);
  System.out.println("Phase1:"+qy.serveur+"-> Conteneur:"+ct+"("+System.currentTimeMillis()+")");
  cx = ct.getCon(parm);
  System.out.println("Phase2:"+qy.serveur+"-> Connexion:"+cx+"("+System.currentTimeMillis()+")");
  if( cx != null )
     sqlId = parm[0];
  else
     return;

  Statement st = cx.createStatement();
  // Attention en millis...
  //st.setQueryTimeout( timeout);
  setInfo( );
  new File(Cache.cacheDir+"/_"+id+".lck").createNewFile();
  Conteneur.getKiller().put( this , id , sqlId , qy.serveur  );



  ResultSet rs = st.executeQuery( qy.qSql );
  Xdr xs = new Xdr();
  xs.Indicateur = new byte[4];
  xs.Indicateur[1] = 1 ; /* sep col tab */
  xs.Indicateur[2] = 9 ; /* sep col tab */
  xs.Indicateur[3] = 10 ; /* sep col lf */
  CodeXdrSql.encode( xs , rs , 0 , 8 );
  ct.free(cx);
  cx = null;
  xs.colName = qy.getCols();
 // System.out.println( "REQUEUEUR getCols###############\n"+new String(xs.colName));

  /* System.out.println( "REQUEUEUR ###############\n"+
    new String(xs.colName) +"##################" );
  */
  ObjectOutputStream out = new ObjectOutputStream (
     new FileOutputStream( Cache.cacheDir+"/_"+id ));
  out.writeObject(xs);
  out.close();

  }
  catch( Exception aa )
  {  //System.out.println(".............\nErr sql:"+ qy.qSql);
     aa.printStackTrace();
     String errf =  Cache.cacheDir+"/_"+id+"_erreur" ;
     erreur = aa.getMessage();
     if( erreur == null ) erreur = aa.toString();

     if( aa instanceof SQLException )
        errCode = ((SQLException)aa).getErrorCode();
     else errCode = -1;

     try {

     PrintStream z = new PrintStream(
           new FileOutputStream(errf));
     aa.printStackTrace(z);
     z.close();
     } catch( Exception abc) {}
  }

  finally
  { Cache.unLock(id);
    if( cx != null )  ct.free(cx);
    new File(Cache.cacheDir+"/_"+id+".lck").delete();
    setFini(erreur,errCode);
  }
}

public int getRId()
{
  return( id  );
}

public ThrQry( Qry qy)
{
  id = Cache.nextVal();
  this.qy = qy;

  if( qy.ctx != null )
  {
    try {
     String inf = Cache.cacheDir+"/_"+id+"_infos" ;
     ObjectOutputStream out = new ObjectOutputStream (
     new FileOutputStream( inf ));
     out.writeObject(qy.ctx);
     out.close();
    }
    catch(Exception a) { a.printStackTrace(); }
  }

  Cache.putLock( id );

}

}
