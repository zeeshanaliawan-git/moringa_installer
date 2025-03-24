<script type="text/javascript">
    function toggleDiv(divId)
    {
        if (document.getElementById(divId).style.display == 'none')
        {
            document.getElementById(divId).style.display = 'block';
            document.getElementById(divId + 'Lbl').innerHTML = '-';
        }
        else
        {
            document.getElementById(divId).style.display = 'none';
            document.getElementById(divId + 'Lbl').innerHTML = '+';
        }
    }

    $(document).ready(function() {
        $("#assistanceDialog").dialog({
            width: 500,
            height: 800,
            autoOpen: false
        });
    });
</script> 


<table border="0" cellpadding="0" cellspacing="0" width="100%" align="left" style="background-color:#DFE2E3;padding:5px 5px 5px 5px;">
    <tr>
        <td class="textcenter" width="18%"><a href="../cr/checkPortability.jsp" <%if(screenNumber==1){%>style=" color: #FF6600"<%}%>>Vérification d'éligibilité à la Portabilité</a></td>
        <td style="color: white;" width="1%">|</td>
        <td class="textcenter" width="12%"><a href="../cr/smallcheck.jsp" <%if(screenNumber==2){%>style=" color: #FF6600"<%}%>>Demande de Portabilité</a></td>
        <td style="color: white;" width="1%">|</td>
        <td class="textcenter" width="23%"><a href="../cr/consultation.jsp" <%if(screenNumber==3){%>style=" color: #FF6600"<%}%>>Consultation d'une demande de portabilité en cours</a></td>
        <td style="color: white;" width="1%">|</td>
        <td class="textcenter" width="23%"><a href="../cr/annulation.jsp" <%if(screenNumber==4){%>style=" color: #FF6600"<%}%>>Annulation d'une demande de portabilité en cours</a></td>
        <td style="color: white;" width="1%">|</td>
        <td class="textcenter" width="9%"><a href="#" onclick="$('#assistanceDialog').dialog('open');">Assistance</a></td>
        <td style="color: white;" width="1%">|</td>
        <td class="textcenter" width="9%"><a href="#" onclick="myCustomAlertWithTitle('En cours...','');">Requéteur</a></td>
        <td style="color: white;" width="10%">|</td>

    </tr>

</table>

<div id="assistanceDialog" title="Assistance" style=" display: none"><%@include file="assistance_include.jsp"%></div>


