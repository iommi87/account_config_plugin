/*
  Recommended indexes for optimal performance:

  -- Covering index on KM (most selective filters first)
  CREATE INDEX IX_KM_Kitchener_Date_Cooked
      ON KM (kitchener_id, create_date, cooking_end_date)
      INCLUDE (operation_id)
      WHERE cooking_end_date IS NOT NULL;  -- filtered index eliminates NULL rows at storage level

  -- Covering index on ItemsFlow
  CREATE INDEX IX_ItemsFlow_Operation_Visible
      ON ItemsFlow (operation_id, visible)
      INCLUDE (product_id, quantity);

  -- Products lookup (id is likely PK already; ensure km_dish is indexed if selectivity warrants it)
  CREATE INDEX IX_Products_KMDish ON Products (id, km_dish);
*/

CREATE PROCEDURE GetKitchenerPreparedCount
    @kitchener_id  INT,
    @date_from     DATETIME2,
    @date_to       DATETIME2,
    @count         INT OUTPUT
AS
SET NOCOUNT ON;

-- Assign directly to the OUTPUT parameter instead of returning a result set.
SELECT @count = CAST(ISNULL(SUM(f.quantity), 0) AS INT)
FROM KM
INNER JOIN ItemsFlow AS f ON f.operation_id = KM.operation_id
INNER JOIN Products  AS p ON p.id           = f.product_id
WHERE KM.kitchener_id      = @kitchener_id
  AND KM.create_date        BETWEEN @date_from AND @date_to
  AND KM.cooking_end_date   IS NOT NULL   -- keep: enables filtered-index seek
  AND f.visible             = 1
  AND p.km_dish             = 1
OPTION (RECOMPILE);  -- keep: date-range parameters benefit from per-execution plan optimisation
