require 'json'
require 'date'

ALL_COUNTS_FILE = 'hn_all_counts.json'
FP_COUNTS_FILE = 'hn_fp_counts.json'

OUTPUT_FILE = 'analyzed_counts.json'

all_counts = JSON.parse(File.read(ALL_COUNTS_FILE))
fp_counts = JSON.parse(File.read(FP_COUNTS_FILE))

data_per_hour = {}

def hour_hash(time_str)
	return "#{DateTime.parse(time_str).wday}-#{DateTime.parse(time_str).hour}"
end

def hours_since_start(time_str)
	return 24 * DateTime.parse(time_str).wday + DateTime.parse(time_str).hour
end

all_counts.each do |data|
	post_time = DateTime.parse(data['hour'])
	key = hour_hash(data['hour'])
	data_per_hour[key] ||= { total: 0, front_page: 0, hour_num: hours_since_start(data['hour']), weekday: post_time.wday, hour: post_time.hour }
	data_per_hour[key][:total] += data['total'].to_i
end

fp_counts.each do |data|
	key = hour_hash(data['hour'])
	data_per_hour[key][:front_page] += data['total'].to_i
end

data_per_hour.each do |key, value|
	value[:fp_chance] = value[:front_page].to_f / value[:total].to_f
end

JSON.dump(data_per_hour.values, File.open(OUTPUT_FILE, 'w'))
