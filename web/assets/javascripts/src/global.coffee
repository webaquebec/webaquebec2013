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
# Class Slider {{{
###
class Slider
  constructor: (slider, opts) ->
    @slider       = slider
    @slidesWrap   = @slider.find('.slides-wrap')
    @navWrap      = @slider.find('.slider-nav')
    @descWrap     = @slider.find('.descs')
    @currentIndex = 0
    @isAnimated   = no
    @timer        = if opts.timer? then opts.timer else 5000

    @slides = (() =>
      slides = []
      for slide, key in @slidesWrap.find('.slide')
        slideObject = $(slide)
        slides.push(slideObject)
        if key is @currentIndex
          @navWrap.append('<a href="javascript://" class="active" data-index="'+key+'"></a>')
          @descWrap.append('<span class="on-stage">'+slideObject.attr('data-desc')+'</span>')
        else
          @navWrap.append('<a href="javascript://" data-index="'+key+'"></a>')
          @descWrap.append('<span>'+slideObject.attr('data-desc')+'</span>')
      slides
    )()
    
    @navElements  = @navWrap.find('a')
    @descElements = @descWrap.find('span')
    
    @slides[@currentIndex].addClass('active')
    @handleNav()
    if @timer > 0
      @i = setInterval( =>
        if !@isAnimated
          @handleNextSlide()
          @isAnimated = yes
          @slide()
      , @timer)
    
  handleNav: ->
    @navElements.click( (e) =>
      this_ = $(e.target)
      index = parseInt(this_.attr('data-index'))

      if @currentIndex isnt index && !@isAnimated
        @nextSlideIndex = index
        @isAnimated = yes
        @slide()
    )
    
  handleNextSlide:  ->
    @nextSlideIndex = if @currentIndex == (@slides.length - 1) then 0 else @currentIndex + 1

  slide: ->
    pos = @slides[@nextSlideIndex].position().left
    
    @descElements.removeClass('on-stage').addClass('backstage')
    @descElements.eq(@nextSlideIndex).addClass('backstage')
    t1 = setTimeout( =>
      @descElements.eq(@nextSlideIndex).removeClass('backstage').addClass('on-stage')
    , 150)

    @navElements.removeClass('active')
    @navElements.eq(@nextSlideIndex).addClass('active')
    @slidesWrap.css({'left' : -pos})
    
    t2 = setTimeout( =>
      @descElements.eq(@currentIndex).removeClass('backstage')
      @currentIndex = @nextSlideIndex
      @isAnimated   = no
    , 500)
###
# }}}
###

###
# Class Schedule {{{
###
class Schedule
  constructor: (opts)->
    @slideWrapper        = $('#schedule .slides-wrap')
    @overFlowwRapper     = $('#schedule .wrapper')
    @navElement          = $('#schedule-nav a')
    @slides              = @slideWrapper.find('.slide')
    @startingHeight      = 500
    @slideWrapperHeight  = @slideWrapper.outerHeight()
    @openBtn             = $('#schedule #open-shedule a')
    
    @navElement.eq(0).addClass('active')

    @openBtn.click( =>
      if @openBtn.hasClass('active')
        @close()
      else
        @open()
    )
    
    onOpen  = if opts? && opts.onOpen? then opts.onOpen else () ->
    onClose = if opts? && opts.onClose? then opts.onClose else () ->
    
    $(@).bind('onOpen', onOpen)
    $(@).bind('onClose', onClose)
    
  slideTo: (id) ->
    target = @slides.filter("##{id}")
    posX   = target.position().left
    @navElement.removeClass('active')
    $('[data-ref="'+id+'"]').addClass('active')
    @slideWrapper.css({ 'left' : -posX})

  open: =>
    $(@).trigger('onOpen')
    @openBtn.html('Fermer')
    @openBtn.addClass('active')
    @overFlowwRapper.css(
      'height'     : @slideWrapperHeight
    )
    
  close: =>
    $(@).trigger('onClose')
    @openBtn.html('Tout afficher')
    @openBtn.removeClass('active')
    t = setTimeout( =>
      @overFlowwRapper.css(
        'height'     : @startingHeight
      )
    ,200)

###
# }}}
###

###
# Class OnePager {{{
###
class OnePager
  constructor: ->
    @didScroll   = false
    @isAnimated  = false
    @currentPage = 0
    @navWrap     = $('nav[role="navigation"]')
    @nav         = @navWrap.find('a')
    @sectionsWrapp = $('#one-pager')
    @sections    = $('[data-section]')
    @navHeight   = @navWrap.outerHeight()
    @navOffset  = @navHeight
    @pagesOffset = {}
    @resetSectionsOffset()
    @animatWhenSliding = no
    
    $(window).on('scroll', =>
      @didScroll = true;
    )

    setInterval () =>
      if @didScroll
        @didScroll = false
        @HandleScrollEvents()
    , 20
  
    @stopScrollOnMouseScroll()
  
  stopScrollOnMouseScroll: ->
    stopScroll = ->
      $('body, html').stop()

    # firefox
    window.addEventListener('DOMMouseScroll', stopScroll, false);
    # Everything else
    window.addEventListener('mousewheel', stopScroll, false)

  resetSectionsOffset: ->
    i = 0
    @sections.length
    @sections.each (index, element) =>
      this_     = $ element
      if i isnt @sections.length - 1
        slideHeight = $(window).height() - $('#header').outerHeight()
      else
        slideHeight = $(window).height() - $('footer').outerHeight() - $('#header').outerHeight()
      
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
        
  slideTo: (target ,speed, moreOffsets) ->
    target          = @sections.filter(target)
    targetId        = target.attr('id')
    moreOffsets     = moreOffsets || 0
    targetScrollTop = target.offset().top - @navOffset - moreOffsets
    targetLink      = $("a[href='#/#{targetId}/']")
    @isAnimated = true
    @currentPage = @getPageIndex(targetId)
    @setActiveMenu(targetLink)
    
    targetScrollTop = if targetScrollTop <= 0 then 0 else targetScrollTop
    if @animatWhenSliding
      $('body, html').stop().animate({'scrollTop' : targetScrollTop},speed, $.bez([0.80, 0, 0.20, 1.0]), () =>
        @isAnimated = false
      )
    else
      $('body, html').stop().animate({'scrollTop' : targetScrollTop}, 0, () =>
        @isAnimated = false
      )
  
  getPageIndex: (id)->
    for i, object of @pagesOffset
      if object.id == id
        return parseInt(i)
  
  hashHasChange: (target) =>
    newhash = "##{target}"
    @slideTo(newhash, 650)
  
  HandleScrollEvents: ->
      if !@isAnimated
        scroll = $(window).scrollTop()
        scroll = scroll - @pagesOffset[@currentPage]['offset'][0]
        precentIn = scroll/(@pagesOffset[@currentPage]['offset'][1]-@pagesOffset[@currentPage]['offset'][0])
        precentIn = Math.round((precentIn * 100))
        if precentIn >= 80
          @currentPage = @currentPage + 1
        else if precentIn < -20
          @currentPage = @currentPage - 1
      
        pageId = @pagesOffset[@currentPage]['id']
        targetLink = $("a[href='#/#{pageId}/']")
      
        if !targetLink.hasClass('active')
          @setActiveMenu($("a[href='#/#{pageId}/']"))

  currentPage: @currentPage
  isAnimated : @isAnimated

###
# }}}
###

###
# Class Gmap {{{
###
class customGmap
  constructor: (elementId) ->
    coord = new google.maps.LatLng(46.817682, -71.2065922)
    gMapOptions = 
      zoom: 17
      center: coord
      mapTypeControl: false
      streetViewControl: false
      panControl: false
      mapTypeId: google.maps.MapTypeId.ROADMAP
    
    mapStyle = [
      {
        "featureType": "poi",
        "stylers": [
          { "hue": "#005eff" },
          { "lightness": -6 },
          { "saturation": -100 }
        ]
      },{
        "featureType": "water",
        "stylers": [
          { "invert_lightness": true },
          { "visibility": "on" },
          { "color": "#0086b8" }
        ]
      },{
        "featureType": "road",
        "stylers": [
          { "visibility": "on" },
          { "hue": "#0099ff" },
          { "gamma": 1.13 }
        ]
      },{
        "featureType": "landscape",
        "stylers": [
          { "saturation": -100 }
        ]
      }]
    
    @map = new google.maps.Map($(elementId)[0], gMapOptions)
    styledMap = new google.maps.StyledMapType(mapStyle, {name: "Styled Map"})
    @map.mapTypes.set('map_style', styledMap)
    @map.setMapTypeId('map_style')
    @infoWindow = new CustomInfoWindow(coord, @map)
    
    
###
# }}}
###

###
# Class CustomInfoWindow {{{
###
class CustomInfoWindow
  constructor: (position, map) ->
    console.log "@@@@@@@@"
    @position = position 
    @map      = map
    wrap = '''
    <div class="customInfoWindow">    
      <div class="padding">
        <span class="address">
          Espace 400e Bell<br>
          100, Quai Saint-André<br>
          Québec, QC
        </span>
        <img src="/assets/images/png/logo-waq-gray.png" alt="" width="121px" height="41px">
      </div>
    </div>
    '''
    @wrap = $(wrap)
    @setMap(@map)
    @isVisible = true
    
    console.log "---------------"
    console.log position
  
  CustomInfoWindow:: = new google.maps.OverlayView()
  
  onAdd: ->
    @wrap.css(
      display: "block"
      position: "absolute"
    )
    panes = @getPanes()
    panes.overlayMouseTarget.appendChild(@wrap[0])
    @iWidth = @wrap.outerWidth()
    @iHeight = @wrap.outerHeight()
    
    cancelHandler = (e) ->
      e.cancelBubble = true
      if e.stopPropagation
        e.stopPropagation()
    
    events = ['mousedown', 'touchstart', 'touchend', 'touchmove', 'contextmenu', 'click', 'dblclick', 'mousewheel', 'DOMMouseScroll']
    @listeners = []
    for event in events
      @listeners.push(google.maps.event.addDomListener(@wrap[0], event, cancelHandler);)
      
  draw: ->
    overlayProjection = @getProjection()
    pos = overlayProjection.fromLatLngToDivPixel(@position)
    @oX = pos.x - @wrap.outerWidth() / 2
    @oY = pos.y - @wrap.outerHeight()
    @wrap.css({
      left: @oX,
      top: @oY
    })
    
  panMap: ->
    if @map.getZoom() < 3
      @map.setZoom(3)
      
    scale = Math.pow(2, @map.getZoom());
    worldCoordinateCenter = @map.getProjection().fromLatLngToPoint(@position)
    worldCoordinateNewCenter = new google.maps.Point(
        worldCoordinateCenter.x - 150/scale,
        worldCoordinateCenter.y + 200/scale
    )
    newCenter = @map.getProjection().fromPointToLatLng(worldCoordinateNewCenter)
    
    @map.panTo(newCenter)
    
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
  
  # Class instaciation
  myHomeSlider = new Slider($('#slider'), {timer : 5000})
  myGmap       = new customGmap('#gmap')
  mySchedule   = new Schedule(
    onOpen : () ->
      myOnePager.hashHasChange('horaire')
    onClose : () ->
      myOnePager.hashHasChange('horaire')
  )
  myOnePager   = new OnePager()
  
  myMasonry    = new $.Mason(
    itemSelector : '.conference'
    containerStyle : { 'position' : 'absolute'}
    columnWidth: (containerWidth) ->
      containerWidth / 4
    isAnimated : true
    animationOptions: { duration: 100 }
  , $('.conferences'))

  #############
  #-- ROUTER --#
  #############
  router = $.sammy(() ->

    @.get(/\#\/(home|horaire|lieu-et-infos|partenaires|a-propos)\/*$/, (cx, section) ->
      myOnePager.hashHasChange(section)
    )
    
    @.get(/\#\/horaire\/(mercredi|jeudi|vendredi)\/*$/, (cx, day) ->
      myOnePager.hashHasChange('horaire')
      mySchedule.slideTo(day)
    )
    
    @.get(/\#\/horaire\/(mercredi|jeudi|vendredi)\/([a-zA-Z0-9\-]+)\/*$/, (cx, day, conf) ->
      myOnePager.hashHasChange('horaire')
    )

  )
  router.debug = true
  router.run()
  myOnePager.animatWhenSliding = yes

  # StickyHeader {{{
  stickyHeader = ( ->
    header = $('nav[role="navigation"]')
    headerOffsetTop = header.offset().top
    viewport        = $(window)

    viewport.scroll( () ->
      if (headerOffsetTop - viewport.scrollTop()) > 0
        header.removeClass('sticky')
      else
        header.addClass('sticky')
    )   
  )()
  #}}}


              
