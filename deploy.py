import subprocess, os
# spam = '''
# godot --export "Windows Desktop" builds/win/SwingWing

# '''
# butler push directory user/game:channel
def read_config():
    out = []
    with open('export_presets.cfg') as f:
        text = f.read()
        start = 0
        while True:
            idx = text.find("\nname=", start)
            if idx == -1:
                return out
            start = idx + len("\nname=")
            end = text.find("\n", start)
            name = text[start+1:end-1]
            idx = text.find("\nexport_path=", start)
            start = idx + len("\nexport_path=")
            end = text.find("\n", start)
            export_path = text[start+1:end-1]
            out.append((name, export_path,))

def deploy():
    targets = read_config()
    lookup = {
        "Windows Desktop": "win",
        "Linux/X11": "linux",
        "Mac OSX": "osx",
        "HTML5": "html5"
    }
    for name, path in targets:
        comm = ["godot", "--export", name, path]
        #subprocess.run(comm)
        path, _ = os.path.split(path)
        channel = lookup[name]
        comm = f"butler push {path} etmm/swing-wing-redux:{channel}".split()
        subprocess.run(comm)

if __name__ == "__main__":
    deploy()