module EmailFormat
  EMAIL_REGEX = /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/
  EMAIL_DENIED_REGEX = /(@\.)|(@\-)/

  def self.valid?(email)
    ((email =~ EMAIL_REGEX) && !(email =~ EMAIL_DENIED_REGEX)) ? true : false
  end
end
