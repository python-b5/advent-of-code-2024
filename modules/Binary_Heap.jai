/* Binary_Heap.jai
 * by python-b5
 *
 * A simple generic implementation of a binary heap / priority queue.
 */

// order_test is used to determine the order of the values in the queue. It
// should return whether the first passed value should be given higher priority
// than the second passed value.
Heap :: struct (
    Value_Type: Type,
    order_test: (Value_Type, Value_Type) -> bool
) {
    values: [..] Value_Type;
}

heap_add :: (heap: *Heap, value: heap.Value_Type) {
    array_add(*heap.values, value);

    current_index := heap.values.count - 1;
    while current_index > 0 {
        parent_index := (current_index - 1) / 2;

        current_value := heap.values[current_index];
        parent_value := heap.values[parent_index];

        if heap.order_test(parent_value, current_value) {
            break;
        }

        heap.values[current_index] = parent_value;
        heap.values[parent_index] = current_value;
        current_index = parent_index;
    }
}

heap_pop :: (heap: *Heap) -> heap.Value_Type {
    assert(!heap_is_empty(heap), "cannot pop from an empty heap");

    root_value := heap.values[0];
    heap.values[0] = pop(*heap.values);

    current_index := 0;
    while true {
        left_index := current_index * 2 + 1;
        right_index := left_index + 1;

        has_left := left_index < heap.values.count;
        has_right := right_index < heap.values.count;

        if !has_left && !has_right {
            break;
        }

        child_index: int;
        if !has_left {
            child_index = right_index;
        } else if !has_right {
            child_index = left_index;
        } else if heap.order_test(
            heap.values[left_index],
            heap.values[right_index]
        ) {
            child_index = left_index;
        } else {
            child_index = right_index;
        }

        current_value := heap.values[current_index];
        child_value := heap.values[child_index];

        if heap.order_test(current_value, child_value) {
            break;
        }

        heap.values[current_index] = child_value;
        heap.values[child_index] = current_value;
        current_index = child_index;
    }

    return root_value;
}

// These last two procedures don't require the heap be passed as a pointer,
// since they do not modify it.
heap_is_empty :: inline (heap: Heap) -> bool {
    return heap.values.count == 0;
}

heap_free :: inline (heap: Heap) {
    for heap.values {
        free(it);
    }

    array_free(heap.values);
}

#scope_file

#import "Basic";
