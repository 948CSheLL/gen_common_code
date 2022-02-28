#include <stdio.h>
#include <string.h>
#include "CUnit/Basic.h"

extern int *upper_bound(int *, int *, int);

struct TestData {
    int array_list[105];
    int array_size;
    int search_val;
    int desired_ans;
} test_data[] = {
    { {1, 1, 2, 3, 3}, 5, 2, 3}, 
    { {1, 1, 3, 4, 5}, 5, 1, 2}, 
    { {1, 2, 3, 5, 5}, 5, 5, 5}, 
    { {1, 2, 3, 4, 5}, 5, 5, 5}, 
    { {1, 4, 5, 5, 8}, 5, 3, 1}, 
    { {1, 4, 5, 5, 8}, 5, 6, 4}, 
    { {1, 4, 5, 5, 8}, 5, 9, 5}, 
    { {1, 4, 6, 6, 8}, 5, 5, 2}, 
};

int judge_expression(struct TestData temp) {
    int ans = upper_bound(temp.array_list, temp.array_list + temp.array_size, temp.search_val) - temp.array_list;
    return ans == temp.desired_ans;
}

void testUPPER_BOUND(void) {
    CU_ASSERT(judge_expression(test_data[0]));
    CU_ASSERT(judge_expression(test_data[1]));
    CU_ASSERT(judge_expression(test_data[2]));
    CU_ASSERT(judge_expression(test_data[3]));
    CU_ASSERT(judge_expression(test_data[4]));
    CU_ASSERT(judge_expression(test_data[5]));
    CU_ASSERT(judge_expression(test_data[6]));
    CU_ASSERT(judge_expression(test_data[7]));
}

int main()
{
   CU_pSuite pSuite = NULL;

   if (CUE_SUCCESS != CU_initialize_registry())
      return CU_get_error();

   pSuite = CU_add_suite("Suite_1", NULL, NULL);
   if (NULL == pSuite) {
      CU_cleanup_registry();
      return CU_get_error();
   }

   if (NULL == CU_add_test(pSuite, "test of upper_bound()", testUPPER_BOUND)) {
      CU_cleanup_registry();
      return CU_get_error();
   }
   CU_basic_set_mode(CU_BRM_VERBOSE);
   CU_basic_run_tests();
   CU_cleanup_registry();
   return CU_get_error();
}
