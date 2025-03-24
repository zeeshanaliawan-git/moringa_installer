<!-- Product specifications -->
<div class="card mb-2">
    <div class="p-0 card-header btn-group bg-secondary d-flex" role="group" aria-label="Basic example">
        <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#product-specs" role="button" aria-expanded="false" aria-controls="collapseExample" title="product_specification" style="padding:0.75rem 1.25rem;color:#3c4b64">
            <strong>Product specifications (for description)</strong>
        </button>
        <% if(!bIsProd) { %>
        <button type="button" class="btn btn-primary" onclick='onsave()'>Save</button>
        <%}%>
    </div>
    <div class="collapse border-0" id="product-specs">
        <div class="card-body form-horizontal">
            <table cellpadding="0" cellspacing="0" border="0" class="table table-hover  results">
                <tr>
                    <th style="text-align: left;">Attribute Name</th>
                    <th style="text-align: left;">Value</th>
                    <th style="text-align: center;">Visible To</th>
                </tr>
                <%
                if(specsCatAttributesRs != null){
                specsCatAttributesRs.moveFirst();
                while(specsCatAttributesRs.next()){
                String attribId = specsCatAttributesRs.value("cat_attrib_id");
                      //String attribValueId = specsCatAttributesRs.value("attrib_value_id");
                      %>
                      <tr class="">
                        <input type="hidden" name='attribute_value_id_<%=attribId%>' value='<%=escapeCoteValue(specsCatAttributesRs.value("attribute_value_id"))%>' />
                        <input type="hidden" name='attribute_value_image_<%=attribId%>' value='' />
                        <input type="hidden" name='attribute_price_diff_<%=attribId%>' value='' />
                        <input type="hidden" name='attribute_price_diff_symbol_<%=attribId%>' value='' />
                        <input type="hidden" name='attribute_is_default_<%=attribId%>' value='' />
                        <input type="hidden" name='attribute_small_text_<%=attribId%>' value='' />
                        <input type="hidden" name='attribute_color_<%=attribId%>' value='' />
                        <td class="">
                            <%=escapeCoteValue(specsCatAttributesRs.value("name"))%>
                        </td>
                        <td class="">
                            <input type="text" name='attribute_value_<%=attribId%>' value='<%=getValue(specsCatAttributesRs,"attribute_value")%>' class="form-control" />
                        </td>
                        <td class="" style="text-transform: capitalize;text-align: center;">
                            <%=escapeCoteValue(specsCatAttributesRs.value("visible_to").replace("_"," "))%>
                        </td>
                    </tr>
                    <%
                    }//end while catAttributes
                }
                %>
            </table>
        </div>
    </div>
</div>
<script type="text/javascript">
etn.asimina.page.ready(200,function(e){

});
</script>
<!-- /Product specifications -->