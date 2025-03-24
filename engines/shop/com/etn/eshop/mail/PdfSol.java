package com.etn.eshop.mail;

import com.etn.lang.ResultSet.Set;
import com.etn.io.BaliseInputFilter;
import java.util.HashMap;
import java.util.Properties;
import java.util.Hashtable;
import java.io.* ;


public class PdfSol {

final char iso2pdf[] = {
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0xcb, 0xe7, 0xe5, 0xcc, 0x80, 0x81, 0x00, 0x82,
 0xe9, 0x83, 0xe6, 0xe8, 0xed, 0xea, 0xeb, 0xec,
 0x00, 0x84, 0x00, 0xee, 0xef, 0xcd, 0x85, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x86, 0x00, 0x00, 0x00,
 0x88, 0x87, 0x89, 0x8b, 0x8a, 0x8c, 0x00, 0x8d,
 0x8f, 0x8e, 0x90, 0x91, 0x93, 0x92, 0x94, 0x95,
 0x00, 0x96, 0x98, 0x97, 0x99, 0x9b, 0x9a, 0x00,
 0x00, 0x9d, 0x9c, 0x9e, 0x9f, 0x00, 0x00, 0x00 };



String toPdf( String iso )
{
  StringBuilder sb = new StringBuilder();
  int c,m;

  if( iso == null ) return(iso);

  if( iso.indexOf("&#8482;") != -1 )
     iso = iso.replace("&#8482;", "\\252");
  for( int i = 0 ; i < iso.length(); i++ )
    { c = iso.charAt(i) & 255;
      if( c > 128 && ( m = iso2pdf[c-128] ) != 0 )
        sb.append("\\"+Integer.toOctalString(m));
      else sb.append((char)c);
    }

  return( sb.toString() );
}

final String REPOSITORY;
final boolean debug;

public PdfSol( Properties env )
{
   String s  = env.getProperty("PDF_REPO");
   if( s == null ) REPOSITORY = "/tmp/";
   else if( s.endsWith("/") ) REPOSITORY=s;
   else REPOSITORY=s+"/";

   debug = env.get("DEBUG")!= null;
}
public PdfSol() { REPOSITORY="/tmp/"; debug=false; }


Hashtable<String,String> tags;


public String makePdf( String model , Set rs )
{

 Process gs = null;
 String uniq = "sol_"+rs.value("wkid")+"_"+rs.value("customerid");

 if( uniq == null || uniq.length() < 4 )
   return( null );

 uniq = REPOSITORY+uniq;

 try {

  tags = new Hashtable<String,String>();

    // datas du client.....
  tags.put("cod_solicidud_porta",toPdf(rs.value("cod_solicidud_porta")));
  tags.put("opdonante",toPdf(rs.value("opdonante")));
  tags.put("dia",toPdf(rs.value("dia")));
  tags.put("mes",rs.value("mes"));
  tags.put("ano",toPdf(rs.value("ano")));
  tags.put("heure",rs.value("heure"));
  tags.put("minute",rs.value("minute"));

  tags.put("ordia",toPdf(rs.value("ordia")));
  tags.put("ormois",rs.value("ormois"));
  tags.put("oran",toPdf(rs.value("oran")));

  tags.put("sim",toPdf(rs.value("sim")));

  // Orange contrat ou prepaye ..???
  if( rs.value("ordertype").equalsIgnoreCase("portabilidad contrato") )
     tags.put("orpay","C");
  else if( rs.value("ordertype").equalsIgnoreCase("portabilidad prepago") )
     tags.put("orpay","T");

  tags.put("forma_pago_donante",rs.value("forma_pago_donante"));
/**
  if(rs.value("forma_pago_donante").equals("T"))
  tags.put("forma_pago_donante1",toPdf(rs.value("forma_pago_donante")));
  else if(rs.value("forma_pago_donante").equals("C"))
          tags.put("forma_pago_donante2",toPdf(rs.value("forma_pago_donante")));
 **/
  tags.put("msisdn",toPdf(rs.value("msisdn")));
  tags.put("simDonante",toPdf(rs.value("simDonante")));
  tags.put("nombre",toPdf(rs.value("nombre")));
  tags.put("apelidos",toPdf(rs.value("apelidos")));
  tags.put("tipodoc",toPdf(rs.value("tipodoc")));



  tags.put("numdoc",rs.value("numdoc"));


  if( rs.value("sexo").equalsIgnoreCase("h") )
  { tags.put("1man","X"); tags.put("1woman",""); }
 else
 {  tags.put("1man",""); tags.put("1woman","X"); }


  tags.put("natio",toPdf(rs.value("natio")));
  tags.put("naciemento",rs.value("naciemento"));
  tags.put("1nacionalidad",toPdf(rs.value("nationality")));
  tags.put("domicilio",toPdf(rs.value("domicilio")));


  tags.put("num",rs.value("num"));
  tags.put("escalera",rs.value("num"));
  tags.put("piso",rs.value("piso"));
  tags.put("puerta",rs.value("puerta"));

  tags.put("localidad",toPdf(rs.value("localidad")));
  tags.put("provincia",toPdf(rs.value("provincia")));
  tags.put("cp",toPdf(rs.value("cp")));

  tags.put("telcontacto",rs.value("telcontacto"));
  tags.put("nombredest","TIENDAMOVIL ORANGE");
  tags.put("sfid",rs.value("sfid"));
  tags.put("dateAcceptClient",rs.value("dateAcceptClient"));





BaliseInputFilter filter = new BaliseInputFilter (
   new BufferedInputStream (
      new FileInputStream( model )),  tags,
   "<"+"%=", "%"+">" , false );

FileOutputStream ps = new FileOutputStream(uniq+".ps");

byte b[] = new byte[8192];
int i;

while( ( i = filter.read(b) ) > 0 )
  ps.write( b,0,i);

filter.close();
ps.close();


String cmd = "/usr/bin/gs -dSAFER -dCompatibilityLevel=1.4 -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="+uniq+".pdf -dSAFER -dCompatibilityLevel=1.4 -c .setpdfwrite -f "+uniq+".ps" ;

Process p = Runtime.getRuntime().exec( cmd );
i = p.waitFor();

File fok = new File( uniq+".pdf");
if( i == 0 && fok.exists() )
  return( uniq+".pdf" );

return( null );

}

catch( Exception e )
{ e.printStackTrace(); return(null); }


finally { new File( uniq+".ps" ).delete(); }

}

}
