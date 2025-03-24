/*
 * Special filter to check for auth enabled sites
 * 
 */

package com.etn.servlet.filter;

import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;

import java.io.IOException;
import java.io.CharArrayWriter;
import java.io.PrintWriter;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServletResponseWrapper;

import org.json.JSONObject;
/**
 *
 * @author umair
 */
public class ApplyPageTemplate implements Filter
{
	private FilterConfig filterConfig;

	public void init(FilterConfig filterConfig)
	{
       	this.filterConfig = filterConfig;
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	public void doFilter(ServletRequest _request, ServletResponse _response, FilterChain chain) throws IOException, ServletException
	{
       	HttpServletRequest request = (HttpServletRequest)_request;
       	MyResponseWrapper response = new MyResponseWrapper((HttpServletResponse) _response);

		if(request.getSession().getAttribute("Etn") == null)
		{
			request.getSession().setAttribute("Etn", new com.etn.beans.Contexte());
		}

		com.etn.beans.Contexte Etn = (com.etn.beans.Contexte)request.getSession().getAttribute("Etn");		
		
		//System.out.println("In ApplyPageTemplate");
		String uri = parseNull(request.getRequestURI());
		
		chain.doFilter(request, response);	
		
		try
		{
			PrintWriter responseWriter = _response.getWriter();
			
			System.out.println("ApplyPageTemplate::"+uri);
			System.out.println("ApplyPageTemplate::"+parseNull(response.getContentType()));
			//only for jsps
			if(uri.toLowerCase().endsWith(".jsp") && parseNull(response.getContentType()).toLowerCase().contains("text/html"))
			{		
				CharArrayWriter charWriter = new CharArrayWriter();			
				com.etn.asimina.util.ApplyPageTemplateHelper helper = com.etn.asimina.util.ApplyPageTemplateHelper.getInstance();
				String content = helper.applyTemplate(Etn, uri, response.toString());
				responseWriter.write(content);
			} 
			else responseWriter.write(response.toString());		
		}
		catch(java.lang.IllegalStateException e)
		{
			//there are couple of jsps which are downloading some files or images ... in that case the jsp has already called response.getOutputStream ... example cart/itemImage.jsp
			//those jsps response will also go through this filter as tomcat does not give any way to exclude some files in the filter config
			//so in such cases this exception is expected
			System.out.println("-------- ApplyPageTemplate :: Expected error for content types other than text/html and application/json ---------------------------------------");
			System.out.println("ApplyPageTemplate::response.getOutputStream() is already called");
		}
	}


	public void destroy()
	{
       	this.filterConfig = null;
	}

	private class MyResponseWrapper extends HttpServletResponseWrapper 
	{
		private CharArrayWriter writer;
		  
		public MyResponseWrapper(HttpServletResponse response) 
		{
			super(response);
			writer = new CharArrayWriter();
		}
		  
		public PrintWriter getWriter() 
		{
			return new PrintWriter(writer);
		}
		  
		public String toString() 
		{
			return writer.toString();
		}  
	}	
}