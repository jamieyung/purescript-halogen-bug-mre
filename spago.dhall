{ name = "purescript-halogen-bug-mre"
, dependencies =
  [ "aff"
  , "effect"
  , "either"
  , "halogen"
  , "maybe"
  , "prelude"
  , "routing"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
