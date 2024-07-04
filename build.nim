import os, osproc, parseopt

const
  itchUsername = "waozi"

proc copyStaticToPublic() =
  let staticDir = "static"
  let publicDir = "public"

  if not dirExists(publicDir):
    createDir(publicDir)

  for f in walkFiles(staticDir / "*"):
    let destFile = publicDir / extractFilename(f)
    echo "Copying ", f, " to ", destFile
    copyFile(f, destFile)

proc buildForWeb(upload: bool, runProgram: bool): bool =
  echo "Building for web..."
  let webBuildCmd = "nim c -d:release -d:emscripten src/main.nim"
  let buildResult = execCmd(webBuildCmd)
  if buildResult != 0:
    echo "Web build failed"
    return false

  if upload:
    let publicZip = "public.zip"
    echo "Zipping public folder..."
    let zipCmd = "zip -r " & publicZip & " public"
    discard execCmd(zipCmd)
    let uploadCmd = "butler push " & publicZip & " " & itchUsername & "/kasaival:html5"
    echo "Uploading to itch.io..."
    discard execCmd(uploadCmd)
    os.removeFile(publicZip)
  if runProgram:
    let serverCmd = "ran public"
    let serverProc = startProcess(serverCmd)
    discard serverProc.waitForExit()
  return true

proc buildForDesktop(upload: bool, runProgram: bool): bool =
  echo "Building for desktop..."
  let desktopBuildCmd = "nim c -d:release src/main.nim"
  let buildResult = execCmd(desktopBuildCmd)
  if buildResult != 0:
    echo "Desktop build failed"
    return false

  let exeFile = "src/main"
  if upload:
    let exeZip = "main.zip"
    echo "Zipping executable..."
    let zipCmd = "zip " & exeZip & " " & exeFile
    discard execCmd(zipCmd)
    let uploadCmd = "butler push " & exeZip & " " & itchUsername & "/kasaival:linux"
    echo "Uploading to itch.io..."
    discard execCmd(uploadCmd)
    os.removeFile(exeZip)
  if runProgram:
    let runCmd = "./" & exeFile
    let runProc = startProcess(runCmd)
    discard runProc.waitForExit()
  return true

proc buildProject(buildType: string, runProgram: bool, upload: bool) =
  var buildSuccess = false
  case buildType
  of "web":
    buildSuccess = buildForWeb(upload, runProgram)
  of "desktop":
    buildSuccess = buildForDesktop(upload, runProgram)
  else:
    echo "Invalid build type"
  
  if not buildSuccess:
    echo "Build failed. Skipping run and upload steps."
    quit(1)

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

  if upload:
    copyStaticToPublic()
    buildProject("web", false, true)
    buildProject("desktop", false, true)
  else:
    if buildType == "web":
      copyStaticToPublic()
    buildProject(buildType, runProgram, false)

parseArgs()