require 'singleton'

module Estimate
  class CalendarService
    include Singleton
    def initialize
      @calendars ||= all_calendars
    end

    def valid(service_id)
      valid_only_today.find { |c| c.service_id.to_s == service_id.to_s }
    end

    def valid_only_today
      return @valid_only_today if @valid_only_today
      date = Time.now.to_date
      @valid_only_today = @calendars.select { |c| c.valid?(date) }
    end

    private

    def all_calendars
      calendars = []
      Config.instance.connection.exec_params('SELECT * FROM gtfs_calendars ') do |result|
        calendars = result.map do |row|
          new(service_id: row['service_id'],
              monday: row['monday'],
              tuesday: row['tuesday'],
              wednesday: row['wednesday'],
              thursday: row['thursday'],
              friday: row['friday'],
              saturday: row['saturday'],
              sunday: row['sunday'],
              start_date: row['start_date'],
              end_date: row['end_date'],
              service_name: row['service_name'])
        end
      end
    end
  end
end
