#= ShelfSortingAndFiltering
# A collection of methods used by controllers to filter and sort ActiveRecord::Relation collections
# by shelf attributes (by ID, by name, etc)
module ShelfSortingAndFiltering
  def self.included(base)
    base.send :include, CollectionSortingAndFiltering
  end

  def filter_by_shelf?
    filter_by? shelf_param_def
  end

  def sort_by_shelf?
    sort_by? shelf_param_def
  end

  def shelf_scope
    Shelf.where ItemFiltering.params_filter_conditions(item_filter_params, shelf_param_def)
  end

  def filter_and_sort_by_shelf(scope)
    filter_and_sort_scope_by Shelf, scope
  end

  private

  def shelf_param_def
    AssociationParameterDefinition.new Shelf, :id, :name
  end
end
