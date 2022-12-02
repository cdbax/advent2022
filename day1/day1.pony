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
          var elves: Array[Elf] = []
          var current_elf: Elf = Elf
          for line in file.lines() do
            match line
            | "" =>
              elves.push(current_elf)
              current_elf = Elf
            | let s: String => 
              try
                current_elf.eat(s.u32()?)
              end
            end
          end
          for elf in elves.values() do
            elf.getTotalCalories(this)
            msg_count = msg_count + 1
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
      stdout.print("Answer is " + max.string())
    end


actor Elf
  let calories: Array[U32]

  new create() =>
    calories = []

  be eat(food: U32) =>
    calories.push(food)

  be getTotalCalories(main: Main) =>
    let sum: U32 = Iter[U32](calories.values()).fold[U32](0, {(sum, i) => sum + i })
    main.report(sum)