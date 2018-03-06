module Estimate
  class Calendar
    attr_accessor :service_id
    attr_accessor :monday
    attr_accessor :tuesday
    attr_accessor :wednesday
    attr_accessor :thursday
    attr_accessor :friday
    attr_accessor :saturday
    attr_accessor :sunday
    attr_accessor :start_date
    attr_accessor :end_date
    attr_accessor :service_name

    def initialize(args)
      @service_id = args[:service_id]
      @monday = args[:monday].to_i
      @tuesday = args[:tuesday].to_i
      @wednesday = args[:wednesday].to_i
      @thursday = args[:thursday].to_i
      @friday = args[:friday].to_i
      @saturday = args[:saturday].to_i
      @sunday = args[:sunday].to_i
      @start_date = Date.strptime(args[:start_date], '%Y-%m-%d')
      @end_date = Date.strptime(args[:end_date], '%Y-%m-%d')
      @service_name = args[:service_name]
    end

    def valid?(date)
      return false unless @start_date <= date && date <= @end_date
      day_valid = [@sunday, @monday, @tuesday, @wednesday, @thursday, @friday, @saturday][date.wday]
      day_valid == 1
    end
  end
end
