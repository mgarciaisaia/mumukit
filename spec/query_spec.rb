require_relative './spec_helper'

class QueryRunner < Mumukit::Stub
  include Mumukit::WithTempfile
  include Mumukit::WithCommandLine

  def run_query!(request)
    request.query
    eval_query compile_query(request)
  end

  def compile_query(r)
    "#{r.extra}\n#{r.content}\nprint('=> ' + (#{r.query}).inspect)"
  end

  def eval_query(r)
    f = write_tempfile! r
    run_command "ruby < #{f.path}"
  ensure
    f.unlink
  end
end

describe Mumukit::TestServer do
  let(:server) { Mumukit::TestServer.new(nil) }

  context 'just extra' do
    it { expect(server.query!(query: '5')[:out]).to eq '=> 5' }
  end

  context 'no content' do
    it { expect(server.query!(query: 'x', extra: 'x = 4')[:out]).to eq '=> 4' }
  end

  context 'with content' do
    it { expect(server.query!(query: 'x', content: 'x = 4')[:out]).to eq '=> 4' }
  end

  context 'with content and effect' do
    it { expect(server.query!(query: 'puts x', content: 'x = 4')[:out]).to eq "4\n=> nil" }
  end

  context 'with content and extra' do
    it { expect(server.query!(query: 'x', content: 'x = y', extra: 'y = 3')[:out]).to eq '=> 3' }
  end

end