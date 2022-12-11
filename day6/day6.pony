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
            var last_14: Array[String] = Array[String](14)
            var count: U32 = 0
            var check_chars = Array[String]
            while check_chars.size() < 14 do
              count = count + 1
              let char = String.from_array([line.shift() ?])
              if last_14.size() == 14 then
                last_14.shift() ?
              end
              last_14.push(char)
              check_chars = Iter[String](last_14.values()).unique[HashEq[String]]().collect(Array[String])
            end
            stdout.print("Marker found at " + count.string())
          end
      end
    end