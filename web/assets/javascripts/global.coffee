###
Author: Louis-Philippe Dumas, @louisdumas, github: lpdumas
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

App.fbButton = '<div class="fb-like-template" data-href=" " data-send="false" data-layout="button_count" data-show-faces="false"></div>'
App.twButton = '<a href="https://twitter.com/share" class="twitter-share-button-template" data-url=" ">Tweet</a>'
  
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
    
    if @slides.length > 1
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
    @overFlowWrapper     = $('#schedule .wrapper')
    @navElement          = $('#schedule-nav a')
    @slides              = @slideWrapper.find('.slide')
    @slideWrapperHeight  = @slideWrapper.outerHeight()
    @currentSlide        = @slides.filter(".active")
    @currentIndex        = @slides.index(@currentSlide)
    @openBtn             = $('#schedule #open-shedule a')
    @confLinks           = $('#schedule a.white')
    @confThumbParents    = $('#schedule .conference')  
    @body                = $('body')
    @sideTimeLineSpan    = $('#time-zone span')
    @shareButtonWrap     = $('.share-btn')
    @startingHeight      = 500
    @wrapConfContent     = null
    @confScrollbar       = null
    @loadingGIF          = null
    @confIsOpen          = false 
    
    template            = '''
    <section id="conf-desc">
      <span class="loading"><img src="/assets/images/interface/loading.gif" /></span>
      <div class="wrap-content"></div>
    </section>
    <span id="overlay"></span>
    '''
    
    if !$('#conf-desc').length
      @body.append(template)
    
    @wrapConfContent = $('#conf-desc .wrap-content')
    @loadingGIF      = $('#conf-desc .loading')
      
    @overlay = $('#overlay')
      
    @confLinks.each( ->
      this_    = $(this)
      newHref  = this_.attr('href').replace('/horaire', '#/horaire')
      this_.attr('href', newHref)
    )
    
    @confLinks.click( ->
      this_ = $(this)
      if window.location.hash is this_.attr('href')
        window.router.refresh()
    )
    
    # @navElement.eq(@currentIndex).addClass('active')

    @openBtn.click( =>
      if @openBtn.hasClass('active')
        @close()
      else
        @open()
    )
    
    @overlay.click( =>
      @closeConf()
    )
    
    onOpen  = if opts? && opts.onOpen? then opts.onOpen else () ->
    onClose = if opts? && opts.onClose? then opts.onClose else () ->
      
    $(window).on('resize', () =>
      if @confScrollbar && @wrapConfContent
        # Redifining conference description wrap height
        newHeigh = @wrapConfContent.outerHeight() - ( @wrapConfContent.find('figure').outerHeight() + 125 ) - 56
        @wrapConfContent.find('.viewport').css({ height : newHeigh})
        @confScrollbar.tinyscrollbar_update()
    )
    
    @openBtn.hide()
    @open()
    
    if @currentIndex != 0
      @slideTo(@currentSlide.attr("id"))
    
    $(@).bind('onOpen', onOpen)
    $(@).bind('onClose', onClose)
    
  showConf: (id) =>
    link             = @confLinks.filter('[data-id="'+id+'"]')
    url              = link.attr('href').replace('#', '')
    @confIsOpen      = true
    @confThumbParent = link.closest('.conference')

    @confThumbParents.removeClass('active')
    @confThumbParent.addClass('active')
    if !@body.hasClass('lock')
      @body.addClass('lock')
    
    request = $.ajax(
      url: url
      type: "GET"
      dataType: "html"
      data: { ajax : 1 }
    )
    
    request.done((response) =>

      @wrapConfContent.html(response)
      
      # Redifining conference description wrap height
      newHeigh = @wrapConfContent.outerHeight() - ( @wrapConfContent.find('figure').outerHeight() + 125 ) - 56
      @wrapConfContent.find('.viewport').css({ height : newHeigh})
      
      @confScrollbar = $('#scrollbar1')

      @confScrollbar.tinyscrollbar()
      
      
      t = setTimeout(()=>
        @loadingGIF.addClass('fadding')
        # Time for the css transition to end
        t1 = setTimeout(()=>
          @loadingGIF.removeClass('fadding').addClass('off')
          
          # Setting up sharing buttons
          shareURL = $('[data-shareURL]').attr('data-shareURL')
          fb       = $(App.fbButton)
          tw       = $(App.twButton)
          
          fb.addClass('fb-like').attr('data-href', shareURL)
          tw.addClass('twitter-share-button').attr('data-url', shareURL)
          
          @shareButtonWrap.html('').append(fb, tw)
          @shareButtonWrap.show()
          
          FB.XFBML.parse()
          twttr.widgets.load()
          
        , 200)
      , 400)
    )

    request.fail((response) =>)

  closeConf: ->
    @confIsOpen = false
    @confThumbParents.removeClass('active')
    @shareButtonWrap.hide()
    @body.removeClass('lock')
    t = setTimeout(()=>
      @loadingGIF.removeClass('off')
    , 400)
    
  slideTo: (id) ->
    target = @slides.filter("##{id}")
    posX   = target.position().left
    
    @navElement.removeClass('active')
    
    $('[data-ref="'+id+'"]').addClass('active')
    
    @sideTimeLineSpan.removeClass('active')
    @sideTimeLineSpan.filter("##{id}-lines").addClass('active')
    @slideWrapper.css({ 'left' : -posX})
    @currentSlide = target
    if @currentSlide.attr('id') isnt 'mercredi'
      @overFlowWrapper.css(
        'height'     : @slideWrapperHeight
        'overflow-y' : 'hidden'
      )
    else
      @overFlowWrapper.css(
        'height'     : 800
        'overflow-y' : 'hidden'
      )
      
  open: =>
    $(@).trigger('onOpen')
    @openBtn.html('Réduire')
    @openBtn.addClass('active')
    
    if @currentSlide.attr('id') isnt 'mercredi'
      @overFlowWrapper.css(
        'height'     : @slideWrapperHeight
        'overflow-y' : 'hidden'
      )
    else
      @overFlowWrapper.css(
        'height'     : 800
        'overflow-y' : 'hidden'
      )
    
  close: =>
    $(@).trigger('onClose')
    @openBtn.html('Tout afficher')
    @openBtn.removeClass('active')
    t = setTimeout( =>
      @overFlowWrapper.css(
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
    @didScroll     = false
    @isAnimated    = false
    @currentPage   = 0
    @navWrap       = $('nav[role="navigation"]')
    @nav           = @navWrap.find('a')
    @sectionsWrapp = $('#one-pager')
    @sections      = $('[data-section]')
    @navHeight     = @navWrap.outerHeight()
    @navOffset     = @navHeight
    @pagesOffset   = {}
    
    @resetSectionsOffset()
    @animateWhenSliding = no
    
    $(window).on('scroll', =>
      @didScroll = true;
    )
    
    @nav.click( ->
      if window.location.hash is $(this).attr('href')
        window.router.refresh()
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

    if window.addEventListener?
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
        
  slideTo: (target) ->
    target          = @sections.filter(target)
    targetId        = target.attr('id')
    moreOffsets     = moreOffsets || 0
    targetScrollTop = target.offset().top - @navOffset - moreOffsets
    targetLink      = $("a[href='#/#{targetId}/']")
    @isAnimated = true
    @currentPage = @getPageIndex(targetId)
    @setActiveMenu(targetLink)
    
    targetScrollTop = if targetScrollTop <= 0 then 0 else targetScrollTop
    if @animateWhenSliding
      $('body, html').stop().animate({'scrollTop' : targetScrollTop}, 650, $.bez([0.80, 0, 0.20, 1.0]), () =>
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
    @slideTo(newhash)
  
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
  settings: 
    markers: [{
      coord: [46.817682, -71.2065922],
      isWaq: true,
      content: '''
      <a href="https://maps.google.ca/maps?q=ESPACE+400E+BELL+100,+QUAI+SAINT-ANDR%C3%89+QU%C3%89BEC,+QC&hl=fr&ie=UTF8&hq=ESPACE+400E+BELL+100,+QUAI+SAINT-ANDR%C3%89+QU%C3%89BEC,+QC&t=m&z=16&iwloc=A" target="_blank">
      Espace 400e Bell<br>
      100, Quai Saint-André<br>
      Québec, QC
      </a>
      ''',
      image: "/assets/images/png/logo-waq-gray.png"
    },{
      coord: [46.815988, -71.203190],
      icon: 
        src    : "/assets/images/interface/germain_dominion.png"
        width  : 43
        height : 56
      shadow:
        src    : "/assets/images/interface/germain-dominion-shadow.png"
        width  : 68
        height : 55
      content: '''
      <a href="https://maps.google.ca/maps?q=ESPACE+400E+BELL+100,+QUAI+SAINT-ANDR%C3%89+QU%C3%89BEC,+QC&hl=fr&ie=UTF8&hq=ESPACE+400E+BELL+100,+QUAI+SAINT-ANDR%C3%89+QU%C3%89BEC,+QC&t=m&z=16&iwloc=A" target="_blank">
      Hôtel Le Germain-Dominion<br>126 Rue Saint-Pierre</a><br>
      <span class="small">1-888-833-5253<br><a href="mailto:reservations@germaindominion.com">reservations@germaindominion.com</a><br>
      Mentionnez le groupe : Web à Québec</span>
      ''',
      image: "/assets/images/interface/germain_dominion_full.png"
    }]
  constructor: (elementId) ->
    coord = new google.maps.LatLng(46.817682, -71.2065922)
    gMapOptions = 
      zoom              : 16
      center            : coord
      mapTypeControl    : false
      streetViewControl : false
      panControl        : false
      scrollwheel       : false
      mapTypeId         : google.maps.MapTypeId.ROADMAP
      
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
    # @infoWindow = 
    @addMarker()
    
  addMarker: ->
    @marker = [];
    for key, marker of @settings.markers
      markerCoord  = new google.maps.LatLng(marker["coord"][0], marker["coord"][1])
      @marker[key] = {}

      # InfoWindow
      opts =
        coord      : markerCoord
        content    : marker.content
        image      : marker.image,
        alwaysOpen : marker.isWaq?
        
      @marker[key]["infoWindow"] = new CustomInfoWindow(@map, opts)
      
      # Icon
      if marker.icon?
        iconWidth            = marker.icon.width
        iconHeight           = marker.icon.height
        iconmid              = [(iconWidth / 2), (iconHeight / 2)]
        @marker[key]["icon"] = new google.maps.MarkerImage(marker.icon.src, null, null, new google.maps.Point(iconmid[0],iconmid[1]), new google.maps.Size(iconWidth, iconHeight))
        
        if marker.shadow?
          shadowWidth            = marker.shadow.width
          shadowHeight           = marker.shadow.height
          shadowmid              = [(shadowWidth / 2), (shadowHeight / 2)]
          @marker[key]["shadow"] = new google.maps.MarkerImage(marker.shadow.src, null, null, new google.maps.Point(shadowmid[0],shadowmid[1]), new google.maps.Size(shadowWidth, shadowHeight))
        
        @marker[key]["marker"] = new google.maps.Marker
          position: markerCoord,
          map: @map
          icon: @marker[key]["icon"]
          shadow: if @marker[key]["shadow"]? then @marker[key]["shadow"] else false
          visible: true
          draggable: false
          cursor: "pointer"
        
        google.maps.event.addListener(@marker[key]["marker"], 'click', (e) =>
          if @currentOpenedInfoWindow?
            @currentOpenedInfoWindow.close()
                  
          @marker[key]["infoWindow"].open()
          @currentOpenedInfoWindow = @marker[key]["infoWindow"]
        )
        
        
      # if marker.isWaq?
        # console?.log "bobo"
        
###
# }}}
###

###
# Class CustomInfoWindow {{{
###
class CustomInfoWindow
  constructor: (map, opts) ->
    
    @position   = opts.coord
    @alwaysOpen = opts.alwaysOpen
    @map        = map
    
    closeBtn = if !@alwaysOpen then "<span class=\"closeBtn\">×</span>" else ""
    wrap = "
    <div class=\"customInfoWindow\">
      #{closeBtn}
      <div class=\"padding\">
        <span class=\"address\">
          #{opts.content}
        </span>
          <img src=\"#{opts.image}\" />
      </div>
      <span class=\"shadow\"></span>
    </div>
    "
    @wrap = $(wrap)
    @setMap(@map)
    @isVisible = true
    @wrap.find('.closeBtn').on('click', =>
      # console?.log "click to close"
      @close()
    )
  CustomInfoWindow:: = new google.maps.OverlayView()
  
  onAdd: ->
    @wrap.css(
      opacity: if @alwaysOpen then 1 else 0
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
  
  open: ->
    @wrap.show()

  close: ->
    @wrap.hide()
    
  draw: ->
    overlayProjection = @getProjection()
    pos = overlayProjection.fromLatLngToDivPixel(@position)
    @oX = pos.x - @wrap.outerWidth() / 2
    @oY = pos.y - @wrap.outerHeight() - 30
    
    wrapImg       = @wrap.find('img')
    wrapImgHeight = wrapImg.height()
    @wrap.find('img').css
      'top': '50%' 
      'margin-top': -(wrapImgHeight/2)
        
    @wrap.css
      left: @oX
      top: @oY
      opacity: 1
      display: if @alwaysOpen then 'block' else 'none'
    
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
  
  # Team captions width hack/fix
  $('#team [itemprop="name"]').each ->
    $this       = $(this)
    newRightPos =  $this.outerWidth()/2

    $this.css
      right : -newRightPos
    
  
  #############
  #-- ROUTER --#
  #############
  window.router = $.sammy(() ->
    
    @.get(/\#\/(accueil|horaire|lieu-et-infos|partenaires|a-propos|nous-joindre)\/*$/, (cx, section) ->
      myOnePager.hashHasChange(section)
      if mySchedule.confIsOpen
        mySchedule.closeConf()
    )
    
    @.get(/\#\/horaire\/(.*)\/$/, (cx, day) ->
      if myOnePager.windowInitialHash
        myOnePager.hashHasChange('horaire')
        myOnePager.windowInitialHash = null
        
      if mySchedule.confIsOpen
        mySchedule.closeConf()
        
        
      mySchedule.slideTo(day)
    )
    
    @.get(/\#\/horaire\/(.*)\/(.*)-([0-9]+)\/*$/, (cx, day, slug, id) ->
      
      # no horizontal animation when we click on a conf link
      # after the initial load
      if myOnePager.windowInitialHash
        myOnePager.hashHasChange('horaire')
        myOnePager.windowInitialHash = null
        
      mySchedule.slideTo(day)
      mySchedule.showConf(id)
    )
  )
  
  router.debug = false
  myOnePager.windowInitialHash = window.location.hash || null
  router.run()
  myOnePager.animateWhenSliding = yes

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


              
