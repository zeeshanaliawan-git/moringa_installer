<!-- Product parameters -->
<div class="btn-group col-12" style="padding-left:0px; padding-right:0px" role="group" aria-label="Basic example">
    <button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#product-parameters" role="button" aria-expanded="false" aria-controls="collapseExample">
        Product parameters
    </button>
    <% if(!bIsProd) { %>
    <button type="button" class="btn btn-primary mb-2" onclick='onsave()'>Save</button>
    <%}%>
</div>
<div class="p-3 collapse" id="product-parameters">
    <div class="form-inline">
        <table cellpadding="0" cellspacing="0" border="0" class="table table-hover table-bordered results">
            <!-- Product attributes (selection)  -->
            <tr>
                <th colspan="3" id="productAttributeSelection" nowrap>Product Attributes (Selection)</th>
            </tr>
            <tr>
                <td colspan="3">
                    <input type="hidden" name="attribute_values_deleted" id="attribute_values_deleted" value="" />
                    <ul id="attribValueTemplateList" style="display:none;margin-top: 0px;margin-left: 0px;padding-left: 10px;list-style-type: circle;">
                        <li style="margin-bottom: 10px;">
                            <input type="hidden" name="attribute_value_id" value="" class="attribute_value_id" />
                            <input type="hidden" name="attribute_value_image" class="attribute_value_image" value="" />
                            Name: <input type="text" name="attribute_value" value="" class="attribute_value form-control" onblur="attributeChanged(this)" />
                            &nbsp;Small Text: <input type="text" name="attribute_small_text" value="" class="attribute_small_text form-control" onblur="" />
                            <span class='attribute_color_span' style="display:none;">&nbsp;Color: <input type="text" name="attribute_color" value="" class="attribute_color form-control" onblur="" /></span>
                            &nbsp; default ?:
                            <input type="radio" name="attribute_is_default_radio" class="attribute_is_default_radio" value="1" onchange="setAttribDefault(this)" />
                            <input type="hidden" name="attribute_is_default" value="0" />
                            &nbsp; <button type="button" onclick='attributeMoveUp(this)' class="btn btn-default"><i class="fa fa-arrow-up" aria-hidden="true"></i></button>
                            &nbsp; <button type="button" onclick='attributeMoveDown(this)' class="btn btn-default"><i class="fa fa-arrow-down" aria-hidden="true"></i></button>
                            &nbsp; <button type="button" onclick='attributeDelete(this)' class='btn btn-default text-danger'><i class="oi oi-x" aria-hidden="true"></i></button>
                        </li>
                    </ul>
                </td>
            </tr>
            <%

            catAttributesRs.moveFirst();
            int attribCount = 0;
            while(catAttributesRs.next()){
            String attribId = catAttributesRs.value("cat_attrib_id");
            String valueType = catAttributesRs.value("value_type");
            attribCount++;
            %>
            <tr class="attrib-value-row">
                <th nowrap width='5%' valign='top' style="border: 0px;"><i>Attribute Name </i>: <font style="text-transform: uppercase;">
                    <%=escapeCoteValue(catAttributesRs.value("name"))%>
                </font>
            </th>
            <th valign='top' style="border: 0px;"><i>Visible to</i>: <font style="">
                <%=escapeCoteValue(catAttributesRs.value("visible_to").replace("_"," "))%>
            </font>
        </th>
        <th></th>
    </tr>
    <tr class="attribValueRow" data-attrib-id='<%=attribId%>' data-attrib-name='<%=getValue(catAttributesRs,"name")%>'>
        <td colspan="2">
            <ul id="attributeValuesList_<%=attribId%>" class="attributeValuesList_<%=attribCount%> attributeValuesList" style="margin-top: 0px;margin-left: 0px;padding-left: 10px;list-style-type: circle;">
            </ul>
        </td>
        <td>
            <% if(!bIsProd) { %>
            <button type="button" id="add_attrib_value_<%=attribCount%>" class="btn btn-default btn-success" onclick='addAttributeValue(<%=attribId%>,"<%=valueType%>")'>+ Add a Line</button>
            <%}%>
        </td>
    </tr>
    <%
            }//end while catAttributes
            %>
        </table>
    </div>
</div>

<script type="text/javascript">
    etn.asimina.page.ready(200,function(e){

    });
</script>
<!-- /Product parameters -->