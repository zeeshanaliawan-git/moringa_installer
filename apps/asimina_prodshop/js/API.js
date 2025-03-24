var fieldNames={
    customerName: "Nombre",
    gender: "Sexo",
    customerSurname: "Apellidos",
    nationality: "Nacionalidad",
    identityType: "Tipo documento",
    dob: "Fecha de nacimiento",
    identityId: "Documento",
    msisdn_existente: "Telefono Orange",
    roadType: "Tipo v&iacute;a",
    roadNumber: "N&uacute;mero",
    roadName: "Nombre v&iacute;a",
    stair: "Escalera",
    locality: "Localidad",
    floorNumber: "Piso",
    postalCode: "CP",
    apartmentNumber: "Puerta (opc.)",
    state: "Provincia",
    contactNumber1: "Tel&eacute;fono de contacto 1",
    customerEmail: "Email",
    contactNumber2: "Tel&eacute;fono de contacto 2",
    account: "Cuenta corriente",
    delvRoadType: "Tipo v&iacute;a",
    delvRoadNumber: "N&uacute;mero",
    delvRoadName: "Nombre v&iacute;a",
    delvStair: "Escalera",
    delvLocality: "Localidad",
    delvFloorNumber: "Piso",
    delvPostalCode: "CP",
    delvApartmentNumber: "Puerta (opc.)",
    delvState: "Provincia",
    terminalPrice: "Precio",
    sfid: "SFID",
    imei: "IMEI",
    iccidSim: "ICCID",
    previousIccidSim: "ICCID SIM donante",
    msisdn: "MSISDN",
    msisdntjt: "MSISDNTJT",
    custTracking: "Tracking",
    typeOfPaymentCurrentOperator: "Forma pago operador actual",
    previousOperator: "Operadora saliente",
    changeWindowDate: "Fecha ventana de cambio",
    portabilityCodeRequest: "Solicitud c&oacute;digo portabilidad"
};

function handleEditCover()
{
    var coverName=$("#coverName").val();
    var coverDesc=$("#coverDescription").val();
    $.ajax({
            type: 'GET',
            url: '../calls/editCoverPage.jsp',
            dataType: 'jsonp',
            data: "coverName="+coverName+"&coverDesc="+coverDesc,
            success: function(data) {

            },
            error: function(data, err) {
            //alert(err);
            },
            async: false,
            cache: false
        });
}
function handleDistinctProcesses(processesArray, mode)
{
    for(var i=0;i<processesArray.length;i++)
    {
        var html;
        if(mode=="combined")
        {
            html='<div id="process'+processesArray[i]+'" style=""><div><h3>Process Name: '+processesArray[i]+'</h3></div><div id="process'+processesArray[i]+'StartPhases"></div><div id="process'+processesArray[i]+'EndPhases"></div><div id="process'+processesArray[i]+'NumberOfPhases"></div><div id="process'+processesArray[i]+'ExternalProcesses"></div><div id="process'+processesArray[i]+'Graph"></div></div><hr/>';
        }
        else
        {
            if(i==0)
        {
            html='<div id="process'+processesArray[i]+'" style="border: black solid 1px; width: 3200px"><div><h3>Process Name: '+processesArray[i]+'</h3></div><div id="process'+processesArray[i]+'StartPhases"></div><div id="process'+processesArray[i]+'EndPhases"></div><div id="process'+processesArray[i]+'NumberOfPhases"></div><div id="process'+processesArray[i]+'ExternalProcesses"></div><div id="process'+processesArray[i]+'Graph"></div></div>';
        }
        else
        {
            html='<div id="process'+processesArray[i]+'" style="page-break-before: always; border: black solid 1px; width: 3200px"><div><h3>Process Name: '+processesArray[i]+'</h3></div><div id="process'+processesArray[i]+'StartPhases"></div><div id="process'+processesArray[i]+'EndPhases"></div><div id="process'+processesArray[i]+'NumberOfPhases"></div><div id="process'+processesArray[i]+'ExternalProcesses"></div><div id="process'+processesArray[i]+'Graph"></div></div>';
        }
        }
        
        $("#processTable").append(html);
    }

    for(var i=0;i<processesArray.length;i++)
    {
        $.ajax({
            type: 'GET',
            url: '../calls/getProcessData.jsp',
            dataType: 'jsonp',
            data: "process="+processesArray[i],
            success: function(data) {
                var html;
                if(data.startPhases!="")
                {
                    html="Start Phases: "+data.startPhases;
                    $("#process"+processesArray[i]+"StartPhases").html(html);
                }
                if(data.endPhases!="")
                {
                    html="End Phases: "+data.endPhases;
                    $("#process"+processesArray[i]+"EndPhases").html(html);
                }
                /*html="Phases: "+data.phases;
                        $("#process"+processesArray[i]+"Phases").html(html);*/
                html="Number Of Phases: "+data.phases.split(",").length;
                $("#process"+processesArray[i]+"NumberOfPhases").html(html);
                if(data.externalProcesses!="")
                {
                    html="External Processes: "+data.externalProcesses;
                    $("#process"+processesArray[i]+"ExternalProcesses").html(html);
                }
            },
            error: function(data, err) {
            //alert(err);
            },
            async: false,
            cache: false
        });
    }

    for(var i=0;i<processesArray.length;i++)
    {
        if(mode=="combined")
        {
            $("#process"+processesArray[i]+"Graph").html("See Appendix for Graph");
        }
        else
        {
            $.ajax({
                type: 'GET',
                url: 'manhattanImage.jsp',
                data: "process="+processesArray[i],
                success: function(data) {
                    var html="";
                    html+='<img src="../generatedImages/'+processesArray[i]+'.png" />';
                    //alert(html);
                    $("#process"+processesArray[i]+"Graph").html(html);
                },
                error: function(data, err) {
                //alert(err);
                },
                async: false,
                cache: false
            });
        }
        
    }
}

function handlePhases(data)
{
    var tempArray=[];
    for(var i=0;i<data.length;i++)
    {
        var tempKey=data[i].start_phase.replace(/ /g,"_")+"KEY";
        if(typeof tempArray[tempKey]=="undefined")
        {
            //alert(tempArray[tempKey]+" "+tempKey);
            tempArray[tempKey]=1;
        }
        else
        {
            //alert(tempArray[tempKey]+" "+tempKey);
            tempArray[tempKey]++;
        }
    }
    //alert(tempArray[tempKey]);
    var html="";
    for(var i=0;i<data.length;) // INCREMENT INSIDE
    {
        var tempKey=data[i].start_phase.replace(/ /g,"_")+"KEY";
        //alert(property+"    "+data[property])

        html+="<tr><td rowspan='"+tempArray[tempKey]+"'>"+data[i].start_phase+"</td>";
        for(var j=0;j<tempArray[tempKey];j++)
        {
            if(j!=0)
            {
                html+="<tr>";
            }
            html+="<td>"+data[i].next_phase+"</td><td>"+data[i].errCode+"</td></tr>";
            i++;
        }

    }
    //alert(html);
    $("#phasesTable").append(html);
}

function handleProfilePhase(data)
{
    var tempArray=[];
    for(var i=0;i<data.length;i++)
    {
        var tempKey=data[i].profile.replace(/ /g,"_")+"KEY";
        if(typeof tempArray[tempKey]=="undefined")
        {
            //alert(tempArray[tempKey]+" "+tempKey);
            tempArray[tempKey]=1;
        }
        else
        {
            //alert(tempArray[tempKey]+" "+tempKey);
            tempArray[tempKey]++;
        }
    }
    //alert(tempArray[tempKey]);
    var html="";
    for(var i=0;i<data.length;) // INCREMENT INSIDE
    {
        var tempKey=data[i].profile.replace(/ /g,"_")+"KEY";
        //alert(property+"    "+data[property])

        html+="<tr><td rowspan='"+tempArray[tempKey]+"'>"+data[i].profile+"</td>";
        for(var j=0;j<tempArray[tempKey];j++)
        {
            if(j!=0)
            {
                html+="<tr>";
            }
            html+="<td>"+data[i].phase+"</td></tr>";
            i++;
        }

    }
    //alert(html);
    $("#profilePhaseTable").append(html);
}

function handleActions(data)
{
    var tempMainArray=[];
    for(var i=0;i<data.length;i++)
    {
        var tempKey=data[i].start_phase.replace(/ /g,"_")+"KEY";
        if(typeof tempMainArray[tempKey]=="undefined")
        {
            tempMainArray[tempKey]=1;
        }
        else
        {
            tempMainArray[tempKey]++;
        }
    }
    //alert(tempArray[tempKey]);
    var html="";
    for(var i=0;i<data.length;) // INCREMENT INSIDE
    {
        var tempKey=data[i].start_phase.replace(/ /g,"_")+"KEY";
        //alert(property+"    "+data[property])

        html+="<tr><td rowspan='"+tempMainArray[tempKey]+"'>"+data[i].start_phase+"</td>";
        for(var j=0;j<tempMainArray[tempKey];j++)
        {
            if(j!=0)
            {
                html+="<tr>";
            }
            var details="";
            if(data[i].actionType=="sms")
            {
                details="Texte: "+data[i].sms;
            }else if(data[i].actionType=="mail")
            {
                details="Order Type: "+data[i].orderType;
                details+="<br>Attachment: "+data[i].attach;
            }else if(data[i].actionType=="sql")
            {
                details="Sql: "+data[i].sql;
            }else
            {
                details="Fact: "+data[i].fact;
            }
            html+="<td>"+data[i].actionType+"</td><td width=\"400\">"+details+"</td></tr>";
            i++;
        }
    }
    //alert(html);
    $("#actionsTable").append(html);
}

function handleErrCodes(data)
{
    var html="";
    html=createTableFromJson(data);
    //alert(html);
    $("#errCodeTable").append(html);
}

function handleFieldSettings(data)
{
    var html="";
    for(var i=0;i<data.length;i++) // INCREMENT INSIDE
    {
        var fieldNameArray=data[i].fieldName.split(",");
        var isMandatoryArray=data[i].isMandatory.split(",");
        //alert(property+"    "+data[property])

        html+="<tr><td rowspan='"+fieldNameArray.length+"'>"+data[i].phase+"</td><td rowspan='"+fieldNameArray.length+"'>"+data[i].screenName+"</td>";
        for(var j=0;j<fieldNameArray.length;j++)
        {
            if(j!=0)
            {
                html+="<tr>";
            }
            var tempFieldName="";
            if(typeof fieldNames[fieldNameArray[j]]!="undefined")
            {
                tempFieldName=fieldNames[fieldNameArray[j]];
            }
            else
            {
                tempFieldName=fieldNameArray[j];
            }

            html+="<td>"+tempFieldName+"</td><td>"+isMandatoryArray[j]+"</td></tr>";
        }
    }
    $("#fieldSettingsTable").append(html);
}

function handleBannedRules(data)
{
    var html="";
    for(var i=0;i<data.length;i++) // INCREMENT INSIDE
    {
        var startPhaseArray=data[i].start_phase.split(",");
        var startProcessArray=data[i].start_proc.split(",");
        var nextPhaseArray=data[i].next_phase.split(",");
        var nextProcessArray=data[i].next_proc.split(",");
        var isBannedArray=data[i].isBanned.split(",");
        //alert(property+"    "+data[property])

        html+="<tr><td rowspan='"+startPhaseArray.length+"'>"+data[i].profile+"</td>";
        for(var j=0;j<startPhaseArray.length;j++)
        {
            if(j!=0)
            {
                html+="<tr>";
            }
            if(isBannedArray[j]==1)
            {
                html+="<td class='redTd'>"+startProcessArray[j]+"</td><td class='redTd'>"+startPhaseArray[j]+"</td><td class='redTd'>"+nextProcessArray[j]+"</td><td class='redTd'>"+nextPhaseArray[j]+"</td></tr>";
            }
            else
            {
                html+="<td>"+startProcessArray[j]+"</td><td>"+startPhaseArray[j]+"</td><td>"+nextProcessArray[j]+"</td><td>"+nextPhaseArray[j]+"</td></tr>";

            }
        }
    }
    //alert(html)
    $("#bannedRulesTable").append(html);
}

function handleConnectors(data)
{
    var html="";
    for(var i=0;i<data.length;i++)
    {
        data[i].executionEvents=data[i].executionEvents.replace(/,/g,"<br>");
    }
    //html=createEditableTableFromJson(data);
    //var html="";
    var classCount=0;
    for(var i=0;i<data.length;i++)
    {
        classCount=0;
        html+="<tr>";
        for(property in data[i])
        {
            if(property!="id")
            {
                classCount++;
                html+="<td class=\"columnClass"+classCount+"\">"+(data[i][property]!=""?data[i][property]:"&nbsp")+"</td>";
            }

        }
        html+="</tr>";
    }
    //alert(html);
    $("#connectorsTable").append(html);
}

function handleReports(data)
{
    var html="";
    for(var i=0;i<data.length;i++)
    {
        var tempFiltres=data[i].filtres.split(";");
        var tempFiltresString="";
        for(var j=0;j<tempFiltres.length;j++)
        {
            if(tempFiltres[j]!="")
            {
                tempFiltres[j]=tempFiltres[j].split(",");
                for(var k=0;k<tempFiltres[j].length;k++)
                {
                    if(k==0)
                    {
                        tempFiltresString+="<b>"+tempFiltres[j][k]+":</b>"
                    }
                    else
                    {
                        tempFiltresString+=" "+tempFiltres[j][k];
                    }
                }
                tempFiltresString+="<br>";
            }            
        }        
        data[i].filtres=tempFiltresString;
        if(data[i].valeurs.indexOf(",")==0)
        {
            data[i].valeurs=data[i].valeurs.replace(",","");
        }
        data[i].valeurs=data[i].valeurs.replace(/,/g,"<br>");
        if(data[i].agregations.indexOf(",")==0)
        {
            data[i].agregations=data[i].agregations.replace(",","");
        }

    }
    html=createEditableTableFromJson(data);
    $("#reportsTable").append(html);
    
}

function handleViewReports(data)
{
    var html="";
    for(var i=0;i<data.length;i++)
    {
        var tempFiltres=data[i].filtres.split(";");
        var tempFiltresString="";
        for(var j=0;j<tempFiltres.length;j++)
        {
            if(tempFiltres[j]!="")
            {
                tempFiltres[j]=tempFiltres[j].split(",");
                for(var k=0;k<tempFiltres[j].length;k++)
                {
                    if(k==0)
                    {
                        tempFiltresString+="<b>"+tempFiltres[j][k]+":</b>"
                    }
                    else
                    {
                        tempFiltresString+=" "+tempFiltres[j][k];
                    }
                }
                tempFiltresString+="<br>";
            }
        }
        data[i].filtres=tempFiltresString;
        if(data[i].valeurs.indexOf(",")==0)
        {
            data[i].valeurs=data[i].valeurs.replace(",","");
        }
        data[i].valeurs=data[i].valeurs.replace(/,/g,"<br>");
        if(data[i].agregations.indexOf(",")==0)
        {
            data[i].agregations=data[i].agregations.replace(",","");
        }

    }
    html=createEditableTableFromJson(data);
    html="<tbody id=\"tb\">"+html+"</tbody>"
    //alert($("#reportsTable").html());
    $("#reportsTable").append(html);
    $("#reportsTable").tablesorter();
    $('#tb tr td').dblclick(function() {
        edit($(this));
    });
}

function handleCron(data)
{
    var html="";
    html=createTableFromJson(data);
    //alert(html);
    $("#cronTable").append(html);
}

function handleWebApps(data)
{
    var html="";
    html=createTableFromJson(data);
    //alert(html);
    $("#webAppTable").append(html);
}

function createTableFromJson(data)
{
    var html="";
    for(var i=0;i<data.length;i++)
    {
        html+="<tr>";
        for(property in data[i])
        {
            html+="<td>"+(data[i][property]!=""?data[i][property]:"&nbsp")+"</td>";
        }
        html+="</tr>";
    }
    return html;
}

function createEditableTableFromJson(data)
{
    var html="";
    for(var i=0;i<data.length;i++)
    {
        html+="<tr>";
        for(property in data[i])
        {
            if(property!="id")
            {
                html+="<td>"+(data[i][property]!=""?data[i][property]:"&nbsp")+"</td>";
            }

        }
        html+="</tr>";
    }
    return html;
}

function edit(obj)
{
    if( obj.length != 1 ) return;
    cur = obj[0];
    if( cur.cellIndex == 0 )  // del
        return (del(cur) );

    if( canUpdt.indexOf(","+cur.cellIndex+",") == -1 ) return;
    inp = document.getElementById('inp');

    with( cur )
    {
        if(!firstChild)
            appendChild( document.createTextNode("") );

        otext = replaceChild(inp,firstChild);
        inp.value = otext.nodeValue;

        }

    cur.normalize();
    inp.focus();

}