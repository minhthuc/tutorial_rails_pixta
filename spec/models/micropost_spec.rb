require 'spec_helper'

describe Micropost do

  let(:user) { FactoryGirl.create(:user) }
  let(:micropost) { FactoryGirl.create(:micropost, user: user) }

  subject { micropost }

  it { is_expected.to respond_to(:content) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:user) }
  it { expect(micropost.user_id).to eq user.id }

  describe "when user_id is not present" do
    before { micropost.user_id = nil }
    it { is_expected.not_to be_valid }
  end

  describe "with blank content" do
    before { micropost.content = " " }
    it { is_expected.not_to be_valid }
  end

  describe "with content that is too long" do
    before { micropost.content = "a" * 141 }
    it { is_expected.not_to be_valid }
  end
end
