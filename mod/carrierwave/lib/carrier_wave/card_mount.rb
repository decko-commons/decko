require "carrierwave"


module CarrierWave
  # Adapt carrierwave mount to cards.
  # We translate the active record hooks in
  # https://github.com/carrierwaveuploader/carrierwave/blob/v3.0.5/lib/carrierwave/orm/activerecord.rb
  # to card events.
  module CardMount
    include CarrierWave::Mount

    def uploaders
      Card.uploaders ||= {}
    end

    def uploader_options
      Card.uploader_options ||= {}
    end

    def mount_uploader column, uploader=nil, options={}, &block
      options[:mount_on] ||= :db_content
      super

      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        include CarrierWave::CardMount::Helper
  
        def attachment
          #{column}
        end

        event :store_#{column}_event, :finalize, when: :store_#{column}_event? do
          store_#{column}!
        end

        # remove files only if card has no history
        event :remove_#{column}_event, :finalize, on: :delete, when: :no_history? do
          remove_#{column}!
        end

        event :mark_remove_#{column}_false_event, :finalize, on: :update do
          mark_remove_#{column}_false
        end

        event :reset_previous_changes_for_#{column}_event, :finalize,
              when: :no_history? do
          reset_previous_changes_for_#{column}
        end

        event :remove_previously_stored_#{column}_event, :finalize, on: :update,
              when: :no_history? do
          remove_previously_stored_#{column}
        end

        # don't attempt to store coded images unless ENV specifies it
        def store_#{column}_event?
          !coded? || ENV["STORE_CODED_FILES"]
        end

        def store_attachment!
          set_specific.delete :#{column}
          store_#{column}!
        end

        def attachment_name
          "#{column}".to_sym
        end

        def #{column}=(new_file)
          return if new_file.blank? || identical_file?(new_file)
          self.selected_action_id = Time.now.to_i unless history?
          assign_file(new_file) { super }
        end

        def identical_file? new_file
          return false if new?

          ::File.identical? #{column}.file.to_file, new_file
        rescue StandardError
          false
        end

        def remote_#{column}_url=(url)
          assign_file(url) { super }
        end

        def assign_file file
          db_column = _mounter(:#{column}).serialization_column
          send(:"\#{db_column}_will_change!") unless duplicate?
          if web?
            self.content = file
          else
            send(:"#{column}_will_change!") unless duplicate?
            yield
          end
        end

        def remove_#{column}=(value)
          column = _mounter(:#{column}).serialization_column
          send(:"\#{column}_will_change!")
          super
        end

        def remove_#{column}!
          self.remove_#{column} = true
          write_#{column}_identifier
          self.remove_#{column} = false
          super
        end

        def #{column}_will_change!
          @#{column}_changed = true
          @#{column}_is_changing = true
        end

        def #{column}_is_changing?
          @#{column}_is_changing
        end

        def #{column}_changed?
          @#{column}_changed
        end
      RUBY
    end
  end

  # The temporary identifiers from Carrierwave's mounters kill CardMount;
  # We don't seem to need them.
  class Mounter
    def write_temporary_identifier
      # noop
    end
  end
end
