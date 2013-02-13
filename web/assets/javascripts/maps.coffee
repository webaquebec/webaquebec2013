###
# Class Gmap {{{
###
class window.CustomGmap
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
    isMobile = if $('body').hasClass 'mobile' then true else false

    gMapOptions =
      zoom              : 16
      center            : coord
      mapTypeControl    : false
      streetViewControl : false
      panControl        : false
      scrollwheel       : false
      mapTypeId         : google.maps.MapTypeId.ROADMAP

    if isMobile
      gMapOptions.draggable = false

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
class window.CustomInfoWindow
  constructor: (map, opts) ->

    @position   = opts.coord
    @alwaysOpen = opts.alwaysOpen
    @map        = map

    closeBtn = if !@alwaysOpen then "<span class=\"closeBtn\">×</span>" else ""
    isMobile = if $('body').hasClass 'mobile' then true else false

    if !isMobile
      wrap = "<div class=\"customInfoWindow\">"
    else
      wrap = "<div class=\"customInfoWindow mobile\">"

    wrap += "
      #{closeBtn}
      <div class=\"padding\">
        <span class=\"address\">
          #{opts.content}
        </span>"

    if !isMobile
      wrap += "<img src=\"#{opts.image}\" />"

    wrap += "</div>"

    if !isMobile
      wrap += "<span class=\"shadow\"></span>"

    wrap += "</div>"

    @wrap = $(wrap)
    @setMap(@map)
    @isVisible = true
    @wrap.find('.closeBtn').on('click', =>
      console?.log "click to close"
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