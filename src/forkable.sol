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

    function fork(uint32 branch) returns (uint32 child_branch) {
        // get the tip node
        uint64 parent_id = _branches[branch];

        // Left is old branch tip, right is new branch tip
        // Forking branch 0 creates a "quasi-root" with no sibling
        child_branch = _next_name++;
        if( branch != 0 ) {
            uint64 left_id = _next_node++;
        }
        uint64 right_id = _next_node++;

        Node memory left = Node({parent: parent_id, sibling: right_id});
        Node memory right = Node({parent: parent_id, sibling: left_id});
        _nodes[left_id] = left;
        _branches[branch] = left_id;
        _nodes[right_id] = right;
        _branches[child_branch] = right_id;
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
    // or resolving its parent and copying the value to itself and its sibling (if one exists)
    function resolve(uint64 node_id, bytes32 key) returns (bytes32) {
        var node = _nodes[node_id];
        var entry = node.writes[key];
        if( entry.live ) {
            return entry.value;
        } else {
            if( node.parent == 0 || node_id == 0 ) {
                node.writes[key].live = true;
                return 0;
            }
            var value = resolve(node.parent, key);
            if( node.sibling != 0 ) {
                var sibling = _nodes[node.sibling];
                sibling.writes[key].value = value;
                sibling.writes[key].live = true;
            }
            var parent = _nodes[node.parent];
            node.writes[key].value = value;
            node.writes[key].live = true;
            delete parent.writes[key];
            return value;
        }
        throw;
    }

    function getBranchInfo(uint32 branch) constant returns (uint64 node_id) {
        return _branches[branch];
    }
    function getNodeInfo(uint64 node_id) constant returns (uint64 parent, uint64 sibling) {
        var node = _nodes[node_id];
        return (node.parent, node.sibling);
    }
    function getNodeWrite(uint64 node_id, bytes32 key) constant returns (bytes32, bool) {
        var entry = _nodes[node_id].writes[key];
        return (entry.value, entry.live);
    }
}
