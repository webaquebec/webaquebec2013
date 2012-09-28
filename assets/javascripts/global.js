/*
 * @author    YOUR NAME !
 * @company   iXmédia <http://www.ixmedia.com>
 */


// Console
if(!window.console){(function(){var A=function(){};window.console={log:A,info:A,dir:A,warn:A,error:A,trace:A,group:A,groupCollapsed:A,groupEnd:A,time:A,timeEnd:A,profile:A,profileEnd:A,count:A};})();}


$(function() {
  // External links {{{
  var $links = $('a');

  $links.keyup(function(e) {
    if (e.which === 9) {
      $(this).addClass('focus');
    }
  });

  $links.blur(function() {
    $(this).removeClass('focus');
  });

/*
  var DOMAIN_REGEX = {}
  window.domainWithoutSubdomain = function(domainWithSubdomain) {
    var matches = domainWithSubdomain.match(DOMAIN_REGEX);
    return matches ? matches[0] : null;
  };

  var links = $links.get(),
    l = links.length;

  while (l--) {
    link = links[l];
    if (!link.className.match(/fancybox|videos/) && !link.href.match(/^(javascript:|mailto:)/) && (domainWithoutSubdomain(link.hostname) != domainWithoutSubdomain(location.hostname) || link.href.match(/\.(docx?|xlsx?|pptx?|pdf|eps|zip|vsd|vxd|rar|wma|mov|avi|wmv|mp3|mp4|mpg|mpeg|mpeg4|m4a|m4v|f4v|flv|csv|xml|ogg|oga|ogv|webm|jpg|jpeg|png|gif|webp|svg|ico|txt|css|js)$/))) {
      link.target = '_blank';
      link.title += link.title ? ' – S’ouvre dans une nouvelle fenêtre.' : 'S’ouvre dans une nouvelle fenêtre.';
      link.className += link.className.indexOf('externe') == -1 ? ' externe' : '';
    }
  }*/
  // }}}
})
