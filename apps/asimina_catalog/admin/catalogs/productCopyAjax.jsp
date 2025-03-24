<jsp:useBean id="Etn" scope="session" class="com.etn.beans.Contexte" />
<%@ page contentType="application/json; charset=utf-8" pageEncoding="utf-8"%>
<%
request.setCharacterEncoding("UTF-8");
response.setCharacterEncoding("UTF-8");
%>
<%@ page import="com.etn.lang.ResultSet.Set,com.etn.util.ItsDate, com.etn.sql.escape, java.util.ArrayList, java.util.LinkedHashMap, java.util.Map,java.util.List, com.etn.beans.app.GlobalParm, org.json.JSONObject, org.json.JSONArray, com.etn.asimina.util.*, com.etn.asimina.data.LanguageFactory, com.etn.asimina.beans.Language"%>
<%@ include file="../../WEB-INF/include/commonMethod.jsp"%>
<%@ include file="../../WEB-INF/include/imager.jsp"%>
<%

    int STATUS_SUCCESS = 1, STATUS_ERROR = 0;

    int status = STATUS_ERROR;
    String message = "";
    JSONObject data = new JSONObject();

    LinkedHashMap<String, String> colValueHM = new LinkedHashMap<String,String>();

    String q = "";
    Set rs = null;

    String productId = parseNull(request.getParameter("productId"));
    String productNewName = parseNull(request.getParameter("productNewName"));
    boolean isCopyImages = "1".equals(parseNull(request.getParameter("copyImages")));

    int newProdId = -1;
    try{

        if(productNewName.trim().length() == 0){
            throw new Exception("name cannot be empty");
        }

        rs = Etn.execute("select * from products where id =  " + escape.cote(productId));

        if(!rs.next()){
            throw new Exception("Invalid product");
        }

        String pid = "" + Etn.getId();

        colValueHM.clear();
        for(String colName : rs.ColName){
            colValueHM.put(colName.toLowerCase(), escape.cote(rs.value(colName)) );
        }

        String removeColumns[] = { "id", "link_id", "pack_details" };
        for(String remColName : removeColumns){
            colValueHM.remove(remColName);
        }
        List<Language> langsList = getLangs(Etn,session);

        for(Language lang : langsList){
            colValueHM.put("lang_"+lang.getLanguageId()+"_name", escape.cote(productNewName));
        }


        colValueHM.put("product_uuid", "UUID()");
        colValueHM.put("image_name", "''");
        colValueHM.put("image_actual_name", "''");
        colValueHM.put("created_by", escape.cote(pid));
        colValueHM.put("created_on", "NOW()");
        colValueHM.put("updated_by", escape.cote(pid));
        colValueHM.put("updated_on", "NOW()");

        q = getInsertQuery("products", colValueHM);

        // newProdId =  9999; //debug
        newProdId = Etn.executeCmd(q);
        //System.out.println(q);

        if(newProdId <= 0){
        	throw new Exception("Error in creating product record");
        }

  		String newProdIdStr = "" + newProdId;

        //product_attribute_values
  		q = " INSERT INTO product_attribute_values( product_id, cat_attrib_id, attribute_value, "
  			+ " is_default, sort_order, small_text, color )  "
  			+ " SELECT " + escape.cote(newProdIdStr) + " AS product_id, "
  			+ " cat_attrib_id, attribute_value, is_default, sort_order, small_text, color "
  			+ " FROM product_attribute_values "
  			+ " WHERE product_id = " + escape.cote(productId)
  			+ " ORDER BY id ";
  		Etn.executeCmd(q);
  		//System.out.println(q);

  		//product_descriptions
  		q = " INSERT INTO product_descriptions( product_id, langue_id, seo, summary, "
  			+ " main_features, video_url, essentials_alignment )  "
  			+ " SELECT " + escape.cote(newProdIdStr) + " AS product_id, "
  			+ " langue_id, seo, summary, main_features, video_url, essentials_alignment "
  			+ " FROM product_descriptions "
  			+ " WHERE product_id = " + escape.cote(productId);
  		Etn.executeCmd(q);
  		//System.out.println(q);

  		//product_tabs
  		q = " INSERT INTO product_tabs( product_id, langue_id, name, content, order_seq)  "
  			+ " SELECT " + escape.cote(newProdIdStr) + " AS product_id, "
  			+ " langue_id, name, content, order_seq "
  			+ " FROM product_tabs "
  			+ " WHERE product_id = " + escape.cote(productId)
  			+ " ORDER BY id ";
  		Etn.executeCmd(q);
  		//System.out.println(q);


  		//product_tags
  		q = " INSERT INTO product_tags( product_id, tag_id, created_by, created_on )  "
  			+ " SELECT " + escape.cote(newProdIdStr) + " AS product_id, "
  			+ " tag_id, " + escape.cote(pid) + " , NOW() "
  			+ " FROM product_tags "
  			+ " WHERE product_id = " + escape.cote(productId);
  		Etn.executeCmd(q);
  		//System.out.println(q);

        //share_bar
        q = "SELECT * FROM share_bar WHERE id = " + escape.cote(productId);
        rs = Etn.execute(q);
        if(rs.rs.Rows > 0){
            ProductShareBarImageHelper oldSBImageHelper = new ProductShareBarImageHelper(productId);
            ProductShareBarImageHelper newSBImageHelper = new ProductShareBarImageHelper(newProdIdStr);
            while(rs.next()){

            	//copy table record
                colValueHM.clear();
                for(String colName : rs.ColName){
                    colValueHM.put(colName.toLowerCase(), escape.cote(rs.value(colName)) );
                }

                colValueHM.put("id", escape.cote(newProdIdStr));
                colValueHM.put("created_on", "NOW()");
                colValueHM.put("updated_on", "NOW()");
                colValueHM.put("created_by", escape.cote(pid));
                colValueHM.put("updated_by", escape.cote(pid));


                //copy sharebar images
        		for(Language lang : langsList){
        		    String langId = lang.getLanguageId();

        		    if(isCopyImages){
        		    	//copy image files on disk
        		    	String fileName = parseNull(rs.value("lang_" + langId + "_og_image"));
	        		   	if(fileName.length() > 0){
	        		        String imageData =  oldSBImageHelper.getBase64Image(fileName);
	        		        newSBImageHelper.saveBase64(imageData, fileName);
	        		    }
        		    }
        		    else{
        		    	//dont copy images, clear column values
        		    	colValueHM.put("lang_" + langId + "_og_image", "''");
        		    	colValueHM.put("lang_" + langId + "_og_original_image_name", "''");
        		    	colValueHM.put("lang_" + langId + "_og_image_label", "''");
        		    }

        		}

                q = getInsertQuery("share_bar", colValueHM);
                Etn.executeCmd(q);
                //System.out.println(q);

            }
        }


  		//product_essential_blocks
        q = "SELECT * FROM product_essential_blocks "
        	+ " WHERE product_id = " + escape.cote(productId)
        	+ " ORDER BY id ";
        rs = Etn.execute(q);
        if(rs.rs.Rows > 0){
            ProductEssentialsImageHelper oldEssImgHelper = new ProductEssentialsImageHelper(productId);
            ProductEssentialsImageHelper newEssImgHelper = new ProductEssentialsImageHelper(newProdIdStr);

            while(rs.next()){

                String fileName = parseNull(rs.value("file_name"));
                String actual_file_name = parseNull(rs.value("actual_file_name"));
                String image_label = parseNull(rs.value("image_label"));

                if(isCopyImages){
	                //copy image from src to dest
	                if(fileName.length() > 0){
	                    String imageData =  oldEssImgHelper.getBase64Image(fileName);
	                    newEssImgHelper.saveBase64(imageData, fileName);
	                }
                }
                else{
                	//dont copy clear images
                	fileName = actual_file_name = image_label = "";
                }

                //copy current row
                q = " INSERT INTO product_essential_blocks( product_id, langue_id, block_text, "
                    + " file_name, actual_file_name, image_label )  "
                    + " SELECT " + escape.cote(newProdIdStr) + " AS product_id, "
                    + " langue_id, block_text, "
                    + escape.cote(fileName) + " AS file_name, "
                    + escape.cote(actual_file_name) + " AS actual_file_name, "
                    + escape.cote(image_label) + " AS image_label "
                    + " FROM product_essential_blocks "
                    + " WHERE id = " + escape.cote(rs.value("id"));
                Etn.executeCmd(q);
                //System.out.println(q);

            }
        }


        //reused in for product_image and also for product_variants
        ProductImageHelper oldProdImgHelper = new ProductImageHelper(productId);
        ProductImageHelper newProdImgHelper = new ProductImageHelper(newProdIdStr);

        if(isCopyImages){
        	//product_images
        	q = "SELECT * FROM product_images "
        		+ " WHERE product_id = " + escape.cote(productId)
        	    + " ORDER BY id ";
        	rs = Etn.execute(q);

        	while(rs.next()){

        	    String fileName = parseNull(rs.value("image_file_name"));

        	    //copy image from src to dest
        	    if(fileName.length() > 0){
        	        String imageData =  oldProdImgHelper.getBase64Image(fileName);
        	        newProdImgHelper.saveBase64(imageData, fileName);
        	        saveAllImages(newProdImgHelper.getImageDirectory(),fileName);
        	    }

        	    //copy current row
        	    q = " INSERT INTO product_images( product_id, langue_id, image_file_name, "
        	        + " image_label, actual_file_name, sort_order )  "
        	        + " SELECT " + escape.cote(newProdIdStr) + " AS product_id, "
        	        + " langue_id, image_file_name, image_label, actual_file_name, sort_order "
        	        + " FROM product_images "
        	        + " WHERE id = " + escape.cote(rs.value("id"));
        	    Etn.executeCmd(q);
        	    //System.out.println(q);

        	}
        }


  		//product variants
  		q = "SELECT * FROM product_variants WHERE product_id = " + escape.cote(productId)
  			+ " ORDER BY id ";
  		rs = Etn.execute(q);
  		while(rs.next()){

            String curVariantId = rs.value("id");

            //copy table record
            colValueHM.clear();
            for(String colName : rs.ColName){
                colValueHM.put(colName.toLowerCase(), escape.cote(rs.value(colName)) );
            }

            colValueHM.remove("id");

            colValueHM.put("product_id", escape.cote(newProdIdStr));
            colValueHM.put("uuid", "UUID()");
            colValueHM.put("sku", escape.cote("randomSKU_"+getRandomString()));
            colValueHM.put("stock","'0'");
            colValueHM.put("created_on", "NOW()");
            colValueHM.put("updated_on", "NOW()");
            colValueHM.put("created_by", escape.cote(pid));
            colValueHM.put("updated_by", escape.cote(pid));

            q = getInsertQuery("product_variants", colValueHM);

            int iVarId = Etn.executeCmd(q);
            	//System.out.println(q);
            if(iVarId <= 0){
                System.out.println("Error Q: " + q);
                throw new Exception("Error in creating new variant record");
            }

            String newVariantId = "" + iVarId;

            //product_variant_ref
            q = " INSERT INTO product_variant_ref( product_variant_id, cat_attrib_id, catalog_attribute_value_id)  "
                + " SELECT " + escape.cote(newVariantId) + " AS product_variant_id, "
                + " cat_attrib_id, catalog_attribute_value_id "
                + " FROM product_variant_ref "
                + " WHERE product_variant_id = " + escape.cote(curVariantId)
                + " ORDER BY id ";
            Etn.executeCmd(q);
            //System.out.println(q);

            //product_variant_details
            q = " INSERT INTO product_variant_details( product_variant_id, langue_id, name, main_features)  "
                + " SELECT " + escape.cote(newVariantId) + " AS product_variant_id, "
                + " langue_id, name, main_features "
                + " FROM product_variant_details "
                + " WHERE product_variant_id = " + escape.cote(curVariantId);
            Etn.executeCmd(q);
            //System.out.println(q);


            //product_variant_resources
            //only get type = image , as video is obsolete, it was moved to product description
            if(isCopyImages){
            	q = "SELECT * FROM product_variant_resources "
            	    + " WHERE type = 'image' AND product_variant_id = " + escape.cote(curVariantId)
            	    + " ORDER BY id ";
            	Set pvrRs = Etn.execute(q);

            	while(pvrRs.next()){

            	    String fileName = parseNull(pvrRs.value("path"));

            	    //copy image from src to dest
            	    if(fileName.length() > 0){
            	        String imageData =  oldProdImgHelper.getBase64Image(fileName);
            	        newProdImgHelper.saveBase64(imageData, fileName);
            	        saveAllImages(newProdImgHelper.getImageDirectory(),fileName);
            	    }

            	    //copy current row
            	    q = " INSERT INTO product_variant_resources( product_variant_id, type, langue_id, "
            	        + " path, actual_file_name, label, sort_order )  "
            	        + " SELECT " + escape.cote(newVariantId) + " AS product_variant_id, "
            	        + " type, langue_id, path, actual_file_name, label, sort_order "
            	        + " FROM product_variant_resources "
            	        + " WHERE id = " + escape.cote(pvrRs.value("id"));
            	    Etn.executeCmd(q);
            	    //System.out.println(q);

            	}
            }

  		}

        // data = new JSONObject(colValueHM);
        data.put("new_product_id", newProdIdStr);
        status = STATUS_SUCCESS;

    }//try
    catch(Exception ex){
        message = ex.getMessage();
        ex.printStackTrace();
        status = STATUS_ERROR;

        //TODO , revert new product, if created, and all its components
        if(newProdId > 0){
            String newProdIdStr = "" + newProdId;

            Etn.executeCmd("DELETE FROM share_bar WHERE id = " + escape.cote(newProdIdStr));
            Etn.executeCmd("DELETE FROM product_attribute_values WHERE product_id = " + escape.cote(newProdIdStr));
            Etn.executeCmd("DELETE FROM product_descriptions WHERE product_id = " + escape.cote(newProdIdStr));
            Etn.executeCmd("DELETE FROM product_tabs WHERE product_id = " + escape.cote(newProdIdStr));
            Etn.executeCmd("DELETE FROM product_tags WHERE product_id = " + escape.cote(newProdIdStr));
            Etn.executeCmd("DELETE FROM product_essential_blocks WHERE product_id = " + escape.cote(newProdIdStr));
            Etn.executeCmd("DELETE FROM product_images WHERE product_id = " + escape.cote(newProdIdStr));

            //variants
            q = " DELETE d "
                + " FROM product_variant_details d "
                + " JOIN product_variants v ON d.product_variant_id = v.id "
                + " AND v.product_id = " + escape.cote(newProdIdStr);
            Etn.executeCmd(q);
            //System.out.println(q);

            q = " DELETE r "
                + " FROM product_variant_ref r "
                + " JOIN product_variants v ON r.product_variant_id = v.id "
                + " AND v.product_id = " + escape.cote(newProdIdStr);
            Etn.executeCmd(q);
            //System.out.println(q);

            q = " DELETE r "
                + " FROM product_variant_resources r "
                + " JOIN product_variants v ON r.product_variant_id = v.id "
                + " AND v.product_id = " + escape.cote(newProdIdStr);
            Etn.executeCmd(q);
            //System.out.println(q);

            Etn.executeCmd("DELETE FROM product_variants WHERE product_id = " + escape.cote(newProdIdStr));

        	Etn.executeCmd("DELETE FROM products WHERE id = " + escape.cote(newProdIdStr));

            //now delete product image directories
            ProductShareBarImageHelper sbImageHelper = new ProductShareBarImageHelper(newProdIdStr);
            deleteDirectoryWithContent(sbImageHelper.getImageDirectory());

            ProductEssentialsImageHelper essImageHelper = new ProductEssentialsImageHelper(newProdIdStr);
            deleteDirectoryWithContent(essImageHelper.getImageDirectory());

            ProductImageHelper prodImageHelper = new ProductImageHelper(newProdIdStr);
            deleteDirectoryWithContent(prodImageHelper.getImageDirectory());



        }
    }

    JSONObject jsonResponse = new JSONObject();
    jsonResponse.put("status",status);
    jsonResponse.put("message",message);
    jsonResponse.put("data",data);
    out.write(jsonResponse.toString());
%>
