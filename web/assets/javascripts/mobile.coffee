
slide = (direction) ->
  roomLength  = $('.day.active .room').length
  currentRoom = $('.day.active .room').index($('.active-room'))
  nextRoom    = currentRoom + direction

  if nextRoom == roomLength
    nextRoom = 0

  if currentRoom == 0 && direction == -1
    nextRoom = roomLength - 1

  newLeft = '-' + nextRoom + '00'

  $('.day.active .active-room').removeClass('active-room')
  $('.day.active .room').eq(nextRoom).addClass('active-room')
  $('#schedule .overflow').animate({'height': $('.day.active .room.active-room').height() })

  $('#schedule .container').css('left', newLeft + '%')

  return

changeActiveDay = (e) ->
  targetDay = e.attr 'data-ref'

  $('#schedule-nav li').removeClass('active')
  e.parent().addClass('active')

  $('.day').hide().removeClass('active')
  $('#' + targetDay).show().addClass('active')

  $('.room.active-room').removeClass('active-room')
  $('#' + targetDay).find('.room:eq(0)').addClass('active-room')

  $('#schedule .container').css('left', 0)
  $('#schedule .overflow').animate({'height': $('#' + targetDay).find('.active-room').height() })


if $('body.schedule')?
  if $('.day.active').length == 0
    $('#schedule-nav li:eq(0)').addClass('active')
    $('.day:eq(0)').addClass('active')

  $('.day.active .room:eq(0)').addClass('active-room')

  activeRoom = $('.day.active .room.active-room')
  $('#schedule .overflow').height(activeRoom.height())

  $('.next').click -> slide(1)
  $('.previous').click -> slide(-1)
  $('#schedule-nav a').click -> changeActiveDay($(this))

if $('body.section-location-and-infos')? && CustomGmap?
  myGmap = new CustomGmap('#gmap')
