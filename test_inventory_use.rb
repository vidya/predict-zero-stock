
require './test_base'

DAY_ONE         = Date.today
AMOUNT_UNIT     = 10
WEEK_DAY_BASE   = 0         # 0: sunday, 1: monday, etc.

describe "InventoryUse" do
  describe "rejection_of_an_invalid_schedule" do
    it "rejects_empty_schedule" do
      schedule        = InventoryUse.new({})

      error_message   = "ERROR: schedule(={schedule.properties.inspect}) is missing one or more of "
      error_message  += "the expected [:amount, :periodicity, :start_date] attributes"

      refute schedule.is_valid?, error_message
    end

    it "rejects_invalid_amount" do
      schedule        = InventoryUse.new(
                                          :amount       => 0 * AMOUNT_UNIT,
                                          :periodicity  => 'daily',
                                          :start_date   => DAY_ONE - 23
                                        )

      error_message   = "ERROR: amount in schedule(=#{schedule.properties.inspect}) is valid"
      refute schedule.is_valid?, error_message
    end
    
    it "rejects_invalid_periodicity" do
      schedule        = InventoryUse.new(
                                          :amount       => AMOUNT_UNIT,
                                          :periodicity  => 'monthly',
                                          :start_date   => DAY_ONE - 23
                                        )

      error_message   = "ERROR: periodicity in schedule(=#{schedule.properties.inspect}) is valid"
      refute schedule.is_valid?, error_message
    end

    it "rejects_invalid_weekly_periodicity" do
      schedule        = InventoryUse.new(
                                          :amount       => AMOUNT_UNIT,
                                          :periodicity  => 'weekly',
                                          :start_date   => DAY_ONE - 23
                                        )

      error_message   = "ERROR: weekly_periodicity in schedule(=#{schedule.properties.inspect}) is valid"
      refute schedule.is_valid?, error_message
    end

    it "rejects_invalid_end_date" do
      schedule        = InventoryUse.new(
                                          :amount           => AMOUNT_UNIT,
                                          :periodicity      => 'weekly',

                                          :start_date       => DAY_ONE - 23,
                                          :end_date         => DAY_ONE - 24,

                                          :day_of_the_week  => WEEK_DAYS[(DAY_ONE - 24).wday]
                                        )

      error_message   = "ERROR: weekly_periodicity in schedule(=#{schedule.properties.inspect}) is invalid"
      refute schedule.is_valid?, error_message
    end
  end

  describe "acceptance_of_a_valid_schedule" do
    it "accepts_weekly_periodicity" do
      schedule        = InventoryUse.new(
                                          :amount           => AMOUNT_UNIT,
                                          :periodicity      => 'weekly',
                                          :start_date       => DAY_ONE - 23,
                                          :day_of_the_week  => WEEK_DAYS[WEEK_DAY_BASE + 1]
                                        )

      error_message   = "ERROR: weekly_periodicity in schedule(=#{schedule.properties.inspect}) is invalid"
      assert schedule.is_valid?, error_message
    end

    it "accepts_valid_end_date" do
      schedule        = InventoryUse.new(
                                          :amount           => AMOUNT_UNIT,
                                          :periodicity      => 'weekly',

                                          :start_date       => DAY_ONE - 23,
                                          :end_date         => DAY_ONE - 3,

                                          :day_of_the_week  => WEEK_DAYS[WEEK_DAY_BASE + 1]
                                        )

      error_message   = "ERROR: weekly_periodicity in schedule(=#{schedule.properties.inspect}) is invalid"
      assert schedule.is_valid?, error_message
    end
  end

  describe "calculation_of_amount_needed_for_daily_schedule" do
    @scenario             = 'daily_schedule'

    before do
      @daily_schedule     = InventoryUse.new(
                                              :amount           => AMOUNT_UNIT,
                                              :periodicity      => 'daily',

                                              :start_date       => DAY_ONE - 23,
                                              :end_date         => DAY_ONE - 2
                                            )
    end

    it 'returns_zero_if_usage_day_is_after_end_date' + '_for_' + @scenario do
      @daily_schedule.amount_needed(DAY_ONE - 24).must_equal 0
    end

    it 'returns_amount_for_start_day' + '_for_' + @scenario do
      @daily_schedule.amount_needed(DAY_ONE - 23).must_equal AMOUNT_UNIT
    end

    it 'returns_amount_for_midrange_day' + '_for_' + @scenario do
      @daily_schedule.amount_needed(DAY_ONE - 21).must_equal AMOUNT_UNIT
    end
  end

  describe "calculation_of_amount_needed_for_unending_daily_schedule" do
    @scenario                      = 'unending_daily_schedule'

    before do
      @daily_unending_schedule     = InventoryUse.new(
                                                        :amount           => AMOUNT_UNIT,
                                                        :periodicity      => 'daily',

                                                        :start_date       => DAY_ONE - 23
                                                     )
    end

    it 'returns_amount_for_midrange_day' + '_for_' + @scenario do
      @daily_unending_schedule.amount_needed(DAY_ONE - 21).must_equal AMOUNT_UNIT
    end
  end

  describe "calculation_of_amount_needed_for_weekly_schedule" do
    @scenario             = 'weekly_schedule'

    before do
      @weekly_schedule    = InventoryUse.new(
                                              :amount           => AMOUNT_UNIT,
                                              :periodicity      => 'weekly',

                                              :start_date       => DAY_ONE - 23,  
                                              :end_date         => DAY_ONE - 2, 


                                              :day_of_the_week  => WEEK_DAYS[DAY_ONE.wday]
                                            )
    end

    it 'returns_zero_if_usage_day_is_after_end_date' + '_for_' + @scenario do
      @weekly_schedule.amount_needed(DAY_ONE - 24).must_equal 0
    end

    it 'returns_zero_if_usage_day_is_before_start_date' + '_for_' + @scenario do
      @weekly_schedule.amount_needed(DAY_ONE - 24).must_equal 0
    end

    it 'returns_amount_if_usage_day_is_not_day_of_the_week' + '_for_' + @scenario do
      @weekly_schedule.amount_needed(DAY_ONE - 23).must_equal 0
    end

    it 'returns_zero_if_usage_day_is_the_day_of_the_week' + '_for_' + @scenario do
      @weekly_schedule.amount_needed(DAY_ONE - 21).must_equal AMOUNT_UNIT
    end
  end

  describe "calculation_of_amount_needed_for_unending_weekly_schedule" do
    @scenario                      = 'unending_weekly_usage'

    before do
      @weekly_unending_schedule    = InventoryUse.new(
                                                        :amount           => AMOUNT_UNIT,
                                                        :periodicity      => 'weekly',

                                                        :start_date       => DAY_ONE - 23,

                                                        :day_of_the_week  => WEEK_DAYS[(DAY_ONE - 23).wday]
                                                      )
    end

    it 'returns_zero_if_usage_day_is_before_start_date_day'  + '_for_' + @scenario do
      @weekly_unending_schedule.amount_needed(DAY_ONE - 24).must_equal 0
    end

    it 'returns_amount_if_usage_day_is_start_date_day'  + '_for_' + @scenario do
      @weekly_unending_schedule.amount_needed(DAY_ONE - 23).must_equal AMOUNT_UNIT
    end

    it 'returns_zero_if_usage_day_is_not_day_of_the_week'  + '_for_' + @scenario do
      @weekly_unending_schedule.amount_needed(DAY_ONE - 21).must_equal 0
    end
  end
end

