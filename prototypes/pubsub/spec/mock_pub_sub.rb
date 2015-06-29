# Mocking every Gcloud method that a particular action calls can be burdensome and brittle.
#
# Sometimes it's easier to create a fake implementation.
class MockPubSub
  attr_accessor :project_id, :topics, :subscriptions

  alias_method :project, :project_id

  def initialize project_id = "PROJECT-ID", keyfile = "KEYFILE"
    self.project_id = project_id
    self.topics = []
    self.subscriptions = []
  end

  def create_topic name
    topic = Topic.new self, "projects/#{project_id}/topics/#{name}"
    topics.push topic
    topic
  end

  def find_topic name
    topics.find {|topic| topic.name == name }
  end

  def find_subscription name
    subscriptions.find {|subscription| subscription.name == name }
  end

  class Topic
    attr_accessor :name, :subscriptions, :_project

    def initialize project, name
      self._project = project
      self.name = name
      self.subscriptions = []
    end

    def create_subscription name, endpoint: nil
      subscription = Subscription.new self, "projects/#{_project.project_id}/subscriptions/#{name}"
      subscription.endpoint = endpoint
      subscriptions.push subscription
      _project.subscriptions.push subscription
      subscription
    end

    def find_subscription name
      subscriptions.find {|sub| sub.name == name }
    end

    def publish data
      message = Message.new data

      subscriptions.each do |subscription|
        event = Event.new
        event.message = message
        event.subscription = subscription
        subscription._events[message.message_id] = event
      end

      nil
    end

    def delete
      _project.topics.delete self
    end
  end

  class Subscription
    attr_accessor :name, :topic, :endpoint, :_events

    def initialize topic, name
      self._events = {}
      self.topic = topic
      self.name = name
    end

    def pull options = {}
      _events.values
    end

    def delete
      topic._project.subscriptions.delete self
      topic.subscriptions.delete self
    end
  end

  class Event
    attr_accessor :message, :subscription

    def acknowledge!
      subscription._events.delete message.message_id
    end

    alias_method :ack!, :acknowledge!
  end

  class Message
    attr_accessor :data, :message_id

    def initialize data
      self.message_id = Message._next_id!
      self.data = data
    end

    def self._next_id!
      @id ||= 0
      @id += 1
    end
  end
end
