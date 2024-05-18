import re
import sys

# Global variable to store output lines with indices
instruction_array = ["0000000000000000"] * 4096
index = 0

# Function to convert assembly instruction to binary
def assemble_instruction(instruction):
    print("instruction", instruction)
    global index
    full_instruction = ["opcode", "src1", "src2", "dest", "imm"]
    parts = re.split(r'\s,\s|,\s|\s', instruction)  # Split using space, comma space, or space comma space
    # print(parts)
    instruction = parts[0]
    immediateIs = "second"
    # print (instruction)
    if instruction.startswith("//") or instruction.startswith("#") or instruction == "":
        return
    elif instruction.upper() == ".ORG":
        index = int(parts[1], 16)
        return
    elif instruction.upper() == "NOP":
        full_instruction[0] = "000000"
        full_instruction[1] = "000" #xxx
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "NOT":
        full_instruction[0] = "000001"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "NEG":
        full_instruction[0] = "000010"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "INC":
        full_instruction[0] = "000011"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "DEC":
        full_instruction[0] = "000100"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "OUT":
        full_instruction[0] = "000101"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "IN":
        full_instruction[0] = "000110"
        full_instruction[1] = "000" #xxx
        full_instruction[2] = "000" #xxx
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "MOV":
        full_instruction[0] = "010000"
        full_instruction[1] = "000" #xxx
        full_instruction[2] = format(int(parts[2][1]), '03b')
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "SWAP":
        full_instruction[0] = "010001"
        full_instruction[1] = format(int(parts[2][1]), '03b')
        full_instruction[2] = format(int(parts[1][1]), '03b')
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "ADD":
        full_instruction[0] = "010010"
        full_instruction[1] = format(int(parts[2][1]), '03b')
        full_instruction[2] = format(int(parts[3][1]), '03b')
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "SUB":
        full_instruction[0] = "010011"
        full_instruction[1] = format(int(parts[2][1]), '03b')
        full_instruction[2] = format(int(parts[3][1]), '03b')
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "AND":
        full_instruction[0] = "010100"
        full_instruction[1] = format(int(parts[2][1]), '03b')
        full_instruction[2] = format(int(parts[3][1]), '03b')
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "OR":
        full_instruction[0] = "010101"
        full_instruction[1] = format(int(parts[2][1]), '03b')
        full_instruction[2] = format(int(parts[3][1]), '03b')
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "XOR":
        full_instruction[0] = "010110"
        full_instruction[1] = format(int(parts[2][1]), '03b')
        full_instruction[2] = format(int(parts[3][1]), '03b')
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "CMP":
        full_instruction[0] = "010111"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = format(int(parts[2][1]), '03b')
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "ADDI":
        full_instruction[0] = "011000"
        full_instruction[1] = format(int(parts[2][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "1"
        immediateIs = "third"
    elif instruction.upper() == "SUBI":
        full_instruction[0] = "011001"
        full_instruction[1] = format(int(parts[2][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "1"
        immediateIs = "third"
    elif instruction.upper() == "PUSH":
        full_instruction[0] = "100000"
        full_instruction[1] = "000" #xxx
        full_instruction[2] = format(int(parts[1][1]), '03b')
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "POP":
        full_instruction[0] = "100001"
        full_instruction[1] = "000" #xxx
        full_instruction[2] = "000" #xxx
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "0"
    elif instruction.upper() == "PROTECT":
        full_instruction[0] = "100010"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "FREE":
        full_instruction[0] = "100011"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "LDM":
        full_instruction[0] = "100100"
        full_instruction[1] = "000" #xxx
        full_instruction[2] = "000" #xxx
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "1"
    elif instruction.upper() == "LDD":
        full_instruction[0] = "100101"
        full_instruction[1] = format(int(parts[3][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = format(int(parts[1][1]), '03b')
        full_instruction[4] = "1"
    elif instruction.upper() == "STD":
        full_instruction[0] = "100110"
        full_instruction[1] = format(int(parts[3][1]), '03b')
        full_instruction[2] = format(int(parts[1][1]), '03b')
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "1"
    elif instruction.upper() == "JZ":
        full_instruction[0] = "110000"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "JMP":
        full_instruction[0] = "110001"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "CALL":
        full_instruction[0] = "110010"
        full_instruction[1] = format(int(parts[1][1]), '03b')
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "RET":
        full_instruction[0] = "110011"
        full_instruction[1] = "000" #xxx
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "RTI":
        full_instruction[0] = "110100"
        full_instruction[1] = "000" #xxx
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "RESET":
        full_instruction[0] = "110101"
        full_instruction[1] = "000" #xxx
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    elif instruction.upper() == "INTERRUPT":
        full_instruction[0] = "110110"
        full_instruction[1] = "000" #xxx
        full_instruction[2] = "000" #xxx
        full_instruction[3] = "000" #xxx
        full_instruction[4] = "0"
    else:
        full_instruction = (format(int(parts[0], 16), '016b'))

    full_instruction = "".join(full_instruction)
    instruction_array[index] = (full_instruction)
    index += 1

    # handle immediate value
    if full_instruction[-1] == "1":
        if immediateIs == "second":
            instruction_array[index] = (format(int(parts[2], 16), '016b'))
            index += 1

        elif immediateIs == "third":
            instruction_array[index] = (format(int(parts[3], 16), '016b'))
            index += 1
    

    print(full_instruction + "\n")
    return full_instruction

# Function to read assembly file, convert instructions, and write to output file
def assemble_file(args):
    input_file : str = args[1]
    output_path : str  = args[2]
    # output_file = output_path + input_file.split('.')[0] + '.mem'
    output_file = output_path + "/data_memory.mem"
    print("Input file: " + input_file)
    print("Output directory: " + output_path)
    with open(input_file, 'r') as f:
        assembly_code = f.readlines()
    
    for i, line in enumerate(assembly_code):
        # print (line)
        # Replace '(' and ')' with spaces
        line = line.replace('(', ' ').replace(')', ' ').replace(',', ' ')
        # Convert multiple spaces to single space
        line = ' '.join(line.split())
        assemble_instruction(line)


    with open(output_file, 'w') as f:
        filePrefix = "// memory data file (do not edit the following line - required for mem load use)\n" \
                     "// instance=/processor_tb/processor1/decode_inst/register_file_instance/registers_array\n" \
                     "// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1\n"
        f.write(filePrefix)
        for  i, instr in enumerate(instruction_array):
            # Convert instruction to binary format and write to file
            binary_instr = "".join(instr)
            f.write(str(i) + ": " + binary_instr + "\n")

# Main function
if __name__ == "__main__":
    assemble_file(sys.argv)
