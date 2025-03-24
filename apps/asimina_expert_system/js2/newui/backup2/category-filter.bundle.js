(window["webpackJsonp"] = window["webpackJsonp"] || []).push([["category-filter"],{

/***/ "./src/modules/ui/category-filter/category-filter.ts":
/*!***********************************************************!*\
  !*** ./src/modules/ui/category-filter/category-filter.ts ***!
  \***********************************************************/
/*! exports provided: CategoryFilter */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "CategoryFilter", function() { return CategoryFilter; });
/* harmony import */ var swiper__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! swiper */ "swiper");
/* harmony import */ var swiper__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(swiper__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
/* harmony import */ var _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../../helper/responsive/responsive */ "./src/modules/helper/responsive/responsive.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }




var CategoryFilter =
/*#__PURE__*/
function () {
  function CategoryFilter() {
    _classCallCheck(this, CategoryFilter);
  }

  _createClass(CategoryFilter, null, [{
    key: "init",
    value: function init() {
      CategoryFilter.debug = new _helper_debug_debug__WEBPACK_IMPORTED_MODULE_1__["Debug"](true);
      CategoryFilter.updateSwiper();
      CategoryFilter.events();
      CategoryFilter.getWrapperWidth();
    }
  }, {
    key: "events",
    value: function events() {
      _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_2__["Responsive"].onWindowResize(function () {
        CategoryFilter.updateSwiper();
      });
    }
  }, {
    key: "updateSwiper",
    value: function updateSwiper() {
      /*
      if (Responsive.isMin("minLg")) {
        CategoryFilter.destroySwiper();
      } else {
        CategoryFilter.createSwiper();
      }
      */
      if ($(window).width() > CategoryFilter.getWrapperWidth()) {
        CategoryFilter.destroySwiper();
        CategoryFilter.hideSwiperNav();
      } else {
        CategoryFilter.createSwiper();
        CategoryFilter.showSwiperNav();
      }
    }
  }, {
    key: "destroySwiper",
    value: function destroySwiper() {
      // console.log('destroySwiper');
      $(".CategoryFilter-list").css({
        "justify-content": "center"
      });
      $(".CategoryFilter-item.fake-item").hide();
      $(".CategoryFilter-item").css("flex", "0 0 160px");

      if (CategoryFilter.swiper) {
        CategoryFilter.debug.log("Destroy CategoryFilter swiper");
        CategoryFilter.swiper.destroy(true, true);
        CategoryFilter.swiper = null;
      }
    }
  }, {
    key: "createSwiper",
    value: function createSwiper() {
      // console.log('createSwiper');
      $(".CategoryFilter-list").css({
        "justify-content": "left"
      });
      $(".CategoryFilter-item.fake-item").show();
      $(".CategoryFilter-item").css("flex", "none");

      if (!CategoryFilter.swiper) {
        CategoryFilter.swiper = new swiper__WEBPACK_IMPORTED_MODULE_0___default.a(".CategoryFilter > .swiper-container", {
          navigation: {
            prevEl: ".CategoryFilter-swiperPrev",
            nextEl: ".CategoryFilter-swiperNext"
          },
          slidesPerView: 4,
          spaceBetween: 0,
          breakpoints: {
            768: {
              slidesPerView: 3
            },
            520: {
              slidesPerView: 2
            },
            320: {
              /*380=>320*/
              slidesPerView: 2
            }
          }
        });
      }
    }
  }, {
    key: "getWrapperWidth",
    value: function getWrapperWidth() {
      var nbCategories = $(".CategoryFilter-item").length;
      return nbCategories * 160; // 160 = largeur d'un item
    }
  }, {
    key: "hideSwiperNav",
    value: function hideSwiperNav() {
      $(".CategoryFilter-swiperPrev").css({
        visibility: "hidden",
        opacity: 0
      });
      $(".CategoryFilter-swiperNext").css({
        visibility: "hidden",
        opacity: 0
      });
    }
  }, {
    key: "showSwiperNav",
    value: function showSwiperNav() {
      $(".CategoryFilter-swiperPrev").css({
        visibility: "visible",
        opacity: 1
      });
      $(".CategoryFilter-swiperNext").css({
        visibility: "visible",
        opacity: 1
      });
    }
  }]);

  return CategoryFilter;
}();

_defineProperty(CategoryFilter, "swiper", void 0);

_defineProperty(CategoryFilter, "debug", void 0);

/***/ })

}]);
//# sourceMappingURL=category-filter.bundle.js.map