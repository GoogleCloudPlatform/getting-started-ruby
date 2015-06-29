require "spec_helper"

RSpec.describe MockPubSub do

  it "has a project ID" do
    pubsub = MockPubSub.new "the-project-id"
    expect(pubsub.project).to eq "the-project-id"
  end

  it "can accept a project ID and keyfile" do
    pubsub = MockPubSub.new "my-project-id", "key-file.json"
    expect(pubsub.project).to eq "my-project-id"
  end

  it "has no topics" do
    expect(MockPubSub.new.topics).to be_empty
  end

  it "can create and list topics" do
    pubsub = MockPubSub.new "the-project"
    expect(MockPubSub.new.topics).to be_empty

    pubsub.create_topic "my-topic"

    expect(pubsub.topics).not_to be_empty
    expect(pubsub.topics.length).to eq 1
    expect(pubsub.topics.first.name).to eq "projects/the-project/topics/my-topic"
  end

  it "can find topic for project" do
    pubsub = MockPubSub.new "the-project"
    expect(pubsub.find_topic("my-topic")).to be_nil

    pubsub.create_topic "my-topic"

    expect(pubsub.find_topic("projects/the-project/topics/my-topic")).not_to be_nil
    expect(pubsub.find_topic("projects/the-project/topics/my-topic").name).to eq "projects/the-project/topics/my-topic"
  end

  it "can create and list subscriptions for topics" do
    pubsub = MockPubSub.new "the-project"
    topic = pubsub.create_topic "my-topic"
    expect(topic.subscriptions).to be_empty

    topic.create_subscription "my-subscription"

    expect(topic.subscriptions).not_to be_empty
    expect(topic.subscriptions.length).to eq 1
    expect(topic.subscriptions.first.name).to eq "projects/the-project/subscriptions/my-subscription"
  end

  it "can find subscription for topic" do
    pubsub = MockPubSub.new "the-project"
    topic = pubsub.create_topic "my-topic"
    expect(topic.find_subscription("projects/the-project/subscriptions/my-subscription")).to be_nil

    topic.create_subscription "my-subscription"
    
    expect(topic.find_subscription("projects/the-project/subscriptions/my-subscription")).not_to be_nil
    expect(topic.find_subscription("projects/the-project/subscriptions/my-subscription").name).
      to eq "projects/the-project/subscriptions/my-subscription"
  end

  it "can find subscription for project" do
    pubsub = MockPubSub.new "the-project"
    topic = pubsub.create_topic "my-topic"
    expect(pubsub.find_subscription("projects/the-project/subscriptions/my-subscription")).to be_nil

    topic.create_subscription "my-subscription"

    expect(topic.find_subscription("projects/the-project/subscriptions/my-subscription").name).
      to eq "projects/the-project/subscriptions/my-subscription"
  end

  it "can pull published messages from subscriptions" do
    pubsub = MockPubSub.new "the-project"
    topic = pubsub.create_topic "my-topic"
    subscription = topic.create_subscription "my-subscription"

    expect(subscription.pull).to be_empty

    topic.publish "hello!"

    events = subscription.pull

    expect(events.length).to eq 1
    expect(events.first.message.data).to eq "hello!"
  end

  it "acknowledged messages are not returned again" do
    pubsub = MockPubSub.new "the-project"
    topic = pubsub.create_topic "my-topic"
    subscription = topic.create_subscription "my-subscription"

    topic.publish "hello!"

    events = subscription.pull
    expect(events.length).to eq 1

    events = subscription.pull
    expect(events.length).to eq 1

    events.first.ack!

    events = subscription.pull
    expect(events.length).to eq 0
  end

  it "different subscriptions pull messages separately" do
    pubsub = MockPubSub.new "the-project"
    topic = pubsub.create_topic "my-topic"
    subscription1 = topic.create_subscription "subscription-1"
    subscription2 = topic.create_subscription "subscription-2"

    topic.publish "hello!"

    expect(subscription1.pull.length).to eq 1
    expect(subscription2.pull.length).to eq 1

    subscription1.pull.each {|event| event.ack! }

    expect(subscription1.pull.length).to eq 0
    expect(subscription2.pull.length).to eq 1

    subscription2.pull.each {|event| event.ack! }

    expect(subscription1.pull.length).to eq 0
    expect(subscription2.pull.length).to eq 0
  end

  it "can delete subscriptions" do
    pubsub = MockPubSub.new "the-project"
    topic = pubsub.create_topic "my-topic"
    subscription = topic.create_subscription "my-subscription"
    
    expect(pubsub.subscriptions.length).to eq 1
    expect(topic.subscriptions.length).to eq 1

    subscription.delete
    
    expect(topic.subscriptions.length).to eq 0
    expect(pubsub.subscriptions.length).to eq 0
  end

  it "can delete topics" do
    pubsub = MockPubSub.new "the-project"
    topic = pubsub.create_topic "my-topic"
    
    expect(pubsub.topics.length).to eq 1

    topic.delete
    
    expect(pubsub.topics.length).to eq 0
  end

  it "can create push subscription" do
    pubsub = MockPubSub.new "the-project"
    topic = pubsub.create_topic "my-topic"

    pull_subscription = topic.create_subscription "pull-subscription"
    expect(pull_subscription.endpoint).to be_nil
    
    push_subscription = topic.create_subscription "push-subscription", endpoint: "https://some-host/path"
    expect(push_subscription.endpoint).to eq "https://some-host/path"
  end

end
