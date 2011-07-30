require 'sinatra'
require 'haml'
require 'uuid'
require "sinatra/reloader" if development?

set :wavs, File.join(File.dirname(__FILE__),'public','wavs')

configure do
  mime_type :wav, 'audio/wav'
end

get "/download/*.wav" do |file|
  send_file session.wavs + file + '.wav', :type => "application/x-download"
end

get "/*.wav" do |file|
  send_file session.wavs + file + '.wav', :type => :wav
end

post  "/get-audio" do

  request.body.rewind  # in case someone already read it
  data = request.body.read
  rows = data.split(" ")
  
  uuid = UUID.new.generate
  input_file_name = uuid + '.beat'
  output_file_name = uuid + '.wav'
  
  sounds = Dir["909Kit/*.wav"]
  sounds.each{|s|
    puts "s = "+s
  }
    
  File.open(input_file_name, 'w') do |f|  
    f.puts "Song: \n"
    f.puts "  Tempo: #{rand(300)} \n"
    f.puts "  Flow: \n"
    f.puts "    - Pattern1:  x1 \n"
    f.puts "Pattern1: \n"
    rows.each{|row|
      f.puts "  - #{sounds[rand(sounds.size())]}:  #{row.strip} \n"
    }
  end  

  success = system("beats",input_file_name, session.wavs + output_file_name)  
  output_file_name
end

get "/?" do
  @blocks = gen_blocks(max_blocks())
  haml :beatblox
end


#######################################
# Helpers
#######################################
helpers do

  def max_blocks()
    1300
  end
  
  def gen_blocks(x)
    x = [x,max_blocks()].min	
    blocks = []
    chars = ['X','.']
    x.times {
      block = []
      4.times {
	    row = ""
        16.times{
	      row+=chars[rand(2)]
	    }
        block << "#{row}"
      }
	  blocks << block
	}
    blocks
  end
      
end
