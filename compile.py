import glob, subprocess, os

jars = glob.glob('antiquebid/target/antiquebid-1.0-SNAPSHOT/WEB-INF/lib/*.jar')
classes_dir = 'antiquebid/target/antiquebid-1.0-SNAPSHOT/WEB-INF/classes'
cp = os.pathsep.join(jars + [classes_dir])

src_files = [f for f in glob.glob('antiquebid/src/main/java/**/*.java', recursive=True) if 'JakartaRest' not in f and 'JakartaEE11' not in f]
cmd = ['javac', '-encoding', 'UTF-8', '-cp', cp, '-d', classes_dir] + src_files
res = subprocess.run(cmd, capture_output=True, text=True)
if res.returncode == 0:
    print('Compilation successful!')
else:
    print('Compilation failed:', res.returncode)
    if res.stdout: print(res.stdout)
    if res.stderr: print(res.stderr)
