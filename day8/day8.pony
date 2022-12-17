use "files"
use "itertools"


actor Main
  let stdout: OutStream

  new create(env: Env) =>
    stdout = env.out

    try
      let file_name = env.args(1)?
      let path = FilePath(FileAuth(env.root), file_name)
      match OpenFile(path)
      | let file: File =>
          // Build a matrix from the input
          let rows: Array[Array[U8]] = []
          let cols: Array[Array[U8]] = []
          for tmp in file.lines() do
            let line: String val = consume tmp
            if cols.size() == 0 then
              // Initialize columns based on width of row
              for s in line.values() do
                cols.push([])
              end
            end
            let new_row = Iter[U8](line.array().values()).map[U8]({(c) ?=> String.from_array([c]).u8() ?}).collect(Array[U8])
            rows.push(new_row)
            var col_idx: USize = 0
            for (idx, c) in new_row.pairs() do
              cols(idx) ?.push(c)
            end
          end

          // We have to initialise the array like this to ensure each element
          // is unique.
          let visible_trees = Array[Array[Bool]].create(rows.size())
          for r in rows.values() do
            visible_trees.push(Array[Bool].init(false, cols.size()))
          end
          let row_max_idx = cols.size() - 1 
          
          // Process each row/column in both directions, counting number of trees
          // Left to Right
          for row_pair in rows.pairs() do
            let row_idx = row_pair._1
            let row = row_pair._2
            let state_row = visible_trees(row_idx) ?
            var max_height: U8 = 0
            for col_pair in row.pairs() do
              let col_idx = col_pair._1
              let height = col_pair._2
              if col_idx == 0 then
                max_height = height
                state_row(col_idx) ? = true
              elseif height > max_height then
                max_height = height
                state_row(col_idx) ? = true
              end
            end
          end
          // Right to Left
          for row_pair in rows.pairs() do
            let row_idx = row_pair._1
            let row = row_pair._2
            let state_row = visible_trees(row_idx) ?
            var max_height: U8 = 0
            for col_pair in row.reverse().pairs() do
              let col_idx = col_pair._1
              let height = col_pair._2
              if col_idx == 0 then
                max_height = height
                state_row(row_max_idx - col_idx) ? = true
              elseif height > max_height then
                max_height = height
                state_row(row_max_idx - col_idx) ? = true
              end
            end
          end
          // Down
          for col_pair in cols.pairs() do
            let col_idx = col_pair._1
            let col = col_pair._2
            var max_height: U8 = 0
            for row_pair in col.pairs() do
              let row_idx = row_pair._1
              let height = row_pair._2
              if row_idx == 0 then
                max_height = height
                visible_trees(row_idx) ?(col_idx) ? = true
              elseif height > max_height then
                max_height = height
                visible_trees(row_idx) ?(col_idx) ? = true
              end
            end
          end
          // Up
          for col_pair in cols.pairs() do
            let col_idx = col_pair._1
            let col = col_pair._2
            var max_height: U8 = 0
            for row_pair in col.reverse().pairs() do
              let row_idx = row_pair._1
              let height = row_pair._2
              if row_idx == 0 then
                max_height = height
                visible_trees(row_max_idx - row_idx) ?(col_idx) ? = true
              elseif height > max_height then
                max_height = height
                visible_trees(row_max_idx - row_idx) ?(col_idx) ? = true
              end
            end
          end

          var total_trees: U32 =
            Iter[Array[Bool]](visible_trees.values())
              .flat_map[U32]({
                (row: Array[Bool]): Iterator[U32] => 
                  Iter[Bool](row.values())
                    .map[U32]({
                      (v) => if v then 1 else 0 end
                    })
              })
              .fold[U32](0, {(acc, v) => acc + v})
          stdout.print("Total visible trees is " + total_trees.string())
      end
    end