<%@ page import="java.io.*"%>
<%@ page import="java.net.*"%>
<%@ page import="com.etn.support.encryption.AesCipher"%>

<%	
	//send profile and reffer url	
	Object login = request.getSession().getAttribute("LOGIN");
	if(login != null){
		String userEmail = "support@asimina.com";		
		userEmail = (String)login;		
		String keyId = "5a473d538eb644afaf623a22b2420d10415eb0f6e9274e13b5";
		String referer = request.getHeader("referer");
		String language = "def";
		String key = "uBOD05PjZhIuiZz3";
		String msg = "userEmail=" + userEmail + "&language=" + language;
		if(referer != null){
			msg += "&pageUrl=" + referer;
		}
		System.out.println("REFERFER:" + referer);
		AesCipher encrypted = AesCipher.encrypt(key, msg);        	
		String urlStr = "http://datatokpis.com/support/server?" + keyId + encrypted.getData();
		URL u = new URL(urlStr);	
		InputStream is = u.openStream();
		DataInputStream dis = new DataInputStream(new BufferedInputStream(is));
		String s;
		while ((s = dis.readLine()) != null) {
			out.print(s);
		}
	}
%>
