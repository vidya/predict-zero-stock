
# Our users like the chemical inventory system you built for them, but sometimes they unexpectedly
# run out of a chemical and have to wait for resupply. After discussing this with them, you realize
# that many uses recur at defined intervals, and this can help you forecast when the chemical will run out.
# 
# For this code problem, you will write the algorithm to predict when a chemical will run out. 
# Please use Ruby (core library only) and include plenty of specs/tests in your favorite testing framework.
# 
# Scheduled use
#  - A scheduled use has an amount, a periodicity, a start date and an optional end date
#  - A scheduled use's periodicity can be daily or weekly (on a particular day of the week)
#
# Given a current amount and a set of scheduled uses, predict when the chemical will run out
#  - If the last use brings the amount to zero, then return the date of the last use
#  - If any use makes the amount negative, return the date of the latest use that did not incur
#    a negative balance

require 'inventory_base'

def amount_needed(schedule_list, usage_day)
  schedule_list.map { |sch| sch.amount_needed(usage_day) }.reduce(:+)
end

def to_scheduled_use_objects(hash_list)
  hash_list.map { |hash| InventoryUse.new hash.merge!(:properties => hash) }
end

def last_scheduled_usage_day(scheduled_use_objects)
  objects_with_end_dates = scheduled_use_objects.map(&:end_date).compact

  return nil if objects_with_end_dates.empty?

  objects_with_end_dates.map(&:end_date).max
end

def has_unending_schedules?(scheduled_use_objects)
  scheduled_use_objects.detect &:end_date
end

#
# scheduled_uses: an array of hashes
#
def reorder_time_forecast(scheduled_uses, amount_remaining)
  schedule_list = to_scheduled_use_objects(scheduled_uses)

  raise "ERROR: schedule_list needs to be an Array of InventoryUse objects" \
    if !(schedule_list.is_a? Array)

  raise "ERROR: schedule_list needs to be an Array of InventoryUse objects" \
    unless schedule_list.all? { |sch| sch.is_a? InventoryUse}

  valid_schedules = schedule_list.select(&:is_valid?)

  return nil if valid_schedules.empty?

  amount_available         = amount_remaining

  last_valid_usage_day     = nil

  last_planned_usage_day   = last_scheduled_usage_day(schedule_list)

  usage_day                = Date.today - 1

  loop do
    usage_day             += 1

    break if (usage_day > last_planned_usage_day)   \
      unless has_unending_schedules?(schedule_list) \
        || last_planned_usage_day.nil?

    required_amount          = amount_needed(valid_schedules, usage_day)

    next if required_amount.zero?

    break if (required_amount > amount_available)

    last_valid_usage_day   = usage_day

    amount_available      -= required_amount
  end

  last_valid_usage_day
end

