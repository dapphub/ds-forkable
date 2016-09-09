import 'dapple/test.sol';
import 'forkable.sol';

contract ForkableDatastoreTest is Test {
    ForkableDatastoreService data;
    uint32 branch1;
    uint32 branch2;
    function setUp() {
        data = new ForkableDatastoreService();
        branch1 = data.fork(0);
        data.set(branch1, "A", "10");
        data.set(branch1, "B", "20");
        data.set(branch1, "C", "30");
    }
    function testBasics() {
        assertEq32(0, data.get(0, "unused_key"));
        assertEq(uint(branch1), 1);
        assertEq32(data.get(branch1, "A"), "10");
    }
    function testForkThenSet() {
        branch2 = data.fork(1);
        assertEq(uint(branch2), 2);
        data.set(branch1, "A", "11");
        assertEq32(data.get(branch1, "A"), "11");
        assertEq32(data.get(branch2, "A"), "10");
        assertEq32(data.get(branch1, "B"), "20");
        assertEq32(data.get(branch2, "B"), "20");
    }
}
