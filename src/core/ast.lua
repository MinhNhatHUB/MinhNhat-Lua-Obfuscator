--[[This File Was Protected By MinhNhat HUB v1.0]]
-- Abstract Syntax Tree Node Definitions

local AST = {}

function AST.StringExpression(value)
    return {type = "StringExpression", value = value}
end

function AST.NumberExpression(value)
    return {type = "NumberExpression", value = value}
end

function AST.BoolExpression(value)
    return {type = "BoolExpression", value = value}
end

function AST.IdentifierExpression(name)
    return {type = "IdentifierExpression", name = name}
end

function AST.BinaryOp(left, op, right)
    return {type = "BinaryOp", left = left, op = op, right = right}
end

function AST.UnaryOp(op, operand)
    return {type = "UnaryOp", op = op, operand = operand}
end

function AST.Assignment(target, value)
    return {type = "Assignment", target = target, value = value}
end

function AST.LocalAssignment(name, value)
    return {type = "LocalAssignment", name = name, value = value}
end

function AST.FunctionDecl(name, params, body)
    return {type = "FunctionDecl", name = name, params = params, body = body}
end

function AST.FunctionCall(func, args)
    return {type = "FunctionCall", func = func, args = args}
end

function AST.IfStatement(condition, thenBranch, elseBranch)
    return {type = "IfStatement", condition = condition, thenBranch = thenBranch, elseBranch = elseBranch}
end

function AST.WhileLoop(condition, body)
    return {type = "WhileLoop", condition = condition, body = body}
end

function AST.ForLoop(var, start, finish, step, body)
    return {type = "ForLoop", var = var, start = start, finish = finish, step = step, body = body}
end

function AST.TableConstructor(fields)
    return {type = "TableConstructor", fields = fields}
end

function AST.TableAccess(table, key)
    return {type = "TableAccess", table = table, key = key}
end

function AST.ReturnStatement(value)
    return {type = "ReturnStatement", value = value}
end

function AST.Block(statements)
    return {type = "Block", statements = statements}
end

function AST.Program(body)
    return {type = "Program", body = body}
end

return AST
