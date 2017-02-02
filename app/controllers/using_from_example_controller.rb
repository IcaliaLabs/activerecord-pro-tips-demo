#= UsingFromExampleController
# Controls the user interaction with the Pro Tip 1: Using `ActiveRecord::Base.from` screen
class UsingFromExampleController < ApplicationController
  include ItemFiltering
  helper_method :item_filter_params

  def without_from
    @items = requested_scope(Item.all).limit(2000).includes(:product, :category, :shelf)
  end

  def with_from
    @items = Item.from(requested_scope(Item.all).limit(2000), :items)
                 .includes(:product, :category, :shelf)
  end

  private

  def requested_scope(starting_scope)
    scoping_methods = [:filter_and_sort_by_product, :filter_and_sort_by_category]
    scoping_methods.reduce(starting_scope) { |scope, scoping_method| send scoping_method, scope }
  end
end
