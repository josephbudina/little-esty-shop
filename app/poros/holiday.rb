class Holiday
  attr_reader :name,
              :date

  def initialize(repo_data)
    @name = repo_data[:name]
    @date = repo_data[:date]
  end
end