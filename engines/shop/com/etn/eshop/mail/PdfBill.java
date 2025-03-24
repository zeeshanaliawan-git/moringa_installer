package com.etn.eshop.mail;

import java.io.*;
import java.util.Properties;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;
import java.lang.reflect.Type;
import java.text.*;
import java.util.Map;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import com.etn.sql.escape;


public class PdfBill
{ 

	ClientSql Etn;
	String REPOSITORY;
	boolean debug = false;
	String htmltopdfcmd ;

	private String parseNull(String s)
	{
		if (s == null) return ("");
		if (s.equals("null")) return ("");
		return (s.trim());
	}

        
        private double parseNullDouble(Object o)
        {
            if (o == null) return 0;
            String s = o.toString();
            if (s.equals("null")) return 0;
            if (s.equals("")) return 0;
            return Double.parseDouble(s);
        }

	private String formatAmt(String amnt)
	{
		if(amnt == null) amnt = "";
		amnt = amnt.trim();
		if(amnt.length() == 0) return amnt;

		DecimalFormatSymbols otherSymbols = new DecimalFormatSymbols(java.util.Locale.getDefault());
		otherSymbols.setDecimalSeparator(',');
		otherSymbols.setGroupingSeparator('.'); 
		DecimalFormat nf = new DecimalFormat("###,##0.00", otherSymbols);
		amnt = nf.format(Double.parseDouble(amnt));
		return amnt;
	}
  

	int doHtml( String clid , Writer o , String type)
	{
		Set rs = Etn.execute("select *,  date_format(NOW(), '%d.%m.%Y') as billingdate "+
					" from customer"+
					" where customerid="+clid );
		if(!rs.next()) return(-1);
                
                String deliveryDisplayName = "";
                String paymentDisplayName = "";
 
		try 
		{                           
                        Gson gson = new Gson();
                        Type listType = new TypeToken<Map<String,Object>>(){}.getType();
                        Map<String, String> ordersnapshotjsonmap = gson.fromJson(rs.value("order_snapshot"), listType);
        
			String htm = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n"+
						"<html>\n<head>\n<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />\n<title>Facture</title>\n"+
						"<style>\nbody{ font-family: Arial ,sans-serif; }\n" +
                                                ".container{ width: 960px; margin: 0 auto; }\n" +
                                                "table{ width: 100%; border-collapse: collapse; }\n" +
                                                ".bordered td{ border:1px solid #ddd; height: 20px; }\n" +
                                                "th{ background-color: #888; border:1px solid #000; }\n</style>\n"+
						"</head>\n<body>\n<div class='container' style=\"height:1000px;\">\n" +
                                                (type.equals("bill")?"    <p style='font-size: 1.5em'>Facture N&deg; "+clid+"</p>\n":"") +
                                                "    <table style='margin-bottom: 30px;width: 60%;float: left;'>\n" +
                                                "      <tr>\n" +
                                                "        <td style='width:50%;text-align: center;background-color: #C1DFA9'>\n" +
                                                "          Be Cheery Be, soci&eacute;t&eacute; par actions simplifi&eacute;e &agrave; associ&eacute;     <br>\n" +
                                                "          unique (SASU) au capital social de 1.000&euro;, immatricul&eacute;e <br>\n" +
                                                "          au registre du commerce et des soci&eacute;t&eacute;s (RCS) de Villeurbanne,  <br>\n" +
                                                "          si&egrave;ge social situ&eacute; au 20 rue Louis Gu&eacute;rin 69100 Villeurbanne / <br>\n" +
                                                "          &eacute;tablissement secondaire situ&eacute; au 40 rue de Paradis 75010 Paris <br>\n" +
                                                "        </td>\n" +
                                                "        </tr>\n" +
                                                "      <tr>\n" +
                                                "        <td><br>"+parseNull(ordersnapshotjsonmap.get("taxString"))+"</td>\n" +
                                                "        </tr>\n" +
                                                "    </table>\n" +
                                                "    <table style=\"width: 40%;\">\n" +
                                                "      <tr>\n" +
                                                "        <td style='width:18%;padding-left: 5%;'>"+(type.equals("bill")?"Date d'&eacute;dition : ":"&nbsp;")+"</td>\n" +
                                                "        <td style='width:18%;text-align:right'>"+(type.equals("bill")?parseNull(rs.value("billingdate")):"&nbsp;")+"</td>\n" +
                                                "      </tr>\n" +
                                                "      <tr>\n" +
                                                "        <td style=\"padding-left: 5%;\">N&deg; commande :</td>\n" +
                                                "        <td style='width:18%;text-align:right'>"+parseNull(rs.value("orderRef"))+"</td>\n" +
                                                "      </tr>\n" +
                                                "      <tr>\n" +
                                                "        <td style=\"padding-left: 5%;\">CLIENT :</td>\n" +
                                                "        <td style='width:18%;text-align:right'>"+parseNull(rs.value("name"))+" "+parseNull(rs.value("surnames"))+"</td>\n" +
                                                "      </tr>\n" +
                                                "      <tr>\n" +
                                                "        <td style=\"padding-left: 5%;\">ADRESSE :</td>\n" +
                                                "        <td style='width:18%;text-align:right'>"+parseNull(rs.value("baline1"))+"</td>\n" +
                                                "      </tr>\n" +
                                                "      <tr>\n" +
                                                "        <td style=\"padding-left: 5%;\">CP VILLE :</td>\n" +
                                                "        <td style='width:18%;text-align:right'>"+parseNull(rs.value("batowncity"))+"</td>\n" +
                                                "      </tr>\n" +
                                                "      <tr>\n" +
                                                "        <td style=\"padding-left: 5%;\">Contact :</td>\n" +
                                                "        <td style='width:18%;text-align:right'>"+parseNull(rs.value("contactPhoneNumber1"))+"</td>\n" +
                                                "      </tr>\n" +
                                                "    </table>\n" +
                                                "    <table style='border:2px solid #000' class='bordered'>\n" +
                                                "      <thead>\n" +
                                                "        <tr>\n" +
                                                "          <th style='width:50%'>Designation</th>\n" +
                                                "          <th>Prix Unitaire HT</th>\n" +
                                                "          <th>Prix Unitaire</th>\n" +
                                                "          <th style=''>Quantite</th>\n" +
                                                "          <th style=''>Total</th>\n" +
                                                "        </tr>\n" +
                                                "      </thead>\n" +
                                                "      <tbody>\n";
                        double itemsTotal = 0;
                        Set rsItems = Etn.execute("select * from order_items where parent_id="+escape.cote(rs.value("parent_uuid")));
                        while(rsItems.next()){                            
                            itemsTotal += parseNullDouble(rsItems.value("price_value"));
                            DecimalFormat df = new DecimalFormat("#.##");
                            htm += "        <tr>\n" +
                                                "          <td>"+parseNull(rsItems.value("product_full_name"))+"</td>\n" +
                                                "          <td>"+df.format((parseNullDouble(rsItems.value("price_value"))/parseNullDouble(rsItems.value("quantity")))/(1+(parseNullDouble(rsItems.value("tax_percentage"))/100)))+" &euro;</td>\n" +
                                                "          <td>"+df.format(parseNullDouble(rsItems.value("price_value"))/parseNullDouble(rsItems.value("quantity")))+" &euro;</td>\n" +
                                                "          <td>"+parseNull(rsItems.value("quantity"))+"</td>\n" +
                                                "          <td>"+parseNull(rsItems.value("price_value"))+" &euro;</td>\n" +
                                                "        </tr>\n";
                            if(deliveryDisplayName.length()==0 || paymentDisplayName.length()==0){
                                listType = new TypeToken<Map<String,Object>>(){}.getType();
                                Map<String, String> product_snapshot  = gson.fromJson(rsItems.value("product_snapshot"), listType);
                                deliveryDisplayName = parseNull(product_snapshot.get("deliveryDisplayName"));
                                paymentDisplayName = parseNull(product_snapshot.get("paymentDisplayName"));
                            }
                        }
                                            htm += "        <tr>\n" +
                                                "          <td>&nbsp;</td>\n" +
                                                "          <td>&nbsp;</td>\n" +
                                                "          <td>&nbsp;</td>\n" +
                                                "          <td>Sous-total</td>\n" +
                                                "          <td>"+itemsTotal+" &euro;</td>\n" +
                                                "        </tr>\n" +
                                                "      </tbody>\n" +
                                                "    </table>\n" +
                                                "    <table style='border: 2px solid #000;border-top:none;border-bottom: none'>\n" +
                                                "      <tr>\n" +
                                                "        <td colspan='2'>M&eacute;thode de paiement:</td>\n" +
                                                "        <td style='text-align: right'>"+paymentDisplayName+"</td>\n" +
                                                "      </tr>\n" +
                                                "      <tr>\n" +
                                                "        <td colspan='2'>Num&eacute;ro transaction:</td>\n" +
                                                "        <td style='text-align: right'>"+parseNull(rs.value("payment_id"))+"</td>\n" +
                                                "      </tr>\n" +
                                                "      <tr>\n" +
                                                "        <td colspan='2'>Total:</td>\n" +
                                                "        <td style='text-align: right'>"+parseNull(rs.value("total_price"))+" &euro;</td>\n" +
                                                "      </tr>\n" +
                                                "      <tr>\n" +
                                                "        <td>&nbsp;</td>\n" +
                                                "        <td>&nbsp;</td>\n" +
                                                "        <td>&nbsp;</td>\n" +
                                                "      </tr>\n" +
                                                "    </table>\n" +
                                                "    <table style='border: 2px solid #000;border-top:none'>\n" +
                                                "      <thead>\n" +
                                                "        <tr>\n" +
                                                "          <td style='width: 50%;text-decoration: underline;'><strong>Contact</strong></td>\n" +
                                                "          <td style='text-decoration: underline;'><strong></strong></td>\n" +
                                                "          <td style='width: 36%;'></td>\n" +
                                                "        </tr>\n" +
                                                "      </thead>\n" +
                                                "      <tbody>\n" +
                                                "        <tr>\n" +
                                                "          <td>Email: contact@hypnorigins.com</td>\n" +
                                                "          <td></td>\n" +
                                                "          <td></td>\n" +
                                                "        </tr>\n" +
                                                "        <tr>\n" +
                                                "          <td></td>\n" +
                                                "          <td></td>\n" +
                                                "          <td></td>\n" +
                                                "        </tr>\n" +
                                                "         <tr>\n" +
                                                "          <td></td>\n" +
                                                "          <td></td>\n" +
                                                "          <td></td>\n" +
                                                "        </tr>\n" +
                                                "      </tbody>\n" +
                                                "\n" +
                                                "    </table>\n" +
                                                "  </div><div class='container' >\n" +
                                                "    <table style='margin-bottom: 30px;width: 100%;'>\n" +
                                                "        <tr><td style='width:25%'>&nbsp;</td>" +
                                                "          <td style='width:50%;text-align: center;font-size: 12px;'>\n" +
                                                "            Be Cheery Be, soci&eacute;t&eacute; par actions simplifi&eacute;e &agrave; associ&eacute;     <br>\n" +
                                                "            unique (SASU) au capital social de 1.000&euro;, immatricul&eacute;e <br>\n" +
                                                "            au registre du commerce et des soci&eacute;t&eacute;s (RCS) de Villeurbanne,  <br>\n" +
                                                "            si&egrave;ge social situ&eacute; au 20 rue Louis Gu&eacute;rin 69100 Villeurbanne / <br>\n" +
                                                "            &eacute;tablissement secondaire situ&eacute; au 40 rue de Paradis 75010 Paris <br>\n" +
                                                "            <br>\n" +
                                                "            Num&eacute;ro de TVA intracommunautaire : FR52824549257\n" +
                                                "          </td><td style='width:25%'>&nbsp;</td>" +
                                                "          </tr>\n" +
                                                "      </table>\n" +
                                                "</div>\n</body>\n</html>\n";
			o.write(htm);

			return(0);

		}
		catch( Exception e )
		{ 
			e.printStackTrace();
			return(-1);
		}

	}

	public String makePdf( String clid, String orderRef, String type )
	{
                String filename = (type.equals("bill")?"/Facture_"+orderRef:"/Recapitulatif_"+orderRef);
		File  html = new File( REPOSITORY+filename+".html");
		File pdf = new File(REPOSITORY+filename+".pdf");
		PrintWriter fhtml = null;
		try 
		{
			fhtml = new PrintWriter( html ,"utf-8");
			int i = doHtml( clid , fhtml, type);
			fhtml.close(); fhtml = null;
			if( i!= 0 ) return(null);
  
			String cmd = htmltopdfcmd + " "+html.toString()+ " "+pdf.toString();
                        System.out.println(cmd);
			Process p = Runtime.getRuntime().exec(cmd);
			i = p.waitFor();

			if( i == 0 && pdf.exists() ) return( pdf.toString() );

			return(null);
		}
		catch( Exception e )
		{ 
			e.printStackTrace(); 
			return(null); 
		}
		finally 
		{ 
			if( fhtml!=null) try { fhtml.close(); } catch(Exception ee) {}
			html.delete(); 
		}

	}

	public PdfBill( ClientSql Etn , Properties env )
	{ 
		this.Etn = Etn;
		String s = env.getProperty("PDF_REPO");
		if( s.endsWith("/") ) REPOSITORY = s.substring(0,s.length()-1);
		else REPOSITORY = s;

		htmltopdfcmd = env.getProperty("HTML_TO_PDF_CMD");

		debug = env.get("DEBUG")!= null;
	}

	public static void main( String a[] ) throws Exception
	{
		Properties p = new Properties();
		p.load( com.etn.eshop.SendMail.class.getResourceAsStream("Scheduler.conf") );

		com.etn.Client.Impl.ClientDedie etn =
		new com.etn.Client.Impl.ClientDedie( "MySql", "com.mysql.jdbc.Driver", p.getProperty("CONNECT") );

		PdfBill pdf = new PdfBill( etn , p );
		String fic = pdf.makePdf( a[0], a[1], "bill" );
		System.out.println("fichier pdf:"+fic);

		System.out.println("0.000");
		System.out.println(pdf.formatAmt("0.000"));

		System.out.println("123");
		System.out.println(pdf.formatAmt("123"));

		System.out.println("123.123");
		System.out.println(pdf.formatAmt("123.123"));

		System.out.println("123123123.333");
		System.out.println(pdf.formatAmt("123123123.333"));

	}

}

