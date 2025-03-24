package com.etn.eshop;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import java.util.*;
import com.etn.sql.escape;
import java.lang.Process;
import java.io.IOException;
import java.nio.file.*;

/*
*
*
*
*
*/

public class Publish extends OtherAction
{
	public int execute( ClientSql etn, int wkid , String clid, String param )
	{

		System.out.println("param:"+param+":");
		if("translation".equalsIgnoreCase(param)) return publishTranslation(etn, wkid, clid);
		else if("catalog".equalsIgnoreCase(param)) return publishCatalog(etn, wkid, clid);
		else if("product".equalsIgnoreCase(param)) return publishProduct(etn, wkid, clid);
		else if("promotion".equalsIgnoreCase(param)) return publishPromotions(etn, wkid, clid);
		//familie not used any more
		//else if("familie".equalsIgnoreCase(param)) return publishFamilie(etn, wkid, clid);

		//NOTE:Shop parameters are now published every time a menu is published as users mostly forget to
		//publish it separately
		//else if("shop".equalsIgnoreCase(param)) return publishShop(etn, wkid, clid);
		else if("resources".equalsIgnoreCase(param)) return publishResources(etn, wkid, clid);
		else if("landingpage".equalsIgnoreCase(param)) return publishLandingPages(etn, wkid, clid);
		else if("cartrule".equalsIgnoreCase(param)) return publishCartRules(etn, wkid, clid);
		else if("additionalfee".equalsIgnoreCase(param)) return publishAdditionalFees(etn, wkid, clid);
		else if("comewith".equalsIgnoreCase(param)) return publishComeWiths(etn, wkid, clid);
		else if("subsidy".equalsIgnoreCase(param)) return publishSubsidies(etn, wkid, clid);
		else if("deliveryfee".equalsIgnoreCase(param)) return publishDeliveryFees(etn, wkid, clid);
		else if("deliverymin".equalsIgnoreCase(param)) return publishDeliveryMins(etn, wkid, clid);
		else if("moduleparams".equalsIgnoreCase(param)) return publishModuleParameters(etn, wkid, clid);
		else if("quantitylimits".equalsIgnoreCase(param)) return publishQuantityLimits(etn, wkid, clid);
		return -1;
	}

	private String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

	private int insertRows(ClientSql etn, Set rs, String tablename)
	{
		return insertRows(etn, rs, tablename, null, null);
	}

	private int insertRows(ClientSql etn, Set rs, String tablename, Map<String, String> variantsStock, Map<String, String> variantsStockThresh)
	{

		String proddb = env.getProperty("PROD_DB");
		int rows = 0;
		while(rs.next())
		{
			String iq = " insert ignore into "+proddb+"."+tablename+" ";
			String iqcols = "";
			String iqvals = "";
			for(int i=0;i< rs.Cols; i++)
			{
				boolean isnullable = false;
				try
				{
					Set _rs = etn.execute("select * from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA = "+escape.cote(env.getProperty("PREPROD_CATALOG_DB"))+" and TABLE_NAME = "+escape.cote(tablename)+" and column_name = "+escape.cote(rs.ColName[i].toLowerCase())+" ");
					if(_rs.next())
					{
						String _dataType = _rs.value("DATA_TYPE");
						if(("int".equalsIgnoreCase(_dataType) || "bigint".equalsIgnoreCase(_dataType) || "decimal".equalsIgnoreCase(_dataType) || "smallint".equalsIgnoreCase(_dataType) ||
							"double".equalsIgnoreCase(_dataType) || "timestamp".equalsIgnoreCase(_dataType) || "datetime".equalsIgnoreCase(_dataType) || "enum".equalsIgnoreCase(_dataType) ||
							"date".equalsIgnoreCase(_dataType) || "time".equalsIgnoreCase(_dataType)) && _rs.value("IS_NULLABLE").equalsIgnoreCase("YES"))
							{
								isnullable = true;
							}															
					}
				} catch(Exception ex) { ex.printStackTrace(); }
				
				if(rs.ColName[i].equalsIgnoreCase("created_on"))
				{
					if(!"product_variants".equals(tablename))
					{
						if(i > 0)
						{
							iqcols += ", ";
							iqvals += ", ";
						}
						iqcols += rs.ColName[i].toLowerCase();
						iqvals += " now() ";
					}
				}
                                else if(rs.ColName[i].equalsIgnoreCase("start_date") || rs.ColName[i].equalsIgnoreCase("end_date") || rs.ColName[i].equalsIgnoreCase("first_publish_on"))
				{
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
					}
					iqcols += rs.ColName[i].toLowerCase();
					iqvals += " str_to_date( " + escape.cote(parseNull(rs.value(i))) + " ,'%d/%m/%Y %H:%i:%s') ";
				}
				else if("products".equals(tablename) && rs.ColName[i].equalsIgnoreCase("stock"))
				{
					//dont push the stock from preprod to prod
				}
				else if("products".equals(tablename) && rs.ColName[i].equalsIgnoreCase("rating_score"))
				{
					//dont push rating
				}
				else if("products".equals(tablename) && rs.ColName[i].equalsIgnoreCase("rating_count"))
				{
					//dont push rating
				}
				else if("products".equals(tablename) && rs.ColName[i].equalsIgnoreCase("is_stock_alert"))
				{
					//dont push stock alert flag
				}
				else if("product_variants".equals(tablename) && rs.ColName[i].equalsIgnoreCase("stock"))
				{
					//always use production's stock if product was already in production
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
					}
					String variantUuid = parseNull(rs.value("uuid"));

					String vStock = "0";
					if(variantsStock != null && variantsStock.get(variantUuid) != null) vStock = variantsStock.get(variantUuid);

					iqcols += rs.ColName[i].toLowerCase();
					iqvals += escape.cote(vStock);
				}
				else if("product_variants".equals(tablename) && rs.ColName[i].equalsIgnoreCase("stock_thresh"))
				{
					//always use production's stock_thresh if product was already in production
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
					}
					String variantUuid = parseNull(rs.value("uuid"));

					String vStockThresh = "0";
					if(variantsStockThresh != null && variantsStockThresh.get(variantUuid) != null) vStockThresh = variantsStockThresh.get(variantUuid);

					iqcols += rs.ColName[i].toLowerCase();
					iqvals += escape.cote(vStockThresh);
				}
				else if("products".equals(tablename) && rs.ColName[i].equalsIgnoreCase("link_id"))
				{
					//means its NULL so we put NULL in production also not 0
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
					}

					if(parseNull(rs.value(i)).length() == 0)
					{
						iqcols += rs.ColName[i].toLowerCase();
						iqvals += " NULL ";
					}
					else
					{
						iqcols += rs.ColName[i].toLowerCase();
						iqvals += escape.cote(parseNull(rs.value(i)));
					}
				}
				else if("product_comments".equals(tablename) && rs.ColName[i].equalsIgnoreCase("tm"))
				{
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
					}
					iqcols += rs.ColName[i].toLowerCase();
					iqvals += " str_to_date( " + escape.cote(parseNull(rs.value(i))) + " ,'%d/%m/%Y %H:%i:%s') ";
				}
				else if(!rs.ColName[i].equalsIgnoreCase("updated_on"))
				{
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
					}
					if(parseNull(rs.value(i)).length() == 0 && isnullable)
					{
						iqcols += "`" + rs.ColName[i].toLowerCase() + "`";
						iqvals += " NULL ";
					}
					else
					{
						//some tables people have used column names as key words of mariadb so we have to add ` before/after the column name otherwise queries fail
						iqcols += "`" + rs.ColName[i].toLowerCase() + "`";
						iqvals += escape.cote(parseNull(rs.value(i)));
					}
				}
			}
			iq += " ( " + iqcols + " ) values ("+iqvals+") ";
			System.out.println("queries =====> "+iq);
			System.out.println("tablename =====> "+tablename);

			int _r = etn.executeCmd(iq);
			if(_r > 0) rows++;
		}
		return rows;
	}

	private int updateRows(ClientSql etn, Set rs, String tablename)
	{
		return updateRows(etn, rs, tablename, null, null);
	}

	private int updateRows(ClientSql etn, Set rs, String tablename, Map<String, String> variantsStock, Map<String, String> variantsStockThresh)
	{
		String proddb = env.getProperty("PROD_DB");
		int rows = 0;

		while(rs.next())
		{
			String iq = " update ignore "+proddb+"."+tablename+" set ";
			String iqcolvals = "";
			String uuid = "";
			String pvid = "";

			for(int i=0;i< rs.Cols; i++)
			{
				if("product_variants".equals(tablename) && rs.ColName[i].equalsIgnoreCase("uuid"))
				{
					uuid = parseNull(rs.value(rs.ColName[i]));
				}
				else if("product_variants".equals(tablename) && rs.ColName[i].equalsIgnoreCase("id"))
				{
					pvid = parseNull(rs.value(rs.ColName[i]));
				}
				else if("product_variants".equals(tablename) && rs.ColName[i].equalsIgnoreCase("stock"))
				{
					//always use production's stock if product was already in production
					String variantUuid = parseNull(rs.value("uuid"));

					String vStock = "0";
					if(variantsStock != null && variantsStock.get(variantUuid) != null) vStock = variantsStock.get(variantUuid);

					iqcolvals += "`" + rs.ColName[i].toLowerCase() + "`=" + escape.cote(vStock);

					if(i != rs.Cols-1)
					{
						iqcolvals += ", ";
					}
				}
				else if("product_variants".equals(tablename) && rs.ColName[i].equalsIgnoreCase("stock_thresh"))
				{
					//always use production's stock_thresh if product was already in production
					String variantUuid = parseNull(rs.value("uuid"));

					String vStockThresh = "0";
					if(variantsStockThresh != null && variantsStockThresh.get(variantUuid) != null) vStockThresh = variantsStockThresh.get(variantUuid);

					iqcolvals += "`" + rs.ColName[i].toLowerCase() + "`=" + escape.cote(vStockThresh);

					if(i != rs.Cols-1)
					{
						iqcolvals += ", ";
					}
				}				
				else if("product_variants".equals(tablename) && rs.ColName[i].equalsIgnoreCase("updated_on"))
				{
					iqcolvals += "`" + rs.ColName[i].toLowerCase() + "`= NOW()";

					if(i != rs.Cols-1)
					{
						iqcolvals += ", ";
					}
				}
				else if(!rs.ColName[i].equalsIgnoreCase("updated_on") && !rs.ColName[i].equalsIgnoreCase("created_on"))
				{

					//some tables people have used column names as key words of mariadb so we have to add ` before/after the column name otherwise queries fail
					iqcolvals += "`" + rs.ColName[i].toLowerCase() + "`=" + escape.cote(parseNull(rs.value(i)));

					if(i != rs.Cols-1)
					{
						iqcolvals += ", ";
					}
				}
			}

			iq += iqcolvals + " where id = " + escape.cote(pvid) + " and uuid = " + escape.cote(uuid);

			int _r = etn.executeCmd(iq);
			if(_r > 0) rows++;
		}
		return rows;
	}

	public static void copyFile(String srcFile, String destFile) throws IOException {
        copyFile(srcFile, destFile, true);
    }

    public static void copyFile(String srcFile, String destFile, boolean overwriteExisting) throws IOException {
        Path srcPath = Paths.get(srcFile);
        Path destPath = Paths.get(destFile);
        if(overwriteExisting){
        	Files.copy(srcPath, destPath, StandardCopyOption.REPLACE_EXISTING);
        }
        else{
        	Files.copy(srcPath, destPath);
        }
    }

	public static void copyDirectory(String src, String dest) throws IOException {
        Path srcPath = Paths.get(src);
        Path destPath = Paths.get(dest);
        copyDirectory(srcPath, destPath);
    }

    public static void copyDirectory(Path srcPath, Path destPath) throws IOException {

        System.out.println("srcPath  : " + srcPath);
        System.out.println("destPath : " + destPath);

        if (Files.exists(srcPath) && Files.isDirectory(srcPath)) {
            if (!Files.exists(destPath)) {
                Files.createDirectories(destPath);
                System.out.println("Dir Created: " + destPath);
            }

            DirectoryStream<Path> entries = null;
            try {
                entries = Files.newDirectoryStream(srcPath);
                for (Path srcChildPath : entries) {

                    Path destChildPath = destPath.resolve(srcPath.relativize(srcChildPath));

                    System.out.println("srcChildPath  : " + srcChildPath);
                    System.out.println("destChildPath : " + destChildPath);

                    if (Files.isDirectory(srcChildPath)) {
                        copyDirectory(srcChildPath, destChildPath);
                    }
                    else {
                        Files.copy(srcChildPath, destChildPath, StandardCopyOption.REPLACE_EXISTING);
                    }
                }
            }
            finally {
                if (entries != null) {
                    entries.close();
                }
            }
        }
        else {
            return;
        }
    }

	/*void updateFreeMarkerPage(ClientSql Etn,String id,String updatedBy,String dbname){
		System.out.println("=================Here to update Page=================");
		
		Etn.executeCmd("update "+dbname+".freemarker_pages SET to_generate=1 where id IN ("+
            "select parent_page_id from "+dbname+".pages where id IN (select page_id from "+dbname+".pages_blocs p "+
            "left join "+dbname+".blocs_details b ON p.bloc_id = b.bloc_id where b.template_data like "+escape.cote("%"+id+"%")+") "+
            "group by parent_page_id)");

		Set rs = Etn.execute("select published_ts,updated_ts,published_ts>updated_ts as 'changed' from "+dbname+".freemarker_pages where id IN ("+
		"select parent_page_id from "+dbname+".pages where id IN (select page_id from "+dbname+".pages_blocs p "+
		"left join "+dbname+".blocs_details b ON p.bloc_id = b.bloc_id where b.template_data like "+escape.cote("%"+id+"%")+") "+
		"group by parent_page_id)");

		if(rs!=null && rs.rs.Rows>0){
			while(rs.next()){
				if(parseNull(rs.value("published_ts")).length()>0 && parseNull(rs.value("changed")).equalsIgnoreCase("1")){

					Etn.executeCmd("update "+dbname+".freemarker_pages SET to_unpublish=0,to_publish=1,to_publish_by="+escape.cote(updatedBy)+
					",publish_status='queued',publish_log=null,to_publish_ts=NOW(),updated_ts=NOW(),updated_by="+escape.cote(updatedBy)+" where id IN ("+
					"select parent_page_id from "+dbname+".pages where id IN (select page_id from "+dbname+".pages_blocs p "+
					"left join "+dbname+".blocs_details b ON p.bloc_id = b.bloc_id where b.template_data like "+escape.cote("%"+id+"%")+") "+
					"group by parent_page_id) AND published_ts IS NOT NULL AND updated_ts <= published_ts");
					System.out.println("=================Page Updated=================");
				}
				
			}
		}

		Set rsNew=Etn.execute("select val from "+dbname+".config where code='SEMAPHORE'");
		if(rsNew!=null && rsNew.rs.Rows>0 && rsNew.next()){
			Etn.execute("SELECT semfree("+escape.cote(rsNew.value("val"))+")");
		}
    }*/

	private int publishResources(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish resources ");

			String proddb = env.getProperty("PROD_DB");
			etn.executeCmd("delete from "+proddb+".resources ");
			Set rs = etn.execute("select * from resources ");
			boolean published = false;
			while(rs.next())
			{
				String iq = " insert into "+proddb+".resources ";
				String iqcols = "";
				String iqvals = "";
				for(int i=0;i< rs.Cols; i++)
				{
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
					}
					iqcols += rs.ColName[i];
					iqvals += escape.cote(rs.value(i));
				}
				iq += " ( " + iqcols + " ) values ("+iqvals+") ";
				if(etn.executeCmd(iq) > 0)
				{
					published = true;
				}
			}
			if(published)
			{
			       ((Scheduler)env.get("sched")).endJob( wkid , clid );
				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishTranslation(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish translations ");

			String proddb = env.getProperty("PROD_DB");
			Set rs = etn.execute("select * from langue_msg ");
			boolean published = false;
			while(rs.next())
			{
				String iq = " insert into "+proddb+".langue_msg ";
				String iqcols = "";
				String iqvals = "";
				String uq = " update ";
				String uqcols = "";
				for(int i=0;i< rs.Cols; i++)
				{
					if(i > 0)
					{
						iqcols += ", ";
						iqvals += ", ";
						uqcols += ", ";
					}
					iqcols += rs.ColName[i];
					iqvals += escape.cote(rs.value(i));
					uqcols += rs.ColName[i] + " = " + escape.cote(rs.value(i));
				}
				iq += " ( " + iqcols + " ) values ("+iqvals+") ";
				uq += uqcols ;
				if(etn.executeCmd(iq + " on duplicate key " + uq) > 0)
				{
					published = true;
				}
			}
			if(published)
			{
//				etn.execute("select semfree('PORTAL')");
			       ((Scheduler)env.get("sched")).endJob( wkid , clid );
				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private String getRawImageName(String fromimgname)
	{
		String toimgname = "";
		if(fromimgname.indexOf(".") > -1)
		{
			String ext = fromimgname.substring(fromimgname.lastIndexOf("."));
			String fname = fromimgname.substring(0, fromimgname.lastIndexOf("."));
			toimgname = fname + "_raw" + ext;
		}
		else toimgname = fromimgname + "_raw";

		return toimgname;
	}

	String getGridImageName(String fromimgname)
	{
		String toimgname = "";
		if(fromimgname.indexOf(".") > -1)
		{
			String ext = fromimgname.substring(fromimgname.lastIndexOf("."));
			String fname = fromimgname.substring(0, fromimgname.lastIndexOf("."));
			toimgname = fname + "_grid" + ext;
		}
		else toimgname = fromimgname + "_grid";

		return toimgname;
	}

	private int publishProduct(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish product id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			boolean copyComments = false;
			if("1".equals(env.getProperty("COPY_PRODUCT_COMMENTS"))) copyComments = true;

			Set rs = etn.execute("select first_publish_on from products where id = " + escape.cote(clid));

			if(rs.rs.Rows > 0)
			{
				Random rand = new Random();
				while(rs.next()){

					String firstPublishOn = parseNull(rs.value("first_publish_on"));

					if(firstPublishOn.length() == 0){

						etn.execute("update products set first_publish_on = DATE_ADD(NOW(), INTERVAL " + (rand.nextInt(100)+"") + " SECOND) where id = " + escape.cote(clid));
					}
				}
				
				rs = etn.execute("Select c.site_id from products p inner join catalogs c on c.id = p.catalog_id and p.id = "+escape.cote(clid));
				rs.next();
				String siteid = rs.value("site_id");

				rs = etn.execute("select * from products where id = " + escape.cote(clid));

				//if product already exists in prod we get its uuid to make sure uuid does not change as on insert of first time we set uuid ... uuid of preprod n prod must be different so we dont move uuid from preprod to prod on publish
				Set _prs = etn.execute("select * from "+proddb+".products where id = " + escape.cote(clid));

				Map<String, String> variantsStock = null;
				Map<String, String> variantsStockThresh = null;
				if(_prs.next())
				{
					copyComments = false; //comments will only be copied the very first time from test site to prod site otherwise not

					//new structure has stock in product variants table also ... get the production stock and use that at time of publishing
					Set _pvar = etn.execute("select id, uuid, stock from "+proddb+".product_variants where  product_id = " + escape.cote(clid));
					variantsStock = new HashMap<String, String>();
					variantsStockThresh = new HashMap<String, String>();
					while(_pvar.next())
					{
						variantsStock.put(parseNull(_pvar.value("uuid")),parseNull(_pvar.value("stock")));
						variantsStockThresh.put(parseNull(_pvar.value("uuid")),parseNull(_pvar.value("stock_thresh")));
					}
				}

				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".product_attribute_values where product_id = " + escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".product_descriptions where product_id = " + escape.cote(clid));
                etn.executeCmd("delete from "+proddb+".products_meta_tags where product_id = " + escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".product_essential_blocks where product_id = " + escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".product_images where product_id = " + escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".product_relationship where product_id = " + escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".product_tabs where product_id = " + escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".product_tags where product_id = " + escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".product_variant_details where product_variant_id in (select id from "+proddb+".product_variants where  product_id = " + escape.cote(clid) + " ) ");
				etn.executeCmd("delete from "+proddb+".product_variant_ref where product_variant_id in (select id from "+proddb+".product_variants where  product_id = " + escape.cote(clid) + " ) ");
				etn.executeCmd("delete from "+proddb+".product_variant_resources where product_variant_id in (select id from "+proddb+".product_variants where  product_id = " + escape.cote(clid) + " ) ");

                int folderId = 0;
				String productUuid="";
				String updatedBy="";
				String productVersion="";
				String productV2Id="";
                if(rs.next()){
                    folderId = Integer.parseInt(rs.value("folder_id"));
                    productUuid = parseNull(rs.value("product_uuid"));
                    updatedBy = parseNull(rs.value("updated_by"));
                    productVersion = parseNull(rs.value("product_version"));
                    productV2Id = parseNull(rs.value("product_definition_id"));
                }

                if(folderId>0){
                // deleteing the parent folders
                    etn.executeCmd("delete pf1, pfd1, pf2, pfd2 from "+proddb+".products_folders pf1 "
                        +" left join "+proddb+".products_folders_details pfd1 on pfd1.folder_id = pf1.id "
                        +" left join "+proddb+".products_folders pf2 on pf1.parent_folder_id = pf2.id " // top level
                        +" left join "+proddb+".products_folders_details pfd2 on pfd2.folder_id = pf2.id "
                        +" where pf1.id = "+escape.cote(folderId+""));
                }

				// We are updating the product_variant instead of insertion over and over again due to created on date it persists the first publish date.
				// etn.executeCmd("delete from "+proddb+".product_variants where  product_id = " + escape.cote(clid));

				etn.executeCmd("delete from "+proddb+".share_bar where ptype = 'product' and id = " + escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".products where id = " + escape.cote(clid));

                rs.moveFirst();
				insertRows(etn, rs, "products");
				Set rscat = etn.execute("select * from catalogs where id = " + escape.cote(rs.value("catalog_id")));
				rscat.next();

				String cid = rscat.value("id");
				System.out.println("catalog id = " + cid);

//				String testImagePath = env.getProperty("PRODUCTS_UPLOAD_DIRECTORY") + clid + "/" ;
//				String prodImagePath = env.getProperty("PROD_PRODUCTS_UPLOAD_DIRECTORY") + clid + "/" ;
//				Path testImageDirectory = Paths.get(testImagePath);
//				if(Files.exists(testImageDirectory)){
//					copyDirectory(testImagePath, prodImagePath);
//				}

                int  parent_folder_id = 0;

                if(folderId > 0){

                    rs = etn.execute("select * from products_folders  where id = "+ escape.cote(folderId+""));
                    if(rs.next()){
                        parent_folder_id = Integer.parseInt(rs.value("parent_folder_id"));
                    }

                    rs.moveFirst();
                    insertRows(etn, rs, "products_folders");

                    rs = etn.execute("select pfd.* from products_folders_details pfd left join products_folders pf on pf.id = pfd.folder_id where pf.id = " + escape.cote(folderId+""));
                    insertRows(etn, rs, "products_folders_details");
                }

                if(parent_folder_id > 0){
                     rs = etn.execute("select * from products_folders  where id = "+ escape.cote(parent_folder_id+""));
                    insertRows(etn, rs, "products_folders");

                    rs = etn.execute("select pfd.* from products_folders_details pfd left join products_folders pf on pf.id = pfd.folder_id where pf.id = " + escape.cote(parent_folder_id+""));
                    insertRows(etn, rs, "products_folders_details");
                }


				rs = etn.execute("select * from product_attribute_values where product_id = " + escape.cote(clid));
				insertRows(etn, rs, "product_attribute_values");

				rs = etn.execute("select * from product_descriptions where product_id = " + escape.cote(clid));
				insertRows(etn, rs, "product_descriptions");

                rs = etn.execute("select * from products_meta_tags where product_id = " + escape.cote(clid));
                insertRows(etn, rs, "products_meta_tags");

				rs = etn.execute("select * from product_essential_blocks where product_id = " + escape.cote(clid));
				insertRows(etn, rs, "product_essential_blocks");


//				String testEssentialImagePath = env.getProperty("PRODUCT_ESSENTIALS_UPLOAD_DIRECTORY") + clid + "/" ;
//				String prodEssentialImagePath = env.getProperty("PROD_PRODUCT_ESSENTIALS_UPLOAD_DIRECTORY") + clid + "/" ;
//				Path srcEssentialDirectory = Paths.get(testEssentialImagePath);
//				if(Files.exists(srcEssentialDirectory)){
//					copyDirectory(testEssentialImagePath, prodEssentialImagePath);
//				}

				Set rsimages = etn.execute("select * from product_images where product_id = " + escape.cote(clid));
				insertRows(etn, rsimages, "product_images");

				rs = etn.execute("select * from product_relationship where product_id = " + escape.cote(clid));
				insertRows(etn, rs, "product_relationship");

				rs = etn.execute("select * from product_tabs where product_id = " + escape.cote(clid));
				insertRows(etn, rs, "product_tabs");

				rs = etn.execute("select * from product_tags where product_id = " + escape.cote(clid));
				insertRows(etn, rs, "product_tags");

				//moving associated tags to production
				rs = etn.execute("select * from tags where id in (select tag_id from product_tags where product_id = " + escape.cote(clid)+")");
				insertRows(etn, rs, "tags");
				
				//moving associated tags folders to production
				rs.moveFirst();
				while(rs.next()) {
					insertTagsFolders(etn,parseNull(rs.value("folder_id")));
				}


				rs = etn.execute("select * from product_variant_details where product_variant_id in (select id from product_variants where  product_id = " + escape.cote(clid) + " )");
				insertRows(etn, rs, "product_variant_details");

				rs = etn.execute("select * from product_variant_ref where product_variant_id in (select id from product_variants where  product_id = " + escape.cote(clid) + " )");
				insertRows(etn, rs, "product_variant_ref");

				rs = etn.execute("select * from product_variant_resources where product_variant_id in (select id from product_variants where  product_id = " + escape.cote(clid) + " )");
				insertRows(etn, rs, "product_variant_resources");

				Set pvrs = etn.execute("select id, uuid from product_variants where product_id = " + escape.cote(clid));

				while(pvrs.next()){
					String curVariantId = pvrs.value("id");
					String curVariantUUID = pvrs.value("uuid");
					rs = etn.execute("select * from product_variants where id = " + escape.cote(curVariantId));

					if(null != variantsStock && variantsStock.get(curVariantUUID) != null){
						updateRows(etn, rs, "product_variants", variantsStock, variantsStockThresh);
					}
					else{
						insertRows(etn, rs, "product_variants", variantsStock, variantsStockThresh);
					}
				}

				String pvDeleteQ = "DELETE FROM " + proddb + ".product_variants "
						+ " WHERE product_id = " + escape.cote(clid) ;
				if(pvrs.rs.Rows > 0){
						pvDeleteQ += " AND id NOT IN ("
							+ " SELECT id FROM product_variants WHERE product_id = " + escape.cote(clid)
						+ " )";
				}
				etn.execute(pvDeleteQ);


				rs = etn.execute("select * from share_bar where ptype = 'product' and id = " + clid);
				insertRows(etn, rs, "share_bar");

				//sharebar images are now in product images folder
/*				String testShareBarImagePath = env.getProperty("PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY") + clid + "/" ;
				String prodShareBarImagePath = env.getProperty("PROD_PRODUCT_SHAREBAR_IMAGES_UPLOAD_DIRECTORY") + clid + "/" ;
				Path srcShareBarDirectory = Paths.get(testShareBarImagePath);
				if(Files.exists(srcShareBarDirectory)){
					copyDirectory(testShareBarImagePath, prodShareBarImagePath);
				}*/

				if(copyComments)
				{
					rs = etn.execute("select * from product_comments where product_id = " + clid);
					insertRows(etn, rs, "product_comments");
				}

				//check if product is linked to another we add that entry in product_link
				rs = etn.execute("select * from "+proddb+".products where id = " + clid);
				if(rs.next() && parseNull(rs.value("link_id")).length() > 0)
				{
					Set _rs = etn.execute("select * from "+proddb+".product_link where id = " + parseNull(rs.value("link_id")));
					if(_rs.rs.Rows == 0) etn.executeCmd("insert into "+proddb+".product_link (id) values ("+parseNull(rs.value("link_id"))+") ");
				}
				
/*				String dbname = env.getProperty("PAGES_DB");
				System.out.println("dbname2==================:"+dbname);
				System.out.println("productUuid2==================:"+productUuid);
				System.out.println("updatedBy2==================:"+updatedBy);
                updateFreeMarkerPage(etn,productUuid,updatedBy,dbname);

				Set rsProd = etn.execute("SELECT catalog_uuid FROM catalogs c LEFT JOIN products p ON p.catalog_id=c.id WHERE p.id="+escape.cote(clid));
				if(rsProd!=null && rsProd.rs.Rows>0 && rsProd.next()){
					System.out.println("catalogUuid2==================:"+parseNull(rsProd.value("catalog_uuid")));
					updateFreeMarkerPage(etn,parseNull(rsProd.value("catalog_uuid")),updatedBy,dbname);
				}
				rsProd = etn.execute("SELECT uuid FROM products_folders c LEFT JOIN products p ON p.folder_id=c.id WHERE p.id="+escape.cote(clid));
				if(rsProd!=null && rsProd.rs.Rows>0 && rsProd.next()){
					System.out.println("FoldersUuid3==================:"+parseNull(rsProd.value("uuid")));
					updateFreeMarkerPage(etn,parseNull(rsProd.value("uuid")),updatedBy,dbname);
				}

				rsProd = etn.execute(" select pf1.uuid from products_folders pf1 left join products_folders pf2 on "+
					"pf2.parent_folder_id=pf1.id left join products p on p.folder_id=pf2.id where p.id="+escape.cote(clid));
				if(rsProd!=null && rsProd.rs.Rows>0 && rsProd.next()){
					System.out.println("FoldersUuid4==================:"+parseNull(rsProd.value("uuid")));
					updateFreeMarkerPage(etn,parseNull(rsProd.value("uuid")),updatedBy,dbname);
				}*/

				((Scheduler)env.get("sched")).endJob( wkid , clid );

				if(productVersion.equalsIgnoreCase("v1")){
					etn.executeCmd("update "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and task in ('publish','unpublish') and site_id = "+escape.cote(siteid)+" and content_type = 'product' and content_id = "+escape.cote(clid));
					etn.executeCmd("insert into "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
						" values("+escape.cote(siteid)+", 'product', "+escape.cote(clid)+", 'publish') ");														
				}else{
					if(!productV2Id.isEmpty()){
						System.out.println("Publish:: Marking Product V2's Page for publish=================");

						etn.executeCmd("delete from "+proddb+".products_definition where id="+escape.cote(productV2Id));
						etn.executeCmd("insert into "+proddb+".products_definition select * from products_definition where id="+escape.cote(productV2Id));
						etn.executeCmd("update "+env.getProperty("PAGES_DB")+".structured_contents set to_publish='1', to_publish_by="+escape.cote(updatedBy)+
							",to_publish_ts=now(),publish_status='queued',publish_log='queued' where id = (select page_id from "+env.getProperty("PAGES_DB")+
							".products_map_pages where product_id="+escape.cote(clid)+")");

						Set rsPagesEngine = etn.execute("select val from "+env.getProperty("PAGES_DB")+".config where code='SEMAPHORE'");
						rsPagesEngine.next();
						etn.execute("select semfree("+escape.cote(rsPagesEngine.value("val"))+")");
					}
				}
				
				etn.execute("select semfree("+escape.cote(env.getProperty("PORTAL_ENG_SEMA"))+")");

				Util.checkProductViewsUsage(etn, env, siteid, clid, true);

				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private void insertTagsFolders(ClientSql etn,String id){
		Set rs = etn.execute("select * from tags_folders where id = " + escape.cote(id));
		insertRows(etn, rs, "tags_folders");
		rs.moveFirst();
		if(rs.next() && parseNull(rs.value("parent_folder_id")).length()>0){
			insertTagsFolders(etn, parseNull(rs.value("parent_folder_id")));
		}
	}

	private int publishCatalog(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish catalog id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from catalogs where id = " + escape.cote(clid));
			if(rs.rs.Rows > 0)
			{
				rs.next();
				String siteid = rs.value("site_id");
				rs.moveFirst();
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".catalog_attribute_values where cat_attrib_id in (select cat_attrib_id from "+proddb+".catalog_attributes where catalog_id = "+escape.cote(clid)+" ) ");
				etn.executeCmd("delete from "+proddb+".catalog_attributes where catalog_id = "+escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".catalog_essential_blocks where catalog_id = "+escape.cote(clid));
//				etn.executeCmd("delete from "+proddb+".catalog_tags where catalog_id = "+escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".catalog_descriptions where catalog_id = "+escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".catalogs where id = " + escape.cote(clid));
                // deleteing all folders realted to catalog
                etn.executeCmd("delete pf, pfd from "+proddb+".products_folders pf left join "+proddb+".products_folders_details pfd on pfd.folder_id = pf.id where pf.catalog_id = " + escape.cote(clid));
				insertRows(etn, rs, "catalogs");
				String catalogname = rs.value("name");
				String catid = rs.value("id");
				String catalogUuid = parseNull(rs.value("catalog_uuid"));
				String updatedBy = parseNull(rs.value("updated_by"));
				System.out.println("---------------- catalogname : " + catalogname);

//				rs = etn.execute("select * from catalog_tags where catalog_id = " + escape.cote(clid));
//				insertRows(etn, rs, "catalog_tags");
                rs = etn.execute("select * from products_folders where catalog_id = " + escape.cote(clid));
                insertRows(etn, rs, "products_folders");
                rs = etn.execute("select pfd.* from products_folders_details pfd left join products_folders pf on pf.id = pfd.folder_id where pf.catalog_id = " + escape.cote(clid));
                insertRows(etn, rs, "products_folders_details");

				rs = etn.execute("select * from catalog_attributes where catalog_id = " + escape.cote(clid));
				insertRows(etn, rs, "catalog_attributes");

				rs = etn.execute("select * from catalog_attribute_values where cat_attrib_id in (select cat_attrib_id from catalog_attributes where catalog_id = "+escape.cote(clid)+" ) ");
				insertRows(etn, rs, "catalog_attribute_values");

				rs = etn.execute("select * from catalog_essential_blocks where catalog_id = " + escape.cote(clid));
				insertRows(etn, rs, "catalog_essential_blocks");

				rs = etn.execute("select * from catalog_descriptions where catalog_id = " + escape.cote(clid));
				insertRows(etn, rs, "catalog_descriptions");

				
/*				String dbname = env.getProperty("PAGES_DB");
				System.out.println("dbname1==================:"+dbname);
				System.out.println("catalogUuid1==================:"+catalogUuid);
				System.out.println("updatedBy1==================:"+updatedBy);
                updateFreeMarkerPage(etn,catalogUuid,updatedBy,dbname);*/
				
//				String testEssentialImagePath = env.getProperty("CATALOG_ESSENTIALS_UPLOAD_DIRECTORY") + clid + "/" ;
//				String prodEssentialImagePath = env.getProperty("PROD_CATALOG_ESSENTIALS_UPLOAD_DIRECTORY") + clid + "/" ;
//				Path srcEssDirectory = Paths.get(testEssentialImagePath);
//				if(Files.exists(srcEssDirectory)){
//					copyDirectory(testEssentialImagePath, prodEssentialImagePath);
//				}


//				rs = etn.execute("select * from tags where id in (select tag_id from catalog_tags where catalog_id = " + escape.cote(clid)+")");
//				insertRows(etn, rs, "tags");

			    ((Scheduler)env.get("sched")).endJob( wkid , clid );
				
				etn.executeCmd("update "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks set status = 9 where status = 0 and task in ('publish','unpublish') and site_id = "+escape.cote(siteid)+" and content_type = 'catalog' and content_id = "+escape.cote(clid));					
				etn.executeCmd("insert into "+env.getProperty("PREPROD_PORTAL_DB")+".cache_tasks (site_id, content_type, content_id, task) "+
						" values("+escape.cote(siteid)+", 'catalog', "+escape.cote(clid)+", 'publish') ");

				etn.execute("select semfree("+escape.cote(env.getProperty("PORTAL_ENG_SEMA"))+")");
				
				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishPromotions(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish Promotions id : " + clid);

			String proddb = env.getProperty("PROD_DB");


			Set rs = etn.execute("select * from promotions where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".promotions_rules where promotion_id = " + clid);
				etn.executeCmd("delete from "+proddb+".promotions where id = " + clid);


				insertRows(etn, rs, "promotions");

				Set itemsRs = etn.execute("select * from promotions_rules WHERE promotion_id = " + clid);
				insertRows(etn, itemsRs, "promotions_rules");

			    ((Scheduler)env.get("sched")).endJob( wkid , clid );
				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishCartRules(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish cart rule id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from cart_promotion where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".cart_promotion where id = " + clid);
				etn.executeCmd("delete from "+proddb+".cart_promotion_coupon where cp_id = " + clid);
				etn.executeCmd("delete from "+proddb+".cart_promotion_on_elements where cart_promo_id = " + clid);

				insertRows(etn, rs, "cart_promotion");

				System.out.println("---------------- cart rule promo name : " + rs.value("name"));

				rs = etn.execute("select * from cart_promotion_coupon where cp_id = " + clid);
				insertRows(etn, rs, "cart_promotion_coupon");

				rs = etn.execute("select * from cart_promotion_on_elements where cart_promo_id = " + clid);
				insertRows(etn, rs, "cart_promotion_on_elements");

			    ((Scheduler)env.get("sched")).endJob( wkid , clid );

				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishAdditionalFees(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish addition fee id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from additionalfees where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".additionalfees where id = " + clid);
				etn.executeCmd("delete from "+proddb+".additionalfee_rules where add_fee_id = " + clid);

				insertRows(etn, rs, "additionalfees");

				System.out.println("---------------- additionfee name : " + rs.value("additional_fee"));

				rs = etn.execute("select * from additionalfee_rules where add_fee_id = " + clid);
				insertRows(etn, rs, "additionalfee_rules");

			    ((Scheduler)env.get("sched")).endJob( wkid , clid );

				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishComeWiths(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish come-with id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from comewiths where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".comewiths where id = " + clid);
				etn.executeCmd("delete from "+proddb+".comewiths_rules where comewith_id = " + clid);

				insertRows(etn, rs, "comewiths");

				System.out.println("---------------- come-with name : " + rs.value("comewith"));

				rs = etn.execute("select * from comewiths_rules where comewith_id = " + clid);
				insertRows(etn, rs, "comewiths_rules");

			    ((Scheduler)env.get("sched")).endJob( wkid , clid );

				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishSubsidies(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish subsidy id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from subsidies where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".subsidies where id = " + clid);
				etn.executeCmd("delete from "+proddb+".subsidies_rules where subsidy_id = " + clid);

				insertRows(etn, rs, "subsidies");

				System.out.println("---------------- subsidy name : " + rs.value("name"));

				rs = etn.execute("select * from subsidies_rules where subsidy_id = " + clid);
				insertRows(etn, rs, "subsidies_rules");

			    ((Scheduler)env.get("sched")).endJob( wkid , clid );

				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishDeliveryFees(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish delivery fee id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from deliveryfees where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".deliveryfees where id = " + clid);
				etn.executeCmd("delete from "+proddb+".deliveryfees_rules where deliveryfee_id = " + clid);

				insertRows(etn, rs, "deliveryfees");

				rs = etn.execute("select * from deliveryfees_rules where deliveryfee_id = " + clid);
				insertRows(etn, rs, "deliveryfees_rules");

			    ((Scheduler)env.get("sched")).endJob( wkid , clid );

				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishDeliveryMins(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish delivery min id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from deliverymins where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".deliverymins where id = " + clid);

				insertRows(etn, rs, "deliverymins");

			    ((Scheduler)env.get("sched")).endJob( wkid , clid );

				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

/*	private int publishFamilie(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish Familie id : " + clid);

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from familie where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".familie where id = " + clid);

				insertRows(etn, rs, "familie");
				String catalogid = parseNull(rs.value("catalog_id"));

				if(parseNull(rs.value("img_name")).length() > 0 )
				{
					String testImagePath = env.getProperty("PRODUCTS_UPLOAD_DIRECTORY") + clid + "/" ;
					String prodImagePath = env.getProperty("PROD_PRODUCTS_UPLOAD_DIRECTORY") + clid + "/" ;
					Path testImageDirectory = Paths.get(testImagePath);
					if(Files.exists(testImageDirectory)){
						copyDirectory(testImagePath, prodImagePath);
					}

					Process proc = Runtime.getRuntime().exec(env.getProperty("COPY_SCRIPT") + " " + parseNull(rs.value("img_name")) + " " + env.getProperty("FAMILIE_IMAGES_UPLOAD_DIRECTORY") + " " + env.getProperty("PROD_FAMILIE_IMAGES_UPLOAD_DIRECTORY")  );
					int r = proc.waitFor();
				}

			    	((Scheduler)env.get("sched")).endJob( wkid , clid );
				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}*/

/*	private int publishShop(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish Shop ");

			String proddb = env.getProperty("PROD_DB");

			Set rs = etn.execute("select * from shop_parameters where site_id = " + escape.cote(clid));

			boolean endjob = false;
			if(rs.rs.Rows > 0)
			{
				etn.executeCmd("delete from "+proddb+".shop_parameters where site_id = " + escape.cote(clid));

				insertRows(etn, rs, "shop_parameters");

				System.out.println(" Currency : " + rs.value("lang_1_currency"));

				Set rs1 = etn.execute("select * from langue_msg where LANGUE_REF = " + escape.cote(rs.value("lang_1_currency")));

				if(rs1.next())
				{
					String q = " insert into "+ proddb +".langue_msg (LANGUE_REF, LANGUE_1, LANGUE_2, LANGUE_3, LANGUE_4, LANGUE_5, updated_on) " +
						    " values ("+escape.cote(rs1.value("LANGUE_REF"))+","+escape.cote(rs1.value("LANGUE_1"))+","+escape.cote(rs1.value("LANGUE_2"))+","+escape.cote(rs1.value("LANGUE_3"))+","+escape.cote(rs1.value("LANGUE_4"))+","+escape.cote(rs1.value("LANGUE_5"))+",now()) "+
						    " on duplicate key update LANGUE_1 = "+escape.cote(rs1.value("LANGUE_1"))+",LANGUE_2 = "+escape.cote(rs1.value("LANGUE_2"))+",LANGUE_3 = "+escape.cote(rs1.value("LANGUE_3"))+",LANGUE_4 = "+escape.cote(rs1.value("LANGUE_4"))+",LANGUE_5 = "+escape.cote(rs1.value("LANGUE_5"))+",updated_on = now() ";
					System.out.println(" langue msg qry : " + q);
					etn.executeCmd(q);
				}

				endjob = true;
			}

			Set rspm = etn.execute("select * from payment_methods where site_id = " + escape.cote(clid));
                        etn.executeCmd("delete from "+proddb+".payment_methods where site_id = " + escape.cote(clid));

                        insertRows(etn, rspm, "payment_methods");


			Set rsdm = etn.execute("select * from delivery_methods where site_id = " + escape.cote(clid));
                        etn.executeCmd("delete from "+proddb+".delivery_methods where site_id = " + escape.cote(clid));

                        insertRows(etn, rsdm, "delivery_methods");


			Set rsfr = etn.execute("select * from fraud_rules where site_id = " + escape.cote(clid));
                        etn.executeCmd("delete from "+proddb+".fraud_rules where site_id = " + escape.cote(clid));

                        insertRows(etn, rsfr, "fraud_rules");

                        endjob = true;


 		       if(endjob)
			{
				((Scheduler)env.get("sched")).endJob( wkid , clid );
				return 0;
			}

			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}*/

	private int publishLandingPages(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish Landing Page id : " + clid);

			String proddb = env.getProperty("PROD_DB");


			Set rs = etn.execute("select * from landing_pages where id = " + escape.cote(clid));
			if(rs.rs.Rows > 0)
			{
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".landing_pages_items where landing_page_id = " + escape.cote(clid));
				etn.executeCmd("delete from "+proddb+".landing_pages where id = " + escape.cote(clid));


				insertRows(etn, rs, "landing_pages");

				Set itemsRs = etn.execute("select * from landing_pages_items WHERE landing_page_id = " + escape.cote(clid));
				insertRows(etn, itemsRs, "landing_pages_items");

				itemsRs.moveFirst();
				while(itemsRs.next()){
					for (int i=1; i<=5; i++ ) {
						String imageName = parseNull(itemsRs.value("lang_"+i+"_image"));
						if(imageName.length() > 0 )
						{
							Path source = Paths.get(env.getProperty("LANDINGPAGE_IMAGES_UPLOAD_DIRECTORY") + imageName);
							Path destination = Paths.get(env.getProperty("PROD_LANDINGPAGE_IMAGES_UPLOAD_DIRECTORY") + imageName);

							Files.copy(source, destination, StandardCopyOption.REPLACE_EXISTING);
						}
					}//for
				}

			    ((Scheduler)env.get("sched")).endJob( wkid , clid );
				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishModuleParameters(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish module parameters for site id : " + clid);
			String proddb = env.getProperty("PROD_DB");
/*			etn.executeCmd("delete from "+proddb+".algolia_default_index where site_id = "+escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".algolia_indexes where site_id = "+escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".algolia_rules where site_id = "+escape.cote(clid));
			etn.executeCmd("delete from "+proddb+".algolia_settings where site_id = "+escape.cote(clid));

			Set rs = etn.execute("select * from algolia_default_index where site_id = " + escape.cote(clid));
			insertRows(etn, rs, "algolia_default_index");

			rs = etn.execute("select * from algolia_indexes where site_id = " + escape.cote(clid));
			insertRows(etn, rs, "algolia_indexes");

			rs = etn.execute("select * from algolia_rules where site_id = " + escape.cote(clid));
			insertRows(etn, rs, "algolia_rules");

			rs = etn.execute("select * from algolia_settings where site_id = " + escape.cote(clid));
			insertRows(etn, rs, "algolia_settings");
*/
			((Scheduler)env.get("sched")).endJob( wkid , clid );
			return 0;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}

	private int publishQuantityLimits(ClientSql etn, int wkid, String clid)
	{
		try
		{
			System.out.println("Publish Quantity limit id : " + clid);

			String proddb = env.getProperty("PROD_DB");


			Set rs = etn.execute("select * from quantitylimits where id = " + clid);
			if(rs.rs.Rows > 0)
			{
				//delete everything from prod and insert again
				etn.executeCmd("delete from "+proddb+".quantitylimits_rules where quantitylimit_id = " + clid);
				etn.executeCmd("delete from "+proddb+".quantitylimits where id = " + clid);


				insertRows(etn, rs, "quantitylimits");

				Set itemsRs = etn.execute("select * from quantitylimits_rules WHERE quantitylimit_id = " + clid);
				insertRows(etn, itemsRs, "quantitylimits_rules");

			    ((Scheduler)env.get("sched")).endJob( wkid , clid );
				return 0;
			}
			return -1;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}
}
