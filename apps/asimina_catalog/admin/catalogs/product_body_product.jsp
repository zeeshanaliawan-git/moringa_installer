<%@ include file="product_body_common.jsp"%>

            <!-- container -->
            <div class="animated fadeIn">
                <div>
                    <form name='frm' id='frm' method='post' action='saveproduct.jsp' enctype='multipart/form-data' novalidate>
                        <input type='hidden' name='catalog_id' id="catalogId" value='<%=escapeCoteValue(cid)%>' />
                        <input type='hidden' name='folder_id' id="folderId" value='<%=escapeCoteValue(folderId)%>' />
                        <input type='hidden' name='id' id="product_id" value='<%=getValue(rs, "id")%>' />
                        <input type='hidden' name='lang_tab' id='lang_tab' value='<%=escapeCoteValue(lang_tab)%>' />
                        <input type="hidden" name="ignore" id="isOrangeApp" value='<%=isOrangeApp?"1":"0"%>' />
                        <input type="hidden" name="product_type" id="product_type" value='<%=prodType%>' />
                        <input type="hidden" name="ignore" id="catalogType" value='<%=catalogType%>' />
                        <input type="hidden" name="ignore" id="showManufacturers" value='<%=showManufacturers?"1":"0"%>' />

                        <div class='multilingual-section'>
                            <%@ include file="general_information.jsp" %>
                            <%@ include file="product_shop_parameters.jsp" %>
                            <%-- @ include file="product_parameters.jsp" --%>
                            <%@ include file="product_variant.jsp"%>
                        <%  //if(!"offer".equals(catalogType)){ %>
                                <%@ include file="product_specifications.jsp"%>
                        <%  //}   %>

                            <%@ include file="product_description.jsp"%>
                            <%@ include file="product_seo_info.jsp"%>
                            <input type='hidden' name='deleteimage' id='deleteimage' value='0' />
                        </div>
                    </form>
                </div>
                <div class="row justify-content-end m-t-10"><a href="#" class="arrondi htpage">^ Top of screen ^</a></div>
            </div>
        </main>

        <div class="modal fade" style='text-align:center; display:none; clear:both;' id='selectAttribValueImageDialog'>
            <div class="modal-dialog modal-lg" role="document">
                <div class="modal-content">
                    <div class="modal-header" style='text-align:left'>
                        <h5 class="modal-title">Select Attribute Value Image</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-left">
                        <ul class="imageGalleryList">
                        </ul>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-success submitbutton">Submit</button>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div>
        <div class="modal fade" style='text-align:center; display:none; clear:both;' id='openImageDialog'>
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header" style='text-align:left;padding: 5px 10px;'>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body text-left">
                        <center>
                            <img src="" alt="" style="max-width:100%;border: 1px dotted silver;" />
                        </center>
                    </div>
                </div><!-- /.modal-content -->
            </div><!-- /.modal-dialog -->
        </div>
        <!-- .modal -->
        <div class="modal fade" id='publishdlg' title='Publish' style='display:none; clear:both;'></div>
        <!-- /.modal -->

        <div class="modal" id="urldlg" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="urldlgLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg modal-resize" role="document">
                <div class="modal-content">
                <!-- Modal body -->
                <div class="modal-body">
                    <!-- Insert your content here -->
                </div>
                </div>
            </div>
        </div>

        <div class="modal" id="natureDialog" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="urldlgLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg modal-resize" role="document">
                <div class="modal-content">
                <!-- Modal body -->
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLongTitle">Select Invoice Nature ..</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    
                    <!-- Insert your content here -->
                </div>
                </div>
            </div>
        </div>

    </div>
        <%@ include file="/WEB-INF/include/footer.jsp" %>
    </div>
    <%-- </div> --%>
    <%
      String prodpushid = id;
      String prodpushtype = "product";
    %>
    <%@ include file="../prodpublishloginmultiselect.jsp"%>
    </div>
    <script type="text/javascript">
    var anythingchanged = false;

    var TAX_PRICE_INCLUDED = <%=isPriceTaxIncluded?"true":"false"%>
    var TAX_PERCENTAGE = <%=taxPercentage%>;
    etn.asimina.page.ready(function() {
        window.isOrangeApp = $('#isOrangeApp').val() == "1";

        window.MAX_PRICE_COUNT = 2;

        $(window).on("load",function(){
            $("input[type=text]").change(function() {
                anythingchanged = true;
            });

            $("select").change(function() {
                anythingchanged = true;
            });

            $("textarea").change(function() {
                anythingchanged = true;
            });

        });


        deleteimage = function() {
            if (!confirm("Are you sure to delete the image?")) return false;
            $("#deleteimage").val("1");
            $("#frm").submit();
        };

        $('#urldlg').modal({
            show: false,
        });
        $('#natureDialog').modal({
            show: false,
        });
        
        showhidetab = function(c) {
            $(".lang1show").hide();
            $(".lang2show").hide();
            $(".lang3show").hide();
            $(".lang4show").hide();
            $(".lang5show").hide();
            $("#tab_lang1show").css("background", "");
            $("#tab_lang2show").css("background", "");
            $("#tab_lang3show").css("background", "");
            $("#tab_lang4show").css("background", "");
            $("#tab_lang5show").css("background", "");
            $("." + c).show();
            $("#tab_" + c).css("background", "#D9EDF7"); //#4FBF87

        };

        showhidetab('<%=lang_tab%>');

        selecttab = function(tab) {
            $("#lang_tab").val(tab);
            showhidetab(tab);
        };

        <%! String callUrl(String u)
            {
                System.out.println("URL "+u);
                java.net.HttpURLConnection con = null;
                try
                {			
                    java.net.URL url = new java.net.URL(u);
                    con = (java.net.HttpURLConnection)url.openConnection();
                    con.setRequestProperty("User-Agent", "Mozilla/5.0");		
                    int responseCode = con.getResponseCode();
                    log(" resp code : " + responseCode );
                    return "true";
                }		
                catch(Exception e)
                {
                    e.printStackTrace();
                }
                return "false";
            } 
        %>

        $('textarea.ckeditor_field').each(function(index, el) {
            var curId = $(el).attr('id');
            
            if(typeof CKEDITOR.instances[curId] == 'undefined'){                
                var ckeditorInstance = CKEDITOR.replace(el);

                ckeditorInstance.config.filebrowserImageBrowseUrl = "<%=GlobalParm.getParm("PAGES_APP_URL")%>admin/imageBrowser.jsp?popup=1";
                ckeditorInstance.config.extraPlugins= ['colorbutton', 'font', 'colordialog', 'justify', 'basicstyles'];
                ckeditorInstance.config.colorButton_enableMore = true;
                ckeditorInstance.config.colorButton_enableAutomatic = false;
                ckeditorInstance.config.allowedContent = true;
                ckeditorInstance.config.colorButton_colors = '000000,FFFFFF,FF7900,F16E00,4BB4E6,50BE87,FFB4E6,A885D8,FFD200,085EBD,0A6E31,FF8AD4,492191,FFB400,B5E8F7,B8EBD6,FFE8F7,D9C2F0,FFF6B6,595959,527EDB,32C832,FFCC00,CD3C14';
                ckeditorInstance.on("instanceReady",function(evt) {
                    //console.log("ckeditor ready "+ evt.editor.name);
                });
                ckeditorInstance.on("blur",function(evt){
                    evt.editor.updateElement();
                    $(evt.editor.element.$).triggerHandler('blur');
                });
            }

            $(el).addClass('d-none'); //keep them hidden
        });

        <% if(id.length() > 0) { %>
        $(".forupdateonly").each(function() { $(this).show(); });
        <% } %>

        validateBeforeSave = function(){
            var isValid = true;
            var invalidObject = null;
            $("#frm input[required],#frm select[required]").each(function(i,o){
                if(!$(o).val()){
                    if(!invalidObject) invalidObject = o;
                    $(o).addClass("is-invalid");
                    isValid = false;
                }else{
                    $(o).removeClass("is-invalid");
                }
            });

            var variantsContainer = $('#collapseVariants');
            //check if variants are enabled for this product
            if(isValid && variantsContainer.length > 0){
                //if yes, at least 1 variant must be defined
                if(variantsContainer.find('.variantHeading').length === 0){
                    isValid = false;
                    bootNotifyError("At least 1 variant must be defined.");
                    invalidObject = $("#addvariant")[0];
                }
            }

            if(isValid){
                var invalidUrlFields = $('#frm input.urlGenInput.is-invalid');
                if(invalidUrlFields.length > 0){
                    isValid = false;
                    invalidObject = invalidUrlFields[0];
                }
            }

            if(invalidObject){
                etn.asimina.util.scrollTo(invalidObject);
            }
            return isValid;
        };

        onsave = function() {

            var sku_ref = $('input[name$="variantSKU"]');
            var skuList = "";
            var is_valid_sku = true;

            sku_ref.each(function(index, cur_sku) {

                var variant_saved  = $('#'+$(this).attr('id')).closest('.collapse').find('input[name="variantSaved"]').val();

                if($(this).next().html().length>0  && $(this).hasClass("is-invalid")){
                    bootNotifyError("SKU "+$(this).val()+" already exists");
                    etn.asimina.util.scrollTo($(this));
                    is_valid_sku  = false;
                }

                var c_sku = $(this).val().trim();
                if(variant_saved == '0'){
                    if(skuList.length>0) skuList += ",";
                    skuList += c_sku;
                }
                if(is_valid_sku){
                    sku_ref.each(function(index, el) {
                        if(c_sku == $(this).val().trim() && $(this).attr("id") != $(cur_sku).attr('id')){
                            bootNotifyError("SKU cannot be same");
                            // $(this).addClass("is-invalid");
                            // $(this).next().html("This SKU already exists");
                            etn.asimina.util.scrollTo($(this));
                            is_valid_sku  = false ;
                            return false;
                        }
                    });
                }
                else return false;
            });

            if(!is_valid_sku) return;

            $.ajax({
                url: 'product_check_sku.jsp',
                data: {
                    "variant_id": "",
                    "sku":skuList}
            })
            .done(function(resp) {
                if(resp){
                    data = JSON.parse(resp);
                    if(data.numberOfRecords > 0){
                        bootNotifyError("SKU cannot be same");
                    }else{
                        setPrices();
                        setInstallmentOptions();

                        //we have to replace src= with something else otherwise XSS filter removes that from ckeditor fields
                        //when saving in db we will revert it back to src= so that image shows up next time
                        $(".ckeditor_field").each(function(){
                            var _id = $(this).attr('id');

                            var editor =  CKEDITOR.instances[_id];
                            editor.updateElement();
                            $(editor.element.$).triggerHandler('change');

                            var focusManager = new CKEDITOR.focusManager( editor );
                            if(focusManager.hasFocus){
                                $(editor.element.$).triggerHandler('blur');
                            }


                            var vl = editor.getData();

                            if(vl.indexOf("src=") > -1)
                            {
                                vl = vl.replace(/src=/gi,"_etnipt_=");
                            }
                            if(vl.indexOf("href=") > -1)
                            {
                                vl = vl.replace(/href=/gi,"_etnhrf_=");
                            }
							if(vl.indexOf("style=") > -1)
							{
								vl = vl.replace(/style=/gi,"_etnstl_=");
							}

                            //set value in hidden alternative field
                            //this hack is needed because ckeditor updates the associated textarea
                            // on form submit event.
                            var hiddenAltField = $("#" + _id + "_ipt");
                            if(hiddenAltField.length == 0){
                                hiddenAltField = $("<input>").attr("type","hidden")
                                .attr("name",$(this).attr("name"));
                                //insert before textarea
                                $(this).before(hiddenAltField);
                            }
                            $(this).attr("name","ignore");

                            hiddenAltField.val(vl);
                        });

                        if(validateBeforeSave()){

                            var _data =  {
                                id : '<%=id%>',
                                type : 'product',
                                catalogId : $('#catalogId').val(),
                                folderId : $('#folderId').val(),
                            };
                            $(".page_path").each(function(){
                                _data[$(this).attr("name")]  =  $(this).val();
                            });

                            $.ajax({
                             url : 'checkpathsuniqueness.jsp',
                             type: 'POST',
                             data: _data,
                             dataType : 'json',
                             success : function(resp)
                             {
                                if(resp.status == 0)
                                {
                                 window.isSavingProduct = true;
                                 $("#frm").submit();
                             }
                             else
                             {
                                 bootNotifyError(resp.msg);

                                 $("#errmsg").html(resp.msg);
                                 $("#errmsg").fadeIn();
                                 $("#errmsg").focus();
                             }
                             },
                             error : function()
                             {
                                alert("Error while communicating with the server");
                             }
                            });
                        }

                    }
                }
            })
            .fail(function() {
                alert("Error in contacting server.");
            })
            .always(function() {

            });
        };

        openimage = function(src) {

            var dialogDiv = $('#openImageDialog');

            dialogDiv.find('img').attr('src', src);
            dialogDiv.modal('show');

            // var prop = "top=0,left=0,resizable=yes, status=no, directories=no, addressbar=no, toolbar=no,";
            // prop += "scrollbars=yes, menubar=no, location=no, statusbar=no" ;
            // prop += ",width=1000" + ",height=800";  //propriete += ",width=" + screen.availWidth + ",height=" + screen.availHeight;
            // var win = window.open("","Image", prop);
            // win.document.write("<html><body style='background:black;height:100%; width:100%;margin: 0;display: table'><div style='display: table-cell;vertical-align:middle; text-align:center'><img src='"+src+"' /></div></body></html>");
        };

       refreshscreen=function()
       {
            var folderUuid = '<%=folderUuid%>';
            var url = "product.jsp?cid=<%=cid%>";
            if(folderUuid.length>0){
                url = url + "&folderId="+folderUuid;
            }
            url = url + "&id=<%=id%>&lang_tab=" + $("#lang_tab").val();
            window.location = url;
       }

        goback = function() {
            if (anythingchanged) {
                if (!confirm("Do you want to discard the changes?")) return;
            }
            window.location = "<%=backto%>";
        };

        <% if(id.length() > 0) { %>
        $(".issaved").show();
        <%}%>

        configureurl = function(urltype) {
            $("#urldlg").html("<div style='color:red'>Loading .....</div>");
            $('#urldlg').modal('show');

            $.ajax({
                url: '../shopurl.jsp',
                type: 'POST',
                data: { id: '<%=id%>', urltype: urltype, catalog: 'products' },
                success: function(resp) {
                    $("#urldlg").html(resp);
                },
                error: function() {
                    alert("Error while communicating with the server");
                }
            });
        };


    });

    etn.asimina.page.ready(function() {

        if ($('#invoice_nature').val() === '') {
            clearNature();
        }

        initPrices();

        initAttributeValues();
        initInstallmentOptions();
        initImageGallery();


        $('#installmentOptionsList').popover({
            selector: 'textarea.infoText',
            content: "Use following <strong>&lt;...&gt;</strong> placeholders in text to output corresponding values dynamically<br>" +
                " - &lt;amount&gt;<br>- &lt;duration&gt;<br>- &lt;durationUnit&gt;" +
                "<br>- &lt;discountAmount&gt;<br>- &lt;discountDuration&gt;<br>- &lt;discountStartDate&gt;<br>- &lt;discountEndDate&gt;<br>- &lt;offerName&gt;",
            trigger: 'focus',
            container: 'body',
            html: true
        });

        $('#collapsegallery').on('shown.bs.collapse', function() {
            adjustImageGallery();
        });

        var imageGalleryList = $('#selectAttribValueImageDialog .imageGalleryList:first');
        imageGalleryList.on('click', 'li', function(event) {
            imageGalleryList.find('li').removeClass('selected-item');
            $(this).addClass('selected-item');
        });

        $('#selectAttribValueImageDialog').on('shown.bs.modal', function() {
            adjustImageGallery(imageGalleryList);
        });
    });


    function setNature(natureVal) {
        if (natureVal != "") {
            $('#invoice_nature').val(natureVal);
            $('#invoice_nature_value').text(natureVal)
                .css('font-style', '').css('color', '');
            $('#clearNatureBtn').show();
            $('#natureDialog').modal('hide');
        }
    }

    function clearNature() {
        $('#invoice_nature').val('');
        $('#invoice_nature_value').text('catalog default')
            .css('font-style', 'italic').css('color', 'gray');
        $('#clearNatureBtn').hide();
    }

    function showHideNatureChilds(familyCount) {
        var _hidden = $("#genre_is_hidden_" + familyCount).val();
        if (_hidden === '0') {
            $(".genre_childs_" + familyCount).hide();
            $("#genre_expand_" + familyCount).hide();
            $("#genre_collapse_" + familyCount).show();
            $("#genre_is_hidden_" + familyCount).val("1");
        } else {
            $(".genre_childs_" + familyCount).show();
            $("#genre_collapse_" + familyCount).hide();
            $("#genre_expand_" + familyCount).show();
            $("#genre_is_hidden_" + familyCount).val("0");
        }
    }

    function onChangePriceValue(input) {
        input = $(input);
        var li = $(input).parents("li:first");

        var price = parseFloat(input.val());
        if (!isNaN(price)) {

            li.find('.tax_price').each(function(i, ele) {

                var taxPriceValue = 0.0;

                var taxPerc = TAX_PERCENTAGE;

                if (typeof taxPerc != 'undefined') {
                    taxPerc = parseFloat(taxPerc);
                    if (isNaN(taxPerc)) {
                        taxPerc = 1.0;
                    }
                } else {
                    taxPerc = 1.0;
                }

                if (TAX_PRICE_INCLUDED) {
                    taxPriceValue = price / (1 + (taxPerc / 100.0));
                } else {
                    taxPriceValue = price * (1 + (taxPerc / 100.0));
                }

                $(ele).find('.tax_price_value').text(taxPriceValue.toFixed(2));

            });

        }
    }

    function getAmountAndSymbol(combined) {
        if (combined.charAt(0) === '%') {
            // %+12.3 , %-12.3
            return [combined.substring(0, 2), combined.substring(2)];
        } else {
            // +12.3,-12.3
            return [combined.substring(0, 1), combined.substring(1)];
        }
    }

    function addAttributeValue(attribId,catalogValueType,attribValueId, attribValue, attribIsDefault,smallText,color) {
        var li = $('#attribValueTemplateList li:first').clone(true);
        var contentList = $('#attributeValuesList_' + attribId);

        contentList.append(li);
        li.attr('attrib-id', attribId);

        var attribIsDefaultRadio = false;

        if (typeof attribValueId !== 'undefined') {


            // var priceDiffSymbol = attribPriceDiff.charAt(0);

            li.find('input,select').each(function(index, el) {
                var name = $(el).attr('name');
                var val = '';

                if (name === 'attribute_value_id') {
                    val = attribValueId;
                } else if (name === 'attribute_value') {
                    val = attribValue;
                } else if (name === 'attribute_is_default') {
                    val = attribIsDefault;
                    attribIsDefaultRadio = (attribIsDefault == '1');
                }else if(name === "attribute_small_text"){
                    val = smallText;
                }else if(name === "attribute_color"){
                    val = color;
                }
                $(el).val(val);
            });

        }

        li.find("input.attribute_color").colorpicker();

        li.find('input,select').each(function(index, el) {
            $(el).attr('name', $(el).attr('name') + "_" + attribId);
        });

        li.find('input.attribute_is_default_radio').prop('checked', attribIsDefaultRadio).trigger('onchange');

        if("color" === catalogValueType){
            li.find("span.attribute_color_span").show();
        }else{

        }
        checkAttribIsDefault(attribId);
    }

    function setAttribDefault(radioInput) {
        radioInput = $(radioInput);
        //$('input[name='+radioInput.attr('name')+']').prop('checked',false);
        var name = radioInput.attr('name');
        name = name.replace("_radio", "");
        $('input[name=' + name + ']').val("0");

        radioInput.parent().find('input[name=' + name + ']').val("1");
    }

    function checkAttribIsDefault(attribId) {
        var isDefault = false;
        $('input[name=attribute_is_default_radio_' + attribId + ']').each(function(index, el) {
            if ($(el).prop('checked')) {
                isDefault = true;
            }
        });

        if (!isDefault) {
            $('input[name=attribute_is_default_radio_' + attribId + ']:first').trigger('click');
        }
    }

    function attributeChanged(input) {
        var li = $(input).parents('li:first');
        etn.asimina.variants.updateCatalogAttributeValues($(li).attr("attrib-id"));
    }

    function attributeMoveUp(button) {
        var li = $(button).parents('li:first');
        li.insertBefore(li.prev());
        etn.asimina.variants.updateCatalogAttributeValues($(li).attr("attrib-id"));
    }

    function attributeMoveDown(button) {
        var li = $(button).parents('li:first');
        li.insertAfter(li.next());
        etn.asimina.variants.updateCatalogAttributeValues($(li).attr("attrib-id"));
    }

    function attributeDelete(button) {
        var li = $(button).parents('li:first');

        var id = li.find('input.attribute_value_id:first').val();
        var attribId = li.attr('attrib-id');
        var msg = "This is a saved value. Are you sure ? "

        if (parseInt(id) > 0) {
            if (confirm(msg)) {
                var deletedIds = $('#attribute_values_deleted');
                deletedIds.val(deletedIds.val() + id + ',');
                li.remove();
                checkAttribIsDefault(attribId);
            }
        } else {
            li.remove();
            checkAttribIsDefault(attribId);
        }
        etn.asimina.variants.updateCatalogAttributeValues(attribId);
    }

    function initAttributeValues() {
        <%
            if(catAttributeValuesRs != null)
      {
        catAttributeValuesRs.moveFirst();

        while(catAttributeValuesRs.next()){
          String attribId = catAttributeValuesRs.value("cat_attrib_id");

          String attribValueId = catAttributeValuesRs.value("id");
          String attribValue = catAttributeValuesRs.value("attribute_value");
          String attribIsDefault = catAttributeValuesRs.value("is_default");

          String str = "addAttributeValue("
                  + escapeDblCote(attribId) + ", "
                  + escapeDblCote(catAttributeValuesRs.value("value_type")) + ","
                  + escapeDblCote(attribValueId) + ", "
                  + escapeDblCote(attribValue) + ", "
                  + escapeDblCote(attribIsDefault) + ","
                  + escapeDblCote(catAttributeValuesRs.value("small_text")) + ","
                  + escapeDblCote(catAttributeValuesRs.value("color"))
                  + ");\n" ;

          out.write(str);
        }

      }
    %>
    }

    function selectAttribValueImage(btn) {
        var attribLi = $(btn).parents('li');

        var attribValueImageEle = attribLi.find('input.attribute_value_image');

        var curImageName = attribValueImageEle.val();

        var dialogDiv = $('#selectAttribValueImageDialog');

        var imagesList = dialogDiv.find('.imageGalleryList:first');
        imagesList.html('');

        var addAttributeImageItem = function(imageId, imageName, imageLabel, imageUrl) {

            var htmlStr = '<center><input type="hidden" name="ignore" class="imageId" value="' + imageId + '"> ' +
                '<input type="hidden" name="ignore" class="imageName" value="' + imageName + '"> ' +
                ' <span style="font-weight: bold;">' + imageLabel + '</span></center>';
            // if(imageUrl.length > 0){
            htmlStr += '<br><center><img class="imageFileName"  src="' + imageUrl + '" style=""></center>';
            // }

            var li = $('<li>');
            li.addClass('image-gallery-item').html(htmlStr);
            imagesList.append(li);

            if (curImageName === imageName) {
                li.addClass('selected-item');
            }
        };

        addAttributeImageItem('', '', 'None', '')

        var imageGalleryList = $('#imageGalleryList li.image-gallery-item');
        imageGalleryList.each(function(index, li) {
            li = $(li);
            var imageId = li.find('.imageId').val();
            var imageName = li.find('.imageName').val();
            var imageLabel = li.find('.imageLabel').text();
            var imageUrl = li.find('.imageFileName').attr('src');
            addAttributeImageItem(imageId, imageName, imageLabel, imageUrl);
        });

        var onSelectImageFunc = function() {

            var selectedItem = imagesList.find('.selected-item:first');
            if (selectedItem.length > 0) {
                var imageName = selectedItem.find('.imageName').val();
                var imageUrl = selectedItem.find('.imageFileName').attr('src');

                attribValueImageEle.val(imageName);
                attribLi.find('img.attribute_value_image').attr('src', imageUrl).show();

                if (imageUrl === '') {
                    attribLi.find('img.attribute_value_image').hide();
                }
            }
            dialogDiv.modal('hide');
        }

        dialogDiv.find('.submitbutton').off('click').click(onSelectImageFunc);

        dialogDiv.modal('show');
    }

    function validateFileUpload(input) {
        var MAX_PHOTO_SIZE = 100 * 1024; //100 KB , in bytes
        var numFiles = input.get(0).files.length;
        var errorMsg = "";
        if (numFiles > 0) {
            var file = input.get(0).files[0];
            var fileName = file.name;
            var fileType = fileName.substring(fileName.lastIndexOf('.') + 1);

            if (numFiles > 1) {
                errorMsg = "Error: Cannot upload more than 1 file. Please select only 1 file.";
            } else if (!isvalidimage(input.val())) {
                errorMsg = "Error: Unsupported file type. Please select a valid image file";
            } else if (file.size > MAX_PHOTO_SIZE) {
                errorMsg = "Error: File size cannot be more than 100 KB. Ideally it shoudl be 25x25 pixel.";
            }

        } else {
            errorMsg = "Error: No file selected.";
        }

        return errorMsg;
    }

    function getAttributesAndValues() {
        var retArray = [];
        $('.attribValueRow').each(function(index, el) {
            try {
                var attribId = $(el).data('attrib-id');
                var attribName = $(el).data('attrib-name');

                if (attribId != null && attribId > 0) {
                    var attrib = {};

                    attrib.id = attribId;
                    attrib.name = attribName;
                    attrib.values = [];
                    $(el).find('.attributeValuesList li').each(function(index, li) {
                        try {
                            var attribValueId = $(li).find('input.attribute_value_id:first').val();
                            if (parseInt(attribValueId) > 0) {
                                var attribValue = $(li).find('input.attribute_value:first').val();
                                attrib.values.push({
                                    id: attribValueId,
                                    value: attribValue
                                });
                            }
                        } catch (ex) {

                        }

                    });

                    retArray.push(attrib);
                }
            } catch (ex) {

            }

        });

        return retArray;
    }

    function addPrice(priceObj) {

        if ($('#pricesList li').length >= MAX_PRICE_COUNT) {
            var msg = "Cannot add more than '" + MAX_PRICE_COUNT + "' prices.";
            alert(msg);
            return false;
        }

        var li = $('#priceTemplate li:first').clone(true);

        if (typeof priceObj != 'undefined' &&
            typeof priceObj["price"] != 'undefined') {

            var price = priceObj["price"];
            var visibleTo = priceObj["visibleTo"];
            try {
                if (parseFloat(price) >= 0) {

                    li.find('input.price').val(price);

                    if (visibleTo) {
                        li.find('select.visibleTo').val(visibleTo);
                    }
                }
            } catch (ex) {

            }
        }

        $('#pricesList').append(li);
        li.find('input.price').trigger('change');
    }

    function removePrice(ele) {
        /*    if( $('#pricesList li').length <= 1){
              var msg = "Cannot remove. There must be atleast 1 price";
              alert(msg);
              return false;
            }
            else{*/
        $(ele).parent('li:first').remove();
        //}
    }


    function setPrices() {

        var pricesList = [];

        var keyMap = [];
        $('#pricesList li').each(function(index, el) {

            var price = $(el).find('input.price:first').val().trim();
            var visibleTo = $(el).find('.visibleTo:first').val();
            var uniqueKey = visibleTo
            try {
                if (parseFloat(price) >= 0 &&
                    typeof keyMap[uniqueKey] === 'undefined') {

                    pricesList.push({
                        "price": price,
                        "visibleTo": visibleTo
                    });

                    keyMap[uniqueKey] = true;
                }

            } catch (ex) {
                //skip
            }


        });

        $('#price').val(JSON.stringify(pricesList));
    }

    function initPrices() {

        /*  var pricesStr = $('#price').val().trim();

          try{

            var pricesList = null;
            try{
              pricesList = JSON.parse(pricesStr);
            }
            catch(ex){ }


            if( $.isArray(pricesList) && pricesList.length > 0 ){

              for (var i = 0; i < pricesList.length; i++) {
                var priceObj = pricesList[i];

                addPrice(priceObj);
              }
            }
            else{
              //set a default price
              //addPrice();
            }


          }
          catch(ex){
            //do nothing
          }*/
    }


    //installment options
    function addInstallmentOption(pObj) {
        var li = $('#installmentOptionTemplate li:first').clone(true);

        if (typeof pObj != 'undefined' &&
            typeof pObj["id"] != 'undefined' &&
            typeof pObj["name"] != 'undefined' &&
            typeof pObj["description"] != 'undefined' &&
            typeof pObj["depositAmount"] != 'undefined' &&
            typeof pObj["installmentAmount"] != 'undefined' &&
            typeof pObj["durationValue"] != 'undefined' &&
            typeof pObj["durationUnit"] != 'undefined'
        ) {

            try {
                var newOptionalProps = {
                    visibleTo: "all",
                    showUiBanner: "0",
                    depositLabel: "",
                    discountInstallmentAmount: "0.0",
                    discountDurationValue: "0",
                    discountStartDate: "",
                    discountEndDate: "",
                    infoTitle: "",
                    infoText: "",
                    discountInfoTitle: "",
                    discountInfoText: "",

                };

                pObj = $.extend({}, newOptionalProps, pObj);

                li.find('.installOptId').val(pObj["id"]);

                li.find('.installOptVisibleTo').val(pObj["visibleTo"]);
                li.find('.installOptShowUiBanner').val(pObj["showUiBanner"]);

                li.find('.installOptName').val(pObj["name"]);
                li.find('.installOptDescription').val(pObj["description"]);

                li.find('.installOptDepositAmount').val(pObj["depositAmount"]);
                li.find('.installOptDepositLabel').val(pObj["depositLabel"]);

                li.find('.installOptInstallmentAmount').val(pObj["installmentAmount"]);
                li.find('.installOptDurationValue').val(pObj["durationValue"]);
                li.find('.installOptDurationUnit').val(pObj["durationUnit"]);

                li.find('.installOptDiscountInstallmentAmount').val(pObj["discountInstallmentAmount"]);
                li.find('.installOptDiscountDurationValue').val(pObj["discountDurationValue"]);

                li.find('.installOptDiscountStartDate').val(pObj["discountStartDate"]);
                li.find('.installOptDiscountEndDate').val(pObj["discountEndDate"]);

                li.find('.installOptInfoTitle').val(pObj["infoTitle"]);
                li.find('.installOptInfoText').val(pObj["infoText"]);

                li.find('.installOptDiscountInfoTitle').val(pObj["discountInfoTitle"]);
                li.find('.installOptDiscountInfoText').val(pObj["discountInfoText"]);

            } catch (ex) {

            }
        } else {
            //set unique id
            var installId = "";
            var flag = true;
            while (flag) {
                flag = false;
                installId = "" + Math.floor(Math.random() * 1000000);
                //if already exist get random again
                $('#installmentOptionsList .installOptId').each(function(index, el) {
                    if ($(el).val() == installId) {
                        flag = true;
                    }
                });
            }

            li.find('.installOptId').val(installId);

        }

        flatpickr(".startDate, .endDate", {
            dateFormat: "Y-m-d"
        });


        $('#installmentOptionsList').append(li);
        li.find('.installOptDurationValue').trigger('change');
        li.find('.installOptDurationUnit').trigger('change');
    }



    function setInstallmentOptions() {

        var installmentOptionsList = [];

        $('#installmentOptionsList li').each(function(index, el) {

            var installId = $(el).find('.installOptId:first').val().trim();

            var visibleTo = $(el).find('.installOptVisibleTo:first').val().trim();
            var showUiBanner = $(el).find('.installOptShowUiBanner:first').val().trim();

            var name = $(el).find('.installOptName:first').val().trim();
            var description = $(el).find('.installOptDescription:first').val().trim();

            var depositAmount = $(el).find('.installOptDepositAmount:first').val().trim();
            var depositLabel = $(el).find('.installOptDepositLabel:first').val().trim();

            var installmentAmount = $(el).find('.installOptInstallmentAmount:first').val().trim();
            var durationValue = $(el).find('.installOptDurationValue:first').val().trim();
            var durationUnit = $(el).find('.installOptDurationUnit:first').val().trim();

            var discountInstallmentAmount = $(el).find('.installOptDiscountInstallmentAmount:first').val().trim();
            var discountDurationValue = $(el).find('.installOptDiscountDurationValue:first').val().trim();

            var discountStartDate = $(el).find('.installOptDiscountStartDate:first').val().trim();
            var discountEndDate = $(el).find('.installOptDiscountEndDate:first').val().trim();

            var infoTitle = $(el).find('.installOptInfoTitle:first').val().trim();
            var infoText = $(el).find('.installOptInfoText:first').val().trim();

            var discountInfoTitle = $(el).find('.installOptDiscountInfoTitle:first').val().trim();
            var discountInfoText = $(el).find('.installOptDiscountInfoText:first').val().trim();

            try {
                //condition changed by umair on 3 march 2017. We have such cases for orange so we are allowing this here
                //        if( name.length > 0 && parseFloat( depositAmount ) > 0 && parseFloat( installmentAmount ) > 0 && parseInt(durationValue) > 0 )

                if (name.length > 0) {
                    installmentOptionsList.push({
                        "id": installId,

                        "visibleTo": visibleTo,
                        "showUiBanner": showUiBanner,

                        "name": name,
                        "description": description,

                        "depositAmount": depositAmount,
                        "depositLabel": depositLabel,
                        "installmentAmount": installmentAmount,
                        "durationValue": durationValue,
                        "durationUnit": durationUnit,

                        "discountInstallmentAmount": discountInstallmentAmount,
                        "discountDurationValue": discountDurationValue,
                        "discountStartDate": discountStartDate,
                        "discountEndDate": discountEndDate,

                        "infoTitle": infoTitle,
                        "infoText": infoText,
                        "discountInfoTitle": discountInfoTitle,
                        "discountInfoText": discountInfoText
                    });
                }

            } catch (ex) {
                //skip
            }


        });

        $('#installment_options').val(JSON.stringify(installmentOptionsList));

    }

    function initInstallmentOptions() {
        /*
            var installOptionsStr = $('#installment_options').val().trim();

            try{

              var installOptionsList = JSON.parse(installOptionsStr);

              if( $.isArray(installOptionsList) ){

                for (var i = 0; i < installOptionsList.length; i++) {
                  var pObj = installOptionsList[i];

                  addInstallmentOption(pObj);
                }
              }


            }
            catch(ex){
              //do nothing
            }
            */
    }

    function updateDurationUnitText(field) {
        field = $(field);
        var parent = field.parents('li:first');

        parent.find('.durationUnitText').html(field.val() + 's');
    }

    function onChangeInstallDuration(field) {
        //check that discount duration is not more than (actual) duration

        var parent = $(field).parents('li:first');
        duration = parent.find('.installOptDurationValue:first').val();
        discountDuration = parent.find('.installOptDiscountDurationValue:first').val();

        duration = isFinite(parseInt(duration)) ? parseInt(duration) : 0;
        discountDuration = isFinite(parseInt(discountDuration)) ? parseInt(discountDuration) : 0;

        if (discountDuration > duration) {
            discountDuration = duration;
        }

        parent.find('.installOptDurationValue:first').val(duration);
        parent.find('.installOptDiscountDurationValue:first').val(discountDuration);

    }

    //image gallery functions
    var IMAGE_PATH_PREFIX = '<%=GlobalParm.getParm("PRODUCTS_IMG_PATH")%>';
    var PROD_IMAGE_PATH_PREFIX = '<%=GlobalParm.getParm("PROD_PRODUCTS_IMG_PATH")%>';

    function initImageGallery() {
        <%
    Set imageRs = Etn.execute("SELECT * FROM "+dbname+"product_images WHERE product_id = "+escape.cote(id)+" ORDER BY sort_order ASC");
    while(imageRs.next()){
      if(bIsProd) out.write("addImageItemProd('"+escapeCoteValue(imageRs.value("id"))+"','"+escapeCoteValue(imageRs.value("image_file_name"))+"','"+escapeCoteValue(imageRs.value("image_label"))+"')\n");
      else out.write("addImageItem('"+escapeCoteValue(imageRs.value("id"))+"','"+escapeCoteValue(imageRs.value("image_file_name"))+"','"+escapeCoteValue(imageRs.value("image_label"))+"')\n");
    }
  %>
    }

    function adjustImageGallery(list) {

        if (typeof list === 'undefined') {
            list = $('#imageGalleryList')
        }

        var li = list.find('li:first');

        if (li.length === 0) return;
        var img = li.find('img.imageFileName');

        var width = li.width();
        list.find('li').height(width);

        var liTop = li.position().top;
        var imgTop = img.position().top;
        var maxHeight = width - Math.abs(liTop - imgTop) - 8;

        list.find('li img.imageFileName').css('max-height', maxHeight);
    }

    function addImageItemProd(imageId, imageFileName, imageLabel) {

        var li = "<li class='image-gallery-item'><center><span class='imageLabel' style='font-weight: bold;'>" + imageLabel + "</span><br><img class='imageFileName' src='" + PROD_IMAGE_PATH_PREFIX + imageFileName + "' ></center></li>";
        $('#imageGalleryList').append(li);
        adjustImageGallery();
    }

    function addImageItem(imageId, imageFileName, imageLabel) {

        var li = $('#imageGalleryItemTemplate li:first').clone(true);

        li.find('input.imageId').val(imageId);
        li.find('input.imageName').val(imageFileName);
        li.find('img.imageFileName').attr('src', IMAGE_PATH_PREFIX + imageFileName);
        li.find('.imageLabel').text(imageLabel);

        $('#imageGalleryList').append(li);
        adjustImageGallery();
    }


    //-------------------------
    </script>
</body>

</html>