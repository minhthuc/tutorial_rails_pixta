# frozen_string_literal: true

require "spec_helper"

RSpec.feature do
  describe "Authentication" do

    subject { page }

    describe "signin page" do
      before { visit signin_path }

      it { is_expected.to have_content("Sign in") }
      it { is_expected.to have_title("Sign in") }
      describe "with invalid information" do
        before { click_button "Sign in" }

        it { is_expected.to have_title("Sign in") }
        it { is_expected.to have_selector("div.alert.alert-error") }
      end

      describe "with valid information" do
        let(:user) { create(:user) }
        before do
          fill_in "Email", with: user.email.upcase
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        it { is_expected.to have_title(user.name) }
        it { should have_link("Users", href: users_path) }
        it { is_expected.to have_link("Profile", href: user_path(user)) }
        it { is_expected.to have_link("Setting", href: edit_user_path(user)) }
        it { is_expected.to have_link("Sign out", href: signout_path) }
        it { is_expected.not_to have_link("Sign in", href: signin_path) }
        describe "after visiting another page" do
          before { click_link "Home" }
          it { is_expected.not_to have_selector("div.alert.alert-error") }
        end
      end

      describe "with invalid information" do
        before { click_button "Sign in" }

        it { is_expected.to have_title("Sign in") }
        it { is_expected.to have_selector("div.alert.alert-error") }

      end
    end

    describe "as wrong user" do
      let(:user) { create(:user) }
      let(:wrong_user) { create(:user, email: "wrong@example.com") }
      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title("Edit user")) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "authorization" do

      describe "for non-signed-in users" do
        let(:user) { FactoryGirl.create(:user) }

        describe "when attempting to visit a protected page" do
          before do
            visit edit_user_path(user)
            fill_in "Email", with: user.email
            fill_in "Password", with: user.password
            click_button "Sign in"
          end
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title("Edit user")
          end
        end

        describe "in the Microposts controller" do

          describe "submitting to the create action" do
            before { post microposts_path }
            specify { expect(response).to redirect_to(signin_path) }
          end

          describe "submitting to the destroy action" do
            before { delete micropost_path(create(:micropost)) }
            specify { expect(response).to redirect_to(signin_path) }
          end
        end
      end

      describe "in the Users controller" do
        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title("Sign in") }
        end
      end

      describe "as non-admin user" do
        let(:user) { create(:user) }
        let(:non_admin) { create(:user) }

        before { sign_in non_admin, no_capybara: true }

        describe "submitting a DELETE request to the Users#destroy action" do
          before { delete user_path(user) }
          specify { expect(response).to redirect_to(root_url) }
        end
      end
    end

  end
end
