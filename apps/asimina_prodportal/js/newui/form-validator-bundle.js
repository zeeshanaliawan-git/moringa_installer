// [AIV_SHORT]  Build version: 5.3.4  
 (window["webpackJsonp"] = window["webpackJsonp"] || []).push([["form-validator"],{

/***/ "./src/modules/tunnel/form-validator.ts":
/*!**********************************************!*\
  !*** ./src/modules/tunnel/form-validator.ts ***!
  \**********************************************/
/*! exports provided: FormValidator */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "FormValidator", function() { return FormValidator; });
/* harmony import */ var _helper_form_validator_field__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../helper/form-validator/field */ "./src/modules/helper/form-validator/field.ts");
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
/* harmony import */ var _tunnel_exit_tunnel_exit__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./tunnel-exit/tunnel-exit */ "./src/modules/tunnel/tunnel-exit/tunnel-exit.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }




var FormValidator = /*#__PURE__*/function () {
  function FormValidator(element) {
    _classCallCheck(this, FormValidator);

    _defineProperty(this, "debug", new _helper_debug_debug__WEBPACK_IMPORTED_MODULE_1__["Debug"](true));

    _defineProperty(this, "element", void 0);

    _defineProperty(this, "$element", void 0);

    _defineProperty(this, "validity", void 0);

    this.element = element;
    this.$element = $(element);
    this.$element.data('form-validator', this);
    this.validity = false;
    this.getFields().each(function (index, value) {
      new _helper_form_validator_field__WEBPACK_IMPORTED_MODULE_0__["Field"](value);
    });
    this.events();
    this.validator(false, false);
  }

  _createClass(FormValidator, [{
    key: "events",
    value: function events() {
      this.onValidate();
      this.onNext();
    }
  }, {
    key: "getFields",
    value: function getFields() {
      var $element = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : this.$element;
      return $element.find('input, textarea, select').not('.JS-FormValidator-ignore');
    }
  }, {
    key: "onValidate",
    value: function onValidate() {
      var _this = this;

      this.$element.on("Field:validate", this.getFields(), function (event) {
        var $target = $(event.target);

        _this.validator(true, undefined, _this.getClosestFormSection($target));
      });
    }
  }, {
    key: "getClosestFormSection",
    value: function getClosestFormSection($field) {
      return $field.closest('.FormValidator-step, .FormValidator');
    }
  }, {
    key: "validator",
    value: function validator(onlyForDirty) {
      var updateInterface = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : true;
      var $formSection = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : this.$element;
      this.debug.group("FormValidator - validator()", onlyForDirty, updateInterface);

      var _this = this;

      var validity = true;
      var sectionValid = true;
      var anElementIsPristine = false;
      this.getFields($formSection).each(function (index, element) {
        var $element = $(element);
        var field = $element.data('field');

        if (!field && !$element.hasClass('.JS-FormValidator-ignore')) {
          field = new _helper_form_validator_field__WEBPACK_IMPORTED_MODULE_0__["Field"](element); // For asynchonous field
        }

        if (!$element.hasClass("isPristine") || onlyForDirty === false) {
          field.validate(updateInterface);

          if (!field.isValid) {
            sectionValid = false;
          }

          validity = sectionValid;
        } else {
          anElementIsPristine = true;
        }
      });

      if (!$formSection.is(this.$element)) {
        this.validator(onlyForDirty, updateInterface);
      } else {
        this.validity = validity;
      }

      this.setSectionValidity(anElementIsPristine, $formSection, validity);
      this.debug.log("Global validity", this.validity);
      this.debug.log("Local validity", validity);
      this.debug.groupEnd();
    }
  }, {
    key: "onNext",
    value: function onNext() {
      var _this2 = this;

      this.$element.on("click", '.JS-FormValidator-submit', function (event) {
        var $target = $(event.target);

        _this2.validator(false, undefined, _this2.getClosestFormSection($target));

        if (!_this2.validity) {
          event.preventDefault();
          return false;
        } else {
          _tunnel_exit_tunnel_exit__WEBPACK_IMPORTED_MODULE_2__["TunnelExit"].clearUnloadEvent();
        }
      });
    }
  }, {
    key: "setSectionValidity",
    value: function setSectionValidity(anElementIsPristine, $formSection, validity) {
      var $sectionButton = $formSection.find('.JS-FormValidator-submit');

      if (!$formSection.is(this.$element)) {
        $sectionButton = $formSection.find('.JS-FormValidator-stepSubmit');
      }

      this.setButtonValidity($sectionButton, anElementIsPristine, validity);
    }
  }, {
    key: "setButtonValidity",
    value: function setButtonValidity($button, anElementIsPristine, validity) {
      if (validity === true && anElementIsPristine === false) {
        $button.removeAttr("disabled");
      } else if (validity === false && anElementIsPristine === false) {
        $button.attr("disabled", "disabled");
      }
    }
  }]);

  return FormValidator;
}();

/***/ }),

/***/ "./src/modules/tunnel/tunnel-exit/tunnel-exit.ts":
/*!*******************************************************!*\
  !*** ./src/modules/tunnel/tunnel-exit/tunnel-exit.ts ***!
  \*******************************************************/
/*! exports provided: TunnelExit */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TunnelExit", function() { return TunnelExit; });
/* harmony import */ var _helper_form_validator_field__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../helper/form-validator/field */ "./src/modules/helper/form-validator/field.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }


var TunnelExit = /*#__PURE__*/function () {
  function TunnelExit() {
    _classCallCheck(this, TunnelExit);
  }

  _createClass(TunnelExit, null, [{
    key: "init",
    value: function init() {
      TunnelExit.$trigger = $(".JS-TunnelExit");
      TunnelExit.trigger = TunnelExit.$trigger.get(0);
      TunnelExit.$modal = $(".TunnelExitModal");
      TunnelExit.modal = TunnelExit.$modal.get(0);
      TunnelExit.href = "#";

      if (TunnelExit.$trigger.length && TunnelExit.$modal.length) {
        TunnelExit.$modal.find("input:not([type='hidden'])").each(function (index, value) {
          TunnelExit.$email = $(value);
          new _helper_form_validator_field__WEBPACK_IMPORTED_MODULE_0__["Field"](value);
        });
        TunnelExit.events();
      }
    }
  }, {
    key: "clearUnloadEvent",
    value: function clearUnloadEvent() {
      window.onbeforeunload = function (e) {};
    }
  }, {
    key: "events",
    value: function events() {
      TunnelExit.$trigger.on("click", function (e) {
        e.preventDefault(); // on recupère le href

        var href = $(this).attr("href");

        if (href) {
          TunnelExit.href = href;
          TunnelExit.$modal.find('.JS-TunnelExit-destination').val(href);
        }

        TunnelExit.$modal.modal('show');
      });
      TunnelExit.$modal.find(".JS-TunnelExit-changePage").on("click", function (e) {
        if (!$(this).hasClass("disabled")) {
          document.location.href = TunnelExit.href;
        }
      });

      window.onbeforeunload = function () {
        if (TunnelExit.$modal.attr("aria-modal") !== "true") {
          // ne pas mettre : ' === false '
          return "";
        }
      };
    }
  }]);

  return TunnelExit;
}();

_defineProperty(TunnelExit, "trigger", void 0);

_defineProperty(TunnelExit, "$trigger", void 0);

_defineProperty(TunnelExit, "modal", void 0);

_defineProperty(TunnelExit, "$modal", void 0);

_defineProperty(TunnelExit, "href", void 0);

_defineProperty(TunnelExit, "$email", void 0);

/***/ })

}]);
//# sourceMappingURL=form-validator-bundle.js.map 