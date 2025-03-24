
/*GRAPH CENTRAL*/

var chart;
var chart2;
var legend;

            var chartData = [
{
    mois: "Aout 2010",
    qos: 23,
    telechargement: 140,
    minutes: 4,
    mobile:400    
	},
{
    mois: "Sept 2010",
    qos: 23,
    telechargement: 150,
    minutes: 4.2,    
    customBullet:'/abcd/img/tel/60x80/SAGEM_MY_G5.png',
    constucteur:"SAGEM",
    mob:"MY G5",
    forfait:"Forfait payé",
    mobile:400
	},
	{
    mois: "Octobre 2010",
    qos: 23,
    telechargement: 140,
    minutes: 4,
   
    mobile:400
	},
	{
    mois: "Nov 2010",
    qos: 20,
    telechargement: 130,
    minutes: 3.8,
    
    mobile:400
	},
{
    mois: "Dec 2010",
    qos: 23,
    telechargement: 138,
    minutes: 3.4,
    
    mobile:400
	},
             
                             
                             {
        mois: "Janvier 2011",
        qos: 24,
        telechargement: 160,
        minutes: 3.7,
        
        mobile:400
    	},{
        mois: "Février 2011",
        qos: 24,
        telechargement: 159,
        minutes: 3.5,
        
        mobile:400
    	},{
        mois: "Mars 2011",
        qos: 23,
        telechargement: 163,
        minutes: 3.8,
        
        mobile:400
    	},{
        mois: "Avril 2011",
        qos: 23,
        telechargement: 160,
        minutes: 4,
       
        mobile:400
    	},{
        mois: "Mai 2011",
        qos: 23,
        telechargement: 150,
        minutes: 4,
       
        mobile:400
    	},
                  {
        mois: "Juin 2011",
        customBullet:'/abcd/img/tel/60x80/APPLE_iphone 4G S.jpg',
        constucteur:"APPLE",
        mob:" Iphone 3G S",
        forfait:"Forfait Origami",
        qos: 20,
        telechargement: 180,
        minutes: 4,
        
        mobile:400
    	},
    	 {
        mois: "Juillet 2011",
        qos: 30,
        telechargement: 200,
        minutes: 5,       
        mobile:400
       },
   	 {
	    mois: "Aout 2011",
	    qos: 29,
	    telechargement: 250,
	    minutes: 5.3,
	  
	    mobile:400
		},
	 {
        mois: "Sept 2011",
        qos: 47,
        telechargement: 300,
        minutes: 5.5,
       
        mobile:400
    	},
 {
        mois: "Nov 2011",
        qos: 30,
        telechargement: 330,
        minutes: 5.1,
    
        mobile:400
    	},
    	{
        mois: "Dec 2011",
        qos: 30,
        telechargement: 340,
        minutes: 5.2,
        mobile:400
    	},
    	{
        mois: "Janvier 2012",
        qos: 30,
        telechargement: 330,
        minutes: 5.1,
        mobile:400
    	},
    	{
        mois: "Février 2012",
        qos: 30,
        telechargement: 335,
        minutes: 5.2,
        mobile:400
    	},
    	{
        mois: "Mars 2012",
        qos: 30,
        telechargement: 330,
        minutes: 5.1,
        mobile:400
       }
    	
        ];
            /*GRAH CENTRAL*/
     

        var chartData2 = [{
            country: "Streaming",
            value: 260
        }, {
            country: "Internet",
            value: 201
        }, {
            country: "Download",
            value: 140
        }, {
            country: "Mail",
            value: 39
        }];
        
        var chartData3 = [{
            techno: "2G",
            value: 50,
            color:"#FF6600"
	        },{
	        techno: "EDGE",
	        value: 80,
	        color: "#7F8DA9"
	        },
	        {
        	techno: "3G",
            value: 150,
            color:"#FEC514"
        }, {
        	techno: "3G+",
            value: 200,
            color:"#DB4C3C"
        }, {
        	techno: "4G",
            value: 0,
            color:"#DAF0FD"
        }];
    
            

            AmCharts.ready(function () {
               
            	
            	/*
            	// SERIAL CHART
                chart = new AmCharts.AmSerialChart();
                chart.pathToImages = "/abcd/images/";
                chart.dataProvider = chartData;
                chart.categoryField = "mois";
                chart.startDuration = 1;
                chart.marginBottom = 10;
                chart.plotAreaBorderColor = "#DADADA";
                chart.plotAreaBorderAlpha = 1;

                // AXES
                // category
                var categoryAxis = chart.categoryAxis;
                categoryAxis.gridPosition = "start";
                categoryAxis.axisAlpha = 0;
                categoryAxis.dashLength = 1;

                // value
                var valueAxis = new AmCharts.ValueAxis();
                valueAxis.dashLength = 1;
                valueAxis.axisAlpha = 0.2;
                chart.addValueAxis(valueAxis);

                // GRAPHS
                // column graph
                var graph1 = new AmCharts.AmGraph();
                graph1.type = "column";
                graph1.title = "QoS";
                graph1.valueField = "qos";
                graph1.lineAlpha = 0;
                graph1.fillColors = "#ADD981";
                graph1.fillAlphas = 1;
         
                chart.addGraph(graph1);
                

                // line graph
                var graph2 = new AmCharts.AmGraph();
                graph2.type = "line";
                graph2.title = "Téléchargement";
                graph2.valueField = "telechargement";
                graph2.lineThickness = 2;
                graph2.bullet = "round";
                graph2.fillAlphas = 0;
               
                chart.addGraph(graph2);
                
             // line graph
                var graph3 = new AmCharts.AmGraph();
                graph3.type = "line";
                graph3.title = "Minutes";
                graph3.valueField = "minutes";
                graph3.lineThickness = 2;
                graph3.bullet = "round";
                graph3.fillAlphas = 0;
                chart.addGraph(graph3);


             // line graph
                var graph3 = new AmCharts.AmGraph();
                graph3.type = "line";
                graph3.title = "Mobile";
                graph3.valueField = "mobile";
                graph3.lineThickness = 0;
                //graph3.bullet = "round";
                graph3.fillAlphas = 0;
                graph3.customBulletField = "customBullet"; 
                graph3.bulletSize = 30; // bullet image should be a rectangle (width = height)
                graph3.balloonText = "[[constucteur]] [[mob]] \n [[forfait]]";
                chart.addGraph(graph3);
                
                var chartCursor = new AmCharts.ChartCursor();
                chart.addChartCursor(chartCursor);
                
                // LEGEND
                var legend = new AmCharts.AmLegend();
                legend.position = "top";
                chart.addLegend(legend);
           
                
                // SCROLLBAR
                var chartScrollbar = new AmCharts.ChartScrollbar();
                chart.addChartScrollbar(chartScrollbar);

               

                
                var categoryAxis = chart.categoryAxis;
                categoryAxis.labelRotation = 45; // this line makes category values to be rotated
                categoryAxis.gridAlpha = 0;
                categoryAxis.fillAlpha = 1;
                categoryAxis.fillColor = "#FAFAFA";
                categoryAxis.gridPosition = "start";
                */
            	
            	
            	// SERIAL CHART    
                chart = new AmCharts.AmSerialChart();
                chart.pathToImages = "/abcd/img/amchart_images/";
                chart.panEventsEnabled = true;
                chart.zoomOutButton = {
                    backgroundColor: "#000000",
                    backgroundAlpha: 0.15
                };
                chart.zoomOutText = "Voir tout"
                chart.dataProvider = chartData;
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

                
                // line graph // TELEPHONE
                var graph4 = new AmCharts.AmGraph();
                graph4.type = "line";
                graph4.title = "Mobile";
                graph4.valueField = "mobile";
                graph4.lineThickness = 0;
                //graph3.bullet = "round";
                graph4.fillAlphas = 0;
                graph4.customBulletField = "customBullet"; 
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
                chart.write("chartdiv");
                
                
                /*GRAPH RIGHT*/
                chart2 = new AmCharts.AmPieChart();
                //chart2.startEffect = ">";
                chart2.dataProvider = chartData2;
            	chart2.titleField = "country";
            	chart2.valueField = "value";
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
            	
              
                // WRITE
              
                
                /*GRAPH RIGHT*/ 
                
                
                var chart3 = new AmCharts.AmSerialChart();
                chart3.dataProvider = chartData3;
                chart3.categoryField = "techno";
                //chart3.startDuration = 1;
                // sometimes we need to set margins manually
                // autoMargins should be set to false in order chart to use custom margin values                
                chart3.autoMargins = false;
                chart3.marginRight = 0;
                chart3.marginLeft = 0;

                // AXES
                // category
                var categoryAxis = chart.categoryAxis;
                categoryAxis.inside = false;
                categoryAxis.axisAlpha = 0;
                categoryAxis.gridAlpha = 0;
                categoryAxis.tickLength = 0;

                // value
                var valueAxis = new AmCharts.ValueAxis();
                valueAxis.axisAlpha = 0;
                valueAxis.gridAlpha = 0;
                chart3.addValueAxis(valueAxis);

                // GRAPH
                var graph5 = new AmCharts.AmGraph();
                graph5.valueField = "value";
                graph5.customBulletField = "bullet"; // field of the bullet in data provider
                graph5.bulletOffset = 16; // distance from the top of the column to the bullet
                graph5.colorField = "color";
                graph5.bulletSize = 34; // bullet image should be rectangle (width = height)
                graph5.type = "column";
                graph5.fillAlphas = 0.8;
                graph5.cornerRadiusTop = 8;
                graph5.lineAlpha = 0;
                chart3.addGraph(graph5);

                
                
                
                // WRITE
                chart2.write("chartdiv3");
                chart3.write("chartdiv2"); 
                
                
            });
            
            
            function zoomChart() {
                // different zoom methods can be used - zoomToIndexes, zoomToDates, zoomToCategoryValues
                chart.zoomToIndexes(10, 20);
            }
            
          
         
          
           
            
            