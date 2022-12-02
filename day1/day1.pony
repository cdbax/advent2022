use "files"
use "itertools"

actor Main
  var msg_count: U32 = 0
  var max: U32 = 0
  let stdout: OutStream

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
              current_elf = Elf //Replace current elf with a new elf
            | let s: String => 
              try
                current_elf.pack(s.u32()?)
              end
            end
          end
      else
        env.err.print("Error opening file '" + file_name + "'")
      end
    end
  
  be report(sum: U32) =>
    msg_count = msg_count - 1
    if sum > max then
      max = sum
    end
    if msg_count == 0 then
      stdout.print("Max calories is " + max.string())
    end


actor Elf
  // An array of calorie counts for each snack
  let snacks: Array[U32]

  new create() =>
    snacks = []

  be pack(food: U32) =>
    snacks.push(food)

  be getTotalCalories(main: Main) =>
    let sum: U32 = Iter[U32](snacks.values()).fold[U32](0, {(sum, i) => sum + i })
    main.report(sum)

