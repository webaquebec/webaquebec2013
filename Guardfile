guard 'shell', :all_on_start => true do
  watch(/^web\/assets\/stylesheets\/.+\.(scss|sass)/) do |match|
    puts match[0] + " changed at " + Time.now.strftime("%H:%M:%S") +". Re-generating CSS from SASS."
    `compass compile assets/ -s compressed`
  end
  
  watch(/^web\/assets\/javascripts\/.+\.coffee/) do |match|
    puts match[0] + " changed at " + Time.now.strftime("%H:%M:%S") +". Re-generating JS from CoffeeScript"
    `coffee -c -o assets/javascripts assets/javascripts/`
  end
end