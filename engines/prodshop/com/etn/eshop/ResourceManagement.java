package com.etn.eshop;

import java.lang.reflect.Type;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import com.etn.Client.Impl.ClientSql;


class ResourceManagement extends OtherAction 
{
	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		return execute(wkid, clid, param);
	}

	public int execute( int wkid , String clid, String param )
	{ 
		System.out.println("Sql wid:"+wkid+" cl:"+clid+" parm:"+param);
		if("assign".equals(param)) return assignResource(wkid, clid);
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
        
        private int shuffleResource(int wkid, String clid)
        {
            return 0;
        }

	private int assignResource(int wkid, String clid)
	{
		int retVal = 0;
		try
		{
			Set rs = etn.execute("select oi.* from order_items oi, "+env.getProperty("CATALOG_DB")+".products p where p.product_uuid = oi.product_ref and oi.id = " + escape.cote(clid));
			rs.next();

			String productref = parseNull(rs.value("product_ref"));

			Map<String, Resource> resources = Util.getResources(etn, env, productref);
			Map<String, Resource> rooms = Util.getResources(etn, env, productref, "secondary");
                        
                        String resourcesInClause = "";
                        String secondaryResourcesInClause = "";
                        
                        for (Map.Entry<String, Resource> entry : resources.entrySet()){
                            String key = entry.getKey();
                            Resource resource = entry.getValue();
                            String calendar_query = "select c.id from order_items oi inner join "+env.getProperty("CATALOG_DB")+".products p ON oi.product_ref = p.product_uuid"+
                            " inner join "+env.getProperty("CATALOG_DB")+".calendar c ON p.catalog_id = c.catalog_id AND p.id = c.product_id where c.type=2 AND oi.id ="+escape.cote(clid)+
                            " AND (CONCAT(',',c.resources,',') LIKE "+escape.cote("%,"+key+",%")+" )"+
                            " AND c.date=STR_TO_DATE(oi.service_date,'%d-%m-%Y') AND ((HOUR(c.start_time)*60+MINUTE(c.start_time) BETWEEN oi.service_start_time AND ((oi.service_start_time-1)+(oi.quantity*oi.service_duration)))"+
                            " OR (HOUR(c.end_time)*60+MINUTE(c.end_time) BETWEEN oi.service_start_time+1 AND ((oi.service_start_time)+(oi.quantity*oi.service_duration))) OR (oi.service_start_time BETWEEN HOUR(c.start_time)*60+MINUTE(c.start_time) AND HOUR(c.end_time)*60+MINUTE(c.end_time)-1)"+
                            " OR (((oi.service_start_time)+(oi.quantity*oi.service_duration)) BETWEEN HOUR(c.start_time)*60+MINUTE(c.start_time)+1 AND HOUR(c.end_time)*60+MINUTE(c.end_time)))";

                            Set rsCalendar = etn.execute(calendar_query);
                            if(rsCalendar.next()) resource.setAvailable(false);
                            else{
                                if(!resourcesInClause.equals("")) resourcesInClause+=",";
                                resourcesInClause += escape.cote(key);
                            }                            
                        }
                        resourcesInClause = "("+resourcesInClause+")";
                        
                        for (Map.Entry<String, Resource> entry : rooms.entrySet()){
                            String key = entry.getKey();
                            Resource resource = entry.getValue();
                            String calendar_query = "select c.id from order_items oi inner join "+env.getProperty("CATALOG_DB")+".products p ON oi.product_ref = p.product_uuid"+
                            " inner join "+env.getProperty("CATALOG_DB")+".calendar c ON p.catalog_id = c.catalog_id AND p.id = c.product_id where c.type=2 AND oi.id ="+escape.cote(clid)+
                            " AND (CONCAT(',',c.resources,',') LIKE "+escape.cote("%,"+key+",%")+" )"+
                            " AND c.date=STR_TO_DATE(oi.service_date,'%d-%m-%Y') AND ((HOUR(c.start_time)*60+MINUTE(c.start_time) BETWEEN oi.service_start_time AND ((oi.service_start_time-1)+(oi.quantity*oi.service_duration)))"+
                            " OR (HOUR(c.end_time)*60+MINUTE(c.end_time) BETWEEN oi.service_start_time+1 AND ((oi.service_start_time)+(oi.quantity*oi.service_duration))) OR (oi.service_start_time BETWEEN HOUR(c.start_time)*60+MINUTE(c.start_time) AND HOUR(c.end_time)*60+MINUTE(c.end_time)-1)"+
                            " OR (((oi.service_start_time)+(oi.quantity*oi.service_duration)) BETWEEN HOUR(c.start_time)*60+MINUTE(c.start_time)+1 AND HOUR(c.end_time)*60+MINUTE(c.end_time)))";

                            Set rsCalendar = etn.execute(calendar_query);
                            if(rsCalendar.next()) resource.setAvailable(false);
                            else{
                                if(!secondaryResourcesInClause.equals("")) secondaryResourcesInClause+=",";
                                secondaryResourcesInClause += escape.cote(key);
                            }
                        }
                        secondaryResourcesInClause = "("+secondaryResourcesInClause+")";
                        
                        

			System.out.println("# of resources : " + resources.size());
			if(rooms != null) System.out.println("# of rooms : " + rooms.size());
		
			rs = etn.execute("select oi.* from order_items oi2, order_items oi, post_work p  "+
					" where oi2.id = "+ escape.cote(clid)+
					" and oi.id <> oi2.id  "+
					" and ( oi.resource in "+resourcesInClause+ 
					" or oi.secondary_resource in "+secondaryResourcesInClause+ 
					" ) and oi2.service_date = oi.service_date  "+
					" and (oi2.service_start_time between oi.service_start_time and ((oi.service_start_time-1)+(oi.quantity*oi.service_duration)+oi.service_gap) "+
					" or ((oi2.service_start_time-1)+(oi2.quantity*oi2.service_duration)+oi2.service_gap) between oi.service_start_time and ((oi.service_start_time-1)+(oi.quantity*oi.service_duration)+oi.service_gap)  "+
					" or oi.service_start_time between oi2.service_start_time and ((oi2.service_start_time-1)+(oi2.quantity*oi2.service_duration)+oi2.service_gap) "+
					" or ((oi.service_start_time-1)+(oi.quantity*oi.service_duration)+oi.service_gap) between oi2.service_start_time and ((oi2.service_start_time-1)+(oi2.quantity*oi2.service_duration)+oi2.service_gap)) "+
					" and oi.id = p.client_key and p.status in(0,9) and p.is_generic_form = 0 and p.phase not in ('cancel','cancel30') ");

			while(rs.next())
			{
				String selectedresource = parseNull(rs.value("resource"));
				String selectedroom = parseNull(rs.value("secondary_resource"));
				if(selectedresource.length() > 0) resources.get(selectedresource).setAvailable(false);
				if(selectedroom.length() > 0) 
				{
					rooms.get(selectedroom).setAvailable(false);
					rooms.get(selectedroom).setIdService(parseNull(rs.value("id")));
				}
			}

			String assignresource = "";
			for(String rscname : resources.keySet())
			{
				if(resources.get(rscname).isAvailable()) 
				{
					assignresource = rscname;
					break;
				}
			}

			String assignroom = "";
			for(String rscname : rooms.keySet())
			{
				if(rooms.get(rscname).isAvailable()) 
				{
					assignroom = rscname;
					break;
				}
			}
				
			System.out.println("Assigning resource : " + assignresource + " assigning room : " + assignroom);
			if(assignresource.length() > 0)
			{
				etn.executeCmd("update order_items set resource = "+escape.cote(assignresource) + " where id = " + clid);
			}
			if(assignroom.length() > 0)
			{
				etn.executeCmd("update order_items set secondary_resource = "+escape.cote(assignroom) + " where id = " + clid);
			}
			if(assignresource.length() > 0 && assignroom.length() > 0) retVal = 0;
			if(assignresource.length() > 0 && assignroom.length() == 0){ 
                           retVal = 18;
                        } 
			if(assignresource.length() == 0 && assignroom.length() > 0) retVal = 19;

			if(retVal == 0 || retVal == 18  || retVal == 19)
			{
				System.out.println("Assignresource ret val : " + retVal);
				String msg = "success";
				if(retVal == 18) msg = "No rooms can be assigned";
				else if(retVal == 19) msg = "No resources can be assigned";

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