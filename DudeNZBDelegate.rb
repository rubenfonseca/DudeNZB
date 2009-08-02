#
#  DudeNZBDelegate.rb
#  DudeNZB
#
#  Created by Ruben Fonseca on 7/28/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#
class DudeNZBDelegate
  attr_accessor :credentials_window, :main_window
  attr_accessor :hostname_field, :port_field, :username_field, :password_field

  attr_accessor :log_window, :total_dl, :uptime, :queue_table_view
  attr_accessor :current_nzb, :percent_complete, :complete_label
  attr_accessor :rate, :pause
  attr_accessor :max_rate_slider, :max_rate
  attr_accessor :version, :total_files, :total_nzbs, :total_segments

  def applicationDidFinishLaunching(notification)
    @preferences = Preferences.new

    self.hostname_field.stringValue = @preferences.hostname
    self.port_field.stringValue = @preferences.port
    self.username_field.stringValue = @preferences.username || ''
    self.password_field.stringValue = @preferences.password || ''

    NSApp.beginSheet(credentials_window,
      modalForWindow:main_window,
      modalDelegate:nil,
      didEndSelector:nil,
      contextInfo:nil)
  end

  def submitCredentials(sender)
    @preferences.hostname = hostname_field.stringValue
    @preferences.port     = port_field.stringValue
    @preferences.username = username_field.stringValue
    @preferences.password = password_field.stringValue
    @preferences.commit

    NSApp.endSheet(credentials_window)
    credentials_window.orderOut(sender)
    
    @timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:'tick', userInfo:nil, repeats:true)
  end

  def hideCredentials(sender)
    NSLog "Cancelled credentials"
    NSApp.endSheet(credentials_window)
    credentials_window.orderOut(sender)
  end
  
  def pause!(sender)
    if sender.title == "Pause"
      HellaNZBRequest.pause
      sender.enabled = false
    else
      HellaNZBRequest.continue
      sender.enabled = false
    end
  end
  
  def change_max_rate(sender)
    HellaNZBRequest.set_max_rate(self.max_rate_slider.intValue)
    self.max_rate.stringValue = "Updating..."
  end
  
  def dequeue(sender)
    idx = self.queue_table_view.selectedRowIndexes.firstIndex
    
    HellaNZBRequest.dequeue(self.queue_table_view.delegate.queue[idx]['id'])
    self.queue_table_view.delegate.queue.delete_at(idx)
    self.queue_table_view.reloadData
  end
  
  def tick
    HellaNZBRequest.status do |object|
      append_log(object['log_entries'])
      self.log_window.setString(@log.reverse.map { |h| h[h.keys.first] }.join("\n") )
      
      self.total_dl.stringValue = "#{object['total_dl_mb'].to_s} MB"
      self.uptime.stringValue = object['uptime']
      self.rate.stringValue = "#{object['rate']} kbps"
      
      self.pause.title = object['is_paused'] ? 'Continue' : 'Pause'
      self.pause.enabled = true
      
      self.version.stringValue = object['version']
      self.total_files.stringValue = object['total_dl_files']
      self.total_nzbs.stringValue = object['total_dl_nzbs']
      self.total_segments.stringValue = object['total_dl_segments']
      
      self.queue_table_view.delegate.queue = object['queued']
      self.queue_table_view.reloadData
      
      if object['maxrate'].to_i == 0
        self.max_rate.stringValue = "Unlimited"
      else
        self.max_rate.stringValue = "#{object['maxrate']} kbps"
      end
      
      if object['currently_downloading'].size > 0
        current = object['currently_downloading'].first
        self.current_nzb.stringValue = "#{current['nzbName']} (#{current['id']}) [#{current['total_mb']}MB]"
        self.percent_complete.doubleValue = object['percent_complete'].to_f
        self.complete_label.stringValue = "#{object['queued_mb']} MB / #{object['percent_complete']}%"
      else
        self.current_nzb.stringValue = 'None'
        self.percent_complete.doubleValue = 0.0
        self.complete_label.stringValue = "- MB / - %"
      end
    end
  end
  
  def openPanelDidEnd(panel, returnCode:returnCode, contextInfo:contextInfo)
    if returnCode == NSOKButton
      file = panel.filenames.first
      HellaNZBRequest.enqueue(File.basename(file), NSData.dataWithContentsOfFile(file))
    end
  end
  
  def add_nzb(sender)
    openDialog = NSOpenPanel.openPanel
    openDialog.canChooseFiles = true
    openDialog.beginSheetForDirectory(nil, file:nil, types:["nzb"], modalForWindow:self.main_window, modalDelegate:self, didEndSelector:'openPanelDidEnd:returnCode:contextInfo:', contextInfo:nil)
  end
  
  private
  def append_log(new_log)
    @log ||= new_log
    
    return if new_log.last == @log.last
    
    pivot = @log.last
    new_log.each_with_index do |item, idx|
      if item == pivot
        @log = @log + new_log[idx+1..-1]
        break
      end
    end
    
    if new_log.last != @log.last
      @log = @log + new_log
    end
  end
end
