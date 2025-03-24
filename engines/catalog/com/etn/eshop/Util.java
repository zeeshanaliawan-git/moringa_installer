package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import java.util.*;
import com.etn.sql.escape;

public class Util
{
	public static String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	private static void findAllParentFolders(ClientSql Etn, String folderId, List<String> folderIds)
	{		
		Set rs = Etn.execute("select * from products_folders where id = "+escape.cote(folderId));
		if(rs.next())
		{
			folderIds.add(rs.value("uuid"));
			int parentFolderId = 0;
			try {
				parentFolderId = Integer.parseInt(rs.value("parent_folder_id"));
			} catch (Exception e) {}
			if(parentFolderId > 0)
			{
				findAllParentFolders(Etn, ""+parentFolderId, folderIds);
			}
		}
	}
	
	public static void checkProductViewsUsage(ClientSql Etn, Properties env, String siteid, String productId, boolean isPublish)
	{
		System.out.println("in checkProductViewsUsage");
		System.out.println("siteid : "+siteid + " productId : " + productId + " isPublish : " + isPublish);
		Set rs = Etn.execute("select p.*, c.catalog_uuid from products p, catalogs c where c.id = p.catalog_id and p.id = "+escape.cote(productId));
		if(rs.rs.Rows == 0) return;
		rs.next();
		List<String> freemarkerPageIds = new ArrayList<>();			
		List<String> structuredContentIds = new ArrayList<>();			

		//for unpublish we check in the list of products already in a page
		//for publish a product might already is published but is published again for some changes so we check in the results table first
		System.out.println("select distinct p.parent_page_id, p.type as page_type "+
				" from " + env.getProperty("PAGES_DB")+".products_view_bloc_results r "+
				" join " + env.getProperty("PAGES_DB")+".products_view_bloc_data d on d.id = r.data_id and d.site_id = "+escape.cote(siteid)+" and d.for_prod_site = 1 "+
				" join " + env.getProperty("PAGES_DB")+".pages p on p.id = d.page_id "+
				" where r.product_id = "+escape.cote(productId)); 
									
		Set rsP = Etn.execute("select distinct p.parent_page_id, p.type as page_type "+
				" from " + env.getProperty("PAGES_DB")+".products_view_bloc_results r "+
				" join " + env.getProperty("PAGES_DB")+".products_view_bloc_data d on d.id = r.data_id and d.site_id = "+escape.cote(siteid)+" and d.for_prod_site = 1 "+
				" join " + env.getProperty("PAGES_DB")+".pages p on p.id = d.page_id "+
				" where r.product_id = "+escape.cote(productId)); 

		while(rsP.next())
		{
			if("freemarker".equals(rsP.value("page_type")) && freemarkerPageIds.contains(rsP.value("parent_page_id")) == false) freemarkerPageIds.add(rsP.value("parent_page_id"));
			else if("structured".equals(rsP.value("page_type")) && structuredContentIds.contains(rsP.value("parent_page_id")) == false) structuredContentIds.add(rsP.value("parent_page_id"));				
		}

		//maybe the product is being published for first time so it wont be there in the results table
		//so we check the catalog id/folder ids and run query again to get returned product IDs
		if(isPublish)
		{
			List<String> folderIds = new ArrayList<>();
			folderIds.add(rs.value("catalog_uuid"));
			if(parseNull(rs.value("folder_id")).length() > 0) 
			{
				findAllParentFolders(Etn, parseNull(rs.value("folder_id")), folderIds);
			}
			String inclause = "";
			for(int i=0;i<folderIds.size();i++)
			{
				if(i>0) inclause += ",";
				inclause += escape.cote(folderIds.get(i));
			}
			System.out.println("select d.view_query, p.parent_page_id, p.type as page_type "+
							" join " + env.getProperty("PAGES_DB")+".products_view_bloc_criteria c "+
							" join "+env.getProperty("PAGES_DB")+".products_view_bloc_data d on c.data_id = d.id and d.site_id = "+escape.cote(siteid)+" and for_prod_site = 1 "+
							" join "+env.getProperty("PAGES_DB")+".pages p on p.id = d.page_id "+
							" where c.cid in ("+inclause+")");
							
			rsP = Etn.execute("select distinct d.view_query, p.parent_page_id, p.type as page_type "+
							" from " + env.getProperty("PAGES_DB")+".products_view_bloc_criteria c "+
							" join "+env.getProperty("PAGES_DB")+".products_view_bloc_data d on c.data_id = d.id and d.site_id = "+escape.cote(siteid)+" and for_prod_site = 1 "+
							" join "+env.getProperty("PAGES_DB")+".pages p on p.id = d.page_id "+
							" where c.cid in ("+inclause+")");
							
			while(rsP.next())
			{
				String qry = rsP.value("view_query");
				Set rsQ = Etn.execute(qry);
				while(rsQ.next())
				{
					//from PagesGenerator.java we always save the query in db with first column as page ID ... make sure its always like that otherwise we are in trouble
					String qryProductId = rsQ.value(0);
					if(qryProductId.equals(productId))
					{
						//we got the new productId in the results of the query of view which means this page must be marked for regenerate
						if("freemarker".equals(rsP.value("page_type")) && freemarkerPageIds.contains(rsP.value("parent_page_id")) == false) freemarkerPageIds.add(rsP.value("parent_page_id"));
						else if("structured".equals(rsP.value("page_type")) && structuredContentIds.contains(rsP.value("parent_page_id")) == false) structuredContentIds.add(rsP.value("parent_page_id"));
						break;
					}
				}
			}
		}
		
		for(int i=0;i<freemarkerPageIds.size();i++)
		{
			System.out.println("Mark freemarker page for regenerate. Page ID : " + freemarkerPageIds.get(i));			
			rsP = Etn.execute("select * from "+env.getProperty("PAGES_DB")+".freemarker_pages where publish_status = 'published' and published_ts >= updated_ts and id = "+ escape.cote(freemarkerPageIds.get(i)));
			
			String qry = "update "+env.getProperty("PAGES_DB")+".freemarker_pages set to_generate = 1, to_generate_by = 0, updated_ts = now() ";
			//page was already green so we mark it for republishing also
			if(rsP.rs.Rows > 0)
			{
				System.out.println("Page ID : " + freemarkerPageIds.get(i) + " is already in green so we mark it for publishing also");
				qry += ", to_publish = 1, to_publish_by = 0, to_publish_ts = now() ";
			}
			qry += " where id = " + escape.cote(freemarkerPageIds.get(i));
			System.out.println(qry);
			Etn.executeCmd(qry);
		}
		for(int i=0;i<structuredContentIds.size();i++)
		{
			System.out.println("Mark structured content for regenerate. Content ID : " + structuredContentIds.get(i));
			rsP = Etn.execute("select * from "+env.getProperty("PAGES_DB")+".structured_contents where publish_status = 'published' and published_ts >= updated_ts and id = "+ escape.cote(structuredContentIds.get(i)));
			
			String qry = "update "+env.getProperty("PAGES_DB")+".structured_contents set to_generate = 1, to_generate_by = 0, updated_ts = now() ";
			//content was already green so we mark it for republishing also
			if(rsP.rs.Rows > 0)
			{
				System.out.println("Content ID : " + structuredContentIds.get(i) + " is already in green so we mark it for publishing also");
				qry += ", to_publish = 1, to_publish_by = 0, to_publish_ts = now() ";
			}
			qry += " where id = " + escape.cote(structuredContentIds.get(i));
			System.out.println(qry);
			Etn.executeCmd(qry);
		}
		
		Set rsC = Etn.execute("select * from "+env.getProperty("PAGES_DB")+".config where code = 'SEMAPHORE'");
		if(rsC.next())
		{
			Etn.execute("select semfree("+escape.cote(rsC.value("val"))+")");
		}
		
	}
		
}