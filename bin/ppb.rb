#!/usr/bin/ruby

require 'json'

if File.file? 'appinfo.json'
  json = JSON.parse(File.read('appinfo.json'))
  # Ensure resource is always defined
  if json['resources'].nil?
    json['resources'] = {'media' => []}
  else
    json['resources']['media'] = []
  end
  resources = json['resources']['media']
  # Remove all previous resources
  resources.clear
  if Dir.exist? 'resources/images'
    platformFiles = []
    supportedFormat = ['.raw', '.png', '.pbi', '.pbi8', '.png-trans']
    Dir.foreach('resources/images') do |filename|
      if File.file? "resources/images/#{filename}"
        ext = File.extname(filename)
        # Generate only supported image formats
        if supportedFormat.include? ext
          # Manage pebble platform image files
          if filename.include? '~'
            filename = filename.sub(/(\w)~.+/, '\1') + ext
          end
          if platformFiles.include? filename
            next
          end
          platformFiles << filename
          resources << {
              type: ext[1..-1],
              file: "images/#{filename}",
              name: "IMAGE_#{filename[0..-(ext.length + 1)].gsub(/\W/i, '_').upcase}"
          }
        end
      end
    end
  end

  if Dir.exist? 'resources/fonts'
    # Ensure fonts is always defined
    fonts = if File.file? 'resources/fonts/ppbinfo.json'
            JSON.parse(File.read('resources/fonts/ppbinfo.json'))
          else
            {}
          end
    Dir.foreach('resources/fonts') do |filename|
      if File.file? "resources/fonts/#{filename}"
        # Avoid configuration file
        unless filename.eql? 'ppbinfo.json'
          sizes = if fonts[filename].nil?
                    [14]
                  else
                    fonts[filename]
                  end
          ext = File.extname(filename)
          # Magic code to remove extension later even if it's empty
          ext << ' '
          sizes.each do |size|
            resources << {
                characterRegex: '[ -~]',
                type: 'font',
                file: "fonts/#{filename}",
                name: "FONT_#{filename[0..-ext.length].gsub(/\W/i, '_').upcase}_#{size}"
            }
          end
        end
      end
    end
  end

  File.write('appinfo.json', JSON.pretty_generate(json))
end
