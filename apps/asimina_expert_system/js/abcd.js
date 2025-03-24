function show(z)
{
	var s = "" ;

	var w = window.open("","aide",'height=360,width=400,top=100,left=140,scrollbars=yes,resizable');
	w.document.open();

 	for( var i in z )
    {
    	s = "";
        c = ("" + i).charAt(0);
        if(c < '0' || c > '9' )
            s += " <font color=blue>" + i + "</font>->" + eval( "z." +i) ;
        else
            s += " " + i + "-> void ptr ";
        s += "<br>";
        w.document.write(s);
	}
	w.document.close();
	return(false);
}

function abcd_init(num_mobile){
	getDossierClient(num_mobile);
	getAlerte_recommandation(num_mobile);
	getChartData(num_mobile);
	getChartData2(num_mobile);
	getChartData3(num_mobile);
	list_mob(num_mobile);
}

function getDossierClient(num_mobile)
	{
		//alert("ici="+t[t.selectedIndex].value); 
	$.ajax({
	type: "POST",
	url: "/abcd/js/dossier_client.jsp",
	data: "num_mobile="+num_mobile,
	dataType: "html",
	success: function(html){       
		$("#dossier_client").html(html);    
		//$("#td_modele2").html(html);    
		
		},
	error:function (xhr, ajaxOptions, thrownError){ 
            //alert(xhr.status); 
           // $("#td_modele").html(xhr.status); 
            alert("dossier_client\n"+xhr.responseText);
        }
		 }); }

function getAlerte_recommandation(num_mobile)
{
	//alert("ici="+t[t.selectedIndex].value); 
$.ajax({
type: "POST",
url: "/abcd/js/alerte_recommandation.jsp",
data: "num_mobile="+num_mobile,
dataType: "html",
success: function(html){       
	$("#alerte_recommandation").html(html);    
	//$("#td_modele2").html(html);    
	
	},
error:function (xhr, ajaxOptions, thrownError){ 
        //alert(xhr.status); 
       // $("#td_modele").html(xhr.status); 
        alert("alerte_recommandation\n"+xhr.responseText);
    }
	 }); }


function list_mob(num_mobile){
	$.ajax({
		type: "POST",
		url: "/abcd/js/list_mob.jsp",
		data: "num_mobile="+num_mobile,
		dataType: "html",
		success: function(html){       
			$("#list_mob").html(html);    
			
			//$("#td_modele2").html(html);    
			
			},
		error:function (xhr, ajaxOptions, thrownError){ 
		        //alert(xhr.status); 
		       // $("#td_modele").html(xhr.status); 
		        alert("list_mob\n"+xhr.responseText);
		    }
			 });
}


function getChartData(num_mobile)
{
	//alert("ici="+t[t.selectedIndex].value); 
$.ajax({
type: "POST",
url: "/abcd/js/req.jsp?num_mobile="+num_mobile+"&req=1",
data: "",
dataType: "json",
success: function(dataProvider){     
//alert(dataProvider);
//SERIAL CHART    
chart = new AmCharts.AmSerialChart();
chart.pathToImages = "/abcd/img/amchart_images/";
chart.panEventsEnabled = true;
chart.zoomOutButton = {
    backgroundColor: "#000000",
    backgroundAlpha: 0.15
};
chart.zoomOutText = "Voir tout"
chart.dataProvider = dataProvider;
chart.categoryField = "mois";
             




// listen for "dataUpdated" event (fired when chart is inited) and call zoomChart method when it happens
//chart.addListener("dataUpdated", zoomChart);

// AXES
// category                
var categoryAxis = chart.categoryAxis;
categoryAxis.dashLength = 2;
categoryAxis.gridAlpha = 0.15;
categoryAxis.axisColor = "#DADADA";
categoryAxis.labelRotation = 45; // this line makes category values to be rotated
categoryAxis.gridAlpha = 0;
categoryAxis.fillAlpha = 1;
categoryAxis.fillColor = "#FAFAFA";
categoryAxis.gridPosition = "start";

// first value axis (on the left)
var valueAxis1 = new AmCharts.ValueAxis();
valueAxis1.axisColor = "#FF6600";
valueAxis1.axisThickness = 2;
valueAxis1.gridAlpha = 0;
chart.addValueAxis(valueAxis1);

// second value axis (on the right) 
var valueAxis2 = new AmCharts.ValueAxis();
valueAxis2.position = "right"; // this line makes the axis to appear on the right
valueAxis2.axisColor = "#FCD202";
valueAxis2.gridAlpha = 0;
valueAxis2.axisThickness = 2;
chart.addValueAxis(valueAxis2);

// third value axis (on the left, detached)
valueAxis3 = new AmCharts.ValueAxis();
valueAxis3.offset = 50; // this line makes the axis to appear detached from plot area
valueAxis3.gridAlpha = 0;
valueAxis3.axisColor = "#B0DE09";
valueAxis3.axisThickness = 2;
chart.addValueAxis(valueAxis3);

// GRAPHS
// first graph
var graph1 = new AmCharts.AmGraph();
graph1.valueAxis = valueAxis1; // we have to indicate which value axis should be used
graph1.title = "QoS";
graph1.valueField = "qos";
graph1.bullet = "round";
graph1.hideBulletsCount = 30;
chart.addGraph(graph1);

// second graph                
var graph2 = new AmCharts.AmGraph();
graph2.valueAxis = valueAxis2; // we have to indicate which value axis should be used
graph2.title = "Téléchargement";
graph2.valueField = "telechargement";
graph2.bullet = "square";
graph2.hideBulletsCount = 30;
chart.addGraph(graph2);

// third graph
var graph3 = new AmCharts.AmGraph();
graph3.valueAxis = valueAxis3; // we have to indicate which value axis should be used
graph3.valueField = "minutes";
graph3.title = "Heures";
graph3.bullet = "triangleUp";
graph3.hideBulletsCount = 30;
chart.addGraph(graph3);


//third graph
var graph5 = new AmCharts.AmGraph();
graph5.valueAxis = valueAxis1; // we have to indicate which value axis should be used
graph5.valueField = "niveau";
graph5.title = "";
graph5.bullet = "";
graph5.hideBulletsCount = 0;
chart.addGraph(graph5);


// line graph // TELEPHONE
var graph4 = new AmCharts.AmGraph();
graph4.type = "line";
graph4.title = "Mobile";
graph4.valueField = "mobile";
graph4.lineThickness = 0;
//graph3.bullet = "round";
graph4.fillAlphas = 0;
graph4.customBulletField = "custombullet"; 
graph4.bulletSize = 30; // bullet image should be a rectangle (width = height)
graph4.balloonText = "[[constucteur]] [[mob]] [[forfait]]";
chart.addGraph(graph4);


var chartCursor = new AmCharts.ChartCursor();
chartCursor.cursorPosition = "mouse";
chart.addChartCursor(chartCursor);

/*
//LEGEND pb with 2.6.3
var legend = new AmCharts.AmLegend();
legend.position = "top";
chart.addLegend(legend);
 */

var legend = new AmCharts.AmLegend();
chart.addLegend(legend);

// SCROLLBAR
var chartScrollbar = new AmCharts.ChartScrollbar();
chart.addChartScrollbar(chartScrollbar);

chart.addListener('doubleClickGraphItem', function (event) {
	//show(event.graph)
	if(event.graph.valueField=="mobile"){
		var f = document.f1;
		f.tac_mob.value = event.item.dataContext.code_mobile;
		//alert(f.tac_mob.value)
		open_v360(f.tac_mob.value);
		//f.submit();
		//w.focus();
	}
	
	});

chart.write("chartdiv");

},
error:function (xhr, ajaxOptions, thrownError){ 
	alert("==>"+thrownError);
}

});
}

function open_v360(mob){
var w = window.open("http://www.etancesys.com/vision360/index.jsp?tac_mob="+mob,"v360","width=1124,height=868,scrollbars=yes,resizable");
}

function getChartData3(num_mobile)
{
	//alert("ici="+t[t.selectedIndex].value); 
$.ajax({
type: "POST",
url: "/abcd/js/req.jsp?num_mobile="+num_mobile+"&req=3",
data: "",
dataType: "json",
success: function(dataProvider){     
	 /*GRAPH RIGHT*/
	var chart2 = new AmCharts.AmSerialChart();
	chart2 = new AmCharts.AmPieChart();
    //chart2.startEffect = ">";
    chart2.dataProvider = dataProvider;
	chart2.titleField = "usages";
	chart2.valueField = "val";
	chart2.outlineColor = "#FFFFFF";
	chart2.outlineAlpha = 0.8;
	chart2.outlineThickness = 2;
    // this makes the chart 3D
	chart2.depth3D = 15;
	chart2.angle = 0;//30
	chart2.labelsEnabled = true;
	chart2.labelText = "[[percents]]%";
	
	
	chart2.labelRadius = 2;
	
	
	
	 var legend2 = new AmCharts.AmLegend();
     legend2.position = "top";
     legend2.fontSize=9;
     legend2.markerSize = 8;
     legend2.markerLabelGap = 2;
     legend2.markerBorderThickness = 0;
     legend2.autoMargins = false;

     legend2.position = "bottom";
         
     chart2.addLegend(legend2);

     chart2.write("chartdiv2");

},
error:function (xhr, ajaxOptions, thrownError){ 
	alert("==>"+thrownError);
}

});
}


function getChartData2(num_mobile)
{
	//alert("ici="+t[t.selectedIndex].value); 
$.ajax({
type: "POST",
url: "/abcd/js/req.jsp?num_mobile="+num_mobile+"&req=2",
data: "",
dataType: "json",
success: function(dataProvider){     

	var chart3 = new AmCharts.AmSerialChart();
	chart3.dataProvider = dataProvider;
	chart3.categoryField = "techno";
	//chart3.startDuration = 1;
	// sometimes we need to set margins manually
	// autoMargins should be set to false in order chart to use custom margin values                
	chart3.autoMargins = false;
	chart3.marginRight = 0;
	chart3.marginLeft = 0;

	/* remplacement ajax
	// AXES
	// category
	var categoryAxis = chart.categoryAxis;
	categoryAxis.inside = false;
	categoryAxis.axisAlpha = 0;
	categoryAxis.gridAlpha = 0; 
	categoryAxis.tickLength = 0;
	*/

	// value
	var valueAxis = new AmCharts.ValueAxis();
	valueAxis.axisAlpha = 0;
	valueAxis.gridAlpha = 0;
	chart3.addValueAxis(valueAxis);

	// GRAPH
	var graph5 = new AmCharts.AmGraph();
	graph5.valueField = "val";
	graph5.customBulletField = "bullet"; // field of the bullet in data provider
	graph5.bulletOffset = 16; // distance from the top of the column to the bullet
	graph5.colorField = "color";
	graph5.bulletSize = 34; // bullet image should be rectangle (width = height)
	graph5.type = "column";
	graph5.fillAlphas = 0.8;
	graph5.cornerRadiusTop = 8;
	graph5.lineAlpha = 0;
	chart3.addGraph(graph5);

	chart3.write("chartdiv3");

},
error:function (xhr, ajaxOptions, thrownError){ 
	alert("==>"+thrownError);
}

});
}

