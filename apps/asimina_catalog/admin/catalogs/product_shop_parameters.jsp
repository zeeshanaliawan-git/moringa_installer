<% if(isEcommerceEnabled(Etn, getSelectedSiteId(session))) { %>
<div class="card mb-2">
    <div class="p-0 card-header btn-group bg-secondary d-flex"  role="group" aria-label="Basic example">
        <button type="button" class="btn btn-link btn-block text-left text-decoration-none" data-toggle="collapse" href="#shop-parameters" role="button" aria-expanded="false" aria-controls="collapseExample" style="padding:0.75rem 1.25rem;color:#3c4b64">
            <strong>Shop parameters</strong>
        </button>
        <% if(!bIsProd) { %>
        <button id="priceSave" type="button" class="btn btn-primary" onclick="onsave()">Save</button>
        <%}%>
    </div>
    <div class="collapse border-0" id="shop-parameters">
        <div class="card-body form-horizontal">
            <div class="form-group row ">
                <label for="inputUniverse" class='col-sm-3 control-label'>Show basket</label>
                <div class='col-sm-9'>
                    <%=addSelectControl("show_basket", "show_basket", yesno, getRsValue(rs, "show_basket"), "custom-select", "")%>
                </div>

            </div>
            <div class="form-group row ">
                <label for="inputUniverse" class='col-sm-3 control-label'>Show Quick Buy</label>
                <div class='col-sm-9'>
                    <%=addSelectControl("show_quickbuy", "show_quickbuy", yesno, getRsValue(rs, "show_quickbuy"), "custom-select", "")%>
                </div>
            </div>
            <div class="form-group row">
                <label for="staticEmail" class="col-sm-3 col-form-label">Payment online?</label>
                <div class="col-sm-9">
                    <%=addSelectControl("payment_online", "payment_online", yesno2, getRsValue(rs, "payment_online"), "custom-select", "")%>
                </div>
            </div>

            <div class="form-group row">
                <label for="staticEmail" class="col-sm-3 col-form-label">Payment cash on delivery?</label>
                <div class="col-sm-9">
                    <%=addSelectControl("payment_cash_on_delivery", "payment_cash_on_delivery", yesno2, getRsValue(rs, "payment_cash_on_delivery"), "custom-select", "")%>
                </div>
            </div>

            <div class="form-group row">
                <label for="staticEmail" class="col-sm-3 col-form-label">Allow ratings?</label>
                <div class="col-sm-9">
                    <%=addSelectControl("allow_ratings", "allow_ratings", feedbackDDValues, getRsValue(rs, "allow_ratings"), "custom-select", "")%>
                </div>
            </div>

            <div class="form-group row">
                <label for="staticEmail" class="col-sm-3 col-form-label">Allow comments?</label>
                <div class="col-sm-9">
                    <%=addSelectControl("allow_comments", "allow_comments", feedbackDDValues2, getRsValue(rs, "allow_comments"), "custom-select", "")%>
                </div>
            </div>

            <div class="form-group row">
                <label for="staticEmail" class="col-sm-3 col-form-label">Allow complaints?</label>
                <div class="col-sm-9">
                    <%=addSelectControl("allow_complaints", "allow_complaints", feedbackDDValues, getRsValue(rs, "allow_complaints"), "custom-select", "")%>
                </div>
            </div>

            <div class="form-group row">
                <label for="staticEmail" class="col-sm-3 col-form-label">Allow questions?</label>
                <div class="col-sm-9">
                    <%=addSelectControl("allow_questions", "allow_questions", feedbackDDValues2, getRsValue(rs, "allow_questions"), "custom-select", "")%>
                </div>
            </div>
        </div>
    </div>
</div>
<% } //end if ecommerce enabled%>