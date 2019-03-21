{ nixpkgs, ... }:

rec {
  toYaml = with builtins; with nixpkgs.lib; x: let
    type = typeOf x;
    concatLines = foldr (a: b: if b != null then "${a}\n${b}" else a) null;
    splitLines = splitString "\n";
  in
    if type == "set"
      then concatLines (
        mapAttrsToList (name: value: (
          let
            typeOfValue = typeOf value;
            listOrSet = typeOfValue == "list" || typeOfValue == "set";
            yamlValue = toYaml value;
            indentedYamlValue = concatLines(
              map (line: "  ${line}") (splitLines yamlValue)
            );
          in if typeOfValue == "list" || typeOfValue == "set" then
            "${name}:\n${indentedYamlValue}"
          else
            "${name}: ${yamlValue}"
        )) x
      )
    else if type == "list"
      then concatLines (
        map (i: "- ${toYaml i}") x
      )
    else if type == "string" || type == "path"
      then "\"${x}\""
    else if type == "bool"
      then if x then "true" else "false"
    else toString x;
}
