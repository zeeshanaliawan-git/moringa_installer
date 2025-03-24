<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm"%>
<%@ page import="java.awt.image.BufferedImage"%>
<%@ page import="javax.imageio.ImageIO, java.io.*"%>
<%@ include file="constants.jsp"%>
<%@ include file="commonMethod.jsp"%>
<%!

	String getTitleForFacebook(String s)
	{
		s = parseNull(s);
		if(s.length() > 70) s = s.substring(0, 70);
		return s;
	}

	String getDescriptionForFacebook(String s)
	{
		s = parseNull(s);
		if(s.length() > 300) s = s.substring(0, 300);
		return s;
	}

%>
<%
	String ptype = parseNull(request.getParameter("ptype"));
	String id  = parseNull(request.getParameter("id"));
	String prefix = parseNull(request.getParameter("prefix"));
	String ogImage = parseNull(request.getParameter("ogImage"));
	String title = parseNull(request.getParameter("title"));
	String productName = parseNull(request.getParameter("productName"));
	String description = parseNull(request.getParameter("description"));
	String summary = parseNull(request.getParameter("summary"));
        int imageWidth = 0;
        int imageHeight = 0;
        if(!ogImage.equals("")){
            try{
                String imagePath = ogImage;
                if(imagePath.lastIndexOf("?") > 0){
                    imagePath = imagePath.substring(0,imagePath.lastIndexOf("?"));
                }
                imagePath = GlobalParm.getParm("TOMCAT_PATH")+"/webapps" + imagePath;
                /*
                BufferedImage bimg = ImageIO.read(new File(imagePath));
                imageWidth = bimg.getWidth();
                imageHeight = bimg.getHeight();
                */

                ProcessBuilder processBuilder = new ProcessBuilder("identify", "-format", "%w %h", imagePath);
                Process process = processBuilder.start();
                
                BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
                String dimensions = reader.readLine();
                
                if (dimensions != null) {
                    String[] parts = dimensions.split(" ");
                    int width = Integer.parseInt(parts[0]);
                    int height = Integer.parseInt(parts[1]);
                    
                    imageWidth = width;
                    imageHeight = height;
                } else {
                    imageWidth = 0;
                    imageHeight = 0;
                    System.out.println("Unable to get dimensions.");
                }

            }
            catch(Exception e){
                e.printStackTrace();
            }
        }


%>
        <meta property="og:title" content="" />
        <meta property="og:description" content="<%=description%>" />
	 <% if (ogImage.length() > 0) {%>
        <meta property="og:image" content="<%=ogImage%>" />
        <meta property="og:image:width" content="<%=imageWidth%>" />
        <meta property="og:image:height" content="<%=imageHeight%>" />
        <meta property="og:image:alt" content="<%=productName%>">
	 <%}%>
        <meta property="og:type" content="website" />


        <meta name="twitter:title" content="" />
        <meta name="twitter:description" content="<%=description%>" />
	 <% if (ogImage.length() > 0) {%>
        <meta name="twitter:image" content="<%=ogImage%>" />
        <meta name="twitter:card" content="summary_large_image" />
        <%} else{%>
        <meta name="twitter:card" content="summary" />
        <%}%>
        <meta name="twitter:message" content="<%=productName%> : <%=description%>" />
<!--        <meta name="email:subject" content="<%=title%>" />-->
        <meta name="email:message" content="<%=description%>" />
	<script type="text/javascript">

	</script>
