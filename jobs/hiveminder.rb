require 'net/http'
require 'json'

SCHEDULER.every '30s', :first_in => 0 do |job|
  http = Net::HTTP.new("hiveminder.com", 80)
  headers = {'Cookie' => ENV['HIVEMINDER_COOKIE']}
  response = http.post("/=/action/DownloadTasks.json", "", headers)
  body = JSON.parse(response.body)
  tasks = []
  if body['success'] == 1
    tasks = body['content']['result'].split("---")[1].strip.split(/\n(?=\S)/)
    tasks = tasks.map { |task|
      task = task.split("\n")[0]
      match = task.match(/^(.+)\s\((\w{5})\)$/)
      label = match[1]
      value = match[2]
      { label: label, value: value }
    }
  end
  send_event('hiveminder', { items: tasks })
end
