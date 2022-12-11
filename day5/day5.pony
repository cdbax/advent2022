use "files"
use "collections"
use "itertools"


class Stack
  var crates: Array[String] iso
  let id: U8

  new create(id': U8) =>
    id = id'
    crates = recover Array[String] end


actor Main
  let stdout: OutStream
  let stacks: Map[U8, Stack] = Map[U8, Stack].create()

  new create(env: Env) =>
    stdout = env.out

    try
      let file_name = env.args(1)?
      let path = FilePath(FileAuth(env.root), file_name)
      match OpenFile(path)
      | let file: File =>
          let lines = file.lines()
          let header = Array[String].create()
          for line in lines do
            // Only process the header data for now
            env.out.print(line.clone())
            if line == "" then
              break
            end
            header.push(consume line)
          end
          // Get the stack IDs
          let stack_ids = header.pop() ?.clone()
          stack_ids.remove(" ")
          // Add an empty array to stacks for every stack_id
          for id in stack_ids.clone().values() do
            let u8_id = String.from_array([id]).u8() ?
            stacks.insert(u8_id, Stack.create(u8_id))
          end
          // Process each remaining header row
          for row in header.values() do
            // Chunks are 4 bytes. We should have one chunk for every stack id.
            // If a byte starts with a [ then add the container type to the stack. 
            var idx: U8 = 0
            var buffer = row.clone()
            while idx < stack_ids.size().u8() do
              let key_char = stack_ids(idx.usize()) ?
              let key = String.from_array([key_char]).u8() ?
              (let chunk, buffer) = (consume buffer).chop(4)
              if chunk(0) ? == '[' then
                // This is a crate, so add it to the relevant stack
                // We don't really care about when this promise will resolve, so we don't store it.
                let crate = chunk(1) ?
                stacks(key) ?.crates.push(String.from_array([consume crate]))
              end
              idx = idx + 1
            end
          end

          // Remaining lines are instructions
          for line in lines do
            var parts = line.split_by(" ")
            let qty = parts(1) ?.usize() ?
            let from_id = parts(3) ?
            let to_id = parts(5) ?
            stdout.print("Move " + qty.string() + " from " + from_id.string() + " to " + to_id.string())
            let from_stack = stacks(from_id.u8() ?) ?
            (let load: Array[String] iso, from_stack.crates) = (consume from_stack.crates).chop(qty)
            stdout.print("Qty = " + qty.string() + " Load = " + load.size().string())
            let to_stack = stacks(to_id.u8() ?) ?
            for c in (consume load).values() do
              stdout.print("Adding " + c + " to " + to_id)
              to_stack.crates.unshift(c)
            end
          end

          let strings: Array[String] =
            Iter[Stack](stacks.values())
              .map[String]({(s) ?=> 
                let crate: String = s.crates.shift() ?
                s.id.string() + " = " + (consume crate)
              })
              .collect(Array[String])
          let sorted: Array[String] = Sort[Array[String], String](strings)

          for s in sorted.values() do
            stdout.print(s)
          end
      end
    end
