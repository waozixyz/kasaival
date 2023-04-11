import os, osproc, strutils, parseopt

proc copyStaticToPublic() =
  let staticDir = "static"
  let publicDir = "public"

  if not dirExists(publicDir):
    createDir(publicDir)

  for f in walkFiles(staticDir / "*"):
    let destFile = publicDir / extractFilename(f)
    echo "Copying ", f, " to ", destFile
    copyFile(f, destFile)

proc buildProject(buildType: string) =
  case buildType
  of "web":
    echo "Building for web..."
    let webBuildCmd = "nim c -d:release -d:emscripten src/main.nim"
    discard execCmd(webBuildCmd)
    let publicZip = "public.zip"
    echo "Zipping public folder..."
    let zipCmd = "zip -r " & publicZip & " public"
    discard execCmd(zipCmd)
    let uploadCmd = "butler push " & publicZip & " waotzi/kasaival:html5"
    echo "Uploading to itch.io..."
    discard execCmd(uploadCmd)
    os.removeFile(publicZip)
  of "desktop":
    echo "Building for desktop..."
    let desktopBuildCmd = "nim c -r -d:release src/main.nim"
    discard execCmd(desktopBuildCmd)
  else:
    echo "Invalid build type"

proc parseArgs() =
  var buildType = "desktop"
  for kind, key, val in getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key:
      of "b", "build":
        buildType = val
    else: discard

  if buildType == "web":
    copyStaticToPublic()

  buildProject(buildType)

parseArgs()
