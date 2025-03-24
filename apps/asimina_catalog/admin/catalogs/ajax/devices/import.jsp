<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set, com.etn.asimina.util.*, com.etn.sql.escape, com.etn.beans.app.GlobalParm, java.io.*, java.util.*,java.lang.reflect.Type, com.google.gson.*, com.google.gson.reflect.TypeToken, org.json.JSONObject,com.etn.asimina.util.FileUtil"%>
<%@ include file="/WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../../../common.jsp"%>
<%@ include file="/WEB-INF/include/imager.jsp"%>
<%@ include file="/WEB-INF/include/constants.jsp"%>


<%@ include file="apicall.jsp"%>

<%!
    void downloadImage(com.etn.beans.Contexte Etn, int deviceid, String url, String brand, String model, int variantId, int imageCount, String lang, String langid, String siteId)
    {
        java.net.HttpURLConnection c = null;
        FileOutputStream fout = null;

        String proxyhost = com.etn.beans.app.GlobalParm.getParm("HTTP_PROXY_HOST");
        String proxyport = com.etn.beans.app.GlobalParm.getParm("HTTP_PROXY_PORT");
        final String proxyuser = com.etn.beans.app.GlobalParm.getParm("HTTP_PROXY_USER");
        final String proxypasswd = com.etn.beans.app.GlobalParm.getParm("HTTP_PROXY_PASSWD");

        try
        {

            // String downloadPath = GlobalParm.getParm("PRODUCTS_UPLOAD_DIRECTORY") + deviceid + "/" ;
            String downloadPath = GlobalParm.getParm("PAGES_UPLOAD_DIRECTORY") + siteId + "/img/" ;
            File dir = FileUtil.getFile(downloadPath);//change
            FileUtil.mkDirs(dir);//change

            java.net.URL u = new java.net.URL(url);
            if(proxyhost != null && proxyhost.trim().length() > 0 )
            {
                java.net.Proxy proxy = new java.net.Proxy(java.net.Proxy.Type.HTTP, new java.net.InetSocketAddress (proxyhost, Integer.parseInt(proxyport)));

                if(proxyuser != null && proxyuser.trim().length() > 0)
                {
                    //System.out.println(url + " : " +proxyhost + " : " + proxyport + " : " + proxyuser + " : " + proxypasswd);
                    java.net.Authenticator authenticator = new java.net.Authenticator() {
                        public java.net.PasswordAuthentication getPasswordAuthentication() {
                            return (new java.net.PasswordAuthentication(proxyuser, proxypasswd.toCharArray()));
                        }
                    };
                    java.net.Authenticator.setDefault(authenticator);
                }

                c = (java.net.HttpURLConnection) u.openConnection(proxy);
            }
            else c = (java.net.HttpURLConnection) u.openConnection();

            c.setRequestMethod("GET");
            c.setDoOutput(false);
            c.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
//			c.setRequestProperty("Authorization", auth);
//			c.setRequestProperty("CountryID", countryid);
            //c.setRequestProperty("User-Agent", "Mozilla/5.0");
            c.connect();

            int status = c.getResponseCode();
            switch (status)
            {
                case 200:
                case 201:
                    String extension = ".png";
                    if("image/jpeg".equals(c.getContentType())) extension = ".jpg";

                    String filename = removeSpecialCharactersFromImageName(removeAccents(brand)) + "_" + removeSpecialCharactersFromImageName(removeAccents(model)) + "_" + lang + "_" + variantId + "_" + imageCount;
                    filename = filename + extension;

                    String actualImageName = url;
                    if(actualImageName.indexOf("/") > -1) actualImageName = actualImageName.substring(actualImageName.lastIndexOf("/")+1);

                    fout = FileUtil.getFileOutputStream(downloadPath + filename);//change
                    // fout = new FileOutputStream (downloadPath + filename);
                    int bytesRead = -1;
                            byte[] buffer = new byte[1024];
                    InputStream in = c.getInputStream();
                    while ((bytesRead = in.read(buffer)) != -1) {
                        fout.write(buffer, 0, bytesRead);
                    }
                    fout.flush();
                    String imageLabel = model;
                    if(brand.length()>0) imageLabel =  brand+" "+model;
                    Etn.executeCmd("insert into product_variant_resources (product_variant_id, type, langue_id, path, actual_file_name,label ,sort_order) values ("+escape.cote(""+variantId)+",'image',"+escape.cote(langid)+","+escape.cote(filename)+","+escape.cote(actualImageName)+","+escape.cote(imageLabel)+","+escape.cote(""+(imageCount+1))+") ");

                    // String gridimgname = getGridImageName(filename);
                    // String rawfilename = getRawImageName(filename);
                    // String ogimagename = getOgImageName(filename);
                    // com.etn.util.Logger.debug("import.jsp", "Going to create raw image");
                    // //this will create a raw image copy before any image manipulation
                    // createForProductsRawImage(downloadPath, filename, downloadPath, rawfilename);

                    // com.etn.util.Logger.debug("import.jsp", "Going to create og image");
                    // createForFacebook(downloadPath, rawfilename, downloadPath, ogimagename);

                    // //we are creating 4x3 or 3x4 aspect ratio image
                    // com.etn.util.Logger.debug("import.jsp", "Going to create listing image");
                    // createForProducts(downloadPath, rawfilename, downloadPath, filename);

                    // //we are creating 2x1 or 1x2 aspect ratio image
                    // com.etn.util.Logger.debug("import.jsp", "Going to create grid image");
                    // createForProductsGridView(downloadPath, rawfilename, downloadPath, gridimgname);
            }
        }
        catch(Exception e)
        {
            e.printStackTrace();
        }
        finally
        {
            if(fout != null) try { fout.close(); } catch (Exception e) {}
            if(c != null) try { c.disconnect(); } catch (Exception e) {}
        }

    }
%>

<%
    String nacode = parseNull(request.getParameter("nacode"));
    String catalogid = parseNull(request.getParameter("catalogid"));
    String folderId = parseNull(request.getParameter("folderId"));

    String selectedf = getSelectedSiteId(session);

    String json = fetchDevice(nacode);

    Map<String, Object> resp = new Gson().fromJson(json, Map.class);
    if((resp.get("status")).equals("error"))
    {
        out.write(json);
        return;
    }

    Map<String, Object> device = (Map<String, Object>)resp.get("device");


    String productName = parseNull((String)device.get("model"));
    String brandName = parseNull((String)device.get("brand"));
    String skuName = productName.replaceAll("[^\\w\\s]+", "").replaceAll(" ","_");
    String variantName = productName;

    if(brandName.length() > 0)
    {
        brandName = brandName.substring(0,1).toUpperCase() + brandName.substring(1);
        skuName =  brandName.replaceAll("[^\\w\\s]+", "").replaceAll(" ","_") +"_"+ skuName;
        variantName  = brandName +" "+variantName;
    }


    String q = "insert into products (device_type, is_new, product_uuid, order_seq, import_source, catalog_id, folder_id, migrated_id, product_type, brand_name, lang_1_name, lang_2_name, lang_3_name, lang_4_name, lang_5_name, created_by, updated_by, updated_on)  " +
        " values ("+escape.cote((String)device.get("device_type"))+", 1, UUID(), '999', "+escape.cote("phonedir_" + (String)device.get("source"))+","+escape.cote(catalogid)+", "+escape.cote(folderId)+", "+escape.cote(nacode)+", 'product', "+escape.cote(brandName)+", "+escape.cote((String)device.get("model"))+", "+escape.cote((String)device.get("model"))+", "+escape.cote((String)device.get("model"))+", "+escape.cote((String)device.get("model"))+", "+escape.cote((String)device.get("model"))+", "+escape.cote(""+Etn.getId())+", "+escape.cote(""+Etn.getId())+", NOW()"+")  ";
    int deviceid = Etn.executeCmd(q);

    if(deviceid > 0)
    {
        String defaultPagePath = UrlHelper.getProductSuggestedPath(Etn, "" + deviceid);

        List<Map<String, Object>> attributes = (List<Map<String, Object>>)device.get("attributes");
        if(attributes.size() > 0)
        {
            int sortOrder = 0;
            Set rs = Etn.execute("select max(sort_order) + 1 as sort_order from catalog_attributes where catalog_id = "+escape.cote(catalogid));
            if(rs.next()) sortOrder = parseInt(rs.value("sort_order"));

            int productAttrSortOrder = 0;
            Set rsp = Etn.execute("select max(sort_order) + 1 as sort_order from product_attribute_values where product_id = "+escape.cote(""+deviceid));
            if(rsp.next()) productAttrSortOrder = parseInt(rsp.value("sort_order"));

            boolean updateCatalog = false;
            for(int i=0;i<attributes.size();i++)
            {
                String attribName = (String)attributes.get(i).get("name");
                List<String> attribValues = (List<String>)(attributes.get(i).get("value"));
                String attributeValue = "";
                for(int j=0; j<attribValues.size(); j++)
                {
                    if(j > 0) attributeValue += ",";
                    attributeValue += parseNull(attribValues.get(j));
                }

                if(attributeValue.length() == 0) continue;

                int attribid = 0;
                rs = Etn.execute("select * from catalog_attributes where catalog_id = "+escape.cote(catalogid)+" and name = "+escape.cote(attribName)+" and type = 'specs' ");
                if(rs.next()) attribid = parseInt(rs.value("cat_attrib_id"));
                else
                {
                    attribid = Etn.executeCmd("insert into catalog_attributes (catalog_id, name, sort_order, type, detail_only, migration_name) values ("+escape.cote(catalogid)+","+escape.cote(attribName)+","+escape.cote(""+sortOrder)+","+escape.cote("specs")+",1,"+escape.cote(attribName)+") ");
                    updateCatalog = true;
                }

                if(attribid > 0)
                {
                    int pattrid = Etn.executeCmd("insert into product_attribute_values (product_id, cat_attrib_id, attribute_value, sort_order) values ("+escape.cote(""+deviceid)+","+escape.cote(""+attribid)+","+escape.cote(attributeValue)+","+escape.cote(""+productAttrSortOrder)+") ");
                    if(pattrid == 0 ) Logger.debug("ERROR::devicesdirectory/import.jsp::unable to insert product attribute : " + attribName);
                    else productAttrSortOrder++;

                    sortOrder++;
                }
                else Logger.debug("ERROR::devicesdirectory/import.jsp::unable to insert catalog attribute : " + attribName);
            }
            if(updateCatalog)
            {
                Etn.executeCmd("update catalogs set version = version + 1, updated_on = now(), updated_by = "+escape.cote(""+Etn.getId())+" where id = " + escape.cote(catalogid));
            }
        }
        //make a default variant with empty attributes ... add first 3 images to default variant images
        int variantId = Etn.executeCmd("insert into product_variants (product_id, sku, uuid, is_default) values ("+escape.cote(""+deviceid)+", "+escape.cote(skuName)+", uuid(), 1)");
        if(variantId > 0)
        {
            Set rslang = Etn.execute("select * from language order by langue_id ");
            while(rslang.next())
            {
                String pagePath = defaultPagePath;

                //check if the default page path we created is unique across the site for the language ... we assume adding the -p<ID> will make it unique
                if(!UrlHelper.isUrlUnique(Etn, selectedf, rslang.value("langue_code"), "product", "" + deviceid, pagePath)) pagePath += "-p" + variantId;
                String catalogName = "";
                Set rsCatalog = Etn.execute("select name from catalogs where id = "+escape.cote(catalogid));
                if(rsCatalog.next()) catalogName = parseNull(rsCatalog.value("name"));
                Etn.executeCmd("insert into product_descriptions (product_id, langue_id, seo_title, seo_canonical_url, page_path) values ("+escape.cote(""+deviceid)+","+escape.cote(rslang.value("langue_id"))+", "+escape.cote(variantName+" | "+catalogName)+", "+escape.cote(pagePath)+", "+escape.cote(pagePath)+") ");
                Etn.executeCmd("insert into product_variant_details (product_variant_id, langue_id, name) values ("+escape.cote(""+variantId)+","+escape.cote(rslang.value("langue_id"))+","+escape.cote(variantName)+") ");

                List<Map<String, String>> images = (List<Map<String, String>>)device.get("images");

                int maxImages = 3;
                if(images.size() < maxImages) maxImages = images.size();
                for(int i=0;i<maxImages;i++)
                {
                    String img = images.get(i).get("path");
                    downloadImage(Etn, deviceid, img, (String)device.get("brand"), (String)device.get("model"), variantId, i, rslang.value("langue_code"), rslang.value("langue_id"), selectedf);
                }
                if(maxImages > 0){
                    //invoke pages engine to generate sub images
                    try{
                        Set rsPages = Etn.execute("SELECT val FROM "+GlobalParm.getParm("PAGES_DB")+".config WHERE code = 'SEMAPHORE'");
                        if(rsPages.next()){
                            Etn.execute("SELECT semfree(" + escape.cote(parseNull(rsPages.value("val"))) + ")");
                        }

                    }
                    catch(Exception pagesEx){
                        pagesEx.printStackTrace();
                    }
                }
            }
        }

        Set rs = Etn.execute("select p.*, per.first_name as updated_by from products p left join person per on per.person_id = p.updated_by where id = " + escape.cote(""+deviceid));
        rs.next();

        String vimg = "";
        Set rsimg = Etn.execute("select * from product_variant_resources where product_variant_id = " + escape.cote(""+variantId));
        if(rsimg.next()) vimg = rsimg.value("path");

        JSONObject retJson = new JSONObject();
        retJson.put("status", "sucess")
                .put("msg", "Device imported")
                .put("product_id", deviceid)
                .put("brand", parseNull(rs.value("brand_name")))
                .put("model", parseNull(rs.value("lang_1_name")))
                .put("order_seq", parseNull(rs.value("order_seq")))
                .put("image", vimg)
                .put("updated_on", rs.value("updated_on"))
                .put("updated_by", rs.value("updated_by"));
        out.write(retJson.toString());

    }
    else out.write("{\"status\":\"error\",\"msg\":\"Unable to import the selected device\"}");

%>

