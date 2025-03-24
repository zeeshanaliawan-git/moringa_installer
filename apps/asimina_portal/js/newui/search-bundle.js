(window["webpackJsonp"] = window["webpackJsonp"] || []).push([["search"],{

/***/ "./src/modules/search/nav-search/nav-search.ts":
/*!*****************************************************!*\
  !*** ./src/modules/search/nav-search/nav-search.ts ***!
  \*****************************************************/
/*! exports provided: NavSearch */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "NavSearch", function() { return NavSearch; });
/* harmony import */ var _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../helper/responsive/responsive */ "./src/modules/helper/responsive/responsive.ts");
/* harmony import */ var _ui_main_overlay_main_overlay__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../ui/main-overlay/main-overlay */ "./src/modules/ui/main-overlay/main-overlay.ts");
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }




var NavSearch =
/*#__PURE__*/
function () {
  function NavSearch() {
    _classCallCheck(this, NavSearch);
  }

  _createClass(NavSearch, null, [{
    key: "init",
    value: function init() {
      if (_helper_debug_debug__WEBPACK_IMPORTED_MODULE_2__["Debug"].isNotLoadedTweenMax()) {
        return;
      }

      NavSearch.$element = $(".NavSearch.isDropDown");
      NavSearch.element = NavSearch.$element.get(0);
      NavSearch.$trigger = $(".JS-NavSearchDropdown-open");

      if (NavSearch.$element.length > 0) {
        _ui_main_overlay_main_overlay__WEBPACK_IMPORTED_MODULE_1__["MainOverlay"].addTrigger(NavSearch.$trigger);
        _ui_main_overlay_main_overlay__WEBPACK_IMPORTED_MODULE_1__["MainOverlay"].addContent(NavSearch.$element);
        NavSearch.events();
        NavSearch.setMaxHeight();
        /* POUR L'OVERFLOW SCROLL */
      }
    }
  }, {
    key: "events",
    value: function events() {
      $(".JS-NavSearchDropdown-open").on("click", function () {
        if (_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__["Responsive"].isMin("minLg")) {
          if (NavSearch.$element.attr("aria-expanded") === "true") {
            NavSearch.$element.attr("aria-expanded", "false");
            NavSearch.closeNavSearch();
          } else {
            NavSearch.$element.attr("aria-expanded", "true");
            NavSearch.openNavSearch();
          }
        }
      });
      $("body").on("click", function (e) {
        if (_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__["Responsive"].isMin("minLg")) {
          var $clickedElement = $(e.target);
          var searchMenuIsClicked = $clickedElement.closest(".NavSearch, .JS-NavSearchDropdown-open").length;

          if (searchMenuIsClicked === 0) {
            if (NavSearch.$element.attr("aria-expanded") === "true") {
              NavSearch.$element.attr("aria-expanded", "false");
              NavSearch.closeNavSearch();
            }
          }
        }
      });
      $(window).on("scroll resize orientationchange", function () {
        NavSearch.setMaxHeight();
        /* POUR L'OVERFLOW SCROLL */
      });
      $(window).on("resize orientationchange", function () {
        if (!_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__["Responsive"].isMin("minLg")) {
          if (NavSearch.$element.attr("aria-expanded") === "true") {
            NavSearch.$element.attr("aria-expanded", "false");
            NavSearch.closeNavSearch();
            _ui_main_overlay_main_overlay__WEBPACK_IMPORTED_MODULE_1__["MainOverlay"].hideOverlay();
          }
        }
      });
    }
  }, {
    key: "openNavSearch",
    value: function openNavSearch() {
      TweenMax.set(NavSearch.$element, {
        display: 'block',
        height: "auto",
        overflow: 'auto'
      });
      TweenMax.from(NavSearch.$element, 0.5, {
        height: 0,
        overflow: 'hidden',
        display: 'block',
        ease: Power2.easeOut,
        onStart: function onStart() {
          NavSearch.$element.scrollTop(0);
        }
      });
      $(".search-btn").addClass("svgMenu");
      NavSearch.$element.find("input.SearchForm-input").trigger("focus");
      $(".JS-NavSearchDropdown-open").addClass("dropdownIsOpen");
    }
  }, {
    key: "closeNavSearch",
    value: function closeNavSearch() {
      TweenMax.set(NavSearch.$element, {
        overflow: 'auto',
        display: 'block'
      });
      TweenMax.to(NavSearch.$element, 0.5, {
        height: 0,
        display: 'none',
        overflow: 'hidden',
        ease: Power2.easeOut
      });
      $(".search-btn").removeClass("svgMenu"); // TODO: A voir

      $(".JS-NavSearchDropdown-open").removeClass("dropdownIsOpen");
    }
  }, {
    key: "setMaxHeight",
    value: function setMaxHeight() {
      /* POUR L'OVERFLOW SCROLL */
      var windowHeight = $(window).height();
      var maxHeight = windowHeight;
      var scrollTop = $(window).scrollTop();

      if (typeof scrollTop === "undefined") {
        scrollTop = 0;
      }

      if (scrollTop < 140) {
        maxHeight = windowHeight - 142;
      } else {
        maxHeight = windowHeight - 62;
      }

      NavSearch.$element.css({
        "max-height": maxHeight
      });
    }
  }]);

  return NavSearch;
}();

_defineProperty(NavSearch, "element", void 0);

_defineProperty(NavSearch, "$element", void 0);

_defineProperty(NavSearch, "$trigger", void 0);

/***/ }),

/***/ "./src/modules/search/search-algolia.ts":
/*!**********************************************!*\
  !*** ./src/modules/search/search-algolia.ts ***!
  \**********************************************/
/*! exports provided: SearchAlgolia */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "SearchAlgolia", function() { return SearchAlgolia; });
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
/* harmony import */ var _tabs_search_tabs__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./tabs/search-tabs */ "./src/modules/search/tabs/search-tabs.ts");
/* harmony import */ var _template_template_product__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./template/template-product */ "./src/modules/search/template/template-product.ts");
/* harmony import */ var _template_template_service__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./template/template-service */ "./src/modules/search/template/template-service.ts");
/* harmony import */ var _template_template_assistance__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./template/template-assistance */ "./src/modules/search/template/template-assistance.ts");
/* harmony import */ var _template_template_magazine__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./template/template-magazine */ "./src/modules/search/template/template-magazine.ts");
/* harmony import */ var _template_template_video__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ./template/template-video */ "./src/modules/search/template/template-video.ts");
/* harmony import */ var _template_template_brand__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ./template/template-brand */ "./src/modules/search/template/template-brand.ts");
/* harmony import */ var _template_template_suggest__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! ./template/template-suggest */ "./src/modules/search/template/template-suggest.ts");
/* harmony import */ var _search_modal_search_modal__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! ./search-modal/search-modal */ "./src/modules/search/search-modal/search-modal.ts");
/* harmony import */ var query_string_for_all__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! query-string-for-all */ "./node_modules/query-string-for-all/dist/index.js");
/* harmony import */ var query_string_for_all__WEBPACK_IMPORTED_MODULE_10___default = /*#__PURE__*/__webpack_require__.n(query_string_for_all__WEBPACK_IMPORTED_MODULE_10__);
/* harmony import */ var _template_template_resultCount__WEBPACK_IMPORTED_MODULE_11__ = __webpack_require__(/*! ./template/template-resultCount */ "./src/modules/search/template/template-resultCount.ts");
/* harmony import */ var _template_template_modalResultCount__WEBPACK_IMPORTED_MODULE_12__ = __webpack_require__(/*! ./template/template-modalResultCount */ "./src/modules/search/template/template-modalResultCount.ts");
function _typeof(obj) { "@babel/helpers - typeof"; if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }













 // INIT CONFIG INTERFACES

var SectionToManage;

(function (SectionToManage) {
  SectionToManage["modal"] = "modal";
  SectionToManage["page"] = "page";
  SectionToManage["dropdown"] = "dropdown";
  SectionToManage["custom"] = "custom";
})(SectionToManage || (SectionToManage = {}));

var SearchAlgolia =
/*#__PURE__*/
function () {
  function SearchAlgolia() {
    _classCallCheck(this, SearchAlgolia);
  }

  _createClass(SearchAlgolia, null, [{
    key: "init",

    /* NavSearch || PageSearch || ModalSearch */
    value: function init() {
      this.initConfig = window.searchAlgoliaConfig;
      this.initTabConfig = window.searchTabsConfig;
      $.each(SearchAlgolia.initConfig.indices, function (key, value) {
        SearchAlgolia.config.set(key, value);
      });
      this.debug = new _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__["Debug"](false);
      this.debug.log('SearchAlgolia - init()');

      if (_helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__["Debug"].isNotLoadedAlgoliaSearch()) {
        return;
      }

      this.tabToGo = {};
      _tabs_search_tabs__WEBPACK_IMPORTED_MODULE_1__["SearchTabs"].init(this.initTabConfig);
      this.algoliaSetup();
      this.setTopTendances();
      this.events();
    }
  }, {
    key: "algoliaSetup",
    value: function algoliaSetup() {
      var _this = this;

      this.client = algoliasearch(this.initConfig.algolia.applicationId, this.initConfig.algolia.apiKey);
      this.config.forEach(function (indice, indiceName) {
        if (indice.indiceKey) {
          // Indexes fusions
          var fusion = [];
          _tabs_search_tabs__WEBPACK_IMPORTED_MODULE_1__["SearchTabs"].tabs.forEach(function (tab, tabName) {
            if (tab.indexes.indexOf(indiceName) >= 0) {
              fusion = tab.indexes;
            }
          });

          if (fusion.length > 0) {
            indice.fusion = fusion;
          } else {
            indice.fusion = false;
          } // HTTP Verification


          _this.client.search([{
            indexName: indice.indiceKey,
            query: '',
            params: {
              hitsPerPage: 0
            }
          }])["catch"](function (err) {
            var tab = _tabs_search_tabs__WEBPACK_IMPORTED_MODULE_1__["SearchTabs"].findTabByIndex(indiceName);

            if (typeof tab.disactiveIndexes === 'undefined') {
              tab.disactiveIndexes = [];
            }

            tab.disactiveIndexes.push(indiceName);

            if (tab.indexes.length === tab.disactiveIndexes.length) {
              tab.$tab.hide();
              indice.$dropdown.hide();
            }

            indice.$component.hide();
            indice.$templateWrapper.hide();
            SearchAlgolia.config["delete"](indiceName);
            console.warn("Algolia index: " + indice.indiceKey + " (" + indiceName + ") has an error " + err.statusCode); //console.warn("Error details: " + err);
          });
        }
      });
      this.resetSearch();
    }
  }, {
    key: "setTopTendances",
    value: function setTopTendances() {
      SearchAlgolia.debug.log('SearchAlgolia - setTopTendances()');
      var suggestIndiceKey = this.config.get('suggest').indiceKey;

      if (!suggestIndiceKey) {
        return;
      }

      var queries = [];
      queries.push({
        indexName: suggestIndiceKey,
        query: '',
        params: {
          hitsPerPage: 6
        }
      });
      this.client.search(queries, SearchAlgolia.saveTopTendances);
    }
  }, {
    key: "saveTopTendances",
    value: function saveTopTendances(err) {
      var response = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];

      if (!err && response.results && response.results.length > 0) {
        var hits = response.results[0].hits;

        if (hits) {
          $.each(hits, function (index, value) {
            if (value.query) {
              $(".TopTendances-items").append('<li data-autosearch="' + value.query + '">' + value.query + '</li>');
            }
          });
        }
      }
    }
  }, {
    key: "showTopTendances",
    value: function showTopTendances() {
      this.find('.TopTendances').show();
    }
  }, {
    key: "hideTopTendances",
    value: function hideTopTendances() {
      this.find('.TopTendances').hide();
    }
  }, {
    key: "resetSearch",
    value: function resetSearch() {
      var _this2 = this;

      var indexes = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
      this.config.forEach(function (value, key, map) {
        if (indexes.length > 0 && indexes.indexOf(key) === -1) {
          return;
        }

        _this2.config.get(key).response = {
          hits: [],
          nbHits: 0,
          page: 0
        };
      });
    }
  }, {
    key: "find",
    value: function find(selector) {
      switch (this.sectionToManage) {
        case 'dropdown':
          return this.sections.$dropdown.find(selector);

        case 'page':
          return this.sections.$page.find(selector);

        default:
          return this.sections.$custom.find(selector);
      }
    }
  }, {
    key: "events",
    value: function events() {
      this.debug.log('SearchAlgolia - event()'); // Interface

      this.updateInputFocusEvent();
      $(".SearchForm-inputClear").on("click", function () {
        SearchAlgolia.clearSearchInput();
      });
      $('.SearchForm [type="submit"]').on('click', function (e) {
        e.preventDefault();
      }); // Fonctionnel

      this.inputEvent();
      this.gotoSearchPageEvent();
      this.initSearchOnLoad();
      this.autoSearchEvents();
      $(".showMoreSearchResults").on("click", function () {
        SearchAlgolia.showMoreResults($(this));
      });
      $('.SearchSort select').on('change', function () {
        var $this = $(this);
        var indexes = JSON.parse($this.val().toString());
        var indexesToSearch = [];

        for (var index in indexes) {
          if (indexes.hasOwnProperty(index)) {
            var indiceKey = indexes[index];

            if (SearchAlgolia.config.has(index)) {
              SearchAlgolia.resetSearch([index]);
              SearchAlgolia.config.get(index).indiceKey = indiceKey;
              indexesToSearch.push(index);
            }
          }
        }

        SearchAlgolia.search(indexesToSearch);
      });
    }
  }, {
    key: "gotoSearchPageEvent",
    value: function gotoSearchPageEvent() {
      $(".JS-SearchAlgolia-submitForm").on('click', function () {
        console.log(SearchAlgolia.find('.SearchForm'));
        SearchAlgolia.find('.SearchForm').submit();
      });
    }
  }, {
    key: "updateInputFocusEvent",
    value: function updateInputFocusEvent() {
      var $searchInput = $("input.SearchForm-input");
      $searchInput.on("focusin", function () {
        $(this).parent().addClass("focused");
      });
      $searchInput.on("focusout", function () {
        $(this).parent().removeClass("focused");
      });
    }
  }, {
    key: "updateSectionToManage",
    value: function updateSectionToManage($element) {
      if ($element.parents('.NavSearch').length > 0) {
        if (SearchAlgolia.sectionToManage !== SectionToManage.dropdown) {
          SearchAlgolia.clearSearchInput();
        }

        SearchAlgolia.sectionToManage = SectionToManage.dropdown;
      } else if ($element.parents('.PageSearch').length > 0) {
        if (SearchAlgolia.sectionToManage !== SectionToManage.page) {
          SearchAlgolia.clearSearchInput();
        }

        SearchAlgolia.sectionToManage = SectionToManage.page;
      } else {
        if (SearchAlgolia.sectionToManage !== SectionToManage.custom) {
          SearchAlgolia.clearSearchInput();
        }

        SearchAlgolia.sectionToManage = SectionToManage.custom;
      }
    }
  }, {
    key: "inputEvent",
    value: function inputEvent() {
      this.debug.log('SearchAlgolia - inputEvent() registred'); // @ts-ignore

      $("input.SearchForm-input:not([data-search])").on("input paste", function (event, data) {
        SearchAlgolia.debug.log('SearchAlgolia - inputEvent() input...');
        var $this = $(this);
        var query = $this.val().toString();

        if ($this.parents('.NavSearch').length > 0) {
          if (SearchAlgolia.sectionToManage === SectionToManage.page) {
            SearchAlgolia.clearSearchInput();
          }

          SearchAlgolia.sectionToManage = SectionToManage.dropdown;
        } else {
          if (SearchAlgolia.sectionToManage === SectionToManage.dropdown) {
            SearchAlgolia.clearSearchInput();
          }

          SearchAlgolia.sectionToManage = SectionToManage.page;
        }

        clearTimeout(SearchAlgolia.searchTimeout);
        SearchAlgolia.searchTimeout = setTimeout(function () {
          SearchAlgolia.debug.log('SearchAlgolia - inputEvent() - SectionToManage : ', SearchAlgolia.sectionToManage);
          SearchAlgolia.manageSearchQuery(query);
        }, 500);
      }); // @ts-ignore

      $("input.SearchForm-input[data-search]").on("input paste", function (event, data) {
        var $this = $(this);
        var query = $this.val().toString();
        clearTimeout(SearchAlgolia.searchTimeout);
        SearchAlgolia.searchTimeout = setTimeout(function () {
          var dataSearch = $this.data("search");

          if (dataSearch) {
            SearchAlgolia.sections.$custom = $(dataSearch.sectionToManage);
            SearchAlgolia.sectionToManage = SectionToManage.custom;
            var customIndice = {
              indiceKey: dataSearch.indiceKey,
              $templateWrapper: $(dataSearch.templateWrapper),
              $component: $(dataSearch.component),
              $dropdown: $(dataSearch.component),
              $template: $(dataSearch.template),
              templateAttributes: dataSearch.templateAttributes,
              response: {},
              blockToShow: {
                page: dataSearch.blockToShow,
                dropdown: dataSearch.blockToShow,
                custom: dataSearch.blockToShow
              },
              fusion: false
            };
            $this.data('indice', customIndice);
            SearchAlgolia.config.set('custom', customIndice);
            SearchAlgolia.manageSearchQuery(query, ['custom']);
          }
        }, 500);
      });
    }
  }, {
    key: "manageSearchQuery",
    value: function manageSearchQuery(query, indexes) {
      if (query) {
        SearchAlgolia.query = query.toString();
      } else {
        SearchAlgolia.query = "";
      }

      if (SearchAlgolia.query.length > 0) {
        SearchAlgolia.hideVocalisationIcon();
        SearchAlgolia.showCross();
      } else {
        SearchAlgolia.hideCross();
        SearchAlgolia.showVocalisationIcon();
        SearchAlgolia.resetInterface();
      }

      if (SearchAlgolia.query.length >= 2) {
        SearchAlgolia.resetSearch();

        if (indexes) {
          SearchAlgolia.search(indexes);
        } else {
          SearchAlgolia.search();
        }
      }
    }
  }, {
    key: "resetInterface",
    value: function resetInterface() {
      var noResult = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : false;

      if (noResult) {
        this.hideTopTendances();
        this.showNoResultBlock();
      } else {
        this.hideNoResultBlock();
        this.showTopTendances();
      }

      this.hideResultsBlock();

      if (!this.isCustom()) {
        this.hideSearchSuggest();
        this.hideSearchDetails();
        _tabs_search_tabs__WEBPACK_IMPORTED_MODULE_1__["SearchTabs"].resetInterface();
      }
    }
  }, {
    key: "updateInterface",
    value: function updateInterface() {
      var totalHits = this.getRealTotalHitsCount();

      if (totalHits === 0) {
        // No results
        this.resetInterface(true);
      } else {
        this.hideNoResultBlock();
        this.showResultsBlock();
        this.updateSearchDetails();
        this.hideTopTendances();
        this.resetDropdownShowMoreButtonVisibility();
        this.goToTab(this.tabToGo);
      }

      _search_modal_search_modal__WEBPACK_IMPORTED_MODULE_9__["SearchModal"].updateSwiper();
    }
  }, {
    key: "goToTab",
    value: function goToTab(tab) {
      if ($('.SearchTabs').length === 0 && !tab) {
        return;
      }

      if (typeof tab.$tab !== 'undefined') {
        if (tab.$tab.hasClass('disabled')) {
          return;
        }

        _tabs_search_tabs__WEBPACK_IMPORTED_MODULE_1__["SearchTabs"].select(tab);
        this.tabToGo = {};
      }
    }
  }, {
    key: "resetDropdownShowMoreButtonVisibility",
    value: function resetDropdownShowMoreButtonVisibility() {
      $('.NavSearch-showMoreResults').data('must-be-visible', null);
    }
  }, {
    key: "hideSearchSuggest",
    value: function hideSearchSuggest() {
      this.find(".SearchSuggest").hide();
    }
  }, {
    key: "isModal",
    value: function isModal() {
      return this.sectionToManage === SectionToManage.modal;
    }
  }, {
    key: "isDropdown",
    value: function isDropdown() {
      return this.sectionToManage === SectionToManage.dropdown;
    }
  }, {
    key: "isPage",
    value: function isPage() {
      return this.sectionToManage === SectionToManage.page;
    }
  }, {
    key: "isCustom",
    value: function isCustom() {
      return this.sectionToManage === SectionToManage.custom;
    }
  }, {
    key: "showResultsBlock",
    value: function showResultsBlock() {
      var _this3 = this;

      if (this.isDropdown()) {
        this.find('.NavSearch-resultsContainer').show();
      } else if (this.isPage()) {
        this.find('.PageSearch-resultsContainer').show();
      } else if (this.isCustom()) {
        this.find('.SearchCustom-resultsContainer').show();
      } // Afficher l'onglet


      var indexToShow = undefined;
      this.config.forEach(function (value, key) {
        if (indexToShow) {
          return;
        }

        if (_this3.getRealHitsCount(value) > 0) {
          indexToShow = key;
        }
      });

      if (this.isPage()) {
        _tabs_search_tabs__WEBPACK_IMPORTED_MODULE_1__["SearchTabs"].selectIfActiveIndiceKey(indexToShow);
      }
    }
  }, {
    key: "hideResultsBlock",
    value: function hideResultsBlock() {
      if (SearchAlgolia.isDropdown()) {
        this.find('.NavSearch-resultsContainer').hide();
      } else if (SearchAlgolia.isPage()) {
        this.find('.PageSearch-resultsContainer').hide();
      } else if (SearchAlgolia.isCustom()) {
        this.find('.SearchCustom-resultsContainer').hide();
      }
    }
  }, {
    key: "clearSearchInput",
    value: function clearSearchInput() {
      SearchAlgolia.debug.log('SearchAlgolia - clearSearchInput()');
      SearchAlgolia.manageSearchQuery();
      SearchAlgolia.find("input.SearchForm-input").val("");
    }
  }, {
    key: "initSearchOnLoad",
    value: function initSearchOnLoad() {
      SearchAlgolia.debug.log('SearchAlgolia - initSearchOnLoad()');
      this.checkParametersInUrl();
      var inputVal = $(".PageSearch input.SearchForm-input").val();

      if (inputVal) {
        inputVal = inputVal.toString();
        inputVal = inputVal.trim();
        this.query = inputVal;

        if (inputVal.length >= 2) {
          SearchAlgolia.sectionToManage = SectionToManage.page;
          SearchAlgolia.query = inputVal;
          SearchAlgolia.manageSearchQuery(inputVal);
        }
      }
    }
  }, {
    key: "checkParametersInUrl",
    value: function checkParametersInUrl() {
      var hash = query_string_for_all__WEBPACK_IMPORTED_MODULE_10__["parse"](location.hash);
      var search = query_string_for_all__WEBPACK_IMPORTED_MODULE_10__["parse"](location.search);

      if (typeof hash.SearchTabs !== 'undefined') {
        this.tabToGo = _tabs_search_tabs__WEBPACK_IMPORTED_MODULE_1__["SearchTabs"].findTabByIndex(hash.SearchTabs.toString());
      }

      if (typeof search.query !== 'undefined') {
        var $searchInput = $(".PageSearch input.SearchForm-input");
        $searchInput.val(search.query.toString()).trigger('input');
      }
    }
  }, {
    key: "autoSearchEvents",
    value: function autoSearchEvents() {
      SearchAlgolia.debug.log('SearchAlgolia - autoSearchEvents() registred');
      $(document).on("click", "[data-autosearch]", function () {
        SearchAlgolia.debug.log('SearchAlgolia - autoSearchEvents() fired');
        var $this = $(this);
        var query = $this.data("autosearch");
        SearchAlgolia.clearSearchInput();
        SearchAlgolia.updateSectionToManage($this);
        SearchAlgolia.clearSearchInput();
        var $searchInput = SearchAlgolia.find("input.SearchForm-input");

        if (query) {
          $searchInput.val(query);
          $searchInput.trigger("input", [true]);
        }
      });
    }
    /* Callback this = Response */

  }, {
    key: "saveSearch",
    value: function saveSearch(err) {
      var response = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];

      if (!err && response.results && response.results.length > 0) {
        response.results.forEach(function (results) {
          var indice = results.index;
          var index = SearchAlgolia.getIndiceByKey(indice);
          SearchAlgolia.debug.log('SearchAlgolia - saveSearch()', indice);

          if (index !== undefined) {
            SearchAlgolia.showShowMore(index);

            if (results.page === 0) {
              SearchAlgolia.config.get(index).response = results;
            } else if (results.page + 1 <= results.nbPages) {
              SearchAlgolia.config.get(index).response.hits = SearchAlgolia.config.get(index).response.hits.concat(results.hits);
            }

            if (results.hits.length === 0 || results.nbPages === 0 || results.nbPages <= results.page + 1) {
              SearchAlgolia.hideShowMore(index);
            }

            SearchAlgolia.showResults(index);
          }
        });
        SearchAlgolia.debug.log('SearchAlgolia - saveSearch() - Finish !');
        SearchAlgolia.updateInterface();
      }
    }
  }, {
    key: "hideShowMore",
    value: function hideShowMore(index) {
      $('.showMoreSearchResults[data-index="' + index + '"]').hide();
    }
  }, {
    key: "showShowMore",
    value: function showShowMore(index) {
      $('.showMoreSearchResults[data-index="' + index + '"]').show();
    }
  }, {
    key: "getIndiceByKey",
    value: function getIndiceByKey(indiceKey) {
      var index = undefined;
      this.config.forEach(function (value, key, map) {
        if (indiceKey === value.indiceKey) {
          index = key;
        }
      });
      return index;
    }
  }, {
    key: "search",
    value: function search() {
      var _this4 = this;

      var indexes = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
      SearchAlgolia.debug.log('SearchAlgolia - search()');
      var queries = [];
      this.config.forEach(function (value, key, map) {
        if (indexes.length > 0 && indexes.indexOf(key) === -1 || value.indiceKey === false) {
          return;
        }

        queries.push({
          indexName: value.indiceKey,
          query: _this4.query,
          params: {
            page: value.response.page,
            hitsPerPage: value.blockToShow[_this4.sectionToManage]
          }
        });
      });
      this.client.search(queries, SearchAlgolia.saveSearch);
    }
  }, {
    key: "getBlockToShowCount",
    value: function getBlockToShowCount(indice) {
      if (SearchAlgolia.isDropdown()) {
        return indice.blockToShow.dropdown;
      }

      return indice.blockToShow.page;
    }
  }, {
    key: "getRealBlockToShowGroupCount",
    value: function getRealBlockToShowGroupCount(indexes) {
      var _this5 = this;

      var blockToShow = 0;
      indexes.forEach(function (value) {
        var indice = _this5.config.get(value);

        if (_this5.getRealHitsCount(indice) > 0) {
          blockToShow += _this5.getBlockToShowCount(_this5.config.get(value));
        }
      });
      return blockToShow;
    }
  }, {
    key: "showResults",
    value: function showResults(index) {
      SearchAlgolia.debug.log('SearchAlgolia - showResults() : ' + index);
      var indice = this.config.get(index);
      var nbHits = this.getRealHitsCount(indice);
      var blockToShow = this.getBlockToShowCount(indice);

      if (nbHits === 0) {
        this.find(indice.$component).hide();
      } else {
        this.find(indice.$component).show();
      }

      if (this.sectionToManage === SectionToManage.dropdown) {
        this.updateNavSearchShowMoreButtons(index, blockToShow, nbHits);
      }

      if (typeof indice.fusion !== 'boolean') {
        nbHits = this.getRealHitGroupCount(indice.fusion);
        blockToShow = this.getRealBlockToShowGroupCount(indice.fusion);
      }

      if (nbHits < blockToShow) {
        blockToShow = nbHits;
      }

      if (this.sectionToManage === SectionToManage.dropdown) {
        this.updateNavSearchHeader(index, blockToShow, nbHits);
        this.updateNavSearchResultWrapper(index, blockToShow, nbHits);
      } else if (this.sectionToManage === SectionToManage.page) {
        _tabs_search_tabs__WEBPACK_IMPORTED_MODULE_1__["SearchTabs"].updateTab(index, nbHits);
      }

      this.populate(index, indice);
    }
  }, {
    key: "showMoreResults",
    value: function showMoreResults($el) {
      SearchAlgolia.debug.log('SearchAlgolia - showMoreResults()');
      var index = $el.attr("data-index");
      SearchAlgolia.config.get(index).response.page++;
      SearchAlgolia.search([index]);
    }
  }, {
    key: "getRealHitsCount",
    value: function getRealHitsCount(indice) {
      if (!indice || indice.response.hits.length === 0) {
        return 0;
      } else {
        return indice.response.nbHits;
      }
    }
  }, {
    key: "getRealTotalHitsCount",
    value: function getRealTotalHitsCount() {
      var _this6 = this;

      var count = 0;
      this.config.forEach(function (value, key) {
        if (key === 'suggest') {
          return;
        }

        count += _this6.getRealHitsCount(value);
      });
      return count;
    }
  }, {
    key: "getRealHitGroupCount",
    value: function getRealHitGroupCount(indexes) {
      var _this7 = this;

      var nbHits = 0;
      indexes.forEach(function (value) {
        nbHits += _this7.getRealHitsCount(_this7.config.get(value));
      });
      return nbHits;
    }
  }, {
    key: "getFormatedPrice",
    value: function getFormatedPrice(index, item, price) {
      if (typeof window.orange_customFormatPrice !== 'undefined' && typeof window.orange_customFormatPrice[index] !== 'undefined') {
        return window.orange_customFormatPrice[index](item);
      }

      if (item.ISO_4217) {
        var numberFormat = new Intl.NumberFormat(document.documentElement.lang, {
          style: 'currency',
          currency: item.ISO_4217
        });
        return numberFormat.format(price);
      }

      return price;
    }
  }, {
    key: "populate",
    value: function populate(index, indice) {
      SearchAlgolia.debug.log('SearchAlgolia - populate() : ', index);

      if (this.getRealHitsCount(indice) === 0 || indice.response.page === 0) {
        this.clearTemplate(indice);
      }

      var hitsPerPage = indice.response.hitsPerPage;
      var page = indice.response.page;
      var minLimit = page * hitsPerPage;
      var maxLimit = (page + 1) * hitsPerPage;
      var hitsToShow = indice.response.hits.slice(minLimit, maxLimit);
      var _iteratorNormalCompletion = true;
      var _didIteratorError = false;
      var _iteratorError = undefined;

      try {
        for (var _iterator = hitsToShow[Symbol.iterator](), _step; !(_iteratorNormalCompletion = (_step = _iterator.next()).done); _iteratorNormalCompletion = true) {
          var item = _step.value;
          var $templateTmp = $(indice.$template.clone().html().trim());
          var templateId = indice.$template.attr('id');

          if (templateId === "resultProductsTemplate") {
            $templateTmp = _template_template_product__WEBPACK_IMPORTED_MODULE_2__["TemplateProduct"].getTemplate(index, item, $templateTmp, indice);
          } else if (templateId === "resultServicesTemplate") {
            $templateTmp = _template_template_service__WEBPACK_IMPORTED_MODULE_3__["TemplateService"].getTemplate(index, item, $templateTmp, indice);
          } else if (templateId === "resultAssistanceTemplate") {
            $templateTmp = _template_template_assistance__WEBPACK_IMPORTED_MODULE_4__["TemplateAssistance"].getTemplate(index, item, $templateTmp, indice);
          } else if (templateId === "resultMagazineTemplate") {
            $templateTmp = _template_template_magazine__WEBPACK_IMPORTED_MODULE_5__["TemplateMagazine"].getTemplate(index, item, $templateTmp, indice);
          } else if (templateId === "resultVideosTemplate") {
            $templateTmp = _template_template_video__WEBPACK_IMPORTED_MODULE_6__["TemplateVideo"].getTemplate(index, item, $templateTmp, indice);
          } else if (templateId === "resultBrandsTemplate") {
            $templateTmp = _template_template_brand__WEBPACK_IMPORTED_MODULE_7__["TemplateBrand"].getTemplate(index, item, $templateTmp, indice);
          } else if (templateId === "resultSuggestTemplate") {
            $templateTmp = _template_template_suggest__WEBPACK_IMPORTED_MODULE_8__["TemplateSuggest"].getTemplate(index, item, $templateTmp, indice);
          }

          $templateTmp.appendTo(this.getSectionTemplateWrapper(indice));
        }
      } catch (err) {
        _didIteratorError = true;
        _iteratorError = err;
      } finally {
        try {
          if (!_iteratorNormalCompletion && _iterator["return"] != null) {
            _iterator["return"]();
          }
        } finally {
          if (_didIteratorError) {
            throw _iteratorError;
          }
        }
      }
    }
  }, {
    key: "getSectionTemplateWrapper",
    value: function getSectionTemplateWrapper(indice) {
      return this.find(indice.$templateWrapper);
    }
  }, {
    key: "showNoResultBlock",
    value: function showNoResultBlock() {
      SearchAlgolia.debug.log('SearchAlgolia - showNoResultBlock()');
      var $element = this.find(".NoResultBlock");
      $element.show();
    }
  }, {
    key: "hideNoResultBlock",
    value: function hideNoResultBlock() {
      SearchAlgolia.debug.log('SearchAlgolia - hideNoResultBlock()');
      var $element = this.find(".NoResultBlock");
      $element.hide();
    }
  }, {
    key: "clearTemplate",
    value: function clearTemplate(indice) {
      SearchAlgolia.debug.log('SearchAlgolia - clearTemplate()');
      this.getSectionTemplateWrapper(indice).html("");
    }
  }, {
    key: "updateSearchDetails",
    value: function updateSearchDetails() {
      SearchAlgolia.debug.log('SearchAlgolia - updateSearchDetails()');

      if (this.isDropdown()) {
        return;
      }

      var totalHits = this.getRealTotalHitsCount();
      var $templateResultCount = _template_template_resultCount__WEBPACK_IMPORTED_MODULE_11__["TemplateResultCount"].getTemplate(totalHits);

      if (totalHits > 0) {
        this.$searchDetails.show();
        this.$searchDetails.html($templateResultCount.html());
      }
    }
  }, {
    key: "hideSearchDetails",
    value: function hideSearchDetails() {
      SearchAlgolia.debug.log('SearchAlgolia - resetPageHeader()');

      if (this.isDropdown() || this.isCustom()) {
        return;
      }

      if (SearchAlgolia.query.length >= 2) {
        var $templateResultCount = _template_template_resultCount__WEBPACK_IMPORTED_MODULE_11__["TemplateResultCount"].getTemplate(0);
        this.$searchDetails.html($templateResultCount.html());
        this.$searchDetails.show();
      } else {
        this.$searchDetails.hide();
      }
    }
    /* MONTRER LA CROIX */

  }, {
    key: "showCross",
    value: function showCross() {
      SearchAlgolia.debug.log('SearchAlgolia - showCross()');
      this.find(".SearchForm-inputClear").css({
        display: "block"
      });
    }
    /* CACHER LA CROIX */

  }, {
    key: "hideCross",
    value: function hideCross() {
      SearchAlgolia.debug.log('SearchAlgolia - hideCross()');
      this.find(".SearchForm-inputClear").css({
        display: "none"
      });
    }
  }, {
    key: "updateNavSearchHeader",
    value: function updateNavSearchHeader(index, blockToShow, nbHits) {
      SearchAlgolia.debug.log('SearchAlgolia - updateNavSearchHeader()', index, blockToShow, nbHits);
      var indice = SearchAlgolia.config.get(index);
      var $templateModalResultCount = _template_template_modalResultCount__WEBPACK_IMPORTED_MODULE_12__["TemplateModalResultCount"].getTemplate(blockToShow, nbHits);
      indice.$dropdown.find('.Results-number').html($templateModalResultCount.html());
    }
  }, {
    key: "updateNavSearchShowMoreButtons",
    value: function updateNavSearchShowMoreButtons(index, blockToShow, nbHits) {
      SearchAlgolia.debug.log('SearchAlgolia - updateNavSearchShowMoreButtons()', index, blockToShow, nbHits);
      var indice = SearchAlgolia.config.get(index);
      var $showMoreResults = indice.$dropdown.find('.NavSearch-showMoreResults');

      if ($('.PageSearch').length === 0 && $showMoreResults.attr('href')) {
        var href = query_string_for_all__WEBPACK_IMPORTED_MODULE_10__["parseUrl"]($showMoreResults.attr('href'));

        if (Object.keys(href.query).length === 0) {
          $showMoreResults.attr('href', $showMoreResults.attr('href') + '?query=' + SearchAlgolia.query + '#SearchTabs=' + index);
        }
      }

      if (nbHits - blockToShow > 0) {
        $showMoreResults.data('must-be-visible', true); // For grouped indexes

        $showMoreResults.show();
      } else {
        if ($showMoreResults.data('must-be-visible') !== true) {
          $showMoreResults.hide();
        }
      }
    }
  }, {
    key: "updateNavSearchResultWrapper",
    value: function updateNavSearchResultWrapper(index, blockToShow, nbHits) {
      SearchAlgolia.debug.log('SearchAlgolia - updateNavSearchResultWrapper()', index, blockToShow, nbHits);
      var indice = SearchAlgolia.config.get(index);

      if (nbHits > 0) {
        this.find(indice.$templateWrapper).show();
        this.find(indice.$templateWrapper).closest(".JS-NavSearch-greyFrame").show();
      } else {
        this.find(indice.$templateWrapper).hide();
        this.find(indice.$templateWrapper).closest(".JS-NavSearch-greyFrame").hide();
      }
    }
  }, {
    key: "highlightSearchAndCut",
    value: function highlightSearchAndCut(data, maxWords) {
      if (data) {
        if (maxWords && data.split(" ").length >= maxWords) {
          data = data.split(" ").splice(0, maxWords).join(" ");
          data += '...';
        }

        var regex = new RegExp(this.query, "gi");
        data = data.replace(regex, '<span class="SearchResult-highlightText">$&</span>');
        return data;
      }
    }
  }, {
    key: "showVocalisationIcon",
    value: function showVocalisationIcon() {
      SearchAlgolia.find(".SearchForm-inputMicro").show();
    }
  }, {
    key: "hideVocalisationIcon",
    value: function hideVocalisationIcon() {
      SearchAlgolia.find(".SearchForm-inputMicro").hide();
    }
  }, {
    key: "getTemplateParameter",
    value: function getTemplateParameter(item, templateMapping) {
      var param = "";

      if (_typeof(templateMapping) === "object" && typeof item[templateMapping[0]] !== 'undefined') {
        param = item[templateMapping[0]][templateMapping[1]];
      }

      if (typeof templateMapping === "string") {
        param = item[templateMapping];
      }

      if (typeof param !== 'undefined' && param !== "" && param !== "false") {
        return param;
      } else {
        return false;
      }
    }
  }, {
    key: "templateParameterExist",
    value: function templateParameterExist(param) {
      return typeof param !== 'undefined' && param !== false && param !== "" && param !== "false";
    }
  }, {
    key: "templateGetMaxWords",
    value: function templateGetMaxWords(maxWords, defaultMaxWords) {
      return SearchAlgolia.templateParameterExist(maxWords) ? maxWords : defaultMaxWords;
    }
  }]);

  return SearchAlgolia;
}();

_defineProperty(SearchAlgolia, "debug", void 0);

_defineProperty(SearchAlgolia, "client", void 0);

_defineProperty(SearchAlgolia, "indexes", []);

_defineProperty(SearchAlgolia, "searchTimeout", false);

_defineProperty(SearchAlgolia, "sectionToManage", "");

_defineProperty(SearchAlgolia, "query", "");

_defineProperty(SearchAlgolia, "initConfig", void 0);

_defineProperty(SearchAlgolia, "initTabConfig", void 0);

_defineProperty(SearchAlgolia, "$searchDetails", $('.SearchDetails'));

_defineProperty(SearchAlgolia, "tabToGo", void 0);

_defineProperty(SearchAlgolia, "sections", {
  $page: $('.PageSearch'),
  $dropdown: $('.NavSearch'),
  $custom: $()
});

_defineProperty(SearchAlgolia, "config", new Map());

/***/ }),

/***/ "./src/modules/search/search-modal/search-modal.ts":
/*!*********************************************************!*\
  !*** ./src/modules/search/search-modal/search-modal.ts ***!
  \*********************************************************/
/*! exports provided: SearchModal */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "SearchModal", function() { return SearchModal; });
/* harmony import */ var _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../helper/responsive/responsive */ "./src/modules/helper/responsive/responsive.ts");
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }



var SearchModal =
/*#__PURE__*/
function () {
  function SearchModal() {
    _classCallCheck(this, SearchModal);
  }

  _createClass(SearchModal, null, [{
    key: "init",
    value: function init() {
      if (_helper_debug_debug__WEBPACK_IMPORTED_MODULE_1__["Debug"].isNotLoadedSwiper()) {
        return;
      }

      SearchModal.$element = $("#navSearchModal"); // TODO: Vérifier

      if (SearchModal.$element.length > 0) {
        SearchModal.events();
      }
    }
  }, {
    key: "events",
    value: function events() {
      $(".JS-NavSearchModal-open").on("click", function (e) {
        if (!_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__["Responsive"].isMin("minLg")) {
          SearchModal.$element.modal("toggle");
          $(this).toggleClass('isOpen');
        }
      });
      $(".HomeSearch").on("click", function (e) {
        if (!_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__["Responsive"].isMin("minLg")) {
          e.preventDefault();
          SearchModal.$element.modal("toggle");
        }
      });
      $(window).on("resize orientationchange", function () {
        if (_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__["Responsive"].isMin("minLg")) {
          SearchModal.$element.modal("hide");
        }
      });
      _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__["Responsive"].onWindowResize(function () {
        SearchModal.updateSwiper();
      });
      SearchModal.$element.on("shown.bs.modal", function () {
        SearchModal.updateSwiper();
        SearchModal.$element.find(".SearchForm-input").focus();
      });
      SearchModal.$element.on("hidden.bs.modal", function () {
        $(".MenuMobile-mainLinks-link.isOpen").removeClass("isOpen");
      });
    }
  }, {
    key: "updateSwiper",
    value: function updateSwiper() {
      if (_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__["Responsive"].isMin("minLg")) {
        SearchModal.destroySwiper();
      } else {
        if (!SearchModal.swiper) {
          SearchModal.createSwiper();
        } else {
          SearchModal.refreshSwiper();
        }
      }
    }
  }, {
    key: "destroySwiper",
    value: function destroySwiper() {
      if (SearchModal.swiper) {
        SearchModal.swiper.destroy(true, true);
        SearchModal.swiper = null;
      }
    }
  }, {
    key: "createSwiper",
    value: function createSwiper() {
      SearchModal.swiper = new Swiper(".Results-mobile.swiper-container", {
        slidesPerView: 1.05,
        spaceBetween: 10
      });
    }
  }, {
    key: "refreshSwiper",
    value: function refreshSwiper() {
      SearchModal.swiper.update();
    }
  }]);

  return SearchModal;
}();

_defineProperty(SearchModal, "element", void 0);

_defineProperty(SearchModal, "$element", void 0);

_defineProperty(SearchModal, "swiper", void 0);

/***/ }),

/***/ "./src/modules/search/search.module.ts":
/*!*********************************************!*\
  !*** ./src/modules/search/search.module.ts ***!
  \*********************************************/
/*! exports provided: SearchAlgolia, SearchModal, NavSearch */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _nav_search_nav_search__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./nav-search/nav-search */ "./src/modules/search/nav-search/nav-search.ts");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "NavSearch", function() { return _nav_search_nav_search__WEBPACK_IMPORTED_MODULE_0__["NavSearch"]; });

/* harmony import */ var _search_modal_search_modal__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./search-modal/search-modal */ "./src/modules/search/search-modal/search-modal.ts");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "SearchModal", function() { return _search_modal_search_modal__WEBPACK_IMPORTED_MODULE_1__["SearchModal"]; });

/* harmony import */ var _search_algolia__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./search-algolia */ "./src/modules/search/search-algolia.ts");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "SearchAlgolia", function() { return _search_algolia__WEBPACK_IMPORTED_MODULE_2__["SearchAlgolia"]; });






/***/ }),

/***/ "./src/modules/search/tabs/search-tabs.ts":
/*!************************************************!*\
  !*** ./src/modules/search/tabs/search-tabs.ts ***!
  \************************************************/
/*! exports provided: SearchTabs */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "SearchTabs", function() { return SearchTabs; });
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
/* harmony import */ var _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../helper/responsive/responsive */ "./src/modules/helper/responsive/responsive.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }



var SearchTabs =
/*#__PURE__*/
function () {
  function SearchTabs() {
    _classCallCheck(this, SearchTabs);
  }

  _createClass(SearchTabs, null, [{
    key: "init",
    // grid
    value: function init(searchTabsConfig) {
      $.each(searchTabsConfig, function (key, value) {
        value.disactiveIndexes = [];
        SearchTabs.tabs.set(key, value);
      });

      if ($('.SearchTabs').length === 0 || _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__["Debug"].isNotLoadedSwiper()) {
        return;
      }

      this.setDisplayMode();
      this.updateSearchSwiper();
      this.events();
    }
  }, {
    key: "events",
    value: function events() {
      // On click > Select
      $('.SearchTabs-item').on('click', function () {
        var $this = $(this);

        if ($this.hasClass('disabled')) {
          return;
        }

        var id = $this.attr('id');
        var tab = SearchTabs.findTabById(id);

        if (tab) {
          SearchTabs.select(tab);
        }
      });
      _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_1__["Responsive"].onWindowResize(function () {
        SearchTabs.updateSearchSwiper();
        SearchTabs.setDisplayMode();
      });
      $('.GridChange-changeMode button').on('click', function () {
        var $this = $(this);
        SearchTabs.displayMode = $this.data('mode');
        SearchTabs.setDisplayMode();
      });
    }
  }, {
    key: "findTabByIndex",
    value: function findTabByIndex(searchIndex) {
      var tab = undefined;
      this.tabs.forEach(function (value, key) {
        if (value.indexes.indexOf(searchIndex) !== -1) {
          tab = value;
        }
      });
      return tab;
    }
  }, {
    key: "findTabById",
    value: function findTabById(id) {
      var tab = undefined;
      this.tabs.forEach(function (value, key) {
        if (value.$tab.attr('id') === id) {
          tab = value;
        }
      });
      return tab;
    } // Update

  }, {
    key: "updateTab",
    value: function updateTab(index, resultsCount) {
      var tab = this.findTabByIndex(index);

      if (tab) {
        if (resultsCount > 0) {
          this.active(tab.$tab, resultsCount);
        } else {
          this.disactive(tab.$tab);
        }
      }
    }
  }, {
    key: "active",
    value: function active($tab, resultsCount) {
      $tab.removeClass('disabled');
      $tab.find('.SearchTabs-resultsCount').text("(".concat(resultsCount, ")"));
    }
  }, {
    key: "disactive",
    value: function disactive($tab) {
      $tab.addClass('disabled').removeClass('selected');
      $tab.find('.SearchTabs-resultsCount').text('');
    }
  }, {
    key: "selectByIndiceKey",
    value: function selectByIndiceKey(indiceKey) {
      var tab = this.findTabByIndex(indiceKey);

      if (tab) {
        this.select(tab);
      }
    }
  }, {
    key: "selectIfActiveIndiceKey",
    value: function selectIfActiveIndiceKey(indiceKey) {
      var selectedTab = this.getSelected();

      if (selectedTab === undefined) {
        this.selectByIndiceKey(indiceKey);
      } else {
        this.select(selectedTab);
      }
    }
  }, {
    key: "select",
    value: function select(tab) {
      // Hide All
      this.tabs.forEach(function (value) {
        value.$target.hide();
        value.$tab.removeClass('selected');
      }); // Show Selected

      tab.$tab.addClass('selected');
      tab.$target.show();

      if (this.swiper) {
        this.swiper.update();
      }
    }
  }, {
    key: "getSelected",
    value: function getSelected() {
      var tab = undefined;
      this.tabs.forEach(function (value) {
        if (value.$tab.hasClass('selected')) {
          tab = value;
        }
      });
      return tab;
    }
  }, {
    key: "resetInterface",
    value: function resetInterface() {
      var _this = this;

      this.tabs.forEach(function (value) {
        _this.disactive(value.$tab);
      });
    }
  }, {
    key: "updateSearchSwiper",
    value: function updateSearchSwiper() {
      if (_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_1__["Responsive"].isMin("minLg")) {
        this.destroySearchSwiper();
      } else {
        this.createSearchSwiper();
      }
    }
  }, {
    key: "destroySearchSwiper",
    value: function destroySearchSwiper() {
      if (this.swiper) {
        this.swiper.destroy(true, true);
        this.swiper = null;
        $(".SearchNav-item ").css("flex", "none");
      }
    }
  }, {
    key: "createSearchSwiper",
    value: function createSearchSwiper() {
      if (!this.swiper) {
        this.swiper = new Swiper(".SearchTabs", {
          slidesPerView: "auto",
          spaceBetween: 0
        });
      }
    }
  }, {
    key: "setDisplayMode",
    value: function setDisplayMode() {
      var $searchProductsWrapper = $(".PageSearch .SearchProduct-wrapper");
      var $gridChangeMode = $('.GridChange-changeMode');

      if (_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_1__["Responsive"].isMax("maxMd")) {
        this.displayMode = "row";
      }

      if (this.displayMode === "row") {
        $searchProductsWrapper.addClass('isRow');
        $gridChangeMode.find('[data-mode]').removeClass('isActive');
        $gridChangeMode.find('[data-mode=row]').addClass('isActive');
      } else {
        $searchProductsWrapper.removeClass('isRow');
        $gridChangeMode.find('[data-mode]').removeClass('isActive');
        $gridChangeMode.find('[data-mode=grid]').addClass('isActive');
      }
    }
  }]);

  return SearchTabs;
}();

_defineProperty(SearchTabs, "tabs", new Map());

_defineProperty(SearchTabs, "swiper", void 0);

_defineProperty(SearchTabs, "displayMode", "row");

_defineProperty(SearchTabs, "debug", new _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__["Debug"](true));

/***/ }),

/***/ "./src/modules/search/template/template-assistance.ts":
/*!************************************************************!*\
  !*** ./src/modules/search/template/template-assistance.ts ***!
  \************************************************************/
/*! exports provided: TemplateAssistance */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TemplateAssistance", function() { return TemplateAssistance; });
/* harmony import */ var _search_algolia__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../search-algolia */ "./src/modules/search/search-algolia.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var TemplateAssistance =
/*#__PURE__*/
function () {
  function TemplateAssistance() {
    _classCallCheck(this, TemplateAssistance);
  }

  _createClass(TemplateAssistance, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice) {
      var templateMapping = indice.templateAttributes;
      var titleMaxWords = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].templateGetMaxWords(templateMapping.titleMaxWords, 6);
      var descriptionMaxWords = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].templateGetMaxWords(templateMapping.descriptionMaxWords, 13);
      var title = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.title);
      var description = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.description);
      var url = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.url);

      if (title) {
        $templateTmp.find(".SearchResult-title").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(title, titleMaxWords));
      } else {
        $templateTmp.find(".SearchResult-title").remove();
      }

      if (description) {
        $templateTmp.find(".SearchResult-content").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(description, descriptionMaxWords));
      } else {
        $templateTmp.find(".SearchResult-content").remove();
      }

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      return $templateTmp;
    }
  }]);

  return TemplateAssistance;
}();

/***/ }),

/***/ "./src/modules/search/template/template-brand.ts":
/*!*******************************************************!*\
  !*** ./src/modules/search/template/template-brand.ts ***!
  \*******************************************************/
/*! exports provided: TemplateBrand */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TemplateBrand", function() { return TemplateBrand; });
/* harmony import */ var _search_algolia__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../search-algolia */ "./src/modules/search/search-algolia.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var TemplateBrand =
/*#__PURE__*/
function () {
  function TemplateBrand() {
    _classCallCheck(this, TemplateBrand);
  }

  _createClass(TemplateBrand, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice) {
      var templateMapping = indice.templateAttributes;
      var title = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.title);
      var imageUrl = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.imageUrl);
      var url = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.url);

      if (title) {
        $templateTmp.find(".SearchBrand-content").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(title));
      } else {
        $templateTmp.find(".SearchBrand-content").remove();
      }

      if (imageUrl) {
        $templateTmp.find(".SearchBrand-img").attr("src", imageUrl);
      } else {
        $templateTmp.find(".SearchBrand-img").remove();
      }

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      return $templateTmp;
    }
  }]);

  return TemplateBrand;
}();

/***/ }),

/***/ "./src/modules/search/template/template-magazine.ts":
/*!**********************************************************!*\
  !*** ./src/modules/search/template/template-magazine.ts ***!
  \**********************************************************/
/*! exports provided: TemplateMagazine */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TemplateMagazine", function() { return TemplateMagazine; });
/* harmony import */ var _search_algolia__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../search-algolia */ "./src/modules/search/search-algolia.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var TemplateMagazine =
/*#__PURE__*/
function () {
  function TemplateMagazine() {
    _classCallCheck(this, TemplateMagazine);
  }

  _createClass(TemplateMagazine, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice) {
      var templateMapping = indice.templateAttributes;
      var titleMaxWords = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].templateGetMaxWords(templateMapping.titleMaxWords, 6);
      var descriptionMaxWords = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].templateGetMaxWords(templateMapping.descriptionMaxWords, 13);
      var title = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.title);
      var url = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.url);
      var description = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.description);

      if (title) {
        $templateTmp.find(".SearchResult-title").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(title, titleMaxWords));
      } else {
        $templateTmp.find(".SearchResult-title").remove();
      }

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      if (description) {
        $templateTmp.find(".SearchResult-content").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(description, descriptionMaxWords));
      } else {
        $templateTmp.find(".SearchResult-content").remove();
      }

      return $templateTmp;
    }
  }]);

  return TemplateMagazine;
}();

/***/ }),

/***/ "./src/modules/search/template/template-modalResultCount.ts":
/*!******************************************************************!*\
  !*** ./src/modules/search/template/template-modalResultCount.ts ***!
  \******************************************************************/
/*! exports provided: TemplateModalResultCount */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TemplateModalResultCount", function() { return TemplateModalResultCount; });
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

var TemplateModalResultCount =
/*#__PURE__*/
function () {
  function TemplateModalResultCount() {
    _classCallCheck(this, TemplateModalResultCount);
  }

  _createClass(TemplateModalResultCount, null, [{
    key: "getTemplate",
    value: function getTemplate(blockToShow, nbHits) {
      var templateId = '#modalResultCountNull';

      if (nbHits === 1) {
        templateId = '#modalResultCountSingular';
      } else if (nbHits > 1) {
        templateId = '#modalResultCountPlural';
      }

      var $templateTmp = $($(templateId).clone().html().trim());
      $templateTmp.find('.Results-showHits').text(blockToShow);
      $templateTmp.find('.Results-totalHits').text(nbHits);
      return $templateTmp;
    }
  }]);

  return TemplateModalResultCount;
}();

/***/ }),

/***/ "./src/modules/search/template/template-product.ts":
/*!*********************************************************!*\
  !*** ./src/modules/search/template/template-product.ts ***!
  \*********************************************************/
/*! exports provided: TemplateProduct */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TemplateProduct", function() { return TemplateProduct; });
/* harmony import */ var _search_algolia__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../search-algolia */ "./src/modules/search/search-algolia.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var TemplateProduct =
/*#__PURE__*/
function () {
  function TemplateProduct() {
    _classCallCheck(this, TemplateProduct);
  }

  _createClass(TemplateProduct, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice) {
      var templateMapping = indice.templateAttributes;
      var titleMaxWords = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].templateGetMaxWords(templateMapping.titleMaxWords, 6);
      var descriptionMaxWords = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].templateGetMaxWords(templateMapping.descriptionMaxWords, 15);
      var url = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.url);
      var price = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.price);
      var imageUrl = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.imageUrl);
      var title = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.title);
      var description = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.description);

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      if (price) {
        var formattedPrice = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getFormatedPrice(index, item, price);
        $templateTmp.find(".SearchProduct-price").html(formattedPrice);
      } else {
        $templateTmp.find(".SearchProduct-price").remove();
      }

      if (imageUrl) {
        $templateTmp.find(".SearchProduct-imgWrapper img").attr('src', imageUrl);
      } else {
        $templateTmp.find(".SearchProduct-imgWrapper img").remove();
      }

      if (title) {
        $templateTmp.find(".SearchProduct-title").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(title, titleMaxWords));
      } else {
        $templateTmp.find(".SearchProduct-title").remove();
      }

      if (description) {
        $templateTmp.find(".SearchProduct-content").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(description, descriptionMaxWords));
      } else {
        $templateTmp.find(".SearchProduct-content").remove();
      }

      return $templateTmp;
    }
  }]);

  return TemplateProduct;
}();

/***/ }),

/***/ "./src/modules/search/template/template-resultCount.ts":
/*!*************************************************************!*\
  !*** ./src/modules/search/template/template-resultCount.ts ***!
  \*************************************************************/
/*! exports provided: TemplateResultCount */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TemplateResultCount", function() { return TemplateResultCount; });
/* harmony import */ var _search_algolia__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../search-algolia */ "./src/modules/search/search-algolia.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var TemplateResultCount =
/*#__PURE__*/
function () {
  function TemplateResultCount() {
    _classCallCheck(this, TemplateResultCount);
  }

  _createClass(TemplateResultCount, null, [{
    key: "getTemplate",
    value: function getTemplate(totalHits) {
      var templateId = '#resultCountNull';

      if (totalHits === 1) {
        templateId = '#resultCountSingular';
      } else if (totalHits > 1) {
        templateId = '#resultCountPlural';
      }

      var $templateTmp = $($(templateId).clone().html().trim());
      $templateTmp.find('.SearchDetails-count').text(totalHits);
      $templateTmp.find('.SearchDetails-keyword').text(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].query);
      return $templateTmp;
    }
  }]);

  return TemplateResultCount;
}();

/***/ }),

/***/ "./src/modules/search/template/template-service.ts":
/*!*********************************************************!*\
  !*** ./src/modules/search/template/template-service.ts ***!
  \*********************************************************/
/*! exports provided: TemplateService */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TemplateService", function() { return TemplateService; });
/* harmony import */ var _search_algolia__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../search-algolia */ "./src/modules/search/search-algolia.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var TemplateService =
/*#__PURE__*/
function () {
  function TemplateService() {
    _classCallCheck(this, TemplateService);
  }

  _createClass(TemplateService, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice) {
      var templateMapping = indice.templateAttributes;
      var fromText = $templateTmp.find('.SearchResult-price').data('from');
      var monthlyText = $templateTmp.find('.SearchResult-price').data('monthly');
      var titleMaxWords = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].templateGetMaxWords(templateMapping.titleMaxWords, 6);
      var descriptionMaxWords = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].templateGetMaxWords(templateMapping.descriptionMaxWords, 15);
      var url = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.url);
      var price1 = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.price1);
      var price2 = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.price2);
      var price3 = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.price3);
      var monthly = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.monthly);
      var commitment = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.commitment);
      var title = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.title);
      var description = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.description);

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      var prices = [];

      if (price1) {
        prices.push(price1);
      }

      if (price2) {
        prices.push(price2);
      }

      if (price3) {
        prices.push(price3);
      }

      var priceCount = prices.length;
      var lowerPrice = Math.min.apply(Math, prices);
      lowerPrice = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getFormatedPrice(index, item, lowerPrice);

      if (priceCount > 0) {
        var price = "";

        if (priceCount > 1) {
          price += fromText + " ";
        }

        price += lowerPrice;

        if (monthly && monthly !== "false") {
          price += monthlyText;
        }

        if (commitment) {
          price += " | " + commitment;
        }

        $templateTmp.find(".SearchResult-price").html(price);
      } else {
        $templateTmp.find(".SearchResult-price").remove();
      }

      if (title) {
        $templateTmp.find(".SearchResult-title").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(title, titleMaxWords));
      } else {
        $templateTmp.find(".SearchResult-title").remove();
      }

      if (description) {
        $templateTmp.find(".SearchResult-content").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(description, descriptionMaxWords));
      } else {
        $templateTmp.find(".SearchResult-content").remove();
      }

      return $templateTmp;
    }
  }]);

  return TemplateService;
}();

/***/ }),

/***/ "./src/modules/search/template/template-suggest.ts":
/*!*********************************************************!*\
  !*** ./src/modules/search/template/template-suggest.ts ***!
  \*********************************************************/
/*! exports provided: TemplateSuggest */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TemplateSuggest", function() { return TemplateSuggest; });
/* harmony import */ var _search_algolia__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../search-algolia */ "./src/modules/search/search-algolia.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var TemplateSuggest =
/*#__PURE__*/
function () {
  function TemplateSuggest() {
    _classCallCheck(this, TemplateSuggest);
  }

  _createClass(TemplateSuggest, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice) {
      var templateMapping = indice.templateAttributes;
      var query = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.query);

      if (query) {
        $templateTmp.text(query.charAt(0).toUpperCase() + query.slice(1));
        $templateTmp.attr('data-autosearch', query);
      }

      return $templateTmp;
    }
  }]);

  return TemplateSuggest;
}();

/***/ }),

/***/ "./src/modules/search/template/template-video.ts":
/*!*******************************************************!*\
  !*** ./src/modules/search/template/template-video.ts ***!
  \*******************************************************/
/*! exports provided: TemplateVideo */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TemplateVideo", function() { return TemplateVideo; });
/* harmony import */ var _search_algolia__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../search-algolia */ "./src/modules/search/search-algolia.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var TemplateVideo =
/*#__PURE__*/
function () {
  function TemplateVideo() {
    _classCallCheck(this, TemplateVideo);
  }

  _createClass(TemplateVideo, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice) {
      var templateMapping = indice.templateAttributes;
      var titleMaxWords = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].templateGetMaxWords(templateMapping.titleMaxWords, 4);
      var descriptionMaxWords = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].templateGetMaxWords(templateMapping.descriptionMaxWords, 10);
      var url = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.url);
      var title = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.title);
      var description = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.description);
      var imageUrl = _search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].getTemplateParameter(item, templateMapping.imageUrl);

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      if (title) {
        $templateTmp.find(".SearchVideo-title").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(title, titleMaxWords));
      } else {
        $templateTmp.find(".SearchVideo-title").remove();
      }

      if (description) {
        $templateTmp.find(".SearchVideo-content").html(_search_algolia__WEBPACK_IMPORTED_MODULE_0__["SearchAlgolia"].highlightSearchAndCut(description, descriptionMaxWords));
      } else {
        $templateTmp.find(".SearchVideo-content").remove();
      }

      if (imageUrl) {
        $templateTmp.find(".SearchVideo-img").attr('src', imageUrl);
      } else {
        $templateTmp.find(".SearchVideo-img").remove();
      }

      return $templateTmp;
    }
  }]);

  return TemplateVideo;
}();

/***/ })

}]);
//# sourceMappingURL=search-bundle.js.map