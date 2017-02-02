class UsingFromExampleController < ApplicationController
  include ItemFiltering
  helper_method :item_filter_params

  def without_from
    @items = requested_scope(Item.all).limit(2000).includes(:product, :category, :shelf)
  end

  def with_from
    @items = Item.from(requested_scope(Item.all), :items).limit(2000).includes(:product, :category, :shelf)
  end

  private

  def requested_scope(starting_scope)
    scope = filter_by_category starting_scope
    scope = filter_by_product scope
    scope.order(Category.arel_table[:id].asc)
  end
end
