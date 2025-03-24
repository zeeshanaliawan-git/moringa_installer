package com.etn.eshop.cron;

import java.util.Properties;

import java.io.*;
import com.etn.util.ItsDate;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

import com.etn.eshop.Util;
import com.etn.eshop.Scheduler;

public class ConsolidatedStatLog
{
    Properties env;
    ClientSql Etn;

    public ConsolidatedStatLog() throws Exception
    {
        env = new Properties();
		env.load(new InputStreamReader( Scheduler.class.getResourceAsStream("Scheduler.conf") , "UTF-8" )) ;

		Etn = new ClientDedie(  "MySql", env.getProperty("CONNECT_DRIVER"), env.getProperty("CONNECT") );
		//load config from db
		Set rs = Etn.execute("SELECT code,val FROM config");
		while (rs.next())
		{
			env.setProperty(rs.value("code"), rs.value("val"));
		}
		String commonsDb = env.getProperty("COMMONS_DB");
		if (commonsDb.trim().length() > 0)
		{
			//load from commons db but don't override local config
			rs = Etn.execute("SELECT code,val FROM " + commonsDb + ".config");
			while (rs.next())
			{
				if (!env.containsKey(rs.value("code")))
				{
					env.setProperty(rs.value("code"), rs.value("val"));
				}
			}
		}        
    }

    private int run(String action){

		System.out.println("Starting at : " + getTime());
		int r = 0;

        try{
			System.out.println("action : " + action);
            String portalDb=env.getProperty("PORTAL_DB");
            
            String[] table_name ={"consolidated_stat_urls_after","consolidated_stat_urls_all","consolidated_stat_urls_before"};
            String[] condition ={"SUBSTRING_INDEX(SUBSTRING_INDEX(sl.page_c, '/', -1),'?',1)","SUBSTRING_INDEX(sl.page_c, '?', 1)","REVERSE(SUBSTRING(REVERSE(sl.page_c), INSTR(REVERSE(sl.page_c), '/')))"};
            for(int i = 0; i<table_name.length;i++){
                String deleteQuery="delete from "+table_name[i];
                
                String insertQuery="insert into "+table_name[i]+" (date_l,page_c,session_j,site_id,eletype,eleid) select distinct date(sl.date_l),"+
                    condition[i]+",sl.session_j,COALESCE(sl.site_id,0),spi.eletype, spi.eleid from "+portalDb+".stat_log sl left join "+
                    portalDb+".stat_log_page_info spi ON spi.page_c = "+condition[i]+" and sl.site_id= (SELECT id FROM "+portalDb+
                    ".sites s WHERE s.suid=spi.site_uuid) where COALESCE("+condition[i]+",'') !=''";     
                
                if(Util.parseNull(action).equalsIgnoreCase("all")){
                    
                    Etn.executeCmd(deleteQuery);
                    r = Etn.executeCmd(insertQuery);
                    
                }else if(Util.parseNull(action).equalsIgnoreCase("previous")){
                    
                    Etn.executeCmd(deleteQuery+" where date(date_l) = CURDATE()-1 ");
                    r = Etn.executeCmd(insertQuery+" and sl.date_l between date_sub(DATE_FORMAT(CURDATE(), '%Y-%m-%d 00:00:00'),INTERVAL 1 DAY)"+
                    " AND date_sub(DATE_FORMAT(CURDATE(), '%Y-%m-%d 23:59:59'),INTERVAL 1 DAY)");
                }
                else{
                    Etn.executeCmd(deleteQuery+" where date(date_l) = CURDATE()");
                    r = Etn.executeCmd(insertQuery+" and sl.date_l between DATE_FORMAT(CURDATE(), '%Y-%m-%d 00:00:00')"+
                    " AND DATE_FORMAT(CURDATE(), '%Y-%m-%d 23:59:59')");
                }

            }



			

        }catch (Exception e) {
            e.printStackTrace();
        }
		System.out.println("rows inserted : " + r);
		return r;
    }

    String  getTime()
    {
        return( ItsDate.getWith(System.currentTimeMillis(),true) );
    }
	
    public static void main( String a[] ) throws Exception
    {
		String action = "";
		if(a != null && a.length > 0) action = a[0];
        new ConsolidatedStatLog().run(action);
    }
}
