 package com.etn.eshop;

import java.util.List;
import java.util.ArrayList;
import java.util.Properties;
import java.util.Date;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Locale;
import java.io.*;
import java.text.SimpleDateFormat;
import java.text.NumberFormat;
import java.text.DecimalFormat;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;
import com.etn.util.ItsDate;


class CreateInvoice
{

    private ClientSql Etn;
    private Properties env;

    public boolean debug = true; //set to false //debug


    String CATALOG_DB = null;
    String CATAPULTE_DB = null;
    String IS_PROD = null;
    String POST_WORK_SPLIT_ITEMS = null;

    public CreateInvoice(ClientSql etn, Properties conf) throws Exception{
        this.Etn = etn;
        this.env = conf;

        String requiredProps[] = {"CATALOG_DB", "INVOICE_DIR", "CATALOG_DB", "POST_WORK_SPLIT_ITEMS"};

        for(String requiredProp : requiredProps){
            if(parseNull(env.getProperty(requiredProp)).length() == 0){
                throw new Exception("Error: "+requiredProp+" not defined in properties.");
            }
        }

        CATALOG_DB = this.env.getProperty("CATALOG_DB");
        CATAPULTE_DB = this.env.getProperty("CATAPULTE_DB");
        IS_PROD = this.env.getProperty("IS_PROD_SHOP");
        POST_WORK_SPLIT_ITEMS = this.env.getProperty("POST_WORK_SPLIT_ITEMS");

        // if(parseNull(env.getProperty("CATALOG_DB")).length() == 0){
        //     throw new Exception("Error: CATALOG_DB not defined in properties.");
        // }
        // if(parseNull(env.getProperty("INVOICE_DIR")).length() == 0){
        //     throw new Exception("Error: INVOICE_DIR not defined in properties.");
        // }
        // if(parseNull(env.getProperty("CATALOG_DB")).length() == 0){
        //     throw new Exception("Error: INVOICE_DIR not defined in properties.");
        // }
        // if(parseNull(env.getProperty("POST_WORK_SPLIT_ITEMS")).length() == 0){
        //     throw new Exception("Error: POST_WORK_SPLIT_ITEMS not defined in properties.");
        // }

    }

    protected void systemLog(Object obj){
        if(debug){
            System.out.println(obj);
        }
    }

    private String parseNull(Object o)
    {
        if( o == null ) return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase())) return("");
        else return(s.trim());
    }

    int parseInt(Object o){
        return parseInt(o, 0);
    }

    int parseInt(Object o, int defaultValue){
        String s = parseNull(o);
        if(s.length() > 0 ){
            try{
                return Integer.parseInt(s);
            }
            catch(Exception e){
                return defaultValue;
            }
        }
        else{
            return defaultValue;
        }
    }

    public boolean generateSaleInvoice(int wkid)    throws Exception{
        systemLog("** generate sale invoice");
        return generateInvoice(wkid,"S");
    }

    public boolean generatePurchaseInvoice(int wkid) throws Exception{
        systemLog("** generate purchase invoice");
        return generateInvoice(wkid,"P");
    }

    protected boolean generateInvoice(int wkid, String invoiceType) throws Exception{

        /*
            TODO: Need to update,
            to handle the extra order charges
            like delivery charges and payment option charges at order level
        */

        BufferedWriter bw = null;
        FileInputStream fmodele = null;

        try
        {
            String fileName = "autoInv_";
            String query = null;
            Set rs = null;

            String currency = "EUR"; // TODO , get std currency from shop config
            String pid = "";

            query = "SELECT lang_1_currency as currency, catapulte_id_prod, "
                    + " catapulte_id_test FROM  "+CATALOG_DB+".shop_parameters LIMIT 1";

            Set shopParamRs = Etn.execute(query);
            if(shopParamRs.next()){
                if("1".equals(IS_PROD)){
                    pid = parseNull(shopParamRs.value("catapulte_id_prod"));
                }
                else{
                    pid = parseNull(shopParamRs.value("catapulte_id_test"));
                }

                if(shopParamRs.value("currency").length() == 3){
                    currency = shopParamRs.value("currency");
                }

            }

            if(pid.length() == 0){
                throw new Exception("Error: catapute user not specified in shop parameters.");
            }

            if("0".equals(POST_WORK_SPLIT_ITEMS)){
                //multiple orders in  order_items table

                query = " SELECT oi.*, o.tm AS tm,  p.invoice_nature as prod_nature, cat.invoice_nature as default_nature "
                    + " FROM order_items oi "
                    + " INNER JOIN orders o ON o.parent_uuid = oi.parent_id "
                    + " INNER JOIN "+CATALOG_DB+".products p ON p.product_uuid = oi.product_ref "
                    + " INNER JOIN "+CATALOG_DB+".catalogs cat ON cat.id = p.catalog_id "
                    + " INNER JOIN post_work pw ON pw.client_key = o.id "
                    + " WHERE pw.id = " + wkid;

                rs = Etn.execute(query);

                if(rs.rs.Rows == 0){
                    throw new Exception("Error: no order item record found for the wkid");
                }

                while(rs.next()){

                    try{

                        fileName += rs.value("id");

                        String invoiceNature = rs.value("prod_nature").trim();
                        if(invoiceNature.length() == 0){
                            invoiceNature = rs.value("default_nature").trim();
                        }

                        String cDate = rs.value("tm");
                        String productName = rs.value("product_name")+"("+rs.value("product_type")+")";
                        String productQuantity = rs.value("quantity");

                        double priceValue = Double.parseDouble(rs.value("price_value"));
                        double taxPercentage = Double.parseDouble(rs.value("tax_percentage"));

                        insertInvoice(  invoiceType, fileName, pid, currency, invoiceNature,
                                        productName, productQuantity, cDate,
                                        priceValue, taxPercentage);

                    }
                    catch(Exception ex){
                        ex.printStackTrace();
                    }

                }

            }
            else{
                //one combined order , customer table

                query = " SELECT oi.*, o.tm AS tm,  p.invoice_nature as prod_nature, cat.invoice_nature as default_nature "
                    + " FROM order_items oi "
                    + " INNER JOIN orders o ON o.parent_uuid = oi.parent_id "
                    + " INNER JOIN "+CATALOG_DB+".products p ON p.product_uuid = oi.product_ref "
                    + " INNER JOIN "+CATALOG_DB+".catalogs cat ON cat.id = p.catalog_id "
                    + " INNER JOIN post_work pw ON pw.client_key = oi.id "
                    + " WHERE pw.id = " + wkid;

                rs = Etn.execute(query);

                if(rs.rs.Rows == 0){
                    throw new Exception("Error: no order item record found for the wkid");
                }

                rs.next();

                fileName += rs.value("id");

                String invoiceNature = rs.value("prod_nature").trim();
                if(invoiceNature.length() == 0){
                    invoiceNature = rs.value("default_nature").trim();
                }

                String cDate = rs.value("tm");
                String productName = rs.value("product_name")+"("+rs.value("product_type")+")";
                String productQuantity = rs.value("quantity");

                double priceValue = Double.parseDouble(rs.value("price_value"));
                double taxPercentage = Double.parseDouble(rs.value("tax_percentage"));

                insertInvoice(  invoiceType, fileName, pid, currency, invoiceNature,
                                productName, productQuantity, cDate,
                                priceValue, taxPercentage);
            }

            return true;
        }
        finally{
            if(bw != null){
                try{ bw.close(); }catch(Exception e){}
            }
        }
    }


    private boolean insertInvoice( String invoiceType, String fileName,
                                String pid, String currency, String invoiceNature,
                                String productName, String productQuantity, String cDate,
                                double priceValue , double taxPercentage   ) throws Exception{


        BufferedWriter bw = null;
        FileInputStream fmodele = null;
        try{

            String fileNameHtml = fileName + ".html";
            String fileNameImage = fileName + ".jpg";

            //check if this wkid has already been used to add an invoice

            String query = " SELECT id FROM "+CATAPULTE_DB+".invoices "
                            + " WHERE file_name = "+ escape.cote(fileNameImage);
            Set rs = Etn.execute(query);
            int existingInvId = -1;
            if(rs.next()){
                //already exists
                systemLog("Invoice for this id already exists. Will be updated.");
                existingInvId = Integer.parseInt(rs.value("id"));
            }

            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-M-dd HH:mm:ss");

            NumberFormat nf = NumberFormat.getNumberInstance(Locale.US);
            DecimalFormat df = (DecimalFormat)nf;
            df.applyPattern("########0.00");

            if(pid.length() == 0){
                throw new Exception("Error: catapute user not specified in shop parameters.");
            }


            double inv_vat = 0.0;
            double original_amount = priceValue;
            if(taxPercentage > 0.0){
                original_amount =  priceValue  / ( 1.0+ (taxPercentage/100.0) );

                original_amount = Double.valueOf(df.format(original_amount));

                inv_vat = priceValue - original_amount;
                inv_vat = Double.valueOf(df.format(inv_vat));
            }


            String sOrigAmount = df.format(original_amount);
            String sVat = df.format(inv_vat);
            String sTotalAmount = df.format(priceValue);

            String _txnDate = cDate;
            _txnDate = ItsDate.stamp(ItsDate.getDate(_txnDate));


            String invNum = "";
            int invId = -1;
            if(existingInvId < 0){

                String insertCounter="INSERT INTO "+CATAPULTE_DB+".invoice_counter (pId, year ,counter) "
                    + " VALUES("+escape.cote(pid)+",YEAR('"+_txnDate.substring(0,8)+"'),1) "
                    + " ON DUPLICATE KEY UPDATE counter = @counter:=counter + 1";

                String []queryArray=new String[]{"set @counter :=1",
                            insertCounter,
                            "SELECT LPAD( @counter, 5, '0') as counter,YEAR('"+_txnDate.substring(0,8)+"')"};

                systemLog(queryArray[1]);
                Set allQuery=Etn.execute(queryArray);
                allQuery.next();
                allQuery.next();
                allQuery.next();

                invNum = allQuery.value(1).substring(2,4)+allQuery.value(0);


                query = "INSERT INTO "+CATAPULTE_DB+".invoices "
                    + " (pid, inv_nature, inv_amount,inv_vat, inv_date, currency, upload_type, "
                    + " matched_amount,document_type,generate_num) values "
                    + " ("+escape.cote(pid)+","+escape.cote(invoiceNature)+","+escape.cote(sOrigAmount)+","+escape.cote(sVat)
                    +     ","+escape.cote(_txnDate)+","+escape.cote(currency)+",'W','0',"+escape.cote(invoiceType)+",'"+invNum+"') ";

                systemLog(query);
                invId = Etn.executeCmd(query);

            }
            else{

                Set invRs = Etn.execute("SELECT generate_num FROM "+CATAPULTE_DB+".invoices WHERE id = "+escape.cote(""+existingInvId));
                invRs.next();

                invNum = invRs.value("generate_num");


                query = "UPDATE "+CATAPULTE_DB+".invoices "
                + " SET pid=" + escape.cote(pid)
                + " , inv_nature=" + escape.cote(invoiceNature)
                + " , inv_amount=" + escape.cote(sOrigAmount)
                + " , inv_vat=" + escape.cote(sVat)
                + " , inv_date=" + escape.cote(_txnDate)
                + " , currency=" + escape.cote(currency)
                + " , document_type=" + escape.cote(invoiceType)
                + " , generate_num=" + escape.cote(invNum)
                + " , upload_type='W', matched_amount='0' "
                + " WHERE id = " + escape.cote(""+existingInvId);

                systemLog(query);
                Etn.executeCmd(query);
                invId = existingInvId;

            }


            if(invId < 0){
                throw new Exception("Error: error in creating/updating invoice record.");
            }


            String wkhtmlPath = this.env.getProperty("WKHTMLTOIMAGE_PATH");

            String saveFilepath = this.env.getProperty("INVOICE_DIR")+ pid+ "/";
            File savePath = new File(saveFilepath);
            if(!savePath.exists()){
              savePath.mkdirs();
            }

            String invoiceTypeLabel = "Sale";
            if("P".equals(invoiceType)){
                invoiceTypeLabel = "Purchase";
            }


            File htmlFile = new File(saveFilepath+fileNameHtml);
            bw = new BufferedWriter(new FileWriter(htmlFile));
            bw.write("<html>");
            bw.write("<head></head>");
            bw.write("<body style='padding:20px;'>");
            String htmlText="<table width=\"95%\" style='border-spacing:10px'>"+
              "<tr>"+
                  "<td width=\"30%\">&nbsp;</td>"+
                  "<td width=\"70%\" valign=\"bottom\"> <strong>Shop Invoice</strong></td>"+
              "</tr><tr>"+
                  "<td width=\"30%\">"+invoiceTypeLabel+" Invoice # </td>"+
                  "<td>"+invNum+"</td>"+
              "</tr><tr>"+
                  "<td width=\"30%\">Date : </td><td>"+dateFormat.format(ItsDate.getDate(cDate))+"</td>"+
              "</tr><tr align=\"center\">"+
                  "<td colspan=\"2\"><hr/></td>"+
              "</tr><tr>"+
                  "<td width=\"30%\">Product : </td><td>"+productName+"</td>"+
              "</tr><tr>"+
                  "<td width=\"30%\">Quantity : </td><td>"+productQuantity+"</td>"+
            "</tr><tr align=\"center\">"+
                  "<td colspan=\"2\"><hr/></td>"+
              "</tr><tr>"+
                  "<td width=\"30%\">Amount :</td><td align=\"right\">"+sOrigAmount+"&nbsp; "+currency+"</td>"+
                  "</tr><tr>"+
                  "<td width=\"30%\">VAT :</td><td align=\"right\">"+sVat+"&nbsp; "+currency+"</td>"+
              "</tr><tr align=\"center\">"+
                  "<td colspan=\"2\"><hr/></td>"+
              "</tr><tr height='20' align=\"right\">"+
                  "<td colspan=\"2\">"+sTotalAmount+"&nbsp; "+currency+"</td>"+
              "</tr><tr align=\"center\">"+
                  "<td colspan=\"2\"><hr/></td>"+
              "</tr>"+
            "</table>";

            bw.write(htmlText);
            bw.write("</body>");
            bw.write("</html>");
            bw.close();
            bw = null;

            String command= wkhtmlPath + " --height 500 --width 500  "+saveFilepath+fileNameHtml+" "+saveFilepath+fileNameImage;
            System.out.println(command);
            Process process = Runtime.getRuntime().exec(command, null);
            String s = "";
            String temp = "";
            BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()));
            while ((temp = br.readLine()) != null) {
                  s += temp + "\n";
            }

            int retVal = 0;
            retVal = process.waitFor();
            if (retVal != 0) {
              System.out.println(retVal);
                  //throw new Exception("Error encountered in running PDF generation command\n" + command);
            }

            htmlFile.delete();

            query = "UPDATE "+CATAPULTE_DB+".invoices "
                    + " SET actual_file_name="+escape.cote(fileNameImage)+",file_name="+escape.cote(fileNameImage)
                    + " WHERE id="+invId;
            Etn.executeCmd(query);

            return true;
        }
        finally{

        }
    }

    public static void main(String a[]) throws Exception {

        System.out.println("### main start");

        //wkid = post_work id
        int wkid = 0;

        if (a.length == 0) {
            wkid = 5559;
        }
        else if("test".equals(a[0]) ){
            wkid    = Integer.parseInt(a[1]);
        }

        Properties p = new Properties();
        p.load(SendMail.class.getResourceAsStream("Scheduler.conf"));

        //System.out.println(p);

        com.etn.Client.Impl.ClientDedie etn =
                new com.etn.Client.Impl.ClientDedie("MySql",
                "com.mysql.jdbc.Driver",
                p.getProperty("CONNECT"));



        CreateInvoice  sc = new CreateInvoice(etn, p);
        sc.generateSaleInvoice(wkid);

        // File file = sc.getCalendarFile(wkid, type, emailType);

        // if(file != null)
        // System.out.println("" + file.getAbsolutePath());

        System.out.println("### main end");
        System.exit(0);

    }

}