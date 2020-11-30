#include<bits/stdc++.h>
using namespace std;
int main(int argc,char ** argv)
{
	string input = argv[1];
    input = "./Compiler/minicc " + input + " ./TempFiles/compiled.tac";
    //sprintf(input,"./Compiler/Compiler %s ./TempFiles/compiled.tac",argv[1]);
    system(input.c_str());
    system("./Virtual-Machine/VM ./TempFiles/compiled.tac ./TempFiles/assembly.txt");
    system("./Assembler/Assembler");
}
