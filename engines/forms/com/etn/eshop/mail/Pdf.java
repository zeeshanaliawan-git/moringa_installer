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
 * Stub pour Pdf Read Only.
 *
 */
public class Pdf {
    
 final String REPOSITORY;
 final boolean debug;
 PDPageContentStream contentStream = null;
   
/**
 * Constructeurs.
*/
public Pdf( Properties env )
{
   String s  = env.getProperty("PDF_REPO");
   if( s == null ) REPOSITORY = "/tmp/";
   else if( s.endsWith("/") ) REPOSITORY=s;
   else REPOSITORY=s+"/";

   debug = env.get("DEBUG")!= null;
}
/**
 * Pour MakePdf
*/
public Pdf() { REPOSITORY="/tmp/"; debug=false; }

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
    
public String makePdf( String model , Set rs )
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

   String uniq = "contrat_"+rs.value("wkid")+"_"+rs.value("customerid");

   if( uniq == null || uniq.length() < 4 ) 
          return( null );

   uniq = REPOSITORY+uniq;
 
/***** Exemple  
        
   String cod_solicidud_porta=parseNull(rs.value("cod_solicidud_porta"));
   write_txt( cod_solicidud_porta,420,771,font,8);

   String sfid = parseNull(rs.value("sfid"));
   write_txt( sfid,95,714,font,8);
        
   String orderType=parseNull(rs.value("orderType"));
   if(orderType.startsWith("alta"))
      write_txt( "X",184, 721,font,12);
   else if(orderType.startsWith("migra"))
      write_txt( "X",248, 721,font,12);
   else if(orderType.startsWith("porta"))
      write_txt( "X",318, 720,font,12);

  etc...
********/

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
*   
public static void main(String[] args) throws Exception  
{

  Properties p = new Properties();
  p.load( com.etn.eshop.SendMail.class.getResourceAsStream("Scheduler.conf") );

   com.etn.Client.Impl.ClientDedie etn =
    new com.etn.Client.Impl.ClientDedie( "MySql",
       "com.mysql.jdbc.Driver",
       p.getProperty("CONNECT") );




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

        Pdf nc = new Pdf( p );
        String pdffile = nc.makePdf("result.pdf", rs);
        
    }
***/
}
