package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import java.util.Properties;
import com.etn.sql.escape;
import java.lang.Process;



public class Remove extends OtherAction
{
	public int execute( ClientSql etn, int wkid , String clid, String param )
	{
		if("product".equalsIgnoreCase(param)) return deleteProduct(etn, wkid, clid);
		else if("catalog".equalsIgnoreCase(param)) return deleteCatalog(etn, wkid, clid);
		else if("familie".equalsIgnoreCase(param)) return deleteFamilie(etn, wkid, clid);
		else if("cartrule".equalsIgnoreCase(param)) return deleteCartRules(etn, wkid, clid);
		else if("additionalfee".equalsIgnoreCase(param)) return deleteAdditionalFee(etn, wkid, clid);
		else if("promotion".equalsIgnoreCase(param)) return deletePromotion(etn, wkid, clid);
		else if("comewith".equalsIgnoreCase(param)) return deleteComeWith(etn, wkid, clid);
		else if("subsidy".equalsIgnoreCase(param)) return deleteSubsidy(etn, wkid, clid);
		else if("deliveryfee".equalsIgnoreCase(param)) return deleteDeliveryFee(etn, wkid, clid);
		else if("deliverymin".equalsIgnoreCase(param)) return deleteDeliveryMin(etn, wkid, clid);
		else if("quantitylimits".equalsIgnoreCase(param)) return deleteQuantityLimit(etn, wkid, clid);
		return -1;
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	private int deleteCatalog(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete catalog id : " + clid);
		try
		{
			String proddb = env.getProperty("PROD_DB");

			etn.executeCmd("delete from "+proddb+".product_tabs where product_id in (select id from products where catalog_id = "+escape.cote(clid)+") ");
			etn.executeCmd("delete from "+proddb+".share_bar where ptype = 'product' and id in (select id from products where catalog_id = "+escape.cote(clid)+") ");
			etn.executeCmd("delete from "+proddb+".products where catalog_id = "+escape.cote(clid)+" ");
			etn.executeCmd("delete from "+proddb+".catalog_business_types where catalog_id = "+escape.cote(clid)+" ");
            etn.executeCmd("delete pf, pfd from "+proddb+".products_folders pf left join "+proddb+".products_folders_details pfd on pfd.folder_id = pf.id where pf.catalog_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".catalogs where id = "+escape.cote(clid)+" ");

		    ((Scheduler)env.get("sched")).endJob( wkid , clid );

			Set rs = etn.execute("Select * from catalogs where id = "+escape.cote(clid));
			if(rs.next())
			{
				String siteid = rs.value("site_id");
				etn.executeCmd("update "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and task in ('publish','unpublish') and site_id = "+escape.cote(siteid)+" and content_type = 'catalog' and content_id = "+escape.cote(clid));					
				etn.executeCmd("insert into "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
					" values("+escape.cote(siteid)+", 'catalog', "+escape.cote(clid)+", 'unpublish') ");
					
				etn.execute("select semfree("+escape.cote(env.getProperty("PORTAL_ENG_SEMA"))+")");
			}
			
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }

	}

	private int deleteProduct(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete product id : " + clid);
		try
		{
			Set rs = etn.execute("select c.site_id,p.product_version,p.updated_by,p.product_definition_id from products p, catalogs c where c.id= p.catalog_id and p.id = " + escape.cote(clid));
			rs.next();
			String siteid = rs.value("site_id");
			
			String proddb = env.getProperty("PROD_DB");

			etn.executeCmd("delete from "+proddb+".product_answers where question_id in (select id from "+proddb+".product_questions where product_id = " + escape.cote(clid)+")");
			etn.executeCmd("delete from "+proddb+".product_attribute_values where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_comments where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_descriptions where product_id = " + escape.cote(clid));
            etn.executeCmd("delete from "+proddb+".products_meta_tags where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_essential_blocks where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_images where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_question_clients where question_uuid in (select question_uuid from "+proddb+".product_questions where product_id = " + escape.cote(clid)+")");
			etn.executeCmd("delete from "+proddb+".product_questions where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_relationship where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_skus where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_stocks where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_tabs where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_tags where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_variant_details where product_variant_id in (select id from "+proddb+".product_variants where product_id = " + escape.cote(clid)+ ")");
			etn.executeCmd("delete from "+proddb+".product_variant_ref where product_variant_id in (select id from "+proddb+".product_variants where product_id = " + escape.cote(clid)+")");
			etn.executeCmd("delete from "+proddb+".product_variant_resources where product_variant_id in (select id from "+proddb+".product_variants where product_id = " + escape.cote(clid)+")");
			etn.executeCmd("delete from "+proddb+".share_bar where ptype = 'product' and id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".product_variants where product_id = " + escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".products where id = " + escape.cote(clid));

			((Scheduler)env.get("sched")).endJob( wkid , clid );
			
			String productVersion = parseNull(rs.value("product_version"));
			String updatedBy = parseNull(rs.value("updated_by"));
			String productV2Id = parseNull(rs.value("product_definition_id"));

			if(productVersion.equalsIgnoreCase("v1")){
				etn.executeCmd("update "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and task in ('publish','unpublish') and site_id = "+escape.cote(siteid)+" and content_type = 'product' and content_id = "+escape.cote(clid));
				etn.executeCmd("insert into "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
					" values("+escape.cote(siteid)+", 'product', "+escape.cote(clid)+", 'unpublish') ");
			}else{
				if(!productV2Id.isEmpty()){
					System.out.println("Remove:: Marking Product V2's Page for unpublish=================");
					etn.execute("delete from "+proddb+".products_definition where id="+escape.cote(productV2Id));
					etn.execute("update "+env.getProperty("PAGES_DB")+".structured_contents set to_unpublish='1', to_unpublish_by="+
						escape.cote(updatedBy)+",to_unpublish_ts=now(),publish_status='queued',publish_log='queued' where id = (select page_id from "+
						env.getProperty("PAGES_DB")+".products_map_pages where product_id="+escape.cote(clid)+")");

					Set rsPagesEngine = etn.execute("select val from "+env.getProperty("PAGES_DB")+".config where code='SEMAPHORE'");
					rsPagesEngine.next();
					etn.execute("select semfree("+escape.cote(rsPagesEngine.value("val"))+")");
				}
			}

			etn.execute("select semfree("+escape.cote(env.getProperty("PORTAL_ENG_SEMA"))+")");
			Util.checkProductViewsUsage(etn, env, siteid, clid, false);
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int deleteFamilie(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete familie id : " + clid);
		try
		{
			String proddb = env.getProperty("PROD_DB");

			Set rsc = etn.execute("select * from familie where id = " + escape.cote(clid));
			rsc.next();

			etn.executeCmd("delete from "+proddb+".familie where id = "+escape.cote(clid)+" ");

		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }

	}

	private int deletePromotion(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete promotion id : " + clid);
		try
		{
			String proddb = env.getProperty("PROD_DB");

			etn.executeCmd("delete from "+proddb+".promotions_rules where promotion_id = "+escape.cote(clid)+" ");
			etn.executeCmd("delete from "+proddb+".promotions where id = "+escape.cote(clid)+" ");

		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }

	}

	private int deleteComeWith(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete come-with id : " + clid);
		try
		{
			String proddb = env.getProperty("PROD_DB");

			etn.executeCmd("delete from "+proddb+".comewiths_rules where comewith_id = "+escape.cote(clid)+" ");
			etn.executeCmd("delete from "+proddb+".comewiths where id = "+escape.cote(clid)+" ");

		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }

	}

	private int deleteCartRules(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete cart rule id : " + clid);
		try
		{
			String proddb = env.getProperty("PROD_DB");

			etn.executeCmd("delete from "+proddb+".cart_promotion_coupon where cp_id = "+escape.cote(clid)+" ");
			etn.executeCmd("delete from "+proddb+".cart_promotion where id = "+escape.cote(clid)+" ");

		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }

	}

	private int deleteAdditionalFee(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete additional fee id : " + clid);
		try
		{
			String proddb = env.getProperty("PROD_DB");

			etn.executeCmd("delete from "+proddb+".additionalfee_rules where add_fee_id = "+escape.cote(clid)+" ");
			etn.executeCmd("delete from "+proddb+".additionalfees where id = "+escape.cote(clid)+" ");

		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }

	}

	private int deleteSubsidy(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete subsidy id : " + clid);
		try
		{
			String proddb = env.getProperty("PROD_DB");

			etn.executeCmd("delete from "+proddb+".subsidies_rules where subsidy_id = "+escape.cote(clid)+" ");
			etn.executeCmd("delete from "+proddb+".subsidies where id = "+escape.cote(clid)+" ");

		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }

	}

        private int deleteDeliveryFee(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete delivery fee id : " + clid);
		try
		{
			String proddb = env.getProperty("PROD_DB");

			etn.executeCmd("delete from "+proddb+".deliveryfees_rules where deliveryfee_id = "+escape.cote(clid)+" ");
			etn.executeCmd("delete from "+proddb+".deliveryfees where id = "+escape.cote(clid)+" ");

		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }

	}

	private int deleteDeliveryMin(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete delivery min id : " + clid);
		try
		{
			String proddb = env.getProperty("PROD_DB");

			etn.executeCmd("delete from "+proddb+".deliverymins where id = "+escape.cote(clid)+" ");

		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }

	}

	private int deleteQuantityLimit(ClientSql etn, int wkid, String clid)
	{
		System.out.println("Going to delete quantity limit id : " + clid);
		try
		{
			String proddb = env.getProperty("PROD_DB");

			etn.executeCmd("delete from "+proddb+".quantitylimits_rules where quantitylimit_id = "+escape.cote(clid)+" ");
			etn.executeCmd("delete from "+proddb+".quantitylimits where id = "+escape.cote(clid)+" ");

		       ((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }

	}

}