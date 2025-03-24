<%@ page import="com.etn.beans.Contexte"%>

<%!

    JSONObject getAbandonedCartsChartSmallData(Contexte Etn,String siteId,String label, String graphType, String startTime, String endTime , Locale requestLocal,String catalogType){
        JSONObject abandonedCartsChart = new JSONObject();

        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject genericChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: false},scales: {xAxes: [{gridLines: {color: 'transparent',zeroLineColor: 'transparent',},ticks: {fontSize: 2,fontColor: 'transparent',},}],yAxes: [{display: false}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4}}}");

            label = parseNull(label);
            graphType = parseNull(graphType);
            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);

            String keyColumn = "";
            Map<String, Object> lastDaysMap = new LinkedHashMap<String, Object>();
            Map<String, Integer> lastDaysIndexesMap = new LinkedHashMap<String, Integer>();
            
            JSONArray lastDays = new JSONArray();
            int rowCount = 0;
            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<15){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
                    lastDaysMap.put(key, 0);
                    lastDaysIndexesMap.put(key, rowCount);
                    rowCount++;
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<500){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth;
                    lastDaysMap.put(key, 0);
                    lastDaysIndexesMap.put(key, rowCount);
                    rowCount++;
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG,requestLocal));
                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    String key = start.get(Calendar.YEAR)+"";
                    lastDaysMap.put(key, 0);
                    lastDaysIndexesMap.put(key, rowCount);
                    rowCount++;
                    lastDays.put(key);
                    start.add(Calendar.YEAR, 1);
                }
            }

            abandonedCartsChart.put("type",graphType);
            abandonedCartsChart.put("options",genericChartOptions);

            JSONObject abandonedCartsChartMainData = new JSONObject();
            abandonedCartsChartMainData.put("labels",lastDays);
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";
            }
			
			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}
			
            Set rsOrders = Etn.execute("select "+keyColumn+", count(distinct o.id) from orders o inner join post_work pw on o.id=pw.client_key"
                + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and pw.proces="+
                escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+" "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+
                cancelPhaseWhereClause+" )":"")+" group by 1 order by creationDate desc;");
            int totalOrders = 0;
            while(rsOrders.next()){
                totalOrders += parseNullInt(rsOrders.value(1));
                lastDaysMap.put(rsOrders.value(0), parseNullInt(rsOrders.value(1)));
            }

            JSONArray orders = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                orders.put(parseNullInt(value));
                lastDaysMap.put(key, 0);
            }

            String filterWhere="";
            String filterJoin="";
            // if(!catalogType.equalsIgnoreCase("all")){
            //     filterJoin = " left join dashboard_filters_items slf on slf.filter_type= cs.eletype and slf.filter_on=cs.eleid ";
            //     filterWhere = " and slf.filter_id="+escape.cote(catalogType);
            // }

            Set rsAbandonedCarts = Etn.execute("select "+keyColumn.replace("o.creationDate","date_l")+", count(distinct session_j) from consolidated_stat_urls_after cs "+
                filterJoin+" where page_c = 'cart.jsp' and (date_l between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and cs.site_id="+
                escape.cote(siteId)+filterWhere+" group by 1 order by date_l desc;");

            while(rsAbandonedCarts.next()){
                int abandonedCartsCount = parseNullInt(rsAbandonedCarts.value(1))-orders.optInt(parseNullInt(lastDaysIndexesMap.get(rsAbandonedCarts.value(0))));
                lastDaysMap.put(rsAbandonedCarts.value(0), abandonedCartsCount);
            }

            JSONArray abandonedCarts = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                abandonedCarts.put(parseNullDouble(value));
            }
            abandonedCartsChartMainData.put("datasets",new JSONArray("[{label: \"Carts\",borderColor: \"rgba(255,255,255,.55)\",data: "+abandonedCarts.toString()+"}]"));
            abandonedCartsChart.put("data",abandonedCartsChartMainData);
            
            Set rsTotal = Etn.execute("select count(distinct session_j) from consolidated_stat_urls_after cs "+filterJoin+" where page_c = 'cart.jsp' and (date_l between "+
            escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and cs.site_id="+escape.cote(siteId)+filterWhere);
            
            rsTotal.next();
            if((parseNullInt(rsTotal.value(0))-totalOrders)<0){
                abandonedCartsChart.put("total",0);
            }else{
                abandonedCartsChart.put("total",parseNullInt(rsTotal.value(0))-totalOrders);
            }
            abandonedCartsChart.put("label",label);
        }catch(Exception e){}
        return abandonedCartsChart;
    }


    JSONObject getAverageOrderChartSmallData(Contexte Etn,String siteId, String label, String graphType, String startTime, String endTime , Locale requestLocal,String catalogType){
        JSONObject averageOrderChart = new JSONObject();
        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject genericChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: false},scales: {xAxes: [{gridLines: {color: 'transparent',zeroLineColor: 'transparent',},ticks: {fontSize: 2,fontColor: 'transparent',},}],yAxes: [{display: false}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4}}}");

            label = parseNull(label);
            graphType = parseNull(graphType);
            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);


            String keyColumn = "";
            Map<String, Object> lastDaysMap = new LinkedHashMap<String, Object>();
            
            JSONArray lastDays = new JSONArray();
            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<15){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<500){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth;
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, requestLocal));
                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    String key = start.get(Calendar.YEAR)+"";
                    lastDaysMap.put(key, 0);
                    lastDays.put(key);
                    start.add(Calendar.YEAR, 1);
                }
            }

            averageOrderChart.put("type",graphType);
            averageOrderChart.put("options",genericChartOptions);
            JSONObject averageOrderChartMainData = new JSONObject();
            averageOrderChartMainData.put("labels",lastDays);
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";
            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}
			
            Set rsOrders = Etn.execute("select "+keyColumn+", count(distinct o.id) from orders o inner join post_work pw on o.id=pw.client_key"
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+" "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+" group by 1 order by creationDate desc;");
            while(rsOrders.next()){
                lastDaysMap.put(rsOrders.value(0), parseNullInt(rsOrders.value(1)));
            }

            int totalOrders = 0;
            JSONArray orders = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                orders.put(parseNullInt(value));
                totalOrders += parseNullInt(value);
                lastDaysMap.put(key, 0);
            }
            String currency = "";
            Set rsRevenue = Etn.execute("select "+keyColumn+",sum(o.total_price), currency from orders o where o.site_id="+escape.cote(siteId)+
                " and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+
                ") and o.id in (select client_key from post_work pw where pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+
                ") "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+
                " group by 1 order by creationDate desc;");
            while(rsRevenue.next()){
                if(currency.length()==0) currency = rsRevenue.value("currency");
                lastDaysMap.put(rsRevenue.value(0), parseNullDouble(rsRevenue.value(1)));
            }

            double totalRevenue = 0;
            JSONArray revenue = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                revenue.put(parseNullDouble(value));
                totalRevenue += parseNullDouble(value);
            }

            JSONArray averageOrder = new JSONArray();
            for(int i=0; i<orders.length(); i++){
                averageOrder.put(Math.round(revenue.optDouble(i)/orders.optDouble(i)*100)/100.0);
            }

            averageOrderChartMainData.put("datasets",new JSONArray("[{label: \"Products\",borderColor: \"rgba(255,255,255,.55)\",data: "+averageOrder.toString()+"}]"));
            averageOrderChart.put("data",averageOrderChartMainData);
            averageOrderChart.put("total",Math.round(totalRevenue/totalOrders*100)/100.0);
            averageOrderChart.put("currency",currency);
            averageOrderChart.put("label",label.replaceAll("<currency>",currency));
        }catch(Exception e){}
        return averageOrderChart;

    }

    JSONObject getDeliveryDistributionTypeChartData(Contexte Etn,String siteId,String startTime, String endTime,String catalogType){
        JSONObject deliveryDistributionType = new JSONObject();

        try{

            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            JSONObject deliveryDistributionTypeOptions = new JSONObject("{\"responsive\": true,\"sort\": \"desc\",\"legend\": {\"display\":true,\"position\": \"top\"},\"animation\": {\"animateScale\": true,\"animateRotate\": true}}");

            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            deliveryDistributionType.put("type","doughnut");
            JSONArray deliveryDistributionTypeCounts = new JSONArray();
            JSONArray deliveryDistributionTypeLabels = new JSONArray();
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";

            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            String query;
            Set rsDeliveryDistributionTypeCounts = Etn.execute(query="SELECT count(distinct o.id), o.delivery_type , dm.displayName, concat(o.delivery_type,' - ',dm.displayName) as deliv"
                    + " FROM orders o inner join post_work pw on o.id=pw.client_key"
                    + " LEFT JOIN "+com.etn.beans.app.GlobalParm.getParm("PREPROD_CATALOG_DB")+".all_delivery_methods dm on dm.method = o.shipping_method_id"
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+" "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")
                    + " group by o.delivery_type ;");
            
            while(rsDeliveryDistributionTypeCounts.next()){
                deliveryDistributionTypeCounts.put(parseNullInt(rsDeliveryDistributionTypeCounts.value(0)));
                if(rsDeliveryDistributionTypeCounts.value("delivery_type").length()>0)
                    deliveryDistributionTypeLabels.put(rsDeliveryDistributionTypeCounts.value("deliv"));
                else
                    deliveryDistributionTypeLabels.put(rsDeliveryDistributionTypeCounts.value("displayName"));
            }

            JSONObject deliveryDistributionTypeMainData = new JSONObject();
            JSONObject deliveryDistributionTypeTempObj = new JSONObject();
            deliveryDistributionTypeTempObj.put("data", deliveryDistributionTypeCounts);
            deliveryDistributionTypeTempObj.put("backgroundColor", new JSONArray("[\"#FF6384\", \"#67b7dc\", \"#a367dc\", \"#dc67ce\", \"#36A2EB\", \"#FFCE56\"]"));
            deliveryDistributionTypeTempObj.put("hoverBackgroundColor", new JSONArray("[\"#FF6384\", \"#67b7dc\", \"#a367dc\", \"#dc67ce\", \"#36A2EB\", \"#FFCE56\"]"));
            JSONArray deliveryDistributionTypeDatasets = new JSONArray();
            deliveryDistributionTypeDatasets.put(deliveryDistributionTypeTempObj);
            deliveryDistributionTypeMainData.put("datasets",deliveryDistributionTypeDatasets);
            deliveryDistributionTypeMainData.put("labels",deliveryDistributionTypeLabels);

            deliveryDistributionType.put("data",deliveryDistributionTypeMainData);

            deliveryDistributionType.put("options",deliveryDistributionTypeOptions);

        }catch(Exception e){

        }
        return  deliveryDistributionType;
    }

    JSONObject getDeliveryDistributionChartData(Contexte Etn,String siteId,String startTime, String endTime){
        JSONObject deliveryDistribution = new JSONObject();

        try{

            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject deliveryDistributionOptions = new JSONObject("{\"responsive\": true,\"sort\": \"desc\",\"legend\": {\"display\":true,\"position\": \"top\"},\"animation\": {\"animateScale\": true,\"animateRotate\": true}}");

            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            deliveryDistribution.put("type","doughnut");
            JSONArray deliveryDistributionCounts = new JSONArray();
            JSONArray deliveryDistributionLabels = new JSONArray();
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";

            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            String query;
            Set rsDeliveryDistributionCounts = Etn.execute(query="SELECT o.shipping_method_id, (select displayName from "+catalogdb+".delivery_methods where method = o.shipping_method_id limit 1), count(distinct o.id)"
                    + " FROM orders o inner join post_work pw on o.id=pw.client_key"
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+" "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")
                    + " group by shipping_method_id ;");
            
            while(rsDeliveryDistributionCounts.next()){
                deliveryDistributionCounts.put(parseNullInt(rsDeliveryDistributionCounts.value(2)));
                deliveryDistributionLabels.put(rsDeliveryDistributionCounts.value(1));
            }

            JSONObject deliveryDistributionMainData = new JSONObject();
            JSONObject deliveryDistributionTempObj = new JSONObject();
            deliveryDistributionTempObj.put("data", deliveryDistributionCounts);
            deliveryDistributionTempObj.put("backgroundColor", new JSONArray("[\"#FF6384\", \"#67b7dc\", \"#a367dc\", \"#dc67ce\", \"#36A2EB\", \"#FFCE56\"]"));
            deliveryDistributionTempObj.put("hoverBackgroundColor", new JSONArray("[\"#FF6384\", \"#67b7dc\", \"#a367dc\", \"#dc67ce\", \"#36A2EB\", \"#FFCE56\"]"));
            JSONArray deliveryDistributionDatasets = new JSONArray();
            deliveryDistributionDatasets.put(deliveryDistributionTempObj);
            deliveryDistributionMainData.put("datasets",deliveryDistributionDatasets);
            deliveryDistributionMainData.put("labels",deliveryDistributionLabels);

            deliveryDistribution.put("data",deliveryDistributionMainData);

            deliveryDistribution.put("options",deliveryDistributionOptions);

        }catch(Exception e){

        }
        return  deliveryDistribution;
    }

    JSONObject getDeliveryPointDistributionChartData( Contexte Etn,String siteId,String startTime, String endTime,String catalogType ){
        JSONObject deliveryPointDistribution = new JSONObject();

        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject deliveryPointDistributionOptions = new JSONObject("{\"responsive\": true,\"sort\": \"desc\",\"legend\": {\"display\":true,\"position\": \"top\"},\"animation\": {\"animateScale\": true,\"animateRotate\": true}}");

            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            deliveryPointDistribution.put("type","doughnut");
            JSONArray deliveryPointDistributionCounts = new JSONArray();
            JSONArray deliveryPointDistributionLabels = new JSONArray();
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";

            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            Set rsDeliveryPointDistributionCounts = Etn.execute("SELECT o.shipping_method_id, o.daline1, count(distinct o.id) FROM orders o inner join post_work pw on o.id=pw.client_key"
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+" "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")
                    + " and o.shipping_method_id='pick_up_in_package_point' and o.daline1<>'' group by o.daline1 order by 3 desc;");
            while(rsDeliveryPointDistributionCounts.next()){
                deliveryPointDistributionCounts.put(parseNullInt(rsDeliveryPointDistributionCounts.value(2)));
                deliveryPointDistributionLabels.put(rsDeliveryPointDistributionCounts.value(1));
            }

            JSONObject deliveryPointDistributionMainData = new JSONObject();
            JSONObject deliveryPointDistributionTempObj = new JSONObject();
            deliveryPointDistributionTempObj.put("data", deliveryPointDistributionCounts);
            deliveryPointDistributionTempObj.put("backgroundColor", new JSONArray("[\"#FF6384\", \"#67b7dc\", \"#a367dc\", \"#dc67ce\", \"#36A2EB\", \"#FFCE56\", \"#4dbd74\", \"red\", \"#dc8c67\"]"));
            deliveryPointDistributionTempObj.put("hoverBackgroundColor", new JSONArray("[\"#FF6384\", \"#67b7dc\", \"#a367dc\", \"#dc67ce\", \"#36A2EB\", \"#FFCE56\", \"#4dbd74\", \"red\", \"#dc8c67\"]"));
            JSONArray deliveryPointDistributionDatasets = new JSONArray();
            deliveryPointDistributionDatasets.put(deliveryPointDistributionTempObj);
            deliveryPointDistributionMainData.put("datasets",deliveryPointDistributionDatasets);
            deliveryPointDistributionMainData.put("labels",deliveryPointDistributionLabels);

            deliveryPointDistribution.put("data",deliveryPointDistributionMainData);

            deliveryPointDistribution.put("options",deliveryPointDistributionOptions);
        }catch(Exception e){

        }
        return deliveryPointDistribution;
    }
    JSONObject getDeliveryStoreDistributionChartData(Contexte Etn,String siteId,String startTime, String endTime,String catalogType){
        JSONObject deliveryStoreDistribution = new JSONObject();
        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject deliveryStoreDistributionOptions = new JSONObject("{\"responsive\": true,\"sort\": \"desc\",\"legend\": {\"display\":true,\"position\": \"top\"},\"animation\": {\"animateScale\": true,\"animateRotate\": true}}");

            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            deliveryStoreDistribution.put("type","doughnut");
            JSONArray deliveryStoreDistributionCounts = new JSONArray();
            JSONArray deliveryStoreDistributionLabels = new JSONArray();
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";

            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            Set rsDeliveryStoreDistributionCounts = Etn.execute("SELECT o.shipping_method_id, o.daline1, count(distinct o.id) FROM orders o inner join post_work pw on o.id=pw.client_key"
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+" "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")
                    + " and o.shipping_method_id='pick_up_in_store' and o.daline1<>'' group by o.daline1 order by 3 desc;");
            while(rsDeliveryStoreDistributionCounts.next()){
                deliveryStoreDistributionCounts.put(parseNullInt(rsDeliveryStoreDistributionCounts.value(2)));
                deliveryStoreDistributionLabels.put(rsDeliveryStoreDistributionCounts.value(1));
            }

            JSONObject deliveryStoreDistributionMainData = new JSONObject();
            JSONObject deliveryStoreDistributionTempObj = new JSONObject();
            deliveryStoreDistributionTempObj.put("data", deliveryStoreDistributionCounts);
            deliveryStoreDistributionTempObj.put("backgroundColor", new JSONArray("[\"#FF6384\", \"#67b7dc\", \"#a367dc\", \"#dc67ce\", \"#36A2EB\", \"#FFCE56\", \"#4dbd74\", \"red\", \"#dc8c67\"]"));
            deliveryStoreDistributionTempObj.put("hoverBackgroundColor", new JSONArray("[\"#FF6384\", \"#67b7dc\", \"#a367dc\", \"#dc67ce\", \"#36A2EB\", \"#FFCE56\", \"#4dbd74\", \"red\", \"#dc8c67\"]"));
            JSONArray deliveryStoreDistributionDatasets = new JSONArray();
            deliveryStoreDistributionDatasets.put(deliveryStoreDistributionTempObj);
            deliveryStoreDistributionMainData.put("datasets",deliveryStoreDistributionDatasets);
            deliveryStoreDistributionMainData.put("labels",deliveryStoreDistributionLabels);

            deliveryStoreDistribution.put("data",deliveryStoreDistributionMainData);

            deliveryStoreDistribution.put("options",deliveryStoreDistributionOptions);
        }catch(Exception e){

        }
         return deliveryStoreDistribution;
    }
    JSONObject getFunnelChartData(Contexte Etn,String siteId, String startTime, String endTime,String catalogType){
        JSONObject funnelConfig = new JSONObject();
        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");

            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            String whereClause;
            JSONArray funnelCounts = new JSONArray();
            JSONArray funnelBackgroundColor = new JSONArray();
            JSONArray funnelHoverBackgroundColor = new JSONArray();
            JSONArray funnelLabels = new JSONArray();
            Set rsFunnelUrls = Etn.execute("select GROUP_CONCAT(url), color, label,GROUP_CONCAT(table_name) from dashboard_urls where url_group = 'funnel' and site_id="+escape.cote(siteId)+" group by url_type order by sort_order ;");
            
            while(rsFunnelUrls.next()){

                JSONObject tablesComapreTypes = new JSONObject();
                
                whereClause = "";
                String[] urls = rsFunnelUrls.value(0).split(",");
                String[] tableNames = rsFunnelUrls.value(3).split(",");

                for(int i=0; i<tableNames.length; i++){

                    if(tablesComapreTypes.has(tableNames[i])){
                        String compareTypeQuery = tablesComapreTypes.get(tableNames[i])+ " OR page_c= "+escape.cote(urls[i]);
                        tablesComapreTypes.put(tableNames[i],compareTypeQuery);
                    }else{
                        tablesComapreTypes.put(tableNames[i]," page_c= "+escape.cote(urls[i]));
                    }
                }

                String filterWhere="";
                String filterJoin="";
                if(!catalogType.equalsIgnoreCase("all")){
                    filterJoin = " left join dashboard_filters_items slf on slf.filter_type= cs.eletype and slf.filter_on=cs.eleid ";
                    filterWhere = " and slf.filter_id="+escape.cote(catalogType);
                }

                String query="select distinct session_j from (";
                String unionQuery="";
                for(int i = 0; i<tablesComapreTypes.names().length(); i++){
                    
                    String tbl_name=tablesComapreTypes.names().getString(i);
                    String conditionVal=tablesComapreTypes.getString(tablesComapreTypes.names().getString(i));

                    if(unionQuery.length()>0){
                        unionQuery+=" UNION ";
                    }
                    unionQuery+="select distinct session_j from "+tbl_name+" cs "+filterJoin+" where cs.site_id="+escape.cote(siteId)+filterWhere+" and (date_l between "+escape.cote(startTime+"000000")+" and "+
                        escape.cote(endTime+"235959")+") and ("+conditionVal+")";
                }
                
                query+=unionQuery+") as abc";

                Set rsFunnelStep = Etn.execute(query);
                funnelCounts.put(rsFunnelStep.rs.Rows);
                funnelBackgroundColor.put(rsFunnelUrls.value("color"));
                funnelHoverBackgroundColor.put(rsFunnelUrls.value("color"));
                funnelLabels.put(rsFunnelUrls.value("label"));
            }

            String template = "";
            funnelConfig.put("type","funnel");

            JSONObject funnelMainData = new JSONObject();
            JSONObject funnelTempObj = new JSONObject();

            funnelTempObj.put("data", funnelCounts);
            funnelTempObj.put("backgroundColor", funnelBackgroundColor);
            funnelTempObj.put("hoverBackgroundColor", funnelHoverBackgroundColor);

            JSONArray funnelDatasets = new JSONArray();
            funnelDatasets.put(funnelTempObj);
            funnelMainData.put("datasets",funnelDatasets);
            funnelMainData.put("labels",funnelLabels);

            funnelConfig.put("data",funnelMainData);

            JSONObject funnelOptions = new JSONObject("{\"responsive\": false,\"sort\": \"desc\",\"legend\": {\"display\":true,\"position\": \"top\"},\"title\": {\"display\": false"
                    + ",\"text\": \"Order funnel\"},\"animation\": {\"animateScale\": true,\"animateRotate\": true}}");
            funnelConfig.put("options",funnelOptions);
        }catch(Exception e){
        }
        return funnelConfig;
    }

    JSONObject getOrdersAndProductsChartData(Contexte Etn, String siteId ,String startTime, String endTime , Locale requestLocal,String catalogType ){
        JSONObject mainChart = new JSONObject();

        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject mainChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: true},scales: {xAxes: [{gridLines: {drawOnChartArea: false}}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4,hoverBorderWidth: 3}}}");

            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat excelDateFormat = new SimpleDateFormat("EEE., d MMMM yyyy", Locale.US);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);

            String keyColumn = "";
            Map<String, Object> lastDaysMap = new LinkedHashMap<String, Object>();
            JSONArray lastDays = new JSONArray();
            JSONArray excelLabels = new JSONArray();

            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<60){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    excelLabels.put(excelDateFormat.format(start.getTime()));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<1000){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth;
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, requestLocal));
                    String month = start.getDisplayName(Calendar.MONTH, Calendar.LONG, Locale.US);
                    excelLabels.put(month+" "+start.get(Calendar.YEAR));

                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    String key = start.get(Calendar.YEAR)+"";
                    lastDaysMap.put(key, 0);
                    lastDays.put(key);
                    excelLabels.put(start.get(Calendar.YEAR));
                    start.add(Calendar.YEAR, 1);
                }
            }

            mainChart.put("type","line");

            JSONObject mainChartMainData = new JSONObject();
            mainChartMainData.put("labels",lastDays);
            mainChart.put("options",mainChartOptions);
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";

            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}
            String qry="";
            Set rsOrdersPerDay = Etn.execute(qry="select "+keyColumn+", count(distinct o.id) from orders o inner join post_work pw on o.id=pw.client_key"
                    + " where (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+" "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+" group by 1 order by creationDate desc;");
            while(rsOrdersPerDay.next()){
                lastDaysMap.put(rsOrdersPerDay.value(0), parseNullInt(rsOrdersPerDay.value(1)));
            }

            JSONArray ordersPerDay = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                ordersPerDay.put(parseNullInt(value));
                lastDaysMap.put(key, 0);
            }

            Set rsQuantityPerDay = Etn.execute("select "+keyColumn+", sum(oi.quantity) from orders o inner join order_items oi on o.parent_uuid = oi.parent_id"
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and o.id in (select client_key from post_work pw where pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+") "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+" group by 1 order by creationDate desc;");
            while(rsQuantityPerDay.next()){
                lastDaysMap.put(rsQuantityPerDay.value(0), parseNullInt(rsQuantityPerDay.value(1)));
            }

            JSONArray quantityPerDay = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                quantityPerDay.put(parseNullInt(value));
            }

            mainChartMainData.put("datasets",new JSONArray("[{label: \"Orders\",borderColor: '#4dbd74',backgroundColor: '#4dbd74', fill: false ,pointHoverBackgroundColor: '#fff',borderWidth: 2,data: "+ordersPerDay.toString()+"},{label: \"Products\",backgroundColor: 'red', fill: false,borderColor: 'red',pointHoverBackgroundColor: '#fff',borderWidth: 2,data: "+quantityPerDay.toString()+"}]"));
            mainChart.put("data",mainChartMainData);
            mainChart.put("excelLabels",excelLabels);
        }catch(Exception e){}
        return mainChart;
    }
    
    JSONObject getOrdersChartSmallData(Contexte Etn,String siteId, String label, String graphType, String startTime, String endTime , Locale requestLocal,String catalogType){
        JSONObject ordersChart = new JSONObject();
        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject genericChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: false},scales: {xAxes: [{gridLines: {color: 'transparent',zeroLineColor: 'transparent',},ticks: {fontSize: 2,fontColor: 'transparent',},}],yAxes: [{display: false}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4}}}");

            label = parseNull(label);
            graphType = parseNull(graphType);
            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);

            String keyColumn = "";
            Map<String, Object> lastDaysMap = new LinkedHashMap<String, Object>();
            
            JSONArray lastDays = new JSONArray();
            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<15){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<500){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth;
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, requestLocal));
                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    String key = start.get(Calendar.YEAR)+"";
                    lastDaysMap.put(key, 0);
                    lastDays.put(key);
                    start.add(Calendar.YEAR, 1);
                }
            }

            ordersChart.put("type",graphType);
            ordersChart.put("options",genericChartOptions);
            JSONObject ordersChartMainData = new JSONObject();
            ordersChartMainData.put("labels",lastDays);
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";

            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            Set rsOrders = Etn.execute("select "+keyColumn+", count(distinct o.id) from orders o inner join post_work pw on o.id=pw.client_key"
                + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+
                escape.cote(endTime+"235959")+") and pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+" "+
                (cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+
                " group by 1 order by o.creationDate desc;");
            int total = 0;
            while(rsOrders.next()){
                total += parseNullInt(rsOrders.value(1));
                lastDaysMap.put(rsOrders.value(0), parseNullInt(rsOrders.value(1)));
            }

            JSONArray orders = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                orders.put(parseNullInt(value));
            }
            ordersChartMainData.put("datasets",new JSONArray("[{label: \"Orders\",borderColor: \"rgba(255,255,255,.55)\",data: "+orders.toString()+"}]"));
            ordersChart.put("data",ordersChartMainData);
            ordersChart.put("total",total);
            ordersChart.put("label",label);
        }catch(Exception e){}
        return ordersChart;
    }
    JSONObject getProductsPerOrderChartSmallData(Contexte Etn,String siteId,String label, String graphType, String startTime, String endTime , Locale requestLocal,String catalogType){
        JSONObject productsPerOrderChart = new JSONObject();

        try{

            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject genericChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: false},scales: {xAxes: [{gridLines: {color: 'transparent',zeroLineColor: 'transparent',},ticks: {fontSize: 2,fontColor: 'transparent',},}],yAxes: [{display: false}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4}}}");

            label = parseNull(label);
            graphType = parseNull(graphType);
            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);

            String keyColumn = "";
            Map<String, Object> lastDaysMap = new LinkedHashMap<String, Object>();
            
            JSONArray lastDays = new JSONArray();
            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<15){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<500){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth;
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, requestLocal));
                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    String key = start.get(Calendar.YEAR)+"";
                    lastDaysMap.put(key, 0);
                    lastDays.put(key);
                    start.add(Calendar.YEAR, 1);
                }
            }

            productsPerOrderChart.put("type",graphType);
            productsPerOrderChart.put("options",genericChartOptions);
            JSONObject productsPerOrderChartMainData = new JSONObject();
            productsPerOrderChartMainData.put("labels",lastDays);
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";
            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            Set rsOrders = Etn.execute("select "+keyColumn+", count(distinct o.id) from orders o inner join post_work pw on o.id=pw.client_key"
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+" "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+" group by 1 order by creationDate desc;");
            while(rsOrders.next()){
                lastDaysMap.put(rsOrders.value(0), parseNullInt(rsOrders.value(1)));
            }

            JSONArray orders = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                orders.put(parseNullInt(value));
                lastDaysMap.put(key, 0);
            }

            Set rsQuantity = Etn.execute("select "+keyColumn+", sum(oi.quantity) from orders o inner join order_items oi on o.parent_uuid = oi.parent_id"
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and o.id in (select client_key from post_work pw where pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+") "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+" group by 1 order by creationDate desc;");
            while(rsQuantity.next()){
                lastDaysMap.put(rsQuantity.value(0), parseNullInt(rsQuantity.value(1)));
            }

            JSONArray quantity = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                quantity.put(parseNullInt(value));
            }

            double totalQuantity = 0;
            double totalOrders = 0;
            JSONArray productsPerOrder = new JSONArray();
            for(int i=0; i<orders.length(); i++){
                totalQuantity+=quantity.optDouble(i);
                totalOrders+=orders.optDouble(i);
                productsPerOrder.put(Math.round(quantity.optDouble(i)/orders.optDouble(i)*100)/100.0);
            }

            productsPerOrderChartMainData.put("datasets",new JSONArray("[{label: \"Products\",borderColor: \"rgba(255,255,255,.55)\",data: "+productsPerOrder.toString()+"}]"));
            productsPerOrderChart.put("data",productsPerOrderChartMainData);
            productsPerOrderChart.put("total",Math.round(totalQuantity/totalOrders*100)/100.0);
            productsPerOrderChart.put("label",label);
        }catch(Exception e){}
        return productsPerOrderChart;
    }
    JSONObject getPromotionDistributionChartData(Contexte Etn,String siteId, String startTime, String endTime,String catalogType){
        JSONObject promotionDistribution = new JSONObject();

        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject promotionDistributionOptions = new JSONObject("{\"responsive\": true,\"sort\": \"desc\",\"legend\": {\"display\":true,\"position\": \"top\"},\"animation\": {\"animateScale\": true,\"animateRotate\": true}}");

            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            promotionDistribution.put("type","doughnut");
            JSONArray promotionDistributionCounts = new JSONArray();
            JSONArray promotionDistributionLabels = new JSONArray();
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";

            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            String query;
            Set rsPromotionDistributionCounts = Etn.execute(query = "SELECT case when oi.price_value=oi.price_old_value then 'No Promotion' else 'Promotion' end, sum(oi.quantity)"
                + " FROM orders o inner join order_items oi on o.parent_uuid = oi.parent_id"
                + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and o.id in (select client_key from post_work pw where pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+") "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")
                + " group by 1 order by 1 desc ;"); // so that promotions come on top

            while(rsPromotionDistributionCounts.next()){
                promotionDistributionCounts.put(parseNullInt(rsPromotionDistributionCounts.value(1)));
                promotionDistributionLabels.put(rsPromotionDistributionCounts.value(0));
            }

            JSONObject promotionDistributionMainData = new JSONObject();
            JSONObject promotionDistributionTempObj = new JSONObject();
            promotionDistributionTempObj.put("data", promotionDistributionCounts);
            promotionDistributionTempObj.put("backgroundColor", new JSONArray("[\"#FF6384\", \"#36A2EB\"]"));
            promotionDistributionTempObj.put("hoverBackgroundColor", new JSONArray("[\"#FF6384\", \"#36A2EB\"]"));
            JSONArray promotionDistributionDatasets = new JSONArray();
            promotionDistributionDatasets.put(promotionDistributionTempObj);
            promotionDistributionMainData.put("datasets",promotionDistributionDatasets);
            promotionDistributionMainData.put("labels",promotionDistributionLabels);

            promotionDistribution.put("data",promotionDistributionMainData);

            promotionDistribution.put("options",promotionDistributionOptions);
        }catch(Exception e){}
        return promotionDistribution;
    }

    JSONObject getQuantityChartSmallData(Contexte Etn,String siteId, String label, String graphType, String startTime, String endTime , Locale requestLocal,String catalogType){
        JSONObject quantityChart = new JSONObject();

        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject genericChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: false},scales: {xAxes: [{gridLines: {color: 'transparent',zeroLineColor: 'transparent',},ticks: {fontSize: 2,fontColor: 'transparent',},}],yAxes: [{display: false}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4}}}");

            label = parseNull(label);
            graphType = parseNull(graphType);
            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);

            String keyColumn = "";
            Map<String, Object> lastDaysMap = new LinkedHashMap<String, Object>();
            
            JSONArray lastDays = new JSONArray();
            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<15){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<500){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth;
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG,requestLocal));
                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    String key = start.get(Calendar.YEAR)+"";
                    lastDaysMap.put(key, 0);
                    lastDays.put(key);
                    start.add(Calendar.YEAR, 1);
                }
            }

            quantityChart.put("type",graphType);
            quantityChart.put("options",genericChartOptions);
            JSONObject quantityChartMainData = new JSONObject();
            quantityChartMainData.put("labels",lastDays);
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";
            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            Set rsQuantity = Etn.execute("select "+keyColumn+", sum(oi.quantity) from orders o inner join order_items oi on o.parent_uuid = oi.parent_id"
                + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+
                escape.cote(endTime+"235959")+") and o.id in (select client_key from post_work pw where pw.proces="+escape.cote(_startProc)+
                " and pw.phase="+escape.cote(_startPhase)+") "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+
                cancelPhaseWhereClause+" )":"")+" group by 1 order by creationDate desc;");
            
            int total = 0;
            while(rsQuantity.next()){
                total += parseNullInt(rsQuantity.value(1));
                lastDaysMap.put(rsQuantity.value(0), parseNullInt(rsQuantity.value(1)));
            }

            JSONArray quantity = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                quantity.put(parseNullInt(value));
                //lastMonthsMap.put(key, 0);
            }
            quantityChartMainData.put("datasets",new JSONArray("[{label: \"Products\",borderColor: \"rgba(255,255,255,.55)\",data: "+quantity.toString()+"}]"));
            quantityChart.put("data",quantityChartMainData);
            quantityChart.put("total",total);
            quantityChart.put("label",label);
        }catch(Exception e){}
        return  quantityChart;
    }
    JSONObject getRevenueChartData(Contexte Etn,String siteId, String startTime, String endTime ,Locale requestLocal,String catalogType){
        JSONObject revenueChartPerDay = new JSONObject();
        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject mainChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: true},scales: {xAxes: [{gridLines: {drawOnChartArea: false}}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4,hoverBorderWidth: 3}}}");

            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat excelDateFormat = new SimpleDateFormat("EEE., d MMMM yyyy", Locale.US);
            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");

            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);

            String keyColumn = "";
            Map<String, Object> lastDaysMap = new LinkedHashMap<String, Object>();
            JSONArray lastDays = new JSONArray();
            JSONArray excelLabels = new JSONArray();

            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<60){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT,requestLocal));
                    excelLabels.put(excelDateFormat.format(start.getTime()));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<1000){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth;
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, requestLocal));
                    String month = start.getDisplayName(Calendar.MONTH, Calendar.LONG, Locale.ENGLISH);
                    excelLabels.put(month+" "+start.get(Calendar.YEAR));

                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    String key = start.get(Calendar.YEAR)+"";
                    lastDaysMap.put(key, 0);
                    lastDays.put(key);
                    excelLabels.put(start.get(Calendar.YEAR));
                    start.add(Calendar.YEAR, 1);
                }
            }

            revenueChartPerDay.put("type","line");
            revenueChartPerDay.put("options",mainChartOptions);
            JSONObject revenueChartPerDayMainData = new JSONObject();
            revenueChartPerDayMainData.put("labels",lastDays);
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";

            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            Set rsRevenuePerDay = Etn.execute("select "+keyColumn+", sum(o.total_price), currency from orders o "
                + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+
                escape.cote(endTime+"235959")+") and o.id in (select client_key from post_work pw where pw.proces="+escape.cote(_startProc)+
                " and pw.phase="+escape.cote(_startPhase)+") "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+" group by 1 order by o.creationDate desc;");

            String currency = "";
            while(rsRevenuePerDay.next()){
                if(currency.length()==0) currency = rsRevenuePerDay.value("currency");
                lastDaysMap.put(rsRevenuePerDay.value(0), parseNullDouble(rsRevenuePerDay.value(1)));
            }

            JSONArray revenuePerDay = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                revenuePerDay.put(parseNullDouble(value));
                lastDaysMap.put(key, 0);
            }

            revenueChartPerDayMainData.put("datasets",new JSONArray("[{label: \"Revenue\",borderColor: '#4dbd74',backgroundColor: '#4dbd74', fill: false,pointHoverBackgroundColor: '#fff',borderWidth: 2,data: "+revenuePerDay.toString()+"}]"));
            revenueChartPerDay.put("data",revenueChartPerDayMainData);
            revenueChartPerDay.put("subtext","in "+currency);
            revenueChartPerDay.put("currency",currency);
            revenueChartPerDay.put("excelLabels",excelLabels);

        }catch(Exception e){}
        return revenueChartPerDay;
    }
    JSONObject getRevenueChartSmallData(Contexte Etn,String siteId,String label, String graphType, String startTime, String endTime , Locale requestLocal,String catalogType){
        JSONObject revenueChart = new JSONObject();
        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject genericChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: false},scales: {xAxes: [{gridLines: {color: 'transparent',zeroLineColor: 'transparent',},ticks: {fontSize: 2,fontColor: 'transparent',},}],yAxes: [{display: false}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4}}}");

            label = parseNull(label);
            graphType = parseNull(graphType);
            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);

            String keyColumn = "";
            Map<String, Object> lastDaysMap = new LinkedHashMap<String, Object>();
            
            JSONArray lastDays = new JSONArray();
            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<15){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<500){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth;
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, requestLocal));
                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    String key = start.get(Calendar.YEAR)+"";
                    lastDaysMap.put(key, 0);
                    lastDays.put(key);
                    start.add(Calendar.YEAR, 1);
                }
            }

            revenueChart.put("type",graphType);
            revenueChart.put("options",genericChartOptions);

            JSONObject revenueChartMainData = new JSONObject();
            revenueChartMainData.put("labels",lastDays);
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";
            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            Set rsRevenue = Etn.execute("select "+keyColumn+", sum(o.total_price), currency from orders o "
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and o.id in (select client_key from post_work pw where pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+") "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+" group by 1 order by creationDate desc;");

			double total = 0;
            String currency = "";
            while(rsRevenue.next()){
                if(currency.length()==0) currency = rsRevenue.value("currency");
                total += parseNullDouble(rsRevenue.value(1));
                lastDaysMap.put(rsRevenue.value(0), parseNullDouble(rsRevenue.value(1)));
            }

            JSONArray revenuePerDay = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                revenuePerDay.put(parseNullDouble(value));
                lastDaysMap.put(key, 0);
            }

            revenueChartMainData.put("datasets",new JSONArray("[{label: \"Revenue\",borderColor: \"rgba(255,255,255,.55)\",data: "+revenuePerDay.toString()+"}]"));
            revenueChart.put("data",revenueChartMainData);
            revenueChart.put("total",total);
            revenueChart.put("currency",currency);
            revenueChart.put("label",label.replaceAll("<currency>",currency));
        }catch(Exception e){}
        return revenueChart;
    }
    JSONArray getTopAgentsChartData( Contexte Etn,String siteId, String startTime, String endTime,String catalogType){
        JSONArray topAgents = new JSONArray();
        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");


            startTime = parseNull(startTime);
            endTime = parseNull(endTime);


            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";
            }
            Set rsTopAgents = Etn.execute("select p.First_name, p.last_name, count(distinct pw.client_key) as sales from orders o inner join post_work pw on o.id=pw.client_key inner join login l on pw.operador = l.name inner join person p on l.pid = p.person_id where o.site_id="+escape.cote(siteId)
                    + " and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and pw.nextid IN ( select id from post_work where phase = 'ColisRemis') "+(cancelPhaseWhereClause.length()>0?" and pw.client_key not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+"  group by operador order by count(operador) desc");
            int maxSales = 0;
            while(rsTopAgents.next()){
                int numSales = parseNullInt(rsTopAgents.value(2));
                if(maxSales == 0) maxSales = numSales;
                JSONObject topAgent = new JSONObject();
                topAgent.put("name", rsTopAgents.value(0)+" "+rsTopAgents.value(1));
                topAgent.put("quantity", rsTopAgents.value(2));
                topAgent.put("width", numSales*100/maxSales);
                topAgents.put(topAgent);
            }
        }catch(Exception e){}
        return topAgents;
    }
    JSONArray getTopSellersChartData(Contexte Etn,String siteId, String startTime, String endTime,String catalogType){
        JSONArray topSellers = new JSONArray();
        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");


            startTime = parseNull(startTime);
            endTime = parseNull(endTime);


            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";
            }

			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            Set rsTopSellers = Etn.execute("select sum(oi.quantity), TRIM(BOTH '\"' FROM (json_extract(oi.product_snapshot, '$.variantName'))) as name from orders o inner join order_items oi on o.parent_uuid = oi.parent_id "
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and o.id in (select client_key from post_work pw where pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+") "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+" group by json_extract(oi.product_snapshot, '$.sku') order by 1 desc  ");

            int maxSales = 0;
            while(rsTopSellers.next()){
                int numSales = parseNullInt(rsTopSellers.value(0));
                if(maxSales == 0) maxSales = numSales;
                JSONObject topSeller = new JSONObject();
                topSeller.put("name", rsTopSellers.value(1));
                topSeller.put("quantity", rsTopSellers.value(0));
                topSeller.put("width", numSales*100/maxSales);
                topSellers.put(topSeller);
            }
        }catch(Exception e){}
        return topSellers;
    }
    JSONObject getTransformationRateChartSmallData(Contexte Etn,String siteId, String label, String graphType, String startTime, String endTime , Locale requestLocal,String catalogType){
        JSONObject transformationRateChart = new JSONObject();
        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject genericChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: false},scales: {xAxes: [{gridLines: {color: 'transparent',zeroLineColor: 'transparent',},ticks: {fontSize: 2,fontColor: 'transparent',},}],yAxes: [{display: false}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4}}}");

            String whereClause = "";

            label = parseNull(label);
            graphType = parseNull(graphType);
            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);

            String keyColumn = "";
            Map<String, Object> lastDaysMap = new LinkedHashMap<String, Object>();
            Map<String, Integer> lastDaysIndexesMap = new LinkedHashMap<String, Integer>();
            
            JSONArray lastDays = new JSONArray();
            int rowCount = 0;
            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<15){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
                    lastDaysMap.put(key, 0);
                    lastDaysIndexesMap.put(key, rowCount);
                    rowCount++;
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<500){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth;
                    lastDaysMap.put(key, 0);
                    lastDaysIndexesMap.put(key, rowCount);
                    rowCount++;
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, requestLocal));
                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    String key = start.get(Calendar.YEAR)+"";
                    lastDaysMap.put(key, 0);
                    lastDaysIndexesMap.put(key, rowCount);
                    rowCount++;
                    lastDays.put(key);
                    start.add(Calendar.YEAR, 1);
                }
            }

            transformationRateChart.put("type",graphType);
            transformationRateChart.put("options",genericChartOptions);
            JSONObject transformationRateChartMainData = new JSONObject();
            transformationRateChartMainData.put("labels",lastDays);
            String cancelPhaseWhereClause = "";
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw2.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw2.phase="+escape.cote(rsCancelPhases.value("phase"))+")";

            }


			String _startPhase = "";
			String _startProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				_startPhase = parseNull(rsDC.value("phase"));
				_startProc = parseNull(rsDC.value("process"));
			}

            Set rsOrders = Etn.execute("select "+keyColumn+", count(distinct o.id) from orders o inner join post_work pw on o.id=pw.client_key"
                    + " where o.site_id="+escape.cote(siteId)+" and (o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and pw.proces="+escape.cote(_startProc)+" and pw.phase="+escape.cote(_startPhase)+" "+(cancelPhaseWhereClause.length()>0?" and o.id not in (select client_key from post_work pw2 where "+cancelPhaseWhereClause+" )":"")+" group by 1 order by o.creationDate desc;");
            while(rsOrders.next()){
                lastDaysMap.put(rsOrders.value(0), parseNullInt(rsOrders.value(1)));
            }

            JSONArray orders = new JSONArray();
            int totalOrders = 0;
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                orders.put(parseNullInt(value));
                totalOrders += parseNullInt(value);
                lastDaysMap.put(key, 0);
            }

            Set rsEshopVisitUrls = Etn.execute("select url,table_name from dashboard_urls where url_type='eshop_visits' and site_id="+escape.cote(siteId));
            
            JSONObject tablesComapreTypes = new JSONObject();
            while(rsEshopVisitUrls.next()){
                String tbl_name = parseNull(rsEshopVisitUrls.value("table_name"));
                String url = parseNull(rsEshopVisitUrls.value("url"));

                if(tablesComapreTypes.has(tbl_name)){
                    String compareTypeQuery = tablesComapreTypes.getString(tbl_name)+ " OR page_c= "+escape.cote(url);
                    tablesComapreTypes.put(tbl_name,compareTypeQuery);
                }else{
                    tablesComapreTypes.put(tbl_name," page_c= "+escape.cote(url));
                }
            }

            String filterWhere="";
            String filterJoin="";
            if(!catalogType.equalsIgnoreCase("all")){
                filterJoin = " left join dashboard_filters_items slf on slf.filter_type= cs.eletype and slf.filter_on=cs.eleid ";
                filterWhere = " and slf.filter_id="+escape.cote(catalogType);
            }

            String query="select "+keyColumn.replace("o.creationDate","date_l")+", count(distinct session_j) from (";
            String unionQuery="";
            for(int i = 0; i<tablesComapreTypes.names().length(); i++){
                
                String tbl_name=tablesComapreTypes.names().getString(i);
                String conditionVal=tablesComapreTypes.getString(tablesComapreTypes.names().getString(i));

                if(unionQuery.length()>0){
                    unionQuery+=" UNION ";
                }
                unionQuery+="select distinct session_j,date_l from "+tbl_name+" cs "+filterJoin+" where cs.site_id="+escape.cote(siteId)+filterWhere+" and (date_l between "+
                    escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+") and ("+conditionVal+")";
            }
            
            query+=unionQuery+") as abc group by "+keyColumn.replace("o.creationDate","date_l");
            
            Set rsEshopVisits = Etn.execute(query);
            int totalSessionJ = 0;
            while(rsEshopVisits.next()){
                totalSessionJ+=parseNullInt(rsEshopVisits.value(1));
                lastDaysMap.put(rsEshopVisits.value(0), Math.round(orders.optInt(parseNullInt(lastDaysIndexesMap.get(rsEshopVisits.value(0))))*100/parseNullDouble(rsEshopVisits.value(1))*100)/100.0);
            }

            JSONArray transformationRate = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                transformationRate.put(parseNullDouble(value));
            }
            transformationRateChartMainData.put("datasets",new JSONArray("[{label: \"Transformation Rate\",borderColor: \"rgba(255,255,255,.55)\",data: "+transformationRate.toString()+"}]"));
            transformationRateChart.put("data",transformationRateChartMainData);
            
            transformationRateChart.put("total",(totalSessionJ==0?0:(Math.round((parseNullDouble(totalOrders)*100/parseNullDouble(totalSessionJ))*100)/100.0))+" "+"%");
            transformationRateChart.put("label",label);
        }catch(Exception e){}
        return  transformationRateChart;
    }
    JSONObject getVisitorsChartSmallData(Contexte Etn,String siteId, String label, String graphType, String startTime, String endTime , Locale requestLocal, String catalogType){
        JSONObject visitorsChart = new JSONObject();
        try{
            String portaldb = com.etn.beans.app.GlobalParm.getParm("PORTAL_DB");
            String catalogdb = com.etn.beans.app.GlobalParm.getParm("CATALOG_DB");
            JSONObject genericChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: false},scales: {xAxes: [{gridLines: {color: 'transparent',zeroLineColor: 'transparent',},ticks: {fontSize: 2,fontColor: 'transparent',},}],yAxes: [{display: false}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4}}}");

            String whereClause = "";

            label = parseNull(label);
            graphType = parseNull(graphType);
            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);

            String keyColumn = "";
            Map<String, Object> lastDaysMap = new LinkedHashMap<String, Object>();
            
            JSONArray lastDays = new JSONArray();
            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<15){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth+"-"+start.get(Calendar.DAY_OF_MONTH);
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<500){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    int tempMonth = start.get(Calendar.MONTH)+1; // because January is 0 in Calendar while in mysql January is 1
                    String key = start.get(Calendar.YEAR)+"-"+tempMonth;
                    lastDaysMap.put(key, 0);
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, requestLocal));
                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    String key = start.get(Calendar.YEAR)+"";
                    lastDaysMap.put(key, 0);
                    lastDays.put(key);
                    start.add(Calendar.YEAR, 1);
                }
            }

            visitorsChart.put("type",graphType);
            visitorsChart.put("options",genericChartOptions);
            JSONObject visitorsChartMainData = new JSONObject();
            visitorsChartMainData.put("labels",lastDays);

            Set rsEshopVisitUrls = Etn.execute("select url,table_name from dashboard_urls where url_type='eshop_visits' and site_id="+escape.cote(siteId));
            
            JSONObject tablesComapreTypes = new JSONObject();
            while(rsEshopVisitUrls.next()){
                String tbl_name = parseNull(rsEshopVisitUrls.value("table_name"));
                String url = parseNull(rsEshopVisitUrls.value("url"));

                if(tablesComapreTypes.has(tbl_name)){
                    String compareTypeQuery = tablesComapreTypes.getString(tbl_name)+ " OR page_c= "+escape.cote(url);
                    tablesComapreTypes.put(tbl_name,compareTypeQuery);
                }else{
                    tablesComapreTypes.put(tbl_name," page_c= "+escape.cote(url));
                }
            }

            String filterWhere="";
            String filterJoin="";
            if(!catalogType.equalsIgnoreCase("all")){
                filterJoin = " left join dashboard_filters_items slf on slf.filter_type= cs.eletype and slf.filter_on=cs.eleid ";
                filterWhere = " and slf.filter_id="+escape.cote(catalogType);
            }
            String query="select "+keyColumn.replace("o.creationDate","date_l")+", count(distinct session_j) from (";
            String unionQuery="";
            for(int i = 0; i<tablesComapreTypes.names().length(); i++){
                
                String tbl_name=tablesComapreTypes.names().getString(i);
                String conditionVal=tablesComapreTypes.getString(tablesComapreTypes.names().getString(i));

                if(unionQuery.length()>0){
                    unionQuery+=" UNION ";
                }
                unionQuery+="select distinct session_j,date_l from "+tbl_name+" cs "+filterJoin+" where cs.site_id="+escape.cote(siteId)+filterWhere+" and (date_l between "+escape.cote(startTime+"000000")+" and "+
                    escape.cote(endTime+"235959")+") and ("+conditionVal+")";
            }
            
            query+=unionQuery+") as abc group by "+keyColumn.replace("o.creationDate","date_l");
            
            Set rsEshopVisits = Etn.execute(query);
            int totalSessionJ =0;
            while(rsEshopVisits.next()){
                totalSessionJ+= parseNullInt(rsEshopVisits.value(1));
                lastDaysMap.put(rsEshopVisits.value(0), parseNullInt(rsEshopVisits.value(1)));
            }

            JSONArray visitors = new JSONArray();
            for (Map.Entry<String, Object> entry : lastDaysMap.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                visitors.put(parseNullDouble(value));
            }
            visitorsChartMainData.put("datasets",new JSONArray("[{label: \"Visitors\",borderColor: \"rgba(255,255,255,.55)\",data: "+visitors.toString()+"}]"));
            visitorsChart.put("data",visitorsChartMainData);

            visitorsChart.put("total",totalSessionJ);
            visitorsChart.put("label",label);
        }catch(Exception e){}
        return visitorsChart;
    }

    private static String formatDateWithoutLeadingZeros(Calendar calendar,String type) {
        int year = calendar.get(Calendar.YEAR);
        int month = calendar.get(Calendar.MONTH) + 1;
        int dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH);

        if(type.equals("day")){
            return String.format(Locale.ENGLISH, "%d-%d-%d", year, month, dayOfMonth);
        }else if(type.equals("month")){
            return String.format(Locale.ENGLISH, "%d-%d", year, month);
        }else{
            return String.format(Locale.ENGLISH, "%d", year);
        }

    }

    private String getDecimalTimeInHour(double decimalHours ){
        int hours = (int) decimalHours;
        int minutes = (int) ((decimalHours - hours) * 60);
        return hours + "H" + minutes;
        
    }

    JSONObject getAverageTimeForOrderTreatmentChartSmallData(Contexte Etn,String siteId, String label, String graphType, String startTime, String endTime , Locale requestLocal,String catalogType){
        JSONObject averageOrderTreatmentChart = new JSONObject();
        try{

            JSONObject genericChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: false},scales: {xAxes: [{gridLines: {color: 'transparent',zeroLineColor: 'transparent',},ticks: {fontSize: 2,fontColor: 'transparent',},}],yAxes: [{display: false}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4}}}");

            label = parseNull(label);
            graphType = parseNull(graphType);
            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);


            String keyColumn = "";
            
            JSONArray lastDays = new JSONArray();
            JSONArray daysArray = new JSONArray();

            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<15){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    daysArray.put(formatDateWithoutLeadingZeros(start,"day"));
                    
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<500){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    daysArray.put(formatDateWithoutLeadingZeros(start,"month"));
                    
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, requestLocal));
                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    daysArray.put(formatDateWithoutLeadingZeros(start,"year"));

                    lastDays.put(start.get(Calendar.YEAR)+"");
                    start.add(Calendar.YEAR, 1);
                }
            }

            averageOrderTreatmentChart.put("type",graphType);
            averageOrderTreatmentChart.put("options",genericChartOptions);
            JSONObject averageOrderTreatmentChartMainData = new JSONObject();
            averageOrderTreatmentChartMainData.put("labels",lastDays);
            
			String recievedPhase = "";
			String recievedProc = "";
			String confirmedPhase = "";
			String confirmedProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-received' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				recievedPhase = parseNull(rsDC.value("phase"));
				recievedProc = parseNull(rsDC.value("process"));
			}
			rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-confirmed' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				confirmedPhase = parseNull(rsDC.value("phase"));
				confirmedProc = parseNull(rsDC.value("process"));
			}
			
            String temp ="SELECT "+keyColumn+" AS month_year,AVG(TIME_TO_SEC(TIMEDIFF("+
            "(SELECT MAX(insertion_date) FROM post_work pw1 WHERE pw1.client_key = o.id AND pw1.phase = "+escape.cote(confirmedPhase)+" and pw1.proces="+
            escape.cote(confirmedProc)+" AND pw1.insertion_date >= o.creationDate),"+
            "(SELECT MAX(insertion_date) FROM post_work pw2 WHERE pw2.client_key = o.id AND pw2.phase = "+escape.cote(recievedPhase)+" and pw2.proces="+
            escape.cote(recievedProc)+" AND pw2.insertion_date >= o.creationDate)"+
            "))) / 3600 AS avg_treatment_time_hours FROM orders o WHERE EXISTS ( SELECT 1 FROM post_work pw "+
            " WHERE pw.client_key = o.id AND pw.phase IN ("+escape.cote(confirmedPhase)+", "+escape.cote(recievedPhase)+") ) and o.site_id="+escape.cote(siteId)+
            "  and o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+
            " GROUP BY month_year ORDER BY month_year asc";

            LinkedHashMap<String, Double> averageOrderMap = new LinkedHashMap<>();
            JSONArray averageOrder = new JSONArray();
            double avgTime=0;

            Set rsOrders = Etn.execute(temp);
            while(rsOrders.next()){
                double number = parseNullDouble(rsOrders.value("avg_treatment_time_hours"));
                averageOrderMap.put(parseNull(rsOrders.value("month_year")), Math.round(number * 100.0) / 100.0);
                avgTime+=number;
            }

            for(int i =0;i<daysArray.length();i++){
                if(averageOrderMap.containsKey(daysArray.get(i))){
                    averageOrder.put(averageOrderMap.get(daysArray.get(i)));
                }else{
                    averageOrder.put("0H");
                }
            }

            if(avgTime<=0){
                averageOrderTreatmentChart.put("total",0);
            }else{
                averageOrderTreatmentChart.put("total",getDecimalTimeInHour(Math.round((avgTime/rsOrders.rs.Rows) * 100.0) / 100.0));
            }

            averageOrderTreatmentChartMainData.put("datasets",new JSONArray("[{label: \"Average time for order treatment\",borderColor: \"rgba(255,255,255,.55)\",data: "+averageOrder.toString()+"}]"));
            averageOrderTreatmentChart.put("data",averageOrderTreatmentChartMainData);
            averageOrderTreatmentChart.put("label",label+" in hours");
        }catch(Exception e){
            e.printStackTrace();
        }
        return averageOrderTreatmentChart;

    }
    JSONObject getAverageTimeForHomeDeliveryChartSmallData(Contexte Etn,String siteId, String label, String graphType, String startTime, String endTime , Locale requestLocal,String catalogType,String deliveryType){
        JSONObject averageOrderTreatmentChart = new JSONObject();
        try{

            JSONObject genericChartOptions = new JSONObject("{maintainAspectRatio: false,legend: {display: false},scales: {xAxes: [{gridLines: {color: 'transparent',zeroLineColor: 'transparent',},ticks: {fontSize: 2,fontColor: 'transparent',},}],yAxes: [{display: false}]},elements: {point: {radius: 0,hitRadius: 10,hoverRadius: 4}}}");

            label = parseNull(label);
            graphType = parseNull(graphType);
            startTime = parseNull(startTime);
            endTime = parseNull(endTime);

            DateFormat formatter = new SimpleDateFormat("yyyyMMdd");
            Date startDate = formatter.parse(startTime);
            Calendar start = Calendar.getInstance();
            start.setTime(startDate);
            Date endDate = formatter.parse(endTime);
            Calendar end = Calendar.getInstance();
            end.setTime(endDate);


            String keyColumn = "";
            
            JSONArray lastDays = new JSONArray();
            JSONArray daysArray = new JSONArray();
            int numberOfDays = ((int)((endDate.getTime()-startDate.getTime())/(1000*24*60*60)))+1;
            if(numberOfDays<15){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c-%e')";
                while(start.compareTo(end)<1){
                    daysArray.put(formatDateWithoutLeadingZeros(start,"day"));
                    lastDays.put(start.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.SHORT, requestLocal));
                    start.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
            else if(numberOfDays<500){
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y-%c')";
                while(start.get(Calendar.YEAR)<end.get(Calendar.YEAR) || (start.get(Calendar.YEAR)==end.get(Calendar.YEAR) && start.get(Calendar.MONTH)<=end.get(Calendar.MONTH))){
                    daysArray.put(formatDateWithoutLeadingZeros(start,"month"));
                    lastDays.put(start.getDisplayName(Calendar.MONTH, Calendar.LONG, requestLocal));
                    start.add(Calendar.MONTH, 1);
                }
            }
            else{
                keyColumn = "DATE_FORMAT(o.creationDate, '%Y')";
                while(start.get(Calendar.YEAR)<=end.get(Calendar.YEAR)){
                    daysArray.put(formatDateWithoutLeadingZeros(start,"year"));
                    lastDays.put(start.get(Calendar.YEAR)+"");
                    start.add(Calendar.YEAR, 1);
                }
            }

            averageOrderTreatmentChart.put("type",graphType);
            averageOrderTreatmentChart.put("options",genericChartOptions);
            JSONObject averageOrderTreatmentChartMainData = new JSONObject();
            averageOrderTreatmentChartMainData.put("labels",lastDays);
            String cancelPhaseWhereClause = "";
            
            Set rsCancelPhases = Etn.execute("select * from dashboard_phases_config where ctype ='cancel' and site_id="+escape.cote(siteId)); // add site_id check later on here.
            while(rsCancelPhases.next()){
                if(cancelPhaseWhereClause.length()>0) cancelPhaseWhereClause += " or ";
                cancelPhaseWhereClause += " (pw3.proces="+escape.cote(rsCancelPhases.value("process"))+" and pw3.phase="+escape.cote(rsCancelPhases.value("phase"))+")";
            }

			String pickedPhase = "";
			String pickedProc = "";
			String deliveredPhase = "";
			String deliveredProc = "";
			Set rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-picked-for-delivery' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				pickedPhase = parseNull(rsDC.value("phase"));
				pickedProc = parseNull(rsDC.value("process"));
			}
			rsDC = Etn.execute("select * from dashboard_phases_config where ctype ='order-delivered-to-home' and site_id="+escape.cote(siteId)); // add site_id check later on here.
			if(rsDC.next())
			{
				deliveredPhase = parseNull(rsDC.value("phase"));
				deliveredProc = parseNull(rsDC.value("process"));
			}

            String query = "SELECT "+keyColumn+" AS month_year,AVG(TIME_TO_SEC(TIMEDIFF("+
            "(SELECT MAX(insertion_date) FROM post_work pw1 WHERE pw1.client_key = o.id AND pw1.phase = "+escape.cote(deliveredPhase)+" and pw1.proces="+
            escape.cote(deliveredProc)+" AND pw1.insertion_date >= o.creationDate),"+
            "(SELECT MAX(insertion_date) FROM post_work pw2 WHERE pw2.client_key = o.id AND pw2.phase = "+escape.cote(pickedPhase)+" and pw2.proces="+
            escape.cote(pickedProc)+" AND pw2.insertion_date >= o.creationDate)"+
            "))) / 3600 AS avg_treatment_time_hours FROM orders o WHERE EXISTS ( SELECT 1 FROM post_work pw "+
            " WHERE pw.client_key = o.id AND pw.phase IN ("+escape.cote(deliveredPhase)+", "+escape.cote(pickedPhase)+") ) and o.site_id="+escape.cote(siteId)+
            "  and o.creationDate between "+escape.cote(startTime+"000000")+" and "+escape.cote(endTime+"235959")+
            " and o.delivery_type="+escape.cote(deliveryType)+" and o.shipping_method_id ='home_delivery' GROUP BY month_year ORDER BY month_year asc";
            
            Set rsOrders = Etn.execute(query);
            
            LinkedHashMap<String, Double> averageOrderMap = new LinkedHashMap<>();
            JSONArray averageOrder = new JSONArray();
            double avgTime=0;
            while(rsOrders.next()){
                double number = parseNullDouble(rsOrders.value("avg_treatment_time_hours"));
                averageOrderMap.put(parseNull(rsOrders.value("month_year")), Math.round(number * 100.0) / 100.0);
                avgTime+=parseNullDouble(rsOrders.value("avg_treatment_time_hours"));
            }

            for(int i =0;i<daysArray.length();i++){
                if(averageOrderMap.containsKey(daysArray.get(i))){
                    averageOrder.put(averageOrderMap.get(daysArray.get(i)));
                }else{
                    averageOrder.put(0);
                }
            }

            if(avgTime<=0){
                averageOrderTreatmentChart.put("total",0);
            }else{
                averageOrderTreatmentChart.put("total",getDecimalTimeInHour(Math.round((avgTime/rsOrders.rs.Rows) * 100.0) / 100.0));
            }

            String labelTmp = "Average time for home delivery - standard";
            if(deliveryType.contains("express")){
                labelTmp = "Average time for home delivery - express";
            }
            averageOrderTreatmentChartMainData.put("datasets",new JSONArray("[{label: "+escape.cote(labelTmp)+",borderColor: \"rgba(255,255,255,.55)\",data: "+averageOrder.toString()+"}]"));
            averageOrderTreatmentChart.put("data",averageOrderTreatmentChartMainData);
            averageOrderTreatmentChart.put("label",label+" in hours");
        }catch(Exception e){
            e.printStackTrace();
        }
        return averageOrderTreatmentChart;

    }
    
%>
