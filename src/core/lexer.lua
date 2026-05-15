--[[This File Was Protected By MinhNhat HUB v1.0]]
-- Lexical Analyzer

local Lexer = {}
Lexer.__index = Lexer

local KEYWORDS = {
    "and", "break", "do", "else", "elseif", "end", "false", "for",
    "function", "if", "in", "local", "nil", "not", "or", "repeat",
    "return", "then", "true", "until", "while", "continue"
}

local SYMBOLS = {
    "+", "-", "*", "/", "%", "^", "#", "=", "~", "<", ">",
    "(", ")", "{", "}", "[", "]", ";", ":", ",", ".", "..", "...",
    "==", "~=", "<=", ">=", "::", "->", "|>", "&"
}

local function isKeyword(word)
    for _, kw in ipairs(KEYWORDS) do
        if word == kw then return true end
    end
    return false
end

local function isWhitespace(char)
    return char == " " or char == "\t" or char == "\n" or char == "\r"
end

local function isDigit(char)
    return char >= "0" and char <= "9"
end

local function isAlpha(char)
    return (char >= "a" and char <= "z") or (char >= "A" and char <= "Z") or char == "_"
end

local function isAlphaNumeric(char)
    return isAlpha(char) or isDigit(char)
end

function Lexer.new(source)
    local self = setmetatable({}, Lexer)
    self.source = source
    self.pos = 1
    self.line = 1
    self.column = 1
    self.tokens = {}
    return self
end

function Lexer:peek(offset)
    offset = offset or 0
    local pos = self.pos + offset
    if pos > #self.source then
        return nil
    end
    return self.source:sub(pos, pos)
end

function Lexer:advance()
    local char = self:peek()
    if char then
        self.pos = self.pos + 1
        if char == "\n" then
            self.line = self.line + 1
            self.column = 1
        else
            self.column = self.column + 1
        end
    end
    return char
end

function Lexer:skipWhitespace()
    while self:peek() and isWhitespace(self:peek()) do
        self:advance()
    end
end

function Lexer:skipComment()
    if self:peek() == "-" and self:peek(1) == "-" then
        self:advance()
        self:advance()
        
        if self:peek() == "[" then
            local bracketCount = 0
            self:advance()
            while self:peek() == "[" do
                bracketCount = bracketCount + 1
                self:advance()
            end
            
            while self:peek() do
                if self:peek() == "]" then
                    local count = 0
                    while self:peek() == "]" do
                        count = count + 1
                        self:advance()
                    end
                    if count == bracketCount then
                        break
                    end
                else
                    self:advance()
                end
            end
        else
            while self:peek() and self:peek() ~= "\n" do
                self:advance()
            end
        end
        return true
    end
    return false
end

function Lexer:readString(quote)
    local str = ""
    self:advance() -- skip opening quote
    
    while self:peek() and self:peek() ~= quote do
        if self:peek() == "\\" then
            self:advance()
            local next = self:peek()
            if next == "n" then
                str = str .. "\n"
            elseif next == "t" then
                str = str .. "\t"
            elseif next == "r" then
                str = str .. "\r"
            elseif next == "\\" then
                str = str .. "\\"
            elseif next == quote then
                str = str .. quote
            else
                str = str .. next
            end
            self:advance()
        else
            str = str .. self:advance()
        end
    end
    
    if self:peek() == quote then
        self:advance() -- skip closing quote
    end
    
    return str
end

function Lexer:readNumber()
    local num = ""
    
    while self:peek() and (isDigit(self:peek()) or self:peek() == ".") do
        num = num .. self:advance()
    end
    
    if self:peek() and (self:peek() == "e" or self:peek() == "E") then
        num = num .. self:advance()
        if self:peek() and (self:peek() == "+" or self:peek() == "-") then
            num = num .. self:advance()
        end
        while self:peek() and isDigit(self:peek()) do
            num = num .. self:advance()
        end
    end
    
    return tonumber(num)
end

function Lexer:readIdentifier()
    local ident = ""
    
    while self:peek() and isAlphaNumeric(self:peek()) do
        ident = ident .. self:advance()
    end
    
    return ident
end

function Lexer:tokenize()
    while self.pos <= #self.source do
        self:skipWhitespace()
        
        if self:skipComment() then
            -- Comment skipped
        elseif self:peek() == "-" and self:peek(1) == "-" then
            -- Already handled by skipComment
        elseif self:peek() == "'" or self:peek() == '"' then
            local quote = self:peek()
            local str = self:readString(quote)
            table.insert(self.tokens, {type = "STRING", value = str})
        elseif isDigit(self:peek()) then
            local num = self:readNumber()
            table.insert(self.tokens, {type = "NUMBER", value = num})
        elseif isAlpha(self:peek()) then
            local ident = self:readIdentifier()
            if isKeyword(ident) then
                table.insert(self.tokens, {type = "KEYWORD", value = ident})
            else
                table.insert(self.tokens, {type = "IDENTIFIER", value = ident})
            end
        else
            local char = self:advance()
            table.insert(self.tokens, {type = "SYMBOL", value = char})
        end
    end
    
    return self.tokens
end

function Lexer:isValidLua()
    local tokens = self:tokenize()
    if #tokens == 0 then
        return false
    end
    return true
end

return Lexer
