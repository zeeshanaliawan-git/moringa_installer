package com.etn.moringa;

import java.util.*;

import com.etn.Client.Impl.ClientSql;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;
import org.jsoup.*;
import org.json.JSONObject;
import org.json.JSONArray;

import java.net.URL;
import java.net.HttpURLConnection;
import java.io.OutputStreamWriter;
import java.io.OutputStream;
import java.io.InputStream;
import java.io.File;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class AlgoliaPublication {
    private Properties env;
	private ClientSql Etn;
    private CacheUtil cacheutil = null;

    private String parseNull(Object o) {
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

    public AlgoliaPublication(ClientSql Etn, Properties env) throws Exception {
        this.Etn = Etn;
		this.env = env;
        cacheutil = new CacheUtil(env, true, true);
    }

    public String appendString(String err_msg, String langue){
        if(err_msg.length()>0) err_msg = "and "+langue;
        err_msg=langue;
        return err_msg;
    }

    public void algoliaIndexationAction(String menuId,String cid,String ctype,String action,String algoliaIndex) throws Exception{
		//some tasks take more time so we must keep updating engine status
		Etn.executeCmd("insert into "+env.getProperty("COMMONS_DB")+".engines_status (engine_name,start_date,end_date) VALUES('Portal',NOW(),null) ON DUPLICATE KEY update start_date=NOW(),end_date=null");
        String currentMenuPath =cacheutil.getMenuPath(Etn, menuId);
        String prodPortaldb = env.getProperty("PROD_PORTAL_DB")+".";
        String sitedomain="";        

        String qry = " select m.*, s.name as sitename, s.domain as sitedomain from "+prodPortaldb+"site_menus m, "+prodPortaldb+"sites s where s.id = m.site_id and m.is_active = 1 and m.id = " + escape.cote(menuId);
        
        Set mainrs = Etn.execute(qry);
        if(mainrs!=null && mainrs.rs.Rows>0){
            sitedomain = parseNull(mainrs.value("sitedomain"));
            if(!sitedomain.endsWith("/")) sitedomain = sitedomain + "/";
        }
        Algolia temp= new Algolia(menuId,Etn,env,true,true,currentMenuPath,sitedomain);

        if(action.equalsIgnoreCase("start")) temp.startIndexation(cid);
        else if(action.equalsIgnoreCase("delete")) {
			Etn.executeCmd("update "+prodPortaldb+"algolia_indexation set is_active = 0 where cid="+escape.cote(cid)+" and ctype="+escape.cote(ctype)+
            " and algolia_index="+escape.cote(algoliaIndex)+" and menu_id="+escape.cote(menuId));
			
			boolean bool=false;
			if(ctype.equals("new_product")){

				Set rsDeleteNewProductIdx = Etn.execute("select variant_id from "+prodPortaldb+"algolia_indexation where cid="+escape.cote(cid)+
					" and ctype="+escape.cote(ctype)+" and algolia_index="+escape.cote(algoliaIndex)+" and menu_id="+escape.cote(menuId));
				if(rsDeleteNewProductIdx.next()) bool = temp.deleteIndex(rsDeleteNewProductIdx.value("variant_id"), algoliaIndex);
			} 
			else bool = temp.deleteIndex(cid, algoliaIndex);

            if(bool){
				Etn.executeCmd("insert into "+prodPortaldb+"algolia_indexation_history (menu_id, ctype, cid, algolia_index, algolia_json, is_active, variant_id) " +
					" select menu_id, ctype, cid, algolia_index, algolia_json, is_active, variant_id from "+prodPortaldb+"algolia_indexation "+
					" where cid="+escape.cote(cid)+" and ctype="+escape.cote(ctype)+" and algolia_index="+escape.cote(algoliaIndex)+" and menu_id="+escape.cote(menuId));
				
                Etn.executeCmd("delete from "+prodPortaldb+"algolia_indexation where cid="+escape.cote(cid)+" and ctype="+escape.cote(ctype)+" and algolia_index="+escape.cote(algoliaIndex)+" and menu_id="+escape.cote(menuId));
			}
		} else temp.startIndexation(cid,ctype);
    }

	private int insertRows(Set rs, String tablename, String dbname) {		
		int rows = 0;
		while(rs.next()) {
			String iq = " insert into "+dbname+"."+tablename+" ";
			String iqcols = "";
			String iqvals = "";
			for(int i=0;i< rs.Cols; i++) {
				if(i > 0) {
					iqcols += ", ";
					iqvals += ", ";	
				}
				iqcols += "`" + rs.ColName[i].toLowerCase()+ "`";
				iqvals += escape.cote(rs.value(i));	
			} 
			iq += " ( " + iqcols + " ) values ("+iqvals+") ";
			int _r = Etn.executeCmd(iq);

			if(_r > 0) rows++;
		}
		return rows;
	}
	
	private int publishAlgoliaSettings(String siteid) {
		try {
			log("Publish Aloglia settings ");

			String catalogdb = env.getProperty("CATALOG_DB");
			String prodcatalogdb = env.getProperty("PROD_CATALOG_DB");

			Etn.executeCmd("delete from "+prodcatalogdb+".algolia_default_index where site_id = "+escape.cote(siteid));
			Etn.executeCmd("delete from "+prodcatalogdb+".algolia_indexes where site_id = "+escape.cote(siteid));
			Etn.executeCmd("delete from "+prodcatalogdb+".algolia_rules where site_id = "+escape.cote(siteid));
			Etn.executeCmd("delete from "+prodcatalogdb+".algolia_settings where site_id = "+escape.cote(siteid));

			int rows = 0;
			Set rs = Etn.execute("select * from "+catalogdb+".algolia_default_index where site_id = " + escape.cote(siteid));
			rows += insertRows(rs, "algolia_default_index", prodcatalogdb);

			rs = Etn.execute("select * from "+catalogdb+".algolia_indexes where site_id = " + escape.cote(siteid));
			rows += insertRows(rs, "algolia_indexes", prodcatalogdb);

			rs = Etn.execute("select * from "+catalogdb+".algolia_rules where site_id = " + escape.cote(siteid));
			rows += insertRows(rs, "algolia_rules", prodcatalogdb);

			rs = Etn.execute("select * from "+catalogdb+".algolia_settings where site_id = " + escape.cote(siteid));
			rows += insertRows(rs, "algolia_settings", prodcatalogdb);

			return rows;
		}
		catch( Exception e ) { e.printStackTrace(); return(-1); }
	}	

	private void log(String m) { System.out.println("AlgoliaPublication::"+m); }

    public void publishAlgoliaIndex() {
		try {
			String pagesdb = env.getProperty("PAGES_DB")+".";
			String catalogdb = env.getProperty("PROD_CATALOG_DB")+".";
			String prodPortaldb = env.getProperty("PROD_PORTAL_DB")+".";

			Set rs = Etn.execute("Select distinct p.site_id from "+prodPortaldb+"publish_content p join "+pagesdb+"structured_contents sc on sc.id=p.cid join "+pagesdb
				+"bloc_templates bt on bt.id=sc.template_id join "+catalogdb+"algolia_settings a on a.site_id=p.site_id where bt.type not in "+
				"('simple_product','simple_virtual_product','configurable_product','configurable_virtual_product') and p.status='0' and p.attempt<=5");
			while(rs.next()) {
				log("Republish algolia settings for site_id : "+rs.value("site_id"));
				publishAlgoliaSettings(rs.value("site_id"));
			}

			rs = Etn.execute("Select sc.uuid,p.*,a.activated from "+prodPortaldb+"publish_content p join "+pagesdb+"structured_contents sc on sc.id=p.cid join "+pagesdb
				+"bloc_templates bt on bt.id=sc.template_id join "+catalogdb+"algolia_settings a on a.site_id=p.site_id where bt.type not in "+
				"('simple_product','simple_virtual_product','configurable_product','configurable_virtual_product') and p.status='0' and p.attempt<=5 and p.ctype not in ('forum','product') order by p.id asc");
			if(rs!=null && rs.rs.Rows>0) {
				log("==============Running============");

				Etn.executeCmd("update "+prodPortaldb+"publish_content set status='1', attempt=attempt+1 where status='0' and attempt<=5");

				while(rs.next()){
					if((parseNull(rs.value("ctype")).equalsIgnoreCase("store") || parseNull(rs.value("ctype")).equalsIgnoreCase("structuredcontent") 
						|| parseNull(rs.value("ctype")).equalsIgnoreCase("structuredpage")) && parseNull(rs.value("activated")).equalsIgnoreCase("1")){
						
						String err_msg="";
						String err_msg1="";
						int counter=0;

						String query="select sm.id,l.langue_code as lang from "+pagesdb+
							"structured_contents_details scd JOIN "+prodPortaldb+"language l on l.langue_id=scd.langue_id"+
							" JOIN "+prodPortaldb+"site_menus sm ON sm.lang=l.langue_code AND sm.site_id="+escape.cote(rs.value("site_id"))+
							" where scd.content_id="+escape.cote(rs.value("cid"));
						
						Set rs2=Etn.execute(query);
						
						if(rs2 !=null && rs2.rs.Rows>0){
							while(rs2.next()){
								if(parseNull(rs2.value("id")).length() > 0){

									if(parseNull(rs.value("publication_type")).equalsIgnoreCase("publish")) {
										algoliaIndexationAction(parseNull(rs2.value("id")),parseNull(rs.value("uuid")),parseNull(rs.value("ctype")),"start","");
									} else if(parseNull(rs.value("publication_type")).equalsIgnoreCase("unpublish")){

										Set rs3 = Etn.execute("select is_active,algolia_index from "+prodPortaldb+"algolia_indexation where menu_id="+
										escape.cote(rs2.value("id"))+" and cid="+escape.cote(rs.value("uuid"))+" and ctype="+escape.cote(rs.value("ctype")));
										
										if(rs3!=null && rs3.rs.Rows>0 && rs3.next()) {
											algoliaIndexationAction(parseNull(rs2.value("id")),parseNull(rs.value("uuid")),parseNull(rs.value("ctype")),"delete",parseNull(rs3.value("algolia_index")));
										} else{
											counter++;
											err_msg1=appendString(err_msg1,parseNull(rs2.value("lang")));
										}
									}
								} else{
									counter++;
									err_msg=appendString(err_msg,parseNull(rs2.value("lang")));
								}
							}

							String message="";
							if(err_msg.length()>0) message+="Menus for "+err_msg+" does not exist. ";
							if(err_msg1.length()>0) message+="Algolia Indexation for "+err_msg1+" does not exist. ";

							String q="update "+prodPortaldb+"publish_content set err_msg="+escape.cote(message);
							if(counter>= rs2.rs.Rows) q+=",status='1'";
							
							q+=" where cid="+escape.cote(rs.value("cid"));
							log("query============:"+q);
							if(counter>0) Etn.executeCmd(q);
						} else{
							Etn.executeCmd("update "+prodPortaldb+"publish_content set err_msg='Either site or "+rs.value("ctype")+" not published.' where cid="+
							escape.cote(rs.value("cid")));
						}
					} else{
						Etn.executeCmd("update "+prodPortaldb+"publish_content set err_msg='Invalid ctype "+parseNull(rs.value("ctype"))+
						" or algolia indexatoin not active for this site.' where cid="+escape.cote(rs.value("cid")));
					}
				}
			}
		} catch(Exception e) { e.printStackTrace();}
    }

    public void publishAlgoliaIndexForForumAndProduct() {
		try  {
			String catalogdb = env.getProperty("CATALOG_DB")+".";
			String prodPortaldb = env.getProperty("PROD_PORTAL_DB")+".";
			String pagesdb = env.getProperty("PAGES_DB")+".";

			Set rs = Etn.execute("Select p.*,a.activated from "+prodPortaldb+"publish_content p join "+catalogdb+
				"algolia_settings a on a.site_id=p.site_id where p.status='0' and p.attempt<=5 and (p.action_dt<=now() or COALESCE(p.action_dt,'')='') and p.ctype in ('forum','marketing_rules','new_product') order by p.id asc");
			if(rs!=null && rs.rs.Rows>0) {
				log("==============Running for Forums / Marketing rules / New Products============");

				Etn.executeCmd("update "+prodPortaldb+"publish_content set status='1', attempt=attempt+1 where status='0' and (action_dt<=now() or COALESCE(action_dt,'')='') and attempt<=5 and ctype in ('forum','marketing_rules','new_product')");
				while(rs.next()){
					String err_msg="";
					int counter=0;

					String query="select sm.id,l.langue_code as lang from "+prodPortaldb+"language l JOIN "+prodPortaldb+"site_menus sm ON sm.lang=l.langue_code where sm.site_id="+escape.cote(rs.value("site_id"));
					Set rs2=Etn.execute(query);
					if(rs2 !=null && rs2.rs.Rows>0) {
						while(rs2.next()) {
							if(parseNull(rs2.value("id")).length() > 0) {
								String cid = rs.value("cid");
								String menuId = rs2.value("id");
								if(parseNull(rs.value("ctype")).equalsIgnoreCase("marketing_rules")) {
									Set rs3 = Etn.execute("select is_active,algolia_index from "+prodPortaldb+"algolia_indexation where menu_id="+escape.cote(menuId)+" and cid="+escape.cote(cid)+" and ctype='product'");
									if(rs3.next()){
										algoliaIndexationAction(parseNull(menuId),parseNull(cid),parseNull(rs.value("ctype")),"delete",parseNull(rs3.value("algolia_index")));
									}
								} else if(parseNull(rs.value("ctype")).equalsIgnoreCase("new_product")) {
									Set rsStrucUuid = Etn.execute("Select uuid from "+pagesdb+"structured_contents where id="+escape.cote(cid));
									rsStrucUuid.next();
									cid=rsStrucUuid.value("uuid");
									Set rs3 = Etn.execute("select is_active,algolia_index from "+prodPortaldb+"algolia_indexation where menu_id="+escape.cote(menuId)+" and cid="+escape.cote(cid)+" and ctype='new_product'");
									if(rs3.next()){
										algoliaIndexationAction(parseNull(menuId),parseNull(cid),parseNull(rs.value("ctype")),"delete",parseNull(rs3.value("algolia_index")));
									}
								} 
								algoliaIndexationAction(parseNull(menuId),parseNull(cid),parseNull(rs.value("ctype")),parseNull(rs.value("ctype")),"");
							} else {
								counter++;
								err_msg=appendString(err_msg,parseNull(rs2.value("lang")));
							}
						}

						String message="";
						if(err_msg.length()>0) message+="Menus for "+err_msg+" does not exist. ";

						String q="update "+prodPortaldb+"publish_content set err_msg="+escape.cote(message);
						if(counter>0) q+=",status='1'";
						
						q+=" where cid="+escape.cote(rs.value("cid"));
						log("query============:"+q);
						if(counter>0) Etn.executeCmd(q);

					} else Etn.executeCmd("update "+prodPortaldb+"publish_content set err_msg='Site not published.' where cid="+escape.cote(rs.value("cid")));
				}
			}
		} catch(Exception e) { e.printStackTrace(); }
    }
}
