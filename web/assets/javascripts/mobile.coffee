
if $('body.schedule')?
  activeRoom = $('.room.active')
  $('#schedule .overflow').height(activeRoom.height())

if $('body.section-location-and-infos')? && CustomGmap?
  myGmap = new CustomGmap('#gmap')

$('.next').click ->
  initSlide(1)

$('.previous').click ->
  initSlide(-1)

initSlide = (direction) ->
  activeRoom = $('.room.active').attr 'id'
  index = activeRoom.index('.container')

  console?.log activeRoom
  # are we at the end? if yes, set the left to 0% if not, increment the current value of 25%

