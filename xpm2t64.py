import sys

def generate_asm(in_file, out_file, col_label):
    with open(in_file, "r") as f:
        lines = f.readlines()

    col = col_label
    data = lines[5:]

    with open(out_file, "w") as f:
        for l in data:
            res = ".byte "
            d = list(filter(lambda x: (x == ' ') or (x == '.'), l.rstrip()))
            
            for c in d:
                if c != '.':
                    res += f"{col}, "
                else:
                    res += f"$00, "
            
            res = res[:len(res)-2] + '\n'
            f.write(res)

files = [("1.xpm", "C1"), ("2.xpm", "C2"), ("3.xpm", "C3"), ("4.xpm", "C4"), ("5.xpm", "C5"), 
         ("6.xpm", "C6"), ("7.xpm", "C7"), ("8.xpm", "C8"), ("9.xpm", "C9"), ("10.xpm", "CA"), 
         ("11.xpm", "CB"), ("12.xpm", "CC"), ("13.xpm", "CD"), ("14.xpm", "CE"), ("15.xpm", "CF")]

for i in files:
    asm_name = (i[0][0:-3]) + "asm"
    generate_asm(i[0], asm_name, i[1])
    