/* Advent of Code 2024
 * Day 23: LAN Party
 */

#import "Basic";
#import "File";
#import "Hash_Table";
#import "Sort";
#import "String";

Connection_Table :: Table(string, [..] string);

// Finds all maximal cliques using the Bron-Kerbosch algorithm.
bron_kerbosch :: (
    r: [] string,
    p: [] string,
    x: [] string,
    connections: Connection_Table,
    cliques: *[..][..] string
) {
    if p.count == 0 && x.count == 0 {
        // We've found a maximal clique.
        clique: [..] string;
        array_copy(*clique, r);
        array_add(cliques, clique);
    }

    // p and x are passed as array views, but we need to modify them.
    mutable_p: [..] string;
    array_copy(*mutable_p, p);
    defer array_free(mutable_p);

    mutable_x: [..] string;
    array_copy(*mutable_x, x);
    defer array_free(mutable_x);

    for mutable_p {
        new_r: [..] string;
        new_p: [..] string;
        new_x: [..] string;

        defer array_free(new_r);
        defer array_free(new_p);
        defer array_free(new_x);

        array_copy(*new_r, r);
        array_add(*new_r, it);

        // The connections table is guaranteed to contain all computers.
        individual_connections, _ := table_find(*connections, it);

        for mutable_p {
            if array_find(individual_connections, it) {
                array_add(*new_p, it);
            }
        }

        for mutable_x {
            if array_find(individual_connections, it) {
                array_add(*new_x, it);
            }
        }

        bron_kerbosch(new_r, new_p, new_x, connections, cliques);

        array_add(*mutable_x, it);
        remove it;
    }
}

main :: () {
    input, success := read_entire_file("inputs/day_23.txt");
    assert(success);

    lines := split(input, "\n");
    defer array_free(lines);

    connections: Connection_Table;
    defer {
        for connections {
            array_free(it);
        }

        deinit(*connections);
    }

    for lines {
        if it == "" {
            continue;
        }

        computers := split(it, "-");
        defer array_free(computers);

        for computers {
            individual_connections := table_find_pointer(*connections, it);
            if individual_connections == null {
                individual_connections: [..] string;
                array_add(*individual_connections, computers[xx !it_index]);
                table_add(*connections, it, individual_connections);
            } else {
                array_add(individual_connections, computers[xx !it_index]);
            }
        }
    }

    computers: [..] string;
    defer array_free(computers);

    for connections {
        array_add(*computers, it_index);
    }

    triangles_with_t := 0;
    for computer_a, index_a: computers {
        connections_a, _ := table_find(*connections, computer_a);
        for computer_b: connections_a {
            _, index_b := array_find(computers, computer_b);
            if index_b <= index_a {
                continue;
            }

            connections_b, _ := table_find(*connections, computer_b);
            for computer_c: connections_b {
                _, index_c := array_find(computers, computer_c);
                if index_c <= index_b {
                    continue;
                }

                if array_find(connections_a, computer_c) && (
                    computer_a[0] == #char "t"
                    || computer_b[0] == #char "t"
                    || computer_c[0] == #char "t"
                ) {
                    triangles_with_t += 1;
                }
            }
        }
    }

    print("Part 1: %\n", triangles_with_t);

    cliques: [..][..] string;
    defer {
        for cliques {
            array_free(it);
        }

        array_free(cliques);
    }

    bron_kerbosch(.[], computers, .[], connections, *cliques);

    lan_party: [..] string;
    largest_count := 0;

    for cliques {
        if it.count > largest_count {
            lan_party = it;
            largest_count = it.count;
        }
    }

    print("Part 2: %\n", join(.. quick_sort(lan_party, compare), ","));
}
