require_relative 'getpg'

def get_level_one_users(pg)
  return pg.get_users_on_call['escalation_policies'].flat_map do |policy|
    policy['on_call'].map do |oncall|
      oncall['user']['id'] if oncall['start'] and oncall['level'] == 1
    end.compact
  end
end

pg = TapJoy::PagerDuty.new
get_level_one_users(pg).each do |u|
  user = pg.get_user_details(u)['user']
  on_call = user['on_call']
  puts "Name: #{user['name']}"
  on_call.each do |oc|
    puts "\tGroup: #{oc['escalation_policy']['name']}"
    puts "\tStart: #{oc['start']}"
    puts "\tEnd: #{oc['end']}"
    puts "\n"
  end
  puts '---'
end
