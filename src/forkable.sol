import 'ds-base/base.sol';

contract ForkableDatastoreService is DSBase {
    // temporary type tags:
    // uint64: internal ID
    // uint32: "name" - virtual ID
    function ForkableDatastoreService() {
        // Branch 0 points to node 0, whose parent/sibling/storage is 0
        _next_name++;
        _next_node++;
    }
    struct Node {
        uint64 parent;
        uint64 sibling;
        mapping(bytes32=>Entry) writes;
    }
    struct Entry {
        bytes32 value;
        bool live;
    }
    mapping(uint64=>Node) _nodes;
    mapping(uint32=>uint64) _branches;

    uint32 _next_name;
    uint64 _next_node;

    function fork(uint32 branch_name) returns (uint32 child_name) {
        uint64 parent_id = _branches[branch_name];
        Node parent = _nodes[parent_id];

        // Left is old branch, right is new branch
        // Forking branch 0 creates a "quasi-root" with no sibling
        uint64 left_id = 0;
        Node memory left = Node({parent: 0, sibling: 0});
        if( branch_name != 0 ) {
            left_id = _next_node++;
            left = Node({parent: parent_id, sibling: right_id});
            _nodes[left_id] = left;
            _branches[branch_name] = left_id;
        }

        child_name = _next_name++;
        uint64 right_id = _next_node++;
        Node memory right = Node({parent: parent_id, sibling: left_id});
        _nodes[right_id] = right;
        _branches[child_name] = right_id;

    }

    function get(uint32 branch_name, bytes32 key) returns (bytes32) {
        return resolve(_branches[branch_name], key);
    }
    function set(uint32 branch_name, bytes32 key, bytes32 value) {
        var node_id = _branches[branch_name];
        resolve(node_id, key);
        var node = _nodes[node_id];
        node.writes[key].value = value;
        node.writes[key].live = true;
    }
    // Resolving a node means either returning its value (if it is live or branch 0),
    // or resolving its parent and copying the value to itself and its sibling.
    function resolve(uint64 node_id, bytes32 key) returns (bytes32) {
        var node = _nodes[node_id];
        var entry = node.writes[key];
        if( entry.live ) {
            return entry.value;
        } else {
            if( node.parent == 0 || node_id == 0 ) {
                return 0;
            }
            var sibling = _nodes[node.sibling];
            var value = resolve(node.parent, key);
            node.writes[key].value = value;
            node.writes[key].live = true;
            sibling.writes[key].value = value;
            sibling.writes[key].value = value;
            return value;
        }
        throw;
    }
}
