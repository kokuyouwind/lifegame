CREATE TABLE cell_string(status int, str string);
INSERT INTO cell_string VALUES (1, "*");
INSERT INTO cell_string VALUES (0, " ");

CREATE TABLE rules(current int, count int, next int);
INSERT INTO rules VALUES (0, 3, 1);
INSERT INTO rules VALUES (1, 2, 1);
INSERT INTO rules VALUES (1, 3, 1);

CREATE TABLE cells(step int, x int, y int, status int);
CREATE UNIQUE INDEX step_position ON cells(step, x, y);

CREATE TABLE indexes(x int, y int);
WITH RECURSIVE cnt(i) AS (
  SELECT 1 UNION ALL
  SELECT i+1 FROM cnt LIMIT 5
) INSERT INTO indexes SELECT x.i, y.i FROM cnt AS x CROSS JOIN cnt AS y;

CREATE TABLE neighbors_diff(x int, y int);
WITH RECURSIVE cnt(i) AS (
  SELECT -1 UNION ALL
  SELECT i+1 FROM cnt LIMIT 3
)
INSERT INTO neighbors_diff
  SELECT x.i, y.i FROM cnt AS x CROSS JOIN cnt AS y
  WHERE x.i <> 0 OR y.i <> 0;

INSERT INTO cells SELECT 1, x, y, abs(random()) % 2 FROM indexes;

CREATE TABLE steps(step int);
CREATE TABLE current_cells(step int, x int, y int, status int);
CREATE TABLE prints(step int, str string);
CREATE TRIGGER update_cells INSERT ON steps
BEGIN
  INSERT INTO current_cells SELECT * FROM cells WHERE step = New.step;
  INSERT INTO prints
    SELECT New.step, group_concat(str, char(13) || char(10))
    FROM (
      SELECT y, group_concat(str, "") as str
      FROM current_cells JOIN cell_string ON current_cells.status = cell_string.status
      GROUP BY x ORDER BY x
    ) GROUP BY y ORDER BY y;
  INSERT INTO cells
    SELECT NEW.step+1, counted_cells.x, counted_cells.y, ifnull(rules.next, 0)
    FROM (
      SELECT current_cells.*, SUM(neighbors.status) as count
      FROM current_cells
      CROSS JOIN neighbors_diff
      JOIN current_cells AS neighbors
        ON neighbors.x = current_cells.x + neighbors_diff.x
        AND neighbors.y = current_cells.y + neighbors_diff.y
      GROUP BY current_cells.x, current_cells.y
    ) as counted_cells
    LEFT JOIN rules ON rules.current = counted_cells.status AND rules.count = counted_cells.count;
  DELETE FROM current_cells;
END;

WITH RECURSIVE current_step(step) AS (
  SELECT 1 UNION ALL
  SELECT step+1 FROM current_step LIMIT 50
) INSERT INTO steps SELECT * FROM current_step;

SELECT "==" || prints.step || "==" || char(13) || char(10) || prints.str
FROM prints
LEFT JOIN prints AS before ON prints.step = before.step + 1
WHERE prints.step == 1 OR prints.str != before.str
ORDER BY prints.step;
