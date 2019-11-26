require "google/cloud/firestore"
require "rack/session/abstract/id"

module Rack
  module Session
    class FirestoreSession < Abstract::Persisted
      def initialize app, options = {}
        super

        @firestore = Google::Cloud::Firestore.new
        @col = @firestore.col "sessions"
      end

      def find_session req, session_id
        return [generate_sid, {}] if session_id.nil?

        doc = @col.doc session_id
        fields = doc.get.fields || {}
        [session_id, stringify_keys(fields)]
      end

      def write_session req, session_id, new_session, _opts
        doc = @col.doc session_id
        doc.set new_session, merge: true
        session_id
      end

      def delete_session req, session_id, _opts
        doc = @col.doc session_id
        doc.delete
        generate_sid
      end

      def stringify_keys hash
        new_hash = {}
        hash.each do |k, v|
          if v.is_a? Hash
            new_hash[k.to_s] = stringify_keys v
          else
            new_hash[k.to_s] = v
          end
        end
        new_hash
      end
    end
  end
end
