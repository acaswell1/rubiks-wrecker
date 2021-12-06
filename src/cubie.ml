module CSet = Set.Make(Color)

type cubie = Corner of CSet.t | Edge of CSet.t | Center of CSet.t
