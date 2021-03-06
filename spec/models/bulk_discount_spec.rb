require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe "relationships" do
    it {should belong_to :merchants}
  end
end