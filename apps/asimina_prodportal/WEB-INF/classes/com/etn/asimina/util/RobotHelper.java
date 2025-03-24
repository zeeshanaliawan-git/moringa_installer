package com.etn.asimina.util;

import com.etn.beans.Contexte;
import com.etn.beans.app.GlobalParm;
import com.etn.sql.escape;
import com.etn.util.Logger;
import com.etn.asimina.util.PortalHelper;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.etn.util.Logger;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;

import org.json.JSONObject;


public class RobotHelper
{
	private static final RobotHelper apt = new RobotHelper();
	private List<String> ipsList = null;
	
	private RobotHelper(){
        try{
			Logger.info("RobotHelper", "-------------- Creating RobotHelper instance --------------");
			Contexte db = new Contexte();
			init(db);
        }catch(Exception ex){
            ex.printStackTrace();
        }		
	}
	
	private void init(Contexte db)
	{
		Logger.info("RobotHelper", "in init");
		ipsList = new ArrayList<String>();
		Set rs = db.execute("select * from config where code = 'COMMONS_DB'");
		String commonsDb = "";
		if(rs.next())
		{
			commonsDb = rs.value("val");
		}			
		Logger.info("RobotHelper", "commonsDb:"+commonsDb);
		if(commonsDb.length() > 0)
		{
			rs = db.execute("select * from "+commonsDb+".config where code = 'robot_ips' ");
			if(rs.next())
			{
				String[] _ips = PortalHelper.parseNull(rs.value("val")).split(",");
				for(String _ip : _ips)
				{
					ipsList.add(PortalHelper.parseNull(_ip));
				}
			}
		}
	}
	
	public void reload(Contexte db)
	{
		init(db);
	}
	
	public static RobotHelper getInstance()
	{
		Logger.debug("RobotHelper", "in getInstance");
		if(apt == null) Logger.error("RobotHelper", "impossible state ---- apt is null");
		return apt;
	}
	
	public boolean excludeIpForStats(String ip)
	{
		if(ipsList != null && ipsList.contains(ip)) return true;
		return false;
	}
}