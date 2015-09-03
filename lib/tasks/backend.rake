require "fileutils"

namespace :backend do

  BACKEND_FILES = %w[
    config/application.rb
    app/models/book.rb
    app/controllers/books_controller.rb
  ]

  def use_backend name
    backend_root = "structured_data/#{name}"

    BACKEND_FILES.each do |file|
      puts "#{backend_root}/#{file} -> #{file}"
      FileUtils.cp Rails.root.join(backend_root, file), Rails.root.join(file)
    end
  end

  desc "Use Google Cloud Datastore backend"
  task datastore: :environment do
    use_backend :datastore
  end

  desc "Use ActiveRecord SQL database backend"
  task active_record: :environment do
    use_backend :active_record
  end

end
