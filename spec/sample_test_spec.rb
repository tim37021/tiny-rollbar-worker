describe "Sample Test" do
  it "boots" do
    expect {
      Sidekiq
      Rollbar
    }.not_to raise_error
  end
end