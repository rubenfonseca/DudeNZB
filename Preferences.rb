#
#  Preferences.rb
#  DudeNZB
#
#  Created by Ruben Fonseca on 7/29/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

class Preferences
  attr_accessor :username, :password, :hostname, :port
  
  def initialize
    @_defaults = NSUserDefaults.standardUserDefaults
    dict = {
      'hostname' => 'localhost',
      'port'     => 8760
    }
    @_defaults.registerDefaults(dict)
    
    self.username = @_defaults.objectForKey('username')
    self.password = @_defaults.objectForKey('password')
    self.hostname = @_defaults.objectForKey('hostname')
    self.port     = @_defaults.objectForKey('port')
  end
  
  def commit
    @_defaults.setObject(self.hostname, forKey:'hostname')
    @_defaults.setObject(self.port,     forKey:'port')
    @_defaults.setObject(self.username, forKey:'username')
    @_defaults.setObject(self.password, forKey:'password')
    @_defaults.synchronize
  end
end
