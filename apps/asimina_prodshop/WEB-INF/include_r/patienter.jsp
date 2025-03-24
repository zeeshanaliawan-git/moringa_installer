<!-- DEBUT DU SCRIPT -->
<STYLE TYPE="text/css">
<!--
#cache {
    position:absolute;
    top:200px;
    z-index:10;
    visibility:hidden;
}
-->
</STYLE>
<DIV ID="cache">
<TABLE WIDTH=500 BGCOLOR="#D5D4FF" BORDER=0 CELLPADDING=1 CELLSPACING=0>
<TR><TD ALIGN=center VALIGN=middle>
<TABLE WIDTH=100% BGCOLOR="white" BORDER=0 CELLPADDING=0 CELLSPACING=0>
<TR><TD ALIGN=center VALIGN=middle>
<FONT FACE="Arial" SIZE=2 COLOR="#413AFF">
<BR>>> <%=libelle_msg(Etn,request,"Veuillez patienter pendant la construction de la page ....")%>"<< <BR><BR></FONT></TD>  </TR></TABLE>
</TD>  </TR></TABLE></DIV>

<SCRIPT LANGUAGE="JavaScript">
/*
SCRIPT EDITE SUR L'EDITEUR JAVASCRIPT
http://www.editeurjavascript.com
*/
var nava = (document.layers);
var dom = (document.getElementById);
var iex = (document.all);
if (nava) { cach = document.cache }
else if (dom) { cach = document.getElementById("cache").style }
else if (iex) { cach = cache.style }
largeur = screen.width;
largeur = document.body.clientWidth;
longeur = document.body.clientHeight;

cach.left = Math.round((largeur/2)-200);
cach.top = Math.round((longeur/2)-100);

cach.visibility = "visible";

function cacheOff()
	{
	cach.visibility = "hidden";
	}
//window.onload = cacheOff

 var oldonload = window.onload; //fonctions existantes
    if (typeof window.onload != 'function') { //si pas de fonction onload sur la page, on colle la fonction directement
        window.onload =  cacheOff;
    }else {
        window.onload = function() {  //s'il y a déjà des fonctions dans le onload, on le rajoute aux fonctions existantes
            oldonload();
             cacheOff();
        }
    }



</SCRIPT>
<!-- FIN DU SCRIPT -->