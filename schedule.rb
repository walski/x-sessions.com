require 'csv'
require 'open-uri'

class Schedule
  URL = 'https://docs.google.com/spreadsheet/pub?key=0Au_LuhlBQUkEdHRSc3Y2Q3h1SEstVXlGVmw2RG80U0E&single=true&gid=0&range=A6%3AD99&output=csv'

  def initialize
    @now  = Time.now
    @date = @now.strftime('%d.%m.%y')
    @time = @now.strftime('%H:%M')
  end

  def fetch
    @data = open(URL).read.to_s.force_encoding('utf-8')
  end

  def parse
    @doc = CSV.parse(@data)
  end

  def sessions
    day_of_event = Time.new(2013,11,22).at_midnight

    last_topic, last_speaker = []

    sessions = @doc.map do |line|
      time, topic, speaker = line
      hours, minutes = time.split(':').map(&:to_i)

      one_minute = 60
      one_hour = 60 * one_minute

      time = day_of_event + (hours * one_hour) + (minutes * one_minute)

      if topic && !topic.blank? && speaker && !speaker.blank?
        {'info' => topic, 'speaker' => speaker, 'time' => time}
      else
        nil
      end
    end.compact

    sessions.each_with_index do |session, i|
      next_session = sessions[i+1] || {}

      session['end'] = next_session['time'] || session['time']
    end

    sessions
  end

  def self.all
    instance = new
    instance.fetch
    instance.parse
    instance.sessions
  end
end
