require 'rails_helper'

RSpec.describe Holiday, type: :model do
  describe "methods" do
    it 'has holidays' do
      @holidays = HolidayService.new.holiday_objs

      expect(@holidays.class).to eq(Array)
      expect(@holidays.first.name.class).to eq(String)
      expect(@holidays.first.date.class).to eq(String)
    end
  end
end