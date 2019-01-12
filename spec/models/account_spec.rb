require "rails_helper"

describe Account do
  subject do
    described_class.new(YNAB::Account.new(id: "1234"))
  end

  describe "delegation" do
    it "delegates methods to the child object" do
      expect(subject.id).to eq("1234")
    end
  end
end
