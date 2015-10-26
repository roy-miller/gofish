require 'spec_helper'

describe User do
  let(:id) { 123 }
  let(:user) { User.new(id: id, name: 'username') }

  before do
    User.reset_users
  end

  it 'finds a user when one exists' do
    User.users << user
    found = User.find(id)
    expect(found).to be user
  end

  it 'does not find a user when one does not exist' do
    found = User.find(id)
    expect(found).to be_nil
  end
end
