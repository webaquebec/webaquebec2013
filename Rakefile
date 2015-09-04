require 'open-uri'

desc "Restore ajax version of schedule"
task :restore_ajax do
  Dir.glob('horaire/**/*.html').each do |page|
    # Full layout version
    open("http://webaquebec2013.herokuapp.com/#{page.sub(/.html\Z/, '')}") do |response|
      File.write(page, response.read)
    end

    # Ajax version
    open("http://webaquebec2013.herokuapp.com/#{page.sub(/.html\Z/, '')}?ajax=1") do |response|
      File.write("#{page.sub(/.html\Z/, '.ajax.html')}", response.read)
    end
  end
end