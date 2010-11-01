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

    @icons = []
    @buddies.each do |buddy|
      image = Gtk::Image.new get_icon(buddy)
      @icons.push({
        :buddy => buddy,
        :image => image
      })
      @widget.add image
    end

    Purple.on_change do |buddy|
      @icons.each do |i|
        next unless i[:buddy] == buddy
        i[:image].image = get_icon i[:buddy]
      end
    end
  end

  SIZE = 22
  def get_icon buddy
    image = Gdk::Pixbuf.new buddy.icon
    image = image.scale SIZE, SIZE
    unless buddy.online?
      image = image.saturate_and_pixelate 0.0, false
    end
    return image
  end
end
