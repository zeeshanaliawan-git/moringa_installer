<!-- Product attributes -->
<div class="card mb-2">
    <div class="p-0 card-header btn-group bg-secondary d-flex" role="group" >
        <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#product-attributes-collapse" role="button" style="padding:0.75rem 1.25rem;color:#3c4b64">
            <strong>Product attributes</strong>
            <% if(rs == null){%> <span >(add attributes after save)</span> <%}%>
        </button>
        <% if(!bIsProd) { %>
        <button type="button" class="btn btn-success" onclick='addAttribute("selection");showAttribCollapse(this);' <%=(rs==null)?"disabled":""%> style="text-wrap:nowrap">+ Add attribute</button>
        <button type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
        <%}%>
    </div>
    <div class="d-none">
        <input type="hidden" name="attribute_deleted" id="attribute_deleted" value="" />
        <input type="hidden" name="attribute_values_deleted" id="attribute_values_deleted" value="" />
        <!-- templates -->
        <ul id="attribListTemplate" >
            <li class="attribListItem list-group-item" id="" >
                <div class="row">
                    <input type="hidden" name="attribute_id" value="" />
                    <input type="hidden" name="attribute_type" value="" />

                    <div class="col-md ">
                        <label for="" class="justify-content-start" >Name :</label>
                        <input type="text" name="attribute_name" value="" class="form-control w-100" />
                    </div>
                    <div class="col-md ">
                        <label for="" class="justify-content-start">Visible To :</label>
                        <select name="attribute_visible_to" class="custom-select w-100">
                            <option value="all">All</option>
                            <option value="logged_customer">Customers</option>
                            <option value="backoffice">Backoffice</option>
                        </select>
                    </div>
                    <span class="attribute_value_type col-md ">
                        <label for="" class="justify-content-start">Value Type :</label>
                        <select name="attribute_value_type" class="custom-select w-100" onchange="onChangeValueType(this)">
                            <option value="text">Button</option>
                            <option value="color">Color</option>
                            <option value="select">Select</option>
                        </select>
                    </span>
                    <span class="attribute_is_searchable col-md ">
                        Enable Filter? :
                        <input type="checkbox" class="attribute_is_searchable_check" name="ignore"  onclick="updateIsSearchable(this);" value="1"/>
                        <input type="hidden" name="attribute_is_searchable" value="" />
                    </span>
                    <div class="col-md d-flex align-items-end" style="gap:5px">
                        <button type="button" onclick='attributeMoveUp(this)' class="btn btn-default hideFixed">
                            <i class="fa fa-arrow-up" aria-hidden="true"></i>
                        </button>
                        <button type="button" onclick='attributeMoveDown(this)' class="btn btn-default hideFixed">
                            <i class="fa fa-arrow-down" aria-hidden="true"></i>
                        </button>
                        <button type="button" class="btn btn-success addAttribValueBtn" onclick='addAttributeValueBtn(this)' title="Add a value">
                            <i class="fa fa-plus " aria-hidden="true"></i>
                            <span class="sr-only">Add a value</span>
                        </button>
                        <button type="button" onclick='attributeDelete(this)' class='btn btn-danger hideFixed'>
                            <i class="fa fa-times " aria-hidden="true"></i>
                        </button>
                    </div>
                </div>
                <div class="row attribValueRow">
                    <div class="col border-top pt-2 mt-2">
                        <ul class="list-group attribValueList w-100" >
                        </ul>
                    </div>
                </div>
            </li>
        </ul>
        <ul id="attribValueListTemplate">
            <li class="list-group-item list-group-item-secondary">
                <input type="hidden" class="attribute_value_id" name="attribute_value_id" value="" />
                Name:
                <input type="text" class="form-control attribute_value" name="attribute_value" value=""/>
                Small text:
                <input type="text" class="form-control attribute_small_text" name="attribute_small_text" value=""/>
                <span class="attribute_color_span">
                    Color:
                    <input type="text" class="form-control attribute_color" name="attribute_color" value="" style="width: 100px;" />
                </span>
                <button type="button" onclick='attributeMoveUp(this)' class="btn btn-default"><i class="fa fa-arrow-up" aria-hidden="true"></i></button>
                <button type="button" onclick='attributeMoveDown(this)' class="btn btn-default"><i class="fa fa-arrow-down" aria-hidden="true"></i></button>
                 <button type="button" onclick='attributeDelete(this,true)' class='btn btn-default text-danger'><i class="fa fa-times" aria-hidden="true"></i></button>
            </li>
        </ul>
    </div>
    <div class="collapse border-0 form-inline" id="product-attributes-collapse">
        <div class="card-body">
            <ul id="productAttributesList" class="list-group w-100" >
            </ul>
        </div>
    </div>
</div>
<!-- /Product attributes -->
<!-- Product specifications -->
<div class="card mb-2">
    <div class="p-0 card-header btn-group bg-secondary d-flex" role="group" >
        <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#product-specifications-collapse" role="button" aria-expanded="false" title="catalog_attribute" style="padding:0.75rem 1.25rem;color:#3c4b64">
            <strong>Product specifications</strong>
            (for description)
        </button>
        <% if(!bIsProd) { %>
        <button type="button" class="btn btn-success" onclick='addAttribute("specs");showAttribCollapse(this);' style="text-wrap:nowrap">+ Add attribute</button>
        <button type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
        <%}%>
    </div>
    <div class="border-0 collapse form-inline" id="product-specifications-collapse">
        <div class="card-body">
            <ul id="productAttributesListSpecs" class="list-group w-100" >
            </ul>
        </div>
    </div>
</div>
<!-- /Product specifications -->

<script type="text/javascript">

<% if(!bIsProd) { %>

    function initAttributes(){
        <%
            if(attribRs != null){

                attribRs.moveFirst();
                while(attribRs.next()){
                    String attribId = attribRs.value("cat_attrib_id");

                    String funcStr = "addAttribute("
                          + escapeDblCote(attribRs.value("type")) + ", "
                          + escapeDblCote(attribRs.value("cat_attrib_id")) + ", "
                          + escapeDblCote(attribRs.value("name")) + ", "
                          + escapeDblCote(attribRs.value("visible_to")) + ", "
                          + escapeDblCote(attribRs.value("value_type")) + ", "
                          + escapeDblCote(attribRs.value("is_searchable")) + ", "
                          + escapeDblCote(attribRs.value("is_fixed"))
                          + ");\n" ;

                    out.write(funcStr);
                    Set crAttribValueRs = Etn.execute("SELECT * FROM catalog_attribute_values WHERE cat_attrib_id = " + escape.cote(attribId) + " ORDER BY sort_order, id");
                    while(crAttribValueRs.next()){
                        funcStr = "addAttributeValue("
                          + escapeDblCote(crAttribValueRs.value("cat_attrib_id")) + ", "
                          + escapeDblCote(crAttribValueRs.value("id")) + ", "
                          + escapeDblCote(crAttribValueRs.value("attribute_value")) + ", "
                          + escapeDblCote(crAttribValueRs.value("small_text")) + ", "
                          + escapeDblCote(crAttribValueRs.value("color"))
                          + ");\n" ;

                          out.write(funcStr);
                    }
                }
                attribRs2.moveFirst();
                while(attribRs2.next()){
                    String attribId = attribRs2.value("cat_attrib_id");

                    String funcStr = "addAttribute("
                          + escapeDblCote(attribRs2.value("type")) + ", "
                          + escapeDblCote(attribRs2.value("cat_attrib_id")) + ", "
                          + escapeDblCote(attribRs2.value("name")) + ", "
                          + escapeDblCote(attribRs2.value("visible_to")) + ", "
                          + escapeDblCote(attribRs2.value("value_type")) + ", "
                          + escapeDblCote(attribRs2.value("is_searchable")) + ", "
                          + escapeDblCote(attribRs2.value("is_fixed"))
                          + ");\n" ;

                    out.write(funcStr);
                }
            }

        %>
    }

    function addAttribute(attribType, attribId, name, visibleTo, valueType, isSearchable, isFixed){

        var attribList = $('#productAttributesList');
        if(attribType === "specs"){
            attribList = $('#productAttributesListSpecs');
        }

        var attribTemplate = $('#attribListTemplate li:first');
        var newAttrib = attribTemplate.clone(true);

		//we need backoffice option only for specs attributes
		if(attribType !== "specs")
		{
			newAttrib.find("[name=attribute_visible_to] option[value='backoffice']").remove();
		}

        attribList.append(newAttrib);

        newAttrib.find("[name=attribute_name]").attr('required','required');
        newAttrib.find("[name=attribute_type]").val(attribType);

        if(!attribId){
            attribId = 'new_'+getRandomInt(100000);
        }
        else{
            newAttrib.find("[name=attribute_name]").val(name);
            newAttrib.find("[name=attribute_visible_to]").val(visibleTo);
            newAttrib.find("[name=attribute_value_type]").val(valueType);
            newAttrib.find("[name=attribute_is_fixed]").val(isFixed);
            newAttrib.find("[name=attribute_is_searchable]").val(isSearchable);
            if(isSearchable == "1"){
                newAttrib.find('.attribute_is_searchable_check').prop("checked",true);
            }

            if(isFixed == "1"){
                newAttrib.find(".hideFixed").hide();

                newAttrib.find("select").each(function(index, select) {
                    select = $(select);
                    var input = $("<input>").attr({
                        type : "text",
                        name : select.attr("name"),
                        onchange : select.attr("onchange"),
                        value : select.val(),
                        class : "form-control w-100",
                    });
                    input.insertBefore(select);
                    select.remove();
                });

                newAttrib.find("input").prop("readonly",true);
            }
        }

        if(attribType == "specs"){
            newAttrib.find('span.attribute_value_type,.addAttribValueBtn,.attribValueRow').hide();
        }
        else{
            newAttrib.find('span.attribute_is_searchable').hide();
        }

        newAttrib.attr('id','attribListItem_'+attribId);
        newAttrib.data('attrib-id',attribId);
        newAttrib.find('input[name=attribute_id]').val(attribId);
    }

    function onChangeValueType(input){
        var attribListItem = $(input).parents('.attribListItem:first');
        var valuesList = attribListItem.find(".attribValueList");

        var isColor = ( $(input).val() === "color" );
        if(isColor){
            valuesList.find(".attribute_color_span").show();
        }
        else{
            valuesList.find(".attribute_color_span").hide();
        }

    }

    function addAttributeValueBtn(btn){
       var attribId = $(btn).parents('.attribListItem:first').data('attrib-id');

       addAttributeValue(attribId);
    }

    function addAttributeValue(attribId, attribValueId, attribValue, smallText, color, isSearchable) {

        var attribListItem = $('#attribListItem_'+attribId);
        var valuesList = attribListItem.find(".attribValueList");

        var li = $('#attribValueListTemplate li:first').clone(true);
        valuesList.append(li);

        attribListItem.find("[name=attribute_value_type]").trigger('onchange');

        if (typeof attribValueId !== 'undefined') {

            li.find('input,select,button').each(function(index, el) {
                var name = $(el).attr('name');
                var val = '';

                if (name === 'attribute_value_id') {
                    val = attribValueId;
                }
                else if (name === 'attribute_value') {
                    val = attribValue;
                }
                else if(name === "attribute_small_text"){
                    val = smallText;
                }
                else if(name === "attribute_color"){
                    val = color;
                }
                $(el).val(val);
            });

        }

        var colorInput = li.find("input[name=attribute_color]");
        colorInput.spectrum({
                preferredFormat : "hex",
                allowEmpty : true,
                showButtons : true,
                showInitial : true,
                showAlpha : true,
                showInput : true,
                // showPalette : true,
                // change: function(color) {
                //     console.log("on change");
                //     console.log(color.toHexString()); // #ff0000
                // },
                // beforeShow : function(color){
                //     console.log("on becore show " + $(this).val());
                //     $(this).spectrum("set",$(this).val());
                // }

            });

        li.find('input,select').each(function(index, el) {
            $(el).attr('name', $(el).attr('name') + "_" + attribId);
        });
    }

    function updateIsSearchable(checkbox){
        var li = $(checkbox).parents('li:first');
        li.find('input[name=attribute_is_searchable]').val( $(checkbox).prop('checked')?'1':'0' );
    }

    function attributeMoveUp(button){
        var li = $(button).parents('li:first');
        li.insertBefore(li.prev());
    }

    function attributeMoveDown(button){
        var li = $(button).parents('li:first');
        li.insertAfter(li.next());
    }

    function attributeDelete(button, isValue){
        var li = $(button).parents('li:first');

        var id = li.find('input[name=attribute_id]').val();
        var deletedIds = $('#attribute_deleted');

        if(isValue){
            id = li.find('input.attribute_value_id').val();
            deletedIds = $('#attribute_values_deleted');
        }

        var msg = "This is a saved item. Deleting it will remove its values from all corresponding products. Are you sure ? "

        if( parseInt(id) > 0){
            if(confirm(msg)){
                deletedIds.val(deletedIds.val() + id + ',');
                li.remove();
            }
        }
        else{
                li.remove();
        }
    }

    function showAttribCollapse(btn){
        var collapseId = $(btn).parent().find("[data-toggle=collapse]:first").attr('href');
        $(collapseId).collapse('show');
    }

<% } else { %>

    function initAttributes(){}
    function addAttribute(){}
    function onChangeValueType(){}
    function addAttributeValueBtn(){}
    function updateIsSearchable(){}
    function attributeMoveUp(){}
    function attributeMoveDown(){}
    function attributeDelete(){}


<% } %>
</script>