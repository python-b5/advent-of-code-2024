/* Advent of Code 2024
 * Day 17: Chronospatial Computer
 */

#import "Basic";
#import "File";
#import "String";

Registers :: struct {
    a, b, c: int;
}

State :: struct {
    register_a, iteration: int;
}

resolve_combo_operand :: (operand: u8, registers: Registers) -> int {
    if operand == {
        case 4; return registers.a;
        case 5; return registers.b;
        case 6; return registers.c;
        case;   return operand;
    }
}

run_program :: (initial_registers: Registers, program: [] u8) -> [..] int {
    registers := initial_registers;
    instruction_pointer := 0;
    output: [..] int;

    while instruction_pointer < program.count {
        opcode := program[instruction_pointer];
        operand := program[instruction_pointer + 1];
        instruction_pointer += 2;

        // I don't personally find the instruction names any more readable than
        // the plain opcodes, so I didn't bother using an enum.
        if opcode == {
            case 0;
                registers.a = (
                    registers.a
                    / 1 << resolve_combo_operand(operand, registers)
                );

            case 1;
                registers.b = registers.b ^ operand;

            case 2;
                registers.b = resolve_combo_operand(operand, registers) % 8;

            case 3;
                if registers.a != 0 {
                    instruction_pointer = operand;
                }

            case 4;
                registers.b = registers.b ^ registers.c;

            case 5;
                array_add(
                    *output,
                    resolve_combo_operand(operand, registers) % 8
                );

            case 6;
                registers.b = (
                    registers.a
                    / 1 << resolve_combo_operand(operand, registers)
                );

            case 7;
                registers.c = (
                    registers.a
                    / 1 << resolve_combo_operand(operand, registers)
                );
        }
    }

    return output;
}

main :: () {
    input, success := read_entire_file("inputs/day_17.txt");
    assert(success);

    lines := split(input, "\n");
    defer array_free(lines);

    program_strings := split(slice(lines[4], 9, lines[4].count - 9), ",");
    defer array_free(program_strings);

    program: [..] u8;
    defer array_free(program);

    for program_strings {
        array_add(*program, xx string_to_int(it));
    }

    output := run_program(.{
        a = string_to_int(slice(lines[0], 12, lines[0].count - 12)),
        b = string_to_int(slice(lines[1], 12, lines[1].count - 12)),
        c = string_to_int(slice(lines[2], 12, lines[2].count - 12))
    }, program);
    defer array_free(output);

    builder: String_Builder;
    defer reset(*builder);

    for output {
        print_to_builder(*builder, "%", it);
        if it_index < output.count - 1 {
            append(*builder, ",");
        }
    }

    print("Part 1: %\n", builder_to_string(*builder));

    // Every three bits given to the program add another number to the output.
    // Because of this, we can bruteforce three bits at a time. We're using DFS
    // here instead of just bruteforcing the groups of bits in sequence because
    // occasionally we may run into a false lead.
    stack: [..] State;
    array_add(*stack, .{0, 0});
    defer array_free(stack);

    lowest_solution := -1;
    while stack.count {
        current := pop(*stack);
        target := program[program.count - current.iteration - 1];

        for 0..7 {
            new_register_a := current.register_a << 3 | it;
            registers := Registers.{new_register_a, 0, 0};

            output := run_program(registers, program);
            defer array_free(output);

            if output[0] == target {
                if current.iteration == program.count - 1 {
                    if
                        new_register_a < lowest_solution
                        || lowest_solution == -1
                    {
                        lowest_solution = new_register_a;
                    }
                } else {
                    array_add(*stack, .{registers.a, current.iteration + 1});
                }
            }
        }
    }

    print("Part 2: %\n", lowest_solution);
}
