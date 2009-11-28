module ApplicationHelper
  
  def details_table options={}, &blk
    table = DetailsTable.new self, options
    table.create &blk
  end
  
end
