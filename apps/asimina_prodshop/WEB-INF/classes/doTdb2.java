import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;





public class doTdb2 {

public static void main(String args[]) throws Exception 
{



 try{
      String processOutput = "";
      String cmd[] = new String[5];
      cmd[0] = "/bin/sh";
      cmd[1] = "/usr/local/tomcat/webapps/requeteur2/WEB-INF/classes/doTdb.sh";///usr/bin/wkhtmltopdf
      cmd[2] = "-O Landscape";
      cmd[3] = "http://127.0.0.1:8080/requeteur2/chart/imprimer.jsp?id_tdb=3&visu=graph&t=1";
      cmd[4] = "/usr/local/tomcat/webapps/requeteur2/chart/pdf/coucou.pdf";
      
      
      System.out.println("cmd 2 : "+cmd[1]);
      System.out.println("cmd 3 : "+cmd[2]);
      
      
      Process pp = Runtime.getRuntime().exec(cmd);
      
      int err1 = pp.waitFor();
      
      
      int ev= pp.exitValue();
      
    
      
      
      System.out.println("err================>"+err1+"==ev:"+ev);


	//f.delete();
	

/*is.close();
isr.close();
br.close();*/
//f.delete();
 }catch (Exception e) {
	System.out.println("==>"+getStackTraceAsString(e));
}
}

public static String getStackTraceAsString(Throwable e) {
    java.io.ByteArrayOutputStream bytes = new java.io.ByteArrayOutputStream();
    java.io.PrintWriter writer = new java.io.PrintWriter(bytes, true);
    e.printStackTrace(writer);
    return bytes.toString();
  }

}
