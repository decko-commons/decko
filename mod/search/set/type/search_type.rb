include_set Type::Json
include_set Abstract::CqlSearch
include_set Abstract::SearchViews

format do
  def chunk_list
    :query
  end
end
