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

describe CarrierWave::Storage::YandexFotki::File do
  let(:uploader) { double 'uploader' }
  let(:storage) { double 'storage', :connection => double('connection') }
  let(:identifier) { {'image_id' => 42, 'image_url' => "url_of_image"} }
  let(:file) { double(File) }
  let(:yf_file) { CarrierWave::Storage::YandexFotki::File.new(uploader, storage, identifier) }

  describe '#store' do
    it 'should post file using storage connection' do
      storage.connection.should_receive(:post_foto).with(file)
      yf_file.store(file)
    end
  end

  describe '#url' do
    context 'default style' do
      it 'should return original url from identifier' do
        yf_file.url.should == identifier['image_url']
      end
    end

    context 'integer sizes' do
      size_to_suffix = {
        800 => 'XL', 500 => 'L', 300 => 'M', 150 => 'S', 100 => 'XS', 75 => 'XXS', 50 => 'XXXS',
      }
      size_to_suffix.each do |k, v|
        it 'url(%d) should return url with %s suffix' % [k, v] do
          yf_file.url(k).should == 'url_of_' + v
        end
      end
    end

    context 'version (symbol or string) sizes' do
      size_to_suffix = {
        :ORIG => 'orig', :ORIGINAL => 'orig', :XL => 'XL', :L => 'L', :M => 'M', :S => 'S', :XS => 'XS', :XXS => 'XXS', :XXXS => 'XXXS',
        :orig => 'orig', :original => 'orig', :xl => 'XL', :l => 'L', :m => 'M', :s => 'S', :xs => 'XS', :xxs => 'XXS', :xxxs => 'XXXS'
      }
      size_to_suffix.each do |k, v|
        it 'url(:%s) should return url with %s suffix' % [k, v] do
          yf_file.url(k).should == 'url_of_' + v
        end
        it 'url("%s") should return url with %s suffix' % [k, v] do
          yf_file.url(k.to_s).should == 'url_of_' + v
        end
      end
    end

    it 'should return nil if no style found' do
      variants = ['foo', 123, :bar]
      variants.each { |v| yf_file.url(v).should_not be }
    end
  end

  describe '#delete' do
    it 'should pass image id from identifier to connection delete_foto method' do
      storage.connection.should_receive(:delete_foto)
      yf_file.delete
    end
  end
end
