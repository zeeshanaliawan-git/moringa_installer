<div class="row pb-2">
    <div class="col">
        Language :
        <div class="form-check form-check-inline">
            <input id="langCheckAll" class="form-check-input" type="checkbox" value="" checked="checked"
                   onchange="onChangeExportLangCheck(this)">
            <label class="form-check-label">All</label>
        </div>
        <%
            String exportLangIds[] = parseNull(request.getParameter("langIds")).split(",");
            List<Language> langsList = getLangs(Etn,session);

            for (Language curLang : langsList) {
        %>
        <div class="form-check form-check-inline">
            <input class="form-check-input langCheck langCheck_<%=curLang.getLanguageId()%>" type="checkbox" value="<%=curLang.getLanguageId()%>"
                   onchange="onChangeExportLangCheck(this)">
            <label class="form-check-label"><%=curLang.getLanguage()%>
            </label>
        </div>
        <%
            }
        %>

    </div>
</div>
<script type="text/javascript">
    //onready
    $(function () {
        <%
            for(String curLangId : exportLangIds){
                if(parseInt(curLangId) > 0){
                    out.write("$('input.langCheck_"+curLangId+"').prop('checked',true).trigger('change');");
                }
            }
        %>
    });

    function getExportLangIds() {
        var langIds = [];
        if (!$('#langCheckAll').prop("checked")) {
            $('input.langCheck:checked').each(function (i, input) {
                langIds.push($(input).val());
            })
        }
        return langIds.length > 0 ? langIds.join(",") : "";
    }

    function onChangeExportLangCheck(checkbox) {
        checkbox = $(checkbox)

        if (checkbox.prop("checked")) {
            if (checkbox.val() === "") {
                //"all" was checked , uncheck all other
                $('input.langCheck').prop('checked', false);
            }
            else {
                $('#langCheckAll').prop('checked', false);
            }
        }
        else {
            //uncheked , if all languages unchecked then check "all" option
            if ($('input.langCheck:checked').length === 0) {
                $('#langCheckAll').prop('checked', true);
            }
        }
    }

    function validateExportLangIds() {

        if ($('#langCheckAll:checked,input.langCheck:checked').length === 0) {
            //if no option of language is selected ,
            bootNotifyError("No language selected");
            return false
        }
        return true;
    }
</script>