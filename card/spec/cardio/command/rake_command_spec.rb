RSpec.describe Cardio::Command::RakeCommand do
  it "escapes arguments correctly" do
    command = Cardio::Command::RakeCommand.new "decko", "eat", ["--name", "site key"]
    expect(command.commands.first).to eq "bundle exec rake decko:eat -- --name site\\ key"
  end
end