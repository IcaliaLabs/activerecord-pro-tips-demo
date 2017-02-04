#= CategorySortingAndFiltering
# A collection of methods used by controllers to filter and sort ActiveRecord::Relation collections
# by category attributes (by ID, by name, etc)
module CategorySortingAndFiltering
  extend ActiveSupport::Concern

  included do
    include CollectionSortingAndFiltering
    sort_and_filter_by Category, :id, :name
  end

  def filter_by_category?
    filter_by? Category
  end

  def filter_by_category(scope)
    return scope unless filter_by_category?
    scope.merge(category_scope)
  end

  def sort_by_category?
    sort_by? Category
  end

  def sort_by_category(scope)
    return scope unless sort_by_category?
    by_sorting_conditions = sort_conditions_for Category
    scope.order by_sorting_conditions
  end

  def category_scope
    conditions_met = filter_conditions_for Category
    Category.where conditions_met
  end

  def filter_and_sort_by_category(scope)
    filter_and_sort_scope_by Category, scope
  end
end
