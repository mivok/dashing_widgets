# List of servers to ping
servers = [
  '192.168.1.1',
  'google.com',
  'www.verizon.com',
  'trello.com'
]

# The server from the list above whose times should be graphed
graph_server = 'google.com'

points = [0] * 10

SCHEDULER.every '5s', :first_in => 0 do |job|
  times = Array.new
  status = 'ok'

  servers.each do |server|
    result = %x(ping -W 2 -q -c 1 #{server})
    if ($?.exitstatus == 0)
      time = result.split("\n")[-1].split('/')[-2].to_f
    else
      time = "--"
      status = 'bad'
    end

    if server == graph_server
      points.shift
      points << time == "--" ? 0 : time
    end
    time = time.round if time != "--"

    times << {label: server, time: time}
  end

  send_event('ping', {
    items: times,
    status: status,
    points: points.map.with_index.map{|y,x| {x: x, y: y}},
    graph_server: graph_server
  })
end
