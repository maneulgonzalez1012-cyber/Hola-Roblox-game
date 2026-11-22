-- Prometheus a98c50165f2a53f6d765a82eee60dfea53803445.
-- VM de registros, aplanado de flujo y expresiones, sin anti-tamper.
return {
    LuaVersion = "LuaU",
    VarNamePrefix = "",
    NameGenerator = "MangledShuffled",
    PrettyPrint = false,
    Seed = 12345,
    Steps = {
        { Name = "Vmify", Settings = {} },
        { Name = "EncryptStrings", Settings = { HoistVmStrings = true } },
        { Name = "ConstantArray", Settings = { Threshold = 1, StringsOnly = true, Shuffle = true, Rotate = true, LocalWrapperThreshold = 0 } },
        { Name = "WrapInFunction", Settings = {} },
        { Name = "Cff", Settings = { ExcludeVm = true } },
        { Name = "NumbersToExpressions", Settings = {} },
    },
}
