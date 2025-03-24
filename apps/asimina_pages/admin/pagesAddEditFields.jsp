<!-- to be included only -->
<div class="card mb-2">
    <div class="card-header bg-secondary" data-toggle="collapse" href="#globalInfoCollapse" role="button" aria-expanded="true" aria-controls="globalInfoCollapse">
        <strong><%=_pageFirstSectionHeading%></strong>
    </div>
    <div class="collapse show pt-3" id="globalInfoCollapse">
        <div class="card-body">
            <div class="form-group row pageFieldRowName">
                <label class="col-sm-3 col-form-label">Page name</label>
                <div class="col-sm-9">
                    <input type="text" class="form-control" name="name" value=""
                            maxlength="300" required="required" onchange="onChangePageName(this)">
                    <div class="invalid-feedback">
                        Cannot be empty
                    </div>
                </div>
            </div>

            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">Path</label>
                <div class="col-sm-9">
                    <div class="input-group">
                        <div class="input-group-prepend pagePathPrefixDiv">
                            <span  class="input-group-text">/</span>
                        </div>

                        <input type="text" class="form-control" name="path" value=""
                            maxlength="500" required="required"
                            onkeyup="onPathKeyup(this)"
                            onblur="onPathBlur(this)">

                        <div class="input-group-append">
                            <span class="input-group-text rounded-right">.html</span>
                        </div>
                        <div class="invalid-feedback">
                            Cannot be empty
                        </div>
                    </div>
                </div>

            </div>

            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">Canonical URL</label>
                <div class="col-sm-9">
                    <input type="text" class="form-control" name="canonical_url" value=""  maxlength="500">
                </div>
            </div>

            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">Variant</label>
                <div class="col-sm-9">
                    <select class="custom-select" name="variant" >
                        <option value="all">All</option>
                        <option value="anonymous">Anonymous</option>
                        <option value="logged">Logged</option>
                    </select>
                </div>
            </div>

            <div class="form-group row pageFieldRowTemplateId">
                <label  class="col-sm-3 col-form-label">Page template</label>
                <div class="col-sm-9">
                    <select class="custom-select" name="template_id" required="" >
                <%
                    Set ptRs = Etn.execute("SELECT id, name FROM page_templates WHERE site_id = "
                        + escape.cote(getSiteId(session))
                        + " ORDER BY name");
                    while(ptRs.next()){
                        out.write("<option value='"+ptRs.value("id")+"'>"+ptRs.value("name")+"</option>");
                    }
                %>
                    </select>
                </div>
            </div>

            <div class="form-group row pageFieldRowTags">
                <label class="col col-form-label">Tags</label>
                <div class="col-9">
                    <input type="hidden" name="pageTags" value="">
                    <input type="text" <%=(_disableTags?"disabled":"")%> name="pageTagInput" class="form-control tagInputField" value=""
                        placeholder="search and add (by clicking return)">
                </div>
                <div class="tagsDiv form-group col-sm-12 mt-3 <%=(_disableTags?"_secondaryTagsDiv":"pageTagsDiv")%>"></div>
            </div>
        </div>
    </div><!--  collapse -->
</div>

<div class="card mb-2">
    <div class="card-header bg-secondary" data-toggle="collapse" href="#metaTagsCollapse" role="button" aria-expanded="true" aria-controls="metaTagsCollapse">
        <strong>Metatags</strong>
    </div>
    <div class="collapse show" id="metaTagsCollapse">
        <div class="card-body">
            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">Title</label>
                <div class="col-sm-9">
                    <input type="text" class="form-control" name="title" value="" maxlength="500" required="required">
                    <div class="invalid-feedback">
                        Cannot be empty
                    </div>
                </div>
            </div>
            <div class="form-group row pageFieldRowLanguage">
                <label  class="col-sm-3 col-form-label">Language</label>
                <div class="col-sm-9">
                    <select class="custom-select" name="langue_code">
                    <%
                        Set langRs = Etn.execute("SELECT * FROM language ORDER BY langue_id");
                        while(langRs.next()){
                    %>
                        <option value='<%=getValue(langRs,"langue_code")%>'><%=getValue(langRs,"langue")%> - <%=getValue(langRs,"langue_code")%></option>
                    <%  }  %>
                    </select>
                </div>
            </div>

            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">Meta keywords</label>
                <div class="col-sm-9">
                    <input type="text" class="form-control" name="meta_keywords" value="" maxlength="500">
                </div>
            </div>

            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">Meta description</label>
                <div class="col-sm-9">
                    <div class="input-group">
                        <input type="text" class="form-control"
                            name="meta_description" value=""
                            maxlength="500" onkeyup="updateFieldCounter(this)">
                        <div class="input-group-append">
                            <span class="input-group-text fieldCounter rounded-right">0</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">Type</label>
                <div class="col-sm-9">
                    <select class="custom-select" name="social_type" >
                        <option value="website">Website</option>
                        <option value="article">Article</option>
                    </select>
                </div>
            </div>

            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">image</label>
                <div class="col-sm-9">
                    <!-- card -->
                    <div class="card image_card ">
                        <div class="card-body text-center image_body social_image_body">
                            <input type="hidden" name="social_image" value="" class="image_value"
                                onchange="onSocialImageChange(this)">
                            <img class="card-image-top" style="max-width:100px;max-height:100px" src=""
                                onload="onSocialImageChange(this)">
                            <div class="col-12">
                                <span class="social_img_error text-success small"></span>
                            </div>
                        </div>
                        <div class="card-footer image_footer">
                            <div class="form-group row mb-0">
                                <div class="col-6">
                                    <button type="button" class="btn btn-link"
                                        onclick="loadFieldImage(this)">Load Image</button>
                                </div>
                                <div class="col-6">
                                    <button type="button" class="btn btn-link text-danger"
                                        onclick="clearFieldImage(this);clearSocialImgError(this);">Delete Image</button>
                                </div>

                                <div class="col-12 d-none">
                                    <input type="text" name="ignore" value=""
                                            class="image_alt form-control"
                                            placeholder="alt text" maxlength="50">
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- /card -->
                </div>
            </div>
        </div>
    </div><!--  collapse -->
</div>

<div class="card mb-2">
    <div class="card-header bg-secondary" data-toggle="collapse" href="#customMetaTagsCollapse" role="button" aria-expanded="true" aria-controls="customMetaTagsCollapse">
        <strong>Custom Metatags</strong>
    </div>
    <div class="collapse show" id="customMetaTagsCollapse" style="border:none;">
        <div class="card-body">
            <div class="customMetaTagContent mt-3">

            </div>
            <div id="customMetaTagTemplate" class="d-none">
                <div class="form-group row customMetaTagRow">
                    <div class="col-5 pr-1">
                        <input type="text" class="form-control" name="meta_name" placeholder="name">
                    </div>
                    <div class="col-6 px-1">
                        <input type="text" class="form-control" name="meta_content" placeholder="content">
                    </div>
                    <div class="col-1">
                        <button type="button" class="btn btn-danger"
                            onclick="deleteCustomMetaTag(this)">
                            x</button>
                    </div>
                </div>
            </div>
            <div class="form-group row">
                <div class="col text-right">
                    <button type="button" class="btn btn-success addCustomMetaTagButton"
                            onclick="addCustomMetaTag(this)">Add a meta tag</button>
                </div>
            </div>
        </div>
    </div><!--  collapse -->
</div>

<div class="card mb-2">
    <div class="card-header bg-secondary" data-toggle="collapse" href="#dataLayerCollapse" role="button" aria-expanded="true" aria-controls="dataLayerCollapse">
        <strong>Datalayer</strong>
    </div>
    <div class="collapse show pt-3" id="dataLayerCollapse">
        <div class="card-body">
            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">Page type</label>
                <div class="col-sm-9">
                    <input type="text" class="form-control" name="dl_page_type" value="" maxlength="200" >

                </div>
            </div>
            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">Sub level 1</label>
                <div class="col-sm-9">
                    <input type="text" class="form-control" name="dl_sub_level_1" value="" maxlength="200" >

                </div>
            </div>
            <div class="form-group row">
                <label  class="col-sm-3 col-form-label">Sub level 2</label>
                <div class="col-sm-9">
                    <input type="text" class="form-control" name="dl_sub_level_2" value="" maxlength="200" >

                </div>
            </div>
        </div>
    </div><!--  collapse -->
</div>


<!-- obsolete / hidden -->
<button type="button" class=" d-none btn btn-secondary btn-lg btn-block text-left mb-1"
        data-toggle="collapse" href="#socialCollapse" role="button" >
    Social networks
</button>
<div class=" d-none collapse show pt-3" id="socialCollapse">
    <div class="form-group row">
        <label  class="col-sm-3 col-form-label">Title</label>
        <div class="col-sm-9">
            <input type="text" class="form-control" name="social_title" value="">
        </div>
    </div>



    <div class="form-group row">
        <label  class="col-sm-3 col-form-label">Decsription</label>
        <div class="col-sm-9">
            <textarea class="form-control" name="social_description" rows="3"></textarea>
        </div>
    </div>

    <div class="form-group row">
        <label  class="col-sm-3 col-form-label">Twitter message</label>
        <div class="col-sm-9">
             <textarea class="form-control" name="social_twitter_message" rows="3"></textarea>
        </div>
    </div>

    <div class="form-group row">
        <label  class="col-sm-3 col-form-label">Twiter hashtags</label>
        <div class="col-sm-9">
            <input type="text" class="form-control" name="social_twitter_hashtags" value="">
        </div>
    </div>

    <div class="form-group row">
        <label  class="col-sm-3 col-form-label">Email subject</label>
        <div class="col-sm-9">
            <input type="text" class="form-control" name="social_email_subject" value="">
        </div>
    </div>

    <div class="form-group row">
        <label  class="col-sm-3 col-form-label">Email popin title</label>
        <div class="col-sm-9">
            <input type="text" class="form-control" name="social_email_popin_title" value="">
        </div>
    </div>

    <div class="form-group row">
        <label  class="col-sm-3 col-form-label">Email message</label>
        <div class="col-sm-9">
             <textarea class="form-control" name="social_email_message" rows="3"></textarea>
        </div>
    </div>

    <div class="form-group row">
        <label  class="col-sm-3 col-form-label">SMS text</label>
        <div class="col-sm-9">
            <input type="text" class="form-control" name="social_sms_text" value="">
        </div>
    </div>
</div>
<script type="text/javascript">
    function addPageTag(tag, input){

        if( !pageTagExists(tag, input) ){
            input = $(input);
            var pageTagsDiv = input.parent().find(".pageTagsDiv:first");
			
			var _tagpillid = "_tagpill"+tagsDiv.children(".tagButton").length;

            var divMain = $("<div class='tagButton float-left mb-2 pr-2' data-tag_pillid="+_tagpillid+">");
            var button = $("<button type='button' class='btn btn-pill btn-secondary' >");
            var strong = $("<strong class='moringa-orange-color'>X</strong>");
            strong.click(function(e){
                $(this).closest(".tagButton").remove();
            });
            button.append(strong).append("&nbsp;"+tag.label);
            divMain.append(button).append("<input type='hidden' name='pageTag' value='" + tag.id + "'>");

            pageTagsDiv.append(divMain);			

			var _divMain = $("<div class='tagButton float-left mb-2 pr-2 "+_tagpillid+"'>");
			var _button = $("<button type='button' class='btn btn-pill btn-secondary' >");
			_button.append("&nbsp;" + tag.label);
			_divMain.append(_button);

			$("._secondaryTagsDiv").append(_divMain);
			
        }
    }

    function pageTagExists(tag, input){

        input = $(input);
        var pageTagsDiv = input.parent().find(".pageTagsDiv:first");

        var doesTagExist = false;
        pageTagsDiv.find("input[name=pageTag]").each(function(i,ele){
            if($(ele).val() === tag.id){
               doesTagExist = true;
               return false;
            }
        });
        return doesTagExist;
    }

    var MIN_SOCIAL_IMG_WIDTH = 600;
    var MIN_SOCIAL_IMG_HEIGHT = 314;
    function checkSocialImageDimensions(form){

        var img = form.find('.social_image_body img:first');
        var imgErrorEle = form.find('.social_img_error');
        imgErrorEle.removeClass('text-warning');

        if(img.attr('src').trim().length == 0){
            imgErrorEle.text("");
            return true;
        }

        var width = img[0].naturalWidth;
        var height = img[0].naturalHeight;
        var msg = "Current image dimensions: "+ width + " x " + height + ".";
        if(width < MIN_SOCIAL_IMG_WIDTH || height < MIN_SOCIAL_IMG_HEIGHT){
            var msg = "Warning: Image dimension should be minimum "
                    + MIN_SOCIAL_IMG_WIDTH + " x " + MIN_SOCIAL_IMG_HEIGHT
                    +  ". " + msg  + " This image will be scaled to meet minimum dimensions.";
            imgErrorEle.text(msg).addClass('text-warning');
            return true;
        }
        else{
            imgErrorEle.text("");
            return true;
        }
    }

    function onSocialImageChange(inp){
        var form = $(inp).parents("form:first");
        setTimeout(function(){
            checkSocialImageDimensions(form);
        }, 1000);
    }

    function clearSocialImgError(btn){
        var form = $(btn).parents("form:first");
        form.find('.social_img_error').text("");
    }

    function addCustomMetaTag(button, metaObj){
        var form = $(button).parents("form:first");

        var newMetaTag = $($('#customMetaTagTemplate').html());

        newMetaTag.find('[type=text]').attr('required','required');

        if(typeof metaObj != 'undefined'){
            newMetaTag.find('[name=meta_name]').val(metaObj.meta_name);
            newMetaTag.find('[name=meta_content]').val(metaObj.meta_content);
        }

        form.find('.customMetaTagContent').append(newMetaTag);

    }

    function deleteCustomMetaTag(btn){
        var metaTagEle = $(btn).parents('.customMetaTagRow:first');

        if(metaTagEle.length == 0){
            return false;
        }

        metaTagEle.remove();
    }

    function onChangePageName(nameInput){
        nameInput = $(nameInput);
        var form = nameInput.parents('form:first');

        titleInput = form.find('[name=title]');
        if(titleInput.val().trim().length == 0){
            titleInput.val(nameInput.val());
        }
    }

</script>