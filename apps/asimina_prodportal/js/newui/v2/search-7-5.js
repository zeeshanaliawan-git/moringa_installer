/*! Orange MEA 7.5.0 - new/1 - search - 2022-07-12T15:19:17.498Z */
(self["webpackChunkOrangeLibraryWebpack"] = self["webpackChunkOrangeLibraryWebpack"] || []).push([["search"],{

/***/ "./src/modules/menu/menu-mobile/menu-mobile.ts":
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "X": function() { return /* binding */ MenuMobile; }
/* harmony export */ });
/* harmony import */ var _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__("./src/modules/helper/responsive/responsive.ts");
/* harmony import */ var _ui_main_overlay_main_overlay__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__("./src/modules/ui/main-overlay/main-overlay.ts");
/* harmony import */ var gsap__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__("./node_modules/gsap/index.js");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }




var MenuMobile = /*#__PURE__*/function () {
  function MenuMobile() {
    _classCallCheck(this, MenuMobile);
  }

  _createClass(MenuMobile, null, [{
    key: "init",
    value: function init() {
      MenuMobile.$element = $(".MenuMobile");
      MenuMobile.element = MenuMobile.$element.get(0);
      MenuMobile.$trigger = $(".burgerIcon");
      MenuMobile.isOpening = false;
      MenuMobile.isClosing = false;

      if (MenuMobile.$element.length) {
        _ui_main_overlay_main_overlay__WEBPACK_IMPORTED_MODULE_1__/* .MainOverlay.addContent */ .i.addContent(MenuMobile.$element);
        MenuMobile.events();
      }
    }
  }, {
    key: "events",
    value: function events() {
      MenuMobile.$trigger.on("click", function () {
        if ($(this).hasClass("open")) {
          MenuMobile.closeSubMenu();
        } else {
          MenuMobile.openSubMenu();
        }
      });
      MenuMobile.$element.find(".MenuMobile-nav-link").on("click", function () {
        var el = $(this).siblings(".collapse");
        if ($('.MenuMobile').hasClass('isCdsVariant')) return;
        MenuMobile.goToSecondSlide(el);
      });
      MenuMobile.$element.find(".MenuMobile-subHeader").on("click", function () {
        MenuMobile.goToFirstSlide();
      });
      MenuMobile.$element.find(".MenuMobile-subItem-link").on("click", function () {
        var el = $(this).siblings(".MenuMobile-subSubNavWrapper");
        MenuMobile.goToThirdSlide(el);
      });
      MenuMobile.$element.find(".MenuMobile-subSubBack").on("click", function () {
        MenuMobile.backToSecondSlide();
      });
      MenuMobile.$element.find(".user-connexion-btn").on("click", function () {
        if ($(this).hasClass("open")) {
          $(this).removeClass("open");
          MenuMobile.$element.find(".ConnexionCart-offline").css({
            opacity: 0,
            visibility: "hidden"
          });
          MenuMobile.$element.find(".ConnexionCart-form").css({
            opacity: 0,
            visibility: "hidden"
          });
          MenuMobile.$element.find(".ConnexionCart-connected").css({
            opacity: 0,
            visibility: "hidden"
          });
          MenuMobile.$element.find(".user-connexion-triangle").css({
            opacity: 0,
            visibility: "hidden"
          });
        } else {
          $(this).addClass("open");
          MenuMobile.$element.find(".user-connexion-triangle").css({
            opacity: 1,
            visibility: "visible"
          });

          if ($(this).hasClass("connected")) {
            MenuMobile.$element.find(".ConnexionCart-connected").css({
              opacity: 1,
              visibility: "visible"
            });
          } else {
            MenuMobile.$element.find(".ConnexionCart-offline").css({
              opacity: 1,
              visibility: "visible"
            });
          }
        }
      });
      MenuMobile.$element.find(".ConnexionCart-close").on("click", function () {
        MenuMobile.$element.find(".user-connexion-btn").removeClass("open");
        MenuMobile.$element.find(".ConnexionCart").css({
          opacity: 0,
          visibility: "hidden"
        });
        MenuMobile.$element.find(".user-connexion-triangle").css({
          opacity: 0,
          visibility: "hidden"
        });
      });
      $("body").on("click", function (e) {
        var $clickedElement = $(e.target);
        var cartMenuIsClicked = $clickedElement.closest(".ConnexionCart, .user-connexion-btn").length;
        var menuIsClicked = $clickedElement.closest(MenuMobile.$trigger).length + $clickedElement.closest(MenuMobile.$element).length;

        if (menuIsClicked === 0) {
          MenuMobile.closeSubMenu();
        }

        if (cartMenuIsClicked === 0) {
          if (MenuMobile.$element.find(".user-connexion-btn").hasClass("open")) {
            MenuMobile.$element.find(".user-connexion-btn").removeClass("open");
            MenuMobile.$element.find(".ConnexionCart-offline").css({
              opacity: 0,
              visibility: "hidden"
            });
            MenuMobile.$element.find(".ConnexionCart-connected").css({
              opacity: 0,
              visibility: "hidden"
            });
            MenuMobile.$element.find(".ConnexionCart-form").css({
              opacity: 0,
              visibility: "hidden"
            });
            MenuMobile.$element.find(".user-connexion-triangle").css({
              opacity: 0,
              visibility: "hidden"
            });
          }
        }
      });
      MenuMobile.$element.find(".ConnexionCart-offline .ConnexionCart-btn > button").on("click", function () {
        MenuMobile.$element.find(".ConnexionCart-offline").css({
          opacity: 0,
          visibility: "hidden"
        });
        MenuMobile.$element.find(".ConnexionCart-form").css({
          opacity: 1,
          visibility: "visible"
        });
      });
      $(window).on('orientationchange', function () {
        MenuMobile.closeSubMenu();
        _ui_main_overlay_main_overlay__WEBPACK_IMPORTED_MODULE_1__/* .MainOverlay.hideOverlay */ .i.hideOverlay();
      });
      _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__/* .Responsive.onWindowResize */ .E.onWindowResize(function () {
        if (!_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__/* .Responsive.isMax */ .E.isMax('maxMd')) {
          MenuMobile.closeSubMenu();
          _ui_main_overlay_main_overlay__WEBPACK_IMPORTED_MODULE_1__/* .MainOverlay.hideOverlay */ .i.hideOverlay();
        } else {
          if (!MenuMobile.$trigger.hasClass('open')) MenuMobile.goToFirstSlide();
        }
      });
    }
  }, {
    key: "getMenuMaxHeight",
    value: function getMenuMaxHeight() {
      return _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_0__/* .Responsive.windowHeight */ .E.windowHeight() - MenuMobile.$element.height();
    }
  }, {
    key: "openSubMenu",
    value: function openSubMenu() {
      if (MenuMobile.$trigger.hasClass("open") || MenuMobile.isClosing) {
        return;
      }

      MenuMobile.isOpening = true;
      _ui_main_overlay_main_overlay__WEBPACK_IMPORTED_MODULE_1__/* .MainOverlay.showOverlay */ .i.showOverlay(MenuMobile.$trigger);
      $(document).trigger("MenuMobile:opening");
      gsap__WEBPACK_IMPORTED_MODULE_2__/* .gsap.to */ .p8.to(MenuMobile.$element.find(".MenuMobile-wrapper"), {
        duration: 0.5,
        y: "0%",
        autoAlpha: 1,
        zIndex: 1,
        onComplete: function onComplete() {
          MenuMobile.addScroll(MenuMobile.$element.find(".MenuMobile-collapse"));
          $(document).trigger("MenuMobile:open");
          MenuMobile.isOpening = false;
        }
      });
      MenuMobile.$trigger.addClass("open");
    }
  }, {
    key: "closeSubMenu",
    value: function closeSubMenu() {
      if (!MenuMobile.$trigger.hasClass("open") || MenuMobile.isOpening) {
        return;
      }

      MenuMobile.isClosing = true;
      _ui_main_overlay_main_overlay__WEBPACK_IMPORTED_MODULE_1__/* .MainOverlay.hideOverlay */ .i.hideOverlay();
      $(document).trigger("MenuMobile:closing");
      gsap__WEBPACK_IMPORTED_MODULE_2__/* .gsap.to */ .p8.to(MenuMobile.$element.find(".MenuMobile-wrapper"), {
        duration: 0.5,
        y: "-100%",
        autoAlpha: 0,
        zIndex: -1,
        onComplete: function onComplete() {
          MenuMobile.goToFirstSlide();
          MenuMobile.$element.find(".MenuMobile-wrapper").removeClass('isScrollable');
          $(document).trigger("MenuMobile:close");
          MenuMobile.isClosing = false;
        }
      });
      MenuMobile.$trigger.removeClass("open");
    }
  }, {
    key: "goToSecondSlide",
    value: function goToSecondSlide(elementToShow) {
      $(".MenuMobile-nav-panel").css({
        opacity: "0",
        visibility: "hidden"
      });
      elementToShow.css({
        opacity: "1",
        visibility: "visible"
      });
      MenuMobile.addScroll(elementToShow);
      var height = elementToShow.height();
      $('.MenuMobile-wrapper').height(height);

      if ($("html").attr("dir") === "rtl") {
        gsap__WEBPACK_IMPORTED_MODULE_2__/* .gsap.to */ .p8.to(MenuMobile.$element.find(".MenuMobile-collapse"), {
          duration: 0.5,
          x: "100%"
        });
      } else {
        gsap__WEBPACK_IMPORTED_MODULE_2__/* .gsap.to */ .p8.to(MenuMobile.$element.find(".MenuMobile-collapse"), {
          duration: 0.5,
          x: "-100%"
        });
      }
    }
  }, {
    key: "goToFirstSlide",
    value: function goToFirstSlide() {
      MenuMobile.addScroll(MenuMobile.$element.find(".MenuMobile-collapse"));
      gsap__WEBPACK_IMPORTED_MODULE_2__/* .gsap.to */ .p8.to(MenuMobile.$element.find(".MenuMobile-collapse"), {
        duration: 0.5,
        x: "0%"
      });
    }
  }, {
    key: "goToThirdSlide",
    value: function goToThirdSlide(elementToShow) {
      $(".MenuMobile-subSubNavWrapper").css({
        opacity: "0",
        visibility: "hidden"
      });
      MenuMobile.addScroll(elementToShow);
      elementToShow.css({
        opacity: "1",
        visibility: "visible"
      });

      if ($("html").attr("dir") === "rtl") {
        gsap__WEBPACK_IMPORTED_MODULE_2__/* .gsap.to */ .p8.to(MenuMobile.$element.find(".MenuMobile-collapse"), {
          duration: 0.5,
          x: "200%"
        });
      } else {
        gsap__WEBPACK_IMPORTED_MODULE_2__/* .gsap.to */ .p8.to(MenuMobile.$element.find(".MenuMobile-collapse"), {
          duration: 0.5,
          x: "-200%"
        });
      }
    }
  }, {
    key: "backToSecondSlide",
    value: function backToSecondSlide() {
      if ($("html").attr("dir") === "rtl") {
        gsap__WEBPACK_IMPORTED_MODULE_2__/* .gsap.to */ .p8.to(MenuMobile.$element.find(".MenuMobile-collapse"), {
          duration: 0.5,
          x: "100%"
        });
      } else {
        gsap__WEBPACK_IMPORTED_MODULE_2__/* .gsap.to */ .p8.to(MenuMobile.$element.find(".MenuMobile-collapse"), {
          duration: 0.5,
          x: "-100%"
        });
      }
    }
  }, {
    key: "addScroll",
    value: function addScroll($elementToShow) {
      var height = $elementToShow.height();
      var $menuMobileWrapper = $('.MenuMobile-wrapper');
      var maxHeight = MenuMobile.getMenuMaxHeight();
      $menuMobileWrapper.height(height);

      if (height > maxHeight) {
        $menuMobileWrapper.height("").addClass('isScrollable');
      } else {
        $menuMobileWrapper.height(height).removeClass('isScrollable');
      }
    }
  }]);

  return MenuMobile;
}();

_defineProperty(MenuMobile, "element", void 0);

_defineProperty(MenuMobile, "$element", void 0);

_defineProperty(MenuMobile, "$trigger", void 0);

_defineProperty(MenuMobile, "isOpening", void 0);

_defineProperty(MenuMobile, "isClosing", void 0);

/***/ }),

/***/ "./src/modules/search/search.module.ts":
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
// ESM COMPAT FLAG
__webpack_require__.r(__webpack_exports__);

// EXPORTS
__webpack_require__.d(__webpack_exports__, {
  "NavSearch": function() { return /* reexport */ NavSearch; },
  "NavSearchRefresh": function() { return /* reexport */ NavSearchRefresh; },
  "SearchAlgolia": function() { return /* reexport */ SearchAlgolia; },
  "SearchModal": function() { return /* reexport */ SearchModal; },
  "Vocalization": function() { return /* reexport */ Vocalization; }
});

// EXTERNAL MODULE: ./src/modules/helper/responsive/responsive.ts
var responsive = __webpack_require__("./src/modules/helper/responsive/responsive.ts");
// EXTERNAL MODULE: ./src/modules/ui/main-overlay/main-overlay.ts
var main_overlay = __webpack_require__("./src/modules/ui/main-overlay/main-overlay.ts");
// EXTERNAL MODULE: ./node_modules/gsap/index.js + 1 modules
var gsap = __webpack_require__("./node_modules/gsap/index.js");
// EXTERNAL MODULE: ./node_modules/gsap/gsap-core.js
var gsap_core = __webpack_require__("./node_modules/gsap/gsap-core.js");
;// CONCATENATED MODULE: ./src/modules/search/nav-search/nav-search.ts
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }




var NavSearch = /*#__PURE__*/function () {
  function NavSearch() {
    _classCallCheck(this, NavSearch);
  }

  _createClass(NavSearch, null, [{
    key: "init",
    value: function init() {
      NavSearch.$element = $(".NavSearch.isDropDown");
      NavSearch.element = NavSearch.$element.get(0);
      NavSearch.$trigger = $(".JS-NavSearchDropdown-open");
      NavSearch.isCdsVariant = NavSearch.$element.hasClass('isCdsVariant');
      NavSearch.isOpenOnTop = NavSearch.$element.hasClass('isOpenOnTop');

      if (NavSearch.$element.length > 0) {
        main_overlay/* MainOverlay.addTrigger */.i.addTrigger(NavSearch.$trigger);
        main_overlay/* MainOverlay.addContent */.i.addContent(NavSearch.$element);
        NavSearch.events();
        NavSearch.setMaxHeight();
        /* POUR L'OVERFLOW SCROLL */
      }
    }
  }, {
    key: "events",
    value: function events() {
      $(".JS-NavSearchDropdown-open").on("click", function () {
        if (responsive/* Responsive.isMin */.E.isMin("minLg") || NavSearch.isCdsVariant) {
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
        if (responsive/* Responsive.isMin */.E.isMin("minLg") || NavSearch.isCdsVariant) {
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
        if (!responsive/* Responsive.isMin */.E.isMin("minLg") || NavSearch.isOpenOnTop) {
          if (NavSearch.$element.attr("aria-expanded") === "true") {
            NavSearch.$element.attr("aria-expanded", "false");
            NavSearch.closeNavSearch();
            main_overlay/* MainOverlay.hideOverlay */.i.hideOverlay();
          }
        }
      });
    }
  }, {
    key: "openNavSearch",
    value: function openNavSearch() {
      $(document).trigger("MenuManager:openNavSearch");
      gsap/* gsap.set */.p8.set(NavSearch.$element, {
        display: 'block',
        height: "auto",
        overflow: 'auto'
      });
      gsap/* gsap.from */.p8.from(NavSearch.$element, {
        duration: 0.5,
        height: 0,
        overflow: 'hidden',
        display: 'block',
        ease: gsap_core/* Power2.easeOut */.Lp.easeOut,
        onStart: function onStart() {
          NavSearch.$element.scrollTop(0);
        },
        onComplete: function onComplete() {
          gsap/* gsap.set */.p8.set(NavSearch.$element, {
            height: "auto"
          });
        }
      });
      $(".search-btn").addClass("svgMenu");
      NavSearch.$element.find("input.SearchForm-input").trigger("focus");
      $(".JS-NavSearchDropdown-open").addClass("dropdownIsOpen");

      if (NavSearch.isCdsVariant) {
        $(".JS-NavSearchMobileDropdown").addClass("isOpen");
      }
    }
  }, {
    key: "closeNavSearch",
    value: function closeNavSearch() {
      gsap/* gsap.set */.p8.set(NavSearch.$element, {
        overflow: 'auto',
        display: 'block'
      });
      gsap/* gsap.to */.p8.to(NavSearch.$element, {
        duration: 0.5,
        height: 0,
        display: 'none',
        overflow: 'hidden',
        ease: gsap_core/* Power2.easeOut */.Lp.easeOut
      });
      $(".search-btn").removeClass("svgMenu"); // TODO: A voir

      $(".JS-NavSearchDropdown-open").removeClass("dropdownIsOpen");

      if (NavSearch.isCdsVariant) {
        $(".JS-NavSearchMobileDropdown").removeClass("isOpen");
      }
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

      var JSNavSearchDropdownOpen = $(".JS-NavSearchDropdown-open");

      if (scrollTop < 140) {
        maxHeight = windowHeight - 142;

        if (NavSearch.isOpenOnTop && !JSNavSearchDropdownOpen.hasClass('dropdownIsOpen')) {
          gsap/* gsap.set */.p8.set(JSNavSearchDropdownOpen, {
            pointerEvents: 'none'
          });
          NavSearch.$element.addClass('JS-blockClosing');
          NavSearch.$element.attr("aria-expanded", "false");
          main_overlay/* MainOverlay.hideOverlay */.i.hideOverlay();
          this.openNavSearch();
        }
      } else {
        maxHeight = windowHeight - 62;

        if (NavSearch.isOpenOnTop && JSNavSearchDropdownOpen.hasClass('dropdownIsOpen')) {
          gsap/* gsap.set */.p8.set(JSNavSearchDropdownOpen, {
            pointerEvents: 'all'
          });
          NavSearch.$element.removeClass('isOpenOnLoad JS-blockClosing');
          NavSearch.$element.attr("aria-expanded", "false");
          main_overlay/* MainOverlay.hideOverlay */.i.hideOverlay();
          this.closeNavSearch();
        }
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
// EXTERNAL MODULE: ./src/modules/helper/debug/debug.ts
var debug = __webpack_require__("./src/modules/helper/debug/debug.ts");
;// CONCATENATED MODULE: ./src/modules/search/search-modal/search-modal.ts
function search_modal_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function search_modal_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function search_modal_createClass(Constructor, protoProps, staticProps) { if (protoProps) search_modal_defineProperties(Constructor.prototype, protoProps); if (staticProps) search_modal_defineProperties(Constructor, staticProps); return Constructor; }

function search_modal_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }



var SearchModal = /*#__PURE__*/function () {
  function SearchModal() {
    search_modal_classCallCheck(this, SearchModal);
  }

  search_modal_createClass(SearchModal, null, [{
    key: "init",
    value: function init() {
      if (debug/* Debug.isNotLoadedSwiper */.c.isNotLoadedSwiper()) {
        return;
      }

      SearchModal.$element = $("#navSearchModal"); // TODO: VÃ©rifier

      if (SearchModal.$element.length > 0) {
        SearchModal.events();
      }
    }
  }, {
    key: "events",
    value: function events() {
      $(".JS-NavSearchModal-open").on("click", function (e) {
        if (!responsive/* Responsive.isMin */.E.isMin("minLg")) {
          $(document).trigger("MenuManager:openSearchModal");
          SearchModal.$element.modal("toggle");
          $(this).toggleClass('isOpen');
        }
      });
      $(".HomeSearch").on("click", function (e) {
        if (!responsive/* Responsive.isMin */.E.isMin("minLg")) {
          e.preventDefault();
          SearchModal.$element.modal("toggle");
        }
      });
      $(window).on("resize orientationchange", function () {
        if (responsive/* Responsive.isMin */.E.isMin("minLg")) {
          SearchModal.$element.modal("hide");
        }
      });
      responsive/* Responsive.onWindowResize */.E.onWindowResize(function () {
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
      if (responsive/* Responsive.isMin */.E.isMin("minLg")) {
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

search_modal_defineProperty(SearchModal, "element", void 0);

search_modal_defineProperty(SearchModal, "$element", void 0);

search_modal_defineProperty(SearchModal, "swiper", void 0);
;// CONCATENATED MODULE: ./src/modules/search/tabs/search-tabs.ts
function search_tabs_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function search_tabs_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function search_tabs_createClass(Constructor, protoProps, staticProps) { if (protoProps) search_tabs_defineProperties(Constructor.prototype, protoProps); if (staticProps) search_tabs_defineProperties(Constructor, staticProps); return Constructor; }

function search_tabs_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }




var SearchTabs = /*#__PURE__*/function () {
  function SearchTabs() {
    search_tabs_classCallCheck(this, SearchTabs);
  }

  search_tabs_createClass(SearchTabs, null, [{
    key: "init",
    // grid
    value: function init(searchTabsConfig) {
      $.each(searchTabsConfig, function (key, value) {
        value.disactiveIndexes = [];
        SearchTabs.tabs.set(key, value);
      });

      if ($('.SearchTabs').length === 0 || debug/* Debug.isNotLoadedSwiper */.c.isNotLoadedSwiper()) {
        return;
      }

      this.setDisplayMode();
      this.createSearchSwiper();
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
      responsive/* Responsive.onWindowResize */.E.onWindowResize(function () {
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

      if (SearchAlgolia.initConfig.hiddenTabs) {
        $tab.show();
      }

      $tab.find('.SearchTabs-resultsCount').text("(".concat(resultsCount, ")"));
    }
  }, {
    key: "disactive",
    value: function disactive($tab) {
      $tab.addClass('disabled').removeClass('selected');

      if (SearchAlgolia.initConfig.hiddenTabs && SearchAlgolia.query !== "") {
        $tab.hide();
      }

      if (SearchAlgolia.initConfig.hiddenTabs && SearchAlgolia.query === "") {
        $tab.show();
      }

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

      if (responsive/* Responsive.isMax */.E.isMax("maxMd")) {
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

search_tabs_defineProperty(SearchTabs, "tabs", new Map());

search_tabs_defineProperty(SearchTabs, "swiper", void 0);

search_tabs_defineProperty(SearchTabs, "displayMode", "row");

search_tabs_defineProperty(SearchTabs, "debug", new debug/* Debug */.c(true));
;// CONCATENATED MODULE: ./src/modules/search/template/template-product.ts
function template_product_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function template_product_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function template_product_createClass(Constructor, protoProps, staticProps) { if (protoProps) template_product_defineProperties(Constructor.prototype, protoProps); if (staticProps) template_product_defineProperties(Constructor, staticProps); return Constructor; }


var TemplateProduct = /*#__PURE__*/function () {
  function TemplateProduct() {
    template_product_classCallCheck(this, TemplateProduct);
  }

  template_product_createClass(TemplateProduct, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice, iteration) {
      var templateMapping = indice.templateAttributes;
      var titleMaxWords = SearchAlgolia.templateGetMaxWords(templateMapping.titleMaxWords, 6);
      var descriptionMaxWords = SearchAlgolia.templateGetMaxWords(templateMapping.descriptionMaxWords, 15);
      var url = SearchAlgolia.getTemplateParameter(item, templateMapping.url);
      var price = SearchAlgolia.getTemplateParameter(item, templateMapping.price);
      var imageUrl = SearchAlgolia.getTemplateParameter(item, templateMapping.imageUrl);
      var title = SearchAlgolia.getTemplateParameter(item, templateMapping.title);
      var description = SearchAlgolia.getTemplateParameter(item, templateMapping.description);

      if (title) {
        $templateTmp.attr('data-dl_event_label', title);
        $templateTmp.children("a").attr('data-dl_event_label', title);
        $templateTmp.attr('data-pi_name', title);
        $templateTmp.children("a").attr('data-pi_name', title);
      }

      if (price) {
        $templateTmp.attr('data-pi_price', price);
        $templateTmp.children("a").attr('data-pi_price', price);
        var formattedPrice = SearchAlgolia.getFormatedPrice(index, item, price).split(' ');
        var currency = formattedPrice[1];
        $templateTmp.attr('data-pi_currency', currency);
        $templateTmp.children("a").attr('data-pi_currency', currency);
      }

      if (iteration) {
        $templateTmp.attr('data-position', iteration);
      }

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      if (price) {
        var _formattedPrice = SearchAlgolia.getFormatedPrice(index, item, price);

        $templateTmp.find(".SearchProduct-price").html(_formattedPrice);
      } else {
        $templateTmp.find(".SearchProduct-price").remove();
      }

      var $img = $templateTmp.find(".SearchProduct-imgWrapper img");

      if (imageUrl) {
        $img.attr('src', imageUrl);
        SearchAlgolia.remplaceByFallBackImageEvent($img);
      } else {
        $img.remove();
      }

      if (title) {
        $templateTmp.find(".SearchProduct-title").html(SearchAlgolia.highlightSearchAndCut(title, titleMaxWords));
      } else {
        $templateTmp.find(".SearchProduct-title").remove();
      }

      if (description) {
        $templateTmp.find(".SearchProduct-content").html(SearchAlgolia.highlightSearchAndCut(description, descriptionMaxWords));
      } else {
        $templateTmp.find(".SearchProduct-content").remove();
      }

      SearchAlgolia.addTemplateSearchInsight(item, $templateTmp);
      return $templateTmp;
    }
  }]);

  return TemplateProduct;
}();
;// CONCATENATED MODULE: ./src/modules/search/template/template-service.ts
function template_service_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function template_service_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function template_service_createClass(Constructor, protoProps, staticProps) { if (protoProps) template_service_defineProperties(Constructor.prototype, protoProps); if (staticProps) template_service_defineProperties(Constructor, staticProps); return Constructor; }


var TemplateService = /*#__PURE__*/function () {
  function TemplateService() {
    template_service_classCallCheck(this, TemplateService);
  }

  template_service_createClass(TemplateService, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice, iteration) {
      var templateMapping = indice.templateAttributes;
      var fromText = $templateTmp.find('.SearchResult-price').data('from');
      var monthlyText = $templateTmp.find('.SearchResult-price').data('monthly');
      var titleMaxWords = SearchAlgolia.templateGetMaxWords(templateMapping.titleMaxWords, 6);
      var descriptionMaxWords = SearchAlgolia.templateGetMaxWords(templateMapping.descriptionMaxWords, 15);
      var url = SearchAlgolia.getTemplateParameter(item, templateMapping.url);
      var price1 = SearchAlgolia.getTemplateParameter(item, templateMapping.price1);
      var price2 = SearchAlgolia.getTemplateParameter(item, templateMapping.price2);
      var price3 = SearchAlgolia.getTemplateParameter(item, templateMapping.price3);
      var monthly = SearchAlgolia.getTemplateParameter(item, templateMapping.monthly);
      var commitment = SearchAlgolia.getTemplateParameter(item, templateMapping.commitment);
      var title = SearchAlgolia.getTemplateParameter(item, templateMapping.title);
      var description = SearchAlgolia.getTemplateParameter(item, templateMapping.description);

      if (title) {
        $templateTmp.attr('data-dl_event_label', title);
        $templateTmp.children("a").attr('data-dl_event_label', title);
      }

      if (iteration) {
        $templateTmp.attr('data-position', iteration);
      }

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
      lowerPrice = SearchAlgolia.getFormatedPrice(index, item, lowerPrice);

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
        $templateTmp.find(".SearchResult-title").html(SearchAlgolia.highlightSearchAndCut(title, titleMaxWords));
      } else {
        $templateTmp.find(".SearchResult-title").remove();
      }

      if (description) {
        $templateTmp.find(".SearchResult-content").html(SearchAlgolia.highlightSearchAndCut(description, descriptionMaxWords));
      } else {
        $templateTmp.find(".SearchResult-content").remove();
      }

      SearchAlgolia.addTemplateSearchInsight(item, $templateTmp);
      return $templateTmp;
    }
  }]);

  return TemplateService;
}();
;// CONCATENATED MODULE: ./src/modules/search/template/template-assistance.ts
function template_assistance_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function template_assistance_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function template_assistance_createClass(Constructor, protoProps, staticProps) { if (protoProps) template_assistance_defineProperties(Constructor.prototype, protoProps); if (staticProps) template_assistance_defineProperties(Constructor, staticProps); return Constructor; }


var TemplateAssistance = /*#__PURE__*/function () {
  function TemplateAssistance() {
    template_assistance_classCallCheck(this, TemplateAssistance);
  }

  template_assistance_createClass(TemplateAssistance, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice, iteration) {
      var templateMapping = indice.templateAttributes;
      var titleMaxWords = SearchAlgolia.templateGetMaxWords(templateMapping.titleMaxWords, 6);
      var descriptionMaxWords = SearchAlgolia.templateGetMaxWords(templateMapping.descriptionMaxWords, 13);
      var title = SearchAlgolia.getTemplateParameter(item, templateMapping.title);
      var description = SearchAlgolia.getTemplateParameter(item, templateMapping.description);
      var url = SearchAlgolia.getTemplateParameter(item, templateMapping.url);

      if (title) {
        $templateTmp.attr('data-dl_event_label', title);
        $templateTmp.children("a").attr('data-dl_event_label', title);
      }

      if (iteration) {
        $templateTmp.attr('data-position', iteration);
      }

      if (title) {
        $templateTmp.find(".SearchResult-title").html(SearchAlgolia.highlightSearchAndCut(title, titleMaxWords));
      } else {
        $templateTmp.find(".SearchResult-title").remove();
      }

      if (description) {
        $templateTmp.find(".SearchResult-content").html(SearchAlgolia.highlightSearchAndCut(description, descriptionMaxWords));
      } else {
        $templateTmp.find(".SearchResult-content").remove();
      }

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      SearchAlgolia.addTemplateSearchInsight(item, $templateTmp);
      return $templateTmp;
    }
  }]);

  return TemplateAssistance;
}();
;// CONCATENATED MODULE: ./src/modules/search/template/template-magazine.ts
function template_magazine_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function template_magazine_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function template_magazine_createClass(Constructor, protoProps, staticProps) { if (protoProps) template_magazine_defineProperties(Constructor.prototype, protoProps); if (staticProps) template_magazine_defineProperties(Constructor, staticProps); return Constructor; }


var TemplateMagazine = /*#__PURE__*/function () {
  function TemplateMagazine() {
    template_magazine_classCallCheck(this, TemplateMagazine);
  }

  template_magazine_createClass(TemplateMagazine, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice, iteration) {
      var templateMapping = indice.templateAttributes;
      var titleMaxWords = SearchAlgolia.templateGetMaxWords(templateMapping.titleMaxWords, 6);
      var descriptionMaxWords = SearchAlgolia.templateGetMaxWords(templateMapping.descriptionMaxWords, 13);
      var title = SearchAlgolia.getTemplateParameter(item, templateMapping.title);
      var url = SearchAlgolia.getTemplateParameter(item, templateMapping.url);
      var description = SearchAlgolia.getTemplateParameter(item, templateMapping.description);

      if (title) {
        $templateTmp.attr('data-dl_event_label', title);
        $templateTmp.children("a").attr('data-dl_event_label', title);
      }

      if (iteration) {
        $templateTmp.attr('data-position', iteration);
      }

      if (title) {
        $templateTmp.find(".SearchResult-title").html(SearchAlgolia.highlightSearchAndCut(title, titleMaxWords));
      } else {
        $templateTmp.find(".SearchResult-title").remove();
      }

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      if (description) {
        $templateTmp.find(".SearchResult-content").html(SearchAlgolia.highlightSearchAndCut(description, descriptionMaxWords));
      } else {
        $templateTmp.find(".SearchResult-content").remove();
      }

      SearchAlgolia.addTemplateSearchInsight(item, $templateTmp);
      return $templateTmp;
    }
  }]);

  return TemplateMagazine;
}();
;// CONCATENATED MODULE: ./src/modules/search/template/template-video.ts
function template_video_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function template_video_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function template_video_createClass(Constructor, protoProps, staticProps) { if (protoProps) template_video_defineProperties(Constructor.prototype, protoProps); if (staticProps) template_video_defineProperties(Constructor, staticProps); return Constructor; }


var TemplateVideo = /*#__PURE__*/function () {
  function TemplateVideo() {
    template_video_classCallCheck(this, TemplateVideo);
  }

  template_video_createClass(TemplateVideo, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice, iteration) {
      var templateMapping = indice.templateAttributes;
      var titleMaxWords = SearchAlgolia.templateGetMaxWords(templateMapping.titleMaxWords, 4);
      var descriptionMaxWords = SearchAlgolia.templateGetMaxWords(templateMapping.descriptionMaxWords, 10);
      var url = SearchAlgolia.getTemplateParameter(item, templateMapping.url);
      var title = SearchAlgolia.getTemplateParameter(item, templateMapping.title);
      var description = SearchAlgolia.getTemplateParameter(item, templateMapping.description);
      var imageUrl = SearchAlgolia.getTemplateParameter(item, templateMapping.imageUrl);

      if (title) {
        $templateTmp.attr('data-dl_event_label', title);
        $templateTmp.children("a").attr('data-dl_event_label', title);
      }

      if (iteration) {
        $templateTmp.attr('data-position', iteration);
      }

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      if (title) {
        $templateTmp.find(".SearchVideo-title").html(SearchAlgolia.highlightSearchAndCut(title, titleMaxWords));
      } else {
        $templateTmp.find(".SearchVideo-title").remove();
      }

      if (description) {
        $templateTmp.find(".SearchVideo-content").html(SearchAlgolia.highlightSearchAndCut(description, descriptionMaxWords));
      } else {
        $templateTmp.find(".SearchVideo-content").remove();
      }

      var $img = $templateTmp.find(".SearchVideo-img");

      if (imageUrl) {
        $img.attr('src', imageUrl);
        SearchAlgolia.remplaceByFallBackImageEvent($img);
      } else {
        $img.remove();
      }

      SearchAlgolia.addTemplateSearchInsight(item, $templateTmp);
      return $templateTmp;
    }
  }]);

  return TemplateVideo;
}();
;// CONCATENATED MODULE: ./src/modules/search/template/template-brand.ts
function template_brand_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function template_brand_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function template_brand_createClass(Constructor, protoProps, staticProps) { if (protoProps) template_brand_defineProperties(Constructor.prototype, protoProps); if (staticProps) template_brand_defineProperties(Constructor, staticProps); return Constructor; }


var TemplateBrand = /*#__PURE__*/function () {
  function TemplateBrand() {
    template_brand_classCallCheck(this, TemplateBrand);
  }

  template_brand_createClass(TemplateBrand, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice, iteration) {
      var templateMapping = indice.templateAttributes;
      var title = SearchAlgolia.getTemplateParameter(item, templateMapping.title);
      var imageUrl = SearchAlgolia.getTemplateParameter(item, templateMapping.imageUrl);
      var url = SearchAlgolia.getTemplateParameter(item, templateMapping.url);

      if (title) {
        $templateTmp.attr('data-dl_event_label', title);
        $templateTmp.children("a").attr('data-dl_event_label', title);
      }

      if (iteration) {
        $templateTmp.attr('data-position', iteration);
      }

      if (title) {
        $templateTmp.find(".SearchBrand-content").html(SearchAlgolia.highlightSearchAndCut(title));
      } else {
        $templateTmp.find(".SearchBrand-content").remove();
      }

      var $img = $templateTmp.find(".SearchBrand-img");

      if (imageUrl) {
        $img.attr('src', imageUrl);
        SearchAlgolia.remplaceByFallBackImageEvent($img);
      } else {
        $img.remove();
      }

      if (url) {
        $templateTmp.find("a").attr('href', url);
      } else {
        $templateTmp.find("a").removeAttr('href');
      }

      SearchAlgolia.addTemplateSearchInsight(item, $templateTmp);
      return $templateTmp;
    }
  }]);

  return TemplateBrand;
}();
;// CONCATENATED MODULE: ./src/modules/search/template/template-suggest.ts
function template_suggest_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function template_suggest_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function template_suggest_createClass(Constructor, protoProps, staticProps) { if (protoProps) template_suggest_defineProperties(Constructor.prototype, protoProps); if (staticProps) template_suggest_defineProperties(Constructor, staticProps); return Constructor; }



var TemplateSuggest = /*#__PURE__*/function () {
  function TemplateSuggest() {
    template_suggest_classCallCheck(this, TemplateSuggest);
  }

  template_suggest_createClass(TemplateSuggest, null, [{
    key: "getTemplate",
    value: function getTemplate(index, item, $templateTmp, indice, iteration) {
      var templateMapping = indice.templateAttributes;
      var query = SearchAlgolia.getTemplateParameter(item, templateMapping.query);

      if (query) {
        $templateTmp.text(this.fixAppleProducts(query.charAt(0).toUpperCase() + query.slice(1)));
        $templateTmp.attr('data-autosearch', query);
        $templateTmp.attr('data-dl_event_label', query);

        if (!responsive/* Responsive.isMin */.E.isMin("minLg") && document.querySelector(".NavSearch").classList.contains("SearchSuggest-swiper")) {
          $templateTmp.addClass('SearchSuggestFilter-item swiper-slide');
        }
      }

      SearchAlgolia.addTemplateSearchInsight(item, $templateTmp);
      return $templateTmp;
    }
  }, {
    key: "fixAppleProducts",
    value: function fixAppleProducts(obj) {
      var appleProducts = [{
        "name": "airpods",
        "value": "airPods"
      }, {
        "name": "ipad",
        "value": "iPad"
      }, {
        "name": "iphone",
        "value": "iPhone"
      }, {
        "name": "ipod",
        "value": "iPod"
      }, {
        "name": "macbook",
        "value": "MacBook"
      }];
      var result = obj;
      $.each(appleProducts, function (index, value) {
        var name = value["name"];

        if (obj && name && obj.toLowerCase().includes(name.toLowerCase())) {
          result = obj.replace(new RegExp(name, 'gi'), value["value"]);
        }
      });
      return result;
    }
  }]);

  return TemplateSuggest;
}();
// EXTERNAL MODULE: ./src/modules/menu/menu-mobile/menu-mobile.ts
var menu_mobile = __webpack_require__("./src/modules/menu/menu-mobile/menu-mobile.ts");
;// CONCATENATED MODULE: ./src/modules/search/nav-search-refresh/nav-search-refresh.ts
function nav_search_refresh_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function nav_search_refresh_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function nav_search_refresh_createClass(Constructor, protoProps, staticProps) { if (protoProps) nav_search_refresh_defineProperties(Constructor.prototype, protoProps); if (staticProps) nav_search_refresh_defineProperties(Constructor, staticProps); return Constructor; }

function nav_search_refresh_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }






var NavSearchRefresh = /*#__PURE__*/function () {
  function NavSearchRefresh() {
    nav_search_refresh_classCallCheck(this, NavSearchRefresh);
  }

  nav_search_refresh_createClass(NavSearchRefresh, null, [{
    key: "init",
    value: function init() {
      if (debug/* Debug.isNotLoadedSwiper */.c.isNotLoadedSwiper()) {
        return;
      }

      NavSearchRefresh.$element = $(".JS-nav-search-refresh");
      NavSearchRefresh.$trigger = $('.JS-NavSearchModal-open');

      if (NavSearchRefresh.$element.length > 0) {
        NavSearchRefresh.events();
        NavSearchRefresh.detectIfSearchShouldOpen();
      }
    }
  }, {
    key: "events",
    value: function events() {
      NavSearchRefresh.$trigger.on("click", function (e) {
        if (!responsive/* Responsive.isMin */.E.isMin("minLg")) {
          NavSearchRefresh.toggleDropdown();
        }
      });
      $(window).on("scroll resize orientationchange", function () {
        NavSearchRefresh.detectIfSearchShouldOpen();
      });
      responsive/* Responsive.onWindowResize */.E.onWindowResize(function () {
        NavSearchRefresh.detectIfSearchShouldOpen();
        NavSearchRefresh.updateSwiper();
      });
      $("body").on("click", function (e) {
        if (!responsive/* Responsive.isMin */.E.isMin("minLg")) {
          var $clickedElement = $(e.target);
          var searchMenuIsClicked = $clickedElement.closest(".NavSearch.isRefresh").length;

          if (searchMenuIsClicked === 0 && NavSearchRefresh.$element.find(".NavSearch-resultsContainer").is(":visible")) {
            SearchAlgolia.clearSearchInput();
          }
        }
      });
      $(document).on("MenuMobile:opening", function () {
        if (NavSearchRefresh.$element.hasClass("isOpen")) {
          NavSearchRefresh.$element.css({
            "z-index": -2
          });
        }
      });
      $(document).on("MenuMobile:open", function () {
        if (NavSearchRefresh.$element.hasClass("isOpen")) {
          NavSearchRefresh.$element.css({
            "display": "none"
          });
        }
      });
      $(document).on("MenuMobile:closing", function () {
        if (NavSearchRefresh.$element.length > 0) {
          NavSearchRefresh.$element.css({
            "display": "block"
          });
        }
      });
      $(document).on("MenuMobile:close", function () {
        if (NavSearchRefresh.$element.length > 0) {
          NavSearchRefresh.$element.css({
            "z-index": "auto"
          });
        }
      });
    }
  }, {
    key: "updateSwiper",
    value: function updateSwiper() {
      if (responsive/* Responsive.isMin */.E.isMin("minLg")) {
        NavSearchRefresh.destroySwiper();
      } else {
        if (!NavSearchRefresh.swiper || !NavSearchRefresh.swiperSearchSuggest || !NavSearchRefresh.swiperTopTendances) {
          NavSearchRefresh.createSwiper();
        } else {
          NavSearchRefresh.refreshSwiper();
        }
      }
    }
  }, {
    key: "destroySwiper",
    value: function destroySwiper() {
      if (NavSearchRefresh.swiper) {
        NavSearchRefresh.swiper.destroy(true, true);
        NavSearchRefresh.swiper = null;
      }

      if (NavSearchRefresh.swiperTopTendances) {
        NavSearchRefresh.swiperTopTendances.destroy(true, true);
        NavSearchRefresh.swiperTopTendances = null;
      }

      if (NavSearchRefresh.swiperSearchSuggest) {
        NavSearchRefresh.swiperSearchSuggest.destroy(true, true);
        NavSearchRefresh.swiperSearchSuggest = null;
      }
    }
  }, {
    key: "createSwiper",
    value: function createSwiper() {
      if (NavSearchRefresh.$element.find(".Results-mobile.swiper-container").length && !NavSearchRefresh.swiper) {
        NavSearchRefresh.swiper = new Swiper(NavSearchRefresh.$element.find(".Results-mobile.swiper-container"), {
          slidesPerView: 1.05,
          spaceBetween: 10
        });
      }

      if (!NavSearchRefresh.swiperSearchSuggest) {
        NavSearchRefresh.initSwiperSuggestion();
      }

      if (!NavSearchRefresh.swiperTopTendances) {
        NavSearchRefresh.initSwiperTopTendances();
      }
    }
  }, {
    key: "refreshSwiper",
    value: function refreshSwiper() {
      if (NavSearchRefresh.swiper) {
        NavSearchRefresh.swiper.update();
      }

      if (NavSearchRefresh.swiperSearchSuggest) {
        NavSearchRefresh.swiperSearchSuggest.update();
      }

      if (NavSearchRefresh.swiperTopTendances) {
        NavSearchRefresh.swiperTopTendances.update();
      }
    }
  }, {
    key: "toggleDropdown",
    value: function toggleDropdown() {
      if (NavSearchRefresh.$element.hasClass("isOpen")) {
        NavSearchRefresh.closeDropdown();
      } else {
        if ($(window).scrollTop() === 0) {
          NavSearchRefresh.openDropdown();
        } else {
          menu_mobile/* MenuMobile.closeSubMenu */.X.closeSubMenu();
          NavSearchRefresh.scrollTop();
        }
      }
    }
  }, {
    key: "openDropdown",
    value: function openDropdown() {
      $(document).trigger("MenuManager:openDropdownRefresh");
      NavSearchRefresh.canCloseDropdown = false;
      gsap/* gsap.set */.p8.set(NavSearchRefresh.$element, {
        display: 'block',
        height: "auto",
        overflow: 'auto'
      });
      gsap/* gsap.from */.p8.from(NavSearchRefresh.$element, {
        duration: 0.5,
        height: 0,
        overflow: 'hidden',
        display: 'block',
        ease: gsap_core/* Power2.easeOut */.Lp.easeOut,
        onStart: function onStart() {
          //  MainOverlay.showOverlay(NavSearchRefresh.$trigger);
          //  $('body').removeClass('modal-open');
          $('.MenuMobile-mainLinks-link.JS-NavSearchModal-open').hide();
        },
        onComplete: function onComplete() {
          gsap/* gsap.set */.p8.set(NavSearchRefresh.$element, {
            height: "auto"
          });
          NavSearchRefresh.updateSwiper();
          setTimeout(function () {
            NavSearchRefresh.canCloseDropdown = true;
          }, 100);
        }
      });
      NavSearchRefresh.$element.addClass("isOpen");
      NavSearchRefresh.$trigger.addClass('isOpen');
    }
  }, {
    key: "closeDropdown",
    value: function closeDropdown() {
      if (NavSearchRefresh.$element.hasClass('isOpen') && NavSearchRefresh.canCloseDropdown && $(window).scrollTop() > 190 || responsive/* Responsive.isMin */.E.isMin("minLg")) {
        gsap/* gsap.set */.p8.set(NavSearchRefresh.$element, {
          overflow: 'auto',
          display: 'block'
        });
        gsap/* gsap.to */.p8.to(NavSearchRefresh.$element, {
          duration: 0.5,
          height: 0,
          display: 'none',
          overflow: 'hidden',
          ease: gsap_core/* Power2.easeOut */.Lp.easeOut,
          onStart: function onStart() {
            //  MainOverlay.hideOverlay();
            $('.MenuMobile-mainLinks-link.JS-NavSearchModal-open').show();
          }
        });
        NavSearchRefresh.$element.removeClass("isOpen");
        NavSearchRefresh.$trigger.removeClass('isOpen');
        SearchAlgolia.clearSearchInput(); // On vide la recherche
      }
    }
  }, {
    key: "scrollTop",
    value: function scrollTop() {
      NavSearchRefresh.canCloseDropdown = false;
      var run = true;
      $("html, body").animate({
        scrollTop: 0
      }, {
        duration: 250,
        complete: function complete() {
          if (run) {
            run = false;
            NavSearchRefresh.openDropdown();
          }
        }
      });
    }
  }, {
    key: "detectIfSearchShouldOpen",
    value: function detectIfSearchShouldOpen() {
      if (!responsive/* Responsive.isMin */.E.isMin("minLg")) {
        if ($(window).scrollTop() <= 190) {
          if (!NavSearchRefresh.$element.hasClass("isOpen")) {
            NavSearchRefresh.openDropdown();
          }
        } else {
          if (NavSearchRefresh.$element.hasClass("isOpen")) {
            NavSearchRefresh.closeDropdown();
          }
        }
      } else {
        if (NavSearchRefresh.$element.hasClass("isOpen")) {
          NavSearchRefresh.closeDropdown();
        }
      }
    }
  }, {
    key: "initSwiperTopTendances",
    value: function initSwiperTopTendances() {
      var $element = NavSearchRefresh.$element.find(".TopTendances-swiper.swiper-container");

      if ($element.length) {
        NavSearchRefresh.swiperTopTendances = new Swiper($element, {
          slidesPerView: "auto",
          on: {
            beforeInit: function beforeInit() {
              if (document.dir === 'rtl') {
                NavSearchRefresh.sliderHideAfterGradient($element);
                NavSearchRefresh.sliderShowBeforeGradient($element);
              } else {
                NavSearchRefresh.sliderHideBeforeGradient($element);
                NavSearchRefresh.sliderShowAfterGradient($element);
              }
            },
            reachBeginning: function reachBeginning() {
              if (document.dir === 'rtl') {
                NavSearchRefresh.sliderHideAfterGradient($element);
              } else {
                NavSearchRefresh.sliderHideBeforeGradient($element);
              }
            },
            sliderMove: function sliderMove() {
              NavSearchRefresh.sliderShowBeforeGradient($element);
              NavSearchRefresh.sliderShowAfterGradient($element);
            },
            setTranslate: function setTranslate(position) {
              if (position === 0) {
                if (document.dir === 'rtl') {
                  NavSearchRefresh.sliderHideAfterGradient($element);
                } else {
                  NavSearchRefresh.sliderHideBeforeGradient($element);
                }
              }
            },
            reachEnd: function reachEnd() {
              if (document.dir === 'rtl') {
                NavSearchRefresh.sliderHideBeforeGradient($element);
              } else {
                NavSearchRefresh.sliderHideAfterGradient($element);
              }
            }
          }
        });
      }
    }
  }, {
    key: "initSwiperSuggestion",
    value: function initSwiperSuggestion() {
      var $element = NavSearchRefresh.$element.find(".SearchSuggest-swiper.swiper-container");

      if ($element.length) {
        NavSearchRefresh.swiperSearchSuggest = new Swiper($element, {
          slidesPerView: "auto",
          on: {
            beforeInit: function beforeInit() {
              if (document.dir === 'rtl') {
                NavSearchRefresh.sliderHideAfterGradient($element);
                NavSearchRefresh.sliderShowBeforeGradient($element);
              } else {
                NavSearchRefresh.sliderHideBeforeGradient($element);
                NavSearchRefresh.sliderShowAfterGradient($element);
              }
            },
            reachBeginning: function reachBeginning() {
              if (document.dir === 'rtl') {
                NavSearchRefresh.sliderHideAfterGradient($element);
              } else {
                NavSearchRefresh.sliderHideBeforeGradient($element);
              }
            },
            sliderMove: function sliderMove() {
              NavSearchRefresh.sliderShowBeforeGradient($element);
              NavSearchRefresh.sliderShowAfterGradient($element);
            },
            setTranslate: function setTranslate(position) {
              if (position === 0) {
                if (document.dir === 'rtl') {
                  NavSearchRefresh.sliderHideAfterGradient($element);
                } else {
                  NavSearchRefresh.sliderHideBeforeGradient($element);
                }
              }
            },
            reachEnd: function reachEnd() {
              if (document.dir === 'rtl') {
                NavSearchRefresh.sliderHideBeforeGradient($element);
              } else {
                NavSearchRefresh.sliderHideAfterGradient($element);
              }
            }
          }
        });
      }
    }
  }, {
    key: "sliderShowBeforeGradient",
    value: function sliderShowBeforeGradient($el) {
      if (!$el.hasClass('hasBeforeGradient')) {
        $el.addClass('hasBeforeGradient');
      }
    }
  }, {
    key: "sliderHideBeforeGradient",
    value: function sliderHideBeforeGradient($el) {
      if ($el.hasClass('hasBeforeGradient')) {
        $el.removeClass('hasBeforeGradient');
      }
    }
  }, {
    key: "sliderShowAfterGradient",
    value: function sliderShowAfterGradient($el) {
      if (!$el.hasClass('hasAfterGradient')) {
        $el.addClass('hasAfterGradient');
      }
    }
  }, {
    key: "sliderHideAfterGradient",
    value: function sliderHideAfterGradient($el) {
      if ($el.hasClass('hasAfterGradient')) {
        $el.removeClass('hasAfterGradient');
      }
    }
  }]);

  return NavSearchRefresh;
}();

nav_search_refresh_defineProperty(NavSearchRefresh, "$element", void 0);

nav_search_refresh_defineProperty(NavSearchRefresh, "$trigger", void 0);

nav_search_refresh_defineProperty(NavSearchRefresh, "canCloseDropdown", true);

nav_search_refresh_defineProperty(NavSearchRefresh, "swiperSearchSuggest", void 0);

nav_search_refresh_defineProperty(NavSearchRefresh, "swiperTopTendances", void 0);

nav_search_refresh_defineProperty(NavSearchRefresh, "swiper", void 0);
// EXTERNAL MODULE: ./node_modules/query-string-for-all/dist/index.js
var dist = __webpack_require__("./node_modules/query-string-for-all/dist/index.js");
;// CONCATENATED MODULE: ./src/modules/search/template/template-resultCount.ts
function template_resultCount_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function template_resultCount_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function template_resultCount_createClass(Constructor, protoProps, staticProps) { if (protoProps) template_resultCount_defineProperties(Constructor.prototype, protoProps); if (staticProps) template_resultCount_defineProperties(Constructor, staticProps); return Constructor; }


var TemplateResultCount = /*#__PURE__*/function () {
  function TemplateResultCount() {
    template_resultCount_classCallCheck(this, TemplateResultCount);
  }

  template_resultCount_createClass(TemplateResultCount, null, [{
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
      $templateTmp.find('.SearchDetails-keyword').text(SearchAlgolia.query);
      return $templateTmp;
    }
  }]);

  return TemplateResultCount;
}();
;// CONCATENATED MODULE: ./src/modules/search/template/template-modalResultCount.ts
function template_modalResultCount_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function template_modalResultCount_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function template_modalResultCount_createClass(Constructor, protoProps, staticProps) { if (protoProps) template_modalResultCount_defineProperties(Constructor.prototype, protoProps); if (staticProps) template_modalResultCount_defineProperties(Constructor, staticProps); return Constructor; }

var TemplateModalResultCount = /*#__PURE__*/function () {
  function TemplateModalResultCount() {
    template_modalResultCount_classCallCheck(this, TemplateModalResultCount);
  }

  template_modalResultCount_createClass(TemplateModalResultCount, null, [{
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
// EXTERNAL MODULE: ./src/ts/tools.ts
var tools = __webpack_require__("./src/ts/tools.ts");
// EXTERNAL MODULE: ./node_modules/search-insights/index-browser.cjs.js
var index_browser_cjs = __webpack_require__("./node_modules/search-insights/index-browser.cjs.js");
var index_browser_cjs_default = /*#__PURE__*/__webpack_require__.n(index_browser_cjs);
;// CONCATENATED MODULE: ./src/modules/search/search-algolia.ts
function _typeof(obj) { "@babel/helpers - typeof"; if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

function _createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function search_algolia_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function search_algolia_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function search_algolia_createClass(Constructor, protoProps, staticProps) { if (protoProps) search_algolia_defineProperties(Constructor.prototype, protoProps); if (staticProps) search_algolia_defineProperties(Constructor, staticProps); return Constructor; }

function search_algolia_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

















 // INIT CONFIG INTERFACES

var SectionToManage;

(function (SectionToManage) {
  SectionToManage["modal"] = "modal";
  SectionToManage["page"] = "page";
  SectionToManage["dropdown"] = "dropdown";
  SectionToManage["mobileDropdown"] = "mobileDropdown";
  SectionToManage["custom"] = "custom";
})(SectionToManage || (SectionToManage = {}));

var SearchAlgolia = /*#__PURE__*/function () {
  function SearchAlgolia() {
    search_algolia_classCallCheck(this, SearchAlgolia);
  }

  search_algolia_createClass(SearchAlgolia, null, [{
    key: "init",

    /* NavSearch || PageSearch || ModalSearch */
    value: function init() {
      this.initConfig = window.searchAlgoliaConfig;
      this.initTabConfig = window.searchTabsConfig;
      $.each(SearchAlgolia.initConfig.indices, function (key, value) {
        SearchAlgolia.config.set(key, value);
      });
      this.debug = new debug/* Debug */.c(false);
      this.debug.log('SearchAlgolia - init()');

      if (debug/* Debug.isNotLoadedAlgoliaSearch */.c.isNotLoadedAlgoliaSearch()) {
        return;
      }

      this.tabToGo = {};
      SearchTabs.init(this.initTabConfig);
      this.manageAlgoliaSearch();
    }
  }, {
    key: "manageAlgoliaSearch",
    value: function manageAlgoliaSearch() {
      var _this = this;

      this.alreadyInit = false;

      if ($('.SearchForm-input').is(":visible")) {
        _this.algoliaSearchInit();
      }

      $(document).on("MenuManager:openNavSearch MenuManager:openSearchModal MenuManager:openDropdownRefresh", function () {
        _this.algoliaSearchInit();
      });
    }
  }, {
    key: "algoliaSearchInit",
    value: function algoliaSearchInit() {
      if (!this.alreadyInit) {
        this.alreadyInit = true;
        this.algoliaSetup();
        this.setTopTendances();
        this.events();
      }
    }
  }, {
    key: "algoliaSetup",
    value: function algoliaSetup() {
      var _this2 = this;

      // Initialize Algolia client
      this.client = algoliasearch(this.initConfig.algolia.applicationId, this.initConfig.algolia.apiKey); // Initialize Algolia Search Insight

      index_browser_cjs_default()('init', {
        appId: this.initConfig.algolia.applicationId,
        apiKey: this.initConfig.algolia.apiKey,
        useCookie: true,
        // since v2, this is false by default
        cookieDuration: 60 * 60 * 1000 // one hour, in milliseconds (default: 15552000000)

      }); // Initialize userToken

      index_browser_cjs_default()('getUserToken', null, function (err, userToken) {
        if (err) {
          console.error(err);
          return;
        }

        _this2.userToken = userToken;
      });
      this.config.forEach(function (indice, indiceName) {
        if (indice.indiceKey) {
          // Indexes fusions
          var fusion = [];
          SearchTabs.tabs.forEach(function (tab, tabName) {
            if (tab.indexes.indexOf(indiceName) >= 0) {
              fusion = tab.indexes;
            }
          });

          if (fusion.length > 0) {
            indice.fusion = fusion;
          } else {
            indice.fusion = false;
          } // HTTP Verification


          _this2.client.search([{
            indexName: indice.indiceKey,
            query: '',
            params: {
              hitsPerPage: 0
            }
          }]).catch(function (err) {
            var tab = SearchTabs.findTabByIndex(indiceName);

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
            SearchAlgolia.config.delete(indiceName);
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

      if (!this.config.has('suggest')) {
        return;
      }

      var suggestIndiceKey = this.config.get('suggest').indiceKey;
      var queries = [];
      queries.push({
        indexName: suggestIndiceKey,
        query: '',
        params: {
          userToken: this.userToken,
          clickAnalytics: true,
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
        var results = response.results[0];
        var indice = SearchAlgolia.config.get('suggest');
        indice.response = results;

        if (indice.response.hits) {
          $.each(indice.response.hits, function (index, item) {
            SearchAlgolia.hydrateInsightDatas(indice, item, index + 1);

            if (item.query) {
              var $templateTmp;

              if (!responsive/* Responsive.isMin */.E.isMin("minLg") && document.querySelector(".NavSearch").classList.contains("TopTendances-swiper")) {
                $templateTmp = $('<li class="etn-data-layer-event" data-dl_event_category="TopTendances" data-dl_event_action="button_click" data-dl_event_label="' + SearchAlgolia.fixAppleProducts(item.query) + '" data-autosearch="' + SearchAlgolia.fixAppleProducts(item.query) + '">' + SearchAlgolia.fixAppleProducts(item.query) + '</li>');
              } else {
                $templateTmp = $('<li class="TopTendances-item swiper-slide etn-data-layer-event" data-dl_event_category="TopTendances" data-dl_event_action="button_click" data-dl_event_label="' + SearchAlgolia.fixAppleProducts(item.query) + '" data-autosearch="' + SearchAlgolia.fixAppleProducts(item.query) + '">' + SearchAlgolia.fixAppleProducts(item.query) + '</li>');
              }

              SearchAlgolia.addTemplateSearchInsight(item, $templateTmp);
              $(".TopTendances-items").append($templateTmp);
            }
          });
        }
      }
    }
  }, {
    key: "fixAppleProducts",
    value: function fixAppleProducts(obj) {
      var appleProducts = [{
        "name": "airpods",
        "value": "airPods"
      }, {
        "name": "ipad",
        "value": "iPad"
      }, {
        "name": "iphone",
        "value": "iPhone"
      }, {
        "name": "ipod",
        "value": "iPod"
      }, {
        "name": "macbook",
        "value": "MacBook"
      }];
      var result = obj;
      $.each(appleProducts, function (index, value) {
        var name = value["name"];

        if (obj && name && obj.toLowerCase().includes(name.toLowerCase())) {
          result = obj.replace(new RegExp(name, 'gi'), value["value"]);
        }
      });
      return result;
    } // Affichage du composant Top Tendances

  }, {
    key: "showTopTendances",
    value: function showTopTendances() {
      this.find('.TopTendances').show();
    } // Masquage du composant Top Tendances

  }, {
    key: "hideTopTendances",
    value: function hideTopTendances() {
      this.find('.TopTendances').hide();
    }
  }, {
    key: "resetSearch",
    value: function resetSearch() {
      var _this3 = this;

      var indexes = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
      this.config.forEach(function (value, key, map) {
        if (indexes.length > 0 && indexes.indexOf(key) === -1) {
          return;
        }

        _this3.config.get(key).response = {
          hits: [],
          nbHits: 0,
          page: 0
        };
      });
    }
  }, {
    key: "find",
    value: function find(selector) {
      return this.getSection$element().find(selector);
    }
  }, {
    key: "getSection$element",
    value: function getSection$element() {
      switch (this.sectionToManage) {
        case 'dropdown':
          return this.sections.$dropdown;

        case 'mobileDropdown':
          return this.sections.$dropdown;

        case 'page':
          return this.sections.$page;

        default:
          return this.sections.$custom;
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
      $(document).on('click', '.JS-SearchAlgolia-isTracked', function () {
        var $this = $(this);
        var insightsSearchClickEvent = $this.data("algoliaInsightsSearchClickEvent");

        if (insightsSearchClickEvent) {
          SearchAlgolia.updateSectionToManage($this);
          insightsSearchClickEvent.eventName = 'clickOnResult-' + SearchAlgolia.sectionToManage;
          index_browser_cjs_default()('clickedObjectIDsAfterSearch', insightsSearchClickEvent);
        }
      });
    }
  }, {
    key: "remplaceByFallBackImageEvent",
    value: function remplaceByFallBackImageEvent($image) {
      $image.on('error', function () {
        if (SearchAlgolia.initConfig.imageFallback) {
          $image.attr('src', SearchAlgolia.initConfig.imageFallback);
        } else {
          $image.remove();
        }
      });
    }
  }, {
    key: "gotoSearchPageEvent",
    value: function gotoSearchPageEvent() {
      $(".JS-SearchAlgolia-submitForm").on('click', function () {
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
      if ($element.parents('.NavSearch:not(.isRefresh)').length > 0) {
        if (SearchAlgolia.sectionToManage !== SectionToManage.dropdown) {
          SearchAlgolia.clearSearchInput();
        }

        SearchAlgolia.sectionToManage = SectionToManage.dropdown;
      } else if ($element.parents('.NavSearch.isRefresh').length > 0) {
        if (SearchAlgolia.sectionToManage !== SectionToManage.mobileDropdown) {
          SearchAlgolia.clearSearchInput();
        }

        SearchAlgolia.sectionToManage = SectionToManage.mobileDropdown;
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
    } // evenements lors de la saisie dans l'input de recherche

  }, {
    key: "inputEvent",
    value: function inputEvent() {
      this.debug.log('SearchAlgolia - inputEvent() registred'); // @ts-ignore

      $("input.SearchForm-input:not([data-search])").on("input paste change", function (event, data) {
        SearchAlgolia.debug.log('SearchAlgolia - inputEvent() input...');
        var $this = $(this);
        var query = $this.val().toString();

        if ($this.parents('.NavSearch:not(.isRefresh)').length > 0) {
          if (SearchAlgolia.sectionToManage === SectionToManage.page || SearchAlgolia.sectionToManage === SectionToManage.mobileDropdown) {
            SearchAlgolia.clearSearchInput();
          }

          SearchAlgolia.sectionToManage = SectionToManage.dropdown;
        } else if ($this.parents('.NavSearch.isRefresh').length > 0) {
          if (SearchAlgolia.sectionToManage === SectionToManage.page || SearchAlgolia.sectionToManage === SectionToManage.dropdown) {
            SearchAlgolia.clearSearchInput();
          }

          SearchAlgolia.sectionToManage = SectionToManage.mobileDropdown;
        } else {
          if (SearchAlgolia.sectionToManage === SectionToManage.dropdown || SearchAlgolia.sectionToManage === SectionToManage.mobileDropdown) {
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

      $("input.SearchForm-input[data-search]").on("input paste change", function (event, data) {
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
                mobileDropdown: dataSearch.blockToShow,
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
    } // gestion de l'interface et appel de la fonction search

  }, {
    key: "manageSearchQuery",
    value: function manageSearchQuery(query, indexes) {
      if (query) {
        // le terme de la recherche est stockÃ© dans une variable globale et pourra Ãªtre accessible depuis n'importe quelle fonction
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
        SearchTabs.resetInterface();
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
        $(document).trigger("Search:showResults");
      }

      SearchModal.updateSwiper();
      NavSearchRefresh.updateSwiper();
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

        SearchTabs.select(tab);
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
    key: "isMobileDropdown",
    value: function isMobileDropdown() {
      return this.sectionToManage === SectionToManage.mobileDropdown;
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
      var _this4 = this;

      if (this.isDropdown() || this.isMobileDropdown()) {
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

        if (_this4.getRealHitsCount(value) > 0) {
          indexToShow = key;
        }
      });

      if (this.isPage()) {
        SearchTabs.selectIfActiveIndiceKey(indexToShow);
      }
    }
  }, {
    key: "hideResultsBlock",
    value: function hideResultsBlock() {
      if (SearchAlgolia.isDropdown() || SearchAlgolia.isMobileDropdown()) {
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
      var hash = dist.parse(location.hash);
      var search = dist.parse(location.search);

      if (typeof hash.SearchTabs !== 'undefined') {
        this.tabToGo = SearchTabs.findTabByIndex(hash.SearchTabs.toString());
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
        var $searchInput = $(this).parents(".NavSearch").find("input.SearchForm-input");

        if ($searchInput.length === 0) {
          $searchInput = SearchAlgolia.find("input.SearchForm-input");
        }

        if (query) {
          $searchInput.val(query);
          $searchInput.trigger("input", [true]);
        }
      });
    }
    /* Callback this = Response */
    // fonction appelÃ©e par la fonction Search()

  }, {
    key: "saveSearch",
    value: function saveSearch(err) {
      var response = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : [];

      if (!err && response.results && response.results.length > 0) {
        // response.results va contenir l'ensemble des rÃ©sultats pour chaque index
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
    } // point d'entrÃ©e de la recherche

  }, {
    key: "search",
    value: function search() {
      var _this5 = this;

      var indexes = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : [];
      SearchAlgolia.debug.log('SearchAlgolia - search()');
      var queries = []; // boucle sur chaque index

      this.config.forEach(function (value, key, map) {
        if (indexes.length > 0 && indexes.indexOf(key) === -1 || value.indiceKey === false) {
          return;
        }

        queries.push({
          indexName: value.indiceKey,
          query: _this5.query,
          // le terme de la recherche, stockÃ© en variable globale
          params: {
            userToken: _this5.userToken,
            clickAnalytics: true,
            page: value.response.page,
            hitsPerPage: value.blockToShow[_this5.sectionToManage]
          }
        });
      });
      this.client.search(queries, SearchAlgolia.saveSearch);
    }
  }, {
    key: "getBlockToShowCount",
    value: function getBlockToShowCount(indice) {
      if (SearchAlgolia.isDropdown() || SearchAlgolia.isMobileDropdown()) {
        return indice.blockToShow.dropdown;
      }

      return indice.blockToShow.page;
    }
  }, {
    key: "getRealBlockToShowGroupCount",
    value: function getRealBlockToShowGroupCount(indexes) {
      var _this6 = this;

      var blockToShow = 0;
      indexes.forEach(function (value) {
        var indice = _this6.config.get(value);

        if (_this6.getRealHitsCount(indice) > 0) {
          blockToShow += _this6.getBlockToShowCount(_this6.config.get(value));
        }
      });
      return blockToShow;
    } // Gestion de l'affichage de l'ensemble des rÃ©sultats
    // cette fonction sera appelÃ©e pour chaque index par la fonction saveSearch()

  }, {
    key: "showResults",
    value: function showResults(index) {
      SearchAlgolia.debug.log('SearchAlgolia - showResults() : ' + index);
      var indice = this.config.get(index);
      var nbHits = this.getRealHitsCount(indice);
      var blockToShow = this.getBlockToShowCount(indice);

      if (nbHits === 0) {
        this.find(indice.$component).hide(); // masquage des diffÃ©rents blocs de rÃ©sultat (bloc produit, bloc service, etc...) au niveau de la page des rÃ©sultats
      } else {
        this.find(indice.$component).show(); // affichage des diffÃ©rents blocs de rÃ©sultat (bloc produit, bloc service, etc...) au niveau de la page des rÃ©sultats
      }

      if (this.sectionToManage === SectionToManage.dropdown || this.sectionToManage === SectionToManage.mobileDropdown) {
        this.updateNavSearchShowMoreButtons(index, blockToShow, nbHits);
      }

      if (typeof indice.fusion !== 'boolean') {
        nbHits = this.getRealHitGroupCount(indice.fusion);
        blockToShow = this.getRealBlockToShowGroupCount(indice.fusion);
      }

      if (nbHits < blockToShow) {
        blockToShow = nbHits;
      }

      if (this.sectionToManage === SectionToManage.dropdown || this.sectionToManage === SectionToManage.mobileDropdown) {
        this.updateNavSearchHeader(index, blockToShow, nbHits);
        this.updateNavSearchResultWrapper(index, blockToShow, nbHits);
      } else if (this.sectionToManage === SectionToManage.page) {
        SearchTabs.updateTab(index, nbHits);
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
      var _this7 = this;

      var count = 0;
      this.config.forEach(function (value, key) {
        if (key === 'suggest') {
          return;
        }

        count += _this7.getRealHitsCount(value);
      });
      return count;
    }
  }, {
    key: "getRealHitGroupCount",
    value: function getRealHitGroupCount(indexes) {
      var _this8 = this;

      var nbHits = 0;
      indexes.forEach(function (value) {
        nbHits += _this8.getRealHitsCount(_this8.config.get(value));
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
    } // fonction permettant de remplir les diffÃ©rents templates de rÃ©sultat avec les donnÃ©es issues d'Algolia

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
      var iterationProducts = 0;
      var iterationServices = 0;
      var iterationAssistance = 0;
      var iterationMagazine = 0;
      var iterationVideos = 0;
      var iterationBrands = 0;
      var iterationSuggest = 0;
      var position = 0;

      var _iterator = _createForOfIteratorHelper(hitsToShow),
          _step;

      try {
        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          var item = _step.value;
          var $templateTmp = $(indice.$template.clone().html().trim());
          var templateId = indice.$template.attr('id');
          position++;
          this.hydrateInsightDatas(indice, item, position);

          if (templateId === "resultProductsTemplate") {
            iterationProducts++;
            $templateTmp = TemplateProduct.getTemplate(index, item, $templateTmp, indice, iterationProducts);
          } else if (templateId === "resultServicesTemplate") {
            iterationServices++;
            $templateTmp = TemplateService.getTemplate(index, item, $templateTmp, indice, iterationServices);
          } else if (templateId === "resultAssistanceTemplate") {
            iterationAssistance++;
            $templateTmp = TemplateAssistance.getTemplate(index, item, $templateTmp, indice, iterationAssistance);
          } else if (templateId === "resultMagazineTemplate") {
            iterationMagazine++;
            $templateTmp = TemplateMagazine.getTemplate(index, item, $templateTmp, indice, iterationMagazine);
          } else if (templateId === "resultVideosTemplate") {
            iterationVideos++;
            $templateTmp = TemplateVideo.getTemplate(index, item, $templateTmp, indice, iterationVideos);
          } else if (templateId === "resultBrandsTemplate") {
            iterationBrands++;
            $templateTmp = TemplateBrand.getTemplate(index, item, $templateTmp, indice, iterationBrands);
          } else if (templateId === "resultSuggestTemplate") {
            iterationSuggest++;
            $templateTmp = TemplateSuggest.getTemplate(index, item, $templateTmp, indice, iterationSuggest);
          }

          $templateTmp.appendTo(this.getSectionTemplateWrapper(indice));
        }
      } catch (err) {
        _iterator.e(err);
      } finally {
        _iterator.f();
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

      if (this.isDropdown() || this.isMobileDropdown()) {
        return;
      }

      var totalHits = this.getRealTotalHitsCount();
      var $templateResultCount = TemplateResultCount.getTemplate(totalHits);

      if (totalHits > 0) {
        this.$searchDetails.show();
        this.$searchDetails.html($templateResultCount.html());
      }
    }
  }, {
    key: "hideSearchDetails",
    value: function hideSearchDetails() {
      SearchAlgolia.debug.log('SearchAlgolia - resetPageHeader()');

      if (this.isDropdown() || this.isMobileDropdown() || this.isCustom()) {
        return;
      }

      if (SearchAlgolia.query.length >= 2) {
        var $templateResultCount = TemplateResultCount.getTemplate(0);
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
      var $templateModalResultCount = TemplateModalResultCount.getTemplate(blockToShow, nbHits);
      indice.$dropdown.find('.Results-number').html($templateModalResultCount.html());
    }
  }, {
    key: "updateNavSearchShowMoreButtons",
    value: function updateNavSearchShowMoreButtons(index, blockToShow, nbHits) {
      SearchAlgolia.debug.log('SearchAlgolia - updateNavSearchShowMoreButtons()', index, blockToShow, nbHits);
      var indice = SearchAlgolia.config.get(index);
      var $showMoreResults = indice.$dropdown.find('.NavSearch-showMoreResults');

      if ($('.PageSearch').length === 0 && $showMoreResults.attr('href')) {
        var href = dist.parseUrl($showMoreResults.attr('href'));

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

        var escapedQuery = (0,tools/* escapeStringRegexp */.fA)(this.query);
        var regex = new RegExp(escapedQuery, "gi");
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
  }, {
    key: "addTemplateSearchInsight",
    value: function addTemplateSearchInsight(item, $templateTmp) {
      var _item$insightsSearchC;

      var insightsSearchClickEvent = (_item$insightsSearchC = item.insightsSearchClickEvent) !== null && _item$insightsSearchC !== void 0 ? _item$insightsSearchC : null;

      if (insightsSearchClickEvent) {
        $templateTmp.data('algoliaInsightsSearchClickEvent', insightsSearchClickEvent);
        $templateTmp.addClass('JS-SearchAlgolia-isTracked');
      }
    }
  }, {
    key: "hydrateInsightDatas",
    value: function hydrateInsightDatas(indice, item, position) {
      if (indice.indiceKey && indice.response.queryID) {
        item.insightsSearchClickEvent = {
          eventName: null,
          index: indice.indiceKey,
          queryID: indice.response.queryID,
          objectIDs: [item.objectID],
          positions: [position]
        };
      } else {
        console.error('SearchAlgolia - There is no queryID or indiceKey for this indice', indice.indiceKey);
      }
    }
  }]);

  return SearchAlgolia;
}();

search_algolia_defineProperty(SearchAlgolia, "debug", void 0);

search_algolia_defineProperty(SearchAlgolia, "client", void 0);

search_algolia_defineProperty(SearchAlgolia, "indexes", []);

search_algolia_defineProperty(SearchAlgolia, "userToken", void 0);

search_algolia_defineProperty(SearchAlgolia, "searchTimeout", false);

search_algolia_defineProperty(SearchAlgolia, "sectionToManage", "");

search_algolia_defineProperty(SearchAlgolia, "query", "");

search_algolia_defineProperty(SearchAlgolia, "initConfig", void 0);

search_algolia_defineProperty(SearchAlgolia, "initTabConfig", void 0);

search_algolia_defineProperty(SearchAlgolia, "$searchDetails", $('.SearchDetails'));

search_algolia_defineProperty(SearchAlgolia, "tabToGo", void 0);

search_algolia_defineProperty(SearchAlgolia, "sections", {
  $page: $('.PageSearch'),
  $dropdown: $('.NavSearch'),
  $custom: $()
});

search_algolia_defineProperty(SearchAlgolia, "config", new Map());

search_algolia_defineProperty(SearchAlgolia, "alreadyInit", void 0);
;// CONCATENATED MODULE: ./src/modules/search/search-form/vocalisation.ts
function vocalisation_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function vocalisation_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function vocalisation_createClass(Constructor, protoProps, staticProps) { if (protoProps) vocalisation_defineProperties(Constructor.prototype, protoProps); if (staticProps) vocalisation_defineProperties(Constructor, staticProps); return Constructor; }

function vocalisation_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

var Vocalization = /*#__PURE__*/function () {
  function Vocalization() {
    vocalisation_classCallCheck(this, Vocalization);
  }

  vocalisation_createClass(Vocalization, null, [{
    key: "init",
    value: function init() {
      Vocalization.$button = $(".SearchForm-inputMicro, .ShopSearch-localisationBtn");
      Vocalization.$input = $(".SearchForm-input");

      if (Vocalization.$button.length) {
        Vocalization.checkBroswers();
      }
    }
  }, {
    key: "checkBroswers",
    value: function checkBroswers() {
      var userAgentString = navigator.userAgent;

      if (userAgentString.indexOf("Chrome") > -1 || userAgentString.indexOf("Safari") > -1 || userAgentString.indexOf("Edge") > -1 || userAgentString.indexOf("Chromium") > -1 || userAgentString.indexOf("Safari") > -1) {
        Vocalization.event();
      } else {
        Vocalization.hiddeButton();
      }
    }
  }, {
    key: "hiddeButton",
    value: function hiddeButton() {
      Vocalization.$button.hide();
    }
  }, {
    key: "event",
    value: function event() {
      $(document).on("click", ".SearchForm-inputMicro, .ShopSearch-localisationBtn", function (e) {
        var $input = $(this).parent().siblings('input');

        if ($input.length) {
          Vocalization.recogntion($input);
        } else {
          Vocalization.recogntion($(this).siblings('input'));
        }
      });
    }
  }, {
    key: "recogntion",
    value: function recogntion($el) {
      var SpeechRecognition = SpeechRecognition || webkitSpeechRecognition;
      var recognition = new SpeechRecognition();
      recognition.lang = navigator.language;
      recognition.interimResults = false;
      recognition.maxAlternatives = 1;
      recognition.start();

      recognition.onresult = function (event) {
        $el.val(event.results[0][0].transcript);
        $el.get(0).dispatchEvent(new CustomEvent('input')); // on utilise cette facon de faire pour que ca trigger Ã©galement le @input de vue.js
      };
    }
  }]);

  return Vocalization;
}();

vocalisation_defineProperty(Vocalization, "$button", void 0);

vocalisation_defineProperty(Vocalization, "$input", void 0);
;// CONCATENATED MODULE: ./src/modules/search/search.module.ts







/***/ }),

/***/ "./src/ts/tools.ts":
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "fA": function() { return /* binding */ escapeStringRegexp; }
/* harmony export */ });
/* unused harmony exports mod, numberFormat */
function mod(number, modulo) {
  return (number % modulo + modulo) % modulo;
}
function escapeStringRegexp(string) {
  // Escape characters with special meaning either inside or outside character sets.
  // Use a simple backslash escape when itâ€™s always valid, and a \unnnn escape when the simpler form would be disallowed by Unicode patternsâ€™ stricter grammar.
  return string.replace(/[|\\{}()[\]^$+*?.]/g, '\\$&').replace(/-/g, "\\u002d");
}
var numberFormat = new Intl.NumberFormat(document.documentElement.lang, {
  maximumSignificantDigits: 2
});

/***/ })

}]);