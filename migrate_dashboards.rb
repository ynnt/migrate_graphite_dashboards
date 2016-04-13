#!/usr/bin/env ruby
require 'http'
require 'json'
require 'optparse'

# This function backups all graphite dashboards and saves them to the text file
def backup_dashboards(http_auth, graphite_server)
  board_names = JSON.parse(http_auth.post("#{graphite_server}/dashboard/find/", form: {query:''}).to_s)['dashboards'].map{|n|n['name']}

  board_names.map do |b|
    dat=http_auth.get("#{graphite_server}/dashboard/load/#{b}").to_s
    state_str=JSON.parse(dat)['state'].to_json # :(
    puts state_str
  end
end

# This function restores graphite dashboards from text file
def restore_dashboards(http_auth, txt_file, graphite_server)
  File.open(txt_file).each_line do |l|
    http_auth.post("#{graphite_server}/dashboard/save/#{l['name']}", form: {state: l})
  end
end

if __FILE__ == $0
  http_user, http_password, graphite, txt_file = ''
  action = 'save'

  ARGV.options do |opts|
    opts.banner = "Usage: gr_dashs.rb [options]"

    opts.on('-u', '--username USER', 'Username for http basic auth') { |v| http_user = v }
    opts.on('-p', '--password PASS', 'Password for http basic auth') { |v| http_password = v }
    opts.on('-h', '--host GRAPHITE_HOST', 'Graphite host') { |v| graphite = v }
    opts.on('-t', '--txt-file TXT FILE', 'Text file from which graphite dashboards will be loaded') { |v| txt_file = v }
    opts.on('-a', '--action save|restore', 'Action to do. Default is to save.') { |v| action = v }
  end.parse!

  if graphite.nil?
    puts 'This is mandatory options. Please provide graphite host.'
    Kernel.exit(1)
  end

  if "#{http_user}#{http_password}".length != 0
    h = HTTP.basic_auth(user: http_user, pass: http_password)
  else
    h = HTTP.basic_auth(user: '', pass: '')
  end
 
  case action
  when 'save'
    backup_dashboards(h, graphite)
  when 'restore'
    if txt_file.nil?
      puts 'Input file should be specified!'
      Kernel.exit(1)
    end
    restore_dashboards(h, txt_file, graphite)
  else
    puts "Wrong action specified: #{action}"
    Kernel.exit(1)
  end
end
