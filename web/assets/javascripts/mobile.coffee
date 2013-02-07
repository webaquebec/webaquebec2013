
if $('body.schedule')?
  activeRoom = $('.room.active')
  $('#schedule .overflow').height(activeRoom.height())


$('.next').click ->
  slide(1)

$('.previous').click ->
  slide(-1)

slide = (direction) ->
  console?.log 'foobar', direction