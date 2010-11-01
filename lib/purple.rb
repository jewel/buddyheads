require 'dbus'
require 'gtk2'
require 'pp'

module Purple
  @purple = nil

  @change_responders = []

  def self.on_change &block
    connect if !@purple
    @change_responders.push block
  end

  private
  def self.method_missing symbol, *args
    connect if !@purple
    method = symbol.to_s
    method = 'Purple_' + symbol.to_s
    method.gsub!( /_(.)/ ) { $1.upcase }

    puts "DEBUG: method=#{method} args=#{args.inspect}"
    res = @purple.send( method, *args )
    raise "Weird method #{method} returned #{args.inspect}" if res.length != 1
    puts "DEBUG:  -> #{res[0].inspect}"

    res[0] == 0 ? nil : res[0]
  end

  CHANGE_SIGNALS = %w{
    BuddyStatusChanged
    BuddyIdleChanged
    BuddySignedOn
    BuddySignedOff
    BuddyIconChanged
  }

  def self.connect
    bus = DBus::SessionBus.instance

    gio = GLib::IOChannel.new( bus.socket.fileno )
    gio.add_watch( GLib::IOChannel::IN ) do |c, ch|
      bus.update_buffer
      bus.messages.each do |msg|
        bus.process msg
      end
    end

    service = bus.service("im.pidgin.purple.PurpleService")
    @purple = service.object("/im/pidgin/purple/PurpleObject")
    @purple.introspect
    @purple.default_iface = "im.pidgin.purple.PurpleInterface"

    CHANGE_SIGNALS.each do |sig|
      @purple.on_signal( sig ) do |buddy|
        @change_responders.each do |m|
          m.call buddy
        end
      end
    end
  end

  class Buddy
    def initialize id
      Purple.accounts_get_all_active.each do |account|
        @buddy ||= Purple.find_buddy account, id
      end
      raise "No such buddy: #{id}" unless @buddy
      @contact = Purple.buddy_get_contact @buddy
    end

    def icon
      path = nil
      if Purple.buddy_icons_has_custom_icon @contact
        custom = Purple.buddy_icons_find_custom_icon @contact
        icon_dir = File.join Purple.user_dir, "icons"
        begin
          # this next call only works if pidgin has been recompiled to add the
          # imgstore methods to dbus
          path = File.join icon_dir, Purple.imgstore_get_filename( custom )
        rescue
        end
      end

      if !path
        icon = Purple.buddy_get_icon @buddy
        path = Purple.buddy_icon_get_full_path icon if icon
      end

      path
    end

    def online?
      Purple.buddy_is_online( @buddy ) == 1 ? true : false
    end
  end
end

if $0 == __FILE__
  buddy = Purple::Buddy.new ARGV[0]
  puts buddy.icon
end
