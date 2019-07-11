# frozen_string_literal: true

require 'spec_helper'

RSpec.feature do
  describe 'Authentication' do

    subject { page }

    describe 'signin page' do
      before { visit signin_path }

      it { is_expected.to have_content('Sign in') }
      it { is_expected.to have_title('Sign in') }
      describe 'with invalid information' do
        before { click_button 'Sign in' }

        it { is_expected.to have_title('Sign in') }
        it { is_expected.to have_selector('div.alert.alert-error') }
      end

      describe 'with valid information' do
        let(:user) { create(:user) }
        before do
          fill_in 'Email', with: user.email.upcase
          fill_in 'Password', with: user.password
          click_button 'Sign in'
        end

        it { is_expected.to have_title(user.name) }
        it { is_expected.to have_link('Profile', href: user_path(user)) }
        it { is_expected.to have_link('Sign out', href: signout_path) }
        it { is_expected.not_to have_link('Sign in', href: signin_path) }
        describe 'after visiting another page' do
          before { click_link 'Home' }
          it { is_expected.not_to have_selector('div.alert.alert-error') }
        end
      end

      describe 'with invalid information' do
        before { click_button 'Sign in' }

        it { is_expected.to have_title('Sign in') }
        it { is_expected.to have_selector('div.alert.alert-error') }

      end
    end
  end
end
