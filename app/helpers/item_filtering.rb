module ItemFiltering
  def item_filter_params
    @item_filter_params ||= params.permit :id, :category_id, :category_name,
                                          :product_id, :product_name
  end

  def filter_by_category?
    (params.keys & %w(category_id category_name)).any?
  end

  def category_scope
    conditions = item_filter_params.slice(:category_id, :category_name).transform_keys do |key|
      next $1.to_sym if key.to_s =~ /\Acategory_(\w+)\z/i
      key
    end
    Category.where conditions.to_unsafe_h
  end

  def filter_by_category(scope)
    return scope unless filter_by_category?
    scope.joins(:category).merge category_scope
  end

  def filter_by_product?
    (params.keys & [:product_id, :product_name]).any?
  end

  def product_scope
    conditions = item_filter_params.slice(:product_id, :product_name).transform_keys do |key|
      next $1.to_sym if key.to_s =~ /\Aproduct_(\w+)\z/i
      key
    end
    Product.where conditions.to_unsafe_h
  end

  def filter_by_product(scope)
    return scope unless filter_by_product?
    scope.joins(:product).merge product_scope
  end
end
