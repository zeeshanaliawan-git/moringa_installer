package com.etn.eshop;

import java.lang.reflect.Type;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import java.util.Map;
import java.util.List;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;


class UserRegistration extends OtherAction 
{
	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		return execute(wkid, clid, param);
	}

	public int execute( int wkid , String clid, String param )
	{ 
		System.out.println("Sql wid:"+wkid+" cl:"+clid+" parm:"+param);
		if("create".equals(param)) return createUser(wkid, clid, false);
		else if("createbysu".equals(param)) return createUser(wkid, clid, true);
		return -10;
	} 

	private String parseNull(Object o) 
	{
		if( o == null ) return("");
		String s = o.toString();
  		if("null".equals(s.trim().toLowerCase())) return("");
  		else return(s.trim());
	}

	private List<String> getFeildValues(String datajson, String fld)
	{
		Gson gson = new Gson();

		Type listType = new TypeToken<Map<String,List<String>>>(){}.getType();
		Map<String,List<String>> map = gson.fromJson(datajson, listType);

		return map.get(fld);
	}

	private String getFeildValue(String datajson, String fld)
	{
		List<String> vals = getFeildValues(datajson, fld);
		if(vals == null || vals.isEmpty()) return "";
		return parseNull(vals.get(0));
	}

	private void addProgramToUser(String clientid, String progname)
	{
		String dbname = env.getProperty("PORTAL_DB");
		etn.executeCmd("insert into "+dbname+".client_programs (id_client, program_name) values ("+escape.cote(clientid)+","+escape.cote(progname)+") ");
	}
	
	private String getPassword(Set rs)
	{
		String passwd = getFeildValue(rs.value("form_data"), "password");
		if(passwd.length() > 0) return passwd;
		return getRandomPassword();
	}

	private String getRandomPassword()
	{
		Set rspass = etn.execute("select concat(substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1), "+
						" substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1), "+
						" substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1), "+
						" substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1), "+
						" substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1), "+
						" substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1), "+
						" substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1), "+
						" substring('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', rand()*36+1, 1)) as pas from dual ");

		rspass.next();
		return rspass.value("pas");
	}

	private int createUser(int wkid, String clid, boolean iscreatedbysuperuser)
	{
		int retVal = 0;
		try
		{
			Set rs = etn.execute("select * from generic_forms where id = " + clid);
			if(rs.next())
			{
				String dbname = env.getProperty("PORTAL_DB");
				Set rscl = etn.execute("select * from "+dbname+".clients where username = " + escape.cote(rs.value("email")));
				
				//we just add to client_programs
				if(rscl.rs.Rows > 0)
				{
					rscl.next();
					addProgramToUser(rscl.value("id"), getFeildValue(rs.value("form_data"), "program_name"));

					//case is when we allow guest checkout we add the email address to clients table but that email can register later 
					//so in this case we generate a password and send in appropriate email set in process
					if("1".equals(rscl.value("first_pass_sent"))) retVal = 1; //first_pass_sent means that user in clients is already a member
					else //this is the case where user in clients table was added due to guest checkout ... so now he is actually registering and we update created_date also to start his actual registration
					{
						String passwd = getPassword(rs);
						etn.executeCmd("update "+dbname+".clients set created_date = now(), is_verified = 1, first_time_pass = "+escape.cote(passwd)+", pass = MD5("+escape.cote(passwd)+"), first_pass_sent = 1 where id = " + escape.cote(rscl.value("id")));
						retVal = 0;
					}
				}
				else
				{
					String passwd = getPassword(rs);
					//if user created by super user then we set the password as firstname123
					if(iscreatedbysuperuser) passwd = getFeildValue(rs.value("form_data"), "firstname") + "123";
					
					int clientid = etn.executeCmd(" insert into "+dbname+".clients (username, email, mobile_number, name, surname, pass, is_verified, first_time_pass, first_pass_sent) values ("+escape.cote(rs.value("email"))+", "+escape.cote(rs.value("email"))+","+escape.cote(getFeildValue(rs.value("form_data"), "mobile_number"))+","+escape.cote(getFeildValue(rs.value("form_data"), "firstname"))+","+escape.cote(getFeildValue(rs.value("form_data"), "lastname"))+",MD5("+escape.cote(passwd)+"),1,"+escape.cote(passwd)+", 1) ");
					if(clientid > 0)
					{
						addProgramToUser(""+clientid, getFeildValue(rs.value("form_data"), "program_name"));
						retVal = 0;
					}
					else 
					{
						etn.executeCmd("update post_work set errmessage='error inserting into clients table' where id="+wkid );
						retVal = -20;
					}
				}
			}
			else retVal = -30;			

			if(retVal == 0 || retVal == 1)
			{
				System.out.println("CreateUser ret val : " + retVal);
				String msg = "user updated successfully";
				if(retVal == 0) msg = "user created successfully";
				etn.executeCmd("update post_work set errCode = "+escape.cote(""+retVal)+", errMessage= "+escape.cote(msg)+" where id="+wkid );

				((Scheduler)env.get("sched")).endJob( wkid , clid );					
			}
		}
		catch(Exception e)
		{
			e.printStackTrace();
			retVal = -40;
		}
		finally
		{
			return retVal;
		}
	}
}