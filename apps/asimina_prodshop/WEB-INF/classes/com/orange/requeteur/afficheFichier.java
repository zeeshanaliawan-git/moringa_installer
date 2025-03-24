package com.orange.requeteur;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import javax.servlet.ServletOutputStream;

import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;
import java.io.*;
import java.awt.Graphics2D;
import java.awt.geom.Rectangle2D;
import java.awt.Color;
import java.util.Date;
import java.text.DateFormat;
import java.util.Locale;

import com.lowagie.text.Font;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.ColumnText;
import com.lowagie.text.Element;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Rectangle;
import com.lowagie.text.pdf.DefaultFontMapper;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.FontMapper;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfTemplate;
import com.lowagie.text.pdf.PdfWriter;
import com.lowagie.text.PageSize;
import com.lowagie.text.Image;
import com.lowagie.text.Paragraph;
import com.lowagie.text.FontFactory;


import com.lowagie.text.html.Markup;
import com.lowagie.text.html.HtmlTags;
import com.lowagie.text.html.HtmlWriter;
import com.lowagie.text.html.simpleparser.HTMLWorker;
import com.lowagie.text.html.simpleparser.StyleSheet;

import com.lowagie.text.Header;

import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.hssf.util.AreaReference;
import org.apache.poi.hssf.util.Region;

import com.etn.lang.ResultSet.*;





import org.jfree.chart.JFreeChart;

public class afficheFichier extends HttpServlet {
    public void service(HttpServletRequest req, HttpServletResponse res)
    throws ServletException, java.io.IOException
    {
        try {
            HttpSession session = req.getSession(true);
            Contexte Etn = (Contexte) session.getAttribute("Etn");
            String visu = req.getParameter("visu");
            String nomTdb = (String) session.getAttribute( "nomTdb" );
            File fileName = null;
            if(visu.equals("pdf")){
                String chemin = GlobalParm.getParm("PDF");
                String fic2 = chemin+nomTdb+".pdf";
                fileName = new File(fic2);
                System.out.println("fic2="+fic2);
                doPdf(Etn,session,req,fileName,nomTdb,chemin);
            }
            if(visu.equals("xls")){
                String chemin = GlobalParm.getParm("XLS");
                String fic2 = chemin+nomTdb+".xls";
                fileName = new File(fic2);
                System.out.println("fic2="+fic2);
                doXls(Etn,session,req,fileName,nomTdb,chemin);
            }

            res.setContentType("application/force-download");
            res.setHeader("Content-Disposition", "attachment; filename=\""+nomTdb+"."+visu+"\";");
            InputStream in = new FileInputStream(fileName);
            ServletOutputStream outs = res.getOutputStream();

            try {
                int bit = in.read();
                while ((bit) >= 0) {
                    outs.write(bit);
                       bit = in.read();
                }
            } catch (Exception e) {
                 e.printStackTrace(System.out);
            }
            outs.flush();
            outs.close();
            in.close();
        }catch(Exception ee){
            System.out.println("Err PDF "+getStackTraceAsString(ee)+" !");
        }
    }
    
    public String getStackTraceAsString(Throwable e) {
        java.io.ByteArrayOutputStream bytes = new java.io.ByteArrayOutputStream();
        java.io.PrintWriter writer = new java.io.PrintWriter(bytes, true);
        e.printStackTrace(writer);
        return bytes.toString();
      }
    
    public String libelle_msg(com.etn.beans.Contexte Etn,HttpServletRequest req,String lib){ 
    	String msg="";
    	
//    System.out.println("lib="+lib);
    	if( Etn.lang != 0){
    		HttpSession session =  req.getSession(true);
    	if( session.getAttribute("libelle_msg")==null){ 
    		msg = lib;
    	}else{
    		java.util.HashMap<String,String> h_msg = (java.util.HashMap <String,String>) session.getAttribute("libelle_msg");
    	 //   System.out.println("h_msg="+h_msg.size());
    		String lib2 = lib.replaceAll("[éèêë]","e").toUpperCase();
    		if( h_msg.get(lib2)!=null){
    			if(! h_msg.get(lib2).toString().equals("")){
    				msg = h_msg.get(lib2).toString();
    			}else{
    				msg =  lib;
    			}
    		}else{
    			msg =lib;
//    			Etn.execute("insert IGNORE into langue_msg(LANGUE_REF) values("+ com.etn.sql.escape.cote(lib)+")");
    		}
    	}
    	}else{
    		msg = lib;
    	}
    	return(msg);
    	}

    public void doPdf(com.etn.beans.Contexte Etn,HttpSession session,HttpServletRequest req,File fileName,String nomTdb,String chemin)
    throws Exception {
        int width = 750;
        int height = 450;
        try {
            JFreeChart[] chartTab =(JFreeChart[]) session.getAttribute( "chartTab" );
            PdfPTable[] tabTab = (PdfPTable[]) session.getAttribute( "tabTab" );
            String[] commTab = (String[]) session.getAttribute( "commTab" );
            String[] tabOnglet=(String[]) session.getAttribute( "tabOnglet" );
            String[] tabData = (String[]) session.getAttribute( "tabData" );
            String[] les_tableaux = (String[]) session.getAttribute( "les_tableaux" );
            StyleSheet styles = (StyleSheet) session.getAttribute( "styles" );
            String path_style = (String) session.getAttribute( "path_style" );

           
            
            //java.util.ArrayList objects = (java.util.ArrayList) session.getAttribute( "elt" );

            int flag_tab=0;
            int i = Integer.parseInt((session.getAttribute( "i" )==null?"0":""+session.getAttribute( "i" )),10);
            int nb = Integer.parseInt((session.getAttribute( "nb" )==null?"1":""+session.getAttribute( "nb" )),10);

            //System.out.println("tabData "+tabData.length +" i "+i);
            int k = 0;
            int nb_h =1 ;
            int nb_w =1 ;
            int w =0 ;
            int h =0 ;
            int sp =0;
            int sp_h=0;
            if(nb !=1){
                nb_w =2 ;
                if(nb != 2){
                    nb_h =2 ;
                }
            }

            FontMapper mapper = new DefaultFontMapper();
            OutputStream outFile = new BufferedOutputStream(new FileOutputStream(fileName));
            Rectangle pagesize = new Rectangle(width, height);
            Document document = new Document(PageSize.A4.rotate());
            document.add(new Header(Markup.HTML_ATTR_REL, path_style ));
            PdfWriter writer = PdfWriter.getInstance(document, outFile);
            
            HTMLWorker w1 = new HTMLWorker( document );
           

            document.addAuthor("Orange");
            document.addSubject("Requeteur - Tableau de Bord");
            document.open();
            Image jpg = Image.getInstance(chemin+"logo.jpg");
            jpg.scaleAbsolute(100, 100);
            jpg.setAlignment(Image.LEFT);
            document.add(jpg);
            Paragraph parag = new Paragraph("\n\n\n"+nomTdb,
                    FontFactory.getFont(FontFactory.HELVETICA, 25, Font.BOLD, new Color(0, 0, 0)));
            parag.setAlignment(Element.ALIGN_CENTER);
            document.add(parag);
            DateFormat datedujour = DateFormat.getDateInstance(DateFormat.MEDIUM, Locale.FRANCE);
            Paragraph zonedate=new Paragraph("\n\n\n\n\n\n\n\n\n"+datedujour.format(new Date()),
                    FontFactory.getFont(FontFactory.HELVETICA, 13, Font.BOLD, new Color(0, 0, 0)));
            zonedate.setAlignment(Element.ALIGN_RIGHT);
            document.add(zonedate);
            Paragraph Query=new Paragraph("Requeteur",
                    FontFactory.getFont(FontFactory.HELVETICA, 13, Font.BOLD, new Color(0, 0, 0)));
            Query.setAlignment(Element.ALIGN_LEFT);
            document.add(Query);
           
             
            //StyleSheet styles = new StyleSheet();
            //styles.loadTagStyle("caption", "margin", "auto");

          






             /*java.util.ArrayList objects =  HTMLWorker.parseToList(sr, styles); //new FileReader(urlval.getFile())
            for (int k1 = 0; k1 < objects.size(); k1++) {
                document.add((Element) objects.get(k1));
            }*/



            /*StyleSheet styles = new StyleSheet();
            styles.loadTagStyle("caption", "margin", "auto");
            java.io.StringReader sr = new java.io.StringReader(
            "<div style=\"color=\"red\" \">This is the TITLE in red.</div>");
              java.util.ArrayList list = HTMLWorker.parseToList(sr, styles);

              PdfPTable table = new PdfPTable(1);
              table.addCell( new   com.lowagie.text.pdf.PdfPCell( (Paragraph)list.get(0) ) );
              document.add(table);*/



           for(int j=0; j<i ; j++){
               document.newPage();
               if( les_tableaux[j]!=null ){
                   if(!"".equals(les_tableaux[j])){
                   java.io.StringReader sr = new java.io.StringReader(les_tableaux[j]);
                   w1.setStyleSheet(styles);
                   w1.parse(sr);
                   }
               }
               /*
                  document.newPage();
            //if(  les_tableaux[i]!=null ){

                  // PdfPTable table = new PdfPTable(1);
                 //table.addCell(les_tableaux[0]);
              //	hwriter.add( les_tableaux[0] );
                  //document.add(table);
            //}*/

            if(chartTab[j]!= null){
                    k++;
                    if(k == nb || j==0){
                        document.newPage();
                        if(k == nb)
                            k=0;
                    }
                    switch(k){
                    case 0:
                        w=0;h=0;sp =30;sp_h=30;
                        break;
                    case 1:
                        w=width/nb_w;h=0;sp =60;sp_h=30;
                        break;
                    case 2:
                        w=0;h=height/nb_h;sp =30;sp_h=70;
                        break;
                    case 3:
                        w=width/nb_w;h=height/nb_h;sp =60;sp_h=70;
                        break;
                    }
                    PdfContentByte cb = writer.getDirectContent();
                    PdfTemplate tp = cb.createTemplate(width/nb_w, height/nb_h);
                    Graphics2D g2 = tp.createGraphics(width/nb_w, height/nb_h, mapper);
                    Rectangle2D r2D = new Rectangle2D.Double(0,0,width/nb_w,height/nb_h);
                    //System.out.println(" i "+j+"'");
                    if("1".equals(tabData[j])|| "0".equals(tabData[j])){
                        chartTab[j].draw(g2, r2D);
                    }
                    g2.dispose();
                    cb.addTemplate(tp, w+sp, 595-(height/nb_h)-h-sp_h);
                    if(commTab[j]!= null && !commTab[j].equals("")){
                        PdfTemplate tp2 =  cb.createTemplate(width/nb_w, 80);
                        tp2.beginText();
                        BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
                        tp2.setFontAndSize(bf, 12);
                        tp2.setTextMatrix(0, 80);
                        tp2.setLeading(5);
                        String cpt[] =commTab[j].split("\\\n");
                        for( int a=0; a<cpt.length; a++ ) {
                            tp2.newlineShowText(cpt[a]);
                            tp2.newlineText();                       // try both	newline commands
                        }
                        //tp2.newlineShowText(""+commTab[j]);
                        tp2.endText();

                        //System.out.println(j+" -> "+k+" :"+ w+" "+ h);
                        cb.addTemplate(tp2, w+sp, 595-(height/nb_h)-h-sp_h-80);
                    }
                    if(tabTab[j] != null ){
                        flag_tab =1;
                    }
                }else{
                    if(commTab[j]!=null){
                    document.newPage();
                    Paragraph sstitre = new Paragraph("\n\n\n\n\n"+commTab[j], FontFactory.getFont(FontFactory.HELVETICA, 30, Font.BOLD, new Color(0xFF, 0x55, 0x00)));
                    //Paragraph sstitre = new Paragraph("\n\n\n\n\n"+elt[j], FontFactory.getFont(FontFactory.HELVETICA, 30, Font.BOLD, new Color(0xFF, 0x55, 0x00)));
                    sstitre.setAlignment(Element.ALIGN_CENTER);
                    document.add(sstitre);
                    Paragraph sstitre2 = new Paragraph(" ",
                            FontFactory.getFont(FontFactory.HELVETICA, 13, Font.BOLD, new Color(0xFF, 0x55, 0x00)));
                    sstitre2.setAlignment(Element.ALIGN_CENTER);
                    document.add(sstitre2);
                    k=nb-1;
                    }
                }
            }
            if(flag_tab != 0){
              //  document.newPage();
                Paragraph sstitre = new Paragraph("\n\n\n\n ANNEXES ",
                        FontFactory.getFont(FontFactory.HELVETICA, 30, Font.BOLD, new Color(0xFF, 0x55, 0x00)));
                sstitre.setAlignment(Element.ALIGN_CENTER);
                document.add(sstitre);
                Paragraph sstitre2 = new Paragraph("\n\n (tableaux)",
                        FontFactory.getFont(FontFactory.HELVETICA, 13, Font.BOLD, new Color(0xFF, 0x55, 0x00)));
                sstitre2.setAlignment(Element.ALIGN_CENTER);
                document.add(sstitre2);
                k=nb-1;
                for(int j=0; j<i ; j++){
                    if(tabTab[j] != null ){
                        document.newPage();
                        Paragraph sstitre3 = new Paragraph(""+tabOnglet[j],
                                FontFactory.getFont(FontFactory.HELVETICA, 13, Font.BOLD, new Color(0xFF, 0x55, 0x00)));
                        sstitre3.setAlignment(Element.ALIGN_CENTER);
                        document.add(sstitre3);
                        k=0;
                        tabTab[j].setWidthPercentage(100);
                        document.add(tabTab[j]);

                    }
                }
            }
            document.close();
            outFile.close();
        }catch (IOException e) {
            System.out.println("Unable to execute : \n"+e.getMessage());
        }
    }

    public void doXls(com.etn.beans.Contexte Etn,HttpSession session,HttpServletRequest req,File fileName,String nomTdb,String chemin)
    throws Exception {
        try {
            Set[] tabXls = (Set[]) session.getAttribute( "tabXls" );
            String[] tabOnglet=(String[]) session.getAttribute( "tabOnglet" );
            String y=(String) session.getAttribute( "tableau" );
            String[] les_tableaux = (String[]) session.getAttribute( "les_tableaux" );
           
            HSSFWorkbook wb = new HSSFWorkbook( );
            HSSFSheet sheet = null;
            HSSFRow row = null;
            HSSFCell cell   = null;
            
            
            
            
            for (int sht=0;sht<tabXls.length;sht++){
                int numRow =0;
                String tmp = (sht+1)+"-"+tabOnglet[sht];
                if(tmp.length()>30)
                    tmp = (sht+1)+"-"+tabOnglet[sht].subSequence(0,27);
                tmp=tmp.replaceAll("\\?","_");
                tmp=tmp.replaceAll("\\[","_");
                tmp=tmp.replaceAll("\\]","_");
                tmp=tmp.replaceAll("\\*","_");
                tmp=tmp.replaceAll("\\\\","_");
                tmp=tmp.replaceAll("\\/","_");

                //	/\*?[]
                sheet = wb.createSheet(tmp);
                row = sheet.createRow((short) numRow);
                
                

                
               
              /*  for(int j=0; j<tabXls.length ; j++){
                if( les_tableaux[j]!=null ){
                    if(!"".equals(les_tableaux[j])){
                    	//cell = row.createCell((short) j);
                    	//cell.setCellValue( les_tableaux[j]  );
                    	String ligne[] = les_tableaux[j].split("\n");
                    	for(int l=0;l<ligne.length;l++){
                    		String colonne[] = ligne[l].split("\t");
                    		
                    		
                    		for(int c=0;c<colonne.length;c++){
                    			if( c == 0 ){
                    				if( colonne[c].indexOf("rowspan")!=-1 || colonne[c].indexOf("colspan")!=-1   ){
                    					int r1 = 0;
                    					int c1 = 0;
                    					if( colonne[c].indexOf("rowspan")!=-1  ){
                    						String s = colonne[c];
                    						s = s.substring(colonne[c].indexOf("rowspan")+9);
                    						System.out.println("1.rowspan = " + s);
                    						s = s.substring(0,s.indexOf("'"));
                    						r1 = Short.parseShort(s);
                    						System.out.println("2.rowspan = " + s);
                    					}else{
                    						r1 = 1;
                    					}
                    					if( colonne[c].indexOf("colspan")!=-1  ){
                    						String s = colonne[c];
                    						s = s.substring(colonne[c].indexOf("colspan")+9);
                    						System.out.println("1.colspan = " + s);
                    						s = s.substring(0,s.indexOf("'"));
                    						System.out.println("2.colspan = " + s);
                    						r1 = Short.parseShort(s);
                    					}else{
                    						c1 = 1;
                    					}
                    					
                    					short c2 = Short.parseShort( ""+((c1-1) + c));
                    					int l2 = ((r1-1) + l);
                    					
                    					org.apache.poi.hssf.util.Region  reg=new org.apache.poi.hssf.util.Region(l,(short)c,l2,c2);
                    					row = sheet.createRow((short) l);
                    					cell = row.createCell((short) c);
                                        cell.setCellValue( colonne[c] );
                                        sheet.addMergedRegion(reg);
                    				}else{
                    					row = sheet.createRow((short) l);
                    					cell = row.createCell((short) c);
                                        cell.setCellValue( colonne[c] );
                    				}
                    			}
                    			
                    		}
                    		
                    	}
                    	
                    	
                    		
                    }
                }
                }*/
                
                
                //Set rs=;
                for(int j=0;j < tabXls[sht].Cols;j++){
                    cell = row.createCell((short) j);
                     cell.setCellValue(libelle_msg(Etn,req,tabXls[sht].ColName[j]));
                }
                while(tabXls[sht].next()){
                    numRow ++;
                    row = sheet.createRow((short) numRow);
                    for( int numCell = 0 ; numCell < tabXls[sht].Cols ; numCell++ ){
                        cell = row.createCell((short) numCell);
                        cell.setCellValue(tabXls[sht].value(numCell));
                    }
                }
                
            }




            // Write the output to a file
            FileOutputStream fileOut = new FileOutputStream(fileName);
            wb.write(fileOut);
            fileOut.close();
        }catch (IOException e) {
            System.out.println("Unable to execute : \n"+e.getMessage());
        }
    }

}
















