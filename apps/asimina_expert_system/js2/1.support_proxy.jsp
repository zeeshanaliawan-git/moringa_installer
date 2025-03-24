<%@ page import="java.io.*"%>
<%@ page import="java.net.*"%>
<%@ page import="com.etn.support.util.Encryption"%>
<%@ page import="java.security.PublicKey"%>
<%@ page import="java.net.URLEncoder"%>

<%	
	//send profile and reffer url	
	
	String userEmail = "support@asimina.com";
	if(request.getSession().getAttribute("LOGIN") != null){
		userEmail = (String)request.getSession().getAttribute("LOGIN");
	}	
	String keyId = "6b9a2641-f587-4359-91ea-49aca06f6c94";
	String referer = request.getHeader("referer");
	String msg = "userEmail=" + userEmail + "&language=def";
	if(referer != null){
		msg += "&pageUrl=" + referer;
	}
	
	Encryption ac = new Encryption();
	PublicKey publicKey = ac.getPublic("/home/ronaldo/support_keys/publicKey");
	String encrypted_msg = ac.encryptText(msg, publicKey);	 	
	String urlStr = "http://datatokpis.com/support/js/etn.support.support.include.jsp?keyId=" + keyId + "&data=" + encrypted_msg;
	URL u = new URL(urlStr);	
	InputStream is = u.openStream();
	DataInputStream dis = new DataInputStream(new BufferedInputStream(is));
	String s;
	while ((s = dis.readLine()) != null) {
		out.print(s);
	}
%>
