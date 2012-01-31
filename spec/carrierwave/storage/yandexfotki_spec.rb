require 'spec_helper'

describe CarrierWave::Storage::YandexFotki do
  YFFile = CarrierWave::Storage::YandexFotki::File

  let(:file) { double(File) }
  let(:yf_file) { double(YFFile) }
  let!(:uploader) {
    uploader = double "Uploader"
    uploader.stub(:yandex_login)
    uploader.stub(:yandex_password)
    uploader.stub(:yandex_net_http)
    uploader
  }
  let(:storage) { CarrierWave::Storage::YandexFotki.new(uploader) }

  before do
    image_identifier = {:foo => 'bar'}

    YFFile.stub(:new).and_return(yf_file)
    yf_file.stub(:store).and_return(image_identifier)
  end

  describe '#store!' do
    it 'should create, store and return YF File' do
      YFFile.should_receive(:new).and_return(yf_file)
      yf_file.should_receive(:store).with(file)
      storage.store!(file).should == yf_file
    end

    context 'file already stored' do
      before { storage.store!(file) }
      subject { storage.store!(file) }
      it('should NOT create YF File') { should_not be }
    end
  end

  describe '#identifier' do
    context 'no file stored' do
      subject { storage.identifier }
      it { should_not be }
    end

    context 'file stored' do
      before { storage.store!(file) }
      subject { storage.identifier }
      it { should be_a(String) }
    end
  end

  describe '#retrieve!' do
    it 'should return stored YF File by identifier' do
      image_identifier = double()
      identifier = double()

      YAML.should_receive(:load).with(image_identifier).and_return(identifier)
      YFFile.should_receive(:new).with(uploader, storage, identifier)

      storage.retrieve!(image_identifier).should == yf_file
    end
  end

  describe '#connection' do
    subject { storage.connection }
    it { should be_a(::YandexFotki::Connection) }
  end
end
