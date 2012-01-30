require 'spec_helper'

describe YandexFotki::ActiveRecord do
  describe 'extended class' do
    let!(:klass) { Class.new.send(:extend, YandexFotki::ActiveRecord) }

    subject { klass }

    it { should respond_to :mount_before_save_uploader }

    describe '.mount_before_save_uploader' do
      before {
        klass.stub(:before_save)
        klass.stub(:mount_uploader)
      }

      it 'should call before_save' do
        klass.should_receive(:before_save).with("store_image!")

        klass.class_eval { mount_before_save_uploader :image }
      end

      it 'should call mount_uploader with options' do
        options = {:foo => :bar}
        klass.should_receive(:mount_uploader).with(:image, options)

        klass.class_eval { mount_before_save_uploader :image, options }
      end
    end
  end

end
