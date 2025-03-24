(window["webpackJsonp"] = window["webpackJsonp"] || []).push([["essentiel"],{

/***/ "./src/modules/ui/bloc-essentiel/bloc-essentiel.ts":
/*!*********************************************************!*\
  !*** ./src/modules/ui/bloc-essentiel/bloc-essentiel.ts ***!
  \*********************************************************/
/*! exports provided: BlocEssentiel */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "BlocEssentiel", function() { return BlocEssentiel; });
/* harmony import */ var swiper__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! swiper */ "swiper");
/* harmony import */ var swiper__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(swiper__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
/* harmony import */ var _helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../../helper/responsive/responsive */ "./src/modules/helper/responsive/responsive.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }




var BlocEssentiel =
/*#__PURE__*/
function () {
  function BlocEssentiel() {
    _classCallCheck(this, BlocEssentiel);
  }

  _createClass(BlocEssentiel, null, [{
    key: "init",
    value: function init() {
      // console.log('BlocEssentiel init 1');
      BlocEssentiel.debug = new _helper_debug_debug__WEBPACK_IMPORTED_MODULE_1__["Debug"](true);
      BlocEssentiel.updateSwiper();
      BlocEssentiel.events(); // console.log('BlocEssentiel init 2');
    }
  }, {
    key: "events",
    value: function events() {
      // console.log('BlocEssentiel events');
      $(window).on('resize orientationchange', function () {
        // console.log("BlocEssentiel resize");
        BlocEssentiel.updateSwiper();
      });
      /*
      Responsive.onWindowResize(() => {
        BlocEssentiel.updateSwiper();
      });
      */
    }
  }, {
    key: "updateSwiper",
    value: function updateSwiper() {
      // console.log('BlocEssentiel updateSwiper');
      if (_helper_responsive_responsive__WEBPACK_IMPORTED_MODULE_2__["Responsive"].isMin("minLg")) {
        // console.log('BlocEssentiel.destroySwiper();');
        BlocEssentiel.destroySwiper();
      } else {
        // console.log('BlocEssentiel.createSwiper();');
        BlocEssentiel.createSwiper();
      }
    }
  }, {
    key: "destroySwiper",
    value: function destroySwiper() {
      if (BlocEssentiel.swiper) {
        BlocEssentiel.debug.log("Destroy Essentiel swiper");
        BlocEssentiel.swiper.destroy(true, true);
        BlocEssentiel.swiper = null;
      }
    }
  }, {
    key: "createSwiper",
    value: function createSwiper() {
      if (!BlocEssentiel.swiper) {
        BlocEssentiel.debug.log("Create Essentiel swiper");
        BlocEssentiel.swiper = new swiper__WEBPACK_IMPORTED_MODULE_0___default.a(".Essentiel-swiper", {
          slidesPerView: 2.1,
          spaceBetween: 10,
          pagination: {
            el: ".swiper-pagination",
            clickable: false
          },
          breakpoints: {
            768: {
              slidesPerView: 1.1
            }
          }
        });
      }
    }
  }]);

  return BlocEssentiel;
}();

_defineProperty(BlocEssentiel, "swiper", void 0);

_defineProperty(BlocEssentiel, "debug", void 0);

/***/ })

}]);
//# sourceMappingURL=essentiel.bundle.js.map