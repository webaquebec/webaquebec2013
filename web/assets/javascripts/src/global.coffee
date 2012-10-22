###
Author: @louisdumas
###
###############
## Bootstrap ##
###############{{{
window.App = {}
html = document.documentElement
App.OPACITY =  no
if html.style.opacity != undefined
  html.className += " opacity"
  App.OPACITY = yes 
else
  html.className += " no-opacity"
#}}}

#############
#-- CLASS --#
#############

###
# Class OnePager {{{
###
class OnePager
  constructor: ->
    @didScroll   = false
    @isAnimated  = false
    @currentPage = 0
    @navWrap     = $('#secondary-nav')
    @nav         = @navWrap.find('a')
    @sectionsWrapp = $('#one-page-sections')
    @sections    = $('[data-section]')
    @navHeight   = ($('#header').outerHeight())
    @navOffset  = @navHeight
    @pagesOffset = {}
    @resetSectionsOffset()

    
    debounced = jQuery.debounce( 250, ()=>
      @slideTo("##{@pagesOffset[@currentPage]['id']}", 250)
    )
    
    $(window).scroll () =>
      @didScroll = true;

    setInterval () =>
      if @didScroll
        @didScroll = false
        @HandleScrollEvents()
    , 20
    
    window.onhashchange = @hashHasChange
    window.onhashchange()
  
  resetSectionsOffset: ->
    i = 0
    @sections.length
    @sections.each (index, element) =>
      this_     = $ element
      if i isnt @sections.length - 1
        slideHeight = $(window).height() - $('#header').outerHeight()
      else
        slideHeight = $(window).height() - $('footer').outerHeight() - $('#header').outerHeight()
      this_.css({
        'min-height' : slideHeight
      })
      
      pageId    = this_.attr 'id'
      pageStart = this_.offset().top
      pageEnd   = this_.outerHeight() + this_.offset().top
      @pagesOffset[i] = 
        'id'      : pageId
        'offset' : [pageStart, pageEnd]
      i++
  
  setActiveMenu: (target) ->
    @nav.removeClass 'active'
    target.addClass('active')
  
  handleKeyboard: ->
    $(document).bind('keydown', (e) =>
      if e.keyCode == 40
        e.preventDefault() 
        @prevNext.filter('.next').trigger('click')
      else if e.keyCode == 38
        e.preventDefault() 
        @prevNext.filter('.prev').trigger('click')
    )
  handlePrevNextClick: ->
    @prevNext.click((e) =>
      e.preventDefault()
      this_ = $(e.currentTarget)
      if this_.hasClass('prev') && (@currentPage-1) >= 0
        newHash = "#section=#{@pagesOffset[(@currentPage-1)]['id']}"
        location.hash = newHash
      else if this_.hasClass('next') && (@currentPage+1) < @sections.length
        newHash = "#section=#{@pagesOffset[(@currentPage+1)]['id']}"
        location.hash = newHash
    )    
      
  slideTo: (target ,speed, moreOffsets) ->
    target          = @sections.filter(target)
    targetId        = target.attr('id')
    moreOffsets     = moreOffsets || 0
    targetScrollTop = target.offset().top - @navOffset - moreOffsets
    targetLink      = $("a[href='#/#{targetId}']")
    @isAnimated = true
    @currentPage = @getPageIndex(targetId)
    @setActiveMenu(targetLink)
    
    if @sectionsWrapp.attr('data-transitions') is 'on'
      $('body, html').stop().animate({'scrollTop' : targetScrollTop},speed, $.bez([0.80, 0, 0.20, 1.0]), () =>
        @isAnimated = false
      )
    else
      $('body, html').stop().animate({'scrollTop' : targetScrollTop}, 0, () =>
        @isAnimated = false
        @sectionsWrapp.attr('data-transitions', 'on')
      )
  
  getPageIndex: (id)->
    for i, object of @pagesOffset
      if object.id == id
        return parseInt(i)
  
  hashHasChange: =>
    if location.hash
      newhash = '#' + location.hash.replace('#/', '')
      if @sections.filter(newhash).length
        @slideTo(newhash, 650)
    else
      target = "##{@pagesOffset[@currentPage]['id']}"
      targetLink = $("a[href='#{target.replace('#', '#/')}']")
      @slideTo(target , 650)
      @setActiveMenu(targetLink)
  
  HandleScrollEvents: ->
      if !@isAnimated
        scroll = $(window).scrollTop()
        scroll = scroll - @pagesOffset[@currentPage]['offset'][0]
        precentIn = scroll/(@pagesOffset[@currentPage]['offset'][1]-@pagesOffset[@currentPage]['offset'][0])
        precentIn = Math.round((precentIn * 100))
        if precentIn >= 51
          @currentPage = @currentPage + 1
        else if precentIn < -49
          @currentPage = @currentPage - 1
      
        pageId = @pagesOffset[@currentPage]['id']
        targetLink = $("a[href='#/#{pageId}']")
      
        if !targetLink.hasClass('active')
          this.setActiveMenu($("a[href='#/#{pageId}']"))

  currentPage: @currentPage
  isAnimated : @isAnimated

###
# }}}
###

$ () ->
  # Common 
  ################{{{
  body = $('body')
  
  # Hack for console.log() on IE
  if !window.console
    do ->
      f = () ->
      window.console = {log: f, info: f, dir: f, warn: f, error: f, trace: f, group: f, groupCollapsed: f, groupEnd: f, time: f, timeEnd: f, profile: f, profileEnd: f, count: f}  
  
  # Target _blank on external links
  window.DOMAIN_REGEX = /[a-z0-9\-]+\.(com|org|ca|qc\.ca|gouv\.qc\.ca|net|info|biz|edu|gov|us|fr|dev.ixmedia.com|dev5.ixmedia.com|dev3.ixmedia.com)$/
  $links = $('a');
  $links.keyup((e) ->
    if e.which == 9
      $(this).addClass('focus')
  )
  $links.blur(() ->
    $(this).removeClass('focus')
  )
  window.domainWithoutSubdomain = (domainWithSubdomain) ->
    matches = domainWithSubdomain.match(DOMAIN_REGEX)
    if matches 
      return matches[0] 
    else 
      return null

  links = $links.get()
  l = links.length
  
  `
  while (l--) {
    link = links[l];
    if (!link.className.match(/fancybox|videos/) && !link.href.match(/^(javascript:|mailto:)/) && (domainWithoutSubdomain(link.hostname) != domainWithoutSubdomain(location.hostname) || link.href.match(/\.(docx?|xlsx?|pptx?|pdf|eps|zip|vsd|vxd|rar|wma|mov|avi|wmv|mp3|mp4|mpg|mpeg|mpeg4|m4a|m4v|f4v|flv|csv|xml|ogg|oga|ogv|webm|jpg|jpeg|png|gif|webp|svg|ico|txt|css|js)$/))) {
      link.target = '_blank';
      link.title += link.title ? ' – S’ouvre dans une nouvelle fenêtre.' : 'S’ouvre dans une nouvelle fenêtre.';
      link.className += link.className.indexOf('externe') == -1 ? ' externe' : '';
    }
  }
  `
  #}}}

  # Page
  #####################{{{
  
  # OnePager instanciation
  if $('#one-pager').length
    do ->
      myOnePager = new OnePager()
              
  #}}}