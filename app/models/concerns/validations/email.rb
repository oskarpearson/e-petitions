require 'email_format'

module Validations
  module Email
    extend ActiveSupport::Concern

    included do
      validates_presence_of :email

      validates_each :email do |record, attr, value|
        if value && !EmailFormat.valid?(value)
          record.errors.add(:email, :invalid) unless
        end
      end
    end
  end
end
