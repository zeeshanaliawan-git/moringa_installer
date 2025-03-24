<%@ page import="java.io.*"%>
<%@ page import="java.lang.reflect.*"%>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="com.etn.lang.ResultSet.Set"%>
<%
        String doc=request.getParameter("doc");
        String id=request.getParameter("id");
        String hostName="http://localhost:8080";
        ServletContext sc = getServletConfig().getServletContext();
        //String path = com.etn.beans.app.GlobalParm.getParm("URL_DOCUMENTATION");
        String file = request.getRequestURI();
        String[] tempArray;
        tempArray = file.split("/");
        file= "";
        for (int i = 0; i < tempArray.length-1; i++) {
            file=file+tempArray[i]+"/";
        }
        String pdf_file_path=sc.getRealPath("/") + "invoices/"+(doc.replaceAll("/", "").replaceAll("\\\\", ""))+".pdf";
        String target_url=hostName+file+"trackingBill"+".jsp?id="+java.net.URLEncoder.encode(id, java.nio.charset.StandardCharsets.UTF_8.toString());

        String command=com.etn.beans.app.GlobalParm.getParm("HTML_TO_PDF_CMD")+" -O Portrait "+target_url+"  "+pdf_file_path;
        System.out.println(command);
        Process process = Runtime.getRuntime().exec(command, null);
        String s = "";
        String temp = "";
        BufferedReader br = new BufferedReader(new InputStreamReader(process.getInputStream()));
        while ((temp = br.readLine()) != null) {
                s += temp + "\n";
        }
        System.out.println("******END OF GENERATING PDF******" + s);


        int retVal = 0;
        retVal = process.waitFor();
        if (retVal != 0) {
            System.out.println(retVal);
                //throw new Exception("Error encountered in running PDF generation command\n" + command);
        }
        System.out.println("PDF generated: " + pdf_file_path);

        java.net.URL excelFile = config.getServletContext().getResource("/invoices/"+(doc.replaceAll("/", "").replaceAll("\\\\", ""))+".pdf");
        System.out.println(excelFile);
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\""+(doc.replaceAll("/", "").replaceAll("\\\\", ""))+".pdf\";");
        InputStream inputStream = excelFile.openStream();
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
        finally
        {
            if(inputStream != null)
                    inputStream.close();
            o.close();            
        }
//        return;
        
%>
