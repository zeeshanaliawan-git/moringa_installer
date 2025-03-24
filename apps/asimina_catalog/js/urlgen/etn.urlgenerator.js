/*
    Moringa Url Generator v2.0
    Author : Ali Adnan
    Last Update : 2020-07-13
*/
if (typeof window.etn === "undefined") {
  window.etn = {};
}

/***

** Usage :
* Add (after jquery) :
<script type="text/javascript" src='<%=GlobalParm.getParm("URL_GEN_JS_URL")%>'></script>
<script type="text/javascript">
  window.URL_GEN_AJAX_URL = '<%=GlobalParm.getParm("URL_GEN_AJAX_URL")%>';
</script>

** Usage code sample:

var urlGenAjaxUrl = window.URL_GEN_AJAX_URL;
var urlInputRefOrSelector = $('#urlInput');
var urlGenOptions = {}; //optional, see below for options
var urlGen = etn.initUrlGenerator(urlInputRefOrSelector,urlGenAjaxUrl);
var urlOpenTypeVal = urlGen.getOpenType();

var urlInputRefOrSelector2 = $('#urlInput2');
var urlGenOptions2 = { langId : '1', fullUrl : true, showOpenType : false};
var urlGen2 = etn.initUrlGenerator(urlInputRefOrSelector, urlGenAjaxUrl, urlGenOptions2);

*/

etn.initUrlGenerator = function (input, urlGenAjaxUrl, options) {
  return new etn.MoringaURLGenerator(input, urlGenAjaxUrl, options);
};

etn.inIframe = function () {
  try {
    return window.self !== window.top;
  } catch (error) {
    return true;
  }
};

etn.MoringaURLGenerator = function (_input, _urlGenAjaxUrl, _options) {
  var gen = this;

	//css file is at same location as the ajax url file
	let cssPath = _urlGenAjaxUrl;
	cssPath = cssPath.replace("urlgeneratorAjax.jsp","etn.urlgenerator.css");
	// console.log("cssPath:"+cssPath);
	let _head  = document.getElementsByTagName('head')[0];
	let _link  = document.createElement('link');
	_link.rel  = 'stylesheet';
	_link.type = 'text/css';
	_link.href = cssPath;
	_link.media = 'all';
  if(etn.inIframe())
  _head.appendChild(_link);	

    
  gen.init = function (_input, _urlGenAjaxUrl, _options) {
    gen.URL_GEN_AJAX_URL = _urlGenAjaxUrl;
    gen.input = $(_input);
	gen.onSelectCallback = null;
    // console.log(_options);
    //default options
	
    gen.options = {
      langId: "0",
      showOpenType: true,
      fullUrl: false,
      menuMaxHeight: "200px",
      allowEmptyValue: false,
      template: gen.getTemplateHtml(),
      autoCompleteAppendTo: null,
    };

    if (typeof _options === "object") {
      gen.options = $.extend(gen.options, _options);
    }

    var templateHtml = "";
    if (gen.options.template !== null) {
      if (typeof gen.options.template == "function") {
        templateHtml = gen.options.template();
      } else if (typeof gen.options.template == "string") {
        templateHtml =gen.options.template ;
      }
    }

    if (templateHtml.length > 0) {
      gen.urlGenDiv = $(templateHtml).insertBefore(gen.input);
      var temp = document.createElement("div");
      temp.classList.add("position-relative","flex-grow-1");
      temp.appendChild(gen.input[0]);
      $(temp).insertBefore(gen.urlGenDiv.find(".urlGenOpenTypeDiv"));
      gen.input.addClass("form-control urlGenInput");
      gen.openTypeSelect = gen.urlGenDiv.find("select.urlGenOpenType");
      gen.urlGenTooltip = gen.urlGenDiv.find(".urlGenTooltip");
      gen.errorMsg = gen.urlGenDiv.find(".urlGenErrorMsg");

      //set name according to base input
      var openTypeName =
        (gen.input.attr("name") ? gen.input.attr("name") : "") + "_opentype";
      gen.openTypeSelect.attr("name", openTypeName);

      if (gen.options.showOpenType === false) {
        gen.urlGenDiv.find(".urlGenOpenTypeDiv").hide();
        gen.input.addClass("rounded-right");
      }

      gen.urlGenTooltip.tooltip();
    } else {
      gen.input.addClass("urlGenInput");
    }

    gen.input.on("blur", function () {
      var val = gen.input.val();
      if (val.trim() !== val) {
        gen.input.val(val.trim());
      }	  
      gen.validate();
    });

    gen.initAutoComplete(gen.input);

    //init value of open type set in data- attribute
    var dataOpenType = gen.input.attr("data-open-type");
    if (dataOpenType && dataOpenType.length > 0) {
      gen.setOpenType(dataOpenType);
    }
    //validate url value if set
    if (gen.input.val().trim().length > 0) {
      gen.validate();
    }
	
	  //added to handle the UI issue in ckeditor link dialog
	  $(".cke_dialog_ui_input_text").css("position","relative");

  };
  
  gen.setOnSelectCallback=function(_callback) {
	  gen.onSelectCallback = _callback;
  }

  //getters && setters
  gen.getOpenTypeSelect = function () {
    return gen.openTypeSelect;
  };

  gen.getOpenType = function () {
    return gen.openTypeSelect.val();
  };

  gen.setOpenType = function (val) {
    return gen.openTypeSelect.val(val);
  };

  //debug
  gen.getOptions = function () {
    return options;
  };

  gen.getUrlGenDiv = function () {
    return gen.urlGenDiv;
  };

  gen.getTemplateHtml = function () {
    return (
      '<div class="input-group urlGenDiv">' +
      '    <div class="input-group-prepend">' +
      '        <span class="input-group-text urlGenTooltip" data-toggle="tooltip" data-placement="top" title="Start to type name or URL of a page, then select in the list the right one">URL</span>' +
      "    </div>" +
      '    <div class="input-group-append urlGenOpenTypeDiv">' +
      '        <select class="custom-select urlGenOpenType" style="max-width:150px">' +
      '            <option value="same_window">Same window</option>' +
      '            <option value="new_tab">New tab</option>' +
      '            <option value="new_window">New window</option>' +
      "        </select>" +
      "    </div>" +
      '    <div class="invalid-feedback urlGenErrorMsg"></div>' +
      "</div>"
    );
  };

  gen.initAutoComplete = function (inputElement) {
    let _langId = gen.options.langId;
    Array.from(inputElement).forEach((e) => {
      if (e.getAttribute("data-lang-id")) {
        _langId = e.getAttribute("data-lang-id");
      }
      var ul = e.parentElement.querySelector(".url-gen-ui-autocomplete");
      if(ul==null){
        ul = document.createElement("ul");
        ul.classList.add("url-gen-ui-autocomplete","autocomplete-items","position-absolute","bg-white","pl-0","d-flex","flex-column","overflow-auto","w-100");
        ul.style.listStyleType = "none";
        ul.style.overflow="auto";
        ul.style.left = "0";
        ul.style.maxHeight = "280px";
        ul.style.zIndex = "99999999";
        e.parentNode.appendChild(ul);
      }

        e.addEventListener("keydown",function(event){
          var ulTag = event.target.nextSibling;
          if(event.key==="ArrowDown"){
            var li = ulTag.querySelector(".autocomplete-item-highlight");
            if(li){
              var sibling = li.nextSibling;
              if(sibling) {
                li.classList.remove("autocomplete-item-highlight");
                ulTag.scrollTop = (sibling.offsetTop );
                sibling.classList.add("autocomplete-item-highlight");
              }
            }else{
              if(ulTag.querySelector("li"))
                li = ulTag.querySelector("li").classList.add("autocomplete-item-highlight");
            }
          }else if(event.key==="ArrowUp"){
            var li = ulTag.querySelector(".autocomplete-item-highlight");
            if(li){
              var sibling = li.previousSibling;
              if(sibling) {
                li.classList.remove("autocomplete-item-highlight");
                ulTag.scrollTop = (sibling.offsetTop );
                sibling.classList.add("autocomplete-item-highlight")
              };
            }
          }
          else if(event.key === "Escape"){
            ulTag.innerHTML="";
          }
          else if(event.key === "Enter"){
            var li = ulTag.querySelector(".autocomplete-item-highlight");
            if(li) {
              event.target.value = li.dataset.value;
              ulTag.innerHTML="";
			  if(gen.onSelectCallback != null) gen.onSelectCallback();
            }
          }
        });

        e.addEventListener("input", function () {
          var searchTerm = e.value.trim();
          var fullUrl = gen.options.fullUrl ? "1" : "0";
          if(searchTerm.length>=1)
          {
            $.ajax({
              url: gen.URL_GEN_AJAX_URL,
              type: "POST",
              dataType: "json",
              data: {
                requestType: "search",
                langId: _langId,
                searchTerm: searchTerm,
                fullUrl: fullUrl,
              },
            })
              .done(function (resp) {
                if (resp.status == "1") {
                  ul.innerHTML="";
                  renderMenu(ul, resp.data.urls);
                } else {
                  ul.innerHTML="";
                }
              })
              .fail(function () {
                console.error("Url Gen Search: Error in contacting server.");
                ul.innerHTML="";
              })
              .always(function () {});
        }else{
          ul.innerHTML="";
        }
      });

      e.addEventListener("blur",function(event){
        var ulTag = event.target.nextSibling;
        if(ulTag)
        {
          ulTag.innerHTML="";
        }
      });
  })};

  function renderMenu(menuElement, items) {
    items.forEach(function (item) {
      renderMenuItem(menuElement, item);
    });
    menuElement.style.menuMaxHeight = gen.options.menuMaxHeight;
  }

  function renderMenuItem(ul, item) {
    var li = document.createElement("li");
    li.classList.add("py-2","px-2");
    li.style.cursor="pointer";
    li.dataset.value=item.value;
    li.innerText=item.label;
    
    li.addEventListener("mousedown",function(e)
    {
      var targetUl=e.target.closest("ul");
      var inputTag = targetUl.previousSibling;
      inputTag.value=e.target.dataset.value;
      targetUl.innerHTML="";
	  if(gen.onSelectCallback != null) gen.onSelectCallback();
    });
    ul.appendChild(li);
  }

  gen.setError = function (isError, errorMsg) {
    if (isError) {
      gen.input.addClass("is-invalid");
      if (typeof gen.errorMsg !== "undefined") {
        gen.errorMsg.html(errorMsg);
      }
    } else {
      gen.input.removeClass("is-invalid");
    }
  };

  //using this as reference : https://www.w3schools.com/tags/att_a_href.asp
  gen.allowedStartWithList = [
    "http://",
    "https://",
    "tel:",
    "mailto:",
    "file:",
    "sms:",
    "ftp://",
    "ftps://",
    "#",
  ];

  gen.validate = function () {
    /*if(document.querySelector(".autocomplete-items:not(.hidden)"))
	{
		console.log("gen.validate return");
		return;
	}*/
    
    var isValid = true;
    
    var url = gen.input.val();
	// console.log("validate url " + url);
	
    var isAllowed = false;
    $.each(gen.allowedStartWithList, function (index, val) {
      if (url.indexOf(val) == 0) {
        isAllowed = true;
        return false; //break
      }
    });

    if (!isAllowed) {
      //check for mobile deep links,format starting with  "<appname>://"
      // here as per standard URI specs <appname> (scheme as per URI) valid format is
      // A non-empty scheme component followed by a colon (:),
      // consisting of a sequence of characters beginning with a letter
      // and followed by any combination of letters, digits, plus (+), period (.), or hyphen (-).
      var URIStartRegex = /^[a-zA-Z]+[a-zA-Z\d+.-]*:\/\//i;

      if (URIStartRegex.test(url)) {
        isAllowed = true;
      }
    }

    if (isAllowed) {
      //starts with allowed list of protocols
      gen.setError(false);
    } else if (url.indexOf("pagePreview.jsp") >= 0) {
      var msg =
        "Error: preview URL cannot be used. Use the field to search and select desired URL.";
      gen.setError(true, msg);
    } else if (url === "") {
      //empty value
      if (!gen.options.allowEmptyValue) {
        gen.setError(true, "Cannot be empty");
      } else {
        gen.setError(false);
      }
    } else {
      var fullUrl = gen.options.fullUrl ? "1" : "0";

      var trimmedUrl =
        url.indexOf("?") >= 0 ? url.substring(0, url.indexOf("?")) : url;

      $.ajax({
        url: gen.URL_GEN_AJAX_URL,
        type: "GET",
        dataType: "json",
        data: {
          requestType: "validate",
          langId: gen.options.langId,
          url: trimmedUrl,
          fullUrl: fullUrl,
        },
      })
        .done(function (resp) {
          var isError = true;
          if (resp.status == "1") {
            isError = !resp.data.isValid;
          }

          if (isError) {
            var msg = "Error: URL not found";
            gen.setError(true, msg);
            console.debug(msg);
          } else {
            gen.setError(false);
          }
        })
        .fail(function () {
          console.error("Url Gen Validate : Error in contacting server.");
          gen.setError(
            true,
            "Error in contacting server for checking URL.Please try again."
          );
        })
        .always(function () {
          //hideLoader();
        });
    }
  };
  //init
  gen.init(_input, _urlGenAjaxUrl, _options);
}; //MoringaURLGenerator
