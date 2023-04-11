import os, osproc, parseopt

proc copyStaticToPublic() =
  let staticDir = "static"
  let publicDir = "public"

  if not dirExists(publicDir):
    createDir(publicDir)

  for f in walkFiles(staticDir / "*"):
    let destFile = publicDir / extractFilename(f)
    echo "Copying ", f, " to ", destFile
    copyFile(f, destFile)

proc buildProject(buildType: string, runProgram: bool, upload: bool) =
  case buildType
  of "web":
    echo "Building for web..."
    let webBuildCmd = "nim c -d:release -d:emscripten src/main.nim"
    discard execCmd(webBuildCmd)
    if upload:
      let publicZip = "public.zip"
      echo "Zipping public folder..."
      let zipCmd = "zip -r " & publicZip & " public"
      discard execCmd(zipCmd)
      let uploadCmd = "butler push " & publicZip & " waotzi/kasaival:html5"
      echo "Uploading to itch.io..."
      discard execCmd(uploadCmd)
      os.removeFile(publicZip)
    if runProgram:
      let serverCmd = "ran public"
      discard execCmd(serverCmd)
  of "desktop":
    echo "Building for desktop..."
    let desktopBuildCmd = if runProgram:
      "nim c -r -d:release src/main.nim"
    else:
      "nim c -d:release src/main.nim"
    discard execCmd(desktopBuildCmd)
    let exeFile = "src/main"  
    if upload:
      let exeZip = "main.zip"
      echo "Zipping executable..."
      let zipCmd = "zip " & exeZip & " " & exeFile
      discard execCmd(zipCmd)
      let uploadCmd = "butler push " & exeZip & " waotzi/kasaival:linux"
      echo "Uploading to itch.io..."
      discard execCmd(uploadCmd)
      os.removeFile(exeZip)
    
    if runProgram:
      let runCmd = "./" & exeFile
      discard execCmd(runCmd)
  else:
    echo "Invalid build type"

proc parseArgs() =
  var buildType = "desktop"
  var runProgram = false
  var upload = false
  for kind, key, val in getopt():
    case kind
    of cmdLongOption, cmdShortOption:
      case key:
      of "b", "build":
        buildType = val
      of "r", "run":
        runProgram = true
      of "u", "upload":
        upload = true
    else: discard

  if buildType == "web":
    copyStaticToPublic()

  buildProject(buildType, runProgram, upload)

parseArgs()
