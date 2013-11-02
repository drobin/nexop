module Nexop
  module Handler
    ##
    # Module performs the kex-exchange for a SSH connection.
    #
    # @see http://tools.ietf.org/html/rfc4253#section-7
    class Kex < Handler::Base
      include Log

      def initialize(keystore, send_method)
        super(send_method)
        @keystore = keystore
      end

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
      # Guesses the
      # {Message::KexInit#encryption_algorithms_client_to_server encryption algorithm}
      # used by the session.
      #
      # @param direction [:c2s, :s2c] Specifies the direction of the
      #        communication. Can be either _client to server_ (`:c2s`) or
      #        _server to client_ (:s2c).
      # @return [String] The encryption algorithm which should be used by
      #         the session for the given `direction`.
      def guess_encryption_algorithm(direction)
        method = case direction
        when :c2s then :encryption_algorithms_client_to_server
        when :s2c then :encryption_algorithms_server_to_client
        else raise ArgumentError, "invalid direction: #{direction}"
        end

        kex_init(:c2s).send(method).select do |alg|
          kex_init(:s2c).send(method).include?(alg)
        end.first
      end

      ##
      # Guesses the
      # {Message::KexInit#mac_algorithms_client_to_server MAC algorithm} used
      # by the session.
      #
      # @param direction [:c2s, :s2c] Specifies the direction of the
      #        communication. Can be either _client to server_ (`:c2s`) or
      #        _server to client_ (:s2c).
      # @return [String] The MAC algorithm which should be used by the
      #         session for the given `direction`.
      def guess_mac_algorithm(direction)
        method = case direction
        when :c2s then :mac_algorithms_client_to_server
        when :s2c then :mac_algorithms_server_to_client
        else raise ArgumentError, "invalid direction: #{direction}"
        end

        kex_init(:c2s).send(method).select do |alg|
          kex_init(:s2c).send(method).include?(alg)
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

      def tick(payload)
        @kex_step ||= 1

        case @kex_step
        when 1
          # step 1: receive SSH_MSG_KEXINIT from the client and send back the own one
          c2s = Message::KexInit.parse(payload)
          s2c = kex_init(:s2c)

          receive_kex_init(c2s)
          @kex_step = @kex_step + 1 # advance to next step

          return s2c
        when 2
          # step 2: receive SSH_MSG_KEXDH_INIT and send back SSH_MSG_KEXDH_REPLY
          dh_init = Message::KexdhInit.parse(payload)

          @dh_reply = Message::KexdhReply.new
          @dh_reply.hostkey = @hostkey
          @dh_reply.kex_algorithm = "diffie-hellman-group14-sha1"
          @dh_reply.e = dh_init.e
          @dh_reply.calc_H(@v_c, @v_s, kex_init(:c2s).serialize, kex_init(:s2c).serialize)

          @kex_step = @kex_step + 1 # advance to the next step

         return @dh_reply
        when 3
          # step 3: receive and send SSH_MSG_NEWKEYS
          msg = Message::NewKeys.parse(payload)
          make_finish

          return msg
        end
      end

      def finalize
        @keystore.keys!(@dh_reply.exchange_hash, @dh_reply.shared_secret)

        [ :c2s, :s2c ].each do |direction|
          enc_alg = guess_encryption_algorithm(direction)
          mac_alg = guess_mac_algorithm(direction)

          log.debug("encryption_algorithm[#{direction}]: #{enc_alg}")
          log.debug("mac_algorithm[#{direction}]: #{mac_alg}")
          @keystore.algorithms!(direction, enc_alg, mac_alg)
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
