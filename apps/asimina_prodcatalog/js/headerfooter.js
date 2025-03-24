/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "./";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./src/ts/headerfooter.ts");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./src/modules/helper/svg.loader/svg.loader.ts":
/*!*****************************************************!*\
  !*** ./src/modules/helper/svg.loader/svg.loader.ts ***!
  \*****************************************************/
/*! exports provided: SvgLoader */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "SvgLoader", function() { return SvgLoader; });
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

var SvgLoader =
/*#__PURE__*/
function () {
  function SvgLoader() {
    _classCallCheck(this, SvgLoader);
  }

  _createClass(SvgLoader, null, [{
    key: "init",
    value: function init() {
      SvgLoader.load();
    }
  }, {
    key: "load",
    value: function load() {
      $(function () {
        $('[data-svg]').each(function () {
          var $this = $(this);
          var imgURL = $this.data('svg');
          $.get(imgURL, function (data) {
            var $svg = $(data).find('svg');
            $svg = $svg.removeAttr('xmlns:a');
            $this.append($svg);
            $this.trigger('svgReady');
          }, 'xml');
        });
      });
    }
  }]);

  return SvgLoader;
}();

/***/ }),

/***/ "./src/modules/menu-desktop/menu-desktop.ts":
/*!**************************************************!*\
  !*** ./src/modules/menu-desktop/menu-desktop.ts ***!
  \**************************************************/
/*! exports provided: MenuDesktop */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "MenuDesktop", function() { return MenuDesktop; });
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

//import {TweenMax, Power2} from 'gsap';
var MenuDesktop =
/*#__PURE__*/
function () {
  function MenuDesktop() {
    _classCallCheck(this, MenuDesktop);
  }

  _createClass(MenuDesktop, null, [{
    key: "init",
    value: function init() {
      MenuDesktop.$element = $(".MenuDesktop");
      MenuDesktop.element = MenuDesktop.$element.get(0);
      MenuDesktop.$menuBrand = $(".MenuDesktop-brand");
      MenuDesktop.menuBrand = MenuDesktop.$menuBrand.get(0);
      MenuDesktop.$topNav = $(".MenuTop");
      MenuDesktop.menuBrand = MenuDesktop.$topNav.get(0);
      MenuDesktop.menuPosition = "undefined";
      MenuDesktop.menuOutTimeout = false;
      MenuDesktop.menuInTimeout = false;
      MenuDesktop.collapseIsVisible = false;

      if (MenuDesktop.$element.length) {
        MenuDesktop.events();
        MenuDesktop.setMenuHeight();
      }
    }
  }, {
    key: "events",
    value: function events() {
      MenuDesktop.$element.find(".MenuDesktop-nav-item").on("mouseenter", function () {
        var el = $(this).find(".collapse");
        MenuDesktop.openSubMenu(el);
      });
      MenuDesktop.$element.find(".MenuDesktop-nav-item").on("mouseleave", function () {
        var el = $(this).find(".collapse");
        MenuDesktop.closeSubMenu(el);
      });
      $(window).on("scroll resize orientationchange", function () {
        MenuDesktop.setMenuHeight();
      });
      MenuDesktop.$element.find(".user-connexion-btn").on("click", function () {
        if ($(this).hasClass("open")) {
          $(this).removeClass("open");
          MenuDesktop.$element.find(".ConnexionCart-offline").css({
            opacity: 0,
            visibility: "hidden"
          });
          MenuDesktop.$element.find(".user-connexion-triangle").css({
            opacity: 0,
            visibility: "hidden"
          });
        } else {
          $(this).addClass("open");
          MenuDesktop.$element.find(".ConnexionCart-offline").css({
            opacity: 1,
            visibility: "visible"
          });
          MenuDesktop.$element.find(".user-connexion-triangle").css({
            opacity: 1,
            visibility: "visible"
          });
        }
      });
      MenuDesktop.$element.find(".ConnexionCart-close").on("click", function () {
        MenuDesktop.$element.find(".user-connexion-btn").removeClass("open");
        MenuDesktop.$element.find(".ConnexionCart").css({
          opacity: 0,
          visibility: "hidden"
        });
        MenuDesktop.$element.find(".user-connexion-triangle").css({
          opacity: 0,
          visibility: "hidden"
        });
      });
    }
  }, {
    key: "openSubMenu",
    value: function openSubMenu(elementToExpand) {
      clearTimeout(MenuDesktop.menuOutTimeout);
      MenuDesktop.$element.find(".MenuDesktop-nav-panel").css({
        opacity: 0,
        visibility: "hidden"
      });
      elementToExpand.css({
        opacity: 1,
        visibility: "visible"
      });

      if (MenuDesktop.collapseIsVisible === false) {
        MenuDesktop.menuInTimeout = setTimeout(function () {
          TweenMax.set(elementToExpand, {
            height: "auto"
          });
          TweenMax.from(elementToExpand, 0.5, {
            height: 0,
            ease: Power2.easeOut
          });
          MenuDesktop.collapseIsVisible = true;
        }, 200);
      } else if (MenuDesktop.collapseIsVisible === true) {
        elementToExpand.css({
          height: "auto"
        });
      }
    }
  }, {
    key: "closeSubMenu",
    value: function closeSubMenu(elementToExpand) {
      clearTimeout(MenuDesktop.menuOutTimeout);
      clearTimeout(MenuDesktop.menuInTimeout);
      MenuDesktop.menuOutTimeout = setTimeout(function () {
        TweenMax.to($(".MenuDesktop-nav-panel"), 0.5, {
          height: 0,
          ease: Power2.easeOut
        });
        MenuDesktop.collapseIsVisible = false;
      }, 200);
    }
  }, {
    key: "setMenuHeight",
    value: function setMenuHeight() {
      var scrollTop = $(window).scrollTop();

      if (typeof scrollTop === "undefined") {
        scrollTop = 0;
      }

      if (scrollTop < 140) {
        if (MenuDesktop.menuPosition === "undefined" || MenuDesktop.menuPosition === "bottom") {
          MenuDesktop.menuPosition = "top";
          MenuDesktop.agrandirMenu();
          MenuDesktop.showTopNav();
        }
      } else {
        if (MenuDesktop.menuPosition === "undefined" || MenuDesktop.menuPosition === "top") {
          MenuDesktop.menuPosition = "bottom";
          MenuDesktop.retrecirMenu();
          MenuDesktop.hideTopNav();
        }
      }
    }
  }, {
    key: "agrandirMenu",
    value: function agrandirMenu() {
      MenuDesktop.$element.removeClass("smallH");
      MenuDesktop.$element.addClass("largeH");
      $(".WindowFilter").removeClass("smallH");
      $(".WindowFilter").addClass("largeH");
    }
  }, {
    key: "retrecirMenu",
    value: function retrecirMenu() {
      MenuDesktop.$element.removeClass("largeH");
      MenuDesktop.$element.addClass("smallH");
      $(".WindowFilter").removeClass("largeH");
      $(".WindowFilter").addClass("smallH");
    }
  }, {
    key: "showTopNav",
    value: function showTopNav() {
      TweenMax.set(MenuDesktop.$topNav, {
        height: "auto"
      });
      TweenMax.from(MenuDesktop.$topNav, 0.5, {
        height: 0
      });
    }
  }, {
    key: "hideTopNav",
    value: function hideTopNav() {
      TweenMax.to(MenuDesktop.$topNav, 0.5, {
        height: 0
      });
    }
  }]);

  return MenuDesktop;
}();

_defineProperty(MenuDesktop, "element", void 0);

_defineProperty(MenuDesktop, "$element", void 0);

_defineProperty(MenuDesktop, "menuBrand", void 0);

_defineProperty(MenuDesktop, "$menuBrand", void 0);

_defineProperty(MenuDesktop, "$topNav", void 0);

_defineProperty(MenuDesktop, "menuPosition", void 0);

_defineProperty(MenuDesktop, "menuOutTimeout", void 0);

_defineProperty(MenuDesktop, "menuInTimeout", void 0);

_defineProperty(MenuDesktop, "collapseIsVisible", void 0);

/***/ }),

/***/ "./src/modules/menu-mobile/menu-mobile.ts":
/*!************************************************!*\
  !*** ./src/modules/menu-mobile/menu-mobile.ts ***!
  \************************************************/
/*! exports provided: MenuMobile */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "MenuMobile", function() { return MenuMobile; });
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

//import {TweenMax} from "gsap";
var MenuMobile =
/*#__PURE__*/
function () {
  function MenuMobile() {
    _classCallCheck(this, MenuMobile);
  }

  _createClass(MenuMobile, null, [{
    key: "init",
    value: function init() {
      MenuMobile.$element = $(".MenuMobile");
      MenuMobile.element = MenuMobile.$element.get(0);

      if (MenuMobile.$element.length) {
        MenuMobile.calculateCollapseMaxHeight();
        MenuMobile.events();
      }
    }
  }, {
    key: "events",
    value: function events() {
      MenuMobile.$element.find(".burgerIcon").on("click", function () {
        if ($(this).hasClass("open")) {
          $(this).removeClass("open");
          MenuMobile.closeSubMenu();
        } else {
          $(this).addClass("open");
          MenuMobile.openSubMenu();
        }
      });
      MenuMobile.$element.find(".MenuMobile-nav-link").on("click", function () {
        var el = $(this).siblings(".collapse");
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
          MenuMobile.$element.find(".user-connexion-triangle").css({
            opacity: 0,
            visibility: "hidden"
          });
        } else {
          $(this).addClass("open");
          MenuMobile.$element.find(".ConnexionCart-offline").css({
            opacity: 1,
            visibility: "visible"
          });
          MenuMobile.$element.find(".user-connexion-triangle").css({
            opacity: 1,
            visibility: "visible"
          });
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
    }
  }, {
    key: "calculateCollapseMaxHeight",
    value: function calculateCollapseMaxHeight() {
      var MenuMobileCollapseHeight = $(".MenuMobile-collapse").height();

      if (MenuMobileCollapseHeight > MenuMobile.collapseMaxHeight) {
        MenuMobile.collapseMaxHeight = MenuMobileCollapseHeight;
      }

      $(".MenuMobile-nav-panel").each(function (index, element) {
        var elementHeight = $(element).height();

        if (elementHeight > MenuMobile.collapseMaxHeight) {
          MenuMobile.collapseMaxHeight = elementHeight;
        }
      });
      $(".MenuMobile-subSubNavWrapper").each(function (index, element) {
        var elementHeight = $(element).height();

        if (elementHeight > MenuMobile.collapseMaxHeight) {
          MenuMobile.collapseMaxHeight = elementHeight;
        }
      });
    }
  }, {
    key: "openSubMenu",
    value: function openSubMenu() {
      TweenMax.to(MenuMobile.$element.find(".MenuMobile-collapse"), 0.5, {
        top: "50px"
      });
      MenuMobile.calculateCollapseMaxHeight();
    }
  }, {
    key: "closeSubMenu",
    value: function closeSubMenu() {
      //console.log(MenuMobile.collapseMaxHeight);
      var topValue = -1 * MenuMobile.collapseMaxHeight - 50;
      TweenMax.to(MenuMobile.$element.find(".MenuMobile-collapse"), 0.5, {
        top: topValue
      });
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

      if ($("html").attr("dir") === "rtl") {
        TweenMax.to(MenuMobile.$element.find(".MenuMobile-collapse"), 0.5, {
          x: "100%"
        });
      } else {
        TweenMax.to(MenuMobile.$element.find(".MenuMobile-collapse"), 0.5, {
          x: "-100%"
        });
      }
    }
  }, {
    key: "goToFirstSlide",
    value: function goToFirstSlide() {
      TweenMax.to(MenuMobile.$element.find(".MenuMobile-collapse"), 0.5, {
        x: "0%"
      });
    }
  }, {
    key: "goToThirdSlide",
    value: function goToThirdSlide(elementToShow) {
      //console.log(elementToShow);
      $(".MenuMobile-subSubNavWrapper").css({
        opacity: "0",
        visibility: "hidden"
      });
      elementToShow.css({
        opacity: "1",
        visibility: "visible"
      });

      if ($("html").attr("dir") === "rtl") {
        TweenMax.to(MenuMobile.$element.find(".MenuMobile-collapse"), 0.5, {
          x: "200%"
        });
      } else {
        TweenMax.to(MenuMobile.$element.find(".MenuMobile-collapse"), 0.5, {
          x: "-200%"
        });
      }
    }
  }, {
    key: "backToSecondSlide",
    value: function backToSecondSlide() {
      if ($("html").attr("dir") === "rtl") {
        TweenMax.to(MenuMobile.$element.find(".MenuMobile-collapse"), 0.5, {
          x: "100%"
        });
      } else {
        TweenMax.to(MenuMobile.$element.find(".MenuMobile-collapse"), 0.5, {
          x: "-100%"
        });
      }
    }
  }]);

  return MenuMobile;
}();

_defineProperty(MenuMobile, "element", void 0);

_defineProperty(MenuMobile, "$element", void 0);

_defineProperty(MenuMobile, "collapseMaxHeight", 0);

/***/ }),

/***/ "./src/ts/headerfooter.ts":
/*!********************************!*\
  !*** ./src/ts/headerfooter.ts ***!
  \********************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _modules_menu_desktop_menu_desktop__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../modules/menu-desktop/menu-desktop */ "./src/modules/menu-desktop/menu-desktop.ts");
/* harmony import */ var _modules_menu_mobile_menu_mobile__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../modules/menu-mobile/menu-mobile */ "./src/modules/menu-mobile/menu-mobile.ts");
/* harmony import */ var _modules_helper_svg_loader_svg_loader__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../modules/helper/svg.loader/svg.loader */ "./src/modules/helper/svg.loader/svg.loader.ts");



document.addEventListener("DOMContentLoaded", function (event) {
  _modules_menu_desktop_menu_desktop__WEBPACK_IMPORTED_MODULE_0__["MenuDesktop"].init();
  _modules_menu_mobile_menu_mobile__WEBPACK_IMPORTED_MODULE_1__["MenuMobile"].init();
  _modules_helper_svg_loader_svg_loader__WEBPACK_IMPORTED_MODULE_2__["SvgLoader"].init();
});

/***/ })

/******/ });
//# sourceMappingURL=headerfooter.js.map