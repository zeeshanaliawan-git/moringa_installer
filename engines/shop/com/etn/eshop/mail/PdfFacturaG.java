/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.etn.eshop.mail;

/**
 *
 * @author umair
 */

import java.io.*;
import java.util.Properties;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;

public class PdfFacturaG
{
    ClientSql Etn;
    String REPOSITORY;
    boolean debug =false;

    double iva=0.0;



    String printDouble( double d )
    {
        String s = ""+( d+0.005 );
        int i = s.indexOf('.');
        if( i == -1 || (i+3) > s.length() ) return(s);
        return( s.substring(0,i+3) );
    }

    String printf( String s)
    {
        int i =  s.indexOf('.');
        if( i == -1 ) return( s+".00");
        int l = s.length();
        if( (l - i ) < 3 ) return( s+"0");
        return( s.substring(0, i+3) );
    }



    String getHT( String ttc , String canon)
    {
        if( ttc.length()== 0 || ttc.equals("0") || ttc.equals("0.0") ) return("0.00");

        double total = Double.parseDouble(ttc);
        /**
        if( canon != null )
        total -= Double.parseDouble(canon);
        return( printDouble( total - (total / (1.0 + iva) ))  );
        **/


        double withoutTva = total / (1.0 + iva) ;
        if( canon != null ) return( printDouble( withoutTva - Double.parseDouble(canon) ) );

        return( printDouble( withoutTva ) );
    }

    String getIva( String ttc , String canon)
    {
        if( ttc.length()== 0 || ttc.equals("0") || ttc.equals("0.0") ) return("0.00");

        double total = Double.parseDouble(ttc);
        /**
        if( canon != null )
        total -= Double.parseDouble(canon);
        return( printDouble( total - (total / (1.0 + iva) ))  );
        **/

        double withoutTva = total / (1.0 + iva) ;
        return( printDouble( total - withoutTva ) );
    }


    int doHtml( String clid , Writer o )
    {

        Set rs=null;

        rs = Etn.execute(
        "select c.name,c.surnames,c.Gfactura,c.Gfecha,c.orderid"+
        ",c.identityid,c.terminal,c.sfid"+
        ",c.roadType droadType, c.roadName droadName,c.roadNumber droadNumber"+
        ", c.stair dstair,c.floorNumber dfloorNumber"+
        ", c.apartmentNumber dapartmentNumber, c.order_shipping_amount" +
        ", round((c.order_shipping_amount /(1 + (c.iva/100))),2) shippingWithoutIva "+
        ", round(order_shipping_amount - (order_shipping_amount /(1 + (iva/100))),2) shippingIva "+
        ",c.postalCode dpostalCode,c.locality dlocality,c.state dstate"+
        ",c.price,c.iva,c.mp3,c.canon,c.imei"+
        ",ifnull(a.roadType,c.roadType) roadType"+
        ",ifnull(a.roadName,c.roadName) roadName"+
        ",ifnull(a.roadNumber,c.roadNumber) roadNumber"+
        ",ifnull( a.stair,c.stair) stair"+
        ",ifnull(a.floorNumber,c.floorNumber) floorNumber"+
        ",ifnull(a.apartmentNumber,c.apartmentNumber) apartmentNumber "+
        ",ifnull(a.postalCode,c.postalCode) postalCode"+
        ",ifnull(a.locality,c.locality) locality"+
        ",ifnull(a.state,c.state) state"+
        " from customer c "+
        " left join address a using( customerid)"+
        " where customerid="+clid );

        if(!rs.next()) return(-1);


        iva = Double.parseDouble(rs.value("iva")) / 100.0 ;

        boolean gratuit = getHT( rs.value("price") , null).equals("0.00") ;
        boolean koko = "10000009".equals(rs.value("sfid"));

        try
        {
            o.write(
            "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n"+
            "\n"+
            "<html>\n"+
            "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"+
            "<head>\n"+
            "<title>Guizmo Spain - Factura</title>\n"+
            "\n"+
            "<style>\n"+
            "\n"+
            ".title{font-family: arial;color: black;font-size: 20pt;font-weight: bold;text-align: center;}\n"+
            ".stitle{font-family: arial;color: black;font-size: 12pt;font-weight: bold;text-align: center;}\n"+
            ".texte{font-family: arial;color: black;font-size: 9pt;font-weight: bold;text-align: center;height:25px;}\n"+
            ".textenormal{font-family: arial;color: black;font-size: 9pt;font-weight: normal;text-align: center;height:25px;}\n"+
            ".texteleft{font-family: arial;color: black;font-size: 9pt;font-weight: normal;text-align: left;height:25px;}\n"+
            ".texteB{font-family: arial;color: black;font-size: 9pt;font-weight: bold;text-align: left;height:25px;}\n"+
            ".texteN{font-family: arial;color: black;font-size: 9pt;font-weight: normal;text-align: left;height:25px;}\n"+
            ".texteR{font-family: arial;color: black;font-size: 9pt;font-weight: bold;text-align: right;height:25px;padding-right:5px;}\n"+
            ".title2{font-family: arial;color: white;background-color: "+
            (koko?"#2eb135":"#FF6600")+
            ";font-size: 14pt;text-align: center;font-weight: bold;height:25px;padding-right:5px;}\n"+
            ".texteS{font-family: arial;color: black;font-size: 7pt;font-weight: normal;text-align: left;}\n"+
            ".texteG{font-family: arial;color: #AFB0B2;font-size: 7pt;font-weight: normal;text-align: left;}\n"+
            ".texteO{font-family: arial;color: "+
            (koko?"#2eb135":"#FF6600")+
            ";font-size: 7pt;font-weight: normal;text-align: left;}\n"+
            "\n"+
            "</style>\n"+
            "</head>\n"+
            "\n"+
            "<body>\n"+
            "\n"+
            "	<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" width=\"100%\">\n"+
            "		<tr>\n"+
            "			<td style=\"text-align:left;\"><img src=\""+
            (koko?"amena.png":"logo.png")+"\"></img></td>\n"+
            "			<td class=\"title\" style=\"text-align:left;\">factura</td>\n"+
            "		</tr>\n"+
            "\n"+
            "		<tr>\n"+
            "			<td colspan=\"2\" style=\"border-bottom:2px solid black;\">&nbsp;</td>\n"+
            "		</tr>\n"+
            "				\n"+
            "		<tr>		\n"+
            "			<td class=\"texte\" width=\"50%\">n&uacute;mero de factura</td>\n"+
            "			<td class=\"texte\" width=\"50%\">fecha de factura</td>\n"+
            "\n"+
            "		</tr>\n"+
            "	\n"+
            "		<tr>\n"+
            "			<td class=\"textenormal\" width=\"50%\">"+rs.value("Gfactura")+"</td>\n"+
            "			<td class=\"textenormal\" width=\"50%\">"+rs.value("Gfecha")+"</td>\n"+
            "		</tr>\n"+
            "\n"+
            "<tr>\n"+
            "			<td colspan=\"2\" style=\"border-top:2px solid black;\">&nbsp;</td>\n"+
            "		</tr>\n"+
            "\n"+
            "		<tr>\n"+
            "			<td width=\"50%\">\n"+
            "			<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\">\n"+
            "			<tr>\n"+
            "			<td class=\"texteB\" colspan=\"2\" style=\"vertical-align:top;\">datos del cliente</td>\n"+
            "		</tr>\n"+
            "		\n"+
            "		<tr>\n"+
            "			<td class=\"texteB\" colspan=\"2\">n&ordm; de referencia&nbsp;:&nbsp;<span class=\"texteleft\">"+rs.value("orderid")+"</span></td>\n"+
            "		</tr>\n"+
            "\n"+
            "		<tr>\n"+
            "			<td class=\"texteleft\">\n"+
            rs.value("surnames")+" "+rs.value("name")+"<br>\n"+
            rs.value("roadType")+" "+rs.value("roadName")+" "+rs.value("roadNumber") );

            String etage = rs.value("stair");
            if(rs.value("floorNumber").length() > 0 )
            etage += " "+rs.value("floorNumber")+"&ordm; ";

            etage += " "+rs.value("apartmentNumber");
            etage = etage.trim();
            if( etage.length()> 0 ) o.write(", "+etage);


            o.write(
            "<br>\n"+
            rs.value("postalCode")+" "+rs.value("locality")+"<br>\n"+
            rs.value("state")+"</td>\n"+
            "		</tr>\n"+
            "		<tr>\n"+
            "			<td class=\"texteB\" colspan=\"2\">documento de identidad&nbsp;:&nbsp;<span class=\"texteleft\"></span></td>\n"+
            "<td class=\"texteleft\">"+rs.value("identityId")+"</td>"+
            "		</tr>\n"+
            "		\n"+
            "		<tr>	\n"+
            "			<td class=\"texteB\" colspan=\"2\">forma de pago&nbsp;:&nbsp;<span class=\"texteleft\"></span></td>\n"+
            "<td class=\"texteleft\">contrareembolso</td>"+
            "		</tr>\n"+
            "	</table>\n"+
            "\n"+
            "			</td>\n"+
            "\n"+
            "			<td width=\"50%\" style=\"vertical-align:top;\">\n"+
            "	<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\">\n"+
            "		<tr>\n"+
            "			<td class=\"texteB\" colspan=\"2\">datos fiscales</td>\n"+
            "		</tr>\n"+
            "		<tr>\n"+
            "			<td class=\"texteleft\">\n"+
            rs.value("surnames")+" "+rs.value("name")+"<br>\n"+
            "datos fiscales<br>\n"+
            rs.value("roadType")+" "+rs.value("roadName")+" "+rs.value("roadNumber") );

            String etg = rs.value("stair");
            if(rs.value("floorNumber").length() > 0 )
            etg += " "+rs.value("floorNumber")+"&ordm; ";

            etg += " "+rs.value("apartmentNumber");
            etg = etage.trim();

            if( etg.length()>0 ) o.write(", "+etg);

            o.write(
            "<br>\n"+
            rs.value("postalCode")+" "+rs.value("locality")+"<br>\n"+
            rs.value("state")+"</td>\n"+
            "               </tr>\n"+
            "	</table>\n"+
            "			</td>\n"+
            "		</tr>\n"+
            "		<tr>\n"+
            "			<td colspan=\"2\" style=\"padding-left:50px;padding-right:20px;text-align:right;\">\n"+
            "	<table cellpadding=\"\" cellspacing=\"10\" border=\"0\" width=\"100%\">\n"+
            "	\n"+
            "	<tr>\n"+
            "			<td class=\"title2\" colspan=\"3\">resumen de tu compra</td>\n"+
            "		</tr>\n"+
            "		<tr>\n"+
            "			<td width=\"30%\"></td>\n"+
            "			<td class=\"texte\" width=\"35%\">importe (euros)</td>\n"+
            "			<td class=\"texte\" width=\"35%\">importe total (euros)</td>\n"+
            "		</tr>\n"+
            "		\n"+
            "		<tr>\n"+
            "			<td class=\"texteB\">Costes de gesti&oacute;n</td>\n"+
            "			<td class=\"texteR\">"+printf(rs.value("shippingWithoutIva"))+"</td>\n"+
            "			<td class=\"texteR\">"+printf(rs.value("order_shipping_amount"))+"</td>\n"+
            "		</tr>\n"+
            "\n");

            o.write(
            "		<tr>\n"+
            "		<td colspan=\"2\" style=\"border-bottom:2px solid black;\">&nbsp;</td>\n"+
            "		<td style=\"border-bottom:2px solid black;\">&nbsp;</td>\n"+
            "		</tr>\n"+
            "\n"+
            "		<tr>\n"+
            "			<td class=\"texteB\">total</td>\n"+
            "			<td class=\"texteR\">"+printf(rs.value("shippingWithoutIva"))+"</td>\n"+
            "			<td class=\"texteR\">"+printf(rs.value("order_shipping_amount"))+"</td>\n"+
            "		</tr>		\n"+
            "\n"+
            "		<tr>\n"+
            "		<td colspan=\"2\" style=\"border-top:2px solid black;\">&nbsp;</td>\n"+
            "		<td style=\"border-top:2px solid black;\">&nbsp;</td>\n"+
            "		</tr>\n"+
            "\n"+
            "		<tr>\n"+
            "			<td></td>\n"+
            "			<td class=\"texteB\">total (antes de impuestos)</td>\n"+
            "			<td class=\"texteR\">"+printf(rs.value("shippingWithoutIva"))+"</td>\n"+
            "		</tr>\n"+
            "\n"+
            "		\n"+
            "		<tr>\n"+
            "			<td></td>\n"+
            "			<td class=\"texteB\">IVA ("+rs.value("iva")+"%)</td>\n"+
            "			<td class=\"texteR\">"+printf(rs.value("shippingIva"))+"</td>\n"+
            "		</tr>\n"+
            "		\n"+
            "		<tr>\n"+
            "			<td></td>\n"+
            "			<td class=\"title2\">total a pagar</td>\n"+
            "			<td class=\"title2\" style=\"text-align:right;\">"+printf(rs.value("order_shipping_amount"))+"</td>\n"+
            "		</tr>\n"+
            "	</table>\n"+
            "			</td>\n"+
            "		</tr>\n"+
            "		<tr>\n" );
            if( koko )
            o.write(
            "            <td class=\"texteB\" colspan=\"2\" style=\"border-bottom:2px solid black;\">Aqu&iacute;­ tienes informaci&oacute;n que te puede interesar</td>\n"+
            "        </tr>\n"+
            "       \n"+
            "        <tr>\n"+
            "            <td class=\"texteS\" colspan=\"2\">&nbsp;<br>\n"+
            "<b>Importante :</b> Conserva este documento como justificante de compra.\n"+
            "            </td>\n"+
            "        </tr>\n"+
            "   \n"+
            "        <tr><td>&nbsp;</td></tr>   \n"+
            "\n"+
            "        <tr>\n"+
            "            <td class=\"texteS\" colspan=\"2\">Oficina de Atenci&oacute;n al Usuario de Telecomunicaciones del Ministerio de Industria, Turismo y Comercio: 901.33.66.99 (precio: 0,04 uer/establec. llamada, 0,03 eur /minuto)\n"+
            "www.usuariosteleco.es. Atenci&oacute;n al cliente de amena: 902010378\n"+
            "            </td>\n"+
            "        </tr>\n"+
            "        <tr>\n"+
            "            <td class=\"texteG\" colspan=\"2\">France Telecom Espa&ntilde;a S.A., Con sede social en Pque. Emp. La Finca. P&ordm; del Club Deportivo, 1 Edif. 8, 28223 Pozuelo de Alarc&oacute;n, Madrid- Inscrita en el Reg. Mercantil de Madrid, Tomo 13. 183, Folio 129, Hoja M-213468, CIF: A-82009812 .\n"+
            "            </td>\n"+
            "        </tr>\n"+
            "</table>\n"+
            "\n"+
            "</body>\n"+
            "\n"+
            "\n"+
            "\n"+
            "</html>\n" );


            else
            o.write(
            "			<td class=\"texteS\" colspan=\"2\">Aqu&iacute;­ tienes informaci&oacute;n que te puede interesar</td>\n"+
            "		</tr>\n"+
            "		\n"+
            "		<tr>\n"+
            "		<td class=\"texteS\" colspan=\"2\" style=\"border-top:2px solid black;\">&nbsp;</td>\n"+
            "		</tr>		\n"+
            "		<tr>\n"+
            "			<td class=\"texteS\" colspan=\"2\">"+
            "<b>Importante :</b> Conserva este documento junto con la garant&iacute;a del terminal para poder hacer uso de la misma si fuera necesario\n"+
            "			</td>\n"+
            "		</tr>\n"+
            "		\n"+
            "		<tr>\n"+
            "			<td class=\"texteS\" colspan=\"2\">&iexcl;Si tienes alguna duda, llamanos!</td>\n"+
            "		</tr>\n"+
            "		<tr>\n"+
            "			<td class=\"texteB\" colspan=\"2\">470: Servicio de atenci&oacute;n al cliente Orange. Si quieres informarte acerca de los servicios que Orange te ofrece: cambios de tarifa,\n"+
            "activaci&oacute;n de promociones, configuraci&oacute;n de buz&oacute;n de voz, ...</td>\n"+
            "		</tr>\n"+
            "		<tr>\n"+
            "			<td class=\"texteG\" colspan=\"2\">Oficina de Atenci&oacute;n al Usuario de Telecomunicaciones del Ministerio de Industria, Turismo y Comercio: 901.33.66.99 (precio: 0,04 uer/establec. llamada, 0,03 eur /minuto)\n"+
            "www.usuariosteleco.es. Atenci&oacute;n al cliente de Orange: 902.01.22.20 (Precio: 0,0833 eur/establec. llamada, 0,0673 eur/minuto)\n"+
            "			</td>\n"+
            "		</tr>\n"+
            "		<tr>\n"+
            "			<td class=\"texteO\" colspan=\"2\">France Telecom Espa&ntilde;a S.A., Con sede social en Pque. Emp. La Finca. P&ordm; del Club Deportivo, 1 Edif. 8, 28223 Pozuelo de Alarc&oacute;n, Madrid- Inscrita en el Reg. Mercantil de Madrid, Tomo 13. 183, Folio 129, Hoja M-213468, CIF: A-82009812 .\n"+
            "			</td>\n"+
            "		</tr>\n"+
            "</table>\n"+
            "\n"+
            "</body>\n"+
            "\n"+
            "\n"+
            "\n"+
            "</html>\n"+
            "\n"+
            "\n"+
            "\n" );

            return(0);
        }
        catch( Exception e )
        {
            e.printStackTrace();
            return(-1);
        }

    }

    public String makePdf( String clid )
    {
        File html = new File( REPOSITORY+"/facturaG_"+clid+".html");
        File pdf = new File(REPOSITORY+"/facturaG_"+clid+".pdf");
        PrintWriter fhtml = null;
        try
        {
            fhtml = new PrintWriter( html ,"utf-8");
            int i = doHtml( clid , fhtml);
            fhtml.close(); fhtml = null;
            if( i!= 0 ) return(null);

            //comment for now
            String cmd = "/home/alban/pjt/eshop/mypdf "+html.toString()+ " "+pdf.toString();

            Process p = Runtime.getRuntime().exec(cmd);
            i = p.waitFor();

            if( i == 0 && pdf.exists() ) return( pdf.toString() );
            //comment for now ends
            return(null);
        }
        catch( Exception e )
        {
            e.printStackTrace();
            return(null);
        }

        finally
        {
            if( fhtml!=null)
                try
                {
                    fhtml.close();
                }
                catch(Exception ee) {}
            /*if(!debug) */
            html.delete();
        }
    }

    public PdfFacturaG( ClientSql Etn , Properties env )
    {
        this.Etn = Etn;
        String s = env.getProperty("PDF_REPO");
        if( s.endsWith("/") ) REPOSITORY = s.substring(0,s.length()-1);
        else REPOSITORY = s;

        debug = env.get("DEBUG")!= null;
    }

    public static void main( String a[] ) throws Exception
    {
        Properties p = new Properties();
        //p.load( PdfFacturaG.class.getResourceAsStream("Scheduler.conf") );
        p.load( com.etn.eshop.SendMail.class.getResourceAsStream("Scheduler.conf") );

        com.etn.Client.Impl.ClientDedie etn = new com.etn.Client.Impl.ClientDedie( "MySql", "com.mysql.jdbc.Driver", p.getProperty("CONNECT") );

        PdfFacturaG pdf = new PdfFacturaG( etn , p );
        String fic = pdf.makePdf( a[0] );
        System.out.println("fichier pdf:"+fic);

    }

}

