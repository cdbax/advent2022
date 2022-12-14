use "files"
use "regex"
use "collections"
use "itertools"
use "debug"

class Contents
  let dirs: Map[String, Dir] ref
  let files: Array[DirFile] ref

  new create() =>
    dirs = Map[String, Dir].create()
    files = []

  fun getTotalSize(): U32 =>
    var total: U32 = 0
    for file in files.values() do
      total = total + file.size
    end
    for dir in dirs.values() do
      total = total + dir.contents.getTotalSize()
    end
    total

  fun sumIfBelowThreshold(threshold: U32): U32 =>
    var sum: U32 = 0
    var this_size: U32 = getTotalSize()
    if this_size < threshold then
      sum = sum + this_size
    end
    for dir in dirs.values() do
      sum = sum + dir.contents.sumIfBelowThreshold(threshold)
    end
    sum

  fun findNearestMoreThan(threshold: U32, closest: U32): U32 =>
    var this_size: U32 = getTotalSize()
    var min = closest
    if (this_size > threshold) and ((this_size < min) or (min == 0)) then
      min = this_size
    end
    for dir in dirs.values() do
      min = dir.contents.findNearestMoreThan(threshold, min)
    end
    min

class Dir
  let name: String
  let parent: (Dir ref | None)
  let contents: Contents ref


  new create(name': String, parent': (Dir ref | None)) =>
    name = name'
    parent = parent'
    contents = Contents.create()


class DirFile
  let name: String val
  let size: U32 val

  new create(name': String, size': U32) =>
    name = name'
    size = size'
  

actor Main
  let stdout : OutStream

  new create(env: Env) =>
    stdout = env.out

    try
      let file_name = env.args(1)?
      let path = FilePath(FileAuth(env.root), file_name)
      match OpenFile(path)
      | let file: File =>
          // Initialise the root directory
          let root_directory = Dir.create("/", None)
          var current_directory: Dir ref = root_directory

          // Setup the match patterns
          let cmd_cd_up = "$ cd .."
          let cmd_cd_in = Regex("\\$\\ cd\\ (?<dir>[a-z]+)") ?
          let cmd_ls = "$ ls"
          let ls_file = Regex("(?<size>\\d+)\\ (?<filename>[a-z.]+)") ?
          let ls_dir = Regex("dir\\ (?<dir>[a-z]+)") ?

          let lines = file.lines()
          lines.next() ?//Skip the first line, as the root directory already exists
          while lines.has_next() do
            try
              let line = recover val lines.next() ? end
              match line
              | cmd_cd_in =>
                let target: String = cmd_cd_in(line) ?.find("dir") ?
                current_directory = current_directory.contents.dirs(target) ?
              | cmd_cd_up =>
                current_directory = current_directory.parent as Dir ref
              | cmd_ls =>
                // We can just ignore ls - the file and directory patterns are enough
                continue
              | ls_file =>
                // Add file to contents of current directory
                let matched = ls_file(line) ?
                let file_size = matched.find("size") ?
                let filename = matched.find("filename") ?
                current_directory.contents.files.push(DirFile.create(consume filename, file_size.u32() ?))
              | ls_dir =>
                // Add directory to contents
                let matched = ls_dir(line) ?
                let dir_name = recover val matched.find("dir") ? end
                let new_dir = Dir.create(dir_name, current_directory)
                current_directory.contents.dirs.insert(dir_name, consume new_dir)
              end
            end
          end

          // let sum = root_directory.contents.sumIfBelowThreshold(100001)
          // stdout.print("Sum is " + sum.string())
          // let root_total = root_directory.contents.getTotalSize()
          // stdout.print("Root total is " + root_total.string())

          //Size needed is 2_080_344
          let min = root_directory.contents.findNearestMoreThan(2_080_344, 0)
          stdout.print("Min for needed space is " + min.string())
      end
    else
      Debug.out("Kaboom")
    end