// Generated by CoffeeScript 1.3.1

/*
Author: @louisdumas
*/


(function() {
  var OnePager, Schedule, Slider, customGmap, html,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.App = {};

  html = document.documentElement;

  App.OPACITY = false;

  if (html.style.opacity !== void 0) {
    html.className += " opacity";
    App.OPACITY = true;
  } else {
    html.className += " no-opacity";
  }

  /*
  # Class Slider {{{
  */


  Slider = (function() {

    Slider.name = 'Slider';

    function Slider(slider, opts) {
      var _this = this;
      this.slider = slider;
      this.slidesWrap = this.slider.find('.slides-wrap');
      this.navWrap = this.slider.find('.slider-nav');
      this.descWrap = this.slider.find('.descs');
      this.currentIndex = 0;
      this.isAnimated = false;
      this.timer = opts.timer != null ? opts.timer : 5000;
      this.slides = (function() {
        var key, slide, slideObject, slides, _i, _len, _ref;
        slides = [];
        _ref = _this.slidesWrap.find('.slide');
        for (key = _i = 0, _len = _ref.length; _i < _len; key = ++_i) {
          slide = _ref[key];
          slideObject = $(slide);
          slides.push(slideObject);
          if (key === _this.currentIndex) {
            _this.navWrap.append('<a href="javascript://" class="active" data-index="' + key + '"></a>');
            _this.descWrap.append('<span class="on-stage">' + slideObject.attr('data-desc') + '</span>');
          } else {
            _this.navWrap.append('<a href="javascript://" data-index="' + key + '"></a>');
            _this.descWrap.append('<span>' + slideObject.attr('data-desc') + '</span>');
          }
        }
        return slides;
      })();
      this.navElements = this.navWrap.find('a');
      this.descElements = this.descWrap.find('span');
      this.slides[this.currentIndex].addClass('active');
      this.handleNav();
      if (this.timer > 0) {
        this.i = setInterval(function() {
          if (!_this.isAnimated) {
            _this.handleNextSlide();
            _this.isAnimated = true;
            return _this.slide();
          }
        }, this.timer);
      }
    }

    Slider.prototype.handleNav = function() {
      var _this = this;
      return this.navElements.click(function(e) {
        var index, this_;
        this_ = $(e.target);
        index = parseInt(this_.attr('data-index'));
        if (_this.currentIndex !== index && !_this.isAnimated) {
          _this.nextSlideIndex = index;
          _this.isAnimated = true;
          return _this.slide();
        }
      });
    };

    Slider.prototype.handleNextSlide = function() {
      return this.nextSlideIndex = this.currentIndex === (this.slides.length - 1) ? 0 : this.currentIndex + 1;
    };

    Slider.prototype.slide = function() {
      var pos, t1, t2,
        _this = this;
      pos = this.slides[this.nextSlideIndex].position().left;
      this.descElements.removeClass('on-stage').addClass('backstage');
      this.descElements.eq(this.nextSlideIndex).addClass('backstage');
      t1 = setTimeout(function() {
        return _this.descElements.eq(_this.nextSlideIndex).removeClass('backstage').addClass('on-stage');
      }, 150);
      this.navElements.removeClass('active');
      this.navElements.eq(this.nextSlideIndex).addClass('active');
      this.slidesWrap.css({
        'left': -pos
      });
      return t2 = setTimeout(function() {
        _this.descElements.eq(_this.currentIndex).removeClass('backstage');
        _this.currentIndex = _this.nextSlideIndex;
        return _this.isAnimated = false;
      }, 500);
    };

    return Slider;

  })();

  /*
  # }}}
  */


  /*
  # Class Schedule {{{
  */


  Schedule = (function() {

    Schedule.name = 'Schedule';

    function Schedule(opts) {
      this.close = __bind(this.close, this);

      this.open = __bind(this.open, this);

      var onClose, onOpen,
        _this = this;
      this.slideWrapper = $('#schedule .slides-wrap');
      this.overFlowwRapper = $('#schedule .wrapper');
      this.navElement = $('#schedule-nav a');
      this.slides = this.slideWrapper.find('.slide');
      this.startingHeight = 500;
      this.slideWrapperHeight = this.slideWrapper.outerHeight();
      this.openBtn = $('#schedule #open-shedule a');
      this.navElement.eq(0).addClass('active');
      this.openBtn.click(function() {
        if (_this.openBtn.hasClass('active')) {
          return _this.close();
        } else {
          return _this.open();
        }
      });
      onOpen = (opts != null) && (opts.onOpen != null) ? opts.onOpen : function() {};
      onClose = (opts != null) && (opts.onClose != null) ? opts.onClose : function() {};
      $(this).bind('onOpen', onOpen);
      $(this).bind('onClose', onClose);
    }

    Schedule.prototype.slideTo = function(id) {
      var posX, target;
      target = this.slides.filter("#" + id);
      posX = target.position().left;
      this.navElement.removeClass('active');
      $('[data-ref="' + id + '"]').addClass('active');
      return this.slideWrapper.css({
        'left': -posX
      });
    };

    Schedule.prototype.open = function() {
      $(this).trigger('onOpen');
      this.openBtn.html('Fermer');
      this.openBtn.addClass('active');
      return this.overFlowwRapper.css({
        'height': this.slideWrapperHeight
      });
    };

    Schedule.prototype.close = function() {
      var t,
        _this = this;
      $(this).trigger('onClose');
      this.openBtn.html('Tout afficher');
      this.openBtn.removeClass('active');
      return t = setTimeout(function() {
        return _this.overFlowwRapper.css({
          'height': _this.startingHeight
        });
      }, 200);
    };

    return Schedule;

  })();

  /*
  # }}}
  */


  /*
  # Class OnePager {{{
  */


  OnePager = (function() {

    OnePager.name = 'OnePager';

    function OnePager() {
      this.hashHasChange = __bind(this.hashHasChange, this);

      var _this = this;
      this.didScroll = false;
      this.isAnimated = false;
      this.currentPage = 0;
      this.navWrap = $('nav[role="navigation"]');
      this.nav = this.navWrap.find('a');
      this.sectionsWrapp = $('#one-pager');
      this.sections = $('[data-section]');
      this.navHeight = this.navWrap.outerHeight();
      this.navOffset = this.navHeight;
      this.pagesOffset = {};
      this.resetSectionsOffset();
      this.animatWhenSliding = false;
      $(window).on('scroll', function() {
        return _this.didScroll = true;
      });
      setInterval(function() {
        if (_this.didScroll) {
          _this.didScroll = false;
          return _this.HandleScrollEvents();
        }
      }, 20);
      this.stopScrollOnMouseScroll();
    }

    OnePager.prototype.stopScrollOnMouseScroll = function() {
      var stopScroll;
      stopScroll = function() {
        return $('body, html').stop();
      };
      window.addEventListener('DOMMouseScroll', stopScroll, false);
      return window.addEventListener('mousewheel', stopScroll, false);
    };

    OnePager.prototype.resetSectionsOffset = function() {
      var i,
        _this = this;
      i = 0;
      this.sections.length;
      return this.sections.each(function(index, element) {
        var pageEnd, pageId, pageStart, slideHeight, this_;
        this_ = $(element);
        if (i !== _this.sections.length - 1) {
          slideHeight = $(window).height() - $('#header').outerHeight();
        } else {
          slideHeight = $(window).height() - $('footer').outerHeight() - $('#header').outerHeight();
        }
        pageId = this_.attr('id');
        pageStart = this_.offset().top;
        pageEnd = this_.outerHeight() + this_.offset().top;
        _this.pagesOffset[i] = {
          'id': pageId,
          'offset': [pageStart, pageEnd]
        };
        return i++;
      });
    };

    OnePager.prototype.setActiveMenu = function(target) {
      this.nav.removeClass('active');
      return target.addClass('active');
    };

    OnePager.prototype.slideTo = function(target, speed, moreOffsets) {
      var targetId, targetLink, targetScrollTop,
        _this = this;
      target = this.sections.filter(target);
      targetId = target.attr('id');
      moreOffsets = moreOffsets || 0;
      targetScrollTop = target.offset().top - this.navOffset - moreOffsets;
      targetLink = $("a[href='#/" + targetId + "/']");
      this.isAnimated = true;
      this.currentPage = this.getPageIndex(targetId);
      this.setActiveMenu(targetLink);
      targetScrollTop = targetScrollTop <= 0 ? 0 : targetScrollTop;
      if (this.animatWhenSliding) {
        return $('body, html').stop().animate({
          'scrollTop': targetScrollTop
        }, speed, $.bez([0.80, 0, 0.20, 1.0]), function() {
          return _this.isAnimated = false;
        });
      } else {
        return $('body, html').stop().animate({
          'scrollTop': targetScrollTop
        }, 0, function() {
          return _this.isAnimated = false;
        });
      }
    };

    OnePager.prototype.getPageIndex = function(id) {
      var i, object, _ref;
      _ref = this.pagesOffset;
      for (i in _ref) {
        object = _ref[i];
        if (object.id === id) {
          return parseInt(i);
        }
      }
    };

    OnePager.prototype.hashHasChange = function(target) {
      var newhash;
      newhash = "#" + target;
      return this.slideTo(newhash, 650);
    };

    OnePager.prototype.HandleScrollEvents = function() {
      var pageId, precentIn, scroll, targetLink;
      if (!this.isAnimated) {
        scroll = $(window).scrollTop();
        scroll = scroll - this.pagesOffset[this.currentPage]['offset'][0];
        precentIn = scroll / (this.pagesOffset[this.currentPage]['offset'][1] - this.pagesOffset[this.currentPage]['offset'][0]);
        precentIn = Math.round(precentIn * 100);
        if (precentIn >= 80) {
          this.currentPage = this.currentPage + 1;
        } else if (precentIn < -20) {
          this.currentPage = this.currentPage - 1;
        }
        pageId = this.pagesOffset[this.currentPage]['id'];
        targetLink = $("a[href='#/" + pageId + "/']");
        if (!targetLink.hasClass('active')) {
          return this.setActiveMenu($("a[href='#/" + pageId + "/']"));
        }
      }
    };

    OnePager.prototype.currentPage = OnePager.currentPage;

    OnePager.prototype.isAnimated = OnePager.isAnimated;

    return OnePager;

  })();

  /*
  # }}}
  */


  /*
  # Class Gmap {{{
  */


  customGmap = (function() {

    customGmap.name = 'customGmap';

    function customGmap(elementId) {
      var gMapOptions;
      console.log("foobar");
      gMapOptions = {
        zoom: 17,
        center: new google.maps.LatLng(46.817682, -71.2065922),
        mapTypeControl: false,
        streetViewControl: false,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      this.map = new google.maps.Map($(elementId)[0], gMapOptions);
    }

    customGmap.prototype.test = function() {
      return console.log('sti');
    };

    return customGmap;

  })();

  /*
  # }}}
  */


  $(function() {
    var $links, body, l, links, myGmap, myHomeSlider, myMasonry, myOnePager, mySchedule, router, stickyHeader;
    body = $('body');
    if (!window.console) {
      (function() {
        var f;
        f = function() {};
        return window.console = {
          log: f,
          info: f,
          dir: f,
          warn: f,
          error: f,
          trace: f,
          group: f,
          groupCollapsed: f,
          groupEnd: f,
          time: f,
          timeEnd: f,
          profile: f,
          profileEnd: f,
          count: f
        };
      })();
    }
    window.DOMAIN_REGEX = /[a-z0-9\-]+\.(com|org|ca|qc\.ca|gouv\.qc\.ca|net|info|biz|edu|gov|us|fr|dev.ixmedia.com|dev5.ixmedia.com|dev3.ixmedia.com)$/;
    $links = $('a');
    $links.keyup(function(e) {
      if (e.which === 9) {
        return $(this).addClass('focus');
      }
    });
    $links.blur(function() {
      return $(this).removeClass('focus');
    });
    window.domainWithoutSubdomain = function(domainWithSubdomain) {
      var matches;
      matches = domainWithSubdomain.match(DOMAIN_REGEX);
      if (matches) {
        return matches[0];
      } else {
        return null;
      }
    };
    links = $links.get();
    l = links.length;
    
  while (l--) {
    link = links[l];
    if (!link.className.match(/fancybox|videos/) && !link.href.match(/^(javascript:|mailto:)/) && (domainWithoutSubdomain(link.hostname) != domainWithoutSubdomain(location.hostname) || link.href.match(/\.(docx?|xlsx?|pptx?|pdf|eps|zip|vsd|vxd|rar|wma|mov|avi|wmv|mp3|mp4|mpg|mpeg|mpeg4|m4a|m4v|f4v|flv|csv|xml|ogg|oga|ogv|webm|jpg|jpeg|png|gif|webp|svg|ico|txt|css|js)$/))) {
      link.target = '_blank';
      link.title += link.title ? ' – S’ouvre dans une nouvelle fenêtre.' : 'S’ouvre dans une nouvelle fenêtre.';
      link.className += link.className.indexOf('externe') == -1 ? ' externe' : '';
    }
  }
  ;

    myOnePager = new OnePager();
    myHomeSlider = new Slider($('#slider'), {
      timer: 5000
    });
    myGmap = new customGmap('#gmap');
    mySchedule = new Schedule({
      onOpen: function() {
        return myOnePager.hashHasChange('horaire');
      },
      onClose: function() {
        return myOnePager.hashHasChange('horaire');
      }
    });
    myMasonry = new $.Mason({
      itemSelector: '.conference',
      containerStyle: {
        'position': 'absolute'
      },
      columnWidth: function(containerWidth) {
        return containerWidth / 4;
      },
      isAnimated: true,
      animationOptions: {
        duration: 100
      }
    }, $('.conferences'));
    router = $.sammy(function() {
      this.get(/\#\/(home|horaire|lieu-et-infos|partenaires|a-propos)\/*$/, function(cx, section) {
        return myOnePager.hashHasChange(section);
      });
      this.get(/\#\/horaire\/(mercredi|jeudi|vendredi)\/*$/, function(cx, day) {
        myOnePager.hashHasChange('horaire');
        return mySchedule.slideTo(day);
      });
      return this.get(/\#\/horaire\/(mercredi|jeudi|vendredi)\/([a-zA-Z0-9\-]+)\/*$/, function(cx, day, conf) {
        return myOnePager.hashHasChange('horaire');
      });
    });
    router.debug = true;
    router.run();
    myOnePager.animatWhenSliding = true;
    return stickyHeader = (function() {
      var header, headerOffsetTop, viewport;
      header = $('nav[role="navigation"]');
      headerOffsetTop = header.offset().top;
      viewport = $(window);
      return viewport.scroll(function() {
        if ((headerOffsetTop - viewport.scrollTop()) > 0) {
          return header.removeClass('sticky');
        } else {
          return header.addClass('sticky');
        }
      });
    })();
  });

}).call(this);
