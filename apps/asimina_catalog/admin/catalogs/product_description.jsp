<%@ page import="com.etn.asimina.util.ProductEssentialsImageHelper"%>
<%!
    JSONArray getDescriptionBlocks(Contexte Etn,String productId){
        // ProductEssentialsImageHelper productEssentialsImageHelper = new ProductEssentialsImageHelper(productId);
        JSONArray blocks = new JSONArray();
        String query = "select langue_id,block_text,file_name,actual_file_name,image_label from product_essential_blocks where product_id = " + escape.cote(productId)+" order by id";
        Set rs = Etn.execute(query);
        if(rs != null){
            while(rs.next()){
                JSONObject block = new JSONObject();
                block.put("languageId",rs.value("langue_id"));
                block.put("blockText",rs.value("block_text"));
                block.put("fileName",rs.value("file_name"));
                block.put("actualFileName",rs.value("actual_file_name"));
                block.put("label",rs.value("image_label"));
                // block.put("image",productEssentialsImageHelper.getBase64Image(rs.value("file_name")));
                blocks.put(block);
            }
        }
        return blocks;
    }

    JSONArray getProductTabs(Contexte Etn,String productId){
        String query = "select pt.langue_id language_id,pt.name,pt.content from product_tabs pt inner join language l on pt.langue_id=l.langue_id where pt.product_id = " + escape.cote(productId) + " order by pt.order_seq";

        return toJSONArray(Etn,query);
    }
%>
<%
    String qasas = "select * from product_descriptions where product_id = " + escape.cote(id);
    Set rsDescription = Etn.execute(qasas);
%>
<!-- Product description -->

<div class="card mb-2">
    <div class="p-0 card-header btn-group bg-secondary d-flex" role="group" aria-label="Basic example">
    <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#collapseExample7" role="button" aria-expanded="false" aria-controls="collapseExample7" style="padding:0.75rem 1.25rem;color:#3c4b64"><strong>Product description</strong></button>
    <button id="savemenuinfobtn" type="button" class="btn btn-primary" onclick="onsave()">Save</button>
    </div>

    <div class="collapse border-0 " id="collapseExample7">
        <form class="card-body">
            <div class="p-3 ">
                <div class="form-group row">
                    <label for="staticEmail" class="col-sm-3 col-form-label">Summary</label>
                    <div class="col-sm-9">
                         <%=UIHelper.getLangTextAreasRowWise(langsList,
                            "description_summary_lang_%s",
                            "description_summary_lang_%s",
                            "summary",rsDescription, "ckeditor_field description_summary")%>
                    </div>
                </div>

                <div class="form-group row">
                    <label for="staticEmail" class="col-sm-3 col-form-label">
                        <%= "offer".equals(catalogType) ? "Details" : "Main features"%>
                    </label>
                    <div class="col-sm-9 mainFeaturesParentDiv">
                         <%=UIHelper.getLangTextAreasRowWise(langsList,
                            "description_main_features_lang_%s",
                            "description_main_features_lang_%s",
                            "main_features",rsDescription, "ckeditor_field")%>
                    </div>
                </div>
                <div class="form-group row">
                    <label for="staticEmail" class="col-sm-3 col-form-label">Video URL</label>
                    <div class="col-sm-9">
                        <div class="input-group mb-3">
                            <%=UIHelper.getLangInputsRowWise(langsList,"description_video_url_lang_%s","description_video_url_lang_%s","video_url",rsDescription)%>
                        </div>
                    </div>
                </div>

                <button type="button" class="btn btn-success btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#collapse71" role="button" aria-expanded="false" aria-controls="collapse71">Essentials zone</button>

                <div class="collapse p-3 mb-2 " id="collapse71">

                    <div class="form-group row">
                        <label for="staticEmail" class="col-sm-3 col-form-label">Displaying</label>
                        <div class="col-sm-9">
                            <%=UIHelper.getLangSelectsRowWise(langsList,"description_essentials_alignment_lang_%s","description_essentials_alignment_lang_%s","product_essentials_alignment","","custom-select","","essentials_alignment",rsDescription)%>
                        </div>
                    </div>

                    <%=UIHelper.getLangFields(langsList,"<div id='description_blocks_lang_%1$s' class='asimina-multilingual-block asimina-essential-zone-lang-%1$s' data-language-id='%1$s'></div>")%><!-- there is some problem do not use <div/>-->

                    <div class="text-right"><button type="button" id="btnAddProductDescriptionBlock" class="btn btn-primary">Add a bloc</button></div>
                </div>

                <button type="button" class="btn btn-success btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#collapse72" role="button" aria-expanded="false" aria-controls="collapse72">Tabs zone</button>

                <div class="collapse p-3 " id="collapse72">

                    <%=UIHelper.getLangFields(langsList,"<div id='description_tabs_lang_%1$s' class='asimina-multilingual-block asimina-tab-zone-lang-%1$s' data-language-id='%1$s'></div>")%><!-- there is some problem do not use <div/>-->

                    <div class="text-right"><button type="button" id="btnAddProductTab" class="btn btn-primary">Add a tab</button></div>
                </div>

            </div>
        </form>
    </div>
</div>

<script>
    etn.asimina.page.ready(function(e){

        $("#btnAddProductDescriptionBlock").click(function(e){
            etn.asimina.description_blocks.add("#description_blocks_lang_" + etn.asimina.langtabs.languageId(),etn.asimina.langtabs.languageId());
            etn.asimina.util.setDuplicableSectionOrder($(".asimina-essential-zone-lang-" + etn.asimina.langtabs.languageId() + ":first"));
        });
        var descriptionBlocks = <%=getDescriptionBlocks(Etn,id)%>;
        descriptionBlocks.forEach(function(block){
            etn.asimina.description_blocks.add("#description_blocks_lang_" + block.languageId,block.languageId,block);
        });

        $("#btnAddProductTab").click(function(e){
            etn.asimina.product_tabs.add("#description_tabs_lang_" + etn.asimina.langtabs.languageId(),etn.asimina.langtabs.languageId());
            etn.asimina.util.setDuplicableSectionOrder($(".asimina-tab-zone-lang-" + etn.asimina.langtabs.languageId() + ":first"));
        });

        var productTabs = <%=getProductTabs(Etn,id)%>;
        productTabs.forEach(function(tab){
            etn.asimina.product_tabs.add("#description_tabs_lang_" + tab.languageId,tab.languageId,tab);
        });

        etn.asimina.util.setDuplicableSectionOrder($(".asimina-essential-zone-lang-1:first"));
        etn.asimina.util.setDuplicableSectionOrder($(".asimina-tab-zone-lang-1:first"));
    });
</script>
<!-- Product description -->