
require './inventory_base'

class InventoryUse
  attr_accessor :properties, :defined_keys,
                :amount, :start_date, :end_date, :periodicity, :day_of_the_week

  def initialize(properties)
    @properties        = properties

    @defined_keys      = properties.keys

    @amount            = properties[:amount]
    @start_date        = properties[:start_date]
    @end_date          = properties[:end_date]
    @periodicity       = properties[:periodicity]
    @day_of_the_week   = properties[:day_of_the_week]
  end

  def is_valid?
    return false if defined_keys.nil?

    return false unless ([:amount, :periodicity, :start_date] - defined_keys).empty?

    return false if (defined_keys.include? :end_date) && (end_date < start_date)

    return false unless ['daily', 'weekly'].include? periodicity

    return false if amount <= 0

    if periodicity.eql? 'weekly'
      return false unless defined_keys.include? :day_of_the_week

      return false unless WEEK_DAYS.include? day_of_the_week.downcase
    end

    true
  end

  def amount_needed(usage_day)
    required_amount   = amount

    required_amount   = 0 if usage_day < start_date

    if defined_keys.include? :end_date
      required_amount = 0 if usage_day > end_date
    end

    if periodicity.eql? 'weekly'
      required_amount = 0 unless usage_day.wday.eql? WEEK_DAYS.index day_of_the_week.downcase
    end

    required_amount
  end
end
