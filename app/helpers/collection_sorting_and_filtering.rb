#= CollectionSortingAndFiltering
# A collection of methods used by controllers to filter and sort ActiveRecord::Relation collections
module CollectionSortingAndFiltering
  extend ActiveSupport::Concern

  included do
    cattr_reader :sort_and_filter_params
    delegate :sort_param_keys_for, :filter_param_keys_for, :reducing_methods_for, to: :class
  end

  module ClassMethods
    def sort_and_filter_by(klass, *attributes)
      (@@sort_and_filter_params ||= {})[klass] = \
        AssociationParameterDefinition.new(klass, *attributes)
    end

    def sort_param_keys_for(klass)
      sort_and_filter_params[klass]&.sort_param_keys
    end

    def reducing_methods_for(klass)
      association_name = klass.name.underscore.to_sym
      %w(filter_by sort_by).map do |method_prefix|
        "#{method_prefix}_#{association_name}".to_sym
      end
    end

    def reduce_condition_params(given_params, key_pattern, param_keys)
      given_params.slice(*param_keys).transform_keys do |key|
        next $1.to_sym if key.to_s =~ key_pattern
        key
      end.to_unsafe_h
    end


  end

  #= AssociationParameterDefinition
  # A class intended to generate lists of GET parameters in the expected format for filtering and
  # sorting, and help the processing of those.
  class AssociationParameterDefinition
    attr_reader :klass, :attributes, :filter_param_keys, :sort_param_keys, :filter_key_pattern, :sort_key_pattern

    def initialize(association_class, *association_attrs)
      @klass = association_class
      @attributes = association_attrs
      sort_param_keys
      @filter_key_pattern ||= Regexp.new "\\A#{name}_(\\w+)\\z"
      @sort_key_pattern ||= Regexp.new "\\A#{name}_(\\w+)_sort\\z"
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

    def reducing_methods
      %w(filter_by sort_by).map { |method_prefix| "#{method_prefix}_#{name}".to_sym }
    end
  end

  def requested_collection_params
    @requested_collection_params ||= params.permit :category_id,   :category_id_sort,
                                                   :category_name, :category_name_sort,
                                                   :product_id,    :product_id_sort,
                                                   :product_name,  :product_name_sort,
                                                   :shelf_id,      :shelf_id_sort,
                                                   :shelf_name,    :shelf_name_sort
  end

  def sort_by?(association_class)
    sort_param_keys_for(association_class).reduce(false) do |must_sort, sort_key|
      must_sort || params.key?(sort_key) && params[sort_key].in?(%(asc desc))
    end
  end

  def filter_by?(association_class)
    (params.keys & filter_param_keys_for(association_class)).any?
  end

  def filter_conditions_for(klass)
    ItemFiltering.reduce_condition_params given_params,
                                          param_def.filter_key_pattern,
                                          param_def.filter_param_keys
  end

  private

  def filter_and_sort_scope_by(klass, scope)
    association_name = klass.name.underscore.to_sym
    reducing_methods = ItemFiltering.reducing_methods_for klass
    return scope unless reducing_methods_apply? reducing_methods
    scope = scope.joins(association_name) unless scope.klass == klass

    # Apply the filtering and sorting methods to the scope:
    reduce_scope_by reducing_methods, scope
  end

  def reducing_methods_apply?(reducing_methods)
    reducing_methods.map { |method| send("#{method}?".to_sym) }.reduce(&:|)
  end

  def reduce_scope_by(reducing_methods, scope_to_reduce)
    reducing_methods.reduce(scope_to_reduce) do |reduced_scope, reducing_method|
      send reducing_method, reduced_scope
    end
  end

  def self.params_filter_conditions(given_params, param_def)
    ItemFiltering.reduce_condition_params given_params,
                                          param_def.filter_key_pattern,
                                          param_def.filter_param_keys
  end

  def self.params_sort_conditions(given_params, param_def)
    ItemFiltering.reduce_condition_params(
      given_params,
      param_def.sort_key_pattern,
      param_def.sort_param_keys
    ).map do |keyval|
      column_name, column_order = keyval
      param_def.klass.arel_table[column_name].send(column_order.to_sym)
    end
  end
end
