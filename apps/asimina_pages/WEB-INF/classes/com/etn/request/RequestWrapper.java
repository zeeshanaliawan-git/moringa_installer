/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.etn.request;

import java.util.regex.Pattern;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

import java.util.Map;
import java.util.List;

/**
 *
 * @author umair
 */
public final class RequestWrapper extends HttpServletRequestWrapper
{
	private String cUrl;
	private Map<String, List<String>> ignoreUrlFields;

    public RequestWrapper(HttpServletRequest httpservletrequest, Map<String, List<String>> ignoreUrlFields)
    {
        super(httpservletrequest);
		this.ignoreUrlFields = ignoreUrlFields;
		this.cUrl = httpservletrequest.getRequestURI();
    }

    @Override
    public String[] getParameterValues(String s)
    {
        String as[] = super.getParameterValues(s);
        if(as == null) return null;
		
		boolean doClean = doClean(s);

        int i = as.length;
        String as1[] = new String[i];
        for(int j = 0; j < i; j++)
        {
			if(doClean) as1[j] = cleanXSS(as[j]);
			else as1[j] = as[j];
        }

        return as1;
    }

    @Override
    public String getParameter(String s)
    {
        String s1 = super.getParameter(s);
        if(s1 == null) return null;
		
		if(doClean(s)) s1 = cleanXSS(s1);
		
        return s1;
    }

    @Override
    public String getHeader(String s)
    {
        String s1 = super.getHeader(s);
        if(s1 == null) return null;
        return cleanXSS(s1);
    }

    private String cleanXSS(String s)
    {
		return com.etn.util.XSSHandler.clean(s);
    }
	
	private boolean doClean(String param)
	{
		for(String url : ignoreUrlFields.keySet())
		{
			if(cUrl.endsWith(url))
			{
				for(String ifield : ignoreUrlFields.get(url))
				{
					if(ifield.equals(param)) 
					{
						return false;
					}
				}
			}
		}
		return true;
	}
}
