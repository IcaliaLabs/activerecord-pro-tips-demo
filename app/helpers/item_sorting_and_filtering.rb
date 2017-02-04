#= ItemSortingAndFiltering
# A collection of methods used by controllers to filter and sort ActiveRecord::Relation collections
# by Item attributes (by ID, by availability, etc)
module ItemSortingAndFiltering
  def self.included(base)
    base.send :include, CollectionSortingAndFiltering
    base.expect_sorting_and_filtering_params_for Item, :id, :currently_available
  end

  def filter_by_item?
    filter_by? Item
  end

  def sort_by_item?
    sort_by? Item
  end

  def item_scope
    # Item.where ItemFiltering.params_filter_conditions(item_filter_params, Item, :id, :currently_available)
    Item.where filter_conditions_for(Item)
  end

  def filter_and_sort_by_item(scope)
    filter_and_sort_scope_by Item, scope
  end
end
