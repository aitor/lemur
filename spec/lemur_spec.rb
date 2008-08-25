
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
    records[0].method_name.should eql( "some_instance_method" )
    records[0].original_method.should_not be_nil
    records[0].patch_module.should be( PatchModule )
    records[0].patch_method.should_not be_nil
  end

  it "should prevent duplicate application of the same patch module" do
      #Lemur.patch_class( BasicClass, PatchModule )
    lambda {
      Lemur.patch_class( BasicClass, PatchModule )
    }.should raise_error( Lemur::PatchAppliedException )
  end

end
