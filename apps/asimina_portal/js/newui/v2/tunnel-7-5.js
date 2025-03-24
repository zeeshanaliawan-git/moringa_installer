/*! Orange MEA 7.5.0 - new/1 - tunnel - 2022-07-26T08:20:46.123Z */
(self["webpackChunkOrangeLibraryWebpack"] = self["webpackChunkOrangeLibraryWebpack"] || []).push([["tunnel"],{

/***/ "./src/modules/tunnel/tunnel-exit/tunnel-exit.ts":
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "R": function() { return /* binding */ TunnelExit; }
/* harmony export */ });
/* harmony import */ var _helper_form_validator_field__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__("./src/modules/helper/form-validator/field.ts");
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
          new _helper_form_validator_field__WEBPACK_IMPORTED_MODULE_0__/* .Field */ .g(value);
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

/***/ }),

/***/ "./src/modules/tunnel/tunnel.module.ts":
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
// ESM COMPAT FLAG
__webpack_require__.r(__webpack_exports__);

// EXPORTS
__webpack_require__.d(__webpack_exports__, {
  "BridgeApi": function() { return /* reexport */ BridgeApi; },
  "MapComponent": function() { return /* reexport */ MapComponent; },
  "TunnelDelivery": function() { return /* reexport */ TunnelDelivery; },
  "TunnelExit": function() { return /* reexport */ tunnel_exit/* TunnelExit */.R; },
  "TunnelForm": function() { return /* reexport */ TunnelForm; }
});

// EXTERNAL MODULE: ./src/modules/helper/form-validator/field.ts
var field = __webpack_require__("./src/modules/helper/form-validator/field.ts");
// EXTERNAL MODULE: ./src/modules/tunnel/tunnel-exit/tunnel-exit.ts
var tunnel_exit = __webpack_require__("./src/modules/tunnel/tunnel-exit/tunnel-exit.ts");
;// CONCATENATED MODULE: ./src/modules/tunnel/tunnel-form.ts
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }



var TunnelForm = /*#__PURE__*/function () {
  function TunnelForm() {
    _classCallCheck(this, TunnelForm);
  }

  _createClass(TunnelForm, null, [{
    key: "init",
    value: function init() {
      TunnelForm.$element = $(".TunnelForm");
      TunnelForm.element = TunnelForm.$element.get(0);
      var TunnelSteps = TunnelForm.$element.find('.TunnelForm-step');

      if (TunnelForm.$element.length) {
        TunnelSteps.each(function (index, value) {
          var stepNumber = $(value).data('tunnel-step');
          TunnelForm.stepsValidity[stepNumber] = false;
        });
        TunnelForm.$element.find('input, textarea, select').each(function (index, value) {
          new field/* Field */.g(value);
        });
        TunnelForm.events();
      }
    }
  }, {
    key: "events",
    value: function events() {
      TunnelForm.onValidate();
      TunnelForm.onNext();
      TunnelForm.onChangeSection();
      TunnelForm.preventActions();
    }
  }, {
    key: "onValidate",
    value: function onValidate() {
      TunnelForm.$element.find("input, textarea, select").on("Field:validate", function () {
        var step = parseInt($(this).closest('.TunnelForm-step').data('tunnel-step'));
        TunnelForm.validator(step, true);
      });
    }
  }, {
    key: "onNext",
    value: function onNext() {
      TunnelForm.$element.find(".JS-TunnelForm-nextBtn").on("click", function () {
        // On récupère l'étape correspondante
        var step = parseInt($(this).closest('.TunnelForm-step').data('tunnel-step'));
        TunnelForm.validator(step, false);

        if (TunnelForm.stepsValidity[step]) {
          if (TunnelForm.getStepCount() === step) {
            TunnelForm.validateAll();
          } else {
            TunnelForm.gotoStep(step + 1);
          }
        }
      });
    }
  }, {
    key: "onChangeSection",
    value: function onChangeSection() {
      TunnelForm.$element.find('.TunnelForm-step .collapse').on('shown.bs.collapse', function () {
        var id = $(this).attr('id');

        if (id) {
          var anchor = "#" + id;
          $("html, body").animate({
            scrollTop: $(anchor).offset().top - 55
          }, 500);
        }
      });
    }
  }, {
    key: "preventActions",
    value: function preventActions() {
      // NE PAS OUVRIR LES ONGLETS SI LA SECTION EN COURS N'EST PAS VALIDE
      TunnelForm.$element.find('.TunnelForm-step').on('show.bs.collapse', function (e) {
        // on check si la section n - 1 n'est pas valide
        // recupération de la section
        var dataCurrentStep = $(this).attr('data-tunnel-step');

        if (dataCurrentStep) {
          var currentStep = parseInt(dataCurrentStep);
          var previousStep = currentStep - 1;

          if (previousStep > 0) {
            if (TunnelForm.stepsValidity[previousStep] === false && TunnelForm.getSection(currentStep).hasClass('isPristine')) {
              // si la section n - 1 n'est pas valide on n'ouvre pas
              e.preventDefault();
            }
          }
        }
      });
      TunnelForm.$element.find(".JS-TunnelForm-stepButton").on("click", function (e) {
        e.preventDefault();
      });
    }
  }, {
    key: "validateAll",
    value: function validateAll() {
      var validStepCount = 0;

      for (var stepKey in TunnelForm.stepsValidity) {
        var step = parseInt(stepKey);
        this.validator(step, false);

        if (TunnelForm.stepsValidity[step]) {
          validStepCount++;
        }
      }

      if (validStepCount === TunnelForm.getStepCount()) {
        TunnelForm.sendForm();
      }
    }
  }, {
    key: "getStepCount",
    value: function getStepCount() {
      return Object.keys(TunnelForm.stepsValidity).length;
    }
  }, {
    key: "sendForm",
    value: function sendForm() {
      tunnel_exit/* TunnelExit.clearUnloadEvent */.R.clearUnloadEvent();
      TunnelForm.$element.closest('form').submit();
    }
  }, {
    key: "validator",
    value: function validator(step, onlyForDirty) {
      var $section = this.getSection(step);
      TunnelForm.stepsValidity[step] = true;
      var sectionValid = true;
      var anElementIsPristine = false;
      $section.find("input, textarea, select").each(function (index, element) {
        var $element = $(element);
        var field = $element.data('field');

        if (!$element.hasClass("isPristine") || onlyForDirty === false) {
          field.validate();

          if (!field.isValid) {
            sectionValid = false;
          }

          TunnelForm.stepsValidity[step] = sectionValid;
        } else {
          anElementIsPristine = true;
        }
      });
      TunnelForm.setSectionValidity(step, anElementIsPristine);
    }
  }, {
    key: "gotoStep",
    value: function gotoStep(step) {
      var $section = this.getSection(step);
      var $el = $section.find('.JS-TunnelForm-stepButton');

      if ($el) {
        $el.trigger('click');
      } else {
        console.error("Tunnel step ".concat(step, " doesn't exist"));
      }
    }
  }, {
    key: "getSection",
    value: function getSection(step) {
      return $("[data-tunnel-step='" + step + "']");
    }
  }, {
    key: "setSectionValidity",
    value: function setSectionValidity(step, anElementIsPristine) {
      var $section = this.getSection(step);
      var $sectionButton = $section.find('.JS-TunnelForm-stepButton');

      if (TunnelForm.stepsValidity[step] === true && anElementIsPristine === false) {
        $sectionButton.removeClass("is-invalid");
        $sectionButton.addClass("is-valid");
        $sectionButton.find(".TunnelForm-sectionIconInvalid").hide();
        $sectionButton.find(".TunnelForm-sectionIconValid").show();
        TunnelForm.removeIsPristineClassFromCard(step + 1);
      } else if (TunnelForm.stepsValidity[step] === false && anElementIsPristine === false) {
        $sectionButton.removeClass("is-valid");
        $sectionButton.addClass("is-invalid");
        $sectionButton.find(".TunnelForm-sectionIconValid").hide();
        $sectionButton.find(".TunnelForm-sectionIconInvalid").show();
      }
    }
  }, {
    key: "removeIsPristineClassFromCard",
    value: function removeIsPristineClassFromCard(step) {
      var $element = TunnelForm.$element.find("[data-tunnel-step=" + step + "]");

      if ($element.length > 0) {
        TunnelForm.$element.find($element).removeClass("isPristine");
      }
    }
  }]);

  return TunnelForm;
}();

_defineProperty(TunnelForm, "element", void 0);

_defineProperty(TunnelForm, "$element", void 0);

_defineProperty(TunnelForm, "stepsValidity", {});
// EXTERNAL MODULE: ./node_modules/es-cookie/src/es-cookie.js
var es_cookie = __webpack_require__("./node_modules/es-cookie/src/es-cookie.js");
// EXTERNAL MODULE: ./src/modules/helper/debug/debug.ts
var debug = __webpack_require__("./src/modules/helper/debug/debug.ts");
// EXTERNAL MODULE: ./src/ts/library.ts
var library = __webpack_require__("./src/ts/library.ts");
;// CONCATENATED MODULE: ./src/modules/mapComponent/mapComponent.ts
function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function _createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function mapComponent_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function mapComponent_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function mapComponent_createClass(Constructor, protoProps, staticProps) { if (protoProps) mapComponent_defineProperties(Constructor.prototype, protoProps); if (staticProps) mapComponent_defineProperties(Constructor, staticProps); return Constructor; }

function mapComponent_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }





var MapComponent = /*#__PURE__*/function () {
  function MapComponent($element) {
    mapComponent_classCallCheck(this, MapComponent);

    mapComponent_defineProperty(this, "debug", new debug/* Debug */.c(true));

    mapComponent_defineProperty(this, "$mapContainer", void 0);

    mapComponent_defineProperty(this, "map", void 0);

    mapComponent_defineProperty(this, "$placeHolders", void 0);

    mapComponent_defineProperty(this, "$costAlertModal", void 0);

    mapComponent_defineProperty(this, "markers", []);

    mapComponent_defineProperty(this, "markersListeners", []);

    this.$mapContainer = $element;
    this.$mapContainer.data('map-component', this);
  }

  mapComponent_createClass(MapComponent, [{
    key: "initMap",
    value: function initMap() {
      this.map = new google.maps.Map(this.$mapContainer.get(0), {
        zoom: 12
      });

      if (typeof TunnelDelivery.currentPosition !== "undefined") {
        this.map.setCenter({
          lat: TunnelDelivery.currentPosition.lat,
          lng: TunnelDelivery.currentPosition.lng
        });
      }
    }
  }, {
    key: "createMarkers",
    value: function createMarkers() {
      var uniqueMarker = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : false;

      if (!this.map) {
        return;
      }

      if (uniqueMarker && TunnelDelivery.selectedBoutique) {
        this.createOneMarker(TunnelDelivery.selectedBoutique, uniqueMarker);
      } else {
        if (TunnelDelivery.boutiques.length > 0) {
          var _iterator = _createForOfIteratorHelper(TunnelDelivery.boutiques),
              _step;

          try {
            for (_iterator.s(); !(_step = _iterator.n()).done;) {
              var currentBoutique = _step.value;
              this.createOneMarker(currentBoutique, uniqueMarker);
            }
          } catch (err) {
            _iterator.e(err);
          } finally {
            _iterator.f();
          }
        }
      }
    }
  }, {
    key: "removeMarkers",
    value: function removeMarkers() {
      if (!this.map) {
        return;
      }

      if (this.markers.length > 0) {
        for (var index in this.markers) {
          if (this.markers.hasOwnProperty(index)) {
            google.maps.event.removeListener(this.markersListeners[index]);
            this.markers[index].setMap(null);
          }
        }

        this.markersListeners = [];
        this.markers = [];
      }
    }
  }, {
    key: "createOneMarker",
    value: function createOneMarker(currentBoutique) {
      var uniqueMarker = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : false;

      // uniquerMarker permet de savoir s'il faut mettre les legends ou non
      if (!this.map) {
        return;
      }

      if (currentBoutique && currentBoutique.lat && currentBoutique.lng) {
        var marker = new google.maps.Marker({
          position: {
            lat: currentBoutique.lat,
            lng: currentBoutique.lng
          },
          icon: TunnelDelivery.mapsConfig.markersIconsUrl.normal,
          map: this.map,
          // @ts-ignore
          boutique: currentBoutique
        });
        marker.boutique = currentBoutique;

        if (TunnelDelivery.selectedBoutique && TunnelDelivery.selectedBoutique.id === currentBoutique.id) {
          marker.setIcon(TunnelDelivery.mapsConfig.markersIconsUrl.selected);
        }

        var $popinMarkerTemplate = $($('#popinMarkerTemplate').clone().html().trim());
        var title = library/* Library.OrangeLibrary.PopinMarker.get */.Z.OrangeLibrary.PopinMarker.get('displayTitle')(currentBoutique);
        var content = library/* Library.OrangeLibrary.PopinMarker.get */.Z.OrangeLibrary.PopinMarker.get('displayContent')(currentBoutique);
        $popinMarkerTemplate.find('.PopinMarker-title').html(title);
        $popinMarkerTemplate.find('.PopinMarker-content').html(content);

        if (!uniqueMarker) {
          $popinMarkerTemplate.find('.PopinMarker-button').attr('data-boutique-id', currentBoutique.id);
        } else {
          $popinMarkerTemplate.find('.PopinMarker-button').remove();
        }

        marker.infowindow = new google.maps.InfoWindow({
          content: $popinMarkerTemplate.html(),
          maxWidth: 220
        });

        var _this = this;

        var listener = marker.addListener("click", function (event) {
          _this.closeAllInfoWindow();

          TunnelDelivery.boutiqueListVue.focusBoutique(this.boutique);

          if (this.infowindow) {
            this.infowindow.open(_this.map, this);
          }
        });
        var mouseoverListener = marker.addListener("mouseover", function (event) {
          TunnelDelivery.boutiqueListVue.highlightMarker(this.boutique, true);
        });
        var mouseleaveListener = marker.addListener("mouseout", function (event) {
          TunnelDelivery.boutiqueListVue.highlightMarker(this.boutique, false);
        });
        this.markers.push(marker);
        this.markersListeners.push(listener);
        this.markersListeners.push(mouseoverListener);
        this.markersListeners.push(mouseleaveListener);
      }
    }
  }, {
    key: "closeAllInfoWindow",
    value: function closeAllInfoWindow() {
      if (!this.map) {
        return;
      }

      var _iterator2 = _createForOfIteratorHelper(this.markers),
          _step2;

      try {
        for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
          var marker = _step2.value;
          marker.infowindow.close(this.map, this);
        }
      } catch (err) {
        _iterator2.e(err);
      } finally {
        _iterator2.f();
      }
    }
  }, {
    key: "centerMap",
    value: function centerMap(boutique) {
      var math = Math.random();

      if (!this.map) {
        return;
      }

      if (typeof boutique === 'undefined') {
        boutique = TunnelDelivery.selectedBoutique;
      }

      this.map.panTo({
        lat: boutique.lat,
        lng: boutique.lng
      });
    }
  }, {
    key: "getMarkerByBoutiqueId",
    value: function getMarkerByBoutiqueId(boutiqueId) {
      if (!this.map) {
        return;
      }

      return this.markers.find(function (marker) {
        return marker.boutique.id === boutiqueId;
      });
    }
  }, {
    key: "initPlaceholder",
    value: function initPlaceholder() {
      var _this2 = this;

      this.$placeHolders = $('.JS-ShopSearch-toggleMap');
      this.$costAlertModal = $('#deliveryCostAlertModal');
      this.$placeHolders.on("click", function () {
        _this2.$costAlertModal.modal('show');
      });
      this.$placeHolders.each(function (index, element) {
        element.classList.add('JS-showPlaceholder');
      });
      this.stopLoading();
      this.$costAlertModal.find(".JS-loadButton").on("click", /*#__PURE__*/_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee() {
        var remember;
        return regeneratorRuntime.wrap(function _callee$(_context) {
          while (1) {
            switch (_context.prev = _context.next) {
              case 0:
                _this2.$costAlertModal.modal('hide');

                remember = _this2.$costAlertModal.find('#stopWarning').is(':checked');

                if (remember) {
                  es_cookie.set('TunnelDelivery.autoload', 'true');
                }

                _this2.removePlaceHolder();

                _context.prev = 4;
                _context.next = 7;
                return MapComponent.loadGoogleMapApi();

              case 7:
                TunnelDelivery.initMap();
                TunnelDelivery.selectPreselectedBoutique();
                TunnelDelivery.centerOnFirstResult();
                _context.next = 15;
                break;

              case 12:
                _context.prev = 12;
                _context.t0 = _context["catch"](4);

                _this2.debug.error(_context.t0);

              case 15:
              case "end":
                return _context.stop();
            }
          }
        }, _callee, null, [[4, 12]]);
      })));
    }
  }, {
    key: "stopLoading",
    value: function stopLoading() {
      this.$mapContainer.find('.Loading').remove();
    }
  }, {
    key: "removePlaceHolder",
    value: function removePlaceHolder() {
      this.$placeHolders.each(function (index, element) {
        element.classList.remove('JS-showPlaceholder');
      });
      this.$placeHolders.off();
      this.$costAlertModal.find('.JS-autoload').off();
    }
  }], [{
    key: "loadGoogleMapApi",
    value: function () {
      var _loadGoogleMapApi = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee2() {
        return regeneratorRuntime.wrap(function _callee2$(_context2) {
          while (1) {
            switch (_context2.prev = _context2.next) {
              case 0:
                return _context2.abrupt("return", new Promise(function (resolve, reject) {
                  if (!(MapComponent.googleMapApiLoaded || MapComponent.googleMapApiLoading)) {
                    MapComponent.googleMapApiLoading = true;

                    if (typeof google === 'undefined') {
                      $.ajax({
                        method: "GET",
                        url: MapComponent.baseUrl + '?key=' + MapComponent.apiKey,
                        dataType: "script"
                      }).done(function () {
                        MapComponent.googleMapApiLoaded = true;
                        MapComponent.googleMapApiLoading = false;
                        resolve(true);
                      }).fail(function () {
                        MapComponent.addMapError(TunnelDelivery.mapsConfig.errors.mapLoadingFailed, 'mapLoadingFailed');
                        $('.MapComponent').each(function (index, value) {
                          var mapComponent = $(value).data('map-component');
                          mapComponent.stopLoading();
                        });
                        reject({
                          code: 'mapLoadingFailed',
                          message: 'GoogleMap Javascript API Loading loading failed'
                        });
                      });
                    }
                  } else {
                    reject("GoogleMap Javascript API is already loaded");
                  }
                }));

              case 1:
              case "end":
                return _context2.stop();
            }
          }
        }, _callee2);
      }));

      function loadGoogleMapApi() {
        return _loadGoogleMapApi.apply(this, arguments);
      }

      return loadGoogleMapApi;
    }()
  }, {
    key: "addMapError",
    value: function addMapError(message, code, e) {
      var $mapComponents = $('.MapComponent');
      var $mapComponentsErrors = $('.MapComponent-error');
      var detail = {
        code: code,
        message: message,
        error: e,
        MapComponent: MapComponent
      };
      library/* Library.createEvent */.Z.createEvent($mapComponents, 'error', detail);

      if ($mapComponentsErrors.length === 0) {
        $mapComponents.addClass('isDisabled').append("<div class=\"MapComponent-error\"><div>".concat(message, "</div></div>"));
      } else {
        $mapComponents.addClass('isDisabled');
        $mapComponentsErrors.append("<div>".concat(message, "</div>"));
      }
    }
  }, {
    key: "initPopinMarkerDisplay",
    value: function initPopinMarkerDisplay() {
      if (!library/* Library.OrangeLibrary.PopinMarker.has */.Z.OrangeLibrary.PopinMarker.has('displayTitle')) {
        library/* Library.OrangeLibrary.PopinMarker.set */.Z.OrangeLibrary.PopinMarker.set('displayTitle', MapComponent.popinMarkerDisplayTitle);
      }

      if (!library/* Library.OrangeLibrary.PopinMarker.has */.Z.OrangeLibrary.PopinMarker.has('displayContent')) {
        library/* Library.OrangeLibrary.PopinMarker.set */.Z.OrangeLibrary.PopinMarker.set('displayContent', MapComponent.popinMarkerDisplayContent);
      }
    }
  }, {
    key: "popinMarkerDisplayContent",
    value: function popinMarkerDisplayContent(boutique) {
      return;
    }
  }, {
    key: "popinMarkerDisplayTitle",
    value: function popinMarkerDisplayTitle(boutique) {
      var content = "";

      if (boutique.name) {
        content += boutique.name;
      }

      if (boutique.name && boutique.distance) {
        content += ' - ';
      }

      if (boutique.distance) {
        content += Math.round(boutique.distance / 100) / 10 + '&nbsp;km';
      }

      return content;
    }
  }]);

  return MapComponent;
}();

mapComponent_defineProperty(MapComponent, "autoLoadMap", void 0);

mapComponent_defineProperty(MapComponent, "googleMapApiLoaded", false);

mapComponent_defineProperty(MapComponent, "googleMapApiLoading", false);

mapComponent_defineProperty(MapComponent, "apiKey", void 0);

mapComponent_defineProperty(MapComponent, "baseUrl", void 0);
;// CONCATENATED MODULE: ./src/modules/application/vendors/bridge-api/bridge-api-abstract.ts
function bridge_api_abstract_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function bridge_api_abstract_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

var BridgeApiAbstract = function BridgeApiAbstract() {
  bridge_api_abstract_classCallCheck(this, BridgeApiAbstract);
};

bridge_api_abstract_defineProperty(BridgeApiAbstract, "debug", void 0);

bridge_api_abstract_defineProperty(BridgeApiAbstract, "baseURL", void 0);

bridge_api_abstract_defineProperty(BridgeApiAbstract, "geoLocalisationRadius", 100);

bridge_api_abstract_defineProperty(BridgeApiAbstract, "limit", 200);

bridge_api_abstract_defineProperty(BridgeApiAbstract, "headers", void 0);
;// CONCATENATED MODULE: ./src/modules/application/vendors/bridge-api/bridge-leadformance.ts
function bridge_leadformance_createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = bridge_leadformance_unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function bridge_leadformance_unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return bridge_leadformance_arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return bridge_leadformance_arrayLikeToArray(o, minLen); }

function bridge_leadformance_arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function bridge_leadformance_asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function bridge_leadformance_asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { bridge_leadformance_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { bridge_leadformance_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function bridge_leadformance_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function bridge_leadformance_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function bridge_leadformance_createClass(Constructor, protoProps, staticProps) { if (protoProps) bridge_leadformance_defineProperties(Constructor.prototype, protoProps); if (staticProps) bridge_leadformance_defineProperties(Constructor, staticProps); return Constructor; }

function bridge_leadformance_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }




var BridgeLeadformance = /*#__PURE__*/function () {
  function BridgeLeadformance() {
    bridge_leadformance_classCallCheck(this, BridgeLeadformance);
  }

  bridge_leadformance_createClass(BridgeLeadformance, null, [{
    key: "getGeoLocalisationBoutiques",
    value: function () {
      var _getGeoLocalisationBoutiques = bridge_leadformance_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee2(lat, lng, locationType) {
        var _this = this;

        return regeneratorRuntime.wrap(function _callee2$(_context2) {
          while (1) {
            switch (_context2.prev = _context2.next) {
              case 0:
                return _context2.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref = bridge_leadformance_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee(resolve, reject) {
                    var filters, endpoint, geoReponse, completeResponse, anyOf, geoBoutiqueMap, _iterator, _step, boutique, searchEndpoint, searchFilters, response, _iterator2, _step2, _boutique, geoBoutique, filteredData;

                    return regeneratorRuntime.wrap(function _callee$(_context) {
                      while (1) {
                        switch (_context.prev = _context.next) {
                          case 0:
                            _context.prev = 0;

                            _this.debug.group('BridgeApi - getGeoLocalisationBoutiques()');

                            filters = {
                              query: lat + "," + lng,
                              radius: BridgeApi.geoLocalisationRadius
                            };
                            endpoint = "locations/geosearch?" + "limit=" + BridgeApi.limit;
                            _context.next = 6;
                            return _this.postMethod(endpoint, filters);

                          case 6:
                            geoReponse = _context.sent;
                            completeResponse = [];
                            anyOf = [];
                            geoBoutiqueMap = new Map();
                            _iterator = bridge_leadformance_createForOfIteratorHelper(geoReponse);

                            try {
                              for (_iterator.s(); !(_step = _iterator.n()).done;) {
                                boutique = _step.value;
                                geoBoutiqueMap.set(boutique._id, boutique);
                                anyOf.push(boutique.externalAttributes.locationId);
                              }
                            } catch (err) {
                              _iterator.e(err);
                            } finally {
                              _iterator.f();
                            }

                            searchEndpoint = "locations/search?" + "limit=" + BridgeApi.limit;
                            searchFilters = {
                              status: "ACTIVE",
                              externalAttributes: {
                                "locationId": {
                                  "anyOf": anyOf
                                }
                              }
                            };
                            _context.next = 16;
                            return _this.postMethod(searchEndpoint, searchFilters);

                          case 16:
                            response = _context.sent;
                            _iterator2 = bridge_leadformance_createForOfIteratorHelper(response);

                            try {
                              for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
                                _boutique = _step2.value;
                                geoBoutique = geoBoutiqueMap.get(_boutique._id);

                                if (geoBoutique) {
                                  _boutique.localisation.distance = geoBoutique.localisation.distance;
                                }

                                completeResponse.push(_boutique);
                              }
                            } catch (err) {
                              _iterator2.e(err);
                            } finally {
                              _iterator2.f();
                            }

                            filteredData = BridgeApi.filterResponse(completeResponse, locationType);

                            _this.debug.groupEnd();

                            TunnelDelivery.searchType = searchTypeEnum.geolocation;
                            resolve(filteredData);
                            _context.next = 28;
                            break;

                          case 25:
                            _context.prev = 25;
                            _context.t0 = _context["catch"](0);
                            reject(_context.t0);

                          case 28:
                          case "end":
                            return _context.stop();
                        }
                      }
                    }, _callee, null, [[0, 25]]);
                  }));

                  return function (_x4, _x5) {
                    return _ref.apply(this, arguments);
                  };
                }()));

              case 1:
              case "end":
                return _context2.stop();
            }
          }
        }, _callee2);
      }));

      function getGeoLocalisationBoutiques(_x, _x2, _x3) {
        return _getGeoLocalisationBoutiques.apply(this, arguments);
      }

      return getGeoLocalisationBoutiques;
    }()
  }, {
    key: "searchBoutiques",
    value: function () {
      var _searchBoutiques = bridge_leadformance_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee4(query, locationType) {
        var _this2 = this;

        return regeneratorRuntime.wrap(function _callee4$(_context4) {
          while (1) {
            switch (_context4.prev = _context4.next) {
              case 0:
                return _context4.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref2 = bridge_leadformance_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee3(resolve, reject) {
                    var filters, endpoint, response, filteredData;
                    return regeneratorRuntime.wrap(function _callee3$(_context3) {
                      while (1) {
                        switch (_context3.prev = _context3.next) {
                          case 0:
                            _context3.prev = 0;
                            filters = {
                              status: "ACTIVE",
                              localisation: {
                                "city": query
                              }
                            };
                            endpoint = "locations/search?" + "limit=" + BridgeApi.limit;
                            _context3.next = 5;
                            return _this2.postMethod(endpoint, filters);

                          case 5:
                            response = _context3.sent;
                            filteredData = BridgeApi.filterResponse(response, locationType);
                            TunnelDelivery.searchType = searchTypeEnum.search;
                            resolve(filteredData);
                            _context3.next = 14;
                            break;

                          case 11:
                            _context3.prev = 11;
                            _context3.t0 = _context3["catch"](0);
                            reject(_context3.t0);

                          case 14:
                          case "end":
                            return _context3.stop();
                        }
                      }
                    }, _callee3, null, [[0, 11]]);
                  }));

                  return function (_x8, _x9) {
                    return _ref2.apply(this, arguments);
                  };
                }()));

              case 1:
              case "end":
                return _context4.stop();
            }
          }
        }, _callee4);
      }));

      function searchBoutiques(_x6, _x7) {
        return _searchBoutiques.apply(this, arguments);
      }

      return searchBoutiques;
    }()
  }, {
    key: "getAll",
    value: function () {
      var _getAll = bridge_leadformance_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee6(locationType) {
        var _this3 = this;

        return regeneratorRuntime.wrap(function _callee6$(_context6) {
          while (1) {
            switch (_context6.prev = _context6.next) {
              case 0:
                return _context6.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref3 = bridge_leadformance_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee5(resolve, reject) {
                    var filters, endpoint, response, filteredData;
                    return regeneratorRuntime.wrap(function _callee5$(_context5) {
                      while (1) {
                        switch (_context5.prev = _context5.next) {
                          case 0:
                            _context5.prev = 0;
                            filters = {
                              status: "ACTIVE"
                            };
                            endpoint = "locations/search?" + "limit=" + BridgeApi.limit;
                            _context5.next = 5;
                            return _this3.postMethod(endpoint, filters);

                          case 5:
                            response = _context5.sent;
                            filteredData = BridgeApi.filterResponse(response, locationType);
                            TunnelDelivery.searchType = searchTypeEnum.list;
                            resolve(filteredData);
                            _context5.next = 14;
                            break;

                          case 11:
                            _context5.prev = 11;
                            _context5.t0 = _context5["catch"](0);
                            reject(_context5.t0);

                          case 14:
                          case "end":
                            return _context5.stop();
                        }
                      }
                    }, _callee5, null, [[0, 11]]);
                  }));

                  return function (_x11, _x12) {
                    return _ref3.apply(this, arguments);
                  };
                }()));

              case 1:
              case "end":
                return _context6.stop();
            }
          }
        }, _callee6);
      }));

      function getAll(_x10) {
        return _getAll.apply(this, arguments);
      }

      return getAll;
    }()
  }, {
    key: "findOneBoutique",
    value: function () {
      var _findOneBoutique = bridge_leadformance_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee7(id) {
        return regeneratorRuntime.wrap(function _callee7$(_context7) {
          while (1) {
            switch (_context7.prev = _context7.next) {
              case 0:
                return _context7.abrupt("return", new Promise(function (resolve, reject) {
                  $.ajax({
                    method: "GET",
                    dataType: "json",
                    url: BridgeApi.baseURL + "locations/" + id,
                    headers: BridgeApi.headers
                  }).done(function (data) {
                    resolve(data);
                  }).fail(function (data) {
                    reject(data);
                  });
                }));

              case 1:
              case "end":
                return _context7.stop();
            }
          }
        }, _callee7);
      }));

      function findOneBoutique(_x13) {
        return _findOneBoutique.apply(this, arguments);
      }

      return findOneBoutique;
    }()
  }, {
    key: "postMethod",
    value: function () {
      var _postMethod = bridge_leadformance_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee8(url, filters) {
        var _this4 = this;

        return regeneratorRuntime.wrap(function _callee8$(_context8) {
          while (1) {
            switch (_context8.prev = _context8.next) {
              case 0:
                return _context8.abrupt("return", new Promise(function (resolve, reject) {
                  _this4.debug.group('BridgeApi - postMethod()', url, filters);

                  $.ajax({
                    method: "POST",
                    dataType: "json",
                    url: BridgeApi.baseURL + url,
                    headers: BridgeApi.headers,
                    data: JSON.stringify({
                      "filters": filters
                    })
                  }).always(function () {
                    _this4.debug.groupEnd();
                  }).done(function (data) {
                    _this4.debug.log(data);

                    resolve(data.rows);
                  }).fail(function (data) {
                    reject(data);
                  });
                }));

              case 1:
              case "end":
                return _context8.stop();
            }
          }
        }, _callee8);
      }));

      function postMethod(_x14, _x15) {
        return _postMethod.apply(this, arguments);
      }

      return postMethod;
    }()
  }]);

  return BridgeLeadformance;
}();

bridge_leadformance_defineProperty(BridgeLeadformance, "debug", new debug/* Debug */.c(true));
// EXTERNAL MODULE: external "algoliasearch"
var external_algoliasearch_ = __webpack_require__("algoliasearch");
var external_algoliasearch_default = /*#__PURE__*/__webpack_require__.n(external_algoliasearch_);
;// CONCATENATED MODULE: ./src/modules/application/vendors/bridge-api/bridge-algolia.ts
function bridge_algolia_createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = bridge_algolia_unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function bridge_algolia_unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return bridge_algolia_arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return bridge_algolia_arrayLikeToArray(o, minLen); }

function bridge_algolia_arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function bridge_algolia_asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function bridge_algolia_asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { bridge_algolia_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { bridge_algolia_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function bridge_algolia_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function bridge_algolia_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function bridge_algolia_createClass(Constructor, protoProps, staticProps) { if (protoProps) bridge_algolia_defineProperties(Constructor.prototype, protoProps); if (staticProps) bridge_algolia_defineProperties(Constructor, staticProps); return Constructor; }

function bridge_algolia_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }




var BridgeAlgolia = /*#__PURE__*/function () {
  function BridgeAlgolia() {
    bridge_algolia_classCallCheck(this, BridgeAlgolia);
  }

  bridge_algolia_createClass(BridgeAlgolia, null, [{
    key: "getGeoLocalisationBoutiques",
    value: function () {
      var _getGeoLocalisationBoutiques = bridge_algolia_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee2(lat, lng, locationType) {
        var _this = this;

        return regeneratorRuntime.wrap(function _callee2$(_context2) {
          while (1) {
            switch (_context2.prev = _context2.next) {
              case 0:
                return _context2.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref = bridge_algolia_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee(resolve, reject) {
                    var response, stores;
                    return regeneratorRuntime.wrap(function _callee$(_context) {
                      while (1) {
                        switch (_context.prev = _context.next) {
                          case 0:
                            _context.prev = 0;
                            _context.next = 3;
                            return BridgeAlgolia.algoliaSearchWithPosition(lat, lng, locationType);

                          case 3:
                            response = _context.sent;
                            stores = BridgeAlgolia.formatAlgoliaData(response);

                            _this.debug.groupEnd();

                            TunnelDelivery.searchType = searchTypeEnum.geolocation;
                            resolve(stores);
                            _context.next = 13;
                            break;

                          case 10:
                            _context.prev = 10;
                            _context.t0 = _context["catch"](0);
                            reject(_context.t0);

                          case 13:
                          case "end":
                            return _context.stop();
                        }
                      }
                    }, _callee, null, [[0, 10]]);
                  }));

                  return function (_x4, _x5) {
                    return _ref.apply(this, arguments);
                  };
                }()));

              case 1:
              case "end":
                return _context2.stop();
            }
          }
        }, _callee2);
      }));

      function getGeoLocalisationBoutiques(_x, _x2, _x3) {
        return _getGeoLocalisationBoutiques.apply(this, arguments);
      }

      return getGeoLocalisationBoutiques;
    }()
  }, {
    key: "searchBoutiques",
    value: function () {
      var _searchBoutiques = bridge_algolia_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee4(query, locationType) {
        return regeneratorRuntime.wrap(function _callee4$(_context4) {
          while (1) {
            switch (_context4.prev = _context4.next) {
              case 0:
                return _context4.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref2 = bridge_algolia_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee3(resolve, reject) {
                    var searchOptions, response, stores;
                    return regeneratorRuntime.wrap(function _callee3$(_context3) {
                      while (1) {
                        switch (_context3.prev = _context3.next) {
                          case 0:
                            _context3.prev = 0;
                            searchOptions = {
                              filters: BridgeAlgolia.formatFilters(locationType)
                            };
                            _context3.next = 4;
                            return BridgeAlgolia.algoliaSearch(query, searchOptions);

                          case 4:
                            response = _context3.sent;
                            stores = BridgeAlgolia.formatAlgoliaData(response);
                            TunnelDelivery.searchType = searchTypeEnum.search;
                            resolve(stores);
                            _context3.next = 13;
                            break;

                          case 10:
                            _context3.prev = 10;
                            _context3.t0 = _context3["catch"](0);
                            reject(_context3.t0);

                          case 13:
                          case "end":
                            return _context3.stop();
                        }
                      }
                    }, _callee3, null, [[0, 10]]);
                  }));

                  return function (_x8, _x9) {
                    return _ref2.apply(this, arguments);
                  };
                }()));

              case 1:
              case "end":
                return _context4.stop();
            }
          }
        }, _callee4);
      }));

      function searchBoutiques(_x6, _x7) {
        return _searchBoutiques.apply(this, arguments);
      }

      return searchBoutiques;
    }()
  }, {
    key: "getAll",
    value: function () {
      var _getAll = bridge_algolia_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee6(locationType) {
        return regeneratorRuntime.wrap(function _callee6$(_context6) {
          while (1) {
            switch (_context6.prev = _context6.next) {
              case 0:
                return _context6.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref3 = bridge_algolia_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee5(resolve, reject) {
                    var searchOptions, response, stores;
                    return regeneratorRuntime.wrap(function _callee5$(_context5) {
                      while (1) {
                        switch (_context5.prev = _context5.next) {
                          case 0:
                            _context5.prev = 0;
                            searchOptions = {
                              filters: BridgeAlgolia.formatFilters(locationType)
                            };
                            _context5.next = 4;
                            return BridgeAlgolia.algoliaSearch('', searchOptions);

                          case 4:
                            response = _context5.sent;
                            stores = BridgeAlgolia.formatAlgoliaData(response);
                            TunnelDelivery.searchType = searchTypeEnum.list;
                            resolve(stores);
                            _context5.next = 13;
                            break;

                          case 10:
                            _context5.prev = 10;
                            _context5.t0 = _context5["catch"](0);
                            reject(_context5.t0);

                          case 13:
                          case "end":
                            return _context5.stop();
                        }
                      }
                    }, _callee5, null, [[0, 10]]);
                  }));

                  return function (_x11, _x12) {
                    return _ref3.apply(this, arguments);
                  };
                }()));

              case 1:
              case "end":
                return _context6.stop();
            }
          }
        }, _callee6);
      }));

      function getAll(_x10) {
        return _getAll.apply(this, arguments);
      }

      return getAll;
    }()
  }, {
    key: "algoliaSetup",
    value: function algoliaSetup(index, appId, apiKey, boutiqueIdName) {
      if (!this.client || !this.index) {
        this.client = external_algoliasearch_default()(appId, apiKey);
        this.index = this.client.initIndex(index);
        this.boutiqueIdName = boutiqueIdName;
      }
    }
  }, {
    key: "algoliaSearchWithPosition",
    value: function () {
      var _algoliaSearchWithPosition = bridge_algolia_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee7(lat, lng, locationType) {
        var searchOptions;
        return regeneratorRuntime.wrap(function _callee7$(_context7) {
          while (1) {
            switch (_context7.prev = _context7.next) {
              case 0:
                searchOptions = {
                  getRankingInfo: true,
                  aroundLatLng: lat + ', ' + lng
                };
                searchOptions.filters = BridgeAlgolia.formatFilters(locationType);
                return _context7.abrupt("return", BridgeAlgolia.index.search('', searchOptions).then(function (r) {
                  return r.hits;
                }));

              case 3:
              case "end":
                return _context7.stop();
            }
          }
        }, _callee7);
      }));

      function algoliaSearchWithPosition(_x13, _x14, _x15) {
        return _algoliaSearchWithPosition.apply(this, arguments);
      }

      return algoliaSearchWithPosition;
    }()
  }, {
    key: "formatFilters",
    value: function formatFilters(filters) {
      var filterQuery = 'Status:"ACTIVE"';

      if (filters) {
        filters.forEach(function (filterName, index) {
          filterQuery += " AND ";
          filterQuery = "".concat(filterQuery, "pickup:\"").concat(filterName, "\"");
        });
      }

      return filterQuery;
    }
  }, {
    key: "formatAlgoliaData",
    value: function formatAlgoliaData(data) {
      var days = ["friday", "monday", "saturday", "sunday", "thursday", "tuesday", "wednesday"];
      var stores = [];

      var _iterator = bridge_algolia_createForOfIteratorHelper(data),
          _step;

      try {
        var _loop = function _loop() {
          var boutique = _step.value;
          var obj = {};
          obj._id = boutique[BridgeAlgolia.boutiqueIdName];
          obj.name = boutique["Location name"];
          obj.description = boutique["Description"];
          obj.status = boutique["Status"];
          obj.url = boutique["URL"];
          obj.localisation = {};
          obj.localisation.address1 = boutique["Address 1"];
          obj.localisation.city = boutique["City"];
          obj.localisation.latitude = boutique["_geoloc"]["lat"];
          obj.localisation.longitude = boutique["_geoloc"]["lng"];

          if ("_rankingInfo" in boutique && "geoDistance" in boutique["_rankingInfo"] && boutique["_rankingInfo"]["geoDistance"]) {
            obj.localisation.distance = boutique["_rankingInfo"]["geoDistance"];
          }

          obj.type = {};
          obj.type.label = "Franchise";

          if ("pickup" in boutique) {
            obj.type._id = boutique["pickup"];
          }

          obj.phone = boutique["Phone"] ? boutique["Phone"] : "";
          obj.openingHours = {};
          $.each(days, function (index, value) {
            obj.openingHours[value] = {};
            obj.openingHours[value].periods = [];

            if (boutique["horaires"] && value in boutique["horaires"] && boutique["horaires"][value].length) {
              var _data = [];
              $.each(boutique["horaires"][value], function (key, val) {
                var object = {};
                object.openTime = val[0];
                object.closeTime = val[1];

                _data.push(object);
              });

              if (_data.length) {
                obj.openingHours[value].periods = _data;
              }
            }
          });
          stores.push(obj);
        };

        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          _loop();
        }
      } catch (err) {
        _iterator.e(err);
      } finally {
        _iterator.f();
      }

      return stores;
    }
  }, {
    key: "algoliaSearch",
    value: function () {
      var _algoliaSearch = bridge_algolia_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee8() {
        var query,
            searchOptions,
            _args8 = arguments;
        return regeneratorRuntime.wrap(function _callee8$(_context8) {
          while (1) {
            switch (_context8.prev = _context8.next) {
              case 0:
                query = _args8.length > 0 && _args8[0] !== undefined ? _args8[0] : '';
                searchOptions = _args8.length > 1 && _args8[1] !== undefined ? _args8[1] : {};
                return _context8.abrupt("return", BridgeAlgolia.index.search(query, searchOptions).then(function (r) {
                  return r.hits;
                }));

              case 3:
              case "end":
                return _context8.stop();
            }
          }
        }, _callee8);
      }));

      function algoliaSearch() {
        return _algoliaSearch.apply(this, arguments);
      }

      return algoliaSearch;
    }()
  }]);

  return BridgeAlgolia;
}();

bridge_algolia_defineProperty(BridgeAlgolia, "debug", new debug/* Debug */.c(true));

bridge_algolia_defineProperty(BridgeAlgolia, "index", void 0);

bridge_algolia_defineProperty(BridgeAlgolia, "client", void 0);

bridge_algolia_defineProperty(BridgeAlgolia, "boutiqueIdName", void 0);
;// CONCATENATED MODULE: ./src/modules/application/vendors/bridge-api/bridge-api.ts
function _typeof(obj) { "@babel/helpers - typeof"; if (typeof Symbol === "function" && typeof Symbol.iterator === "symbol") { _typeof = function _typeof(obj) { return typeof obj; }; } else { _typeof = function _typeof(obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; }; } return _typeof(obj); }

function bridge_api_asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function bridge_api_asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { bridge_api_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { bridge_api_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function bridge_api_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function bridge_api_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function bridge_api_createClass(Constructor, protoProps, staticProps) { if (protoProps) bridge_api_defineProperties(Constructor.prototype, protoProps); if (staticProps) bridge_api_defineProperties(Constructor, staticProps); return Constructor; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function"); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, writable: true, configurable: true } }); if (superClass) _setPrototypeOf(subClass, superClass); }

function _setPrototypeOf(o, p) { _setPrototypeOf = Object.setPrototypeOf || function _setPrototypeOf(o, p) { o.__proto__ = p; return o; }; return _setPrototypeOf(o, p); }

function _createSuper(Derived) { var hasNativeReflectConstruct = _isNativeReflectConstruct(); return function _createSuperInternal() { var Super = _getPrototypeOf(Derived), result; if (hasNativeReflectConstruct) { var NewTarget = _getPrototypeOf(this).constructor; result = Reflect.construct(Super, arguments, NewTarget); } else { result = Super.apply(this, arguments); } return _possibleConstructorReturn(this, result); }; }

function _possibleConstructorReturn(self, call) { if (call && (_typeof(call) === "object" || typeof call === "function")) { return call; } return _assertThisInitialized(self); }

function _assertThisInitialized(self) { if (self === void 0) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return self; }

function _isNativeReflectConstruct() { if (typeof Reflect === "undefined" || !Reflect.construct) return false; if (Reflect.construct.sham) return false; if (typeof Proxy === "function") return true; try { Date.prototype.toString.call(Reflect.construct(Date, [], function () {})); return true; } catch (e) { return false; } }

function _getPrototypeOf(o) { _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf : function _getPrototypeOf(o) { return o.__proto__ || Object.getPrototypeOf(o); }; return _getPrototypeOf(o); }

function bridge_api_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }





var BridgeApi = /*#__PURE__*/function (_BridgeApiAbstract) {
  _inherits(BridgeApi, _BridgeApiAbstract);

  var _super = _createSuper(BridgeApi);

  function BridgeApi() {
    bridge_api_classCallCheck(this, BridgeApi);

    return _super.apply(this, arguments);
  }

  bridge_api_createClass(BridgeApi, null, [{
    key: "getGeoLocalisationBoutiques",
    value: function () {
      var _getGeoLocalisationBoutiques = bridge_api_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee(lat, lng, locationType) {
        return regeneratorRuntime.wrap(function _callee$(_context) {
          while (1) {
            switch (_context.prev = _context.next) {
              case 0:
                if (!(BridgeApi.algoliaIndex && BridgeApi.algoliaAppId && BridgeApi.algoliaApiKey && BridgeApi.boutiqueIdName)) {
                  _context.next = 5;
                  break;
                }

                BridgeAlgolia.algoliaSetup(BridgeApi.algoliaIndex, BridgeApi.algoliaAppId, BridgeApi.algoliaApiKey, BridgeApi.boutiqueIdName);
                return _context.abrupt("return", BridgeAlgolia.getGeoLocalisationBoutiques(lat, lng, locationType));

              case 5:
                if (!(BridgeApi.headers && BridgeApi.baseURL)) {
                  _context.next = 7;
                  break;
                }

                return _context.abrupt("return", BridgeLeadformance.getGeoLocalisationBoutiques(lat, lng, locationType));

              case 7:
              case "end":
                return _context.stop();
            }
          }
        }, _callee);
      }));

      function getGeoLocalisationBoutiques(_x, _x2, _x3) {
        return _getGeoLocalisationBoutiques.apply(this, arguments);
      }

      return getGeoLocalisationBoutiques;
    }()
  }, {
    key: "searchBoutiques",
    value: function () {
      var _searchBoutiques = bridge_api_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee3(query, locationType) {
        return regeneratorRuntime.wrap(function _callee3$(_context3) {
          while (1) {
            switch (_context3.prev = _context3.next) {
              case 0:
                if (!(query && typeof query !== "string")) {
                  _context3.next = 2;
                  break;
                }

                return _context3.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref = bridge_api_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee2(resolve, reject) {
                    return regeneratorRuntime.wrap(function _callee2$(_context2) {
                      while (1) {
                        switch (_context2.prev = _context2.next) {
                          case 0:
                            reject("Query is not a string or undefined");

                          case 1:
                          case "end":
                            return _context2.stop();
                        }
                      }
                    }, _callee2);
                  }));

                  return function (_x6, _x7) {
                    return _ref.apply(this, arguments);
                  };
                }()));

              case 2:
                if (!(query.length === 0)) {
                  _context3.next = 4;
                  break;
                }

                return _context3.abrupt("return", this.getAll(locationType));

              case 4:
                if (!(BridgeApi.algoliaIndex && BridgeApi.algoliaAppId && BridgeApi.algoliaApiKey && BridgeApi.boutiqueIdName)) {
                  _context3.next = 9;
                  break;
                }

                BridgeAlgolia.algoliaSetup(BridgeApi.algoliaIndex, BridgeApi.algoliaAppId, BridgeApi.algoliaApiKey, BridgeApi.boutiqueIdName);
                return _context3.abrupt("return", BridgeAlgolia.searchBoutiques(query, locationType));

              case 9:
                if (!(BridgeApi.headers && BridgeApi.baseURL)) {
                  _context3.next = 11;
                  break;
                }

                return _context3.abrupt("return", BridgeLeadformance.searchBoutiques(query, locationType));

              case 11:
              case "end":
                return _context3.stop();
            }
          }
        }, _callee3, this);
      }));

      function searchBoutiques(_x4, _x5) {
        return _searchBoutiques.apply(this, arguments);
      }

      return searchBoutiques;
    }()
  }, {
    key: "getAll",
    value: function () {
      var _getAll = bridge_api_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee4(locationType) {
        return regeneratorRuntime.wrap(function _callee4$(_context4) {
          while (1) {
            switch (_context4.prev = _context4.next) {
              case 0:
                if (!(BridgeApi.algoliaIndex && BridgeApi.algoliaAppId && BridgeApi.algoliaApiKey && BridgeApi.boutiqueIdName)) {
                  _context4.next = 5;
                  break;
                }

                BridgeAlgolia.algoliaSetup(BridgeApi.algoliaIndex, BridgeApi.algoliaAppId, BridgeApi.algoliaApiKey, BridgeApi.boutiqueIdName);
                return _context4.abrupt("return", BridgeAlgolia.getAll(locationType));

              case 5:
                if (!(BridgeApi.headers && BridgeApi.baseURL)) {
                  _context4.next = 7;
                  break;
                }

                return _context4.abrupt("return", BridgeLeadformance.getAll(locationType));

              case 7:
              case "end":
                return _context4.stop();
            }
          }
        }, _callee4);
      }));

      function getAll(_x8) {
        return _getAll.apply(this, arguments);
      }

      return getAll;
    }()
  }, {
    key: "filterResponse",
    value: function filterResponse(rows, locationTypes) {
      return rows.filter(function (boutique) {
        if (boutique.type && locationTypes.includes(boutique.type._id)) {
          return boutique;
        }
      });
    }
  }]);

  return BridgeApi;
}(BridgeApiAbstract);

bridge_api_defineProperty(BridgeApi, "debug", new debug/* Debug */.c(true));

bridge_api_defineProperty(BridgeApi, "index", void 0);

bridge_api_defineProperty(BridgeApi, "baseURL", void 0);

bridge_api_defineProperty(BridgeApi, "geoLocalisationRadius", 100);

bridge_api_defineProperty(BridgeApi, "limit", 200);

bridge_api_defineProperty(BridgeApi, "headers", {
  "X-Api-Key": '',
  "Accept": 'application/vnd.bridge+json; version=1',
  "Content-Type": "application/json"
});

bridge_api_defineProperty(BridgeApi, "algoliaIndex", void 0);

bridge_api_defineProperty(BridgeApi, "algoliaAppId", void 0);

bridge_api_defineProperty(BridgeApi, "algoliaApiKey", void 0);
;// CONCATENATED MODULE: ./src/modules/application/vendors/bridge-api/geoconding-api.ts
function geoconding_api_asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function geoconding_api_asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { geoconding_api_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { geoconding_api_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function geoconding_api_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function geoconding_api_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function geoconding_api_createClass(Constructor, protoProps, staticProps) { if (protoProps) geoconding_api_defineProperties(Constructor.prototype, protoProps); if (staticProps) geoconding_api_defineProperties(Constructor, staticProps); return Constructor; }

function geoconding_api_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }


var PositionType;

(function (PositionType) {
  PositionType["fake"] = "fake";
  PositionType["geolocalisation"] = "geolocalisation";
  PositionType["geocoding"] = "geocoding";
})(PositionType || (PositionType = {}));

var GeocondingApi = /*#__PURE__*/function () {
  function GeocondingApi() {
    geoconding_api_classCallCheck(this, GeocondingApi);
  }

  geoconding_api_createClass(GeocondingApi, null, [{
    key: "getPosition",
    value: function () {
      var _getPosition = geoconding_api_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee2(text) {
        var _this = this;

        return regeneratorRuntime.wrap(function _callee2$(_context2) {
          while (1) {
            switch (_context2.prev = _context2.next) {
              case 0:
                this.debug.group('GeocondingApi - getPosition()', text);
                return _context2.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref = geoconding_api_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee(resolve, reject) {
                    var query, response, currentPosition;
                    return regeneratorRuntime.wrap(function _callee$(_context) {
                      while (1) {
                        switch (_context.prev = _context.next) {
                          case 0:
                            _context.prev = 0;
                            query = "&address=" + encodeURI(text);
                            _context.next = 4;
                            return _this.getMethod(query);

                          case 4:
                            response = _context.sent;

                            if (response.status === 'OK' && typeof response.results[0].geometry.location !== 'undefined') {
                              currentPosition = response.results[0].geometry.location;
                              currentPosition.type = PositionType.geocoding;

                              _this.debug.group('GeocondingApi - getPosition(), currentPosition', currentPosition);

                              _this.debug.groupEnd();

                              resolve(currentPosition);
                            }

                            _this.debug.groupEnd();

                            reject("Google Geocoding API return no result");
                            _context.next = 14;
                            break;

                          case 10:
                            _context.prev = 10;
                            _context.t0 = _context["catch"](0);

                            _this.debug.groupEnd();

                            reject(_context.t0);

                          case 14:
                          case "end":
                            return _context.stop();
                        }
                      }
                    }, _callee, null, [[0, 10]]);
                  }));

                  return function (_x2, _x3) {
                    return _ref.apply(this, arguments);
                  };
                }()));

              case 2:
              case "end":
                return _context2.stop();
            }
          }
        }, _callee2, this);
      }));

      function getPosition(_x) {
        return _getPosition.apply(this, arguments);
      }

      return getPosition;
    }()
  }, {
    key: "getMethod",
    value: function () {
      var _getMethod = geoconding_api_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee3(query) {
        return regeneratorRuntime.wrap(function _callee3$(_context3) {
          while (1) {
            switch (_context3.prev = _context3.next) {
              case 0:
                return _context3.abrupt("return", new Promise(function (resolve, reject) {
                  $.ajax({
                    method: "GET",
                    url: GeocondingApi.baseUrl + "?key=" + GeocondingApi.apiKey + query
                  }).done(function (response) {
                    resolve(response);
                  }).fail(function (response) {
                    reject(response);
                  });
                }));

              case 1:
              case "end":
                return _context3.stop();
            }
          }
        }, _callee3);
      }));

      function getMethod(_x4) {
        return _getMethod.apply(this, arguments);
      }

      return getMethod;
    }()
  }]);

  return GeocondingApi;
}();

geoconding_api_defineProperty(GeocondingApi, "debug", new debug/* Debug */.c(true));

geoconding_api_defineProperty(GeocondingApi, "apiKey", void 0);

geoconding_api_defineProperty(GeocondingApi, "baseUrl", void 0);
// EXTERNAL MODULE: ./node_modules/moment/moment.js
var moment = __webpack_require__("./node_modules/moment/moment.js");
var moment_default = /*#__PURE__*/__webpack_require__.n(moment);
;// CONCATENATED MODULE: ./src/modules/vendor/moment-locale-loader.ts
function moment_locale_loader_asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function moment_locale_loader_asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { moment_locale_loader_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { moment_locale_loader_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function moment_locale_loader_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function moment_locale_loader_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function moment_locale_loader_createClass(Constructor, protoProps, staticProps) { if (protoProps) moment_locale_loader_defineProperties(Constructor.prototype, protoProps); if (staticProps) moment_locale_loader_defineProperties(Constructor, staticProps); return Constructor; }

function moment_locale_loader_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }


var MomentLocaleLoader = /*#__PURE__*/function () {
  function MomentLocaleLoader() {
    moment_locale_loader_classCallCheck(this, MomentLocaleLoader);
  }

  moment_locale_loader_createClass(MomentLocaleLoader, null, [{
    key: "load",
    value: function load(locale) {
      return new Promise( /*#__PURE__*/function () {
        var _ref = moment_locale_loader_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee(resolve, reject) {
          return regeneratorRuntime.wrap(function _callee$(_context) {
            while (1) {
              switch (_context.prev = _context.next) {
                case 0:
                  if (!locale) {
                    locale = document.documentElement.lang;
                    locale = MomentLocaleLoader.getMatchingLocale(locale);
                  }

                  __webpack_require__("./node_modules/moment/locale lazy recursive ^\\.\\/.*\\.js$")("./".concat(locale, ".js")).then(function (result) {
                    moment_default().locale(locale);
                  }).catch(function (error) {
                    console.error("moment locale ".concat(locale, " doesn't exist"));
                  });

                case 2:
                case "end":
                  return _context.stop();
              }
            }
          }, _callee);
        }));

        return function (_x, _x2) {
          return _ref.apply(this, arguments);
        };
      }());
    }
  }, {
    key: "getMatchingLocale",
    value: function getMatchingLocale(locale) {
      if (locale in MomentLocaleLoader.locales) {
        return MomentLocaleLoader.locales[locale];
      }

      return locale;
    }
  }]);

  return MomentLocaleLoader;
}();

moment_locale_loader_defineProperty(MomentLocaleLoader, "locales", {
  "en": "en-gb",
  "hy": "hy-am",
  "oc": "oc-lnc",
  "pa": "pa-in",
  "tl": "tl-ph",
  "ug": "ug-cn",
  "zh": "zh-cn"
});
;// CONCATENATED MODULE: ./src/modules/ui/calendar-picker/calendar-picker.ts
function calendar_picker_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function calendar_picker_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function calendar_picker_createClass(Constructor, protoProps, staticProps) { if (protoProps) calendar_picker_defineProperties(Constructor.prototype, protoProps); if (staticProps) calendar_picker_defineProperties(Constructor, staticProps); return Constructor; }

function calendar_picker_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }



MomentLocaleLoader.load();
var CalendarPicker = /*#__PURE__*/function () {
  function CalendarPicker(config) {
    var _config$isDark;

    calendar_picker_classCallCheck(this, CalendarPicker);

    calendar_picker_defineProperty(this, "element", void 0);

    calendar_picker_defineProperty(this, "template", void 0);

    calendar_picker_defineProperty(this, "config", void 0);

    calendar_picker_defineProperty(this, "isDark", false);

    calendar_picker_defineProperty(this, "name", 'date');

    calendar_picker_defineProperty(this, "vue", void 0);

    calendar_picker_defineProperty(this, "isoDayNameMapping", {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday'
    });

    this.config = config;
    this.template = document.getElementById(config.templateId);
    this.name = config.name;
    this.isDark = (_config$isDark = config.isDark) !== null && _config$isDark !== void 0 ? _config$isDark : false;
  }

  calendar_picker_createClass(CalendarPicker, [{
    key: "createEvent",
    value: function createEvent(element, eventName) {
      var detail = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : {};
      detail.calendarPicker = this;
      var event = new CustomEvent(eventName, {
        'detail': detail
      });
      element.dispatchEvent(event);
    }
  }, {
    key: "getIsoDayName",
    value: function getIsoDayName(weekDay) {
      return this.isoDayNameMapping[weekDay];
    }
  }, {
    key: "updateOpeningHours",
    value: function updateOpeningHours(openingHours) {
      if (this.vue) {
        this.vue.$data.openingHours = openingHours;
      }
    }
  }], [{
    key: "getDaysOfTheWeek",
    value: function getDaysOfTheWeek() {
      var days = [];

      for (var i = 0; i < 7; i++) {
        days.push(moment_default()().weekday(i).format('dd')[0].toUpperCase());
      }

      return days;
    }
  }]);

  return CalendarPicker;
}();
// EXTERNAL MODULE: ./node_modules/vue/dist/vue.esm.js
var vue_esm = __webpack_require__("./node_modules/vue/dist/vue.esm.js");
// EXTERNAL MODULE: ./src/modules/helper/mobile-detect/mobile-detect.ts
var mobile_detect = __webpack_require__("./src/modules/helper/mobile-detect/mobile-detect.ts");
;// CONCATENATED MODULE: ./src/modules/ui/calendar-picker/calendar-picker.vue.ts
function calendar_picker_vue_createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = calendar_picker_vue_unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function calendar_picker_vue_unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return calendar_picker_vue_arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return calendar_picker_vue_arrayLikeToArray(o, minLen); }

function calendar_picker_vue_arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function calendar_picker_vue_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function calendar_picker_vue_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function calendar_picker_vue_createClass(Constructor, protoProps, staticProps) { if (protoProps) calendar_picker_vue_defineProperties(Constructor.prototype, protoProps); if (staticProps) calendar_picker_vue_defineProperties(Constructor, staticProps); return Constructor; }






MomentLocaleLoader.load();
var CalendarPickerVue = /*#__PURE__*/function () {
  function CalendarPickerVue() {
    calendar_picker_vue_classCallCheck(this, CalendarPickerVue);
  }

  calendar_picker_vue_createClass(CalendarPickerVue, null, [{
    key: "registerComponent",
    value: function registerComponent(_this) {
      vue_esm/* default.component */.Z.component('calendar-picker', {
        name: "CalendarPicker",
        template: '#' + _this.config.templateId,
        props: ['openingHours'],
        mounted: function mounted() {
          this.events();
          this.rendezVous = false;

          _this.createEvent(document, 'CalendarPicker:mounted', {
            element: this.$el
          });
        },
        watch: {
          openingHours: function openingHours(val, oldVal) {
            if (val) {
              this.checkDate(this.selectedMoment);
              this.checkHour(this.selectedMoment);
            }
          }
        },
        updated: function updated() {
          var formValidator = $(this.$el).parents('.FormValidator').data('form-validator');
          formValidator.validator(true);
        },
        data: function data() {
          return {
            dates: [],
            isDark: _this.isDark,
            dateIsVisible: false,
            hourIsVisible: false,
            days: CalendarPicker.getDaysOfTheWeek(),
            today: moment_default()().startOf('day'),
            dateContext: moment_default()().startOf('day'),
            selectedMoment: null,
            inputMoment: null,
            dateIsValid: true,
            hourIsValid: true,
            name: _this.name,
            limit: {
              minDate: moment_default()().startOf('day').toDate(),
              maxDate: false
            },
            rendezVous: undefined
          };
        },
        computed: {
          hasMeridiem: function hasMeridiem() {
            return moment_default().localeData().longDateFormat('LT').indexOf('A') > -1;
          },
          year: function year() {
            return this.dateContext.format('Y');
          },
          month: function month() {
            return this.dateContext.format('MMMM');
          },
          monthNumber: function monthNumber() {
            return this.dateContext.format('MM');
          },
          displayHour: {
            get: function get() {
              var date = this.selectedMoment;

              if (!date || date.hour() === 0 && date.minute() === 0) {
                return null;
              }

              return date.format('LT');
            },
            set: function set(newValue) {
              var tmpMoment = moment_default()(newValue, ['LT']);

              if (!tmpMoment.isValid()) {
                return;
              }

              this.inputMoment = tmpMoment;
            }
          },
          displayDate: {
            get: function get() {
              var date = this.selectedMoment;

              if (!date) {
                return null;
              }

              return date.format('LL');
            },
            set: function set(newValue) {
              var tmpMoment = moment_default()(newValue, ['LL', 'L']);

              if (!tmpMoment.isValid()) {
                return;
              }

              this.inputMoment = tmpMoment;
            }
          },
          rawDate: function rawDate() {
            var date = this.selectedMoment;

            if (!date || this.isDisabledHour(this.selectedMoment)) {
              return '';
            }

            return date.format((moment_default()).HTML5_FMT.DATETIME_LOCAL);
          },
          selectedHour: function selectedHour() {
            return this.selectedMoment.hour();
          },
          selectedMinute: function selectedMinute() {
            return this.selectedMoment.minute();
          },
          selectedPeriod: function selectedPeriod() {
            return this.selectedMoment.format('A');
          },
          isoDate: function isoDate() {
            return this.dateContext.toDate();
          },
          currentMonth: function currentMonth() {
            return this.month.toString()[0].toUpperCase() + this.month.toString().slice(1) + ' ' + this.year.toString();
          },
          daysInMonth: function daysInMonth() {
            return this.dateContext.daysInMonth();
          },
          firstDayOfMonth: function firstDayOfMonth() {
            var firstDay = this.dateContext.clone().startOf('month');
            return firstDay.weekday();
          },
          initialDate: function initialDate() {
            return this.today.get('date');
          },
          initialMonth: function initialMonth() {
            return this.today.format('MM');
          },
          initialYear: function initialYear() {
            return this.today.format('Y');
          },
          previousMonth: function previousMonth() {
            return this.dateContext.clone().subtract(1, 'month').endOf('month');
          },
          nextMonth: function nextMonth() {
            return this.dateContext.clone().add(1, 'month').startOf('month');
          },
          nextHour: function nextHour() {
            this.ajustNextOpenHour();
            return this.selectedMoment.clone();
          },
          previousHour: function previousHour() {
            this.ajustPreviousOpenHour();
            return this.selectedMoment.clone();
          },
          nextMinuteStep: function nextMinuteStep() {
            this.ajustNextMinute();
            return this.selectedMoment.clone();
          },
          previousMinuteStep: function previousMinuteStep() {
            this.ajustPreviousMinute();
            return this.selectedMoment.clone();
          },
          nextMeridiemStep: function nextMeridiemStep() {
            this.ajustNextMeridiem();
            return this.selectedMoment.clone();
          },
          previousMeridiemStep: function previousMeridiemStep() {
            this.ajustPreviousMeridiem();
            return this.selectedMoment.clone();
          }
        },
        methods: {
          ajustHour: function ajustHour(modifier) {
            var unity = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : 'hour';
            var amount = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : 1;
            var search = 0;
            var tmpMoment = this.selectedMoment.clone();
            tmpMoment[modifier](amount, unity);

            while (this.isDisabledHour(tmpMoment) && search < 96) {
              search++;
              tmpMoment[modifier](amount, unity);
            }

            if (search < 96) {
              this.selectedMoment = tmpMoment;
              return true;
            } else {
              return false;
            }
          },
          ajustPreviousOpenHour: function ajustPreviousOpenHour() {
            return this.ajustHour('subtract');
          },
          ajustNextOpenHour: function ajustNextOpenHour() {
            return this.ajustHour('add');
          },
          ajustPreviousMinute: function ajustPreviousMinute() {
            return this.ajustHour('subtract', 'minute', 15);
          },
          ajustNextMinute: function ajustNextMinute() {
            return this.ajustHour('add', 'minute', 15);
          },
          ajustPreviousMeridiem: function ajustPreviousMeridiem() {
            return this.ajustHour('subtract', 'hour', 12);
          },
          ajustNextMeridiem: function ajustNextMeridiem() {
            return this.ajustHour('add', 'hour', 12);
          },
          checkDateInput: function checkDateInput() {
            if (this.inputMoment) {
              this.checkDate(this.inputMoment);
              this.inputMoment = null;
              this.closeDate();
            } else {
              this.checkDate(this.selectedDate);
            }

            this.checkHour(this.selectedMoment);
          },
          checkHourInput: function checkHourInput() {
            if (this.inputMoment) {
              this.checkHour(this.inputMoment);
              this.inputMoment = null;
              this.closeHour();
            } else {
              this.checkHour(this.selectedDate);
            }

            this.checkDate(this.selectedDate);
          },
          checkDate: function checkDate(dateMoment) {
            if (!dateMoment) {
              return;
            }

            this.dateIsValid = !this.isDisabledDate(dateMoment);
            this.selectedMoment = this.mergeDate(this.selectedMoment, dateMoment);
          },
          checkHour: function checkHour(dateMoment) {
            if (!dateMoment) {
              return;
            }

            dateMoment = this.mergeDate(dateMoment, this.selectedMoment);
            this.hourIsValid = !this.isDisabledHour(dateMoment);
            this.selectedMoment = dateMoment;
          },
          events: function events() {
            var _this2 = this;

            document.addEventListener('click', function (e) {
              var $target = $(e.target);

              if ($target.closest('.CalendarPicker-calendarWidget').length === 0) {
                _this2.onDateFocusOut();
              }

              if ($target.closest('.CalendarPicker-hourWidget').length === 0) {
                _this2.onHourFocusOut();
              }
            });
          },
          onDateFocusOut: function onDateFocusOut() {
            this.dateIsVisible = false;
            this.checkDate(this.selectedDate);
            this.checkHour(this.selectedDate);
          },
          onHourFocusOut: function onHourFocusOut() {
            this.hourIsVisible = false;
            this.checkHour(this.selectedDate);
            this.checkDate(this.selectedDate);
          },
          addMonth: function addMonth() {
            if (!this.isNextMonthDisabled()) {
              this.dateContext = this.nextMonth;

              _this.createEvent(this.$el, 'change:month', {
                date: this.isoDate,
                direction: "previous"
              });
            }

            _this.createEvent(this.$el, 'change:month', {
              date: this.isoDate,
              direction: "next"
            });
          },
          subtractMonth: function subtractMonth() {
            if (!this.isPreviousMonthDisabled()) {
              this.dateContext = this.previousMonth;

              _this.createEvent(this.$el, 'change:month', {
                date: this.isoDate,
                direction: "previous"
              });
            }
          },
          addHour: function addHour() {
            this.selectedMoment = this.nextHour;
            this.checkHour(this.selectedMoment);
            this.checkDate(this.selectedMoment);
          },
          removeHour: function removeHour() {
            this.selectedMoment = this.previousHour;
            this.checkHour(this.selectedMoment);
            this.checkDate(this.selectedMoment);
          },
          addMinute: function addMinute() {
            this.selectedMoment = this.nextMinuteStep;
            this.checkHour(this.selectedMoment);
            this.checkDate(this.selectedMoment);
          },
          removeMinute: function removeMinute() {
            this.selectedMoment = this.previousMinuteStep;
            this.checkHour(this.selectedMoment);
            this.checkDate(this.selectedMoment);
          },
          addMeridiem: function addMeridiem() {
            this.selectedMoment = this.nextMeridiemStep;
            this.checkHour(this.selectedMoment);
            this.checkDate(this.selectedMoment);
          },
          removeMeridiem: function removeMeridiem() {
            this.selectedMoment = this.previousMeridiemStep;
            this.checkHour(this.selectedMoment);
            this.checkDate(this.selectedMoment);
          },
          isPreviousMonthDisabled: function isPreviousMonthDisabled() {
            return this.limit.minDate && this.previousMonth < this.limit.minDate;
          },
          isNextMonthDisabled: function isNextMonthDisabled() {
            return this.limit.maxDate && this.nextMonth > this.limit.maxDate;
          },
          selectDate: function selectDate(day) {
            if (this.isDisabledDay(day)) {
              return;
            }

            var thisMoment = moment_default()(this.getDateFromDay(day));

            if (this.selectedMoment) {
              this.selectedMoment = this.mergeDate(this.selectedMoment, thisMoment);
            } else {
              this.selectedMoment = moment_default()(this.getDateFromDay(day)).startOf('days');
            }

            this.checkDate(this.selectedMoment);
            this.checkDate(this.selectedMoment);

            _this.createEvent(this.$el, 'select:day', {
              date: this.isoDate
            });

            this.closeDate();
          },
          openDate: function openDate() {
            this.closeHour();
            this.dateIsVisible = true;

            if (this.selectedMoment) {
              this.dateContext = this.mergeDate(this.dateContext, this.selectedMoment);
            }

            _this.createEvent(this.$el, 'date:open');
          },
          openHour: function openHour() {
            this.closeDate();

            if (!this.selectedMoment) {
              return;
            }

            this.hourIsVisible = true;

            _this.createEvent(this.$el, 'hour:open');
          },
          closeDate: function closeDate($event) {
            if ($event && !$($event.target).hasClass('CalendarPicker-wrapper')) {
              return;
            }

            this.dateIsVisible = false;

            _this.createEvent(this.$el, 'date:close');
          },
          closeHour: function closeHour($event) {
            if ($event && !$($event.target).hasClass('CalendarPicker-wrapper')) {
              return;
            }

            this.hourIsVisible = false;

            _this.createEvent(this.$el, 'hour:close');
          },
          getDateFromDay: function getDateFromDay(day) {
            return moment_default()().year(this.dateContext.year()).month(this.dateContext.month()).date(day);
          },
          isSelectedDate: function isSelectedDate(day) {
            if (!this.selectedMoment || this.selectedMoment.length === 0) {
              return false;
            }

            return this.selectedMoment.format("LL") === this.getDateFromDay(day).format("LL");
          },
          isDayOpen: function isDayOpen(moment) {
            if (!this.openingHours) {
              return true;
            }

            return this.getDayOpeningHours(moment).periods.length > 0;
          },
          getDayOpeningHours: function getDayOpeningHours(momentDate) {
            if (!this.openingHours) {
              return [];
            }

            var dayNameOfTheWeek = _this.getIsoDayName(momentDate.isoWeekday());

            return this.openingHours[dayNameOfTheWeek];
          },
          isDisabledDay: function isDisabledDay(day) {
            var thisDate = this.getDateFromDay(day);
            return this.isDisabledDate(thisDate);
          },
          isDisabledDate: function isDisabledDate(momentDate) {
            if (this.limit.maxDate && momentDate > this.limit.maxDate) {
              return true;
            }

            if (this.limit.minDate && momentDate < this.limit.minDate) {
              return true;
            }

            return !this.isDayOpen(momentDate);
          },
          isDisabledHour: function isDisabledHour(momentDate) {
            if (!this.openingHours) {
              return false;
            }

            if (this.isDisabledDate(momentDate)) {
              return true;
            }

            var periods = this.getDayOpeningHours(momentDate).periods;
            var isDisabled;

            var _iterator = calendar_picker_vue_createForOfIteratorHelper(periods),
                _step;

            try {
              for (_iterator.s(); !(_step = _iterator.n()).done;) {
                var period = _step.value;
                var openTime = this.mergeDate(moment_default()("1987-01-17 " + period.openTime, 'YYYY-MM-DD HH:mm'), momentDate);
                var closeTime = this.mergeDate(moment_default()("1987-01-17 " + period.closeTime, 'YYYY-MM-DD HH:mm'), momentDate);

                if (openTime.isSame(closeTime)) {
                  return false;
                }

                isDisabled = !(momentDate.isSameOrAfter(openTime) && momentDate.isSameOrBefore(closeTime));

                if (isDisabled === false) {
                  return false;
                }
              }
            } catch (err) {
              _iterator.e(err);
            } finally {
              _iterator.f();
            }

            return true;
          },
          getDateClasses: function getDateClasses(day) {
            return {
              'isToday': this.today.format("LL") === this.getDateFromDay(day).format("LL"),
              'isSelected': this.isSelectedDate(day),
              'isDisabled': this.isDisabledDay(day)
            };
          },
          mergeDate: function mergeDate(momentHour, momentDate) {
            return momentHour.year(momentDate.year()).month(momentDate.month()).date(momentDate.date()).clone();
          },
          isMobile: function isMobile() {
            return mobile_detect/* MobileDetectHelper.md.isMobile */.V.md.isMobile();
          }
        },
        filters: {}
      });
    }
  }]);

  return CalendarPickerVue;
}();
// EXTERNAL MODULE: ./src/ts/tools.ts
var tools = __webpack_require__("./src/ts/tools.ts");
;// CONCATENATED MODULE: ./src/modules/tunnel/tunnel-delivery/autocomplete.vue.ts
function autocomplete_vue_createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = autocomplete_vue_unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function autocomplete_vue_unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return autocomplete_vue_arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return autocomplete_vue_arrayLikeToArray(o, minLen); }

function autocomplete_vue_arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function autocomplete_vue_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function autocomplete_vue_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function autocomplete_vue_createClass(Constructor, protoProps, staticProps) { if (protoProps) autocomplete_vue_defineProperties(Constructor.prototype, protoProps); if (staticProps) autocomplete_vue_defineProperties(Constructor, staticProps); return Constructor; }




var AutocompleteVue = /*#__PURE__*/function () {
  function AutocompleteVue() {
    autocomplete_vue_classCallCheck(this, AutocompleteVue);
  }

  autocomplete_vue_createClass(AutocompleteVue, null, [{
    key: "init",
    value: function init() {
      return new vue_esm/* default */.Z({
        name: 'ShopSearch-autocomplete',
        el: "#ShopSearch-autocomplete",
        data: {
          cities: [],
          query: ""
        },
        computed: {
          displayedCities: function displayedCities() {
            var array = [];
            var escapedQuery = (0,tools/* escapeStringRegexp */.fA)(this.query);
            var pattern = new RegExp(escapedQuery, 'gi');

            var _iterator = autocomplete_vue_createForOfIteratorHelper(this.cities),
                _step;

            try {
              for (_iterator.s(); !(_step = _iterator.n()).done;) {
                var city = _step.value;
                var capitalizeCity = TunnelDelivery.capitalizeString(city);
                var matches = Array.from(city.matchAll(pattern));
                var boldCity = capitalizeCity;
                var addedCharacter = 0;

                for (var _i = 0, _matches = matches; _i < _matches.length; _i++) {
                  var match = _matches[_i];
                  boldCity = boldCity.slice(0, match.index + addedCharacter) + "<strong>" + boldCity.slice(match.index + addedCharacter);
                  addedCharacter += 8;
                  boldCity = boldCity.slice(0, match.index + this.query.length + addedCharacter) + "</strong>" + boldCity.slice(match.index + this.query.length + addedCharacter);
                  addedCharacter += 9;
                }

                array.push({
                  "original": capitalizeCity,
                  "bold": boldCity
                });
              }
            } catch (err) {
              _iterator.e(err);
            } finally {
              _iterator.f();
            }

            return array;
          }
        },
        methods: {
          reset: function reset() {
            this.query = '';
            this.cities = [];
          },
          autocompleteClicked: function autocompleteClicked(city) {
            $(".JS-ShopSearch-input").val(TunnelDelivery.capitalizeString(city));
            $('.ShopSearch-autocompleteContainer').addClass('JS-autocompleteHidden');
            TunnelDelivery.searchBoutiques();
          }
        }
      });
    }
  }]);

  return AutocompleteVue;
}();
;// CONCATENATED MODULE: ./src/modules/tunnel/tunnel-delivery/boutique-list.vue.ts
function boutique_list_vue_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function boutique_list_vue_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function boutique_list_vue_createClass(Constructor, protoProps, staticProps) { if (protoProps) boutique_list_vue_defineProperties(Constructor.prototype, protoProps); if (staticProps) boutique_list_vue_defineProperties(Constructor, staticProps); return Constructor; }



var BoutiqueListVue = /*#__PURE__*/function () {
  function BoutiqueListVue() {
    boutique_list_vue_classCallCheck(this, BoutiqueListVue);
  }

  boutique_list_vue_createClass(BoutiqueListVue, null, [{
    key: "init",
    value: function init() {
      return new vue_esm/* default */.Z({
        name: 'BoutiqueList',
        el: '#boutiqueList',
        data: {
          boutiques: [],
          selectedBoutique: undefined,
          hoveredBoutique: undefined,
          focusedBoutique: undefined,
          query: ""
        },
        methods: {
          searchType: function searchType() {
            return TunnelDelivery.searchType;
          },
          getLocationType: function getLocationType() {
            return TunnelDelivery.locationType;
          },
          selectBoutique: function selectBoutique(boutique) {
            TunnelDelivery.selectBoutique(boutique, false);
            TunnelDelivery.toggleShopSearchModal();
          },
          highlightMarker: function highlightMarker(boutique, highlight) {
            if (highlight) {
              this.hoveredBoutique = boutique;
              TunnelDelivery.highlightMarker(boutique, highlight);
            } else {
              this.hoveredBoutique = undefined;

              if (!(this.focusedBoutique && boutique.id === this.focusedBoutique.id)) {
                TunnelDelivery.highlightMarker(boutique, highlight);
              }
            }
          },
          focusBoutique: function focusBoutique(boutique) {
            this.focusedBoutique = boutique;
            TunnelDelivery.cleanMarkerHighlight();
            TunnelDelivery.highlightMarker(boutique, true);
            TunnelDelivery.mapsComponents.big.centerMap(boutique);
          },
          cleanFocusBoutique: function cleanFocusBoutique() {
            this.focusedBoutique = undefined;
            TunnelDelivery.cleanMarkerHighlight();
          },
          getShopResultClasses: function getShopResultClasses(boutique) {
            return {
              'isSelected': this.isSelected(boutique),
              'isHovered': this.isHovered(boutique),
              'isFocused': this.isFocused(boutique)
            };
          },
          isSelected: function isSelected(boutique) {
            return this.selectedBoutique && boutique.id === this.selectedBoutique.id;
          },
          isHovered: function isHovered(boutique) {
            return this.hoveredBoutique && boutique.id === this.hoveredBoutique.id;
          },
          isFocused: function isFocused(boutique) {
            return this.focusedBoutique && boutique.id === this.focusedBoutique.id;
          }
        },
        filters: {
          capitalize: function capitalize(text) {
            return TunnelDelivery.capitalizeString(text);
          }
        }
      });
    }
  }]);

  return BoutiqueListVue;
}();
;// CONCATENATED MODULE: ./src/modules/tunnel/tunnel-delivery/delivery-shop-section.vue.ts
function delivery_shop_section_vue_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function delivery_shop_section_vue_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function delivery_shop_section_vue_createClass(Constructor, protoProps, staticProps) { if (protoProps) delivery_shop_section_vue_defineProperties(Constructor.prototype, protoProps); if (staticProps) delivery_shop_section_vue_defineProperties(Constructor, staticProps); return Constructor; }



var DeliveryShopSectionVue = /*#__PURE__*/function () {
  function DeliveryShopSectionVue() {
    delivery_shop_section_vue_classCallCheck(this, DeliveryShopSectionVue);
  }

  delivery_shop_section_vue_createClass(DeliveryShopSectionVue, null, [{
    key: "init",
    value: function init() {
      return new vue_esm/* default */.Z({
        name: 'DeliveryShopSection',
        el: '#DeliveryShopSection',
        data: {
          selectedBoutique: undefined
        },
        mounted: function mounted() {
          $('.JS-isLoadingVue').removeClass('JS-isLoadingVue');
        },
        methods: {
          isSameOpenCloseTime: function isSameOpenCloseTime(periods) {
            if (periods.length > 0) {
              return periods[0].openTime === periods[0].closeTime;
            }

            return false;
          }
        },
        filters: {
          capitalize: function capitalize(text) {
            return TunnelDelivery.capitalizeString(text);
          }
        }
      });
    }
  }]);

  return DeliveryShopSectionVue;
}();
;// CONCATENATED MODULE: ./src/modules/tunnel/tunnel-delivery/delivery-relay-section.vue.ts
function delivery_relay_section_vue_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function delivery_relay_section_vue_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function delivery_relay_section_vue_createClass(Constructor, protoProps, staticProps) { if (protoProps) delivery_relay_section_vue_defineProperties(Constructor.prototype, protoProps); if (staticProps) delivery_relay_section_vue_defineProperties(Constructor, staticProps); return Constructor; }



var DeliveryRelaySectionVue = /*#__PURE__*/function () {
  function DeliveryRelaySectionVue() {
    delivery_relay_section_vue_classCallCheck(this, DeliveryRelaySectionVue);
  }

  delivery_relay_section_vue_createClass(DeliveryRelaySectionVue, null, [{
    key: "init",
    value: function init() {
      return new vue_esm/* default */.Z({
        name: 'DeliveryRelaySection',
        el: '#DeliveryRelaySection',
        data: {
          selectedBoutique: undefined
        },
        mounted: function mounted() {
          $('.JS-isLoadingVue').removeClass('JS-isLoadingVue');
        },
        updated: function updated() {
          var formValidator = $(this.$el).parents('.FormValidator').data('form-validator');
          formValidator.validator(true);
        },
        methods: {
          isSameOpenCloseTime: function isSameOpenCloseTime(periods) {
            if (periods.length > 0) {
              return periods[0].openTime === periods[0].closeTime;
            }

            return false;
          }
        },
        filters: {
          capitalize: function capitalize(text) {
            return TunnelDelivery.capitalizeString(text);
          }
        }
      });
    }
  }]);

  return DeliveryRelaySectionVue;
}();
// EXTERNAL MODULE: ./node_modules/gsap/index.js + 1 modules
var gsap = __webpack_require__("./node_modules/gsap/index.js");
// EXTERNAL MODULE: ./node_modules/gsap/gsap-core.js
var gsap_core = __webpack_require__("./node_modules/gsap/gsap-core.js");
;// CONCATENATED MODULE: ./src/modules/tunnel/tunnel-delivery/tunnel-delivery.ts
function tunnel_delivery_createForOfIteratorHelper(o, allowArrayLike) { var it; if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (it = tunnel_delivery_unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") { if (it) o = it; var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it.return != null) it.return(); } finally { if (didErr) throw err; } } }; }

function tunnel_delivery_unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return tunnel_delivery_arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(o); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return tunnel_delivery_arrayLikeToArray(o, minLen); }

function tunnel_delivery_arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function tunnel_delivery_asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function tunnel_delivery_asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { tunnel_delivery_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { tunnel_delivery_asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function tunnel_delivery_classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function tunnel_delivery_defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function tunnel_delivery_createClass(Constructor, protoProps, staticProps) { if (protoProps) tunnel_delivery_defineProperties(Constructor.prototype, protoProps); if (staticProps) tunnel_delivery_defineProperties(Constructor, staticProps); return Constructor; }

function tunnel_delivery_defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }














var locationTypeEnum;

(function (locationTypeEnum) {
  locationTypeEnum["boutique"] = "boutique";
  locationTypeEnum["relayPoint"] = "relayPoint";
})(locationTypeEnum || (locationTypeEnum = {}));

var searchTypeEnum;

(function (searchTypeEnum) {
  searchTypeEnum["geolocation"] = "geolocation";
  searchTypeEnum["search"] = "search";
  searchTypeEnum["list"] = "list";
})(searchTypeEnum || (searchTypeEnum = {}));

var NoResultsEnum;

(function (NoResultsEnum) {
  NoResultsEnum["main"] = "main";
  NoResultsEnum["search"] = "search";
})(NoResultsEnum || (NoResultsEnum = {}));

var TunnelDelivery = /*#__PURE__*/function () {
  function TunnelDelivery() {
    tunnel_delivery_classCallCheck(this, TunnelDelivery);
  }

  tunnel_delivery_createClass(TunnelDelivery, null, [{
    key: "init",
    value: function init() {
      this.debug.log("TunnelDelivery - init()");
      this.$element = $('.TunnelDelivery');
      this.$element.find('#radio-shop-delivery').prop('checked', 'checked');
      this.$shopSearch = $('.ShopSearch');
      this.$showSearchCloseButton = this.$shopSearch.find(".JS-shop-search-close");
      this.$noBoutiqueElements.main = this.$element.find('.TunnelDelivery-noBoutiqueText');
      this.$noBoutiqueElements.search = this.$shopSearch.find('.TunnelDelivery-noBoutiqueText');
      this.calendarPicker = new CalendarPicker({
        templateId: "calendarPickerTemplate",
        name: 'rdv_date'
      });
      CalendarPickerVue.registerComponent(this.calendarPicker);
      this.createVueInstances();
      this.saveDeliveryAddressForm();
      this.events();
      this.mapsConfig = $('[data-mapsConfig]').data("mapsconfig");
      this.defineApiKeys();
      this.initAutoloadCookie();
      this.locationType = locationTypeEnum.boutique;
      this.showSection();

      if ($('.MapComponentMain').length || $('.MapComponentBig').length || $('.DeliveryShopSection').length || $('.DeliveryPointSection').length) {
        this.load();
      }
    }
  }, {
    key: "getLoadPartial",
    value: function getLoadPartial() {
      var _this2 = this;

      return new Promise( /*#__PURE__*/function () {
        var _ref = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee(resolve, reject) {
          return regeneratorRuntime.wrap(function _callee$(_context) {
            while (1) {
              switch (_context.prev = _context.next) {
                case 0:
                  _context.prev = 0;
                  _context.next = 3;
                  return TunnelDelivery.setPositionAddress();

                case 3:
                  _context.next = 8;
                  break;

                case 5:
                  _context.prev = 5;
                  _context.t0 = _context["catch"](0);

                  _this2.debug.error('Requesting position failed :', _context.t0);

                case 8:
                  _context.prev = 8;
                  _context.next = 11;
                  return TunnelDelivery.loadAroundboutique();

                case 11:
                  resolve();
                  _context.next = 19;
                  break;

                case 14:
                  _context.prev = 14;
                  _context.t1 = _context["catch"](8);
                  MapComponent.addMapError(TunnelDelivery.mapsConfig.errors.bridgeApiLoadingFailed, 'bridgeApiLoadingFailed');

                  _this2.mapsComponents.main.stopLoading();

                  _this2.debug.error('Requesting boutiques failed :', _context.t1);

                case 19:
                case "end":
                  return _context.stop();
              }
            }
          }, _callee, null, [[0, 5], [8, 14]]);
        }));

        return function (_x, _x2) {
          return _ref.apply(this, arguments);
        };
      }());
    }
  }, {
    key: "initAllPlaceholders",
    value: function initAllPlaceholders() {
      this.mapsComponents.main.initPlaceholder();
      this.mapsComponents.big.initPlaceholder();
    }
  }, {
    key: "load",
    value: function load() {
      var _this3 = this;

      this.debug.group("TunnelDelivery - load()"); // Chargement des maps

      MapComponent.autoLoadMap = TunnelDelivery.mapsConfig.autoLoadMap;
      BridgeApi.limit = TunnelDelivery.mapsConfig.limit;
      var $mapMain = $('.MapComponentMain');
      var $mapBig = $('.MapComponentBig');

      if (!$mapMain && !$mapBig) {
        debug/* Debug.implementationError */.c.implementationError('.MapComponentMain or .MapComponentBig are not present in the page');
        return;
      }

      this.mapsComponents.main = new MapComponent($mapMain);
      this.mapsComponents.big = new MapComponent($mapBig);
      this.debug.log("New MapComponent created");
      var loadPartial = this.getLoadPartial();

      if (MapComponent.autoLoadMap) {
        this.debug.log("Autoloading...");
        Promise.all([loadPartial, MapComponent.loadGoogleMapApi()]).then(function () {
          _this3.debug.log("Loaded");

          _this3.initMap();

          _this3.selectClosestBoutique();
        }).catch(function (error) {
          if (error.code && error.code == 'mapLoadingFailed') {
            loadPartial.then(function () {
              _this3.selectClosestBoutique();
            });
          }

          _this3.debug.error(error);
        });
      } else {
        this.debug.log("Partial loading...");
        loadPartial.then(function () {
          _this3.initAllPlaceholders();

          _this3.selectClosestBoutique();

          _this3.debug.groupEnd();
        });
      }
    }
  }, {
    key: "createVueInstances",
    value: function createVueInstances() {
      if ($('#DeliveryShopSection').length) {
        this.deliveryShopSectionVue = DeliveryShopSectionVue.init();
      }

      if ($('#DeliveryRelaySection').length) {
        this.deliveryRelaySectionVue = DeliveryRelaySectionVue.init();
      }

      if ($('#ShopSearch-autocomplete').length) {
        this.autoCompleteVue = AutocompleteVue.init();
      }

      if ($('#boutiqueList').length) {
        this.boutiqueListVue = BoutiqueListVue.init();
      }
    }
  }, {
    key: "events",
    value: function events() {
      var _this4 = this;

      var _this = this;

      var $tunnelDeliveryContainer = $('.TunnelDelivery');
      var $shopSearchButtonInput = $(".JS-ShopSearch-input");
      this.$showSearchCloseButton.on('click', this.toggleShopSearchModal);
      $tunnelDeliveryContainer.on('click', '.ShopSearch-map', function (e) {
        if ($(e.target).hasClass('ShopSearch-map')) {
          _this4.toggleShopSearchModal();
        }
      });
      $tunnelDeliveryContainer.on('click', '.JS-change-shop, .JS-TunnelDelivery-selectShop', function (event) {
        event.preventDefault();

        _this4.toggleShopSearchModal();
      });
      $tunnelDeliveryContainer.on("click", '.JS-deliveryShowToggleBtn', function () {
        TunnelDelivery.toggleSection($(this));
      });
      $('input[name="radio-delivery"]').on('change', function () {
        var sectionNumber = $('input[name="radio-delivery"]:checked', '.JS-DeliverySelector').val();

        _this4.showSection(sectionNumber);
      }); // Toggle des tab de la modal

      $('.JS-tabBoutiqueList').on('click', function () {
        $('.JS-tabContentBoutiqueList').removeClass('JS-tabContentBoutiqueList-hide');
        $('.ShopSearch-content').css({
          'height': '100%',
          'overflow': ''
        });
        $('.JS-tabContentShopMap').addClass('JS-tabContentShopMap-hide');
        $('.JS-tabBoutiqueList').addClass('active');
        $('.JS-tabShopMap').removeClass('active');
      });
      $('.JS-tabShopMap').on('click', function () {
        $('.JS-tabContentShopMap').removeClass('JS-tabContentShopMap-hide');
        $('.ShopSearch-content').css({
          'height': 'auto',
          'overflow': 'visible'
        });
        $('.JS-tabContentBoutiqueList').addClass('JS-tabContentBoutiqueList-hide');
        $('.JS-tabShopMap').addClass('active');
        $('.JS-tabBoutiqueList').removeClass('active');
      });
      $shopSearchButtonInput.on("focus", function () {
        $(".ShopSearch-localisationBtn").hide();
      });
      $shopSearchButtonInput.on("keypress", function (e) {
        if (e.key === 'Enter') {
          TunnelDelivery.searchBoutiques();
        }
      });
      $shopSearchButtonInput.on("focusout", function () {
        $(".ShopSearch-localisationBtn").show();
      });
      $shopSearchButtonInput.on("click focusin", function () {
        $('.ShopSearch-autocompleteContainer').removeClass('JS-autocompleteHidden');
      });
      $('body').on('click', function (e) {
        var searchMenuIsClicked = $(e.target).closest(".ShopSearch-inputWrapper").length;

        if (searchMenuIsClicked === 0) {
          $('.ShopSearch-autocompleteContainer').addClass('JS-autocompleteHidden');
        }
      });
      $shopSearchButtonInput.on("input paste", function () {
        TunnelDelivery.autocomplete();
        var $autocompleteContainer = $('.ShopSearch-autocompleteContainer');

        if ($autocompleteContainer.hasClass('JS-autocompleteHidden')) {
          $autocompleteContainer.removeClass('JS-autocompleteHidden');
        }
      });
      $('.JS-geolocalisationSearchButton').on('click', /*#__PURE__*/tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee3() {
        var $this;
        return regeneratorRuntime.wrap(function _callee3$(_context3) {
          while (1) {
            switch (_context3.prev = _context3.next) {
              case 0:
                $this = $(this);

                if (!$this.hasClass('isDisabled')) {
                  _context3.next = 3;
                  break;
                }

                return _context3.abrupt("return");

              case 3:
                _this.setPositionAddress().then( /*#__PURE__*/function () {
                  var _ref3 = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee2(response) {
                    var _response;

                    return regeneratorRuntime.wrap(function _callee2$(_context2) {
                      while (1) {
                        switch (_context2.prev = _context2.next) {
                          case 0:
                            _context2.prev = 0;
                            $this.addClass('isDisabled');
                            _context2.next = 4;
                            return BridgeApi.getGeoLocalisationBoutiques(_this.currentPosition.lat, _this.currentPosition.lng, _this.rawLocationType);

                          case 4:
                            _response = _context2.sent;
                            $this.removeClass('isDisabled');

                            _this.updateResults(_response);

                            _context2.next = 12;
                            break;

                          case 9:
                            _context2.prev = 9;
                            _context2.t0 = _context2["catch"](0);
                            MapComponent.addMapError(TunnelDelivery.mapsConfig.errors.bridgeApiLoadingFailed, 'bridgeApiLoadingFailed', _context2.t0);

                          case 12:
                          case "end":
                            return _context2.stop();
                        }
                      }
                    }, _callee2, null, [[0, 9]]);
                  }));

                  return function (_x3) {
                    return _ref3.apply(this, arguments);
                  };
                }()).catch(function (e) {
                  TunnelDelivery.geolocalisationError(e);
                });

              case 4:
              case "end":
                return _context3.stop();
            }
          }
        }, _callee3, this);
      })));
      $('.JS-searchBoutiqueButton').on('click', function () {
        TunnelDelivery.searchBoutiques();
      }); // Pour section des adresses

      $('.JS-change-address').on('click', function () {
        $('.DeliveryAddressSection-preview').hide();
        $('.DeliveryAddressSection-form').show();
      });
      $('.JS-TunnelAddressSectionReturn').on('click', function () {
        $('.DeliveryAddressSection-formName').val(_this4.addressDeliveryForm.name).trigger('input');
        $('.DeliveryAddressSection-formFirstName').val(_this4.addressDeliveryForm.firstName).trigger('input');
        $('.DeliveryAddressSection-formAddress').val(_this4.addressDeliveryForm.address).trigger('input');
        $('.DeliveryAddressSection-formAddressComplement').val(_this4.addressDeliveryForm.addressComplement).trigger('input');
        $('.DeliveryAddressSection-formPostalCode').val(_this4.addressDeliveryForm.postalCode).trigger('input');
        $('.DeliveryAddressSection-formCity').val(_this4.addressDeliveryForm.city).trigger('input');
        $('.DeliveryAddressSection-form').hide();
        $('.DeliveryAddressSection-preview').show();
      });
      $('.JS-TunnelAddressSectionValidate').on('click', function () {
        _this4.saveDeliveryAddressForm();

        $('.DeliveryAddressSection-form').hide();
        $('.DeliveryAddressSection-preview').show();
      });
    }
  }, {
    key: "geolocalisationError",
    value: function geolocalisationError(e) {
      library/* Library.createEvent */.Z.createEvent(this.$element, 'error', {
        code: 'geolocalisationFailed',
        message: this.mapsConfig.errors.geolocalisationFailed,
        error: e
      });
      $('.JS-geolocalisationSearchButton').remove();
    }
  }, {
    key: "defineApiKeys",
    value: function defineApiKeys() {
      GeocondingApi.apiKey = this.mapsConfig.api.googleGeocoding.key;
      GeocondingApi.baseUrl = this.mapsConfig.api.googleGeocoding.baseUrl;
      MapComponent.apiKey = this.mapsConfig.api.googleMap.key;
      MapComponent.baseUrl = this.mapsConfig.api.googleMap.baseUrl;

      if ("leadformanceBridge" in this.mapsConfig.api && "key" in this.mapsConfig.api.leadformanceBridge && "baseUrl" in this.mapsConfig.api.leadformanceBridge) {
        BridgeApi.headers["X-Api-Key"] = this.mapsConfig.api.leadformanceBridge.key;
        BridgeApi.baseURL = this.mapsConfig.api.leadformanceBridge.baseUrl;
      }

      if ("algoliaBridge" in this.mapsConfig.api && "index" in this.mapsConfig.api.algoliaBridge && "appId" in this.mapsConfig.api.algoliaBridge && "apiKey" in this.mapsConfig.api.algoliaBridge) {
        BridgeApi.algoliaIndex = this.mapsConfig.api.algoliaBridge.index;
        BridgeApi.algoliaAppId = this.mapsConfig.api.algoliaBridge.appId;
        BridgeApi.algoliaApiKey = this.mapsConfig.api.algoliaBridge.apiKey;
      }

      if ("algoliaBridge" in this.mapsConfig.api && "boutiqueIdName" in this.mapsConfig.api.algoliaBridge) {
        BridgeApi.boutiqueIdName = this.mapsConfig.api.algoliaBridge.boutiqueIdName;
      } else {
        BridgeApi.boutiqueIdName = "objectID";
      }
    }
  }, {
    key: "initAutoloadCookie",
    value: function initAutoloadCookie() {
      if (es_cookie.get('TunnelDelivery.autoload')) {
        this.mapsConfig.autoLoadMap = true;
      }
    }
  }, {
    key: "showSection",
    value: function showSection(sectionNumber) {
      $('.TunnelDelivery [data-section]').hide();

      if (!sectionNumber) {
        sectionNumber = $($('input[name="radio-delivery"]', '.JS-DeliverySelector')[0]).val();
      }

      var elToFind = '[data-section="' + sectionNumber + '"]';
      this.$element.find(elToFind).show();
      var $deliveryMapSection = $('.DeliveryMapSection');

      if (sectionNumber === 'pick_up_in_store') {
        $deliveryMapSection.show();

        if (this.locationType !== locationTypeEnum.boutique) {
          this.locationType = locationTypeEnum.boutique;
          this.updateResultsLocationType();
        }
      } else if (sectionNumber === 'pick_up_in_package_point') {
        $deliveryMapSection.show();

        if (this.locationType !== locationTypeEnum.relayPoint) {
          this.locationType = locationTypeEnum.relayPoint;
          this.updateResultsLocationType();
        }
      } else if (sectionNumber === 'home_delivery') {
        $deliveryMapSection.hide();
      }
    }
  }, {
    key: "toggleSection",
    value: function toggleSection($trigger) {
      var target = $trigger.attr('data-bs-target');
      var $target = $(target);

      if ($target.hasClass('open')) {
        var $textVoirPlus = $("#textVoirPlus");

        if ($textVoirPlus.length) {
          $trigger.text($textVoirPlus.val());
        } else {
          $trigger.text('Voir plus');
        }

        $target.removeClass('open');
        gsap/* gsap.to */.p8.to($target, {
          duration: 0.5,
          height: 0,
          ease: gsap_core/* Power2.easeOut */.Lp.easeOut
        });
      } else {
        var $textVoirMoins = $("#textVoirMoins");

        if ($textVoirMoins.length) {
          $trigger.text($textVoirMoins.val());
        } else {
          $trigger.text('Voir moins');
        }

        $target.addClass('open');
        gsap/* gsap.to */.p8.to($target, {
          duration: 0.5,
          height: 'auto',
          ease: gsap_core/* Power2.easeOut */.Lp.easeOut
        });
      }
    }
  }, {
    key: "saveDeliveryAddressForm",
    value: function saveDeliveryAddressForm() {
      this.addressDeliveryForm = {
        name: $('.DeliveryAddressSection-formName').val(),
        firstName: $('.DeliveryAddressSection-formFirstName').val(),
        address: $('.DeliveryAddressSection-formAddress').val(),
        addressComplement: $('.DeliveryAddressSection-formAddressComplement').val(),
        postalCode: $('.DeliveryAddressSection-formPostalCode').val(),
        city: $('.DeliveryAddressSection-formCity').val()
      };
      $('.JS-deliveryNamePreview').html("" + this.addressDeliveryForm.name + " " + this.addressDeliveryForm.firstName);
      var text = this.addressDeliveryForm.address;

      if (this.addressDeliveryForm.addressComplement) {
        text += "</br>" + this.addressDeliveryForm.addressComplement;
      }

      if (this.addressDeliveryForm.postalCode || this.addressDeliveryForm.city) {
        text += "</br>" + this.addressDeliveryForm.postalCode + " " + this.addressDeliveryForm.city;
      }

      $('.JS-deliveryAddressPreview').html(text.toString());
    }
  }, {
    key: "toggleShopSearchModal",
    value: function toggleShopSearchModal() {
      TunnelDelivery.mapsComponents.big.closeAllInfoWindow();
      TunnelDelivery.boutiqueListVue.cleanFocusBoutique();
      TunnelDelivery.$shopSearch.toggleClass("isHidden");
      TunnelDelivery.toggleBodyScroll();
    }
  }, {
    key: "toggleBodyScroll",
    value: function toggleBodyScroll() {
      $('html, body').toggleClass('big-modal-open');
    }
    /*------------------*/

    /* GESTION DES MAPS */

    /*------------------*/

  }, {
    key: "setPositionAddress",
    value: function setPositionAddress() {
      var _this5 = this;

      return new Promise( /*#__PURE__*/function () {
        var _ref4 = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee4(resolve, reject) {
          return regeneratorRuntime.wrap(function _callee4$(_context4) {
            while (1) {
              switch (_context4.prev = _context4.next) {
                case 0:
                  BridgeApi.geoLocalisationRadius = _this5.mapsConfig.radius;

                  if (!("geolocation" in navigator)) {
                    _context4.next = 4;
                    break;
                  }

                  _context4.next = 4;
                  return new Promise(function (resolvePosition, rejectPosition) {
                    navigator.geolocation.getCurrentPosition(function (position) {
                      _this5.currentPosition = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude,
                        type: PositionType.geolocalisation
                      };
                      resolvePosition();
                    }, function (error) {
                      _this5.debug.error(error);

                      resolvePosition();
                    }, {
                      timeout: 10000
                    });
                  });

                case 4:
                  _this5.debug.log("TunnelDelivery - setPositionAddress()", {
                    "currentPosition": _this5.currentPosition
                  });

                  if (!(_this5.currentPosition.type === PositionType.fake && _this5.mapsConfig.geoCodingAddress)) {
                    _context4.next = 15;
                    break;
                  }

                  _context4.prev = 6;
                  _context4.next = 9;
                  return GeocondingApi.getPosition(_this5.mapsConfig.geoCodingAddress);

                case 9:
                  _this5.currentPosition = _context4.sent;
                  _context4.next = 15;
                  break;

                case 12:
                  _context4.prev = 12;
                  _context4.t0 = _context4["catch"](6);
                  reject(_context4.t0);

                case 15:
                  if (_this5.currentPosition.type === PositionType.fake) {
                    reject("Geolocalisation is not available and Geocoding is globaly disabled");
                  }

                  resolve();

                case 17:
                case "end":
                  return _context4.stop();
              }
            }
          }, _callee4, null, [[6, 12]]);
        }));

        return function (_x4, _x5) {
          return _ref4.apply(this, arguments);
        };
      }());
    }
  }, {
    key: "loadAroundboutique",
    value: function () {
      var _loadAroundboutique = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee5() {
        var hasRealPosition;
        return regeneratorRuntime.wrap(function _callee5$(_context5) {
          while (1) {
            switch (_context5.prev = _context5.next) {
              case 0:
                hasRealPosition = this.currentPosition && this.currentPosition.type !== PositionType.fake;

                if (!hasRealPosition) {
                  _context5.next = 4;
                  break;
                }

                _context5.next = 4;
                return this.initAroundBoutiques();

              case 4:
                if (this.boutiques.length === 0 || !hasRealPosition) {
                  this.showNoBoutique();
                  this.showAllBoutique();
                }

                this.setClosestBoutique();
                this.reloadMarkers();
                this.boutiqueListVue.boutiques = this.boutiques;

              case 8:
              case "end":
                return _context5.stop();
            }
          }
        }, _callee5, this);
      }));

      function loadAroundboutique() {
        return _loadAroundboutique.apply(this, arguments);
      }

      return loadAroundboutique;
    }()
  }, {
    key: "initAroundBoutiques",
    value: function () {
      var _initAroundBoutiques = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee6() {
        var _this6 = this;

        return regeneratorRuntime.wrap(function _callee6$(_context6) {
          while (1) {
            switch (_context6.prev = _context6.next) {
              case 0:
                return _context6.abrupt("return", new Promise(function (resolve, reject) {
                  BridgeApi.getGeoLocalisationBoutiques(_this6.currentPosition.lat, _this6.currentPosition.lng, _this6.rawLocationType).then(function (data) {
                    if (data.length > 0) {
                      TunnelDelivery.hideNoBoutique(NoResultsEnum.main);
                      TunnelDelivery.hydrateBoutique(data);
                      resolve(_this6.boutiques);
                    } else {
                      _this6.debug.error('No boutique found');

                      TunnelDelivery.showNoBoutique();
                      resolve(_this6.boutiques);
                    }
                  }).catch(function (e) {
                    reject(e);
                  });
                }));

              case 1:
              case "end":
                return _context6.stop();
            }
          }
        }, _callee6);
      }));

      function initAroundBoutiques() {
        return _initAroundBoutiques.apply(this, arguments);
      }

      return initAroundBoutiques;
    }()
  }, {
    key: "loadMarkers",
    value: function loadMarkers() {
      this.mapsComponents.main.createMarkers(true);
      this.mapsComponents.big.createMarkers(false);
    }
  }, {
    key: "removeMarkers",
    value: function removeMarkers() {
      this.mapsComponents.main.removeMarkers();
      this.mapsComponents.big.removeMarkers();
    }
  }, {
    key: "reloadMarkers",
    value: function reloadMarkers() {
      this.removeMarkers();
      this.loadMarkers();
    }
  }, {
    key: "hydrateBoutique",
    value: function hydrateBoutique(data) {
      this.debug.log("TunnelDelivery - hydrateBoutique()", data);

      var _iterator = tunnel_delivery_createForOfIteratorHelper(data),
          _step;

      try {
        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          var element = _step.value;
          this.boutiques.push({
            id: element._id ? element._id : undefined,
            lat: element.localisation.latitude ? element.localisation.latitude : undefined,
            lng: element.localisation.longitude ? element.localisation.longitude : undefined,
            distance: element.localisation.distance ? element.localisation.distance : undefined,
            name: element.name ? element.name : undefined,
            description: element.description ? element.description : undefined,
            city: element.localisation.city ? element.localisation.city : undefined,
            openingHours: element.openingHours ? element.openingHours : undefined,
            typeId: element.type._id ? element.type._id : undefined,
            // Extra attributes
            phone: element.phone ? element.phone : undefined,
            fax: element.fax ? element.fax : undefined,
            email: element.email ? element.email : undefined,
            access: element.access ? element.access : undefined,
            parking: element.parking ? element.parking : undefined,
            website: element.website ? element.website : undefined,
            url: element.url ? element.url : undefined,
            shortId: element.shortId ? element.shortId : undefined,
            type: element.type ? element.type : undefined,
            specialOpeningHours: element.specialOpeningHours ? element.specialOpeningHours : undefined,
            exceptionalOpeningHours: element.exceptionalOpeningHours ? element.exceptionalOpeningHours : undefined,
            status: element.status ? element.status : undefined,
            externalAttributes: element.externalAttributes ? element.externalAttributes : undefined,
            localisation: element.localisation ? element.localisation : undefined,
            extensions: element.extensions ? element.extensions : undefined,
            inheritedMedia: element.inheritedMedia ? element.inheritedMedia : undefined,
            media: element.media ? element.media : undefined,
            offerRanges: element.offerRanges ? element.offerRanges : undefined
          });
        }
      } catch (err) {
        _iterator.e(err);
      } finally {
        _iterator.f();
      }

      this.boutiques.sort(function (a, b) {
        return a.distance - b.distance;
      });
    }
  }, {
    key: "hideNoBoutique",
    value: function hideNoBoutique(type) {
      this.debug.log('TunnelDelivery - hideNoBoutique()');
      var $elements = this.getNoBoutiqueByType(type);
      $elements.removeClass('JS-noBoutique');

      if (type !== NoResultsEnum.search) {
        this.showMainMap();
      }
    }
  }, {
    key: "showNoBoutique",
    value: function showNoBoutique(type) {
      this.debug.log('TunnelDelivery - showNoBoutique()', type);
      var $elements = this.getNoBoutiqueByType(type);
      $elements.addClass('JS-noBoutique');

      if (type !== NoResultsEnum.search) {
        this.hideMainMap();
      }
    }
  }, {
    key: "showMainMap",
    value: function showMainMap() {
      this.mapsComponents.main.$mapContainer.show();
    }
  }, {
    key: "hideMainMap",
    value: function hideMainMap() {
      this.mapsComponents.main.$mapContainer.hide();
    }
  }, {
    key: "getNoBoutiqueByType",
    value: function getNoBoutiqueByType(type) {
      if (type) {
        return this.$noBoutiqueElements[type];
      } else {
        return this.$noBoutiqueElements.main.add(this.$noBoutiqueElements.search);
      }
    } // Initialisation des maps

  }, {
    key: "initMap",
    value: function () {
      var _initMap = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee7() {
        return regeneratorRuntime.wrap(function _callee7$(_context7) {
          while (1) {
            switch (_context7.prev = _context7.next) {
              case 0:
                if ($('.MapComponentMain').length) {
                  this.mapsComponents.main.initMap();
                }

                if ($('.MapComponentBig').length) {
                  this.mapsComponents.big.initMap();
                }

                this.popinMarkerEvent();
                this.loadMarkers();

              case 4:
              case "end":
                return _context7.stop();
            }
          }
        }, _callee7, this);
      }));

      function initMap() {
        return _initMap.apply(this, arguments);
      }

      return initMap;
    }()
  }, {
    key: "setClosestBoutique",
    value: function setClosestBoutique() {
      if (this.boutiques.length > 0) {
        this.closestBoutique = this.boutiques.reduce(function (closest, boutique) {
          return closest.distance > boutique.distance ? boutique : closest;
        });
      }
    }
  }, {
    key: "selectClosestBoutique",
    value: function selectClosestBoutique() {
      if (this.closestBoutique) {
        this.selectBoutique(this.closestBoutique, true);
      }
    }
  }, {
    key: "popinMarkerEvent",
    value: function popinMarkerEvent() {
      var _this = this;

      $('.MapComponentBig').on('click', '.PopinMarker-button', function () {
        var boutiqueId = $(this).data('boutique-id');
        var currentBoutique;

        var _iterator2 = tunnel_delivery_createForOfIteratorHelper(_this.boutiques),
            _step2;

        try {
          for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
            var boutique = _step2.value;

            if (boutique.id === boutiqueId) {
              currentBoutique = boutique;
            }
          }
        } catch (err) {
          _iterator2.e(err);
        } finally {
          _iterator2.f();
        }

        if (currentBoutique) {
          _this.selectBoutique(currentBoutique);
        }

        _this.toggleShopSearchModal();
      });
    }
  }, {
    key: "cleanMarkerHighlight",
    value: function cleanMarkerHighlight() {
      this.debug.log('TunnelDelivery - cleanMarkerHighlight()');

      var _iterator3 = tunnel_delivery_createForOfIteratorHelper(this.mapsComponents.big.markers),
          _step3;

      try {
        for (_iterator3.s(); !(_step3 = _iterator3.n()).done;) {
          var marker = _step3.value;

          if (marker && this.selectedBoutique && marker.boutique.id !== this.selectedBoutique.id) {
            marker.setIcon(TunnelDelivery.mapsConfig.markersIconsUrl.normal);
          }
        }
      } catch (err) {
        _iterator3.e(err);
      } finally {
        _iterator3.f();
      }
    }
  }, {
    key: "highlightMarker",
    value: function highlightMarker(boutique, highlight) {
      this.debug.log('TunnelDelivery - highlightMarker()', boutique, highlight);
      var overMarker = this.mapsComponents.big.getMarkerByBoutiqueId(boutique.id);

      if (overMarker && (!this.selectedBoutique || boutique.id !== this.selectedBoutique.id)) {
        if (highlight) {
          overMarker.setIcon(TunnelDelivery.mapsConfig.markersIconsUrl.hover);
        } else {
          overMarker.setIcon(TunnelDelivery.mapsConfig.markersIconsUrl.normal);
        }
      }
    }
  }, {
    key: "selectBoutique",
    value: function selectBoutique(boutique) {
      var isNewData = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : false;

      if (this.selectedBoutique !== boutique) {
        TunnelDelivery.hideNoBoutique(NoResultsEnum.main);
        this.selectedBoutique = boutique;
        this.boutiqueListVue.selectedBoutique = TunnelDelivery.selectedBoutique;
        this.deliveryShopSectionVue.selectedBoutique = TunnelDelivery.selectedBoutique;
        this.deliveryRelaySectionVue.selectedBoutique = this.selectedBoutique;

        if (TunnelDelivery.allMapsAreLoaded()) {
          if (!isNewData) {
            // La légende se ferme toute seule quand on supprime le marker
            this.mapsComponents.big.closeAllInfoWindow();
          }

          TunnelDelivery.reloadMarkers();
        }
      }

      if (TunnelDelivery.allMapsAreLoaded()) {
        this.mapsComponents.main.centerMap();
        this.mapsComponents.big.centerMap();
      }
    }
  }, {
    key: "allMapsAreLoaded",
    value: function allMapsAreLoaded() {
      return this.mapsComponents.big && this.mapsComponents.main;
    }
  }, {
    key: "selectPreselectedBoutique",
    value: function selectPreselectedBoutique() {
      // Permet de passer de l'état boutique sélectionnée sans map à boutique sélectionné avec map
      if (this.selectedBoutique) {
        this.selectBoutique(this.selectedBoutique, false);
      }
    }
  }, {
    key: "autocomplete",
    value: function autocomplete() {
      var _this7 = this;

      clearTimeout(this.searchTimeout);
      var $input = $(".JS-ShopSearch-input");
      var query = $input.val().toString().trim();

      if (query.length < 2) {
        return;
      }

      this.searchTimeout = setTimeout(function () {
        _this7.updateAutocomplete(query);
      }, 500);
    }
  }, {
    key: "cleanInput",
    value: function cleanInput() {
      $(".JS-ShopSearch-input").val('');
      this.autoCompleteVue.reset();
    }
  }, {
    key: "updateAutocomplete",
    value: function () {
      var _updateAutocomplete = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee8(query) {
        var response, citiesArray, _iterator4, _step4, boutique, city;

        return regeneratorRuntime.wrap(function _callee8$(_context8) {
          while (1) {
            switch (_context8.prev = _context8.next) {
              case 0:
                _context8.prev = 0;
                _context8.next = 3;
                return BridgeApi.searchBoutiques(query, this.rawLocationType);

              case 3:
                response = _context8.sent;
                citiesArray = [];
                _iterator4 = tunnel_delivery_createForOfIteratorHelper(response);

                try {
                  for (_iterator4.s(); !(_step4 = _iterator4.n()).done;) {
                    boutique = _step4.value;
                    city = boutique.localisation.city;

                    if (citiesArray.indexOf(city) === -1) {
                      citiesArray.push(city);
                    }
                  }
                } catch (err) {
                  _iterator4.e(err);
                } finally {
                  _iterator4.f();
                }

                this.autoCompleteVue.query = query;
                this.autoCompleteVue.cities = citiesArray;
                _context8.next = 14;
                break;

              case 11:
                _context8.prev = 11;
                _context8.t0 = _context8["catch"](0);
                this.debug.log(_context8.t0);

              case 14:
              case "end":
                return _context8.stop();
            }
          }
        }, _callee8, this, [[0, 11]]);
      }));

      function updateAutocomplete(_x6) {
        return _updateAutocomplete.apply(this, arguments);
      }

      return updateAutocomplete;
    }()
  }, {
    key: "searchBoutiques",
    value: function () {
      var _searchBoutiques = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee9() {
        var $input, query, response;
        return regeneratorRuntime.wrap(function _callee9$(_context9) {
          while (1) {
            switch (_context9.prev = _context9.next) {
              case 0:
                _context9.prev = 0;
                $input = $(".JS-ShopSearch-input");
                query = "" + $input.val().toString().trim();
                _context9.next = 5;
                return BridgeApi.searchBoutiques(query, this.rawLocationType);

              case 5:
                response = _context9.sent;
                this.updateResults(response, query);
                _context9.next = 12;
                break;

              case 9:
                _context9.prev = 9;
                _context9.t0 = _context9["catch"](0);
                this.debug.error(_context9.t0);

              case 12:
              case "end":
                return _context9.stop();
            }
          }
        }, _callee9, this, [[0, 9]]);
      }));

      function searchBoutiques() {
        return _searchBoutiques.apply(this, arguments);
      }

      return searchBoutiques;
    }()
  }, {
    key: "updateResults",
    value: function () {
      var _updateResults = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee10(response) {
        var query,
            _args10 = arguments;
        return regeneratorRuntime.wrap(function _callee10$(_context10) {
          while (1) {
            switch (_context10.prev = _context10.next) {
              case 0:
                query = _args10.length > 1 && _args10[1] !== undefined ? _args10[1] : '';
                this.debug.log("TunnelDelivery - updateResults()");
                this.cleanResults();
                this.boutiqueListVue.query = query;

                if (response.length > 0) {
                  if (this.searchType !== searchTypeEnum.list) {
                    TunnelDelivery.hideNoBoutique(NoResultsEnum.search);
                  }

                  TunnelDelivery.hydrateBoutique(response);
                  this.loadMarkers();
                  this.centerOnFirstResult();
                  this.updateVueBoutiques();
                } else {
                  this.debug.log('TunnelDelivery - updateResults() : No boutiques found');
                  TunnelDelivery.showNoBoutique(NoResultsEnum.search);

                  if (this.searchType === searchTypeEnum.geolocation) {
                    this.showAllBoutique();
                  }
                }

              case 5:
              case "end":
                return _context10.stop();
            }
          }
        }, _callee10, this);
      }));

      function updateResults(_x7) {
        return _updateResults.apply(this, arguments);
      }

      return updateResults;
    }()
  }, {
    key: "showAllBoutique",
    value: function () {
      var _showAllBoutique = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee11() {
        var response;
        return regeneratorRuntime.wrap(function _callee11$(_context11) {
          while (1) {
            switch (_context11.prev = _context11.next) {
              case 0:
                this.debug.log("TunnelDelivery - showAllBoutique()");
                _context11.next = 3;
                return BridgeApi.getAll(this.rawLocationType);

              case 3:
                response = _context11.sent;

                if (response.length > 0) {
                  this.updateResults(response);
                }

              case 5:
              case "end":
                return _context11.stop();
            }
          }
        }, _callee11, this);
      }));

      function showAllBoutique() {
        return _showAllBoutique.apply(this, arguments);
      }

      return showAllBoutique;
    }()
  }, {
    key: "updateVueBoutiques",
    value: function updateVueBoutiques() {
      this.boutiqueListVue.boutiques = this.boutiques;
    }
  }, {
    key: "centerOnFirstResult",
    value: function centerOnFirstResult() {
      if (this.boutiques.length > 0) {
        this.mapsComponents.big.centerMap(this.boutiques[0]);
      }
    }
  }, {
    key: "updateResultsLocationType",
    value: function () {
      var _updateResultsLocationType = tunnel_delivery_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee12() {
        return regeneratorRuntime.wrap(function _callee12$(_context12) {
          while (1) {
            switch (_context12.prev = _context12.next) {
              case 0:
                _context12.prev = 0;
                this.cleanAllInterface();
                _context12.next = 4;
                return this.loadAroundboutique();

              case 4:
                this.selectClosestBoutique();
                _context12.next = 10;
                break;

              case 7:
                _context12.prev = 7;
                _context12.t0 = _context12["catch"](0);
                this.debug.error(_context12.t0);

              case 10:
              case "end":
                return _context12.stop();
            }
          }
        }, _callee12, this, [[0, 7]]);
      }));

      function updateResultsLocationType() {
        return _updateResultsLocationType.apply(this, arguments);
      }

      return updateResultsLocationType;
    }()
  }, {
    key: "cleanResults",
    value: function cleanResults() {
      this.boutiques = [];
      this.boutiqueListVue.boutiques = this.boutiques;
      this.removeMarkers();
    }
  }, {
    key: "cleanSelectedBoutique",
    value: function cleanSelectedBoutique() {
      this.selectedBoutique = undefined;
      this.deliveryShopSectionVue.selectedBoutique = undefined;
      this.deliveryRelaySectionVue.selectedBoutique = undefined;
    }
  }, {
    key: "cleanAllInterface",
    value: function cleanAllInterface() {
      this.cleanResults();
      this.cleanSelectedBoutique();
      this.cleanInput();
    }
    /* UTILS */

  }, {
    key: "capitalizeString",
    value: function capitalizeString(text) {
      if (text.length === 0) {
        return '';
      }

      var wordsArray = text.toLowerCase().split(' ');
      var capsArray = wordsArray.map(function (word) {
        return word[0].toUpperCase() + word.slice(1);
      });
      return capsArray.join(' ');
    }
  }, {
    key: "locationType",
    // tunnel-step-2.php
    // mapComponent
    get: function get() {
      if (!this.mapsConfig) {
        return locationTypeEnum.boutique;
      }

      if (this.rawLocationType === this.mapsConfig.relayPointLocationType) {
        return locationTypeEnum.relayPoint;
      }

      return locationTypeEnum.boutique;
    },
    set: function set(value) {
      if (!this.mapsConfig) {
        return;
      }

      if (value === locationTypeEnum.relayPoint) {
        this.rawLocationType = this.mapsConfig.relayPointLocationType;
      } else {
        this.rawLocationType = this.mapsConfig.boutiqueLocationType;
      }
    }
  }, {
    key: "currentPosition",
    get: function get() {
      if (!this._currentPosition) {
        if (TunnelDelivery.mapsConfig.defaultMapCenter) {
          var currentPosition = TunnelDelivery.mapsConfig.defaultMapCenter;
          currentPosition.type = PositionType.fake;
          return currentPosition;
        }
      } else {
        return this._currentPosition;
      }
    },
    set: function set(value) {
      this._currentPosition = value;
    }
  }]);

  return TunnelDelivery;
}();

tunnel_delivery_defineProperty(TunnelDelivery, "debug", new debug/* Debug */.c(true));

tunnel_delivery_defineProperty(TunnelDelivery, "isBodyScrollBlocked", false);

tunnel_delivery_defineProperty(TunnelDelivery, "$shopSearch", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "$showSearchCloseButton", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "addressDeliveryForm", {
  name: "",
  firstName: "",
  address: "",
  addressComplement: "",
  postalCode: "",
  city: ""
});

tunnel_delivery_defineProperty(TunnelDelivery, "mapsComponents", {
  main: undefined,
  big: undefined
});

tunnel_delivery_defineProperty(TunnelDelivery, "mapsConfig", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "$element", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "$noBoutiqueElements", {
  main: undefined,
  search: undefined
});

tunnel_delivery_defineProperty(TunnelDelivery, "boutiqueListVue", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "deliveryShopSectionVue", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "deliveryRelaySectionVue", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "autoCompleteVue", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "_currentPosition", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "boutiques", []);

tunnel_delivery_defineProperty(TunnelDelivery, "selectedBoutique", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "closestBoutique", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "rawLocationType", []);

tunnel_delivery_defineProperty(TunnelDelivery, "searchTimeout", false);

tunnel_delivery_defineProperty(TunnelDelivery, "searchType", void 0);

tunnel_delivery_defineProperty(TunnelDelivery, "calendarPicker", void 0);
;// CONCATENATED MODULE: ./src/modules/tunnel/tunnel.module.ts







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
  // Use a simple backslash escape when it’s always valid, and a \unnnn escape when the simpler form would be disallowed by Unicode patterns’ stricter grammar.
  return string.replace(/[|\\{}()[\]^$+*?.]/g, '\\$&').replace(/-/g, "\\u002d");
}
var numberFormat = new Intl.NumberFormat(document.documentElement.lang, {
  maximumSignificantDigits: 2
});

/***/ }),

/***/ "./node_modules/moment/locale lazy recursive ^\\.\\/.*\\.js$":
/***/ (function(module, __unused_webpack_exports, __webpack_require__) {

var map = {
	"./af.js": [
		"./node_modules/moment/locale/af.js",
		"moment-locale-af"
	],
	"./ar-dz.js": [
		"./node_modules/moment/locale/ar-dz.js",
		"moment-locale-ar-dz"
	],
	"./ar-kw.js": [
		"./node_modules/moment/locale/ar-kw.js",
		"moment-locale-ar-kw"
	],
	"./ar-ly.js": [
		"./node_modules/moment/locale/ar-ly.js",
		"moment-locale-ar-ly"
	],
	"./ar-ma.js": [
		"./node_modules/moment/locale/ar-ma.js",
		"moment-locale-ar-ma"
	],
	"./ar-sa.js": [
		"./node_modules/moment/locale/ar-sa.js",
		"moment-locale-ar-sa"
	],
	"./ar-tn.js": [
		"./node_modules/moment/locale/ar-tn.js",
		"moment-locale-ar-tn"
	],
	"./ar.js": [
		"./node_modules/moment/locale/ar.js",
		"moment-locale-ar"
	],
	"./az.js": [
		"./node_modules/moment/locale/az.js",
		"moment-locale-az"
	],
	"./be.js": [
		"./node_modules/moment/locale/be.js",
		"moment-locale-be"
	],
	"./bg.js": [
		"./node_modules/moment/locale/bg.js",
		"moment-locale-bg"
	],
	"./bm.js": [
		"./node_modules/moment/locale/bm.js",
		"moment-locale-bm"
	],
	"./bn-bd.js": [
		"./node_modules/moment/locale/bn-bd.js",
		"moment-locale-bn-bd"
	],
	"./bn.js": [
		"./node_modules/moment/locale/bn.js",
		"moment-locale-bn"
	],
	"./bo.js": [
		"./node_modules/moment/locale/bo.js",
		"moment-locale-bo"
	],
	"./br.js": [
		"./node_modules/moment/locale/br.js",
		"moment-locale-br"
	],
	"./bs.js": [
		"./node_modules/moment/locale/bs.js",
		"moment-locale-bs"
	],
	"./ca.js": [
		"./node_modules/moment/locale/ca.js",
		"moment-locale-ca"
	],
	"./cs.js": [
		"./node_modules/moment/locale/cs.js",
		"moment-locale-cs"
	],
	"./cv.js": [
		"./node_modules/moment/locale/cv.js",
		"moment-locale-cv"
	],
	"./cy.js": [
		"./node_modules/moment/locale/cy.js",
		"moment-locale-cy"
	],
	"./da.js": [
		"./node_modules/moment/locale/da.js",
		"moment-locale-da"
	],
	"./de-at.js": [
		"./node_modules/moment/locale/de-at.js",
		"moment-locale-de-at"
	],
	"./de-ch.js": [
		"./node_modules/moment/locale/de-ch.js",
		"moment-locale-de-ch"
	],
	"./de.js": [
		"./node_modules/moment/locale/de.js",
		"moment-locale-de"
	],
	"./dv.js": [
		"./node_modules/moment/locale/dv.js",
		"moment-locale-dv"
	],
	"./el.js": [
		"./node_modules/moment/locale/el.js",
		"moment-locale-el"
	],
	"./en-au.js": [
		"./node_modules/moment/locale/en-au.js",
		"moment-locale-en-au"
	],
	"./en-ca.js": [
		"./node_modules/moment/locale/en-ca.js",
		"moment-locale-en-ca"
	],
	"./en-gb.js": [
		"./node_modules/moment/locale/en-gb.js",
		"moment-locale-en-gb"
	],
	"./en-ie.js": [
		"./node_modules/moment/locale/en-ie.js",
		"moment-locale-en-ie"
	],
	"./en-il.js": [
		"./node_modules/moment/locale/en-il.js",
		"moment-locale-en-il"
	],
	"./en-in.js": [
		"./node_modules/moment/locale/en-in.js",
		"moment-locale-en-in"
	],
	"./en-nz.js": [
		"./node_modules/moment/locale/en-nz.js",
		"moment-locale-en-nz"
	],
	"./en-sg.js": [
		"./node_modules/moment/locale/en-sg.js",
		"moment-locale-en-sg"
	],
	"./eo.js": [
		"./node_modules/moment/locale/eo.js",
		"moment-locale-eo"
	],
	"./es-do.js": [
		"./node_modules/moment/locale/es-do.js",
		"moment-locale-es-do"
	],
	"./es-mx.js": [
		"./node_modules/moment/locale/es-mx.js",
		"moment-locale-es-mx"
	],
	"./es-us.js": [
		"./node_modules/moment/locale/es-us.js",
		"moment-locale-es-us"
	],
	"./es.js": [
		"./node_modules/moment/locale/es.js",
		"moment-locale-es"
	],
	"./et.js": [
		"./node_modules/moment/locale/et.js",
		"moment-locale-et"
	],
	"./eu.js": [
		"./node_modules/moment/locale/eu.js",
		"moment-locale-eu"
	],
	"./fa.js": [
		"./node_modules/moment/locale/fa.js",
		"moment-locale-fa"
	],
	"./fi.js": [
		"./node_modules/moment/locale/fi.js",
		"moment-locale-fi"
	],
	"./fil.js": [
		"./node_modules/moment/locale/fil.js",
		"moment-locale-fil"
	],
	"./fo.js": [
		"./node_modules/moment/locale/fo.js",
		"moment-locale-fo"
	],
	"./fr-ca.js": [
		"./node_modules/moment/locale/fr-ca.js",
		"moment-locale-fr-ca"
	],
	"./fr-ch.js": [
		"./node_modules/moment/locale/fr-ch.js",
		"moment-locale-fr-ch"
	],
	"./fr.js": [
		"./node_modules/moment/locale/fr.js",
		"moment-locale-fr"
	],
	"./fy.js": [
		"./node_modules/moment/locale/fy.js",
		"moment-locale-fy"
	],
	"./ga.js": [
		"./node_modules/moment/locale/ga.js",
		"moment-locale-ga"
	],
	"./gd.js": [
		"./node_modules/moment/locale/gd.js",
		"moment-locale-gd"
	],
	"./gl.js": [
		"./node_modules/moment/locale/gl.js",
		"moment-locale-gl"
	],
	"./gom-deva.js": [
		"./node_modules/moment/locale/gom-deva.js",
		"moment-locale-gom-deva"
	],
	"./gom-latn.js": [
		"./node_modules/moment/locale/gom-latn.js",
		"moment-locale-gom-latn"
	],
	"./gu.js": [
		"./node_modules/moment/locale/gu.js",
		"moment-locale-gu"
	],
	"./he.js": [
		"./node_modules/moment/locale/he.js",
		"moment-locale-he"
	],
	"./hi.js": [
		"./node_modules/moment/locale/hi.js",
		"moment-locale-hi"
	],
	"./hr.js": [
		"./node_modules/moment/locale/hr.js",
		"moment-locale-hr"
	],
	"./hu.js": [
		"./node_modules/moment/locale/hu.js",
		"moment-locale-hu"
	],
	"./hy-am.js": [
		"./node_modules/moment/locale/hy-am.js",
		"moment-locale-hy-am"
	],
	"./id.js": [
		"./node_modules/moment/locale/id.js",
		"moment-locale-id"
	],
	"./is.js": [
		"./node_modules/moment/locale/is.js",
		"moment-locale-is"
	],
	"./it-ch.js": [
		"./node_modules/moment/locale/it-ch.js",
		"moment-locale-it-ch"
	],
	"./it.js": [
		"./node_modules/moment/locale/it.js",
		"moment-locale-it"
	],
	"./ja.js": [
		"./node_modules/moment/locale/ja.js",
		"moment-locale-ja"
	],
	"./jv.js": [
		"./node_modules/moment/locale/jv.js",
		"moment-locale-jv"
	],
	"./ka.js": [
		"./node_modules/moment/locale/ka.js",
		"moment-locale-ka"
	],
	"./kk.js": [
		"./node_modules/moment/locale/kk.js",
		"moment-locale-kk"
	],
	"./km.js": [
		"./node_modules/moment/locale/km.js",
		"moment-locale-km"
	],
	"./kn.js": [
		"./node_modules/moment/locale/kn.js",
		"moment-locale-kn"
	],
	"./ko.js": [
		"./node_modules/moment/locale/ko.js",
		"moment-locale-ko"
	],
	"./ku.js": [
		"./node_modules/moment/locale/ku.js",
		"moment-locale-ku"
	],
	"./ky.js": [
		"./node_modules/moment/locale/ky.js",
		"moment-locale-ky"
	],
	"./lb.js": [
		"./node_modules/moment/locale/lb.js",
		"moment-locale-lb"
	],
	"./lo.js": [
		"./node_modules/moment/locale/lo.js",
		"moment-locale-lo"
	],
	"./lt.js": [
		"./node_modules/moment/locale/lt.js",
		"moment-locale-lt"
	],
	"./lv.js": [
		"./node_modules/moment/locale/lv.js",
		"moment-locale-lv"
	],
	"./me.js": [
		"./node_modules/moment/locale/me.js",
		"moment-locale-me"
	],
	"./mi.js": [
		"./node_modules/moment/locale/mi.js",
		"moment-locale-mi"
	],
	"./mk.js": [
		"./node_modules/moment/locale/mk.js",
		"moment-locale-mk"
	],
	"./ml.js": [
		"./node_modules/moment/locale/ml.js",
		"moment-locale-ml"
	],
	"./mn.js": [
		"./node_modules/moment/locale/mn.js",
		"moment-locale-mn"
	],
	"./mr.js": [
		"./node_modules/moment/locale/mr.js",
		"moment-locale-mr"
	],
	"./ms-my.js": [
		"./node_modules/moment/locale/ms-my.js",
		"moment-locale-ms-my"
	],
	"./ms.js": [
		"./node_modules/moment/locale/ms.js",
		"moment-locale-ms"
	],
	"./mt.js": [
		"./node_modules/moment/locale/mt.js",
		"moment-locale-mt"
	],
	"./my.js": [
		"./node_modules/moment/locale/my.js",
		"moment-locale-my"
	],
	"./nb.js": [
		"./node_modules/moment/locale/nb.js",
		"moment-locale-nb"
	],
	"./ne.js": [
		"./node_modules/moment/locale/ne.js",
		"moment-locale-ne"
	],
	"./nl-be.js": [
		"./node_modules/moment/locale/nl-be.js",
		"moment-locale-nl-be"
	],
	"./nl.js": [
		"./node_modules/moment/locale/nl.js",
		"moment-locale-nl"
	],
	"./nn.js": [
		"./node_modules/moment/locale/nn.js",
		"moment-locale-nn"
	],
	"./oc-lnc.js": [
		"./node_modules/moment/locale/oc-lnc.js",
		"moment-locale-oc-lnc"
	],
	"./pa-in.js": [
		"./node_modules/moment/locale/pa-in.js",
		"moment-locale-pa-in"
	],
	"./pl.js": [
		"./node_modules/moment/locale/pl.js",
		"moment-locale-pl"
	],
	"./pt-br.js": [
		"./node_modules/moment/locale/pt-br.js",
		"moment-locale-pt-br"
	],
	"./pt.js": [
		"./node_modules/moment/locale/pt.js",
		"moment-locale-pt"
	],
	"./ro.js": [
		"./node_modules/moment/locale/ro.js",
		"moment-locale-ro"
	],
	"./ru.js": [
		"./node_modules/moment/locale/ru.js",
		"moment-locale-ru"
	],
	"./sd.js": [
		"./node_modules/moment/locale/sd.js",
		"moment-locale-sd"
	],
	"./se.js": [
		"./node_modules/moment/locale/se.js",
		"moment-locale-se"
	],
	"./si.js": [
		"./node_modules/moment/locale/si.js",
		"moment-locale-si"
	],
	"./sk.js": [
		"./node_modules/moment/locale/sk.js",
		"moment-locale-sk"
	],
	"./sl.js": [
		"./node_modules/moment/locale/sl.js",
		"moment-locale-sl"
	],
	"./sq.js": [
		"./node_modules/moment/locale/sq.js",
		"moment-locale-sq"
	],
	"./sr-cyrl.js": [
		"./node_modules/moment/locale/sr-cyrl.js",
		"moment-locale-sr-cyrl"
	],
	"./sr.js": [
		"./node_modules/moment/locale/sr.js",
		"moment-locale-sr"
	],
	"./ss.js": [
		"./node_modules/moment/locale/ss.js",
		"moment-locale-ss"
	],
	"./sv.js": [
		"./node_modules/moment/locale/sv.js",
		"moment-locale-sv"
	],
	"./sw.js": [
		"./node_modules/moment/locale/sw.js",
		"moment-locale-sw"
	],
	"./ta.js": [
		"./node_modules/moment/locale/ta.js",
		"moment-locale-ta"
	],
	"./te.js": [
		"./node_modules/moment/locale/te.js",
		"moment-locale-te"
	],
	"./tet.js": [
		"./node_modules/moment/locale/tet.js",
		"moment-locale-tet"
	],
	"./tg.js": [
		"./node_modules/moment/locale/tg.js",
		"moment-locale-tg"
	],
	"./th.js": [
		"./node_modules/moment/locale/th.js",
		"moment-locale-th"
	],
	"./tk.js": [
		"./node_modules/moment/locale/tk.js",
		"moment-locale-tk"
	],
	"./tl-ph.js": [
		"./node_modules/moment/locale/tl-ph.js",
		"moment-locale-tl-ph"
	],
	"./tlh.js": [
		"./node_modules/moment/locale/tlh.js",
		"moment-locale-tlh"
	],
	"./tr.js": [
		"./node_modules/moment/locale/tr.js",
		"moment-locale-tr"
	],
	"./tzl.js": [
		"./node_modules/moment/locale/tzl.js",
		"moment-locale-tzl"
	],
	"./tzm-latn.js": [
		"./node_modules/moment/locale/tzm-latn.js",
		"moment-locale-tzm-latn"
	],
	"./tzm.js": [
		"./node_modules/moment/locale/tzm.js",
		"moment-locale-tzm"
	],
	"./ug-cn.js": [
		"./node_modules/moment/locale/ug-cn.js",
		"moment-locale-ug-cn"
	],
	"./uk.js": [
		"./node_modules/moment/locale/uk.js",
		"moment-locale-uk"
	],
	"./ur.js": [
		"./node_modules/moment/locale/ur.js",
		"moment-locale-ur"
	],
	"./uz-latn.js": [
		"./node_modules/moment/locale/uz-latn.js",
		"moment-locale-uz-latn"
	],
	"./uz.js": [
		"./node_modules/moment/locale/uz.js",
		"moment-locale-uz"
	],
	"./vi.js": [
		"./node_modules/moment/locale/vi.js",
		"moment-locale-vi"
	],
	"./x-pseudo.js": [
		"./node_modules/moment/locale/x-pseudo.js",
		"moment-locale-x-pseudo"
	],
	"./yo.js": [
		"./node_modules/moment/locale/yo.js",
		"moment-locale-yo"
	],
	"./zh-cn.js": [
		"./node_modules/moment/locale/zh-cn.js",
		"moment-locale-zh-cn"
	],
	"./zh-hk.js": [
		"./node_modules/moment/locale/zh-hk.js",
		"moment-locale-zh-hk"
	],
	"./zh-mo.js": [
		"./node_modules/moment/locale/zh-mo.js",
		"moment-locale-zh-mo"
	],
	"./zh-tw.js": [
		"./node_modules/moment/locale/zh-tw.js",
		"moment-locale-zh-tw"
	]
};
function webpackAsyncContext(req) {
	if(!__webpack_require__.o(map, req)) {
		return Promise.resolve().then(function() {
			var e = new Error("Cannot find module '" + req + "'");
			e.code = 'MODULE_NOT_FOUND';
			throw e;
		});
	}

	var ids = map[req], id = ids[0];
	return __webpack_require__.e(ids[1]).then(function() {
		return __webpack_require__.t(id, 7);
	});
}
webpackAsyncContext.keys = function() { return Object.keys(map); };
webpackAsyncContext.id = "./node_modules/moment/locale lazy recursive ^\\.\\/.*\\.js$";
module.exports = webpackAsyncContext;

/***/ })

}]);