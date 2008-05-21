require File.dirname(__FILE__) + '/../spec_helper'

describe "<%= module_name %>::Main (controller)" do
  
  # Feel free to remove the specs below
  
  before :all do
    Merb::Router.prepare { |r| r.add_slice(:<%= module_name %>) } if standalone?
  end
  
  it "should have an index action" do
    controller = dispatch_to(<%= module_name %>::Main, :index)
    controller.status.should == 200
    controller.body.should contain('<%= module_name %>')
  end
  
  it "should work with the default route" do
    controller = get("/<%= base_name %>/main/index")
    controller.should be_kind_of(<%= module_name %>::Main)
    controller.action_name.should == 'index'
  end
  
  it "should have helper methods for dealing with public paths" do
    controller = dispatch_to(<%= module_name %>::Main, :index)
    controller.public_path_for(:image).should == "/slices/<%= base_name %>/images"
    controller.public_path_for(:javascript).should == "/slices/<%= base_name %>/javascripts"
    controller.public_path_for(:stylesheet).should == "/slices/<%= base_name %>/stylesheets"
  end

end