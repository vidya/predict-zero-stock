
require './inventory_base'

class InventoryUse
  attr_accessor :properties,
                :amount, :start_date, :end_date, :periodicity, :wday

  def initialize(properties)
    @properties        = properties

    @amount            = properties[:amount]
    @start_date        = properties[:start_date]
    @end_date          = properties[:end_date]
    @periodicity       = properties[:periodicity]
    @wday              = properties[:wday]
  end

  def is_valid?
    return false unless (amount && periodicity && start_date)

    return false if (end_date) && (end_date < start_date)

    return false unless periodicity.eql?('daily') || periodicity.eql?('weekly')

    return false if (amount <= 0)

    return false unless periodicity.eql?('weekly') \
      && wday && WEEK_DAYS.include?(wday.downcase)

    true
  end

  def amount_needed(usage_date)
    required_amount = if (usage_date < start_date)
                        0
                      else
                        amount
                      end

    required_amount = 0 if (end_date) && (usage_date > end_date)

    if periodicity.eql?('weekly')
      required_amount = 0 unless usage_date.wday.eql?(WEEK_DAYS.index wday.downcase)
    end

    required_amount
  end
end
