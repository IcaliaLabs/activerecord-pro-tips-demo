#= UsingFromExampleController
# Controls the user interaction with the Pro Tip 1: Using `ActiveRecord::Base.from` screen
class UsingFromExampleController < ApplicationController
  include ItemFiltering
  helper_method :item_filter_params
  before_action :set_items, only: [:without_from, :with_from]

  def without_from
    @items = @items.limit(2000).includes(:product, :category, :shelf)
  end

  def with_from
    @items = Item.from(@items, :items).limit(2000).includes(:product, :category, :shelf)
  end

  private

  def set_items
    @items = requested_scope(Item.all)
  end

  def requested_scope(starting_scope)
    scoping_methods = [:filter_and_sort_by_product, :filter_and_sort_by_category]
    scoping_methods.reduce(starting_scope) { |scope, scoping_method| send scoping_method, scope }
  end
end
