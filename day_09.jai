/* Advent of Code 2024
 * Day 09: Disk Fragmenter
 */

#import "Basic";
#import "File";

main :: () {
    input, success := read_entire_file("inputs/day_09.txt");
    assert(success);

    disk_part_1: [..] int;
    defer array_free(disk_part_1);

    creating_file := true;
    file_index := 0;
    max_file_index := 0;

    file_disk_positions: [..] int;
    file_sizes: [..] int;
    defer array_free(file_disk_positions);
    defer array_free(file_sizes);

    for input {
        // For some reason, leaving this out (and thus treating the trailing
        // newline as a size of 218, due to how the size is calculated) doesn't
        // seem to affect the results? To be safe, I'm going to keep it in, just
        // in case it's only a quirk with my input specifically.
        if it == #char "\n" {
            continue;
        }

        // We need the size twice if we're creating a file, so it's better to
        // define it up here.
        size := it - #char "0";

        block: int;
        if creating_file {
            block = file_index;

            if file_index > max_file_index {
                max_file_index = file_index;
            }

            file_index += 1;

            array_add(*file_disk_positions, disk_part_1.count);
            array_add(*file_sizes, size);
        } else {
            block = -1;
        }

        for 1..size {
            array_add(*disk_part_1, block);
        }

        creating_file = !creating_file;
    }

    // Needed to detect gaps in part 1.
    file_size_total := 0;
    for file_sizes {
        file_size_total += it;
    }

    // We need to do this before the disk is modified for part 1. This doesn't
    // need to be a resizeable array because unlike in part 1, we won't be
    // popping blocks off it like it's a stack.
    disk_part_2 := array_copy(disk_part_1);
    defer array_free(disk_part_2);

    while part_1_loop := true {
        block := pop(*disk_part_1);
        if block == -1 {
            continue;
        }

        for disk_part_1 {
            if it == -1 {
                disk_part_1[it_index] = block;
                break;
            }
        }

        // If there are no remaining gaps between files, we're finished.
        for disk_part_1 {
            if it == -1 {
                break;
            }

            if it_index == file_size_total - 1 {
                break part_1_loop;
            }
        }
    }

    // Because it's guaranteed in part 1 that there will be no gaps between
    // files, we can stop looping here as soon as we reach an empty block.
    checksum_part_1 := 0;
    for disk_part_1 {
        if it == -1 {
            break;
        }

        checksum_part_1 += it * it_index;
    }

    print("Part 1: %\n", checksum_part_1);

    // You have to mark for loops with #v2 right now for the new reversing
    // behavior to work. This will eventually no longer be required, so if I
    // remember I'll remove the #v2 here when that happens.
    for #v2 < file_index: 0..max_file_index {
        position := file_disk_positions[file_index];
        size := file_sizes[file_index];

        moved_file := false;
        for new_position: 0..position - 1 {
            end := new_position + size - 1;

            for new_position..end {
                if disk_part_2[it] != -1 {
                    continue new_position;
                }
            }

            for new_position..end {
                disk_part_2[it] = file_index;
            }

            moved_file = true;

            // There's a kind of unusual loop structure here, where if we reach
            // the end of the loop we always break. Maybe this could be
            // refactored for better clarity, though it reads okay to me right
            // now.
            break;
        }

        if moved_file {
            for position..position + size - 1 {
                disk_part_2[it] = -1;
            }
        }
    }

    // Unlike in part 1, there may be gaps between files, so we're forced to
    // iterate through the whole disk.
    checksum_part_2 := 0;
    for disk_part_2 {
        if it != -1 {
            checksum_part_2 += it * it_index;
        }
    }

    print("Part 2: %\n", checksum_part_2);
}
