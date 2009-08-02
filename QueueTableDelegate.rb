#
#  QueueTableDelegate.rb
#  DudeNZB
#
#  Created by Ruben Fonseca on 7/30/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

class QueueTableDelegate
  attr_accessor :queue
  attr_accessor :remove_button
  
  def numberOfRowsInTableView(tableView)
    queue.count rescue 0
  end
  
  def tableView(tableView, objectValueForTableColumn:column, row:row)
    case column.identifier
    when 'id'
      return self.queue[row]['id']
    when 'name'
      return self.queue[row]['nzbName']
    when 'size'
      return self.queue[row]['total_mb']
    else
      return nil
    end
  end
  
  def tableViewSelectionDidChange(notification)
    if notification.object.selectedRowIndexes.count.zero?
      self.remove_button.enabled = false
    else
      self.remove_button.enabled = true
    end
  end
end
