require 'spec_helper'

describe User do
  let(:id) { 123 }
  let(:user) { User.new(id: id, name: 'username') }
end
