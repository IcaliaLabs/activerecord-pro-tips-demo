#= ProductSortingAndFiltering
# A collection of methods used by controllers to filter and sort ActiveRecord::Relation collections
# by product attributes (by ID, by name, etc)
module ProductSortingAndFiltering
  def self.included(base)
    base.send :include, CollectionSortingAndFiltering
  end

  def filter_by_product?
    filter_by? Product, :id, :name
  end

  def sort_by_product?
    sort_by? Product, :id, :name
  end

  def product_scope
    Product.where ItemFiltering.params_filter_conditions(item_filter_params, product_param_def)
  end

  def filter_and_sort_by_product(scope)
    filter_and_sort_scope_by Product, scope
  end
end
