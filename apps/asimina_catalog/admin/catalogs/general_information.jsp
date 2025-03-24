<%!
    String getManufacturerOptions(Set rs,Set rscat){
        String brandsStr = rscat.value("manufacturers");
        String brand = getRsValue(rs,"brand_name");
        Gson gson = new Gson();
        java.lang.reflect.Type gsonTypeMap = new TypeToken<java.util.List<Object>>(){}.getType();
        java.util.List brandList = null;
        try{
            brandList = gson.fromJson(brandsStr, gsonTypeMap);
        }
        catch(Exception ex){}
        String brandOptions = "";

        if(brandList != null){
            for (Object tObj : brandList) {
                Map<String,String> curObj = (Map)tObj;

                brandOptions += "<option value='" + escapeCoteValue(curObj.get("name")) + "' ";
                if(brand.equals(curObj.get("name"))){
                    brandOptions += " selected='selected'";
                }
                brandOptions += " >" + escapeCoteValue(curObj.get("name")) + "</option>\n";
            }
        }
        return brandOptions;
    }

    JSONArray getAllTags(Contexte Etn, String siteId){
        JSONArray tags = new JSONArray();
        Set rs = Etn.execute("select id, label, folder_id from tags where site_id = "+escape.cote(siteId)+ " order by label");
        if(rs != null){
            while(rs.next()){
                JSONObject tag = new JSONObject();
                tag.put("id",rs.value("id"));

                if(parseNull(rs.value("folder_id")).length() > 0){
                    Set tagFolder = Etn.execute("select * from tags_folders where id="+escape.cote(rs.value("folder_id")));
                    if(tagFolder.next()){
                        tag.put("label",parseNull(tagFolder.value("name")).replace("$","/")+"/"+parseNull(rs.value("label")));
                    }else{
                        tag.put("label",rs.value("label"));
                    }
                }else{
                    tag.put("label",rs.value("label"));
                }

                tags.put(tag);
            }
        }
        return tags;
    }

    JSONArray getProductTags(Contexte Etn,String id){
        JSONArray tags = new JSONArray();
        Set rs = Etn.execute("select t.id,t.label from tags t join product_tags p on t.id = p.tag_id and p.product_id = " + escape.cote(id));
        if(rs != null){
            while(rs.next()){
                JSONObject tag = new JSONObject();
                tag.put("id",rs.value("id"));
                tag.put("label",rs.value("label"));
                tags.put(tag);
            }
        }
        return tags;
    }

    JSONArray getProductImages(Contexte Etn,String id,ImageHelper imageHelper){
        JSONArray images = new JSONArray();
        Set rs = Etn.execute("select langue_id,image_file_name,image_label,actual_file_name from product_images where product_id = " + escape.cote(id));
        if(rs != null){
            while(rs.next()){
                JSONObject image = new JSONObject();
                image.put("fileName",rs.value("image_file_name"));
                image.put("label",rs.value("image_label"));
                image.put("actualFileName",rs.value("actual_file_name"));
                image.put("languageId",rs.value("langue_id"));
                images.put(image);
            }
        }
        return images;
    }
%>
<!-- General informations -->
<%@ page import="com.etn.asimina.beans.KeyValuePair" %>
<%
    Set rsDesc2 = Etn.execute("select langue_id, page_template_id from product_descriptions where product_id = " + escape.cote(id));

    ArrayList<KeyValuePair<String, String>> pageTemplatesList = new ArrayList<KeyValuePair<String,String>>();
    pageTemplatesList.add(new KeyValuePair("0", "-- Catalog default --"));
    Set ptRs = Etn.execute("SELECT id, name FROM "+GlobalParm.getParm("PAGES_DB")+".page_templates WHERE site_id = "+escape.cote(selectedsiteid)+" ORDER BY is_system DESC, name ASC");
    while(ptRs.next()){
        pageTemplatesList.add(new KeyValuePair(ptRs.value("id"), ptRs.value("name")));
    }

%>
<div class="card mb-2">
<div class="p-0 card-header btn-group bg-secondary d-flex"  role="group" aria-label="Basic example">
                <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#generalinformaton" role="button" aria-expanded="false" aria-controls="collapseExample" style="padding:0.75rem 1.25rem;color:#3c4b64">
                    <strong>General Information</strong>
                </button>
                <% if(!bIsProd) { %>
                    <button id="generalSave" type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
                <%}%>
</div>
<div class="collapse border-0 show" id="generalinformaton">
        <div class="card-body form-horizontal">
            <div class="form-group row">
                <label for="lang_1_name" class="col-sm-3 col-form-label">Product name</label>
                <div class="col-sm-9">
                    <%=UIHelper.getLangInputs(langsList,"lang_%s_name", "lang_%s_name", "lang_%s_name", rs, "product_name_lang_input")%>
                </div>
            </div>
            <% if("offer".equals(catalogType)){%>
            <div class="form-group row">
                <label for="sticker" class="col-sm-3 col-form-label">Type</label>
                <div class="col-sm-9">
                    <!-- offer type only set when creating new offer -->
                    <% if(rs == null){ %>
                    <select class="custom-select" name="ignore" id="offerTypeSelect" onChange="onChangeOfferType()">
                        <option value="offer_prepaid">Prepaid</option>
                        <option value="offer_postpaid">Postpaid</option>
                    </select>
                    <% } else {
                        String prodTypeStr = "offer_postpaid".equals(prodType)?"Postpaid":"Prepaid";
                    %>
                        <input type="text" name="ignore" value="<%=prodTypeStr%>"  class="form-control" readonly>
                    <% } %>
                </div>
            </div>
            <%}%>

            <% if(showManufacturers){%>
            <div class='form-group row <%=showManufacturers?"":"d-none"%>'>
                <label for="staticEmail" class="col-sm-3 col-form-label">Manufacturer</label>
                <div class="col-sm-9 d-flex">
                    <%
                    boolean manReadonly  = true;
                    if(rs == null || parseNull(rs.value("import_source")).length() == 0){
                        manReadonly = false;
                    }
                    manReadonly = false;//manufacturer readonly deprecated , its editable in all cases


                    if(manReadonly){
                    %>
                    <input type="text" class="form-control brand_name" name="ignore" readonly
                        value='<%=getValue(rs,"brand_name")%>' >
                    <%

                    } else {

                        Set brandRs = Etn.execute("SELECT DISTINCT brand_name FROM products WHERE catalog_id = " + escape.cote(cid) + " ORDER BY brand_name");
                        JSONArray brandArray = new JSONArray();
                        while(brandRs.next()){
                            String curBrand = getRsValue(brandRs, "brand_name");
                            if(curBrand.length() > 0){
                                brandArray.put(curBrand);
                            }
                        }
                    %>
                        <div class="input-group">
                            <input type="text" class="form-control brand_name"
                                value='<%=getValue(rs,"brand_name")%>'
                                name="brand_name" id="brand_name"
                                >
                        </div>
                        <span class="input-group-append">
                            <button id="brand_name_btn" class="btn btn-secondary" type="button">
                                <i class="fas fa-caret-down"></i>
                            </button>
                        </span>
                        <script type="text/javascript">
                                etn.asimina.page._brandList = <%=brandArray.toString()%>;
                        </script>
                    <% } %>
                </div>
            </div>
            <% } %>

            <div class="form-group row">
                <label for="staticEmail" class="col-sm-3 col-form-label">Tag </label>
                <div class="col-sm-9">
                    <div class="input-group mb-3">
                        <div class="position-relative w-100">
                            <input type="text" class="form-control" placeholder="search and add (by clicking return)" id="inputProductTags">
                        </div>
                    </div>
                    <div id="divProductTags" class="tagsDiv row"></div>
                </div>
            </div>


            <div class="form-group row">
                <label for="sort_variant" class="col-sm-3 col-form-label">Variant sort</label>
                <div class="col-sm-9">
                    <%=addSelectControl("sort_variant", "sort_variant", variantSortOptionValues, getRsValue(rs, "sort_variant"), "custom-select", "")%>
                </div>
            </div>


			<% if("1".equals(GlobalParm.getParm("IS_ORANGE_APP")) == false) {%>
			<div class="form-group row">
				<label for="select_variant_by" class="col-sm-3 col-form-label">Variant selection by</label>
				<div class="col-sm-9">
					<select name="select_variant_by" id="select_variant_by" class="custom-select">
						<option value="attributes">Attributes</option>
						<option <%=getRsValue(rs, "select_variant_by").equals("image")?"selected":""%> value="image">Image</option>
					</select>
				</div>
			</div>
			<%}%>
            <div class="form-group row">
                <label class="col-sm-3 col-form-label">Variant</label>
                <div class="col-sm-9">
                   <select class='custom-select' name='html_variant' id='html_variant'>
                        <option value="all" <%=getRsValue(rs,"html_variant").equals("all")?"selected":""%> >All</option>
                        <option value="anonymous" <%=getRsValue(rs,"html_variant").equals("anonymous")?"selected":""%> >Anonymous</option>
                        <option value="logged" <%=getRsValue(rs,"html_variant").equals("logged")?"selected":""%> >Logged</option>
                    </select>
                </div>
            </div>

            <div class="form-group row">
                <label class="col-sm-3 col-form-label">Page template</label>
                <div class="col-sm-9">
                    <%=UIHelper.getLangSelectsRowWise(langsList,"description_page_template_id_lang_%s", "description_page_template_id_lang_%s", pageTemplatesList," page_template_id custom-select", " required " ,"page_template_id",rsDesc2 )%>
                </div>
            </div>

            <%=UIHelper.getLangFields(langsList,"<div id='product_image_lang_%1$s' class='asimina-multilingual-block' data-language-id='%1$s'></div>")%><!-- there is
            some problem do not use <div/>-->
        </div>
    </div>
</div>
    <script type="text/javascript">

        function onChangeOfferType(){
            var prodTypeInput = $("#product_type");
            var select = $("#offerTypeSelect");
            if(prodTypeInput.length > 0 && select.length > 0){
                var prodType = $(select).val();
                prodTypeInput.val(prodType);

                etn.asimina.variants.onProductTypeChange();
            }
        }
        onChangeOfferType();

        function removeTag(ele)
        {   
            let tag = $(ele).closest("span.badge-tag");
            tag.remove();
        }

        function tagExists(tag){
            var doesTagExist = false;
            $("input[type='hidden'][name='tagValue']").each(function(i,o){
                if($(o).val() === tag.id){
                   doesTagExist = true;
                }
                return;
            });
            return doesTagExist;
        }
        function addTag(tag){
            if(!tagExists(tag)){
                let pill = $("<span></span>",{ class: 'badge badge-pill badge-dark badge-tag mb-2 mr-2' });
                pill.append($(`<a></a>`,{ 
                    class:'badge badge-pill badge-white ml-2', 
                    html: '<i data-feather="x" style="color:#f16e00"></i>'
                }).on("click",function(){
                    removeTag(this);
                }));
                
                $("#divProductTags").append(pill);

                let tagContent = tag.label.split("/");
                
                if(tagContent.length>1){
                    let folderSpan = $(`<span></span>`,{class: "badge-folder pr-1"});
                    folderSpan.text(tagContent[0]+" /");
                    pill.find("a").first().before(folderSpan);
                    pill.find("a").first().before(tagContent[1]);        
                }
                else{
                    pill.find("a").first().before(tagContent);
                }
                pill.find("a").first().append(`<input type='hidden' class='tagValue' name='tagValue' value='${tag.id}'>`);
                feather.replace();
            }
        }
        etn.asimina.page.ready(200,function(e){

            $('input.product_name_lang_input').each(function(index, el) {
                el = $(el);
                el.attr('maxlength','255');
                if(index == 0){
                    el.prop('required',true);
                }
            });

        $("input.product_name_lang_input").on("change",function(e){

            var product_name = $(this).val().trim();
            var brand_name = "";
            if($('#brand_name').length>0) brand_name =  $('#brand_name').val().trim();
            var lang = $(this).attr('data-language-id');

            if($('#brand_name').length<=0 && $('input[name="product_image_lang_'+lang+'Label"]').first().hasClass("unsaved"))
                $('input[name="product_image_lang_'+lang+'Label"]').first().val(product_name);

            // change variant, sku alt Image, text
              $('input[name$="variantId"]').each(function(index, val) {
                var v_name = "";
                var id =  $(this).val();
                var isSaved =  $(this).prev().val();
                if(isSaved == '0'){
                    var attribValues  = "";
                    $('#variantName'+id+'_lang_'+lang).parent().parent().parent().prevAll('.row').each(function(index, val){
                        var attVal =  $(this).find('option:selected').text();
                        if(attVal.length > 0 && attVal != '(none)'){
                            if(attribValues.length>0) attribValues += " ";
                            attribValues += attVal;
                        }
                    });
                    v_name += brand_name;
                    if(product_name.length >  0) {
                        if(v_name.length>0) v_name += " ";
                        v_name += product_name;
                    }
                    if(attribValues.length>0)
                        if(v_name.length>0) v_name += " ";
                        v_name += attribValues;
                    $('#variantName'+id+'_lang_'+lang).val(v_name);
                    $('#variantName'+id+"_lang_"+lang).next().html("");
                    $('#variantName'+id+"_lang_"+lang).removeClass("is-invalid");

                    if(lang == 1){
                        var headCollapse =  $('#variantName'+id+'_lang_'+lang).closest('.collapse').prev();
                        var varNum =  headCollapse.find('input.sectionOrderInput').first().val();
                        headCollapse.find('button').first().html("Variant "+varNum+": "+v_name);
                    }
                    $('input[name$="variantImage'+id+'_lang_'+lang+'Label"]').each(function(index, val) {
                        if($('#brand_name').length>0) $(this).val(v_name);
                        else $(this).val(product_name);
                     });
                    if(lang == 1) {
                        $('#variantSKU'+id).val(v_name.replace(/ /g,"_").replace(/[^\w\s]/gi, ''));
                        $('#variantSKU'+id).next().html("");
                        $('#variantSKU'+id).removeClass("is-invalid");
                    }
                }
              });
        });
        $('#brand_name').on("change",function(e){

            var product_name = "";
            var brand_name = $('#brand_name').val().trim();
            var lang =0;
            // change variant, sku alt Image, text
            for(var i=0; i<etn.asimina.langtabs.langs().length; i++){
                lang = etn.asimina.langtabs.langs()[i].languageId;
                product_name = $('#lang_'+lang+'_'+'name').val().trim();
                $('input[name$="variantId"]').each(function(index, val) {
                var v_name = "";
                var id =  $(this).val();
                var isSaved =  $(this).prev().val();
                if(isSaved == '0'){
                    var attribValues  = "";
                    $('#variantName'+id+'_lang_'+lang).parent().parent().parent().prevAll('.row').each(function(index, val){
                        var attVal =  $(this).find('option:selected').text();
                        if(attVal.length > 0 && attVal !== '(none)'){
                            if(attribValues.length>0) attribValues += " ";
                            attribValues += attVal;
                        }
                    });
                    v_name += brand_name;
                    if(product_name.length >  0) {
                        if(v_name.length>0) v_name += " ";
                        v_name += product_name;
                    }
                    if(attribValues.length>0)
                        if(v_name.length>0) v_name += " ";
                        v_name += attribValues;
                    $('#variantName'+id+'_lang_'+lang).val(v_name);

                    if(lang == 1){
                        var headCollapse =  $('#variantName'+id+'_lang_'+lang).closest('.collapse').prev();
                        var varNum =  headCollapse.find('input.sectionOrderInput').first().val();
                        headCollapse.find('button').first().html("Variant "+varNum+": "+v_name);
                    }
                    $('input[name$="variantImage'+id+'_lang_'+lang+'Label"]').each(function(index, val) {
                        $(this).val(v_name);
                     });
                    if(i == 0)  {
                        $('#variantSKU'+id).val(v_name.replace(/ /g,"_").replace(/[^\w\s]/gi, ''));
                        $('#variantSKU'+id).next().html("");
                        $('#variantSKU'+id).removeClass("is-invalid");
                    }
                }
              });
            }
        });


            var allTags = <%=getAllTags(Etn, getSelectedSiteId(session) )%>;
            var productTags = <%=getProductTags(Etn,id)%>;
        
            productTags.forEach(function(tag){
                addTag(tag);
            });

            if($("#brand_name").length > 0){

                var onChangeBrandName = function(input){
                    var val = $(input).val();
                    var properCase = [];
                    $.each(val.split(" "),function(index, val) {
                        val = val.trim();
                        properCase.push(val.charAt(0).toUpperCase()
                                + val.substr(1));
                    });
                    var newVal = properCase.join(" ");
                    $(input).val(newVal);
                };

                initTagAutocomplete($("#brand_name"),false, etn.asimina.page._brandList,false);

                $('#brand_name_btn').on( "mousedown", function(e) {

                    var input=document.getElementById("brand_name");
                    var autocompleteList = input.nextElementSibling;

                    if(autocompleteList==null) {

                        autocompleteList=document.createElement("ul");
                        autocompleteList.classList.add("autocomplete-items","p-0","w-100");
                        autocompleteList.style.listStyleType="none";
                        autocompleteList.style.borderTop="none";
                        autocompleteList.style.border="1px solid #ddd";

                    }else{
                        autocompleteList.innerHTML="";
                    }

                    etn.asimina.page._brandList.forEach(function(tag) {
                        const suggestion = document.createElement('li');
                        var newText = tag ;
                        suggestion.innerHTML = `<a style="cursor:pointer;" title="${newText}" >${newText}</a>`;
                        suggestion.addEventListener('mousedown', function(e) {
                            input.value = e.target.querySelector("a").innerHTML.trim();
                            autocompleteList.outerHTML="";
                        });

                        autocompleteList.appendChild(suggestion);
                        const parent = input.parentElement;
                        const oldAutocompleteList = parent.querySelector('.autocomplete-items');
                        if (oldAutocompleteList) {
                            parent.removeChild(oldAutocompleteList);
                        }
                        parent.appendChild(autocompleteList);
                    });

                });
            }

            initTagAutocomplete($( "#inputProductTags" ),false,allTags,true);

            <%
            if( "offer".equals(catalogType) ){
            %>
                var images = <%=getProductImages(Etn,id,productImageHelper)%>;
                images.forEach(function(image){
                    etn.asimina.images2.add("product_image_lang_" + image.languageId,"#product_image_lang_" + image.languageId,image,"Image");
                });
                etn.asimina.langtabs.langs().forEach(function(lang){
                   etn.asimina.images2.addEmpty("product_image_lang_" + lang.languageId,"#product_image_lang_" + lang.languageId,1,true);
                });
            <%
            }
            %>
        });
    </script>
    <!-- /General informations -->