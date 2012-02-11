shared_examples "YandexFotki::HttpAdapter" do
  let(:url) { "http://example.com/path/file" }

  let(:auth_header) do
    {'Authorization' => 'authkey'}
  end

  describe '#get' do
    before do
      stub_request(:get, url).to_return(:body => 'get_response')
    end

    it 'should make http get request with auth header' do
      subject.get(url, auth_header)
      a_request(:get, url).with(:headers => auth_header).should have_been_made
    end

    it 'should allow http get request without auth header' do
      subject.get(url)
      a_request(:get, url).with(:headers => {'Authorization' => ''}).should_not have_been_made
      a_request(:get, url).should have_been_made
    end

    it 'should return http response' do
      subject.get(url).should == 'get_response'
    end
  end

  describe '#delete' do
    before do
      stub_request(:delete, url).to_return(:body => 'delete_response')
    end

    it 'should make http delete request with auth header' do
      subject.delete(url, auth_header)
      a_request(:delete, url).with(:headers => auth_header).should have_been_made
    end

    it 'should return http response' do
      subject.delete(url, auth_header).should == 'delete_response'
    end
  end

  describe '#post_form' do
    let(:post_params) do
      {'request_id' => 'request_id_val', 'credentials' => 'credentials_val'}
    end

    before do
      stub_request(:post, url).to_return(:body => 'post_response')
    end

    it 'should make http post request' do
      subject.post_form(url, post_params)
      a_request(:post, url).with(:body => post_params).should have_been_made
    end

    it 'should return http response' do
      subject.post_form(url, post_params).should == 'post_response'
    end
  end

  describe '#post_multipart' do
    let(:file) do
      double 'file', :path => 'filepath', :filename => 'filename', :content_type => 'content/type'
    end

    before do
      stub_request(:post, url).to_return(:body => 'post_multipart_response')
    end

    def post_multipart
      subject.post_multipart(url, file, auth_header)
    end

    it 'should make http post request with auth headers' do
      post_multipart
      a_request(:post, url)
        .with(:headers => auth_header)
        .should have_been_made
      # .with(:body => "image=#{file.path}&yaru=0", :headers => auth_header)
    end

    it 'should return http response' do
      post_multipart.should == 'post_multipart_response'
    end
  end

  describe '#put' do
    before do
      stub_request(:put, url).to_return(:body => 'put_response')
    end

    def put
      subject.put(url, 'data', auth_header.update('Content-Type' => 'content/type'))
    end

    it 'should make http post request with auth and content-type headers' do
      put
      a_request(:put, url)
        .with(:body => "data", :headers => auth_header.update('Content-Type' => 'content/type'))
        .should have_been_made
    end

    it 'should return http response' do
      put.should == 'put_response'
    end
  end
end
