#= ItemFiltering
# A collection of methods used by controllers to filter and sort ActiveRecord::Relation collections
module ItemFiltering
  def item_filter_params
    @item_filter_params ||= params.permit :id,
                                          :category_id,   :category_id_sort,
                                          :category_name, :category_name_sort,
                                          :product_id,    :product_id_sort,
                                          :product_name,  :product_name_sort
  end

  def filter_by_category?
    filter_by? :category, :id, :name
  end

  def sort_by_category?
    sort_by? :category, :id, :name
  end

  def category_scope
    Category.where conditions_from_params(:category, :id, :name)
  end

  def filter_and_sort_by_category(scope)
    return scope unless filter_by_category? || sort_by_category?
    scope = filter_by_category scope.joins(:category)
    sort_by_category scope
  end

  def filter_by_product?
    (params.keys & [:product_id, :product_name]).any?
  end

  def sort_by_product?
    sort_by? :product, :id, :name
  end

  def product_scope
    Product.where conditions_from_params(:product, :id, :name)
  end

  def filter_and_sort_by_product(scope)
    return scope unless filter_by_product?
    scope = filter_by_product scope.joins(:product)
    sort_by_product scope
  end

  def filter_by_shelf?
    filter_by? :shelf, :id, :name
  end

  def sort_by_shelf?
    sort_by? :shelf, :id, :name
  end

  def shelf_scope
    Shelf.where conditions_from_params(:shelf, :id, :name)
  end

  def filter_and_sort_by_shelf(scope)
    return scope unless filter_by_shelf? || sort_by_shelf?
    scope = filter_by_shelf scope.joins(:shelf)
    sort_by_shelf scope
  end

  private

  def filter_by_category(scope)
    return scope unless filter_by_category?
    scope.merge(category_scope)
  end

  def sort_by_category(scope)
    return scope unless sort_by_category?
    scope.order sort_conditions_from_params(:category, :id, :name)
  end

  def filter_by_product(scope)
    return scope unless filter_by_product?
    scope.merge(product_scope)
  end

  def sort_by_product(scope)
    return scope unless sort_by_product?
    scope.order sort_conditions_from_params(:product, :id, :name)
  end

  def filter_by_shelf(scope)
    return scope unless filter_by_shelf?
    scope.merge(shelf_scope)
  end

  def sort_by_shelf(scope)
    return scope unless sort_by_shelf?
    scope.order sort_conditions_from_params(:shelf, :id, :name)
  end

  def sort_by?(assoc_name, *assoc_attrs)
    ItemFiltering.sort_keys(assoc_name, assoc_attrs).reduce(false) do |must_sort, sort_key|
      must_sort || params.key?(sort_key) && params[sort_key].in?(%(asc desc))
    end
  end

  def self.sort_keys(assoc_name, assoc_attrs)
    assoc_attrs.map { |attr_name| "#{assoc_name}_#{attr_name}_sort".to_sym }
  end

  def filter_by?(assoc_name, *assoc_attrs)
    (params.keys & ItemFiltering.filter_keys(assoc_name, assoc_attrs)).any?
  end

  def self.filter_keys(assoc_name, assoc_attrs)
    assoc_attrs.map { |attr_name| "#{assoc_name}_#{attr_name}".to_sym }
  end

  def conditions_from_params(assoc_name, *assoc_attrs)
    key_pattern = Regexp.new "\\A#{assoc_name}_(\\w+)\\z"
    item_filter_params.slice(*ItemFiltering.filter_keys(assoc_name, assoc_attrs)).transform_keys do |key|
      next $1.to_sym if key.to_s =~ key_pattern
      key
    end.to_unsafe_h
  end

  def sort_conditions_from_params(assoc_name, *assoc_attrs)
    associated_class = assoc_name.to_s.camelize.safe_constantize
    return unless associated_class.present?
    key_pattern = Regexp.new "\\A#{assoc_name}_(\\w+)_sort\\z"
    item_filter_params.slice(*ItemFiltering.sort_keys(assoc_name, assoc_attrs)).transform_keys do |key|
      next $1.to_sym if key.to_s =~ key_pattern
      key
    end.to_unsafe_h.map do |keyval|
      column_name, column_order = keyval
      associated_class.arel_table[column_name].send(column_order.to_sym)
    end
  end
end
