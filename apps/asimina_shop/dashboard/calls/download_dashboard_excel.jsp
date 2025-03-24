<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@page import="java.util.*, java.io.* ,com.etn.asimina.util.FileUtil"%>
<%@ include file="/common.jsp"%>
<%

    String filename =  request.getParameter("filename");
    System.out.println(filename);
    FileInputStream input = null;
    BufferedInputStream buf=null;
    ServletOutputStream myOut=null;

    try
    {
        File myfile = FileUtil.getFile(com.etn.beans.app.GlobalParm.getParm("DASHBOARD_EXCEL_PATH")+filename);//change
		input = new FileInputStream(myfile);
        //set response headers
        myOut = response.getOutputStream();

        String mimeType = getMimeType(filename);
        if(mimeType != null) response.setContentType(mimeType);

        response.addHeader("Content-Disposition","attachment; filename=dashboard.xls");
        response.setContentLength( (int) myfile.length( ) );
        buf = new BufferedInputStream(input);
        int readBytes = 0;

        //read from the file; write to the ServletOutputStream
        while((readBytes = buf.read( )) != -1)
            myOut.write(readBytes);
        if (input != null)
            input.close();
        if (myOut != null)
            myOut.close();
        if (buf != null)
            buf.close();
    }
    catch (Exception e)
    {
        System.out.println("ERROR "+e);
        request.setAttribute("exception",e);
        if (input != null)
            input.close();
        if (myOut != null)
            myOut.close();
        if (buf != null)
            buf.close();
    }
%>