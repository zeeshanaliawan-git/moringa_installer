
<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@page import="com.etn.lang.ResultSet.Set"%>
<%@page import="com.etn.sql.escape, java.io.*, org.apache.poi.hssf.usermodel.*, org.apache.poi.hssf.util.HSSFColor"%>
<%@page import="java.util.*, java.text.*, java.math.BigDecimal,java.lang.Math, com.etn.beans.app.GlobalParm, org.json.* ,com.etn.asimina.util.FileUtil"%>
<%@ include file="dashboardCommon.jsp" %>
<%@ include file="/common.jsp"%>

<%!
    String extractPostRequestBody(HttpServletRequest request) {
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            java.util.Scanner s = null;
            try {
                s = new java.util.Scanner(request.getInputStream(), "UTF-8").useDelimiter("\\A");
            } catch (Exception e) {
                e.printStackTrace();
            }
            return s.hasNext() ? s.next() : "";
        }
        return "";
    }
    void addRow (HSSFSheet sheet, int rownum, String col1, String col2, HSSFCellStyle style1, HSSFCellStyle style2)
    {
        HSSFRow row = sheet.createRow(rownum);
        row.setHeight((short)300);

        HSSFCell cell = row.createCell(0);
        cell.setCellValue("");

        cell = row.createCell(1);
        cell.setCellValue(col1);
        cell.setCellStyle(style1);

        cell = row.createCell(2);
        cell.setCellValue(col2);
        cell.setCellStyle(style2);
    }
    void addthreeCellRow (HSSFSheet sheet, int rownum, String col1, String col2, String col3, HSSFCellStyle style1, HSSFCellStyle style2)
    {
        HSSFRow row = sheet.createRow(rownum);
        row.setHeight((short)400);

        HSSFCell cell = row.createCell(0);
        cell.setCellValue("");

        cell = row.createCell(1);
        cell.setCellValue(col1);
        cell.setCellStyle(style1);

        cell = row.createCell(2);
        cell.setCellValue(col2);
        cell.setCellStyle(style2);


        cell = row.createCell(3);
        cell.setCellValue(col3);
        cell.setCellStyle(style2);

    }

    void createRow (HSSFSheet sheet, int rownum, String col1, String col2, String col3, String col4, String col5, HSSFCellStyle alignleft, HSSFCellStyle alignright)
    {
        HSSFRow row = sheet.createRow(rownum);
        HSSFCell cell = row.createCell(0);
        cell.setCellValue(col1);
        cell.setCellStyle(alignleft);

        cell = row.createCell(1);
        cell.setCellValue(col2);
        cell.setCellStyle(alignleft);

        cell = row.createCell(2);
        cell.setCellValue(col3);
        cell.setCellStyle(alignright);
        cell = row.createCell(3);
        cell.setCellValue(col4);
        cell.setCellStyle(alignright);

        cell = row.createCell(4);
        cell.setCellValue(col5);
        cell.setCellStyle(alignright);
    }

    void addHeading (HSSFSheet sheet, int rownum, String value, HSSFCellStyle style)
    {

        HSSFRow row = sheet.createRow(rownum);
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("");

        cell = row.createCell(1);
        cell.setCellValue(value);
        cell.setCellStyle(style);
        sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(rownum,rownum+1,1,3));
    }
    JSONObject extractData(JSONObject chartData, String chartName){
        JSONObject data = new JSONObject();
        try{
            if(chartName.equals("products&orders")){
                //Orders
                JSONObject orderObj =  new JSONObject();
                orderObj.put("datasets",chartData.getJSONObject("data").getJSONArray("datasets").getJSONObject(0).getJSONArray("data"));
                orderObj.put("labels",chartData.getJSONArray("excelLabels"));
                orderObj.put("title","Orders");
                orderObj.put("type","");
                data.put("order",orderObj);

                JSONObject productObj =  new JSONObject();
                productObj.put("datasets",chartData.getJSONObject("data").getJSONArray("datasets").getJSONObject(1).getJSONArray("data"));
                productObj.put("labels",chartData.getJSONArray("excelLabels"));
                productObj.put("title","Products");
                productObj.put("type","");

                data.put("product",productObj);
            }
            else if (chartData.getString("type").equals("doughnut")){
                Double total = 0.0;
                JSONArray rev_data =  chartData.getJSONObject("data").getJSONArray("datasets").getJSONObject(0).getJSONArray("data");
                for(int i = 0; i<rev_data.length(); i++)
                    total += rev_data.getDouble(i);
                JSONArray percentages = new JSONArray();
                for(int i = 0; i<rev_data.length(); i++){
                    percentages.put(Math.round((rev_data.getInt(i)/total)*100));
                }
                data.put("percentages",percentages);
                data.put("datasets",chartData.getJSONObject("data").getJSONArray("datasets").getJSONObject(0).getJSONArray("data"));
                data.put("labels",chartData.getJSONObject("data").getJSONArray("labels"));
                data.put("type","doughnut");
                data.put("title",chartName);
            }else if (chartName.equals("Funnel")){
                data.put("datasets",chartData.getJSONObject("data").getJSONArray("datasets").getJSONObject(0).getJSONArray("data"));
                data.put("labels",chartData.getJSONObject("data").getJSONArray("labels"));
                data.put("type","funnel");
                data.put("title",chartName);
            }else if(chartName.equals("Top Agents") || chartName.equals("Top selling products")){
                JSONArray values = new JSONArray();
                JSONArray labels = new JSONArray();
                JSONArray  array  = chartData.getJSONArray("data");

                for(int i = 0;i<array.length();i++){
                    values.put(array.getJSONObject(i).getString("quantity"));
                    labels.put(array.getJSONObject(i).getString("name"));
                }
                data.put("datasets",values);
                data.put("labels",labels);
                data.put("title",chartName);
                data.put("type","");
            }
            else if(chartName.equals("Revenue")){
                data.put("datasets",chartData.getJSONObject("data").getJSONArray("datasets").getJSONObject(0).getJSONArray("data"));
                data.put("labels",chartData.getJSONArray("excelLabels"));
                data.put("title",chartName+" ("+chartData.getString("currency")+")");
                data.put("type","");
            }
        }catch(Exception e){
            System.out.println(e);
            e.printStackTrace();
        }
    return data;


    }
    JSONArray getChartsData(com.etn.beans.Contexte Etn,String siteId, String start, String end, Locale locale,String catalogType){
        JSONArray chartsJson = new JSONArray();

        try{
            JSONObject data = new JSONObject();

            JSONObject chartData = new JSONObject();
            JSONObject kpidata  = new JSONObject();
            JSONArray kpidatesets  = new JSONArray();
            JSONArray kpilables  = new JSONArray();


            //---------------- KPI CHARTS -----------------------------------

            data = getRevenueChartSmallData(Etn,siteId, "Total Revenue", "kpi", start, end, locale,catalogType);
            kpidatesets.put(data.getString("total")+" "+data.getString("currency"));
            kpilables.put(data.getString("label"));


            data = getOrdersChartSmallData(Etn,siteId, "Total orders", "kpi", start, end, locale,catalogType);
            kpidatesets.put(data.getString("total"));
            kpilables.put(data.getString("label"));


            data = getQuantityChartSmallData(Etn,siteId, "Total products", "kpi", start, end, locale,catalogType);
            kpidatesets.put(data.getString("total"));
            kpilables.put(data.getString("label"));


            data = getTransformationRateChartSmallData(Etn,siteId, "Transformation rate", "kpi", start, end, locale,catalogType);
            kpidatesets.put(data.getString("total"));
            kpilables.put(data.getString("label"));


            data = getAbandonedCartsChartSmallData(Etn,siteId,"Abandoned carts","kpi", start, end, locale,catalogType);
            kpidatesets.put(data.getString("total"));
            kpilables.put(data.getString("label"));


            data = getProductsPerOrderChartSmallData(Etn,siteId, "Products per order", "kpi", start, end, locale,catalogType);
            kpidatesets.put(data.getString("total"));
            kpilables.put(data.getString("label"));



            data = getAverageOrderChartSmallData(Etn,siteId, "Average order amount", "kpi", start, end, locale,catalogType);
            kpidatesets.put(data.getString("total")+" "+data.getString("currency"));
            //+chartData.getString("currency")
            kpilables.put(data.getString("label"));


            data = getVisitorsChartSmallData(Etn,siteId, "Number of visitors", "kpi", start, end, locale,catalogType);
            kpidatesets.put(data.getString("total"));
            kpilables.put(data.getString("label"));


            JSONObject temp  = new JSONObject();
            temp.put("datasets",kpidatesets);
            temp.put("labels",kpilables);
            temp.put("title","Main KPIs");
            temp.put("type","kpi");
            chartsJson.put(temp);

            //---------------- KPI CHARTS -----------------------------------
            data = getOrdersAndProductsChartData(Etn,siteId, start, end, locale,catalogType);
            JSONObject obj =  extractData(data,"products&orders");
            chartsJson.put(obj.getJSONObject("product"));
            chartsJson.put(obj.getJSONObject("order"));



            data = getRevenueChartData(Etn,siteId, start, end, locale,catalogType);
            chartsJson.put(extractData(data,"Revenue"));// revenue


            data = getFunnelChartData(Etn,siteId,start, end,catalogType);
            chartsJson.put(extractData(data,"Funnel"));


            // Top selling products
            data.put("data", getTopSellersChartData(Etn,siteId, start, end,catalogType));
            chartsJson.put(extractData(data,"Top selling products"));


            // top agents
            data.put("data", getTopAgentsChartData(Etn,siteId, start, end,catalogType));
            chartsJson.put(extractData(data,"Top Agents"));


            data = getPromotionDistributionChartData(Etn,siteId, start, end,catalogType);
            chartsJson.put(extractData(data,"Distribution of products per promotion"));


            data = getDeliveryDistributionChartData(Etn,siteId, start, end);
            chartsJson.put(extractData(data,"Distribution of sales per delivery method"));


            data = getDeliveryStoreDistributionChartData(Etn,siteId, start, end,catalogType);
            chartsJson.put(extractData(data,"Distribution of sales per delivery stores"));


            data = getDeliveryPointDistributionChartData(Etn,siteId, start, end,catalogType);
            chartsJson.put(extractData(data,"Distribution of sales per delivery point"));


        }catch(Exception e){
         e.printStackTrace();
        System.out.println( e);
        }
        return chartsJson;
    }

%>
<%

    // String start  = extractPostRequestBody(request);

    String date = request.getParameter("dateSpan");
    String start =  request.getParameter("start");
    String end =  request.getParameter("end");
    String catalogType =  request.getParameter("catalogType");
    String siteId=parseNull(session.getAttribute("SELECTED_SITE_ID"));
    JSONArray chartsJson =   getChartsData(Etn,siteId, start,end,request.getLocale(),catalogType);
    UUID uuid = UUID.randomUUID();
    String filename =  uuid.toString()+".xls";

    FileOutputStream fout = null;
    try {
        HSSFWorkbook workbook=new HSSFWorkbook();
        HSSFSheet sheet =  workbook.createSheet("Sheet");

        HSSFPalette palette = workbook.getCustomPalette();
        // define colors
        HSSFColor lightGray = palette.findColor((byte) 0xC6, (byte)0xC6,(byte) 0xC6);
        if (lightGray == null )
        {
            palette.setColorAtIndex(HSSFColor.LAVENDER.index, (byte) 0xC6, (byte)0xC6,(byte) 0xC6);
            lightGray = palette.getColor(HSSFColor.LAVENDER.index);
        }
        HSSFColor orange = palette.findColor((byte) 0xff, (byte)0x8c,(byte) 0x00);
        if (orange == null )
        {
            palette.setColorAtIndex(HSSFColor.ORANGE.index, (byte) 0xff, (byte)0x8c,(byte) 0x00);
            orange = palette.getColor(HSSFColor.ORANGE.index);
        }

        HSSFFont simplefont = workbook.createFont();
        simplefont.setFontHeight((short)(12*20));
        simplefont.setFontName("Calibri");

        HSSFFont headingFont = workbook.createFont();
        headingFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
        headingFont.setFontHeight((short)(24*20));
        headingFont.setColor(orange.getIndex());
        headingFont.setFontName("Calibri");

        HSSFFont heading2Font = workbook.createFont();
        heading2Font.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
        heading2Font.setFontHeight((short)(18*20));
        heading2Font.setColor(HSSFColor.WHITE.index);
        heading2Font.setFontName("Calibri");

        HSSFCellStyle leftcellstyle = workbook.createCellStyle();
        leftcellstyle.setAlignment(HSSFCellStyle.ALIGN_LEFT);
        leftcellstyle.setFont(simplefont);

        HSSFCellStyle rigthtcellstyle = workbook.createCellStyle();
        rigthtcellstyle.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
        rigthtcellstyle.setFont(simplefont);


        HSSFCellStyle headingCellstyle = workbook.createCellStyle();
        headingCellstyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
        headingCellstyle.setFont(headingFont);

        HSSFCellStyle heading2Cellstyle = workbook.createCellStyle();
        heading2Cellstyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
        heading2Cellstyle.setAlignment(HSSFCellStyle.ALIGN_LEFT);
        heading2Cellstyle.setFont(heading2Font);
        heading2Cellstyle.setFillForegroundColor(lightGray.getIndex());
        heading2Cellstyle.setFillPattern(HSSFPatternFormatting.SOLID_FOREGROUND);


        int rownum = 1;
        HSSFRow row = sheet.createRow(rownum);
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("");
        cell = row.createCell(1);
        cell.setCellValue("Dashboard Data Export");
        cell.setCellStyle(headingCellstyle);
        sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(1,2,1,3));
        rownum++;
        rownum++;

        addRow(sheet,rownum,"Considered period",date,leftcellstyle,rigthtcellstyle);
        rownum++;
        rownum++;

        JSONArray datasets = null;
        JSONArray labels = null;
        JSONArray percentages = null;
        String title = "";
        String type = "";

        for(int i=0; i<chartsJson.length(); i++){
            if(chartsJson.getJSONObject(i).has("datasets")){
                type = chartsJson.getJSONObject(i).optString("type","");
                datasets = chartsJson.getJSONObject(i).getJSONArray("datasets");
                labels = chartsJson.getJSONObject(i).getJSONArray("labels");
                title = chartsJson.getJSONObject(i).getString("title");

                if(labels.length()>0){

                    addHeading(sheet,rownum,title,heading2Cellstyle);
                    rownum++;
                    rownum++;

                    if(type.equalsIgnoreCase("kpi")){
                        for(int y=0; y<labels.length(); y++){
                            addRow(sheet,rownum,labels.getString(y),datasets.getString(y),leftcellstyle,rigthtcellstyle);
                            rownum++;
                        }
                    }
                    else if(type.equalsIgnoreCase("doughnut")){
                        percentages = chartsJson.getJSONObject(i).getJSONArray("percentages");
                        for(int y=0; y<labels.length(); y++){
                            addthreeCellRow(sheet,rownum,labels.getString(y),datasets.getInt(y)+"",percentages.getInt(y)+" %",leftcellstyle,rigthtcellstyle);
                            rownum++;
                        }
                    }
                    else{
                       for(int y=0; y<labels.length(); y++){
                            addRow(sheet,rownum,labels.getString(y),datasets.getInt(y)+"",leftcellstyle,rigthtcellstyle);
                            rownum++;
                        }
                    }
                }
            }
        }

        for(int colIndex = 0; colIndex < 5 ; colIndex++)
        {
            sheet.autoSizeColumn(colIndex, true);
        }
        File fileDirectory = FileUtil.getFile(com.etn.beans.app.GlobalParm.getParm("DASHBOARD_EXCEL_PATH"));//change
        FileUtil.mkDirs(fileDirectory);//change
        fout = FileUtil.getFileOutputStream(com.etn.beans.app.GlobalParm.getParm("DASHBOARD_EXCEL_PATH")+filename);//change
        workbook.write(fout);
        out.write(filename);
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
        finally
        {
            try {
                if(fout != null) fout.close();
                } catch (Exception e) {}
        }
%>