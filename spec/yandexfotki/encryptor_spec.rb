require 'spec_helper'

describe YandexFotki::Encryptor do
  it "should encrypt data with key (example from documentation)" do
    credentials = YandexFotki::Encryptor.encrypt \
      'BFC949E4C7ADCC6F179226D574869CBF44D6220DA37C054C64CE48D4BAA36B039D8206E45E4576BFDB1D3B40D958FF0894F6541717824FDEBCEDD27C4BE1F057#10001',
      '<credentials login="alekna" password="123456"/>'
    credentials.should == 'LwBAAAgbGOm18LL5drSQwemI9sGvU0vT2m1NygMSMLyuhQ3hN8lE6CA6C+EVOZCFvDJp9BNUNmi5G/0tlElN9QMB13g='
  end
end
