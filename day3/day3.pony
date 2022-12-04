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
          let lines = file.lines()
          // Dispatch 3 lines at a time to a BatchChecker
          while lines.has_next() do
            var batch_count: U32 = 0
            let checker = BatchChecker(this)
            while lines.has_next() and (batch_count < 3) do
              checker.addSack(lines.next()?)
              batch_count = batch_count + 1
            end
            checker.checkBatch()
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


actor BatchChecker
  var batch: Array[String]
  let main: Main

  new create(main': Main) =>
    batch = []
    main = main'

  be addSack(sack: String) =>
    batch.push(sack)
  
  be checkBatch() =>
    try
      // Build the first set from the first sack
      let first_set = Set[U8].create()
      let first_sack = batch.shift()?
      for i in first_sack.values() do
        first_set.set(i)
      end
      // Build a set for each remaining sack and intersect with the first
      let other_sacks = batch.values()
      while other_sacks.has_next() do
        let next_set = Set[U8].create()
        let next_sack = other_sacks.next()?
        for i in next_sack.values() do
          next_set.set(i)
        end
        first_set.intersect(next_set)
      end
      // Calculate priority from the common item
      let items = first_set.values()
      if items.has_next() then
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

