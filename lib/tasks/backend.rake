require "fileutils"

namespace :backend do

  BACKEND_FILES = %w[
    config/application.rb
    app/models/book.rb
    app/controllers/books_controller.rb
  ]

  desc "Use Google Cloud Datastore backend"
  task datastore: :environment do
    backend_root = "structured_data/datastore"

    BACKEND_FILES.each do |file|
      puts "Copy #{backend_root}/#{file}"
      FileUtils.cp Rails.root.join(backend_root, file), Rails.root.join(file)
    end
  end

  desc "Use ActiveRecord SQL database backend"
  task active_record: :environment do
    backend_root = "structured_data/active_record"

    BACKEND_FILES.each do |file|
      puts "Copy #{backend_root}/#{file}"
      FileUtils.cp Rails.root.join(backend_root, file), Rails.root.join(file)
    end
  end

end
