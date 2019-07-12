require "spec_helper"

RSpec.feature do
  describe "User pages" do

    subject { page }
    context "signup page" do
      before { visit signup_path }

      it { is_expected.to have_content("Sign up") }
      it { is_expected.to have_title(full_title("Sign up")) }
    end
    context "profile page" do
      # Replace with code to make a user variable

      let(:user) { create(:user) }

      before { visit user_path(user) }

      it { is_expected.to have_content(user.name) }
      it { is_expected.to have_title(user.name) }
    end
    context "signup page" do
      before { visit signup_path }

      it { is_expected.to have_content("Sign up") }
      it { is_expected.to have_title(full_title("Sign up")) }
    end
    context "signup" do

      before { visit signup_path }

      let(:submit) { "Create my account" }

      describe "with invalid information" do
        it "should not create a user" do
          expect { click_button submit }.not_to change(User, :count)
        end
      end

      describe "with valid information" do
        before do
          fill_in "Name", with: "Example User"
          fill_in "Email", with: "user@example.com"
          fill_in "Password", with: "foobar"
          fill_in "Confirmation", with: "foobar"
        end

        it "should create a user" do
          expect { click_button submit }.to change(User, :count).by(1)
        end

        describe "after saving the user" do
          before { click_button submit }
          let(:user) { User.find_by(email: "user@example.com") }

          it { is_expected.to have_link("Sign out") }
          it { is_expected.to have_title(user.name) }
          it { is_expected.to have_selector("div.alert.alert-success", text: "Welcome") }
        end
      end
    end
    context "edit" do
      let(:user) { create(:user) }
      before do
        sign_in(user)
        visit edit_user_path(user)
      end
      context "page" do
        it { is_expected.to have_content("Update your profile") }
        it { is_expected.to have_title("Edit user") }
        it { is_expected.to have_link("change", href: "http://gravatar.com/emails") }
      end

      context "with invalid information" do
        before { click_button "Save changes" }

        it { is_expected.to have_content("error") }
      end
      context "with valid information" do
        let(:new_name) { "New Name" }
        let(:new_email) { "new@example.com" }
        before do
          fill_in "Name", with: new_name
          fill_in "Email", with: new_email
          fill_in "Password", with: user.password
          fill_in "Confirm Password", with: user.password
          click_button "Save changes"
        end

        it { should have_title(new_name) }
        it { should have_selector("div.alert.alert-success") }
        it { should have_link("Sign out", href: signout_path) }
        specify { expect(user.reload.name).to eq new_name }
        specify { expect(user.reload.email).to eq new_email }
      end
    end
    describe "index" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in user
        visit users_path
      end

      it { should have_title("All users") }
      it { should have_content("All users") }

      it "should list each user" do
        User.all.each do |user|
          expect(page).to have_selector("li", text: user.name)
        end
      end

      describe "pagination" do

        before(:all) { 30.times { FactoryGirl.create(:user) } }
        after(:all)  { User.delete_all }

        it { should have_selector("div.pagination") }

        it "should list each user" do
          User.paginate(page: 1).each do |user|
            expect(page).to have_selector("li", text: user.name)
          end
        end
      end

      describe "delete links" do

        it { should_not have_link("delete") }

        describe "as an admin user" do
          let(:admin) { FactoryGirl.create(:admin) }
          before do
            sign_in admin
            visit users_path
          end

          it { should have_link("delete", href: user_path(User.first)) }
          it "should be able to delete another user" do
            expect do
              click_link("delete", match: :first)
            end.to change(User, :count).by(-1)
          end
          it { should_not have_link("delete", href: user_path(admin)) }
        end
      end

    end
  end
end
