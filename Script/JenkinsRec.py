# -*- coding: cp932 -*-
import os
import time
import sys
import subprocess

def execCmd(cmd):
        print "Command Send : %s" % cmd
        args = cmd.split(" ")
        subproc_args = { 'stdin'        : subprocess.PIPE,
                         'stdout'       : subprocess.PIPE,
                         'stderr'       : subprocess.STDOUT,
        }

        try:
            p = subprocess.Popen(args, **subproc_args)
        except OSError:
            print "Failed to execute command: %s" % args[0]
            sys.exit(1)

        (stdouterr, stdin) = (p.stdout, p.stdin)
        L = []
        result = None
        if stdouterr is None:
            pass
        else:
            while True:
                line = stdouterr.readline()
                if not line:
                    break
                L.append(line.rstrip())
            result = "".join(L)
        code = p.wait()
        time.sleep(3)
        print "Command Resturn Code: %d" % code
        return result

list = os.listdir(os.path.normpath(os.path.join("F:","retry")))
for f in list:
    filename = f.rsplit(".")[0]
    category = "アニメ/特撮"
    bat = os.path.normpath(os.path.join("C:\SCRename","bat","AfterRec.bat"))
    cmd = '%s "%s" "%s" "%s"' % (bat, f, filename, category)
    execCmd(cmd)
