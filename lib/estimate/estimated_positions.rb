module Estimate
  class EstimatedPositions < SimpleDelegator
    def initialize
      super([])
    end

    def nearest_ep_by_time_now
      sort_by { |ep| (ep.timestamp.to_i - Time.now.to_i).abs }.first
    end

    def as_json(merge_with = {})
      map { |ep| merge_with.merge(ep.as_json) }
    end

    def not_overdue?
      size > 1 && (last.timestamp.to_i - Time.now.to_i) > 20
    end
  end
end
