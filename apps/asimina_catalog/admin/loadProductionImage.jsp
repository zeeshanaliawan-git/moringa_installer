<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@page import="com.etn.lang.ResultSet.Set, com.etn.beans.app.GlobalParm, com.etn.sql.escape"%>

<%@ page  import="java.io.FileInputStream,com.etn.asimina.util.FileUtil" %>
<%@ page  import="java.io.BufferedInputStream"  %>
<%@ page  import="java.io.File"  %>

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
	
	String ty = parseNull(request.getParameter("ty"));
	String id = parseNull(request.getParameter("id"));

	
	String path = "";
	String file = "";

	if("product".equals(ty))
	{
		path = GlobalParm.getParm("PROD_PRODUCTS_UPLOAD_DIRECTORY");
		Set rs = Etn.execute("select * from "+GlobalParm.getParm("PROD_DB") +".products where id = " + escape.cote(id));
		if(rs.next()) file = parseNull(rs.value("image_name"));
	}
	else if("sharebar".equals(ty))
	{
		String ptype = parseNull(request.getParameter("ptype"));
		if(ptype.equals("tarif")) path = GlobalParm.getParm("PROD_TARIF_SHAREBAR_IMAGES_UPLOAD_DIRECTORY");
		else if(ptype.equals("device")) path = GlobalParm.getParm("PROD_DEVICE_SHAREBAR_IMAGES_UPLOAD_DIRECTORY");
		else if(ptype.equals("accessory")) path = GlobalParm.getParm("PROD_ACCESSORY_SHAREBAR_IMAGES_UPLOAD_DIRECTORY");
		else if(ptype.equals("product")) path = GlobalParm.getParm("PROD_PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY");

		Set rs = Etn.execute("select * from "+GlobalParm.getParm("PROD_DB") +".share_bar where id = " + escape.cote(id) + " and ptype = " + escape.cote(ptype));
		if(rs.next()) file = parseNull(rs.value("og_image"));
	}


	if(file.length() > 0)	
	{
		BufferedInputStream buf=null;
		ServletOutputStream myOut=null;
		try
		{
			File img = FileUtil.getFile(path + file);//change

			System.out.println("load image : " + path + file);
			response.setContentType("image/png");
			FileInputStream input = new FileInputStream(img);
			response.addHeader("Content-Disposition","attachment; filename=\"" + file + "\"" );
       	     	response.setHeader("Cache-Control", "private");
	            	response.setHeader("Pragma", "private");

			myOut = response.getOutputStream( );
			response.setContentLength( (int) img.length( ) );
			buf = new BufferedInputStream(input);
			int readBytes = 0;

			//read from the file; write to the ServletOutputStream
			while((readBytes = buf.read( )) != -1) myOut.write(readBytes);
		}
		catch(Exception e)
		{
			e.printStackTrace();
		}
		finally
		{
			if (myOut != null) myOut.close( );
			if (buf != null) buf.close( );         
		}
	}
%>