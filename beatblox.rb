#######################################################################################
# IDEAS
#
#   allow full songs, not just one repeated pattern
#   synthesize pleasant sounds
#   randomly synthesize sounds
#   convert wav to mp3
#   visual waveform gem http://rubygems.org/gems/waveform
#######################################################################################

require 'sinatra'
require 'haml'
require 'uuid'
require "sinatra/reloader" if development?

###############################################################
# Settings
###############################################################

set :pattern_count, 4
set :rows_per_pattern, 4
set :chars_per_rows, 16
set :max_bpm, 200
set :max_blox, 1300
set :generated, File.join(File.dirname(__FILE__),'public','generated')
set :input_wavs, Dir["input-wavs/**/*.wav"]  

configure do
  mime_type :wav, 'audio/wav'
end

###############################################################
# Routes
###############################################################

get "/download/*.wav" do |file|
  send_file File.join(settings.generated , file + '.wav'), :type => "application/x-download"
end

get "/download/*.beat" do |file|
  send_file File.join(settings.generated , file + '.beat'), :type => "application/x-download"
end

get "/*.wav" do |file|
  send_file File.join(settings.generated , file + '.wav'), :type => :wav
end

post  "/get-audio" do
  request.body.rewind  # in case someone already read it
  pattern_rows = request.body.read.split(" ")
  
  uuid = UUID.new.generate
  input_beat = File.join(settings.generated, uuid + '.beat')
  output_wav = File.join(settings.generated, uuid + '.wav')    
  
  tempo = pattern_rows[0]#first element is the tempo
  pattern_rows = pattern_rows.drop(1)#remove tempo from rows
  beat_file(tempo, pattern_rows,input_beat)
  
  puts "input_beat = "+input_beat
  puts "output_wav = "+output_wav
  puts "pattern_rows = "+pattern_rows.to_s
  puts "settings.input_wavs = "+settings.input_wavs.to_s
	
  success = system("beats",input_beat, output_wav)  
  if success 
    puts "success! " + output_wav
  end
  
  File.basename(output_wav)
end

get "/?" do
  @blocks = gen_blocks(settings.max_blox)
  haml :beatblox
end


###############################################################
# Helpers
###############################################################
helpers do

  def beat_file(tempo,pattern_rows,input_beat)
    File.open(input_beat, 'w') do |f|  
    f.puts "Song: \n"
    f.puts "  Tempo: #{tempo} \n"
    f.puts "  Flow: \n"
    f.puts "    - Pattern1:  x#{settings.pattern_count} \n"
    f.puts "Pattern1: \n"
    pattern_rows.each{|row|
	  rnd_wav = settings.input_wavs[rand(settings.input_wavs.size())]
      f.puts "  - ../../#{rnd_wav}:  #{row.strip} \n"
    }
  end  


  end
  
  def gen_blocks(x)
    x = [x,settings.max_blox].min	
    blocks = []
    chars = ['X','.']
    x.times {
      block = []
	  block << "#{rand(settings.max_bpm)}"	  
      settings.rows_per_pattern.times {
	    row = ""
        settings.chars_per_rows.times{
	      row+=chars[rand(2)]
	    }
        block << "#{row}"
      }
	  blocks << block
	}
    blocks
  end
  
end
