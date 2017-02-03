#= ItemFiltering
# A collection of methods used by controllers to filter and sort ActiveRecord::Relation collections
module ItemFiltering
  #= AssociationParameterDefinition
  # A class intended to generate lists of GET parameters in the expected format for filtering and
  # sorting, and help the processing of those.
  class AssociationParameterDefinition
    attr_reader :klass, :attributes

    def initialize(association_class, *association_attrs)
      @klass = association_class
      @attributes = association_attrs
    end

    def filter_param_keys
      @filter_param_keys ||= attributes.map { |attribute| "#{name}_#{attribute}".to_sym }
    end

    def sort_param_keys
      @sort_param_keys ||= filter_param_keys.map { |key| "#{key}_sort".to_sym }
    end

    def name
      @name ||= klass.name.underscore.to_sym
    end

    def param_keys
      filter_param_keys + sort_param_keys
    end

    def filter_key_pattern
      @filter_key_pattern ||= Regexp.new "\\A#{name}_(\\w+)\\z"
    end

    def sort_key_pattern
      @sort_key_pattern ||= Regexp.new "\\A#{name}_(\\w+)_sort\\z"
    end
  end

  def item_filter_params
    @item_filter_params ||= params.permit :id,
                                          :category_id,   :category_id_sort,
                                          :category_name, :category_name_sort,
                                          :product_id,    :product_id_sort,
                                          :product_name,  :product_name_sort
  end

  define_method(:category_param_def) { AssociationParameterDefinition.new Category, :id, :name }
  define_method(:filter_by_category?) { filter_by? category_param_def }
  define_method(:sort_by_category?) { sort_by? category_param_def }

  def category_scope
    Category.where ItemFiltering.params_filter_conditions(category_param_def)
  end

  def filter_and_sort_by_category(scope)
    return scope unless filter_by_category? || sort_by_category?
    scope = filter_by_category scope.joins(:category)
    sort_by_category scope
  end

  define_method(:product_param_def) { AssociationParameterDefinition.new Product, :id, :name }
  define_method(:filter_by_product?) { filter_by? product_param_def }
  define_method(:sort_by_product?) { sort_by? product_param_def }

  def product_scope
    Product.where ItemFiltering.params_filter_conditions(product_param_def)
  end

  def filter_and_sort_by_product(scope)
    return scope unless filter_by_product?
    scope = filter_by_product scope.joins(:product)
    sort_by_product scope
  end

  define_method(:shelf_param_def) { AssociationParameterDefinition.new Shelf, :id, :name }
  define_method(:filter_by_shelf?) { filter_by? shelf_param_def }
  define_method(:sort_by_shelf?) { sort_by? shelf_param_def }

  def shelf_scope
    Shelf.where ItemFiltering.params_filter_conditions(shelf_param_def)
  end

  def filter_and_sort_by_shelf(scope)
    return scope unless filter_by_shelf? || sort_by_shelf?
    scope = filter_by_shelf scope.joins(:shelf)
    sort_by_shelf scope
  end

  def self.reduce_condition_params(given_params, key_pattern, param_keys)
    given_params.slice(*param_keys).transform_keys do |key|
      next $1.to_sym if key.to_s =~ key_pattern
      key
    end.to_unsafe_h
  end

  private

  def filter_by_category(scope)
    return scope unless filter_by_category?
    scope.merge(category_scope)
  end

  def sort_by_category(scope)
    return scope unless sort_by_category?
    scope.order params_sort_conditions(category_param_def)
  end

  def filter_by_product(scope)
    return scope unless filter_by_product?
    scope.merge(product_scope)
  end

  def sort_by_product(scope)
    return scope unless sort_by_product?
    scope.order params_sort_conditions(product_param_def)
  end

  def filter_by_shelf(scope)
    return scope unless filter_by_shelf?
    scope.merge(shelf_scope)
  end

  def sort_by_shelf(scope)
    return scope unless sort_by_shelf?
    scope.order params_sort_conditions(shelf_param_def)
  end

  def sort_by?(param_def)
    param_def.sort_param_keys.reduce(false) do |must_sort, sort_key|
      must_sort || params.key?(sort_key) && params[sort_key].in?(%(asc desc))
    end
  end

  def filter_by?(param_def)
    (params.keys & param_def.filter_param_keys).any?
  end

  def self.params_filter_conditions(param_def)
    ItemFiltering.reduce_condition_params item_filter_params,
                                          param_def.filter_key_pattern,
                                          param_def.filter_param_keys
  end

  def self.params_sort_conditions(param_def)
    ItemFiltering.reduce_condition_params(
      item_filter_params,
      param_def.sort_key_pattern,
      param_def.sort_param_keys
    ).map do |keyval|
      column_name, column_order = keyval
      param_def.klass.arel_table[column_name].send(column_order.to_sym)
    end
  end
end
