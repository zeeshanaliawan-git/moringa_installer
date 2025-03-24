package com.etn.eshop;

import java.io.*;
import java.net.URL;

import java.security.*;
import java.security.cert.*;

import javax.net.ssl.*;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Properties;
import java.util.StringTokenizer;

import com.etn.util.ItsDate;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import java.util.*;
import java.lang.reflect.Type;


public class DataCleaner
{
    Properties env;
    ClientSql Etn;

    public DataCleaner( String parm[]) throws Exception
    {
        env = new Properties();
		env.load(new InputStreamReader( getClass().getResourceAsStream("Scheduler.conf") , "UTF-8" )) ;

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

    String  getTime()
    {
        return( ItsDate.getWith(System.currentTimeMillis(),true) );
    }

    String parseNull(Object o)
    {
        if( o == null ) return("");
        String s = o.toString();
        if("null".equals(s.trim().toLowerCase())) return("");
        else return(s.trim());
    }
	
	private void run()
	{
		System.out.println("Start at : " +getTime());
		String basedir = parseNull(env.getProperty("FORM_UPLOADS_ROOT_PATH"));
		if(basedir.length() == 0)
		{
			System.out.println("ERROR::Base directory is empty. Cannot proceed");
			return;
		}
		if(basedir.endsWith("/") == false) basedir += "/";
		System.out.println("Forms uploads base directory : "+basedir);
		
		String numberOfMonths = parseNull(env.getProperty("KEEP_FORMS_ATTACHMENT_MONTHS"));
		if(numberOfMonths.length() == 0) numberOfMonths = "3";
		
		Set rs = Etn.execute("Select * from process_forms where type not in ('forgot_password','sign_up') and delete_uploads='1' order by created_on  ");
		while(rs.next())
		{
			String formid = parseNull(rs.value("form_id"));
			String tablename = parseNull(rs.value("table_name"));
			System.out.println("Start cleanup for form ID : " + formid + " table name : "+tablename);
			try
			{
				Set rsT = Etn.execute("Select * from "+tablename+" where created_on <= adddate(now(), interval -"+numberOfMonths+" month)");
				if(rsT != null)
				{
					while(rsT.next())
					{
						String rowid = parseNull(rsT.value(tablename+"_id"));
						String rowfolderpath = basedir + formid + "/" + rowid;
						try {
							
							if(java.nio.file.Files.exists(java.nio.file.Paths.get(rowfolderpath)))
							{	
								System.out.println("Delete folder for row ID : "+ rowid + " created on : "+rsT.value("created_on")+" path : "+rowfolderpath);
								java.io.File dir = new java.io.File(rowfolderpath);
								String[] files = dir.list();
								for(String _file : files)
								{
									java.io.File currentFile = new java.io.File(dir.getPath(), _file);
									currentFile.delete();
								}
								dir.delete();
							}
						} catch(Exception e) { e.printStackTrace(); }
					}
				}
			}
			catch(Exception e)
			{
				e.printStackTrace();
			}
			System.out.println("-----------------");
		}
		System.out.println("End at : " +getTime());
	}

    public static void main( String a[] ) throws Exception
    {
        new DataCleaner(a).run();
    }
}
