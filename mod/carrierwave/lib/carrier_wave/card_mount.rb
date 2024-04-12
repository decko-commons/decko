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
        event :write_#{column}_identifier_event, :prepare_to_store do
          write_#{column}_identifier
        end

        event :store_#{column}_event, :finalize,
              when: :store_#{column}_event? do
          store_#{column}!
        end

        # remove files only if card has no history
        event :remove_#{column}_event, :finalize,
              on: :delete, when: proc { |c| !c.history? } do
          remove_#{column}!
        end

        # event :mark_remove_#{column}_false_event, :finalize, on: :update do
        #   mark_remove_#{column}_false
        # end

        event :reset_previous_changes_for_#{column}_event, :store,
              when: proc { |c| !c.history? } do
          reset_previous_changes_for_#{column}
        end

        event :remove_previously_stored_#{column}_event, :finalize,
              on: :update, when: proc { |c| !c.history?} do
          remove_previously_stored_#{column}
        end

        # don't attempt to store coded images unless ENV specifies it
        def store_#{column}_event?
          !coded? || ENV["STORE_CODED_FILES"]
        end

        def attachment
          #{column}
        end

        def store_attachment!
          set_specific.delete :#{column}
          store_#{column}!
        end

        def attachment_name
          "#{column}".to_sym
        end

        def read_uploader *args
          read_attribute *args
        end

        def write_uploader *args
          write_attribute *args
        end

        def #{column}=(new_file)
          return if new_file.blank?
          self.selected_action_id = Time.now.to_i unless history?
          assign_file(new_file) { super }
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

        def serializable_hash(opts=nil)
          except = opts&.dig(:except) && Array.wrap(opts[:except]).map(&:to_s)
          only = opts&.dig(:only) && Array.wrap(opts[:only]).map(&:to_s)

          self.class.uploaders.each_with_object(super(opts)) do |(column, uploader), hash|
            if (!only && !except) ||
               (only && only.include?(column.to_s)) ||
               (!only && except && !except.include?(column.to_s))
              hash[column.to_s] = _mounter(column).uploader.serializable_hash
            end
          end
        end
      RUBY
    end
  end
end
