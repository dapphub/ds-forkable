import 'ds-auth/auth.sol';
import 'ds-base/base.sol';

contract ForkableDatastoreService is DSBase {
    // temporary type tags:
    // uint64: internal ID
    // uint32: "name" - virtual ID
    function ForkableDatastoreService() {
        _next_name++;
        _next_node++;
    }
    struct Branch {
        // storage
        // number of used slots
    }
    struct Node {
        uint64 parent;
        uint64 sibling;
    }
    struct Entry {
        bytes32 value;
        bool live;
    }

    mapping(uint64=>Node) _nodes;
    mapping(uint32=>uint64) _aliases;
    mapping(uint32=>mapping(bytes32=>Entry)) _storages;

    uint32 _next_name;
    uint64 _next_node;

    function fork(uint32 branch_name) returns (uint32 child_name) {
        child_name = _next_name++;
        uint64 old_parent_node_id = _aliases[branch_name];
        uint64 new_parent_node_id = _next_node++;
        uint64 new_child_node_id = _next_node++;
        Node memory parent_node = Node({parent: old_parent_node_id, left: new_parent_node_id, right: new_child_node_id});
        Node memory child_node = Node({parent: old_parent_node_id, left: new_parent_node_id, right: new_child_node_id});
    }

    function get(uint32 branch_name, bytes32 key) returns (bytes32) {
        return resolve(_aliases[branch_name], key);
    }
    function set(uint32 branch_name, bytes32 key, bytes32 value) {
        var node_id = _aliases[branch_name];
        resolve(node_id, key);
        _storages[branch_name][key].value = value;
        _storages[branch_name][key].live = true;
    }
    function resolve(uint64 node_id, bytes32 key) returns (bytes32) {
        var node = _nodes[node_id];
        var entry = _storages[node.name][key];
        if( entry.live ) {
            return entry.value;
        } else {
            if( node.parent == 0 ) {
                return 0;
            }
            Node memory parent_node = _nodes[node.parent];
            Node memory sibling_node;
            if( node_id == parent_node.left ) {
                sibling_node = _nodes[parent_node.right];
            } else {
                sibling_node = _nodes[parent_node.left];
            }
            var value = resolve(node.parent, key);
            _storages[node.name][key].value = value;
            _storages[node.name][key].live = true;
            _storages[sibling_node.name][key].value = value;
            _storages[sibling_node.name][key].live = true;
            return value;
        }
        throw;
    }
}
