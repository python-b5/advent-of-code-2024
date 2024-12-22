/* Advent of Code 2024
 * Day 22: Monkey Market
 */

#import "Basic";
#import "File";
#import "Hash_Table";
#import "String";

// There's no point making this an actual == operator; it's never used as such,
// and doing so would make it harder to use in tables.
change_sequences_are_equal :: inline (a: [4] int, b: [4] int) -> bool {
    return a[0] == b[0] && a[1] == b[1] && a[2] == b[2] && a[3] == b[3];
}

main :: () {
    input, success := read_entire_file("inputs/day_22.txt");
    assert(success);

    lines := split(input, "\n");
    defer array_free(lines);

    secrets: [..] int;
    defer array_free(secrets);

    for lines {
        if it != "" {
            array_add(*secrets, string_to_int(it));
        }
    }

    price_sums: Table(
        [4] int,
        int,
        given_compare_function = change_sequences_are_equal
    );
    defer deinit(*price_sums);

    secret_sum := 0;
    for secrets {
        prices: [2001] int;
        prices[0] = it % 10;

        for 1..2000 {
            secrets[it_index] = (
                (secrets[it_index] * 64) ^ secrets[it_index]
            ) % 16777216;

            secrets[it_index] = (
                (secrets[it_index] / 32) ^ secrets[it_index]
            ) % 16777216;

            secrets[it_index] = (
                (secrets[it_index] * 2048) ^ secrets[it_index]
            ) % 16777216;

            prices[it] = secrets[it_index] % 10;
        }

        secret_sum += secrets[it_index];

        changes: [2000] int;
        for prices {
            if it_index > 0 {
                changes[it_index - 1] = it - prices[it_index - 1];
            }
        }

        seen_sequences: Table(
            [4] int,
            void,
            given_compare_function = change_sequences_are_equal
        );

        for 1..1997 {
            sequence: [4] int;
            for array_view(changes, it - 1, 4) {
                sequence[it_index] = it;
            }

            if !table_contains(*seen_sequences, sequence) {
                current_price_sum, success := table_find(*price_sums, sequence);
                if success {
                    table_set(
                        *price_sums,
                        sequence,
                        current_price_sum + prices[it + 3]
                    );
                } else {
                    table_add(*price_sums, sequence, prices[it + 3]);
                }

                table_add(*seen_sequences, sequence, #run {});
            }
        }
    }

    print("Part 1: %\n", secret_sum);

    max_price_sum := 0;
    for price_sums {
        if it > max_price_sum {
            max_price_sum = it;
        }
    }

    print("Part 2: %\n", max_price_sum);
}
