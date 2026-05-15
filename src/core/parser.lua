--[[This File Was Protected By MinhNhat HUB v1.0]]
-- Parser - Converts source code to AST

local Parser = {}
Parser.__index = Parser

local function createNode(type, ...)
    local args = {...}
    local node = {type = type}
    for i, arg in ipairs(args) do
        node["arg" .. i] = arg
    end
    return node
end

function Parser.new(source)
    local self = setmetatable({}, Parser)
    self.source = source
    self.pos = 1
    self.line = 1
    self.tokens = {}
    self:tokenize()
    self.tokenPos = 1
    return self
end

function Parser:tokenize()
    local source = self.source
    local pos = 1
    
    while pos <= #source do
        local char = source:sub(pos, pos)
        
        if char == " " or char == "\t" or char == "\n" or char == "\r" then
            pos = pos + 1
        elseif char == "-" and source:sub(pos, pos + 1) == "--" then
            while pos <= #source and source:sub(pos, pos) ~= "\n" do
                pos = pos + 1
            end
        elseif char == "'" or char == '"' then
            local quote = char
            pos = pos + 1
            local str = ""
            while pos <= #source do
                if source:sub(pos, pos) == quote then
                    pos = pos + 1
                    break
                end
                str = str .. source:sub(pos, pos)
                pos = pos + 1
            end
            table.insert(self.tokens, {type = "STRING", value = str})
        elseif char >= "0" and char <= "9" then
            local num = ""
            while pos <= #source and (source:sub(pos, pos) >= "0" and source:sub(pos, pos) <= "9" or source:sub(pos, pos) == ".") do
                num = num .. source:sub(pos, pos)
                pos = pos + 1
            end
            table.insert(self.tokens, {type = "NUMBER", value = tonumber(num)})
        elseif (char >= "a" and char <= "z") or (char >= "A" and char <= "Z") or char == "_" then
            local ident = ""
            while pos <= #source and ((source:sub(pos, pos) >= "a" and source:sub(pos, pos) <= "z") or (source:sub(pos, pos) >= "A" and source:sub(pos, pos) <= "Z") or source:sub(pos, pos) == "_" or (source:sub(pos, pos) >= "0" and source:sub(pos, pos) <= "9")) do
                ident = ident .. source:sub(pos, pos)
                pos = pos + 1
            end
            table.insert(self.tokens, {type = "IDENT", value = ident})
        else
            table.insert(self.tokens, {type = "SYMBOL", value = char})
            pos = pos + 1
        end
    end
end

function Parser:peek(offset)
    offset = offset or 0
    local pos = self.tokenPos + offset
    if pos > #self.tokens then
        return nil
    end
    return self.tokens[pos]
end

function Parser:advance()
    local token = self:peek()
    self.tokenPos = self.tokenPos + 1
    return token
end

function Parser:parse()
    local statements = {}
    
    while self:peek() do
        local stmt = self:parseStatement()
        if stmt then
            table.insert(statements, stmt)
        end
    end
    
    return {
        type = "PROGRAM",
        body = statements
    }
end

function Parser:parseStatement()
    local token = self:peek()
    if not token then return nil end
    
    if token.type == "IDENT" then
        return self:parseAssignment()
    elseif token.type == "SYMBOL" and token.value == "=" then
        return self:parseAssignment()
    end
    
    self:advance()
    return {type = "UNKNOWN", token = token}
end

function Parser:parseAssignment()
    local name = self:advance()
    if self:peek() and self:peek().value == "=" then
        self:advance()
        local value = self:parseExpression()
        return {
            type = "ASSIGNMENT",
            name = name.value,
            value = value
        }
    end
    return nil
end

function Parser:parseExpression()
    local token = self:advance()
    if not token then return nil end
    
    if token.type == "NUMBER" then
        return {type = "NUMBER", value = token.value}
    elseif token.type == "STRING" then
        return {type = "STRING", value = token.value}
    elseif token.type == "IDENT" then
        return {type = "IDENT", value = token.value}
    end
    
    return {type = "UNKNOWN"}
end

return Parser
