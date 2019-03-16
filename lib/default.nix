rec {
  listDir = dir: with builtins; attrValues (mapAttrs (name: type: { inherit name type; }) (readDir dir));
  isDirContainingDefaultNixPath = path: builtins.pathExists (path + "/default.nix");
  isNixFilePath = path: builtins.match ".+\.nix" (baseNameOf path) != null;
  getPathAndTypeUnderDir = dir: map ({ name, type }: { path = dir + "/${name}"; inherit type; }) (listDir dir);
  getImportablePathsUnderDir = dir: map ({ path, ... }: path) (builtins.filter ({ path, type }: if type == "directory" then isDirContainingDefaultNixPath path else isNixFilePath path) (getPathAndTypeUnderDir dir));
  getImportPathsUnderDir = dir: builtins.filter (path: (baseNameOf path) != "default.nix") (getImportablePathsUnderDir dir);
}
