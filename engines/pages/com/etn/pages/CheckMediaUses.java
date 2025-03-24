package com.etn.pages;

import com.etn.sql.escape;
import com.etn.lang.ResultSet.Set;
import java.util.Properties;
import com.etn.Client.Impl.ClientSql;
import com.etn.Client.Impl.ClientDedie;
import java.io.FileReader;
import java.io.File;



public class CheckMediaUses{
        
        private Properties env;
        private ClientSql Etn;

        public CheckMediaUses(String parm[]) throws Exception {
                env = new Properties();

                boolean envLoaded = false;
                if (parm.length > 0) {
                        File confFile = new File(parm[0]);
                        if (confFile.exists() && confFile.isFile()) {
                                env.load(new FileReader(confFile));
                                envLoaded = true;
                        }
                }

                if (!envLoaded) {
                        throw new Exception("Error: No .conf file provided!!");
                }

        
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

        public void updateDb(){
                System.out.println("Runing CheckMediaUses file");

                Etn.execute("TRUNCATE TABLE " + env.getProperty("PAGES_DB") + ".media_records");
                Set rsSites=Etn.execute("SELECT id from "+env.getProperty("PORTAL_DB")+".sites");
                while(rsSites.next()) {

                        String site_id=rsSites.value("id");

                        Etn.executeCmd("INSERT INTO " + env.getProperty("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                                "SELECT f.id,f.file_name,b.name,'Bloc' FROM " + env.getProperty("PAGES_DB") + ".blocs b " +
                                "LEFT JOIN " + env.getProperty("PAGES_DB") + ".files f ON f.site_id=b.site_id " +
                                "LEFT JOIN " + env.getProperty("PAGES_DB") + ".blocs_details bd ON bd.bloc_id=b.id " +
                                "WHERE b.site_id=" + escape.cote(site_id) + " AND (bd.template_data LIKE CONCAT('%',f.file_name,'%'))");

                        Etn.executeCmd("INSERT INTO " + env.getProperty("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                                "SELECT f.id,f.file_name,l.name,'Library' FROM " + env.getProperty("PAGES_DB") + ".libraries l " +
                                "LEFT JOIN " + env.getProperty("PAGES_DB") + ".libraries_files lf ON lf.library_id=l.id " +
                                "LEFT JOIN " + env.getProperty("PAGES_DB") + ".files f ON f.id=lf.file_id WHERE l.site_id=" + escape.cote(site_id));

                        Etn.executeCmd("INSERT INTO " + env.getProperty("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                                "SELECT f.id,f.file_name,c.name,'Catalog' FROM " + env.getProperty("CATALOG_DB") + ".catalogs c " +
                                "LEFT JOIN " + env.getProperty("PAGES_DB") + ".files f ON f.site_id=c.site_id " +
                                "LEFT JOIN " + env.getProperty("CATALOG_DB") + ".catalog_essential_blocks ceb ON ceb.catalog_id=c.id " +
                                "WHERE c.site_id=" + escape.cote(site_id) + " AND (ceb.actual_file_name = f.file_name)");

                        Etn.executeCmd("INSERT INTO " + env.getProperty("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                                "SELECT f.id,f.file_name,p.lang_1_name,'Product' FROM " + env.getProperty("CATALOG_DB") + ".catalogs c " +
                                "LEFT JOIN " + env.getProperty("PAGES_DB") + ".files f ON f.site_id=c.site_id " +
                                "LEFT JOIN " + env.getProperty("CATALOG_DB") + ".products p ON p.catalog_id=c.id " +
                                "LEFT JOIN " + env.getProperty("CATALOG_DB") + ".product_essential_blocks peb ON peb.product_id=p.id " +
                                "WHERE c.site_id=" + escape.cote(site_id) + " AND peb.actual_file_name=f.file_name");

                        Etn.executeCmd("INSERT INTO " + env.getProperty("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                                "SELECT f.id,f.file_name,pv.sku,'Product Variant' FROM " + env.getProperty("CATALOG_DB") + ".catalogs c " +
                                "LEFT JOIN " + env.getProperty("PAGES_DB") + ".files f ON f.site_id=c.site_id " +
                                "LEFT JOIN " + env.getProperty("CATALOG_DB") + ".products p ON p.catalog_id=c.id " +
                                "LEFT JOIN " + env.getProperty("CATALOG_DB") + ".product_variants pv ON pv.product_id=p.id " +
                                "LEFT JOIN " + env.getProperty("CATALOG_DB") + ".product_variant_resources pvr ON pvr.product_variant_id=pv.id " +
                                "WHERE c.site_id=" + escape.cote(site_id) + " AND pvr.actual_file_name=f.file_name");

                        Etn.executeCmd("INSERT INTO " + env.getProperty("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                                "SELECT f.id,f.file_name,pfu.table_name,'Table' FROM " + env.getProperty("FORMS_DB") + ".process_forms_unpublished pfu " +
                                "LEFT JOIN " + env.getProperty("PAGES_DB") + ".files f ON f.site_id=pfu.site_id " +
                                "LEFT JOIN " + env.getProperty("FORMS_DB") + ".process_form_descriptions pfd ON pfd.form_id=pfu.form_id " +
                                "LEFT JOIN " + env.getProperty("FORMS_DB") + ".process_form_fields_unpublished pffu ON pffu.form_id = pfu.form_id " +
                                "LEFT JOIN " + env.getProperty("FORMS_DB") + ".process_form_field_descriptions_unpublished pffdu ON pffdu.form_id=pffu.form_id " +
                                "WHERE pfu.site_id=" + escape.cote(site_id) + " AND pffu.type='label' AND ( pfd.success_msg LIKE CONCAT('%',f.file_name,'%') OR pffdu.value=f.file_name)");


                }

                Etn.executeCmd("UPDATE " + env.getProperty("PAGES_DB") + ".files f SET f.times_used=(SELECT COUNT(*) FROM " +
                        env.getProperty("PAGES_DB") + ".media_records mr WHERE f.id=mr.file_id) ");
                System.out.println("CheckMediaUses file execution completed.");
        }
        public static void main(String a[]) throws Exception{
                CheckMediaUses obj = new CheckMediaUses(a);
                obj.updateDb();
        }
        
    
    
}