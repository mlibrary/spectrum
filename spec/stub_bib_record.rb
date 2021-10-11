class StubBibRecord
  [
    :genre, 
    :sgenre, 
    :restriction, 
    :edition, 
    :physical_description, 
    :date, 
    :pub, 
    :place, 
    :publisher, 
    :pub_date, 
    :author, 
    :title, 
    :isbn, 
    :issn, 
  ].each do |method|
    define_method(method) do
      method
    end
  end
end
