<%@page contentType="text/html; charset=UTF-8" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%@ page import="com.etn.sql.escape"%>
<%!
public class AlphabeticComparator 
implements java.util.Comparator{
  public int compare(Object o1, Object o2) {
    String s1 = (String)o1;
    String s2 = (String)o2;
    return s1.toLowerCase().compareTo(
      s2.toLowerCase());
  }
}
%>
<%
String id = request.getParameter("id");
if(id==null) id ="0";

String nom = request.getParameter("nom");
if(nom==null) nom ="";

String texte = request.getParameter("texte");
if(texte==null) texte ="";

String condicion = request.getParameter("condicion");
if(condicion==null) condicion ="";

Set rsL = Etn.execute("select * from sms where sms_id = " + escape.cote(id)); 
if(rsL.next()){
	nom = rsL.value("nom");
	texte = rsL.value("texte");
	condicion = rsL.value("where_clause");
	if(condicion==null || condicion.equals("null")) condicion ="";
}
%>
<input type="hidden" name="id" value="<%=id%>">
<table cellpadding="0" cellspacing="0" border="0" width="100%" style="border-collapse: collapse;">
<tr>
	<td style="font-weight: bold;">Name</td>
	<td><input type="text" name="nom" value="<%=nom %>"></td>
</tr>
<tr>
	<td style="font-weight: bold;">Condition</td>
	<td><input type="text" name="condicion" value="<%=condicion %>" size="50"></td>
</tr>
<tr>
	<td style="font-weight: bold;">Field</td>
	<td style="font-weight: bold;">Publisher</td>
</tr>
<tr>
<td valign="top">
<%
Set rs = Etn.execute("desc customer"); 
String liste_champ[] = new String[rs.rs.Rows];

int z=0;
while(rs.next()){
	liste_champ[z] = rs.value(0);
	z++;
}

java.util.Arrays.sort(liste_champ, new AlphabeticComparator());


for(int y=0;y<liste_champ.length;y++){
	out.write("<br><img src='../img/puce3.png' border='0'>&nbsp;<a href='javascript://' onclick=\"mettreC('db"+liste_champ[y]+"');\">"+liste_champ[y]+"</a>");
}

/*while(rs.next()){
	out.write("<br><img src='../img/puce3.png' border='0'>&nbsp;<a href='javascript://' onclick=\"mettreC('db"+rs.value(0)+"');\">"+rs.value(0)+"</a>");
}*/
%>
</td>
<td valign="top">
<textarea id="text1" rows="30" cols="50" name="texte"><%=texte %></textarea><br>
<center><input type="button" value="Save" onclick="ajout_modif();"></center>
</td>
</tr>
</table>
