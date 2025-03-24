<%!
    JSONArray getVariantAttributes(Contexte Etn,String variantId){
        //TODO AA
        String query = ""
                + "select r.id variant_attribute_id,r.cat_attrib_id catalog_attribute_id,catalog_attribute_value_id,v.attribute_value "
                + "  from product_variant_ref r "
                + "  left join catalog_attribute_values v on r.catalog_attribute_value_id = v.id and r.cat_attrib_id = v.cat_attrib_id "
                + " where product_variant_id = " + escape.cote(variantId);

        return toJSONArray(Etn,query);
    }


    JSONArray getVariantDetails(Contexte Etn,String variantId){

        String query = "select langue_id AS language_id,name,main_features, action_button_desktop, action_button_desktop_url, action_button_desktop_url_opentype, action_button_mobile, action_button_mobile_url, action_button_mobile_url_opentype from product_variant_details  where product_variant_id = " + escape.cote(variantId);

        return toJSONArray(Etn,query);
    }

    JSONArray getVariantResources(Contexte Etn,String variantId,ProductImageHelper productImageHelper){
        JSONArray resources = new JSONArray();
        String query = "select id resource_id,type,langue_id language_id,path,actual_file_name,label from product_variant_resources where product_variant_id = " + escape.cote(variantId) + " order by sort_order ";
        Set rs = Etn.execute(query);
        if(rs != null){
            while(rs.next()){
                JSONObject resource = new JSONObject();
                resource.put("resourceId",rs.value("resourceId"));
                resource.put("type",rs.value("type"));
                resource.put("path",rs.value("path"));//needed on client side for videos.
                resource.put("languageId",rs.value("language_id"));
                resource.put("actualFileName",rs.value("actual_file_name"));
                resource.put("label",rs.value("label"));
                resource.put("fileName",rs.value("path"));
                // if(productImageHelper != null){
                //     String rawImage = rs.value("path");//getRawImageName(rs.value("path"));
                //     resource.put("image",productImageHelper.getBase64Image(rawImage));
                // }else{
                //     //com.etn.util.Logger.info(("Image is null");
                //     resource.put("image","");
                // }
                resources.put(resource);
            }
        }
        return resources;
    }


    JSONArray getVariants(Contexte Etn,String productId,ProductImageHelper productImageHelper, String sortVariant){

        String sorting = " order by ";

        if(sortVariant.equals("cda"))
            sorting += "created_on asc, id asc";
        else if(sortVariant.equals("cdd"))
            sorting += "created_on desc, id desc";
        else if(sortVariant.equals("pd"))
            sorting += "price desc ";
        else if(sortVariant.equals("pa"))
            sorting += "price asc";
        else if(sortVariant.equals("cu"))
            sorting += "order_seq asc";
        else
            sorting += "id";

        JSONArray variants = new JSONArray();
		if(com.etn.asimina.util.UIHelper.parseNull(productId).length() > 0)
		{
			Set rs = Etn.execute("select id AS variant_id,sku,is_active,is_default,is_show_price,price,frequency,commitment,stock,sticker from product_variants where product_id = " + escape.cote(productId) + sorting);

			if(rs != null){
				while(rs.next()){
					JSONObject variant = toJSONObject(rs);
					String variantId = variant.getString("variantId");
					variant.put("attributes",getVariantAttributes(Etn,variantId));
					variant.put("details",getVariantDetails(Etn,variantId));
					variant.put("resources",getVariantResources(Etn,variantId,productImageHelper));
					variants.put(variant);
				}
			}
		}
        return variants;
    }

    JSONArray getConstants(Contexte Etn, String selectedsiteid){

        JSONArray constants = new JSONArray();

        Set rs = Etn.execute("select `sname` as `key`, IF(LENGTH(`display_name_2`) = 0, `display_name_1`, `display_name_2`) as `value` from `stickers` where `site_id` = " + escape.cote(selectedsiteid) + " order by `priority`");

        if(rs != null){

            constants.put(new JSONObject("{\"value\":\"No Sticker\",\"key\":\"none\"}"));
            while(rs.next()){

                constants.put(toJSONObject(rs));
            }
        }

        return constants;
    }

    JSONArray getCatalagAttributeValues(Contexte Etn, String catAttribId){
        String q = "SELECT * FROM catalog_attribute_values "
                    + " WHERE cat_attrib_id = " + escape.cote(catAttribId)
                    + " ORDER BY sort_order,id " ;

        JSONArray retArray = toJSONArray(Etn, q);

        return retArray;
    }
%>

<!-- variants -->

<div class="card mb-2">
    <div class="p-0 card-header btn-group bg-secondary d-flex" role="group" aria-label="Basic example">
        <button type="button" class="btn btn-link btn-block text-left text-decoration-none"
            data-toggle="collapse" href="#collapseVariants" role="button" aria-expanded="false" aria-controls="collapseVariants" style="padding:0.75rem 1.25rem;color:#3c4b64">
            <strong>Variants</strong>
        </button>
        <button id="addvariant" type="button" class="btn btn-success" style="text-wrap:nowrap" >+ Add Variant</button>
        <button  type="button" class="btn btn-primary" onclick="onsave()">Save</button>
    </div>

    <div class="collapse border-0 asimina-variant-zone p-3" id="collapseVariants"></div>
</div>
<script type="text/javascript">
    function showVariantCollapse(btn){
        var collapseId = $(btn).parent().find("[data-toggle=collapse]:first").attr('href');
        $(collapseId).collapse('show');
    }
    etn.asimina.page.ready(100,function(e){

        etn.asimina.langtabs.init(<%=new JSONArray(langsList)%>);
        etn.asimina.constants.init(<%=com.etn.asimina.data.ConstantsFactory.instance.getJSON().toString()%>);
        etn.asimina.variants.init({
            'parent':'#collapseVariants',
            'catalogAttributes':[],
            'productType':'<%=prodType%>',
            'catalogType':'<%=catalogType%>',
            'isPriceTaxIncluded':<%=(isPriceTaxIncluded)?"true":"false"%>,
            'taxPercentage':<%=taxPercentage%>,'productName':'<%=getValue(rs, "lang_1_name")%>'
        });
        <%
            catAttributesRs.moveFirst();
            while(catAttributesRs.next()){
                String curCatAttribId = catAttributesRs.value("cat_attrib_id");
                JSONArray catAttribValues = getCatalagAttributeValues(Etn,curCatAttribId);
        %>
            etn.asimina.variants.addCatalogAttribute('<%=curCatAttribId%>','<%=escapeCoteValue(catAttributesRs.value("name"))%>', <%=catAttribValues.toString()%> );
        <%
            }
        %>
        etn.asimina.variants.addAll(<%=getVariants(Etn,id,productImageHelper,getValue(rs, "sort_variant"))%>,<%=getConstants(Etn, selectedsiteid)%>);
        $('#addvariant').click(function(e){
            etn.asimina.variants.add(undefined,<%= getConstants(Etn, selectedsiteid)%>);
            $('#collapseVariants').collapse('show');

            etn.asimina.util.setDuplicableSectionOrder($(".asimina-variant-zone:first"));
        });

        etn.asimina.util.setDuplicableSectionOrder($(".asimina-variant-zone:first"));

    });

    function seturl(id, url){
        $('#'+id).val(url);
    }

</script>

                    <!-- /variants -->
