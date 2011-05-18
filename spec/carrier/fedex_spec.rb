require_relative '../spec_helper'

describe 'FedEx' do  
  before do
    @valid_credentials = {:key => "1111", :password => "2222", :account => "3333", :meter => "4444"}
    @invalid_credentials = {:key => "5555", :password => "6666", :account => "7777", :meter => "8888"}
    @valid_tracking_number = "999999999999"
    @invalid_tracking_number = "000000000000"
    
    @client = PackageTracker::Client.new(:fedex => @valid_credentials)
    @invalid_credentials_client = PackageTracker::Client.new(:fedex => @invalid_credentials)
        
    stub_request(:post, "https://gateway.fedex.com/xml")
      .with(:body => PackageTracker::Carriers::FedEx.send(:request_data, @valid_tracking_number, @valid_credentials))
      .to_return(:body => File.new("spec/fixtures/responses/fedex/valid.xml"), :status => 200)
      
    stub_request(:post, "https://gateway.fedex.com/xml")
      .with(:body => PackageTracker::Carriers::FedEx.send(:request_data, @valid_tracking_number, @invalid_credentials))
      .to_return(:body => File.new("spec/fixtures/responses/fedex/invalid_credentials.xml"), :status => 200)
      
    stub_request(:post, "https://gateway.fedex.com/xml")
      .with(:body => PackageTracker::Carriers::FedEx.send(:request_data, @invalid_tracking_number, @valid_credentials))
      .to_return(:body => File.new("spec/fixtures/responses/fedex/invalid_tracking_number.xml"), :status => 200)
      
    stub_request(:post, "https://gatewaybeta.fedex.com/xml")
      .to_return(:body => File.new("spec/fixtures/responses/fedex/valid.xml"), :status => 200)
  end
  
  it 'should send requests to the test server in test mode' do
    test_client = PackageTracker::Client.new(:fedex => @valid_credentials)
    test_client.test_mode!
    test_client.track(@valid_tracking_number)
    WebMock.should have_requested(:post, "https://gatewaybeta.fedex.com/xml")
  end

  it 'should send requests to the live server in production mode' do
    @client.track(@valid_tracking_number)
    WebMock.should have_requested(:post, "https://gateway.fedex.com/xml")
  end

  it 'should raise an error with missing credentials' do
    lambda { PackageTracker::Client.new(:fedex => {:key => "1111"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    lambda { PackageTracker::Client.new(:fedex => {:password => "2222"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    lambda { PackageTracker::Client.new(:fedex => {:account => "3333"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    lambda { PackageTracker::Client.new(:fedex => {:meter => "4444"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    
    lambda { @client.track(@valid_tracking_number) }.should_not raise_error(PackageTracker::MissingCredentialsError)
  end
  
  it 'should raise an error with invalid credentials' do
    lambda { @invalid_credentials_client.track(@valid_tracking_number) }.should raise_error(PackageTracker::InvalidCredentialsError)
  end
  
  it 'should raise an error when an invalid tracking number is supplied' do
    lambda { @client.track(@invalid_tracking_number) }.should raise_error(PackageTracker::InvalidTrackingNumberError)
  end
  
  it 'should return a response object' do
    response = @client.track(@valid_tracking_number)
    response.should be_an_instance_of(PackageTracker::Response)
  end
  
  it 'should return the correct number of statuses' do
    @client.track(@valid_tracking_number).statuses.length.should == 8
  end
end
