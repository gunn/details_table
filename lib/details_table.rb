class DetailsTable
  attr_accessor :object, :base, :options
  
  def initialize base, opts={}
    options = { :class=>"details_table", :field_class=>"field",
                :row_class => "row", :value_class=>"value",
                :no_data => "<span class='no_data'>[No Data]</span>", :object=>nil }.merge(opts)
                
    self.base    = base
    self.object  = options[:object]
    self.options = options
  end
  
  def create &blk
    haml_tag :table, :class => options[:class] do
      yield self if block_given?
      if options[:except] || !block_given?
        options[:except] ||= []
        (object.class.column_names - options[:except]).each do |field|
          detail field
        end
      end
    end
    nil
  end
  
  def detail field, *args
    opts = args.pop if args.last && args.last.is_a?( Hash )
    opts ||= {}
    
    detail_options = options.merge(opts)
    value = args.first if args.first
    
    haml_tag :tr, :class => detail_options[:row_class] do
      # the ":<" flag means that tags do not get their own lines.
      haml_tag(:td, :<, :class => detail_options[:field_class]) do
        haml_concat field.to_s.humanize
      end
      haml_tag(:td, :<, :class => detail_options[:value_class]) do
        haml_concat (value || value_for_field(field) || options[:no_data])
      end
    end
    nil
  end
  
  def value_for_field field
    # return if there's no object, or field is not defined on it
    # in this case output will default to options[:no_data]
    return if !(result = object && object.send( field ))
    case
    when result.is_a?(Time)
      "#{time_ago_in_words( result )} ago"
    # Do it this way so as to not break when Money gem is not present 
    when result.class.to_s == "Money"
      result.format
    when result.blank?
      nil
    else result
    end
  end
  
  def method_missing(meth, *args, &blk)
    base.send meth, *args, &blk
  end
  
end