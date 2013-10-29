require 'spec_helper'

describe Nexop::Keystore do
  let(:keystore) { Nexop::Keystore.new }

  context "encryption_algorithm" do
    [ :c2s, :s2c ].each do |direction|
      it "is NONE by default for #{direction}" do
        keystore.encryption_algorithm(direction).should == Nexop::EncryptionAlgorithm::NONE
      end
    end

    it "only accepts :c2s and :s2c" do
      expect{ keystore.encryption_algorithm(:xxx) }.to raise_error(ArgumentError)
    end
  end

  context "mac_algorithm" do
    [ :c2s, :s2c ].each do |direction|
      it "is NONE by default for #{direction}" do
        keystore.mac_algorithm(direction).should == Nexop::MacAlgorithm::NONE
      end
    end

    it "only accepts :c2s and :s2c" do
      expect{ keystore.mac_algorithm(:xxx) }.to raise_error(ArgumentError)
    end
  end

  context "exchange_hash" do
    it "is nil be default" do
      keystore.exchange_hash.should be_nil
    end
  end

  context "session_id" do
    it "is nil by default" do
      keystore.session_id.should be_nil
    end
  end

  context "shared_secret" do
    it "is nil by default" do
      keystore.shared_secret.should be_nil
    end
  end

  context "encryption_key" do
    [ :c2s, :s2c ].each do |direction|
      it "is nil by default for #{direction}" do
        keystore.encryption_key(direction).should be_nil
      end

      it "is nil when you have some keys but no algorithm for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.encryption_key(direction).should be_nil
      end

      it "is nil when you have an algorithm but no keys for #{direction}" do
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::NONE)
        keystore.encryption_key(direction).should be_nil
      end

      it "calculates a key for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::NONE)
        keystore.encryption_key(direction).should_not be_nil
      end

      it "returns the same key once calculated for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::NONE)
        key = keystore.encryption_key(direction)
        keystore.encryption_key(direction).should equal(key)
      end

      it "changes the key when new keys are assigned for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::NONE)
        key_old = keystore.encryption_key(direction)

        keystore.keys!("abc", 1147)
        keystore.encryption_key(direction).should_not == key_old
      end

      it "resets the key if you switch the algorithm to #{Nexop::EncryptionAlgorithm::NONE} for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::NONE)
        keystore.encryption_key(direction).should_not be_nil

        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::NONE, Nexop::MacAlgorithm::NONE)
        keystore.encryption_key(direction).should be_nil
      end
    end

    it "does not accept any other direction than :c2s and :s2c" do
      expect{ keystore.encryption_key("xxx") }.to raise_error(ArgumentError)
    end
  end

  context "initialization_vector" do
    [ :c2s, :s2c ].each do |direction|
      it "is nil by default for #{direction}" do
        keystore.initialization_vector(direction).should be_nil
      end

      it "is nil when you have some keys but no algorithm for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.initialization_vector(direction).should be_nil
      end

      it "is nil when you have an algorithm but no keys for #{direction}" do
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::NONE)
        keystore.initialization_vector(direction).should be_nil
      end

      it "calculates a key for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::NONE)
        keystore.initialization_vector(direction).should_not be_nil
      end

      it "returns the same key once calculated for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::NONE)
        key = keystore.initialization_vector(direction)
        keystore.initialization_vector(direction).should equal(key)
      end

      it "changes the key when new keys are assigned for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::NONE)
        key_old = keystore.initialization_vector(direction)

        keystore.keys!("abc", 1147)
        keystore.initialization_vector(direction).should_not == key_old
      end

      it "resets the key if you switch the algorithm to #{Nexop::EncryptionAlgorithm::NONE} for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::NONE)
        keystore.initialization_vector(direction).should_not be_nil

        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::NONE, Nexop::MacAlgorithm::NONE)
        keystore.initialization_vector(direction).should be_nil
      end
    end

    it "does not accept any other direction than :c2s and :s2c" do
      expect{ keystore.initialization_vector("xxx") }.to raise_error(ArgumentError)
    end
  end

  context "integrity_key" do
    [ :c2s, :s2c ].each do |direction|
      it "is nil by default for #{direction}" do
        keystore.integrity_key(direction).should be_nil
      end

      it "is nil when you have some keys but no algorithm for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.integrity_key(direction).should be_nil
      end

      it "is nil when you have an algorithm but no keys for #{direction}" do
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::NONE, Nexop::MacAlgorithm::SHA1)
        keystore.integrity_key(direction).should be_nil
      end

      it "calculates a key for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::NONE, Nexop::MacAlgorithm::SHA1)
        keystore.integrity_key(direction).should_not be_nil
      end

      it "returns the same key once calculated for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::NONE, Nexop::MacAlgorithm::SHA1)
        key = keystore.integrity_key(direction)
        keystore.integrity_key(direction).should equal(key)
      end

      it "changes the key when new keys are assigned for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::NONE, Nexop::MacAlgorithm::SHA1)
        key_old = keystore.integrity_key(direction)

        keystore.keys!("abc", 1147)
        keystore.integrity_key(direction).should_not == key_old
      end

      it "resets the key if you switch the algorithm to #{Nexop::MacAlgorithm::NONE} for #{direction}" do
        keystore.keys!("xxx", 4711)
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::NONE, Nexop::MacAlgorithm::SHA1)
        keystore.integrity_key(direction).should_not be_nil

        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::NONE, Nexop::MacAlgorithm::NONE)
        keystore.integrity_key(direction).should be_nil
      end
    end

    it "does not accept any other direction than :c2s and :s2c" do
      expect{ keystore.integrity_key("xxx") }.to raise_error(ArgumentError)
    end
  end

  context "algorithms!" do
    [ :c2s, :s2c ].each do |direction|
      it "updates the algorithms for #{direction}" do
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::SHA1)
        keystore.encryption_algorithm(direction).should == Nexop::EncryptionAlgorithm::DES
        keystore.mac_algorithm(direction).should == Nexop::MacAlgorithm::SHA1
      end

      it "rejects an unsupported encryption algorithm for #{direction}" do
        expect{ keystore.algorithms!(direction, "xxx", Nexop::MacAlgorithm::SHA1) }.to raise_error(ArgumentError)
      end

      it "rejects an unsupported mac algorithm for #{direction}" do
        expect{ keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, "xxx") }.to raise_error(ArgumentError)
      end
    end

    it "only accepts :c2s and :s2c" do
      expect{ keystore.algorithms!(:xxx, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::SHA1) }.to raise_error(ArgumentError)
    end
  end

  context "keys!" do
    it "updates the exchange hash" do
      keystore.keys!("xxx", 1)
      keystore.exchange_hash.should == "xxx"
    end

    it "updates the session id" do
      keystore.keys!("xxx", 1)
      keystore.session_id.should == "xxx"
    end

    it "does not update the session id on any further invocation" do
      keystore.keys!("xxx", 1)
      keystore.keys!("abc", 1)
      keystore.session_id.should == "xxx"
    end

    it "updates the shared secret" do
      keystore.keys!("xxx", 4711)
      keystore.shared_secret.should == 4711
    end
  end
end
