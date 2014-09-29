require "spec_helper"

class DucksboardReporter::Reporters::FooBar < DucksboardReporter::Reporter
  attr_accessor :log_file
end

describe DucksboardReporter::App do
  let(:app) { DucksboardReporter::App.new(File.expand_path("../config.yml", __FILE__)) }
  let(:reporter) { app.reporters["foo_bar"] }
  let(:widget) { app.widgets.first }

  describe "configuration" do
    let(:config) { app.config }

    it "load from YAML file" do
      expect(config.reporters).to have(2).items
      expect(config.widgets).to have(1).item
      expect(config.api_key).to eq("YOUR_API_KEY")
    end
  end

  it "registers reporters from config" do
    expect(app.reporters.values.map(&:class)).to include(DucksboardReporter::Reporters::Random)
  end

  it "registers widgets from config" do
    expect(app.widgets.map(&:class)).to include(DucksboardReporter::Widget)
  end

  describe "single reporter" do

    it "sets name from config" do
      expect(reporter.name).to eq("foo_bar")
    end

    it "applies options to reporters" do
      expect(reporter.log_file).to eq("/var/log/haproxy.log")
    end
  end

  describe "single widget" do

    it "sets id from config" do
      expect(widget.id).to eq(1234)
    end

    it "references reporter" do
      expect(widget.reporter).to eq(reporter)
    end
  end
end

