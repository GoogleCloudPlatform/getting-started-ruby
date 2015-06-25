require "gcloud/pubsub"
require "sinatra"
require "slim"
require "yaml"

ENV["RACK_ENV"] ||= "development"

pubsub_config = YAML.load_file("pubsub.yml")[ENV["RACK_ENV"]]

Pubsub = Gcloud.pubsub pubsub_config["project_id"], pubsub_config["keyfile"]

get "/" do
  @messages = {}
  @topics = Pubsub.topics
  slim :index
end

post "/topics" do
  Pubsub.create_topic params[:name]
  redirect "/"
end

post %r{/topics/(.*)/subscriptions} do |topic_name|
  topic = Pubsub.find_topic topic_name
  topic.create_subscription params[:name]
  redirect "/"
end

post %r{/topics/(.*)/publish} do |topic_name|
  topic = Pubsub.find_topic topic_name
  topic.publish params[:message]
  redirect "/"
end

get %r{/subscriptions/(.*)/pull} do |subscription_name|
  subscription = Pubsub.find_subscription subscription_name
  messages = subscription.pull immediate: true, max: 100
  messages.each {|msg| msg.ack! }

  @messages = {}
  @messages[subscription_name] = messages.map {|msg| msg.message.data }
  @topics = Pubsub.topics
  slim :index
end

get "/_ah/health" do
  "ok"
end

__END__

@@ index
doctype html
html
  head
    title My Pub/Sub
    css:
      .topic {
        padding-left: 20px;
      }
      .subscription {
        padding-left: 20px;
      }
      fieldset {
        border-radius: 5px;
        border-color: #eee;
        margin: 10px 0;
      }
      legend {
        font-size: 15px;
        font-variant: small-caps;
      }

  body
    h1 Pub/Sub

    .topics
      fieldset
        legend Create Topic
        form method="post" action="/topics"
          input name="name" placeholder="Topic name"
          input type="submit" value="Create Topic"

      - if @topics.any?
        h2 Topics
        - @topics.each do |topic|
          .topic
            h3 = topic.name

            fieldset
              legend Publish Message
              form method="post" action="/topics/#{topic.name}/publish"
                input name="message" placeholder="Message text to publish"
                input type="submit" value="Publish"

            .subscriptions
              fieldset
                legend Create Subscription
                form method="post" action="/topics/#{topic.name}/subscriptions"
                  input name="name" placeholder="Subscription name"
                  input type="submit" value="Create Subscription"
                  
              - if topic.subscriptions.any?
                h4 Subscriptions
                - topic.subscriptions.each do |subscription|
                  .subscription
                    h5 = subscription.name

                    - if @messages.has_key? subscription.name
                      h6 Pulled Messages
                      - @messages[subscription.name].each do |message|
                        .message = message.to_s

                    fieldset
                      legend Pull Messages
                      form method="get" action="/subscriptions/#{subscription.name}/pull"
                        input type="submit" value="Pull Messages"    
