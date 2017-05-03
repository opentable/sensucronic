require "spec_helper"

RSpec.describe Sensucronic do
  it "has a version number" do
    expect(Sensucronic::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
