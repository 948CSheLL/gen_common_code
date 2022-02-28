#include <stdio.h>
#include <string.h>
#include "CUnit/Basic.h"

extern int function_name(void);
int judge_expression(void);
void testFUNCTION_NAME(void);

int main() {
    CU_pSuite pSuite = NULL;

    if (CUE_SUCCESS != CU_initialize_registry())
        return CU_get_error();

    pSuite = CU_add_suite("Suite_1", NULL, NULL);
    if (NULL == pSuite) {
        CU_cleanup_registry();
        return CU_get_error();
    }

    if (NULL == CU_add_test(pSuite, "test of function_name()", testFUNCTION_NAME)) {
        CU_cleanup_registry();
        return CU_get_error();
    }
    CU_basic_set_mode(CU_BRM_VERBOSE);
    CU_basic_run_tests();
    CU_cleanup_registry();
    return CU_get_error();
}

void testFUNCTION_NAME(void) {
    CU_ASSERT(judge_expression());
}
