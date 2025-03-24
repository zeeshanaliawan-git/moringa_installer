<%/*!java.awt.Color getColorAppli(String lib){
      java.awt.Color c = null;
      if(lib.equalsIgnoreCase("1800")) c = new Color(0, 0, 0);
      if(lib.equalsIgnoreCase("900")) c = new Color(255, 255, 255);
      if(lib.equalsIgnoreCase("P2P")) c = new Color(255, 0, 0);
      if(lib.equalsIgnoreCase("FTP")) c = new Color(0, 255, 0);
      if(lib.equalsIgnoreCase("News")) c = new Color(0, 0, 255);
      if(lib.equalsIgnoreCase("Mail")) c = new Color(255, 255, 0);
      if(lib.equalsIgnoreCase("DB")) c = new Color(255, 0, 255);
      if(lib.equalsIgnoreCase("Others")) c = new Color(0, 247, 255);
      if(lib.equalsIgnoreCase("Control")) c = new Color(127, 0, 0);
      if(lib.equalsIgnoreCase("Games")) c = new Color(255, 99, 49);
      if(lib.equalsIgnoreCase("Streaming")) c = new Color(0, 0, 127);
      if(lib.equalsIgnoreCase("Chat")) c = new Color(127, 127, 0);
      if(lib.equalsIgnoreCase("VoIP")) c = new Color(127, 0, 127);
      if(lib.equalsIgnoreCase("MailOrange")) c = new Color(0, 127, 127);
      if(lib.equalsIgnoreCase("VPN")) c = new Color(191, 191, 191);
      if(lib.equalsIgnoreCase("VVM")) c = new Color(127, 127, 127);
      if(lib.equalsIgnoreCase("MMS")) c = new Color(156, 156, 255);
      if(lib.equalsIgnoreCase("StreamAVSP")) c = new Color(156, 49, 99);
      if(lib.equalsIgnoreCase("OrangePortal")) c = new Color(255, 255, 206);
	
      System.out.println("COLOR("+lib+") ================>"+(c==null?"":c.toString()));
      return(c);
}
String[] getTabColor(){
      return( new String[]{"1800","90","P2P","FTP","News","Mail","DB","Others","Control","Games","Streaming","Chat","VoIP","MailOrange","VPN","VVM","MMS","StreamAVSP","OrangePortal"});
}*/
%>


<%!

/*writing color wrapper :D */

void seriesColorSetter(JFreeChart chart ,javax.servlet.http.HttpServletRequest req,String colColors,String valColors){
    String temp[] =colColors.split("-");
            
               for(int i=0;i<temp.length;i++){

                   if(temp.length>0 && temp[i]!=""){
                   String temp2[] =temp[i].split(":");

                   int index=Integer.parseInt(temp2[0]);
                   
                   String temp3[] =temp2[1].split(",");

                   int r=Integer.parseInt(temp3[0]);
                   int g=Integer.parseInt(temp3[1]);
                   int b=Integer.parseInt(temp3[2]);

               CategoryPlot plot = chart.getCategoryPlot();
               CategoryItemRenderer renderer = plot.getRenderer();
               renderer.setSeriesPaint(index, new Color(r, g, b));

                   }

               }
               //System.out.println("innnnnnnnnnnnnnnnnnnnnnnn="+valColors);

               String valtemp[] =valColors.split("-");

               for(int i=0;i<valtemp.length;i++){
                    


                   if(valtemp.length>0 && valtemp[i]!=""){
                   String temp2[] =valtemp[i].split(":");

                   int index=Integer.parseInt(temp2[0]);

                   String temp3[] =temp2[1].split(",");

                   int r=Integer.parseInt(temp3[0]);
                   int g=Integer.parseInt(temp3[1]);
                   int b=Integer.parseInt(temp3[2]);

                   //System.out.println("$$$$$$$$$$$$$$$$$$$$="+r+","+g+","+b+" ind="+index);
                     
                   CategoryPlot plot = chart.getCategoryPlot();
                   CategoryItemRenderer renderer = plot.getRenderer();
                    //renderer.setSeriesPaint(index, new Color(r, g, b));
                    //renderer.setSeriesPaint(0,new Color(70,194,31));
                     //renderer.setSeriesItemLabelPaint(0,new Color(70,194,31));
                    //BarRenderer barRenderer = (BarRenderer)plot.getRenderer();

                    }
               }
    }






/********/
 
void StackedBar_format( JFreeChart chart ,javax.servlet.http.HttpServletRequest req){

                
               
               /*color edit*/
               //seriesColorSetter(chart,req,colColors,valColors);
               
               /*CategoryPlot plot = chart.getCategoryPlot();
               CategoryItemRenderer renderer = plot.getRenderer();
               renderer.setSeriesPaint(0, new Color(219, 21, 219));
               renderer.setSeriesPaint(1, new Color(219, 21, 21));
               renderer.setSeriesPaint(2, new Color(192, 192, 192));
               renderer.setSeriesPaint(3, new Color(64, 64, 64));
               renderer.setSeriesPaint(4, new Color(255, 204, 102));
               renderer.setSeriesPaint(5, new Color(255, 153, 0));
		
               StackedBarRenderer renderer2 = (StackedBarRenderer) plot.getRenderer();
               renderer2.setShadowVisible(false);
               */
	
		
       /*	java.util.List ls = plot.getCategories();
               java.awt.Color[] c = new java.awt.Color[ls.size()];
               for(int i=0;i<ls.size();i++){
                     System.out.println(" StackedBar_format====> " + ls.get(i));
                     c[i] = getColorAppli(""+ls.get(i));
                     plot.getRenderer().setSeriesPaint(i, c[i]);

               }
		
               CategoryAxis domainAxis = plot.getDomainAxis();*/
	
		
}

void Histo_format(JFreeChart chart ,javax.servlet.http.HttpServletRequest req){
                
               // seriesColorSetter(chart,req,colColors,valColors);

              // CategoryPlot plot = chart.getCategoryPlot();
               /*CategoryItemRenderer renderer = plot.getRenderer();
               renderer.setSeriesPaint(0, new Color(255, 102, 0));
               renderer.setSeriesPaint(1, new Color(128, 128, 128));
               renderer.setSeriesPaint(2, new Color(192, 192, 192));
               renderer.setSeriesPaint(3, new Color(64, 64, 64));
               renderer.setSeriesPaint(4, new Color(255, 204, 102));
               renderer.setSeriesPaint(5, new Color(255, 153, 0));*/
               //renderer.setShadowVisible(false);
               /*java.util.List ls = plot.getCategories();
               java.awt.Color[] c = new java.awt.Color[ls.size()];
               for(int i=0;i<ls.size();i++){
                     System.out.println(" Histo_format====> " + ls.get(i));
                     c[i] = getColorAppli(""+ls.get(i));
                     plot.getRenderer().setSeriesPaint(i, c[i]);

               }*/
	 
}

void Ligne_format(JFreeChart chart ,javax.servlet.http.HttpServletRequest req){
       // CategoryPlot plot = chart.getCategoryPlot();

            
               //seriesColorSetter(chart,req,colColors,valColors);



               
               LineAndShapeRenderer renderer = new LineAndShapeRenderer();
               /*renderer.setSeriesPaint(0, Color.black);
               renderer.setSeriesPaint(1, new Color(255, 2, 2));
               plot.setRenderer(0, renderer);*/
		
               for(int h=0;h<255;h++){
                       renderer.setSeriesShape(h, new java.awt.geom.Rectangle2D.Double(-3.0, -3.0, 6.0, 6.0));
               }
		
               /*java.util.List ls = plot.getCategories();
               java.awt.Color[] c = new java.awt.Color[ls.size()];
               for(int i=0;i<ls.size();i++){
                     System.out.println(" Ligne_format====> " + ls.get(i));
                     c[i] = getColorAppli(""+ls.get(i));
                     plot.getRenderer().setSeriesPaint(i, c[i]);

               }*/
		
	 
}



void Camembert_format(JFreeChart chart ,javax.servlet.http.HttpServletRequest req){
               PiePlot p = (PiePlot) chart.getPlot();

               

               /***Some Color tranformation :D***/

               /*String temp[] =colColors.split("-");

               for(int i=0;i<temp.length;i++){

                   

                   if(temp.length>0 && temp[i]!=""){
                   String temp2[] =temp[i].split(":");

                   int index=Integer.parseInt(temp2[0]);
                   
                   String temp3[] =temp2[1].split(",");

                   int r=Integer.parseInt(temp3[0]);
                   int g=Integer.parseInt(temp3[1]);
                   int b=Integer.parseInt(temp3[2]);

                   p.setSectionPaint(index, new Color(r, g, b));

                   }

               }*/

               
               /* * * * * */

        /*	p.setSectionPaint(0, new Color(255, 102, 0));
               p.setSectionPaint(1, new Color(128, 128, 128));
               p.setSectionPaint(2, new Color(192, 192, 192));
               p.setSectionPaint(3, new Color(64, 64, 64));
               p.setSectionPaint(4, new Color(255, 204, 102));
               p.setSectionPaint(5, new Color(255, 153, 0));*/
}



void HistoLigne_format(JFreeChart chart ,javax.servlet.http.HttpServletRequest req){
        

        

       // seriesColorSetter(chart,req,colColors,valColors);

       /* java.util.List ls = plot.getCategories();
               java.awt.Color[] c = new java.awt.Color[ls.size()];
               for(int i=0;i<ls.size();i++){
                     System.out.println(" HistoLigne_format====> " + ls.get(i));
                     c[i] = getColorAppli(""+ls.get(i));
                     plot.getRenderer().setSeriesPaint(i, c[i]);

               }*/
		
		
	 
}



void Aire_format(JFreeChart chart ,javax.servlet.http.HttpServletRequest req){
        

        
	 //seriesColorSetter(chart,req,colColors,valColors);
       /* java.util.List ls = plot.getCategories();
               java.awt.Color[] c = new java.awt.Color[ls.size()];
               for(int i=0;i<ls.size();i++){
                     System.out.println(" Aire_format====> " + ls.get(i));
                     c[i] = getColorAppli(""+ls.get(i));
                     plot.getRenderer().setSeriesPaint(i, c[i]);

               }*/
}


void WebPlot_format(JFreeChart chart ,javax.servlet.http.HttpServletRequest req){
      


        

          SpiderWebPlot plot =(SpiderWebPlot)chart.getPlot();




               /***Some Color tranformation :D***/

            /*   String temp[] =colColors.split("-");

               for(int i=0;i<temp.length;i++){

                   

                   if(temp.length>0 && temp[i]!=""){
                   String temp2[] =temp[i].split(":");

                   int index=Integer.parseInt(temp2[0]);
                   
                   String temp3[] =temp2[1].split(",");

                   int r=Integer.parseInt(temp3[0]);
                   int g=Integer.parseInt(temp3[1]);
                   int b=Integer.parseInt(temp3[2]);

                    plot.setSeriesPaint(index, new Color(r, g, b));

                   }

               }*/


               /* * * * * */



          
          
        //seriesColorSetter(chart,req,colColors);
        /*java.util.List ls = plot.getCategories();
               java.awt.Color[] c = new java.awt.Color[ls.size()];
               for(int i=0;i<ls.size();i++){
                     System.out.println(" WebPlot_format====> " + ls.get(i));
                     c[i] = getColorAppli(""+ls.get(i));
                     plot.getRenderer().setSeriesPaint(i, c[i]);

               }*/
	 
}
%>
