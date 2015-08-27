require 'rails_helper'
require 'email_format'

RSpec.describe 'Email Format' do
  subject { EmailFormat }

  it 'matches simple email addresses' do
    expect(subject.valid?('laura@example.com')).to be true
    expect(subject.valid?('jo213@public.com')).to be true
  end

  it 'matches tagged email addresses' do
    expect(subject.valid?('laura+petitions@example.com')).to be true
  end

  it 'matches subdomain email addresses' do
    expect(subject.valid?('laura@subdomain.example.com')).to be true
  end

  it 'matches email addresses with uncommon tld' do
    expect(subject.valid?('laura@example.photography')).to be true
    expect(subject.valid?('laura@example.london')).to be true
    expect(subject.valid?('laura@example.averylongtldname')).to be true
  end

  it 'matches email addresses with single characters' do
    expect(subject.valid?('l@s.c')).to be true
  end

  it 'matches email addresses that contain dashes' do
    expect(subject.valid?('l@some-example.example')).to be true
    expect(subject.valid?('l@s-ome.example')).to be true
  end

  it 'matches email addresses with special characters' do
    expect(subject.valid?('laura@!\"\#$%(),/;<>_[]\`|.com')).to be true
    expect(subject.valid?('laura!\"\#$%()@example.com')).to be true
  end

  it 'doesn\'t match email addresses without a domain and tld' do
    expect(subject.valid?('laura@example')).to be false
  end

  it 'doesn\'t match email addresses without a local' do
    expect(subject.valid?('@example.com')).to be false
  end

  it 'doesn\'t match email addresses without at sign' do
    expect(subject.valid?('laura')).to be false
    expect(subject.valid?('laura.example.com')).to be false
  end

  it 'doesn\'t match email addresses with a space character' do
    expect(subject.valid?('laura@example. com')).to be false
    expect(subject.valid?('laura@ example.com')).to be false
    expect(subject.valid?('laura space@example.com')).to be false
  end

  it 'doesn\'t match email addresses with at sign in local, sld or tld' do
    expect(subject.valid?('laura@123@example.com')).to be false
    expect(subject.valid?('laura@example@.com')).to be false
    expect(subject.valid?('laura@example.@com')).to be false
  end

  it 'doesn\'t allow domains that end with a hyphen or a dot' do
    expect(subject.valid?('laura@example.com.')).to be false
    expect(subject.valid?('laura@example.com-')).to be false
  end

  it 'doesn\'t allow domains that starts with hyphen or a dot' do
    expect(subject.valid?('laura@.example.com')).to be false
    expect(subject.valid?('laura@-example.com')).to be false
  end
end
