{ ... }:

{
  imports = (with import ../../../lib; getImportPathsUnderDir ./.);
}
