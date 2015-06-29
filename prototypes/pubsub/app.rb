require "gcloud/pubsub"
require "sinatra"
require "slim"
require "yaml"
require "json"
require "base64"
require_relative "app_engine_https"

ENV["RACK_ENV"] ||= "development"

use AppEngineHttps

before do
  if File.directory? "/var/log/app_engine/custom_logs"
    @logger = Logger.new("/var/log/app_engine/custom_logs/application.log", File::WRONLY | File::APPEND)
  else
    @logger = Logger.new(STDOUT)
  end

  @pubsub ||= begin
    config = YAML.load_file("pubsub.yml")[ENV["RACK_ENV"]]
    Gcloud.pubsub config["project_id"], config["keyfile"]
  end
end

get "/" do
  @messages = {}
  @topics = @pubsub.topics
  slim :index
end

post "/topics" do
  @pubsub.create_topic params[:name]
  redirect "/"
end

post %r{/topics/(.*)/subscriptions} do |topic_name|
  topic = @pubsub.find_topic topic_name
  if params[:type] == "pull"
    topic.create_subscription params[:name]
    @logger.info "Create Pull subscription #{params[:name]}"
  else
    subscription_name = File.join "projects", @pubsub.project, "subscriptions", params[:name]
    # POST /subscriptions/:name/message
    push_endpoint = File.join request.base_url, "subscriptions", subscription_name, "message"
    topic.create_subscription params[:name], endpoint: push_endpoint
    @logger.info "Create Push subscription #{params[:name]} to #{push_endpoint}"
  end
  redirect "/"
end


post %r{/topics/(.*)/publish} do |topic_name|
  topic = @pubsub.find_topic topic_name
  topic.publish params[:message]
  @logger.info "Published message for topic #{topic_name}: #{params[:message].inspect}"
  redirect "/"
end

delete %r{/topics/(.*)} do |topic_name|
  topic = @pubsub.find_topic topic_name
  topic.delete
  redirect "/"
end

get %r{/subscriptions/(.*)/pull} do |subscription_name|
  subscription = @pubsub.find_subscription subscription_name
  messages = subscription.pull immediate: true, max: 100
  messages.each {|msg| msg.ack! }

  @messages = {}
  @messages[subscription_name] = messages.map {|msg| msg.message.data }

  @logger.info "Pulled messages for subscription #{subscription_name}"
  @logger.info @messages.inspect

  @topics = @pubsub.topics
  slim :index
end

delete %r{/subscriptions/(.*)} do |subscription_name|
  subscription = @pubsub.find_subscription subscription_name
  subscription.delete
  redirect "/"
end

post %r{/subscriptions/(.*)/message} do |subscription_name|
  @logger.info "Push Message received for subscription #{subscription_name}"
  message = JSON.parse request.body.read
  id = message["message"]["message_id"]
  data = Base64.decode64 message["message"]["data"]
  @logger.info "Message (#{id}) #{data.inspect}"
  status 102
  "ok"
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
      fieldset input[type=submit] {
        margin-left: 10px;
      }
      form.delete {
        float: left;
        margin-right: 5px;
      }
      form.delete input[type=submit] {
        border: none;
        background-color: inherit;
        color: blue;
        cursor: pointer;
      }

  body
    h1 Pub/Sub

    .topics
      fieldset
        legend Create Topic
        form.new_topic method="post" action="/topics"
          input name="name" placeholder="Topic name"
          input type="submit" value="Create Topic"

      - if @topics.none?
        p There are no topics!
      - else
        h2 Topics
        - @topics.each do |topic|
          .topic
            form.delete method="post" action="/topics/#{topic.name}"
              input type="hidden" name="_method" value="delete"
              input type="submit" value="X"
            h3 = topic.name

            - if topic.subscriptions.any?
              fieldset
                legend Publish Message
                form.publish_message method="post" action="/topics/#{topic.name}/publish"
                  input name="message" placeholder="Message text to publish"
                  input type="submit" value="Publish"

            .subscriptions
              fieldset
                legend Create Subscription
                form.new_subscription method="post" action="/topics/#{topic.name}/subscriptions"
                  input name="name" placeholder="Subscription name"
                  label
                    input type="radio" name="type" value="pull" checked="true"
                    | Pull
                  label
                    input type="radio" name="type" value="push"
                    | Push
                  input type="submit" value="Create Subscription"
                  
              - if topic.subscriptions.none?
                p #{topic.name} has no subscriptions!
              - else
                h4 Subscriptions
                - topic.subscriptions.each do |subscription|
                  .subscription
                    form.delete method="post" action="/subscriptions/#{subscription.name}"
                      input type="hidden" name="_method" value="delete"
                      input type="submit" value="X"
                    h5 = subscription.name

                    - if @messages.has_key? subscription.name
                      h6 Pulled Messages (#{@messages[subscription.name].length})
                      ul.messages
                        - @messages[subscription.name].each do |message|
                          li.message
                            pre = message.to_s

                    - if subscription.endpoint
                      p
                        | View Pushed messages in the Google Developer Console 
                        a href="https://console.developers.google.com/project/#{@pubsub.project}/logs?logName=appengine.googleapis.com%2Fcustom.var.log.app_engine.app.custom_logs.application.log" Logs Viewer
                    - else
                      fieldset
                        legend Pull Messages
                        form method="get" action="/subscriptions/#{subscription.name}/pull"
                          input type="submit" value="Pull Messages"    
