use "files"
use "collections"
use "itertools"

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
            // Build an array of all section ids for each elf pair
            let assignments: Array[String] iso = line.split_by(",")
            let elf_1: Array[U32] val = recover val Assignment.fromString(assignments(0) ?) ? end
            let elf_2: Array[U32] val = recover val Assignment.fromString(assignments(1) ?) ? end
            // Get the checker to see if a section contains its counterpart and report back
            SectionChecker(elf_1, elf_2).checkSections(this)
            msg_count = msg_count + 1
          end
      end
    end
  
  be report(result: U32) =>
    msg_count = msg_count - 1
    total = total + result
    if msg_count == 0 then
      stdout.print("Result is " + total.string())
    end
  

primitive Assignment
  fun fromString(str: String): Array[U32] ? =>
    let section_ids = str.split_by("-")
    let from = section_ids(0) ?.u32() ?
    let to = section_ids(1) ?.u32() ? + 1
    let assigned_ids: Range[U32] = Range[U32](from, to)
    let assignment: Array[U32] = []
    for id in assigned_ids do
      assignment.push(id)
    end
    assignment


actor SectionChecker
  let section_1: Array[U32] val
  let section_2: Array[U32] val

  new create(section_1': Array[U32] val, section_2': Array[U32] val) =>
    section_1 = section_1'
    section_2 = section_2'

  be checkSections(main: Main) =>
    let section_1_contains_2 = Iter[U32](section_2.values()).all({(s) => section_1.contains(s)})
    let section_2_contains_1 = Iter[U32](section_1.values()).all({(s) => section_2.contains(s)})
    if section_1_contains_2 or section_2_contains_1 then
      main.report(1)
    else
      main.report(0)
    end