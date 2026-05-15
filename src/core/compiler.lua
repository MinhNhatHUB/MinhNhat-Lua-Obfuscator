--[[This File Was Protected By MinhNhat HUB v1.0]]
-- Compiler - Converts AST back to Lua code

local Compiler = {}
Compiler.__index = Compiler

function Compiler.new()
    local self = setmetatable({}, Compiler)
    self.indent = 0
    return self
end

function Compiler:getIndent()
    return string.rep("  ", self.indent)
end

function Compiler:compileExpression(node)
    if not node then return "nil" end
    
    if node.type == "StringExpression" then
        return '"' .. tostring(node.value):gsub('"', '\\"') .. '"'
    elseif node.type == "NumberExpression" then
        return tostring(node.value)
    elseif node.type == "BoolExpression" then
        return tostring(node.value)
    elseif node.type == "IdentifierExpression" then
        return node.name
    elseif node.type == "BinaryOp" then
        return self:compileExpression(node.left) .. " " .. node.op .. " " .. self:compileExpression(node.right)
    elseif node.type == "UnaryOp" then
        return node.op .. self:compileExpression(node.operand)
    elseif node.type == "FunctionCall" then
        local args = ""
        if node.args then
            for i, arg in ipairs(node.args) do
                if i > 1 then args = args .. ", " end
                args = args .. self:compileExpression(arg)
            end
        end
        return self:compileExpression(node.func) .. "(" .. args .. ")"
    elseif node.type == "TableConstructor" then
        return "{}"
    elseif node.type == "TableAccess" then
        return self:compileExpression(node.table) .. "[" .. self:compileExpression(node.key) .. "]"
    end
    
    return "nil"
end

function Compiler:compileStatement(node)
    if not node then return "" end
    
    if node.type == "Assignment" then
        return self:getIndent() .. node.name .. " = " .. self:compileExpression(node.value)
    elseif node.type == "LocalAssignment" then
        return self:getIndent() .. "local " .. node.name .. " = " .. self:compileExpression(node.value)
    elseif node.type == "FunctionCall" then
        return self:getIndent() .. self:compileExpression(node)
    elseif node.type == "IfStatement" then
        local code = self:getIndent() .. "if " .. self:compileExpression(node.condition) .. " then\n"
        self.indent = self.indent + 1
        if node.thenBranch then
            for _, stmt in ipairs(node.thenBranch.statements or {node.thenBranch}) do
                code = code .. self:compileStatement(stmt) .. "\n"
            end
        end
        self.indent = self.indent - 1
        if node.elseBranch then
            code = code .. self:getIndent() .. "else\n"
            self.indent = self.indent + 1
            for _, stmt in ipairs(node.elseBranch.statements or {node.elseBranch}) do
                code = code .. self:compileStatement(stmt) .. "\n"
            end
            self.indent = self.indent - 1
        end
        code = code .. self:getIndent() .. "end"
        return code
    elseif node.type == "ReturnStatement" then
        return self:getIndent() .. "return " .. self:compileExpression(node.value)
    elseif node.type == "FunctionDecl" then
        local params = ""
        if node.params then
            for i, param in ipairs(node.params) do
                if i > 1 then params = params .. ", " end
                params = params .. param
            end
        end
        local code = self:getIndent() .. "local function " .. node.name .. "(" .. params .. ")\n"
        self.indent = self.indent + 1
        if node.body then
            for _, stmt in ipairs(node.body.statements or {node.body}) do
                code = code .. self:compileStatement(stmt) .. "\n"
            end
        end
        self.indent = self.indent - 1
        code = code .. self:getIndent() .. "end"
        return code
    elseif node.type == "RawCode" then
        return node.code or ""
    end
    
    return ""
end

function Compiler:compile(ast)
    if not ast then return "" end
    
    if ast.type == "Program" then
        local code = ""
        for _, stmt in ipairs(ast.body) do
            code = code .. self:compileStatement(stmt) .. "\n"
        end
        return code
    end
    
    return self:compileStatement(ast)
end

return Compiler
