module Staged
  module PetitionSigner
    class ReplayEmail < Staged::Base::Signature
      include Staged::Validations::MultipleSigners
      include ::Validations::Email
    end
  end
end
