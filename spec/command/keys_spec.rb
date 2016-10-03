require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Keys do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ keys }).should.be.instance_of Command::Keys
      end
    end
  end
end

