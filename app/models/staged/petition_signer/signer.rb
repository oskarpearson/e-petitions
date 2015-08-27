module Staged
  module PetitionSigner
    class Signer < Staged::Base::Signature
      include Staged::Validations::SignerDetails
      include Staged::Validations::MultipleSigners
      include ::Validations::Email
    end
  end
end
