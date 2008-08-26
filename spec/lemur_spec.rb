
require 'lemur'

module PatchModule
  def some_instance_method()
    @value = "#{self.class.name} + PatchModule"
  end

  def some_other_instance_method()
    @value = "#{self.class.name} + PatchModule + other"
  end
end

class BasicClass

  def value
    @value
  end

  def some_instance_method()
    @value = "#{self.class.name} + BasicClass"
  end

end


describe Lemur do

  before(:all) do 
    Lemur.patch_class( BasicClass, PatchModule )
  end

  it "should mix in module methods" do
    o = BasicClass.new
    o.some_other_instance_method
    o.value.should eql( "BasicClass + PatchModule + other" )
  end

  it "should override instance methods" do
    o = BasicClass.new
    o.some_instance_method
    o.value.should eql( "BasicClass + PatchModule" )
  end

  it "should track patch records by class" do
    records = Lemur.patch_records(BasicClass)
    records.should_not be_nil
    records.should_not be_empty
    records.size.should eql( 1 )
    records[0].patched_class.should be(BasicClass)
    records[0].patch_module.should be( PatchModule )
    records[0].patched_methods.should_not be_nil
    records[0].patched_methods.should_not be_empty
    records[0].patched_methods.keys.should include( "some_instance_method" )
    records[0].patched_methods['some_instance_method'].method_name.should eql( "some_instance_method" )
    records[0].patched_methods['some_instance_method'].original_method.should_not be_nil
    records[0].patched_methods['some_instance_method'].patch_method.should_not be_nil
  end

  it "should enumerate all patched classes" do
    patched = Lemur.patched_classes
    patched.should_not be_nil
    patched.should_not be_empty
    patched.size.should eql( 1 )
    patched.should include( BasicClass )
  end

  it "should prevent duplicate application of the same patch module" do
    lambda {
      Lemur.patch_class( BasicClass, PatchModule )
    }.should raise_error( Lemur::PatchAppliedException )
  end

end
