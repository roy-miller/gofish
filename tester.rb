require 'timeout'

@condition = false
def main_method
  puts "running main"
  Thread.start { timer }
  puts "this should be right after started timer"
  sleep 3
end
def timer
  begin
    puts "starting timer"
    Timeout::timeout(1) {
      puts "started timer"
      until @condition
      end
    }
  rescue Timeout::Error => e
    puts "got an error, calling something else"
    do_something
  end
end

def do_something
  puts "did something"
end
main_method
