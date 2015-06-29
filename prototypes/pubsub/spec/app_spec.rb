require "spec_helper"

RSpec.describe "Pub/Sub Sample App" do
  include Capybara::DSL

  before do
    @pubsub = MockPubSub.new "project-id"
    allow(Gcloud).to receive(:pubsub) { @pubsub }

    @log = StringIO.new
    @logger = Logger.new @log
    allow(Logger).to receive(:new) { @logger }
  end

  it "show project with no topics" do
    expect(@pubsub.topics).to be_empty

    visit "/"

    expect(page).to have_content "There are no topics!"
  end

  it "list topics" do
    @pubsub.create_topic "my-messages"

    visit "/"

    expect(page).not_to have_content "There are no topics!"
    expect(page).to have_content "my-messages"
    expect(page).to have_content "projects/project-id/topics/my-messages has no subscriptions!"
  end

  it "lists topics' subscriptions" do
    topic = @pubsub.create_topic "my-messages"
    topic.create_subscription "subscription-1"
    topic.create_subscription "subscription-2"

    visit "/"
    
    expect(page).to have_content "projects/project-id/topics/my-messages"
    expect(page).to have_content "projects/project-id/subscriptions/subscription-1"
    expect(page).to have_content "projects/project-id/subscriptions/subscription-2"
  end

  it "can create topics" do
    expect(@pubsub.topics).to be_empty

    visit "/"
    within "form.new_topic" do
      fill_in "name", with: "my-first-topic"
      click_button "Create Topic"
    end

    expect(@pubsub.topics.length).to eq 1
    expect(@pubsub.topics.first.name).to eq "projects/project-id/topics/my-first-topic"
  end

  it "can create subscriptions" do
    topic = @pubsub.create_topic "my-topic"
    expect(topic.subscriptions).to be_empty

    visit "/"
    within "form.new_subscription" do
      fill_in "name", with: "my-first-subscription"
      click_button "Create Subscription"
    end

    expect(topic.subscriptions.length).to eq 1
    expect(topic.subscriptions.first.name).to eq "projects/project-id/subscriptions/my-first-subscription"
  end

  it "can publish messages to topics" do
    topic = @pubsub.create_topic "my-topic"
    subscription = topic.create_subscription "my-subscription"
    expect(subscription.pull).to be_empty

    visit "/"
    within "form.publish_message" do
      fill_in "message", with: "hello!"
      click_button "Publish"
    end

    events = subscription.pull
    expect(events.length).to eq 1
    expect(events.first.message.data).to eq "hello!"
  end

  it "can pull messages from topics' subscriptions" do
    topic = @pubsub.create_topic "my-topic"
    subscription = topic.create_subscription "my-subscription"
    topic.publish "Hello from Message!"

    visit "/"

    expect(page).not_to have_content "Pulled Messages"
    expect(page).not_to have_content "Hello from Message!"

    click_button "Pull Messages"

    expect(page).to have_content "Pulled Messages (1)"
    expect(page).to have_content "Hello from Message!"
  end

  it "can create Push subscriptions" do
    topic = @pubsub.create_topic "my-topic"
    expect(topic.subscriptions).to be_empty

    visit "/"
    within "form.new_subscription" do
      fill_in "name", with: "my-first-subscription"
      choose "Push"
      click_button "Create Subscription"
    end

    expect(topic.subscriptions.length).to eq 1
    expect(topic.subscriptions.first.name).to eq "projects/project-id/subscriptions/my-first-subscription"
    expect(topic.subscriptions.first.endpoint).
      to eq "http://www.example.com/subscriptions/projects/project-id/subscriptions/my-first-subscription/message"
  end

  it "can delete subscriptions" do
    topic = @pubsub.create_topic "my-topic"
    subscription = topic.create_subscription "my-subscription"
    expect(topic.subscriptions.length).to eq 1

    visit "/"
    within ".subscription form.delete" do
      click_button "X"
    end

    expect(topic.subscriptions.length).to eq 0
  end

  it "can delete topics" do
    topic = @pubsub.create_topic "my-topic"
    expect(@pubsub.topics.length).to eq 1

    visit "/"
    within ".topic form.delete" do
      click_button "X"
    end

    expect(@pubsub.topics.length).to eq 0
  end
  
  describe "Push messages" do
    include Rack::Test::Methods

    def app() Capybara.app end

    it "can receive Push messages" do
      topic = @pubsub.create_topic "my-topic"
      subscription = topic.create_subscription "my-subscription", endpoint:
        "http://www.example.com/subscriptions/projects/project-id/subscriptions/my-first-subscription/message"

      message = { message: { message_id: 123, data: Base64.encode64("hi there!") }}

      post "/subscriptions/projects/project-id/subscriptions/my-first-subscription/message", message.to_json

      expect(@log.string).to include 'Message (123) "hi there!"'
    end
  end
end
