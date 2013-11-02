module Nexop
  module Handler
    ##
    # Base class for all handler running on a {Session}.
    class Base
      def initialize
        @finished = false
      end

      ##
      # Tests whether the handler has finished its operation.
      #
      # @return [Boolean] If `true` is returned, then the handler has
      #         finished its operation and no more invocation of {#tick} are
      #         required.
      # @see #finished=
      def finished?
        @finished ||= false
      end

      ##
      # Performs a single step of the handler.
      #
      # The handler should consume the `payload` (if present) and produce
      # some output. Depending on the service and the state of the service
      # the `payload` can be empty!
      #
      # The output can be:
      #
      # - {Message::Base}: A single message which should be send back to the
      #   client.
      # - `Array` of {Message::Base}: The `tick` operation results into more
      #   than one packet, which are all serialized and send back to the
      #   client.
      # - `false`: This is a `NOOP`. The handler should still be active but
      #   currently produces no output.
      # - If a {SessionError} is raised, then the handler results into an
      #   abnormal situation and the session will be destroyed.
      #
      # If {#finished?} succeeds, then the handler has finished its
      # operation. Any message returned by the `tick`-implementation is the
      # last message send to the client.
      #
      # @param payload [String] The payload (raw message data) the handler
      #        should consume.
      # @return [Message::Base, Array] A {Message::Base message} or an
      #         array of {Message::Base messages}, which should be send to
      #         the client.
      # @return [false] The method-invocation is interpreted as a `NOOP`.
      # @raise [SessionError] The handler results into an abnormal situation
      #        and the session will be destroyed.
      def tick(payload)
        raise NotImplementedError, "must be implemented"
      end

      ##
      # Handler finalization.
      #
      # The method is invoked after the last {#tick}-invocation, when
      # {#finished?} returns true and the remaining messages where send to
      # the client.
      #
      # @raise [SessionError] The handler results into an abnormal situation
      #        and the session will be destroyed.
      def finalize
      end

      protected

      ##
      # Updates the {#finished?}-flag.
      def make_finish
        @finished = true
      end
    end
  end
end
