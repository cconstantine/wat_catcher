require 'spec_helper'

describe WatCatcher::BugsnagController, type: :controller do
  routes { WatCatcher::Engine.routes }

  describe "GET #show" do
    before do
      expect_any_instance_of(WatCatcher::Poster).to receive(:perform) { true }
    end
    let(:req) { get :show, { "notifierVersion" => "2.3.2", "apiKey" => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "projectRoot" => "http://localhost:3001", "context" => "/exceptionals", "user" => "{\"id\":16,\"first_name\":null,\"name\":\"asdfasd\",\"email\":\"asdfasdf\",\"created_at\":\"2014-04-07T22:21:57.041Z\",\"updated_at\":\"2014-04-07T22:21:57.041Z\"}", "metaData" => { "script" => { "src" => "http://localhost:3001/assets/exceptionals/thrower.js?body=1", "content" => "" }, "Last Event" => { "millisecondsAgo" => "742", "type" => "load", "target" => "#document" } }, "url" => "http://localhost:3001/exceptionals", "userAgent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36", "language" => "en-US", "severity" => "fatal", "name" => "Error", "message" => "Uncaught Error: foo", "stacktrace" => "Error: foo\n    at thrower (http://localhost:3001/assets/exceptionals/thrower.js?body=1:3:11)\n    at http://localhost:3001/assets/exceptionals/thrower.js?body=1:7:12\n    at _super.bugsnag (http://localhost:3001/assets/bugsnag.js?body=1:128:30)\n    at http://localhost:3001/assets/bugsnag.js?body=1:583:15", "file" => "http://localhost:3001/assets/exceptionals/thrower.js?body=1", "lineNumber" => "3", "columnNumber" => "11", "ct" => "img", "cb" => "1397595292609", "id" => "Wattle" } }
    subject { req; OpenStruct.new assigns[:report].params[:wat] }
    it "should be success" do
      req
      expect(response).to be_success
    end
    it { expect(subject.message).to eq "Uncaught Error: foo" }
    it { expect(subject.backtrace.count).to eq 4 }
    it { expect(subject.page_url).to eq "http://localhost:3001/exceptionals" }
    it { expect(subject.language).to eq "javascript" }
    it { expect(subject.app_user).to include({ 'id' => 16, 'first_name' => nil, 'name' => 'asdfasd', 'email' => 'asdfasdf' }) }

    context "with a bogus user" do
      let(:req) { get :show, {"notifierVersion" => "2.3.2", "apiKey" => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "projectRoot" => "http://localhost:3001", "context" => "/exceptionals", "user" => "{\"id\":16,", "metaData" => { "script" => { "src" => "http://localhost:3001/assets/exceptionals/thrower.js?body=1", "content" => "" }, "Last Event" => { "millisecondsAgo" => "742", "type" => "load", "target" => "#document" } }, "url" => "http://localhost:3001/exceptionals", "userAgent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36", "language" => "en-US", "severity" => "fatal", "name" => "Error", "message" => "Uncaught Error: foo", "stacktrace" => "Error: foo\n    at thrower (http://localhost:3001/assets/exceptionals/thrower.js?body=1:3:11)\n    at http://localhost:3001/assets/exceptionals/thrower.js?body=1:7:12\n    at _super.bugsnag (http://localhost:3001/assets/bugsnag.js?body=1:128:30)\n    at http://localhost:3001/assets/bugsnag.js?body=1:583:15", "file" => "http://localhost:3001/assets/exceptionals/thrower.js?body=1", "lineNumber" => "3", "columnNumber" => "11", "ct" => "img", "cb" => "1397595292609", "id" => "Wattle" } }
      it "should be success" do
        req
        expect(response).to be_success
      end

      it { expect(subject.message).to eq "Uncaught Error: foo" }
      it { expect(subject.backtrace.count).to eq 4 }
      it { expect(subject.page_url).to eq "http://localhost:3001/exceptionals" }
      it { expect(subject.language).to eq "javascript" }
      it { expect(subject.app_user).to be_nil }
    end
  end

end

