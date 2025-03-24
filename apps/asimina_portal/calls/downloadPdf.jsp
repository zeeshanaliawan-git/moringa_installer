<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte"/>
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%request.setCharacterEncoding("utf-8");response.setCharacterEncoding("utf-8");%>
<%@ page import="java.io.*"%>
<%@ page import="java.lang.reflect.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.sql.escape, com.etn.beans.app.GlobalParm"%>
<%!
String parseNull(Object o)
{
        if( o == null ) return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase())) return("");
        else return(s.trim());
}
%>
<%
        String id=request.getParameter("id");
        String client_id = com.etn.asimina.session.ClientSession.getInstance().getLoginClientId(Etn, request);
        System.out.println(client_id);
        Set rsOrder = Etn.execute("select orderRef from "+GlobalParm.getParm("SHOP_DB")+".orders where client_id="+escape.cote(client_id)+" and parent_uuid="+escape.cote(id));
        
        if(rsOrder.next()){     
            java.net.URL pdfFile = config.getServletContext().getResource("/invoices/Facture_"+rsOrder.value("orderRef")+".pdf");
            if(pdfFile!=null){
                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition", "attachment; filename=\""+rsOrder.value("orderRef")+".pdf\";");
                InputStream inputStream = pdfFile.openStream();
                OutputStream o = response.getOutputStream();
                try
                {

                    byte[] buffer = new byte[1024];
                    int bytesRead = 0;
                    do
                    {
                            bytesRead = inputStream.read(buffer, 0, buffer.length);
                            o.write(buffer, 0, bytesRead);
                    }
                    while (bytesRead == buffer.length);

                    o.flush();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
                finally
                {
                    if(inputStream != null) inputStream.close();

                    o.close();            
                }
            }
            else{
                out.write("Invoice not generated, please try again later.");
            }
        }
        else{
            out.write("Order does not exist / You are not authorised");
        }
//        return;
        
%>
