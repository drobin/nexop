class Nexop::Message::KexInit < Nexop::Message::Base
  SSH_MSG_KEXINIT = 20

  add_field(:type, type: :byte, const: SSH_MSG_KEXINIT)
  add_field(:cookie, type: :byte_16, default: Array.new(16, 0))

  ##
  # @!attribute [r] kex_algorithms
  # @return [Array] The key exchange method specifies how one-time session keys
  #         are generated for encryption and for authentication, and how the
  #         server  authentication is done.
  add_field(:kex_algorithms, type: :name_list, default: [])
  add_field(:server_host_key_algorithms, type: :name_list, default: [])

  ##
  # @!attribute [r] encryption_algorithms_client_to_server
  # @return [Array] A name-list of acceptable symmetric encryption algorithms
  #         in order of preference to be used for the client to server
  #         communication.
  add_field(:encryption_algorithms_client_to_server, type: :name_list, default: [])

  ##
  # @!attribute [r] encryption_algorithms_server_to_client
  # @return [Array] A name-list of acceptable symmetric encryption algorithms
  #         in order of preference to be used for the server to client
  #         communication.
  add_field(:encryption_algorithms_server_to_client, type: :name_list, default: [])

  ##
  # @!attribute [r] mac_algorithms_client_to_server
  # @return [Array] A name-list of acceptable MAC algorithms in order of
  #         preference to be used for the client to server communication.
  add_field(:mac_algorithms_client_to_server, type: :name_list, default: [])

  ##
  # @!attribute [r] mac_algorithms_server_to_client
  # @return [Array] A name-list of acceptable MAC algorithms in order of
  #         preference to be used for the server to client communication.
  add_field(:mac_algorithms_server_to_client, type: :name_list, default: [])
  add_field(:compression_algorithms_client_to_server, type: :name_list, default: [])
  add_field(:compression_algorithms_server_to_client, type: :name_list, default: [])
  add_field(:languages_client_to_server, type: :name_list, default: [])
  add_field(:languages_server_to_client, type: :name_list, default: [])
  add_field(:first_kex_packet_follows, type: :boolean, default: false)
  add_field(:reserved, type: :uint32, const: 0)
end
