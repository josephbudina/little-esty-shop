class HolidayService < ApiService
  def holidays
    repos_endpoint = "https://date.nager.at/Api/v2/NextPublicHolidays/us"
    get_holiday_data(repos_endpoint)
  end

  def holiday_objs
    holidays[0..2].map do |holiday_data|
      Holiday.new(holiday_data)
    end
  end
end