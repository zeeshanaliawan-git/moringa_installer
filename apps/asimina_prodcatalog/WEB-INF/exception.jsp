<%@page isErrorPage="true" %>

<%!


public static String getStackMsgHtml(Throwable e) {
    StringBuffer sb = new StringBuffer();
    sb.append("<strong>"+e.toString()).append("</strong><br>");
            StackTraceElement[] stackArray = e.getStackTrace();

                for(int i = 0; i < stackArray.length; ++i) {
                        StackTraceElement element = stackArray[i];
                        sb.append("<span style='margin-left:35px'>"+element.toString() + "</span><br>");
                                    }

                                        return sb.toString();
                                        }


%>

<%
        Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
        System.out.println("Exception::" + request.getContextPath());
        System.out.println("Status Code::"+statusCode);
        String servletName = (String) request.getAttribute("javax.servlet.error.servlet_name");
        if (servletName == null) {
                servletName = "Unknown";
        }
        String requestUri = (String) request.getAttribute("javax.servlet.error.request_uri");
        System.out.println("Request Uri::"+requestUri);
        exception.printStackTrace();


        String showException = request.getParameter("s");
%>
<html>
	<body>
		<div style='margin-top:15px;'>
			<p style='font-size:24px;color:red;'>OOPS!!!!</strong></p>

			<p style='font-weight:bold;'>Some error occurred while processing your request</p>
		</div>

		<div>
			<p><strong>URI</strong>&nbsp;<% out.write(requestUri); %><br>
		</div>
	</body>
<html>

