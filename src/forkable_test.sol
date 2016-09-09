import 'dapple/test.sol';
import 'forkable.sol';

contract ForkableDatastoreTest is Test {
    ForkableDatastoreService data;
    uint32 branch1;
    uint32 branch2;
    function setUp() {
        data = new ForkableDatastoreService();
        branch1 = data.fork(0);
        data.set(branch1, "A", 10);
        data.set(branch1, "B", 20);
        data.set(branch1, "C", 30);
    }
    function testSetup() {
        assertEq32(0, data.get(0, "unused_key"));
        assertEq(1, uint(branch1));
        assertEq32(data.get(branch1, "A"), 10);
    }
    function testFirstForkInternals() {
        var node_id = data.getBranchInfo(branch1);
        assertEq(1, uint(node_id));
        var (parent, sibling) = data.getNodeInfo(1);
        assertEq(0, uint(parent));
        assertEq(0, uint(sibling));
    }
    function testForkThenSet() {
        var node1 = data.getBranchInfo(branch1);
        log_named_uint("branch1 node", node1);
        var (parent1, sibling1) = data.getNodeInfo(node1);
        log_named_uint("branch1 parent", parent1);
        log_named_uint("branch1 sibling", sibling1);

        logs("FORK");
        branch2 = data.fork(branch1);
        assertEq(uint(branch2), 2);
        node1 = data.getBranchInfo(branch1);
        var node2 = data.getBranchInfo(2);
        log_named_uint("branch1 node", node1);
        log_named_uint("branch2 node", node2);

        (parent1, sibling1) = data.getNodeInfo(node1);
        log_named_uint("branch1 parent", parent1);
        log_named_uint("branch1 sibling", sibling1);
        var (parent2, sibling2) = data.getNodeInfo(node2);
        log_named_uint("branch2 parent", parent2);
        log_named_uint("branch2 sibling", sibling2);
        

        data.set(branch1, "A", 11);
        assertEq32(data.get(branch1, "A"), 11);
        assertEq32(data.get(branch1, "B"), 20);

        assertEq32(data.get(branch2, "A"), 10);
        assertEq32(data.get(branch2, "B"), 20);
        data.set(branch2, "C", 32);
        assertEq32(data.get(branch1, "C"), 30);
        assertEq32(data.get(branch2, "C"), 32);
    }
}
