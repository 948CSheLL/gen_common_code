
int *lower_bound(int *array_l, int *array_r, int val) {
    if(array_l >= array_r) {
        fprintf(stderr, "lower_bound error: array_l greater equal than array_r\n");
        return NULL;
    }
    while(array_l < array_r) {
        int *mid = array_l + (array_r - array_l) / 2;
        if(*mid >= val) {
            array_r = mid;
        } else {
            array_l = mid + 1;
        }
    }
    return array_r;
}
