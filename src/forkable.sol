import 'ds-auth/auth.sol';
import 'ds-base/base.sol';

contract ForkableDatastoreService is DSBase {
    function ForkableDatastore() {
    }
    struct Branch {
        address owner;
        uint parent;
        uint left;
        uint right;
    }
    struct Entry {
        bytes32 value;
        bool exists;
    }
    mapping(uint=>Branch) _branches;
    mapping(uint=>uint) _parents;
    mapping(uint=> mapping(bytes32=>bytes32) ) _storages;
    uint next_branch;

    function fork(uint branch_id) returns (uint new_branch) {
        var parent = _branches[branch_id];
        var left_id = next_branch++;
        var right_id = next_branch++;
        var left = Branch({ owner: parent.owner, parent: branch_id, left: left_id, right: right_id });
        // create two children
        // reassign virtual id
    }

    function advanceEntry(uint branch, bytes32 key) internal {
        var b = _branches[branch];
        _storages[b.left][key] = _storages[branch][key];
        _storages[b.right][key] = _storages[branch][key];
        delete _storages[branch][key];
    }
}
