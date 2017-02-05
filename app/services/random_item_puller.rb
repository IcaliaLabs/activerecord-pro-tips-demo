class RandomItemPuller
  delegate :pull_random_items_from_inventory, :pull_topmost_item_from_all_shelves, to: :class
  def self.pull_random_items_from_inventory
    # This won't work.... the DB just clogs out...
    # ActiveRecord::Base.connection.execute <<~SQL
    #   UPDATE "items" SET "currently_available" = "updates"."random_value" FROM (
    #     SELECT "items"."id", (round(random()) > 0) AS "random_value"
    #     FROM "items" WHERE "currently_available" = 't'
    #   ) "updates";
    # SQL
  end

  # A great example of "SELECT LAST N OF EACH" type of SQL query...
  def self.pull_topmost_item_from_all_shelves
    ActiveRecord::Base.connection.execute <<~SQL
      UPDATE "items" SET "currently_available" = 'f', "shelf_rank" = NULL
      FROM (
        SELECT "items"."id" AS "item_id"
        FROM "items" INNER JOIN (
          SELECT
              "items"."shelf_id",
              MAX("items"."shelf_rank") AS "max_shelf_rank"
          FROM
              "items"
          GROUP BY
              "items"."shelf_id"
          ) "item_ranks" ON
            "items"."shelf_id" = "item_ranks"."shelf_id"
            AND "items"."shelf_rank" = "item_ranks"."max_shelf_rank"
      ) "item_pull_out"
      WHERE "items"."id" = "item_pull_out"."item_id"
    SQL
  end
end
