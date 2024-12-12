term.clear()
term.setCursorPos(1,1)

shell.run("delete","install")
shell.run("delete","eject")
shell.run("cp","disk/install","install")
shell.run("cp","disk/eject","eject")
print("First Time Install: Type 'install' to start, if not type 'eject' ")