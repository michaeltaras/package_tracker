require_relative '../spec_helper'

describe 'FedEx' do  
  before do
    @valid_credentials = {:user_id => "556MICHA5644", :password => "597RG17CA755"}
    @invalid_credentials = {:user_id => "3333", :password => "4444"}
    @valid_tracking_number = "EJ958083578US"
    @invalid_tracking_number = "EJ000000000US"
    
    @client = PackageTracker::Client.new(:usps => @valid_credentials)
    @invalid_credentials_client = PackageTracker::Client.new(:usps => @invalid_credentials)
        
    stub_request(:post, "http://production.shippingapis.com/ShippingAPI.dll")
      .with(:body => PackageTracker::Carriers::USPS.send(:request_data, @valid_tracking_number, @valid_credentials))
      .to_return(:body => File.new("spec/fixtures/responses/usps/valid.xml"), :status => 200)
      
    stub_request(:post, "http://production.shippingapis.com/ShippingAPI.dll")
      .with(:body => PackageTracker::Carriers::USPS.send(:request_data, @valid_tracking_number, @invalid_credentials))
      .to_return(:body => File.new("spec/fixtures/responses/usps/invalid_credentials.xml"), :status => 200)
      
    stub_request(:post, "http://production.shippingapis.com/ShippingAPI.dll")
      .with(:body => PackageTracker::Carriers::USPS.send(:request_data, @invalid_tracking_number, @valid_credentials))
      .to_return(:body => File.new("spec/fixtures/responses/usps/invalid_tracking_number.xml"), :status => 200)
      
    stub_request(:post, "http://testing.shippingapis.com/ShippingAPITest.dll")
      .to_return(:body => File.new("spec/fixtures/responses/usps/valid.xml"), :status => 200)
  end
  
  it 'should send requests to the test server in test mode' do
    test_client = PackageTracker::Client.new(:usps => @valid_credentials)
    test_client.test_mode!
    test_client.track(@valid_tracking_number)
    WebMock.should have_requested(:post, "http://testing.shippingapis.com/ShippingAPITest.dll")
  end
  
  it 'should send requests to the live server in production mode' do
    @client.track(@valid_tracking_number)
    WebMock.should have_requested(:post, "http://production.shippingapis.com/ShippingAPI.dll")
  end
  
  it 'should raise an error with missing credentials' do
    lambda { PackageTracker::Client.new(:usps => {:user_id => "3333"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    lambda { PackageTracker::Client.new(:usps => {:password => "4444"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    
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
    @client.track(@valid_tracking_number).statuses.length.should == 4
  end
  
  it 'should be able to verify delivery' do
    @client.track(@valid_tracking_number).delivered?.should be true
  end
  
  it 'should properly parse the location the statuses' do
    response = @client.track(@valid_tracking_number)
    statuses = response.statuses
    
    statuses[0][:location].should == "Wilmington DE 19801"
    statuses[3][:location].should == "EDGEWATER NJ 07020"
    
    response.current_location.should == "Wilmington DE 19801"
  end
  
  it 'should return the statuses in chronological order' do
    statuses = @client.track(@valid_tracking_number).statuses
    statuses.should == statuses.sort_by { |status| status[:time] }.reverse
  end

end