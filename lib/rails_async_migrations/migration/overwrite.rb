module RailsAsyncMigrations
  module Migration
    class Overwrite
      attr_reader :instance, :method_name

      def initialize(instance, method_name)
        @instance = instance
        @method_name = method_name
      end

      def perform
        dispatch_trace
        trigger_callback
      end

      private

      def dispatch_trace
        Tracer.new.verbose "#{instance.class}\##{method_name} was called in a locked state"
      end

      def trigger_callback
        if instance.class.method_defined? :trigger_callback
          instance.send(:trigger_callback, method_name)
        end
      end
    end
  end
end
