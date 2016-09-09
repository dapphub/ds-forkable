import 'dapple/test.sol';
import 'forkable.sol';

contract ForkableDatastoreTest is Test {
    ForkableDatastoreService data;
    function setUp() {
        data = new ForkableDatastoreService();
    }
    function testBasics() {
        assertEq32(0, data.get(0, "nothing"));
        uint32 branch1 = data.fork(0);
        assertEq(uint(branch1), 1);
        data.set(branch1, "key1", "val1");
        data.set(branch1, "key2", "val2");
        assertEq32(data.get(branch1, "key1"), "val1");
        var branch2 = data.fork(1);
        data.set(branch1, "key1", "val1.1");
        assertEq(uint(branch2), 2);
        assertEq32(data.get(branch1, "key1"), "val1.1");
        assertEq32(data.get(branch2, "key1"), "val1");
    }
}
