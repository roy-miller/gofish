# require 'timeout'
#
# @condition = false
# def main_method
#   puts "running main"
#   Thread.start { timer }
#   puts "this should be right after started timer"
#   sleep 3
# end
# def timer
#   begin
#     puts "starting timer"
#     Timeout::timeout(1) {
#       puts "started timer"
#       until @condition
#       end
#     }
#   rescue Timeout::Error => e
#     puts "got an error, calling something else"
#     do_something
#   end
# end
#
# def do_something
#   puts "did something"
# end
# main_method

# require "observer"
#
# class Ticker          ### Periodically fetch a stock price.
#   include Observable
#
#   def initialize(symbol)
#     @symbol = symbol
#   end
#
#   def run
#     lastPrice = nil
#     loop do
#       price = Price.fetch(@symbol)
#       print "Current price: #{price}\n"
#       if price != lastPrice
#         changed                 # notify observers
#         lastPrice = price
#         notify_observers(Time.now, price)
#       end
#       sleep 1
#     end
#   end
# end
#
# class Price           ### A mock class to fetch a stock price (60 - 140).
#   def Price.fetch(symbol)
#     60 + rand(80)
#   end
# end
#
# class Warner          ### An abstract observer of Ticker objects.
#   def initialize(ticker, limit)
#     @limit = limit
#     ticker.add_observer(self)
#   end
# end
#
# class WarnLow < Warner
#   def update(time, price)       # callback for observer
#     if price < @limit
#       print "--- #{time.to_s}: Price below #@limit: #{price}\n"
#     end
#   end
# end
#
# class WarnHigh < Warner
#   def update(time, price)       # callback for observer
#     if price > @limit
#       print "+++ #{time.to_s}: Price above #@limit: #{price}\n"
#     end
#   end
# end
#
# ticker = Ticker.new("MSFT")
# WarnLow.new(ticker, 80)
# WarnHigh.new(ticker, 120)
# ticker.run

require 'pry'

class Thing
  def foo
    @foo
  end

  def foo=(value)
    @foo = value
  end

  def change_foo
    foo = foo + 1
  end
end

x = Thing.new
binding.pry
x.foo = 1
x.change_foo
puts x.foo
