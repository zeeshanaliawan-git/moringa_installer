//  Reviewed By Awais 
import com.etn.beans.app.GlobalParm;

import javax.servlet.*;
import javax.servlet.http.*;
import com.etn.beans.Contexte;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

import java.io.*;

public class doTdb extends HttpServlet {

public void service(HttpServletRequest req, HttpServletResponse res) throws ServletException, java.io.IOException 
{

Contexte Etn = null;
  String err=null;
  try {
  Etn = (Contexte) req.getSession(false).getAttribute("Etn");
  } catch (Exception a) {} 

String typeF = req.getParameter("typeF");   
  
String id_tdb = req.getParameter("id_tdb");

String param = req.getParameter("param");

String sql1 = "SELECT id_tdb, nom_tdb "; 
sql1+= " FROM tdb where id_tdb="+ escape.cote(id_tdb)+" ";//change
Set rsT = Etn.execute(sql1);

if(rsT.next()){

 try{
      String processOutput = "";
      String cmd[] = new String[5];
      cmd[0] = "/bin/sh";
      cmd[1] = GlobalParm.getParm("CHEMIN")+"/WEB-INF/classes/doTdb.sh";///usr/bin/wkhtmltopdf
      cmd[2] = param;
      cmd[3] = GlobalParm.getParm("URL_CHART")+"/chart/imprimer.jsp?id_tdb="+rsT.value("id_tdb")+"&visu=graph&t=1";
      cmd[4] = GlobalParm.getParm("PDF")+"/"+rsT.value("nom_tdb")+".pdf";
      
      
      System.out.println("cmd 2 : "+cmd[1]);
      System.out.println("cmd 3 : "+cmd[2]);
      
      
      Process pp = Runtime.getRuntime().exec(cmd);
      
      int err1 = pp.waitFor();
      
      
      
      //InputStream is = pp.getInputStream();
      int ev= pp.exitValue();
     /* InputStreamReader isr = new InputStreamReader(is);
      BufferedReader br = new BufferedReader(isr);
      String line;
      while ((line = br.readLine()) != null) {
          processOutput += line;
          
      }*/
    
      
      
      System.out.println("err================>"+err1+"==ev:"+ev);


	File f = new File(GlobalParm.getParm("PDF")+"/"+rsT.value("nom_tdb")+"."+typeF);
	InputStream fis = new BufferedInputStream(new FileInputStream(f));
	//FileInputStream fis = new FileInputStream(f);
	long l = f.length();
	ByteArrayOutputStream obf = new ByteArrayOutputStream( 200000 );
	int c;
	int j=0;
	for(long i=0;i<l;i++) {
	           obf.write(fis.read());
	}
	
	/*byte buf2[] = new byte[1024]; 
	while ((c = fis.read(buf2)) >= 0 ){
		buf2[j++]=(byte)c;;
	}*/
	
	//res.setContentType("application/force-download\r\n"+"Content-Disposition:attachment;filename=\"Input.xls\"");
	res.setContentType("application/force-download");
	res.setHeader("Content-Disposition", "attachment; filename=\""+rsT.value("nom_tdb")+"."+typeF+"\";");
	
	
	obf.writeTo( res.getOutputStream());
	obf.close();
	//f.delete();
	

fis.close();
f.delete();
 }catch (Exception e) {
	System.out.println(""+getStackTraceAsString(e));
}
}

}
public static String getStackTraceAsString(Throwable e) {
    java.io.ByteArrayOutputStream bytes = new java.io.ByteArrayOutputStream();
    java.io.PrintWriter writer = new java.io.PrintWriter(bytes, true);
    e.printStackTrace(writer);
    return bytes.toString();
  }

}