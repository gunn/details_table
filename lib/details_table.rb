class DetailsTable
  attr_accessor :object, :base, :options
  
  def initialize base, opts={}
    options = { :class=>"details_table", :field_class=>"field",
                :input_type => "text_field",
                :row_class => "row", :value_class=>"value",
                :no_data => "<span class='no_data'>[No Data]</span>", :object=>nil }.merge(opts)
                
    self.base    = base
    self.object  = options[:object]
    self.options = options
  end
  
  def create &blk
    haml_tag :table, :class => options[:class] do
      yield self if block_given?
      
      fields = case 
      when options[:except] then object.class.column_names-options[:except]
      when options[:only]   then options[:only]
      when !block_given?    then object.class.column_names
      end
      
      details( fields ) if fields
      
    end
    nil
  end
  
  def details fields, *args
    fields.each do |field|
      detail field, *args
    end
  end
  
  def detail field, *args
    field = field.to_sym
    opts = args.pop if args.last && args.last.is_a?( Hash )
    opts ||= {}
    
    detail_options = options.merge(opts)
    value = args.first if args.first
    
    haml_tag :tr, :class => detail_options[:row_class] do
      # the ":<" flag means that tags do not get their own lines.
      haml_tag(:td, :<, :class => detail_options[:field_class]) do
        haml_concat field.to_s.humanize
      end
      
      if options[:form] && !value
        detail_options[:value_class] = "#{detail_options[:value_class]} has_text_field"
        show_value = detail_options[:form].send(detail_options[:input_type], field )
      else
        show_value = (value || value_for_field(field) || detail_options[:no_data])
      end
      haml_tag(:td, :<, :class => detail_options[:value_class]) do
        haml_concat show_value
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