use "files"
use "collections"
use "itertools"

actor Main
  let stdout: OutStream
  var msg_count: U32 = 0
  var priority_sum: U32 = 0

  new create(env: Env) =>
    stdout = env.out

    try
      let file_name = env.args(1)?
      let path = FilePath(FileAuth(env.root), file_name)
      match OpenFile(path)
      | let file: File =>
          for line in file.lines() do
            SackChecker(consume line).checkSack(this)
            msg_count = msg_count + 1
          end
      else
        env.err.print("Error opening file '" + file_name + "'")
      end
    end
  
  be report(priority: U32) =>
    msg_count = msg_count - 1
    priority_sum = priority_sum + priority
    if msg_count == 0 then
      stdout.print("Sum is " + priority_sum.string())
    end


actor SackChecker
  let sack_contents: String

  new create(sack_contents': String) =>
    sack_contents = sack_contents'

  be checkSack(main: Main) =>
    // Initialise a couple of sets
    // Strings are just a sequence of bytes, and we know we're only dealing
    // with characters that don't exceed 255 so we can just us U8s to keep
    // it simple
    let set_a: HashSet[U8, HashEq[U8]] = HashSet[U8, HashEq[U8]].create()
    let set_b: HashSet[U8, HashEq[U8]] = HashSet[U8, HashEq[U8]].create()
    // Chop the sack contents in half
    let chop_length = sack_contents.size() / 2
    let chop_target = sack_contents.clone()
    (let compartment_a: String, let compartment_b: String) = (consume chop_target).chop(chop_length)
    // Populate the sets with their respective contents
    for i in compartment_a.values() do
      set_a.set(i)
    end
    for i in compartment_b.values() do
      set_b.set(i)
    end
    // Intersect the sets, leaving us with the common item
    set_a.intersect(set_b)
    let items = set_a.values()
    if items.has_next() then
      try
        let item = items.next()?
        let priority = Priority.forItem(item)
        main.report(priority)
      end
    end


primitive Priority
  fun forItem(item: U8): U32 =>
    if item > 96 then
      // lowercase letters are 97 to 122
      (item - 96).u32()
    else
      // uppercase letters are 65 to 90
      (item - 38).u32()
    end

