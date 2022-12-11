use "files"
use "itertools"
use "collections"


actor Main
  let stdout : OutStream

  new create(env: Env) =>
    stdout = env.out

    try
      let file_name = env.args(1)?
      let path = FilePath(FileAuth(env.root), file_name)
      match OpenFile(path)
      | let file: File =>
          for line in file.lines() do
            var last_4: Array[String] = Array[String](4)
            var count: U32 = 0
            var check_chars = Array[String]
            while check_chars.size() < 4 do
              count = count + 1
              let char = String.from_array([line.shift() ?])
              if last_4.size() == 4 then
                last_4.shift() ?
              end
              last_4.push(char)
              check_chars = Iter[String](last_4.values()).unique[HashEq[String]]().collect(Array[String])
            end
            stdout.print("Marker found at " + count.string())
          end
      end
    end