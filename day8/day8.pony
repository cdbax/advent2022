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

          var max_score: U32 = 0
          for (row_idx, row) in rows.pairs() do
            // Edge trees will always have a score of zero, so skip them
            if (row_idx == 0) or (row_idx == (rows.size() - 1)) then
              continue
            end
            
            for (col_idx, height) in row.pairs() do
              if (col_idx == 0) or (col_idx == (cols.size() - 1)) then
                continue
              end
              var total_score: U32 = 1
              let left = row.slice(where to = col_idx)
              let right = row.slice(col_idx + 1)
              let col = cols(col_idx) ?
              let up = col.slice(where to = row_idx)
              let down = col.slice(row_idx + 1)
              // Iterate through left trees in reverse
              var count: U32 = 0
              for t in left.reverse().values() do
                count = count + 1
                if t >= height then
                  break
                end
              end
              total_score = total_score * count
              count = 0
              // Iterate through right trees
              for t in right.values() do
                count = count + 1
                if t >= height then
                  break
                end
              end
              total_score = total_score * count
              count = 0
              // Iterate through up trees in reverse
              for t in up.reverse().values() do
                count = count + 1
                if t >= height then
                  break
                end
              end              
              total_score = total_score * count
              count = 0
              // Iterate through down trees
              for t in down.values() do
                count = count + 1
                if t >= height then
                  break
                end
              end
              total_score = total_score * count
              if total_score > max_score then
                max_score = total_score
              end
            end
          end

          stdout.print("Highest score is " + max_score.string())
      end
    end