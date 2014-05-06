require 'spec_helper'

describe 'StaticPages' do

  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title))}
  end

  describe 'Home Page' do
    before { visit root_path }
    let(:heading) {'Sample App'}
    let(:page_title) {''}

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }

    describe "for signed in users" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "following/followers counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end

      describe "with feed" do
        before do
          FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
          visit root_path
        end
        it "should render the user's feed" do
          user.feed.each do |item|
            expect(page).to have_selector("li##{item.id}", text: item.content)
          end
        end
        context "containing 1 micropost" do
          it { should have_content("1 micropost") }
        end
        context "containing more than 1 micropost" do
          before do
            FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
            visit root_path
          end
          it { should have_content("#{user.feed.count} microposts") }
        end

      end
      describe "pagination" do
        before do
          31.times do |i|
            FactoryGirl.create(:micropost, user: user, content: "#{i}")
          end
          visit root_path
        end
        it { should have_selector('div.pagination') }

        it " should list each feed" do
          user.feed.paginate(page: 1).each do |feed|
            expect(page).to have_selector("li##{feed.id}", text: feed.content)
          end
        end

      end
    end
  end
  describe 'Help Page' do
    before { visit help_path }
    let(:heading) {'Help'}
    let(:page_title) {'Help'}

    it_should_behave_like "all static pages"
  end
  describe 'About Page' do
    before { visit about_path }
    let(:heading) {'About Us'}
    let(:page_title) {'About Us'}

    it_should_behave_like "all static pages"
  end
  describe 'Contact Page' do
    before { visit contact_path }
    let(:heading) {'Contact'}
    let(:page_title) {'Contact'}

    it_should_behave_like "all static pages"
  end
  it "Should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    click_link "Sign up now!"
    expect(page).to have_title(full_title('Sign up'))
    click_link "sample app"
    expect(page).to have_title(full_title(''))
  end
end
