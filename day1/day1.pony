use "files"
use "itertools"
use "collections"

actor Main
  var msg_count: U32 = 0
  var max: U32 = 0
  let stdout: OutStream
  let tally: Tally = Tally

  new create(env: Env) =>
    stdout = env.out

    try
      let file_name = env.args(1)?
      let path = FilePath(FileAuth(env.root), file_name)
      match OpenFile(path)
      | let file: File =>
          var current_elf: Elf = Elf
          for line in file.lines() do
            match line
            | "" =>
              msg_count = msg_count + 1
              current_elf.getTotalCalories(this)
              current_elf = Elf // replace current elf with a new elf
            | let s: String => 
              try
                current_elf.pack(s.u32()?) // parsing the string as a U32 could error, hence the ?
              end
            end
          end
      else
        env.err.print("Error opening file '" + file_name + "'")
      end
    end
  
  be report(sum: U32) =>
    msg_count = msg_count - 1
    tally.newTally(sum)
    if sum > max then
      max = sum
    end
    if msg_count == 0 then
      stdout.print("Max calories is " + max.string())
      tally.reportTotal(stdout)
    end


// A lowly elf that carries snacks
actor Elf
  // An array of calorie counts for each snack
  let snacks: Array[U32]

  new create() =>
    snacks = []

  be pack(food: U32) =>
    snacks.push(food)

  be getTotalCalories(main: Main) =>
    // A .sum function would be nice, but here we are...
    let sum: U32 = Iter[U32](snacks.values()).fold[U32](0, {(sum, i) => sum + i })
    main.report(sum)

// Some rando keeping tally of the elves with the top 3 calorie counts
actor Tally
  var top_3: Array[U32]

  new create() =>
    top_3 = []

  be newTally(tally: U32) =>
    top_3.push(tally)
    let new_top_3 = Sort[Array[U32], U32](top_3) // Yes, this is how you sort arrays in Pony
    if new_top_3.size() > 3 then
      let start = new_top_3.size() - 3
      top_3 = new_top_3.slice(start)
    end

  be reportTotal(stdout: OutStream) =>
    let sum: U32 = Iter[U32](top_3.values()).fold[U32](0, {(sum, i) => sum + i })
    stdout.print("Top 3 Sum is " + sum.string())