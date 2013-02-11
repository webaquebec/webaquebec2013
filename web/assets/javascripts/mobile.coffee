
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

if $('body.schedule')?
  $('.day.active .room:eq(0.)').addClass('active-room')

  activeRoom = $('.day.active .room.active-room')
  $('#schedule .overflow').height(activeRoom.height())

  $('.next').click ->
    slide(1)

  $('.previous').click ->
    slide(-1)


if $('body.section-location-and-infos')? && CustomGmap?
  myGmap = new CustomGmap('#gmap')
