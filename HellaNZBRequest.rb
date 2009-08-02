#
#  HellaNZBRequest.rb
#  DudeNZB
#
#  Created by Ruben Fonseca on 7/29/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

require 'uri'

class HellaNZBRequest
  attr_accessor :block
  
  def initialize
    @preferences = Preferences.new
  end
  
  def self.status(&block)
    h = HellaNZBRequest.new
    h.block = block
    h.call('status')
  end
  
  def self.pause
    h = HellaNZBRequest.new
    h.call('pause')
  end
  
  def self.continue
    h = HellaNZBRequest.new
    h.call('continue')
  end
  
  def self.set_max_rate(rate)
    h = HellaNZBRequest.new
    h.call('maxrate', rate)
  end
  
  def self.dequeue(id)
    h = HellaNZBRequest.new
    h.call('dequeue', id)
  end
  
  def self.enqueue(name, contents)
    h = HellaNZBRequest.new
    h.call('enqueue', name, contents)
  end
  
  def request(request, didReceiveResponse:response)
    if response.isFault.zero?
      @block.call(response.object) if @block
    else
      NSLog "Fault Code #{response.faultCode.stringValue}"
      NSLog "Fault String #{response.faultString}"
    end
    
    # NSLog "Response body: #{response.body}"
  end
  
  def call(method, *args)
    url = NSURL.URLWithString "http://#{@preferences.username}:#{@preferences.password}@#{@preferences.hostname}:#{@preferences.port}/"
    request = XMLRPCRequest.alloc.initWithURL(url)
    manager = XMLRPCConnectionManager.sharedManager
    
    request.setMethod(method, withParameters:args)
    NSLog "Request body: #{request.body}"
    
    manager.spawnConnectionWithXMLRPCRequest(request, delegate:self)
  end
end
