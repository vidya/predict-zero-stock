
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

require './test_base'

DAY_ONE         = Date.today
AMOUNT_UNIT     = 10
WEEK_DAY_BASE   = 0         # 0: sunday, 1: monday, etc.

describe "ChemicalInventory" do
  describe 'method_date_of_last_use' do
    describe 'single_valid_schedule' do
      @scenario        = 'single_schedule'

      before do
        @schedule_list = [
                            {
                              :amount           => AMOUNT_UNIT,
                              :periodicity      => 'daily',

                              :start_date       =>  DAY_ONE - 23
                            },

                            {
                              :amount           => AMOUNT_UNIT,
                              :periodicity      => 'monthly',               #invalid schedule

                              :start_date       =>  DAY_ONE - 23
                            }
                          ]

        #binding.pry
      end

      attr_accessor :schedule_list
      
      it 'available_supply_equals_amount_needed_by_valid_schedules' + '_for_' + @scenario do
        amount_remaining   = AMOUNT_UNIT
        reorder_time_forecast(schedule_list, amount_remaining).must_equal (DAY_ONE)
      end

      it 'available_supply_is_less_than_amount_needed_by_valid_schedules' + '_for_' + @scenario do
        amount_remaining   = AMOUNT_UNIT - 1

        reorder_time_forecast(schedule_list, amount_remaining).must_be_nil
      end
    end                          # single_valid_schedule

    describe 'multiple_schedules' do
      @scenario         = 'multiple_schedules'

      before do
        @schedule_list  = [
                            {
                              :amount           => AMOUNT_UNIT,
                              :periodicity      => 'daily',

                              :start_date       =>  DAY_ONE - 23
                            },

            {
                              :amount           => AMOUNT_UNIT,
                              :periodicity      => 'daily',

                              :start_date       =>  DAY_ONE - 7
                            }
                          ]
      end

      attr_accessor :schedule_list

      it 'available_supply_equals_amount_needed_by_active_schedules' + '_for_' + @scenario do
        amount_remaining   = 2.3 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_equal DAY_ONE
      end

      it 'available_supply_is_less_than_amount_needed_by_active_schedules' + '_for_' + @scenario do
        amount_remaining   = 1.5 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_be_nil
      end

      it 'available_supply_lasts_only_for_one_use_of_active_schedules' + '_for_' + @scenario do
        amount_remaining   = 2.2987 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_equal DAY_ONE
      end
    end                             # multiple_schedules

    describe 'ending_schedules' do
      @scenario         = 'ending_schedules'

      before do
        @schedule_list  = [
                            {
                              :amount           => AMOUNT_UNIT,
                              :periodicity      => 'daily',

                              :start_date       =>  DAY_ONE - 23,
                              :end_date         =>  DAY_ONE - 3
                            },

                            {
                              :amount           => AMOUNT_UNIT,
                              :periodicity      => 'daily',

                              :start_date       =>  DAY_ONE - 7
                            }
                          ]
      end

      attr_accessor :schedule_list

      it 'available_supply_equals_active_schedule_amount' + '_for_' + @scenario do
        amount_remaining   = 2.3 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_equal DAY_ONE + 1
      end

      it 'available_supply_is_less_than_active_schedule_amount' + '_for_' + @scenario do
        amount_remaining   = 0.8 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_be_nil
      end

      it 'available_supply_lasts_only_for_one_use_of_active_schedule' + '_for_' + @scenario do
        amount_remaining   = 1.2987 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_equal DAY_ONE
      end

      it 'available_supply_lasts_only_for_one_use_of_active_schedule' + '_for_' + @scenario do
        amount_remaining   = 1000 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_equal (DAY_ONE + 1000 - 1)
      end
    end                               # ending_schedules

    describe 'ending_schedules_abundant_supply' do
      @scenario         = 'ending_schedules'

      before do
        @schedule_list  = [
                            {
                              :amount           => AMOUNT_UNIT,
                              :periodicity      => 'daily',

                              :start_date       =>  DAY_ONE - 23,
                              :end_date         =>  DAY_ONE + 3
                            }
                          ]
      end

      attr_accessor :schedule_list

      it 'available_supply_lasts_only_for_one_use_of_active_schedule' + '_for_' + @scenario do
        amount_remaining   = 1000 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_equal (DAY_ONE + 3)
      end
    end                               # ending_schedules_abundant_supply

    describe 'day_of_the_week_schedules' do
      @scenario         = 'ending_schedules'

      before do
        @schedule_list  = [
                            {
                              :amount           => AMOUNT_UNIT,
                              :periodicity      => 'daily',

                              :start_date       =>  DAY_ONE - 23,
                              :end_date         =>  DAY_ONE - 3
                            },

                            {
                              :amount           => AMOUNT_UNIT,
                              :periodicity      => 'weekly',

                              :start_date       => DAY_ONE - 7,

                              :wday  => WEEK_DAYS[WEEK_DAY_BASE + 1]
                            }
                          ]
      end

      attr_accessor :schedule_list

      it 'available_supply_equals_active_schedule_amount' + '_for_' + @scenario do
        amount_remaining   = 2.3 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_equal (DAY_ONE + 13)
      end

      it 'supply_is_less_than_schedule_amount' + '_for_' + @scenario do
        amount_remaining   = 0.8 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_be_nil
      end

      it 'supply_enough_for_only_one_use' + '_for_' + @scenario do
        amount_remaining   = 1.2987 * AMOUNT_UNIT

        reorder_time_forecast(schedule_list, amount_remaining).must_equal (DAY_ONE + 6)
      end
    end                               # day_of_the_week_schedules
  end
end

