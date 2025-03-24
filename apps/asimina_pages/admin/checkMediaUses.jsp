<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.beans.app.GlobalParm, com.etn.sql.escape, com.etn.lang.ResultSet.Set, java.util.ArrayList "%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap,org.json.*,java.util.Enumeration,javax.servlet.ServletException, javax.servlet.http.*, org.apache.poi.ss.formula.functions.Column"%>

<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.io.DataInputStream"%>
<%@ include file="../WEB-INF/include/commonMethod.jsp"%>
<%

    Etn.execute("TRUNCATE TABLE " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".media_records");
    Set rsSites=Etn.execute("SELECT id from "+com.etn.beans.app.GlobalParm.getParm("PORTAL_DB")+".sites");
    while(rsSites.next()) {

        String site_id=rsSites.value("id");

        Etn.executeCmd("INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                "SELECT f.id,f.file_name,b.name,'Bloc' FROM " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".blocs b " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".files f ON f.site_id=b.site_id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".blocs_details bd ON bd.bloc_id=b.id " +
                "WHERE b.site_id=" + escape.cote(site_id) + " AND (bd.template_data LIKE CONCAT('%',f.file_name,'%'))");

        Etn.executeCmd("INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                "SELECT f.id,f.file_name,l.name,'Library' FROM " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".libraries l " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".libraries_files lf ON lf.library_id=l.id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".files f ON f.id=lf.file_id WHERE l.site_id=" + escape.cote(site_id));

        Etn.executeCmd("INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                "SELECT f.id,f.file_name,c.name,'Catalog' FROM " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".catalogs c " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".files f ON f.site_id=c.site_id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".catalog_essential_blocks ceb ON ceb.catalog_id=c.id " +
                "WHERE c.site_id=" + escape.cote(site_id) + " AND (ceb.actual_file_name = f.file_name)");

        Etn.executeCmd("INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                "SELECT f.id,f.file_name,p.lang_1_name,'Product' FROM " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".catalogs c " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".files f ON f.site_id=c.site_id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".products p ON p.catalog_id=c.id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".product_essential_blocks peb ON peb.product_id=p.id " +
                "WHERE c.site_id=" + escape.cote(site_id) + " AND peb.actual_file_name=f.file_name");

        Etn.executeCmd("INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                "SELECT f.id,f.file_name,pv.sku,'Product Variant' FROM " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".catalogs c " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".files f ON f.site_id=c.site_id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".products p ON p.catalog_id=c.id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".product_variants pv ON pv.product_id=p.id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("CATALOG_DB") + ".product_variant_resources pvr ON pvr.product_variant_id=pv.id " +
                "WHERE c.site_id=" + escape.cote(site_id) + " AND pvr.actual_file_name=f.file_name");

        Etn.executeCmd("INSERT INTO " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".media_records (file_id,file_name,used_at,type) " +
                "SELECT f.id,f.file_name,pfu.table_name,'Table' FROM " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_forms_unpublished pfu " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".files f ON f.site_id=pfu.site_id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_descriptions pfd ON pfd.form_id=pfu.form_id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_fields_unpublished pffu ON pffu.form_id = pfu.form_id " +
                "LEFT JOIN " + com.etn.beans.app.GlobalParm.getParm("FORMS_DB") + ".process_form_field_descriptions_unpublished pffdu ON pffdu.form_id=pffu.form_id " +
                "WHERE pfu.site_id=" + escape.cote(site_id) + " AND pffu.type='label' AND ( pfd.success_msg LIKE CONCAT('%',f.file_name,'%') OR pffdu.value=f.file_name)");

    }
        Etn.executeCmd("UPDATE " + com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".files f SET f.times_used=(SELECT COUNT(*) FROM " +
                com.etn.beans.app.GlobalParm.getParm("PAGES_DB") + ".media_records mr WHERE f.id=mr.file_id) ");



%>