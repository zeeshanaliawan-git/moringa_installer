// [AIV_SHORT]  Build version: 5.3.4  
 (window["webpackJsonp"] = window["webpackJsonp"] || []).push([["tunnel"],{

/***/ "./node_modules/es-cookie/src/es-cookie.js":
/*!*************************************************!*\
  !*** ./node_modules/es-cookie/src/es-cookie.js ***!
  \*************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var __assign = this && this.__assign || function () {
  __assign = Object.assign || function (t) {
    for (var s, i = 1, n = arguments.length; i < n; i++) {
      s = arguments[i];

      for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p)) t[p] = s[p];
    }

    return t;
  };

  return __assign.apply(this, arguments);
};

exports.__esModule = true;

function stringifyAttribute(name, value) {
  if (!value) {
    return '';
  }

  var stringified = '; ' + name;

  if (value === true) {
    return stringified; // boolean attributes shouldn't have a value
  }

  return stringified + '=' + value;
}

function stringifyAttributes(attributes) {
  if (typeof attributes.expires === 'number') {
    var expires = new Date();
    expires.setMilliseconds(expires.getMilliseconds() + attributes.expires * 864e+5);
    attributes.expires = expires;
  }

  return stringifyAttribute('Expires', attributes.expires ? attributes.expires.toUTCString() : '') + stringifyAttribute('Domain', attributes.domain) + stringifyAttribute('Path', attributes.path) + stringifyAttribute('Secure', attributes.secure) + stringifyAttribute('SameSite', attributes.sameSite);
}

function encode(name, value, attributes) {
  return encodeURIComponent(name).replace(/%(23|24|26|2B|5E|60|7C)/g, decodeURIComponent) // allowed special characters
  .replace(/\(/g, '%28').replace(/\)/g, '%29') // replace opening and closing parens
  + '=' + encodeURIComponent(value) // allowed special characters
  .replace(/%(23|24|26|2B|3A|3C|3E|3D|2F|3F|40|5B|5D|5E|60|7B|7D|7C)/g, decodeURIComponent) + stringifyAttributes(attributes);
}

exports.encode = encode;

function parse(cookieString) {
  var result = {};
  var cookies = cookieString ? cookieString.split('; ') : [];
  var rdecode = /(%[\dA-F]{2})+/gi;

  for (var i = 0; i < cookies.length; i++) {
    var parts = cookies[i].split('=');
    var cookie = parts.slice(1).join('=');

    if (cookie.charAt(0) === '"') {
      cookie = cookie.slice(1, -1);
    }

    try {
      var name_1 = parts[0].replace(rdecode, decodeURIComponent);
      result[name_1] = cookie.replace(rdecode, decodeURIComponent);
    } catch (e) {// ignore cookies with invalid name/value encoding
    }
  }

  return result;
}

exports.parse = parse;

function getAll() {
  return parse(document.cookie);
}

exports.getAll = getAll;

function get(name) {
  return getAll()[name];
}

exports.get = get;

function set(name, value, attributes) {
  document.cookie = encode(name, value, __assign({
    path: '/'
  }, attributes));
}

exports.set = set;

function remove(name, attributes) {
  set(name, '', __assign(__assign({}, attributes), {
    expires: -1
  }));
}

exports.remove = remove;

/***/ }),

/***/ "./src/modules/application/vendors/bridge-api/bridge-api.ts":
/*!******************************************************************!*\
  !*** ./src/modules/application/vendors/bridge-api/bridge-api.ts ***!
  \******************************************************************/
/*! exports provided: BridgeApi */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "BridgeApi", function() { return BridgeApi; });
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
/* harmony import */ var _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../../tunnel/tunnel-delivery/tunnel-delivery */ "./src/modules/tunnel/tunnel-delivery/tunnel-delivery.ts");
function _createForOfIteratorHelper(o) { if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (o = _unsupportedIterableToArray(o))) { var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var it, normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(n); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }



var BridgeApi = /*#__PURE__*/function () {
  function BridgeApi() {
    _classCallCheck(this, BridgeApi);
  }

  _createClass(BridgeApi, null, [{
    key: "getGeoLocalisationBoutiques",
    value: function () {
      var _getGeoLocalisationBoutiques = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee2(lat, lng, locationType) {
        var _this = this;

        return regeneratorRuntime.wrap(function _callee2$(_context2) {
          while (1) {
            switch (_context2.prev = _context2.next) {
              case 0:
                return _context2.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee(resolve, reject) {
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
                            endpoint = "locations/geosearch?" + "limit=" + _this.limit;
                            _context.next = 6;
                            return _this.postMethod(endpoint, filters);

                          case 6:
                            geoReponse = _context.sent;
                            completeResponse = [];
                            anyOf = [];
                            geoBoutiqueMap = new Map();
                            _iterator = _createForOfIteratorHelper(geoReponse);

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

                            searchEndpoint = "locations/search?" + "limit=" + _this.limit;
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
                            _iterator2 = _createForOfIteratorHelper(response);

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

                            filteredData = _this.filterResponse(completeResponse, locationType);

                            _this.debug.groupEnd();

                            _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_1__["TunnelDelivery"].searchType = _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_1__["searchTypeEnum"].geolocation;
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
      var _searchBoutiques = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee5(query, locationType) {
        var _this2 = this;

        return regeneratorRuntime.wrap(function _callee5$(_context5) {
          while (1) {
            switch (_context5.prev = _context5.next) {
              case 0:
                if (!(query && typeof query !== "string")) {
                  _context5.next = 2;
                  break;
                }

                return _context5.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref2 = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee3(resolve, reject) {
                    return regeneratorRuntime.wrap(function _callee3$(_context3) {
                      while (1) {
                        switch (_context3.prev = _context3.next) {
                          case 0:
                            reject("Query is not a string or undefined");

                          case 1:
                          case "end":
                            return _context3.stop();
                        }
                      }
                    }, _callee3);
                  }));

                  return function (_x8, _x9) {
                    return _ref2.apply(this, arguments);
                  };
                }()));

              case 2:
                if (!(query.length === 0)) {
                  _context5.next = 4;
                  break;
                }

                return _context5.abrupt("return", this.getAll(locationType));

              case 4:
                return _context5.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref3 = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee4(resolve, reject) {
                    var filters, endpoint, response, filteredData;
                    return regeneratorRuntime.wrap(function _callee4$(_context4) {
                      while (1) {
                        switch (_context4.prev = _context4.next) {
                          case 0:
                            _context4.prev = 0;
                            filters = {
                              status: "ACTIVE",
                              localisation: {
                                "city": query
                              }
                            };
                            endpoint = "locations/search?" + "limit=" + _this2.limit;
                            _context4.next = 5;
                            return _this2.postMethod(endpoint, filters);

                          case 5:
                            response = _context4.sent;
                            filteredData = _this2.filterResponse(response, locationType);
                            _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_1__["TunnelDelivery"].searchType = _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_1__["searchTypeEnum"].search;
                            resolve(filteredData);
                            _context4.next = 14;
                            break;

                          case 11:
                            _context4.prev = 11;
                            _context4.t0 = _context4["catch"](0);
                            reject(_context4.t0);

                          case 14:
                          case "end":
                            return _context4.stop();
                        }
                      }
                    }, _callee4, null, [[0, 11]]);
                  }));

                  return function (_x10, _x11) {
                    return _ref3.apply(this, arguments);
                  };
                }()));

              case 5:
              case "end":
                return _context5.stop();
            }
          }
        }, _callee5, this);
      }));

      function searchBoutiques(_x6, _x7) {
        return _searchBoutiques.apply(this, arguments);
      }

      return searchBoutiques;
    }()
  }, {
    key: "getAll",
    value: function () {
      var _getAll = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee7(locationType) {
        var _this3 = this;

        return regeneratorRuntime.wrap(function _callee7$(_context7) {
          while (1) {
            switch (_context7.prev = _context7.next) {
              case 0:
                return _context7.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref4 = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee6(resolve, reject) {
                    var filters, endpoint, response, filteredData;
                    return regeneratorRuntime.wrap(function _callee6$(_context6) {
                      while (1) {
                        switch (_context6.prev = _context6.next) {
                          case 0:
                            _context6.prev = 0;
                            filters = {
                              status: "ACTIVE"
                            };
                            endpoint = "locations/search?" + "limit=" + _this3.limit;
                            _context6.next = 5;
                            return _this3.postMethod(endpoint, filters);

                          case 5:
                            response = _context6.sent;
                            filteredData = _this3.filterResponse(response, locationType);
                            _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_1__["TunnelDelivery"].searchType = _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_1__["searchTypeEnum"].list;
                            resolve(filteredData);
                            _context6.next = 14;
                            break;

                          case 11:
                            _context6.prev = 11;
                            _context6.t0 = _context6["catch"](0);
                            reject(_context6.t0);

                          case 14:
                          case "end":
                            return _context6.stop();
                        }
                      }
                    }, _callee6, null, [[0, 11]]);
                  }));

                  return function (_x13, _x14) {
                    return _ref4.apply(this, arguments);
                  };
                }()));

              case 1:
              case "end":
                return _context7.stop();
            }
          }
        }, _callee7);
      }));

      function getAll(_x12) {
        return _getAll.apply(this, arguments);
      }

      return getAll;
    }()
  }, {
    key: "findOneBoutique",
    value: function () {
      var _findOneBoutique = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee8(id) {
        return regeneratorRuntime.wrap(function _callee8$(_context8) {
          while (1) {
            switch (_context8.prev = _context8.next) {
              case 0:
                return _context8.abrupt("return", new Promise(function (resolve, reject) {
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
                return _context8.stop();
            }
          }
        }, _callee8);
      }));

      function findOneBoutique(_x15) {
        return _findOneBoutique.apply(this, arguments);
      }

      return findOneBoutique;
    }()
  }, {
    key: "postMethod",
    value: function () {
      var _postMethod = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee9(url, filters) {
        var _this4 = this;

        return regeneratorRuntime.wrap(function _callee9$(_context9) {
          while (1) {
            switch (_context9.prev = _context9.next) {
              case 0:
                return _context9.abrupt("return", new Promise(function (resolve, reject) {
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
                return _context9.stop();
            }
          }
        }, _callee9);
      }));

      function postMethod(_x16, _x17) {
        return _postMethod.apply(this, arguments);
      }

      return postMethod;
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
}();

_defineProperty(BridgeApi, "debug", new _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__["Debug"](true));

_defineProperty(BridgeApi, "baseURL", void 0);

_defineProperty(BridgeApi, "geoLocalisationRadius", 100);

_defineProperty(BridgeApi, "limit", 200);

_defineProperty(BridgeApi, "headers", {
  "X-Api-Key": '',
  "Accept": 'application/vnd.bridge+json; version=1',
  "Content-Type": "application/json"
});

/***/ }),

/***/ "./src/modules/application/vendors/bridge-api/geoconding-api.ts":
/*!**********************************************************************!*\
  !*** ./src/modules/application/vendors/bridge-api/geoconding-api.ts ***!
  \**********************************************************************/
/*! exports provided: PositionType, GeocondingApi */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "PositionType", function() { return PositionType; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "GeocondingApi", function() { return GeocondingApi; });
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }


var PositionType;

(function (PositionType) {
  PositionType["fake"] = "fake";
  PositionType["geolocalisation"] = "geolocalisation";
  PositionType["geocoding"] = "geocoding";
})(PositionType || (PositionType = {}));

var GeocondingApi = /*#__PURE__*/function () {
  function GeocondingApi() {
    _classCallCheck(this, GeocondingApi);
  }

  _createClass(GeocondingApi, null, [{
    key: "getPosition",
    value: function () {
      var _getPosition = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee2(text) {
        var _this = this;

        return regeneratorRuntime.wrap(function _callee2$(_context2) {
          while (1) {
            switch (_context2.prev = _context2.next) {
              case 0:
                this.debug.group('GeocondingApi - getPosition()', text);
                return _context2.abrupt("return", new Promise( /*#__PURE__*/function () {
                  var _ref = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee(resolve, reject) {
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
      var _getMethod = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee3(query) {
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

_defineProperty(GeocondingApi, "debug", new _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__["Debug"](true));

_defineProperty(GeocondingApi, "apiKey", void 0);

_defineProperty(GeocondingApi, "baseUrl", void 0);

/***/ }),

/***/ "./src/modules/mapComponent/mapComponent.ts":
/*!**************************************************!*\
  !*** ./src/modules/mapComponent/mapComponent.ts ***!
  \**************************************************/
/*! exports provided: MapComponent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "MapComponent", function() { return MapComponent; });
/* harmony import */ var _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../tunnel/tunnel-delivery/tunnel-delivery */ "./src/modules/tunnel/tunnel-delivery/tunnel-delivery.ts");
/* harmony import */ var es_cookie__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! es-cookie */ "./node_modules/es-cookie/src/es-cookie.js");
/* harmony import */ var es_cookie__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(es_cookie__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
/* harmony import */ var _ts_library__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../../ts/library */ "./src/ts/library.ts");
function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function _createForOfIteratorHelper(o) { if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (o = _unsupportedIterableToArray(o))) { var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var it, normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(n); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }





var MapComponent = /*#__PURE__*/function () {
  function MapComponent($element) {
    _classCallCheck(this, MapComponent);

    _defineProperty(this, "debug", new _helper_debug_debug__WEBPACK_IMPORTED_MODULE_2__["Debug"](true));

    _defineProperty(this, "$mapContainer", void 0);

    _defineProperty(this, "map", void 0);

    _defineProperty(this, "$placeHolders", void 0);

    _defineProperty(this, "$costAlertModal", void 0);

    _defineProperty(this, "markers", []);

    _defineProperty(this, "markersListeners", []);

    this.$mapContainer = $element;
    this.$mapContainer.data('map-component', this);
  }

  _createClass(MapComponent, [{
    key: "initMap",
    value: function initMap() {
      this.map = new google.maps.Map(this.$mapContainer.get(0), {
        zoom: 12
      });

      if (typeof _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].currentPosition !== "undefined") {
        this.map.setCenter({
          lat: _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].currentPosition.lat,
          lng: _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].currentPosition.lng
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

      if (uniqueMarker && _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].selectedBoutique) {
        this.createOneMarker(_tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].selectedBoutique, uniqueMarker);
      } else {
        if (_tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].boutiques.length > 0) {
          var _iterator = _createForOfIteratorHelper(_tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].boutiques),
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
          icon: _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].mapsConfig.markersIconsUrl.normal,
          map: this.map,
          // @ts-ignore
          boutique: currentBoutique
        });
        marker.boutique = currentBoutique;

        if (_tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].selectedBoutique && _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].selectedBoutique.id === currentBoutique.id) {
          marker.setIcon(_tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].mapsConfig.markersIconsUrl.selected);
        }

        var $popinMarkerTemplate = $($('#popinMarkerTemplate').clone().html().trim());
        var title = _ts_library__WEBPACK_IMPORTED_MODULE_3__["Library"].OrangeLibrary.PopinMarker.get('displayTitle')(currentBoutique);
        var content = _ts_library__WEBPACK_IMPORTED_MODULE_3__["Library"].OrangeLibrary.PopinMarker.get('displayContent')(currentBoutique);
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
          trackPinShop();
          _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].boutiqueListVue.focusBoutique(this.boutique);

          if (this.infowindow) {
            this.infowindow.open(_this.map, this);
          }
        });
        var mouseoverListener = marker.addListener("mouseover", function (event) {
          _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].boutiqueListVue.highlightMarker(this.boutique, true);
        });
        var mouseleaveListener = marker.addListener("mouseout", function (event) {
          _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].boutiqueListVue.highlightMarker(this.boutique, false);
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
        boutique = _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].selectedBoutique;
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
                  es_cookie__WEBPACK_IMPORTED_MODULE_1__["set"]('TunnelDelivery.autoload', 'true');
                }

                _this2.removePlaceHolder();

                _context.prev = 4;
                _context.next = 7;
                return MapComponent.loadGoogleMapApi();

              case 7:
                _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].initMap();
                _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].selectPreselectedBoutique();
                _tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].centerOnFirstResult();
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
                        trackMapLoad();
                        MapComponent.googleMapApiLoading = false;
                        resolve(true);
                      }).fail(function () {
                        MapComponent.addMapError(_tunnel_tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].mapsConfig.errors.mapLoadingFailed, 'mapLoadingFailed');
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
      _ts_library__WEBPACK_IMPORTED_MODULE_3__["Library"].createEvent($mapComponents, 'error', detail);

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
      if (!_ts_library__WEBPACK_IMPORTED_MODULE_3__["Library"].OrangeLibrary.PopinMarker.has('displayTitle')) {
        _ts_library__WEBPACK_IMPORTED_MODULE_3__["Library"].OrangeLibrary.PopinMarker.set('displayTitle', MapComponent.popinMarkerDisplayTitle);
      }

      if (!_ts_library__WEBPACK_IMPORTED_MODULE_3__["Library"].OrangeLibrary.PopinMarker.has('displayContent')) {
        _ts_library__WEBPACK_IMPORTED_MODULE_3__["Library"].OrangeLibrary.PopinMarker.set('displayContent', MapComponent.popinMarkerDisplayContent);
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

_defineProperty(MapComponent, "autoLoadMap", void 0);

_defineProperty(MapComponent, "googleMapApiLoaded", false);

_defineProperty(MapComponent, "googleMapApiLoading", false);

_defineProperty(MapComponent, "apiKey", void 0);

_defineProperty(MapComponent, "baseUrl", void 0);

/***/ }),

/***/ "./src/modules/tunnel/tunnel-delivery/autocomplete.vue.ts":
/*!****************************************************************!*\
  !*** ./src/modules/tunnel/tunnel-delivery/autocomplete.vue.ts ***!
  \****************************************************************/
/*! exports provided: AutocompleteVue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "AutocompleteVue", function() { return AutocompleteVue; });
/* harmony import */ var _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./tunnel-delivery */ "./src/modules/tunnel/tunnel-delivery/tunnel-delivery.ts");
/* harmony import */ var _ts_tools__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../../ts/tools */ "./src/ts/tools.ts");
function _createForOfIteratorHelper(o) { if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (o = _unsupportedIterableToArray(o))) { var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var it, normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(n); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }



var AutocompleteVue = /*#__PURE__*/function () {
  function AutocompleteVue() {
    _classCallCheck(this, AutocompleteVue);
  }

  _createClass(AutocompleteVue, null, [{
    key: "init",
    value: function init() {
      return new Vue({
        name: 'ShopSearch-autocomplete',
        el: "#ShopSearch-autocomplete",
        data: {
          cities: [],
          query: ""
        },
        computed: {
          displayedCities: function displayedCities() {
            var array = [];
            var escapedQuery = Object(_ts_tools__WEBPACK_IMPORTED_MODULE_1__["escapeStringRegexp"])(this.query);
            var pattern = new RegExp(escapedQuery, 'gi');

            var _iterator = _createForOfIteratorHelper(this.cities),
                _step;

            try {
              for (_iterator.s(); !(_step = _iterator.n()).done;) {
                var city = _step.value;
                var capitalizeCity = _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].capitalizeString(city);
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
            $(".JS-ShopSearch-input").val(_tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].capitalizeString(city));
            $('.ShopSearch-autocompleteContainer').addClass('JS-autocompleteHidden');
            _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].searchBoutiques();
          }
        }
      });
    }
  }]);

  return AutocompleteVue;
}();

/***/ }),

/***/ "./src/modules/tunnel/tunnel-delivery/boutique-list.vue.ts":
/*!*****************************************************************!*\
  !*** ./src/modules/tunnel/tunnel-delivery/boutique-list.vue.ts ***!
  \*****************************************************************/
/*! exports provided: BoutiqueListVue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "BoutiqueListVue", function() { return BoutiqueListVue; });
/* harmony import */ var _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./tunnel-delivery */ "./src/modules/tunnel/tunnel-delivery/tunnel-delivery.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var BoutiqueListVue = /*#__PURE__*/function () {
  function BoutiqueListVue() {
    _classCallCheck(this, BoutiqueListVue);
  }

  _createClass(BoutiqueListVue, null, [{
    key: "init",
    value: function init() {
      return new Vue({
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
            return _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].searchType;
          },
          getLocationType: function getLocationType() {
            return _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].locationType;
          },
          selectBoutique: function selectBoutique(boutique) {
            _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].selectBoutique(boutique, false);
            _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].toggleShopSearchModal();
          },
          highlightMarker: function highlightMarker(boutique, highlight) {
            if (highlight) {
              this.hoveredBoutique = boutique;
              _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].highlightMarker(boutique, highlight);
            } else {
              this.hoveredBoutique = undefined;

              if (!(this.focusedBoutique && boutique.id === this.focusedBoutique.id)) {
                _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].highlightMarker(boutique, highlight);
              }
            }
          },
          focusBoutique: function focusBoutique(boutique) {
            this.focusedBoutique = boutique;
            _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].cleanMarkerHighlight();
            _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].highlightMarker(boutique, true);
            _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].mapsComponents.big.centerMap(boutique);
          },
          cleanFocusBoutique: function cleanFocusBoutique() {
            this.focusedBoutique = undefined;
            _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].cleanMarkerHighlight();
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
            return _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].capitalizeString(text);
          }
        }
      });
    }
  }]);

  return BoutiqueListVue;
}();

/***/ }),

/***/ "./src/modules/tunnel/tunnel-delivery/delivery-relay-section.vue.ts":
/*!**************************************************************************!*\
  !*** ./src/modules/tunnel/tunnel-delivery/delivery-relay-section.vue.ts ***!
  \**************************************************************************/
/*! exports provided: DeliveryRelaySectionVue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "DeliveryRelaySectionVue", function() { return DeliveryRelaySectionVue; });
/* harmony import */ var _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./tunnel-delivery */ "./src/modules/tunnel/tunnel-delivery/tunnel-delivery.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var DeliveryRelaySectionVue = /*#__PURE__*/function () {
  function DeliveryRelaySectionVue() {
    _classCallCheck(this, DeliveryRelaySectionVue);
  }

  _createClass(DeliveryRelaySectionVue, null, [{
    key: "init",
    value: function init() {
      return new Vue({
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
            return _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].capitalizeString(text);
          }
        }
      });
    }
  }]);

  return DeliveryRelaySectionVue;
}();

/***/ }),

/***/ "./src/modules/tunnel/tunnel-delivery/delivery-shop-section.vue.ts":
/*!*************************************************************************!*\
  !*** ./src/modules/tunnel/tunnel-delivery/delivery-shop-section.vue.ts ***!
  \*************************************************************************/
/*! exports provided: DeliveryShopSectionVue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "DeliveryShopSectionVue", function() { return DeliveryShopSectionVue; });
/* harmony import */ var _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./tunnel-delivery */ "./src/modules/tunnel/tunnel-delivery/tunnel-delivery.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }


var DeliveryShopSectionVue = /*#__PURE__*/function () {
  function DeliveryShopSectionVue() {
    _classCallCheck(this, DeliveryShopSectionVue);
  }

  _createClass(DeliveryShopSectionVue, null, [{
    key: "init",
    value: function init() {
      return new Vue({
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
            return _tunnel_delivery__WEBPACK_IMPORTED_MODULE_0__["TunnelDelivery"].capitalizeString(text);
          }
        }
      });
    }
  }]);

  return DeliveryShopSectionVue;
}();

/***/ }),

/***/ "./src/modules/tunnel/tunnel-delivery/tunnel-delivery.ts":
/*!***************************************************************!*\
  !*** ./src/modules/tunnel/tunnel-delivery/tunnel-delivery.ts ***!
  \***************************************************************/
/*! exports provided: locationTypeEnum, searchTypeEnum, NoResultsEnum, TunnelDelivery */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "locationTypeEnum", function() { return locationTypeEnum; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "searchTypeEnum", function() { return searchTypeEnum; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "NoResultsEnum", function() { return NoResultsEnum; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TunnelDelivery", function() { return TunnelDelivery; });
/* harmony import */ var _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../mapComponent/mapComponent */ "./src/modules/mapComponent/mapComponent.ts");
/* harmony import */ var _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../application/vendors/bridge-api/bridge-api */ "./src/modules/application/vendors/bridge-api/bridge-api.ts");
/* harmony import */ var _application_vendors_bridge_api_geoconding_api__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../../application/vendors/bridge-api/geoconding-api */ "./src/modules/application/vendors/bridge-api/geoconding-api.ts");
/* harmony import */ var _ui_calendar_picker_calendar_picker__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../../ui/calendar-picker/calendar-picker */ "./src/modules/ui/calendar-picker/calendar-picker.ts");
/* harmony import */ var _ui_calendar_picker_calendar_picker_vue__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ../../ui/calendar-picker/calendar-picker.vue */ "./src/modules/ui/calendar-picker/calendar-picker.vue.ts");
/* harmony import */ var _autocomplete_vue__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./autocomplete.vue */ "./src/modules/tunnel/tunnel-delivery/autocomplete.vue.ts");
/* harmony import */ var _boutique_list_vue__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ./boutique-list.vue */ "./src/modules/tunnel/tunnel-delivery/boutique-list.vue.ts");
/* harmony import */ var _delivery_shop_section_vue__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ./delivery-shop-section.vue */ "./src/modules/tunnel/tunnel-delivery/delivery-shop-section.vue.ts");
/* harmony import */ var _delivery_relay_section_vue__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! ./delivery-relay-section.vue */ "./src/modules/tunnel/tunnel-delivery/delivery-relay-section.vue.ts");
/* harmony import */ var es_cookie__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! es-cookie */ "./node_modules/es-cookie/src/es-cookie.js");
/* harmony import */ var es_cookie__WEBPACK_IMPORTED_MODULE_9___default = /*#__PURE__*/__webpack_require__.n(es_cookie__WEBPACK_IMPORTED_MODULE_9__);
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! ../../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
/* harmony import */ var _ts_library__WEBPACK_IMPORTED_MODULE_11__ = __webpack_require__(/*! ../../../ts/library */ "./src/ts/library.ts");
function _createForOfIteratorHelper(o) { if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (o = _unsupportedIterableToArray(o))) { var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var it, normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(n); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }













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
    _classCallCheck(this, TunnelDelivery);
  }

  _createClass(TunnelDelivery, null, [{
    key: "init",
    value: function init() {
      this.debug.log("TunnelDelivery - init()");
      this.$element = $('.TunnelDelivery'); // this.$element.find('#radio-shop-delivery').prop('checked', 'checked');

      this.$shopSearch = $('.ShopSearch');
      this.$showSearchCloseButton = this.$shopSearch.find(".JS-shop-search-close");
      this.$noBoutiqueElements.main = this.$element.find('.TunnelDelivery-noBoutiqueText');
      this.$noBoutiqueElements.search = this.$shopSearch.find('.TunnelDelivery-noBoutiqueText');
      this.calendarPicker = new _ui_calendar_picker_calendar_picker__WEBPACK_IMPORTED_MODULE_3__["CalendarPicker"]({
        templateId: "calendarPickerTemplate",
        name: 'rdv_date'
      });
      _ui_calendar_picker_calendar_picker_vue__WEBPACK_IMPORTED_MODULE_4__["CalendarPickerVue"].registerComponent(this.calendarPicker);
      this.createVueInstances();
      this.saveDeliveryAddressForm();
      this.events();
      this.mapsConfig = $('[data-mapsConfig]').data("mapsconfig");
      this.defineApiKeys();
      this.initAutoloadCookie();
      this.locationType = locationTypeEnum.boutique;
      this.showSection();
      this.load();
    }
  }, {
    key: "getLoadPartial",
    value: function getLoadPartial() {
      var _this2 = this;

      return new Promise( /*#__PURE__*/function () {
        var _ref = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee(resolve, reject) {
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
                  _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_0__["MapComponent"].addMapError(TunnelDelivery.mapsConfig.errors.bridgeApiLoadingFailed, 'bridgeApiLoadingFailed');

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

      _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_0__["MapComponent"].autoLoadMap = TunnelDelivery.mapsConfig.autoLoadMap;
      _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_1__["BridgeApi"].limit = TunnelDelivery.mapsConfig.limit;
      var $mapMain = $('.MapComponentMain');
      var $mapBig = $('.MapComponentBig');

      if (!$mapMain && !$mapBig) {
        _helper_debug_debug__WEBPACK_IMPORTED_MODULE_10__["Debug"].implementationError('.MapComponentMain or .MapComponentBig are not present in the page');
        return;
      }

      this.mapsComponents.main = new _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_0__["MapComponent"]($mapMain);
      this.mapsComponents.big = new _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_0__["MapComponent"]($mapBig);
      this.debug.log("New MapComponent created");
      var loadPartial = this.getLoadPartial();

      if (_mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_0__["MapComponent"].autoLoadMap) {
        this.debug.log("Autoloading...");
        Promise.all([loadPartial, _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_0__["MapComponent"].loadGoogleMapApi()]).then(function () {
          _this3.debug.log("Loaded");

          _this3.initMap();

          _this3.selectClosestBoutique();
        })["catch"](function (error) {
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
      this.deliveryShopSectionVue = _delivery_shop_section_vue__WEBPACK_IMPORTED_MODULE_7__["DeliveryShopSectionVue"].init();
      this.deliveryRelaySectionVue = _delivery_relay_section_vue__WEBPACK_IMPORTED_MODULE_8__["DeliveryRelaySectionVue"].init();
      this.autoCompleteVue = _autocomplete_vue__WEBPACK_IMPORTED_MODULE_5__["AutocompleteVue"].init();
      this.boutiqueListVue = _boutique_list_vue__WEBPACK_IMPORTED_MODULE_6__["BoutiqueListVue"].init();
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
      trackListPageLoad();
          _this4.toggleShopSearchModal();
        }
      });
      $tunnelDeliveryContainer.on('click', '.JS-change-shop, .JS-TunnelDelivery-selectShop', function (event) {
        event.preventDefault();
      trackListPageLoad();
        _this4.toggleShopSearchModal();
      });
      $tunnelDeliveryContainer.on("click", '.JS-deliveryShowToggleBtn', function () {
        TunnelDelivery.toggleSection($(this));
        trackMoreDetailsButton();
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
      $('.JS-geolocalisationSearchButton').on('click', /*#__PURE__*/_asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee3() {
          trackGeolocate();
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
                  var _ref3 = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee2(response) {
                    var _response;

                    return regeneratorRuntime.wrap(function _callee2$(_context2) {
                      while (1) {
                        switch (_context2.prev = _context2.next) {
                          case 0:
                            _context2.prev = 0;
                            $this.addClass('isDisabled');
                            _context2.next = 4;
                            return _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_1__["BridgeApi"].getGeoLocalisationBoutiques(_this.currentPosition.lat, _this.currentPosition.lng, _this.rawLocationType);

                          case 4:
                            _response = _context2.sent;
                            $this.removeClass('isDisabled');

                            _this.updateResults(_response);

                            _context2.next = 12;
                            break;

                          case 9:
                            _context2.prev = 9;
                            _context2.t0 = _context2["catch"](0);
                            _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_0__["MapComponent"].addMapError(TunnelDelivery.mapsConfig.errors.bridgeApiLoadingFailed, 'bridgeApiLoadingFailed', _context2.t0);

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
                }())["catch"](function (e) {
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
      _ts_library__WEBPACK_IMPORTED_MODULE_11__["Library"].createEvent(this.$element, 'error', {
        code: 'geolocalisationFailed',
        message: this.mapsConfig.errors.geolocalisationFailed,
        error: e
      });
      $('.JS-geolocalisationSearchButton').remove();
    }
  }, {
    key: "defineApiKeys",
    value: function defineApiKeys() {
      _application_vendors_bridge_api_geoconding_api__WEBPACK_IMPORTED_MODULE_2__["GeocondingApi"].apiKey = this.mapsConfig.api.googleGeocoding.key;
      _application_vendors_bridge_api_geoconding_api__WEBPACK_IMPORTED_MODULE_2__["GeocondingApi"].baseUrl = this.mapsConfig.api.googleGeocoding.baseUrl;
      _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_0__["MapComponent"].apiKey = this.mapsConfig.api.googleMap.key;
      _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_0__["MapComponent"].baseUrl = this.mapsConfig.api.googleMap.baseUrl;
      _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_1__["BridgeApi"].headers["X-Api-Key"] = this.mapsConfig.api.leadformanceBridge.key;
      _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_1__["BridgeApi"].baseURL = this.mapsConfig.api.leadformanceBridge.baseUrl;
    }
  }, {
    key: "initAutoloadCookie",
    value: function initAutoloadCookie() {
      if (es_cookie__WEBPACK_IMPORTED_MODULE_9__["get"]('TunnelDelivery.autoload')) {
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

      if (sectionNumber === "pick_up_in_store") {
        $deliveryMapSection.show();

        if (this.locationType !== locationTypeEnum.boutique) {
          this.locationType = locationTypeEnum.boutique;
          this.updateResultsLocationType();
        }
      } else if (sectionNumber === "pick_up_in_package_point") {
        $deliveryMapSection.show();

        if (this.locationType !== locationTypeEnum.relayPoint) {
          this.locationType = locationTypeEnum.relayPoint;
          this.updateResultsLocationType();
        }
      } else if (sectionNumber === "home_delivery") {
        $deliveryMapSection.hide();
      }
    }
  }, {
    key: "toggleSection",
    value: function toggleSection($trigger) {
      var target = $trigger.attr('data-target');
      var $target = $(target);

      if ($target.hasClass('open')) {
        $trigger.text('Voir plus');
        $target.removeClass('open');
        TweenMax.to($target, 0.5, {
          height: 0,
          ease: Power2.easeOut
        });
      } else {
        $trigger.text('Voir moins');
        $target.addClass('open');
        TweenMax.set($target, {
          height: 'auto'
        });
        TweenMax.from($target, 0.5, {
          height: 0,
          ease: Power2.easeOut
        });
      }
    }
  }, {
    key: "saveDeliveryAddressForm",
    value: function saveDeliveryAddressForm() {
      this.addressDeliveryForm = {
        name: ($('.DeliveryAddressSection-formName').val()).split("'").join("&#39;").split("\"").join("&#34;").split("<").join("&lt;").split(">").join("&gt;"),
        firstName: ($('.DeliveryAddressSection-formFirstName').val()).split("'").join("&#39;").split("\"").join("&#34;").split("<").join("&lt;").split(">").join("&gt;"),
        address: ($('.DeliveryAddressSection-formAddress').val()).split("'").join("&#39;").split("\"").join("&#34;").split("<").join("&lt;").split(">").join("&gt;"),
        addressComplement: ($('.DeliveryAddressSection-formAddressComplement').val()).split("'").join("&#39;").split("\"").join("&#34;").split("<").join("&lt;").split(">").join("&gt;"),
        postalCode: ($('.DeliveryAddressSection-formPostalCode').val()).split("'").join("&#39;").split("\"").join("&#34;").split("<").join("&lt;").split(">").join("&gt;"),
        city: ($('.DeliveryAddressSection-formCity').val()).split("'").join("&#39;").split("\"").join("&#34;").split("<").join("&lt;").split(">").join("&gt;")
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
		if(typeof _this5.mapsConfig.showMaps !== 'undefined' && _this5.mapsConfig.showMaps === false)  
		{
//			console.log(_this5.mapsConfig.showMaps)
//			console.log("Return as maps are off")
			return;
		}
      return new Promise( /*#__PURE__*/function () {
        var _ref4 = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee4(resolve, reject) {
          return regeneratorRuntime.wrap(function _callee4$(_context4) {
            while (1) {
              switch (_context4.prev = _context4.next) {
                case 0:
                  _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_1__["BridgeApi"].geoLocalisationRadius = _this5.mapsConfig.radius;

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
                        type: _application_vendors_bridge_api_geoconding_api__WEBPACK_IMPORTED_MODULE_2__["PositionType"].geolocalisation
                      };
                      resolvePosition();
                    }, function (error) {
                      _this5.debug.error(error);

                      resolvePosition();
                    });
                  });

                case 4:
                  _this5.debug.log("TunnelDelivery - setPositionAddress()", {
                    "currentPosition": _this5.currentPosition
                  });

                  if (!(_this5.currentPosition.type === _application_vendors_bridge_api_geoconding_api__WEBPACK_IMPORTED_MODULE_2__["PositionType"].fake && _this5.mapsConfig.geoCodingAddress)) {
                    _context4.next = 15;
                    break;
                  }

                  _context4.prev = 6;
                  _context4.next = 9;
                  return _application_vendors_bridge_api_geoconding_api__WEBPACK_IMPORTED_MODULE_2__["GeocondingApi"].getPosition(_this5.mapsConfig.geoCodingAddress);

                case 9:
                  _this5.currentPosition = _context4.sent;
                  _context4.next = 15;
                  break;

                case 12:
                  _context4.prev = 12;
                  _context4.t0 = _context4["catch"](6);
                  reject(_context4.t0);

                case 15:
                  if (_this5.currentPosition.type === _application_vendors_bridge_api_geoconding_api__WEBPACK_IMPORTED_MODULE_2__["PositionType"].fake) {
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
      var _loadAroundboutique = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee5() {
        var hasRealPosition;
        return regeneratorRuntime.wrap(function _callee5$(_context5) {
          while (1) {
            switch (_context5.prev = _context5.next) {
              case 0:
                hasRealPosition = this.currentPosition && this.currentPosition.type !== _application_vendors_bridge_api_geoconding_api__WEBPACK_IMPORTED_MODULE_2__["PositionType"].fake;

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
      var _initAroundBoutiques = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee6() {
        var _this6 = this;

        return regeneratorRuntime.wrap(function _callee6$(_context6) {
          while (1) {
            switch (_context6.prev = _context6.next) {
              case 0:
                return _context6.abrupt("return", new Promise(function (resolve, reject) {
                  _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_1__["BridgeApi"].getGeoLocalisationBoutiques(_this6.currentPosition.lat, _this6.currentPosition.lng, _this6.rawLocationType).then(function (data) {
                    if (data.length > 0) {
                      TunnelDelivery.hideNoBoutique(NoResultsEnum.main);
                      TunnelDelivery.hydrateBoutique(data);
                      resolve(_this6.boutiques);
                    } else {
                      _this6.debug.error('No boutique found');

                      TunnelDelivery.showNoBoutique();
                      resolve(_this6.boutiques);
                    }
                  })["catch"](function (e) {
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

      var _iterator = _createForOfIteratorHelper(data),
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
        trackNoShopLocated();
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
      var _initMap = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee7() {
        return regeneratorRuntime.wrap(function _callee7$(_context7) {
          while (1) {
            switch (_context7.prev = _context7.next) {
              case 0:
                this.mapsComponents.main.initMap();
                this.mapsComponents.big.initMap();
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

        var _iterator2 = _createForOfIteratorHelper(_this.boutiques),
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

      var _iterator3 = _createForOfIteratorHelper(this.mapsComponents.big.markers),
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
      trackSelectShop();
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
      var _updateAutocomplete = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee8(query) {
        var response, citiesArray, _iterator4, _step4, boutique, city;

        return regeneratorRuntime.wrap(function _callee8$(_context8) {
          while (1) {
            switch (_context8.prev = _context8.next) {
              case 0:
                _context8.prev = 0;
                _context8.next = 3;
                return _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_1__["BridgeApi"].searchBoutiques(query, this.rawLocationType);

              case 3:
                response = _context8.sent;
                citiesArray = [];
                _iterator4 = _createForOfIteratorHelper(response);

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
      var _searchBoutiques = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee9() {
        var $input, query, response;
        return regeneratorRuntime.wrap(function _callee9$(_context9) {
          while (1) {
            switch (_context9.prev = _context9.next) {
              case 0:
                _context9.prev = 0;
                $input = $(".JS-ShopSearch-input");
                query = "" + $input.val().toString().trim();
                _context9.next = 5;
                return _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_1__["BridgeApi"].searchBoutiques(query, this.rawLocationType);

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
      var _updateResults = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee10(response) {
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
      var _showAllBoutique = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee11() {
        var response;
        return regeneratorRuntime.wrap(function _callee11$(_context11) {
          while (1) {
            switch (_context11.prev = _context11.next) {
              case 0:
                this.debug.log("TunnelDelivery - showAllBoutique()");
                _context11.next = 3;
                return _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_1__["BridgeApi"].getAll(this.rawLocationType);

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
      var _updateResultsLocationType = _asyncToGenerator( /*#__PURE__*/regeneratorRuntime.mark(function _callee12() {
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
          currentPosition.type = _application_vendors_bridge_api_geoconding_api__WEBPACK_IMPORTED_MODULE_2__["PositionType"].fake;
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

_defineProperty(TunnelDelivery, "debug", new _helper_debug_debug__WEBPACK_IMPORTED_MODULE_10__["Debug"](true));

_defineProperty(TunnelDelivery, "isBodyScrollBlocked", false);

_defineProperty(TunnelDelivery, "$shopSearch", void 0);

_defineProperty(TunnelDelivery, "$showSearchCloseButton", void 0);

_defineProperty(TunnelDelivery, "addressDeliveryForm", {
  name: "",
  firstName: "",
  address: "",
  addressComplement: "",
  postalCode: "",
  city: ""
});

_defineProperty(TunnelDelivery, "mapsComponents", {
  main: undefined,
  big: undefined
});

_defineProperty(TunnelDelivery, "mapsConfig", void 0);

_defineProperty(TunnelDelivery, "$element", void 0);

_defineProperty(TunnelDelivery, "$noBoutiqueElements", {
  main: undefined,
  search: undefined
});

_defineProperty(TunnelDelivery, "boutiqueListVue", void 0);

_defineProperty(TunnelDelivery, "deliveryShopSectionVue", void 0);

_defineProperty(TunnelDelivery, "deliveryRelaySectionVue", void 0);

_defineProperty(TunnelDelivery, "autoCompleteVue", void 0);

_defineProperty(TunnelDelivery, "_currentPosition", void 0);

_defineProperty(TunnelDelivery, "boutiques", []);

_defineProperty(TunnelDelivery, "selectedBoutique", void 0);

_defineProperty(TunnelDelivery, "closestBoutique", void 0);

_defineProperty(TunnelDelivery, "rawLocationType", []);

_defineProperty(TunnelDelivery, "searchTimeout", false);

_defineProperty(TunnelDelivery, "searchType", void 0);

_defineProperty(TunnelDelivery, "calendarPicker", void 0);

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

/***/ }),

/***/ "./src/modules/tunnel/tunnel-form.ts":
/*!*******************************************!*\
  !*** ./src/modules/tunnel/tunnel-form.ts ***!
  \*******************************************/
/*! exports provided: TunnelForm */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TunnelForm", function() { return TunnelForm; });
/* harmony import */ var _helper_form_validator_field__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../helper/form-validator/field */ "./src/modules/helper/form-validator/field.ts");
/* harmony import */ var _tunnel_exit_tunnel_exit__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./tunnel-exit/tunnel-exit */ "./src/modules/tunnel/tunnel-exit/tunnel-exit.ts");
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
          new _helper_form_validator_field__WEBPACK_IMPORTED_MODULE_0__["Field"](value);
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
      _tunnel_exit_tunnel_exit__WEBPACK_IMPORTED_MODULE_1__["TunnelExit"].clearUnloadEvent(); // TunnelForm.$element.closest('form').submit();

      updateCheckout();
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

/***/ }),

/***/ "./src/modules/tunnel/tunnel.module.ts":
/*!*********************************************!*\
  !*** ./src/modules/tunnel/tunnel.module.ts ***!
  \*********************************************/
/*! exports provided: TunnelForm, TunnelExit, TunnelDelivery, MapComponent, BridgeApi */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _tunnel_form__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./tunnel-form */ "./src/modules/tunnel/tunnel-form.ts");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "TunnelForm", function() { return _tunnel_form__WEBPACK_IMPORTED_MODULE_0__["TunnelForm"]; });

/* harmony import */ var _tunnel_exit_tunnel_exit__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./tunnel-exit/tunnel-exit */ "./src/modules/tunnel/tunnel-exit/tunnel-exit.ts");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "TunnelExit", function() { return _tunnel_exit_tunnel_exit__WEBPACK_IMPORTED_MODULE_1__["TunnelExit"]; });

/* harmony import */ var _tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./tunnel-delivery/tunnel-delivery */ "./src/modules/tunnel/tunnel-delivery/tunnel-delivery.ts");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "TunnelDelivery", function() { return _tunnel_delivery_tunnel_delivery__WEBPACK_IMPORTED_MODULE_2__["TunnelDelivery"]; });

/* harmony import */ var _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../mapComponent/mapComponent */ "./src/modules/mapComponent/mapComponent.ts");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "MapComponent", function() { return _mapComponent_mapComponent__WEBPACK_IMPORTED_MODULE_3__["MapComponent"]; });

/* harmony import */ var _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ../application/vendors/bridge-api/bridge-api */ "./src/modules/application/vendors/bridge-api/bridge-api.ts");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "BridgeApi", function() { return _application_vendors_bridge_api_bridge_api__WEBPACK_IMPORTED_MODULE_4__["BridgeApi"]; });








/***/ }),

/***/ "./src/modules/ui/calendar-picker/calendar-picker.ts":
/*!***********************************************************!*\
  !*** ./src/modules/ui/calendar-picker/calendar-picker.ts ***!
  \***********************************************************/
/*! exports provided: CalendarPicker */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "CalendarPicker", function() { return CalendarPicker; });
/* harmony import */ var _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../helper/debug/debug */ "./src/modules/helper/debug/debug.ts");
function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }

function _defineProperty(obj, key, value) { if (key in obj) { Object.defineProperty(obj, key, { value: value, enumerable: true, configurable: true, writable: true }); } else { obj[key] = value; } return obj; }


var CalendarPicker = /*#__PURE__*/function () {
  function CalendarPicker(config) {
    var _config$isDark;

    _classCallCheck(this, CalendarPicker);

    _defineProperty(this, "element", void 0);

    _defineProperty(this, "template", void 0);

    _defineProperty(this, "config", void 0);

    _defineProperty(this, "isDark", false);

    _defineProperty(this, "name", 'date');

    _defineProperty(this, "vue", void 0);

    _defineProperty(this, "isoDayNameMapping", {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday'
    });

    if (_helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__["Debug"].isNotLoadedVue() || _helper_debug_debug__WEBPACK_IMPORTED_MODULE_0__["Debug"].isNotLoadedMoment()) {
      return;
    }

    this.config = config;
    this.template = document.getElementById(config.templateId);
    this.name = config.name;
    this.isDark = (_config$isDark = config.isDark) !== null && _config$isDark !== void 0 ? _config$isDark : false;
  }

  _createClass(CalendarPicker, [{
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
        days.push(moment().weekday(i).format('dd')[0].toUpperCase());
      }

      return days;
    }
  }]);

  return CalendarPicker;
}();

/***/ }),

/***/ "./src/modules/ui/calendar-picker/calendar-picker.vue.ts":
/*!***************************************************************!*\
  !*** ./src/modules/ui/calendar-picker/calendar-picker.vue.ts ***!
  \***************************************************************/
/*! exports provided: CalendarPickerVue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "CalendarPickerVue", function() { return CalendarPickerVue; });
/* harmony import */ var _calendar_picker__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./calendar-picker */ "./src/modules/ui/calendar-picker/calendar-picker.ts");
/* harmony import */ var _helper_mobile_detect_mobile_detect__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../helper/mobile-detect/mobile-detect */ "./src/modules/helper/mobile-detect/mobile-detect.ts");
function _createForOfIteratorHelper(o) { if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) { if (Array.isArray(o) || (o = _unsupportedIterableToArray(o))) { var i = 0; var F = function F() {}; return { s: F, n: function n() { if (i >= o.length) return { done: true }; return { done: false, value: o[i++] }; }, e: function e(_e) { throw _e; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var it, normalCompletion = true, didErr = false, err; return { s: function s() { it = o[Symbol.iterator](); }, n: function n() { var step = it.next(); normalCompletion = step.done; return step; }, e: function e(_e2) { didErr = true; err = _e2; }, f: function f() { try { if (!normalCompletion && it["return"] != null) it["return"](); } finally { if (didErr) throw err; } } }; }

function _unsupportedIterableToArray(o, minLen) { if (!o) return; if (typeof o === "string") return _arrayLikeToArray(o, minLen); var n = Object.prototype.toString.call(o).slice(8, -1); if (n === "Object" && o.constructor) n = o.constructor.name; if (n === "Map" || n === "Set") return Array.from(n); if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen); }

function _arrayLikeToArray(arr, len) { if (len == null || len > arr.length) len = arr.length; for (var i = 0, arr2 = new Array(len); i < len; i++) { arr2[i] = arr[i]; } return arr2; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } }

function _createClass(Constructor, protoProps, staticProps) { if (protoProps) _defineProperties(Constructor.prototype, protoProps); if (staticProps) _defineProperties(Constructor, staticProps); return Constructor; }



var CalendarPickerVue = /*#__PURE__*/function () {
  function CalendarPickerVue() {
    _classCallCheck(this, CalendarPickerVue);
  }

  _createClass(CalendarPickerVue, null, [{
    key: "registerComponent",
    value: function registerComponent(_this) {
      Vue.component('calendar-picker', {
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
            days: _calendar_picker__WEBPACK_IMPORTED_MODULE_0__["CalendarPicker"].getDaysOfTheWeek(),
            today: moment().startOf('day'),
            dateContext: moment().add(1,'days').startOf('day'),
            selectedMoment: null,
            inputMoment: null,
            dateIsValid: true,
            hourIsValid: true,
            name: _this.name,
            limit: {
              minDate: moment().add(1,'days').startOf('day').toDate(),
              maxDate: false
            },
            rendezVous: undefined
          };
        },
        computed: {
          hasMeridiem: function hasMeridiem() {
            return moment.localeData().longDateFormat('LT').indexOf('A') > -1;
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
              var tmpMoment = moment(newValue, ['LT']);

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

              return date.format('YYYY-MM-DD');
            },
            set: function set(newValue) {
              var tmpMoment = moment(newValue, ['LL', 'L']);

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

            return date.format(moment.HTML5_FMT.DATETIME_LOCAL);
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
            var firstDay = this.dateContext.startOf('month');
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
            return this.dateContext.subtract(1, 'month').endOf('month').clone();
          },
          nextMonth: function nextMonth() {
            return this.dateContext.add(1, 'month').startOf('month').clone();
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

            var thisMoment = moment(this.getDateFromDay(day));

            if (this.selectedMoment) {
              this.selectedMoment = this.mergeDate(this.selectedMoment, thisMoment);
            } else {
              this.selectedMoment = moment(this.getDateFromDay(day)).startOf('days');
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
            return moment().year(this.dateContext.year()).month(this.dateContext.month()).date(day);
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

            var _iterator = _createForOfIteratorHelper(periods),
                _step;

            try {
              for (_iterator.s(); !(_step = _iterator.n()).done;) {
                var period = _step.value;
                var openTime = this.mergeDate(moment("1987-01-17 " + period.openTime, 'YYYY-MM-DD HH:mm'), momentDate);
                var closeTime = this.mergeDate(moment("1987-01-17 " + period.closeTime, 'YYYY-MM-DD HH:mm'), momentDate);

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
            return _helper_mobile_detect_mobile_detect__WEBPACK_IMPORTED_MODULE_1__["MobileDetectHelper"].md.isMobile();
          }
        },
        filters: {}
      });
    }
  }]);

  return CalendarPickerVue;
}();

/***/ }),

/***/ "./src/ts/tools.ts":
/*!*************************!*\
  !*** ./src/ts/tools.ts ***!
  \*************************/
/*! exports provided: mod, escapeStringRegexp */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "mod", function() { return mod; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "escapeStringRegexp", function() { return escapeStringRegexp; });
function mod(number, modulo) {
  return (number % modulo + modulo) % modulo;
}
function escapeStringRegexp(string) {
  // Escape characters with special meaning either inside or outside character sets.
  // Use a simple backslash escape when it’s always valid, and a \unnnn escape when the simpler form would be disallowed by Unicode patterns’ stricter grammar.
  return string.replace(/[|\\{}()[\]^$+*?.]/g, '\\$&').replace(/-/g, "\\u002d");
}

/***/ })

}]);
//# sourceMappingURL=tunnel-bundle.js.map 