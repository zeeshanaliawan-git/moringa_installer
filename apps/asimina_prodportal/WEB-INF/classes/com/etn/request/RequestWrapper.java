/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.etn.request;

import java.util.regex.Pattern;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

/**
 *
 * @author umair
 */
public final class RequestWrapper extends HttpServletRequestWrapper
{

    public RequestWrapper(HttpServletRequest httpservletrequest)
    {
        super(httpservletrequest);
    }

    @Override
    public String[] getParameterValues(String s)
    {
        String as[] = super.getParameterValues(s);
        if(as == null) return null;

        int i = as.length;
        String as1[] = new String[i];
        for(int j = 0; j < i; j++)
        {
            as1[j] = cleanXSS(as[j]);
        }

        return as1;
    }

    @Override
    public String getParameter(String s)
    {
        String s1 = super.getParameter(s);
        if(s1 == null) return null;
        return cleanXSS(s1);
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
}
