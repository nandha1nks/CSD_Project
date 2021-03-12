#include <bits/stdc++.h>
#include "token.h"
using namespace std;

#define outputTemVM "temp.vm"

class VM
{
private:
    string ifname, ofname;
    vector<Token> tokens;
    string token;
    stack<vector<string>> localVars;
    stack<vector<string>> args;
    int inputLabel=0;
    void threeAddToVMCode();
    void vmCodeToAssembly();
    int get3acTypeOfInstruction(vector<Token>&);
    int getVMTypeOfInstruction(vector<Token>&);
    string getVMCode(string);
    string getAssemblyCode(string);
    string getSegmentPos(Token&);
    string memInit();
    string saveRegisters();
    string loadRegisters();

public:
    VM(string, string);
    void convertToAssembly();
};

VM::VM(string inputFileName, string outputFileName)
{
    ifname = inputFileName;
    ofname = outputFileName;
}

void VM::convertToAssembly()
{
    threeAddToVMCode();
    vmCodeToAssembly();
}

void VM::threeAddToVMCode()
{
    ifstream fin;
    ofstream fout;
    fin.open(ifname);
    fout.open(outputTemVM);
    string is, vms;
    while (getline(fin, is))
    {
        vms = getVMCode(is);
        fout << vms;
    }
    fin.close();
    fout.close();
}

string VM::getVMCode(string s)
{
    string segmentPos;
    // Arithmetic Operations And Assignment Statements

    // 1. Tokenize
    stringstream tokenizer(s);
    tokens.clear();
    while (getline(tokenizer, token, ' '))
    {
        Token t(token);
        tokens.push_back(t);
    }

    // 2. Match Format of 3 address code
    // Assignment - 0
    // Arithmetic, Logical - 1
    // Labels, Branching - 2
    // Function/method definition and return - 3
    // Function/methods call - 4
    // Function/methods parameters - 5
    // Variable declaration - 6
    // Input-Output - 7
    // New Line - 8
    // Syntax Error - 9

    int typeOfInstruction = get3acTypeOfInstruction(tokens);

    // 3. Convert to appropriate VM Code
    string vmcode = "";
    if (typeOfInstruction == 0)
    {
        // Assignment Operation
        segmentPos = getSegmentPos(tokens.at(2));
        vmcode = "push " + segmentPos + "\n";
        segmentPos = getSegmentPos(tokens.at(0));
        vmcode += "pop " + segmentPos + "\n";
    }
    else if (typeOfInstruction == 1)
    {
        // Arithmetic and Logical Operation
        segmentPos = getSegmentPos(tokens.at(2));
        vmcode = "push " + segmentPos + "\n";
        segmentPos = getSegmentPos(tokens.at(4));
        vmcode += "push " + segmentPos + "\n";

        string opType = tokens.at(3).name;
        if (opType.compare("+") == 0)
            vmcode += "add\n";
        else if (opType.compare("-") == 0)
            vmcode += "sub\n";
        else if (opType.compare("==") == 0)
            vmcode += "eq\n";
        else if (opType.compare("<") == 0)
            vmcode += "lt\n";
        else if (opType.compare("&&") == 0)
            vmcode += "and\n";
        else if (opType.compare("||") == 0)
            vmcode += "or\n";

        segmentPos = getSegmentPos(tokens.at(0));
        vmcode += "pop " + segmentPos + "\n";
    }
    else if(typeOfInstruction == 2)
    {
        // Labels and Branches
        
        // Label
        if(tokens.at(1).name.compare(":") == 0)
            vmcode += "label " + tokens.at(0).name;

        // Unconditional jump
        else if(tokens.at(0).name.compare("goto") == 0)
            vmcode += "goto " + tokens.at(1).name;

        // Conditional jump
        else if(tokens.at(2).name.compare("goto") == 0)
        {
            segmentPos = getSegmentPos(tokens.at(1));
            vmcode += "push " + segmentPos + "\n";
            vmcode += "if-goto " + tokens.at(3).name;
        }
            
        vmcode += "\n";
    }
    else if(typeOfInstruction == 3)
    {
        // Function/method definition and return
        if(tokens.at(0).name.compare("function")==0)
        {
            vector<string> v;
            localVars.push(v);
            for(int i=3; i<tokens.size(); i++)
                v.push_back(tokens.at(++i).name);
            args.push(v);

            vmcode += "function " + tokens.at(1).name + " " + tokens.at(2).name + "\n";

        }

        // Return
        else if(tokens.at(0).name.compare("return")==0)
        {

            // Void function
            if(tokens.size()==1)
            {
                vmcode += "push NULL\n";
                vmcode += "return\n";
            }

            // Non-void function
            else if(tokens.size()==2)
            {
                segmentPos = getSegmentPos(tokens.at(1));
                vmcode += "push " + segmentPos + "\n";
                vmcode += "return\n";
            }

            localVars.pop();
            args.pop();
        }
        
    }
    else if(typeOfInstruction == 4)
    {
        // Function/methods call

        //Void call
        if(tokens.at(0).name.compare("call") == 0)
            vmcode += "call " + tokens.at(1).name + " " + tokens.at(2).name + "\n";

        //Non-void call
        else if(tokens.at(2).name.compare("call") == 0)
        {
            vmcode += "call " + tokens.at(3).name + " " + tokens.at(4).name + "\n";
            segmentPos = getSegmentPos(tokens.at(0));
            vmcode += "pop " + segmentPos + "\n";
        }
    }
    else if(typeOfInstruction == 5)
    {
        // Function/methods parameters
        if(tokens.at(0).name.compare("pushParam") == 0)
        {
            segmentPos = getSegmentPos(tokens.at(1));
            vmcode += "push " + segmentPos + "\n";
        }
    }
    else if(typeOfInstruction == 6)
    {
        // Variable Declaration
        localVars.top().push_back(tokens.at(1).name);
    }
    else if(typeOfInstruction == 7)
    {
        // Input-Output
        segmentPos = getSegmentPos(tokens.at(1));
        
        // print
        if(tokens.at(0).name.compare("print") == 0)
            vmcode += "print " + segmentPos + "\n";
        
        // read
        else if(tokens.at(0).name.compare("read") == 0)
            vmcode += "read " + segmentPos + "\n";
    }
    else if(typeOfInstruction == 8)
    {
        // New line
        vmcode += "\n";
    }
    else
    {
        //Syntax Error
        cout << "Three Address Code Syntax ERROR : -" << endl;
        cout << s << endl;
    }
    return vmcode;
}

int VM::get3acTypeOfInstruction(vector<Token> &v)
{
    //New line
    if(v.empty())
        return 8;

    //Assignment - 0
    if (v.size() == 3 && v.at(1).name.compare("=")==0)
        return 0;

    //Arithmetic and Logical - 1
    else if (v.size() == 5 && v.at(1).name.compare("=")==0 && v.at(2).name.compare("call")!=0)
        return 1;

    // Function/method definition and return - 3
    else if(v.at(0).name.compare("function") == 0 || v.at(0).name.compare("return") == 0)
        return 3;

    // Lables and Branches - 2
    else if(v.size()>1 && (v.at(1).name.compare(":") == 0 || tokens.at(0).name.compare("goto") == 0 || tokens.at(0).name.compare("If") == 0))
        return 2;

    // Function/method calls - 4
    else if(v.size()>1 && (v.at(0).name.compare("call") == 0 || v.at(1).name.compare("=") == 0))
        return 4;

    // Functional Parameters - 5
    else if(v.at(0).name.compare("pushParam") == 0)
        return 5;

    // Variable declaration - 6
    else if(v.at(0).name.compare("int") == 0 || v.at(0).name.compare("char") == 0)
        return 6;

    // Input-Output
    else if(v.at(0).name.compare("print") == 0 || v.at(0).name.compare("read") == 0)
        return 7;

    // Syntax Error
    else
        return 9;
}

string VM::getSegmentPos(Token &t)
{
    string s = "";
    
    if(t.name.at(0)=='_')
    {
        s += "temp " + t.name.substr(2);
        return s;
    }

    if(t.name.at(0)=='\'' || isdigit(t.name.at(0)))
    {
        s += "constant " + t.name;
        return s;
    }

    vector <string> v = args.top();
    auto it = find(v.begin(), v.end(), t.name);
    if(it!=v.end())
    {
        s += "argument " + to_string(it-v.begin());
        return s;
    }

    v = localVars.top();
    it = find(v.begin(), v.end(), t.name);
    if(it!=v.end())
    {
        s += "local " + to_string(it-v.begin());
        return s;
    }

    cout<<"Not found!!! -> "<<t.name<<" -> adding to local"<<endl;

    s += "local " + to_string(localVars.top().size());
    localVars.top().push_back(t.name);
    return s;
}

void VM::vmCodeToAssembly()
{
    ifstream fin;
    ofstream fout;
    fin.open(outputTemVM);
    fout.open(ofname);
    string is, arm;

    arm = memInit();
    fout << arm;

    while (getline(fin, is))
    {
        arm = getAssemblyCode(is);
        fout << arm;
    }

    fin.close();
    fout.close();
}

string VM::memInit()
{
    string armcode = "";

    // SP,LCL,ARG init
    armcode += "li $r28,3\n";
    armcode += "sw $r28,$zero(0)\n";
    armcode += "sw $r28,$one(0)\n";
    armcode += "sw $r28,$one(1)\n";
    
    // Reg Stack pointer(RSP) init
    armcode += "li $r28,16389\n";
    armcode += "sw $r28,$zero(16388)\n";
    return armcode;
}

string VM::getAssemblyCode(string s)
{
    // 1. Tokenize
    stringstream tokenizer(s);
    tokens.clear();
    while (getline(tokenizer, token, ' '))
    {
        Token t(token);
        tokens.push_back(t);
    }


    // 2. Match Format of VM code
    // push - 0
    // pop - 1
    // Function/method declaration - 2
    // Function/methods call - 3
    // return - 4
    // Arihmetic, Logical - 5
    // if-goto - 6
    // goto - 7
    // Label - 8
    // print - 9
    // read - 10
    // New Line - 11
    // Syntax Error - 12

    int typeOfInstruction = getVMTypeOfInstruction(tokens);
    // cout<<s<<" -> "<<typeOfInstruction<<endl;
    // 3. Convert to appropriate assembly Code
    string armcode = "";
    if (typeOfInstruction == 0)
    {
        // push

        // temp
        if(tokens.at(1).name.compare("temp")==0)
        {
            // _ti <==> r(i%26)
            int regNo = (stoi(tokens.at(2).name))%26;

            // $ri -> MEM[SP]
            armcode += "\tlw $r28,$zero(0)\n";
            armcode += "\tsw $r" + to_string(regNo) + ",$r28(0)\n";

            // SP++
            armcode += "\tadd $r28,$r28,$one\n";
            armcode += "\tsw $r28,$zero(0)\n";
        }

        else
        {
            // local
            if(tokens.at(1).name.compare("local")==0)
            {
                // $r28 <- MEM[LCL + i]
                armcode += "\tlw $r27,$one(0)\n";
                armcode += "\tlw $r28,$r27(" + tokens.at(2).name + ")\n";
            }

            // argument
            else if(tokens.at(1).name.compare("argument")==0)
            {
                // $r28 <- MEM[ARG + i]
                armcode += "\tlw $r27,$one(1)\n";
                armcode += "\tlw $r28,$r27(" + tokens.at(2).name + ")\n";
            }

            // constant
            else if(tokens.at(1).name.compare("constant")==0)
                // $r28 <- constant
                armcode += "\tli $r28," + tokens.at(2).name + "\n";

            // $r28 -> MEM[SP]
            armcode += "\tlw $r27,$zero(0)\n";
            armcode += "\tsw $r28,$r27(0)\n";

            // SP++
            armcode += "\tadd $r27,$r27,$one\n";
            armcode += "\tsw $r27,$zero(0)\n";

        }
    }
    else if (typeOfInstruction == 1)
    {
        // pop

        // SP--
        armcode += "\tlw $r28,$zero(0)\n";
        armcode += "\taddi $r28,$r28,-1\n";
        armcode += "\tsw $r28,$zero(0)\n";

        // temp
        if(tokens.at(1).name.compare("temp")==0)
        {
            // _ti <==> r(i%26)
            int regNo = (stoi(tokens.at(2).name))%26;

            // $ri <- MEM[SP-1]
            armcode += "\tlw $r" + to_string(regNo) + ",$r28(0)\n";
        }

        else
        {
            
            // $r27 <- MEM[SP-1]
            armcode += "\tlw $r27,$r28(0)\n";

            // local
            if(tokens.at(1).name.compare("local")==0)
            {
                // $r27 -> MEM[LCL + i]
                armcode += "\tlw $r28,$one(0)\n";
                armcode += "\tsw $r27,$r28(" + tokens.at(2).name + ")\n";
            }

            // argument
            else if(tokens.at(1).name.compare("argument")==0)
            {
                // $r28 -> MEM[ARG + i]
                armcode += "\tlw $r28,$one(1)\n";
                armcode += "\tsw $r27,$r28(" + tokens.at(2).name + ")\n";
            }

        }
    }
    else if(typeOfInstruction == 2)
    {
        // Function/method declaration - 2
        armcode += tokens.at(1).name + ":\n";

        // push 0 in stack k times
        int k = stoi(tokens.at(2).name);
        if(k>0)
        { 
            armcode += "\tlw $r28,$zero(0)\n";
            while(k--)
            {
                armcode += "\tsw $zero,$r28(0)\n";
                armcode += "\tadd $r28,$r28,$one\n";
            }
            armcode += "\tsw $r28,$zero(0)\n";
        }
    }
    else if(typeOfInstruction == 3)
    {
        // Function/methods call - 3
        
        // push return-addr // save return-addr
        armcode += "\tlw $r28,$zero(0)\n";
        armcode += "\tsw $r29,$r28(0)\n";
        armcode += "\tadd $r28,$r28,$one\n";

        // push LCL // save LCL
        armcode += "\tlw $r27,$one(0)\n";
        armcode += "\tsw $r27,$r28(0)\n";
        armcode += "\tadd $r28,$r28,$one\n";

        // push ARG // save ARG
        armcode += "\tlw $r27,$one(1)\n";
        armcode += "\tsw $r27,$r28(0)\n";
        armcode += "\tadd $r28,$r28,$one\n";

        // ARG = SP - n - 3 // change ARG
        int n = stoi(tokens.at(2).name)+3;
        armcode += "\taddi $r27,$r28,-" + to_string(n) + "\n";
        armcode += "\tsw $r27,$one(1)\n";

        // Update SP
        armcode += "\tsw $r28,$zero(0)\n";

        // LCL = SP // change LCL
        armcode += "\tsw $r28,$one(0)\n";

        // save r0-r25 values
        armcode += saveRegisters();

        // goto fun // call function
        armcode += "\tjal " + tokens.at(1).name + "\n\n";

        // return-addr: // a label
        // armcode += tokens.at(1).name + "_return:\n";
        
    }
    else if(typeOfInstruction == 4)
    {
        // return - 4

        // FRAME = LCL //
        armcode += "\tlw $r28,$one(0)\n";

        // RET = *(FRAME - 3) // keep return-addr
        armcode += "\tadd $r26,$r29,$zero\n";
        armcode += "\taddi $r29,$r28,-3\n";
        armcode += "\tlw $r29,$r29(0)\n";

        // *ARG = pop() // return value
        armcode += "\tlw $r27,$zero(0)\n";
        armcode += "\taddi $r27,$r27,-1\n";
        armcode += "\tlw $r27,$r27(0)\n";
        armcode += "\tlw $r28,$one(1)\n";
        armcode += "\tsw $r27,$r28(0)\n";

        // SP = ARG + 1 // restore SP of called
        armcode += "\tadd $r28,$r28,$one\n";
        armcode += "\tsw $r28,$zero(0)\n";

        // ARG = *(FRAME - 1) // restore ARG
        armcode += "\tlw $r28,$one(0)\n";
        armcode += "\taddi $r28,$r28,-1\n";
        armcode += "\tlw $r27,$r28(0)\n";
        armcode += "\tsw $r27,$one(1)\n";

        // LCL = *(FRAME - 2) // restore LCL
        armcode += "\taddi $r28,$r28,-1\n";
        armcode += "\tlw $r27,$r28(0)\n";
        armcode += "\tsw $r27,$one(0)\n";

        // Load old register values
        armcode += loadRegisters();

        // goto RET // back to return-addr
        armcode += "\tjr $r26\n";
    }
    else if(typeOfInstruction == 5)
    {
        // Arihmetic, Logical - 5

        // $r28 <- SP-1
        armcode += "\tlw $r28,$zero(0)\n";
        armcode += "\taddi $r28,$r28,-1\n";

        // $r27 <- MEM[SP-1]
        armcode += "\tlw $r27,$r28(0)\n";

        // $r28 <- SP-2
        armcode += "\taddi $r28,$r28,-1\n";

        // $r26 <- MEM[SP-2]
        armcode += "\tlw $r26,$r28(0)\n";
        
        // perform operation
        if(tokens.at(0).name.compare("add")==0)
            armcode += "\tadd $r26,$r26,$r27\n";

        else if(tokens.at(0).name.compare("sub")==0)
            armcode += "\tsub $r26,$r26,$r27\n";

        else if(tokens.at(0).name.compare("eq")==0)
            armcode += "\tseq $r26,$r26,$r27\n";

        else if(tokens.at(0).name.compare("lt")==0)
            armcode += "\tslt $r26,$r26,$r27\n";

        else if(tokens.at(0).name.compare("and")==0)
            armcode += "\tand $r26,$r26,$r27\n";

        else if(tokens.at(0).name.compare("or")==0)
            armcode += "\tor $r26,$r26,$r27\n";

        // $r26 -> MEM[SP-2]
        armcode += "\tsw $r26,$r28(0)\n";

        // $r28 <- SP-1
        armcode += "\tadd $r28,$r28,$one\n";
        armcode += "\tsw $r28,$zero(0)\n";
    
    }
    else if(typeOfInstruction == 6)
    {
        // if-goto - 6

        // $r27 <- MEM[SP]
        armcode += "\tlw $r28,$zero(0)\n";
        armcode += "\taddi $r28,$r28,-1\n";
        armcode += "\tlw $r27,$r28(0)\n";

        // branch if $r27==$one
        armcode += "\tbeq $r27,$one," + tokens.at(1).name + "\n";
    
    }
    else if(typeOfInstruction == 7)
    {
        // goto - 7
        armcode += "\tj " + tokens.at(1).name + "\n";

    }
    else if(typeOfInstruction == 8)
    {
        // Label
        if(tokens.at(1).name.compare("end")==0)
        {
            armcode = "end:\n";
            armcode += "\tj end\n";
        }
        else
            armcode += tokens.at(1).name + ":\n";
    }
    else if(typeOfInstruction == 9)
    {
        // print
        
        // temp
        if(tokens.at(1).name.compare("temp")==0)
        {
            // _ti <==> r(i%26)
            int regNo = (stoi(tokens.at(2).name))%26;

            // $ri -> MEM[16387]
            armcode += "\tsw $r" + to_string(regNo) + ",$zero(16387)\n";
        }

        else
        {
            
            // local
            if(tokens.at(1).name.compare("local")==0)
            {
                // $r28 <- MEM[LCL + i]
                armcode += "\tlw $r28,$one(0)\n";
                armcode += "\tlw $r28,$r28(" + tokens.at(2).name + ")\n";
            }

            // argument
            else if(tokens.at(1).name.compare("argument")==0)
            {
                // $r28 <- MEM[ARG + i]
                armcode += "\tlw $r28,$one(1)\n";
                armcode += "\tlw $r28,$r28(" + tokens.at(2).name + ")\n";
            }

            // r28 -> MEM[16387]
            armcode += "\tsw $r28,$zero(16387)\n";
        }
    }
    else if(typeOfInstruction == 10)
    {
        // read
        
        // input_i:
        string label = "input_" + to_string(inputLabel++);
        armcode += label + ":\n";

        // $r28 <- MEM[16386]
        armcode += "\tlw $r28,$zero(16386)\n";
        armcode += "\tbeq $r28,$zero," + label + "\n";

        // temp
        if(tokens.at(1).name.compare("temp")==0)
        {
            // _ti <==> r(i%26)
            int regNo = (stoi(tokens.at(2).name))%26;

            // $ri <- MEM[16386]
            armcode += "\tadd $r" + to_string(regNo) + ",$r28,$zero\n";
        }

        else
        {
            
            // local
            if(tokens.at(1).name.compare("local")==0)
            {
                // $r27 <- LCL
                armcode += "\tlw $r27,$one(0)\n";
            }

            // argument
            else if(tokens.at(1).name.compare("argument")==0)
            {
                // $r27 <- ARG
                armcode += "\tlw $r27,$one(1)\n";
            }

            // r28 -> MEM[16387]
            armcode += "\tsw $r28,$r27(" + tokens.at(2).name + ")\n";
        }
    }
    else if(typeOfInstruction == 11)
    {
        // New line
        armcode += "\n";
    }
    else
    {
        //Syntax Error
        cout << "VM Code Syntax ERROR : -" << endl;
        cout << s << endl;
    }
    return armcode;
}

int VM::getVMTypeOfInstruction(vector<Token> &v)
{
    //New Line
    if(v.empty())
        return 11;

    else if(v.at(0).name.compare("push")==0)
        return 0;
    else if(v.at(0).name.compare("pop")==0)
        return 1;
    else if(v.at(0).name.compare("function")==0)
        return 2;
    else if(v.at(0).name.compare("call")==0)
        return 3;
    else if(v.at(0).name.compare("return")==0)
        return 4;

    // Arithmetic, Logical
    else if(v.size()==1)
        return 5;

    else if(v.at(0).name.compare("if-goto")==0)
        return 6;
    else if(v.at(0).name.compare("goto")==0)
        return 7;
    else if(v.at(0).name.compare("label")==0)
        return 8;
    else if(v.at(0).name.compare("print")==0)
        return 9;
    else if(v.at(0).name.compare("read")==0)
        return 10;
    
    // Syntax Error
    else
        return 12;
}

string VM::saveRegisters()
{
    string armcode = "";
    armcode += "\tlw $r28,$zero(16388)\n";
    for(int i=0; i<=25; i++)
    {
        armcode += "\tsw $r" + to_string(i) + ",$r28(0)\n";
        armcode += "\tadd $r28,$r28,$one\n";
    }
    armcode += "\tsw $r28,$zero(16388)\n";
    return armcode;
}

string VM::loadRegisters()
{
    string armcode = "";
    armcode += "\tlw $r28,$zero(16388)\n";
    for(int i=25; i>=0; i--)
    {
        armcode += "\taddi $r28,$r28,-1\n";
        armcode += "\tlw $r" + to_string(i) + ",$r28(0)\n";
    }
    armcode += "\tsw $r28,$zero(16388)\n";
    return armcode;
}