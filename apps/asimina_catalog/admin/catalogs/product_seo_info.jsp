<%
    String qSeo = "";
	Set rsMetaTags = null;
	if(parseNull(id).length() > 0)
	{
		qSeo = "select pd.langue_id, pd.seo, pd.seo_title, pd.page_path, pd.seo_canonical_url,"
		+" concat(concat_ws('/', nullif(cd.folder_name,''), nullif(fv.concat_path,'')),'/')  as folders_prefix_path"
		+" from product_descriptions pd"
		+" left join catalog_descriptions cd on cd.langue_id = pd.langue_id"
		+" left join products_folders_lang_path fv on fv.langue_id = cd.langue_id and fv.folder_id= "+escape.cote(folderId)
		+" and fv.site_id = "+escape.cote(selectedsiteid)
		+" where product_id = " + escape.cote(id)+" and cd.catalog_id ="+escape.cote(cid);
		
		rsMetaTags = Etn.execute("select meta_name, group_concat(content order by langue_id) as contents from products_meta_tags where product_id = "+escape.cote(id)+" group by meta_name");

	}
	else
	{
		qSeo = "select cd.langue_id, "
		+" concat(concat_ws('/', nullif(cd.folder_name,''), nullif(fv.concat_path,'')),'/')  as folders_prefix_path"
		+" from catalog_descriptions cd "
		+" left join products_folders_lang_path fv on fv.langue_id = cd.langue_id and fv.folder_id= "+escape.cote(folderId)
		+" and fv.site_id = "+escape.cote(selectedsiteid)
		+" where cd.catalog_id ="+escape.cote(cid);
	}
	
	System.out.println("---------- ^^^^^^^^^^^^^^^^^^^^ " + qSeo);
    Set rsSeo = Etn.execute(qSeo);

    JSONArray metaTags = new JSONArray();
    while(rsMetaTags != null && rsMetaTags.next()){
        JSONObject metaObj = new JSONObject();
        JSONArray metaContents = new JSONArray();

        for(String content : rsMetaTags.value("contents").split(",")){
            metaContents.put(content);
        }
        metaObj.put("metaName",rsMetaTags.value("meta_name"));
        metaObj.put("contents",metaContents);
        metaTags.put(metaObj);
    }
%>
<!-- Product SEO Information -->

<div class="card mb-2">
    <div class="p-0 card-header btn-group bg-secondary d-flex" role="group" aria-label="Basic example">
        <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#collapseSeoInfo" role="button" aria-expanded="false" aria-controls="collapseSeoInfo" style="padding:0.75rem 1.25rem;color:#3c4b64"><strong>SEO Information</strong></button>
        <button id="savemenuinfobtn" type="button" class="btn btn-primary" onclick="onsave()">Save</button>
    </div>
    <%

        for(Language curLang : langsList ){
            String curLangId = curLang.getLanguageId();
            Set rsCatalogDesc =  Etn.execute("select * From catalog_descriptions where catalog_id = "+escape.cote(cid) + " and langue_id = " + escape.cote(curLangId));
            String _catalogFolderName = "";
            if(rsCatalogDesc.next()) _catalogFolderName = parseNull(rsCatalogDesc.value("folder_name"));
            _catalogFolderName = com.etn.asimina.util.UrlHelper.removeSpecialCharacters(com.etn.asimina.util.UrlHelper.removeAccents(_catalogFolderName));

            out.write(String.format("<input type='hidden' name='ignore' id='catalog_lang_%s_folder_name' value='%s' >",curLangId, escapeCoteValue(_catalogFolderName)));
            out.write(String.format("<input type='hidden' name='ignore' id='catalog_lang_%s_heading' value='%s' >",curLangId, escapeCoteValue(parseNull(rscat.value("lang_"+curLangId+"_heading")))) );
        }
    %>

    <div class="collapse border-0 " id="collapseSeoInfo">
        <div class="card-body">
            <div class="form-group row">
                <label class="col-sm-3 col-form-label">Title</label>
                <div class="col-sm-9">
                    <%=UIHelper.getLangInputsRowWise(langsList,"description_seo_title_lang_%s","description_seo_title_lang_%s","seo_title",rsSeo)%>
                </div>
            </div>

            <div class="form-group row">
                <label class="col-sm-3 col-form-label">Path</label>
                <div class="col-sm-9">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <%=UIHelper.getLangClosedTagElements(langsList,"span","folders_prefix_path_lang_%s","folders_prefix_path_lang_%s","folders_prefix_path",rsSeo," input-group-text " )%>
                        </div>
                           <%=UIHelper.getLangInputsRowWise(langsList,"description_page_path_lang_%s","description_page_path_lang_%s","page_path",rsSeo, " page_path ")%>
                        <div class="input-group-append">
                            <span class="input-group-text">.html</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-group row">
                <label class="col-sm-3 col-form-label">Canonical URL</label>
                <div class="col-sm-9">
                    <%=UIHelper.getLangInputsRowWise(langsList,"description_seo_canonical_url_lang_%s","description_seo_canonical_url_lang_%s","seo_canonical_url",rsSeo)%>
                </div>
            </div>

            <div class="form-group row">
                <label class="col-sm-3 col-form-label">SEO description</label>
                <div class="col-sm-9">
                    <div class="input-group mb-3">
                        <%=UIHelper.getLangInputsRowWise(langsList,"description_seo_lang_%s","description_seo_lang_%s","seo",rsSeo, "description_seo")%>
                        <div class="input-group-append">
                            <%=UIHelper.getLangFields(langsList,"<span class='input-group-text rounded-right' id='description_seo_lang_%1$s_count' data-language-id='%1$s'>0</span>")%>
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-group row">
                <label class="col-sm-3 col-form-label">Meta Tags</label>
                <div class="col-sm-9" id="metaTagsMainDiv" >

                </div>
            </div>

            <div class="form-group row" data-language-id = "1" id="meta_tag_button">
                <label class="col-sm-3 col-form-label"></label>
                <div class="col-sm-9">
                    <button type="button" class="btn btn-success addCustomMetaTagButton" onclick="addCustomMetaTag()">Add a meta tag</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    var metaCounts = 0;
    etn.asimina.page.ready(function(e){

        var metaTags = <%=metaTags%>;
        metaTags.forEach(function(value, index){
            addCustomMetaTag(value);
        });

        var showManufacturers = $('#showManufacturers').val() == "1";

        $("input.description_seo").on("input",function(e){
            var langId = $(this).attr("data-language-id");
            if(langId){
                $("#description_seo_lang_" + langId + "_count").text($(this).val().length);
            }
        })
        .trigger("input");

        $('input.page_path').on("input",function(e){
            onPathKeyup(this);
        })
        .on("blur",function(e){
            onPathBlur(this);
        });

        var updateSEOInfo = function(langId)
		{
            var productNameInput = $("#lang_"+langId+"_name");
            var productName = productNameInput.val().trim();

            var title = $("#description_seo_title_lang_"+langId);
            var canonicalUrl = $("#description_seo_canonical_url_lang_"+langId);
            var pagePath = $("#description_page_path_lang_"+langId);

            var catalogHeading = $("#catalog_lang_"+langId+"_heading").val();
			var productId = $("#product_id").val();
			//page path will only be set for a new product ... we don't want to disturb page path once a product is saved
			if(productId == "" && pagePath.length > 0 && productName.length > 0)
			{
				var pathStr = productName;
                if(showManufacturers == "1")
				{
                    var brandName = $("#brand_name");
                    if(brandName.length > 0 && brandName.val().trim().length > 0){
                        pathStr = brandName.val().trim() + " " + pathStr;
                    }
                }

                var productPagePath = "";
                $.each(pathStr.split(" "), function(index, val){
                    if(val == "|"){
                        return true;
                    }
                    productPagePath = productPagePath + " "+ val;
                });
                pagePath.val(productPagePath);
                pagePath.triggerHandler("input");
                pagePath.triggerHandler('blur');

                if(pagePath.val().trim().length >0)
				{
                    canonicalUrl.val(pagePath.val() + ".html");
                }
                else
				{
                    canonicalUrl.val("");
                }
			}

            if(title.length > 0)
			{
                var titleStr = productName;
                if(showManufacturers == "1")
				{
                    var brandName = $("#brand_name");
                    if(brandName.length > 0 && brandName.val().trim().length > 0){
                        titleStr = brandName.val().trim() + " " + titleStr;
                    }
                }

                //add catalog heading and website name to title str
                titleStr = titleStr + " | " + catalogHeading

                if(productName.length == 0){
                    titleStr = "";
                }

                title.val(titleStr);
            }
        };

        $("input.product_name_lang_input").on("change",function(e){
            var langId = $(this).attr("data-language-id");
            updateSEOInfo(langId);

        });

        if(showManufacturers){
            var brandNameInput = $("#brand_name");
            brandNameInput.on("change",function(e){
                var langsList = etn.asimina.langtabs.langs();
                $.each(langsList, function(index, curLang) {
                    updateSEOInfo(curLang.languageId);
                });
            });
        }

        $("textarea.description_summary").on("blur",function(e){
            //console.log('summary change called ');
            //console.log(this);
            var langId = $(this).attr("data-language-id");
            var summaryStr = $(this).val().trim();
            summaryStr = $(summaryStr).text();//remove html from contents
			console.log(summaryStr);
			//we should not update the seo description if description summary is empty ... its an issue where we have set the seo description but summary is empty
			if(summaryStr != '') $("#description_seo_lang_"+langId).val(summaryStr);

        });

    });

    function deleteCustomMetaTag(btn){
        var metaTagEle = $(btn).parent().parent();
        if(metaTagEle.length == 0){
            return false;
        }
        metaTagEle.remove();
    }

   function addCustomMetaTag(metaTag){
        var metaName = "";
        var metaContents = [];

        if(metaTag){
            metaName = metaTag.metaName;
            metaContents =  metaTag.contents;
        }
        metaCounts++;
        var _html ="<div class='form-group row'>"
                +"<div class='col-5 pr-1'>"
                +   "<input type='text' class='form-control' name='meta_name' placeholder='name' value='"+metaName+"' required  >"
                +"</div>"
                +"<div class='col-6 px-1'>";
                <%
                    for (int i = 0; i < langsList.size(); i++) {
                %>
                var content = "";
                if(metaContents[<%=i%>]){
                    content  = metaContents[<%=i%>];
                }
                _html +='<input type="text" class="form-control meta_content"  <%if(i==0){%>  multilingual="true" style="display: block;"<%}else{%> style="display: none;"<%}%> placeholder="content" onchange name="meta_content_lang_<%=i+1%>" value="'+content+'">';
                <%}%>
                _html+="</div>"
                +"<div class='col-1'>"
                +    "<button type='button' class='btn btn-danger' onclick='deleteCustomMetaTag(this)'>x</button>"
                +"</div>"
            +"</div>";
        $('#metaTagsMainDiv').append(_html);
   }
</script>
<!-- Product description -->