# frozen_string_literal: true

require "spec_helper"

describe User do
  let(:user) {
    User.new(name: "Example User", email: "user@example.com",
             password: "foobar", password_confirmation: "foobar") }

  subject { user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }

  context "remember token" do
    before { user.save }
    it { expect(user.remember_token).not_to be_blank }
  end

  context "when name is not present" do
    before { user.name = " " }
    it { should_not be_valid }
  end

  context "when name is nil" do
    before { user.name = nil }
    it { should_not be_valid }
  end

  context "when password is nil" do
    before { user.name = nil }
    it { should_not be_valid }
  end

  context "when password is nil" do
    before { user.password = nil }
    it { should_not be_valid }
  end

  context "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).not_to be_valid
      end
    end
  end

  context "when password is not present" do
    let(:user) {
      User.new(name: "Example User", email: "user@example.com",
                password: " ", password_confirmation: " ") }
    it { should_not be_valid }
  end

  context "with a password that's too short" do
    before { user.password = user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  context "when password doesn't match confirmation" do
    before { user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  context "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end
  end
  context "when email address is already taken" do
    before do
      user_with_same_email = user.dup
      user_with_same_email.email = user.email.upcase
      user_with_same_email.save
    end
    it { should_not be_valid }
  end

  it { should respond_to(:authenticate) }
  it { should respond_to(:admin) }
  it { should respond_to(:microposts) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to true" do
    before do
      user.save!
      user.toggle!(:admin)
    end

    it { should be_admin }
  end

  describe "micropost associations" do

    before { user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      expect(user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy associated microposts" do
      microposts = user.microposts.to_a
      user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

  end
end
