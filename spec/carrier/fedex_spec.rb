require_relative '../spec_helper'

describe 'FedEx' do  
  before do
    @valid_credentials = {:key => "1111", :password => "2222", :account => "3333", :meter => "4444"}
    @invalid_credentials = {:key => "5555", :password => "6666", :account => "7777", :meter => "8888"}
    @valid_tracking_number = "999999999999"
    @invalid_tracking_number = "000000000000"
    
    @client = PackageTracker::Client.new(:fedex => @valid_credentials)
    
    stub_request(:post, "http://gatewaybeta.fedex.com/xml")
    stub_request(:post, "http://gateway.fedex.com/xml")
  end
  
  it 'should send requests to the test server in test mode' do
    test_client = PackageTracker::Client.new(:fedex => @valid_credentials)
    test_client.test_mode!
    test_client.track(@valid_tracking_number)
    WebMock.should have_requested(:post, "http://gatewaybeta.fedex.com/xml")
  end

  it 'should send requests to the live server in production mode' do
    @client.track(@valid_tracking_number)
    WebMock.should have_requested(:post, "http://gateway.fedex.com/xml")
  end

  it 'should raise an error with missing credentials' do
    lambda { PackageTracker::Client.new(:fedex => {:key => "1111"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    lambda { PackageTracker::Client.new(:fedex => {:password => "2222"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    lambda { PackageTracker::Client.new(:fedex => {:account => "3333"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    lambda { PackageTracker::Client.new(:fedex => {:meter => "4444"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
  end
  
  it 'should raise an error with invalid credentials' do
    pending
  end
  
  it 'should raise an error when an invalid tracking number is supplied' do
    pending
  end
  
  it 'should return a response object' do
    pending
  end
  
  it 'should return the correct number of status activities' do
    pending
  end
end
