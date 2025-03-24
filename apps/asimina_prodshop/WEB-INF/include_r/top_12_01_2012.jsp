
<style>
<!--
.bandcad {width: 990px;text-align: left;}

.bandtop1,.bandtop2 {margin: 0px;padding: 0px;background-color: #2A3E46;font-family: arial;font-size: 8pt;}
.bandtop1 {}
.bandtop2 {}
a.logo:LINK,a.logo:VISITED,a.logo:HOVER {font-size: 14pt;font-weight: bold;color: white;cursor: pointer;text-decoration: none;font-style: italic;font-family: trebuchet MS;}
div.pic {background: url("../img/logo_requeteur.png") no-repeat;margin: 0px;padding: 0px;}
.bandlink a:LINK,.bandlink a:VISITED,.bandlink a:HOVER {font-size: 8pt;font-weight: bold;cursor: pointer;padding: 0px;margin: 0px;}
.bandlink a:LINK,.bandlink a:VISITED {color: white;text-decoration: none;}
.bandlink a:HOVER {color: #9FDCFF;text-decoration: none;}/*#F2754F*/
.bandlink td {text-align: center;/*background: url("../img/bandtab.png") repeat-x top;*/height: 30px;}
.bandlink td.bandsep {color: #7B8A93/*#AAD1E1*/;font-size: 8pt;font-family: arial;}
.bandmess {background: url('../img/mail_box2.png') #2A3E46 no-repeat 10%;color: #9FDCFF/*#AAD1E1*/;font-size: 7pt;height: 20px;vtext-align: left;text-indent: 25px;font-family: trebuchet MS;'}


 -->
</style>

<div class="bandtop1">
<center>
<table class="bandcad" cellpadding="0" cellspacing="0" border="0" height="25">
	<tr>
		<td width="2">&nbsp;</td>
		<td>
		<font style="color: white;font-size: 8pt;">
	
		</font>
		</td>
		
		<td align="right">
		
		
		
		<table width="150" cellpadding="0" cellspacing="0" border="0"> 
		  <tr>
		    <td class="bandmess" style="cursor: pointer;" title='Cliquer ici pour sélectionner une requête' onclick="parent.voir();"><b style="font-weight: bold;font-style: italic;font-size: 8pt;">INBOX</b> 
		    </td>
		    <td style="vertical-align: bottom;padding-left: 5px;" align="left"><iframe height="19" frameborder="0" id="requete_en_cours" name="requete_en_cours" src="<%=url_requeteur+""%>/requete_en_cours.jsp" marginheight="0" marginwidth="0" scrolling="no" style="width: 80px;margin: 0px;padding: 0px;"></iframe>
		   </td>
		  </tr>
		</table>
		
		
		
		</td>
		<td align="right" class="label" width="100"><font style="color: silver;font-size: 8pt;"><i><%=Etn.last_name%>&nbsp;<%=Etn.first_name%></i></font>
		<!-- <%//=libelle_msg(Etn,request,"Utilisateur connect&eacute;")%> : -->
		</td>

	</tr>
</table>
</center>
</div>


<div id="cacher2" style="font-size: 11px;position: absolute;top:4%;right:10%;display: none;z-index: 1000;"><!-- background-color: #2A3E46;border:1px solid silver; -->
		
		
		
		
		
	
		</div>