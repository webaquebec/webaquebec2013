/* ****************************************************

  @file         analytics.js
  @version      v2.0
  @description  Force le « tracking » Google Analytics des liens externes, des documents et des mailto.
  @author       remi, jp & Rafaël (ixmedia.com)

***************************************************** */
(function() {

  // Seulement si Google Analytics est présent!
  if (typeof pageTracker !== 'object' && typeof _gaq !== 'object') return;

  var CONFIG = {
    'courriel': {
      check: function() { return this.protocol === 'mailto:' },
      url  : function() { return '/' + this.href.substring(7) }
    },
    'document': {
      check: function() { return this.hostname === window.location.hostname && this.href.match(/\.(docx?|xlsx?|pptx?|pdf|eps|zip|vsd|vxd|rar|wma|mov|avi|wmv|mp3|mp4|mpg|mpeg|mpeg4|m4a|m4v|f4v|flv|csv|xml|ogg|oga|ogv|webm|jpg|jpeg|png|gif|webp|svg|ico|txt|css|js)$/) },
      url  : function() { return this.href.replace(window.location.hostname, '').replace(window.location.protocol + '//', '') }
    },
    'externe': {
      check: function() { return this.hostname !== location.hostname },
      url  : function() { return '/' + this.href.replace(/^https?:\/\//, '') }
    }
  };

  var trackingHandler = function(url) {
    if (typeof pageTracker == 'object') { // ancienne version
      pageTracker._trackPageview(url);
    } else if (typeof _gaq == 'object') { // nouvelle version, on vérifie l’ancienne en premier parce que l’objet "_gaq" existait déjà dans l’ancienne version
      _gaq.push(['_trackPageview', url]);
    }
  };

  for (var a = document.links.length; a--;) {
    (function() {
      var lien = this;
      // on ne track pas ces liens
      if (!lien.href || lien.href.match(/javascript:/) || lien.className.match(/fancybox/)) return;

      linktypecheck:
      for (var linkType in CONFIG) {
        if (!CONFIG.hasOwnProperty(linkType)) continue;

        if (CONFIG[ linkType ].check.call(lien)) {

          (function(linkType, linkTypeChecker, urlFilterer) {

            if (lien.addEventListener !== undefined) {
              lien.addEventListener('click', function() {
                trackingHandler('/' + linkType + urlFilterer.call(lien));
              }, false);
            } else {
              lien.attachEvent('onclick', function() {
                trackingHandler('/' + linkType + urlFilterer.call(lien));
              });
            }

          }).call(lien, linkType, CONFIG[ linkType ].check, CONFIG[ linkType ].url);

          break linktypecheck;
        }
      }
    }).call(document.links[a]);
  }

})();
