// Generated by CoffeeScript 1.4.0
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.Viewporter = (function() {

    function Viewporter(element_id, params) {
      var prop, val, _ref,
        _this = this;
      this.element_id = element_id;
      this.params = params != null ? params : {};
      this.setupViewport = __bind(this.setupViewport, this);

      this.resetViewportIfChanged = __bind(this.resetViewportIfChanged, this);

      this.orientationChanged = __bind(this.orientationChanged, this);

      this.monitorSize = __bind(this.monitorSize, this);

      this.element = null;
      if ((this.element_id != null) && (document.getElementById(this.element_id) != null)) {
        this.element = document.getElementById(this.element_id);
      }
      this.loggingLevel = 0;
      this.isAndroid = navigator.userAgent.match(/Android/i);
      this.isIphone = navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i);
      this.isChrome = navigator.userAgent.match(/Chrome/i) || navigator.userAgent.match(/CriOS/i);
      this.pixelRatio = 1;
      if (window.devicePixelRatio) {
        this.pixelRatio = window.devicePixelRatio;
      }
      this.previousScreenSize = {
        width: 0,
        height: 0
      };
      this.viewportChanged = false;
      this.viewportWidth = 320;
      this.viewportHeight = 480;
      this.fullWidthLandscape = true;
      this.fullHeightLandscape = true;
      this.fullWidthPortrait = true;
      this.fullHeightPortrait = true;
      if (window.innerWidth < window.innerHeight) {
        this.windowInnerWidth = window.innerWidth / this.pixelRatio;
        this.windowInnerHeight = window.innerHeight / this.pixelRatio;
      } else {
        this.windowInnerWidth = window.innerHeight / this.pixelRatio;
        this.windowInnerHeight = window.innerWidth / this.pixelRatio;
      }
      this.resolutionsSeen = [];
      window.addEventListener("ondeviceorientation", this.orientationChanged);
      window.addEventListener("orientationchange", this.orientationChanged);
      window.addEventListener("resize", function(event) {
        _this.trace("resize " + window.innerHeight, 2);
        if (_this.isIphone || _this.isAndroid) {
          return _this.resetViewportIfChanged();
        } else {
          _this.calculateWindowSize();
          return _this.setupViewport();
        }
      });
      this.interval = 300;
      if ((this.params != null) && typeof this.params === "object") {
        _ref = this.params;
        for (prop in _ref) {
          val = _ref[prop];
          this[prop] = val;
        }
      }
      this.hideAddressBar();
      if (this.isIphone) {
        setTimeout(function() {
          return _this.monitorSize();
        }, this.interval);
      }
      setTimeout(function() {
        _this.calculateWindowSize();
        _this.setupViewport();
        setTimeout(_this.hideAddressBar, 1);
        return addEventListener("load", function() {
          setTimeout(this.hideAddressBar, 0);
          return setTimeout(this.hideAddressBar, 10);
        });
      }, 10);
      this.trace(navigator.userAgent, 2);
    }

    Viewporter.prototype.monitorSize = function(event) {
      var _this = this;
      this.resetViewportIfChanged();
      return setTimeout(function() {
        return _this.monitorSize();
      }, this.interval);
    };

    Viewporter.prototype.orientationChanged = function() {
      var _ref;
      if (((_ref = this.element) != null ? _ref.style : void 0) != null) {
        this.element.style.display = "none";
      }
      this.trace("orientationchange", 2);
      this.calculateWindowSize();
      return this.setupViewport();
    };

    Viewporter.prototype.resetViewportIfChanged = function() {
      var _this = this;
      if (this.isLandscape) {
        this.calculateWindowSize();
        if (this.actualScreenWidth !== this.previousScreenSize.width || this.actualScreenHeight !== this.previousScreenSize.height) {
          this.setupViewport();
          this.previousScreenSize.width = this.actualScreenWidth;
          this.previousScreenSize.height = this.actualScreenHeight;
          return setTimeout(function() {
            return _this.setupViewport();
          }, 300);
        }
      }
    };

    Viewporter.prototype.calculateWindowSize = function() {
      var addressBarHeight, found, i, lowerHeight, navBarHeight, sh, statusBarHeight, sw, upperHeight, upperHeightWithBar, _i, _ref, _ref1;
      this.viewportWidth = 320;
      this.viewportHeight = 480;
      this.viewportScale = 1;
      this.isLandscape = true;
      if (typeof window.orientation !== "undefined") {
        this.isLandscape = Math.abs(window.orientation) === 90 ? true : false;
      } else {
        this.isLandscape = window.innerWidth > window.innerHeight;
      }
      this.actualScreenWidth = this.orientedWidth();
      this.actualScreenHeight = this.orientedHeight();
      window.innerHeight;
      sw = screen.width / this.pixelRatio;
      sh = screen.height / this.pixelRatio;
      if (sw > sh) {
        sw = sh;
        sh = screen.width / this.pixelRatio;
      }
      statusBarHeight = 10;
      navBarHeight = 44;
      addressBarHeight = 60;
      if (this.isIphone) {
        lowerHeight = this.isChrome ? 256 : 268;
        upperHeight = 320;
        upperHeightWithBar = 260;
        if (this.isLandscape) {
          if (this.actualScreenHeight <= lowerHeight && this.actualScreenHeight !== upperHeightWithBar) {
            this.actualScreenHeight = lowerHeight;
          }
        } else {
          if (this.actualScreenHeight === 444) {
            this.actualScreenHeight += addressBarHeight;
          }
        }
        if (this.actualScreenHeight >= upperHeightWithBar && this.actualScreenHeight !== lowerHeight && this.actualScreenHeight < upperHeight) {
          this.actualScreenHeight = upperHeight;
        }
      }
      found = false;
      for (i = _i = 0, _ref = this.resolutionsSeen.length; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (i < this.resolutionsSeen.length) {
          if (((_ref1 = this.resolutionsSeen[i]) != null ? _ref1.width : void 0) === this.actualScreenWidth && this.resolutionsSeen[i].height === this.actualScreenHeight) {
            found = true;
          }
        }
      }
      if (!this.isLandscape) {
        if (this.isIphone) {
          this.actualScreenHeight += 0;
        }
      }
      if (!found) {
        this.resolutionsSeen.push({
          width: this.actualScreenWidth,
          height: this.actualScreenHeight
        });
      }
      if (typeof window.orientation === "undefined" && !this.isIphone && !this.isAndroid) {
        this.actualScreenWidth = window.innerWidth;
        this.actualScreenHeight = window.innerHeight;
      }
      this.viewportChanged = false;
      if (this.viewportWidth !== this.actualScreenWidth || this.viewportHeight !== this.actualScreenHeight) {
        this.viewportChanged = true;
      }
      this.viewportWidth = this.actualScreenWidth;
      this.viewportHeight = this.actualScreenHeight;
      return this.viewportScale = this.actualScreenWidth / this.viewportWidth;
    };

    Viewporter.prototype.setupViewport = function() {
      var body, event, h, s, setHeight, setWidth, viewport, viewportContent, viewportProperties, w, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8,
        _this = this;
      viewport = document.querySelector("meta[name=viewport]");
      this.trace("" + screen.width + "x" + screen.height + " / " + this.viewportWidth + "x" + this.viewportHeight, 2);
      h = this.viewportHeight + Math.random() * .1;
      w = this.viewportWidth;
      s = this.viewportScale;
      if (this.isAndroid && this.isChrome) {
        h = this.viewportHeight + 0;
        w = this.viewportWidth + 0;
      }
      viewportProperties = [];
      viewportProperties.push("initial-scale=" + s);
      viewportProperties.push("minimum-scale=" + s);
      viewportProperties.push("maximum-scale=" + s);
      viewportProperties.push("user-scalable=no");
      body = document.getElementsByTagName("body");
      setWidth = (this.isLandscape && this.fullWidthLandscape) || (!this.isLandscape && this.fullWidthPortrait);
      setHeight = (this.isLandscape && this.fullHeightLandscape) || (!this.isLandscape && this.fullHeightPortrait);
      if (setWidth) {
        viewportProperties.push("width=" + w);
        if (((_ref = this.element) != null ? _ref.style : void 0) != null) {
          this.element.style.width = this.viewportWidth + "px";
          this.element.style["overflow-x"] = "hidden";
        }
        if ((body != null ? (_ref1 = body[0]) != null ? _ref1.style : void 0 : void 0) != null) {
          body[0].style.width = this.viewportWidth + "px";
        }
      } else {
        if (((_ref2 = this.element) != null ? _ref2.style : void 0) != null) {
          this.element.style.width = "inherit";
          this.element.style["overflow-x"] = "auto";
        }
        if ((body != null ? (_ref3 = body[0]) != null ? _ref3.style : void 0 : void 0) != null) {
          body[0].style.width = "";
        }
      }
      if (setHeight) {
        viewportProperties.push("height=" + h);
        if (((_ref4 = this.element) != null ? _ref4.style : void 0) != null) {
          this.element.style.height = this.viewportHeight + "px";
          this.element.style["overflow-y"] = "hidden";
        }
        if ((body != null ? (_ref5 = body[0]) != null ? _ref5.style : void 0 : void 0) != null) {
          body[0].style.height = this.viewportHeight + "px";
        }
      } else {
        if (((_ref6 = this.element) != null ? _ref6.style : void 0) != null) {
          this.element.style.height = "inherit";
          this.element.style["overflow-y"] = "auto";
        }
        if ((body != null ? (_ref7 = body[0]) != null ? _ref7.style : void 0 : void 0) != null) {
          body[0].style.height = "";
        }
      }
      viewportContent = viewportProperties.join(", ");
      if (((_ref8 = this.element) != null ? _ref8.style : void 0) != null) {
        setTimeout(function() {
          return _this.element.style.display = "block";
        }, 100);
      }
      this.trace(viewportContent, 2);
      if (!this.isAndroid || !this.isChrome) {
        viewport.setAttribute("content", "width = device-width, height = device-height, initial-scale = 1, minimum-scale = 1, maximum-scale = 1, user-scalable = no");
      }
      setTimeout(function() {
        return viewport.setAttribute("content", viewportContent);
      }, 30);
      setTimeout(this.hideAddressBar, 1);
      if (this.viewportChanged) {
        event = document.createEvent("Event");
        event.initEvent("viewportchanged", true, true);
        event.width = this.viewportWidth;
        event.height = this.viewportHeight;
        event.isLandscape = this.isLandscape;
        return window.dispatchEvent(event);
      }
    };

    Viewporter.prototype.orientedWidth = function() {
      var w;
      return w = this.isLandscape ? this.screenHeight() : this.screenWidth();
    };

    Viewporter.prototype.orientedHeight = function() {
      var h, windowRatio;
      if (this.isIphone || this.isChrome) {
        windowRatio = window.innerWidth > window.innerHeight ? window.innerWidth / window.innerHeight : window.innerHeight / window.innerWidth;
        h = this.orientedWidth() * (this.isLandscape ? 1 / windowRatio : windowRatio);
      } else {
        h = this.isLandscape ? this.screenWidth() : this.screenHeight();
      }
      return Math.round(h);
    };

    Viewporter.prototype.screenWidth = function() {
      var div, sw;
      div = this.isAndroid ? 1 / this.pixelRatio : 1;
      return sw = screen.width < screen.height ? screen.width * div : screen.height * div;
    };

    Viewporter.prototype.screenHeight = function() {
      var div, sh;
      div = this.isAndroid ? 1 / this.pixelRatio : 1;
      return sh = screen.width > screen.height ? screen.width * div : screen.height * div;
    };

    Viewporter.prototype.hideAddressBar = function() {
      window.scrollTo(0, 0);
      return setTimeout(function() {
        return window.scrollTo(0, 1);
      }, 100);
    };

    Viewporter.prototype.trace = function(str, level) {
      var log;
      if (this.loggingLevel > 0) {
        if ((typeof console !== "undefined" && console !== null ? console.log : void 0) != null) {
          console.log(str);
        }
        if (level <= this.loggingLevel) {
          log = document.getElementById("log");
          if (log != null) {
            log.innerHTML = str + "<br />\n" + log.innerHTML;
            if (log.innerHTML.length > 2000) {
              return log.innerHTML = log.innerHTML.substring(0, 2000);
            }
          }
        }
      }
    };

    return Viewporter;

  })();

}).call(this);
