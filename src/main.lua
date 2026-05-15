--[[This File Was Protected By MinhNhat HUB v1.0]]
-- MinhNhat Lua Obfuscator v1.0
-- Main Entry Point

local Parser = require("src.core.parser")
local Compiler = require("src.core.compiler")
local Lexer = require("src.core.lexer")

local RenameVariables = require("src.obfuscators.renameVariables")
local StringEncryption = require("src.obfuscators.stringEncryption")
local BytecodeEncoder = require("src.obfuscators.bytecodeEncoder")
local NumberObfuscation = require("src.obfuscators.numberObfuscation")
local JunkCode = require("src.obfuscators.junkCode")
local ControlFlowFlattening = require("src.obfuscators.controlFlowFlattening")
local AntiDebug = require("src.obfuscators.antiDebug")
local AntiDecompiler = require("src.obfuscators.antiDecompiler")
local StringSplitting = require("src.obfuscators.stringSplitting")
local OpaquePredicates = require("src.obfuscators.opaquePredicates")
local VMGenerator = require("src.obfuscators.vmGenerator")
local ProxifyLocals = require("src.obfuscators.proxifyLocals")

local Presets = require("src.presets.presets")

local Obfuscator = {}

local function getPreset(presetName)
    if type(presetName) == "string" then
        return Presets[presetName] or Presets.ultra
    end
    return presetName
end

local function addWatermark(code)
    return "--[[This File Was Protected By MinhNhat HUB v1.0]]\\n" .. code
end

local function applyObfuscators(ast, options, pipeline)
    if options.renameVariables then
        ast = RenameVariables.apply(ast, pipeline)
    end
    
    if options.stringEncryption then
        ast = StringEncryption.apply(ast, pipeline)
    end
    
    if options.numberObfuscation then
        ast = NumberObfuscation.apply(ast, pipeline)
    end
    
    if options.junkCode then
        ast = JunkCode.apply(ast, pipeline)
    end
    
    if options.opaquePredicates then
        ast = OpaquePredicates.apply(ast, pipeline)
    end
    
    if options.antiDebug then
        ast = AntiDebug.apply(ast, pipeline)
    end
    
    if options.antiDecompiler then
        ast = AntiDecompiler.apply(ast, pipeline)
    end
    
    if options.stringSplitting then
        ast = StringSplitting.apply(ast, pipeline)
    end
    
    if options.vmGenerator then
        ast = VMGenerator.apply(ast, pipeline)
    end
    
    if options.proxifyLocals then
        ast = ProxifyLocals.apply(ast, pipeline)
    end
    
    if options.controlFlowFlattening then
        ast = ControlFlowFlattening.apply(ast, pipeline)
    end
    
    if options.bytecodeEncoding then
        ast = BytecodeEncoder.apply(ast, pipeline)
    end
    
    return ast
end

function Obfuscator.obfuscate(sourceCode, presetOrOptions)
    local options = getPreset(presetOrOptions)
    
    -- Verify Lua syntax
    local lexer = Lexer.new(sourceCode)
    if not lexer:isValidLua() then
        error("Invalid Lua code provided")
    end
    
    -- Parse source code
    local parser = Parser.new(sourceCode)
    local ast = parser:parse()
    
    -- Setup pipeline
    local pipeline = {
        options = options,
        namegenerator = require("src.util.Il_generator"),
        randomStrings = require("src.util.randomStrings"),
        randomLiterals = require("src.util.randomLiterals"),
        isLuauRuntime = options.luauRuntime,
        vmDepth = options.loaderVMDepth or 1
    }
    
    -- Apply obfuscators
    local obfuscatedAst = applyObfuscators(ast, options, pipeline)
    
    -- Compile back to Lua
    local compiler = Compiler.new()
    local obfuscatedCode = compiler:compile(obfuscatedAst)
    
    -- Add watermark
    obfuscatedCode = addWatermark(obfuscatedCode)
    
    -- Minify if enabled
    if options.minifier then
        local Minifier = require("src.util.minifier")
        obfuscatedCode = Minifier.minify(obfuscatedCode)
    end
    
    return obfuscatedCode
end

function Obfuscator.obfuscateFile(inputPath, outputPath, presetOrOptions)
    local file = io.open(inputPath, "r")
    if not file then
        error("Cannot open file: " .. inputPath)
    end
    
    local sourceCode = file:read("*a")
    file:close()
    
    local obfuscatedCode = Obfuscator.obfuscate(sourceCode, presetOrOptions)
    
    local outFile = io.open(outputPath, "w")
    if not outFile then
        error("Cannot write to file: " .. outputPath)
    end
    
    outFile:write(obfuscatedCode)
    outFile:close()
    
    print("Obfuscated file saved to: " .. outputPath)
end

return Obfuscator
