-- Prometheus a98c50165f2a53f6d765a82eee60dfea53803445.
-- Aplanado de flujo y expresiones numéricas, sin comprobaciones anti-tamper.
return {
    LuaVersion = "LuaU",
    VarNamePrefix = "",
    NameGenerator = "MangledShuffled",
    PrettyPrint = false,
    Seed = 12345,
    Steps = {
        { Name = "Cff", Settings = {} },
        { Name = "EncryptStrings", Settings = {} },
        { Name = "ConstantArray", Settings = { Threshold = 1, StringsOnly = true, Shuffle = true, Rotate = true } },
        { Name = "NumbersToExpressions", Settings = {} },
        { Name = "WrapInFunction", Settings = {} },
    },
}
