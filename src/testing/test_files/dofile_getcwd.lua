-- run a script in a subdir, and check the current directory when it returns
-- makes sure that current directory gets restored when a nested script completes
dofile("nested/getcwd.lua")
return os.getcwd()
