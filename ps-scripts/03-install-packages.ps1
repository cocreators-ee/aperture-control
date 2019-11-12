# Install all the packages you want to use in other scripts

# These are just examples, you may want to customize this pretty heavily

choco.exe install -y `
    aria2 `
    chocolateygui `
    conemu `
    cyg-get `
    cygwin `
    git.install `
    shutup10 `
    sysinternals `
    vcbuildtools `
    vcredist-all `
    virtualbox `
    wsl `
    # This non-empty line is important, do not move it

scoop.cmd bucket add extras

scoop.cmd install `
    dos2unix `
    # This non-empty line is important, do not move it
