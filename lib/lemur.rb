
module Lemur

  def self.patch_records(patched_class)
    @patch_records ||= {}
    records = @patch_records[ patched_class ]
    unless ( records )
      records = []
      @patch_records[ patched_class ] = records
    end
    records
  end
  
  def self.check_previous_application( original_class, patch_module )
    records = patch_records( original_class )
    return unless records
    records.each do |r|
      if ( r.patch_module == patch_module )
        raise PatchAppliedException.new
      end
    end
  end

  def self.patch_class(original_class, patch_module)
    check_previous_application( original_class, patch_module )
    patch_method_names = patch_module.public_instance_methods(false).collect{|e|e.to_s}
    
    original_class.public_instance_methods.each do |m|
      if ( patch_method_names.include?( m.to_s ) )
        Lemur.patch_records( original_class ) << PatchRecord.new( original_class, 
                                                                  m,
                                                                  original_class.instance_method( m ),
                                                                  patch_module,
                                                                  patch_module.instance_method( m ) )
        original_class.class_eval( "alias_method :lemur_#{m}, :#{m}" )
        original_class.class_eval( "remove_method :#{m}" )
      end
    end

    original_class.class_eval( "include #{patch_module}" )
  end

  class PatchRecord

    attr_accessor :patched_class
    attr_accessor :method_name
    attr_accessor :original_method
    attr_accessor :patch_module
    attr_accessor :patch_method

    def initialize(patched_class, method_name, original_method, patch_module, patch_method)
      @patched_class   = patched_class
      @method_name     = method_name
      @original_method = original_method
      @patch_module    = patch_module
      @patch_method    = patch_method
    end
  end

  class PatchAppliedException < Exception
  end
end
