
#define SEG_SIZE 100005
#define node_t int
#define left_node(root) (root * 2)
#define right_node(root) (root * 2 + 1)

struct SegmentTree {
    node_t sum;
    node_t lazy;
    int seg_l;
    int seg_r;
} seg_tree[4 * SEG_SIZE];

void push_up(int root) {
    seg_tree[root].sum = seg_tree[left_node(root)].sum + seg_tree[right_node(root)].sum;
}

void push_down(int root) {
    int seg_mid = (seg_tree[root].seg_l + seg_tree[root].seg_r) / 2;
    seg_tree[left_node(root)].lazy += seg_tree[root].lazy;
    seg_tree[left_node(root)].sum += seg_tree[root].lazy * (seg_mid - seg_tree[root].seg_l + 1);
    seg_tree[right_node(root)].lazy += seg_tree[root].lazy;
    seg_tree[right_node(root)].sum += seg_tree[root].lazy * (seg_tree[root].seg_r - (seg_mid + 1) + 1);
    seg_tree[root].lazy = 0;
}

void creat_seg_tree(int root, int seg_l, int seg_r, int *seg) {
    seg_tree[root].lazy = 0;
    seg_tree[root].seg_l = seg_l;
    seg_tree[root].seg_r = seg_r;
    if(seg_l == seg_r) {
        seg_tree[root].sum = seg[seg_l];
    } else {
        int seg_mid = (seg_l + seg_r) / 2;
        creat_seg_tree(left_node(root), seg_l, seg_mid, seg);
        creat_seg_tree(right_node(root), seg_mid + 1, seg_r, seg);
        push_up(root);
    }
}

void update_seg_tree(int root, int update_l, int update_r, node_t val) {
    if(update_l <= seg_tree[root].seg_l && seg_tree[root].seg_r <= update_r) {
        seg_tree[root].sum += val * (seg_tree[root].seg_r - seg_tree[root].seg_l + 1);
        seg_tree[root].lazy += val;
    } else {
        if(seg_tree[root].lazy) {
            push_down(root);
        }
        int seg_mid = (seg_tree[root].seg_l + seg_tree[root].seg_r) / 2;
        if(update_l <= seg_mid) {
            update_seg_tree(left_node(root), update_l, update_r, val);
        }
        if(seg_mid + 1 <= update_r) {
            update_seg_tree(right_node(root), update_l, update_r, val);
        }
        push_up(root);
    }
}

node_t query_seg_tree(int root, int query_l, int query_r) {
    if(query_l <= seg_tree[root].seg_l && seg_tree[root].seg_r <= query_r) {
        return seg_tree[root].sum;
    } else {
        if(seg_tree[root].lazy) {
            push_down(root);
        }
        int seg_mid = (seg_tree[root].seg_l + seg_tree[root].seg_r) / 2;
        node_t sum = 0;
        if(query_l <= seg_mid) {
            sum += query_seg_tree(left_node(root), query_l, query_r);
        }
        if(seg_mid + 1 <= query_r) {
            sum += query_seg_tree(right_node(root), query_l, query_r);
        }
        return sum;
    }
}
