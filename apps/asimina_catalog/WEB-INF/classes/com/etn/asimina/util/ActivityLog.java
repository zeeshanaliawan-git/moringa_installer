package com.etn.asimina.util;

import com.etn.beans.Contexte;
import com.etn.sql.escape;
import com.etn.beans.app.GlobalParm;

import javax.servlet.http.HttpServletRequest;
import java.util.*;

public class ActivityLog
{
	public static String getIP(HttpServletRequest request)
	{
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("x-real-ip");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
		
		ip = parseNull(ip);

		//X-fowarded-for has chain of IPs ( comma separated list ) where first one is the client's IP, then comes the load balancer IP
		//if load balancer sends the request to server 2 and server 2 sends it back to server 1 then this chain will
		//have server 2 IP as well.
		//If user adds the x-fowarded-for header in request, then that information will always be at the start of this chain

		//this is the list of IPs we have to filter out from the x-fowarded-for chain
		List<String> filterIps = Arrays.asList(parseNull(GlobalParm.getParm("X_FORWARDED_FOR_IPS_CHAIN")).split("\\s*,\\s*"));
		
		List<String> ipList = Arrays.asList(ip.split("\\s*,\\s*"));
		if(ipList != null)
		{
			//we always traverse this list from right as load balancer and all reverse proxy server IPs are at the end of this list
			for(int i=(ipList.size()-1);i>=0;i--)
			{
				//here we are checking if this IP is either load balancer's ip or second server ip
				if(filterIps.contains(parseNull(ipList.get(i)))) continue;
				//first IP we get which is not in filterIps list is the client's IP
				ip = parseNull(ipList.get(i));
				break;
			}
		}
		
		//some countries are sending %2 or %1 with the IP .. seems like that is sent depending on which server the load balancer
		//sends the request
		String newIp = "";
		for(int i=0;i<ip.length();i++)
		{
			char charAt = ip.charAt(i);
			if('0' == charAt || 
				'1' == charAt || 
				'2' == charAt || 
				'3' == charAt || 
				'4' == charAt || 
				'5' == charAt || 
				'6' == charAt || 
				'7' == charAt || 
				'8' == charAt || 
				'9' == charAt || 
				'.' == charAt ) newIp += charAt;
			else break;
		}
		
		//System.out.println("IP:"+ip);
        return newIp;
	}

	public static void addLog(com.etn.beans.Contexte Etn, HttpServletRequest request, String username,String item_id, String action, String type, String description, String siteId)
	{
		String userAgent = request.getHeader("user-agent");
		if(userAgent == null) userAgent = "";

		String q = "INSERT INTO "+GlobalParm.getParm("COMMONS_DB")+".user_actions  (username, ip, item_id, action, type, description, site_id, user_agent, activity_on)"+
					"VALUES ("+
						escape.cote(username)+","+
						escape.cote(getIP(request))+","+
						escape.cote(item_id)+","+
						escape.cote(action)+","+
						escape.cote(type)+","+
						escape.cote(description)+","+
						escape.cote(siteId)+","+
						escape.cote(userAgent)+","+
						" now())";
		Etn.executeCmd(q);
	}
	
    private static String parseNull(Object o) {
        if (o == null) {
            return ("");
        }
        String s = o.toString();
        if ("null".equals(s.trim().toLowerCase())) {
            return ("");
        } else {
            return (s.trim());
        }
    }
	
}