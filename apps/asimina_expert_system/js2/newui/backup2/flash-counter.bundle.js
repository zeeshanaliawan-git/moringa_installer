(window["webpackJsonp"] = window["webpackJsonp"] || []).push([["flash-counter"],{

/***/ "./src/modules/ui/counter/counter.ts":
/*!*******************************************!*\
  !*** ./src/modules/ui/counter/counter.ts ***!
  \*******************************************/
/*! exports provided: Counter */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Counter", function() { return Counter; });
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }

var Counter =
/*#__PURE__*/
function () {
  function Counter(flashCounter) {
    _classCallCheck(this, Counter);

    _defineProperty(this, "flashCounter", void 0);

    _defineProperty(this, "$flashCounter", void 0);

    _defineProperty(this, "$dayElement", void 0);

    _defineProperty(this, "$hoursElement", void 0);

    _defineProperty(this, "$minutesElement", void 0);

    _defineProperty(this, "$secondsElement", void 0);

    this.flashCounter = flashCounter;
    this.$flashCounter = $(this.flashCounter);
    this.$dayElement = this.$flashCounter.find(".Counter-days");
    this.$hoursElement = this.$flashCounter.find(".Counter-hours");
    this.$minutesElement = this.$flashCounter.find(".Counter-minutes");
    this.$secondsElement = this.$flashCounter.find(".Counter-seconds");
    this.runCounter();
  }

  _createClass(Counter, [{
    key: "runCounter",
    value: function runCounter() {
      var _this = this;

      var timestamp = parseInt(this.$flashCounter.attr("data-timestamp"));
      setInterval(function () {
        // Initialisation du compteur
        var counterText = {
          days: "",
          hours: "",
          minutes: "",
          seconds: ""
        };
        var counterValue = {
          days: 0,
          hours: 0,
          minutes: 0,
          seconds: 0
        };
        var now = new Date().getTime();
        now = now / 1000; // le timestamp est exprimé en secondes ou millisecondes...

        var delta = Math.abs(timestamp - now); // Calcul des valeurs

        counterValue.days = Math.floor(delta / 86400);
        delta -= counterValue.days * 86400;
        counterValue.hours = Math.floor(delta / 3600) % 24;
        delta -= counterValue.hours * 3600;
        counterValue.minutes = Math.floor(delta / 60) % 60;
        delta -= counterValue.minutes * 60;
        counterValue.seconds = Math.floor(delta % 60); // Mise en forme des valeurs

        counterText.days = counterValue.days.toString();
        counterText.hours = counterValue.hours.toString();
        counterText.minutes = counterValue.minutes.toString();
        counterText.seconds = counterValue.seconds.toString();

        if (counterValue.days < 10) {
          counterText.days = "0" + counterValue.days;
        }

        if (counterValue.hours < 10) {
          counterText.hours = "0" + counterValue.hours;
        }

        if (counterValue.minutes < 10) {
          counterText.minutes = "0" + counterValue.minutes;
        }

        if (counterValue.seconds < 10) {
          counterText.seconds = "0" + counterValue.seconds;
        } // Mise à jour du DOM


        _this.$dayElement.text(counterText.days);

        _this.$hoursElement.text(counterText.hours);

        _this.$minutesElement.text(counterText.minutes);

        _this.$secondsElement.text(counterText.seconds);
      }, 1000);
    }
  }]);

  return Counter;
}();

/***/ })

}]);
//# sourceMappingURL=flash-counter.bundle.js.map