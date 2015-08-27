module Staged
  module PetitionCreator
    class ReplayEmail < Staged::Base::Petition
      include Staged::PetitionCreator::HasCreatorSignature

      class CreatorSignature < Staged::Base::CreatorSignature
        include ::Validations::Email
      end
    end
  end
end
