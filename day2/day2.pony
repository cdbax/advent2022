use "files"
use "itertools"

primitive Rock
primitive Paper
primitive Scissors

type Shape is (Rock | Paper | Scissors)

primitive ShapeBuilder
  fun fromString(s: String): Shape? =>
    match s
    | "A" | "X" => Rock
    | "B" | "Y" => Paper
    | "C" | "Z" => Scissors
    else
      error
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
            let round: Array[Shape] = 
                          Iter[String]((consume chars).values())
                            .map[Shape]({(s: String): Shape? => ShapeBuilder.fromString(s)?})
                            .collect(Array[Shape](2))
            if round.size() == 2 then
              let opponent: Shape = round(0)?
              let me: Shape = round(1)?
              Game(opponent, me).reportScore(this)
              msg_count = msg_count + 1
            end
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