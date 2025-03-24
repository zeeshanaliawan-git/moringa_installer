package com.etn.eshop.mail;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.List;
import java.util.Properties;


import org.apache.pdfbox.exceptions.COSVisitorException;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.edit.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDType1Font;

import com.etn.lang.ResultSet.Set;


/**
 *
 */


public class NewContrat {
    
 final String REPOSITORY;
 final boolean debug;
 PDPageContentStream contentStream = null;
   
/**
 * Unique Constructeur.
*/
public NewContrat( Properties env )
{
   String s  = env.getProperty("PDF_REPO");
   if( s == null ) REPOSITORY = "/tmp/";
   else if( s.endsWith("/") ) REPOSITORY=s;
   else REPOSITORY=s+"/";

   debug = env.get("DEBUG")!= null;
}
/**
 * Ecrit un caractère tradeMark en absence de celui-ci dans la font.
 * Inutilisé ( @see specialTrans )
void tradeMark( int x , int y ,  PDType1Font font,int size_font )
throws IOException
{ 
  int j = size_font / 2 ;
  write_txt( "T" , x , y+j , font , j );
  write_txt( "M" , x+j-2 , y+j  , font , j );
} 

**/

    
/**
 * Certains caractères sont incorrectement mappés
 * cas TM par exemple.
 * @param source
 * @return source mappée.
*/
String specialTrans( String s )
{ char c[] = s.toCharArray();

  for( int i = 0 ; i < c.length ; i++ )
    if( c[i] == (char)8482 ) // TM
      c[i] = (char)153;
    else if(  c[i] == (char)8364 )  // Euro
      c[i] = (char)128;

  return( new String(c));

}
    
/**
 * Bétonnage au cas qry source pointe des champs 
 * inexistants.
 * On en profite pour mapper certains chars.
 * @return un string affichable.
*/
String parseNull(String str) 
{
  try { return( specialTrans(str.trim())); } 
  catch (Exception e) { return(""); }
}
 
/**
 * Ajoute @param space(s) caratère entre chaque caractère
 * du @param word.
 * @return le résultat.
*/  
String spacing( String word,String space)
{
  String retour="";
  for(int i=0; i <word.length();i++)
        if(i == word.length()-1)
            retour+=word.charAt(i);
        else
            retour+=word.charAt(i)+space;
                  
  return retour;
}

/**
 * Ecriture d'un texte à postion précise
*/
void write_txt( String text, double x,double y , PDType1Font font,int size_font)
throws Exception
{
   contentStream.setFont(font, size_font);
   contentStream.beginText();
   contentStream.moveTextPositionByAmount((float)x,(float)y);
   contentStream.drawString(text );
   contentStream.endText();
}

    
/**
 * Permet d' ecrire du text dans le pdf
 * @param text  :le text a ecrire
 * @param x  : postion selon l' axe x
 * @param y  : postion selon l' axe y
 * @param font  : la font a utilise 
 * @param size_font  
*/
void write_txt( String text, int x,int y , PDType1Font font,int size_font) 
throws IOException
{
   contentStream.setFont(font, size_font);
   contentStream.beginText();
   contentStream.moveTextPositionByAmount(x,y);
   contentStream.drawString(text );
   contentStream.endText();        
}

/**
 * Ecrit le @param text en séparant chaque caractères 
 * par @param space unité( float).
*/
void write_chars( String text , int x , int y , PDType1Font font,int size_font , float space ) throws Exception
  { 
     
     contentStream.setFont(font, size_font);
     contentStream.beginText();
     contentStream.moveTextPositionByAmount(x,y);
    
     for( int i = 0 ; i < text.length(); i++ )
     { contentStream.drawString(""+text.charAt(i) );
       contentStream.moveTextPositionByAmount(space,0);
     }
     contentStream.endText();
  }

 
/**
 * The Method.
 * @param model : le modèle pdf.
 * @param rs : un row courant ( rs.next à déjà été appelé ).
 * @return : le nom du fichier produit ou null sur erreur.
*/    

String makePdf( String model , Set rs )
{
  PDDocument document = null;

  try 
  {
        
   document = new PDDocument();
   // bug library: warning initialized true n'est pas mis à jour sur close ...
   document.getDocument().setWarnMissingClose(false); // on force à false...

   document = PDDocument.load(model);
   List<?> allPages = document.getDocumentCatalog().getAllPages();
   PDPage page = (PDPage) allPages.get(0);
        
   contentStream = new PDPageContentStream(document, page,true,true,true);

   //PDType1Font font = PDType1Font.TIMES_ROMAN;
   PDType1Font font = PDType1Font.HELVETICA_BOLD ;

   String uniq = "__"+rs.value("customerid");

   if( uniq == null || uniq.length() < 4 ) 
          return( null );

   uniq = "/tmp/"+uniq;
        
   String cod_solicidud_porta=parseNull(rs.value("cod_solicidud_porta"));

   int offX = 110 , offY = -10;

   write_txt( cod_solicidud_porta,420,771,font,8);

   String sfid = parseNull(rs.value("sfid"));
   //write_txt( sfid,203,704,font,8);
   //write_txt( spacing(sfid,"   "),204, 704,font,8);
   write_chars( sfid,204, 704,font,8,(float)11.6);
        
   String orderType=parseNull(rs.value("orderType"));
   if(orderType.startsWith("alta"))
      write_txt( "X",184.0, 730.3,font,12);
   else if(orderType.startsWith("migra"))
      write_txt( "X",248, 730,font,12);
   else if(orderType.startsWith("porta"))
      write_txt( "X",318, 730,font,12);

//                page 4:

   String Nombre = parseNull(parseNull(rs.value("nombre")));
   write_txt( Nombre,92, 678,font,8);

   String appelidos = parseNull(rs.value("apelidos"));
   write_txt( appelidos,262, 678,font,8);

    String direccion = parseNull(rs.value("roadtype"))+ " " +
       parseNull(rs.value("roadname"));
    write_txt( direccion,92, 668,font,8); 

    String N = parseNull(rs.value("roadnumber"));
    write_txt( spacing(N,"  "),375, 668,font,8); 

    String escaalera = parseNull(rs.value("stair"));
    write_txt( escaalera,440, 668,font,6); 

    String piso = parseNull(rs.value("floornumber"));
    write_txt( piso,485, 668,font,6); 

    String puerta = parseNull(rs.value("apartmentNumber"));
    write_txt( puerta,535, 668,font,5); 

    String localidad = parseNull(rs.value("localidad"));
    write_txt( localidad,92, 657,font,8);   

    String provincia = parseNull(rs.value("state"));
    write_txt( provincia,322, 657,font,8);

    String code_post = parseNull(rs.value("postalCode"));
    write_txt( spacing(code_post,"   "),498, 657,font,8);

    String tipo_doc = parseNull(rs.value("identityType"));
    write_txt( tipo_doc,179, 647,font,8);

    String n_doc = parseNull(rs.value("identityId"));
    write_txt( spacing(n_doc, "    "),356, 647,font,8);

    String fecha_nacimento  = parseNull(rs.value("dateOfBirth"));
    if(!fecha_nacimento.equals(""))
    {
      String day=fecha_nacimento.split("/")[0];
      write_txt( spacing(day, "  "),119, 637,font,8);
      String month=fecha_nacimento.split("/")[1];
      write_txt( spacing(month, "  "),145, 637,font,8);
      String year=fecha_nacimento.split("/")[2];
      write_txt( spacing(year, "   "),168, 637,font,8);
    }
        
       
   String nacionalidad  = parseNull(rs.value("nationality"));
   write_txt( nacionalidad,254, 637,font,8);
        
   String sexo  = parseNull(rs.value("sex"));
   if(sexo.equalsIgnoreCase("H"))
     write_txt( "X",501.4, 633.7,font,12);
    else if(sexo.equalsIgnoreCase("M"))
     write_txt( "X",521, 634,font,12);
        
  String telefono_contacto  = parseNull(rs.value("contactPhoneNumber1"));
  write_txt( spacing(telefono_contacto, "   "),133, 626,font,8);
        
        
  String email  = parseNull(rs.value("email"));
  write_txt( email,265, 627,font,8);

// forma de pago : Non

//  write_txt("recibo domiciliado" ,110,540,font,8);
 
  String cuenta_bancaria  = parseNull(rs.value("account"));
  if(!cuenta_bancaria.equals(""))
  {
    String entidad=cuenta_bancaria.split("-")[0];
    write_txt( spacing(entidad, "   "),132, 507,font,8);
    String sucursal=cuenta_bancaria.split("-")[1];
    write_txt( spacing(sucursal, "   "),206, 507,font,8);
    String DC=cuenta_bancaria.split("-")[2];
    write_txt( spacing(DC, "   "),264, 507,font,8);
    String cuntea=cuenta_bancaria.split("-")[3];
    write_txt( spacing(cuntea, "   "),312, 507,font,8);
   }
      


//
//                page 5:

  String msisdn  = parseNull(rs.value("msisdn"));
  String iccid_donante  = parseNull(rs.value("previousIccIdSim"));
  switch( iccid_donante.length() )
  { case 17 : iccid_donante = "89"+iccid_donante; break;
    case 15 : iccid_donante = "893"+iccid_donante; break;
  }

  if( iccid_donante.startsWith("8934") )
     iccid_donante = iccid_donante.substring(4);

        
  if( rs.value("ordertype").toLowerCase().indexOf("porta") != - 1  )
  {

       
  write_txt( Nombre,93, 455,font,8);
  write_txt( appelidos,270, 455,font,8);
  write_txt( tipo_doc,188, 444,font,8);
  write_txt( spacing(rs.value("identityid"), "   "),345, 444,font,8); 
  write_txt( nacionalidad,105, 435,font,8);
        
  String operator_Donante  = parseNull(rs.value("previousOperator"));
  write_txt( operator_Donante,120, 407,font,8);

  String  tarjeta_contrato  = parseNull(
         rs.value("forma_pago_donante"));
  if(tarjeta_contrato.startsWith("C"))
      write_txt( "X",378, 397,font,8);
  else if(tarjeta_contrato.startsWith("T"))
      write_txt( "X",263, 397,font,8); // tjt ou prepago

  //write_txt( spacing(msisdn, "  "),63, 398,font,8);
  write_chars( msisdn , 63, 372,font,8 , (float)10.2 );

   
   //write_txt( spacing(iccid_donante, "  "),220, 398,font,8);
   write_chars( iccid_donante,219, 371,font,8, (float)10.3);
        

  if(tarjeta_contrato.startsWith("C"))
    write_txt( "C",374, 371,font,12);
  else if(tarjeta_contrato.startsWith("T"))
    write_txt( "T",374, 371,font,12);

        
        
        
  String aa   = parseNull(rs.value("changeWindowDate"));
  if( aa.length() < 10) aa = "           ";
  write_txt( ""+aa.charAt(0),175,372,font,8);
  write_txt( ""+aa.charAt(1),182,372,font,8);
  write_txt( ""+aa.charAt(3),219,372,font,8);
  write_txt( ""+aa.charAt(4),226,372,font,8);
  for( int i = 0 ; i < 4 ; i++ )
    write_txt( ""+aa.charAt(i+6),263+(i*10),372,font,8);

}

//
//                =====================================================
//                Page 6:
        

  //write_txt( spacing(msisdn, "   "),127, 314,font,8);
  write_chars( msisdn, 127, 306,font,8,(float)10.2);
        
  String ICCID_Orange   = parseNull(rs.value("iccidSim"));
  //write_txt( ICCID_Orange,112, 297,font,8);
  if( orderType.startsWith("migra") )
     ICCID_Orange = "8934"+iccid_donante;
  
  //write_chars( ICCID_Orange,104, 288,font,8,(float)6.8);
  write_txt( ICCID_Orange,110, 288,font,8);

  // SmartSim
  String smart=rs.value("iccsmart");
  if( smart.length() > 0 )
    write_txt( smart,270, 288,font,8);

  String tarif   = parseNull(rs.value("tarif"));
  String tarifdata =  parseNull(rs.value("tarifdata"));
  int i;
  String recargar = null;
  
  if( ( i = tarif.toLowerCase().indexOf("recarga") ) >= 0 )
  { 
    recargar = tarif.substring(i);
    if( recargar.indexOf("20") != -1 ) recargar = "20";
    else if( recargar.indexOf("10") != -1 ) recargar = "10";
    
    if( recargar != null ) 
      tarif = tarif.substring(0,i);
  }
  
  //if( tarif.length() == 0 ) 
  //  tarif = tarifdata; 
  
  write_txt( tarif,77, 275,font,8);
  write_txt( tarifdata,412, 275,font,8);
  

  String compromiso_operador   = parseNull(rs.value("cpOperator"));
  write_txt( compromiso_operador,210, 264,font,8);

  String compromiso_voz    = parseNull(rs.value("cpTarifV"));
  write_txt( compromiso_voz,335, 264,font,8);

  String compromiso_data    = parseNull(rs.value("cpTarifD"));
  write_txt( compromiso_data,475, 264,font,8);

  if( recargar != null ) 
  { if( "10".equals( recargar ) )
       write_txt( "X" ,168, 248,font,8);
    else  if( "20".equals( recargar ) )
       write_txt( "X" ,208.60, 248,font,8);
  }

// On line
   write_txt( "X",242, 195,font,8);



//                Page 7:

  String imei    = parseNull(rs.value("imei"));
  if(!imei.equals("111111111111119"))
     // write_txt( spacing(imei, "   "),77, 174,font,8);
     write_chars( imei, 79, 168,font,8,(float)11.7);
       
  write_txt( "X",321, 168,font,8);

  String marca_modelo    = parseNull(rs.value("terminal"));
  write_txt( marca_modelo,425,168,font,8);


// terminal2
  String imei2 = rs.value("imeiterm2");
  if( imei2.length() > 0 )
  {  write_chars( imei2, 85, 159,font,8,(float)11.5);
     String zz[] = rs.value("terminal2").split(":",-1) ;
     if( zz.length > 1 ) 
       write_txt( zz[1] , 425 , 158, font,8);

     write_txt( "X",321, 157,font,8);

   }  


   write_txt( "Aceptado   por   el", 83 , 54 , font , 7 );
   write_txt( "cliente  electrónica",83 , 47, font,7);
   write_txt( "o  telefónicamente.", 83, 40, font , 7 );


   String fecha    = parseNull(rs.value("creationDate"));
   write_txt( fecha,83, 20,font,7);

   // nouvelle  partie
   write_txt( "Aceptado   por   el", 183 , 54 , font , 7 );
   write_txt( "cliente  electrónica",183 , 47, font,7);
   write_txt( "o  telefónicamente.", 183, 40, font , 7 );


   String fecha1    = parseNull(rs.value("creationDate"));
   write_txt( fecha1,184, 20,font,7);


   contentStream.close();
   contentStream = null;

   document.save(  ""+uniq+".pdf");
   document.close(); 
   document = null;

        
        
   File fok = new File( uniq+".pdf"); 
   if(  fok.exists() ) 
      return( uniq+".pdf" );

   return( null );
        
        
 }
 catch( Exception e )
 { e.printStackTrace();
   return(null);
 }

 finally
 { 

  if( contentStream != null )
    { try { contentStream.close(); }
      catch( Exception gonfle) { gonfle.printStackTrace(); }
    }


  if( document != null )
    { try { document.close(); }
      catch( Exception gonfle2) { gonfle2.printStackTrace(); }
    }

   contentStream = null;
   document = null;
 }

}

    
/**
 * Pour Test...
*/   
public static void main(String[] args) throws Exception  
{

  Properties p = new Properties();
  p.put("CONNECT", 
         "jdbc:mysql://127.0.0.1:13306/eshop?user=root&password=");
  p.put("PDF_REPO",".");



 String sql=  "select p.*, c.*, "+
                "p.id as wkid, "+
                "c.creationDate as fecha,c.ordertype," +
                "substring(portabilityCodeRequest,3) as cod_solicidud_porta,"+
                     "previousOperator as opdonante, day(creationDate) as dia ,"+
                     "month(creationDate) as mes ,  year(creationDate) as ano, "+
                     "hour(creationDate) as heure , minute(creationDate) as minute, "+
                     " iccidsim as sim ,"+
                     " day(changeWindowDate) as ordia, month(changeWindowDate) as ormois,"+
                     "year(changeWindowDate) as oran, "+
                     " case (typeOfPaymentCurrentOperator) "+
                     "when 'contrato' then 'C'"+
                     "when ('tjt' or 'prepago') then 'T'"+
                     "end as forma_pago_donante ,"+
                              "previousIccidSim as simDonante,"+
                              "name as nombre,"+
                              "surnames as apelidos,"+
                              "identityType as tipodoc,"+
                              "identityId as numdoc,"+
                              "if(sex='H','M','F') sexo,"+
                              "nationality as natio,"+
                              "dateOfBirth as naciemento,"+
                              "roadname as domicilio,"+
                              "roadNumber as num,"+
                              "locality as localidad,"+
                              "postalcode as cp "+
                " from post_work p inner join customer c "+
                " on p.client_key = c.customerid where p.id = "+2051629 ; 
        System.out.println("sql====:"+sql);


        com.etn.Client.Impl.ClientDedie Etn =  
          new com.etn.Client.Impl.ClientDedie( "MySql",
       "com.mysql.jdbc.Driver",
       //"jdbc:mysql://127.0.0.1:13306/eshop?user=root&password=" );
       p.getProperty("CONNECT") );

        com.etn.lang.ResultSet.Set rs =Etn.execute(sql);
        rs.next();

        NewContrat nc = new NewContrat( p );
        String pdffile = nc.makePdf("result.pdf", rs);
        
    }
}
