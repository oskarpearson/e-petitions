module Staged
  module PetitionCreator
    class Creator < Staged::Base::Petition
      include Staged::PetitionCreator::HasCreatorSignature

      class CreatorSignature < Staged::Base::CreatorSignature
        include Staged::Validations::SignerDetails
        include ::Validations::Email
      end
    end
  end
end

