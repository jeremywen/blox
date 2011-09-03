#######################################################################################
# NOTES
#   mono files are faster
#
# IDEAS
#
#   allow full songs, not just one repeated pattern
#   synthesize pleasant sounds
#   randomly synthesize sounds
#   convert wav to mp3
#   visual waveform gem http://rubygems.org/gems/waveform
#
#   geolocation
#     read logs in to find all unique ip addresses
#     find them on a map
#     map them on a google map

#######################################################################################

require "sinatra"
require "haml"
require "uuid"
require "beats"
require "optparse"
require "yaml"
require "wavefile"
require "audioengine"
require "audioutils"
require "beatswavefile"
require "kit"
require "pattern"
require "song"
require "songoptimizer"
require "songparser"
require "track"
require "geocoder"
require "sinatra/reloader" if development?

#######################################################################################
# Settings
#######################################################################################
set :pattern_count, 1
set :pattern_play_count, 2
set :rows_per_pattern, 4
set :chars_per_rows, 16
set :min_bpm, 20
set :max_bpm, 250
set :max_blox, 130
set :input_wavs, Dir["input-wavs/**/*.wav"]  
set :possible_chars, ["X","."]

configure :production do
  Dir.mkdir("logs") unless File.exist?("logs")

  # stdout and stderr to a file during production
  t = Time.now.strftime("%m_%d_%Y")
  $\="\r\n"
  $stdout.reopen("logs/#{t}.log", "a+")
  $stdout.sync = true
  $stderr.reopen($stdout)
end

configure :development do
end

configure do
  puts "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]"
  puts "[][][][][][][][] starting blox server...  [][][][][][][][][]"
  puts "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]"
  puts "#{time_now = Time.now}"
  puts "Deleting old files generated..."
  SECONDS_PER_DAY = 60 * 60 * 24
  kept_count = 0
  delete_count = 0
  Dir["public/generated/*.*"].each { |file|
    if time_now - File.mtime(file) > SECONDS_PER_DAY
	  File.delete(file)
	  delete_count+=1
	else
	  kept_count+=1
	end
  }
  puts "Kept #{kept_count} files.  Deleted #{delete_count} files older than one day."
  puts "settings.input_wavs.size() = " + settings.input_wavs.size().to_s
  puts "settings.pattern_count = " + settings.pattern_count.to_s
  puts "settings.pattern_play_count = " + settings.pattern_play_count.to_s
  puts "settings.rows_per_pattern = " + settings.rows_per_pattern.to_s
  puts "settings.chars_per_rows = " + settings.chars_per_rows.to_s
  puts "settings.min_bpm = " + settings.min_bpm.to_s
  puts "settings.max_bpm = " + settings.max_bpm.to_s
  puts "settings.max_blox = " + settings.max_blox.to_s

  puts "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]"
  puts "[][][][][][][][][] omg blox started!  [][][][][][][][][][][]"
  puts "[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]"
end

#######################################################################################
# Routes
#######################################################################################

get "/geo" do
  #
end

get "/one" do
  block = []
  add_pattern_only(block)
  file_name = make_wav(rand_tempo(),block)
  redirect "/download/#{file_name}"
end

get "/logs" do
  send_file "logs/output.log", :type=> "text/plain"
end

get "/download/*.*" do |file,ext|
  file = "public/generated/#{file}.#{ext}"
  puts "ROUTE: download - exists=#{File.exists?(file)} - file=#{file}"
  send_file file, :type => "application/x-download"
end

get "/*.wav" do |file|
  file = "public/generated/#{file}.wav"
  puts "ROUTE: play - exists=#{File.exists?(file)} - file=#{file}"
  send_file file, :type => "audio/wav"
end

post  "/get-audio" do
  request.body.rewind  # in case someone already read it
  pattern_rows = request.body.read.split(" ")

  tempo = pattern_rows[0]#first element is the tempo
  pattern_rows = pattern_rows.drop(1)#remove tempo from rows

  make_wav(tempo, pattern_rows)
end

get "/?" do
  @blocks = gen_blocks(settings.max_blox)
  haml :beatblox
end

error do
  e = request.env["sinatra.error"]
  puts e.to_s
  puts e.backtrace.join("\n")
  "Application Error!"
end

#######################################################################################
# Helpers
#######################################################################################
helpers do

  def make_wav(tempo, pattern_rows)  
    uuid = UUID.new.generate
    input_beat = "public/generated/#{uuid}.beat"
    output_wav = "public/generated/#{uuid}.wav"
    
    beat_file(tempo, pattern_rows, input_beat)
    
    puts "  tempo = "+tempo.to_s
    puts "  pattern_rows = "+pattern_rows.to_s
    puts "  input_beat = "+input_beat.to_s
    puts "  output_wav = "+output_wav.to_s
      
    beats_start_time = Time.now  
    beats = Beats.new(input_beat, output_wav,{})
    output = beats.run()
    duration = output[:duration]
    puts "#{duration[:minutes]}:#{duration[:seconds].to_s.rjust(2, '0')} of audio written in #{Time.now - beats_start_time} seconds."
    beats = nil
    
    if File.exists?(output_wav)
      puts "success :-) " + output_wav
    else
      puts "fail :-( " + output_wav
    end
    
    File.basename(output_wav)
  end

  def beat_file(tempo,pattern_rows,input_beat)
    File.open(input_beat, "w") do |f|  
      f.puts "Song: \n"
      f.puts "  Tempo: #{tempo} \n"
      
      f.puts "  Flow: \n"    
      settings.pattern_count.times {|x|
        f.puts "    - p#{x}:  x#{settings.pattern_play_count} \n"
      }
      
      samples_per_kit = settings.pattern_count * settings.rows_per_pattern
      kit_parts = []
      f.puts "  Kit: \n"    
      samples_per_kit.times {|x|
        kit_part = "k#{x}"
        f.puts "    - #{kit_part}:  ../../#{settings.input_wavs[rand(settings.input_wavs.size())]} \n"
        kit_parts.push(kit_part)
      }
      
      settings.pattern_count.times {|x|
        f.puts "p#{x}: \n"
        pattern_rows.each{|row|
          f.puts "  - #{kit_parts.pop()}:  #{row.strip} \n"
        }
      }
    end
  end
  
  def gen_blocks(x)
    x = [x,settings.max_blox].min    
    blocks = []
    x.times {
      block = []
      block << "#{rand_tempo()}"      
      add_pattern_only(block)
      blocks << block
    }
    blocks
  end
  
  def add_pattern_only(block)
    settings.rows_per_pattern.times {
      row = ""
      settings.chars_per_rows.times{
        row += settings.possible_chars[rand(2)]
      }
      block << "#{row}"
    }
  end
  
  def rand_tempo()
    settings.min_bpm + rand(settings.max_bpm - settings.min_bpm)
  end
  
end
