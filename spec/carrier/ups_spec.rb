require_relative '../spec_helper'

describe "UPS" do  
  before do
    @valid_credentials = {:user_id => "1111", :password => "2222", :key => "3333"}
    @invalid_credentials = {:user_id => "4444", :password => "5555", :key => "6666"}
    @valid_tracking_number = "1ZA2552X0397250131"
    @invalid_tracking_number = "1ZA2552X0397250132"
    
    @client = PackageTracker::Client.new(:ups => @valid_credentials)
    @invalid_credentials_client = PackageTracker::Client.new(:ups => @invalid_credentials)
    
    stub_request(:post, "http://wwwcie.ups.com/ups.app/xml/Track")
      .with(:body => PackageTracker::Carriers::UPS.send(:request_data, @valid_tracking_number, @valid_credentials))
      .to_return(:body => File.new("spec/fixtures/responses/ups/valid.xml"), :status => 200)
      
    stub_request(:post, "http://wwwcie.ups.com/ups.app/xml/Track")
      .with(:body => PackageTracker::Carriers::UPS.send(:request_data, @valid_tracking_number, @invalid_credentials))
      .to_return(:body => File.new("spec/fixtures/responses/ups/invalid_credentials.xml"), :status => 200)
      
    stub_request(:post, "http://wwwcie.ups.com/ups.app/xml/Track")
      .with(:body => PackageTracker::Carriers::UPS.send(:request_data, @invalid_tracking_number, @valid_credentials))
      .to_return(:body => File.new("spec/fixtures/responses/ups/invalid_tracking_number.xml"), :status => 200)
  end
  
  it 'should send requests to the test server when in test mode' do
    test_client = PackageTracker::Client.new(:ups => @valid_credentials)
    test_client.test_mode!
    test_client.track(@valid_tracking_number)
    WebMock.should have_requested(:post, "http://wwwcie.ups.com/ups.app/xml/Track")
  end
  
  it 'should send requests to the live server when in production mode' do
    @client.track(@valid_tracking_number)
    WebMock.should have_requested(:post, "http://wwwcie.ups.com/ups.app/xml/Track")
  end
  
  it 'should handle missing credentials' do
    lambda { PackageTracker::Client.new(:ups => {:user_id => "1111"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    lambda { PackageTracker::Client.new(:ups => {:password => "2222"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    lambda { PackageTracker::Client.new(:ups => {:key => "3333"}).track(@valid_tracking_number) }.should raise_error(PackageTracker::MissingCredentialsError)
    
    lambda { @client.track("1ZA2552X0397250131") }.should_not raise_error(PackageTracker::MissingCredentialsError)
  end
  
  it 'should handle invalid credentials' do
    lambda { @invalid_credentials_client.track("1ZA2552X0397250131") }.should raise_error(PackageTracker::InvalidCredentialsError)
  end
  
  it 'should handle invalid tracking numbers' do
    lambda { @client.track(@invalid_tracking_number) }.should raise_error(PackageTracker::InvalidTrackingNumberError)
  end
  
  it 'should properly build the request body' do
    # @client.track(@valid_tracking_number)
    # WebMock.should have_requested(:post, "http://www.ups.com/ups.app/xml/Track").with(:body => File.new("spec/fixtures/requests/ups/valid.xml").read)
    pending "Not Exactly sure of the best way to test this"
  end
  
  it 'should return a response object' do
    response = @client.track(@valid_tracking_number)
    response.should be_an_instance_of(PackageTracker::Response)
  end
  
  it 'should return the correct number of status activities' do
    @client.track(@valid_tracking_number).statuses.length.should be 13
  end
  
  it 'should be able to verify delivery' do
    @client.track(@valid_tracking_number).delivered?.should be true
  end
  
  it 'should properly parse the location the statuses' do
    response = @client.track(@valid_tracking_number)
    statuses = response.statuses
    
    statuses[0][:location].should == "SAN FRANCISCO, CA, US"
    statuses[6][:location].should == "SAN PABLO, CA, US"
    statuses[12][:location].should == "US"
    
    response.current_location.should == "SAN FRANCISCO, CA, US"
  end
  
  it 'should return the statuses in chronological order' do
    statuses = @client.track(@valid_tracking_number).statuses
    statuses.should == statuses.sort_by { |status| status[:time] }.reverse
  end
end
