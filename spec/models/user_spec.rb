# frozen_string_literal: true

require "spec_helper"

describe User do
  let(:user) do
    User.new(name: "Example User", email: "user@example.com",
             password: "foobar", password_confirmation: "foobar") end

  subject { user }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:email) }
  it { is_expected.to respond_to(:password_digest) }
  it { is_expected.to respond_to(:password) }
  it { is_expected.to respond_to(:password_confirmation) }
  it { is_expected.to respond_to(:remember_token) }
  it { is_expected.to respond_to(:authenticate) }
  it { is_expected.to respond_to(:microposts) }
  it { is_expected.to respond_to(:feed) }
  it { is_expected.to respond_to(:following?) }
  it { is_expected.to respond_to(:followed_users) }
  it { is_expected.to respond_to(:follow!) }
  it { is_expected.to respond_to(:reverse_relationships) }
  it { is_expected.to respond_to(:followers) }

  context "remember token" do
    before { user.save }
    it { expect(user.remember_token).not_to be_blank }
  end

  context "when name is not present" do
    before { user.name = " " }
    it { is_expected.not_to be_valid }
  end

  context "when name is nil" do
    before { user.name = nil }
    it { is_expected.not_to be_valid }
  end

  context "when password is nil" do
    before { user.name = nil }
    it { is_expected.not_to be_valid }
  end

  context "when password is nil" do
    before { user.password = nil }
    it { is_expected.not_to be_valid }
  end

  context "when email format is invalid" do
    it "is_expected.to be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).not_to be_valid
      end
    end
  end

  context "when password is not present" do
    let(:user) do
      User.new(name: "Example User", email: "user@example.com",
                password: " ", password_confirmation: " ") end
    it { is_expected.not_to be_valid }
  end

  context "with a password that's too short" do
    before { user.password = user.password_confirmation = "a" * 5 }
    it { is_expected.to be_invalid }
  end

  context "when password doesn't match confirmation" do
    before { user.password_confirmation = "mismatch" }
    it { is_expected.not_to be_valid }
  end

  context "when email format is valid" do
    it "is_expected.to be valid" do
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
    it { is_expected.not_to be_valid }
  end

  it { is_expected.to respond_to(:authenticate) }
  it { is_expected.to respond_to(:admin) }
  it { is_expected.to respond_to(:microposts) }
  it { is_expected.to respond_to(:relationships) }
  it { is_expected.to respond_to(:followed_users) }
  it { is_expected.to respond_to(:follow!) }
  it { is_expected.to respond_to(:unfollow!) }

  it { is_expected.to be_valid }
  it { is_expected.not_to be_admin }

  describe "with admin attribute set to true" do
    before do
      user.save!
      user.toggle!(:admin)
    end

    it { is_expected.to be_admin }
  end

  describe "micropost associations" do

    before { user.save }
    let!(:older_micropost) do
      create(:micropost, user: user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      create(:micropost, user: user, created_at: 1.hour.ago)
    end

    it "is_expected.to have the right microposts in the right order" do
      expect(user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "is_expected.to destroy associated microposts" do
      microposts = user.microposts.to_a
      user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      its(:feed) { is_expected.to include(newer_micropost) }
      its(:feed) { is_expected.to include(older_micropost) }
      its(:feed) { is_expected.not_to include(unfollowed_post) }
    end
  end

  describe "following" do
    let (:other_user) { create(:user) }

    before do
      user.save
      user.follow!(other_user)
    end
    it { is_expected.to be_following(other_user) }
    its(:followed_users) { is_expected.to include(other_user) }
    describe "and unfollowing" do
      before { user.unfollow!(other_user) }

      it { is_expected.to be_following(other_user) }
      its(:followed_users) { is_expected.to_not include(other_user) }
      describe "followed user" do
        subject { other_user }
        its(:followers) { is_expected.to include(user) }
      end
    end
  end
end
