#!/usr/bin/env ruby
# frozen_string_literal: true

require 'cgi'
require 'base64'
require 'fileutils'
require 'json'

def escape(text)
  CGI.escapeHTML(text)
end

def generate_talk_poster(talk)
  svg_path = File.expand_path('talk.svg', __dir__)
  tmp_svg_path = '/tmp/speaker.svg'
  png_path = File.expand_path("output/#{talk['speaker_name']}.png", __dir__)

  FileUtils.cp(svg_path, tmp_svg_path)

  svg_content = File.read(tmp_svg_path)
  svg_content = svg_content.gsub('{{speaker_name}}', escape(talk['speaker_name'].to_s))
  svg_content = svg_content.gsub('{{speaker_bio}}', escape(talk['speaker_bio'].to_s))
  svg_content = svg_content.gsub('{{title1}}', escape(talk['title1'].to_s))
  svg_content = svg_content.gsub('{{title2}}', escape(talk['title2'].to_s))
  svg_content = svg_content.gsub('{{title3}}', escape(talk['title3'].to_s))
  svg_content = svg_content.gsub('{{title4}}', escape(talk['title4'].to_s))

  speaker_image_path = File.expand_path(talk['speaker_image'], '#{__dir__}/input')
  svg_content = svg_content.gsub('%7B%7Bspeaker_image%7D%7D', speaker_image_path)
  svg_content = svg_content.gsub('{{speaker_image}}', speaker_image_path)
  File.write(tmp_svg_path, svg_content)

  FileUtils.cp(tmp_svg_path, File.expand_path("output/#{talk['speaker_name']}.svg", __dir__))
  system("inkscape #{tmp_svg_path} --export-type=png --export-filename=#{png_path}")
end

def make_talk_posters(event)
  event['talks'].each do |talk|
    puts "Making poster for #{talk['title']}"
    generate_talk_poster(talk)
  end
end

def make_agenda_poster(event)
  variables = {
    '{{talk1}}' => escape(event['talks'][0]['title']),
    '{{talk1_speaker}}' => escape(event['talks'][0]['speaker_name']),
    '{{talk2}}' => escape(event['talks'][1]['title']),
    '{{talk2_speaker}}' => escape(event['talks'][1]['speaker_name']),
    '{{talk3}}' => escape(event['talks'][2]['title']),
    '{{talk3_speaker}}' => escape(event['talks'][2]['speaker_name']),
    '{{talk4}}' => escape(event['talks'][3]['title']),
    '{{talk4_speaker}}' => escape(event['talks'][3]['speaker_name']),
  }
  
  svg_path = File.expand_path('agenda.svg', __dir__)
  tmp_svg_path = '/tmp/agenda.svg'
  png_path = File.expand_path("output/agenda.png", __dir__)

  FileUtils.cp(svg_path, tmp_svg_path)
  svg_content = File.read(tmp_svg_path)

  for key, value in variables
    svg_content = svg_content.gsub(key, value)
  end

  File.write(tmp_svg_path, svg_content)
  FileUtils.cp(tmp_svg_path, File.expand_path("output/agenda.svg", __dir__))
  system("inkscape #{tmp_svg_path} --export-type=png --export-filename=#{png_path}")
end

arg = ARGV[0]
if arg == 'agenda'
  make_agenda_poster(JSON.parse(File.read(File.expand_path('event.json', __dir__))))
elsif arg == 'talks'
  make_talk_posters(JSON.parse(File.read(File.expand_path('event.json', __dir__))))
else
  puts 'Usage: #{$0} [agenda|talks]'
  exit 1
end
