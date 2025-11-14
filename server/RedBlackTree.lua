---@class RedBlackTree
---@field x integer
---@field y integer
---@field z integer
---@field value Serializable
---@field isRed boolean
---@field left RedBlackTree
---@field right RedBlackTree
---@field parent RedBlackTree

-- Note: I'm not using a class because RedBlackTree is a low-level data structure. Methods will be defined in MetaChunk instead.
-- Note: there is no need for deleting. Chunks that are empty can be reused

---@return RedBlackTree
local function createNode(x, y, z, value, left, right, parent)
    return {
        x = x,
        y = y,
        z = z,
        value = value,
        isRed = false,
        left = left,
        right = right,
        parent = parent
    }
end

--- Compares 3 integers
function compare(node, x, y, z)
    if node.x > x then
        return 1
    elseif node.x < x then
        return -1
    elseif node.y > y then
        return 1
    elseif node.y < y then
        return -1
    elseif node.z > z then
        return 1
    elseif node.z < z then
        return -1
    else
        return 0
    end
end

---Performs a binary search for the given item.
---@param node RedBlackTree
---@param x integer
---@param y integer
---@param z integer
---@return any | nil
local function search(node, x, y, z)
    if node == nil then
        return
    end

    local comparison = compare(node, x, y, z)
    if comparison == 1 then
        return search(node.left, x, y, z)
    elseif comparison == -1 then
        return search(node.right, x, y, z)
    else
        return node.value
    end
end

---Left rotates a node in a RedBlackTree
---@param tree { root: RedBlackTree }
---@param node RedBlackTree
local function rotateLeft(tree, node)
    local right = node.right
    node.right = right.left

    if right.left ~= nil then
        right.left.parent = node
    end

    right.parent = node.parent

    if node.parent == nil then
        tree.root = right
    elseif node == node.parent.left then
        node.parent.left = right
    else
        node.parent.right = right
    end

    right.left = node
    node.parent = right
end

---Right rotates a node in a RedBlackTree
---@param tree { root: RedBlackTree }
---@param node RedBlackTree
local function rotateRight(tree, node)
    local left = node.left
    node.left = left.right

    if left.right ~= nil then
        left.right.parent = node
    end

    left.parent = node.parent

    if node.parent == nil then
        tree.root = left
    elseif node == node.parent.right then
        node.parent.right = left
    else
        node.parent.left = left
    end

    left.right = node
    node.parent = left
end

---Performs tree rebalancing whenever a node is inserted, ensuring the tree does not degenerate into a linked list
---@param tree { root: RedBlackTree }
---@param node RedBlackTree
local function fixInsert(tree, node)
    while node ~= tree.root and node.parent.isRed do
        if node.parent == node.parent.parent.left then
            local uncle = node.parent.parent.right
            if uncle.isRed then
                node.parent.isRed = false
                uncle.isRed = false
                node.parent.parent.isRed = true
                node = node.parent.parent
            else
                if node == node.parent.right then
                    node = node.parent
                    rotateLeft(tree, node)
                end
                node.parent.isRed = false
                node.parent.parent.isRed = true
                rotateRight(tree, node.parent.parent)
            end
        else
            local uncle = node.parent.parent.left
            if uncle.isRed then
                node.parent.isRed = false
                uncle.isRed = false
                node.parent.parent.isRed = true
                node = node.parent.parent
            else
                if node == node.parent.left then
                    node = node.parent
                    rotateRight(tree, node)
                end
                node.parent.isRed = false
                node.parent.parent.isRed = true
                rotateLeft(tree, node.parent.parent)
            end
        end
    end
    tree.root.isRed = false
end

local function insert(tree, x, y, z, value)
    local node = createNode(x, y, z, value)

    ---@type RedBlackTree
    local parent = nil
    local current = tree.root

    -- Find parent
    while current ~= nil do
        parent = current
        local comparison = compare(tree, x, y, z)
        if comparison == 1 then
            current = current.right
        else
            current = current.left
        end
    end
    node.parent = parent

    -- Actually insert the node
    if parent == nil then
        tree.root = node
    elseif compare(node, parent.x, parent.y, parent.z) == -1 then
        parent.left = node
    else
        parent.right = node
    end

    if node.parent == nil then
        node.isRed = false
        return
    end

    if node.parent.parent == nil then
        return
    end

    fixInsert(tree, node)
end

---@param tree RedBlackTree
---@param writer BinaryWriter
local function serialize(tree, writer)
    writer:i32(tree.x)
        :i32(tree.y)
        :i32(tree.z)
        :boolean(tree.isRed)

    tree.value:serialize(writer)

    local left = tree.left
    if left then
        writer:u8(1)
        serialize(left, writer)
    else
        writer:u8(0)
    end

    local right = tree.right
    if right then
        writer:u8(1)
        serialize(right, writer)
    else
        writer:u8(0)
    end
end

---@param reader BinaryReader
---@param valueClass Serializable
local function deserialize(reader, valueClass)
    local x = reader:i32()
    local y = reader:i32()
    local z = reader:i32()
    local isRed = reader:boolean()

    -- Extra parameters needed for chunk
    ---@diagnostic disable-next-line: redundant-parameter
    local value = valueClass:deserialize(reader, x, y, z)

    local left, right = nil, nil
    if reader:u8() ~= 0 then
        left = deserialize(reader, valueClass)
    end
    if reader:u8() ~= 0 then
        right = deserialize(reader, valueClass)
    end

    local node = createNode(x, y, z, value, left, right)
    node.isRed = isRed
    if left then left.parent = node end
    if right then right.parent = node end

    return node
end

return {
    createNode = createNode,
    search = search,
    insert = insert,
}