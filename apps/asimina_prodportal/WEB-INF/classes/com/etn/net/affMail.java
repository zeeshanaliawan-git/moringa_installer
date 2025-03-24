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


import com.etn.lang.ResultSet.*;





import org.jfree.chart.JFreeChart;

public class affMail extends HttpServlet {
    public void service(HttpServletRequest req, HttpServletResponse res)
    throws ServletException, java.io.IOException
    {
        try {
            HttpSession session = req.getSession(true);
            Contexte Etn = (Contexte) session.getAttribute("Etn");
            
            String id=req.getParameter("id");

            String env=req.getParameter("env");
            if( env == null ) env = "";
            
            
            InputStream  f1 = getMail(id);
           
           
            Properties	props   = new Properties();
            props.setProperty("MAIL_FROM","n.laval@etancesys.com");
            props.setProperty("MAIL_REPLY","n.laval@etancesys.com");
            props.setProperty("MAIL_DEBUG","false");

            Set rs=Etn.execute("select 1=1");
            MailFromModel m = new MailFromModel(props);
            m.writeTo(res.getOutputStream(),f1,rs,"test");
            
            
            

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
            System.out.println("Err "+ee.getMessage()+"");
        }
    }
    
  
    
    

   

}
















