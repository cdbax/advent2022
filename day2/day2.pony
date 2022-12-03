use "files"
use "itertools"

primitive Rock
primitive Paper
primitive Scissors

type Shape is (Rock | Paper | Scissors)

primitive Win
primitive Lose
primitive Draw

type Goal is (Win | Lose | Draw)

primitive Builder
  fun shapeFromString(s: String): Shape? =>
    match s
    | "A" => Rock
    | "B" => Paper
    | "C" => Scissors
    else
      error
    end

  fun goalFromString(s: String): Goal? =>
    match s
    | "X" => Lose
    | "Y" => Draw
    | "Z" => Win
    else
      error
    end

  fun nextMove(s: Shape, g: Goal): Shape =>
    match g
    | Draw => s
    | Lose =>
      match s
      | Rock => Scissors
      | Paper => Rock
      | Scissors => Paper
      end
    | Win =>
      match s
      | Rock => Paper
      | Paper => Scissors
      | Scissors => Rock
      end
    end




actor Main
  let stdout: OutStream
  var total: U32 = 0
  var msg_count: U32 = 0

  new create(env: Env) =>
    stdout = env.out

    try
      let file_name = env.args(1)?
      let path = FilePath(FileAuth(env.root), file_name)
      match OpenFile(path)
      | let file: File =>
          for line in file.lines() do
            let chars: Array[String] = line.split_by(" ")
            let opponent: Shape = Builder.shapeFromString(chars(0)?)?
            let goal: Goal = Builder.goalFromString(chars(1)?)?
            let me: Shape = Builder.nextMove(opponent, goal)
            Game(opponent, me).reportScore(this)
            msg_count = msg_count + 1
          end
      else
        env.err.print("Error opening file '" + file_name + "'")
      end
    end

  be recordScore(score: U32) =>
    total = total + score
    msg_count = msg_count - 1
    if msg_count == 0 then
      stdout.print("Total score is: " + total.string())
    end



primitive GameScorer
  fun calculateScore(a: Shape, b: Shape): U32 =>
    let pointsForRound: U32 =
      // This implementation makes me sad.
      // I wanted to have a match case like `| (a, a) => 3` and not have to
      // write 3 separate cases for Draws, but apparently primitives can't
      // be compared like that, so here we are.
      match (a, b)
      | (Rock, Rock) => 3
      | (Paper, Paper) => 3
      | (Scissors, Scissors) => 3
      | (Rock, Paper) => 6
      | (Paper, Scissors) => 6
      | (Scissors, Rock) => 6
      else
        0
      end
    pointsForRound + pointsForShape(b)
  
  fun pointsForShape(s: Shape): U32 =>
    match s
    | Rock => 1
    | Paper => 2
    | Scissors => 3
    end

actor Game
  let score: U32

  new create(opponent_choice: Shape val, my_choice: Shape val) =>
    score = GameScorer.calculateScore(opponent_choice, my_choice)

  be reportScore(main: Main) =>
    main.recordScore(score)