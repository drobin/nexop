module Nexop
  module Handler
    ##
    # Module performs the kex-exchange for a SSH connection.
    #
    # @see http://tools.ietf.org/html/rfc4253#section-7
    class Kex < Handler::Base
      ##
      # Returns the {Message::KexInit} message for the requested direction.
      #
      # The direction can be either `:c2s` or `:s2c`:
      #
      # - `:c2s`: (_client to server_) The {Message::KexInit} message received
      #   from the ciient. The message can be assigned with {#receive_kex_init}.
      # - `:s2c`: (_server to client_) The {Message::KexInit} message send to
      #   client. The module provides the message and cannot be changed from
      #   outside.
      #
      # @param direction [:c2s, :s2c] The requested direction
      # @return [Message::KexInit] The requested message
      # @raise [ArgumentError] if the `direction` is neither `:c2s` or `:s2c`.
      def kex_init(direction)
        case direction
        when :c2s then @kex_init_c2s
        when :s2c then build_kex_init_s2c
        else raise ArgumentError, "either :c2s or :s2c expected"
        end
      end

      ##
      # Assigns the {Message::KexInit} message received from client to the
      # protocol handler.
      #
      # The message can be fetched again with {#kex_init}`(:c2s)`.
      def receive_kex_init(msg)
        @kex_init_c2s = msg
      end

      ##
      # Guesses the {Message::KexInit#kex_algorithms kex algorithm} used by
      # the session.
      #
      # @return [String] The kex algorithm which should be used by the
      #         session.
      def guess_kex_algorithm
        c2s = kex_init(:c2s)
        s2c = kex_init(:s2c)

        if c2s.kex_algorithms.first == s2c.kex_algorithms.first
          return c2s.kex_algorithms.first
        end

        c2s.kex_algorithms.select do |alg|
          kex_init(:s2c).kex_algorithms.include?(alg)
        end.first
      end

      ##
      # Prepares the handler with all information used by the
      # protocol-handshake.
      #
      # @param hostkey [Hostkey] The hostkey
      # @param v_c [String] client identification string
      # @param v_s [String] server identification string
      # @return [Kex]
      def prepare(hostkey, v_c, v_s)
        @hostkey = hostkey
        @v_c = v_c
        @v_s = v_s
        self
      end

      ##
      # Session-tick implementation for the key-exchange.
      #
      # The method should be called by the session as long as `true` is
      # returned.
      #
      # @param payload [String] A binary string contains the payload of a
      #        packet.
      # @return [Boolean] As long as `true` is returned, the key exchange is
      #         still active and the method should be called again. If `false`
      #         is returned, then the key exchange is complete and you can
      #         switch to the next session-state.
      def tick_kex(payload)
        @kex_step ||= 1

        case @kex_step
        when 1
          # step 1: receive SSH_MSG_KEXINIT from the client and send back the own one
          c2s = Message::KexInit.parse(payload)
          s2c = kex_init(:s2c)

          receive_kex_init(c2s)
          send_message(s2c)

          @kex_step = @kex_step + 1

          true # continue with key exchange
        when 2
          # step 2: receive SSH_MSG_KEXDH_INIT and send back SSH_MSG_KEXDH_REPLY
          dh_init = Message::KexdhInit.parse(payload)

          dh_reply = Message::KexdhReply.new
          dh_reply.hostkey = @hostkey
          dh_reply.kex_algorithm = "diffie-hellman-group14-sha1"
          dh_reply.e = dh_init.e
          dh_reply.calc_H(@v_c, @v_s, kex_init(:c2s).serialize, kex_init(:s2c).serialize)

          send_message(dh_reply)

          @kex_step = @kex_step + 1

          true # continue with the key exchange
        when 3
          # step 3: receive and send SSH_MSG_NEWKEYS
          msg = Message::NewKeys.parse(payload)
          send_message(msg)

          false # nothing else to do, quit key exchange
        else
          # nothing else to do, quit key exchange
          false
        end
      end

      private

      def build_kex_init_s2c
        unless @kex_init_s2c
          @kex_init_s2c = Message::KexInit.new
          @kex_init_s2c.kex_algorithms = [ "diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1" ]
          @kex_init_s2c.server_host_key_algorithms = [ "ssh-rsa" ]
          @kex_init_s2c.encryption_algorithms_client_to_server = [ "3des-cbc" ]
          @kex_init_s2c.encryption_algorithms_server_to_client = [ "3des-cbc" ]
          @kex_init_s2c.mac_algorithms_client_to_server = [ "hmac-sha1" ]
          @kex_init_s2c.mac_algorithms_server_to_client = [ "hmac-sha1" ]
          @kex_init_s2c.compression_algorithms_client_to_server = [ "none" ]
          @kex_init_s2c.compression_algorithms_server_to_client = [ "none" ]
        end

        @kex_init_s2c
      end
    end
  end
end
