RSpec.describe Cardio::Command::RakeCommand do
  it "escapes arguments correctly" do
    command = described_class.new "decko", "eat", ["--name", "site key"]
    expect(command.commands.first).to eq "bundle exec rake decko:eat -- --name site\\ key"
  end
end
