<%!
    JSONArray getEssentialBlocks(Contexte Etn,String catalogId){
        //CatalogEssentialsImageHelper imageHelper = new CatalogEssentialsImageHelper(catalogId);
        JSONArray blocks = new JSONArray();
        String query = "SELECT * FROM catalog_essential_blocks WHERE catalog_id = " + escape.cote(catalogId) + " order by id";
        Set rs = Etn.execute(query);
        if(rs != null){
            while(rs.next()){
                JSONObject block = new JSONObject();
                block.put("languageId",rs.value("langue_id"));
                block.put("blockText",rs.value("block_text"));
                block.put("fileName",rs.value("file_name"));
                block.put("actualFileName",rs.value("actual_file_name"));
                block.put("label",rs.value("image_label"));
                //block.put("image",imageHelper.getBase64Image(rs.value("file_name")));
                blocks.put(block);
            }
        }
        return blocks;
    }
%>
<!-- catalog essential zones -->
<div class="card">
    <div class="card-header bg-success text-left" data-toggle="collapse" href="#catalog-essential-zone-collapse">
        <button type="button" class="btn btn-link text-white"  role="button" >
            <strong>Essentials zone</strong>
        </button>
    </div>
    <div class="d-none">
    </div>
    <div class="border-0 collapse show" id="catalog-essential-zone-collapse">
        <div class="card-body">
            <div class="form-group row">
                <label for="staticEmail" class="col-sm-3 col-form-label">Displaying</label>
                <div class="col-sm-9">
                    <%
                        java.util.List<Language> langs = langsList;
                        for (int i = 0; i < langs.size(); i++) {
                            String curLanguageId = langs.get(i).getLanguageId();
                            String curColumnName = "essentials_alignment_lang_"+curLanguageId;
                            String curSelectedValue = rs!=null?rs.value(curColumnName):"";
                            String curAttributes = " multilingual='true' ";
                            if(i > 0){
                                curAttributes = "style='display:none;'";
                            }
                            String selectHtml = UIHelper.getSelectControl(curColumnName,curColumnName, "product_essentials_alignment","", curSelectedValue, "custom-select", curAttributes);
                            out.write(selectHtml);
                        }
                    %>
                </div>
            </div>
            <!-- essential description blocks  -->
            <%=UIHelper.getLangFields(langsList,"<div id='essential_blocks_lang_%1$s' class='asimina-multilingual-block asimina-essential-zone-lang-%1$s' data-language-id='%1$s'></div>")%>
            <div class="w-100 text-right">
                <button type="button" class="btn btn-success" onclick='addEssentialBloc()' <%=(rs==null)?"disabled":""%>>Add a bloc</button>
            </div>
        </div>

    </div>
</div>
<script type="text/javascript">
<% if(!bIsProd) { %>
	function addEssentialBloc(){
        var curLangId =  etn.asimina.langtabs.languageId();
        etn.asimina.description_blocks.add("#essential_blocks_lang_" + curLangId,curLangId);
        etn.asimina.util.setDuplicableSectionOrder($(".asimina-essential-zone-lang-" + curLangId + ":first"));
	}

    etn.asimina.page.ready(100,function(e){
        var essentialBlocks = <%=getEssentialBlocks(Etn,id)%>;
        essentialBlocks.forEach(function(block){
            etn.asimina.description_blocks.add("#essential_blocks_lang_" + block.languageId,block.languageId,block);
        });

        etn.asimina.util.setDuplicableSectionOrder($(".asimina-essential-zone-lang-1:first"));
    });
<% } else { %>
// function initAttributes(){}
// function addAttribute(){}
// function onChangeValueType(){}
// function addAttributeValueBtn(){}
// function updateIsSearchable(){}
// function attributeMoveUp(){}
// function attributeMoveDown(){}
// function attributeDelete(){}
<% } %>
</script>