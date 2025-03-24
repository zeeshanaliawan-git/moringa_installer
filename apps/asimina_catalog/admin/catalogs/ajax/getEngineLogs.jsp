<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map, com.etn.beans.app.GlobalParm, java.net.*,java.io.*"%>
<%@ include file="../../../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../../common.jsp"%>
<% 
    /*try {
        ServerSocket serverSocket = new ServerSocket(6666);
        out.println("{\"status\":\"Server started on port 6666\"}");
        Socket socket = serverSocket.accept();
        DataInputStream dis = new DataInputStream(socket.getInputStream());
        String message = dis.readUTF();
        out.println("{\"messageReceived\":\"" + message + "\"}");
        serverSocket.close();
    } catch (IOException e) {
        out.println("{\"error\":\"" + e.getMessage() + "\"}");
    }*/
    try{
        System.out.println("Waiting for clients...");
        ServerSocket soc = new ServerSocket(9806);
        Socket socket = soc.accept();
        System.out.println("Connection established");
        out.write("{\"msg\":\"Connection established\" }" );
    }catch(Exception e)
    {
        out.write("{\"error\":\"" + e.getMessage()+"\" }" );
    }
%>