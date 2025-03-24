<%@page contentType="text/html; charset=UTF-8" %>
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.asimina.util.UIHelper"%>
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

String selectedLang = request.getParameter("lang");
if(selectedLang == null || selectedLang.length() == 0) selectedLang = "1";

String strReadonly = "";
if(selectedLang.equals("1") == false) strReadonly = "readonly";

String condicion = request.getParameter("condicion");
if(condicion==null) condicion ="";

Set rsL = Etn.execute("select * from sms where sms_id = " + com.etn.sql.escape.cote(id)); 
if(rsL.next()){
	nom = rsL.value("nom");
	//for first language we still have column texte as we did not want to create problem for some custom code sms classes ( in osl )
	if(selectedLang.equals("1")) texte = rsL.value("texte");
	else texte = rsL.value("lang_"+selectedLang+"_texte");
	condicion = rsL.value("where_clause");
	if(condicion==null || condicion.equals("null")) condicion ="";
}
%>
<input type="hidden" name="id" value="<%=id%>">
<table cellpadding="0" cellspacing="0" border="0" width="100%" style="border-collapse: collapse;">
<tr>
	<td style="font-weight: bold;">Name</td>
	<td><input type="text" name="nom" value="<%=UIHelper.escapeCoteValue(nom)%>" <%=strReadonly%>></td>
</tr>
<tr>
	<td style="font-weight: bold;">Condition</td>
	<td><input type="text" name="condicion" value="<%=UIHelper.escapeCoteValue(condicion)%>" size="50" <%=strReadonly%>></td>
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
%>
</td>
<td valign="top">
<textarea id="text1" rows="30" cols="50" name="texte"><%=UIHelper.escapeCoteValue(texte)%></textarea><br>
<center><input type="button" value="Save" onclick="ajout_modif();"></center>
</td>
</tr>
</table>
