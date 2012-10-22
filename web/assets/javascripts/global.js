// Generated by CoffeeScript 1.3.1

/*
Author: @louisdumas
*/


(function() {
  var OnePager, html,
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
  # Class OnePager {{{
  */


  OnePager = (function() {

    OnePager.name = 'OnePager';

    function OnePager() {
      this.hashHasChange = __bind(this.hashHasChange, this);

      var debounced,
        _this = this;
      this.didScroll = false;
      this.isAnimated = false;
      this.currentPage = 0;
      this.navWrap = $('#secondary-nav');
      this.nav = this.navWrap.find('a');
      this.sectionsWrapp = $('#one-page-sections');
      this.sections = $('[data-section]');
      this.navHeight = $('#header').outerHeight();
      this.navOffset = this.navHeight;
      this.pagesOffset = {};
      this.resetSectionsOffset();
      debounced = jQuery.debounce(250, function() {
        return _this.slideTo("#" + _this.pagesOffset[_this.currentPage]['id'], 250);
      });
      $(window).scroll(function() {
        return _this.didScroll = true;
      });
      setInterval(function() {
        if (_this.didScroll) {
          _this.didScroll = false;
          return _this.HandleScrollEvents();
        }
      }, 20);
      window.onhashchange = this.hashHasChange;
      window.onhashchange();
    }

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
        this_.css({
          'min-height': slideHeight
        });
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

    OnePager.prototype.handleKeyboard = function() {
      var _this = this;
      return $(document).bind('keydown', function(e) {
        if (e.keyCode === 40) {
          e.preventDefault();
          return _this.prevNext.filter('.next').trigger('click');
        } else if (e.keyCode === 38) {
          e.preventDefault();
          return _this.prevNext.filter('.prev').trigger('click');
        }
      });
    };

    OnePager.prototype.handlePrevNextClick = function() {
      var _this = this;
      return this.prevNext.click(function(e) {
        var newHash, this_;
        e.preventDefault();
        this_ = $(e.currentTarget);
        if (this_.hasClass('prev') && (_this.currentPage - 1) >= 0) {
          newHash = "#section=" + _this.pagesOffset[_this.currentPage - 1]['id'];
          return location.hash = newHash;
        } else if (this_.hasClass('next') && (_this.currentPage + 1) < _this.sections.length) {
          newHash = "#section=" + _this.pagesOffset[_this.currentPage + 1]['id'];
          return location.hash = newHash;
        }
      });
    };

    OnePager.prototype.slideTo = function(target, speed, moreOffsets) {
      var targetId, targetLink, targetScrollTop,
        _this = this;
      target = this.sections.filter(target);
      targetId = target.attr('id');
      moreOffsets = moreOffsets || 0;
      targetScrollTop = target.offset().top - this.navOffset - moreOffsets;
      targetLink = $("a[href='#/" + targetId + "']");
      this.isAnimated = true;
      this.currentPage = this.getPageIndex(targetId);
      this.setActiveMenu(targetLink);
      if (this.sectionsWrapp.attr('data-transitions') === 'on') {
        return $('body, html').stop().animate({
          'scrollTop': targetScrollTop
        }, speed, $.bez([0.80, 0, 0.20, 1.0]), function() {
          return _this.isAnimated = false;
        });
      } else {
        return $('body, html').stop().animate({
          'scrollTop': targetScrollTop
        }, 0, function() {
          _this.isAnimated = false;
          return _this.sectionsWrapp.attr('data-transitions', 'on');
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

    OnePager.prototype.hashHasChange = function() {
      var newhash, target, targetLink;
      if (location.hash) {
        newhash = '#' + location.hash.replace('#/', '');
        if (this.sections.filter(newhash).length) {
          return this.slideTo(newhash, 650);
        }
      } else {
        target = "#" + this.pagesOffset[this.currentPage]['id'];
        targetLink = $("a[href='" + (target.replace('#', '#/')) + "']");
        this.slideTo(target, 650);
        return this.setActiveMenu(targetLink);
      }
    };

    OnePager.prototype.HandleScrollEvents = function() {
      var pageId, precentIn, scroll, targetLink;
      if (!this.isAnimated) {
        scroll = $(window).scrollTop();
        scroll = scroll - this.pagesOffset[this.currentPage]['offset'][0];
        precentIn = scroll / (this.pagesOffset[this.currentPage]['offset'][1] - this.pagesOffset[this.currentPage]['offset'][0]);
        precentIn = Math.round(precentIn * 100);
        if (precentIn >= 51) {
          this.currentPage = this.currentPage + 1;
        } else if (precentIn < -49) {
          this.currentPage = this.currentPage - 1;
        }
        pageId = this.pagesOffset[this.currentPage]['id'];
        targetLink = $("a[href='#/" + pageId + "']");
        if (!targetLink.hasClass('active')) {
          return this.setActiveMenu($("a[href='#/" + pageId + "']"));
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


  $(function() {
    var $links, body, l, links;
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

    if ($('#one-pager').length) {
      return (function() {
        var myOnePager;
        return myOnePager = new OnePager();
      })();
    }
  });

}).call(this);
