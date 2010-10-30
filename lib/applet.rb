require 'lib/purple'
require 'yaml'

CONFIG_FILE = File.join ENV['HOME'], '.config/buddyheads/settings'

class BuddyApplet
  attr_reader :widget
  def initialize
    @settings = YAML::load File.read( CONFIG_FILE )
    @buddies = @settings['buddy_ids'].map do |id|
      Purple::Buddy.new id
    end

    @widget = Gtk::HBox.new
    @buddies.each do |buddy|
      image = Gtk::Image.new buddy.icon
      @widget.add image
    end
  end
end
