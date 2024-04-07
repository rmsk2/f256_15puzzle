import sys

def generate_asm(in_file, out_file, col_label, reverse):
    with open(in_file, "r") as f:
        lines = f.readlines()

    col = col_label
    data = lines[5:]

    with open(out_file, "w") as f:
        for l in data:
            res = ".byte "
            d = list(filter(lambda x: (x == ' ') or (x == '.'), l.rstrip()))
            
            for c in d:
                if not reverse:
                    if c != '.':
                        res += f"{col}, "
                    else:
                        res += f"$00, "
                else:
                    if c != '.':
                        res += f"$00, "
                    else:
                        res += f"{col}, "
            
            res = res[:len(res)-2] + '\n'
            f.write(res)

files = [("1.xpm", "C1", False), ("2.xpm", "C2", False), ("3.xpm", "C3", False), ("4.xpm", "C4", False), ("5.xpm", "C5", False), 
         ("6.xpm", "C6", False), ("7.xpm", "C7", False), ("8.xpm", "C8", False), ("9.xpm", "C9", False), ("10.xpm", "CA", False), 
         ("11.xpm", "CB", False), ("12.xpm", "CC", False), ("13.xpm", "CD", False), ("14.xpm", "CE", False), ("15.xpm", "CF", False), 
         ("cursor.xpm", "D0", True), ("joystick.xpm", "D0", True)]

for i in files:
    asm_name = (i[0][0:-3]) + "asm"
    generate_asm(i[0], asm_name, i[1], i[2])
    