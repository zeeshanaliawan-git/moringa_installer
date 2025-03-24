<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.InputStream"%>
<%@page import="com.etn.beans.app.GlobalParm,com.etn.asimina.util.FileUtil"%>
<%
response.setContentType("application/vnd.ms-excel");
response.setHeader("Content-Disposition", "attachment; filename=\"exemple_import_stock.txt\";");
String fileName= GlobalParm.getParm("CHEMIN")+"stock/exemple_import_stock.txt";
InputStream in = FileUtil.getFileInputStream(fileName);//change
String s="";
out.clearBuffer();
try {
	InputStreamReader isr = new InputStreamReader(in);
	BufferedReader br = new BufferedReader(isr);
    String line;
    while ((line = br.readLine()) != null) {
        s += line+"\n";
    }
    out.write(s);
} catch (Exception e) {
     e.printStackTrace(System.out);
}

in.close();
// Fin T�l�chargement
%>