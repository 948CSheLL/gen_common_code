#include "CUnit/Basic.h"

extern int *lower_bound(int *, int *, int);

struct TestData {
    int array_list[105];
    int array_l;
    int array_r;
    int search_val;
    int desired_ans;
    int is_null;
} test_data[] = {
    { {1, 1, 2, 3, 3}, 0, 0, 2, 2, 1},
    { {1, 1, 2, 3, 3}, 1, 0, 2, 2, 1},
    { {1, 1, 2, 3, 3}, 0, 5, 2, 2, 0},
    { {1, 1, 3, 4, 5}, 0, 5, 1, 0, 0},
    { {1, 2, 3, 5, 5}, 0, 5, 5, 3, 0},
    { {1, 2, 3, 4, 5}, 0, 5, 5, 4, 0},
    { {1, 4, 5, 5, 8}, 0, 5, 3, 1, 0},
    { {1, 4, 5, 5, 8}, 0, 5, 6, 4, 0},
    { {1, 4, 5, 5, 8}, 0, 5, 9, 5, 0},
    { {1, 4, 6, 6, 8}, 0, 5, 5, 2, 0},
};

int judge_expression(struct TestData temp) {
    int *p_ans = lower_bound(temp.array_list + temp.array_l, temp.array_list + temp.array_r, temp.search_val);
    if(temp.is_null) {
        return NULL == p_ans;
    } else {
        return (p_ans - temp.array_list - temp.array_l) == temp.desired_ans;
    }
}

void testLOWER_BOUND(void) {
    CU_ASSERT(judge_expression(test_data[0]));
    CU_ASSERT(judge_expression(test_data[1]));
    CU_ASSERT(judge_expression(test_data[2]));
    CU_ASSERT(judge_expression(test_data[3]));
    CU_ASSERT(judge_expression(test_data[4]));
    CU_ASSERT(judge_expression(test_data[5]));
    CU_ASSERT(judge_expression(test_data[6]));
    CU_ASSERT(judge_expression(test_data[7]));
    CU_ASSERT(judge_expression(test_data[8]));
    CU_ASSERT(judge_expression(test_data[9]));
}

int main() {
    CU_pSuite pSuite = NULL;

    if (CUE_SUCCESS != CU_initialize_registry())
        return CU_get_error();

    pSuite = CU_add_suite("Suite_1", NULL, NULL);
    if (NULL == pSuite) {
        CU_cleanup_registry();
        return CU_get_error();
    }

    if (NULL == CU_add_test(pSuite, "test of lower_bound()", testLOWER_BOUND)) {
        CU_cleanup_registry();
        return CU_get_error();
    }
    CU_basic_set_mode(CU_BRM_VERBOSE);
    CU_basic_run_tests();
    CU_cleanup_registry();
    return CU_get_error();
}
