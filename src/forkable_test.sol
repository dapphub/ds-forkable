import 'dapple/test.sol';
import 'forkable.sol';

contract ForkableDatastoreTest is Test {
    ForkableDatastoreService data;
    function setUp() {
        data = new ForkableDatastoreService();
    }
    function testBasics() {
    }
}
