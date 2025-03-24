<%
    String shareBarQuery = "select * from " + dbname + "share_bar s where s.id =  " + escape.cote(id) + " and ptype = 'product' ";
    Set rsShareBar = Etn.execute(shareBarQuery);
    if(rsShareBar != null) rsShareBar.next();
%>
                            <div class="btn-group col-12" style="padding-left:0px; padding-right:0px" role="group" aria-label="Basic example">
								<button type="button" class="btn btn-secondary btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#collapseExample8" role="button" aria-expanded="false" aria-controls="collapseExample8">Social share bar</button>
								<button id="savemenuinfobtn" type="button" class="btn btn-primary mb-2" onclick="onsave()">Save</button>
							</div>


							<div class="collapse p-3 " id="collapseExample8">
								<!-- Facebook -->
								<button type="button" class="btn btn-success btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#collapse81" role="button" aria-expanded="false" aria-controls="collapse81">Facebook</button>

								<div class="collapse p-3 mb-2 " id="collapse81">
									<div class="form-group row">
										<label for="share_bar_og_active" class="col-sm-3 col-form-label">Activated?</label>
										<div class="col-sm-9">
											 <%=addSelectControl("share_bar_og_active", "share_bar_og_active", yesno2, getRsValue(rsShareBar, "og_active"), "custom-select", "")%>
										</div>
									</div>
									<div class="form-group row">
										<label for="staticEmail" class="col-sm-3 col-form-label">Facebook title</label>
                                        <div class="col-sm-9">
                                            <%=UIHelper.getLangInputs("share_bar_lang_%s_og_title","share_bar_lang_%s_og_title","lang_%s_og_title",rsShareBar)%>
										</div>
									</div>
									<div class="form-group row">
										<label for="staticEmail" class="col-sm-3 col-form-label">Facebook description</label>
										<div class="col-sm-9">
											 <%=UIHelper.getLangTextAreas("2","share_bar_lang_%s_og_description","share_bar_lang_%s_og_description","lang_%s_og_description",rsShareBar)%>
										</div>
									</div>

                                    <%=UIHelper.getLangFields("<div id='product_share_bar_facebook_image_lang_%1$s' class='asimina-multilingual-block' data-language-id='%1$s'></div>")%><!-- there is some problem do not use <div/>-->
								</div>
								<!-- /Facebook -->

								<!-- Twitter -->
								<button type="button" class="btn btn-success btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#collapse82" role="button" aria-expanded="false" aria-controls="collapse82">Twitter</button>

								<div class="collapse p-3 mb-2 " id="collapse82">
									<div class="form-group row">
										<label for="staticEmail" class="col-sm-3 col-form-label">Activated?</label>
										<div class="col-sm-9">
											<%=addSelectControl("share_bar_twitter_active", "share_bar_twitter_active", yesno2, getRsValue(rsShareBar, "twitter_active"), "custom-select", "")%>
										</div>
									</div>
									<div class="form-group row">
										<label for="staticEmail" class="col-sm-3 col-form-label">Twitter message</label>
										<div class="col-sm-9">
											 <%=UIHelper.getLangTextAreas("2","share_bar_lang_%s_twitter_message","share_bar_lang_%s_twitter_message","lang_%s_twitter_message",rsShareBar)%>
										</div>
									</div>
									<div class="form-group row">
										<label for="staticEmail" class="col-sm-3 col-form-label">Twitter site</label>
										<div class="col-sm-9">
											<%=UIHelper.getLangInputs("share_bar_lang_%s_twitter_site","share_bar_lang_%s_twitter_site","lang_%s_twitter_site",rsShareBar)%>
										</div>
									</div>

								</div>
								<!-- /Twitter -->

								<!-- Mail -->
								<button type="button" class="btn btn-success btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#collapse83" role="button" aria-expanded="false" aria-controls="collapse83">Mail</button>

								<div class="collapse p-3 mb-2 " id="collapse83">
									<div class="form-group row">
										<label for="staticEmail" class="col-sm-3 col-form-label">Activated?</label>
										<div class="col-sm-9">
											<%=addSelectControl("share_bar_email_active", "share_bar_email_active", yesno2, getRsValue(rsShareBar, "email_active"), "custom-select", "")%>
										</div>
									</div>
									<div class="form-group row">
										<label for="staticEmail" class="col-sm-3 col-form-label">Email title</label>
										<div class="col-sm-9">
											<%=UIHelper.getLangInputs("share_bar_lang_%s_email_popin_title","share_bar_lang_%s_email_popin_title","lang_%s_email_popin_title",rsShareBar)%>
										</div>
									</div>
									<div class="form-group row">
										<label for="staticEmail" class="col-sm-3 col-form-label">Email subject</label>
										<div class="col-sm-9">
											<%=UIHelper.getLangInputs("share_bar_lang_%s_email_subject","share_bar_lang_%s_email_subject","lang_%s_email_subject",rsShareBar)%>
										</div>
									</div>
									<div class="form-group row">
										<label for="staticEmail" class="col-sm-3 col-form-label">Email message</label>
										<div class="col-sm-9">
											 <%=UIHelper.getLangTextAreas("2","share_bar_lang_%s_email_message","share_bar_lang_%s_email_message","lang_%s_email_message",rsShareBar)%>
										</div>
									</div>
								</div>
								<!-- /Mail -->

								<!-- SMS -->
								<button type="button" class="btn btn-success btn-lg btn-block text-left mb-2" data-toggle="collapse" href="#collapse84" role="button" aria-expanded="false" aria-controls="collapse84">SMS</button>

								<div class="collapse p-3 mb-2 " id="collapse84">
									<div class="form-group row">
										<label for="staticEmail" class="col-sm-3 col-form-label">Activated?</label>
										<div class="col-sm-9">
											<%=addSelectControl("share_bar_sms_active", "share_bar_sms_active", yesno2, getRsValue(rsShareBar, "sms_active"), "custom-select", "")%>
										</div>
                                    </div>
                                    <div class="form-group row">
                                        <label for="staticEmail" class="col-sm-3 col-form-label">SMS message</label>
                                        <div class="col-sm-9">
                                            <div class="input-group">
                                                <%=UIHelper.getLangInputs("share_bar_lang_%s_sms_text","share_bar_lang_%s_sms_text","lang_%s_sms_text",rsShareBar)%>
                                                <div class="input-group-append">
                                                    <%=UIHelper.getLangFields("<span class='input-group-text' id='share_bar_lang_%1$s_sms_text_count' data-language-id='%1$s'>0</span>")%>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
								</div>
								<!-- /SMS -->
							</div>

<script>
    etn.asimina.page.ready(function(e){
        <%for(com.etn.asimina.beans.Language lang : getLangs(Etn,selectedsiteId)){%>
        <%if(productShareBarImageHelper != null){%>
        var image<%=lang.getLanguageId()%> = {actualFileName:"<%=getRsValue(rsShareBar,"lang_" + lang.getLanguageId() + "_og_original_image_name")%>",image:"<%=productShareBarImageHelper.getBase64Image(getRsValue(rsShareBar,"lang_" + lang.getLanguageId() + "_og_image"))%>",label:"<%=getRsValue(rsShareBar,"lang_" + lang.getLanguageId() + "_og_image_label")%>"};
        <%}else{%>
        var image<%=lang.getLanguageId()%> = null;
        <%}%>
        etn.asimina.images.add("share_bar_facebook_image_lang_<%=lang.getLanguageId()%>","#product_share_bar_facebook_image_lang_<%=lang.getLanguageId()%>",image<%=lang.getLanguageId()%>,"Image");
        <%}%>
        <%for(com.etn.asimina.beans.Language lang : getLangs(Etn,selectedsiteId)){%>
        $("#<%=String.format("share_bar_lang_%s_sms_text",lang.getLanguageId())%>").on("input",function(e){
            var langId = $(this).attr("data-language-id");
            if(langId){
                $("#share_bar_lang_" + langId+ "_sms_text_count").html($(this).val().length);
            }
        });
        $("#<%=String.format("share_bar_lang_%s_sms_text",lang.getLanguageId())%>").trigger("input");
        <%}%>


    });
</script>