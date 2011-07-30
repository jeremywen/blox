require 'sinatra'
require 'haml'
require 'uuid'
require "sinatra/reloader" if development?

configure do
  mime_type :wav, 'audio/wav'
end

get "/*.wav" do |file|
  puts "file = "+file
  send_file file+'.wav', :type => :wav
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

  success = system("beats",input_file_name,output_file_name)  
  output_file_name
end

get "/:times/?" do 
  x = params[:times].to_i
  if x > max_blocks()
    default_blocks()
  end
  @blocks = gen_blocks(x)
  haml :beatblox
end

get "/?" do
  default_blocks()
end


#######################################
# Helpers
#######################################
helpers do

  def max_blocks()
    1300
  end
  
  def default_blocks()
    redirect to("/#{max_blocks()}")
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
