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

      let(:user) { create(:user) }
      let!(:m1) { create(:micropost, user: user, content: "Foo") }
      let!(:m2) { create(:micropost, user: user, content: "Bar") }

      before { visit user_path(user) }

      it { is_expected.to have_content(user.name) }
      it { is_expected.to have_title(user.name) }

      describe "follow/unfollow buttons" do
        let(:other_user) { FactoryGirl.create(:user) }
        before { sign_in user }

        describe "following a user" do
          before { visit user_path(other_user) }

          it "should increment the followed user count" do
            expect do
              click_button "Follow"
            end.to change(user.followed_users, :count).by(1)
          end

          it "should increment the other user's followers count" do
            expect do
              click_button "Follow"
            end.to change(other_user.followers, :count).by(1)
          end

          describe "toggling the button" do
            before { click_button "Follow" }
            it { is_expected.to have_xpath("//input[@value='Unfollow']") }
          end
        end

        describe "unfollowing a user" do
          before do
            user.follow!(other_user)
            visit user_path(other_user)
          end

          it "should decrement the followed user count" do
            expect do
              click_button "Unfollow"
            end.to change(user.followed_users, :count).by(-1)
          end

          it "should decrement the other user's followers count" do
            expect do
              click_button "Unfollow"
            end.to change(other_user.followers, :count).by(-1)
          end

          describe "toggling the button" do
            before { click_button "Unfollow" }
            it { should have_xpath("//input[@value='Follow']") }
          end
        end
      end
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
        after(:all) { User.delete_all }

        it { should have_selector("div.pagination") }

        it "should list each user" do
          User.paginate(page: 1).each do |user|
            expect(page).to have_selector("li", text: user.name)
          end
        end
      end

      describe "delete links" do

        it { is_expected.not_to have_link("delete") }

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
          it { is_expected.not_to have_link("delete", href: user_path(admin)) }
        end
      end

    end

    describe "following/followers" do
      let(:user) { FactoryGirl.create(:user) }
      let(:other_user) { FactoryGirl.create(:user) }
      before { user.follow!(other_user) }

      describe "followed users" do
        before do
          sign_in user
          visit following_user_path(user)
        end

        it { is_expected.to have_title(full_title("Following")) }
        it { is_expected.to have_selector("h3", text: "Following") }
        it { is_expected.to have_link(other_user.name, href: user_path(other_user)) }
      end

      describe "followers" do
        before do
          sign_in other_user
          visit followers_user_path(other_user)
        end

        it { is_expected.to have_title(full_title("Followers")) }
        it { is_expected.to have_selector("h3", text: "Followers") }
        it { is_expected.to have_link(user.name, href: user_path(user)) }
      end
    end

    describe "micropost associations" do
      let(:user) { FactoryGirl.create(:user) }
      before { user.save }
      subject { user }
      let!(:older_micropost) do
        FactoryGirl.create(:micropost, user: user, created_at: 1.day.ago)
      end
      let!(:newer_micropost) do
        FactoryGirl.create(:micropost, user: user, created_at: 1.hour.ago)
      end
      describe "status" do
        let(:unfollowed_post) do
          FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
        end
        let(:followed_user) { FactoryGirl.create(:user) }

        before do
          user.follow!(followed_user)
          3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
        end

        its(:feed) { is_expected.to include(newer_micropost) }
        its(:feed) { is_expected.to include(older_micropost) }
        its(:feed) { is_expected.not_to include(unfollowed_post) }
        its(:feed) do
          followed_user.microposts.each do |micropost|
            should include(micropost)
          end
        end
      end
    end
  end
end
