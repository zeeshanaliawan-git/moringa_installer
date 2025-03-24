package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import java.util.Properties;
import org.json.JSONObject;
import org.json.JSONArray;

/** 
 * Must be extended.
*/
public class Sql extends OtherAction { 


	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		return execute(wkid, clid, param);
	}

	public int execute( int wkid , String clid, String param )
	{ 
		System.out.println("Sql wid:"+wkid+" cl:"+clid+" parm:"+param);
		if( param.equalsIgnoreCase("StockPlus") )
		{
			updateStock(clid, true);
			return 0;
		}

		if( param.equalsIgnoreCase("StockMinus") )
		{
			updateStock(clid, false);
			return 0;
		}

		Set rs = etn.execute("select nextOnerr,throwErr,sqltext  from osql where id="+ escape.cote(param) );
		if(!rs.next() ) return(1);

		boolean next= rs.value(0).length() > 0;
		boolean signal= rs.value(1).length() > 0;
		String sql = rs.value(2).replace("$clid",escape.cote(clid));
		sql = sql.replace("$wkid",""+wkid);
		System.out.println(sql);
		String tsql[] = sql.split(";");
		rs = etn.execute( tsql );
		if( rs == null ) return(-1);
		if(  !rs.next() && ( signal || next ) ) return(2);
		if( signal || next  ) 
		{
			String lastCode = rs.value(0) , lastmsg = rs.value(1) ;
			while( rs.next() )
			{ 
				lastCode = rs.value(0) ; lastmsg = rs.value(1) ; 
			}

		 
			System.out.println("Sql:errcode ->"+lastCode ); 
			//special code where we have to wait in phase due to previous action called. 
			//Like mail reminders where we have to wait in phase till reminder mail/sms is sent 
			//120000 is returned so that engine does not try moving to next phase
			//by default next attempt will be made after 30mins but if we want next attempt to be made like after 15mins then we return 120015 similarly for 30mins 120030
			int nlastcode = -1;
			try
			{
				nlastcode = Integer.parseInt(lastCode);
			}
			catch(Exception e) {}
			if(nlastcode >= 120000) 
			{
				//default interval for this action to execute again is 30mins
				int intervalmins = nlastcode - 120000;
				if(intervalmins <= 0) intervalmins = 30;

				etn.executeCmd("update post_work set start = null, priority = date_add(now(), interval "+intervalmins+" minute), flag = 0 where id="+wkid );

				return (0);
			}

			if( "nop".equals( lastCode ) || lastCode.length() == 0 ) 
			{  
				etn.executeCmd("update post_work set errmessage='nop' where id="+wkid );
				return(0);
			}

			etn.executeCmd("update post_work set errcode="+lastCode+
			",errmessage="+escape.cote(lastmsg)+
			" where id="+wkid );
	  
		   if( next ) ((Scheduler)env.get("sched")).endJob( wkid , clid );
		}
	  
		return(0);

	}
	
	private void updateComewithsStock(String comeWithJson, String qty, boolean add)
	{
		if(Util.parseNull(comeWithJson).length() > 0)
		{
			String operator = "+";
			if(!add) operator = "-";
			System.out.println("In updateComewithsStock ");
			try
			{
				JSONArray comewith = new JSONArray(Util.parseNull(comeWithJson));
				if(comewith != null && comewith.length() > 0)
				{
					for(int i=0; i<comewith.length(); i++)
					{
						String comeWithVariantId = Util.parseNull(comewith.getJSONObject(i).getString("variant_id"));
						if(comeWithVariantId.length() > 0)
						{
							//for offers we have no stock 
							Set rsP = etn.execute("select pv.* from "+env.getProperty("CATALOG_DB")+".product_variants pv, "+
								env.getProperty("CATALOG_DB")+".products p "+
								" where p.product_type not in ('offer_postpaid','offer_prepaid','simple_virtual_product','configurable_virtual_product') "+
								" and p.id = pv.product_id and pv.id = "+escape.cote(comeWithVariantId));
							if(rsP.next())
							{
								etn.executeCmd("update "+env.getProperty("CATALOG_DB")+".product_variants set stock = stock "+operator+" "+qty+" where id = "+ escape.cote(comeWithVariantId));
							}
						}
					}
				}
			}
			catch(Exception e)
			{
				System.out.println("Error updating comewiths stock");
				e.printStackTrace();				
			}
		}						
	}

	private void updateStock(String clid, boolean add)
	{
		String operator = "+";
		if(!add) operator = "-";
		System.out.println("In updateStock clid : " + clid + " POST_WORK_SPLIT_ITEMS : " + Util.parseNull(env.getProperty("POST_WORK_SPLIT_ITEMS")) + " operator : " + operator);
		if("1".equals(env.getProperty("POST_WORK_SPLIT_ITEMS")))
		{
			Set rs = etn.execute("select * from order_items where id = " + escape.cote(clid));
			if(rs.next())
			{
				if("product".equals(rs.value("product_type")) || "simple_product".equals(rs.value("product_type")) || "configurable_product".equals(rs.value("product_type")))
				{
					String variantId = Util.parseNull(rs.value("product_ref"));
					String qty = Util.parseNull(rs.value("quantity"));
					if(variantId.length() > 0)
					{
						etn.executeCmd("update "+env.getProperty("CATALOG_DB")+".product_variants set stock = stock "+operator+" "+qty+" where id = "+ escape.cote(variantId));
						updateComewithsStock(Util.parseNull(rs.value("comewiths")), qty, add);
						
						String query1 = "select pv.product_id,c.site_id,'publish','marketing_rules',now() from product_variants pv left join products p on pv.product_id = p.id"+
							" left join catalogs c on c.id=p.catalog_id where pv.id="+escape.cote(variantId);
						etn.executeCmd("insert into "+env.getProperty("PROD_PORTAL_DB")+".publish_content (cid,site_id,publication_type,ctype,action_dt) "+query1);
						etn.execute("select semfree("+escape.cote(env.getProperty("PORTAL_ENG_SEMA"))+")");
					}
				}
			}
		}
		else
		{
			Set rs = etn.execute("select * from orders where id = " + escape.cote(clid));
			if(rs.next())
			{
				String parentId = rs.value("parent_uuid");
				Set rs2 = etn.execute("select * from order_items where parent_id =" + escape.cote(parentId));
				while(rs2.next())
				{
					if("product".equals(rs2.value("product_type")) || "simple_product".equals(rs2.value("product_type")) || "configurable_product".equals(rs2.value("product_type")))
					{
						String variantId = Util.parseNull(rs2.value("product_ref"));
						String qty = Util.parseNull(rs2.value("quantity"));
						if(variantId.length() > 0)
						{
							etn.executeCmd("update "+env.getProperty("CATALOG_DB")+".product_variants set stock = stock "+operator+" "+qty+" where id = "+ escape.cote(variantId));
							updateComewithsStock(Util.parseNull(rs2.value("comewiths")), qty, add);


							String query1 = "select pv.product_id,c.site_id,'publish','marketing_rules',now() from "+env.getProperty("CATALOG_DB")+
								".product_variants pv left join "+env.getProperty("CATALOG_DB")+".products p on pv.product_id = p.id"+
								" left join "+env.getProperty("CATALOG_DB")+".catalogs c on c.id=p.catalog_id where pv.id="+escape.cote(variantId);

							etn.executeCmd("insert into "+env.getProperty("PROD_PORTAL_DB")+".publish_content (cid,site_id,publication_type,ctype,action_dt) "+query1);
							etn.execute("select semfree("+escape.cote(env.getProperty("PORTAL_ENG_SEMA"))+")");
						}							
					}
				}
			}				
		}		
	}
}
